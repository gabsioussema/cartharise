/// Listen on the phone (step 3, plan H): [PlatformReadAloud] reads text
/// with the platform's own text-to-speech through a small method channel —
/// Android `TextToSpeech` (`ReadAloudChannel.kt`), iOS
/// `AVSpeechSynthesizer` (`AppDelegate.swift`). No package, no network.
///
/// * **On the phone only.** Android picks a voice that needs no network
///   connection and is installed (never a cloud voice); iOS voices are
///   on-device. A language without such a voice is "no voice", honestly.
/// * **Silent mode is respected.** Android: on silent with the sound coming
///   from the phone's speaker, nothing plays and [speak] says so
///   ([ReadAloudFailure.failed] with the cause [kSilentMode]); headphones
///   still work. iOS: the speech uses the ambient audio category on the
///   speaker, so the Ring/Silent switch mutes it.
/// * **Stop anytime.** [stop] is immediate; a phone call or another app
///   taking the sound stops it too (audio focus / session interruption).
/// * **Nothing is logged.** The text crosses the channel only to be spoken;
///   errors name a reason, never the text.
library;

import 'dart:async';

import 'package:flutter/services.dart';

import 'read_aloud.dart';

/// The channel both platforms implement.
const String kReadAloudChannel = 'app.cartharise/read_aloud';

/// Longest piece handed to the engine at once (Android accepts up to
/// `TextToSpeech.getMaxSpeechInputLength()`, 4000; smaller pieces also give
/// natural pauses and a quick stop).
const int kSpeechChunkLength = 1000;

/// Why [ReadAloud.speak] didn't play although a voice exists: the phone is
/// on silent and the sound would come from its speaker. Carried as the
/// [ReadAloudException.cause] of a [ReadAloudFailure.failed] (the contract
/// has no reason of its own for it), so the UI can say what to do.
class SilentMode {
  const SilentMode();

  @override
  String toString() => 'SilentMode';
}

/// The one [SilentMode] cause.
const kSilentMode = SilentMode();

/// Whether [error] means the phone is on silent (see [SilentMode]).
bool isSilentMode(ReadAloudException error) => error.cause is SilentMode;

/// [text] cut into the pieces the engine reads one after another: one per
/// paragraph (a blank line), and a paragraph longer than [maxLength] split
/// after a sentence, else at a space, else (a very long word) hard. Only
/// whitespace at the cuts is dropped — never a word — and empty pieces are
/// skipped, so `''` or blanks give no pieces at all.
List<String> speechChunks(String text, {int maxLength = kSpeechChunkLength}) {
  assert(maxLength > 0);
  final chunks = <String>[];
  for (final paragraph in text.split(RegExp(r'\n\s*\n'))) {
    var rest = paragraph.trim();
    while (rest.length > maxLength) {
      final window = rest.substring(0, maxLength + 1);
      var cut = -1;
      for (final m in RegExp(r'[.!?…؟。]["»”’)]*\s').allMatches(window)) {
        cut = m.end;
      }
      if (cut <= 0) cut = window.lastIndexOf(RegExp(r'\s')) + 1;
      if (cut <= 0) cut = maxLength;
      final piece = rest.substring(0, cut).trim();
      if (piece.isNotEmpty) chunks.add(piece);
      rest = rest.substring(cut).trimLeft();
    }
    if (rest.isNotEmpty) chunks.add(rest);
  }
  return chunks;
}

/// [ReadAloud] through the platform's text-to-speech (see the library
/// comment). One text at a time: [speak] replaces what is being read.
class PlatformReadAloud implements ReadAloud {
  PlatformReadAloud({this.channel = const MethodChannel(kReadAloudChannel)}) {
    channel.setMethodCallHandler(_onCall);
  }

  /// The platform side ([kReadAloudChannel]; tests may pass their own).
  final MethodChannel channel;
  final _states = StreamController<bool>.broadcast();
  int _next = 0;

  /// The text being read (its id), or null.
  int? _current;
  bool _speaking = false;

  void _set(bool speaking) {
    if (_speaking == speaking) return;
    _speaking = speaking;
    _states.add(speaking);
  }

  /// The platform says a text ended (finished, stopped or failed). Ends of
  /// texts that were already replaced are ignored.
  Future<Object?> _onCall(MethodCall call) async {
    if (call.method == 'done' && call.arguments == _current) {
      _current = null;
      _set(false);
    }
    return null;
  }

  @override
  Future<bool> available(String languageTag) async {
    try {
      return await channel.invokeMethod<bool>('available', {
            'tag': languageTag,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> speak(String text, {required String languageTag}) async {
    final chunks = speechChunks(text);
    if (chunks.isEmpty) return;
    final id = ++_next;
    _current = id;
    try {
      await channel.invokeMethod<void>('speak', {
        'tag': languageTag,
        'id': id,
        'chunks': chunks,
      });
    } on PlatformException catch (e) {
      if (_current == id) {
        _current = null;
        _set(false);
      }
      throw switch (e.code) {
        'noVoice' => const ReadAloudException(ReadAloudFailure.noVoice),
        'unavailable' => const ReadAloudException(
          ReadAloudFailure.unavailable,
        ),
        'silent' => const ReadAloudException(
          ReadAloudFailure.failed,
          kSilentMode,
        ),
        // The code only (never the platform message: it could quote text).
        _ => ReadAloudException(ReadAloudFailure.failed, e.code),
      };
    } on MissingPluginException {
      if (_current == id) _current = null;
      throw const ReadAloudException(ReadAloudFailure.unavailable);
    }
    // Stopped (or replaced) while the platform was starting it: not ours.
    if (_current == id) _set(true);
  }

  @override
  Future<void> stop() async {
    _current = null;
    _set(false);
    try {
      await channel.invokeMethod<void>('stop');
    } on PlatformException {
      // Nothing more to do: the UI already shows it stopped.
    } on MissingPluginException {
      // No engine: nothing is speaking.
    }
  }

  @override
  Stream<bool> get speaking => _states.stream;

  @override
  bool get isSpeaking => _speaking;

  @override
  Future<void> dispose() async {
    _current = null;
    _set(false);
    try {
      await channel.invokeMethod<void>('dispose');
    } on PlatformException {
      // Released anyway on the platform side when the engine goes.
    } on MissingPluginException {
      // Nothing to release.
    }
  }
}
