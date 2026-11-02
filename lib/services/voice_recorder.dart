/// Voice recordings, on the phone only (the `record` package; no network,
/// no transcription). The microphone permission is asked only when the user
/// taps Record; a refusal is reported ([VoiceFailure.permissionDenied]) so
/// the UI can offer typing instead.
///
/// Recordings are written straight into the private attachments folder
/// (`AttachmentStore.newRecordingPath`). An interruption (a call, another
/// app taking the microphone) pauses the recording; [VoiceRecorder.stop]
/// then keeps what was recorded so far — a partial file is never thrown
/// away. Only [VoiceRecorder.cancel] deletes it. Nothing is logged.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:record/record.dart';

enum VoiceFailure {
  /// The user refused the microphone.
  permissionDenied,

  /// No microphone or no supported encoder.
  unavailable,

  /// Anything else (the file couldn't be written, …).
  failed,
}

class VoiceRecorderException implements Exception {
  const VoiceRecorderException(this.reason, [this.cause]);

  final VoiceFailure reason;
  final Object? cause;

  @override
  String toString() => 'VoiceRecorderException: ${reason.name}';
}

/// Shown as a clear recording state (never by colour alone).
enum VoiceRecorderState {
  idle,
  recording,

  /// Paused by an interruption; [VoiceRecorder.stop] keeps what was
  /// recorded.
  paused,
}

/// A finished (or interrupted) recording.
class RecordingResult {
  const RecordingResult({
    required this.path,
    required this.duration,
    this.interrupted = false,
  });

  final String path;

  /// Time spent recording (pauses excluded).
  final Duration duration;

  /// The recording was paused by an interruption before it was stopped.
  final bool interrupted;
}

/// Provided to the widget tree as `Provider<VoiceRecorder>`.
abstract class VoiceRecorder {
  /// Whether the microphone may be used. With [request] (only when the user
  /// tapped Record) the system asks them.
  Future<bool> hasPermission({bool request = true});

  /// Starts recording into [path]. Throws [VoiceRecorderException].
  Future<void> start(String path);

  /// Stops and keeps the file — whole, or what was recorded before an
  /// interruption. Null when nothing was being recorded.
  Future<RecordingResult?> stop();

  /// Stops and deletes the file.
  Future<void> cancel();

  bool get isRecording;

  VoiceRecorderState get state;

  /// The state as it changes (an interruption shows as paused).
  Stream<VoiceRecorderState> get states;

  /// Input level while recording, 0 (silence) to 1 (loud), a few times a
  /// second — for a calm level meter.
  Stream<double> get amplitude;

  /// Stops (keeping the file) and releases the microphone.
  Future<void> dispose();
}

/// Mono AAC at a modest bit rate: a minute is about 0.5 MB.
const RecordConfig kVoiceRecordConfig = RecordConfig(
  encoder: AudioEncoder.aacLc,
  bitRate: 64000,
  sampleRate: 44100,
  numChannels: 1,
  audioInterruption: AudioInterruptionMode.pause,
);

/// dBFS at or below which the meter shows silence.
const double _kSilenceDb = -50;

/// 0–1 level for a dBFS reading.
double levelOfDb(double db) {
  if (db.isNaN || db <= _kSilenceDb) return 0;
  if (db >= 0) return 1;
  return math.pow((db - _kSilenceDb) / -_kSilenceDb, 1.5).toDouble();
}

class RecordVoiceRecorder implements VoiceRecorder {
  AudioRecorder? _recorder;
  StreamSubscription<RecordState>? _stateSub;
  final _states = StreamController<VoiceRecorderState>.broadcast();
  VoiceRecorderState _state = VoiceRecorderState.idle;
  final _clock = Stopwatch();
  bool _interrupted = false;
  bool _stopping = false;

  AudioRecorder get _audio => _recorder ??= AudioRecorder();

  @override
  Future<bool> hasPermission({bool request = true}) async {
    try {
      return await _audio.hasPermission(request: request);
    } on Object {
      return false;
    }
  }

  @override
  Future<void> start(String path) async {
    if (_state != VoiceRecorderState.idle) {
      throw const VoiceRecorderException(VoiceFailure.failed);
    }
    if (!await hasPermission()) {
      throw const VoiceRecorderException(VoiceFailure.permissionDenied);
    }
    try {
      if (!await _audio.isEncoderSupported(kVoiceRecordConfig.encoder)) {
        throw const VoiceRecorderException(VoiceFailure.unavailable);
      }
      _interrupted = false;
      _stateSub ??= _audio.onStateChanged().listen(_onState);
      await _audio.start(kVoiceRecordConfig, path: path);
      _clock
        ..reset()
        ..start();
      _setState(VoiceRecorderState.recording);
    } on VoiceRecorderException {
      rethrow;
    } on Object catch (e) {
      _setState(VoiceRecorderState.idle);
      throw VoiceRecorderException(VoiceFailure.failed, e);
    }
  }

  void _onState(RecordState s) {
    if (_stopping) return;
    switch (s) {
      case RecordState.pause:
        _interrupted = true;
        _clock.stop();
        _setState(VoiceRecorderState.paused);
      case RecordState.record:
        _clock.start();
        _setState(VoiceRecorderState.recording);
      case RecordState.stop:
        // Stopped by the system: the file is kept; stop() reports it.
        _clock.stop();
    }
  }

  void _setState(VoiceRecorderState s) {
    if (_state == s) return;
    _state = s;
    _states.add(s);
  }

  @override
  Future<RecordingResult?> stop() async {
    if (_state == VoiceRecorderState.idle) return null;
    _stopping = true;
    try {
      final path = await _audio.stop();
      _clock.stop();
      if (path == null) return null;
      return RecordingResult(
        path: path,
        duration: _clock.elapsed,
        interrupted: _interrupted,
      );
    } on Object catch (e) {
      throw VoiceRecorderException(VoiceFailure.failed, e);
    } finally {
      _stopping = false;
      _setState(VoiceRecorderState.idle);
    }
  }

  @override
  Future<void> cancel() async {
    if (_state == VoiceRecorderState.idle) return;
    _stopping = true;
    try {
      await _audio.cancel();
    } on Object {
      // The partial file is removed with the orphans on the next load.
    } finally {
      _clock.stop();
      _stopping = false;
      _setState(VoiceRecorderState.idle);
    }
  }

  @override
  bool get isRecording => _state != VoiceRecorderState.idle;

  @override
  VoiceRecorderState get state => _state;

  @override
  Stream<VoiceRecorderState> get states => _states.stream;

  @override
  Stream<double> get amplitude => _audio
      .onAmplitudeChanged(const Duration(milliseconds: 200))
      .map((a) => levelOfDb(a.current));

  @override
  Future<void> dispose() async {
    if (isRecording) {
      try {
        await stop();
      } on Object {
        // Kept as it is on disk.
      }
    }
    await _stateSub?.cancel();
    _stateSub = null;
    await _recorder?.dispose();
    _recorder = null;
  }
}
