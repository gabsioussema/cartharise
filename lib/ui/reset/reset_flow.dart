import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../domain/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/headers.dart';

/// Where one prompt stands in a journey. Shown with an icon AND a word,
/// never by colour alone.
enum PromptStatus { open, answered, skipped }

PromptStatus statusOf(ReflectionAnswer? answer) {
  if (answer == null) return PromptStatus.open;
  if (answer.answered) return PromptStatus.answered;
  if (answer.skipped) return PromptStatus.skipped;
  return PromptStatus.open;
}

/// The order Back / Save & continue / Skip walk through: the core reset
/// (morning → daytime → evening) for core prompts, or the three optional
/// contemplations on their own.
List<Prompt> resetSequenceFor(ContentLibrary content, Prompt prompt) {
  if (!prompt.core) {
    return content.byPhase(prompt.phase).where((p) => !p.core).toList();
  }
  return [
    for (final phase in PromptPhase.values)
      ...content.byPhase(phase).where((p) => p.core),
  ];
}

/// The first prompt of [prompts] that is neither answered nor skipped, else
/// the first one (so the user can revisit).
Prompt? firstOpenOrFirst(List<Prompt> prompts, Journey journey) {
  if (prompts.isEmpty) return null;
  for (final p in prompts) {
    if (statusOf(journey.answer(p.id)) == PromptStatus.open) return p;
  }
  return prompts.first;
}

/// Answered / skipped / total of [prompts] in [journey] (works for past
/// journeys too, unlike `AppState.progressFor`).
PhaseProgress progressOf(List<Prompt> prompts, Journey journey) {
  var answered = 0, skipped = 0;
  for (final p in prompts) {
    switch (statusOf(journey.answer(p.id))) {
      case PromptStatus.answered:
        answered++;
      case PromptStatus.skipped:
        skipped++;
      case PromptStatus.open:
        break;
    }
  }
  return PhaseProgress(
    answered: answered,
    skipped: skipped,
    total: prompts.length,
  );
}

/// The local `HH:MM` of a daytime check-in: the user's reminder time, else
/// the source default.
String? checkinTimeOf(AppState state, Prompt prompt) {
  if (prompt.phase != PromptPhase.daytime) return null;
  for (final r in state.reminders) {
    if (r.promptId == prompt.id) return r.time;
  }
  return prompt.defaultTime;
}

/// `HH:MM` in the device's clock format ("13:30" or "1:30 PM").
String formatLocalTime(BuildContext context, String hhmm) {
  try {
    final (h, m) = parseClock(hhmm);
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: h, minute: m),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  } on FormatException {
    return hhmm;
  }
}

/// A readable date ("Nov 3, 2026") in the device locale.
String formatDay(BuildContext context, DateTime time) =>
    MaterialLocalizations.of(context).formatShortDate(time.toLocal());

String phaseName(AppLocalizations l, PromptPhase phase) => switch (phase) {
  PromptPhase.morning => l.resetPhaseMorning,
  PromptPhase.daytime => l.resetPhaseDaytime,
  PromptPhase.bonus => l.resetPhaseBonus,
  PromptPhase.evening => l.resetPhaseEvening,
};

String subflowName(AppLocalizations l, ResetSubflow subflow) =>
    switch (subflow) {
      ResetSubflow.mirror => l.resetSubflowMirror,
      ResetSubflow.vision => l.resetSubflowVision,
      ResetSubflow.interrupt => l.resetSubflowInterrupt,
      ResetSubflow.breakthrough => l.resetSubflowBreakthrough,
    };

String groupName(AppLocalizations l, PromptGroup group) => switch (group) {
  PromptGroup.currentReality => l.resetGroupCurrentReality,
  PromptGroup.antiVision => l.resetGroupAntiVision,
  PromptGroup.identity => l.resetGroupIdentity,
  PromptGroup.vision => l.resetGroupVision,
  PromptGroup.interrupt => l.resetGroupInterrupt,
  PromptGroup.contemplation => l.resetGroupContemplation,
  PromptGroup.insight => l.resetGroupInsight,
  PromptGroup.direction => l.resetGroupDirection,
  PromptGroup.plan => l.resetGroupPlan,
};

String statusLabel(AppLocalizations l, PromptStatus status) => switch (status) {
  PromptStatus.answered => l.resetStateAnswered,
  PromptStatus.skipped => l.resetStateSkipped,
  PromptStatus.open => l.resetStateOpen,
};

/// Counts in words ("3 of 6 answered, 1 skipped").
String progressWords(AppLocalizations l, PhaseProgress p) {
  if (p.answered == 0 && p.skipped == 0) return l.resetCountNotStarted;
  if (p.skipped == 0) return l.resetCountAnswered(p.answered, p.total);
  return l.resetCountAnsweredSkipped(p.answered, p.total, p.skipped);
}

/// The status icon that goes with [statusLabel] (decorative: the label
/// carries the meaning).
class PromptStatusIcon extends StatelessWidget {
  const PromptStatusIcon({super.key, required this.status, this.size = 22});

  final PromptStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final (icon, color) = switch (status) {
      PromptStatus.answered => (Icons.check_circle, p.accent),
      PromptStatus.skipped => (Icons.redo, p.textSecondary),
      PromptStatus.open => (Icons.radio_button_unchecked, p.textSecondary),
    };
    return ExcludeSemantics(
      child: Icon(icon, size: size, color: color),
    );
  }
}

/// A status chip: icon + word.
class PromptStatusTag extends StatelessWidget {
  const PromptStatusTag({super.key, required this.status});

  final PromptStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ChipTag(
      label: statusLabel(l, status),
      icon: switch (status) {
        PromptStatus.answered => Icons.check,
        PromptStatus.skipped => Icons.redo,
        PromptStatus.open => Icons.radio_button_unchecked,
      },
      tone: status == PromptStatus.answered
          ? ChipTone.success
          : ChipTone.neutral,
    );
  }
}

/// A small uppercase bronze label above a title (board style).
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: CarthaPalette.of(context).accent,
      letterSpacing: 1.4,
      fontWeight: FontWeight.w600,
    ),
  );
}

/// A section heading inside a page.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: 8, bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(text, style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// The scrolling column every Reset / Awakening screen uses: 20 dp gutters
/// on phones, a centred reading column (≤ 720 dp) on tablets.
class ReadingColumn extends StatelessWidget {
  const ReadingColumn({
    super.key,
    required this.children,
    this.controller,
    this.top = 8,
  });

  final List<Widget> children;
  final ScrollController? controller;
  final double top;

  static const double maxWidth = 720;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final side = math.max(20.0, (constraints.maxWidth - maxWidth) / 2);
      return ListView(
        controller: controller,
        padding: EdgeInsetsDirectional.fromSTEB(side, top, side, 32),
        children: children,
      );
    },
  );
}

/// Opens a scrollable bottom sheet that honours reduced motion and never
/// grows past 85 % of the screen.
Future<T?> showResetSheet<T>(
  BuildContext context, {
  required String title,
  required List<Widget> Function(BuildContext sheetContext) children,
  required bool motion,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  sheetAnimationStyle: motion ? null : AnimationStyle.noAnimation,
  builder: (sheetContext) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
    ),
    child: SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 12),
          ...children(sheetContext),
        ],
      ),
    ),
  ),
);
