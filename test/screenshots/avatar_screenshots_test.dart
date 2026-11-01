// Renders the avatar portrait gallery to PNGs for design review (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

/// A varied cast: every hair style once, mixed skin tones, colours and
/// garments, so a single sheet shows how the parts get along.
const _cast = <(String, Avatar)>[
  (
    'bald',
    Avatar(
      skinTone: SkinTone.umber,
      hair: HairStyle.bald,
      facialHair: FacialHair.beard,
      hairColor: HairColor.grey,
      garment: Garment.cloak,
      garmentColor: GarmentColor.crimson,
    ),
  ),
  (
    'buzz',
    Avatar(
      skinTone: SkinTone.honey,
      face: FaceShape.square,
      hair: HairStyle.buzz,
      hairColor: HairColor.darkBrown,
      garmentColor: GarmentColor.olive,
      accessory: Accessory.satchel,
    ),
  ),
  (
    'short',
    Avatar(
      skinTone: SkinTone.sand,
      hair: HairStyle.short,
      hairColor: HairColor.brown,
      eyewear: Eyewear.round,
      garment: Garment.robe,
      garmentColor: GarmentColor.indigo,
    ),
  ),
  (
    'wavy',
    Avatar(
      skinTone: SkinTone.clay,
      face: FaceShape.round,
      hair: HairStyle.wavy,
      hairColor: HairColor.auburn,
      expression: Expression.smile,
      mark: SkinMark.freckles,
      garmentColor: GarmentColor.sage,
    ),
  ),
  (
    'curly',
    Avatar(
      skinTone: SkinTone.copper,
      hair: HairStyle.curly,
      hairColor: HairColor.black,
      garment: Garment.wrap,
      garmentColor: GarmentColor.ivory,
      accessory: Accessory.amulet,
    ),
  ),
  (
    'coily',
    Avatar(
      skinTone: SkinTone.ebony,
      hair: HairStyle.coily,
      hairColor: HairColor.black,
      expression: Expression.focused,
      garmentColor: GarmentColor.bronze,
      sigil: Sigil.sun,
    ),
  ),
  (
    'afro',
    Avatar(
      skinTone: SkinTone.walnut,
      face: FaceShape.round,
      hair: HairStyle.afro,
      hairColor: HairColor.darkBrown,
      expression: Expression.smile,
      garment: Garment.robe,
      garmentColor: GarmentColor.forest,
    ),
  ),
  (
    'locs',
    Avatar(
      skinTone: SkinTone.chestnut,
      face: FaceShape.long,
      hair: HairStyle.locs,
      hairColor: HairColor.black,
      facialHair: FacialHair.moustache,
      garment: Garment.cloak,
      garmentColor: GarmentColor.olive,
      sigil: Sigil.compass,
    ),
  ),
  (
    'braids',
    Avatar(
      skinTone: SkinTone.umber,
      hair: HairStyle.braids,
      hairColor: HairColor.black,
      eyewear: Eyewear.square,
      garmentColor: GarmentColor.crimson,
      accessory: Accessory.compass,
    ),
  ),
  (
    'bun',
    Avatar(
      skinTone: SkinTone.honey,
      hair: HairStyle.bun,
      hairColor: HairColor.black,
      mark: SkinMark.beautyMark,
      garment: Garment.wrap,
      garmentColor: GarmentColor.sand,
      sigil: Sigil.star,
    ),
  ),
  (
    'long',
    Avatar(
      skinTone: SkinTone.sand,
      face: FaceShape.long,
      hair: HairStyle.long,
      hairColor: HairColor.blonde,
      garmentColor: GarmentColor.indigo,
      accessory: Accessory.scroll,
      sigil: Sigil.laurel,
    ),
  ),
  (
    'ponytail',
    Avatar(
      skinTone: SkinTone.copper,
      hair: HairStyle.ponytail,
      hairColor: HairColor.copper,
      mark: SkinMark.vitiligo,
      garmentColor: GarmentColor.sage,
      sigil: Sigil.path,
    ),
  ),
];

const _base = Avatar(
  skinTone: SkinTone.clay,
  hair: HairStyle.short,
  hairColor: HairColor.darkBrown,
);

List<(String, Avatar)> _parts() => [
  for (final v in FaceShape.values) ('face ${v.name}', _base.copyWith(face: v)),
  for (final v in FacialHair.values)
    ('facial ${v.name}', _base.copyWith(facialHair: v)),
  for (final v in Eyewear.values)
    ('glasses ${v.name}', _base.copyWith(eyewear: v)),
  for (final v in SkinMark.values)
    (
      'mark ${v.name}',
      _base.copyWith(mark: v, skinTone: () => SkinTone.walnut),
    ),
  for (final v in Expression.values)
    ('expr ${v.name}', _base.copyWith(expression: v)),
  for (final v in Headwear.values)
    ('head ${v.name}', _base.copyWith(headwear: v)),
  for (final v in Garment.values)
    ('garment ${v.name}', _base.copyWith(garment: v)),
  for (final v in Accessory.values)
    ('carry ${v.name}', _base.copyWith(accessory: v)),
  for (final v in Sigil.values) ('sigil ${v.name}', _base.copyWith(sigil: v)),
];

List<(String, Avatar)> _colours() => [
  for (final t in kSkinTonePresentation)
    (t.name, _base.copyWith(skinTone: () => t)),
  for (final c in HairColor.values)
    ('hair ${c.name}', _base.copyWith(hairColor: c, hair: HairStyle.wavy)),
  for (final c in GarmentColor.values)
    (c.name, _base.copyWith(garmentColor: c, garment: Garment.cloak)),
];

class _Gallery extends StatelessWidget {
  const _Gallery(this.items, {required this.size});

  final List<(String, Avatar?)> items;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsetsDirectional.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            for (final (label, a) in items)
              SizedBox(
                width: size < 72 ? 72 : size,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarView(avatar: a, size: size),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: p.textSecondary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<void> _shoot(
  WidgetTester tester,
  String name,
  Widget gallery,
  Size size, {
  Brightness brightness = Brightness.dark,
  double pixelRatio = 1.5,
}) async {
  await pumpCartha(
    tester,
    data: onboardedData(),
    home: gallery,
    size: size,
    brightness: brightness,
    systemPadding: EdgeInsets.zero,
  );
  await captureScreenshot(tester, name, pixelRatio: pixelRatio);
}

void main() {
  for (final b in Brightness.values) {
    testWidgets('cast ${b.name}', (tester) async {
      await _shoot(
        tester,
        'avatar_cast_${b.name}',
        const _Gallery(_cast, size: 168),
        const Size(760, 640),
        brightness: b,
      );
    });
  }

  for (final b in Brightness.values) {
    testWidgets('sizes ladder ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        brightness: b,
        size: const Size(1010, 300),
        systemPadding: EdgeInsets.zero,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsetsDirectional.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final group in [
                  [_cast[6].$2, _cast[9].$2, _cast[7].$2],
                  [
                    const Avatar(hair: HairStyle.long),
                    _cast[2].$2.copyWith(headwear: Headwear.headscarf),
                    null,
                  ],
                ])
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final a in group)
                        for (final s in [120.0, 64.0, 48.0, 32.0, 24.0])
                          Padding(
                            padding: const EdgeInsetsDirectional.all(4),
                            child: AvatarView(avatar: a, size: s),
                          ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
      await captureScreenshot(tester, 'avatar_ladder_${b.name}', pixelRatio: 2);
    });
  }

  testWidgets('parts', (tester) async {
    await _shoot(
      tester,
      'avatar_parts',
      _Gallery(_parts(), size: 120),
      const Size(1100, 1180),
    );
  });

  testWidgets('colours', (tester) async {
    await _shoot(
      tester,
      'avatar_colours',
      _Gallery(_colours(), size: 104),
      const Size(1100, 420),
    );
  });

  testWidgets('silhouettes', (tester) async {
    await _shoot(
      tester,
      'avatar_silhouettes',
      _Gallery([
        for (final (label, a) in _cast)
          (label, a.copyWith(skinTone: () => null)),
        ('emblem', null),
      ], size: 120),
      const Size(1100, 480),
    );
  });

  testWidgets('headwear across hair', (tester) async {
    await _shoot(
      tester,
      'avatar_headwear',
      _Gallery([
        for (final hw in Headwear.values.skip(1))
          for (final (label, a) in [_cast[6], _cast[10], _cast[8]])
            ('${hw.name}/$label', a.copyWith(headwear: hw)),
      ], size: 120),
      const Size(1100, 760),
    );
  });

  for (final b in Brightness.values) {
    testWidgets('detail ${b.name}', (tester) async {
      await _shoot(
        tester,
        'avatar_detail_${b.name}',
        _Gallery([
          _cast[11],
          _cast[3],
          _cast[5],
          _cast[2],
          (
            'headscarf',
            _cast[9].$2.copyWith(
              headwear: Headwear.headscarf,
              garmentColor: GarmentColor.ivory,
            ),
          ),
          (
            'turban',
            _cast[0].$2.copyWith(
              headwear: Headwear.turban,
              facialHair: FacialHair.fullBeard,
              hairColor: HairColor.black,
              garmentColor: GarmentColor.indigo,
            ),
          ),
          (
            'hood',
            _cast[4].$2.copyWith(
              headwear: Headwear.hood,
              garmentColor: GarmentColor.olive,
            ),
          ),
          ('laurel', _cast[1].$2.copyWith(headwear: Headwear.laurel)),
        ], size: 240),
        const Size(1040, 560),
        brightness: b,
        pixelRatio: 1,
      );
    });
  }
}
