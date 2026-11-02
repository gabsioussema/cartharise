// Step 3 › G "dictation" (docs/plans/evolve.md): **Dictate** under the
// fields people write in — speak, see the words live, Stop, check the text,
// then Insert puts it at the cursor (never on its own). Every way the phone
// can't dictate is one honest line with Record or type instead; failures
// keep what was heard; back and the app going away never drop words; screen
// readers hear the state. The hooks: the reset answer, a journal note, the
// Try note, a try's note, an attempt, a path day, the weekly review. Sizes,
// themes, right to left and accessibility.
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/services/dictation.dart';
import 'package:cartharise/ui/campaign/attempt_sheet.dart';
import 'package:cartharise/ui/campaign/experiment_entry_sheet.dart';
import 'package:cartharise/ui/campaign/try_screen.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:cartharise/ui/media/recorder_sheet.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/voice/dictate_button.dart';
import 'package:cartharise/ui/voice/dictation_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

final _t = DateTime(2026, 11, 2, 20, 15);

/// One field with **Dictate** under it (the shape every hook has).
class _Field extends StatefulWidget {
  const _Field({
    this.initial = '',
    this.selection,
    this.recordInstead,
    this.inserted,
  });

  final String initial;
  final TextSelection? selection;
  final KeepRecording? recordInstead;
  final List<String>? inserted;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final _controller = TextEditingController(text: widget.initial);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    final selection = widget.selection;
    if (selection != null) _controller.selection = selection;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: ListView(
      padding: const EdgeInsetsDirectional.all(20),
      children: [
        TextField(
          key: const ValueKey('field'),
          controller: _controller,
          focusNode: _focus,
          minLines: 3,
          maxLines: null,
          decoration: const InputDecoration(labelText: 'Your words'),
        ),
        DictateButton(
          key: const ValueKey('dictate'),
          controller: _controller,
          focusNode: _focus,
          recordInstead: widget.recordInstead,
          onInserted: widget.inserted?.add,
        ),
      ],
    ),
  );
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(_key('field')).controller!.text;

TextSelection _fieldSelection(WidgetTester tester) =>
    tester.widget<TextField>(_key('field')).controller!.selection;

String _reviewText(WidgetTester tester) =>
    tester.widget<TextField>(_key('dictation-review')).controller!.text;

Future<CarthaHarness> _field(
  WidgetTester tester, {
  String initial = '',
  TextSelection? selection,
  KeepRecording? recordInstead,
  List<String>? inserted,
  FakeDictation? dictation,
  Size size = const Size(390, 844),
  double textScale = 1,
  Brightness brightness = Brightness.dark,
  AppData? data,
}) => pumpCartha(
  tester,
  data: data ?? onboardedData(),
  dictation: dictation,
  size: size,
  textScale: textScale,
  brightness: brightness,
  home: _Field(
    initial: initial,
    selection: selection,
    recordInstead: recordInstead,
    inserted: inserted,
  ),
);

/// Taps [f], scrolling the page first when it is below the fold.
Future<void> _tap(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await pumpFrames(tester);
}

/// The Dictate link (at the start of its line) of the DictateButton [key].
Finder _dictateLink([String key = 'dictate']) =>
    find.descendant(of: _key(key), matching: find.byType(TextButton));

Future<void> _dictate(WidgetTester tester, [String key = 'dictate']) =>
    _tap(tester, _dictateLink(key));

/// Screen-reader announcements made from now on.
List<String> _announcements(WidgetTester tester) {
  final said = <String>[];
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockDecodedMessageHandler<Object?>(
    SystemChannels.accessibility,
    (message) async {
      if (message is Map && message['type'] == 'announce') {
        said.add((message['data'] as Map)['message'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => messenger.setMockDecodedMessageHandler<Object?>(
      SystemChannels.accessibility,
      null,
    ),
  );
  return said;
}

/// Bars of the level meter lit in the accent colour.
int _lit(WidgetTester tester) {
  final palette = CarthaPalette.of(tester.element(_key('dictation-level')));
  return tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: _key('dictation-level'),
          matching: find.byType(DecoratedBox),
        ),
      )
      .where((b) => (b.decoration as BoxDecoration).color == palette.accent)
      .length;
}

Future<void> _expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

/// Dictates [words] (the recognizer's final text) and stops: the review.
Future<void> _speakAndStop(
  WidgetTester tester,
  CarthaHarness h,
  String words,
) async {
  h.dictation.partial(words);
  h.dictation.finalText = words;
  await pumpFrames(tester, count: 2);
  await _tap(tester, _key('dictation-stop'));
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

void main() {
  group('insertDictation: at the cursor, nothing else changed', () {
    TextEditingValue v(String text, [TextSelection? selection]) =>
        TextEditingValue(
          text: text,
          selection: selection ?? const TextSelection.collapsed(offset: -1),
        );

    test('an empty field, no cursor yet', () {
      final r = insertDictation(v(''), 'I saw the sea');
      expect(r.text, 'I saw the sea');
      expect(r.selection, const TextSelection.collapsed(offset: 13));
    });

    test(
      'no cursor yet: at the end, one space so words never run together',
      () {
        expect(
          insertDictation(v('Morning.'), 'Then tea').text,
          'Morning. Then tea',
        );
        expect(
          insertDictation(v('Morning. '), 'Then tea').text,
          'Morning. Then tea',
        );
        expect(
          insertDictation(v('Morning.\n'), 'Then tea').text,
          'Morning.\nThen tea',
        );
      },
    );

    test('a cursor in the middle: spaces only where a word would touch', () {
      final r = insertDictation(
        v(
          'Morning walk. Then breakfast.',
          const TextSelection.collapsed(offset: 13),
        ),
        'I saw the sea',
      );
      expect(r.text, 'Morning walk. I saw the sea Then breakfast.');
      expect(r.selection, const TextSelection.collapsed(offset: 27));
      final start = insertDictation(
        v('world', const TextSelection.collapsed(offset: 0)),
        'Hello',
      );
      expect(start.text, 'Hello world');
      expect(start.selection.baseOffset, 5);
    });

    test('words selected stay; the text goes right after them', () {
      final r = insertDictation(
        v('one two three', const TextSelection(baseOffset: 4, extentOffset: 7)),
        'and a half',
      );
      expect(r.text, 'one two and a half three');
      expect(r.selection, const TextSelection.collapsed(offset: 18));
    });

    test('the dictated text itself is inserted exactly (Arabic too)', () {
      expect(insertDictation(v('صباح'), 'الخير').text, 'صباح الخير');
      expect(insertDictation(v('a'), '  spaced  ').text, 'a  spaced  ');
      final same = v('kept', const TextSelection.collapsed(offset: 2));
      expect(insertDictation(same, ''), same);
    });
  });

  group('Dictate', () {
    testWidgets('speak, see the words live, Stop, check them, then Insert '
        'puts them at the cursor — never on their own', (tester) async {
      final said = _announcements(tester);
      final inserted = <String>[];
      final h = await _field(
        tester,
        initial: 'Morning walk. Then breakfast.',
        selection: const TextSelection.collapsed(offset: 13),
        inserted: inserted,
      );
      await _dictate(tester);
      // Checked first without asking anything, then started in the app's
      // language.
      expect(h.dictation.checked, ['en']);
      expect(h.dictation.started, ['en']);
      expect(h.dictation.isListening, isTrue);
      expect(find.byType(DictationSheet), findsOneWidget);
      expect(find.text('Listening'), findsOneWidget);
      expect(
        find.text('Recognised on this phone. Nothing is sent.'),
        findsOneWidget,
      );
      expect(find.text('Speak. Your words appear here.'), findsOneWidget);
      expect(said, ["Listening. Tap Stop when you're done."]);

      h.dictation.partial('I saw');
      await pumpFrames(tester, count: 2);
      expect(
        find.descendant(
          of: _key('dictation-heard'),
          matching: find.text('I saw'),
        ),
        findsOneWidget,
      );
      expect(_lit(tester), 0);
      h.dictation.level(0.5);
      await pumpFrames(tester, count: 2);
      expect(_lit(tester), 10);
      h.dictation.partial('I saw the sea and');
      await pumpFrames(tester, count: 2);
      expect(find.text('I saw the sea and'), findsOneWidget);
      // Nothing reaches the field while listening.
      expect(_fieldText(tester), 'Morning walk. Then breakfast.');

      h.dictation.finalText = 'I saw the sea and';
      await _tap(tester, _key('dictation-stop'));
      expect(h.dictation.stopCount, 1);
      expect(h.dictation.isListening, isFalse);
      expect(_reviewText(tester), 'I saw the sea and');
      expect(said.last, 'Done listening. Check the text, then Insert.');
      expect(
        find.text('Edit it if you like. It goes in only when you tap Insert.'),
        findsOneWidget,
      );
      // The final text waits for review: still not in the field.
      expect(_fieldText(tester), 'Morning walk. Then breakfast.');
      expect(inserted, isEmpty);

      await tester.enterText(_key('dictation-review'), 'I saw the sea');
      await tester.pump();
      await _tap(tester, _key('dictation-insert'));
      expect(find.byType(DictationSheet), findsNothing);
      expect(_fieldText(tester), 'Morning walk. I saw the sea Then breakfast.');
      expect(
        _fieldSelection(tester),
        const TextSelection.collapsed(offset: 27),
      );
      expect(inserted, ['Morning walk. I saw the sea Then breakfast.']);
      expect(said.last, 'Text inserted.');
    });

    testWidgets('Discard asks first and inserts nothing; Keep goes back to '
        'the text', (tester) async {
      final inserted = <String>[];
      final h = await _field(tester, initial: 'Mine.', inserted: inserted);
      await _dictate(tester);
      await _speakAndStop(tester, h, 'Not this');
      await _tap(tester, _key('dictation-discard'));
      expect(find.text('Discard this text?'), findsOneWidget);
      expect(find.text("It won't be added."), findsOneWidget);
      await _tap(tester, find.text('Keep'));
      expect(_reviewText(tester), 'Not this');

      await _tap(tester, _key('dictation-discard'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Discard'));
      expect(find.byType(DictationSheet), findsNothing);
      expect(_fieldText(tester), 'Mine.');
      expect(inserted, isEmpty);
    });

    testWidgets('Insert is off while the text is empty', (tester) async {
      final h = await _field(tester);
      await _dictate(tester);
      await _speakAndStop(tester, h, 'Something');
      await tester.enterText(_key('dictation-review'), '   ');
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(
              find.descendant(
                of: _key('dictation-insert'),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('Cancel: nothing heard closes at once; words heard are '
        'asked about first', (tester) async {
      final h = await _field(tester, initial: 'Mine.');
      await _dictate(tester);
      await _tap(tester, _key('dictation-cancel'));
      expect(find.byType(DictationSheet), findsNothing);
      expect(h.dictation.cancelCount, 1);
      expect(h.dictation.isListening, isFalse);

      await _dictate(tester);
      h.dictation.partial('Half a thought');
      await pumpFrames(tester, count: 2);
      await _tap(tester, _key('dictation-cancel'));
      expect(find.text('Discard this text?'), findsOneWidget);
      await _tap(tester, find.text('Keep'));
      // Still listening: nothing was lost.
      expect(h.dictation.isListening, isTrue);
      expect(find.text('Half a thought'), findsOneWidget);
      await _tap(tester, _key('dictation-cancel'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Discard'));
      expect(find.byType(DictationSheet), findsNothing);
      expect(h.dictation.cancelCount, 2);
      expect(_fieldText(tester), 'Mine.');
    });

    for (final (availability, line, retry) in [
      (
        DictationAvailability.needsModel,
        "To dictate, add this language for offline speech in your phone's "
            'settings.',
        true,
      ),
      (
        DictationAvailability.unsupported,
        "Dictation in this language isn't available on this phone.",
        false,
      ),
      (
        DictationAvailability.noPermission,
        'Microphone or speech access is off. Allow it in Settings to dictate.',
        true,
      ),
      (
        DictationAvailability.tooOld,
        'Dictation needs a newer system version on this phone.',
        false,
      ),
    ]) {
      testWidgets('${availability.name}: one honest line, Record or type '
          'instead, nothing started', (tester) async {
        final h = await _field(
          tester,
          dictation: FakeDictation(availabilityDefault: availability),
          recordInstead: (_) async => true,
        );
        await _dictate(tester);
        expect(h.dictation.checked, ['en']);
        expect(h.dictation.started, isEmpty, reason: 'never started');
        expect(find.text(line), findsOneWidget);
        expect(find.text('Listening'), findsNothing);
        expect(_key('dictation-record-instead'), findsOneWidget);
        expect(_key('dictation-type-instead'), findsOneWidget);
        expect(_key('dictation-retry'), retry ? findsOneWidget : findsNothing);
        await _expectAccessible(tester);

        // Type instead: the field, ready for the keyboard.
        await _tap(tester, _key('dictation-type-instead'));
        expect(find.byType(DictationSheet), findsNothing);
        expect(
          tester.widget<TextField>(_key('field')).focusNode!.hasFocus,
          isTrue,
        );
      });
    }

    testWidgets('no Record instead where the field holds no recordings', (
      tester,
    ) async {
      await _field(
        tester,
        dictation: FakeDictation(
          availabilityDefault: DictationAvailability.unsupported,
        ),
      );
      await _dictate(tester);
      expect(_key('dictation-record-instead'), findsNothing);
      expect(_key('dictation-type-instead'), findsOneWidget);
    });

    testWidgets('Record instead opens the recorder; the voice note is kept '
        'where the field is', (tester) async {
      final kept = <Attachment>[];
      final h = await _field(
        tester,
        dictation: FakeDictation(
          availabilityDefault: DictationAvailability.unsupported,
        ),
        recordInstead: (a) async {
          kept.add(a);
          return true;
        },
      );
      await _dictate(tester);
      await _tap(tester, _key('dictation-record-instead'));
      expect(find.byType(DictationSheet), findsNothing);
      expect(find.byType(RecorderSheet), findsOneWidget);
      expect(h.recorder.started, hasLength(1));
      await _tap(tester, _key('recorder-stop'));
      expect(kept.single.kind, AttachmentKind.audio);
      expect(kept.single.transcript, isNull, reason: 'kept apart from text');
      expect(_fieldText(tester), '');
    });

    testWidgets('refused when asked: said plainly; Try again asks again', (
      tester,
    ) async {
      final h = await _field(tester);
      await _dictate(tester);
      await h.dictation.fail(DictationFailure.noPermission);
      await pumpFrames(tester);
      expect(
        find.text(
          'Microphone or speech access is off. Allow it in Settings to '
          'dictate.',
        ),
        findsOneWidget,
      );
      await _tap(tester, _key('dictation-retry'));
      expect(h.dictation.started, ['en', 'en']);
      expect(find.text('Listening'), findsOneWidget);
    });

    testWidgets('a failure keeps the words heard for review, and says so', (
      tester,
    ) async {
      final inserted = <String>[];
      final h = await _field(tester, inserted: inserted);
      await _dictate(tester);
      h.dictation.partial('The part before the call');
      await pumpFrames(tester, count: 2);
      await h.dictation.fail(DictationFailure.interrupted);
      await pumpFrames(tester);
      expect(_key('dictation-stopped-early'), findsOneWidget);
      expect(
        find.text("Dictation stopped early. Here's what was heard."),
        findsOneWidget,
      );
      expect(_reviewText(tester), 'The part before the call');
      expect(inserted, isEmpty);
      await _tap(tester, _key('dictation-insert'));
      expect(_fieldText(tester), 'The part before the call');
    });

    for (final (failure, line) in [
      (
        DictationFailure.interrupted,
        'Dictation stopped: a call or another app took the microphone.',
      ),
      (
        DictationFailure.noSpeech,
        'Nothing was heard. Try again, or type '
            'instead.',
      ),
      (DictationFailure.busy, 'Dictation is busy. Try again in a moment.'),
      (
        DictationFailure.failed,
        'Dictation stopped. Try again, or type '
            'instead.',
      ),
      (
        DictationFailure.needsModel,
        "To dictate, add this language for offline speech in your phone's "
            'settings.',
      ),
    ]) {
      testWidgets('${failure.name} with nothing heard: the reason, in one '
          'line', (tester) async {
        final h = await _field(tester);
        await _dictate(tester);
        await h.dictation.fail(failure);
        await pumpFrames(tester);
        expect(find.text(line), findsOneWidget);
        expect(_key('dictation-review'), findsNothing);
        expect(_key('dictation-retry'), findsOneWidget);
        expect(_key('dictation-type-instead'), findsOneWidget);
      });
    }

    testWidgets('Stop with nothing heard says so; a partial without a final '
        'text is kept', (tester) async {
      final h = await _field(tester);
      await _dictate(tester);
      await _tap(tester, _key('dictation-stop'));
      expect(
        find.text('Nothing was heard. Try again, or type instead.'),
        findsOneWidget,
      );
      await _tap(tester, _key('dictation-retry'));
      h.dictation.partial('Only a partial');
      await pumpFrames(tester, count: 2);
      await _tap(tester, _key('dictation-stop'));
      expect(_reviewText(tester), 'Only a partial');
      expect(_key('dictation-stopped-early'), findsNothing);
    });

    testWidgets('the app hidden while listening: stopped, the words wait for '
        'review', (tester) async {
      final h = await _field(tester);
      await _dictate(tester);
      h.dictation.partial('Before the phone rang');
      h.dictation.finalText = 'Before the phone rang';
      await pumpFrames(tester, count: 2);
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      expect(h.dictation.stopCount, 1);
      // Back in the app: the words are there to check.
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await pumpFrames(tester);
      expect(_reviewText(tester), 'Before the phone rang');
      expect(_fieldText(tester), '');
    });

    testWidgets('Back while listening stops (never drops words); Back in '
        'review asks first', (tester) async {
      final h = await _field(tester);
      await _dictate(tester);
      h.dictation.partial('Kept words');
      h.dictation.finalText = 'Kept words';
      await pumpFrames(tester, count: 2);
      await tester.binding.handlePopRoute();
      await pumpFrames(tester);
      expect(h.dictation.stopCount, 1);
      expect(_reviewText(tester), 'Kept words');

      await tester.binding.handlePopRoute();
      await pumpFrames(tester);
      expect(find.text('Discard this text?'), findsOneWidget);
      await _tap(tester, find.text('Keep'));
      expect(_reviewText(tester), 'Kept words');
    });

    testWidgets('closed from elsewhere while listening: the microphone stops, '
        'nothing is inserted', (tester) async {
      final h = await _field(tester, initial: 'Mine.');
      await _dictate(tester);
      h.dictation.partial('Not inserted');
      await pumpFrames(tester, count: 2);
      Navigator.of(tester.element(find.byType(DictationSheet))).pop();
      await pumpFrames(tester);
      expect(h.dictation.cancelCount, 1);
      expect(h.dictation.isListening, isFalse);
      expect(_fieldText(tester), 'Mine.');
    });

    testWidgets('screen readers: the button says what it does; the sheet is '
        'labelled and every control reachable', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await _field(tester);
      expect(
        tester.getSemantics(_dictateLink()),
        matchesSemantics(
          label: 'Dictate',
          hint: 'Speak, then check the text before it goes in.',
          isButton: true,
          hasTapAction: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );
      await _dictate(tester);
      h.dictation.partial('Words heard');
      await pumpFrames(tester, count: 2);
      expect(find.bySemanticsLabel(RegExp('Heard so far')), findsOneWidget);
      await _expectAccessible(tester);
      await _speakAndStop(tester, h, 'Words heard');
      await _expectAccessible(tester);
      semantics.dispose();
    });

    testWidgets('Arabic: right to left, dictated in Arabic', (tester) async {
      final h = await _field(
        tester,
        data: onboardedData(
          settings: const AppSettings(language: AppLanguage.ar),
        ),
      );
      final button = find.descendant(
        of: find.byType(DictateButton),
        matching: find.byType(TextButton),
      );
      // Start is the right in Arabic.
      expect(tester.getTopRight(button).dx, greaterThan(390 / 2));
      await _dictate(tester);
      expect(h.dictation.started, ['ar']);
      expect(
        Directionality.of(tester.element(find.byType(DictationSheet))),
        TextDirection.rtl,
      );
      await _speakAndStop(tester, h, 'صباح الخير');
      await _tap(tester, _key('dictation-insert'));
      expect(_fieldText(tester), 'صباح الخير');
      expect(tester.takeException(), isNull);
    });

    group('fits every screen', () {
      const long =
          'Today I walked down to the harbour before work and noticed how '
          'much calmer I feel when the phone stays at home. I want to keep '
          'that quiet hour, even on busy days, and write about it at night.';
      for (final size in kSizeMatrix) {
        for (final brightness in Brightness.values) {
          testWidgets('$size (${brightness.name})', (tester) async {
            final h = await _field(
              tester,
              size: size.size,
              textScale: size.textScale,
              brightness: brightness,
              initial: long,
            );
            await expectNoOverflow(tester);
            await _dictate(tester);
            h.dictation.partial(long);
            h.dictation.level(0.7);
            await pumpFrames(tester, count: 2);
            await expectNoOverflow(tester);
            h.dictation.finalText = long;
            await _tap(tester, _key('dictation-stop'));
            expect(_reviewText(tester), long);
            await expectNoOverflow(tester);
            await _tap(tester, _key('dictation-discard'));
            await _tap(tester, find.widgetWithText(FilledButton, 'Discard'));
            h.dictation.availabilityDefault = DictationAvailability.needsModel;
            await _dictate(tester);
            expect(_key('dictation-problem'), findsOneWidget);
            await expectNoOverflow(tester);
          });
        }
      }
      testWidgets('320×568 @2.0 right to left', (tester) async {
        final h = await _field(
          tester,
          size: const Size(320, 568),
          textScale: 2,
          data: onboardedData(
            settings: const AppSettings(language: AppLanguage.ar),
          ),
        );
        await _dictate(tester);
        h.dictation.partial(long);
        await pumpFrames(tester, count: 2);
        await expectNoOverflow(tester);
        h.dictation.finalText = long;
        await _tap(tester, _key('dictation-stop'));
        await expectNoOverflow(tester);
      });
    });
  });

  group('where people write', () {
    testWidgets('the reset answer: inserted at the cursor and autosaved '
        'exactly', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const GuidedPromptScreen(promptId: 'morning.02'),
      );
      await tester.enterText(find.byType(TextField), 'I notice ');
      await tester.pump(const Duration(seconds: 1));
      await _dictate(tester, 'reset-answer-dictate');
      await _speakAndStop(tester, h, 'that I rush my mornings');
      await _tap(tester, _key('dictation-insert'));
      await tester.pump(
        kAnswerAutosaveDelay + const Duration(milliseconds: 100),
      );
      expect(
        h.state.answer('morning.02')?.body,
        'I notice that I rush my mornings',
      );
    });

    testWidgets('a new journal note: created with the words exactly; Record '
        'instead keeps a voice note on it', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const JournalEntryScreen(),
      );
      await _dictate(tester, 'journal-entry-dictate');
      await _speakAndStop(tester, h, 'Evening walk by the sea');
      await _tap(tester, _key('dictation-insert'));
      await tester.pump(const Duration(seconds: 1));
      expect(h.state.data.journal.single.body, 'Evening walk by the sea');

      h.dictation.availabilityDefault = DictationAvailability.unsupported;
      await _dictate(tester, 'journal-entry-dictate');
      await _tap(tester, _key('dictation-record-instead'));
      await _tap(tester, _key('recorder-stop'));
      final note = h.state.data.journal.single;
      expect(note.attachments.single.kind, AttachmentKind.audio);
      expect(note.body, 'Evening walk by the sea');
    });

    testWidgets('the Try note: the draft is kept', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const TryScreen(experimentId: 'try.terrain.01'),
      );
      await _dictate(tester, 'try-note-dictate');
      await _speakAndStop(tester, h, 'Left my phone in the drawer');
      await _tap(tester, _key('dictation-insert'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        h.state.data.tryNoteDrafts['try.terrain.01'],
        'Left my phone in the drawer',
      );
    });

    testWidgets("a try's note: saved with Save", (tester) async {
      final entry = ExperimentEntry(
        id: 'e1',
        experimentId: 'try.terrain.01',
        day: '2026-11-02',
        note: 'Walked',
        createdAt: _t,
      );
      final h = await pumpCartha(
        tester,
        data: onboardedData().copyWith(experimentLog: [entry]),
        home: _opener((c) => showExperimentEntrySheet(c, entry, title: 'Try')),
      );
      await _tap(tester, _key('open'));
      await _dictate(tester, 'tried-edit-dictate');
      await _speakAndStop(tester, h, 'without my phone');
      await _tap(tester, _key('dictation-insert'));
      await _tap(tester, _key('tried-edit-save'));
      expect(h.state.data.experimentLog.single.note, 'Walked without my phone');
    });

    testWidgets('an attempt: each field has its own Dictate, named for '
        'screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      final entry = BattleLogEntry(
        id: 'a1',
        day: '2026-11-02',
        attempt: 'Wrote the first page',
        createdAt: _t,
      );
      final h = await pumpCartha(
        tester,
        data: onboardedData().copyWith(campaignLog: [entry]),
        home: _opener((c) => showAttemptSheet(c, entry)),
      );
      await _tap(tester, _key('open'));
      expect(
        find.bySemanticsLabel('Dictate: What did you actually try?'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Dictate: What did you learn? (optional)'),
        findsOneWidget,
      );
      await _dictate(tester, 'attempt-edit-learning-dictate');
      await _speakAndStop(tester, h, 'Mornings work better');
      await _tap(tester, _key('dictation-insert'));
      await _tap(tester, find.text('Save attempt'));
      final saved = h.state.data.campaignLog.single;
      expect(saved.learning, 'Mornings work better');
      expect(saved.attempt, 'Wrote the first page');
      semantics.dispose();
    });

    testWidgets('a path day: the note autosaves', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const PathDayScreen(day: 3),
      );
      await _tap(
        tester,
        find.descendant(
          of: find.byType(DictateButton),
          matching: find.byType(TextButton),
        ),
      );
      await _speakAndStop(tester, h, 'Noticed the same pull at noon');
      await _tap(tester, _key('dictation-insert'));
      await tester.pump(const Duration(seconds: 1));
      expect(
        h.state.data.pathAnswers[3]?.body,
        'Noticed the same pull at noon',
      );
    });

    testWidgets('the weekly review: three named Dictates; the review is '
        'created with the words', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        size: const Size(390, 1400),
        home: const ReviewScreen(),
      );
      for (final field in ['Wins', 'Friction', 'Next experiment']) {
        expect(find.bySemanticsLabel('Dictate: $field'), findsOneWidget);
      }
      await _tap(tester, find.bySemanticsLabel('Dictate: Wins'));
      await _speakAndStop(tester, h, 'Walked every day');
      await _tap(tester, _key('dictation-insert'));
      await tester.pump(const Duration(seconds: 1));
      final review = h.state.data.reviews.single;
      expect(review.wins, 'Walked every day');
      expect(review.friction, '');
      semantics.dispose();
    });
  });
}
