import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/persona/persona_ops.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_content.dart';
import 'support/fakes.dart';

final _t = DateTime(2026, 11, 3, 9, 30);

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

/// One quest done today (20 XP: the Practitioner, so Bronze opens).
Quest _questDoneToday() => Quest(
  id: 'q1',
  title: 'Walk 20 minutes',
  createdAt: _t,
  completedOn: const {'2026-11-03'},
);

/// One attempt today (the Challenger, so the Laurel banner opens).
BattleLogEntry _attemptToday() => BattleLogEntry(
  id: 'a1',
  day: '2026-11-03',
  attempt: 'Wrote for 25 minutes',
  createdAt: _t,
);

CampaignProgress _progress({int xp = 0, Set<Achievement> earned = const {}}) =>
    CampaignProgress(
      xp: xp,
      chapters: const [],
      earned: earned,
      questsCompleted: 0,
      pathDaysWritten: 0,
      attempts: 0,
    );

void main() {
  group('Avatar (inclusive by design)', () {
    test('no default skin tone: a new avatar is a silhouette', () {
      expect(const Avatar().skinTone, isNull);
    });

    test('skin tones are presented in a mixed order, every tone once', () {
      expect(kSkinTonePresentation.toSet(), SkinTone.values.toSet());
      expect(kSkinTonePresentation, isNot(SkinTone.values));
    });

    test('round-trips through a backup, including the silhouette', () {
      const avatar = Avatar(
        skinTone: SkinTone.walnut,
        hair: HairStyle.locs,
        hairColor: HairColor.grey,
        eyewear: Eyewear.round,
        mark: SkinMark.vitiligo,
        headwear: Headwear.headscarf,
        garment: Garment.cloak,
        garmentColor: GarmentColor.olive,
        accessory: Accessory.satchel,
        sigil: Sigil.sun,
      );
      for (final a in [avatar, const Avatar()]) {
        final data = AppData(
          persona: Persona(
            avatar: a,
            motto: '  Steady, not fast  ',
            updatedAt: _t,
          ),
        );
        final back = decodeBackup(encodeBackup(data, _t)).persona!;
        expect(back.avatar, a);
        expect(back.motto, '  Steady, not fast  ');
      }
    });

    test('unknown parts from a newer version fall back, never fail', () {
      final a = Avatar.fromJson({'hair': 'mohawk', 'skinTone': 'teal'});
      expect(a.hair, const Avatar().hair);
      expect(a.skinTone, isNull);
    });

    test('older data without a persona loads with none', () {
      final json = AppData.empty.toJson()..remove('persona');
      expect(AppData.fromJson(json).persona, isNull);
    });

    test('kept extras round-trip through a backup; older data has none', () {
      final data = AppData(
        avatarUnlocked: {Unlockable.sigilLaurel, Unlockable.garmentBronze},
      );
      expect(decodeBackup(encodeBackup(data, _t)).avatarUnlocked, {
        Unlockable.sigilLaurel,
        Unlockable.garmentBronze,
      });
      final older = AppData.empty.toJson()..remove('avatarUnlocked');
      expect(AppData.fromJson(older).avatarUnlocked, isEmpty);
    });

    test('kept extras from a newer version are left out; junk is refused', () {
      final json = AppData.empty.toJson()
        ..['avatarUnlocked'] = ['sigilStar', 'cape'];
      expect(AppData.fromJson(json).avatarUnlocked, {Unlockable.sigilStar});
      json['avatarUnlocked'] = [42];
      expect(() => AppData.fromJson(json), throwsFormatException);
      json['avatarUnlocked'] = 'sigilStar';
      expect(() => AppData.fromJson(json), throwsFormatException);
    });
  });

  group('unlocks', () {
    test('appearance is always free; only decorative extras unlock', () {
      for (final free in [
        ...SkinTone.values,
        ...HairStyle.values,
        ...HairColor.values,
        ...FacialHair.values,
        ...Eyewear.values,
        ...SkinMark.values,
        ...Expression.values,
        ...FaceShape.values,
        ...Garment.values,
        Headwear.headscarf,
        Headwear.turban,
        Headwear.hood,
      ]) {
        expect(requirementOf(free), isNull, reason: '$free');
      }
      final locked = [
        for (final e in [
          ...Headwear.values,
          ...GarmentColor.values,
          ...Accessory.values,
          ...Sigil.values,
        ])
          if (requirementOf(e) != null) e,
      ];
      expect(locked, hasLength(Unlockable.values.length));
    });

    test('each unlock has exactly one source', () {
      for (final u in Unlockable.values) {
        final s = unlockSource(u);
        expect((s.waypoint == null) != (s.achievement == null), isTrue);
      }
    });

    test('route stops and achievements open their items', () {
      expect(unlockedBy(_progress(), gameOn: true), isEmpty);
      final alps = unlockedBy(_progress(xp: 550), gameOn: true);
      expect(alps, containsAll([Unlockable.sigilPath, Unlockable.sigilStar]));
      expect(alps, isNot(contains(Unlockable.headwearLaurel)));
      expect(
        unlockedBy(_progress(earned: {Achievement.strategist}), gameOn: true),
        {Unlockable.accessoryAmulet},
      );
    });

    test('with the game layer off, everything is open', () {
      expect(unlockedBy(_progress(), gameOn: false), Unlockable.values.toSet());
    });
  });

  group('state', () {
    test('save, edit and clear; motto kept exactly as typed', () async {
      final state = await _loaded();
      expect(state.persona, isNull);
      await state.savePersona(
        const Avatar(skinTone: SkinTone.honey),
        motto: ' One step ',
      );
      expect(state.persona!.avatar.skinTone, SkinTone.honey);
      expect(state.persona!.motto, ' One step ');
      expect(state.persona!.updatedAt, _t);
      await state.clearPersona();
      expect(state.persona, isNull);
    });

    test('a motto over the limit is refused', () async {
      final state = await _loaded();
      expect(
        () => state.savePersona(const Avatar(), motto: 'x' * 61),
        throwsArgumentError,
      );
    });

    test('a worn item is never taken away', () async {
      final state = await _loaded(
        AppData(
          settings: const AppSettings(game: false),
          persona: Persona(
            avatar: const Avatar(headwear: Headwear.laurel),
            updatedAt: _t,
          ),
        ),
      );
      expect(state.canUse(Headwear.laurel), isTrue);
      // Turning the game on (no progress) keeps what is already worn.
      await state.updateSettings(state.settings.copyWith(game: true));
      expect(state.canUse(Headwear.laurel), isTrue);
      expect(state.canUse(Headwear.circlet), isFalse);
      expect(state.canUse(Headwear.headscarf), isTrue);
    });
  });

  group('extras are kept for good (nothing unlocked is taken away)', () {
    test('withProgressUnlocks: only grows, only with the game layer on', () {
      final done = AppData(quests: [_questDoneToday()]);
      final kept = withProgressUnlocks(done, fakeContent);
      expect(kept.avatarUnlocked, {Unlockable.garmentBronze});
      // Progress down: nothing is removed.
      final undone = withProgressUnlocks(
        kept.copyWith(quests: const []),
        fakeContent,
      );
      expect(undone.avatarUnlocked, {Unlockable.garmentBronze});
      // Nothing new: the same data back.
      expect(
        identical(withProgressUnlocks(undone, fakeContent), undone),
        isTrue,
      );
      // Game off: nothing is added (everything is open anyway).
      final off = done.copyWith(settings: const AppSettings(game: false));
      expect(withProgressUnlocks(off, fakeContent).avatarUnlocked, isEmpty);
    });

    test('unticking the quest keeps Bronze open, on disk too', () async {
      final store = MemoryDataStore(AppData.empty);
      final state = await _loaded(null, store);
      final quest = await state.addQuest('Walk 20 minutes');
      await state.setQuestDone(quest.id, true);
      expect(state.campaign.earned, contains(Achievement.practitioner));
      expect(state.canUse(GarmentColor.bronze), isTrue);

      await state.setQuestDone(quest.id, false);
      expect(state.campaign.earned, isEmpty, reason: 'records are records');
      expect(state.avatarUnlocks, contains(Unlockable.garmentBronze));
      expect(state.canUse(GarmentColor.bronze), isTrue);
      await state.deleteQuest(quest.id);
      expect(state.canUse(GarmentColor.bronze), isTrue);
      expect(store.saved!.avatarUnlocked, contains(Unlockable.garmentBronze));
    });

    test('deleting the last attempt keeps the Laurel banner open', () async {
      final state = await _loaded();
      final entry = await state.recordAttempt('Wrote for 25 minutes');
      expect(state.canUse(Sigil.laurel), isTrue);
      await state.deleteAttempt(entry.id);
      expect(state.campaign.earned, isNot(contains(Achievement.challenger)));
      expect(state.canUse(Sigil.laurel), isTrue);
    });

    test('dropping below a route stop keeps its extra open', () async {
      final state = await _loaded(
        AppData(
          quests: [
            for (var d = 1; d <= 5; d++)
              Quest(
                id: 'oct$d',
                title: 'October $d',
                createdAt: _t,
                completedOn: {'2026-10-0$d'},
              ),
          ],
        ),
      );
      expect(state.campaign.waypoint, Waypoint.newCarthage);
      await state.deleteQuest('oct5');
      expect(state.campaign.waypoint, Waypoint.carthage);
      expect(state.canUse(Sigil.path), isTrue);
    });

    test(
      'progress from before this version is kept from the first load',
      () async {
        // Saved without a kept set: what the records open is kept on load.
        final state = await _loaded(
          AppData(quests: [_questDoneToday()], campaignLog: [_attemptToday()]),
        );
        await state.setQuestDone('q1', false);
        await state.deleteAttempt('a1');
        expect(state.canUse(GarmentColor.bronze), isTrue);
        expect(state.canUse(Sigil.laurel), isTrue);
      },
    );

    test('with the game layer off nothing is kept by progress', () async {
      final state = await _loaded(
        const AppData(settings: AppSettings(game: false)),
      );
      final quest = await state.addQuest('Walk 20 minutes');
      await state.setQuestDone(quest.id, true);
      expect(state.data.avatarUnlocked, isEmpty);
      await state.setQuestDone(quest.id, false);
      await state.updateSettings(state.settings.copyWith(game: true));
      expect(state.canUse(GarmentColor.bronze), isFalse);
    });

    test("a worn extra stays the user's after changing the look", () async {
      // Worn while the game layer was off, then the game turned on.
      final state = await _loaded(
        AppData(
          persona: Persona(
            avatar: const Avatar(headwear: Headwear.laurel),
            updatedAt: _t,
          ),
        ),
      );
      expect(state.avatarUnlocks, isEmpty);
      expect(state.canUse(Headwear.laurel), isTrue, reason: 'worn');
      await state.savePersona(const Avatar(headwear: Headwear.hood));
      expect(state.canUse(Headwear.laurel), isTrue, reason: 'kept');
      expect(state.data.avatarUnlocked, {Unlockable.headwearLaurel});
      expect(state.canUse(Headwear.circlet), isFalse);
    });

    test('removing the avatar keeps what it wore', () async {
      final state = await _loaded(
        AppData(
          persona: Persona(
            avatar: const Avatar(sigil: Sigil.star),
            updatedAt: _t,
          ),
        ),
      );
      await state.clearPersona();
      expect(state.persona, isNull);
      expect(state.canUse(Sigil.star), isTrue);
    });

    test('in the backup; cleared by "Delete all data"', () async {
      final state = await _loaded(AppData(quests: [_questDoneToday()]));
      await state.setQuestDone('q1', false);
      final backup = state.exportBackup();
      expect(
        decodeBackup(backup).avatarUnlocked,
        contains(Unlockable.garmentBronze),
      );
      await state.deleteAllData();
      expect(state.data.avatarUnlocked, isEmpty);
      expect(state.canUse(GarmentColor.bronze), isFalse);
      await state.importBackup(backup);
      expect(state.canUse(GarmentColor.bronze), isTrue);
    });
  });
}
