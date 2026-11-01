import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'reset_flow.dart';

/// One earlier reset, read-only (F-034): every prompt the user answered or
/// skipped then, grouped by phase, with their words exactly as written.
class PastResetScreen extends StatelessWidget {
  const PastResetScreen({super.key, required this.journeyId});

  final String journeyId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = CarthaPalette.of(context);
    Journey? journey;
    for (final j in state.pastJourneys) {
      if (j.id == journeyId) journey = j;
    }
    if (journey == null) {
      return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          top: false,
          child: ReadingColumn(
            children: [EmptyState(title: l.resetPastMissing)],
          ),
        ),
      );
    }
    final j = journey;
    final dates = [
      l.resetPastStarted(formatDay(context, j.startedAt)),
      if (j.completedAt != null)
        l.resetPastFinished(formatDay(context, j.completedAt!))
      else
        l.resetPastUnfinished,
    ].join(' · ');
    final leftOpen = state.content.corePrompts
        .where((x) => statusOf(j.answer(x.id)) == PromptStatus.open)
        .length;
    final sections = <Widget>[];
    for (final phase in PromptPhase.values) {
      final touched = [
        for (final prompt in state.content.byPhase(phase))
          if (statusOf(j.answer(prompt.id)) != PromptStatus.open) prompt,
      ];
      if (touched.isEmpty) continue;
      sections
        ..add(SectionTitle(phaseName(l, phase)))
        ..addAll([
          for (final prompt in touched) ...[
            _PastAnswer(prompt: prompt, answer: j.answer(prompt.id)!),
            const SizedBox(height: 12),
          ],
        ]);
    }
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ReadingColumn(
          children: [
            ScreenHeader(
              title: l.resetPastScreenTitle,
              subtitle: dates,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(Icons.lock_outline, size: 18, color: p.accent),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.resetPastReadOnly,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sections.isEmpty)
              EmptyState(title: l.resetPastEmpty, icon: Icons.history)
            else
              ...sections,
            if (sections.isNotEmpty && leftOpen > 0)
              Text(
                l.resetPastLeftOpen(leftOpen),
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _PastAnswer extends StatelessWidget {
  const _PastAnswer({required this.prompt, required this.answer});

  final Prompt prompt;
  final ReflectionAnswer answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = statusOf(answer);
    return SectionCard(
      title: prompt.title,
      trailing: status == PromptStatus.skipped
          ? const PromptStatusTag(status: PromptStatus.skipped)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(prompt.question, style: theme.textTheme.bodySmall),
          if (answer.answered) ...[
            const SizedBox(height: 10),
            // Plain text, exactly as written.
            Text(answer.body, style: theme.textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}
