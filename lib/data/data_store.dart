/// Where the user's [AppData] lives. Local only: nothing here talks to a
/// network. The on-disk format is the documented backup format
/// (`domain/backup.dart`), so the saved file is itself a valid backup.
library;

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/app_data.dart';
import '../domain/backup.dart';

/// A saved file exists but can't be read or parsed. The caller must surface
/// this honestly and must NOT overwrite the file.
class StorageReadException implements Exception {
  const StorageReadException(this.message, [this.cause]);
  final String message;
  final Object? cause;
  @override
  String toString() => 'StorageReadException: $message';
}

/// Writing (or deleting) failed: storage full, blocked or unavailable.
class StorageWriteException implements Exception {
  const StorageWriteException(this.message, [this.cause]);
  final String message;
  final Object? cause;
  @override
  String toString() => 'StorageWriteException: $message';
}

abstract class DataStore {
  /// The saved data, or null when nothing has been saved yet. Throws
  /// [StorageReadException] when saved data exists but is unreadable.
  Future<AppData?> read();

  /// Replaces the saved data. Throws [StorageWriteException] on failure; the
  /// previously saved data is then still intact (writes are atomic).
  Future<void> write(AppData data);

  /// Removes everything saved by Cartharise.
  Future<void> clear();

  /// Moves an unreadable saved file aside (kept, not deleted) so the app can
  /// start empty. Returns where it was kept, or null when there was nothing.
  Future<String?> moveAside();

  /// Plain-language location, for storage transparency (F-043).
  String get locationDescription;
}

/// JSON in the app's private support directory, written atomically
/// (temporary file + rename) so a crash mid-write never corrupts the data.
class FileDataStore implements DataStore {
  /// [directory] defaults to `getApplicationSupportDirectory()`.
  FileDataStore({this.directory, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const fileName = 'cartharise.json';

  /// Where the file lives; null = the platform's app support directory.
  final Directory? directory;
  Directory? _resolved;
  final DateTime Function() _clock;

  Future<Directory> _dir() async =>
      _resolved ??= directory ?? await getApplicationSupportDirectory();

  Future<File> _file() async => File('${(await _dir()).path}/$fileName');

  @override
  String get locationDescription =>
      directory?.path ?? "Cartharise's private app folder on this device";

  @override
  Future<AppData?> read() async {
    final File file;
    final String text;
    try {
      file = await _file();
      if (!await file.exists()) return null;
      text = await file.readAsString();
    } on Object catch (e) {
      throw StorageReadException('The saved file could not be read', e);
    }
    try {
      return decodeBackup(text);
    } on FormatException catch (e) {
      throw StorageReadException('The saved file is damaged', e);
    }
  }

  @override
  Future<void> write(AppData data) async {
    try {
      final file = await _file();
      await file.parent.create(recursive: true);
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(encodeBackup(data, _clock()), flush: true);
      await tmp.rename(file.path);
    } on Object catch (e) {
      throw StorageWriteException('Saving to this device failed', e);
    }
  }

  @override
  Future<void> clear() async {
    try {
      final file = await _file();
      for (final f in [file, File('${file.path}.tmp')]) {
        if (await f.exists()) await f.delete();
      }
    } on Object catch (e) {
      throw StorageWriteException('Deleting the saved data failed', e);
    }
  }

  @override
  Future<String?> moveAside() async {
    try {
      final file = await _file();
      if (!await file.exists()) return null;
      final stamp = _clock().toUtc().toIso8601String().replaceAll(':', '-');
      final kept = '${file.parent.path}/cartharise.unreadable-$stamp.json';
      await file.rename(kept);
      return kept;
    } on Object catch (e) {
      throw StorageWriteException(
        'Setting the unreadable file aside failed',
        e,
      );
    }
  }
}

/// In-memory store for tests and previews. Round-trips through the real JSON
/// format so serialisation is exercised, and can be told to fail.
class MemoryDataStore implements DataStore {
  MemoryDataStore([AppData? initial])
    : raw = initial == null ? null : encodeBackup(initial, DateTime.utc(2026));

  /// The stored text (set it to anything to simulate a damaged file).
  String? raw;

  /// Text set aside by [moveAside].
  String? asideRaw;

  bool failReads = false;
  bool failWrites = false;
  int writes = 0;

  /// Makes [read] take this long (to see loading states in widget tests).
  Duration readDelay = Duration.zero;

  @override
  String get locationDescription => 'memory (test)';

  /// The currently saved data (decoded), or null.
  AppData? get saved => raw == null ? null : decodeBackup(raw!);

  @override
  Future<AppData?> read() async {
    if (readDelay > Duration.zero) await Future<void>.delayed(readDelay);
    if (failReads) throw const StorageReadException('Simulated read failure');
    final text = raw;
    if (text == null) return null;
    try {
      return decodeBackup(text);
    } on FormatException catch (e) {
      throw StorageReadException('The saved file is damaged', e);
    }
  }

  @override
  Future<void> write(AppData data) async {
    if (failWrites) {
      throw const StorageWriteException('Simulated write failure');
    }
    writes++;
    raw = encodeBackup(data, DateTime.utc(2026));
  }

  @override
  Future<void> clear() async {
    if (failWrites) {
      throw const StorageWriteException('Simulated delete failure');
    }
    raw = null;
  }

  @override
  Future<String?> moveAside() async {
    if (raw == null) return null;
    asideRaw = raw;
    raw = null;
    return 'memory (set aside)';
  }
}
