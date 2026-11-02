import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/attachment_ops.dart';
import '../journal/journal_kit.dart' show formatDayTime;
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'photo_tile.dart';

/// What the viewer did, for the screen it returns to (an inline notice).
enum PhotoViewerResult { removed, removedNotSaved }

/// Opens the photo [attachmentId] of the entry [entryId] full screen.
Future<PhotoViewerResult?> openPhotoViewer(
  BuildContext context, {
  required AttachmentHolder holder,
  required String entryId,
  required String attachmentId,
}) => Navigator.of(context).push<PhotoViewerResult>(
  MaterialPageRoute(
    builder: (_) => PhotoViewerScreen(
      holder: holder,
      entryId: entryId,
      attachmentId: attachmentId,
    ),
  ),
);

/// One photo, full screen (pinch to zoom), with **Pin as memory** / **Unpin**
/// and **Remove** (asks first; the file is deleted once that is saved). A
/// photo whose file is gone says so calmly and can still be removed.
class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({
    super.key,
    required this.holder,
    required this.entryId,
    required this.attachmentId,
  });

  final AttachmentHolder holder;
  final String entryId;
  final String attachmentId;

  Attachment? _find(AppState s) {
    for (final a in s.data.attachmentsOf(holder, entryId)) {
      if (a.id == attachmentId) return a;
    }
    return null;
  }

  bool _isPinned(AppState s) {
    final pin = s.data.pinnedMemory;
    return pin != null &&
        pin.kind == PinnedKind.photo &&
        pin.sourceId == entryId &&
        pin.attachmentId == attachmentId;
  }

  Future<void> _togglePin(BuildContext context, bool pinned) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    if (pinned) {
      await state.unpinMemory();
    } else {
      await state.pinMemory(
        kind: PinnedKind.photo,
        sourceId: entryId,
        attachmentId: attachmentId,
      );
    }
    final failed = state.saveStatus == SaveStatus.failed;
    final message = switch ((pinned, failed)) {
      (false, false) => l.mediaPinned,
      (false, true) => l.mediaPinnedNotSaved,
      (true, false) => l.mediaUnpinned,
      (true, true) => l.mediaUnpinnedNotSaved,
    };
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _remove(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    final ok = await confirmDialog(
      context,
      title: l.mediaPhotoRemoveTitle,
      body: l.mediaPhotoRemoveBody,
      action: l.mediaRemove,
      destructive: true,
    );
    if (!ok) return;
    await state.removeAttachment(holder, entryId, attachmentId);
    navigator.pop(
      state.saveStatus == SaveStatus.failed
          ? PhotoViewerResult.removedNotSaved
          : PhotoViewerResult.removed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final photo = context.select<AppState, Attachment?>(_find);
    final pinned = context.select<AppState, bool>(_isPinned);
    final date = photo == null ? null : formatDayTime(context, photo.createdAt);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.mediaPhotoTitle),
        actions: [
          if (photo != null) ...[
            IconButton(
              key: const ValueKey('photo-pin'),
              tooltip: pinned ? l.mediaUnpin : l.mediaPinPhoto,
              isSelected: pinned,
              icon: const Icon(Icons.push_pin_outlined),
              selectedIcon: const Icon(Icons.push_pin),
              onPressed: () => _togglePin(context, pinned),
            ),
            IconButton(
              key: const ValueKey('photo-remove'),
              tooltip: l.mediaPhotoRemove,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _remove(context),
            ),
          ],
        ],
      ),
      body: SafeArea(
        top: false,
        child: photo == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(24),
                  child: Text(
                    l.mediaPhotoMissingLabel,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Semantics(
                      image: true,
                      label: l.mediaPhotoLabel(date!),
                      child: InteractiveViewer(
                        key: const ValueKey('photo-viewer-image'),
                        maxScale: 5,
                        child: Center(
                          child: AttachmentImage(
                            attachment: photo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      12,
                      20,
                      16,
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l.mediaPhotoAddedOn(date),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                        if (pinned)
                          ChipTag(
                            key: const ValueKey('photo-pinned-tag'),
                            label: l.mediaPinnedTitle,
                            icon: Icons.push_pin,
                            tone: ChipTone.accent,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
