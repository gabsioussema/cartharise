/// The documented JSON backup format (F-040/F-041):
///
/// ```json
/// { "app": "cartharise", "format": 1, "exportedAt": "<ISO-8601 UTC>", "data": { …AppData… } }
/// ```
library;

import 'dart:convert';

import 'app_data.dart';

const String kBackupApp = 'cartharise';
const int kBackupFormat = 1;

String encodeBackup(AppData data, DateTime exportedAt) =>
    const JsonEncoder.withIndent('  ').convert({
      'app': kBackupApp,
      'format': kBackupFormat,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'data': data.toJson(),
    });

/// Parses and fully validates a backup. Throws [FormatException] for anything
/// that is not a complete Cartharise backup; never returns partial data.
AppData decodeBackup(String text) {
  final Object? root;
  try {
    root = jsonDecode(text);
  } on FormatException {
    throw const FormatException('Not a JSON file');
  }
  if (root is! Map || root['app'] != kBackupApp) {
    throw const FormatException('Not a Cartharise backup');
  }
  if (root['format'] != kBackupFormat) {
    throw FormatException('Unsupported backup format', root['format']);
  }
  return AppData.fromJson(root['data']);
}
