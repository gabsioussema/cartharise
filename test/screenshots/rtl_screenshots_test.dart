// Renders the main screens in Arabic (right to left, Noto Sans Arabic UI)
// to PNGs for design review (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/campaign_pages.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';
import '../ui/rtl_test.dart' show arabicData, pumpArabic;

void main() {
  for (final b in Brightness.values) {
    final suffix = b.name;

    Future<void> tab(WidgetTester tester, String name, AppTab tab) async {
      final h = await pumpArabic(tester, brightness: b);
      h.shell.select(tab);
      await pumpFrames(tester);
      await captureScreenshot(tester, 'rtl_${name}_$suffix');
    }

    Future<void> screen(
      WidgetTester tester,
      String name,
      Widget home, {
      Size size = const Size(390, 844),
      double textScale = 1,
    }) async {
      await pumpArabic(
        tester,
        brightness: b,
        home: home,
        size: size,
        textScale: textScale,
      );
      await captureScreenshot(tester, 'rtl_${name}_$suffix');
    }

    testWidgets('today $suffix', (tester) async {
      await tab(tester, '01_today', AppTab.today);
    });
    testWidgets('reset $suffix', (tester) async {
      await tab(tester, '02_reset', AppTab.reset);
    });
    testWidgets('journal $suffix', (tester) async {
      await tab(tester, '03_journal', AppTab.journal);
    });
    testWidgets('you $suffix', (tester) async {
      await tab(tester, '04_you', AppTab.you);
    });
    testWidgets('compass $suffix', (tester) async {
      await screen(tester, '05_compass', const CompassTab());
    });
    testWidgets('missions $suffix', (tester) async {
      await screen(
        tester,
        '06_missions',
        const CompassTab(initial: CompassSection.missions),
      );
    });
    testWidgets('campaign $suffix', (tester) async {
      await screen(
        tester,
        '07_campaign',
        const CompassTab(initial: CompassSection.campaign),
      );
    });
    testWidgets('route $suffix', (tester) async {
      await screen(tester, '08_route', campaignPageScreen(CampaignPage.route));
    });
    testWidgets('try $suffix', (tester) async {
      await screen(tester, '09_try', campaignPageScreen(CampaignPage.tryIt));
    });
    testWidgets('question $suffix', (tester) async {
      await screen(
        tester,
        '10_question',
        const GuidedPromptScreen(promptId: 'morning.04'),
      );
    });
    testWidgets('lesson $suffix', (tester) async {
      await screen(
        tester,
        '11_lesson',
        const LessonScreen(lessonId: 'lesson.01'),
      );
    });
    testWidgets('path day $suffix', (tester) async {
      await screen(tester, '12_path_day', const PathDayScreen(day: 3));
    });
    testWidgets('small phone at 200 % $suffix', (tester) async {
      final h = await pumpArabic(
        tester,
        brightness: b,
        size: const Size(320, 568),
        textScale: 2,
      );
      h.shell.select(AppTab.today);
      await pumpFrames(tester);
      await captureScreenshot(tester, 'rtl_13_today_320_$suffix');
    });
    // Audit S3-m1 / S3-m6: the section pills stacked at 320 dp / 200 %
    // (never a broken word), an English answer and English attempts in the
    // Arabic app, each in its own direction.
    testWidgets('pills at 320 dp, 200 % $suffix', (tester) async {
      await screen(
        tester,
        '16_pills_320',
        const CompassTab(initial: CompassSection.campaign),
        size: const Size(320, 568),
        textScale: 2,
      );
    });
    testWidgets('English answer $suffix', (tester) async {
      await screen(
        tester,
        '17_english_answer',
        const GuidedPromptScreen(promptId: 'morning.02'),
      );
    });
    testWidgets('mixed battle log $suffix', (tester) async {
      final data = arabicData();
      await pumpArabic(
        tester,
        brightness: b,
        size: const Size(390, 1300),
        data: data.copyWith(
          campaignLog: [
            BattleLogEntry(
              id: 'a1',
              day: '2026-11-02',
              attempt: 'Wrote the first page (draft).',
              learning: 'Mornings work better.',
              createdAt: DateTime(2026, 11, 2, 20),
            ),
            BattleLogEntry(
              id: 'a2',
              day: '2026-11-01',
              attempt: 'كتبت لمدة 20 دقيقة قبل العمل.',
              learning: 'الصباح أهدأ.',
              createdAt: DateTime(2026, 11, 1, 20),
            ),
          ],
        ),
        home: const BattleLogScreen(),
      );
      await tester.enterText(
        find.byKey(const ValueKey('campaign-attempt')),
        'Called Sam (10 min).',
      );
      await pumpFrames(tester, count: 2);
      await captureScreenshot(tester, 'rtl_18_battle_log_mixed_$suffix');
    });
    testWidgets('onboarding $suffix', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: AppData.empty.copyWith(
          settings: const AppSettings(language: AppLanguage.ar),
        ),
        content: englishContent,
        contentFor: contentFor,
      );
      await captureScreenshot(tester, 'rtl_14_onboarding_brand_$suffix');
      await tester.tap(find.byKey(const ValueKey('onboarding-next')));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'rtl_15_onboarding_limits_$suffix');
    });
  }
}
