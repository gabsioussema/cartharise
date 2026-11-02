import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../services/media_picker.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../widgets/widgets.dart';
import 'media_kit.dart';

/// Asks the camera once, at app level, for a photo it took while Android
/// closed the app ([MediaPicker.recoverLostPhoto]) and holds it in
/// [AppState.recoveredMedia] until the user decides — never handed to
/// whichever entry happens to open first. Best effort and silent when
/// there is none; the picker's temporary copy is released either way.
Future<void> recoverLostCameraPhoto(AppState state, MediaPicker picker) async {
  final String? path;
  try {
    path = await picker.recoverLostPhoto();
  } on Object {
    return;
  }
  if (path == null) return;
  try {
    await state.holdRecoveredPhoto(path);
  } on Object {
    // Couldn't be copied (storage full): nothing is claimed.
  } finally {
    await picker.release(path);
  }
}

/// Photos and recordings kept from before that wait for the user's
/// decision ([AppState.recoveredMedia]): a recording cut off when the app
/// closed (it may be incomplete) or a photo the camera handed back. Each
/// says what it is, with **Keep in a new note** and **Discard** (asks
/// first). After keeping, says so — or, when that couldn't be saved yet,
/// says that with Retry. Nothing when there is nothing to decide.
class RecoveredMediaCard extends StatefulWidget {
  const RecoveredMediaCard({super.key});

  @override
  State<RecoveredMediaCard> createState() => _RecoveredMediaCardState();
}

class _RecoveredMediaCardState extends State<RecoveredMediaCard> {
  MediaMessage? _message;
  String? _keptNote;

  Future<void> _keep(AppState state, Attachment a) async {
    final l = AppLocalizations.of(context);
    final note = await state.keepRecovered(a);
    if (!mounted) return;
    final saved = state.saveStatus != SaveStatus.failed;
    final message = saved
        ? MediaMessage(l.mediaRecoveredKept, tone: NoticeTone.done)
        : MediaMessage(l.mediaNotSavedYet, tone: NoticeTone.error, retry: true);
    setState(() {
      _message = message;
      _keptNote = note.id;
    });
    announce(context, message.text);
  }

  Future<void> _discard(AppState state, Attachment a) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.mediaRecoveredDiscardTitle,
      body: l.mediaRecoveredDiscardBody,
      action: l.mediaRecoveredDiscard,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await state.discardRecovered(a);
    if (mounted) setState(() => _message = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final items = state.recoveredMedia;
    final message = _message;
    if (items.isEmpty && message == null) return const SizedBox.shrink();
    final keptNote = _keptNote;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: Column(
        key: const ValueKey('recovered-media'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final a in items) ...[
            MediaNotice(
              key: ValueKey('recovered-${a.id}'),
              message: a.kind == AttachmentKind.audio
                  ? l.mediaRecoveredRecording
                  : l.mediaRecoveredPhoto,
              tone: NoticeTone.warning,
              actions: [
                TextLinkButton(
                  key: ValueKey('recovered-keep-${a.id}'),
                  label: l.mediaRecoveredKeep,
                  icon: Icons.note_add_outlined,
                  onPressed: () => _keep(state, a),
                ),
                TextLinkButton(
                  key: ValueKey('recovered-discard-${a.id}'),
                  label: l.mediaRecoveredDiscard,
                  icon: Icons.delete_outline,
                  onPressed: () => _discard(state, a),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (message != null)
            MediaNotice(
              key: const ValueKey('recovered-message'),
              message: message.text,
              tone: message.tone,
              actions: [
                if (message.retry)
                  retrySaveButton(
                    context,
                    after: () {
                      if (mounted && state.saveStatus != SaveStatus.failed) {
                        setState(
                          () => _message = MediaMessage(
                            l.mediaRecoveredKept,
                            tone: NoticeTone.done,
                          ),
                        );
                      }
                    },
                  ),
                if (keptNote != null && !message.retry)
                  TextLinkButton(
                    key: const ValueKey('recovered-open'),
                    label: l.mediaTodayOpen,
                    onPressed: () =>
                        AppNav.openJournalEntry(context, entryId: keptNote),
                  ),
              ],
              onDismiss: () => setState(() => _message = null),
            ),
        ],
      ),
    );
  }
}
