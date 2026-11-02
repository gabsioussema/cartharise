// Renders Listen (step 3 › H) to PNGs for design review against
// "Cartharise Brand and App System Board.png" (not CI): Listen on a lesson,
// reading (Stop reading + the hint), Listen and Listen to my answer on a
// question, an honest failure line, and French / Arabic right to left.
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/services/read_aloud.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _t = DateTime(2026, 11, 2, 20, 15);

AppData _data({AppLanguage language = AppLanguage.en}) =>
    onboardedData(settings: AppSettings(language: language)).copyWith(
      journeys: [
        Journey(
          id: 'j1',
          startedAt: _t,
          activePromptId: 'morning.01',
          answers: {
            'morning.01': ReflectionAnswer(
              promptId: 'morning.01',
              body: 'Most evenings end on the sofa with my phone.',
              updatedAt: _t,
            ),
          },
        ),
      ],
      currentJourneyId: () => 'j1',
    );

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _link(String key) =>
    find.descendant(of: _key(key), matching: find.byType(TextButton));

/// Scrolls [f] into view only when it isn't on screen already (so the
/// page keeps its top in the picture).
Future<void> _show(WidgetTester tester, Finder f) async {
  if (f.hitTestable().evaluate().isNotEmpty) return;
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
  await pumpFrames(tester);
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await _show(tester, f);
  await tester.tap(f);
  await pumpFrames(tester);
}

void main() {
  for (final b in Brightness.values) {
    final suffix = b.name;

    Future<CarthaHarness> pump(
      WidgetTester tester, {
      AppLanguage language = AppLanguage.en,
      FakeReadAloud? readAloud,
      required Widget home,
    }) => pumpCartha(
      tester,
      brightness: b,
      data: _data(language: language),
      content: englishContent,
      contentFor: contentFor,
      readAloud: readAloud,
      home: home,
    );

    testWidgets('listen lesson $suffix', (tester) async {
      await pump(tester, home: const LessonScreen(lessonId: 'lesson.03'));
      await captureScreenshot(tester, 'listen_01_lesson_$suffix');
      await _tap(tester, _link('lesson-listen'));
      await captureScreenshot(tester, 'listen_02_reading_$suffix');
    });

    testWidgets('listen question $suffix', (tester) async {
      await pump(
        tester,
        home: const GuidedPromptScreen(promptId: 'morning.01'),
      );
      await _show(tester, _link('reset-answer-listen'));
      await captureScreenshot(tester, 'listen_03_question_$suffix');
    });

    testWidgets('listen failure $suffix', (tester) async {
      await pump(
        tester,
        readAloud: FakeReadAloud()..failSpeak = ReadAloudFailure.noVoice,
        home: const LessonScreen(lessonId: 'lesson.03'),
      );
      await _tap(tester, _link('lesson-listen'));
      await captureScreenshot(tester, 'listen_04_no_voice_$suffix');
    });

    testWidgets('listen french $suffix', (tester) async {
      await pump(
        tester,
        language: AppLanguage.fr,
        home: const LessonScreen(lessonId: 'lesson.03'),
      );
      await _tap(tester, _link('lesson-listen'));
      await captureScreenshot(tester, 'listen_05_fr_reading_$suffix');
    });

    testWidgets('listen arabic $suffix', (tester) async {
      await pump(
        tester,
        language: AppLanguage.ar,
        home: const GuidedPromptScreen(promptId: 'morning.01'),
      );
      await _tap(tester, _link('reset-question-listen-morning.01'));
      await captureScreenshot(tester, 'listen_06_ar_question_$suffix');
    });
  }
}
