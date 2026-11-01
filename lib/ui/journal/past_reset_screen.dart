import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'journal_kit.dart';

/// An earlier reset, read-only (F-034): the answers per prompt, grouped by
/// phase, exactly as written. The user may choose to show their current
/// answers alongside (F-035). No scores, ratings or labels.
///
/// The one screen for an earlier reset, opened from Journal › Look back and
/// from Reset › Past resets, so it reads the same from both.
class PastResetScreen extends StatefulWidget {
  const PastResetScreen({super.key, required this.journeyId});

  final String journeyId;

  @override
  State<PastResetScreen> createState() => _PastResetScreenState();
}

class _PastResetScreenState extends State<PastResetScreen> {
  bool _compare = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final journey = state.pastJourneyById(widget.journeyId);
    if (journey == null) {
      return Scaffold(
        appBar: AppBar(),
        body: AreaListView(
          children: [
            EmptyState(
              icon: Icons.history,
              title: l.journalPastResetMissingTitle,
            ),
          ],
        ),
      );
    }

    final current = state.journey;
    final hasCurrent = current.id != journey.id && current.answers.isNotEmpty;
    final known = <String>{};
    final sections = <Widget>[];
    for (final phase in PromptPhase.values) {
      final cards = <Widget>[];
      for (final prompt in state.content.byPhase(phase)) {
        known.add(prompt.id);
        final answer = journey.answer(prompt.id);
        if (answer == null || (!answer.answered && !answer.skipped)) continue;
        cards.add(
          _AnswerCard(
            key: ValueKey('past-answer-${prompt.id}'),
            title: prompt.title,
            question: prompt.question,
            answer: answer,
            current: _compare && hasCurrent ? current.answer(prompt.id) : null,
            showCurrent: _compare && hasCurrent,
          ),
        );
      }
      if (cards.isEmpty) continue;
      sections
        ..add(AreaSectionLabel(phaseLabel(l, phase)))
        ..addAll([
          for (final c in cards)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: c,
            ),
        ]);
    }
    // Answers to prompts no longer in the content stay readable.
    final other = [
      for (final a in journey.answers.values)
        if (!known.contains(a.promptId) && a.answered) a,
    ];
    if (other.isNotEmpty) {
      sections.add(AreaSectionLabel(l.journalPastResetOther));
      for (final a in other) {
        sections.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 12),
            child: _AnswerCard(
              title: a.promptId,
              answer: a,
              showCurrent: false,
            ),
          ),
        );
      }
    }

    final subtitle = [
      l.journalResetStarted(formatDay(context, journey.startedAt)),
      if (journey.completedAt != null)
        l.journalResetCompleted(formatDay(context, journey.completedAt!))
      else
        l.journalPastResetUnfinished,
    ].join(' · ');
    // Core questions neither answered nor skipped then (said calmly).
    final leftOpen = state.content.corePrompts.where((prompt) {
      final a = journey.answer(prompt.id);
      return a == null || (!a.answered && !a.skipped);
    }).length;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AreaListView(
          children: [
            ScreenHeader(
              title: l.journalPastResetTitle,
              subtitle: subtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
            ),
            Text(
              l.journalPastResetReadOnly,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
              ),
            ),
            if (hasCurrent) ...[
              const SizedBox(height: 8),
              SectionCard(
                padding: EdgeInsetsDirectional.zero,
                child: SwitchListTile(
                  key: const ValueKey('past-reset-compare'),
                  title: Text(l.journalPastResetCompare),
                  value: _compare,
                  onChanged: (v) => setState(() => _compare = v),
                ),
              ),
            ],
            if (sections.isEmpty)
              EmptyState(icon: Icons.history, title: l.journalPastResetNone)
            else ...[
              ...sections,
              if (leftOpen > 0)
                Text(
                  l.journalPastResetLeftOpen(leftOpen),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    super.key,
    required this.title,
    required this.answer,
    required this.showCurrent,
    this.question,
    this.current,
  });

  final String title;
  final String? question;
  final ReflectionAnswer answer;
  final bool showCurrent;
  final ReflectionAnswer? current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    Widget label(String text) => Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 4),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: p.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    Widget words(ReflectionAnswer? a, String emptyText) {
      if (a != null && a.answered) {
        return SelectableText(a.body, style: theme.textTheme.bodyLarge);
      }
      if (a != null && a.skipped) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: ChipTag(label: l.journalPastResetSkipped, icon: Icons.redo),
        );
      }
      return Text(
        emptyText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: p.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return SectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (question != null) ...[
            Text(
              question!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (showCurrent) label(l.journalPastResetThen),
          words(answer, l.journalPastResetSkipped),
          if (showCurrent) ...[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
              child: Divider(color: p.border),
            ),
            label(l.journalPastResetNow),
            words(current, l.journalPastResetNoCurrent),
          ],
        ],
      ),
    );
  }
}
