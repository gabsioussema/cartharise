// Step 3 › G "dictation" (docs/plans/evolve.md): the platform Dictation
// behind a method + event channel, and the guards that keep it on the
// phone (Android on-device recognizer only, iOS on-device only, no
// fallback, nothing logged).
import 'dart:async';
import 'dart:io';

import 'package:cartharise/services/dictation.dart';
import 'package:cartharise/services/dictation_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

const _methods = MethodChannel(kDictationMethodChannel);
const _events = EventChannel(kDictationEventChannel);

String _describe(DictationEvent e) => switch (e) {
  DictationPartial(:final text) => 'partial:$text',
  DictationFinal(:final text) => 'final:$text',
  DictationLevel(:final level) => 'level:$level',
  DictationError(:final reason) => 'error:${reason.name}',
  DictationEnded() => 'ended',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(_methods, null);
    messenger.setMockStreamHandler(_events, null);
  });

  group('decoding what the platform sends', () {
    test('events by type; anything unknown is ignored', () {
      expect(
        _describe(decodeDictationEvent({'type': 'partial', 'text': 'I am'})!),
        'partial:I am',
      );
      expect(
        _describe(decodeDictationEvent({'type': 'final', 'text': 'I am'})!),
        'final:I am',
      );
      expect(_describe(decodeDictationEvent({'type': 'ended'})!), 'ended');
      expect(
        _describe(decodeDictationEvent({'type': 'level', 'level': 0.25})!),
        'level:0.25',
      );
      // Levels are 0–1 whatever the platform sends.
      expect(
        (decodeDictationEvent({'type': 'level', 'level': 7})! as DictationLevel)
            .level,
        1,
      );
      expect(
        (decodeDictationEvent({'type': 'level', 'level': -3})!
                as DictationLevel)
            .level,
        0,
      );
      expect(
        (decodeDictationEvent({'type': 'level', 'level': double.nan})!
                as DictationLevel)
            .level,
        0,
      );
      for (final raw in <Object?>[
        null,
        'partial',
        {'type': 'partial'},
        {'type': 'partial', 'text': 3},
        {'type': 'level', 'level': 'loud'},
        {'type': 'confetti'},
      ]) {
        expect(decodeDictationEvent(raw), isNull, reason: '$raw');
      }
    });

    test('failures by name; unknown is "failed"', () {
      for (final f in DictationFailure.values) {
        expect(
          (decodeDictationEvent({'type': 'error', 'reason': f.name})!
                  as DictationError)
              .reason,
          f,
        );
      }
      expect(decodeDictationFailure('meteor'), DictationFailure.failed);
      expect(decodeDictationFailure(null), DictationFailure.failed);
    });

    test('availability by name; unknown is never "available"', () {
      for (final a in DictationAvailability.values) {
        expect(decodeDictationAvailability(a.name), a);
      }
      expect(
        decodeDictationAvailability('maybe'),
        DictationAvailability.unsupported,
      );
      expect(
        decodeDictationAvailability(null),
        DictationAvailability.unsupported,
      );
    });
  });

  group('PlatformDictation', () {
    test('availability asks the platform with the language tag, never '
        'starting anything', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(_methods, (call) async {
        calls.add(call);
        return 'needsModel';
      });
      final dictation = PlatformDictation();
      expect(
        await dictation.availability('fr'),
        DictationAvailability.needsModel,
      );
      expect(calls.single.method, 'availability');
      expect(calls.single.arguments, {'tag': 'fr'});
      expect(dictation.isListening, isFalse);
    });

    test('no platform channel (desktop, tests): unsupported, and starting '
        'ends at once instead of waiting', () async {
      final dictation = PlatformDictation();
      expect(
        await dictation.availability('en'),
        DictationAvailability.unsupported,
      );
      final events = await dictation.start('en').toList();
      expect(events.map(_describe), ['error:unsupported', 'ended']);
      expect(dictation.isListening, isFalse);
      // Starting without asking first finds out the same way.
      final fresh = await PlatformDictation().start('en').toList();
      expect(fresh.map(_describe), ['error:unsupported', 'ended']);
    });

    test('a platform error answering availability is "unsupported"', () async {
      messenger.setMockMethodCallHandler(_methods, (call) async {
        throw PlatformException(code: 'boom');
      });
      expect(
        await PlatformDictation().availability('en'),
        DictationAvailability.unsupported,
      );
    });

    test(
      'start → partials, levels, final, ended; then the stream closes',
      () async {
        Object? listenedWith;
        late MockStreamHandlerEventSink sink;
        final calls = <String>[];
        messenger.setMockMethodCallHandler(_methods, (call) async {
          calls.add(call.method);
          if (call.method == 'availability') return 'available';
          if (call.method == 'stop') {
            sink
              ..success({'type': 'final', 'text': 'I walked to the sea'})
              ..success({'type': 'ended'})
              ..endOfStream();
          }
          return null;
        });
        messenger.setMockStreamHandler(
          _events,
          MockStreamHandler.inline(
            onListen: (arguments, events) {
              listenedWith = arguments;
              sink = events;
              events
                ..success({'type': 'level', 'level': 0.5})
                ..success({'type': 'partial', 'text': 'I walked'})
                ..success({'type': 'something new'});
            },
          ),
        );
        final dictation = PlatformDictation();
        expect(
          await dictation.availability('en'),
          DictationAvailability.available,
        );
        final seen = <String>[];
        final done = Completer<void>();
        dictation
            .start('en')
            .listen((e) => seen.add(_describe(e)), onDone: done.complete);
        await pumpEventQueue();
        expect(listenedWith, {'tag': 'en'});
        expect(dictation.isListening, isTrue);
        expect(seen, ['level:0.5', 'partial:I walked']);

        // A second dictation while one runs: busy, and the first goes on.
        final busy = await dictation.start('en').toList();
        expect(busy.map(_describe), ['error:busy', 'ended']);
        expect(dictation.isListening, isTrue);

        await dictation.stop();
        await done.future;
        expect(seen, [
          'level:0.5',
          'partial:I walked',
          'final:I walked to the sea',
          'ended',
        ]);
        expect(dictation.isListening, isFalse);
        expect(calls, ['availability', 'stop']);
      },
    );

    test('cancel asks the platform; its "ended" closes the stream', () async {
      late MockStreamHandlerEventSink sink;
      messenger.setMockMethodCallHandler(_methods, (call) async {
        if (call.method == 'availability') return 'available';
        if (call.method == 'cancel') {
          sink
            ..success({'type': 'ended'})
            ..endOfStream();
        }
        return null;
      });
      messenger.setMockStreamHandler(
        _events,
        MockStreamHandler.inline(onListen: (_, events) => sink = events),
      );
      final dictation = PlatformDictation();
      await dictation.availability('ar');
      final events = dictation.start('ar').toList();
      await pumpEventQueue();
      await dictation.cancel();
      expect((await events).map(_describe), ['ended']);
      expect(dictation.isListening, isFalse);
    });

    test('a platform failure arrives as an error, then ended', () async {
      messenger.setMockMethodCallHandler(_methods, (call) async => 'available');
      messenger.setMockStreamHandler(
        _events,
        MockStreamHandler.inline(
          onListen: (_, events) => events
            ..success({'type': 'partial', 'text': 'Half a'})
            ..success({'type': 'error', 'reason': 'interrupted'})
            ..success({'type': 'ended'})
            ..endOfStream(),
        ),
      );
      final events = await PlatformDictation().start('en').toList();
      expect(events.map(_describe), [
        'partial:Half a',
        'error:interrupted',
        'ended',
      ]);
    });

    test('the channel closing without "ended", or failing, still ends it '
        'honestly', () async {
      messenger.setMockMethodCallHandler(_methods, (call) async => 'available');
      messenger.setMockStreamHandler(
        _events,
        MockStreamHandler.inline(
          onListen: (_, events) => events
            ..success({'type': 'partial', 'text': 'Hello'})
            ..endOfStream(),
        ),
      );
      final closed = await PlatformDictation().start('en').toList();
      expect(closed.map(_describe), ['partial:Hello', 'ended']);

      messenger.setMockStreamHandler(
        _events,
        MockStreamHandler.inline(
          onListen: (_, events) => events.error(code: 'boom'),
        ),
      );
      final failed = await PlatformDictation().start('en').toList();
      expect(failed.map(_describe), ['error:failed', 'ended']);
    });

    test('closing the sheet (cancelling the subscription) stops the '
        'platform too', () async {
      var cancelled = 0;
      messenger.setMockMethodCallHandler(_methods, (call) async => 'available');
      messenger.setMockStreamHandler(
        _events,
        MockStreamHandler.inline(
          onListen: (_, events) =>
              events.success({'type': 'partial', 'text': 'Hi'}),
          onCancel: (_) => cancelled++,
        ),
      );
      final dictation = PlatformDictation();
      final sub = dictation.start('en').listen((_) {});
      await pumpEventQueue();
      expect(dictation.isListening, isTrue);
      await sub.cancel();
      await pumpEventQueue();
      expect(cancelled, 1);
      expect(dictation.isListening, isFalse);
    });

    test('stop and cancel do nothing when nothing runs', () async {
      final calls = <String>[];
      messenger.setMockMethodCallHandler(_methods, (call) async {
        calls.add(call.method);
        return null;
      });
      final dictation = PlatformDictation();
      await dictation.stop();
      await dictation.cancel();
      expect(calls, isEmpty);
    });
  });

  group('on the phone only (platform code)', () {
    const kotlinDir = 'android/app/src/main/kotlin/app/cartharise/cartharise';
    final plugin = _read('$kotlinDir/DictationPlugin.kt');
    final swift = _read('ios/Runner/DictationChannel.swift');

    test('Android: only the on-device recognizer, never the default one or '
        '"prefer offline" as a substitute', () {
      expect(
        plugin,
        contains('SpeechRecognizer.createOnDeviceSpeechRecognizer'),
      );
      expect(
        plugin,
        contains('SpeechRecognizer.isOnDeviceRecognitionAvailable'),
      );
      expect(plugin, contains('checkRecognitionSupport'));
      expect(plugin, contains('Build.VERSION_CODES.S'));
      expect(plugin, contains('"tooOld"'));
      expect(plugin, isNot(contains('createSpeechRecognizer(')));
      expect(plugin, isNot(contains('EXTRA_PREFER_OFFLINE')));
      expect(plugin, isNot(contains('ACTION_WEB_SEARCH')));
      expect(plugin, isNot(contains('startActivity')));
    });

    test('Android: registered, discoverable, and the channels match', () {
      expect(
        _read('$kotlinDir/MainActivity.kt'),
        contains('flutterEngine.plugins.add(DictationPlugin())'),
      );
      expect(plugin, contains('"$kDictationMethodChannel"'));
      expect(plugin, contains('"$kDictationEventChannel"'));
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      final queries = RegExp(
        '<queries>(.*?)</queries>',
        dotAll: true,
      ).firstMatch(manifest)!.group(1)!;
      expect(
        queries,
        contains('<action android:name="android.speech.RecognitionService" />'),
      );
      expect(manifest, isNot(contains('android.permission.INTERNET')));
    });

    test('iOS: on-device recognition required, only where supported', () {
      expect(swift, contains('request.requiresOnDeviceRecognition = true'));
      expect(swift, contains('supportsOnDeviceRecognition'));
      expect(swift, contains('"$kDictationMethodChannel"'));
      expect(swift, contains('"$kDictationEventChannel"'));
      expect(
        _read('ios/Runner/AppDelegate.swift'),
        contains('DictationChannel(messenger:'),
      );
      final project = _read('ios/Runner.xcodeproj/project.pbxproj');
      expect(
        RegExp(r'DictationChannel\.swift in Sources').allMatches(project),
        hasLength(2),
        reason: 'a build file and the Runner target\'s Sources phase',
      );
      final plist = _read('ios/Runner/Info.plist');
      final speech = RegExp(
        r'<key>NSSpeechRecognitionUsageDescription</key>\s*<string>([^<]+)</string>',
      ).firstMatch(plist);
      expect(speech, isNotNull);
      expect(speech!.group(1), contains('this phone'));
      expect(speech.group(1), contains('Dictate'));
    });

    test('nothing the user says is logged, on either platform', () {
      for (final logging in ['Log.', 'println', 'printStackTrace']) {
        expect(plugin, isNot(contains(logging)), reason: logging);
      }
      for (final logging in ['print(', 'NSLog', 'os_log', 'debugPrint']) {
        expect(swift, isNot(contains(logging)), reason: logging);
      }
      final dart = _read('lib/services/dictation_platform.dart');
      for (final logging in ['print(', 'debugPrint', 'log(']) {
        expect(dart, isNot(contains(logging)), reason: logging);
      }
    });

    test('the app wires the platform dictation', () {
      expect(
        _read('lib/main.dart'),
        contains('dictation: PlatformDictation()'),
      );
    });
  });
}
