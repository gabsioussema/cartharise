import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// What happened to a share sheet.
enum ShareOutcome { shared, dismissed, unavailable }

/// Moves user-owned files in and out of the app — only when the user asks:
/// export via the system share sheet, import via the system file picker.
/// Provided to the widget tree as `Provider<FileShare>`.
abstract class FileShare {
  /// Writes [content] to a temporary [filename] and opens the share sheet.
  /// Throws on failure (show an honest message).
  Future<ShareOutcome> shareTextFile(
    String filename,
    String content,
    String mimeType,
  );

  /// Lets the user pick a text file; its contents, or null if cancelled.
  /// Throws [FormatException] for files that are not UTF-8 text or too large.
  Future<String?> pickTextFile();
}

/// Largest file [pickTextFile] accepts (a backup of years of writing is far smaller).
const int kMaxImportBytes = 20 * 1024 * 1024;

class SystemFileShare implements FileShare {
  @override
  Future<ShareOutcome> shareTextFile(
    String filename,
    String content,
    String mimeType,
  ) async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/share');
    // Only the latest export is kept in the private temp folder.
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    final file = File('${dir.path}/$filename');
    await file.writeAsString(content, flush: true);
    final result = await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType)]),
    );
    return switch (result.status) {
      ShareResultStatus.success => ShareOutcome.shared,
      ShareResultStatus.dismissed => ShareOutcome.dismissed,
      ShareResultStatus.unavailable => ShareOutcome.unavailable,
    };
  }

  @override
  Future<String?> pickTextFile() async {
    final picked = await FilePicker.pickFile(type: FileType.any);
    if (picked == null) return null;
    final length = await picked.length();
    if (length != null && length > kMaxImportBytes) {
      throw const FormatException('The file is too large');
    }
    final bytes = await picked.readAsBytes();
    if (bytes.length > kMaxImportBytes) {
      throw const FormatException('The file is too large');
    }
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('Not a text file');
    }
  }
}
