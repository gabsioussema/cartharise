// Renders the onboarding pages and the Today tab to PNGs for design review
// against "Cartharise Brand and App System Board.png" (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/widgets/scenes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';
import '../ui/today_test.dart' show inProgressData, settledData;

/// Lets the one-shot scene rise finish.
Future<void> _settleScenes(WidgetTester tester) =>
    pumpFrames(tester, count: 20);

void main() {
  for (final b in Brightness.values) {
    testWidgets('onboarding ${b.name}', (tester) async {
      await pumpCartha(tester, brightness: b, content: englishContent);
      Future<void> next() async {
        await tester.tap(find.byKey(const ValueKey('onboarding-next')));
        await _settleScenes(tester);
      }

      await _settleScenes(tester);
      await captureScreenshot(tester, '10_onboarding_brand_${b.name}');
      for (final name in ['understand', 'reset', 'direction', 'steps']) {
        await next();
        await captureScreenshot(tester, '11_onboarding_${name}_${b.name}');
      }
      await next();
      await captureScreenshot(tester, '12_onboarding_limits_${b.name}');
      await tester.ensureVisible(
        find.byKey(const ValueKey('onboarding-adult')),
      );
      await pumpFrames(tester, count: 2);
      await captureScreenshot(tester, '12_onboarding_limits_end_${b.name}');
      await tester.tap(find.byKey(const ValueKey('onboarding-adult')));
      await pumpFrames(tester, count: 2);
      await next();
      await captureScreenshot(tester, '13_onboarding_credit_${b.name}');
      await next();
      await captureScreenshot(tester, '14_onboarding_pace_${b.name}');
      await next();
      await tester.enterText(find.byType(TextField), 'Sam');
      await pumpFrames(tester, count: 2);
      await captureScreenshot(tester, '15_onboarding_name_${b.name}');
      await next();
      await captureScreenshot(tester, '16_onboarding_privacy_${b.name}');
    });

    testWidgets('today first day ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: onboardedData(name: null),
        content: englishContent,
      );
      await _settleScenes(tester);
      await captureScreenshot(tester, '20_today_first_${b.name}');
    });

    testWidgets('today in progress ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: inProgressData(),
        content: englishContent,
        size: const Size(390, 1500),
      );
      await _settleScenes(tester);
      await captureScreenshot(tester, '21_today_in_progress_${b.name}');
    });

    testWidgets('today with an avatar ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
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
      );
      await _settleScenes(tester);
      await captureScreenshot(tester, '21b_today_avatar_${b.name}');
    });

    testWidgets('today settled ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: settledData(),
        content: englishContent,
        size: const Size(390, 1500),
        now: DateTime(2026, 11, 6, 19, 10),
      );
      await _settleScenes(tester);
      await captureScreenshot(tester, '22_today_settled_${b.name}');
    });

    testWidgets('scenes ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: onboardedData(),
        size: const Size(390, 1400),
        home: Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                SunriseScene(),
                SizedBox(height: 8),
                PathScene(),
                SizedBox(height: 8),
                CompassScene(),
                SizedBox(height: 8),
                StepsScene(),
                SizedBox(height: 8),
                DawnRuinsScene(),
              ],
            ),
          ),
        ),
      );
      await _settleScenes(tester);
      await captureScreenshot(tester, '23_scenes_${b.name}');
    });
  }
}
