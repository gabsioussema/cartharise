import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'missions_copy.dart';
import 'missions_logic.dart';

/// The optional thirty-day path (F-057): thirty day cards grouped Observe /
/// Experiment / Build / Adjust. Every day is open on any day (D-08); a
/// written day carries an icon + "Written" label, never a streak.
class PathGrid extends StatelessWidget {
  const PathGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final days = state.content.thirtyDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(l.missionsPathTitle, style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: 4),
        Text(
          l.missionsPathIntro,
          style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ChipTag(
            label: l.missionsPathWrittenCount(state.pathWrittenCount),
            icon: Icons.edit_note,
          ),
        ),
        for (final stage in PathStage.values)
          if (days.any((d) => d.stage == stage)) ...[
            const SizedBox(height: 20),
            _StageHeader(
              stage: stage,
              days: [
                for (final d in days)
                  if (d.stage == stage) d.day,
              ],
            ),
            const SizedBox(height: 10),
            _DayGrid(
              days: [
                for (final d in days)
                  if (d.stage == stage) d,
              ],
            ),
          ],
      ],
    );
  }
}

class _StageHeader extends StatelessWidget {
  const _StageHeader({required this.stage, required this.days});

  final PathStage stage;
  final List<int> days;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final from = days.reduce(math.min);
    final to = days.reduce(math.max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            '${pathStageLabel(l, stage)} · ${l.missionsStageDays(from, to)}',
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 2),
        Text(pathStageHelp(l, stage), style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Rows of equal-height day cards; the column count follows the width and
/// the text size (one column on a small phone at 200 %).
class _DayGrid extends StatelessWidget {
  const _DayGrid({required this.days});

  final List<PathDay> days;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / (112 * scale)).floor().clamp(
          1,
          6,
        );
        return Column(
          children: [
            for (var start = 0; start < days.length; start += columns)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < columns; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(
                          child: start + i < days.length
                              ? _DayCard(day: days[start + i])
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.day});

  final PathDay day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final written = context.select((AppState s) => s.pathWritten(day.day));
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
          key: ValueKey('path-day-${day.day}'),
          color: written ? p.selection : p.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
            side: written
                ? BorderSide(color: p.accent, width: 1.5)
                : BorderSide(color: p.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => AppNav.openPathDay(context, day.day),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.missionsDayLabel(day.day),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: p.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(day.title, style: theme.textTheme.bodyMedium),
                  if (written) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: p.accent),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            l.missionsDayWritten,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: p.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
