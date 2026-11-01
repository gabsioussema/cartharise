import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartharise/domain/app_data.dart' show AppTheme;
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/persona/avatar_painter.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
import 'package:cartharise/ui/theme/avatar_palette.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// A plain base to vary one part at a time from (no headwear hiding hair,
/// a skin tone so the face is drawn).
const _base = Avatar(
  skinTone: SkinTone.clay,
  hair: HairStyle.short,
  hairColor: HairColor.darkBrown,
  accessory: Accessory.none,
  sigil: Sigil.elephant,
);

final _scene = AvatarScene.of(CarthaTheme.dark().extension<CarthaPalette>()!);

/// Every value of every part, as one-part variations of [base].
Map<String, List<Avatar>> _variations(Avatar base) => {
  'SkinTone': [
    base.copyWith(skinTone: () => null),
    for (final v in SkinTone.values) base.copyWith(skinTone: () => v),
  ],
  'FaceShape': [for (final v in FaceShape.values) base.copyWith(face: v)],
  'HairStyle': [for (final v in HairStyle.values) base.copyWith(hair: v)],
  'HairColor': [for (final v in HairColor.values) base.copyWith(hairColor: v)],
  'FacialHair': [
    for (final v in FacialHair.values) base.copyWith(facialHair: v),
  ],
  'Eyewear': [for (final v in Eyewear.values) base.copyWith(eyewear: v)],
  'SkinMark': [for (final v in SkinMark.values) base.copyWith(mark: v)],
  'Expression': [
    for (final v in Expression.values) base.copyWith(expression: v),
  ],
  'Headwear': [for (final v in Headwear.values) base.copyWith(headwear: v)],
  'Garment': [for (final v in Garment.values) base.copyWith(garment: v)],
  'GarmentColor': [
    for (final v in GarmentColor.values) base.copyWith(garmentColor: v),
  ],
  'Accessory': [for (final v in Accessory.values) base.copyWith(accessory: v)],
  'Sigil': [for (final v in Sigil.values) base.copyWith(sigil: v)],
};

/// Paints [avatar] off screen and returns its RGBA pixels.
Future<Uint8List> _render(
  Avatar? avatar, {
  double size = 96,
  bool showSigil = true,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final painter = avatar == null
      ? AvatarEmblemPainter(scene: _scene)
      : AvatarPainter(avatar: avatar, scene: _scene, showSigil: showSigil);
  painter.paint(canvas, Size.square(size));
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.ceil(), size.ceil());
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  picture.dispose();
  return data!.buffer.asUint8List();
}

/// Every distinct opaque colour in [rgba].
Set<int> _colours(Uint8List rgba) => {
  for (var i = 0; i < rgba.length; i += 4)
    if (rgba[i + 3] == 255) (rgba[i] << 16) | (rgba[i + 1] << 8) | rgba[i + 2],
};

int _rgb(Color c) => c.toARGB32() & 0xFFFFFF;

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('level of detail', () {
    test('tiny under 40 px, regular to 119 px, fine from 120 px', () {
      expect(avatarDetailFor(24), AvatarDetail.tiny);
      expect(avatarDetailFor(39.9), AvatarDetail.tiny);
      expect(avatarDetailFor(40), AvatarDetail.regular);
      expect(avatarDetailFor(96), AvatarDetail.regular);
      expect(avatarDetailFor(120), AvatarDetail.fine);
      expect(avatarDetailFor(240), AvatarDetail.fine);
    });

    test('below 40 px the banner and the finest marks are left out', () async {
      for (final a in [
        _base.copyWith(sigil: Sigil.none),
        _base.copyWith(sigil: Sigil.compass),
      ]) {
        expect(
          await _render(a, size: 24),
          await _render(_base.copyWith(sigil: Sigil.none), size: 24),
        );
      }
      expect(
        await _render(_base.copyWith(mark: SkinMark.freckles), size: 24),
        await _render(_base, size: 24),
      );
    });
  });

  group('every part is drawn', () {
    for (final MapEntry(key: part, value: avatars) in _variations(
      _base,
    ).entries) {
      test('$part: every value paints at 24, 48, 96 and 240 px', () async {
        for (final size in [24.0, 48.0, 96.0, 240.0]) {
          for (final a in avatars) {
            final px = await _render(a, size: size);
            expect(px.length, size.ceil() * size.ceil() * 4);
          }
        }
      });

      test('$part: each value looks different at 96 px', () async {
        final renders = [for (final a in avatars) await _render(a)];
        for (var i = 0; i < renders.length; i++) {
          for (var j = i + 1; j < renders.length; j++) {
            expect(
              listEquals(renders[i], renders[j]),
              isFalse,
              reason: '$part #$i and #$j render the same',
            );
          }
        }
      });
    }

    test('every headwear over every hair style and face shape', () async {
      for (final hw in Headwear.values) {
        for (final hair in HairStyle.values) {
          for (final face in FaceShape.values) {
            await _render(
              _base.copyWith(
                headwear: hw,
                hair: hair,
                face: face,
                facialHair: FacialHair.fullBeard,
                eyewear: Eyewear.square,
              ),
              size: 48,
            );
          }
        }
      }
    });

    test('every garment with every carried item, sigil and colour', () async {
      for (final g in Garment.values) {
        for (final acc in Accessory.values) {
          for (final s in Sigil.values) {
            await _render(
              _base.copyWith(
                garment: g,
                accessory: acc,
                sigil: s,
                garmentColor: GarmentColor.values[(acc.index + s.index) % 8],
                headwear: Headwear.values[(g.index + acc.index) % 6],
              ),
              size: 64,
            );
          }
        }
      }
    });

    test(
      'a scarf or turban covers the hair (any style looks the same)',
      () async {
        for (final hw in [Headwear.headscarf, Headwear.turban]) {
          final short = await _render(
            _base.copyWith(headwear: hw, hair: HairStyle.short),
          );
          final afro = await _render(
            _base.copyWith(headwear: hw, hair: HairStyle.afro),
          );
          expect(listEquals(short, afro), isTrue, reason: hw.name);
        }
      },
    );

    test('without the banner, the sigil choice changes nothing', () async {
      final a = await _render(
        _base.copyWith(sigil: Sigil.sun),
        showSigil: false,
      );
      final b = await _render(
        _base.copyWith(sigil: Sigil.laurel),
        showSigil: false,
      );
      expect(listEquals(a, b), isTrue);
    });
  });

  group('silhouette (no skin tone)', () {
    const silhouette = Avatar(
      hair: HairStyle.long,
      hairColor: HairColor.copper,
      eyewear: Eyewear.round,
      mark: SkinMark.vitiligo,
      expression: Expression.smile,
      headwear: Headwear.circlet,
      garment: Garment.cloak,
      garmentColor: GarmentColor.crimson,
      accessory: Accessory.compass,
      sigil: Sigil.star,
    );

    test('no skin, hair, garment or material colour is assumed', () async {
      final seen = _colours(await _render(silhouette, size: 240));
      final avatarColours = {
        for (final t in SkinTone.values) ...[
          AvatarPalette.skin(t).base,
          AvatarPalette.skin(t).shade,
          AvatarPalette.skin(t).lip,
        ],
        for (final c in HairColor.values) AvatarPalette.hair(c).base,
        for (final c in GarmentColor.values) ...[
          AvatarPalette.garment(c).base,
          AvatarPalette.garment(c).under,
        ],
        AvatarColors.ink,
        AvatarColors.metal,
        AvatarColors.leather,
        AvatarColors.parchment,
        AvatarColors.ribbon,
        AvatarColors.frameDark,
      };
      for (final c in avatarColours) {
        expect(seen.contains(_rgb(c)), isFalse, reason: '$c in silhouette');
      }
    });

    test('a chosen tone brings the skin colour in', () async {
      for (final t in SkinTone.values) {
        final seen = _colours(
          await _render(silhouette.copyWith(skinTone: () => t), size: 96),
        );
        expect(
          seen,
          contains(_rgb(AvatarPalette.skin(t).base)),
          reason: t.name,
        );
      }
    });

    test('monochrome: colours change nothing, shapes still show', () async {
      final a = await _render(silhouette);
      final recoloured = await _render(
        silhouette.copyWith(
          hairColor: HairColor.black,
          garmentColor: GarmentColor.ivory,
        ),
      );
      expect(listEquals(a, recoloured), isTrue);
      final reshaped = await _render(silhouette.copyWith(hair: HairStyle.afro));
      expect(listEquals(a, reshaped), isFalse);
    });

    test('no face is drawn: expressions and marks change nothing', () async {
      final calm = await _render(
        silhouette.copyWith(expression: Expression.calm, mark: SkinMark.none),
      );
      final other = await _render(
        silhouette.copyWith(
          expression: Expression.focused,
          mark: SkinMark.freckles,
        ),
      );
      expect(listEquals(calm, other), isTrue);
    });
  });

  group('avatar colours', () {
    test('skin tones, hair and garment colours are all distinct', () {
      Set<int> rgb(Iterable<Color> cs) => {for (final c in cs) _rgb(c)};
      expect(
        rgb(SkinTone.values.map((t) => AvatarPalette.skin(t).base)),
        hasLength(SkinTone.values.length),
      );
      expect(
        rgb(HairColor.values.map((c) => AvatarPalette.hair(c).base)),
        hasLength(HairColor.values.length),
      );
      expect(
        rgb(GarmentColor.values.map((c) => AvatarPalette.garment(c).base)),
        hasLength(GarmentColor.values.length),
      );
    });

    test('glasses frames read on every skin tone (≥ 2.5:1)', () {
      for (final t in SkinTone.values) {
        final skin = AvatarPalette.skin(t);
        expect(
          _contrast(AvatarPalette.frameFor(skin), skin.base),
          greaterThanOrEqualTo(2.5),
          reason: t.name,
        );
      }
    });

    test('vitiligo patches are lighter than the skin, never white', () {
      for (final t in SkinTone.values) {
        final skin = AvatarPalette.skin(t);
        expect(
          skin.patch.computeLuminance(),
          greaterThan(skin.base.computeLuminance()),
          reason: t.name,
        );
        expect(_rgb(skin.patch), isNot(0xFFFFFF));
      }
    });

    test('garment trims stand out from their garment (≥ 1.8:1)', () {
      for (final c in GarmentColor.values) {
        final g = AvatarPalette.garment(c);
        expect(
          _contrast(g.trim, g.base),
          greaterThanOrEqualTo(1.8),
          reason: c.name,
        );
      }
    });

    test('dark garments get a lighter edge on every hero disc (≥ 3:1)', () {
      for (final theme in AppTheme.values) {
        for (final b in Brightness.values) {
          final disc = AvatarScene.of(
            CarthaTheme.build(theme, b).extension<CarthaPalette>()!,
          ).disc;
          for (final c in GarmentColor.values) {
            final g = AvatarPalette.garment(c);
            final edge = AvatarPalette.garmentEdge(g, disc);
            final why = '${theme.name} ${b.name} ${c.name}';
            if (_contrast(g.base, disc) < AvatarPalette.minGarmentContrast) {
              expect(edge, isNotNull, reason: why);
              expect(
                _contrast(edge!, disc),
                greaterThanOrEqualTo(3),
                reason: why,
              );
            } else {
              expect(edge, isNull, reason: '$why stands clear');
            }
          }
          // The default garment colour is one that needs it.
          expect(
            AvatarPalette.garmentEdge(
              AvatarPalette.garment(const Avatar().garmentColor),
              disc,
            ),
            isNotNull,
          );
        }
      }
    });

    test(
      'the edge is drawn on the shoulders, scarf, hood and turban',
      () async {
        final edge = AvatarPalette.garmentEdge(
          AvatarPalette.garment(GarmentColor.forest),
          _scene.disc,
        )!;
        for (final g in Garment.values) {
          expect(
            _colours(await _render(_base.copyWith(garment: g), size: 240)),
            contains(_rgb(edge)),
            reason: g.name,
          );
        }
        // Around the head (the top 40 %), only headwear in the garment's
        // colour has the edge.
        Future<int> edgeAroundHead(Headwear hw) async {
          final px = await _render(_base.copyWith(headwear: hw), size: 240);
          var n = 0;
          for (var i = 0; i < 240 * 96 * 4; i += 4) {
            final rgb = (px[i] << 16) | (px[i + 1] << 8) | px[i + 2];
            if (px[i + 3] == 255 && rgb == _rgb(edge)) n++;
          }
          return n;
        }

        expect(await edgeAroundHead(Headwear.none), 0);
        for (final hw in [Headwear.headscarf, Headwear.hood, Headwear.turban]) {
          expect(await edgeAroundHead(hw), greaterThan(0), reason: hw.name);
        }
        // A light garment stands clear on its own: no edge.
        final sand = AvatarPalette.garment(GarmentColor.sand);
        expect(AvatarPalette.garmentEdge(sand, _scene.disc), isNull);
      },
    );

    test('raw colours live only in lib/ui/theme/', () {
      final raw = RegExp(
        r'Color\s*\(\s*(?:0x|[0-9])|Color\.fromARGB|Color\.fromRGBO|'
        r'\bColors\.(?!transparent\b)\w+|\bCarthaColors\b',
      );
      for (final path in [
        'lib/ui/persona/avatar_painter.dart',
        'lib/ui/persona/avatar_view.dart',
      ]) {
        final lines = File(path).readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].trimLeft().startsWith('//')) continue;
          expect(raw.hasMatch(lines[i]), isFalse, reason: '$path:${i + 1}');
        }
      }
      expect(File('lib/ui/theme/avatar_palette.dart').existsSync(), isTrue);
    });
  });

  group('painter', () {
    test('repaints only when something visible changes', () {
      final p = AvatarPainter(avatar: _base, scene: _scene);
      expect(
        p.shouldRepaint(AvatarPainter(avatar: _base, scene: _scene)),
        isFalse,
      );
      expect(
        p.shouldRepaint(
          AvatarPainter(
            avatar: _base.copyWith(hair: HairStyle.locs),
            scene: _scene,
          ),
        ),
        isTrue,
      );
      expect(
        p.shouldRepaint(
          AvatarPainter(avatar: _base, scene: _scene, showSigil: false),
        ),
        isTrue,
      );
      final light = AvatarScene.of(
        CarthaTheme.light().extension<CarthaPalette>()!,
      );
      expect(light == _scene, isTrue, reason: 'hero disc in both themes');
    });

    test('an empty or odd size paints nothing and does not throw', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final p = AvatarPainter(avatar: _base, scene: _scene);
      p.paint(canvas, Size.zero);
      p.paint(canvas, const Size(0, 40));
      p.paint(canvas, const Size(120, 60));
      recorder.endRecording().dispose();
    });
  });

  group('AvatarView', () {
    Widget host(List<Widget> children) => Scaffold(
      body: SingleChildScrollView(
        child: Wrap(spacing: 8, runSpacing: 8, children: children),
      ),
    );

    for (final b in Brightness.values) {
      testWidgets('sizes 24, 48, 96 and 240 (${b.name})', (tester) async {
        const sizes = [24.0, 48.0, 96.0, 240.0];
        await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: b,
          home: host([
            for (final s in sizes)
              AvatarView(key: ValueKey(s), avatar: _base, size: s),
            for (final s in sizes) AvatarView(key: ValueKey(-s), size: s),
          ]),
        );
        for (final s in sizes) {
          expect(tester.getSize(find.byKey(ValueKey(s))), Size.square(s));
          expect(tester.getSize(find.byKey(ValueKey(-s))), Size.square(s));
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('screen reader: "Your avatar", "No avatar yet" or a label', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: host(const [
          AvatarView(avatar: _base),
          AvatarView(),
          AvatarView(avatar: _base, semanticLabel: 'Sam as a strategist'),
          AvatarView(avatar: _base, excludeFromSemantics: true),
        ]),
      );
      expect(find.bySemanticsLabel('Your avatar'), findsOneWidget);
      expect(find.bySemanticsLabel('No avatar yet'), findsOneWidget);
      expect(find.bySemanticsLabel('Sam as a strategist'), findsOneWidget);
      final image = tester.getSemantics(find.bySemanticsLabel('Your avatar'));
      expect(image.flagsCollection.isImage, isTrue);
      handle.dispose();
    });

    testWidgets('no avatar keeps the emblem; an avatar gets the portrait', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: host(const [
          AvatarView(key: ValueKey('none')),
          AvatarView(key: ValueKey('mine'), avatar: _base, showSigil: false),
        ]),
      );
      CustomPainter? painterOf(String key) => tester
          .widget<CustomPaint>(
            find.descendant(
              of: find.byKey(ValueKey(key)),
              matching: find.byType(CustomPaint),
            ),
          )
          .painter;
      expect(painterOf('none'), isA<AvatarEmblemPainter>());
      final mine = painterOf('mine')! as AvatarPainter;
      expect(mine.avatar, _base);
      expect(mine.showSigil, isFalse);
    });

    for (final b in Brightness.values) {
      for (final c in kSizeMatrix) {
        testWidgets('size matrix $c (${b.name})', (tester) async {
          await pumpCartha(
            tester,
            data: onboardedData(),
            size: c.size,
            textScale: c.textScale,
            brightness: b,
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsetsDirectional.all(16),
                children: [
                  for (final (s, a) in [
                    (240.0, _base),
                    (96.0, _base.copyWith(skinTone: () => null)),
                    (48.0, null),
                  ])
                    Row(
                      children: [
                        AvatarView(avatar: a, size: s),
                        const SizedBox(width: 12),
                        const Flexible(child: Text('Your strategist')),
                      ],
                    ),
                ],
              ),
            ),
          );
          await expectNoOverflow(tester);
        });
      }
    }
  });
}
