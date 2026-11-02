/// Where photos and voice recordings live: the app's private `attachments/`
/// folder, next to the data file (`getApplicationSupportDirectory()`), so it
/// is kept out of OS backups exactly like the data file — Android by the
/// manifest rules (the whole `files` domain is excluded), iOS by marking the
/// folder `isExcludedFromBackup` (see `lib/data/backup_exclusion.dart`).
///
/// Local only: nothing here talks to a network, and no file name, path or
/// user text is ever logged. Failures are typed ([AttachmentException]) so
/// the UI can say honestly what happened and offer an alternative.
library;

import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../domain/app_data.dart';

/// Largest photo or recording kept (a long voice note is a few MB).
const int kMaxAttachmentBytes = 50 * 1024 * 1024;

/// Why an attachment operation failed.
enum AttachmentFailure {
  /// The picked file or the recording isn't there (any more).
  sourceMissing,

  /// The file is empty: nothing was recorded or picked.
  empty,

  /// Larger than [kMaxAttachmentBytes].
  tooLarge,

  /// Copying or writing failed (storage full, blocked or unavailable).
  writeFailed,

  /// The attachment's file is missing from the folder.
  missing,

  /// The file exists but couldn't be read.
  readFailed,

  /// The file couldn't be removed.
  deleteFailed,
}

/// A failed attachment operation. Never claim the photo or recording was
/// kept; say [reason] plainly and offer retry (or typing instead).
class AttachmentException implements Exception {
  const AttachmentException(this.reason, [this.cause]);

  final AttachmentFailure reason;
  final Object? cause;

  @override
  String toString() => 'AttachmentException: ${reason.name}';
}

/// The private folder of attachment files. Methods taking an [Attachment]
/// work on its [Attachment.fileName]; the `…File` methods take a file name
/// (backup, restore and cleanup).
abstract class AttachmentStore {
  /// Copies the file at [sourcePath] (e.g. the photo picker's temporary
  /// copy) into the folder as a new attachment. The source is left as it
  /// is. Throws [AttachmentException] (`sourceMissing`, `empty`,
  /// `tooLarge`, `writeFailed`); nothing is kept then.
  Future<Attachment> importFile(
    String sourcePath, {
    required AttachmentKind kind,
    int? durationMs,
  });

  /// A new path inside the folder for a voice recording to be written to
  /// directly. Until [adoptRecording] or [discardRecording] it is pending:
  /// [deleteOrphans] leaves it alone.
  Future<String> newRecordingPath();

  /// The recording written to [path] (from [newRecordingPath]) as an
  /// attachment — the whole file, or what was recorded before an
  /// interruption. Throws [AttachmentException] (`sourceMissing`, `empty`)
  /// when nothing was recorded: never claim a recording that didn't happen.
  Future<Attachment> adoptRecording(String path, {int? durationMs});

  /// Removes a pending recording (the user cancelled).
  Future<void> discardRecording(String path);

  /// The attachment's file (it may be missing: check [exists]).
  Future<File> fileFor(Attachment attachment);

  Future<bool> exists(Attachment attachment) => hasFile(attachment.fileName);

  /// The file's bytes. Throws [AttachmentException] (`missing`,
  /// `readFailed`).
  Future<Uint8List> readBytes(Attachment attachment) =>
      readFile(attachment.fileName);

  /// Removes the attachment's file (a missing file is fine). Throws
  /// [AttachmentException] (`deleteFailed`).
  Future<void> delete(Attachment attachment) => deleteFile(attachment.fileName);

  /// Bytes the attachment's file takes (0 when missing).
  Future<int> sizeOf(Attachment attachment) => sizeOfFile(attachment.fileName);

  /// Removes the whole folder ("Delete all data"). Throws
  /// [AttachmentException] (`deleteFailed`) if something stays.
  Future<void> deleteAll();

  /// Bytes all attachment files take together.
  Future<int> totalSize();

  /// The names of the files in the folder.
  Future<Set<String>> fileNames();

  Future<bool> hasFile(String fileName);

  /// Throws [AttachmentException] (`missing`, `readFailed`).
  Future<Uint8List> readFile(String fileName);

  /// Writes [bytes] as [fileName] (restoring a backup), replacing a file of
  /// that name. Atomic. Throws [ArgumentError] for a name that isn't a safe
  /// attachment name, [AttachmentException] (`writeFailed`) on failure.
  Future<void> writeFile(String fileName, List<int> bytes);

  /// Throws [AttachmentException] (`deleteFailed`).
  Future<void> deleteFile(String fileName);

  Future<int> sizeOfFile(String fileName);

  /// Deletes every file in the folder that is not in [keep] and not a
  /// pending recording. Returns how many were deleted. Never touches a
  /// file still referenced.
  Future<int> deleteOrphans(Set<String> keep);

  /// Sets the folder aside (renamed, kept) when the data file was unreadable
  /// and the user starts fresh, so the files it named are not cleaned up.
  /// Returns where it was kept, or null when there was nothing.
  Future<String?> moveAside();
}

/// File extensions kept for imported files, per kind.
const _photoExtensions = {'jpg', 'jpeg', 'png', 'heic', 'heif', 'webp', 'gif'};
const _audioExtensions = {'m4a', 'aac', 'mp3', 'wav', 'ogg', 'opus', 'mp4'};

String _extensionFor(String sourcePath, AttachmentKind kind) {
  final name = sourcePath.split(RegExp(r'[/\\]')).last;
  final dot = name.lastIndexOf('.');
  final ext = dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
  final allowed = kind == AttachmentKind.photo
      ? _photoExtensions
      : _audioExtensions;
  if (allowed.contains(ext)) return ext;
  return kind == AttachmentKind.photo ? 'jpg' : 'm4a';
}

/// The extension a new voice recording gets (AAC in an MP4 container).
const String kRecordingExtension = 'm4a';

/// Makes attachment ids such as `att_lz3k9a1f…` (time + counter + salt).
class _Ids {
  _Ids(this._clock);

  final DateTime Function() _clock;
  final _random = Random();
  int _counter = 0;

  String next() {
    final stamp = _clock().microsecondsSinceEpoch.toRadixString(36);
    final salt = _random.nextInt(1 << 20).toRadixString(36);
    return 'att_$stamp${(_counter++).toRadixString(36)}$salt';
  }
}

/// The real store: files in `<app support>/attachments/`, written through a
/// temporary file and a rename so a crash never leaves half a photo.
class FileAttachmentStore extends AttachmentStore {
  /// [directory] is the data folder (default: the app support directory,
  /// where `FileDataStore` keeps `cartharise.json`).
  FileAttachmentStore({
    this.directory,
    this.excludeFromBackup,
    DateTime Function()? clock,
    this.maxBytes = kMaxAttachmentBytes,
  }) : _clock = clock ?? DateTime.now,
       _ids = _Ids(clock ?? DateTime.now);

  static const folderName = 'attachments';

  /// The data folder; null = the platform's app support directory.
  final Directory? directory;

  /// Called with the attachments folder's path after it is created or
  /// written to, to keep it out of OS backups where that takes code (iOS).
  /// A failure is kept in [backupExclusionError] and retried next time.
  final Future<void> Function(String folderPath)? excludeFromBackup;

  /// Why the last [excludeFromBackup] call failed, or null.
  Object? backupExclusionError;

  final int maxBytes;
  final DateTime Function() _clock;
  final _Ids _ids;
  final Set<String> _pending = {};
  Directory? _parent;

  Future<Directory> _parentDir() async =>
      _parent ??= directory ?? await getApplicationSupportDirectory();

  Future<Directory> _folder() async =>
      Directory('${(await _parentDir()).path}/$folderName');

  Future<Directory> _ensureFolder() async {
    final folder = await _folder();
    if (!await folder.exists()) await folder.create(recursive: true);
    final exclude = excludeFromBackup;
    if (exclude != null) {
      try {
        await exclude(folder.path);
        backupExclusionError = null;
      } on Object catch (e) {
        backupExclusionError = e;
      }
    }
    return folder;
  }

  Future<File> _file(String fileName) async =>
      File('${(await _folder()).path}/$fileName');

  /// The file name of [path] if it is directly inside the folder.
  Future<String?> _nameInFolder(String path) async {
    final folder = (await _folder()).path;
    final file = File(path);
    if (file.parent.path != folder) return null;
    final name = file.uri.pathSegments.last;
    return isSafeAttachmentFileName(name) ? name : null;
  }

  @override
  Future<Attachment> importFile(
    String sourcePath, {
    required AttachmentKind kind,
    int? durationMs,
  }) async {
    final source = File(sourcePath);
    final int length;
    try {
      if (!await source.exists()) {
        throw const AttachmentException(AttachmentFailure.sourceMissing);
      }
      length = await source.length();
    } on AttachmentException {
      rethrow;
    } on Object catch (e) {
      throw AttachmentException(AttachmentFailure.sourceMissing, e);
    }
    if (length == 0) throw const AttachmentException(AttachmentFailure.empty);
    if (length > maxBytes) {
      throw const AttachmentException(AttachmentFailure.tooLarge);
    }
    final id = _ids.next();
    final fileName = '$id.${_extensionFor(sourcePath, kind)}';
    File? tmp;
    try {
      final folder = await _ensureFolder();
      tmp = File('${folder.path}/$fileName.tmp');
      await source.copy(tmp.path);
      await tmp.rename('${folder.path}/$fileName');
    } on Object catch (e) {
      await _deleteQuietly(tmp);
      throw AttachmentException(AttachmentFailure.writeFailed, e);
    }
    return Attachment(
      id: id,
      kind: kind,
      fileName: fileName,
      createdAt: _clock(),
      durationMs: durationMs,
    );
  }

  @override
  Future<String> newRecordingPath() async {
    final Directory folder;
    try {
      folder = await _ensureFolder();
    } on Object catch (e) {
      throw AttachmentException(AttachmentFailure.writeFailed, e);
    }
    final fileName = '${_ids.next()}.$kRecordingExtension';
    _pending.add(fileName);
    return '${folder.path}/$fileName';
  }

  @override
  Future<Attachment> adoptRecording(String path, {int? durationMs}) async {
    final name = await _nameInFolder(path);
    if (name == null) {
      throw const AttachmentException(AttachmentFailure.sourceMissing);
    }
    final file = File(path);
    final int length;
    try {
      length = await file.exists() ? await file.length() : -1;
    } on Object catch (e) {
      throw AttachmentException(AttachmentFailure.readFailed, e);
    }
    if (length < 0) {
      _pending.remove(name);
      throw const AttachmentException(AttachmentFailure.sourceMissing);
    }
    if (length == 0) {
      _pending.remove(name);
      await _deleteQuietly(file);
      throw const AttachmentException(AttachmentFailure.empty);
    }
    _pending.remove(name);
    final dot = name.lastIndexOf('.');
    return Attachment(
      id: dot < 0 ? name : name.substring(0, dot),
      kind: AttachmentKind.audio,
      fileName: name,
      createdAt: _clock(),
      durationMs: durationMs,
    );
  }

  @override
  Future<void> discardRecording(String path) async {
    final name = await _nameInFolder(path);
    if (name == null) return;
    _pending.remove(name);
    await deleteFile(name);
  }

  @override
  Future<File> fileFor(Attachment attachment) => _file(attachment.fileName);

  @override
  Future<void> deleteAll() async {
    _pending.clear();
    try {
      final folder = await _folder();
      if (await folder.exists()) await folder.delete(recursive: true);
    } on Object catch (e) {
      throw AttachmentException(AttachmentFailure.deleteFailed, e);
    }
  }

  @override
  Future<int> totalSize() async {
    var total = 0;
    for (final f in await _files()) {
      try {
        total += await f.length();
      } on Object {
        // Gone meanwhile.
      }
    }
    return total;
  }

  Future<List<File>> _files() async {
    final folder = await _folder();
    if (!await folder.exists()) return const [];
    return [
      await for (final e in folder.list(followLinks: false))
        if (e is File) e,
    ];
  }

  @override
  Future<Set<String>> fileNames() async => {
    for (final f in await _files())
      if (!f.path.endsWith('.tmp')) f.uri.pathSegments.last,
  };

  @override
  Future<bool> hasFile(String fileName) async {
    if (!isSafeAttachmentFileName(fileName)) return false;
    try {
      return await (await _file(fileName)).exists();
    } on Object {
      return false;
    }
  }

  @override
  Future<Uint8List> readFile(String fileName) async {
    if (!await hasFile(fileName)) {
      throw const AttachmentException(AttachmentFailure.missing);
    }
    try {
      return await (await _file(fileName)).readAsBytes();
    } on Object catch (e) {
      throw AttachmentException(AttachmentFailure.readFailed, e);
    }
  }

  @override
  Future<void> writeFile(String fileName, List<int> bytes) async {
    if (!isSafeAttachmentFileName(fileName)) {
      throw ArgumentError.value(fileName, 'fileName', 'is not a plain name');
    }
    File? tmp;
    try {
      final folder = await _ensureFolder();
      tmp = File('${folder.path}/$fileName.tmp');
      await tmp.writeAsBytes(bytes, flush: true);
      await tmp.rename('${folder.path}/$fileName');
    } on Object catch (e) {
      await _deleteQuietly(tmp);
      throw AttachmentException(AttachmentFailure.writeFailed, e);
    }
  }

  @override
  Future<void> deleteFile(String fileName) async {
    if (!isSafeAttachmentFileName(fileName)) return;
    try {
      final file = await _file(fileName);
      if (await file.exists()) await file.delete();
    } on Object catch (e) {
      throw AttachmentException(AttachmentFailure.deleteFailed, e);
    }
  }

  @override
  Future<int> sizeOfFile(String fileName) async {
    if (!await hasFile(fileName)) return 0;
    try {
      return await (await _file(fileName)).length();
    } on Object {
      return 0;
    }
  }

  @override
  Future<int> deleteOrphans(Set<String> keep) async {
    var deleted = 0;
    for (final f in await _files()) {
      final name = f.uri.pathSegments.last;
      if (keep.contains(name) || _pending.contains(name)) continue;
      try {
        await f.delete();
        deleted++;
      } on Object {
        // Tried again on the next load.
      }
    }
    return deleted;
  }

  @override
  Future<String?> moveAside() async {
    final folder = await _folder();
    if (!await folder.exists()) return null;
    final stamp = _clock().toUtc().toIso8601String().replaceAll(':', '-');
    final kept = '${(await _parentDir()).path}/$folderName.unreadable-$stamp';
    try {
      await folder.rename(kept);
    } on Object catch (e) {
      throw AttachmentException(AttachmentFailure.writeFailed, e);
    }
    _pending.clear();
    return kept;
  }

  static Future<void> _deleteQuietly(File? file) async {
    if (file == null) return;
    try {
      if (await file.exists()) await file.delete();
    } on Object {
      // Cleaned up with the orphans on the next load.
    }
  }
}

/// In-memory store for tests and previews (like `MemoryDataStore`), with
/// the same rules as [FileAttachmentStore] and switches to simulate
/// failures. Paths it hands out start with [kMemoryRoot] and exist only
/// here; [importFile] reads a real file only when [sources] has no bytes for
/// that path.
class MemoryAttachmentStore extends AttachmentStore {
  MemoryAttachmentStore({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      _ids = _Ids(clock ?? DateTime.now);

  static const kMemoryRoot = '/memory/attachments';

  final DateTime Function() _clock;
  final _Ids _ids;

  /// The folder's files: name → bytes.
  final Map<String, Uint8List> files = {};

  /// Bytes "picked" at a path (what [importFile] copies).
  final Map<String, List<int>> sources = {};

  /// Pending recordings (name → bytes written so far by a fake recorder).
  final Map<String, Uint8List?> _pending = {};

  bool failWrites = false;
  bool failReads = false;
  bool failDeletes = false;
  int maxBytes = kMaxAttachmentBytes;

  /// The folder after [moveAside], if it was set aside.
  Map<String, Uint8List>? asideFiles;

  String _nameOf(String path) => path.split('/').last;

  /// What a recorder writes to a [newRecordingPath] (used by fakes).
  void writeRecording(String path, List<int> bytes) {
    final name = _nameOf(path);
    if (!_pending.containsKey(name)) {
      throw StateError('Not a pending recording path');
    }
    _pending[name] = Uint8List.fromList(bytes);
  }

  @override
  Future<Attachment> importFile(
    String sourcePath, {
    required AttachmentKind kind,
    int? durationMs,
  }) async {
    List<int>? bytes = sources[sourcePath];
    if (bytes == null) {
      final file = File(sourcePath);
      if (!file.existsSync()) {
        throw const AttachmentException(AttachmentFailure.sourceMissing);
      }
      bytes = file.readAsBytesSync();
    }
    if (bytes.isEmpty) throw const AttachmentException(AttachmentFailure.empty);
    if (bytes.length > maxBytes) {
      throw const AttachmentException(AttachmentFailure.tooLarge);
    }
    if (failWrites) {
      throw const AttachmentException(AttachmentFailure.writeFailed);
    }
    final id = _ids.next();
    final fileName = '$id.${_extensionFor(sourcePath, kind)}';
    files[fileName] = Uint8List.fromList(bytes);
    return Attachment(
      id: id,
      kind: kind,
      fileName: fileName,
      createdAt: _clock(),
      durationMs: durationMs,
    );
  }

  @override
  Future<String> newRecordingPath() async {
    if (failWrites) {
      throw const AttachmentException(AttachmentFailure.writeFailed);
    }
    final fileName = '${_ids.next()}.$kRecordingExtension';
    _pending[fileName] = null;
    return '$kMemoryRoot/$fileName';
  }

  @override
  Future<Attachment> adoptRecording(String path, {int? durationMs}) async {
    final name = _nameOf(path);
    if (!path.startsWith('$kMemoryRoot/') || !_pending.containsKey(name)) {
      throw const AttachmentException(AttachmentFailure.sourceMissing);
    }
    final bytes = _pending.remove(name);
    if (bytes == null) {
      throw const AttachmentException(AttachmentFailure.sourceMissing);
    }
    if (bytes.isEmpty) throw const AttachmentException(AttachmentFailure.empty);
    files[name] = bytes;
    return Attachment(
      id: name.substring(0, name.lastIndexOf('.')),
      kind: AttachmentKind.audio,
      fileName: name,
      createdAt: _clock(),
      durationMs: durationMs,
    );
  }

  @override
  Future<void> discardRecording(String path) async {
    _pending.remove(_nameOf(path));
  }

  /// Names of recordings started and neither kept nor discarded.
  Set<String> get pendingRecordings => _pending.keys.toSet();

  @override
  Future<File> fileFor(Attachment attachment) async =>
      File('$kMemoryRoot/${attachment.fileName}');

  @override
  Future<void> deleteAll() async {
    if (failDeletes) {
      throw const AttachmentException(AttachmentFailure.deleteFailed);
    }
    files.clear();
    _pending.clear();
  }

  @override
  Future<int> totalSize() async =>
      files.values.fold<int>(0, (sum, b) => sum + b.length);

  @override
  Future<Set<String>> fileNames() async => files.keys.toSet();

  @override
  Future<bool> hasFile(String fileName) async => files.containsKey(fileName);

  @override
  Future<Uint8List> readFile(String fileName) async {
    final bytes = files[fileName];
    if (bytes == null) {
      throw const AttachmentException(AttachmentFailure.missing);
    }
    if (failReads) {
      throw const AttachmentException(AttachmentFailure.readFailed);
    }
    return bytes;
  }

  @override
  Future<void> writeFile(String fileName, List<int> bytes) async {
    if (!isSafeAttachmentFileName(fileName)) {
      throw ArgumentError.value(fileName, 'fileName', 'is not a plain name');
    }
    if (failWrites) {
      throw const AttachmentException(AttachmentFailure.writeFailed);
    }
    files[fileName] = Uint8List.fromList(bytes);
  }

  @override
  Future<void> deleteFile(String fileName) async {
    if (failDeletes) {
      throw const AttachmentException(AttachmentFailure.deleteFailed);
    }
    files.remove(fileName);
  }

  @override
  Future<int> sizeOfFile(String fileName) async => files[fileName]?.length ?? 0;

  @override
  Future<int> deleteOrphans(Set<String> keep) async {
    if (failDeletes) return 0;
    final orphans = [
      for (final name in files.keys)
        if (!keep.contains(name) && !_pending.containsKey(name)) name,
    ];
    orphans.forEach(files.remove);
    return orphans.length;
  }

  @override
  Future<String?> moveAside() async {
    if (files.isEmpty) return null;
    asideFiles = Map.of(files);
    files.clear();
    _pending.clear();
    return 'memory (set aside)';
  }
}
