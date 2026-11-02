// Step 3 audit fixes (docs/plans/evolve.md, Step 3), on screen:
// * S3-m3 — Dictate's "Type instead" puts the cursor in its field on every
//   host (the reset answer, the Try note, the weekly review, an attempt and
//   the new attempt form).
// * S3-m4 — the battle log's new attempt form has Dictate under both fields,
//   reviewed before it goes in, autosaved as the draft.
// * S3-m6 — the user's words keep their own direction: text fields follow
//   what is typed, and past answers, try notes, attempts and learnings,
//   project names and the Compass show in the words' direction in either
//   app language.
// The section pills (S3-m1) are tested in test/ui/rtl_test.dart, the logic
// (S3-m2) in test/evolve3_fixes_test.dart.
import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/services/dictation.dart';
import 'package:cartharise/ui/campaign/attempt_sheet.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/campaign/campaign_pages.dart';
import 'package:cartharise/ui/campaign/try_screen.dart';
import 'package:cartharise/ui/journal/past_reset_screen.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/voice/dictate_button.dart';
import 'package:cartharise/ui/voice/dictation_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

final _t = DateTime(2026, 11, 2, 20, 15);

/// Taps [f], scrolling it into view first.
Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await pumpFrames(tester);
}

TextField _field(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field);

/// The Dictate link under [field] (the DictateButton writing into the same
/// controller).
Finder _dictateFor(WidgetTester tester, Finder field) {
  final controller = _field(tester, field).controller;
  return find.descendant(
    of: find.byWidgetPredicate(
      (w) => w is DictateButton && w.controller == controller,
    ),
    matching: find.byType(TextButton),
  );
}

/// A page with one button that opens [open] (sheets need a route below).
Widget _opener(Future<void> Function(BuildContext) open) => Scaffold(
  body: Builder(
    builder: (context) => Center(
      child: TextButton(
        key: const ValueKey('open'),
        onPressed: () => open(context),
        child: const Text('Open'),
      ),
    ),
  ),
);

/// Dictates [words] (the recognizer's final text), stops, and inserts.
Future<void> _dictateWords(
  WidgetTester tester,
  CarthaHarness h,
  Finder field,
  String words,
) async {
  await _tap(tester, _dictateFor(tester, field));
  h.dictation.partial(words);
  h.dictation.finalText = words;
  await pumpFrames(tester, count: 2);
  await _tap(tester, _key('dictation-stop'));
  await _tap(tester, _key('dictation-insert'));
}

/// The left edges of [a] and [b] (substrings of [paragraph]'s text) as laid
/// out: which one is drawn further left.
(double, double) _lefts(RenderParagraph paragraph, String a, String b) {
  final text = paragraph.text.toPlainText();
  double left(String part) {
    final at = text.lastIndexOf(part);
    expect(at, isNonNegative, reason: '"$part" in "$text"');
    return paragraph
        .getBoxesForSelection(
          TextSelection(baseOffset: at, extentOffset: at + part.length),
        )
        .map((box) => box.left)
        .reduce((x, y) => x < y ? x : y);
  }

  return (left(a), left(b));
}

AppData _arabic(AppData data) =>
    data.copyWith(settings: data.settings.copyWith(language: AppLanguage.ar));

Future<CarthaHarness> _pumpReal(
  WidgetTester tester, {
  required AppData data,
  required Widget home,
  Size size = const Size(390, 844),
  FakeDictation? dictation,
}) => pumpCartha(
  tester,
  data: data,
  home: home,
  size: size,
  dictation: dictation,
  content: englishContent,
  contentFor: contentFor,
);

void main() {
  group('S3-m3: Type instead puts the cursor in the field', () {
    final attempt = BattleLogEntry(
      id: 'a1',
      day: '2026-11-02',
      attempt: 'Wrote the first page',
      createdAt: _t,
    );
    final hosts = <(String, Widget, AppData, bool, List<String>)>[
      (
        'the reset answer',
        const GuidedPromptScreen(promptId: 'morning.02'),
        onboardedData(),
        false,
        ['reset-answer'],
      ),
      (
        'the Try note',
        const TryScreen(experimentId: 'try.terrain.01'),
        onboardedData(),
        false,
        ['try-note'],
      ),
      (
        'the weekly review',
        const ReviewScreen(),
        onboardedData(),
        false,
        ['review-wins', 'review-friction', 'review-next'],
      ),
      (
        'an attempt (edit sheet)',
        _opener((c) => showAttemptSheet(c, attempt)),
        onboardedData().copyWith(campaignLog: [attempt]),
        true,
        ['attempt-edit-attempt', 'attempt-edit-learning'],
      ),
      (
        'the new attempt form',
        const BattleLogScreen(),
        onboardedData(),
        false,
        ['campaign-attempt', 'campaign-learning'],
      ),
    ];
    for (final (name, home, data, sheet, fields) in hosts) {
      testWidgets('$name: unavailable → Type instead → the field has focus', (
        tester,
      ) async {
        await pumpCartha(
          tester,
          data: data,
          home: home,
          size: const Size(390, 1400),
          dictation: FakeDictation(
            availabilityDefault: DictationAvailability.unsupported,
          ),
        );
        if (sheet) await _tap(tester, _key('open'));
        for (final key in fields) {
          final field = _key(key);
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pump();
          expect(_field(tester, field).focusNode, isNotNull, reason: key);
          expect(_field(tester, field).focusNode!.hasFocus, isFalse);
          await _tap(tester, _dictateFor(tester, field));
          expect(find.byType(DictationSheet), findsOneWidget);
          await _tap(tester, _key('dictation-type-instead'));
          expect(find.byType(DictationSheet), findsNothing);
          expect(
            _field(tester, field).focusNode!.hasFocus,
            isTrue,
            reason: '$key is ready for the keyboard',
          );
        }
      });
    }
  });

  group('S3-m4: the new attempt form has Dictate', () {
    testWidgets('one named Dictate per field; reviewed, inserted, autosaved '
        'as the draft, then recorded exactly', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        size: const Size(390, 1400),
        home: const BattleLogScreen(),
      );
      expect(
        find.bySemanticsLabel('Dictate: What did you actually try?'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Dictate: What did you learn? (optional)'),
        findsOneWidget,
      );
      await tester.enterText(_key('campaign-attempt'), 'Wrote');
      await tester.pump();
      await _dictateWords(
        tester,
        h,
        _key('campaign-attempt'),
        'the first page before work',
      );
      expect(
        _field(tester, _key('campaign-attempt')).controller!.text,
        'Wrote the first page before work',
      );
      await _dictateWords(
        tester,
        h,
        _key('campaign-learning'),
        'Mornings work better',
      );
      // The draft is kept as if typed (debounced).
      await tester.pump(const Duration(seconds: 1));
      expect(h.state.attemptDraft?.attempt, 'Wrote the first page before work');
      expect(h.state.attemptDraft?.learning, 'Mornings work better');

      await _tap(tester, _key('campaign-record'));
      final saved = h.state.data.campaignLog.single;
      expect(saved.attempt, 'Wrote the first page before work');
      expect(saved.learning, 'Mornings work better');
      expect(h.state.attemptDraft, isNull);
      semantics.dispose();
    });

    testWidgets('unavailable: Type instead, and no Record instead (the '
        'attempt holds no voice notes before it is recorded)', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        size: const Size(390, 1400),
        home: const BattleLogScreen(),
        dictation: FakeDictation(
          availabilityDefault: DictationAvailability.needsModel,
        ),
      );
      await _tap(tester, _dictateFor(tester, _key('campaign-attempt')));
      expect(_key('dictation-type-instead'), findsOneWidget);
      expect(_key('dictation-record-instead'), findsNothing);
    });
  });

  group('S3-m6: the user\'s words keep their own direction', () {
    testWidgets('a text field follows what is typed: English in the Arabic '
        'app runs left to right, its full stop at its end', (tester) async {
      final data = _arabic(onboardedData()).copyWith(
        journeys: [
          Journey(
            id: 'j',
            startedAt: _t,
            activePromptId: 'morning.02',
            answers: {
              'morning.02': ReflectionAnswer(
                promptId: 'morning.02',
                body: 'My commute is too long (45 min).',
                updatedAt: _t,
              ),
            },
          ),
        ],
        currentJourneyId: () => 'j',
      );
      final harness = await _pumpReal(
        tester,
        data: data,
        home: const GuidedPromptScreen(promptId: 'morning.02'),
      );
      final field = _key('reset-answer');
      expect(
        Directionality.of(tester.element(field)),
        TextDirection.rtl,
        reason: 'the app is in Arabic',
      );
      expect(_field(tester, field).textDirection, TextDirection.ltr);
      final editable = tester
          .state<EditableTextState>(
            find.descendant(of: field, matching: find.byType(EditableText)),
          )
          .renderEditable;
      final stop = editable
          .getBoxesForSelection(
            const TextSelection(baseOffset: 31, extentOffset: 32),
          )
          .single;
      final words = editable
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 2),
          )
          .single;
      expect(stop.left, greaterThan(words.right), reason: '"." after "min)"');

      // Arabic typed instead: right to left; nothing typed: the app's.
      await tester.enterText(field, 'أتصفّح الهاتف.');
      await tester.pump();
      expect(_field(tester, field).textDirection, TextDirection.rtl);
      await tester.enterText(field, '45');
      await tester.pump();
      expect(_field(tester, field).textDirection, isNull);
      // What was typed is saved exactly.
      await tester.enterText(field, 'Walk 20 min.');
      await tester.pump(const Duration(seconds: 2));
      expect(harness.state.answer('morning.02')?.body, 'Walk 20 min.');
    });

    testWidgets('an Arabic note in the English app reads right to left in '
        'every field', (tester) async {
      final attempt = BattleLogEntry(
        id: 'a1',
        day: '2026-11-02',
        attempt: 'كتبت الصفحة الأولى',
        createdAt: _t,
      );
      await pumpCartha(
        tester,
        data: onboardedData().copyWith(campaignLog: [attempt]),
        home: _opener((c) => showAttemptSheet(c, attempt)),
      );
      await _tap(tester, _key('open'));
      expect(
        _field(tester, _key('attempt-edit-attempt')).textDirection,
        TextDirection.rtl,
      );
      expect(
        _field(tester, _key('attempt-edit-learning')).textDirection,
        isNull,
        reason: 'empty: the app\'s direction',
      );
    });

    testWidgets('a past English answer in the Arabic app reads left to right', (
      tester,
    ) async {
      const answer = 'My commute is too long (45 min).';
      final data = _arabic(onboardedData()).copyWith(
        journeys: [
          Journey(
            id: 'journey_before',
            startedAt: DateTime(2026, 10, 1, 8),
            completedAt: DateTime(2026, 10, 1, 21),
            answers: {
              'morning.01': ReflectionAnswer(
                promptId: 'morning.01',
                body: answer,
                updatedAt: _t,
              ),
              'morning.02': ReflectionAnswer(
                promptId: 'morning.02',
                body: 'أتصفّح الهاتف حتى وقت متأخر.',
                updatedAt: _t,
              ),
            },
          ),
        ],
      );
      await _pumpReal(
        tester,
        data: data,
        home: const PastResetScreen(journeyId: 'journey_before'),
        size: const Size(390, 1600),
      );
      SelectableText shown(String text) => tester.widget<SelectableText>(
        find.byWidgetPredicate((w) => w is SelectableText && w.data == text),
      );
      expect(shown(answer).textDirection, TextDirection.ltr);
      expect(
        shown('أتصفّح الهاتف حتى وقت متأخر.').textDirection,
        TextDirection.rtl,
      );
    });

    testWidgets('in the Arabic app: an English attempt reads left to right '
        'and an English learning keeps its full stop at its end', (
      tester,
    ) async {
      final data = _arabic(onboardedData()).copyWith(
        campaignLog: [
          BattleLogEntry(
            id: 'a1',
            day: '2026-11-02',
            attempt: 'Wrote the first page (draft).',
            learning: 'Mornings work better.',
            createdAt: _t,
          ),
        ],
      );
      await _pumpReal(
        tester,
        data: data,
        home: const BattleLogScreen(),
        size: const Size(390, 1400),
      );
      expect(
        tester
            .renderObject<RenderParagraph>(
              find.text('Wrote the first page (draft).'),
            )
            .textDirection,
        TextDirection.ltr,
      );
      // The app's label stays Arabic and right to left; the learning sits
      // inside it in its own direction.
      final learned = find.textContaining('Mornings work better.');
      final paragraph = tester.renderObject<RenderParagraph>(learned);
      expect(paragraph.textDirection, TextDirection.rtl);
      expect(
        paragraph.text.toPlainText(),
        contains('\u2068Mornings work better.\u2069'),
      );
      final (better, stop) = _lefts(paragraph, 'better', '.');
      expect(stop, greaterThan(better), reason: '"." after "better"');
    });

    testWidgets('in the English app: an Arabic try note, attempt and '
        'learning read right to left; English words stay as they were', (
      tester,
    ) async {
      final data = onboardedData().copyWith(
        experimentLog: [
          ExperimentEntry(
            id: 'e1',
            experimentId: 'try.terrain.01',
            day: '2026-11-02',
            note: 'تركت الهاتف في الدرج.',
            createdAt: _t,
          ),
        ],
        campaignLog: [
          BattleLogEntry(
            id: 'a1',
            day: '2026-11-02',
            attempt: 'كتبت الصفحة الأولى.',
            learning: 'الصباح أفضل.',
            createdAt: _t,
          ),
          BattleLogEntry(
            id: 'a2',
            day: '2026-11-01',
            attempt: 'Walked',
            learning: 'Start small.',
            createdAt: _t,
          ),
        ],
      );
      await pumpCartha(
        tester,
        data: data,
        home: campaignPageScreen(CampaignPage.collection),
        size: const Size(390, 1600),
      );
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('تركت الهاتف في الدرج.'))
            .textDirection,
        TextDirection.rtl,
      );

      await pumpCartha(
        tester,
        data: data,
        home: const BattleLogScreen(),
        size: const Size(390, 1600),
      );
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('كتبت الصفحة الأولى.'))
            .textDirection,
        TextDirection.rtl,
      );
      expect(
        find.text('Learned: \u2068الصباح أفضل.\u2069'),
        findsOneWidget,
        reason: 'isolated inside the English sentence',
      );
      // Words running the app's way are shown exactly, with nothing added.
      expect(find.text('Learned: Start small.'), findsOneWidget);
      expect(
        tester.renderObject<RenderParagraph>(find.text('Walked')).textDirection,
        TextDirection.ltr,
      );
    });
  });
}
