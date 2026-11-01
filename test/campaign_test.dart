import 'dart:convert';
import 'dart:io';

import 'package:cartharise/content/en.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/missions/quest_tile.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_content.dart';
import 'support/fakes.dart';

final _t = DateTime(2026, 11, 3, 9, 30);

String _two(int i) => i.toString().padLeft(2, '0');

/// Answers (written, not skipped) for [ids].
Map<String, ReflectionAnswer> _answers(Iterable<String> ids) => {
  for (final id in ids)
    id: ReflectionAnswer(promptId: id, body: 'Words for $id', updatedAt: _t),
};

Journey _journey(String id, Iterable<String> answered) =>
    Journey(id: id, startedAt: _t, answers: _answers(answered));

List<String> _ids(String phase, int count) => [
  for (var i = 1; i <= count; i++) '$phase.${_two(i)}',
];

AppData _withJourney(Iterable<String> answered) =>
    AppData(journeys: [_journey('j1', answered)], currentJourneyId: 'j1');

Quest _quest(String id, Set<String> days, {bool daily = false}) => Quest(
  id: id,
  title: 'Quest $id',
  createdAt: _t,
  recurrence: daily ? QuestRecurrence.daily : QuestRecurrence.none,
  completedOn: days,
);

BattleLogEntry _attempt(String id, String day) =>
    BattleLogEntry(id: id, day: day, attempt: 'Tried $id', createdAt: _t);

void main() {
  group('chapters (F-059)', () {
    test('the article counts: 4 + 7 + 3 morning, 6 daytime, 7 evening', () {
      for (final content in [englishContent, fakeContent]) {
        final counts = [
          for (final c in CampaignChapter.values) c.promptIds(content).length,
        ];
        expect(counts, [4, 7, 3, 6, 7]);
      }
    });

    test('chapters follow the reset order and skip the bonus prompts', () {
      expect(CampaignChapter.terrain.promptIds(englishContent), [
        'morning.01',
        'morning.02',
        'morning.03',
        'morning.04',
      ]);
      expect(
        CampaignChapter.pattern.promptIds(englishContent),
        _ids('morning', 11).sublist(4),
      );
      expect(
        CampaignChapter.banner.promptIds(englishContent),
        _ids('morning', 14).sublist(11),
      );
      expect(
        CampaignChapter.autopilot.promptIds(englishContent),
        _ids('daytime', 6),
      );
      expect(
        CampaignChapter.plan.promptIds(englishContent),
        _ids('evening', 7),
      );
    });

    test('progress counts written answers in the current reset only', () {
      final data = AppData(
        journeys: [
          _journey('old', _ids('morning', 14)),
          Journey(
            id: 'now',
            startedAt: _t,
            answers: {
              ..._answers(['morning.01', 'morning.02']),
              'morning.03': ReflectionAnswer(
                promptId: 'morning.03',
                skipped: true,
                updatedAt: _t,
              ),
              'morning.04': ReflectionAnswer(
                promptId: 'morning.04',
                body: '   ',
                updatedAt: _t,
              ),
            },
          ),
        ],
        currentJourneyId: 'now',
      );
      final p = campaignProgress(data, fakeContent);
      expect(p.chapters.first.answered, 2);
      expect(p.chapters.first.explored, isFalse);
      expect(p.chaptersExplored, 0);
    });

    test('no reset yet: every chapter at zero', () {
      final p = campaignProgress(AppData.empty, fakeContent);
      expect(p.chapters.map((c) => c.answered), everyElement(0));
      expect(p.xp, 0);
      expect(p.level, 1);
      expect(p.earned, isEmpty);
    });
  });

  group('XP (F-060): participation only, never taken away for rest', () {
    test('+5 per core question answered, once per question across resets', () {
      final data = AppData(
        journeys: [
          _journey('a', ['morning.01', 'morning.02', 'bonus.01']),
          _journey('b', ['morning.01', 'evening.07']),
        ],
        currentJourneyId: 'b',
      );
      // morning.01 counts once; bonus prompts are not core.
      expect(campaignProgress(data, fakeContent).xp, 3 * kXpPerReflection);
    });

    test('skipped and blank answers earn nothing; length is irrelevant', () {
      final short = _withJourney(['morning.01']);
      final long = AppData(
        journeys: [
          Journey(
            id: 'j1',
            startedAt: _t,
            answers: {
              'morning.01': ReflectionAnswer(
                promptId: 'morning.01',
                body: 'A very long answer. ' * 200,
                updatedAt: _t,
              ),
              'morning.02': ReflectionAnswer(
                promptId: 'morning.02',
                skipped: true,
                updatedAt: _t,
              ),
            },
          ),
        ],
        currentJourneyId: 'j1',
      );
      expect(
        campaignProgress(long, fakeContent).xp,
        campaignProgress(short, fakeContent).xp,
      );
    });

    test('+20 per quest completion, counting at most 3 a day', () {
      final data = AppData(
        quests: [
          _quest('a', {'2026-11-01', '2026-11-02'}, daily: true),
          _quest('b', {'2026-11-01'}),
          _quest('c', {'2026-11-01'}),
          _quest('d', {'2026-11-01'}),
          _quest('e', {'2026-11-01'}),
        ],
      );
      final p = campaignProgress(data, fakeContent);
      // 5 completions on Nov 1 (3 count) + 1 on Nov 2.
      expect(p.xp, 4 * kXpPerQuest);
      expect(p.questsCompleted, 6);
    });

    test('+10 per written 30-day note, +15 per review week', () {
      final data = AppData(
        pathAnswers: {
          1: PathAnswer(day: 1, body: 'Noticed', updatedAt: _t),
          2: PathAnswer(day: 2, body: '  ', updatedAt: _t),
          3: PathAnswer(day: 3, body: 'Tried', updatedAt: _t),
        },
        reviews: [
          WeeklyReview(id: 'r1', weekStart: '2026-10-26', createdAt: _t),
          WeeklyReview(id: 'r2', weekStart: '2026-11-02', createdAt: _t),
          WeeklyReview(id: 'r3', weekStart: '2026-11-02', createdAt: _t),
        ],
      );
      final p = campaignProgress(data, fakeContent);
      expect(p.pathDaysWritten, 2);
      expect(p.xp, 2 * kXpPerPathDay + 2 * kXpPerReview);
    });

    test('+15 per day with an attempt, however many that day', () {
      final data = AppData(
        campaignLog: [
          _attempt('a', '2026-11-03'),
          _attempt('b', '2026-11-03'),
          _attempt('c', '2026-11-03'),
          _attempt('d', '2026-11-01'),
        ],
      );
      final p = campaignProgress(data, fakeContent);
      expect(p.xp, 2 * kXpPerAttemptDay);
      expect(p.attempts, 4);
    });

    test('levels: one every 100 XP, with progress towards the next', () {
      final data = AppData(
        quests: [
          for (var d = 1; d <= 7; d++) _quest('q$d', {'2026-11-${_two(d)}'}),
        ],
      );
      final p = campaignProgress(data, fakeContent);
      expect(p.xp, 140);
      expect(p.level, 2);
      expect(p.levelXp, 40);
    });

    test('resting adds nothing and takes nothing away', () {
      final data = _withJourney(_ids('morning', 4));
      final before = campaignProgress(data, fakeContent);
      // A new, empty reset (the user starts again) keeps earlier XP.
      final again = data.copyWith(
        journeys: [...data.journeys, _journey('j2', const [])],
        currentJourneyId: () => 'j2',
      );
      final after = campaignProgress(again, fakeContent);
      expect(after.xp, before.xp);
      expect(after.earned, before.earned);
    });
  });

  group('achievements (F-062)', () {
    test('chapter achievements need every chapter question in one reset', () {
      final p = campaignProgress(
        _withJourney([
          ..._ids('morning', 14),
          ..._ids('daytime', 6),
          ..._ids('evening', 6),
        ]),
        fakeContent,
      );
      expect(p.earned, {
        Achievement.observer,
        Achievement.pathfinder,
        Achievement.visionary,
        Achievement.watchful,
      });
      expect(p.earned, isNot(contains(Achievement.strategist)));
    });

    test('earned in an earlier reset stays earned', () {
      final data = AppData(
        journeys: [
          _journey('old', _ids('evening', 7)),
          _journey('now', const []),
        ],
        currentJourneyId: 'now',
      );
      final p = campaignProgress(data, fakeContent);
      expect(p.earned, contains(Achievement.strategist));
      expect(p.chapters.last.explored, isFalse);
    });

    test('a completed quest and a first attempt', () {
      final p = campaignProgress(
        AppData(
          quests: [
            _quest('a', {'2026-11-03'}),
          ],
          campaignLog: [_attempt('x', '2026-11-03')],
        ),
        fakeContent,
      );
      expect(p.earned, {Achievement.practitioner, Achievement.challenger});
    });
  });

  group('route, next achievement and boss', () {
    test("Hannibal's route: one stop per level, Italy from level 7 on", () {
      expect(waypointFor(1), Waypoint.carthage);
      expect(waypointFor(2), Waypoint.newCarthage);
      expect(waypointFor(6), Waypoint.alps);
      expect(waypointFor(7), Waypoint.italy);
      expect(waypointFor(40), Waypoint.italy);
      expect(Waypoint.values, hasLength(7));
    });

    test('next stop and XP to it; none once in Italy', () {
      final start = campaignProgress(AppData.empty, fakeContent);
      expect(start.waypoint, Waypoint.carthage);
      expect(start.nextWaypoint, Waypoint.newCarthage);
      expect(start.xpToNext, kXpPerLevel);

      final far = campaignProgress(
        AppData(
          quests: [
            for (var d = 1; d <= 30; d++) _quest('q$d', {'2026-10-${_two(d)}'}),
          ],
        ),
        fakeContent,
      );
      expect(far.level, 7);
      expect(far.waypoint, Waypoint.italy);
      expect(far.nextWaypoint, isNull);
    });

    test('the next achievement is the first not earned, in order', () {
      expect(
        campaignProgress(AppData.empty, fakeContent).nextAchievement,
        Achievement.observer,
      );
      final p = campaignProgress(_withJourney(_ids('morning', 4)), fakeContent);
      expect(p.nextAchievement, Achievement.pathfinder);
    });

    test('action XP counts quests, attempts and reviews, not typing', () {
      final p = campaignProgress(
        AppData(
          journeys: [_journey('j1', _ids('morning', 14))],
          currentJourneyId: 'j1',
          pathAnswers: {1: PathAnswer(day: 1, body: 'Noticed', updatedAt: _t)},
          quests: [
            _quest('a', {'2026-11-03'}),
          ],
          campaignLog: [_attempt('x', '2026-11-03')],
        ),
        fakeContent,
      );
      expect(p.xpFromActions, kXpPerQuest + kXpPerAttemptDay);
      expect(p.xp, greaterThan(p.xpFromActions));
    });

    test('the boss counts the project milestones', () {
      final p = campaignProgress(
        AppData(
          project: MonthProject(
            title: 'Essay',
            updatedAt: _t,
            milestones: const [
              Milestone(id: 'm1', title: 'Outline', done: true),
              Milestone(id: 'm2', title: 'Draft'),
              Milestone(id: 'm3', title: 'Share'),
            ],
          ),
        ),
        fakeContent,
      );
      expect(p.milestones, 3);
      expect(p.milestonesDone, 1);
    });
  });

  group('data (F-061)', () {
    test('battle log and the game setting round-trip through a backup', () {
      final data = AppData(
        settings: const AppSettings(game: false),
        campaignLog: [
          BattleLogEntry(
            id: 'a1',
            day: '2026-11-03',
            attempt: '  Sent the draft  ',
            learning: 'Short is fine.\nReally.',
            createdAt: _t,
            editedAt: _t.add(const Duration(hours: 1)),
          ),
        ],
      );
      final back = decodeBackup(encodeBackup(data, _t));
      expect(back.settings.game, isFalse);
      final e = back.campaignLog.single;
      expect(e.attempt, '  Sent the draft  ');
      expect(e.learning, 'Short is fine.\nReally.');
      expect(e.day, '2026-11-03');
      expect(e.editedAt, isNotNull);
    });

    test('older data without the Campaign loads with it on and empty', () {
      final json = AppData.empty.toJson()
        ..remove('campaignLog')
        ..['settings'] = (const AppSettings().toJson()..remove('game'));
      final data = AppData.fromJson(jsonDecode(jsonEncode(json)));
      expect(data.campaignLog, isEmpty);
      expect(data.settings.game, isTrue);
    });

    test('a malformed attempt is rejected', () {
      final json = AppData.empty.toJson()
        ..['campaignLog'] = [
          {'id': 'a', 'day': 'yesterday', 'attempt': 'x', 'createdAt': '2026'},
        ];
      expect(() => AppData.fromJson(json), throwsFormatException);
    });
  });

  group('state operations', () {
    Future<AppState> loaded([AppData? data]) async {
      final state = AppState(
        store: MemoryDataStore(data ?? AppData.empty),
        content: fakeContent,
        reminders: FakeReminderScheduler(),
        clock: () => _t,
      );
      await state.load();
      return state;
    }

    test('record, edit and delete an attempt; words kept as typed', () async {
      final state = await loaded();
      final entry = await state.recordAttempt(
        '  Called the printer  ',
        learning: 'Ask earlier ',
      );
      expect(state.data.campaignLog.single.attempt, '  Called the printer  ');
      expect(entry.day, '2026-11-03');
      expect(state.campaign.xp, kXpPerAttemptDay);

      await state.editAttempt(
        entry.id,
        attempt: 'Called the printer twice',
        learning: '',
      );
      final edited = state.data.campaignLog.single;
      expect(edited.attempt, 'Called the printer twice');
      expect(edited.learning, '');
      expect(edited.day, entry.day);
      expect(edited.editedAt, isNotNull);

      await state.deleteAttempt(entry.id);
      expect(state.data.campaignLog, isEmpty);
    });

    test('newest attempt first', () async {
      final state = await loaded();
      await state.recordAttempt('first');
      await state.recordAttempt('second');
      expect(state.data.campaignLog.map((e) => e.attempt), ['second', 'first']);
    });

    test('a blank attempt is refused and nothing is written', () async {
      final state = await loaded();
      expect(() => state.recordAttempt('   '), throwsArgumentError);
      expect(state.data.campaignLog, isEmpty);
    });

    test('turning the game off keeps the battle log', () async {
      final state = await loaded();
      await state.recordAttempt('kept');
      await state.setGameEnabled(false);
      expect(state.gameEnabled, isFalse);
      expect(state.data.campaignLog, hasLength(1));
      await state.setGameEnabled(true);
      expect(state.gameEnabled, isTrue);
    });

    test('the monthly boss: the Missions project, else the Compass', () async {
      final state = await loaded(
        AppData(compass: const LifeCompass(monthProject: 'Write 4 essays')),
      );
      expect(state.monthlyBoss, 'Write 4 essays');
      await state.mutate(
        (d) => d.copyWith(
          project: () => MonthProject(title: 'Launch the shop', updatedAt: _t),
        ),
      );
      expect(state.monthlyBoss, 'Launch the shop');
    });
  });

  group('avatar extras along the Campaign (persona plan C)', () {
    CampaignProgress at({int xp = 0, Set<Achievement> earned = const {}}) =>
        CampaignProgress(
          xp: xp,
          chapters: const [],
          earned: earned,
          questsCompleted: 0,
          pathDaysWritten: 0,
          attempts: 0,
        );

    test('the order: route stops along the road, then achievements', () {
      expect(kUnlockOrder, [
        Unlockable.sigilPath, // New Carthage
        Unlockable.garmentSage, // the Ebro
        Unlockable.headwearCirclet, // the Pyrenees
        Unlockable.accessoryCompass, // the Rhône
        Unlockable.sigilStar, // the Alps
        Unlockable.headwearLaurel, // Italy
        Unlockable.accessoryScroll, // The Observer
        Unlockable.sigilCompass, // The Pathfinder
        Unlockable.garmentIndigo, // The Visionary
        Unlockable.garmentCrimson, // The Watchful
        Unlockable.accessoryAmulet, // The Strategist
        Unlockable.garmentBronze, // The Practitioner
        Unlockable.sigilLaurel, // The Challenger
      ]);
      expect(kUnlockOrder.toSet(), Unlockable.values.toSet());
    });

    test('next: the first extra not open yet', () {
      expect(nextUnlock(at()), Unlockable.sigilPath);
      // At the Rhône (level 5): the Alps' star is next.
      expect(nextUnlock(at(xp: 420)), Unlockable.sigilStar);
      // In Italy every stop is open: the achievements follow, in order,
      // skipping those already earned.
      expect(nextUnlock(at(xp: 600)), Unlockable.accessoryScroll);
      expect(
        nextUnlock(
          at(xp: 600, earned: {Achievement.observer, Achievement.practitioner}),
        ),
        Unlockable.sigilCompass,
      );
      // An earned achievement before the road is walked changes nothing on
      // the road.
      expect(
        nextUnlock(at(earned: {Achievement.observer})),
        Unlockable.sigilPath,
      );
    });

    test('next skips what the avatar already wears (never taken away)', () {
      expect(
        nextUnlock(at(), owned: {Unlockable.sigilPath, Unlockable.garmentSage}),
        Unlockable.headwearCirclet,
      );
    });

    test('none once everything is open', () {
      final all = at(xp: 600, earned: Achievement.values.toSet());
      expect(unlockedBy(all, gameOn: true), Unlockable.values.toSet());
      expect(nextUnlock(all), isNull);
      expect(nextUnlock(at(xp: 600), owned: Unlockable.values.toSet()), isNull);
    });

    test('reaching a stop or earning an achievement only ever adds', () {
      var before = unlockedBy(at(), gameOn: true);
      for (var xp = 0; xp <= 700; xp += 20) {
        final now = unlockedBy(at(xp: xp), gameOn: true);
        expect(now.containsAll(before), isTrue, reason: '$xp XP');
        before = now;
      }
    });
  });

  group('quest XP preview (persona plan C)', () {
    test('counts each quest once on the day, as the XP rules do', () {
      final quests = [
        _quest('a', {'2026-11-03', '2026-11-02'}, daily: true),
        _quest('b', {'2026-11-03'}),
        _quest('c', {'2026-11-01'}),
        _quest('d', const {}),
      ];
      expect(questsDoneOn(quests, '2026-11-03'), 2);
      expect(questsDoneOn(quests, '2026-11-02'), 1);
      expect(questsDoneOn(quests, '2026-11-04'), 0);
    });

    Future<AppState> loaded(AppData data) async {
      final state = AppState(
        store: MemoryDataStore(data),
        content: fakeContent,
        reminders: FakeReminderScheduler(),
        clock: () => _t,
      );
      await state.load();
      return state;
    }

    test('open while the game is on and fewer than 3 are done today', () async {
      final two = [
        _quest('a', {'2026-11-03'}),
        _quest('b', {'2026-11-03'}),
        _quest('c', const {}),
      ];
      final state = await loaded(AppData(quests: two));
      expect(questXpOpenOn(state, '2026-11-03'), isTrue);
      // A third completion is the last that counts today.
      await state.setQuestDone('c', true, day: '2026-11-03');
      expect(questsDoneOn(state.data.quests, '2026-11-03'), kQuestDaysCap);
      expect(questXpOpenOn(state, '2026-11-03'), isFalse);
      // Another day starts open again.
      expect(questXpOpenOn(state, '2026-11-04'), isTrue);
      // Nothing to preview with the game layer off.
      await state.setGameEnabled(false);
      expect(questXpOpenOn(state, '2026-11-04'), isFalse);
    });
  });

  test('Campaign copy never judges (F-031, F-060)', () {
    final guilt = RegExp(
      r'streak|missed|points|score|fail|behind|lazy|overdue|should have|'
      r'you must|you fixed your life|punish',
      caseSensitive: false,
    );
    final arb = jsonDecode(
      File('l10n_src/campaign_en.arb').readAsStringSync(),
    ) as Map<String, Object?>;
    for (final MapEntry(:key, :value) in arb.entries) {
      if (key.startsWith('@') || value is! String) continue;
      expect(guilt.hasMatch(value), isFalse, reason: '$key: $value');
    }
  });
}
