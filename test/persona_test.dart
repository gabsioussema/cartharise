import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/persona/persona_ops.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_content.dart';
import 'support/fakes.dart';

final _t = DateTime(2026, 11, 3, 9, 30);

Future<AppState> _loaded([AppData? data]) async {
  final state = AppState(
    store: MemoryDataStore(data ?? AppData.empty),
    content: fakeContent,
    reminders: FakeReminderScheduler(),
    clock: () => _t,
  );
  await state.load();
  return state;
}

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
}
