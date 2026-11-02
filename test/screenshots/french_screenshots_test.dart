// Renders the language picker and the main screens in French to PNGs for
// design review (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/you/appearance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';
import '../ui/french_ui_test.dart' show frenchData;

void main() {
  for (final b in Brightness.values) {
    final suffix = b.name;

    Future<void> shot(
      WidgetTester tester,
      String name, {
      AppData? data,
      Widget? home,
      AppTab? tab,
      String? pill,
      Size size = const Size(390, 844),
      double textScale = 1.0,
    }) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: data ?? frenchData(),
        home: home,
        shell: tab == null ? null : ShellController(initial: tab),
        size: size,
        textScale: textScale,
        content: englishContent,
        contentFor: contentFor,
      );
      if (pill != null) {
        await tester.tap(find.text(pill).first);
        await pumpFrames(tester, count: 3);
      }
      await captureScreenshot(tester, '${name}_$suffix');
    }

    // The picker in each language, plus "Same as phone" on an English UI.
    testWidgets('language picker en $suffix', (tester) async {
      await shot(
        tester,
        'french_01_picker_en',
        data: onboardedData(),
        home: const AppearanceScreen(),
      );
    });
    testWidgets('language picker fr $suffix', (tester) async {
      await shot(tester, 'french_02_picker_fr', home: const AppearanceScreen());
    });
    testWidgets('language picker ar $suffix', (tester) async {
      await shot(
        tester,
        'french_03_picker_ar',
        data: frenchData(language: AppLanguage.ar),
        home: const AppearanceScreen(),
      );
    });
    testWidgets('language picker fr small $suffix', (tester) async {
      await shot(
        tester,
        'french_04_picker_fr_320',
        home: const AppearanceScreen(),
        size: const Size(320, 568),
        textScale: 2,
      );
    });

    // Main screens in French (phone, and the small phone at 200 % text).
    testWidgets('today fr $suffix', (tester) async {
      await shot(tester, 'french_10_today', tab: AppTab.today);
    });
    testWidgets('today fr small $suffix', (tester) async {
      await shot(
        tester,
        'french_11_today_320',
        tab: AppTab.today,
        size: const Size(320, 568),
        textScale: 2,
      );
    });
    testWidgets('reset fr $suffix', (tester) async {
      await shot(tester, 'french_12_reset', tab: AppTab.reset);
    });
    testWidgets('compass fr $suffix', (tester) async {
      await shot(tester, 'french_13_compass', tab: AppTab.compass);
    });
    testWidgets('missions fr $suffix', (tester) async {
      await shot(
        tester,
        'french_14_missions',
        tab: AppTab.compass,
        pill: 'Missions',
      );
    });
    testWidgets('campaign fr $suffix', (tester) async {
      await shot(
        tester,
        'french_15_campaign',
        tab: AppTab.compass,
        pill: 'Campagne',
      );
    });
    testWidgets('journal fr $suffix', (tester) async {
      await shot(tester, 'french_16_journal', tab: AppTab.journal);
    });
    testWidgets('you fr $suffix', (tester) async {
      await shot(tester, 'french_17_you', tab: AppTab.you);
    });
    testWidgets('prompt fr $suffix', (tester) async {
      await shot(
        tester,
        'french_18_prompt',
        home: const GuidedPromptScreen(promptId: 'morning.09'),
        size: const Size(390, 1200),
      );
    });
    testWidgets('prompt fr small $suffix', (tester) async {
      await shot(
        tester,
        'french_19_prompt_320',
        home: const GuidedPromptScreen(promptId: 'morning.09'),
        size: const Size(320, 568),
        textScale: 2,
      );
    });
    testWidgets('lesson fr $suffix', (tester) async {
      await shot(
        tester,
        'french_20_lesson',
        home: const LessonScreen(lessonId: 'lesson.03'),
        size: const Size(390, 1600),
      );
    });
  }
}
