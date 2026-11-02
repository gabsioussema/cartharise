import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../widgets/widgets.dart';
import 'campaign_ops.dart';

enum _EntrySheetResult { saved, remove }

/// Corrects the note of a tried experiment, or removes the try from the
/// Collection (asks first). The note is saved exactly as typed.
Future<void> showExperimentEntrySheet(
  BuildContext context,
  ExperimentEntry entry, {
  required String title,
}) async {
  final result = await showModalBottomSheet<_EntrySheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => ExperimentEntrySheet(entry: entry, title: title),
  );
  if (result != _EntrySheetResult.remove || !context.mounted) return;
  final l = AppLocalizations.of(context);
  final confirmed = await confirmDialog(
    context,
    title: l.campaignTriedRemoveTitle,
    body: l.campaignTriedRemoveBody,
    action: l.campaignTriedRemove,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final state = context.read<AppState>();
  await state.deleteExperimentEntry(entry.id);
  messenger?.showSnackBar(
    SnackBar(
      content: Text(
        state.saveStatus == SaveStatus.failed
            ? l.campaignNotSavedYet
            : l.campaignTriedRemoved,
      ),
    ),
  );
}

class ExperimentEntrySheet extends StatefulWidget {
  const ExperimentEntrySheet({
    super.key,
    required this.entry,
    required this.title,
  });

  final ExperimentEntry entry;

  /// The experiment's title.
  final String title;

  @override
  State<ExperimentEntrySheet> createState() => _ExperimentEntrySheetState();
}

class _ExperimentEntrySheetState extends State<ExperimentEntrySheet> {
  late final _note = TextEditingController(text: widget.entry.note);
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    final state = context.read<AppState>();
    setState(() => _busy = true);
    await state.editExperimentEntry(widget.entry.id, note: _note.text);
    if (!mounted) return;
    navigator.pop(_EntrySheetResult.saved);
    if (state.saveStatus == SaveStatus.failed) {
      messenger?.showSnackBar(SnackBar(content: Text(l.campaignNotSavedYet)));
    }
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
            child: Text(widget.title, style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('tried-edit-note'),
            controller: _note,
            minLines: 1,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.campaignTryNoteLabel),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            key: const ValueKey('tried-edit-save'),
            label: l.campaignTriedSave,
            expand: true,
            busy: _busy,
            onPressed: _save,
          ),
          const SizedBox(height: 4),
          Center(
            child: TextLinkButton(
              key: const ValueKey('tried-edit-remove'),
              label: l.campaignTriedRemove,
              icon: Icons.delete_outline,
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).pop(_EntrySheetResult.remove),
            ),
          ),
        ],
      ),
    );
  }
}
