import 'dart:convert';
import 'dart:io';

import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/domain/local_date.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/campaign/campaign_invite.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:cartharise/ui/missions/missions_logic.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/today/next_action.dart';
import 'package:cartharise/ui/today/next_step.dart';
import 'package:cartharise/ui/today/today_model.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/widgets/scenes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

// ── Test data (also used by the screenshot test) ────────────────────────────

/// Yesterday morning (kTestNow is Tuesday 3 November 2026, 09:30).
final _at = DateTime(2026, 11, 2, 8);

ReflectionAnswer _answer(String id, {String? body, bool skipped = false}) =>
    ReflectionAnswer(
      promptId: id,
      body: body ?? (skipped ? '' : 'My words for $id'),
      skipped: skipped,
      updatedAt: _at,
    );

String _two(int i) => i.toString().padLeft(2, '0');

const _avatar = Avatar(
  skinTone: SkinTone.copper,
  hair: HairStyle.coily,
  garment: Garment.cloak,
);

/// [data] with a saved avatar.
AppData _withAvatar(AppData data) => data.copyWith(
  persona: () => Persona(avatar: _avatar, motto: 'One step', updatedAt: _at),
);

const _walk = 'Walk 20 minutes';
const _page = 'Write one page';
const _phone = 'Phone off by 22:00';
const _vision = 'Calm mornings, honest work, time outside.';
const _month = 'Write and publish four short essays.';

/// Three morning answers, resume point morning.04, three quests (one daily
/// quest already done today), a vision and month project, path day 3.
AppData inProgressData({
  String? name = 'Sam',
}) => onboardedData(name: name).copyWith(
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
    // Planned for today, so it is in Today's focus (as in Missions).
    Quest(id: 'q2', title: _page, createdAt: _at, dueDate: dateKey(kTestNow)),
    Quest(
      id: 'q3',
      title: _phone,
      createdAt: _at,
      recurrence: QuestRecurrence.daily,
    ),
  ],
  compass: LifeCompass(vision: _vision, monthProject: _month, updatedAt: _at),
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

/// [inProgressData] with nothing done today: every quest is open.
AppData _openQuestsData() {
  final base = inProgressData();
  return base.copyWith(
    quests: [
      for (final q in base.quests) q.copyWith(completedOn: const {}),
    ],
  );
}

/// [settledData] on a quiet day: the only quest was finished yesterday, so
/// nothing is open and nothing was done today.
AppData _settledQuiet() => settledData().copyWith(
  quests: [
    Quest(
      id: 'old',
      title: 'Fix the bike',
      createdAt: _at,
      completedOn: {dateKey(_at)},
    ),
  ],
);

// ── Helpers ─────────────────────────────────────────────────────────────────

Quest _quest(String id) => Quest(id: id, title: 'Quest $id', createdAt: _at);

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
  Quest? openQuest,
  String? projectTitle,
  String? nextMilestone,
  TodayPin pin = TodayPin.auto,
  bool oneDayPace = false,
  DoneToday doneToday = DoneToday.nothing,
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
  openQuest: openQuest,
  projectTitle: projectTitle,
  nextMilestone: nextMilestone,
  pin: pin,
  oneDayPace: oneDayPace,
  doneToday: doneToday,
);

/// Facts of a settled user (reset done, Compass with levers, quests).
NextStepFacts _settled({
  int weekday = DateTime.tuesday,
  bool reviewed = false,
  Quest? openQuest,
  String? projectTitle,
  TodayPin pin = TodayPin.auto,
  DoneToday doneToday = DoneToday.nothing,
}) => _facts(
  lessonsRead: 7,
  resetStarted: true,
  resetCompleted: true,
  eveningFinished: true,
  compassEmpty: false,
  compassHasLevers: true,
  questCount: 3,
  weekday: weekday,
  reviewedThisWeek: reviewed,
  openQuest: openQuest,
  projectTitle: projectTitle,
  pin: pin,
  doneToday: doneToday,
);

Prompt _p(String id) => fakeContent.prompt(id)!;

Finder _inDirection(Finder f) => find.descendant(
  of: find.byKey(const ValueKey('today-direction')),
  matching: f,
);

Finder _inNextStep(Finder f) => find.descendant(
  of: find.byKey(const ValueKey('today-next-step')),
  matching: f,
);

Finder _inSheet(Finder f) => find.descendant(
  of: find.byKey(const ValueKey('today-choose-sheet')),
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

/// Lets storage writes land, then draws.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await pumpFrames(tester, count: 4);
}

Future<void> _openSheet(WidgetTester tester) async {
  await _tapVisible(tester, find.byKey(const ValueKey('today-choose-other')));
  expect(find.byKey(const ValueKey('today-choose-sheet')), findsOneWidget);
}

/// Opens (or closes) "Your direction", scrolling Today's list to it first
/// (the list builds lazily on a phone).
Future<void> _expandDirection(WidgetTester tester) async {
  final toggle = find.byKey(const ValueKey('today-direction-toggle'));
  if (toggle.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      toggle,
      200,
      scrollable: find
          .descendant(
            of: find.byType(TodayTab),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await _tapVisible(tester, toggle);
}

void main() {
  group('nextStepFor (pure)', () {
    test(
      'nothing started, no quests → begin the morning, lessons optional',
      () {
        final step = nextStepFor(_facts());
        expect(step.kind, NextStepKind.start);
        expect(step.prompt?.id, 'morning.01');
        expect(step.suggestLessons, isTrue);
        expect(step.pinned, isFalse);
      },
    );

    test('lessons already read → no lesson suggestion', () {
      final step = nextStepFor(_facts(lessonsRead: 2));
      expect(step.kind, NextStepKind.start);
      expect(step.suggestLessons, isFalse);
    });

    test('open quests but the reset not started → do a quest', () {
      final q = _quest('a');
      final step = nextStepFor(_facts(openQuest: q, questCount: 1));
      expect(step, NextStep(NextStepKind.quest, quest: q));
    });

    test('quests, none open today, reset not started → begin the reset', () {
      expect(nextStepFor(_facts(questCount: 2)).kind, NextStepKind.start);
    });

    test('an open quest comes before resuming the reset', () {
      final step = nextStepFor(
        _facts(
          resetStarted: true,
          nextPrompt: _p('daytime.02'),
          openQuest: _quest('a'),
          questCount: 1,
        ),
      );
      expect(step.kind, NextStepKind.quest);
      expect(step.quest?.id, 'a');
    });

    test('a reset in progress (no open quest) resumes at its next prompt', () {
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
      NextStep at(int weekday, {bool reviewed = false}) =>
          nextStepFor(_settled(weekday: weekday, reviewed: reviewed));
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

    test('the project is never chosen by the app itself', () {
      final step = nextStepFor(_settled(projectTitle: 'Four essays'));
      expect(step.kind, NextStepKind.journal);
    });

    group('pins', () {
      test('notes → a journal note, even with open quests', () {
        final step = nextStepFor(
          _settled(pin: TodayPin.notes, openQuest: _quest('a')),
        );
        expect(step, const NextStep(NextStepKind.journal, pinned: true));
      });

      test('reflection → begin the reset, even with open quests', () {
        final step = nextStepFor(
          _facts(
            pin: TodayPin.reflection,
            openQuest: _quest('a'),
            questCount: 1,
          ),
        );
        expect(step.kind, NextStepKind.start);
        expect(step.prompt?.id, 'morning.01');
        expect(step.pinned, isTrue);
      });

      test('reflection → resume a reset in progress', () {
        final step = nextStepFor(
          _facts(
            pin: TodayPin.reflection,
            resetStarted: true,
            nextPrompt: _p('evening.02'),
            openQuest: _quest('a'),
            questCount: 1,
          ),
        );
        expect(
          step,
          NextStep(
            NextStepKind.resume,
            prompt: _p('evening.02'),
            pinned: true,
          ),
        );
      });

      test('reflection, reset done → the weekly review at the end of the '
          'week, else the app decides', () {
        expect(
          nextStepFor(
            _settled(pin: TodayPin.reflection, weekday: DateTime.friday),
          ),
          const NextStep(NextStepKind.weeklyReview, pinned: true),
        );
        final tuesday = nextStepFor(
          _settled(pin: TodayPin.reflection, openQuest: _quest('a')),
        );
        expect(tuesday.kind, NextStepKind.quest);
        expect(tuesday.pinned, isFalse, reason: 'fell back');
      });

      test('project → the month project with its next milestone', () {
        final step = nextStepFor(
          _facts(
            pin: TodayPin.project,
            projectTitle: 'Four essays',
            nextMilestone: 'First draft',
            openQuest: _quest('a'),
            questCount: 1,
          ),
        );
        expect(
          step,
          const NextStep(
            NextStepKind.project,
            projectTitle: 'Four essays',
            nextMilestone: 'First draft',
            pinned: true,
          ),
        );
      });

      test('project without a project → falls back to the app order', () {
        final step = nextStepFor(_facts(pin: TodayPin.project));
        expect(step.kind, NextStepKind.start);
        expect(step.pinned, isFalse);
        final settled = nextStepFor(
          _settled(pin: TodayPin.project, openQuest: _quest('a')),
        );
        expect(settled.kind, NextStepKind.quest);
      });

      test('auto is the app order', () {
        expect(
          nextStepFor(_settled(pin: TodayPin.auto, openQuest: _quest('a'))),
          NextStep(NextStepKind.quest, quest: _quest('a')),
        );
      });
    });
  });

  group('stepOptions (pure)', () {
    test('every step that makes sense now, once each, a note last', () {
      final options = stepOptions(
        _facts(
          resetStarted: true,
          nextPrompt: _p('morning.04'),
          openQuest: _quest('a'),
          questCount: 1,
          projectTitle: 'Four essays',
          weekday: DateTime.saturday,
        ),
      );
      expect([for (final s in options) s.kind], [
        NextStepKind.quest,
        NextStepKind.resume,
        NextStepKind.weeklyReview,
        NextStepKind.project,
        NextStepKind.journal,
      ]);
      expect(options.every((s) => !s.pinned), isTrue);
    });

    test('a fresh start offers the reset and a note', () {
      expect([for (final s in stepOptions(_facts())) s.kind], [
        NextStepKind.start,
        NextStepKind.journal,
      ]);
    });

    test('the Compass steps when they apply', () {
      expect(
        [
          for (final s in stepOptions(
            _facts(
              resetStarted: true,
              eveningFinished: true,
              canImportCompass: true,
            ),
          ))
            s.kind,
        ],
        [NextStepKind.buildCompass, NextStepKind.journal],
      );
    });
  });

  group('doneForToday (pure)', () {
    const journal = NextStep(NextStepKind.journal);

    test('the app\'s own choice: anything Today could suggest, done today', () {
      expect(doneForToday(_settled(), journal), isFalse);
      for (final done in const [
        DoneToday(quest: true),
        DoneToday(answer: true),
        DoneToday(note: true),
        DoneToday(review: true),
        DoneToday(compass: true),
        DoneToday(project: true),
      ]) {
        expect(doneForToday(_settled(doneToday: done), journal), isTrue);
      }
    });

    test('pinned: only the chosen kind counts', () {
      NextStepFacts f(TodayPin pin, DoneToday d) => _settled(
        pin: pin,
        projectTitle: 'Four essays',
        weekday: DateTime.friday,
        doneToday: d,
      );
      bool done(TodayPin pin, DoneToday d) =>
          doneForToday(f(pin, d), nextStepFor(f(pin, d)));

      expect(done(TodayPin.notes, const DoneToday(quest: true)), isFalse);
      expect(done(TodayPin.notes, const DoneToday(note: true)), isTrue);
      expect(done(TodayPin.reflection, const DoneToday(note: true)), isFalse);
      expect(done(TodayPin.reflection, const DoneToday(answer: true)), isTrue);
      expect(done(TodayPin.reflection, const DoneToday(review: true)), isTrue);
      expect(done(TodayPin.project, const DoneToday(quest: true)), isFalse);
      expect(done(TodayPin.project, const DoneToday(project: true)), isTrue);
    });

    test('a one-day reset under way keeps offering "Continue"', () {
      final facts = _facts(
        resetStarted: true,
        nextPrompt: _p('daytime.01'),
        oneDayPace: true,
        doneToday: const DoneToday(answer: true),
      );
      final step = nextStepFor(facts);
      expect(step.kind, NextStepKind.resume);
      expect(doneForToday(facts, step), isFalse);
      final flexible = _facts(
        resetStarted: true,
        nextPrompt: _p('daytime.01'),
        doneToday: const DoneToday(answer: true),
      );
      expect(doneForToday(flexible, nextStepFor(flexible)), isTrue);
    });

    test('nothing done today → never "done", however long ago the last '
        'activity was', () {
      expect(DoneToday.nothing.anything, isFalse);
      expect(doneForToday(_facts(), nextStepFor(_facts())), isFalse);
    });
  });

  group('NextStepFacts.of (stored state only)', () {
    late DateTime clock;
    late MemoryDataStore store;
    late AppState state;

    Future<void> boot(AppData data) async {
      clock = kTestNow;
      store = MemoryDataStore(data);
      state = AppState(
        store: store,
        content: fakeContent,
        reminders: FakeReminderScheduler(),
        clock: () => clock,
      );
      await state.load();
    }

    setUp(() => boot(onboardedData()));

    NextStepFacts facts() => NextStepFacts.of(state);
    NextStep step() => nextStepFor(facts());

    test('reading the suggestion never writes', () {
      final before = store.raw;
      expect(step().kind, NextStepKind.start);
      expect(doneForToday(facts(), step()), isFalse);
      expect(state.saveStatus, SaveStatus.idle);
      expect(store.raw, before);
    });

    test('follows the days from start to weekly review', () async {
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
      expect(facts().doneToday.answer, isTrue);

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
      expect(facts().doneToday.compass, isTrue);

      await state.addQuestsFromLevers(state.leverDrafts);
      final walk = state.data.quests.first;
      expect(step(), NextStep(NextStepKind.quest, quest: walk));

      for (final q in state.data.quests) {
        await state.setQuestDone(q.id, true);
      }
      expect(facts().doneToday.quest, isTrue);
      expect(step().kind, NextStepKind.journal, reason: 'Tuesday');

      clock = DateTime(2026, 11, 6, 18); // Friday
      expect(facts().doneToday.anything, isFalse, reason: 'a new day');
      expect(step().kind, NextStepKind.quest, reason: 'daily quests reopen');
      for (final q in state.data.quests) {
        await state.setQuestDone(q.id, true);
      }
      expect(step().kind, NextStepKind.weeklyReview);
      await state.saveReview(
        weekStart: weekStartKey(clock),
        wins: 'w',
        friction: 'f',
        nextExperiment: 'n',
      );
      expect(step().kind, NextStepKind.journal);
      expect(facts().doneToday.review, isTrue);
    });

    test(
      'a completed reset with skipped evening offers a hand-filled Compass',
      () async {
        await state.skipPrompt('evening.01');
        await state.completeJourney();
        expect(step(), const NextStep(NextStepKind.buildCompass));
        expect(facts().doneToday.answer, isFalse, reason: 'a skip is no answer');
      },
    );

    test('opening a prompt without writing counts as started', () async {
      await state.setActivePrompt('daytime.03');
      expect(step(), NextStep(NextStepKind.resume, prompt: _p('daytime.03')));
    });

    test('the open quest is the first open one of today\'s focus', () async {
      await boot(inProgressData());
      // q1 is done today; q2 (planned today) comes before q3 (daily).
      expect(facts().openQuest?.id, 'q2');
      expect(facts().doneToday.quest, isTrue);
      expect(facts().doneToday.answer, isFalse, reason: 'answers: yesterday');
    });

    test('today\'s notes, reviews and project work count; older ones '
        'do not', () async {
      await boot(
        onboardedData().copyWith(
          journal: [JournalEntry(id: 'n1', body: 'old', createdAt: _at)],
          reviews: [
            WeeklyReview(
              id: 'r1',
              weekStart: '2026-10-26',
              wins: 'w',
              friction: 'f',
              nextExperiment: 'n',
              createdAt: _at,
            ),
          ],
          project: () => MonthProject(title: 'Four essays', updatedAt: _at),
        ),
      );
      expect(facts().doneToday.anything, isFalse);
      await state.addJournalEntry(body: 'today');
      expect(facts().doneToday.note, isTrue);
      await state.setProjectStatus(ProjectStatus.active);
      expect(facts().doneToday.project, isTrue);
    });

    test('a project quest done today counts as project work', () async {
      await boot(
        onboardedData().copyWith(
          quests: [
            Quest(
              id: 'p1',
              title: 'Outline',
              createdAt: _at,
              source: QuestSource.project,
            ),
          ],
        ),
      );
      await state.setQuestDone('p1', true);
      expect(facts().doneToday.project, isTrue);
      expect(facts().doneToday.quest, isTrue);
    });

    test('the project: saved (unless finished) or the Compass draft', () async {
      await boot(
        onboardedData().copyWith(
          compass: LifeCompass(monthProject: '  Draft project ', updatedAt: _at),
        ),
      );
      expect(facts().projectTitle, 'Draft project');
      expect(facts().nextMilestone, isNull);

      await boot(
        onboardedData().copyWith(
          project: () => MonthProject(
            title: 'Four essays',
            updatedAt: _at,
            milestones: const [
              Milestone(id: 'm1', title: 'Outline', done: true),
              Milestone(id: 'm2', title: 'First draft'),
            ],
          ),
          settings: const AppSettings(todayPin: TodayPin.project),
        ),
      );
      expect(facts().projectTitle, 'Four essays');
      expect(facts().nextMilestone, 'First draft');
      expect(facts().pin, TodayPin.project);
      expect(step().kind, NextStepKind.project);

      await boot(
        onboardedData().copyWith(
          project: () => MonthProject(
            title: 'Four essays',
            status: ProjectStatus.done,
            updatedAt: _at,
          ),
          settings: const AppSettings(todayPin: TodayPin.project),
        ),
      );
      expect(facts().hasProject, isFalse);
      expect(step().kind, NextStepKind.start, reason: 'falls back');
    });

    test('pace one day is read from the profile', () async {
      final data = onboardedData();
      await boot(
        data.copyWith(
          profile: () => data.profile!.copyWith(pace: Pace.oneDay),
        ),
      );
      expect(facts().oneDayPace, isTrue);
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

    test('first-use hints show until the feature is first used', () {
      final fresh = FirstUseHints.of(onboardedData());
      expect(fresh.reset, isTrue);
      expect(fresh.compass, isTrue);
      expect(fresh.quests, isTrue);

      final used = FirstUseHints.of(inProgressData());
      expect(used.reset, isFalse);
      expect(used.compass, isFalse);
      expect(used.quests, isFalse);

      // An opened prompt, a saved Compass version or a finished reset is
      // use too, even when the current fields are empty again.
      final opened = FirstUseHints.of(
        onboardedData().copyWith(
          journeys: [
            Journey(id: 'j', startedAt: _at, activePromptId: 'morning.01'),
          ],
          compassHistory: [
            CompassVersion(
              savedAt: _at,
              compass: const LifeCompass(vision: 'v'),
              reason: CompassVersionReason.manual,
            ),
          ],
        ),
      );
      expect(opened.reset, isFalse);
      expect(opened.compass, isFalse);
      expect(opened.quests, isTrue);
    });
  });

  group('TodayTab', () {
    testWidgets('greets by local time, with the name or "Traveler"', (
      tester,
    ) async {
      await _pumpToday(tester);
      expect(find.text('Good morning, Sam.'), findsOneWidget);
      expect(find.text('Clarity today. Progress tomorrow.'), findsOneWidget);
    });

    testWidgets('the avatar stands beside the greeting once made', (
      tester,
    ) async {
      await _pumpToday(tester);
      expect(find.byKey(const ValueKey('today-avatar')), findsNothing);
      expect(
        find.descendant(
          of: find.byType(TodayTab),
          matching: find.byType(AvatarView),
        ),
        findsNothing,
        reason: 'no emblem stand-in on Today',
      );

      await _pumpToday(tester, data: _withAvatar(onboardedData()));
      final view = tester.widget<AvatarView>(
        find.byKey(const ValueKey('today-avatar')),
      );
      expect(view.avatar, _avatar);
      expect(view.excludeFromSemantics, isTrue, reason: 'the greeting says it');
      expect(find.text('Good morning, Sam.'), findsOneWidget);
      // Beside the greeting, on the same line.
      final avatarBox = tester.getRect(
        find.byKey(const ValueKey('today-avatar')),
      );
      final greetingBox = tester.getRect(find.text('Good morning, Sam.'));
      expect(avatarBox.right, lessThanOrEqualTo(greetingBox.left));
      expect(avatarBox.top, lessThan(greetingBox.bottom));
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

    testWidgets('the order: next action, Write, glance, quests, direction', (
      tester,
    ) async {
      await _pumpToday(tester, data: inProgressData());
      double top(String key) => tester.getTopLeft(find.byKey(ValueKey(key))).dy;
      final order = [
        'today-next-step',
        'today-write',
        'today-journey',
        'today-focus',
        'today-direction',
      ];
      for (var i = 1; i < order.length; i++) {
        expect(top(order[i]), greaterThan(top(order[i - 1])), reason: order[i]);
      }
    });

    testWidgets(
      'first day: begin the morning, lessons optional, first-use hints',
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
        // One line introduces the reset (instead of a welcome page).
        expect(
          _inNextStep(
            find.text('Morning, daytime, evening: one day, at your own pace.'),
          ),
          findsOneWidget,
        );
        expect(find.text('Learn the 7 ideas (optional)'), findsOneWidget);
        expect(find.text('No quests for today'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('today-hint-quests')),
          findsOneWidget,
        );
        expect(
          find.text('Quests are small steps you choose. Adjust them each week.'),
          findsOneWidget,
        );
        expect(
          find.text('Your answers can become a Life Compass.'),
          findsOneWidget,
        );
        // The reset tile invites a start; no progress bar and no path day
        // before anything was written.
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('today-journey')),
            matching: find.text('Start'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('today-journey')),
            matching: find.byType(LinearProgressIndicator),
          ),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('today-path-day')), findsNothing);
        expect(find.byKey(const ValueKey('today-done')), findsNothing);

        await _tapVisible(tester, _inNextStep(find.text('Begin')));
        final prompt = tester.widget<GuidedPromptScreen>(
          find.byType(GuidedPromptScreen),
        );
        expect(prompt.promptId, 'morning.01');
      },
    );

    testWidgets('hints are gone once the feature was used', (tester) async {
      await _pumpToday(tester, data: inProgressData());
      await tester.tap(find.byKey(const ValueKey('today-one-more')));
      await pumpFrames(tester);
      expect(find.byKey(const ValueKey('today-hint-quests')), findsNothing);
      expect(find.byKey(const ValueKey('today-hint-compass')), findsNothing);
      expect(
        find.text('Morning, daytime, evening: one day, at your own pace.'),
        findsNothing,
      );

      // No quest right now, but there were some: the calm empty line.
      await _pumpToday(
        tester,
        data: inProgressData().copyWith(
          quests: [
            Quest(
              id: 'later',
              title: 'Plan next week',
              createdAt: _at,
              dueDate: '2026-11-20',
            ),
          ],
          compass: const LifeCompass(),
          compassHistory: [
            CompassVersion(
              savedAt: _at,
              compass: const LifeCompass(vision: 'v'),
              reason: CompassVersionReason.manual,
            ),
          ],
        ),
      );
      expect(find.text('No quests for today'), findsOneWidget);
      expect(find.text("Add a small quest when you're ready."), findsOneWidget);
      expect(find.byKey(const ValueKey('today-hint-quests')), findsNothing);
      expect(find.text('Your Compass is empty.'), findsOneWidget);
      expect(find.byKey(const ValueKey('today-hint-compass')), findsNothing);
    });

    testWidgets('the scene is compact: about a third of its width', (
      tester,
    ) async {
      await _pumpToday(tester);
      final size = tester.getSize(find.byType(BrandScene));
      expect(
        size.width / size.height,
        closeTo(NextActionCard.sceneAspectRatio, 0.01),
      );
      expect(size.height, lessThan(size.width / 2), reason: 'smaller than 2:1');
      expect(
        tester.widget<BrandScene>(find.byType(BrandScene)).compact,
        isTrue,
        reason: 'the compact variant crops the art instead of squashing it',
      );
    });

    testWidgets('"Learn the 7 ideas" opens the lessons', (tester) async {
      await _pumpToday(tester);
      await _tapVisible(tester, find.text('Learn the 7 ideas (optional)'));
      expect(find.byType(AwakeningScreen), findsOneWidget);
    });

    testWidgets('an open quest: "Mark done", then the easy stop and '
        '"One more"', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpToday(tester, data: _openQuestsData());
      // The first quest of today's focus (Missions' order).
      final focus = h.state.todayFocus();
      final first = focus.first;
      expect(_inNextStep(find.text(first.title)), findsOneWidget);
      expect(_inNextStep(find.text("One of today's quests.")), findsOneWidget);
      await _tapVisible(tester, _inNextStep(find.text('Mark done')));
      await _settle(tester);
      expect(h.state.questById(first.id)!.isDoneOn(h.state.today), isTrue);
      expect(
        h.store.saved!.quests.firstWhere((q) => q.id == first.id).completedOn,
        {h.state.today},
      );

      // Done for today: said in words, with a quiet way to one more.
      expect(
        _inNextStep(find.text('Done. That can be enough for today.')),
        findsOneWidget,
      );
      expect(_inNextStep(find.text('Mark done')), findsNothing);
      expect(find.bySemanticsLabel('Show one more step'), findsOneWidget);
      await _tapVisible(tester, find.byKey(const ValueKey('today-one-more')));
      // The next open quest.
      expect(_inNextStep(find.text(focus[1].title)), findsOneWidget);
      expect(find.byKey(const ValueKey('today-done')), findsNothing);
      semantics.dispose();
    });

    testWidgets('something done today shows the easy stop first', (
      tester,
    ) async {
      // q1 was completed today.
      await _pumpToday(tester, data: inProgressData());
      expect(find.byKey(const ValueKey('today-done')), findsOneWidget);
      expect(find.text('Done. That can be enough for today.'), findsOneWidget);
      // The quests stay listed below, as they are.
      for (final t in [_walk, _page, _phone]) {
        expect(find.text(t), findsOneWidget);
      }
      await _tapVisible(tester, find.text('One more'));
      expect(_inNextStep(find.text(_page)), findsOneWidget);
    });

    testWidgets('a reset in progress: resume with the phase', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpToday(
        tester,
        data: inProgressData().copyWith(quests: []),
      );
      expect(find.text('Continue the morning reflection'), findsOneWidget);
      expect(find.text('Next: Morning 4 title'), findsOneWidget);
      expect(find.text('Morning · question 4 of 14'), findsOneWidget);

      // At a glance: progress in words, the path day once written.
      expect(find.text('3/27'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Reset: 3/27. 3 of 27 reflections written'),
        findsOneWidget,
      );
      expect(find.text('Day 3'), findsOneWidget);
      expect(find.text('Observe'), findsOneWidget);

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
    });

    testWidgets('the direction is collapsed, and expands on a tap', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpToday(tester, data: inProgressData());
      final toggle = find.byKey(const ValueKey('today-direction-toggle'));
      expect(find.text(_vision), findsNothing);
      expect(find.text(_month), findsNothing);
      expect(find.text("Your vision and this month's project."), findsOneWidget);
      expect(
        tester.getSemantics(toggle),
        isSemantics(
          label: "Your direction. Your vision and this month's project.",
          isButton: true,
          hasTapAction: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );
      expect(_inDirection(find.byIcon(Icons.expand_more)), findsOneWidget);

      await _expandDirection(tester);
      expect(find.text(_vision), findsOneWidget);
      expect(find.text(_month), findsOneWidget);
      expect(
        tester.getSemantics(toggle),
        isSemantics(
          isButton: true,
          hasTapAction: true,
          hasExpandedState: true,
          isExpanded: true,
        ),
      );
      expect(_inDirection(find.byIcon(Icons.expand_less)), findsOneWidget);

      await _expandDirection(tester);
      expect(find.text(_vision), findsNothing);
      semantics.dispose();
    });

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
      await _settle(tester);
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

    testWidgets('open quests show "+20 XP", as in Missions', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpToday(tester, data: inProgressData());
      Finder chip(String id) => find.byKey(ValueKey('today-quest-xp-$id'));
      // q1 is done today; q2 and q3 are open.
      expect(chip('q1'), findsNothing);
      expect(chip('q2'), findsOneWidget);
      expect(chip('q3'), findsOneWidget);
      expect(
        find.descendant(of: chip('q2'), matching: find.text('+20 XP')),
        findsOneWidget,
      );
      // Read out with the row: never by the chip's colour alone.
      expect(
        tester.getSemantics(find.bySemanticsLabel("Mark '$_page' done")),
        isSemantics(hint: 'Earns 20 XP when done'),
      );
      expect(
        tester
            .getSemantics(find.bySemanticsLabel("Mark '$_walk' done"))
            .getSemanticsData()
            .hint,
        isEmpty,
      );
      semantics.dispose();
    });

    testWidgets("no XP chip once today's quest XP is used up", (tester) async {
      final base = inProgressData();
      final today = dateKey(kTestNow);
      await _pumpToday(
        tester,
        data: base.copyWith(
          quests: [
            ...base.quests,
            for (final id in ['d1', 'd2'])
              Quest(
                id: id,
                title: 'Done $id',
                createdAt: _at,
                completedOn: {today},
              ),
          ],
        ),
      );
      expect(find.text(_page), findsOneWidget);
      expect(find.byKey(const ValueKey('today-quest-xp-q2')), findsNothing);
      expect(find.text('+20 XP'), findsNothing);
    });

    testWidgets('no XP chip with the game layer off', (tester) async {
      final base = inProgressData();
      await _pumpToday(
        tester,
        data: base.copyWith(settings: const AppSettings(game: false)),
      );
      expect(find.text(_page), findsOneWidget);
      expect(find.byKey(const ValueKey('today-quest-xp-q2')), findsNothing);
      expect(find.text('+20 XP'), findsNothing);
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
              Quest(
                id: 'q$i',
                title: 'Quest $i',
                createdAt: _at,
                dueDate: dateKey(kTestNow),
              ),
          ],
        ),
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('today-focus')),
          matching: find.text('Quest 5'),
        ),
        findsOneWidget,
      );
      expect(find.text('Quest 6'), findsNothing);
      await _tapVisible(tester, find.text('See all 7 quests'));
      expect(h.shell.tab, AppTab.compass);
      expect(h.shell.compassSection.value, CompassSection.missions);
    });

    testWidgets("Today's focus and Missions agree on what is for today", (
      tester,
    ) async {
      final base = inProgressData();
      final h = await _pumpToday(
        tester,
        data: base.copyWith(
          quests: [
            ...base.quests,
            Quest(id: 'anytime', title: 'Anytime task', createdAt: _at),
            Quest(
              id: 'later',
              title: 'Plan next week',
              createdAt: _at,
              dueDate: '2026-11-20',
            ),
            Quest(
              id: 'overdue',
              title: 'Call the bank',
              createdAt: _at,
              dueDate: '2026-11-01',
            ),
          ],
        ),
      );
      final sections = h.state.missionSections();
      expect(sections.later.map((q) => q.title), [
        'Anytime task',
        'Plan next week',
      ]);
      // Exactly Missions' Today section, nothing from "Anytime & upcoming".
      expect(
        h.state.todayFocus().map((q) => q.id).toSet(),
        sections.today.map((q) => q.id).toSet(),
      );
      for (final q in sections.today) {
        expect(find.text(q.title), findsOneWidget, reason: q.title);
      }
      expect(find.text('Call the bank'), findsOneWidget);
      expect(find.text('Anytime task'), findsNothing);
      expect(find.text('Plan next week'), findsNothing);
      // The other quests are counted, with a way to them.
      await _tapVisible(tester, find.text('2 more for anytime or later'));
      expect(h.shell.tab, AppTab.compass);
      expect(h.shell.compassSection.value, CompassSection.missions);
    });

    testWidgets('a planned one-off ticked on Today stays listed, ticked', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpToday(tester, data: inProgressData());
      await _tapVisible(tester, find.text(_page));
      await _settle(tester);
      expect(h.state.missionSections().done.map((q) => q.id), ['q2']);
      expect(h.state.todayFocus().map((q) => q.id), contains('q2'));
      expect(
        tester.getSemantics(find.bySemanticsLabel("Mark '$_page' done")),
        isSemantics(isChecked: true, hasCheckedState: true, hasTapAction: true),
      );
      semantics.dispose();
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
      await _tapVisible(tester, find.byKey(const ValueKey('today-path-day')));
      expect(tester.widget<PathDayScreen>(find.byType(PathDayScreen)).day, 4);
      Navigator.of(tester.element(find.byType(PathDayScreen))).pop();
      await pumpFrames(tester);
      expect(find.text('Open Compass'), findsNothing, reason: 'collapsed');
      await _expandDirection(tester);
      await _tapVisible(tester, find.text('Open Compass'));
      expect(h.shell.tab, AppTab.compass);
      expect(h.shell.compassSection.value, CompassSection.compass);
    });

    testWidgets('the reset tile switches to the Reset tab', (tester) async {
      final h = await _pumpToday(tester, data: inProgressData());
      await _tapVisible(tester, find.byKey(const ValueKey('today-journey')));
      expect(h.shell.tab, AppTab.reset);
    });

    testWidgets('the Write capture opens a new note', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpToday(tester, data: inProgressData());
      final write = find.byKey(const ValueKey('today-write'));
      expect(find.text('Write a few lines…'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Write a new note')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      await _tapVisible(tester, write);
      final screen = tester.widget<JournalEntryScreen>(
        find.byType(JournalEntryScreen),
      );
      expect(screen.entryId, isNull, reason: 'a new note');
      expect(h.state.data.journal, isEmpty, reason: 'nothing until typed');
      semantics.dispose();
    });

    testWidgets('the Campaign invitation sits below the next action while '
        'unanswered', (tester) async {
      await _pumpToday(
        tester,
        data: onboardedData(
          settings: const AppSettings(game: false, gameInvited: false),
        ),
      );
      final invite = find.byKey(const ValueKey('today-invite'));
      expect(invite, findsOneWidget);
      expect(tester.widget(invite), isA<CampaignInviteCard>());
      expect(
        tester.getTopLeft(invite).dy,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.byKey(const ValueKey('today-next-step'))).dy,
        ),
      );
      expect(
        tester.getTopLeft(invite).dy,
        lessThan(tester.getTopLeft(find.byKey(const ValueKey('today-write'))).dy),
      );

      // Answered (or an existing user): never shown.
      await _pumpToday(tester);
      expect(find.byKey(const ValueKey('today-invite')), findsNothing);
      await _pumpToday(
        tester,
        data: onboardedData(
          settings: const AppSettings(game: false, gameInvited: true),
        ),
      );
      expect(find.byKey(const ValueKey('today-invite')), findsNothing);
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
        find.descendant(
          of: find.byKey(const ValueKey('today-journey')),
          matching: find.text('Done'),
        ),
        findsOneWidget,
      );
      expect(
        find.text('Your answers can become a Life Compass.'),
        findsOneWidget,
      );
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
      await _pumpToday(tester, data: _settledQuiet());
      expect(_inNextStep(find.text('Write a note')), findsOneWidget);
      expect(find.text('Day 12'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('27 of 27 reflections written')),
        findsOneWidget,
      );
      await _tapVisible(tester, find.text('New note'));
      expect(find.byType(JournalEntryScreen), findsOneWidget);
    });

    testWidgets('Friday evening: weekly review', (tester) async {
      await _pumpToday(
        tester,
        data: _settledQuiet(),
        now: DateTime(2026, 11, 6, 19, 10),
      );
      expect(find.text('Look back on your week'), findsOneWidget);
      await _tapVisible(tester, find.text('Start a weekly review'));
      expect(find.byType(ReviewScreen), findsOneWidget);
    });

    testWidgets('"Choose something else" lists the other steps; one tap '
        'starts one', (tester) async {
      final h = await _pumpToday(tester, data: _openQuestsData());
      expect(
        _inNextStep(find.text(h.state.todayFocus().first.title)),
        findsOneWidget,
      );
      await _openSheet(tester);
      expect(find.text('Other steps'), findsOneWidget);
      // Everything that makes sense now, except the quest on the card.
      final options = [
        for (final kind in NextStepKind.values)
          if (find
              .byKey(ValueKey('today-option-${kind.name}'))
              .evaluate()
              .isNotEmpty)
            kind,
      ];
      expect(options, [
        NextStepKind.resume,
        NextStepKind.project,
        NextStepKind.journal,
      ]);
      expect(
        _inSheet(find.text('Continue the morning reflection')),
        findsOneWidget,
      );
      expect(_inSheet(find.text('Work on your project')), findsOneWidget);
      expect(_inSheet(find.text('Write a note')), findsOneWidget);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('today-option-resume')),
      );
      expect(find.byKey(const ValueKey('today-choose-sheet')), findsNothing);
      expect(
        tester
            .widget<GuidedPromptScreen>(find.byType(GuidedPromptScreen))
            .promptId,
        'morning.04',
      );
    });

    testWidgets('a quest picked in the sheet opens Missions', (tester) async {
      final h = await _pumpToday(
        tester,
        data: _openQuestsData().copyWith(
          settings: const AppSettings(todayPin: TodayPin.notes),
        ),
      );
      expect(_inNextStep(find.text('Write a note')), findsOneWidget);
      await _openSheet(tester);
      expect(_inSheet(find.text("Do one of today's quests")), findsOneWidget);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('today-option-quest')),
      );
      expect(h.shell.compassSection.value, CompassSection.missions);
    });

    testWidgets('"Help me with" remembers the choice and steers the card', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpToday(tester);
      await _openSheet(tester);
      expect(find.text('Help me with'), findsOneWidget);
      for (final label in [
        'My project',
        'Reflection',
        'Notes',
        'Decide for me',
      ]) {
        expect(_inSheet(find.text(label)), findsOneWidget, reason: label);
      }
      expect(
        tester.getSemantics(find.byKey(const ValueKey('today-pin-auto'))),
        isSemantics(
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: true,
        ),
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('today-pin-notes'))),
        isSemantics(
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: false,
        ),
      );
      // No project yet: said honestly.
      expect(
        _inSheet(find.text('No project yet. Today decides for now.')),
        findsOneWidget,
      );

      await _tapVisible(tester, find.byKey(const ValueKey('today-pin-notes')));
      await _settle(tester);
      expect(find.byKey(const ValueKey('today-choose-sheet')), findsNothing);
      expect(h.state.settings.todayPin, TodayPin.notes);
      expect(h.store.saved!.settings.todayPin, TodayPin.notes);
      expect(_inNextStep(find.text('Write a note')), findsOneWidget);

      await _openSheet(tester);
      expect(
        tester.getSemantics(find.byKey(const ValueKey('today-pin-notes'))),
        isSemantics(
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: true,
        ),
      );
      // The reset (the app's own first step) is now one of the others.
      expect(
        _inSheet(find.text('Begin the morning reflection')),
        findsOneWidget,
      );
      await _tapVisible(tester, find.byKey(const ValueKey('today-pin-auto')));
      await _settle(tester);
      expect(h.state.settings.todayPin, TodayPin.auto);
      expect(
        _inNextStep(find.text('Begin the morning reflection')),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('dismissing the sheet changes nothing', (tester) async {
      final h = await _pumpToday(tester);
      final writes = h.store.writes;
      await _openSheet(tester);
      await tester.tapAt(const Offset(195, 40));
      await pumpFrames(tester);
      expect(find.byKey(const ValueKey('today-choose-sheet')), findsNothing);
      expect(h.store.writes, writes);
      expect(h.state.settings.todayPin, TodayPin.auto);
    });

    testWidgets('pinned "My project": the project and its next milestone', (
      tester,
    ) async {
      await _pumpToday(
        tester,
        data: inProgressData().copyWith(
          project: () => MonthProject(
            title: 'Four short essays',
            status: ProjectStatus.active,
            updatedAt: _at,
            milestones: const [
              Milestone(id: 'm1', title: 'Pick topics', done: true),
              Milestone(id: 'm2', title: 'First draft'),
            ],
          ),
          settings: const AppSettings(todayPin: TodayPin.project),
        ),
      );
      // Pinned project: a quest done today doesn't count as project work.
      expect(find.byKey(const ValueKey('today-done')), findsNothing);
      expect(_inNextStep(find.text('Work on your project')), findsOneWidget);
      expect(_inNextStep(find.text('Four short essays')), findsOneWidget);
      expect(_inNextStep(find.text('Next: First draft')), findsOneWidget);
      await _tapVisible(tester, find.text('Open the project'));
      expect(find.byType(ProjectScreen), findsOneWidget);
    });

    testWidgets('pinned "Notes": done once a note was written today', (
      tester,
    ) async {
      await _pumpToday(
        tester,
        data: inProgressData().copyWith(
          settings: const AppSettings(todayPin: TodayPin.notes),
          journal: [
            JournalEntry(id: 'n1', body: 'Today', createdAt: kTestNow),
          ],
        ),
      );
      expect(find.byKey(const ValueKey('today-done')), findsOneWidget);
      await _tapVisible(tester, find.text('One more'));
      expect(_inNextStep(find.text('Write a note')), findsOneWidget);
    });

    testWidgets('after a long absence: just the next action, no counts', (
      tester,
    ) async {
      final long = DateTime(2026, 8, 20, 9);
      await _pumpToday(
        tester,
        data: onboardedData().copyWith(
          journeys: [
            Journey(
              id: 'j',
              startedAt: long,
              activePromptId: 'morning.03',
              answers: {
                'morning.01': ReflectionAnswer(
                  promptId: 'morning.01',
                  body: 'Long ago',
                  skipped: false,
                  updatedAt: long,
                ),
              },
            ),
          ],
          currentJourneyId: () => 'j',
          quests: [
            Quest(
              id: 'old',
              title: 'Planned long ago',
              createdAt: long,
              dueDate: '2026-08-21',
            ),
          ],
        ),
      );
      expect(find.byKey(const ValueKey('today-done')), findsNothing);
      expect(_inNextStep(find.text('Planned long ago')), findsOneWidget);
      final counts = RegExp(
        r'\b\d+ (days?|weeks?)\b|since|ago|welcome back|missed',
        caseSensitive: false,
      );
      for (final text in _texts(tester)) {
        if (text == 'Planned long ago') continue; // the user's own title
        expect(counts.hasMatch(text), isFalse, reason: text);
        expect(_judgement.hasMatch(text), isFalse, reason: text);
      }
    });

    testWidgets('a failed save is shown honestly on Today', (tester) async {
      final h = await _pumpToday(tester, data: inProgressData());
      h.store.failWrites = true;
      await _tapVisible(tester, find.text(_page));
      await _settle(tester);
      expect(find.text("Your last change couldn't be saved."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('no streak, score or guilt copy in any state', (tester) async {
      for (final data in [
        onboardedData(),
        inProgressData(),
        _openQuestsData(),
        settledData(),
        _settledQuiet(),
      ]) {
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
            _openQuestsData(),
            settledData(),
            _withAvatar(inProgressData()),
            onboardedData(
              settings: const AppSettings(game: false, gameInvited: false),
            ),
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
          // The direction opened, and the sheet.
          await _pumpToday(
            tester,
            data: _openQuestsData(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await _expandDirection(tester);
          await expectNoOverflow(tester);
          final list = tester.state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(TodayTab),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
          list.position.jumpTo(0);
          await pumpFrames(tester, count: 2);
          await _openSheet(tester);
          await expectNoOverflow(tester);
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
