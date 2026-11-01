import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../awakening/lesson_card.dart';
import '../journal/past_reset_screen.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'reset_flow.dart';

/// The Reset hub (PLAN.md §2): pace, optional lessons, the three phases with
/// calm progress, "Continue" to the resume point, past resets and "Start a
/// new reset". Nothing here is locked: every phase and prompt can be opened
/// at any time (F-046).
class ResetTab extends StatelessWidget {
  const ResetTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final journey = state.journey;
    final started = journey.answers.isNotEmpty || journey.completedAt != null;
    final past = state.pastJourneys;
    return Scaffold(
      body: SafeArea(
        child: ReadingColumn(
          top: 0,
          children: [
            ScreenHeader(
              title: l.resetTitle,
              subtitle: l.resetSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 12),
            ),
            const _PaceNote(),
            const SizedBox(height: 16),
            const _ProgressCard(),
            const SizedBox(height: 24),
            const LessonStrip(),
            const SizedBox(height: 16),
            SectionTitle(l.resetPhasesTitle),
            const _MorningCard(),
            const SizedBox(height: 16),
            const _DaytimeCard(),
            const SizedBox(height: 16),
            const _EveningCard(),
            if (past.isNotEmpty) ...[
              const SizedBox(height: 24),
              _PastResets(journeys: past),
            ],
            if (started) ...[const SizedBox(height: 24), const _NewResetCard()],
          ],
        ),
      ),
    );
  }
}

class _PaceNote extends StatelessWidget {
  const _PaceNote();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pace = context.select(
      (AppState s) => s.data.profile?.pace ?? Pace.flexible,
    );
    final oneDay = pace == Pace.oneDay;
    return SectionCard(
      icon: oneDay ? Icons.wb_sunny_outlined : Icons.self_improvement,
      title: oneDay ? l.resetPaceOneDayTitle : l.resetPaceFlexibleTitle,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(oneDay ? l.resetPaceOneDayBody : l.resetPaceFlexibleBody),
          TextLinkButton(
            label: l.resetPaceChange,
            onPressed: () => AppNav.switchTab(context, AppTab.you),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final journey = state.journey;
    final core = state.content.corePrompts;
    final coreProgress = progressOf(core, journey);
    final next = state.nextPrompt;
    final touched = journey.answers.isNotEmpty;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProgressRing(value: state.coreProgress),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l.resetProgressTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.resetProgressCount(
                        coreProgress.answered,
                        coreProgress.total,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (journey.completedAt != null) ...[
            Text(l.resetCompletedOn(formatDay(context, journey.completedAt!))),
            const SizedBox(height: 12),
          ],
          if (next != null) ...[
            Text(
              l.resetProgressNext(next.title),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              '${phaseName(l, next.phase)} · '
              '${l.resetQuestionOf(next.ordinal, state.content.byPhase(next.phase).length)}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: touched ? l.resetContinue : l.resetBegin,
              trailingIcon: Icons.arrow_forward,
              expand: true,
              onPressed: () => AppNav.openPrompt(context, next.id),
            ),
          ] else ...[
            Text(l.resetAllDoneBody),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l.resetSeeCreated,
              trailingIcon: Icons.arrow_forward,
              expand: true,
              onPressed: () => AppNav.openResetComplete(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// A phase card: ring with counts, title, subtitle and its rows.
class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.children,
  });

  final String title;
  final String subtitle;
  final PhaseProgress progress;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = CarthaPalette.of(context);
    final words = progressWords(l, progress);
    return SectionCard(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProgressRing(
                value: progress.fraction,
                size: 56,
                label: l.resetRingLabel(progress.answered, progress.total),
                semanticLabel: words,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(title, style: theme.textTheme.titleMedium),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: p.accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(words, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

/// A tappable row inside a phase card. Status is an icon plus words.
class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.onTap,
    this.leading,
    this.lines = const [],
    this.tags = const [],
  });

  final String title;
  final Widget? leading;
  final List<String> lines;
  final List<Widget> tags;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = CarthaPalette.of(context);
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: theme.textTheme.titleSmall),
                        for (final line in lines) ...[
                          const SizedBox(height: 2),
                          Text(line, style: theme.textTheme.bodySmall),
                        ],
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(spacing: 8, runSpacing: 6, children: tags),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ExcludeSemantics(
                    child: Icon(Icons.chevron_right, color: p.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A row for one prompt: status icon, title, optional time, status word.
class _PromptRow extends StatelessWidget {
  const _PromptRow({required this.prompt, this.optional = false});

  final Prompt prompt;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final status = statusOf(state.answer(prompt.id));
    final time = checkinTimeOf(state, prompt);
    return _Row(
      leading: Padding(
        padding: const EdgeInsetsDirectional.only(top: 1),
        child: PromptStatusIcon(status: status),
      ),
      title: prompt.title,
      lines: [statusLabel(l, status)],
      tags: [
        if (time != null)
          ChipTag(
            label: l.resetCheckinTime(formatLocalTime(context, time)),
            icon: Icons.schedule,
            tone: ChipTone.accent,
          ),
        if (optional) ChipTag(label: l.resetOptionalChip),
      ],
      onTap: () => AppNav.openPrompt(context, prompt.id),
    );
  }
}

/// A row for a subflow (The Mirror, The Vision, The Breakthrough): opens its
/// first open prompt, or its first prompt when all are done.
class _SubflowRow extends StatelessWidget {
  const _SubflowRow({
    required this.title,
    required this.body,
    required this.prompts,
  });

  final String title;
  final String body;
  final List<Prompt> prompts;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final progress = progressOf(prompts, state.journey);
    return _Row(
      title: title,
      lines: [body, progressWords(l, progress)],
      onTap: () {
        final target = firstOpenOrFirst(prompts, state.journey);
        if (target != null) AppNav.openPrompt(context, target.id);
      },
    );
  }
}

class _MorningCard extends StatelessWidget {
  const _MorningCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final morning = state.content.byPhase(PromptPhase.morning);
    final mirror = [
      for (final p in morning)
        if (p.group.subflow == ResetSubflow.mirror) p,
    ];
    final vision = [
      for (final p in morning)
        if (p.group.subflow == ResetSubflow.vision) p,
    ];
    return _PhaseCard(
      title: l.resetPhaseMorning,
      subtitle: '${l.resetSubflowMirror} · ${l.resetSubflowVision}',
      progress: state.progressFor(PromptPhase.morning),
      children: [
        if (mirror.isNotEmpty)
          _SubflowRow(
            title: l.resetSubflowMirror,
            body: l.resetMirrorBody,
            prompts: mirror,
          ),
        if (vision.isNotEmpty)
          _SubflowRow(
            title: l.resetSubflowVision,
            body: l.resetVisionBody,
            prompts: vision,
          ),
      ],
    );
  }
}

class _DaytimeCard extends StatelessWidget {
  const _DaytimeCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final daytime = state.content.byPhase(PromptPhase.daytime);
    final bonus = state.content.byPhase(PromptPhase.bonus);
    return _PhaseCard(
      title: l.resetPhaseDaytime,
      subtitle: l.resetSubflowInterrupt,
      progress: state.progressFor(PromptPhase.daytime),
      children: [
        Text(l.resetInterruptBody, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        for (final p in daytime) _PromptRow(prompt: p),
        if (bonus.isNotEmpty) ...[
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l.resetOptionalTitle,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ChipTag(label: l.resetOptionalChip),
            ],
          ),
          const SizedBox(height: 4),
          Text(l.resetOptionalBody, style: theme.textTheme.bodySmall),
          const SizedBox(height: 4),
          for (final p in bonus) _PromptRow(prompt: p, optional: true),
        ],
      ],
    );
  }
}

class _EveningCard extends StatelessWidget {
  const _EveningCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final evening = state.content.byPhase(PromptPhase.evening);
    return _PhaseCard(
      title: l.resetPhaseEvening,
      subtitle: l.resetSubflowBreakthrough,
      progress: state.progressFor(PromptPhase.evening),
      children: [
        _SubflowRow(
          title: l.resetSubflowBreakthrough,
          body: l.resetBreakthroughBody,
          prompts: evening,
        ),
      ],
    );
  }
}

class _PastResets extends StatelessWidget {
  const _PastResets({required this.journeys});

  final List<Journey> journeys;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SectionCard(
      title: l.resetPastTitle,
      icon: Icons.history,
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final j in journeys)
            _Row(
              title: l.resetPastStarted(formatDay(context, j.startedAt)),
              lines: [
                if (j.completedAt != null)
                  l.resetPastFinished(formatDay(context, j.completedAt!))
                else
                  l.resetPastUnfinished,
                l.resetPastAnswerCount(
                  j.answers.values.where((a) => a.answered).length,
                ),
              ],
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PastResetScreen(journeyId: j.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NewResetCard extends StatelessWidget {
  const _NewResetCard();

  Future<void> _start(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final ok = await confirmDialog(
      context,
      title: l.resetNewConfirmTitle,
      body: l.resetNewConfirmBody,
      action: l.resetNewConfirmAction,
    );
    if (!ok) return;
    await state.startNewJourney();
    messenger?.showSnackBar(SnackBar(content: Text(l.resetNewStarted)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SectionCard(
      title: l.resetNewTitle,
      icon: Icons.restart_alt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.resetNewBody),
          const SizedBox(height: 12),
          SecondaryButton(
            label: l.resetNewConfirmAction,
            icon: Icons.restart_alt,
            expand: true,
            onPressed: () => _start(context),
          ),
        ],
      ),
    );
  }
}
