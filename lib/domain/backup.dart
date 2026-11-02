/// The documented backup formats (F-040/F-041).
///
/// **v1 — one JSON file** (also the format of the saved data file):
///
/// ```json
/// { "app": "cartharise", "format": 1, "exportedAt": "<ISO-8601 UTC>", "data": { …AppData… } }
/// ```
///
/// **v2 — a `.zip`** (what "Export backup" makes since step 2):
///
/// ```
/// data.json                  the JSON above with "format": 2
/// attachments/<fileName>     every photo and recording the data refers to
/// ```
///
/// Restoring accepts both. Pure Dart: the `archive` package's in-memory zip.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'app_data.dart';

const String kBackupApp = 'cartharise';

/// A JSON backup (and the saved data file).
const int kBackupFormat = 1;

/// A `.zip` backup: [kBackupDataEntry] + [kBackupAttachmentsFolder].
const int kBackupArchiveFormat = 2;

/// The JSON document inside a v2 backup.
const String kBackupDataEntry = 'data.json';

/// The folder of attachment files inside a v2 backup.
const String kBackupAttachmentsFolder = 'attachments/';

/// Largest backup file accepted for a restore. Export refuses to make a
/// larger one ([BackupTooLargeException]): a backup that could never be
/// restored is never offered as one.
const int kMaxBackupBytes = 256 * 1024 * 1024;

/// The photos and recordings (or the whole `.zip`) are more than a restore
/// accepts ([kMaxBackupBytes]); nothing was made. Say so and offer the
/// words-only JSON backup instead — never "exported".
class BackupTooLargeException implements Exception {
  const BackupTooLargeException(this.bytes);

  /// How many bytes it would have taken (at least).
  final int bytes;

  @override
  String toString() => 'BackupTooLargeException';
}

/// Most bytes a v2 backup may unpack to (guards against zip bombs).
const int kMaxBackupUnpackedBytes = 512 * 1024 * 1024;

/// The JSON envelope of [data] (format [kBackupFormat] unless [format] says
/// otherwise; v2 backups carry it as [kBackupDataEntry] with format 2).
String encodeBackup(
  AppData data,
  DateTime exportedAt, {
  int format = kBackupFormat,
}) => const JsonEncoder.withIndent('  ').convert({
  'app': kBackupApp,
  'format': format,
  'exportedAt': exportedAt.toUtc().toIso8601String(),
  'data': data.toJson(),
});

/// Parses and fully validates a JSON backup (format 1, or the `data.json`
/// of a v2 backup). Throws [FormatException] for anything that is not a
/// complete Cartharise backup; never returns partial data.
AppData decodeBackup(String text) => decodeBackupJson(text).data;

/// A backup, fully decoded and validated, not applied yet.
class BackupContents {
  const BackupContents({
    required this.data,
    required this.format,
    this.exportedAt,
    this.files = const {},
  });

  final AppData data;

  /// [kBackupFormat] (JSON) or [kBackupArchiveFormat] (zip).
  final int format;

  /// When the backup was made, if the file says so.
  final DateTime? exportedAt;

  /// Attachment file name → its bytes, for the files the data refers to
  /// that the backup contains (only a v2 backup has any).
  final Map<String, Uint8List> files;

  /// The attachment files the data refers to.
  Set<String> get referenced => data.attachmentFileNames;

  /// Files the data refers to that are not in this backup. They are never
  /// dropped silently: the entries keep them (shown as missing) and the
  /// restore preview counts the ones this phone doesn't have either.
  Set<String> get notIncluded => referenced.difference(files.keys.toSet());
}

/// Decodes a JSON backup with its envelope details. Format 1 or 2.
BackupContents decodeBackupJson(String text) {
  final Object? root;
  try {
    root = jsonDecode(text);
  } on FormatException {
    throw const FormatException('Not a JSON file');
  }
  if (root is! Map || root['app'] != kBackupApp) {
    throw const FormatException('Not a Cartharise backup');
  }
  final format = root['format'];
  if (format != kBackupFormat && format != kBackupArchiveFormat) {
    throw FormatException('Unsupported backup format', format);
  }
  DateTime? exportedAt;
  final stamp = root['exportedAt'];
  if (stamp is String) exportedAt = DateTime.tryParse(stamp);
  return BackupContents(
    data: AppData.fromJson(root['data']),
    format: format as int,
    exportedAt: exportedAt,
  );
}

/// Whether [bytes] start like a zip file (`PK\x03\x04`).
bool isZipBytes(List<int> bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x50 &&
    bytes[1] == 0x4b &&
    bytes[2] == 0x03 &&
    bytes[3] == 0x04;

/// A v2 backup: [kBackupDataEntry] and, under [kBackupAttachmentsFolder],
/// the [files] given (attachment file name → bytes). Media is stored, not
/// compressed again; only names that are safe attachment names and that
/// the data refers to are written.
Uint8List encodeBackupArchive(
  AppData data,
  DateTime exportedAt,
  Map<String, List<int>> files,
) {
  final referenced = data.attachmentFileNames;
  final archive = Archive()
    ..add(
      ArchiveFile.string(
        kBackupDataEntry,
        encodeBackup(data, exportedAt, format: kBackupArchiveFormat),
      ),
    );
  final names = files.keys.toList()..sort();
  for (final name in names) {
    if (!isSafeAttachmentFileName(name) || !referenced.contains(name)) {
      continue;
    }
    final bytes = files[name]!;
    archive.add(
      ArchiveFile.noCompress(
        '$kBackupAttachmentsFolder$name',
        bytes.length,
        bytes,
      ),
    );
  }
  return ZipEncoder().encodeBytes(archive, modified: exportedAt.toUtc());
}

/// Decodes a backup file: a v2 `.zip` or a v1 JSON file (UTF-8). Fully
/// validated; throws [FormatException] for anything else, so a restore can
/// be refused before anything changes.
BackupContents decodeBackupBytes(List<int> bytes) {
  if (bytes.length > kMaxBackupBytes) {
    throw const FormatException('The file is too large');
  }
  if (!isZipBytes(bytes)) {
    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('Not a text file');
    }
    return decodeBackupJson(text);
  }
  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes, verify: true);
  } on Object {
    throw const FormatException('Damaged archive');
  }
  var unpacked = 0;
  for (final f in archive) {
    if (f.isFile) unpacked += f.size;
  }
  if (unpacked > kMaxBackupUnpackedBytes) {
    throw const FormatException('The file is too large');
  }
  final dataEntry = archive.find(kBackupDataEntry);
  if (dataEntry == null || !dataEntry.isFile) {
    throw const FormatException('Not a Cartharise backup');
  }
  final dataBytes = _content(dataEntry);
  final String text;
  try {
    text = utf8.decode(dataBytes);
  } on FormatException {
    throw const FormatException('Not a Cartharise backup');
  }
  final json = decodeBackupJson(text);
  final referenced = json.referenced;
  final files = <String, Uint8List>{};
  for (final f in archive) {
    if (!f.isFile || !f.name.startsWith(kBackupAttachmentsFolder)) continue;
    final name = f.name.substring(kBackupAttachmentsFolder.length);
    // Only plain names the data refers to: nothing else is written, and a
    // name can never reach outside the attachments folder.
    if (!isSafeAttachmentFileName(name) || !referenced.contains(name)) {
      continue;
    }
    files[name] = _content(f);
  }
  return BackupContents(
    data: json.data,
    format: kBackupArchiveFormat,
    exportedAt: json.exportedAt,
    files: files,
  );
}

/// The entry's bytes, checked against its size and CRC.
Uint8List _content(ArchiveFile f) {
  try {
    final bytes = f.readBytes();
    final crc = f.crc32;
    if (bytes == null ||
        bytes.length != f.size ||
        (crc != null && getCrc32(bytes) != crc)) {
      throw const FormatException('Damaged archive');
    }
    return bytes;
  } on Object {
    // A bad CRC or size, or data that doesn't inflate.
    throw const FormatException('Damaged archive');
  }
}
