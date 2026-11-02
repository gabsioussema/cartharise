import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../media/attachment_strip.dart';
import '../missions/project_link.dart';
import '../missions/project_ops.dart';
import '../widgets/widgets.dart';
import 'campaign_ops.dart';

enum _AttemptSheetResult { saved, delete }

/// Corrects or deletes a battle-log attempt (F-061), and holds its photos
/// and voice notes (saved as soon as they are added). Delete asks first.
Future<void> showAttemptSheet(
  BuildContext context,
  BattleLogEntry entry,
) async {
  final result = await showModalBottomSheet<_AttemptSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Reduced motion (device or Settings › Motion): no slide.
    sheetAnimationStyle: motionEnabled(context)
        ? null
        : AnimationStyle.noAnimation,
    builder: (_) => AttemptSheet(entry: entry),
  );
  if (result != _AttemptSheetResult.delete || !context.mounted) return;
  final l = AppLocalizations.of(context);
  final confirmed = await confirmDialog(
    context,
    title: l.campaignAttemptDeleteTitle,
    body: l.campaignAttemptDeleteBody,
    action: l.campaignAttemptDelete,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  await context.read<AppState>().deleteAttempt(entry.id);
  messenger?.showSnackBar(SnackBar(content: Text(l.campaignAttemptDeleted)));
}

class AttemptSheet extends StatefulWidget {
  const AttemptSheet({super.key, required this.entry});

  final BattleLogEntry entry;

  @override
  State<AttemptSheet> createState() => _AttemptSheetState();
}

class _AttemptSheetState extends State<AttemptSheet> {
  late final _attempt = TextEditingController(text: widget.entry.attempt);
  late final _learning = TextEditingController(text: widget.entry.learning);
  final _learningFocus = FocusNode();

  /// The project this attempt can be linked to (its own, else the active
  /// one), and whether it is.
  late final MonthProject? _project = context
      .read<AppState>()
      .linkableProjectForAttempt(widget.entry);
  late bool _linked = _project != null && widget.entry.projectId == _project.id;
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _attempt.dispose();
    _learning.dispose();
    _learningFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_attempt.text.trim().isEmpty) {
      setState(() => _error = l.campaignAttemptRequired);
      return;
    }
    setState(() => _busy = true);
    final state = context.read<AppState>();
    await state.editAttempt(
      widget.entry.id,
      attempt: _attempt.text,
      learning: _learning.text,
    );
    final project = _linked ? _project?.id : null;
    if (_project != null && project != widget.entry.projectId) {
      await state.setAttemptProject(widget.entry.id, project);
    }
    if (mounted) Navigator.of(context).pop(_AttemptSheetResult.saved);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
              l.campaignAttemptEditTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('attempt-edit-attempt'),
            controller: _attempt,
            minLines: 2,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l.campaignAttemptLabel,
              errorText: _error,
              errorMaxLines: 3,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('attempt-edit-learning'),
            controller: _learning,
            focusNode: _learningFocus,
            minLines: 2,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.campaignLearningLabel),
          ),
          if (_project != null) ...[
            const SizedBox(height: 8),
            ProjectLinkSwitch(
              key: const ValueKey('attempt-project-link'),
              project: _project,
              past: context.read<AppState>().data.project?.id != _project.id,
              value: _linked,
              onChanged: (v) => setState(() => _linked = v),
            ),
          ],
          const SizedBox(height: 16),
          AttachmentStrip(
            holder: AttachmentHolder.attempt,
            entryId: widget.entry.id,
            onWriteInstead: _learningFocus.requestFocus,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l.campaignAttemptSave,
            expand: true,
            busy: _busy,
            onPressed: _save,
          ),
          const SizedBox(height: 4),
          Center(
            child: TextLinkButton(
              label: l.campaignAttemptDelete,
              icon: Icons.delete_outline,
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).pop(_AttemptSheetResult.delete),
            ),
          ),
        ],
      ),
    );
  }
}
