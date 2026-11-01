import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../widgets/widgets.dart';
import 'campaign_ops.dart';

enum _AttemptSheetResult { saved, delete }

/// Corrects or deletes a battle-log attempt (F-061). Delete asks first.
Future<void> showAttemptSheet(
  BuildContext context,
  BattleLogEntry entry,
) async {
  final result = await showModalBottomSheet<_AttemptSheetResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
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
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _attempt.dispose();
    _learning.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_attempt.text.trim().isEmpty) {
      setState(() => _error = l.campaignAttemptRequired);
      return;
    }
    setState(() => _busy = true);
    await context.read<AppState>().editAttempt(
      widget.entry.id,
      attempt: _attempt.text,
      learning: _learning.text,
    );
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
            minLines: 2,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.campaignLearningLabel),
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
