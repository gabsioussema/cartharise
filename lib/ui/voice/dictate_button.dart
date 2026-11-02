import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../services/read_aloud.dart';
import '../../state/app_state.dart';
import '../../state/attachment_ops.dart';
import '../media/media_kit.dart';
import '../media/recorder_sheet.dart';
import '../widgets/widgets.dart';
import 'dictation_sheet.dart';

/// [value] with [text] inserted at the cursor — nothing else changes.
///
/// * At a collapsed cursor the text goes there; with words selected it goes
///   right after them (the selection is kept, never replaced); with no
///   cursor yet (the field was never focused) it goes at the end.
/// * One space is added on a side only where the text would otherwise run
///   into a word; the inserted text itself is exactly as reviewed.
/// * The cursor lands right after the inserted text.
TextEditingValue insertDictation(TextEditingValue value, String text) {
  if (text.isEmpty) return value;
  final current = value.text;
  final selection = value.selection;
  final at = selection.isValid
      ? selection.end.clamp(0, current.length)
      : current.length;
  final before = current.substring(0, at);
  final after = current.substring(at);
  final lead =
      before.isNotEmpty &&
          !_isSpace(before[before.length - 1]) &&
          !_isSpace(text[0])
      ? ' '
      : '';
  final trail =
      after.isNotEmpty &&
          !_isSpace(after[0]) &&
          !_isSpace(text[text.length - 1])
      ? ' '
      : '';
  return TextEditingValue(
    text: '$before$lead$text$trail$after',
    selection: TextSelection.collapsed(offset: at + lead.length + text.length),
  );
}

bool _isSpace(String unit) => unit.trim().isEmpty;

/// Keeps a recording made instead of dictating on an existing entry (a try
/// or an attempt), like its own **Record** does. False when it is on screen
/// but not saved on the phone yet.
KeepRecording keepRecordingOn(
  AppState state,
  AttachmentHolder holder,
  String entryId,
) => (Attachment recording) async {
  await state.addAttachment(holder, entryId, recording);
  return state.saveStatus != SaveStatus.failed;
};

/// **Dictate**, under a text field: speak, check the text, then it goes in
/// at the cursor — only when the user taps **Insert**
/// ([showDictationSheet]). Recognition is on the phone only; when it can't
/// run, the sheet says why in one line and offers **Record instead** (when
/// [recordInstead] is given) or **Type instead** (focuses [focusNode]).
///
/// A quiet link with an icon and the word, at the start of the line.
/// [onInserted] gets the field's whole text after an insertion (a
/// programmatic change doesn't call the field's `onChanged`: hosts autosave
/// here). [fieldLabel] names the field for screen readers when a screen has
/// several.
class DictateButton extends StatefulWidget {
  const DictateButton({
    super.key,
    required this.controller,
    this.focusNode,
    this.onInserted,
    this.recordInstead,
    this.fieldLabel,
  });

  final TextEditingController controller;

  /// The field's focus: **Type instead** (and Write instead after a
  /// recording) focuses it.
  final FocusNode? focusNode;

  /// After an insertion, with the field's new text.
  final ValueChanged<String>? onInserted;

  /// Where a voice note recorded instead is kept (entries that hold
  /// recordings: a note, a try, an attempt). Null: no **Record instead**.
  final KeepRecording? recordInstead;

  /// The field's name, for the button's screen-reader label.
  final String? fieldLabel;

  @override
  State<DictateButton> createState() => _DictateButtonState();
}

class _DictateButtonState extends State<DictateButton> {
  bool _open = false;

  Future<void> _dictate() async {
    if (_open) return;
    final l = AppLocalizations.of(context);
    final tag = Localizations.localeOf(context).toLanguageTag();
    // The microphone shouldn't hear Listen reading aloud.
    final voice = context.read<ReadAloud>();
    if (voice.isSpeaking) unawaited(voice.stop());
    setState(() => _open = true);
    DictationOutcome? outcome;
    try {
      outcome = await showDictationSheet(
        context,
        languageTag: tag,
        offerRecord: widget.recordInstead != null,
      );
    } finally {
      if (mounted) setState(() => _open = false);
    }
    if (!mounted || outcome == null) return;
    switch (outcome.end) {
      case DictationEnd.insert:
        final text = outcome.text;
        if (text == null || text.isEmpty) return;
        final controller = widget.controller;
        controller.value = insertDictation(controller.value, text);
        widget.onInserted?.call(controller.text);
        announce(context, l.voiceInserted);
      case DictationEnd.recordInstead:
        final keep = widget.recordInstead;
        if (keep == null) return;
        final recorded = await showRecorderSheet(context, keep: keep);
        if (mounted && recorded?.end == RecorderEnd.writeInstead) {
          widget.focusNode?.requestFocus();
        }
      case DictationEnd.typeInstead:
        widget.focusNode?.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final field = widget.fieldLabel;
    final onPressed = _open ? null : _dictate;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        container: true,
        button: true,
        enabled: onPressed != null,
        label: field == null ? l.voiceDictate : l.voiceDictateInto(field),
        hint: l.voiceDictateHint,
        excludeSemantics: true,
        onTap: onPressed,
        child: TextLinkButton(
          label: l.voiceDictate,
          icon: Icons.keyboard_voice_outlined,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
