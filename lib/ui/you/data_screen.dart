import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/backup.dart';
import '../../l10n/app_localizations.dart';
import '../../services/file_share.dart';
import '../../services/media_picker.dart';
import '../../state/app_state.dart';
import '../../domain/app_data.dart';
import '../journal/journal_kit.dart';
import '../media/media_kit.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'backup_preview.dart';

/// MIME type of a v1 JSON backup.
const String kBackupMimeType = 'application/json';

/// MIME type of the v2 backup (`.zip`: data.json + attachments/).
const String kBackupZipMimeType = 'application/zip';

/// Your data (F-040–F-043, F-055):
///
/// * where the data lives, honestly (on this device, not encrypted by
///   Cartharise, not synced);
/// * export everything as the documented v2 backup (`.zip` with the photos
///   and recordings) through the share sheet (also the "Export a copy"
///   target after a failed save); what it includes is said (words and
///   settings, how many photos and voice notes, their size), and when they
///   are more than a backup can hold; files that couldn't be read are said;
/// * restore a backup (v2 `.zip` or v1 JSON): the file is fully validated
///   first — a bad file is rejected with "your current data was not
///   changed" — then the user confirms replacing everything with the backup
///   from its date, told how many photos or recordings it names are
///   missing; if the restored data couldn't be saved, it says so instead of
///   "restored";
/// * delete all data after two explicit confirmations: the saved file, the
///   photos and recordings, reminders and every temporary export/import
///   copy ([FileShare.clearTemporaryFiles], [MediaPicker.clearTemporaryFiles]);
///   the app then returns to onboarding.
class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  bool _exporting = false;
  bool _importing = false;
  bool _deleting = false;

  /// Why the last chosen file couldn't be restored.
  String? _importError;

  Future<void> _export() async {
    final state = context.read<AppState>();
    final files = context.read<FileShare>();
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    setState(() => _exporting = true);
    try {
      final archive = await state.exportBackupArchive();
      final outcome = await files.shareBytesFile(
        'cartharise-backup-${state.today}.zip',
        archive.bytes,
        kBackupZipMimeType,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (outcome) {
            ShareOutcome.shared when archive.missing.isNotEmpty =>
              l.youDataExportedPartial,
            ShareOutcome.shared => l.youDataExported,
            ShareOutcome.dismissed => l.youShareDismissed,
            ShareOutcome.unavailable => l.shareFailed,
          }),
        ),
      );
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l.shareFailed)));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _import() async {
    final state = context.read<AppState>();
    final files = context.read<FileShare>();
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context);
    setState(() {
      _importing = true;
      _importError = null;
    });
    try {
      final List<int>? bytes;
      try {
        bytes = await files.pickFileBytes(maxBytes: kMaxBackupBytes);
      } on FormatException catch (e) {
        _fail(backupErrorMessage(l, e));
        return;
      } on Object {
        _fail(l.youDataImportOpenFailed);
        return;
      }
      if (bytes == null || !mounted) return;
      final RestorePreview preview;
      try {
        preview = await state.previewRestore(bytes);
      } on FormatException catch (e) {
        _fail(backupErrorMessage(l, e));
        return;
      }
      if (!mounted) return;
      final date = preview.exportedAt == null
          ? l.youDataImportUnknownDate
          : formatDayTime(context, preview.exportedAt!);
      final missing = preview.missing.length;
      final ok = await confirmDialog(
        context,
        title: l.youDataImportConfirmTitle,
        body: missing == 0
            ? l.youDataImportConfirmBody(date)
            : '${l.youDataImportConfirmBody(date)}\n\n'
                  '${l.youDataImportMissing(missing)}',
        action: l.youDataImportConfirmAction,
        destructive: true,
      );
      if (!ok) return;
      try {
        await state.restoreBackup(preview);
      } on AttachmentException {
        // Nothing was replaced: the files had to be written first.
        _fail(l.youDataImportFilesFailed);
        return;
      }
      // Never claim a restore that wasn't saved (F-055): the backup is on
      // screen, but only Retry (SaveIndicator) makes it stick.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            state.saveStatus == SaveStatus.failed
                ? l.youDataImportedNotSaved
                : l.youDataImported,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _fail(String reason) {
    if (mounted) setState(() => _importError = reason);
  }

  Future<void> _deleteAll() async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final files = context.read<FileShare>();
    final media = context.read<MediaPicker>();
    final messenger = ScaffoldMessenger.of(context);
    final first = await confirmDialog(
      context,
      title: l.youDataDeleteConfirm1Title,
      body: l.youDataDeleteConfirm1Body,
      action: l.youDataDeleteConfirm1Action,
      destructive: true,
    );
    if (!first || !mounted) return;
    final second = await confirmDialog(
      context,
      title: l.youDataDeleteConfirm2Title,
      body: l.youDataDeleteConfirm2Body,
      action: l.youDataDeleteConfirm2Action,
      destructive: true,
    );
    if (!second || !mounted) return;
    setState(() => _deleting = true);
    try {
      // Export and import copies first (share sheet, file picker), so no
      // copy of the user's words outlives "Delete all data".
      var copiesLeft = false;
      try {
        await files.clearTemporaryFiles();
      } on Object {
        copiesLeft = true;
      }
      try {
        await media.clearTemporaryFiles();
      } on Object {
        copiesLeft = true;
      }
      final bool filesGone;
      try {
        // The app returns to onboarding by itself (BootScreen).
        filesGone = await state.deleteAllData();
      } on Object {
        messenger.showSnackBar(SnackBar(content: Text(l.youDataDeleteFailed)));
        return;
      }
      if (!filesGone) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.youDataDeleteFilesLeft)),
        );
      } else if (copiesLeft) {
        messenger.showSnackBar(
          SnackBar(content: Text(l.youDataDeleteCopiesLeft)),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AreaListView(
          children: [
            ScreenHeader(
              title: l.youDataTitle,
              subtitle: l.youDataSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
            ),
            const SaveIndicator(),
            if (state.saveStatus == SaveStatus.failed)
              const SizedBox(height: 12),
            SectionCard(
              icon: Icons.phone_android,
              title: l.youDataWhereTitle,
              child: StorageTransparencyText(
                key: const ValueKey('data-storage'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.ios_share,
              title: l.youDataExportTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.youDataExportBody, style: secondary),
                  const SizedBox(height: 8),
                  const _BackupContents(),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    key: const ValueKey('data-export'),
                    label: l.youDataExportButton,
                    icon: Icons.download_outlined,
                    expand: true,
                    busy: _exporting,
                    onPressed: _export,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.settings_backup_restore,
              title: l.youDataImportTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.youDataImportBody, style: secondary),
                  const SizedBox(height: 4),
                  Text(
                    l.mediaDataImportFormats,
                    key: const ValueKey('data-import-formats'),
                    style: secondary,
                  ),
                  if (_importError != null) ...[
                    const SizedBox(height: 12),
                    _ImportError(reason: _importError!),
                  ],
                  const SizedBox(height: 16),
                  SecondaryButton(
                    key: const ValueKey('data-import'),
                    label: l.youDataImportButton,
                    icon: Icons.folder_open_outlined,
                    expand: true,
                    onPressed: _importing ? null : _import,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.delete_outline,
              title: l.youDataDeleteTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.youDataDeleteBody, style: secondary),
                  const SizedBox(height: 16),
                  DestructiveButton(
                    key: const ValueKey('data-delete'),
                    label: l.youDataDeleteButton,
                    onPressed: _deleting ? null : _deleteAll,
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

/// What a backup includes: the words and settings, plus how many photos
/// and voice notes and the space they take on this phone — and, when they
/// are more than a backup can hold ([kMaxBackupBytes]), that honestly.
class _BackupContents extends StatefulWidget {
  const _BackupContents();

  @override
  State<_BackupContents> createState() => _BackupContentsState();
}

class _BackupContentsState extends State<_BackupContents> {
  Set<String>? _names;
  Future<int>? _size;

  static Future<int> _sizeOf(AppState state, Set<String> names) async {
    var total = 0;
    for (final name in names) {
      try {
        total += await state.attachmentStore.sizeOfFile(name);
      } on Object {
        // Unreadable: the export says so when it happens.
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final all = state.data.allAttachments.toList();
    final names = {for (final a in all) a.fileName};
    if (_names == null || !setEquals(names, _names)) {
      _names = names;
      _size = _sizeOf(state, names);
    }
    final style = theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary);
    if (all.isEmpty) {
      return Text(
        l.mediaDataNoFiles,
        key: const ValueKey('data-media-summary'),
        style: style,
      );
    }
    final photos = all.where((a) => a.kind == AttachmentKind.photo).length;
    final files = attachmentCountText(l, photos, all.length - photos)!;
    return FutureBuilder<int>(
      future: _size,
      builder: (context, snapshot) {
        final size = snapshot.data;
        if (size == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.mediaDataWithFiles(files, formatBytes(context, size)),
              key: const ValueKey('data-media-summary'),
              style: style,
            ),
            if (size > kMaxBackupBytes) ...[
              const SizedBox(height: 8),
              MediaNotice(
                key: const ValueKey('data-media-too-large'),
                message: l.mediaDataTooLarge,
                tone: NoticeTone.warning,
              ),
            ],
          ],
        );
      },
    );
  }
}

/// "This file couldn't be used", the reason, and "Your current data was not
/// changed."
class _ImportError extends StatelessWidget {
  const _ImportError({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        key: const ValueKey('data-import-error'),
        padding: const EdgeInsetsDirectional.all(14),
        decoration: BoxDecoration(
          color: p.errorContainer,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          border: Border.all(color: p.error),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: p.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.youDataImportFailedTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: p.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(reason, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    l.youDataImportUnchanged,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
