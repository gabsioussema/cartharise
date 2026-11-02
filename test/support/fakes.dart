import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cartharise/reminders/reminder_plan.dart';
import 'package:cartharise/reminders/reminder_scheduler.dart';
import 'package:cartharise/services/attachment_store.dart';
import 'package:cartharise/services/file_share.dart';
import 'package:cartharise/services/media_picker.dart';
import 'package:cartharise/services/voice_player.dart';
import 'package:cartharise/services/voice_recorder.dart';

export 'package:cartharise/services/attachment_store.dart'
    show MemoryAttachmentStore;

/// Records what would be scheduled; answers permission with [permission].
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.permission = ReminderPermission.granted});

  ReminderPermission permission;
  List<PlannedReminder> scheduled = const [];
  int permissionRequests = 0;
  int cancelCount = 0;
  bool failSchedule = false;
  String? launchPayload;
  final _taps = StreamController<String>.broadcast();

  @override
  Future<ReminderPermission> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> schedule(List<PlannedReminder> plans) async {
    if (failSchedule) throw StateError('Simulated scheduling failure');
    scheduled = List.of(plans);
  }

  @override
  Future<void> cancelAll() async {
    cancelCount++;
    scheduled = const [];
  }

  /// Simulates the user tapping a notification for [promptId].
  void tap(String promptId) => _taps.add(promptId);

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> takeLaunchPayload() async {
    final p = launchPayload;
    launchPayload = null;
    return p;
  }

  /// The localized notification channel text the UI set, if any.
  String? channelName;
  String? channelDescription;

  @override
  void setChannelText({required String name, required String description}) {
    channelName = name;
    channelDescription = description;
  }
}

/// A shared file, as the fake share sheet saw it. [content] is the text of
/// a text file ('' for a binary one); [bytes] is the file as shared.
class SharedFile {
  SharedFile(this.filename, this.content, this.mimeType, [Uint8List? bytes])
    : bytes = bytes ?? Uint8List.fromList(utf8.encode(content));
  final String filename;
  final String content;
  final String mimeType;
  final Uint8List bytes;
}

/// Records shares; [pickResult] (text) or [pickBytes] is what the "file
/// picker" returns.
class FakeFileShare implements FileShare {
  final List<SharedFile> shared = [];
  ShareOutcome outcome = ShareOutcome.shared;
  bool failShare = false;
  String? pickResult;

  /// A binary file to pick (e.g. a `.zip` backup); wins over [pickResult].
  Uint8List? pickBytes;
  Object? pickError;

  /// How often [clearTemporaryFiles] ran; [failClear] makes it throw.
  int clearCount = 0;
  bool failClear = false;

  @override
  Future<ShareOutcome> shareTextFile(
    String filename,
    String content,
    String mimeType,
  ) async {
    if (failShare) throw StateError('Simulated share failure');
    shared.add(SharedFile(filename, content, mimeType));
    return outcome;
  }

  @override
  Future<ShareOutcome> shareBytesFile(
    String filename,
    Uint8List bytes,
    String mimeType,
  ) async {
    if (failShare) throw StateError('Simulated share failure');
    shared.add(SharedFile(filename, '', mimeType, Uint8List.fromList(bytes)));
    return outcome;
  }

  @override
  Future<String?> pickTextFile() async {
    if (pickError != null) throw pickError!;
    return pickResult;
  }

  @override
  Future<Uint8List?> pickFileBytes({int maxBytes = kMaxImportBytes}) async {
    if (pickError != null) throw pickError!;
    final bytes =
        pickBytes ??
        (pickResult == null
            ? null
            : Uint8List.fromList(utf8.encode(pickResult!)));
    if (bytes != null && bytes.length > maxBytes) {
      throw const FormatException('The file is too large');
    }
    return bytes;
  }

  @override
  Future<void> clearTemporaryFiles() async {
    clearCount++;
    if (failClear) throw StateError('Simulated cleanup failure');
  }
}

/// The photo picker: [nextPhoto] is the path "picked" (null = cancelled),
/// [error] what it throws. Register the bytes at that path in a
/// [MemoryAttachmentStore.sources] (or write a real file) to import it.
class FakeMediaPicker implements MediaPicker {
  String? nextPhoto;
  MediaPickerException? error;
  String? lostPhoto;

  /// `camera` of each [pickPhoto] call, in order.
  final List<bool> requests = [];
  final List<String> released = [];
  int clearCount = 0;
  bool failClear = false;

  @override
  Future<String?> pickPhoto({required bool camera}) async {
    requests.add(camera);
    if (error != null) throw error!;
    return nextPhoto;
  }

  @override
  Future<String?> recoverLostPhoto() async {
    final p = lostPhoto;
    lostPhoto = null;
    return p;
  }

  @override
  Future<void> release(String path) async => released.add(path);

  @override
  Future<void> clearTemporaryFiles() async {
    clearCount++;
    if (failClear) throw StateError('Simulated cleanup failure');
  }
}

/// The microphone: [permission] answers the permission question, [bytes]
/// is what a recording "writes" on [stop] (into [store] for its memory
/// paths, else a real file). [interrupt] pauses like a phone call does;
/// [stop] then still keeps what was recorded.
class FakeVoiceRecorder implements VoiceRecorder {
  FakeVoiceRecorder({this.store});

  final MemoryAttachmentStore? store;
  bool permission = true;
  int permissionRequests = 0;
  VoiceFailure? failStart;
  List<int> bytes = const [1, 2, 3, 4];
  Duration elapsed = const Duration(seconds: 3);
  String? _path;
  bool _interrupted = false;
  VoiceRecorderState _state = VoiceRecorderState.idle;
  final _states = StreamController<VoiceRecorderState>.broadcast();
  final _levels = StreamController<double>.broadcast();

  /// Paths recordings were started into.
  final List<String> started = [];
  int cancelCount = 0;

  void _set(VoiceRecorderState s) {
    _state = s;
    _states.add(s);
  }

  /// Simulates an interruption (a call): the recording pauses.
  void interrupt() {
    if (_state != VoiceRecorderState.recording) return;
    _interrupted = true;
    _set(VoiceRecorderState.paused);
  }

  /// Sends a level to [amplitude] listeners.
  void level(double value) => _levels.add(value);

  @override
  Future<bool> hasPermission({bool request = true}) async {
    if (request) permissionRequests++;
    return permission;
  }

  @override
  Future<void> start(String path) async {
    if (!await hasPermission()) {
      throw const VoiceRecorderException(VoiceFailure.permissionDenied);
    }
    if (failStart != null) throw VoiceRecorderException(failStart!);
    started.add(path);
    _path = path;
    _interrupted = false;
    _set(VoiceRecorderState.recording);
  }

  @override
  Future<RecordingResult?> stop() async {
    final path = _path;
    if (path == null) return null;
    final memory = store;
    if (memory != null && path.startsWith(MemoryAttachmentStore.kMemoryRoot)) {
      memory.writeRecording(path, bytes);
    } else {
      File(path).writeAsBytesSync(bytes);
    }
    _path = null;
    _set(VoiceRecorderState.idle);
    return RecordingResult(
      path: path,
      duration: elapsed,
      interrupted: _interrupted,
    );
  }

  @override
  Future<void> cancel() async {
    if (_path == null) return;
    cancelCount++;
    _path = null;
    _set(VoiceRecorderState.idle);
  }

  @override
  bool get isRecording => _state != VoiceRecorderState.idle;

  @override
  VoiceRecorderState get state => _state;

  @override
  Stream<VoiceRecorderState> get states => _states.stream;

  @override
  Stream<double> get amplitude => _levels.stream;

  @override
  Future<void> dispose() async {
    if (isRecording) await stop();
  }
}

/// Playback: records what was played; [failPlay] makes [play] throw.
class FakeVoicePlayer implements VoicePlayer {
  final List<String> played = [];
  bool failPlay = false;
  String? _path;
  VoicePlayerState _state = VoicePlayerState.stopped;
  final _states = StreamController<VoicePlayerState>.broadcast();
  final _positions = StreamController<Duration>.broadcast();
  final _durations = StreamController<Duration>.broadcast();

  void _set(VoicePlayerState s) {
    _state = s;
    _states.add(s);
  }

  /// Sends a position to listeners.
  void positionAt(Duration d) => _positions.add(d);

  /// Ends playback as the file would.
  void complete() => _set(VoicePlayerState.completed);

  @override
  Future<void> play(String path) async {
    if (failPlay) throw const VoicePlayerException();
    played.add(path);
    _path = path;
    _set(VoicePlayerState.playing);
    _durations.add(const Duration(seconds: 3));
  }

  @override
  Future<void> pause() async => _set(VoicePlayerState.paused);

  @override
  Future<void> resume() async => _set(VoicePlayerState.playing);

  @override
  Future<void> stop() async {
    _path = null;
    _set(VoicePlayerState.stopped);
  }

  @override
  Future<void> seek(Duration position) async => _positions.add(position);

  @override
  String? get currentPath => _path;

  @override
  VoicePlayerState get state => _state;

  @override
  Stream<VoicePlayerState> get states => _states.stream;

  @override
  Stream<Duration> get position => _positions.stream;

  @override
  Stream<Duration> get duration => _durations.stream;

  @override
  Future<void> dispose() async {}
}
