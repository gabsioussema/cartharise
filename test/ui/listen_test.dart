// Step 3 › H "read-aloud" (docs/plans/evolve.md): **Listen** on a lesson and
// a reset question, and — only on an explicit tap — **Listen to my answer**
// / **Listen to my note**. One at a time; Stop reading anytime; it stops when
// the page goes away, is covered, or the app is hidden, and keeps reading
// while scrolled. Hidden where the phone has no voice; failures are one
// honest line. Dictate stops it. Sizes, themes, right to left, a11y.
import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/content/fr.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/services/read_aloud.dart';
import 'package:cartharise/services/read_aloud_platform.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/voice/listen_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

/// The link inside a [ListenButton] (the widget may span its line).
Finder _link(String key) =>
    find.descendant(of: _key(key), matching: find.byType(TextButton));

final _t = DateTime(2026, 11, 2, 20, 15);

AppData _withAnswer(String body) => onboardedData().copyWith(
  journeys: [
    Journey(
      id: 'j1',
      startedAt: _t,
      activePromptId: 'morning.02',
      answers: {
        'morning.02': ReflectionAnswer(
          promptId: 'morning.02',
          body: body,
          updatedAt: _t,
        ),
      },
    ),
  ],
  currentJourneyId: () => 'j1',
);

AppData _withNote({String? title, String body = ''}) =>
    onboardedData().copyWith(
      journal: [
        JournalEntry(id: 'note_1', title: title, body: body, createdAt: _t),
      ],
    );

/// Taps [f], scrolling the page first when it is below the fold (lazily
/// built).
Future<void> _tap(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump();
  await tester.pump();
}

/// A reader that is on silent (Android: nothing plays on the speaker).
class _SilentReadAloud extends FakeReadAloud {
  @override
  Future<void> speak(String text, {required String languageTag}) async =>
      throw const ReadAloudException(ReadAloudFailure.failed, kSilentMode);
}

void main() {
  group('a lesson', () {
    testWidgets('Listen reads the lesson in the app language; Stop reading '
        'ends it at once', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const LessonScreen(lessonId: 'lesson.02'),
      );
      // Nothing is read on its own.
      expect(h.readAloud.spoken, isEmpty);
      expect(find.text('Listen'), findsOneWidget);

      await _tap(tester, _link('lesson-listen'));
      expect(h.readAloud.spoken, hasLength(1));
      final spoken = h.readAloud.spoken.single;
      expect(spoken.languageTag, 'en');
      expect(
        spoken.text,
        'Lesson 2 title\n\nSummary of lesson 2.\n\nExplanation of lesson 2.'
        '\n\nA second paragraph.\n\nExample for lesson 2.\n\n'
        'Nuance for lesson 2.',
      );
      expect(find.text('Stop reading'), findsOneWidget);
      expect(
        find.text("Can't hear it? Check the volume and silent mode."),
        findsOneWidget,
      );

      await _tap(tester, _link('lesson-listen'));
      expect(h.readAloud.stopCount, 1);
      expect(h.readAloud.isSpeaking, isFalse);
      expect(find.text('Listen'), findsOneWidget);
      expect(find.text('Stop reading'), findsNothing);
    });

    testWidgets('when the voice finishes, it is Listen again', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      await _tap(tester, _link('lesson-listen'));
      expect(find.text('Stop reading'), findsOneWidget);
      h.readAloud.finish();
      await tester.pump();
      expect(find.text('Stop reading'), findsNothing);
      expect(find.text('Listen'), findsOneWidget);
    });

    testWidgets('leaving the lesson stops the voice', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const LessonScreen(lessonId: 'lesson.01'),
        ),
      );
      await pumpFrames(tester);
      await _tap(tester, _link('lesson-listen'));
      expect(h.readAloud.isSpeaking, isTrue);
      navigator.pop();
      await pumpFrames(tester);
      expect(find.byType(LessonScreen), findsNothing);
      expect(h.readAloud.isSpeaking, isFalse);
      expect(h.readAloud.stopCount, 1);
    });

    testWidgets('a page pushed on top stops it (TickerMode)', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      await _tap(tester, _link('lesson-listen'));
      expect(h.readAloud.isSpeaking, isTrue);
      Navigator.of(tester.element(find.byType(LessonScreen)))
          .push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
      await pumpFrames(tester, count: 10);
      expect(h.readAloud.isSpeaking, isFalse);
    });

    testWidgets('the app going to the background stops it', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      await _tap(tester, _link('lesson-listen'));
      expect(h.readAloud.isSpeaking, isTrue);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      expect(h.readAloud.isSpeaking, isFalse);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
    });

    testWidgets('scrolling away keeps it reading (kept alive)', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        size: const Size(320, 568),
        textScale: 2,
        // The real lesson: long enough to scroll the button far away.
        content: englishContent,
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      await _tap(tester, _link('lesson-listen'));
      expect(h.readAloud.isSpeaking, isTrue);
      await expectNoOverflow(tester); // scrolls to the very end
      expect(h.readAloud.stopCount, 0);
      expect(h.readAloud.isSpeaking, isTrue);
    });

    testWidgets('no voice on this phone: no Listen at all', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        readAloud: FakeReadAloud(availableTags: {}),
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      expect(find.text('Listen'), findsNothing);
      expect(_link('lesson-listen'), findsNothing);
      expect(h.readAloud.spoken, isEmpty);
    });

    testWidgets('a failure is one honest line, and Listen stays', (
      tester,
    ) async {
      final voice = FakeReadAloud()..failSpeak = ReadAloudFailure.noVoice;
      await pumpCartha(
        tester,
        data: onboardedData(),
        readAloud: voice,
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      await _tap(tester, _link('lesson-listen'));
      expect(
        find.text(
          'No voice for this language on this phone. You can add one in '
          'its speech settings.',
        ),
        findsOneWidget,
      );
      expect(find.text('Listen'), findsOneWidget);
      expect(find.text('Stop reading'), findsNothing);

      voice.failSpeak = ReadAloudFailure.unavailable;
      await _tap(tester, _link('lesson-listen'));
      expect(
        find.text("Listen isn't available on this phone."),
        findsOneWidget,
      );

      voice.failSpeak = ReadAloudFailure.failed;
      await _tap(tester, _link('lesson-listen'));
      expect(find.text("Couldn't read this aloud. Try again."), findsOneWidget);

      // Tried again and it works: the line goes.
      voice.failSpeak = null;
      await _tap(tester, _link('lesson-listen'));
      expect(find.text("Couldn't read this aloud. Try again."), findsNothing);
      expect(find.text('Stop reading'), findsOneWidget);
    });

    testWidgets('on silent: says how to hear it', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        readAloud: _SilentReadAloud(),
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      await _tap(tester, _link('lesson-listen'));
      expect(
        find.text(
          'Your phone is on silent. Turn the sound on, or use headphones.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('screen readers: a named button that says its state', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      expect(find.bySemanticsLabel('Listen'), findsOneWidget);
      await _tap(tester, _link('lesson-listen'));
      expect(find.bySemanticsLabel('Stop reading'), findsOneWidget);
      semantics.dispose();
    });
  });

  group('a reset question', () {
    testWidgets('Listen reads the question; Listen to my answer reads the '
        'answer exactly, only on its tap; one at a time', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _withAnswer('  My  own words, as typed.  '),
        home: const GuidedPromptScreen(promptId: 'morning.02'),
      );
      expect(h.readAloud.spoken, isEmpty);
      final question = _link('reset-question-listen-morning.02');
      final answer = _link('reset-answer-listen');
      expect(find.text('Listen to my answer'), findsOneWidget);

      await _tap(tester, question);
      expect(
        h.readAloud.spoken.last.text,
        'Context for morning 2.\n\nQuestion morning 2?',
      );
      expect(h.readAloud.spoken.last.languageTag, 'en');
      expect(
        find.descendant(of: question, matching: find.text('Stop reading')),
        findsOneWidget,
      );

      // The answer takes over; the question's button is Listen again.
      await _tap(tester, answer);
      expect(h.readAloud.spoken.last.text, 'My  own words, as typed.');
      expect(
        find.descendant(of: question, matching: find.text('Listen')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: answer, matching: find.text('Stop reading')),
        findsOneWidget,
      );
      // Listening never changes what was saved.
      expect(
        h.state.answer('morning.02')?.body,
        '  My  own words, as typed.  ',
      );
    });

    testWidgets('no answer yet: no Listen to my answer until there are '
        'words', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const GuidedPromptScreen(promptId: 'morning.02'),
      );
      expect(find.text('Listen to my answer'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Now some words');
      await tester.pump();
      expect(find.text('Listen to my answer'), findsOneWidget);
    });

    testWidgets('Dictate stops Listen (the microphone shouldn\'t hear it)', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const GuidedPromptScreen(promptId: 'morning.02'),
      );
      await _tap(tester, _link('reset-question-listen-morning.02'));
      expect(h.readAloud.isSpeaking, isTrue);
      await _tap(
        tester,
        find.descendant(
          of: _key('reset-answer-dictate'),
          matching: find.byType(TextButton),
        ),
      );
      await pumpFrames(tester);
      expect(h.readAloud.isSpeaking, isFalse);
      expect(h.dictation.started, isNotEmpty);
    });
  });

  group('a note', () {
    testWidgets('Listen to my note reads the title and the note, only on '
        'its tap', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _withNote(title: 'Tuesday', body: 'A quiet walk.\n\nThen tea.'),
        home: const JournalEntryScreen(entryId: 'note_1'),
      );
      expect(h.readAloud.spoken, isEmpty);
      await _tap(tester, _link('journal-entry-listen'));
      expect(
        h.readAloud.spoken.single.text,
        'Tuesday\n\nA quiet walk.\n\nThen tea.',
      );
      expect(h.state.data.journal.single.body, 'A quiet walk.\n\nThen tea.');
    });

    testWidgets('an empty note has no Listen', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const JournalEntryScreen(),
      );
      expect(find.text('Listen to my note'), findsNothing);
      await tester.enterText(_key('journal-entry-body'), 'Hello');
      await tester.pump();
      expect(find.text('Listen to my note'), findsOneWidget);
    });
  });

  group('language', () {
    testWidgets('French app: a translated lesson is read in French, an item '
        'still in English with an English voice', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(
          settings: const AppSettings(language: AppLanguage.fr),
        ),
        content: frenchContent,
        contentFor: contentFor,
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      await _tap(tester, _link('lesson-listen'));
      expect(h.readAloud.spoken.single.languageTag, 'fr');
      expect(
        h.readAloud.spoken.single.text,
        startsWith(frenchContent.lesson('lesson.01')!.title),
      );
      final context = tester.element(find.byType(LessonScreen));
      expect(contentListenTag(context, ContentKind.lesson, 'lesson.01'), 'fr');
      expect(
        contentListenTag(context, ContentKind.lesson, 'lesson.not-translated'),
        'en',
      );
    });
  });

  group('sizes, themes, right to left, a11y', () {
    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        for (final language in [AppLanguage.en, AppLanguage.ar]) {
          testWidgets('lesson while reading fits $size '
              '(${brightness.name}, ${language.name})', (tester) async {
            await pumpCartha(
              tester,
              data: onboardedData(settings: AppSettings(language: language)),
              size: size.size,
              textScale: size.textScale,
              brightness: brightness,
              contentFor: contentFor,
              home: const LessonScreen(lessonId: 'lesson.01'),
            );
            await _tap(tester, _link('lesson-listen'));
            if (language == AppLanguage.ar) {
              expect(
                Directionality.of(tester.element(find.byType(ListenButton))),
                TextDirection.rtl,
              );
              expect(find.text('إيقاف القراءة'), findsOneWidget);
            }
            await expectNoOverflow(tester);
          });
        }
      }
    }

    for (final brightness in Brightness.values) {
      testWidgets('tap targets, labels and contrast (${brightness.name})', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: _withAnswer('Some words'),
          brightness: brightness,
          home: const GuidedPromptScreen(promptId: 'morning.02'),
        );
        await _tap(tester, _link('reset-answer-listen'));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }

    testWidgets('right to left: the link starts at the right', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(
          settings: const AppSettings(language: AppLanguage.ar),
        ),
        contentFor: contentFor,
        home: const LessonScreen(lessonId: 'lesson.01'),
      );
      final link = tester.getRect(_link('lesson-listen'));
      final page = tester.getRect(find.byType(LessonScreen));
      expect(page.right - link.right, lessThan(page.width / 4));
      expect(link.left, greaterThan(page.width / 2));
    });
  });
}
