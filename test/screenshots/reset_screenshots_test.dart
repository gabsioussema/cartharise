// Renders the Reset and Awakening screens to PNGs for design review against
// "Cartharise Brand and App System Board.png" (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/reset/reset_complete_screen.dart';
import 'package:cartharise/ui/reset/reset_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

ReflectionAnswer _a(String id, String body, {bool skipped = false}) =>
    ReflectionAnswer(
      promptId: id,
      body: body,
      skipped: skipped,
      updatedAt: DateTime(2026, 11, 3, 8),
    );

/// A user part-way through the morning, with one check-in done.
AppData _midReset() {
  final base = onboardedData();
  final journey = Journey(
    id: 'journey_now',
    startedAt: DateTime(2026, 11, 3, 7, 45),
    activePromptId: 'morning.05',
    answers: {
      'morning.01': _a(
        'morning.01',
        'Most evenings I scroll until late, even when I am tired.',
      ),
      'morning.02': _a('morning.02', 'Not enough time to cook properly.'),
      'morning.03': _a('morning.03', '', skipped: true),
      'morning.04': _a('morning.04', 'I keep waiting for a calmer month.'),
      'daytime.01': _a('daytime.01', 'Sorting email instead of the report.'),
    },
  );
  return base.copyWith(
    profile: () => base.profile!.copyWith(pace: Pace.oneDay),
    journeys: [journey],
    currentJourneyId: () => journey.id,
    lessonsRead: {'lesson.01', 'lesson.02'},
  );
}

AppData _finished() {
  final base = onboardedData();
  final journey = Journey(
    id: 'journey_now',
    startedAt: DateTime(2026, 11, 3, 7, 45),
    answers: {
      for (final p in englishContent.corePrompts)
        p.id: _a(p.id, 'My words for ${p.title}.'),
      'evening.04': _a(
        'evening.04',
        'I want slower mornings, honest work I am proud of, and time '
            'outdoors with the people I love.',
      ),
      'bonus.02': _a('bonus.02', 'Safety is the couch; aliveness is the hill.'),
    },
  );
  return base.copyWith(journeys: [journey], currentJourneyId: () => journey.id);
}

void main() {
  for (final b in Brightness.values) {
    testWidgets('reset hub ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        content: englishContent,
        data: _midReset(),
        home: const ResetTab(),
        size: const Size(390, 2600),
      );
      await captureScreenshot(tester, '20_reset_hub_${b.name}');
    });

    testWidgets('guided prompt ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        content: englishContent,
        data: _midReset(),
        home: const ResetTab(),
        size: const Size(390, 1400),
      );
      AppNav.openPrompt(tester.element(find.byType(ResetTab)), 'morning.05');
      await pumpFrames(tester, count: 8);
      await tester.tap(find.text('Example — not a right answer'));
      await pumpFrames(tester, count: 4);
      await tester.enterText(
        find.byType(TextField),
        'Still scrolling at midnight, still saying "next month".',
      );
      await pumpFrames(tester, count: 8);
      FocusManager.instance.primaryFocus?.unfocus();
      await pumpFrames(tester, count: 2);
      await captureScreenshot(tester, '21_reset_prompt_${b.name}');
    });

    testWidgets('daytime check-in ${b.name}', (tester) async {
      tester.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      addTearDown(tester.platformDispatcher.clearAlwaysUse24HourTestValue);
      await pumpCartha(
        tester,
        brightness: b,
        content: englishContent,
        data: _midReset(),
        home: const ResetTab(),
      );
      AppNav.openPrompt(tester.element(find.byType(ResetTab)), 'daytime.02');
      await pumpFrames(tester, count: 8);
      await captureScreenshot(tester, '22_reset_checkin_${b.name}');
    });

    testWidgets('jump sheet ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        content: englishContent,
        data: _midReset(),
        home: const ResetTab(),
      );
      AppNav.openPrompt(tester.element(find.byType(ResetTab)), 'morning.05');
      await pumpFrames(tester, count: 8);
      await tester.tap(find.byTooltip('Jump to a question'));
      await pumpFrames(tester, count: 8);
      await captureScreenshot(tester, '23_reset_jump_${b.name}');
    });

    testWidgets('reset complete ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        content: englishContent,
        data: _finished(),
        home: const ResetCompleteScreen(),
        size: const Size(390, 1100),
      );
      await captureScreenshot(tester, '24_reset_complete_${b.name}');
    });

    testWidgets('awakening ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        content: englishContent,
        data: _midReset(),
        home: const AwakeningScreen(),
        size: const Size(390, 1500),
      );
      await captureScreenshot(tester, '25_awakening_${b.name}');
    });

    testWidgets('lesson ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        content: englishContent,
        data: _midReset(),
        home: const LessonScreen(lessonId: 'lesson.02'),
        size: const Size(390, 2400),
      );
      final check = englishContent.lesson('lesson.02')!.check!;
      await tester.tap(find.text(check.options[check.correctIndex]));
      await pumpFrames(tester, count: 4);
      await captureScreenshot(tester, '26_lesson_${b.name}');
    });
  }
}
