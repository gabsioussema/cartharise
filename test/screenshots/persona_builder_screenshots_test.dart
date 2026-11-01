// Renders the avatar builder and the You profile to PNGs for design review
// (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/persona/persona_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _at = DateTime(2026, 11, 2, 20);

/// The game layer on and no progress yet (extras locked), with a saved
/// avatar that wears a laurel kept from before.
AppData _data({bool withPersona = true}) =>
    onboardedData(settings: const AppSettings(game: true)).copyWith(
      persona: () => withPersona
          ? Persona(
              avatar: const Avatar(
                skinTone: SkinTone.walnut,
                hair: HairStyle.locs,
                hairColor: HairColor.black,
                eyewear: Eyewear.round,
                headwear: Headwear.laurel,
                garment: Garment.cloak,
                garmentColor: GarmentColor.olive,
                accessory: Accessory.satchel,
                sigil: Sigil.sun,
              ),
              motto: 'Steady, not fast.',
              updatedAt: _at,
            )
          : null,
    );

Future<void> _category(WidgetTester tester, String name) async {
  final chip = find.byKey(ValueKey('persona-category-$name'));
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await pumpFrames(tester);
}

void main() {
  for (final brightness in Brightness.values) {
    final b = brightness.name;

    testWidgets('builder: new avatar ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(withPersona: false),
        home: const PersonaBuilderScreen(),
        brightness: brightness,
      );
      await captureScreenshot(tester, 'persona_builder_new_$b');
    });

    testWidgets('builder: banner extras, locked ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        home: const PersonaBuilderScreen(),
        brightness: brightness,
      );
      await _category(tester, 'sigil');
      await captureScreenshot(tester, 'persona_builder_banner_$b');
    });

    testWidgets('builder: headwear, kept laurel ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        home: const PersonaBuilderScreen(),
        brightness: brightness,
        size: const Size(390, 1100),
      );
      await _category(tester, 'headwear');
      await captureScreenshot(tester, 'persona_builder_headwear_$b');
    });

    testWidgets('You profile with an avatar ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        shell: ShellController(initial: AppTab.you),
        brightness: brightness,
      );
      await captureScreenshot(tester, 'persona_you_profile_$b');
    });
  }

  testWidgets('builder: small phone, 200 % text', (tester) async {
    await pumpCartha(
      tester,
      data: _data(),
      home: const PersonaBuilderScreen(),
      size: const Size(320, 568),
      textScale: 2,
    );
    await captureScreenshot(tester, 'persona_builder_small_200');
  });

  testWidgets('builder: tablet', (tester) async {
    await pumpCartha(
      tester,
      data: _data(),
      home: const PersonaBuilderScreen(),
      size: const Size(1024, 1366),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await _category(tester, 'garmentColor');
    await captureScreenshot(tester, 'persona_builder_tablet');
  });
}
