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
import 'board_view.dart';
import 'lever_drafts_card.dart';
import 'missions_copy.dart';
import 'missions_logic.dart';
import 'path_grid.dart';
import 'quest_sheet.dart';
import 'quest_tile.dart';

/// How Missions shows the quests: the list (Today / Anytime & upcoming /
/// Done) or the board (Later → Ready → Doing → Done). One task list, two
/// views.
enum MissionsLayout { list, board }

/// The Missions section (F-027–F-031, F-057): lever drafts, the quests as a
/// list (Today / Anytime & upcoming / Done, collapsed) or as a board
/// ([QuestBoard]), the month project and the 30-day path. No streaks,
/// points or "missed" states anywhere.
///
/// The view (List by default) and the board's Today filter are kept while
/// the app runs (the route's [PageStorage]), not saved.
class MissionsView extends StatefulWidget {
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
  State<MissionsView> createState() => _MissionsViewState();
}

class _MissionsViewState extends State<MissionsView> {
  static const _layoutId = 'missions-layout';
  static const _todayOnlyId = 'missions-board-today';

  MissionsLayout _layout = MissionsLayout.list;
  bool _todayOnly = false;
  bool _restored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    _restored = true;
    final bucket = PageStorage.maybeOf(context);
    final layout = bucket?.readState(context, identifier: _layoutId);
    if (layout is MissionsLayout) _layout = layout;
    final todayOnly = bucket?.readState(context, identifier: _todayOnlyId);
    if (todayOnly is bool) _todayOnly = todayOnly;
  }

  void _setLayout(MissionsLayout layout) {
    if (layout == _layout) return;
    setState(() => _layout = layout);
    PageStorage.maybeOf(context)
        ?.writeState(context, layout, identifier: _layoutId);
  }

  void _setTodayOnly(bool on) {
    if (!mounted || on == _todayOnly) return;
    setState(() => _todayOnly = on);
    PageStorage.maybeOf(context)
        ?.writeState(context, on, identifier: _todayOnlyId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final drafts = state.leverDrafts;
    final levers = state.compass.dailyLevers;
    final board = _layout == MissionsLayout.board;
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
          if (drafts.isNotEmpty && widget.leversHandledFor != levers) ...[
            LeverDraftsCard(
              drafts: drafts,
              onFinished: () => widget.onLeversHandled(levers),
            ),
            const SizedBox(height: 20),
          ],
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                container: true,
                label: l.missionsViewLabel,
                child: SegmentedButton<MissionsLayout>(
                  key: const ValueKey('missions-layout'),
                  segments: [
                    ButtonSegment(
                      value: MissionsLayout.list,
                      icon: const Icon(Icons.view_agenda_outlined),
                      label: Text(l.missionsViewList),
                    ),
                    ButtonSegment(
                      value: MissionsLayout.board,
                      icon: const Icon(Icons.view_kanban_outlined),
                      label: Text(l.missionsViewBoard),
                    ),
                  ],
                  selected: {_layout},
                  onSelectionChanged: (s) => _setLayout(s.first),
                ),
              ),
              if (board)
                FilterChip(
                  key: const ValueKey('board-today-filter'),
                  label: Text(l.missionsBoardTodayFilter),
                  avatar: const Icon(Icons.today_outlined),
                  tooltip: l.missionsBoardTodayFilterTooltip,
                  selected: _todayOnly,
                  onSelected: _setTodayOnly,
                ),
            ],
          ),
          const SizedBox(height: 16),
          CarthaPageMotion(
            page: _layout,
            child: board
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.missionsBoardHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      QuestBoard(
                        todayOnly: _todayOnly,
                        onShowAll: () => _setTodayOnly(false),
                      ),
                    ],
                  )
                : const _QuestList(),
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

/// The quests as a list: Today (with the date) and "Add a quest", Anytime &
/// upcoming, then Done folded with its count.
class _QuestList extends StatelessWidget {
  const _QuestList();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final day = state.today;
    final sections = state.missionSections(day);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
      ],
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
      glyph: CarthaGlyph.direction,
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
