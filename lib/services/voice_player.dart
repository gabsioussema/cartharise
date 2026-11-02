/// Plays the user's own voice recordings from the private attachments
/// folder (the `audioplayers` package, local files only — never a URL).
/// Playback starts only on an explicit tap. Nothing is logged.
library;

import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

enum VoicePlayerState { stopped, playing, paused, completed }

/// Playback failed (the file is missing or can't be decoded).
class VoicePlayerException implements Exception {
  const VoicePlayerException([this.cause]);

  final Object? cause;

  @override
  String toString() => 'VoicePlayerException';
}

/// Provided to the widget tree as `Provider<VoicePlayer>`. One recording
/// plays at a time: playing another stops the current one.
abstract class VoicePlayer {
  /// Plays the local file at [path] from the start. Throws
  /// [VoicePlayerException].
  Future<void> play(String path);

  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> seek(Duration position);

  /// The file playing (or paused), or null.
  String? get currentPath;

  VoicePlayerState get state;
  Stream<VoicePlayerState> get states;

  /// Position while playing.
  Stream<Duration> get position;

  /// Length of the file playing, once known.
  Stream<Duration> get duration;

  Future<void> dispose();
}

class AudioVoicePlayer implements VoicePlayer {
  AudioPlayer? _player;
  final List<StreamSubscription<Object?>> _subs = [];
  final _states = StreamController<VoicePlayerState>.broadcast();
  VoicePlayerState _state = VoicePlayerState.stopped;
  String? _path;

  AudioPlayer get _audio {
    final existing = _player;
    if (existing != null) return existing;
    // No log lines: they would name the file being played.
    AudioLogger.logLevel = AudioLogLevel.none;
    final player = AudioPlayer();
    _subs.add(
      player.onPlayerStateChanged.listen(
        (s) => _setState(switch (s) {
          PlayerState.playing => VoicePlayerState.playing,
          PlayerState.paused => VoicePlayerState.paused,
          PlayerState.completed => VoicePlayerState.completed,
          PlayerState.stopped ||
          PlayerState.disposed => VoicePlayerState.stopped,
        }),
      ),
    );
    return _player = player;
  }

  void _setState(VoicePlayerState s) {
    if (_state == s) return;
    _state = s;
    _states.add(s);
  }

  @override
  Future<void> play(String path) async {
    if (!File(path).existsSync()) throw const VoicePlayerException();
    try {
      await _audio.stop();
      _path = path;
      await _audio.play(DeviceFileSource(path));
    } on Object catch (e) {
      _path = null;
      _setState(VoicePlayerState.stopped);
      throw VoicePlayerException(e);
    }
  }

  @override
  Future<void> pause() async => _player?.pause();

  @override
  Future<void> resume() async => _player?.resume();

  @override
  Future<void> stop() async {
    await _player?.stop();
    _path = null;
    _setState(VoicePlayerState.stopped);
  }

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  @override
  String? get currentPath => _path;

  @override
  VoicePlayerState get state => _state;

  @override
  Stream<VoicePlayerState> get states => _states.stream;

  @override
  Stream<Duration> get position => _audio.onPositionChanged;

  @override
  Stream<Duration> get duration => _audio.onDurationChanged;

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    await _player?.dispose();
    _player = null;
    _path = null;
  }
}
