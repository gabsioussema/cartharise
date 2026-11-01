import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';

/// Asks to confirm an action. [destructive] paints the action in the error
/// colour (delete, replace, start over). Returns true only when the action
/// was chosen; dismissing counts as cancel.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  String? cancel,
  bool destructive = false,
}) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      final p = CarthaPalette.of(context);
      return AlertDialog(
        scrollable: true,
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancel ?? l.cancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: p.error,
                    foregroundColor: p.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

/// Asks for one line (or a few) of text. Returns the text exactly as typed,
/// or null if cancelled.
///
/// The dialog owns its controller: `showDialog` completes when the route is
/// popped, but the dialog keeps rebuilding during its exit animation, so
/// disposing the controller from the caller would crash.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String action,
  String? initial,
  String? hint,
  String? label,
  int? maxLength,
  int maxLines = 1,
  bool requireText = false,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _TextInputDialog(
      title: title,
      action: action,
      initial: initial,
      hint: hint,
      label: label,
      maxLength: maxLength,
      maxLines: maxLines,
      requireText: requireText,
      textCapitalization: textCapitalization,
    ),
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.action,
    this.initial,
    this.hint,
    this.label,
    this.maxLength,
    required this.maxLines,
    required this.requireText,
    required this.textCapitalization,
  });

  final String title;
  final String action;
  final String? initial;
  final String? hint;
  final String? label;
  final int? maxLength;
  final int maxLines;
  final bool requireText;
  final TextCapitalization textCapitalization;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.requireText && _controller.text.trim().isEmpty) return;
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        minLines: 1,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        textCapitalization: widget.textCapitalization,
        decoration: InputDecoration(
          hintText: widget.hint,
          labelText: widget.label,
        ),
        onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.action)),
      ],
    );
  }
}
