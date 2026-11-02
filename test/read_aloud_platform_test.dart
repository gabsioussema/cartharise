// Step 3 › H "read-aloud" (docs/plans/evolve.md): the platform ReadAloud
// behind a method channel — what it sends, how the platform's "done" ends
// a text (and a replaced text's late "done" doesn't), every error as a
// reason (never the platform's message), and how text is cut into pieces
// without losing a word. Plus the guards that keep it on the phone.
import 'dart:io';

import 'package:cartharise/services/read_aloud.dart';
import 'package:cartharise/services/read_aloud_platform.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel(kReadAloudChannel);

String _read(String path) => File(path).readAsStringSync();

String _bare(String s) => s.replaceAll(RegExp(r'\s'), '');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(_channel, null));

  /// The platform calling Dart ("done" with a text's id).
  Future<void> platformSays(String method, Object? arguments) async {
    await messenger.handlePlatformMessage(
      kReadAloudChannel,
      const StandardMethodCodec().encodeMethodCall(
        MethodCall(method, arguments),
      ),
      (_) {},
    );
  }

  group('speechChunks', () {
    test('blank text gives nothing to read', () {
      expect(speechChunks(''), isEmpty);
      expect(speechChunks('  \n\n \t '), isEmpty);
    });

    test('one piece per paragraph, trimmed', () {
      expect(speechChunks('  First line.\nSame paragraph.\n\n  Second.  '), [
        'First line.\nSame paragraph.',
        'Second.',
      ]);
    });

    test('a long paragraph is cut after a sentence, never mid-word', () {
      final text = List.filled(40, 'One short sentence here.').join(' ');
      final chunks = speechChunks(text, maxLength: 100);
      expect(chunks.length, greaterThan(1));
      for (final c in chunks) {
        expect(c.length, lessThanOrEqualTo(100));
        expect(c, endsWith('.'));
      }
      expect(_bare(chunks.join()), _bare(text));
    });

    test('no sentence end: cut at a space; one huge word: cut hard', () {
      final words = List.filled(30, 'word').join(' ');
      final atSpaces = speechChunks(words, maxLength: 22);
      for (final c in atSpaces) {
        expect(c.length, lessThanOrEqualTo(22));
        expect(c.split(' ').every((w) => w == 'word'), isTrue);
      }
      expect(_bare(atSpaces.join()), _bare(words));
      final huge = 'x' * 25;
      expect(speechChunks(huge, maxLength: 10), ['x' * 10, 'x' * 10, 'x' * 5]);
    });

    test('Arabic and French sentence ends count too', () {
      final text = 'سؤال أول؟ ${'كلمة ' * 6}نهاية.';
      final chunks = speechChunks(text, maxLength: 20);
      expect(chunks.first, 'سؤال أول؟');
      expect(_bare(chunks.join()), _bare(text));
    });
  });

  group('PlatformReadAloud', () {
    test('speak sends the tag, an id and the pieces; done ends it', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(_channel, (call) async {
        calls.add(call);
        return null;
      });
      final voice = PlatformReadAloud();
      final states = <bool>[];
      final sub = voice.speaking.listen(states.add);

      await voice.speak('Hello.\n\nAgain.', languageTag: 'fr');
      expect(voice.isSpeaking, isTrue);
      final call = calls.single;
      expect(call.method, 'speak');
      final args = call.arguments as Map;
      expect(args['tag'], 'fr');
      expect(args['chunks'], ['Hello.', 'Again.']);
      final id = args['id'] as int;

      await platformSays('done', id);
      expect(voice.isSpeaking, isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(states, [true, false]);
      await sub.cancel();
    });

    test('a replaced text\'s late done is ignored', () async {
      final ids = <int>[];
      messenger.setMockMethodCallHandler(_channel, (call) async {
        if (call.method == 'speak') ids.add((call.arguments as Map)['id']);
        return null;
      });
      final voice = PlatformReadAloud();
      await voice.speak('First.', languageTag: 'en');
      await voice.speak('Second.', languageTag: 'en');
      expect(ids, hasLength(2));
      await platformSays('done', ids.first);
      expect(voice.isSpeaking, isTrue);
      await platformSays('done', ids.last);
      expect(voice.isSpeaking, isFalse);
    });

    test('blank text: nothing is sent', () async {
      var sent = false;
      messenger.setMockMethodCallHandler(_channel, (call) async {
        sent = true;
        return null;
      });
      await PlatformReadAloud().speak('   ', languageTag: 'en');
      expect(sent, isFalse);
    });

    test('stop is immediate and tells the platform', () async {
      final methods = <String>[];
      messenger.setMockMethodCallHandler(_channel, (call) async {
        methods.add(call.method);
        return null;
      });
      final voice = PlatformReadAloud();
      await voice.speak('Hello.', languageTag: 'en');
      await voice.stop();
      expect(voice.isSpeaking, isFalse);
      expect(methods, ['speak', 'stop']);
      await voice.dispose();
      expect(methods.last, 'dispose');
    });

    test('errors become reasons; silent mode is recognisable; the '
        'platform\'s message is never kept', () async {
      Future<ReadAloudException> failWith(String code) async {
        messenger.setMockMethodCallHandler(_channel, (call) async {
          throw PlatformException(code: code, message: 'secret words');
        });
        final voice = PlatformReadAloud();
        try {
          await voice.speak('secret words', languageTag: 'en');
        } on ReadAloudException catch (e) {
          expect(voice.isSpeaking, isFalse);
          expect(e.toString(), isNot(contains('secret')));
          return e;
        }
        fail('speak should throw for $code');
      }

      expect((await failWith('noVoice')).reason, ReadAloudFailure.noVoice);
      expect(
        (await failWith('unavailable')).reason,
        ReadAloudFailure.unavailable,
      );
      final silent = await failWith('silent');
      expect(silent.reason, ReadAloudFailure.failed);
      expect(isSilentMode(silent), isTrue);
      final other = await failWith('engine');
      expect(other.reason, ReadAloudFailure.failed);
      expect(isSilentMode(other), isFalse);
      expect(other.cause, 'engine');
    });

    test('no platform side: unavailable, never a hang', () async {
      final voice = PlatformReadAloud(
        channel: const MethodChannel('app.cartharise/read_aloud_missing'),
      );
      expect(await voice.available('en'), isFalse);
      await expectLater(
        voice.speak('Hello.', languageTag: 'en'),
        throwsA(
          isA<ReadAloudException>().having(
            (e) => e.reason,
            'reason',
            ReadAloudFailure.unavailable,
          ),
        ),
      );
      await voice.stop();
      expect(voice.isSpeaking, isFalse);
    });

    test('available asks per language; a platform error is "no"', () async {
      messenger.setMockMethodCallHandler(_channel, (call) async {
        if (call.method != 'available') return null;
        final tag = (call.arguments as Map)['tag'];
        if (tag == 'ar') throw PlatformException(code: 'x');
        return tag == 'fr';
      });
      final voice = PlatformReadAloud();
      expect(await voice.available('fr'), isTrue);
      expect(await voice.available('en'), isFalse);
      expect(await voice.available('ar'), isFalse);
    });
  });

  group('on the phone only', () {
    test('Android: offline voices only, no permission, nothing logged', () {
      final kt = _read(
        'android/app/src/main/kotlin/app/cartharise/cartharise/'
        'ReadAloudChannel.kt',
      );
      expect(kt, contains('isNetworkConnectionRequired'));
      expect(kt, isNot(contains('Log.')));
      expect(kt, isNot(contains('println')));
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      expect(manifest, contains('android.intent.action.TTS_SERVICE'));
      expect(manifest, isNot(contains('android.permission.INTERNET')));
    });

    test('iOS: on-device voices, the silent switch respected, nothing '
        'logged', () {
      final swift = _read('ios/Runner/AppDelegate.swift');
      expect(swift, contains('AVSpeechSynthesizer'));
      expect(swift, contains('.ambient'));
      expect(swift, isNot(contains('NSLog')));
      expect(swift, isNot(contains('print(')));
    });
  });
}
