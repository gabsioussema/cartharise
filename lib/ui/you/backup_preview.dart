/// Reading a backup before restoring it (F-041): validate it completely
/// first, and know its date for the "Replace everything…?" question. Backup
/// files (v2 `.zip` or v1 JSON) go through `AppState.previewRestore`, which
/// also counts the photos and recordings they lack.
library;

import '../../domain/app_data.dart';
import '../../domain/backup.dart';
import '../../l10n/app_localizations.dart';

/// A fully validated backup, not yet applied.
class BackupPreview {
  const BackupPreview({required this.data, this.exportedAt});

  final AppData data;

  /// When the backup was made, if the file says so.
  final DateTime? exportedAt;
}

/// Decodes and validates [text] as a Cartharise JSON backup. Throws
/// [FormatException] for anything else; current data is never touched.
BackupPreview previewBackup(String text) {
  final contents = decodeBackupJson(text);
  return BackupPreview(data: contents.data, exportedAt: contents.exportedAt);
}

/// Why a file can't be restored, in plain language.
String backupErrorMessage(AppLocalizations l, FormatException e) =>
    switch (e.message) {
      'Not a JSON file' => l.youDataImportNotJson,
      'Not a Cartharise backup' => l.youDataImportNotBackup,
      'Unsupported backup format' ||
      'Unsupported schema version' => l.youDataImportUnsupported,
      'The file is too large' => l.youDataImportTooLarge,
      'Not a text file' => l.youDataImportNotText,
      _ => l.youDataImportDamaged,
    };
