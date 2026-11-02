// Renders Today and You › Appearance in every theme, dark and light, for
// design review (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/you/appearance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';
import '../ui/today_test.dart' show inProgressData;

void main() {
  for (final theme in AppTheme.values) {
    for (final b in Brightness.values) {
      testWidgets('today ${theme.name} ${b.name}', (tester) async {
        await pumpCartha(
          tester,
          brightness: b,
          theme: theme,
          data: inProgressData().copyWith(
            persona: () => Persona(
              avatar: const Avatar(
                skinTone: SkinTone.copper,
                hair: HairStyle.locs,
                garment: Garment.cloak,
                garmentColor: GarmentColor.sand,
              ),
              updatedAt: DateTime(2026, 11, 2, 8),
            ),
          ),
          content: englishContent,
          size: const Size(390, 1100),
        );
        await pumpFrames(tester, count: 20);
        await captureScreenshot(tester, 'theme_${theme.name}_today_${b.name}');
      });
    }
  }

  for (final b in Brightness.values) {
    testWidgets('appearance picker ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        theme: AppTheme.tyrian,
        data: inProgressData(),
        home: const AppearanceScreen(),
      );
      await captureScreenshot(tester, 'theme_picker_${b.name}');
    });
  }
}
