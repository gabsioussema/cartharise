// Renders Dictate (step 3 › G) to PNGs for design review against
// "Cartharise Brand and App System Board.png" (not CI): the link under a
// note, listening with the words heard so far, the review before Insert,
// the honest "can't dictate here" line, and Arabic right to left.
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/services/dictation.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _t = DateTime(2026, 11, 2, 20, 15);

AppData _data({AppSettings? settings}) =>
    onboardedData(settings: settings).copyWith(
      journal: [
        JournalEntry(
          id: 'n1',
          title: 'Evening walk',
          body:
              'I think more clearly outside. The hill path, no phone, '
              'twenty minutes.',
          createdAt: _t,
        ),
      ],
    );

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _link(String key) =>
    find.descendant(of: _key(key), matching: find.byType(TextButton));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await pumpFrames(tester);
  await tester.tap(f);
  await pumpFrames(tester);
}

const _heard =
    'Tomorrow I want to take the same path again, and leave the phone at '
    'home';

void main() {
  for (final b in Brightness.values) {
    final suffix = b.name;

    Future<CarthaHarness> pump(
      WidgetTester tester, {
      FakeDictation? dictation,
      AppSettings? settings,
      Widget home = const JournalEntryScreen(entryId: 'n1'),
    }) => pumpCartha(
      tester,
      brightness: b,
      data: _data(settings: settings),
      content: englishContent,
      dictation: dictation,
      home: home,
    );

    testWidgets('dictation link $suffix', (tester) async {
      await pump(
        tester,
        home: const GuidedPromptScreen(promptId: 'morning.01'),
      );
      await tester.ensureVisible(_link('reset-answer-dictate'));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'dictation_01_link_$suffix');
    });

    testWidgets('dictation listening $suffix', (tester) async {
      final h = await pump(tester);
      await _tap(tester, _link('journal-entry-dictate'));
      h.dictation
        ..partial(_heard)
        ..level(0.55);
      await pumpFrames(tester, count: 2);
      await captureScreenshot(tester, 'dictation_02_listening_$suffix');
    });

    testWidgets('dictation review $suffix', (tester) async {
      final h = await pump(tester);
      await _tap(tester, _link('journal-entry-dictate'));
      h.dictation
        ..partial(_heard)
        ..finalText = '$_heard.';
      await pumpFrames(tester, count: 2);
      await _tap(tester, _key('dictation-stop'));
      await captureScreenshot(tester, 'dictation_03_review_$suffix');
    });

    testWidgets('dictation unavailable $suffix', (tester) async {
      await pump(
        tester,
        dictation: FakeDictation(
          availabilityDefault: DictationAvailability.needsModel,
        ),
      );
      await _tap(tester, _link('journal-entry-dictate'));
      await captureScreenshot(tester, 'dictation_04_unavailable_$suffix');
    });

    testWidgets('dictation stopped early $suffix', (tester) async {
      final h = await pump(tester);
      await _tap(tester, _link('journal-entry-dictate'));
      h.dictation.partial('Tomorrow I want to take the same path');
      await pumpFrames(tester, count: 2);
      await h.dictation.fail(DictationFailure.interrupted);
      await pumpFrames(tester);
      await captureScreenshot(tester, 'dictation_05_stopped_early_$suffix');
    });

    testWidgets('dictation arabic $suffix', (tester) async {
      final h = await pump(
        tester,
        settings: const AppSettings(language: AppLanguage.ar),
      );
      await _tap(tester, _link('journal-entry-dictate'));
      h.dictation
        ..partial('غدًا أريد أن أسلك الطريق نفسه وأترك الهاتف في البيت')
        ..level(0.4);
      await pumpFrames(tester, count: 2);
      await captureScreenshot(tester, 'dictation_06_arabic_$suffix');
    });
  }
}
