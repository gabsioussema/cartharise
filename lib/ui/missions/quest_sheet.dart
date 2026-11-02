import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/formatting.dart';
import '../widgets/widgets.dart';
import 'missions_logic.dart';
import 'project_link.dart';
import 'project_ops.dart';
import 'quest_tile.dart';

/// How the quest sheet was closed.
enum QuestSheetResult { saved, delete }

/// Adds a quest (no [quest]) or edits one (F-027, F-029): title, "repeat
/// every day", optional date and — while there is a project to link —
/// "Part of the month project" (a new quest starts linked to the active
/// project). "Delete quest" deletes with Undo.
///
/// A new quest starts in the board lane [stage] (Ready unless the board's
/// "Add to …" says otherwise); [onAdded] hears about it once it is saved.
Future<void> showQuestSheet(
  BuildContext context, {
  Quest? quest,
  QuestStage stage = QuestStage.ready,
  ValueChanged<Quest>? onAdded,
}) async {
  final result = await showModalBottomSheet<QuestSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Reduced motion (device or Settings › Motion): no slide.
    sheetAnimationStyle: motionEnabled(context)
        ? null
        : AnimationStyle.noAnimation,
    builder: (_) => QuestSheet(quest: quest, stage: stage, onAdded: onAdded),
  );
  if (result == QuestSheetResult.delete && quest != null && context.mounted) {
    await deleteQuestWithUndo(context, quest);
  }
}

class QuestSheet extends StatefulWidget {
  const QuestSheet({
    super.key,
    this.quest,
    this.stage = QuestStage.ready,
    this.onAdded,
  });

  /// Null = a new quest.
  final Quest? quest;

  /// The board lane a new quest starts in (a new quest is never done).
  final QuestStage stage;

  /// Called with the new quest once it is saved.
  final ValueChanged<Quest>? onAdded;

  @override
  State<QuestSheet> createState() => _QuestSheetState();
}

class _QuestSheetState extends State<QuestSheet> {
  late final _title = TextEditingController(text: widget.quest?.title ?? '');
  late bool _daily = widget.quest?.recurrence == QuestRecurrence.daily;
  late String? _due = widget.quest?.dueDate;

  /// The project this quest can be linked to (its own, else the active
  /// one), and whether it is.
  late final MonthProject? _project = context
      .read<AppState>()
      .linkableProjectFor(widget.quest);
  late bool _linked =
      _project != null &&
      (widget.quest == null || widget.quest!.projectId == _project.id);
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = parseDateKey(context.read<AppState>().today);
    final initial = _due == null ? today : parseDateKey(_due!);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.isBefore(today) ? initial : today,
      lastDate: DateTime(today.year + 5, today.month, today.day),
      currentDate: today,
    );
    if (picked != null && mounted) setState(() => _due = dateKey(picked));
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final text = _title.text.trim();
    if (text.isEmpty) {
      setState(() => _error = l.missionsQuestTitleRequired);
      return;
    }
    setState(() => _busy = true);
    final state = context.read<AppState>();
    final recurrence = _daily ? QuestRecurrence.daily : QuestRecurrence.none;
    final due = _daily ? null : _due;
    final quest = widget.quest;
    if (quest == null) {
      final added = await state.addQuest(
        text,
        recurrence: recurrence,
        dueDate: due,
        stage: widget.stage == QuestStage.done
            ? QuestStage.ready
            : widget.stage,
        linkProject: _linked,
      );
      widget.onAdded?.call(added);
    } else {
      await state.editQuest(
        quest,
        title: text,
        recurrence: recurrence,
        dueDate: due,
      );
      final project = _linked ? _project?.id : null;
      if (_project != null && project != quest.projectId) {
        await state.setQuestProject(quest.id, project);
      }
    }
    if (mounted) Navigator.of(context).pop(QuestSheetResult.saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final editing = widget.quest != null;
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              editing ? l.missionsEditQuestTitle : l.missionsNewQuestTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('quest-title'),
            controller: _title,
            autofocus: !editing,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l.missionsQuestTitleLabel,
              hintText: l.missionsQuestTitleHint,
              errorText: _error,
              errorMaxLines: 3,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: _daily,
            onChanged: (v) => setState(() => _daily = v),
            contentPadding: EdgeInsetsDirectional.zero,
            title: Text(l.missionsQuestRepeat),
            subtitle: Text(l.missionsQuestRepeatHelp),
          ),
          if (!_daily) ...[
            const SizedBox(height: 8),
            Text(l.missionsQuestDueLabel, style: theme.textTheme.titleSmall),
            if (_due == null) ...[
              const SizedBox(height: 2),
              Text(l.missionsQuestNoDate, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SecondaryButton(
                  key: const ValueKey('quest-date'),
                  label: _due == null
                      ? l.missionsQuestChooseDate
                      : formatDayKey(context, _due!),
                  icon: Icons.event_outlined,
                  onPressed: _pickDate,
                ),
                if (_due != null)
                  TextLinkButton(
                    label: l.missionsQuestClearDate,
                    icon: Icons.close,
                    onPressed: () => setState(() => _due = null),
                  ),
              ],
            ),
          ],
          if (_project != null) ...[
            const SizedBox(height: 8),
            ProjectLinkSwitch(
              project: _project,
              past: context.read<AppState>().data.project?.id != _project.id,
              value: _linked,
              onChanged: (v) => setState(() => _linked = v),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: l.missionsQuestSave,
            expand: true,
            busy: _busy,
            onPressed: _save,
          ),
          const SizedBox(height: 4),
          Center(
            child: editing
                ? TextLinkButton(
                    label: l.missionsQuestDeleteAction,
                    icon: Icons.delete_outline,
                    onPressed: _busy
                        ? null
                        : () =>
                              Navigator.of(context)
                                  .pop(QuestSheetResult.delete),
                  )
                : TextLinkButton(
                    label: l.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
          ),
        ],
      ),
    );
  }
}
