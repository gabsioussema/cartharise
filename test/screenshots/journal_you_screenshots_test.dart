// Renders the Journal and You screens to PNGs for design review against
// "Cartharise Brand and App System Board.png" (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/journal/past_reset_screen.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:cartharise/ui/you/appearance_screen.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:cartharise/ui/you/inspiration_screen.dart';
import 'package:cartharise/ui/you/reminders_screen.dart';
import 'package:cartharise/ui/you/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';
import '../ui/journal_test.dart' show journalData;

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

void main() {
  for (final b in Brightness.values) {
    final suffix = b.name;

    Future<void> tab(
      WidgetTester tester,
      String name,
      String label, {
      String? section,
    }) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: journalData(),
        content: englishContent,
      );
      await tester.tap(_nav(label));
      await pumpFrames(tester);
      if (section != null) {
        await tester.tap(find.text(section));
        await pumpFrames(tester, count: 2);
      }
      await captureScreenshot(tester, '${name}_$suffix');
    }

    Future<void> screen(
      WidgetTester tester,
      String name,
      Widget home, {
      Size size = const Size(390, 844),
    }) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: journalData(),
        content: englishContent,
        home: home,
        size: size,
      );
      await captureScreenshot(tester, '${name}_$suffix');
    }

    testWidgets('journal notes $suffix', (tester) async {
      await tab(tester, 'journal_01_notes', 'Journal');
    });
    testWidgets('journal reviews $suffix', (tester) async {
      await tab(tester, 'journal_02_reviews', 'Journal', section: 'Reviews');
    });
    testWidgets('journal look back $suffix', (tester) async {
      await tab(
        tester,
        'journal_03_look_back',
        'Journal',
        section: 'Look back',
      );
    });
    testWidgets('journal note $suffix', (tester) async {
      await screen(
        tester,
        'journal_04_note',
        const JournalEntryScreen(entryId: 'note_b'),
      );
    });
    testWidgets('journal review $suffix', (tester) async {
      await screen(
        tester,
        'journal_05_review',
        const ReviewScreen(reviewId: 'review_1'),
      );
    });
    testWidgets('journal review new $suffix', (tester) async {
      await screen(tester, 'journal_06_review_new', const ReviewScreen());
    });
    testWidgets('journal past reset $suffix', (tester) async {
      await screen(
        tester,
        'journal_07_past_reset',
        const PastResetScreen(journeyId: 'journey_old'),
      );
    });
    testWidgets('you hub $suffix', (tester) async {
      await tab(tester, 'you_01_hub', 'You');
    });
    testWidgets('you inspiration $suffix', (tester) async {
      await screen(
        tester,
        'you_02_inspiration',
        const InspirationScreen(),
        size: const Size(390, 1400),
      );
    });
    testWidgets('you reminders $suffix', (tester) async {
      await screen(
        tester,
        'you_03_reminders',
        const RemindersScreen(),
        size: const Size(390, 1500),
      );
    });
    testWidgets('you appearance $suffix', (tester) async {
      await screen(
        tester,
        'you_04_appearance',
        const AppearanceScreen(),
        size: const Size(390, 844),
      );
    });
    testWidgets('you data $suffix', (tester) async {
      await screen(
        tester,
        'you_05_data',
        const DataScreen(),
        size: const Size(390, 1200),
      );
    });
    testWidgets('you support $suffix', (tester) async {
      await screen(
        tester,
        'you_06_support',
        const SupportScreen(),
        size: const Size(390, 1100),
      );
    });
  }
}
