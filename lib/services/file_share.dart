import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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

  /// Writes [bytes] to a temporary [filename] (e.g. the `.zip` backup) and
  /// opens the share sheet. Throws on failure (show an honest message).
  Future<ShareOutcome> shareBytesFile(
    String filename,
    Uint8List bytes,
    String mimeType,
  );

  /// Lets the user pick a text file; its contents, or null if cancelled.
  /// Throws [FormatException] for files that are not UTF-8 text or too large.
  Future<String?> pickTextFile();

  /// Lets the user pick any file (a `.zip` or `.json` backup); its bytes,
  /// or null if cancelled. Throws [FormatException] ('The file is too
  /// large') above [maxBytes].
  Future<Uint8List?> pickFileBytes({int maxBytes = kMaxImportBytes});

  /// Deletes every copy of the user's words made while moving files in and
  /// out: export files in the app's private temporary folder (ours and the
  /// share sheet's) and the file picker's cached copies of imported files.
  /// Part of "Delete all data". Throws if something couldn't be deleted.
  Future<void> clearTemporaryFiles();
}

/// Largest file [FileShare.pickTextFile] accepts (a backup of years of
/// writing is far smaller).
const int kMaxImportBytes = 20 * 1024 * 1024;

class SystemFileShare implements FileShare {
  /// Our export copies, in the app's private temporary folder.
  static const _shareFolder = 'share';

  /// share_plus copies shared files here on Android (`cacheDir/share_plus`,
  /// which is what `getTemporaryDirectory()` returns there) and only clears
  /// it at the next share.
  static const _sharePlusFolder = 'share_plus';

  Future<Directory> _temp(String name) async =>
      Directory('${(await getTemporaryDirectory()).path}/$name');

  @override
  Future<ShareOutcome> shareTextFile(
    String filename,
    String content,
    String mimeType,
  ) => _share(
    filename,
    mimeType,
    (file) => file.writeAsString(content, flush: true),
  );

  @override
  Future<ShareOutcome> shareBytesFile(
    String filename,
    Uint8List bytes,
    String mimeType,
  ) => _share(
    filename,
    mimeType,
    (file) => file.writeAsBytes(bytes, flush: true),
  );

  Future<ShareOutcome> _share(
    String filename,
    String mimeType,
    Future<File> Function(File file) write,
  ) async {
    final dir = await _temp(_shareFolder);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    final file = File('${dir.path}/$filename');
    try {
      await write(file);
      final result = await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: mimeType)]),
      );
      return switch (result.status) {
        ShareResultStatus.success => ShareOutcome.shared,
        ShareResultStatus.dismissed => ShareOutcome.dismissed,
        ShareResultStatus.unavailable => ShareOutcome.unavailable,
      };
    } finally {
      // The share sheet is done with our copy (Android works from its own
      // copy, see [clearTemporaryFiles]): keep no export lying around, even
      // when the sheet was dismissed.
      await _deleteQuietly(dir);
    }
  }

  @override
  Future<String?> pickTextFile() async {
    final bytes = await pickFileBytes();
    if (bytes == null) return null;
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('Not a text file');
    }
  }

  @override
  Future<Uint8List?> pickFileBytes({int maxBytes = kMaxImportBytes}) async {
    final picked = await FilePicker.pickFile(type: FileType.any);
    if (picked == null) return null;
    try {
      final length = await picked.length();
      if (length != null && length > maxBytes) {
        throw const FormatException('The file is too large');
      }
      final bytes = await picked.readAsBytes();
      if (bytes.length > maxBytes) {
        throw const FormatException('The file is too large');
      }
      return bytes;
    } finally {
      // The picker may have cached a copy of the file (Android:
      // cache/file_picker): it has been read, so remove it now. A failure
      // here doesn't block the import; "Delete all data" tries again.
      try {
        await FilePicker.clearTemporaryFiles();
      } on Object {
        // Best effort, see above.
      }
    }
  }

  @override
  Future<void> clearTemporaryFiles() async {
    for (final name in [_shareFolder, _sharePlusFolder]) {
      final dir = await _temp(name);
      if (await dir.exists()) await dir.delete(recursive: true);
    }
    await FilePicker.clearTemporaryFiles();
  }

  static Future<void> _deleteQuietly(Directory dir) async {
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } on Object {
      // Cleared again by the next export or by "Delete all data".
    }
  }
}
