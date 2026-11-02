import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'missions_logic.dart';
import 'quest_sheet.dart';
import 'quest_tile.dart';

/// The board lane's name: Later · Ready · Doing · Done.
String laneLabel(AppLocalizations l, QuestStage lane) => switch (lane) {
  QuestStage.later => l.missionsLaneLater,
  QuestStage.ready => l.missionsLaneReady,
  QuestStage.doing => l.missionsLaneDoing,
  QuestStage.done => l.missionsLaneDone,
};

/// Each lane's icon, always shown next to its name (never colour alone).
IconData laneIcon(QuestStage lane) => switch (lane) {
  QuestStage.later => Icons.schedule,
  QuestStage.ready => Icons.outlined_flag,
  QuestStage.doing => Icons.directions_walk,
  QuestStage.done => Icons.check_circle_outline,
};

/// Moves [quest] to the board lane [lane] for today ([MissionsOps.moveQuest])
/// and says so with "Undo" (it puts the lane and the completion days back
/// exactly as they were). Into Done completes it by the existing rules, so
/// XP comes only from that completion; between Later, Ready and Doing
/// nothing is earned. A failed save is said honestly, with Retry.
Future<void> moveQuestWithFeedback(
  BuildContext context,
  Quest quest,
  QuestStage lane,
) async {
  final l = AppLocalizations.of(context);
  final state = context.read<AppState>();
  final messenger = ScaffoldMessenger.of(context);
  final before = state.questById(quest.id);
  if (before == null || before.laneOn(state.today) == lane) return;
  await state.moveQuest(before.id, lane);
  messenger.hideCurrentSnackBar();
  if (state.saveStatus == SaveStatus.failed) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(l.saveStatusFailed),
        action: SnackBarAction(label: l.retry, onPressed: state.retrySave),
      ),
    );
    return;
  }
  final daily = before.recurrence == QuestRecurrence.daily;
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        lane == QuestStage.done && daily
            ? l.missionsBoardDoneForToday(before.title)
            : l.missionsBoardMoved(before.title, laneLabel(l, lane)),
      ),
      persist: false,
      action: SnackBarAction(
        label: l.missionsUndo,
        onPressed: () => undoQuestMove(state, before),
      ),
    ),
  );
}

/// Puts a moved quest back: its stored lane and completion days as they
/// were in [before] (anything else changed since is kept).
Future<void> undoQuestMove(AppState state, Quest before) {
  final current = state.questById(before.id);
  if (current == null) return Future.value();
  return state.updateQuest(
    current.copyWith(
      stage: before.stage,
      completedOn: before.completedOn,
      doneFrom: () => before.doneFrom,
    ),
  );
}

/// One quest on the board: its title (struck through once done), the
/// list's labels ([QuestLabels]: source, project, every day, planned for,
/// done, "+20 XP") across the card's full width, and a "Move to…" button.
/// Tapping it edits it (delete is in the sheet). Hold it to drag it to
/// another lane; the screen scrolls when it nears an edge. Screen readers
/// get "Move to …" actions on the card itself. Completing happens by moving
/// it to Done — the board has no checkbox of its own.
class BoardCard extends StatefulWidget {
  const BoardCard({
    super.key,
    required this.quest,
    required this.day,
    required this.lane,
  });

  final Quest quest;

  /// The local day (`yyyy-MM-dd`) the lanes and the checkbox refer to.
  final String day;

  /// The lane the card is shown in.
  final QuestStage lane;

  @override
  State<BoardCard> createState() => _BoardCardState();
}

class _BoardCardState extends State<BoardCard> {
  EdgeDraggingAutoScroller? _scroller;

  /// The card's width when touched, so the dragged copy matches it.
  double? _width;

  void _measure() {
    final size = context.size;
    if (size != null) _width = size.width;
  }

  void _dragStarted() {
    final scrollable = Scrollable.maybeOf(context);
    _scroller = scrollable == null
        ? null
        : EdgeDraggingAutoScroller(scrollable, velocityScalar: 7);
  }

  void _dragUpdated(DragUpdateDetails details) {
    _scroller?.startAutoScrollIfNecessary(
      Rect.fromCenter(center: details.globalPosition, width: 1, height: 96),
    );
  }

  void _dragStopped() {
    _scroller?.stopAutoScroll();
    _scroller = null;
  }

  @override
  void dispose() {
    _dragStopped();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final quest = widget.quest;
    final done = quest.isDoneOn(widget.day);
    final others = [
      for (final s in QuestStage.values)
        if (s != widget.lane) s,
    ];
    final tile = Material(
      key: ValueKey('board-tile-${quest.id}'),
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        side: BorderSide(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showQuestSheet(context, quest: quest),
        // The move button sits in the corner so the labels can use the
        // card's full width below the title (narrow tablet columns).
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 34),
                    child: Text(
                      quest.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: done ? p.textSecondary : p.textPrimary,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: p.textSecondary,
                      ),
                    ),
                  ),
                  QuestLabels(quest: quest, day: widget.day),
                ],
              ),
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: PopupMenuButton<QuestStage>(
                key: ValueKey('board-move-${quest.id}'),
                tooltip: l.missionsBoardMoveTooltip(quest.title),
                icon: Icon(
                  Icons.drive_file_move_outline,
                  color: p.textSecondary,
                ),
                popUpAnimationStyle: motionEnabled(context)
                    ? null
                    : AnimationStyle.noAnimation,
                onSelected: (lane) =>
                    moveQuestWithFeedback(context, quest, lane),
                itemBuilder: (context) => [
                  for (final s in others)
                    PopupMenuItem(
                      key: ValueKey('board-move-${quest.id}-${s.name}'),
                      value: s,
                      child: ListTile(
                        leading: Icon(laneIcon(s)),
                        title: Text(l.missionsBoardMoveToLane(laneLabel(l, s))),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      container: true,
      customSemanticsActions: {
        for (final s in others)
          CustomSemanticsAction(
            label: l.missionsBoardMoveToLane(laneLabel(l, s)),
          ): () =>
              moveQuestWithFeedback(context, quest, s),
      },
      child: Listener(
        onPointerDown: (_) => _measure(),
        child: LongPressDraggable<Quest>(
          data: quest,
          onDragStarted: _dragStarted,
          onDragUpdate: _dragUpdated,
          onDragEnd: (_) => _dragStopped(),
          onDraggableCanceled: (_, _) => _dragStopped(),
          feedback: Builder(
            builder: (_) => _DragFeedback(
              title: quest.title,
              width: _width ?? 280,
              palette: p,
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: tile),
          child: tile,
        ),
      ),
    );
  }
}

/// The card's copy under the finger while dragging: the title on a card
/// with an accent outline (the card it came from stays, faded).
class _DragFeedback extends StatelessWidget {
  const _DragFeedback({
    required this.title,
    required this.width,
    required this.palette,
  });

  final String title;
  final double width;
  final CarthaPalette palette;

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SizedBox(
      width: width,
      child: Material(
        // Flat, like every card: the accent outline says "picked up".
        color: p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          side: BorderSide(color: p.accent, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
          child: Row(
            children: [
              Icon(Icons.drive_file_move_outline, size: 20, color: p.accent),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: p.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
