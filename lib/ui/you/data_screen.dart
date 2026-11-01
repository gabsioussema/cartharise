import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/file_share.dart';
import '../../state/app_state.dart';
import '../journal/journal_kit.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'backup_preview.dart';

/// MIME type of the JSON backup.
const String kBackupMimeType = 'application/json';

/// Your data (F-040–F-043, F-055):
///
/// * where the data lives, honestly (on this device, not encrypted by
///   Cartharise, not synced);
/// * export everything as the documented JSON backup through the share
///   sheet (also the "Export a copy" target after a failed save);
/// * restore a backup: the file is fully validated first — a bad file is
///   rejected with "your current data was not changed" — then the user
///   confirms replacing everything with the backup from its date;
/// * delete all data after two explicit confirmations; the app then
///   returns to onboarding.
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
      final outcome = await files.shareTextFile(
        'cartharise-backup-${state.today}.json',
        state.exportBackup(),
        kBackupMimeType,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (outcome) {
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
      final String? text;
      try {
        text = await files.pickTextFile();
      } on FormatException catch (e) {
        _fail(backupErrorMessage(l, e));
        return;
      } on Object {
        _fail(l.youDataImportOpenFailed);
        return;
      }
      if (text == null || !mounted) return;
      final BackupPreview preview;
      try {
        preview = previewBackup(text);
      } on FormatException catch (e) {
        _fail(backupErrorMessage(l, e));
        return;
      }
      final date = preview.exportedAt == null
          ? l.youDataImportUnknownDate
          : formatDayTime(context, preview.exportedAt!);
      final ok = await confirmDialog(
        context,
        title: l.youDataImportConfirmTitle,
        body: l.youDataImportConfirmBody(date),
        action: l.youDataImportConfirmAction,
        destructive: true,
      );
      if (!ok) return;
      try {
        await state.importBackup(text);
      } on FormatException catch (e) {
        _fail(backupErrorMessage(l, e));
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(l.youDataImported)));
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
      // The app returns to onboarding by itself (BootScreen).
      await state.deleteAllData();
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l.youDataDeleteFailed)));
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
              child: Text(
                state.storageDescription,
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
