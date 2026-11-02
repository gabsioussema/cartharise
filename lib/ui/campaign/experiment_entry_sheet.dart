import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../widgets/widgets.dart';
import 'campaign_ops.dart';

enum _EntrySheetResult { saved, remove }

/// Corrects the note of a tried experiment, or removes the try from the
/// Collection (asks first). The note is saved exactly as typed. A changed
/// note is never dropped silently: when the sheet is closed without
/// **Save note** (swiped away, back, a tap outside), it asks whether to
/// save the change.
Future<void> showExperimentEntrySheet(
  BuildContext context,
  ExperimentEntry entry, {
  required String title,
}) async {
  final edited = ValueNotifier<String>(entry.note);
  final result = await showModalBottomSheet<_EntrySheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Reduced motion (device or Settings › Motion): no slide.
    sheetAnimationStyle: motionEnabled(context)
        ? null
        : AnimationStyle.noAnimation,
    builder: (_) =>
        ExperimentEntrySheet(entry: entry, title: title, edited: edited),
  );
  final text = edited.value;
  edited.dispose();
  if (!context.mounted) return;
  if (result == null && text != entry.note) {
    await _offerToSave(context, entry, text);
    return;
  }
  if (result != _EntrySheetResult.remove) return;
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

/// The sheet was closed with a changed note it didn't save: save it
/// exactly as typed, or let it go — the user decides.
Future<void> _offerToSave(
  BuildContext context,
  ExperimentEntry entry,
  String text,
) async {
  final l = AppLocalizations.of(context);
  final save = await confirmDialog(
    context,
    title: l.campaignTriedUnsavedTitle,
    body: l.campaignTriedUnsavedBody,
    action: l.campaignTriedSave,
    cancel: l.campaignTriedDiscard,
  );
  if (!save || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final state = context.read<AppState>();
  await state.editExperimentEntry(entry.id, note: text);
  if (state.saveStatus == SaveStatus.failed) {
    messenger?.showSnackBar(SnackBar(content: Text(l.campaignNotSavedYet)));
  }
}

class ExperimentEntrySheet extends StatefulWidget {
  const ExperimentEntrySheet({
    super.key,
    required this.entry,
    required this.title,
    this.edited,
  });

  final ExperimentEntry entry;

  /// The experiment's title.
  final String title;

  /// Follows the note as it is typed, so a sheet closed without saving can
  /// offer to keep the change.
  final ValueNotifier<String>? edited;

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
            onChanged: (text) => widget.edited?.value = text,
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
