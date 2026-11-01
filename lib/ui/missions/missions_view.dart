import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/formatting.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'lever_drafts_card.dart';
import 'missions_copy.dart';
import 'missions_logic.dart';
import 'path_grid.dart';
import 'quest_sheet.dart';
import 'quest_tile.dart';

/// The Missions section (F-027–F-031, F-057): lever drafts, Today /
/// Anytime & upcoming / Done (collapsed), the month project and the 30-day
/// path. No streaks, points or "missed" states anywhere.
class MissionsView extends StatelessWidget {
  const MissionsView({
    super.key,
    this.leversHandledFor,
    required this.onLeversHandled,
  });

  /// The daily-levers text whose drafts were already added or put aside
  /// this session (the card stays hidden until the levers change).
  final String? leversHandledFor;
  final ValueChanged<String> onLeversHandled;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final day = state.today;
    final sections = state.missionSections(day);
    final drafts = state.leverDrafts;
    final levers = state.compass.dailyLevers;
    Widget tiles(List<Quest> quests) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final q in quests)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8),
            child: QuestTile(key: ValueKey(q.id), quest: q, day: day),
          ),
      ],
    );
    Widget calm(String text) => Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
      ),
    );
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.missionsIntro,
            style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: SaveIndicator(),
          ),
          const SizedBox(height: 8),
          if (drafts.isNotEmpty && leversHandledFor != levers) ...[
            LeverDraftsCard(
              drafts: drafts,
              onFinished: () => onLeversHandled(levers),
            ),
            const SizedBox(height: 20),
          ],
          _ListHeader(
            title: l.missionsToday,
            subtitle: formatDay(context, parseDateKey(day)),
          ),
          if (sections.today.isEmpty)
            calm(l.missionsTodayEmpty)
          else
            tiles(sections.today),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SecondaryButton(
              key: const ValueKey('missions-add-quest'),
              label: l.missionsAddQuest,
              icon: Icons.add,
              onPressed: () => showQuestSheet(context),
            ),
          ),
          const SizedBox(height: 24),
          _ListHeader(title: l.missionsLater),
          if (sections.later.isEmpty)
            calm(l.missionsLaterEmpty)
          else
            tiles(sections.later),
          if (sections.done.isNotEmpty)
            ExpansionTile(
              // Its own storage slot: the scroll view's offset lives above.
              key: const PageStorageKey<String>('missions-done'),
              tilePadding: EdgeInsetsDirectional.zero,
              childrenPadding: EdgeInsetsDirectional.zero,
              shape: const Border(),
              collapsedShape: const Border(),
              iconColor: p.accent,
              collapsedIconColor: p.textSecondary,
              title: Text(
                l.missionsDone(sections.done.length),
                style: theme.textTheme.titleMedium,
              ),
              children: [tiles(sections.done)],
            ),
          const SizedBox(height: 24),
          const _ProjectCard(),
          const SizedBox(height: 28),
          const PathGrid(),
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.titleLarge),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

/// The month project at a glance → [ProjectScreen] (F-030).
class _ProjectCard extends StatelessWidget {
  const _ProjectCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final project = state.data.project;
    final fromCompass = state.compass.monthProject.trim();
    return SectionCard(
      key: const ValueKey('missions-project'),
      icon: Icons.calendar_month_outlined,
      title: l.missionsProjectTitle,
      trailing: Icon(Icons.chevron_right, color: p.textSecondary),
      onTap: () => AppNav.openProject(context),
      child: project == null
          ? Text(
              fromCompass.isEmpty
                  ? l.missionsProjectEmpty
                  : l.missionsProjectFromCompass(fromCompass),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title.trim().isEmpty
                      ? l.missionsProjectUntitled
                      : project.title,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    ChipTag(
                      label: projectStatusLabel(l, project.status),
                      icon: projectStatusIcon(project.status),
                      tone: ChipTone.accent,
                    ),
                    if (project.milestones.isNotEmpty)
                      ChipTag(
                        label: l.missionsProjectMilestones(
                          project.milestones.where((m) => m.done).length,
                          project.milestones.length,
                        ),
                        icon: Icons.flag_outlined,
                      ),
                  ],
                ),
              ],
            ),
    );
  }
}
