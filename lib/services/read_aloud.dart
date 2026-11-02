/// Read aloud (step 3): **Listen** to a lesson, a prompt or — after an
/// explicit tap — the user's own note, through the phone's own
/// text-to-speech. Pure Dart contract. The app uses `PlatformReadAloud`
/// (`read_aloud_platform.dart`: Android `TextToSpeech`, iOS
/// `AVSpeechSynthesizer`). [UnavailableReadAloud] is only the fallback
/// where there is no platform voice (tests, previews, desktop).
///
/// Rules every implementation keeps:
/// * **Only on a tap.** Nothing is spoken on its own; personal text only
///   after the user tapped Listen on it.
/// * **On the phone.** The system's offline voices only — never a cloud
///   voice service; text is never sent anywhere and never logged.
/// * **Stop anytime.** [ReadAloud.stop] ends speech at once; leaving the
///   screen stops it too. Silent mode is respected by the platform side.
///
/// Language tags are BCP 47 (`en-US`, `fr-FR`, `ar`).
library;

import 'dart:async';

/// Why speaking failed.
enum ReadAloudFailure {
  /// No text-to-speech on this phone (or in this build).
  unavailable,

  /// No voice for the language.
  noVoice,

  /// Anything else.
  failed,
}

class ReadAloudException implements Exception {
  const ReadAloudException(this.reason, [this.cause]);

  final ReadAloudFailure reason;
  final Object? cause;

  /// Names the reason only — never the text.
  @override
  String toString() => 'ReadAloudException: ${reason.name}';
}

/// Provided to the widget tree as `Provider<ReadAloud>`. One text at a
/// time: speaking another stops the current one.
abstract class ReadAloud {
  /// Whether [languageTag] can be read aloud on this phone.
  Future<bool> available(String languageTag);

  /// Starts reading [text] in [languageTag] (completes once speaking has
  /// started; [speaking] reports when it ends). Throws
  /// [ReadAloudException].
  Future<void> speak(String text, {required String languageTag});

  /// Stops speaking at once (nothing happens when silent).
  Future<void> stop();

  /// True while speaking, false once finished or stopped.
  Stream<bool> get speaking;

  bool get isSpeaking;

  /// Stops and releases the engine.
  Future<void> dispose();
}

/// Read aloud where the phone (or this build) has no text-to-speech: no
/// language is available and [speak] throws
/// [ReadAloudFailure.unavailable]. The app's read-aloud until the
/// platform implementation lands.
class UnavailableReadAloud implements ReadAloud {
  const UnavailableReadAloud();

  @override
  Future<bool> available(String languageTag) async => false;

  @override
  Future<void> speak(String text, {required String languageTag}) async =>
      throw const ReadAloudException(ReadAloudFailure.unavailable);

  @override
  Future<void> stop() async {}

  @override
  Stream<bool> get speaking => const Stream.empty();

  @override
  bool get isSpeaking => false;

  @override
  Future<void> dispose() async {}
}
