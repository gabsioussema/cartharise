/// Dictation (step 3): speech to text, **on the phone only**. Pure Dart
/// contract; the platform implementation (Android
/// `SpeechRecognizer.createOnDeviceSpeechRecognizer`, API 31+; iOS
/// `SFSpeechRecognizer` with `requiresOnDeviceRecognition`) lands with the
/// dictation feature. Until then the app uses [UnsupportedDictation].
///
/// Rules every implementation keeps:
/// * **On-device or nothing.** Never a network recognizer, never a silent
///   fallback to one: when the phone can't recognise a language on the
///   device, [Dictation.availability] says so and the UI offers Record or
///   typing instead.
/// * **Asked only on a tap.** [Dictation.availability] never asks for a
///   permission; [Dictation.start] (after the user tapped Dictate) may.
/// * **The user's words stay theirs.** Recognised text is shown for review
///   before it is inserted; nothing is rewritten, summarised or inserted
///   on its own, and no recognised text is logged.
/// * **Honest failures.** Every failure arrives as a [DictationError] with a
///   typed [DictationFailure], followed by [DictationEnded].
///
/// Language tags are BCP 47 (`en-US`, `fr-FR`, `ar`), usually the app's
/// locale (`Localizations.localeOf(context).toLanguageTag()`).
library;

import 'dart:async';

/// Whether dictation can run on this phone for a language.
enum DictationAvailability {
  /// An on-device recognizer for the language is ready.
  available,

  /// The phone can recognise the language on the device once its language
  /// pack is downloaded (the user does that in the system settings).
  needsModel,

  /// No on-device recognizer for this language on this phone.
  unsupported,

  /// The microphone or speech recognition was refused and can only be
  /// allowed again in the system settings.
  noPermission,

  /// The system is too old for on-device recognition (Android before 12,
  /// iOS before 13).
  tooOld,
}

/// Why a dictation stopped early.
enum DictationFailure {
  /// The user refused the microphone or speech recognition.
  noPermission,

  /// No on-device recognizer for the language.
  unsupported,

  /// The language pack isn't on the phone yet.
  needsModel,

  /// The system is too old for on-device recognition.
  tooOld,

  /// Nothing was heard, or nothing could be recognised.
  noSpeech,

  /// Another app or a call took the microphone.
  interrupted,

  /// The recognizer is busy with another request.
  busy,

  /// Anything else.
  failed,
}

/// What a running dictation reports, in order: any number of
/// [DictationPartial] and [DictationLevel] events, at most one
/// [DictationFinal], at most one [DictationError], then exactly one
/// [DictationEnded] — after which the stream closes.
sealed class DictationEvent {
  const DictationEvent();
}

/// The text recognised so far (replaces the previous partial; for display
/// only, never inserted).
final class DictationPartial extends DictationEvent {
  const DictationPartial(this.text);

  final String text;
}

/// The recognised text once the user stopped (shown for review, inserted
/// only when the user confirms).
final class DictationFinal extends DictationEvent {
  const DictationFinal(this.text);

  final String text;
}

/// Input level, 0 (silence) to 1 (loud), a few times a second — for a calm
/// level meter.
final class DictationLevel extends DictationEvent {
  const DictationLevel(this.level);

  final double level;
}

/// Dictation failed; [DictationEnded] follows. Text recognised before the
/// failure (the last [DictationPartial]) is still the user's to keep.
final class DictationError extends DictationEvent {
  const DictationError(this.reason);

  final DictationFailure reason;
}

/// The dictation is over (stopped, cancelled or failed). Always the last
/// event.
final class DictationEnded extends DictationEvent {
  const DictationEnded();
}

/// Provided to the widget tree as `Provider<Dictation>`. One dictation at a
/// time.
abstract class Dictation {
  /// Whether [languageTag] can be dictated on this phone, on the device.
  /// Never asks for a permission.
  Future<DictationAvailability> availability(String languageTag);

  /// Starts listening in [languageTag] (only after the user tapped
  /// Dictate; the system may ask for the microphone and speech permission
  /// now). Events as described on [DictationEvent]. Starting while a
  /// dictation runs reports [DictationFailure.busy].
  Stream<DictationEvent> start(String languageTag);

  /// Stops listening: the recognised text arrives as [DictationFinal], then
  /// [DictationEnded].
  Future<void> stop();

  /// Stops and discards: [DictationEnded] without a [DictationFinal].
  Future<void> cancel();

  /// Whether a dictation is running.
  bool get isListening;
}

/// Dictation where the phone (or this build) has no on-device recognizer:
/// every language is [DictationAvailability.unsupported], and [start] ends
/// at once with [DictationFailure.unsupported]. The app's dictation until
/// the platform implementation lands.
class UnsupportedDictation implements Dictation {
  const UnsupportedDictation();

  @override
  Future<DictationAvailability> availability(String languageTag) async =>
      DictationAvailability.unsupported;

  @override
  Stream<DictationEvent> start(String languageTag) => Stream.fromIterable(
    const [DictationError(DictationFailure.unsupported), DictationEnded()],
  );

  @override
  Future<void> stop() async {}

  @override
  Future<void> cancel() async {}

  @override
  bool get isListening => false;
}
