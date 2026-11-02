/// The phone's own speech recognizer behind [Dictation], through a small
/// platform channel — **on the device only**:
///
/// * **Android** (`android/app/src/main/kotlin/…/DictationPlugin.kt`):
///   `SpeechRecognizer.createOnDeviceSpeechRecognizer` (Android 12+, API 31)
///   after `SpeechRecognizer.isOnDeviceRecognitionAvailable`; the language's
///   on-device support from `checkRecognitionSupport` (Android 13+). Never
///   the default recognizer, which may use a server. Before Android 12:
///   [DictationAvailability.tooOld].
/// * **iOS** (`ios/Runner/DictationChannel.swift`): `SFSpeechRecognizer` for
///   the language, only when `supportsOnDeviceRecognition`, with
///   `requiresOnDeviceRecognition = true`; audio from `AVAudioEngine`.
///
/// Anywhere else (tests, desktop) the channel is missing and every language
/// is [DictationAvailability.unsupported]. Nothing here logs: recognised
/// text only travels from the platform to the widget that shows it.
library;

import 'dart:async';

import 'package:flutter/services.dart';

import 'dictation.dart';

/// Method channel: `availability` ({tag}) → an availability name, `stop`,
/// `cancel`.
const kDictationMethodChannel = 'app.cartharise/dictation';

/// Event channel: listened to with {tag}; sends maps
/// `{type: partial|final|level|error|ended, text?, level?, reason?}`, then
/// ends its stream after `ended`.
const kDictationEventChannel = 'app.cartharise/dictation/events';

/// Reads an availability name the platform sent; anything unknown (or a
/// missing answer) is [DictationAvailability.unsupported] — never a silent
/// "available".
DictationAvailability decodeDictationAvailability(Object? name) {
  for (final value in DictationAvailability.values) {
    if (value.name == name) return value;
  }
  return DictationAvailability.unsupported;
}

/// Reads a failure name the platform sent; anything unknown is
/// [DictationFailure.failed].
DictationFailure decodeDictationFailure(Object? name) {
  for (final value in DictationFailure.values) {
    if (value.name == name) return value;
  }
  return DictationFailure.failed;
}

/// One platform event as a [DictationEvent], or null for anything this
/// version doesn't know (ignored, never an error).
DictationEvent? decodeDictationEvent(Object? raw) {
  if (raw is! Map) return null;
  final text = raw['text'];
  switch (raw['type']) {
    case 'partial':
      return text is String ? DictationPartial(text) : null;
    case 'final':
      return text is String ? DictationFinal(text) : null;
    case 'level':
      final level = raw['level'];
      if (level is! num) return null;
      final value = level.toDouble();
      return DictationLevel(value.isNaN ? 0 : value.clamp(0.0, 1.0));
    case 'error':
      return DictationError(decodeDictationFailure(raw['reason']));
    case 'ended':
      return const DictationEnded();
  }
  return null;
}

/// [Dictation] through the platform channels above. One dictation at a
/// time: a second [start] while one runs reports [DictationFailure.busy].
class PlatformDictation implements Dictation {
  PlatformDictation({
    this.methods = const MethodChannel(kDictationMethodChannel),
    this.events = const EventChannel(kDictationEventChannel),
  });

  /// [kDictationMethodChannel] (tests may pass their own).
  final MethodChannel methods;

  /// [kDictationEventChannel] (tests may pass their own).
  final EventChannel events;

  /// The running dictation's events (null when none runs).
  StreamController<DictationEvent>? _session;

  /// Whether this platform has the dictation channel (null = not asked
  /// yet). Without it, starting reports [DictationFailure.unsupported]
  /// instead of waiting on a channel nobody answers.
  bool? _hasPlatform;

  @override
  Future<DictationAvailability> availability(String languageTag) async {
    try {
      final name = await methods.invokeMethod<String>('availability', {
        'tag': languageTag,
      });
      _hasPlatform = true;
      return decodeDictationAvailability(name);
    } on MissingPluginException {
      _hasPlatform = false;
      return DictationAvailability.unsupported;
    } on PlatformException {
      _hasPlatform = true;
      return DictationAvailability.unsupported;
    }
  }

  @override
  Stream<DictationEvent> start(String languageTag) {
    if (_session != null) {
      return Stream.fromIterable(const [
        DictationError(DictationFailure.busy),
        DictationEnded(),
      ]);
    }
    late final StreamController<DictationEvent> session;
    StreamSubscription<Object?>? platform;
    var ended = false;

    void end([DictationFailure? failure]) {
      if (ended) return;
      ended = true;
      if (failure != null) session.add(DictationError(failure));
      session.add(const DictationEnded());
      if (identical(_session, session)) _session = null;
      unawaited(platform?.cancel());
      unawaited(session.close());
    }

    session = StreamController<DictationEvent>(
      onListen: () async {
        if (_hasPlatform == null) await availability(languageTag);
        if (ended) return;
        if (_hasPlatform == false) {
          end(DictationFailure.unsupported);
          return;
        }
        platform = events
            .receiveBroadcastStream({'tag': languageTag})
            .listen(
              (raw) {
                if (ended) return;
                final event = decodeDictationEvent(raw);
                if (event == null) return;
                if (event is DictationEnded) {
                  end();
                } else {
                  session.add(event);
                }
              },
              onError: (Object _) {
                // A channel failure ends the dictation honestly (never
                // quietly, and nothing about the user's words is logged).
                end(DictationFailure.failed);
              },
              // The platform closed without saying "ended".
              onDone: end,
            );
      },
      onCancel: () {
        // The widget stopped listening (e.g. the sheet closed): the
        // platform stops too, and nothing is inserted anywhere.
        ended = true;
        if (identical(_session, session)) _session = null;
        return platform?.cancel();
      },
    );
    _session = session;
    return session.stream;
  }

  @override
  Future<void> stop() async {
    if (_session == null) return;
    try {
      await methods.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Nothing is running on this platform.
    } on PlatformException {
      // The platform ends the dictation with an error event.
    }
  }

  @override
  Future<void> cancel() async {
    if (_session == null) return;
    try {
      await methods.invokeMethod<void>('cancel');
    } on MissingPluginException {
      // Nothing is running on this platform.
    } on PlatformException {
      // Ended below either way.
    }
  }

  @override
  bool get isListening => _session != null;
}
