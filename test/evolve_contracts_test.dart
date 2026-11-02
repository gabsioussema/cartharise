// Step 1.0 contracts (docs/plans/evolve.md): settings for the invitation and
// Today's pin, attempt drafts, the Playground's experiments and notices, the
// Campaign rules for experiments and reward picks, the glyph / art / invite
// stubs, and that every new field is in the backup and cleared by "Delete
// all data".
import 'dart:convert';

import 'package:cartharise/content/en.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/campaign/campaign_invite.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/persona/persona_ops.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

final _t = DateTime(2026, 11, 3, 9, 30);
const _today = '2026-11-03';

String _two(int i) => i.toString().padLeft(2, '0');

Future<AppState> _loaded([AppData? data, MemoryDataStore? store]) async {
  final state = AppState(
    store: store ?? MemoryDataStore(data ?? AppData.empty),
    content: fakeContent,
    reminders: FakeReminderScheduler(),
    clock: () => _t,
  );
  await state.load();
  return state;
}

AppData _roundTrip(AppData data) => decodeBackup(encodeBackup(data, _t));

/// A JSON copy of [data] with [edit] applied to the encoded map.
Map<String, Object?> _json(
  AppData data,
  void Function(Map<String, Object?>) edit,
) {
  final json = jsonDecode(jsonEncode(data.toJson())) as Map<String, Object?>;
  edit(json);
  return json;
}

ExperimentEntry _tried(String id, String experimentId, {String day = _today}) =>
    ExperimentEntry(
      id: id,
      experimentId: experimentId,
      day: day,
      createdAt: _t,
    );

Journey _journeyAnswering(Iterable<String> ids) => Journey(
  id: 'j1',
  startedAt: _t,
  answers: {
    for (final id in ids)
      id: ReflectionAnswer(promptId: id, body: 'Words', updatedAt: _t),
  },
);

Quest _questDone(String id, String day) =>
    Quest(id: id, title: 'Quest $id', createdAt: _t, completedOn: {day});

CampaignProgress _at({int xp = 0, Set<Achievement> earned = const {}}) =>
    CampaignProgress(
      xp: xp,
      chapters: const [],
      earnedBy: {for (final a in earned) a: EarnedRoute.doing},
      questsCompleted: 0,
      pathDaysWritten: 0,
      attempts: 0,
    );

void main() {
  group('AppSettings: gameInvited and todayPin', () {
    test('defaults: invited (existing users), pin auto, game on', () {
      const s = AppSettings();
      expect(s.gameInvited, isTrue);
      expect(s.todayPin, TodayPin.auto);
      expect(s.game, isTrue);
      expect(AppSettings.fromJson(null).gameInvited, isTrue);
    });

    test('round-trip through a backup, every pin', () {
      for (final pin in TodayPin.values) {
        final data = AppData(
          settings: AppSettings(game: false, gameInvited: false, todayPin: pin),
        );
        final back = _roundTrip(data).settings;
        expect(back.todayPin, pin);
        expect(back.gameInvited, isFalse);
        expect(back.game, isFalse);
      }
    });

    test('older files: invited, pin auto (never see the invitation)', () {
      final json = _json(AppData.empty, (j) {
        (j['settings']! as Map)
          ..remove('gameInvited')
          ..remove('todayPin');
      });
      final s = AppData.fromJson(json).settings;
      expect(s.gameInvited, isTrue);
      expect(s.todayPin, TodayPin.auto);
    });

    test('an unknown pin falls back to auto; junk is refused', () {
      Map<String, Object?> withPin(Object? pin) => _json(AppData.empty, (j) {
        (j['settings']! as Map)['todayPin'] = pin;
      });
      expect(
        AppData.fromJson(withPin('someday')).settings.todayPin,
        TodayPin.auto,
      );
      expect(
        AppData.fromJson(withPin('notes')).settings.todayPin,
        TodayPin.notes,
      );
      expect(() => AppData.fromJson(withPin(3)), throwsFormatException);
      final badInvite = _json(AppData.empty, (j) {
        (j['settings']! as Map)['gameInvited'] = 'yes';
      });
      expect(() => AppData.fromJson(badInvite), throwsFormatException);
    });

    test('copyWith keeps or changes each', () {
      const s = AppSettings(todayPin: TodayPin.project, gameInvited: false);
      expect(s.copyWith(game: false).todayPin, TodayPin.project);
      expect(s.copyWith(game: false).gameInvited, isFalse);
      expect(s.copyWith(todayPin: TodayPin.auto).todayPin, TodayPin.auto);
      expect(s.copyWith(gameInvited: true).gameInvited, isTrue);
    });
  });

  group('onboarding asks about the game (new profiles only)', () {
    test(
      'a new profile starts with the Campaign off, invitation pending',
      () async {
        final state = await _loaded();
        await state.completeOnboarding(
          pace: Pace.flexible,
          adultConfirmed: true,
          askAboutGame: true,
        );
        expect(state.settings.game, isFalse);
        expect(state.settings.gameInvited, isFalse);
        expect(state.campaignInvitePending, isTrue);
      },
    );

    test('a replayed welcome keeps the Campaign as it was', () async {
      final state = await _loaded();
      await state.completeOnboarding(pace: Pace.flexible, adultConfirmed: true);
      expect(state.settings.game, isTrue);
      await state.resetOnboarding();
      await state.completeOnboarding(
        pace: Pace.flexible,
        adultConfirmed: true,
        askAboutGame: true,
      );
      expect(state.settings.game, isTrue);
      expect(state.settings.gameInvited, isTrue);
    });
  });

  group('the Campaign invitation', () {
    const pending = AppData(
      settings: AppSettings(game: false, gameInvited: false),
    );

    test('Play turns the Campaign on and answers it for good', () async {
      final store = MemoryDataStore(pending);
      final state = await _loaded(null, store);
      expect(state.campaignInvitePending, isTrue);
      await state.answerCampaignInvite(play: true);
      expect(state.gameEnabled, isTrue);
      expect(state.campaignInvitePending, isFalse);
      expect(store.saved!.settings.gameInvited, isTrue);
      expect(store.saved!.settings.game, isTrue);
    });

    test('Not now answers it and leaves the Campaign off', () async {
      final state = await _loaded(pending);
      await state.answerCampaignInvite(play: false);
      expect(state.gameEnabled, isFalse);
      expect(state.campaignInvitePending, isFalse);
    });
  });

  group('attempt drafts', () {
    test('round-trip exactly as typed; older data has none', () {
      final data = AppData(
        attemptDraft: AttemptDraft(
          attempt: '  Called the printer ',
          learning: 'Ask earlier\n',
          updatedAt: _t,
        ),
      );
      final back = _roundTrip(data).attemptDraft!;
      expect(back.attempt, '  Called the printer ');
      expect(back.learning, 'Ask earlier\n');
      expect(back.updatedAt.isAtSameMomentAs(_t), isTrue);
      final older = _json(AppData.empty, (j) => j.remove('attemptDraft'));
      expect(AppData.fromJson(older).attemptDraft, isNull);
      final junk = _json(AppData.empty, (j) => j['attemptDraft'] = 'draft');
      expect(() => AppData.fromJson(junk), throwsFormatException);
    });

    test('saved exactly as typed; both blank removes it', () async {
      final store = MemoryDataStore(AppData.empty);
      final state = await _loaded(null, store);
      await state.saveAttemptDraft(' Wrote ', '');
      expect(state.attemptDraft!.attempt, ' Wrote ');
      expect(state.attemptDraft!.learning, '');
      expect(store.saved!.attemptDraft!.attempt, ' Wrote ');
      await state.saveAttemptDraft('', 'only the learning');
      expect(state.attemptDraft!.learning, 'only the learning');
      await state.saveAttemptDraft('  ', '\n');
      expect(state.attemptDraft, isNull);
      expect(store.saved!.attemptDraft, isNull);
    });

    test('nothing is written when nothing changed', () async {
      final store = MemoryDataStore(AppData.empty);
      final state = await _loaded(null, store);
      await state.saveAttemptDraft('', '');
      expect(store.writes, 0);
      await state.saveAttemptDraft('Wrote', 'x');
      final writes = store.writes;
      await state.saveAttemptDraft('Wrote', 'x');
      expect(store.writes, writes);
    });

    test('recording the attempt clears the draft in the same change', () async {
      final store = MemoryDataStore(AppData.empty);
      final state = await _loaded(null, store);
      await state.saveAttemptDraft('Wrote for 25 minutes', 'Mornings');
      final writes = store.writes;
      final seen = <(int, bool)>[];
      void listen() => seen.add((
        state.data.campaignLog.length,
        state.data.attemptDraft == null,
      ));
      state.addListener(listen);
      await state.recordAttempt('Wrote for 25 minutes', learning: 'Mornings');
      state.removeListener(listen);
      expect(store.writes, writes + 1, reason: 'one write');
      expect(store.saved!.campaignLog.single.attempt, 'Wrote for 25 minutes');
      expect(store.saved!.attemptDraft, isNull);
      // Never a moment with the attempt recorded and the draft still there.
      expect(seen, everyElement((1, true)));
    });

    test('a blank attempt is refused and the draft is kept', () async {
      final state = await _loaded();
      await state.saveAttemptDraft('   ', 'learned');
      expect(() => state.recordAttempt('   '), throwsArgumentError);
      expect(state.attemptDraft!.learning, 'learned');
    });
  });

  group('content: experiments and notices', () {
    test(
      'the fake library has two experiments per chapter and two notices',
      () {
        for (final chapter in CampaignChapter.values) {
          expect(fakeContent.experimentsFor(chapter).map((e) => e.id), [
            'try.${chapter.name}.01',
            'try.${chapter.name}.02',
          ]);
        }
        expect(
          fakeContent.experiment('try.plan.02')!.chapter,
          CampaignChapter.plan,
        );
        expect(fakeContent.experiment('try.nowhere.01'), isNull);
        expect(fakeContent.notice('notice.01')!.promptId, 'morning.01');
        expect(fakeContent.notice('notice.02')!.lessonId, 'lesson.01');
        expect(fakeContent.notice('notice.99'), isNull);
      },
    );

    test('a library without them has none (older constructors)', () {
      final bare = ContentLibrary(
        languageCode: 'en',
        version: 1,
        lessons: const [],
        prompts: const [],
        thirtyDays: const [],
        credit: fakeContent.credit,
      );
      expect(bare.experiments, isEmpty);
      expect(bare.notices, isEmpty);
    });

    test('a notice opens exactly one prompt or lesson', () {
      final id = 'notice.${_two(9)}';
      expect(
        () => Notice(
          id: id,
          glyph: CarthaGlyph.notice,
          title: 'Both',
          promptId: 'morning.01',
          lessonId: 'lesson.01',
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Notice(id: id, glyph: CarthaGlyph.notice, title: 'Neither'),
        throwsA(isA<AssertionError>()),
      );
    });

    for (final (name, library) in [
      ('English', englishContent),
      ('fake', fakeContent),
    ]) {
      test('$name: ids permanent-shaped, unique; 1–3 steps; real targets', () {
        final ids = <String>{};
        for (final e in library.experiments) {
          expect(
            RegExp(r'^try\.([a-z]+)\.(\d+)$').firstMatch(e.id)?.group(1),
            e.chapter.name,
            reason: e.id,
          );
          expect(ids.add(e.id), isTrue, reason: 'duplicate ${e.id}');
          expect(e.title.trim(), isNotEmpty, reason: e.id);
          expect(e.steps.length, inInclusiveRange(1, 3), reason: e.id);
          for (final step in e.steps) {
            expect(step.trim(), isNotEmpty, reason: e.id);
          }
          expect(e.minutes, greaterThan(0), reason: e.id);
        }
        for (final n in library.notices) {
          expect(RegExp(r'^notice\.\d+$').hasMatch(n.id), isTrue, reason: n.id);
          expect(ids.add(n.id), isTrue, reason: 'duplicate ${n.id}');
          expect(n.title.trim(), isNotEmpty, reason: n.id);
          final opens = n.promptId != null
              ? library.prompt(n.promptId!)
              : library.lesson(n.lessonId!);
          expect(opens, isNotNull, reason: '${n.id} opens nothing');
        }
      });
    }
  });

  group('the experiment log', () {
    test('round-trips exactly as typed; older data has none; junk refused', () {
      final data = AppData(
        experimentLog: [
          ExperimentEntry(
            id: 'e1',
            experimentId: 'try.terrain.01',
            day: _today,
            note: '  Saw the cracked tile \n',
            createdAt: _t,
            editedAt: _t.add(const Duration(hours: 1)),
          ),
          _tried('e2', 'try.plan.01', day: '2026-11-01'),
        ],
      );
      final back = _roundTrip(data).experimentLog;
      expect(back.map((e) => e.id), ['e1', 'e2']);
      expect(back.first.note, '  Saw the cracked tile \n');
      expect(back.first.editedAt, isNotNull);
      expect(back.last.note, '');
      expect(back.last.editedAt, isNull);
      final older = _json(AppData.empty, (j) => j.remove('experimentLog'));
      expect(AppData.fromJson(older).experimentLog, isEmpty);
      for (final bad in [
        {
          'id': 'x',
          'experimentId': 'try.plan.01',
          'day': 'today',
          'createdAt': '2026-11-03T09:00:00Z',
        },
        {'id': 'x', 'day': _today, 'createdAt': '2026-11-03T09:00:00Z'},
      ]) {
        final json = _json(AppData.empty, (j) => j['experimentLog'] = [bad]);
        expect(() => AppData.fromJson(json), throwsFormatException);
      }
    });

    test('try, edit and delete; newest first; note exactly as typed', () async {
      final store = MemoryDataStore(AppData.empty);
      final state = await _loaded(null, store);
      final first = await state.tryExperiment('try.terrain.01');
      final second = await state.tryExperiment(
        'try.pattern.01',
        note: ' Noticed it twice ',
      );
      expect(first.day, _today);
      expect(first.note, '');
      expect(state.experimentLog.map((e) => e.id), [second.id, first.id]);
      expect(store.saved!.experimentLog.first.note, ' Noticed it twice ');
      expect(state.hasTried('try.terrain.01'), isTrue);
      expect(state.hasTried('try.banner.01'), isFalse);

      await state.editExperimentEntry(first.id, note: 'Took 3 minutes');
      final edited = state.experimentLog.last;
      expect(edited.note, 'Took 3 minutes');
      expect(edited.day, first.day);
      expect(edited.editedAt, isNotNull);

      await state.deleteExperimentEntry(second.id);
      expect(state.experimentLog.single.id, first.id);
    });

    test('an unknown experiment is refused and nothing is written', () async {
      final store = MemoryDataStore(AppData.empty);
      final state = await _loaded(null, store);
      expect(() => state.tryExperiment('try.nowhere.01'), throwsArgumentError);
      expect(
        () => state.addExperimentToTasks('try.nowhere.01'),
        throwsArgumentError,
      );
      expect(state.experimentLog, isEmpty);
      expect(store.writes, 0);
    });

    test('"Add to my tasks": one quest from the experiment, no duplicate '
        'while open, no XP by itself', () async {
      final state = await _loaded();
      final quest = await state.addExperimentToTasks('try.banner.02');
      expect(quest.source, QuestSource.experiment);
      expect(quest.title, fakeContent.experiment('try.banner.02')!.title);
      expect(quest.recurrence, QuestRecurrence.none);
      expect(state.campaign.xp, 0);
      expect(state.experimentLog, isEmpty, reason: 'adding is not trying');

      final again = await state.addExperimentToTasks('try.banner.02');
      expect(again.id, quest.id);
      expect(state.data.quests, hasLength(1));

      await state.setQuestDone(quest.id, true);
      final next = await state.addExperimentToTasks('try.banner.02');
      expect(next.id, isNot(quest.id));
      expect(state.data.quests, hasLength(2));
    });

    test('the experiment source round-trips; appended, never renamed', () {
      expect(QuestSource.values.last, QuestSource.experiment);
      final back = _roundTrip(
        AppData(
          quests: [
            Quest(
              id: 'q',
              title: 'Try it',
              createdAt: _t,
              source: QuestSource.experiment,
            ),
          ],
        ),
      );
      expect(back.quests.single.source, QuestSource.experiment);
    });
  });

  group('Campaign rules: experiments', () {
    test('+10 XP per distinct experiment, once each, as action XP', () {
      expect(kXpPerExperiment, 10);
      final once = campaignProgress(
        AppData(experimentLog: [_tried('a', 'try.terrain.01')]),
        fakeContent,
      );
      expect(once.xp, kXpPerExperiment);
      expect(once.xpFromActions, kXpPerExperiment);
      expect(once.experimentsTried, 1);

      final repeated = campaignProgress(
        AppData(
          experimentLog: [
            _tried('a', 'try.terrain.01'),
            _tried('b', 'try.terrain.01', day: '2026-11-04'),
            _tried('c', 'try.terrain.01', day: '2026-11-05'),
          ],
        ),
        fakeContent,
      );
      expect(repeated.xp, kXpPerExperiment, reason: 'never farmed');

      final two = campaignProgress(
        AppData(
          experimentLog: [
            _tried('a', 'try.terrain.01'),
            _tried('b', 'try.terrain.02'),
          ],
        ),
        fakeContent,
      );
      expect(two.xp, 2 * kXpPerExperiment);
      expect(two.chapters.first.tried, 2);
      expect(two.experimentsTried, 2);
    });

    test('the note never matters: a long note earns the same', () {
      final short = campaignProgress(
        AppData(experimentLog: [_tried('a', 'try.plan.01')]),
        fakeContent,
      );
      final long = campaignProgress(
        AppData(
          experimentLog: [
            ExperimentEntry(
              id: 'a',
              experimentId: 'try.plan.01',
              day: _today,
              note: 'So much to say. ' * 100,
              createdAt: _t,
            ),
          ],
        ),
        fakeContent,
      );
      expect(long.xp, short.xp);
      expect(long.earnedBy, short.earnedBy);
    });

    test("a chapter's achievement by trying one of its experiments", () {
      final p = campaignProgress(
        AppData(experimentLog: [_tried('a', 'try.pattern.02')]),
        fakeContent,
      );
      expect(p.earnedBy, {Achievement.pathfinder: EarnedRoute.trying});
      expect(p.earned, {Achievement.pathfinder});
      expect(p.chapters[1].explored, isFalse, reason: 'nothing answered');
    });

    test('… or by reflecting (named when both are true)', () {
      final ids = CampaignChapter.terrain.promptIds(fakeContent);
      final reflected = campaignProgress(
        AppData(journeys: [_journeyAnswering(ids)], currentJourneyId: 'j1'),
        fakeContent,
      );
      expect(reflected.earnedBy, {
        Achievement.observer: EarnedRoute.reflecting,
      });
      final both = campaignProgress(
        AppData(
          journeys: [_journeyAnswering(ids)],
          currentJourneyId: 'j1',
          experimentLog: [_tried('a', 'try.terrain.01')],
        ),
        fakeContent,
      );
      expect(both.earnedBy[Achievement.observer], EarnedRoute.reflecting);
      // Answered is answered; skipped stays honestly distinct.
      final skipped = campaignProgress(
        AppData(
          journeys: [
            Journey(
              id: 'j1',
              startedAt: _t,
              answers: {
                for (final id in ids)
                  id: ReflectionAnswer(
                    promptId: id,
                    skipped: true,
                    updatedAt: _t,
                  ),
              },
            ),
          ],
          currentJourneyId: 'j1',
        ),
        fakeContent,
      );
      expect(skipped.earnedBy, isEmpty);
    });

    test('the Practitioner and the Challenger are earned by doing', () {
      final p = campaignProgress(
        AppData(
          quests: [_questDone('q', _today)],
          campaignLog: [
            BattleLogEntry(id: 'a', day: _today, attempt: 'x', createdAt: _t),
          ],
        ),
        fakeContent,
      );
      expect(p.earnedBy, {
        Achievement.practitioner: EarnedRoute.doing,
        Achievement.challenger: EarnedRoute.doing,
      });
    });

    test(
      'an unknown experiment id still counts its XP, not an achievement',
      () {
        // From a newer version's backup: the record is kept and counted once.
        final p = campaignProgress(
          AppData(experimentLog: [_tried('a', 'try.future.01')]),
          fakeContent,
        );
        expect(p.xp, kXpPerExperiment);
        expect(p.earnedBy, isEmpty);
      },
    );

    test('each chapter achievement names its chapter', () {
      for (final chapter in CampaignChapter.values) {
        expect(Achievement.ofChapter(chapter).chapter, chapter);
      }
      expect(Achievement.practitioner.chapter, isNull);
      expect(Achievement.challenger.chapter, isNull);
    });
  });

  group('reward picks', () {
    test('earned: route stops after Carthage + achievements', () {
      expect(rewardPicksEarned(_at()), 0);
      // Level 3 (the Ebro: two stops after Carthage) and two achievements.
      expect(
        rewardPicksEarned(
          _at(xp: 250, earned: {Achievement.observer, Achievement.challenger}),
        ),
        4,
      );
      expect(
        rewardPicksEarned(_at(xp: 900, earned: Achievement.values.toSet())),
        Unlockable.values.length,
      );
    });

    test('left = max(0, earned − kept)', () {
      final three = _at(xp: 250, earned: {Achievement.observer});
      expect(rewardPicksLeft(three, const {}), 3);
      expect(rewardPicksLeft(three, {Unlockable.sigilPath}), 2);
      expect(
        rewardPicksLeft(three, {
          Unlockable.sigilPath,
          Unlockable.garmentSage,
          Unlockable.accessoryScroll,
          Unlockable.headwearLaurel,
          Unlockable.sigilStar,
        }),
        0,
      );
    });

    test('the suggested extra comes first; owned ones are not offered', () {
      final ebro = _at(xp: 250);
      expect(suggestedReward(ebro, const {}), Unlockable.sigilPath);
      expect(
        suggestedReward(ebro, {Unlockable.sigilPath}),
        Unlockable.garmentSage,
      );
      // Every reached milestone's extra owned: the first free one in order.
      expect(
        suggestedReward(ebro, {Unlockable.sigilPath, Unlockable.garmentSage}),
        Unlockable.headwearCirclet,
      );
      final options = rewardOptions(ebro, {Unlockable.sigilPath});
      expect(options.first, Unlockable.garmentSage);
      expect(
        options.toSet(),
        Unlockable.values.toSet()..remove(Unlockable.sigilPath),
      );
      expect(options, hasLength(Unlockable.values.length - 1));
      expect(suggestedReward(ebro, Unlockable.values.toSet()), isNull);
      expect(rewardOptions(ebro, Unlockable.values.toSet()), isEmpty);
    });

    test('choose a reward: kept for good, a pick spent', () async {
      final store = MemoryDataStore(AppData(quests: [_questDone('q', _today)]));
      final state = await _loaded(null, store);
      expect(state.picksEarned, 1);
      expect(state.picksLeft, 1);
      expect(state.suggestedPick, Unlockable.garmentBronze);
      expect(state.rewardChoices.first, Unlockable.garmentBronze);
      expect(state.canUse(GarmentColor.bronze), isFalse, reason: 'locked');

      await state.chooseReward(Unlockable.sigilStar);
      expect(state.picksLeft, 0);
      expect(state.canUse(Sigil.star), isTrue);
      expect(store.saved!.avatarUnlocked, {Unlockable.sigilStar});
      expect(state.rewardChoices, isNot(contains(Unlockable.sigilStar)));
      expect(state.canUse(GarmentColor.bronze), isFalse);
    });

    test('refused: no pick left, already owned, game off', () async {
      final state = await _loaded(
        AppData(
          quests: [_questDone('q', _today)],
          persona: Persona(
            avatar: const Avatar(sigil: Sigil.star),
            updatedAt: _t,
          ),
        ),
      );
      expect(
        () => state.chooseReward(Unlockable.sigilStar),
        throwsArgumentError,
        reason: 'worn: already the user\'s',
      );
      await state.chooseReward(Unlockable.garmentBronze);
      expect(
        () => state.chooseReward(Unlockable.sigilPath),
        throwsStateError,
        reason: 'no pick left',
      );
      await state.setGameEnabled(false);
      expect(
        () => state.chooseReward(Unlockable.sigilPath),
        throwsStateError,
        reason: 'game off: everything is open anyway',
      );
      expect(state.data.avatarUnlocked, {Unlockable.garmentBronze});
    });

    test('nothing kept is ever taken away', () async {
      final state = await _loaded(AppData(quests: [_questDone('q', _today)]));
      await state.chooseReward(Unlockable.headwearLaurel);
      await state.setQuestDone('q', false);
      await state.deleteQuest('q');
      expect(state.picksEarned, 0);
      expect(state.picksLeft, 0);
      expect(state.canUse(Headwear.laurel), isTrue);
      await state.setGameEnabled(false);
      await state.setGameEnabled(true);
      expect(state.canUse(Headwear.laurel), isTrue);
      expect(state.data.avatarUnlocked, {Unlockable.headwearLaurel});
    });

    test('game off opens everything; no picks to spend', () async {
      final state = await _loaded(
        AppData(
          settings: const AppSettings(game: false),
          quests: [_questDone('q', _today)],
        ),
      );
      expect(state.avatarUnlocks, Unlockable.values.toSet());
      for (final u in Unlockable.values) {
        expect(state.ownsExtra(u), isTrue, reason: '$u');
      }
      expect(state.canUse(Headwear.laurel), isTrue);
      expect(state.picksLeft, 0);
      expect(state.rewardChoices, isEmpty);
      expect(state.suggestedPick, isNull);
    });

    test('mutate and load no longer open extras by themselves', () async {
      final store = MemoryDataStore(
        AppData(
          quests: [
            for (var d = 1; d <= 10; d++)
              _questDone('oct$d', '2026-10-${_two(d)}'),
          ],
          avatarUnlocked: const {Unlockable.accessoryCompass},
        ),
      );
      final state = await _loaded(null, store);
      // Two stops and the Practitioner reached: three picks, one kept.
      expect(state.campaign.waypoint, Waypoint.ebro);
      expect(state.data.avatarUnlocked, {Unlockable.accessoryCompass});
      expect(state.picksLeft, 2);
      await state.addJournalEntry(body: 'any change');
      await state.recordAttempt('An attempt');
      expect(state.data.avatarUnlocked, {Unlockable.accessoryCompass});
      expect(store.saved!.avatarUnlocked, {Unlockable.accessoryCompass});
      expect(state.picksLeft, 3);
    });

    test('a locked extra cannot be worn; once chosen it can', () async {
      final state = await _loaded(AppData(quests: [_questDone('q', _today)]));
      const laurel = Avatar(headwear: Headwear.laurel);
      expect(() => state.savePersona(laurel), throwsArgumentError);
      expect(state.persona, isNull);
      await state.chooseReward(Unlockable.headwearLaurel);
      await state.savePersona(laurel);
      expect(state.persona!.avatar.headwear, Headwear.laurel);
    });
  });

  group('backup and "Delete all data" carry every new field', () {
    test('export → delete all → import', () async {
      final store = MemoryDataStore(
        AppData(
          settings: const AppSettings(
            game: true,
            gameInvited: false,
            todayPin: TodayPin.reflection,
          ),
          quests: [_questDone('q', _today)],
        ),
      );
      final state = await _loaded(null, store);
      await state.saveAttemptDraft('Half an attempt ', '');
      await state.tryExperiment('try.autopilot.01', note: ' a note ');
      await state.chooseReward(Unlockable.garmentBronze);
      final backup = state.exportBackup();

      final decoded = decodeBackup(backup);
      expect(decoded.settings.gameInvited, isFalse);
      expect(decoded.settings.todayPin, TodayPin.reflection);
      expect(decoded.attemptDraft!.attempt, 'Half an attempt ');
      expect(decoded.experimentLog.single.note, ' a note ');
      expect(decoded.avatarUnlocked, {Unlockable.garmentBronze});

      await state.deleteAllData();
      expect(store.raw, isNull);
      expect(state.settings.gameInvited, isTrue);
      expect(state.settings.todayPin, TodayPin.auto);
      expect(state.attemptDraft, isNull);
      expect(state.experimentLog, isEmpty);
      expect(state.data.avatarUnlocked, isEmpty);

      await state.importBackup(backup);
      expect(state.settings.todayPin, TodayPin.reflection);
      expect(state.settings.gameInvited, isFalse);
      expect(state.attemptDraft!.attempt, 'Half an attempt ');
      expect(state.experimentLog.single.experimentId, 'try.autopilot.01');
      expect(state.canUse(GarmentColor.bronze), isTrue);
    });
  });

  group('stubs: glyphs, art and the invitation', () {
    for (final brightness in Brightness.values) {
      testWidgets('render with palette tokens (${brightness.name})', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: brightness,
          size: const Size(390, 2400),
          home: Scaffold(
            body: ListView(
              children: [
                for (final g in CarthaGlyph.values)
                  GlyphIcon(g, semanticLabel: 'Glyph ${g.name}'),
                const GlyphIcon(CarthaGlyph.experiment, size: 48),
                const LessonIllustration('lesson.01'),
                const LessonIllustration('lesson.07', height: 64),
                for (final a in Achievement.values) ...[
                  AchievementBadge(a, earned: true),
                  AchievementBadge(a, size: 32),
                ],
                const CampaignInviteCard(),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.bySemanticsLabel('Glyph notice'), findsOneWidget);
        expect(find.bySemanticsLabel('Glyph progress'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('lesson-illustration-lesson.07')),
          findsOneWidget,
        );
        expect(
          tester
              .getSize(
                find.byKey(const ValueKey('lesson-illustration-lesson.07')),
              )
              .height,
          64,
        );
        expect(
          find.byKey(const ValueKey('achievement-badge-observer')),
          findsNWidgets(2),
        );
        // Earned or not shows by shape too, never colour alone.
        expect(find.byIcon(Icons.military_tech), findsNWidgets(7));
        expect(find.byIcon(Icons.military_tech_outlined), findsNWidgets(7));
        // The invitation placeholder renders nothing.
        expect(tester.getSize(find.byType(CampaignInviteCard)).height, 0);
        semantics.dispose();
      });
    }
  });
}
