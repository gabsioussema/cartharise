import 'dart:convert';
import 'dart:io';

import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/domain/local_date.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/today/next_step.dart';
import 'package:cartharise/ui/today/today_model.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/widgets/progress.dart';
import 'package:cartharise/ui/widgets/scenes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

// ── Test data (also used by the screenshot test) ────────────────────────────

final _at = DateTime(2026, 11, 2, 8);

ReflectionAnswer _answer(String id, {String? body, bool skipped = false}) =>
    ReflectionAnswer(
      promptId: id,
      body: body ?? (skipped ? '' : 'My words for $id'),
      skipped: skipped,
      updatedAt: _at,
    );

String _two(int i) => i.toString().padLeft(2, '0');

const _walk = 'Walk 20 minutes';
const _page = 'Write one page';
const _phone = 'Phone off by 22:00';
const _vision = 'Calm mornings, honest work, time outside.';
const _month = 'Write and publish four short essays.';

/// Three morning answers, resume point morning.04, three quests (one daily
/// quest already done today), a vision and month project, path day 3.
AppData inProgressData({String? name = 'Sam'}) => onboardedData(name: name)
    .copyWith(
      journeys: [
        Journey(
          id: 'journey_1',
          startedAt: _at,
          activePromptId: 'morning.04',
          answers: {
            for (var i = 1; i <= 3; i++)
              'morning.${_two(i)}': _answer('morning.${_two(i)}'),
          },
        ),
      ],
      currentJourneyId: () => 'journey_1',
      lessonsRead: {'lesson.01'},
      quests: [
        Quest(
          id: 'q1',
          title: _walk,
          createdAt: _at,
          recurrence: QuestRecurrence.daily,
          completedOn: {dateKey(kTestNow)},
          source: QuestSource.dailyLever,
        ),
        Quest(id: 'q2', title: _page, createdAt: _at),
        Quest(
          id: 'q3',
          title: _phone,
          createdAt: _at,
          recurrence: QuestRecurrence.daily,
        ),
      ],
      compass: LifeCompass(
        vision: _vision,
        monthProject: _month,
        updatedAt: _at,
      ),
      pathAnswers: {
        3: PathAnswer(
          day: 3,
          body: 'Noticed I reach for my phone first thing.',
          updatedAt: _at,
        ),
      },
    );

/// A completed reset (every core prompt answered), a full Compass, quests
/// and twelve days of the thirty-day path.
AppData settledData() {
  final ids = [
    for (var i = 1; i <= 14; i++) 'morning.${_two(i)}',
    for (var i = 1; i <= 6; i++) 'daytime.${_two(i)}',
    for (var i = 1; i <= 7; i++) 'evening.${_two(i)}',
  ];
  return inProgressData().copyWith(
    journeys: [
      Journey(
        id: 'journey_1',
        startedAt: _at,
        completedAt: _at.add(const Duration(hours: 14)),
        answers: {for (final id in ids) id: _answer(id)},
      ),
    ],
    compass: LifeCompass(
      antiVision: 'Another year of drifting and saying "later".',
      vision: _vision,
      yearGoal: 'Ship one small project people use.',
      monthProject: _month,
      dailyLevers: '- $_walk\n- $_page\n- $_phone',
      updatedAt: _at,
    ),
    pathAnswers: {
      for (var d = 1; d <= 12; d++)
        d: PathAnswer(
          day: d,
          body: 'Day $d note',
          updatedAt: _at.add(Duration(days: d)),
        ),
    },
  );
}

// ── Helpers ─────────────────────────────────────────────────────────────────

NextStepFacts _facts({
  int lessonsRead = 0,
  bool resetStarted = false,
  bool resetCompleted = false,
  Prompt? nextPrompt,
  Prompt? firstPrompt,
  bool eveningFinished = false,
  bool compassEmpty = true,
  bool compassHasLevers = false,
  bool canImportCompass = false,
  int questCount = 0,
  bool reviewedThisWeek = false,
  int weekday = DateTime.tuesday,
}) => NextStepFacts(
  lessonsRead: lessonsRead,
  resetStarted: resetStarted,
  resetCompleted: resetCompleted,
  nextPrompt: nextPrompt,
  firstPrompt: firstPrompt ?? fakeContent.prompt('morning.01'),
  eveningFinished: eveningFinished,
  compassEmpty: compassEmpty,
  compassHasLevers: compassHasLevers,
  canImportCompass: canImportCompass,
  questCount: questCount,
  reviewedThisWeek: reviewedThisWeek,
  weekday: weekday,
);

Prompt _p(String id) => fakeContent.prompt(id)!;

Finder _inNextStep(Finder f) => find.descendant(
  of: find.byKey(const ValueKey('today-next-step')),
  matching: f,
);

/// Every visible string on screen (Text and rich text).
List<String> _texts(WidgetTester tester) => [
  for (final w in tester.widgetList<Text>(find.byType(Text)))
    w.data ?? w.textSpan?.toPlainText() ?? '',
];

final _judgement = RegExp(
  r'streak|score|fail|missed|behind|overdue|lazy|you fixed your life|should have',
  caseSensitive: false,
);

/// The real app on the Today tab. Tall by default so every card is built
/// (the size-matrix tests use real phone sizes). Unmounts any previous app
/// first, so several pumps in one test each boot their own state.
Future<CarthaHarness> _pumpToday(
  WidgetTester tester, {
  AppData? data,
  DateTime? now,
  Size size = const Size(390, 2400),
  double textScale = 1,
  Brightness brightness = Brightness.dark,
  int frames = 6,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final h = await pumpCartha(
    tester,
    data: data ?? onboardedData(),
    now: now,
    size: size,
    textScale: textScale,
    brightness: brightness,
    frames: frames,
  );
  expect(find.byType(TodayTab), findsOneWidget);
  return h;
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await pumpFrames(tester, count: 2);
  await tester.tap(finder);
  await pumpFrames(tester);
}

void main() {
  group('nextStepFor (pure)', () {
    test(
      'nothing started → begin the morning reflection, lessons optional',
      () {
        final step = nextStepFor(_facts());
        expect(step.kind, NextStepKind.start);
        expect(step.prompt?.id, 'morning.01');
        expect(step.suggestLessons, isTrue);
      },
    );

    test('lessons already read → no lesson suggestion', () {
      final step = nextStepFor(_facts(lessonsRead: 2));
      expect(step.kind, NextStepKind.start);
      expect(step.suggestLessons, isFalse);
    });

    test('a reset in progress resumes at its next prompt', () {
      final step = nextStepFor(
        _facts(resetStarted: true, nextPrompt: _p('daytime.02')),
      );
      expect(step, NextStep(NextStepKind.resume, prompt: _p('daytime.02')));
    });

    test('resuming wins over building the Compass while prompts are open', () {
      final step = nextStepFor(
        _facts(
          resetStarted: true,
          nextPrompt: _p('morning.05'),
          eveningFinished: true,
          canImportCompass: true,
        ),
      );
      expect(step.kind, NextStepKind.resume);
    });

    test('evening done and Compass empty → build the Compass', () {
      final withAnswers = nextStepFor(
        _facts(
          resetStarted: true,
          eveningFinished: true,
          canImportCompass: true,
        ),
      );
      expect(
        withAnswers,
        const NextStep(NextStepKind.buildCompass, canImport: true),
      );
      final skipped = nextStepFor(
        _facts(resetStarted: true, eveningFinished: true),
      );
      expect(skipped, const NextStep(NextStepKind.buildCompass));
    });

    test('a completed reset never asks to resume', () {
      final step = nextStepFor(
        _facts(
          resetStarted: true,
          resetCompleted: true,
          nextPrompt: _p('morning.09'),
          eveningFinished: true,
        ),
      );
      expect(step.kind, NextStepKind.buildCompass);
    });

    test('levers but no quests → turn levers into quests', () {
      final step = nextStepFor(
        _facts(
          resetStarted: true,
          eveningFinished: true,
          compassEmpty: false,
          compassHasLevers: true,
        ),
      );
      expect(step.kind, NextStepKind.leversToQuests);
    });

    test('otherwise: weekly review at the end of the week, else a note', () {
      NextStep at(int weekday, {bool reviewed = false}) => nextStepFor(
        _facts(
          resetStarted: true,
          eveningFinished: true,
          compassEmpty: false,
          compassHasLevers: true,
          questCount: 3,
          weekday: weekday,
          reviewedThisWeek: reviewed,
        ),
      );
      expect(at(DateTime.tuesday).kind, NextStepKind.journal);
      expect(at(DateTime.thursday).kind, NextStepKind.journal);
      expect(at(DateTime.friday).kind, NextStepKind.weeklyReview);
      expect(at(DateTime.sunday).kind, NextStepKind.weeklyReview);
      expect(at(DateTime.saturday, reviewed: true).kind, NextStepKind.journal);
    });

    test('a Compass without levers and no quests is not nagged about', () {
      final step = nextStepFor(
        _facts(resetStarted: true, eveningFinished: true, compassEmpty: false),
      );
      expect(step.kind, NextStepKind.journal);
    });
  });

  group('NextStepFacts.of (stored state only)', () {
    late DateTime clock;
    late MemoryDataStore store;
    late AppState state;

    setUp(() async {
      clock = kTestNow;
      store = MemoryDataStore(onboardedData());
      state = AppState(
        store: store,
        content: fakeContent,
        reminders: FakeReminderScheduler(),
        clock: () => clock,
      );
      await state.load();
    });

    NextStep step() => nextStepFor(NextStepFacts.of(state));

    test('reading the suggestion never writes', () {
      final before = store.raw;
      expect(step().kind, NextStepKind.start);
      expect(state.saveStatus, SaveStatus.idle);
      expect(store.raw, before);
    });

    test('follows the journey from start to weekly review', () async {
      expect(
        step(),
        NextStep(
          NextStepKind.start,
          prompt: _p('morning.01'),
          suggestLessons: true,
        ),
      );

      await state.markLessonRead('lesson.01');
      expect(step().suggestLessons, isFalse);

      await state.saveAnswer('morning.01', 'first words');
      expect(step(), NextStep(NextStepKind.resume, prompt: _p('morning.02')));

      // Answer the evening plan, skip everything else.
      for (final p in fakeContent.corePrompts) {
        if (p.mapsTo != null) {
          await state.saveAnswer(
            p.id,
            p.id == 'evening.07' ? '- Walk\n- Read' : 'text ${p.id}',
          );
        } else if (state.answer(p.id) == null) {
          await state.skipPrompt(p.id);
        }
      }
      expect(state.nextPrompt, isNull);
      expect(
        step(),
        const NextStep(NextStepKind.buildCompass, canImport: true),
      );

      await state.importCompassFromEvening(CompassField.values.toSet());
      expect(step().kind, NextStepKind.leversToQuests);

      await state.addQuestsFromLevers(state.leverDrafts);
      expect(step().kind, NextStepKind.journal, reason: 'Tuesday');

      clock = DateTime(2026, 11, 6, 18); // Friday
      expect(step().kind, NextStepKind.weeklyReview);
      await state.saveReview(
        weekStart: weekStartKey(clock),
        wins: 'w',
        friction: 'f',
        nextExperiment: 'n',
      );
      expect(step().kind, NextStepKind.journal);
    });

    test(
      'a completed reset with skipped evening offers a hand-filled Compass',
      () async {
        await state.skipPrompt('evening.01');
        await state.completeJourney();
        expect(step(), const NextStep(NextStepKind.buildCompass));
      },
    );

    test('opening a prompt without writing counts as started', () async {
      await state.setActivePrompt('daytime.03');
      expect(step(), NextStep(NextStepKind.resume, prompt: _p('daytime.03')));
    });
  });

  group('today model', () {
    test('part of day from the local hour', () {
      DayPart at(int h, [int m = 0]) => dayPartAt(DateTime(2026, 11, 3, h, m));
      expect(at(3, 59), DayPart.evening);
      expect(at(4), DayPart.morning);
      expect(at(11, 59), DayPart.morning);
      expect(at(12), DayPart.afternoon);
      expect(at(17, 59), DayPart.afternoon);
      expect(at(18), DayPart.evening);
      expect(at(23), DayPart.evening);
    });

    test('path day = latest written day; blank notes do not count', () {
      PathAnswer a(int day, String body, int minute) => PathAnswer(
        day: day,
        body: body,
        updatedAt: DateTime(2026, 11, 3, 9, minute),
      );
      expect(currentPathDay({}), isNull);
      expect(currentPathDay({4: a(4, '  ', 30)}), isNull);
      expect(currentPathDay({2: a(2, 'x', 10), 9: a(9, 'y', 5)}), 2);
      expect(currentPathDay({2: a(2, 'x', 10), 9: a(9, 'y', 10)}), 9);
      expect(currentPathDay({2: a(2, 'x', 10), 9: a(9, ' ', 50)}), 2);
      final answers = {1: a(1, 'x', 1), 2: a(2, 'x', 2), 4: a(4, 'x', 3)};
      expect(nextPathDay(answers, 2), 3);
      expect(nextPathDay(answers, 4), 5);
      expect(nextPathDay({30: a(30, 'x', 1)}, 30), 30);
    });

    test(
      'journey summary counts core prompts only, without judgement',
      () async {
        final state = AppState(
          store: MemoryDataStore(inProgressData()),
          content: fakeContent,
          reminders: FakeReminderScheduler(),
          clock: () => kTestNow,
        );
        await state.load();
        await state.saveAnswer('bonus.01', 'optional words');
        final s = JourneySummary.of(state);
        expect(s.answered, 3);
        expect(s.total, 27);
        expect(s.started, isTrue);
        expect(s.completed, isFalse);
        expect(s.allTouched, isFalse);
        expect([for (final p in s.phases) p.phase], kCorePhases);
        expect(s.phases.first.progress.answered, 3);
        expect(s.pathDay, 3);
        expect(s.pathNextDay, 4);
        expect(s.pathStage, PathStage.observe);
      },
    );
  });

  group('TodayTab', () {
    testWidgets('greets by local time, with the name or "Traveler"', (
      tester,
    ) async {
      await _pumpToday(tester);
      expect(find.text('Good morning, Sam.'), findsOneWidget);
      expect(find.text('Clarity today. Progress tomorrow.'), findsOneWidget);
    });

    for (final (hour, text) in [
      (14, 'Good afternoon, Traveler.'),
      (21, 'Good evening, Traveler.'),
    ]) {
      testWidgets('greeting at $hour:00 without a name', (tester) async {
        await _pumpToday(
          tester,
          data: onboardedData(name: null),
          now: DateTime(2026, 11, 3, hour),
        );
        expect(find.text(text), findsOneWidget);
      });
    }

    testWidgets(
      'first day: begin the morning, lessons optional, calm empty states',
      (tester) async {
        await _pumpToday(tester);
        expect(
          _inNextStep(find.text('Begin the morning reflection')),
          findsOneWidget,
        );
        expect(
          _inNextStep(find.textContaining('14 short questions')),
          findsOneWidget,
        );
        expect(find.text('Learn the 7 ideas (optional)'), findsOneWidget);
        expect(find.text('No quests for today'), findsOneWidget);
        expect(find.text('Your Compass is empty'), findsOneWidget);
        expect(
          find.text(
            "Your reset hasn't started yet. It's ready whenever you are.",
          ),
          findsOneWidget,
        );
        // No progress ring and no path day before anything was written.
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('today-journey')),
            matching: find.byType(ProgressRing),
          ),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('today-path-day')), findsNothing);
        expect(find.byType(DawnRuinsScene), findsOneWidget);

        await _tapVisible(tester, _inNextStep(find.text('Begin')));
        final prompt = tester.widget<GuidedPromptScreen>(
          find.byType(GuidedPromptScreen),
        );
        expect(prompt.promptId, 'morning.01');
      },
    );

    testWidgets('"Learn the 7 ideas" opens the lessons', (tester) async {
      await _pumpToday(tester);
      await _tapVisible(tester, find.text('Learn the 7 ideas (optional)'));
      expect(find.byType(AwakeningScreen), findsOneWidget);
    });

    testWidgets(
      'in progress: resume with the phase, quests, journey, direction',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final h = await _pumpToday(tester, data: inProgressData());
        expect(find.text('Continue the morning reflection'), findsOneWidget);
        expect(find.text('Next: Morning 4 title'), findsOneWidget);
        expect(find.text('Morning · question 4 of 14'), findsOneWidget);

        // Today's focus.
        for (final t in [_walk, _page, _phone]) {
          expect(find.text(t), findsOneWidget);
        }
        expect(find.text('Daily'), findsNWidgets(2));
        expect(find.text('No quests for today'), findsNothing);

        // Your journey, in words.
        expect(find.text('3 of 27 reflections written'), findsOneWidget);
        expect(
          find.text('Your reset is waiting where you left it.'),
          findsOneWidget,
        );
        expect(find.text('Morning 3/14'), findsOneWidget);
        expect(
          find.bySemanticsLabel('Morning: 3 of 14 written'),
          findsOneWidget,
        );
        expect(find.text('Day 3 of 30'), findsOneWidget);
        expect(find.text('Thirty-day path · Observe'), findsOneWidget);

        // Your direction.
        expect(find.text(_vision), findsOneWidget);
        expect(find.text(_month), findsOneWidget);

        await _tapVisible(tester, find.text('Continue'));
        expect(
          tester
              .widget<GuidedPromptScreen>(find.byType(GuidedPromptScreen))
              .promptId,
          'morning.04',
        );
        semantics.dispose();
        expect(
          h.state.saveStatus,
          SaveStatus.idle,
          reason: 'viewing never writes',
        );
      },
    );

    testWidgets('quests have accessible checkboxes and toggle for today', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpToday(tester, data: inProgressData());
      final walk = find.bySemanticsLabel("Mark '$_walk' done");
      final page = find.bySemanticsLabel("Mark '$_page' done");
      expect(walk, findsOneWidget);
      expect(page, findsOneWidget);
      expect(
        tester.getSemantics(walk),
        isSemantics(hasCheckedState: true, isChecked: true, hasTapAction: true),
      );
      expect(
        tester.getSemantics(page),
        isSemantics(
          hasCheckedState: true,
          isChecked: false,
          hasTapAction: true,
        ),
      );

      await _tapVisible(tester, find.text(_page));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester, count: 2);
      expect(h.state.questById('q2')!.isDoneOn(h.state.today), isTrue);
      expect(h.store.saved!.quests[1].completedOn, {h.state.today});
      expect(
        tester.getSemantics(page),
        isSemantics(isChecked: true, hasCheckedState: true, hasTapAction: true),
      );

      // And back again (also through the checkbox itself).
      final box = find.descendant(
        of: find.ancestor(of: find.text(_walk), matching: find.byType(InkWell)),
        matching: find.byType(Checkbox),
      );
      await _tapVisible(tester, box);
      expect(h.state.questById('q1')!.isDoneOn(h.state.today), isFalse);
      semantics.dispose();
    });

    testWidgets('only the first quests are listed, with a way to see all', (
      tester,
    ) async {
      final base = inProgressData();
      final h = await _pumpToday(
        tester,
        data: base.copyWith(
          quests: [
            for (var i = 1; i <= 7; i++)
              Quest(id: 'q$i', title: 'Quest $i', createdAt: _at),
          ],
        ),
      );
      expect(find.text('Quest 5'), findsOneWidget);
      expect(find.text('Quest 6'), findsNothing);
      await _tapVisible(tester, find.text('See all 7 quests'));
      expect(h.shell.tab, AppTab.compass);
      expect(h.shell.compassSection.value, CompassSection.missions);
    });

    testWidgets('"Add a quest" opens Missions', (tester) async {
      final h = await _pumpToday(tester);
      await _tapVisible(tester, find.text('Add a quest'));
      expect(h.shell.tab, AppTab.compass);
      expect(h.shell.compassSection.value, CompassSection.missions);
    });

    testWidgets('direction and path open the Compass and the path day', (
      tester,
    ) async {
      final h = await _pumpToday(tester, data: inProgressData());
      await _tapVisible(tester, find.text('Open day 4'));
      expect(tester.widget<PathDayScreen>(find.byType(PathDayScreen)).day, 4);
      Navigator.of(tester.element(find.byType(PathDayScreen))).pop();
      await pumpFrames(tester);
      await _tapVisible(tester, find.text('Open Compass'));
      expect(h.shell.tab, AppTab.compass);
      expect(h.shell.compassSection.value, CompassSection.compass);
    });

    testWidgets('"Open the reset" switches to the Reset tab', (tester) async {
      final h = await _pumpToday(tester, data: inProgressData());
      await _tapVisible(tester, find.text('Open the reset'));
      expect(h.shell.tab, AppTab.reset);
    });

    testWidgets('evening done, Compass empty → build it from the answers', (
      tester,
    ) async {
      final data = settledData().copyWith(
        compass: const LifeCompass(),
        quests: [],
      );
      await _pumpToday(tester, data: data);
      expect(_inNextStep(find.text('Build your Compass')), findsOneWidget);
      expect(
        find.text(
          'You finished this reset. Your answers stay here to revisit.',
        ),
        findsOneWidget,
      );
      expect(find.text('Your Compass is empty'), findsOneWidget);
      await _tapVisible(tester, find.text('Review your answers'));
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('levers and no quests → choose quests in Missions', (
      tester,
    ) async {
      final h = await _pumpToday(
        tester,
        data: settledData().copyWith(quests: []),
      );
      expect(find.text('Turn your levers into quests'), findsOneWidget);
      await _tapVisible(tester, find.text('Choose quests'));
      expect(h.shell.compassSection.value, CompassSection.missions);
    });

    testWidgets('a settled week day suggests a note; Friday a weekly review', (
      tester,
    ) async {
      await _pumpToday(tester, data: settledData());
      expect(_inNextStep(find.text('Write a note')), findsOneWidget);
      expect(find.text('Day 12 of 30'), findsOneWidget);
      expect(find.text('27 of 27 reflections written'), findsOneWidget);
      await _tapVisible(tester, find.text('New note'));
      expect(find.byType(JournalEntryScreen), findsOneWidget);
    });

    testWidgets('Friday evening: weekly review', (tester) async {
      await _pumpToday(
        tester,
        data: settledData(),
        now: DateTime(2026, 11, 6, 19, 10),
      );
      expect(find.text('Look back on your week'), findsOneWidget);
      await _tapVisible(tester, find.text('Start a weekly review'));
      expect(find.byType(ReviewScreen), findsOneWidget);
    });

    testWidgets('a failed save is shown honestly on Today', (tester) async {
      final h = await _pumpToday(tester, data: inProgressData());
      h.store.failWrites = true;
      await _tapVisible(tester, find.text(_page));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester, count: 2);
      expect(find.text("Your last change couldn't be saved."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('no streak, score or guilt copy in any state', (tester) async {
      for (final data in [onboardedData(), inProgressData(), settledData()]) {
        await _pumpToday(tester, data: data);
        await expectNoOverflow(tester);
        for (final text in _texts(tester)) {
          expect(_judgement.hasMatch(text), isFalse, reason: text);
        }
      }
    });

    testWidgets('the hero scene rises once, and is static without motion', (
      tester,
    ) async {
      await _pumpToday(tester);
      final scene = find.byType(BrandScene);
      expect(isBrandSceneAnimating(tester.state(scene)), isTrue);
      await pumpFrames(tester, count: 20);
      expect(isBrandSceneAnimating(tester.state(scene)), isFalse);
      expect(brandSceneProgress(tester.state(scene)), 1);

      await _pumpToday(
        tester,
        data: onboardedData(settings: const AppSettings(motion: false)),
        frames: 1,
      );
      final still = tester.state(find.byType(BrandScene));
      expect(isBrandSceneAnimating(still), isFalse);
      expect(brandSceneProgress(still), 1);
    });

    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('fits $size (${brightness.name})', (tester) async {
          for (final data in [
            onboardedData(name: null),
            inProgressData(),
            settledData(),
          ]) {
            await _pumpToday(
              tester,
              data: data,
              size: size.size,
              textScale: size.textScale,
              brightness: brightness,
            );
            expect(find.byType(TodayTab), findsOneWidget);
            await expectNoOverflow(tester);
          }
        });
      }
    }
  });

  test('Today and onboarding strings carry no judgement words', () {
    for (final name in ['today_en.arb', 'onboarding_en.arb']) {
      final arb = jsonDecode(
        File('l10n_src/$name').readAsStringSync(),
      ) as Map<String, Object?>;
      for (final MapEntry(:key, :value) in arb.entries) {
        if (key.startsWith('@') || value is! String) continue;
        // "No streaks, no scores" is the one allowed, reassuring mention.
        final text = value.replaceAll('No streaks, no scores.', '');
        expect(_judgement.hasMatch(text), isFalse, reason: '$name › $key');
      }
    }
  });
}
