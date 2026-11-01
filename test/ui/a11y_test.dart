import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/local_date.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/journal/past_reset_screen.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/persona/persona_builder.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/reset/reset_complete_screen.dart';
import 'package:cartharise/ui/you/appearance_screen.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:cartharise/ui/you/inspiration_screen.dart';
import 'package:cartharise/ui/you/reminders_screen.dart';
import 'package:cartharise/ui/you/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// Accessibility (F-044, §11 edge case 6): every main screen meets the
/// Android (48 dp) and iOS (44 pt) tap-target guidelines, labels every
/// tappable element and keeps text contrast (dark and light); the guided
/// prompt can be used with a keyboard alone.

final _at = DateTime(2026, 11, 2, 8);

ReflectionAnswer _answer(String id, {bool skipped = false}) => ReflectionAnswer(
  promptId: id,
  body: skipped ? '' : 'My words for $id',
  skipped: skipped,
  updatedAt: _at,
);

/// A user in the middle of things: answers, quests, a Compass, a note, a
/// review and an earlier reset, so every screen shows real content.
AppData _data() => onboardedData().copyWith(
  journeys: [
    Journey(
      id: 'journey_old',
      startedAt: DateTime(2026, 9, 1, 7),
      completedAt: DateTime(2026, 9, 2, 21),
      answers: {
        'morning.01': _answer('morning.01'),
        'morning.02': _answer('morning.02', skipped: true),
      },
    ),
    Journey(
      id: 'journey_now',
      startedAt: _at,
      activePromptId: 'morning.02',
      answers: {'morning.01': _answer('morning.01')},
    ),
  ],
  currentJourneyId: () => 'journey_now',
  quests: [
    Quest(
      id: 'q1',
      title: 'Walk 20 minutes',
      createdAt: _at,
      recurrence: QuestRecurrence.daily,
      completedOn: {dateKey(kTestNow)},
    ),
    Quest(
      id: 'q2',
      title: 'Write one page',
      createdAt: _at,
      dueDate: '2026-11-03',
    ),
  ],
  compass: LifeCompass(
    vision: 'Calm mornings, honest work.',
    dailyLevers: 'Walk\nRead',
    updatedAt: _at,
  ),
  journal: [JournalEntry(id: 'note_1', body: 'A first note.', createdAt: _at)],
  reviews: [
    WeeklyReview(
      id: 'review_1',
      weekStart: '2026-10-26',
      wins: 'Calm mornings',
      friction: 'Late nights',
      nextExperiment: 'Phone away',
      createdAt: _at,
    ),
  ],
  pathAnswers: {1: PathAnswer(day: 1, body: 'Noticed a lot.', updatedAt: _at)},
);

Future<void> _expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

Future<void> _pill(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await pumpFrames(tester);
}

/// One screen of the a11y matrix: how to show it.
typedef _Screen = ({
  String name,
  AppTab? tab,
  Widget? home,
  String? pill,
  bool firstLaunch,
});

_Screen _tab(String name, AppTab tab, {String? pill}) =>
    (name: name, tab: tab, home: null, pill: pill, firstLaunch: false);

_Screen _home(String name, Widget home) =>
    (name: name, tab: null, home: home, pill: null, firstLaunch: false);

final List<_Screen> _screens = [
  _tab('Today', AppTab.today),
  _tab('Reset', AppTab.reset),
  _tab('Compass', AppTab.compass),
  _tab('Missions', AppTab.compass, pill: 'Missions'),
  _tab('Campaign', AppTab.compass, pill: 'Campaign'),
  _tab('Journal notes', AppTab.journal),
  _tab('Journal reviews', AppTab.journal, pill: 'Reviews'),
  _tab('Journal look back', AppTab.journal, pill: 'Look back'),
  _tab('You', AppTab.you),
  _home('Guided prompt', const GuidedPromptScreen(promptId: 'morning.02')),
  _home('Reset complete', const ResetCompleteScreen()),
  _home('Past reset', const PastResetScreen(journeyId: 'journey_old')),
  _home('Awakening', const AwakeningScreen()),
  _home('Lesson', const LessonScreen(lessonId: 'lesson.01')),
  _home('Path day', const PathDayScreen(day: 1)),
  _home('Month project', const ProjectScreen()),
  _home('Inspiration', const InspirationScreen()),
  _home('Reminders', const RemindersScreen()),
  _home('Appearance', const AppearanceScreen()),
  _home('Your data', const DataScreen()),
  _home('Support', const SupportScreen()),
  _home('Persona builder', const PersonaBuilderScreen()),
  (name: 'Onboarding', tab: null, home: null, pill: null, firstLaunch: true),
];

void main() {
  group('accessibility guidelines', () {
    for (final screen in _screens) {
      for (final brightness in Brightness.values) {
        testWidgets('${screen.name} (${brightness.name})', (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpCartha(
            tester,
            data: screen.firstLaunch ? null : _data(),
            home: screen.home,
            brightness: brightness,
            shell: screen.tab == null
                ? null
                : ShellController(initial: screen.tab!),
          );
          if (screen.pill != null) await _pill(tester, screen.pill!);
          await _expectAccessible(tester);
          semantics.dispose();
        });
      }
    }
  });

  group('keyboard only', () {
    FocusNode? focused() => FocusManager.instance.primaryFocus;
    FocusNode nodeOf(WidgetTester tester, String label) =>
        Focus.of(tester.element(find.text(label).last));

    testWidgets('Tab reaches every guided-prompt control in reading order', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _data(),
        size: const Size(390, 2400),
        home: const GuidedPromptScreen(promptId: 'morning.02'),
      );
      // Start in the answer field and type with the keyboard.
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'Typed with keys');
      await tester.pump(const Duration(seconds: 1));

      final order = [
        'Save & continue',
        'Back',
        'Skip for now',
        'Jump',
        'Pause',
        'Feeling heavy?',
      ];
      for (final label in order) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(
          focused(),
          same(nodeOf(tester, label)),
          reason: 'Tab should move focus to "$label"',
        );
      }

      // Enter activates the focused control: "Feeling heavy?" opens the
      // soften / pause / support choices.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await pumpFrames(tester);
      expect(find.text('This can be a lot'), findsOneWidget);
      expect(find.text('Support and safety'), findsOneWidget);
      // The words typed are saved exactly.
      expect(h.state.answer('morning.02')?.body, 'Typed with keys');
    });
  });
}
