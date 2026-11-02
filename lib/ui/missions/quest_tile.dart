import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../campaign/campaign_ops.dart';
import '../compass/formatting.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'missions_logic.dart';
import 'project_art.dart';
import 'quest_sheet.dart';

/// Deletes [quest] at once and offers "Undo" (puts it back where it was).
Future<void> deleteQuestWithUndo(BuildContext context, Quest quest) async {
  final l = AppLocalizations.of(context);
  final state = context.read<AppState>();
  final messenger = ScaffoldMessenger.of(context);
  final index = state.data.quests.indexWhere((q) => q.id == quest.id);
  if (index < 0) return;
  await state.deleteQuest(quest.id);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l.missionsQuestDeleted),
        // Undo is offered for a few seconds, then the bar goes by itself
        // (an action would otherwise keep it on screen until dismissed).
        persist: false,
        action: SnackBarAction(
          label: l.missionsUndo,
          onPressed: () => state.restoreQuest(quest, index),
        ),
      ),
    );
}

/// Completes or reopens [quest] for [day]. A finished one-off moves to Done,
/// so that is said, with "Undo".
Future<void> setQuestDoneWithFeedback(
  BuildContext context,
  Quest quest,
  bool done,
  String day,
) async {
  final l = AppLocalizations.of(context);
  final state = context.read<AppState>();
  final messenger = ScaffoldMessenger.of(context);
  await state.setQuestDone(quest.id, done, day: day);
  if (done && quest.recurrence == QuestRecurrence.none) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l.missionsQuestMovedToDone(quest.title)),
          persist: false,
          action: SnackBarAction(
            label: l.missionsUndo,
            onPressed: () => state.setQuestDone(quest.id, false, day: day),
          ),
        ),
      );
  }
}

enum _QuestAction { edit, delete }

/// How many quests count as done on [day] for XP: each quest once that day,
/// as `campaignProgress` counts them.
int questsDoneOn(Iterable<Quest> quests, String day) =>
    quests.where((q) => q.completedOn.contains(day)).length;

/// Whether completing a quest on [day] would add XP: the game layer is on and
/// fewer than [kQuestDaysCap] quests are done that day.
bool questXpOpenOn(AppState state, String day) =>
    state.gameEnabled && questsDoneOn(state.data.quests, day) < kQuestDaysCap;

/// One quest: an accessible checkbox ("Mark '…' done"), the title, calm
/// labels ([QuestLabels]: from an experiment · its project, with its
/// picture · every day · planned for · done today · "+20 XP") and an
/// options menu.
/// Tapping the row edits it. Done is shown by the tick, strike-through and a
/// label — never by colour alone, and nothing is ever "missed" (F-031).
class QuestTile extends StatelessWidget {
  const QuestTile({super.key, required this.quest, required this.day});

  final Quest quest;

  /// The local day the checkbox refers to (`yyyy-MM-dd`).
  final String day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final done = quest.isDoneOn(day);
    return Material(
      color: p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        side: BorderSide(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showQuestSheet(context, quest: quest),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(2, 4, 0, 4),
          child: Row(
            children: [
              Checkbox(
                key: ValueKey('quest-check-${quest.id}'),
                value: done,
                semanticLabel: l.missionsQuestMarkDone(quest.title),
                onChanged: (v) =>
                    setQuestDoneWithFeedback(context, quest, v ?? false, day),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: done ? p.textSecondary : p.textPrimary,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: p.textSecondary,
                        ),
                      ),
                      QuestLabels(quest: quest, day: day),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<_QuestAction>(
                tooltip: l.missionsQuestOptions(quest.title),
                icon: Icon(Icons.more_vert, color: p.textSecondary),
                onSelected: (action) => switch (action) {
                  _QuestAction.edit => showQuestSheet(context, quest: quest),
                  _QuestAction.delete => deleteQuestWithUndo(context, quest),
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _QuestAction.edit,
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l.missionsQuestEdit),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: _QuestAction.delete,
                    child: ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: Text(l.missionsQuestDelete),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A quest's calm labels, the same in the list and on the board (one task
/// list, many views): from an experiment · its project · every day ·
/// planned for · done today / done on · "+20 XP" while the Campaign is on,
/// the quest is open and today's quest XP isn't used up. Nothing when there
/// is nothing to say.
class QuestLabels extends StatelessWidget {
  const QuestLabels({super.key, required this.quest, required this.day});

  final Quest quest;

  /// The local day "done" and the XP rule refer to (`yyyy-MM-dd`).
  final String day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = quest.isDoneOn(day);
    final daily = quest.recurrence == QuestRecurrence.daily;
    final xpOpen = context.select<AppState, bool>((s) => questXpOpenOn(s, day));
    final showXp = xpOpen && !done;
    final fromTry = quest.source == QuestSource.experiment;
    final project = watchProject(context, quest.projectId);
    String? doneLabel;
    if (done) {
      final last = (quest.completedOn.toList()..sort()).last;
      doneLabel = daily || last == day
          ? l.missionsQuestDoneToday
          : l.missionsQuestDoneOn(formatDayKey(context, last));
    }
    final due = !daily && quest.dueDate != null && !done;
    if (!fromTry && project == null && !daily && !due && !done && !showXp) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          // Added from the Playground's "Try".
          if (fromTry)
            ChipTag(
              key: ValueKey('quest-source-${quest.id}'),
              label: l.campaignQuestFromTry,
              glyph: CarthaGlyph.experiment,
            ),
          // The month project it belongs to (current or past), with its
          // picture: read as "Project: <title>".
          if (project != null)
            ProjectTag(project, key: ValueKey('quest-project-${quest.id}')),
          if (daily) ChipTag(label: l.missionsQuestDaily, icon: Icons.repeat),
          if (due)
            ChipTag(
              label: l.missionsQuestDue(formatDayKey(context, quest.dueDate!)),
              icon: Icons.event_outlined,
            ),
          if (doneLabel != null)
            ChipTag(
              label: doneLabel,
              icon: Icons.check,
              tone: ChipTone.success,
            ),
          if (showXp)
            Semantics(
              label: l.campaignQuestXpLabel(kXpPerQuest),
              excludeSemantics: true,
              child: ChipTag(
                key: ValueKey('quest-xp-${quest.id}'),
                label: l.campaignQuestXp(kXpPerQuest),
                icon: Icons.auto_awesome,
                tone: ChipTone.accent,
              ),
            ),
        ],
      ),
    );
  }
}
