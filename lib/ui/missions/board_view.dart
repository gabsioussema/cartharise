import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'board_card.dart';
import 'missions_logic.dart';
import 'quest_sheet.dart';

/// Doing above this many gets a gentle note — never a limit.
const kBoardDoingCalm = 3;

/// Missions › Board: the same quests as the list, in lanes Later → Ready →
/// Doing → Done ([MissionsOps.questBoard]). Stacked on phones, four columns
/// from [columnsFrom] dp wide. Cards move by drag (hold) or by their
/// "Move to…" button; only a move into Done completes a quest (and earns
/// what ticking it earns). [todayOnly] keeps the quests for today (every
/// daily quest and those planned for today or earlier, as the Today tab
/// shows them) in every lane. Done stays folded until opened.
class QuestBoard extends StatefulWidget {
  const QuestBoard({super.key, this.todayOnly = false, this.onShowAll});

  /// Window width from which the lanes sit side by side.
  static const columnsFrom = 840.0;

  final bool todayOnly;

  /// Turns the Today filter off (offered when a new quest is hidden by it).
  final VoidCallback? onShowAll;

  @override
  State<QuestBoard> createState() => _QuestBoardState();
}

class _QuestBoardState extends State<QuestBoard> {
  static const _doneOpenId = 'missions-board-done-open';
  bool _doneOpen = false;
  bool _restored = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restored) return;
    _restored = true;
    final saved = PageStorage.maybeOf(context)
        ?.readState(context, identifier: _doneOpenId);
    if (saved is bool) _doneOpen = saved;
  }

  void _toggleDone() {
    setState(() => _doneOpen = !_doneOpen);
    PageStorage.maybeOf(context)
        ?.writeState(context, _doneOpen, identifier: _doneOpenId);
  }

  Future<void> _add(QuestStage lane) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final todayOnly = widget.todayOnly;
    final onShowAll = widget.onShowAll;
    await showQuestSheet(
      context,
      stage: lane,
      onAdded: (quest) {
        if (!todayOnly) return;
        final forToday = state.todayFocus().any((q) => q.id == quest.id);
        if (forToday) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(l.missionsBoardHiddenByFilter),
              persist: false,
              action: onShowAll == null
                  ? null
                  : SnackBarAction(
                      label: l.missionsBoardShowAll,
                      onPressed: onShowAll,
                    ),
            ),
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final day = state.today;
    final board = state.questBoard(day);
    final forToday = widget.todayOnly
        ? {for (final q in state.todayFocus(day)) q.id}
        : null;
    List<Quest> shown(QuestStage lane) => [
      for (final q in board[lane]!)
        if (forToday == null || forToday.contains(q.id)) q,
    ];
    final columns = MediaQuery.sizeOf(context).width >= QuestBoard.columnsFrom;
    final lanes = [
      for (final lane in QuestStage.values)
        _Lane(
          key: ValueKey('board-lane-${lane.name}'),
          lane: lane,
          quests: shown(lane),
          day: day,
          filtered: forToday != null,
          // What the lane shows: with the Today filter, today's Doing.
          crowded:
              lane == QuestStage.doing &&
              shown(QuestStage.doing).length > kBoardDoingCalm,
          open: lane != QuestStage.done || _doneOpen,
          onToggle: lane == QuestStage.done ? _toggleDone : null,
          onAdd: lane == QuestStage.done ? null : () => _add(lane),
        ),
    ];
    if (columns) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, lane) in lanes.indexed) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: lane),
            ],
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, lane) in lanes.indexed) ...[
          if (i > 0) const SizedBox(height: 12),
          lane,
        ],
      ],
    );
  }
}

/// One lane: a header (icon, name, count), the cards, a calm line when it is
/// empty, and "Add to …". The whole lane takes a dropped card; while one
/// hovers it, the outline turns accent and "Drop to move here" shows.
class _Lane extends StatelessWidget {
  const _Lane({
    super.key,
    required this.lane,
    required this.quests,
    required this.day,
    required this.filtered,
    required this.crowded,
    required this.open,
    this.onToggle,
    this.onAdd,
  });

  final QuestStage lane;
  final List<Quest> quests;
  final String day;

  /// The Today filter is on ([quests] are today's only).
  final bool filtered;

  /// Doing shows more than [kBoardDoingCalm] quests.
  final bool crowded;

  /// False while Done is folded away.
  final bool open;

  /// Folds or opens the lane (Done only).
  final VoidCallback? onToggle;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    final name = laneLabel(l, lane);
    return DragTarget<Quest>(
      onWillAcceptWithDetails: (details) {
        final current = context.read<AppState>().questById(details.data.id);
        return current != null && current.laneOn(day) != lane;
      },
      onAcceptWithDetails: (details) =>
          moveQuestWithFeedback(context, details.data, lane),
      builder: (context, candidates, rejected) {
        final hovering = candidates.isNotEmpty;
        final empty = switch (lane) {
          _ when filtered => l.missionsLaneTodayEmpty,
          QuestStage.later => l.missionsLaneLaterEmpty,
          QuestStage.ready => l.missionsLaneReadyEmpty,
          QuestStage.doing => l.missionsLaneDoingEmpty,
          QuestStage.done => l.missionsLaneDoneEmpty,
        };
        final collapsible = onToggle != null && quests.isNotEmpty;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 10, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CarthaTheme.radius),
                border: Border.all(color: p.border),
              ),
              foregroundDecoration: hovering
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(CarthaTheme.radius),
                      border: Border.all(color: p.accent, width: 2),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LaneHeader(
                    lane: lane,
                    name: name,
                    count: quests.length,
                    open: open,
                    onToggle: collapsible ? onToggle : null,
                  ),
                  if (crowded)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 8),
                      child: Row(
                        key: const ValueKey('board-doing-note'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(top: 1),
                            child: Icon(
                              Icons.spa_outlined,
                              size: 18,
                              color: p.accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.missionsBoardDoingNote,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: p.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (quests.isEmpty || !open)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: 2,
                        bottom: 4,
                      ),
                      child: Text(
                        quests.isEmpty ? empty : l.missionsLaneDoneFolded,
                        style: secondary,
                      ),
                    )
                  else
                    for (final q in quests)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 8),
                        child: BoardCard(
                          key: ValueKey('board-card-${q.id}'),
                          quest: q,
                          day: day,
                          lane: lane,
                        ),
                      ),
                  if (onAdd != null)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextLinkButton(
                        key: ValueKey('board-add-${lane.name}'),
                        label: l.missionsBoardAddTo(name),
                        icon: Icons.add,
                        onPressed: onAdd,
                      ),
                    ),
                ],
              ),
            ),
            if (hovering)
              PositionedDirectional(
                top: -12,
                end: 16,
                child: ExcludeSemantics(
                  child: ChipTag(
                    label: l.missionsBoardDropHere,
                    icon: Icons.south,
                    tone: ChipTone.accent,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// A lane's heading: its icon and name with the count, announced as one
/// header ("Doing, 2 quests"). For Done it is also the button that folds the
/// lane (with its expanded state announced).
class _LaneHeader extends StatelessWidget {
  const _LaneHeader({
    required this.lane,
    required this.name,
    required this.count,
    required this.open,
    this.onToggle,
  });

  final QuestStage lane;
  final String name;
  final int count;
  final bool open;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
      child: Row(
        children: [
          Icon(laneIcon(lane), size: 20, color: p.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                if (count > 0) ChipTag(label: '$count'),
              ],
            ),
          ),
          if (onToggle != null)
            Icon(
              open ? Icons.expand_less : Icons.expand_more,
              color: open ? p.accent : p.textSecondary,
            ),
        ],
      ),
    );
    final summary = l.missionsLaneSummary(name, count);
    if (onToggle == null) {
      return Semantics(
        header: true,
        label: summary,
        excludeSemantics: true,
        child: row,
      );
    }
    return Semantics(
      header: true,
      button: true,
      expanded: open,
      label: summary,
      onTap: onToggle,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('board-toggle-${lane.name}'),
        onTap: onToggle,
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        child: row,
      ),
    );
  }
}
