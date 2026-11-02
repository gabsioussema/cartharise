import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../services/media_picker.dart';
import '../../state/app_state.dart';
import '../../state/attachment_ops.dart';
import '../widgets/widgets.dart';
import 'media_kit.dart';
import 'photo_tile.dart';
import 'photo_viewer.dart';
import 'recorder_sheet.dart';
import 'voice_note_player.dart';

/// The photos and voice notes of one entry — a journal note, an experiment
/// tried or an attempt — with **Add photo** (camera or library) and
/// **Record**. Photos open full screen (remove, pin); voice notes play in
/// place. Each addition is saved at once, and what happened is said inline
/// (also when a sheet would hide a snackbar): added, not saved yet (Retry),
/// or why nothing was added, with the alternative.
///
/// Shows nothing for an entry that doesn't exist (any more).
class AttachmentStrip extends StatefulWidget {
  const AttachmentStrip({
    super.key,
    required this.holder,
    required this.entryId,
    this.createWith,
    this.onWriteInstead,
  }) : assert(entryId != null || createWith != null);

  final AttachmentHolder holder;

  /// The entry; null while it isn't created yet (a new note).
  final String? entryId;

  /// Adds the attachment to the entry, creating the entry first when it
  /// doesn't exist yet. Returns false when that couldn't be saved yet.
  final Future<bool> Function(Attachment attachment)? createWith;

  /// Typing instead of recording or adding a photo (e.g. focus the field).
  final VoidCallback? onWriteInstead;

  @override
  State<AttachmentStrip> createState() => _AttachmentStripState();
}

class _AttachmentStripState extends State<AttachmentStrip> {
  late final AppState _state = context.read<AppState>();
  late final MediaPicker _picker = context.read<MediaPicker>();
  MediaMessage? _message;
  bool _busy = false;

  /// A photo the camera took while the app was closed (Android), not added.
  String? _lostPhoto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recoverLostPhoto());
  }

  bool get _entryExists {
    final id = widget.entryId;
    return id == null || _state.holderOf(id) == widget.holder;
  }

  Future<void> _recoverLostPhoto() async {
    if (!mounted || !_entryExists) return;
    final String? path;
    try {
      path = await _picker.recoverLostPhoto();
    } on Object {
      return;
    }
    if (path != null && mounted) setState(() => _lostPhoto = path);
  }

  void _show(MediaMessage? message) {
    if (mounted) setState(() => _message = message);
  }

  /// Puts [a] (already in the attachment store) on the entry.
  Future<bool> _keep(Attachment a) async {
    final id = widget.entryId;
    final create = widget.createWith;
    if (id == null && create != null) return create(a);
    if (id == null) throw StateError('No entry');
    await _state.addAttachment(widget.holder, id, a);
    return _state.saveStatus != SaveStatus.failed;
  }

  Future<void> _addPhoto() async {
    final camera = await showMediaSheet<bool>(
      context,
      builder: (_) => const _PhotoSourceSheet(),
    );
    if (camera == null || !mounted) return;
    await _pick(camera: camera);
  }

  Future<void> _pick({required bool camera}) async {
    final l = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _message = null;
    });
    String? path;
    try {
      path = await _picker.pickPhoto(camera: camera);
    } on MediaPickerException catch (e) {
      final denied = e.reason != MediaFailure.failed;
      _show(
        MediaMessage(
          pickerFailureText(l, e.reason, camera: camera),
          tone: denied ? NoticeTone.warning : NoticeTone.error,
          // The other way in: the library instead of the camera, or
          // writing instead of a photo.
          actionLabel: camera && denied
              ? l.mediaChoosePhoto
              : widget.onWriteInstead != null && denied
              ? l.mediaWriteInstead
              : null,
          action: camera && denied
              ? () => _pick(camera: false)
              : widget.onWriteInstead,
        ),
      );
    } on Object {
      _show(MediaMessage(l.mediaPickFailed, tone: NoticeTone.error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (path != null) await _import(path);
  }

  /// Copies the picked photo into the private folder and onto the entry;
  /// the picker's temporary copy is released whatever happens.
  Future<void> _import(String path) async {
    final l = AppLocalizations.of(context);
    if (mounted) setState(() => _busy = true);
    try {
      final Attachment photo;
      try {
        photo = await _state.attachmentStore.importFile(
          path,
          kind: AttachmentKind.photo,
        );
      } on AttachmentException catch (e) {
        _show(
          MediaMessage(photoFailureText(l, e.reason), tone: NoticeTone.error),
        );
        return;
      }
      final bool saved;
      try {
        saved = await _keep(photo);
      } on Object {
        try {
          await _state.attachmentStore.delete(photo);
        } on Object {
          // An orphan now: removed on the next load.
        }
        _show(MediaMessage(l.mediaEntryGone, tone: NoticeTone.error));
        return;
      }
      _show(
        saved
            ? MediaMessage(l.mediaPhotoAdded, tone: NoticeTone.done)
            : MediaMessage(
                l.mediaNotSavedYet,
                tone: NoticeTone.error,
                retry: true,
              ),
      );
    } finally {
      await _picker.release(path);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addLostPhoto() async {
    final path = _lostPhoto;
    if (path == null) return;
    setState(() => _lostPhoto = null);
    await _import(path);
  }

  Future<void> _discardLostPhoto() async {
    final path = _lostPhoto;
    if (path == null) return;
    setState(() => _lostPhoto = null);
    await _picker.release(path);
  }

  Future<void> _record() async {
    final l = AppLocalizations.of(context);
    setState(() => _message = null);
    final outcome = await showRecorderSheet(
      context,
      keep: _keep,
      offerWriteInstead: widget.onWriteInstead != null,
    );
    if (!mounted || outcome == null) return;
    switch (outcome.end) {
      case RecorderEnd.writeInstead:
        widget.onWriteInstead?.call();
      case RecorderEnd.saved:
        _show(MediaMessage(l.mediaRecorderSaved, tone: NoticeTone.done));
      case RecorderEnd.notSaved:
        _show(
          MediaMessage(l.mediaNotSavedYet, tone: NoticeTone.error, retry: true),
        );
    }
  }

  Future<void> _open(Attachment photo) async {
    final id = widget.entryId;
    if (id == null) return;
    final l = AppLocalizations.of(context);
    final result = await openPhotoViewer(
      context,
      holder: widget.holder,
      entryId: id,
      attachmentId: photo.id,
    );
    switch (result) {
      case null:
        return;
      case PhotoViewerResult.removed:
        _show(MediaMessage(l.mediaPhotoRemoved, tone: NoticeTone.done));
      case PhotoViewerResult.removedNotSaved:
        _show(
          MediaMessage(
            l.mediaRemovedNotSaved,
            tone: NoticeTone.error,
            retry: true,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final id = widget.entryId;
    final holder = widget.holder;
    final attachments = context.select<AppState, List<Attachment>?>((s) {
      if (id == null) return const [];
      if (s.holderOf(id) != holder) return null;
      return s.data.attachmentsOf(holder, id);
    });
    // The entry isn't there (any more): nothing to add to.
    if (attachments == null) return const SizedBox.shrink();
    final photos = [
      for (final a in attachments)
        if (a.kind == AttachmentKind.photo) a,
    ];
    final voice = [
      for (final a in attachments)
        if (a.kind == AttachmentKind.audio) a,
    ];
    final message = _message;
    return Column(
      key: ValueKey('media-strip-${holder.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message != null) ...[
          MediaNotice(
            key: const ValueKey('media-notice'),
            message: message.text,
            tone: message.tone,
            actions: [
              if (message.retry)
                retrySaveButton(
                  context,
                  after: () {
                    if (_state.saveStatus != SaveStatus.failed) _show(null);
                  },
                ),
              if (message.actionLabel != null && message.action != null)
                TextLinkButton(
                  key: const ValueKey('media-notice-action'),
                  label: message.actionLabel!,
                  onPressed: () {
                    _show(null);
                    message.action!();
                  },
                ),
            ],
            onDismiss: () => _show(null),
          ),
          const SizedBox(height: 12),
        ],
        if (_lostPhoto != null) ...[
          MediaNotice(
            key: const ValueKey('media-lost-photo'),
            message: l.mediaLostPhoto,
            actions: [
              TextLinkButton(
                label: l.mediaLostPhotoAdd,
                icon: Icons.add_photo_alternate_outlined,
                onPressed: _busy ? null : _addLostPhoto,
              ),
              TextLinkButton(
                label: l.mediaLostPhotoDiscard,
                onPressed: _discardLostPhoto,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (photos.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final photo in photos)
                PhotoTile(
                  key: ValueKey('photo-${photo.id}'),
                  attachment: photo,
                  onTap: () => _open(photo),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        for (final recording in voice) ...[
          VoiceNotePlayer(
            key: ValueKey('player-${recording.id}'),
            attachment: recording,
            holder: holder,
            entryId: id!,
            onMessage: _show,
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SecondaryButton(
              key: const ValueKey('media-add-photo'),
              label: l.mediaAddPhoto,
              icon: Icons.add_photo_alternate_outlined,
              onPressed: _busy ? null : _addPhoto,
            ),
            SecondaryButton(
              key: const ValueKey('media-record'),
              label: l.mediaRecord,
              icon: Icons.mic_none,
              onPressed: _busy ? null : _record,
            ),
          ],
        ),
      ],
    );
  }
}

/// Camera or library? (true = camera).
class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
            child: Semantics(
              header: true,
              child: Text(
                l.mediaPhotoSourceTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
          ListTile(
            key: const ValueKey('media-photo-camera'),
            minTileHeight: 56,
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 20,
            ),
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l.mediaTakePhoto),
            onTap: () => Navigator.of(context).pop(true),
          ),
          ListTile(
            key: const ValueKey('media-photo-library'),
            minTileHeight: 56,
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: 20,
            ),
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l.mediaChoosePhoto),
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}
