import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/compass/compass_import.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/journal/past_reset_screen.dart';
import 'package:cartharise/ui/reset/reset_complete_screen.dart';
import 'package:cartharise/ui/reset/reset_tab.dart';
import 'package:cartharise/ui/you/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// Tall enough that every row of a screen is built (ListViews are lazy).
const _tall = Size(390, 4000);

final _startedAt = DateTime(2026, 11, 3, 7, 45);

ReflectionAnswer _a(String id, String body, {bool skipped = false}) =>
    ReflectionAnswer(
      promptId: id,
      body: body,
      skipped: skipped,
      updatedAt: DateTime(2026, 11, 3, 8),
    );

/// An onboarded user whose current reset holds [answers] (id → text) and
/// [skipped] ids, plus optional [past] resets.
AppData _data({
  Map<String, String> answers = const {},
  Set<String> skipped = const {},
  DateTime? completedAt,
  List<Journey> past = const [],
  Pace pace = Pace.flexible,
  Set<String> lessonsRead = const {},
  List<ReminderPreference> reminders = const [],
}) {
  final base = onboardedData();
  final journey = Journey(
    id: 'journey_now',
    startedAt: _startedAt,
    completedAt: completedAt,
    answers: {
      for (final e in answers.entries) e.key: _a(e.key, e.value),
      for (final id in skipped) id: _a(id, '', skipped: true),
    },
  );
  final touched = answers.isNotEmpty || skipped.isNotEmpty;
  return base.copyWith(
    profile: () => base.profile!.copyWith(pace: pace),
    journeys: [...past, if (touched || completedAt != null) journey],
    currentJourneyId: touched || completedAt != null ? () => journey.id : null,
    lessonsRead: lessonsRead,
    reminders: reminders,
  );
}

Journey _pastJourney() => Journey(
  id: 'journey_before',
  startedAt: DateTime(2026, 10, 1, 8),
  completedAt: DateTime(2026, 10, 1, 21),
  answers: {
    'morning.01': _a('morning.01', 'Back then: tired evenings.'),
    'morning.02': _a('morning.02', '', skipped: true),
  },
);

/// Every core prompt answered, with a vision for evening.04.
Map<String, String> _allCore({String vision = 'A calm, useful life.'}) => {
  for (final p in fakeContent.corePrompts) p.id: 'Answer to ${p.id}',
  'evening.04': vision,
};

Future<CarthaHarness> _pumpHub(
  WidgetTester tester, {
  AppData? data,
  Size size = _tall,
  double textScale = 1,
  Brightness brightness = Brightness.dark,
  bool englishContent = false,
}) => pumpCartha(
  tester,
  data: data ?? _data(),
  home: const ResetTab(),
  size: size,
  textScale: textScale,
  brightness: brightness,
  content: englishContent ? _english : null,
);

const _english = englishContent;

/// Opens [promptId] from the hub, as the app does.
Future<void> _openPrompt(WidgetTester tester, String promptId) async {
  AppNav.openPrompt(tester.element(find.byType(ResetTab)), promptId);
  await pumpFrames(tester, count: 8);
}

/// The main vertical list of the topmost [screen] of type [T].
Finder _listOf<T>() => find
    .descendant(
      of: find.byType(T),
      matching: find.byWidgetPredicate(
        (w) =>
            w is Scrollable &&
            axisDirectionToAxis(w.axisDirection) == Axis.vertical,
      ),
    )
    .first;

/// Taps [finder], first scrolling [scrollable] until a lazily built target
/// exists.
Future<void> _tap(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollable,
}) async {
  if (scrollable != null && finder.evaluate().isEmpty) {
    tester.state<ScrollableState>(scrollable).position.jumpTo(0);
    await tester.pump();
    await tester.scrollUntilVisible(finder, 300, scrollable: scrollable);
  }
  await tester.ensureVisible(finder);
  // A focused field scrolls its caret back into view after a change; let
  // that finish, then bring the target back.
  await tester.pump(const Duration(milliseconds: 200));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester, count: 8);
}

Finder _button(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

String _field(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).controller!.text;

void _use24h(WidgetTester tester, bool value) {
  tester.platformDispatcher.alwaysUse24HourFormatTestValue = value;
  addTearDown(tester.platformDispatcher.clearAlwaysUse24HourTestValue);
}

void main() {
  group('Reset hub', () {
    testWidgets('three phases, six timed check-ins, optional contemplations', (
      tester,
    ) async {
      _use24h(tester, true);
      await _pumpHub(tester);
      expect(find.text('The Reset'), findsOneWidget);
      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Daytime'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
      expect(find.text('The Mirror'), findsOneWidget);
      expect(find.text('The Vision'), findsOneWidget);
      expect(find.text('The Breakthrough · Insights'), findsNothing);
      for (final t in kFakeDaytimeTimes) {
        expect(find.text('Check-in · $t'), findsOneWidget, reason: t);
      }
      for (var i = 1; i <= 6; i++) {
        expect(find.text('Daytime $i title'), findsOneWidget);
      }
      expect(find.text('Optional contemplations'), findsOneWidget);
      for (var i = 1; i <= 3; i++) {
        expect(find.text('Bonus $i title'), findsOneWidget);
      }
      // Bonus is labelled optional (header + each row) and not counted.
      expect(find.text('Optional'), findsNWidgets(4));
      expect(find.text('0 of 27 core questions answered'), findsOneWidget);
      expect(find.text('Begin'), findsOneWidget);
      // Nothing to look back on yet, nothing to restart.
      expect(find.text('Past resets'), findsNothing);
      expect(find.text('Start a new reset'), findsNothing);
    });

    testWidgets('check-in times follow the device clock and user changes', (
      tester,
    ) async {
      _use24h(tester, false);
      await _pumpHub(
        tester,
        data: _data(
          reminders: const [
            ReminderPreference(promptId: 'daytime.02', time: '14:45'),
          ],
        ),
      );
      expect(find.text('Check-in · 11:00 AM'), findsOneWidget);
      expect(find.text('Check-in · 2:45 PM'), findsOneWidget);
      expect(find.text('Check-in · 1:30 PM'), findsNothing);
    });

    testWidgets('pace note follows the profile; nothing locks', (tester) async {
      await _pumpHub(tester, data: _data(pace: Pace.oneDay));
      expect(find.text('Your pace: one day'), findsOneWidget);
      expect(find.textContaining('Nothing locks'), findsOneWidget);
    });

    testWidgets('own pace', (tester) async {
      await _pumpHub(tester);
      expect(find.text('Your pace: flexible'), findsOneWidget);
      expect(find.textContaining('Nothing locks'), findsOneWidget);
    });

    testWidgets('progress counts in words, state by icon and word', (
      tester,
    ) async {
      final h = await _pumpHub(
        tester,
        data: _data(
          answers: {
            'morning.01': 'a',
            'morning.02': 'b',
            'daytime.01': 'c',
            'daytime.02': 'd',
          },
          skipped: {'daytime.03'},
        ),
      );
      expect(find.text('4 of 27 core questions answered'), findsOneWidget);
      expect(find.text('2 of 14 answered'), findsOneWidget);
      expect(find.text('2 of 6 answered, 1 skipped'), findsOneWidget);
      expect(find.text('Not started yet'), findsWidgets);
      // The six check-ins say their state in words.
      expect(find.text('Answered'), findsNWidgets(2));
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Next: ${h.state.nextPrompt!.title}'), findsOneWidget);
      expect(h.state.nextPrompt!.id, 'morning.03');
    });

    testWidgets('Begin / Continue opens the resume point', (tester) async {
      final h = await _pumpHub(
        tester,
        data: _data(answers: {'morning.01': 'x'}),
      );
      await _tap(tester, find.text('Continue'));
      expect(find.byType(GuidedPromptScreen), findsOneWidget);
      expect(find.text('Question morning 2?'), findsOneWidget);
      expect(h.state.journey.activePromptId, 'morning.02');
    });

    testWidgets('a check-in row and a subflow row open their prompts', (
      tester,
    ) async {
      await _pumpHub(tester, data: _data(answers: {'morning.12': 'x'}));
      await _tap(tester, find.text('Daytime 4 title'));
      expect(find.text('Question daytime 4?'), findsOneWidget);
      await _tap(tester, find.byTooltip('Pause and return to the Reset'));
      await _tap(tester, find.text('The Vision'));
      expect(find.text('Question morning 13?'), findsOneWidget);
    });

    testWidgets('lesson strip shows read state and opens a lesson', (
      tester,
    ) async {
      await _pumpHub(tester, data: _data(lessonsRead: {'lesson.01'}));
      expect(find.text('Learn the ideas first (optional)'), findsOneWidget);
      expect(find.text('1 of 7 read'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Not read yet'), findsNWidgets(6));
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(-200, 0),
      );
      await _tap(tester, find.text('Lesson 2 title'));
      expect(find.byType(LessonScreen), findsOneWidget);
    });

    testWidgets('start a new reset: confirm, history kept, read-only view', (
      tester,
    ) async {
      final h = await _pumpHub(
        tester,
        data: _data(answers: {'morning.01': 'Today’s words'}),
      );
      expect(find.text('Start a new reset'), findsOneWidget);
      // Cancelling changes nothing.
      await _tap(tester, _button('Start new reset'));
      await _tap(tester, find.text('Cancel'));
      expect(h.state.pastJourneys, isEmpty);
      expect(h.state.answer('morning.01')?.body, 'Today’s words');

      await _tap(tester, _button('Start new reset'));
      await _tap(
        tester,
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Start new reset'),
        ),
      );
      expect(h.state.pastJourneys, hasLength(1));
      expect(h.state.journey.answers, isEmpty);
      expect(find.textContaining('New reset started'), findsOneWidget);
      expect(find.text('Past resets'), findsOneWidget);
      expect(h.store.saved!.journeys, hasLength(2));

      await _tap(tester, find.text('Started Nov 3, 2026'));
      expect(find.byType(PastResetScreen), findsOneWidget);
      expect(find.text('Today’s words'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.textContaining('Read-only'), findsOneWidget);
    });

    testWidgets('past reset shows answers exactly and skipped prompts', (
      tester,
    ) async {
      await _pumpHub(
        tester,
        data: _data(past: [_pastJourney()], answers: {'morning.01': 'now'}),
      );
      expect(find.text('Past resets'), findsOneWidget);
      expect(find.text('Finished Oct 1, 2026'), findsOneWidget);
      await _tap(tester, find.text('Started Oct 1, 2026'));
      expect(find.text('Back then: tired evenings.'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('now'), findsNothing);
      expect(find.text('25 questions were left open.'), findsOneWidget);
    });
  });

  group('Guided prompt (F-011, F-012)', () {
    testWidgets('one question at a time: context, position, progress', (
      tester,
    ) async {
      await _pumpHub(tester);
      await _openPrompt(tester, 'morning.01');
      expect(find.text('MORNING · THE MIRROR'), findsOneWidget);
      expect(find.text('Question 1 of 14'), findsOneWidget);
      expect(find.text('Current reality'), findsOneWidget);
      expect(find.text('Context for morning 1.'), findsOneWidget);
      expect(find.text('Question morning 1?'), findsOneWidget);
      expect(find.text('Question morning 2?'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(1 / 14, 1e-9));
      // Every control is present; Back is disabled on the very first one.
      expect(find.text('Save & continue'), findsOneWidget);
      expect(find.text('Skip for now'), findsOneWidget);
      expect(find.text('Jump'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.byTooltip('Jump to a question'), findsOneWidget);
      expect(
        tester.widget<ButtonStyleButton>(_button('Back')).onPressed,
        isNull,
      );
      // No softer wording for this prompt in the fake content.
      expect(find.text('Softer wording'), findsNothing);
    });

    testWidgets('answers persist after navigating forward, back and away', (
      tester,
    ) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'morning.01');
      await tester.enterText(find.byType(TextField), 'First answer');
      await _tap(tester, find.text('Save & continue'));
      expect(find.text('Question morning 2?'), findsOneWidget);
      expect(find.text('Question 2 of 14'), findsOneWidget);
      expect(_field(tester), isEmpty);
      await tester.enterText(find.byType(TextField), 'Second answer');
      await _tap(tester, find.text('Back'));
      expect(find.text('Question morning 1?'), findsOneWidget);
      expect(_field(tester), 'First answer');
      await _tap(tester, find.text('Save & continue'));
      expect(_field(tester), 'Second answer');

      // Leave and come back: still there, and written to storage.
      await _tap(tester, find.byTooltip('Pause and return to the Reset'));
      expect(find.byType(GuidedPromptScreen), findsNothing);
      await _openPrompt(tester, 'morning.01');
      expect(_field(tester), 'First answer');
      final saved = h.store.saved!.currentJourney!;
      expect(saved.answer('morning.01')!.body, 'First answer');
      expect(saved.answer('morning.02')!.body, 'Second answer');

      // A restart reads the same words back.
      final restarted = AppState(
        store: h.store,
        content: fakeContent,
        reminders: FakeReminderScheduler(),
      );
      await restarted.load();
      expect(restarted.answer('morning.02')!.body, 'Second answer');
    });

    testWidgets('autosave waits for a pause in typing, then saves exactly', (
      tester,
    ) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'morning.01');
      await tester.enterText(find.byType(TextField), '  spaced  ');
      await tester.pump(const Duration(milliseconds: 300));
      expect(h.state.answer('morning.01'), isNull);
      await tester.enterText(find.byType(TextField), '  spaced words  ');
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.state.answer('morning.01'), isNull);
      await tester.pump(const Duration(milliseconds: 300));
      expect(h.state.answer('morning.01')!.body, '  spaced words  ');
      await tester.pump();
      expect(find.text('Saved on this device'), findsOneWidget);
    });

    testWidgets('pending text is saved when the screen is disposed', (
      tester,
    ) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'morning.01');
      await tester.enterText(find.byType(TextField), 'Typed, then gone');
      expect(h.state.answer('morning.01'), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(h.state.answer('morning.01')!.body, 'Typed, then gone');
      expect(
        h.store.saved!.currentJourney!.answer('morning.01')!.body,
        'Typed, then gone',
      );
    });

    testWidgets('pending text is saved when the app goes to the background', (
      tester,
    ) async {
      addTearDown(
        () => tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        ),
      );
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'daytime.02');
      await tester.enterText(find.byType(TextField), 'Switching apps');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(h.state.answer('daytime.02')!.body, 'Switching apps');
    });

    testWidgets('pending text is saved on system back', (tester) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'morning.04');
      await tester.enterText(find.byType(TextField), 'Back gesture');
      await tester.binding.handlePopRoute();
      await pumpFrames(tester, count: 8);
      expect(find.byType(GuidedPromptScreen), findsNothing);
      expect(h.state.answer('morning.04')!.body, 'Back gesture');
    });

    testWidgets('skip moves on; return later via Jump and answer', (
      tester,
    ) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'morning.01');
      await _tap(tester, find.text('Skip for now'));
      expect(find.text('Question morning 2?'), findsOneWidget);
      expect(h.state.answer('morning.01')!.skipped, isTrue);

      await _tap(tester, find.byTooltip('Jump to a question'));
      expect(find.text('Morning questions'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      await _tap(tester, find.text('1. Morning 1 title'));
      expect(find.text('Question morning 1?'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.textContaining('Skipped. Come back anytime'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Ready now');
      await _tap(tester, find.text('Save & continue'));
      final a = h.state.answer('morning.01')!;
      expect(a.body, 'Ready now');
      expect(a.skipped, isFalse);
      expect(h.state.progressFor(PromptPhase.morning).skipped, 0);
    });

    testWidgets('Jump lists the phase with state icons and words', (
      tester,
    ) async {
      final h = await _pumpHub(
        tester,
        data: _data(answers: {'morning.02': 'x'}, skipped: {'morning.03'}),
      );
      await _openPrompt(tester, 'morning.01');
      await _tap(tester, find.text('Jump'));
      final sheet = find.byType(BottomSheet);
      expect(
        find.descendant(of: sheet, matching: find.byType(ListTile)),
        findsNWidgets(14),
      );
      expect(find.text('You are here · Not answered yet'), findsOneWidget);
      expect(find.text('Answered'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(
        find.descendant(of: sheet, matching: find.byIcon(Icons.check_circle)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: sheet, matching: find.byIcon(Icons.redo)),
        findsOneWidget,
      );
      await _tap(tester, find.text('5. Morning 5 title'));
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Question morning 5?'), findsOneWidget);
      expect(find.text('Question 5 of 14'), findsOneWidget);
      expect(h.state.journey.activePromptId, 'morning.05');
      expect(h.state.nextPrompt!.id, 'morning.05');
    });

    testWidgets('softer wording toggles and stays on for the next prompt', (
      tester,
    ) async {
      await _pumpHub(tester);
      await _openPrompt(tester, 'morning.05');
      expect(find.text('Question morning 5?'), findsOneWidget);
      await _tap(tester, find.text('Softer wording'));
      expect(find.text('Softer question morning 5?'), findsOneWidget);
      expect(find.text('Question morning 5?'), findsNothing);
      await _tap(tester, find.text('Save & continue'));
      expect(find.text('Softer question morning 6?'), findsOneWidget);
      await _tap(tester, find.text('Softer wording'));
      expect(find.text('Question morning 6?'), findsOneWidget);
    });

    testWidgets('help opens and closes; the example is labelled', (
      tester,
    ) async {
      await _pumpHub(tester);
      await _openPrompt(tester, 'morning.01');
      expect(find.text('Help for morning 1.'), findsNothing);
      await _tap(tester, find.text('What does this mean?'));
      expect(find.text('Help for morning 1.'), findsOneWidget);
      await _tap(tester, find.text('Close'));
      expect(find.text('Help for morning 1.'), findsNothing);
      expect(find.byType(GuidedPromptScreen), findsOneWidget);

      expect(find.text('Example — not a right answer'), findsOneWidget);
      expect(find.text('Example for morning 1.'), findsNothing);
      await _tap(tester, find.text('Example — not a right answer'));
      expect(find.text('Example for morning 1.'), findsOneWidget);
    });

    testWidgets('very long text with special characters is kept exactly', (
      tester,
    ) async {
      final h = await _pumpHub(tester);
      const special =
          '<b>not bold</b> & <script>alert(1)</script> {braces} \$money '
          '"quotes" ‘curly’ — dash … 🐘🌅👩🏽‍💻 مرحبا שלום 日本語 '
          'e\u0301 zero\u200Bwidth \\n back\\slash\n\tTabbed line\n\n';
      final long = List.filled(60, special).join();
      expect(long.length, greaterThan(5000));
      await _openPrompt(tester, 'morning.02');
      await tester.enterText(find.byType(TextField), long);
      // Close the keyboard, as a user would before reaching the buttons.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await _tap(
        tester,
        find.text('Save & continue'),
        scrollable: _listOf<GuidedPromptScreen>(),
      );
      expect(h.state.answer('morning.02')!.body, long);
      await _tap(
        tester,
        find.text('Back'),
        scrollable: _listOf<GuidedPromptScreen>(),
      );
      expect(_field(tester), long);
      expect(h.store.saved!.currentJourney!.answer('morning.02')!.body, long);
      await expectNoOverflow(tester);
    });

    testWidgets('long answer fits the smallest phone at 200 % text', (
      tester,
    ) async {
      final h = await _pumpHub(
        tester,
        size: kSizeMatrix.first.size,
        textScale: kSizeMatrix.first.textScale,
        data: _data(
          answers: {'morning.05': List.filled(80, 'Wörds 🐘 & <tags> ').join()},
        ),
      );
      await _openPrompt(tester, 'morning.05');
      await tester.scrollUntilVisible(
        find.byType(TextField),
        300,
        scrollable: _listOf<GuidedPromptScreen>(),
      );
      expect(_field(tester), h.state.answer('morning.05')!.body);
      await expectNoOverflow(tester);
    });

    testWidgets('daytime prompts show their local check-in time', (
      tester,
    ) async {
      _use24h(tester, true);
      await _pumpHub(tester);
      await _openPrompt(tester, 'daytime.02');
      expect(find.text('DAYTIME · THE INTERRUPT'), findsOneWidget);
      expect(find.text('Check-in · 13:30'), findsOneWidget);
      expect(find.text('Check-in'), findsNothing);
      expect(find.text('Question 2 of 6'), findsOneWidget);
    });

    testWidgets('feeling heavy: soften, support, pause', (tester) async {
      await _pumpHub(tester);
      await _openPrompt(tester, 'morning.06');
      await _tap(tester, find.text('Feeling heavy?'));
      expect(find.text('This can be a lot'), findsOneWidget);
      expect(find.text('Skip this question'), findsOneWidget);
      expect(find.text('Take a pause'), findsOneWidget);
      expect(find.text('Support and safety'), findsOneWidget);
      expect(find.textContaining("isn't therapy"), findsOneWidget);
      await _tap(tester, find.text('Switch to softer wording'));
      expect(find.text('Softer question morning 6?'), findsOneWidget);

      // Already soft: the sheet no longer offers it.
      await _tap(tester, find.text('Feeling heavy?'));
      expect(find.text('Switch to softer wording'), findsNothing);
      await _tap(tester, find.text('Support and safety'));
      expect(find.byType(SupportScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await pumpFrames(tester, count: 8);
      expect(find.byType(GuidedPromptScreen), findsOneWidget);

      await _tap(tester, find.text('Feeling heavy?'));
      await _tap(tester, find.text('Take a pause'));
      expect(find.byType(GuidedPromptScreen), findsNothing);
      expect(find.byType(ResetTab), findsOneWidget);
    });

    testWidgets('feeling heavy → skip this question', (tester) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'morning.07');
      await _tap(tester, find.text('Feeling heavy?'));
      await _tap(tester, find.text('Skip this question'));
      expect(h.state.answer('morning.07')!.skipped, isTrue);
      expect(find.text('Question morning 8?'), findsOneWidget);
    });

    testWidgets('Pause keeps the words and the hub resumes after them', (
      tester,
    ) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'morning.01');
      await tester.enterText(find.byType(TextField), 'Half a thought');
      await _tap(tester, find.text('Pause'));
      expect(find.byType(ResetTab), findsOneWidget);
      expect(h.state.answer('morning.01')!.body, 'Half a thought');
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Next: Morning 2 title'), findsOneWidget);
    });

    testWidgets('opening a prompt makes it the resume point', (tester) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'evening.02');
      expect(h.state.journey.activePromptId, 'evening.02');
      expect(h.state.nextPrompt!.id, 'evening.02');
    });

    testWidgets('morning continues into the daytime check-ins', (tester) async {
      await _pumpHub(tester);
      await _openPrompt(tester, 'morning.14');
      await _tap(tester, find.text('Skip for now'));
      expect(find.text('Question daytime 1?'), findsOneWidget);
      await _tap(tester, find.text('Back'));
      expect(find.text('Question morning 14?'), findsOneWidget);
    });

    testWidgets('optional contemplations end back at the hub', (tester) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'bonus.03');
      expect(find.text('OPTIONAL · THE INTERRUPT'), findsOneWidget);
      expect(find.text('Question 3 of 3'), findsOneWidget);
      expect(find.text('Optional'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Extra note');
      await _tap(tester, find.text('Save & continue'));
      expect(find.byType(GuidedPromptScreen), findsNothing);
      expect(find.byType(ResetTab), findsOneWidget);
      expect(h.state.answer('bonus.03')!.body, 'Extra note');
      expect(h.state.coreProgress, 0);
    });

    testWidgets('a failed save is shown honestly; the words stay', (
      tester,
    ) async {
      final h = await _pumpHub(tester);
      await _openPrompt(tester, 'morning.01');
      h.store.failWrites = true;
      await tester.enterText(find.byType(TextField), 'Still here');
      await pumpFrames(tester, count: 8);
      expect(find.text("Your last change couldn't be saved."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(_field(tester), 'Still here');
    });

    testWidgets('reduced motion: example and sheets appear without animating', (
      tester,
    ) async {
      final base = _data();
      await _pumpHub(
        tester,
        data: base.copyWith(settings: base.settings.copyWith(motion: false)),
      );
      await _openPrompt(tester, 'morning.01');
      await tester.tap(find.text('Example — not a right answer'));
      await tester.pump();
      expect(find.text('Example for morning 1.'), findsOneWidget);
      expect(find.byType(AnimatedSize), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Jump to a question'));
      await tester.pump();
      await tester.pump();
      final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(sheet.animationController?.value ?? 1.0, 1.0);
    });

    testWidgets('an unknown prompt id shows a calm message', (tester) async {
      await _pumpHub(tester);
      await _openPrompt(tester, 'morning.99');
      expect(find.text("This question isn't available."), findsOneWidget);
    });

    testWidgets('real English content: a full prompt renders', (tester) async {
      await _pumpHub(tester, englishContent: true);
      await _openPrompt(tester, 'morning.05');
      final prompt = englishContent.prompt('morning.05')!;
      expect(find.text(prompt.question), findsOneWidget);
      expect(find.text(prompt.context), findsOneWidget);
      expect(find.text('Softer wording'), findsOneWidget);
    });
  });

  group('Reset complete (F-022)', () {
    testWidgets('the last evening prompt leads to a calm completion', (
      tester,
    ) async {
      const vision = 'Calm mornings, a garden 🌱 & <real> "rest".';
      final h = await _pumpHub(
        tester,
        data: _data(answers: _allCore(vision: vision)),
      );
      await _openPrompt(tester, 'evening.07');
      expect(find.text('Save & finish'), findsOneWidget);
      await _tap(tester, find.text('Save & finish'));
      expect(find.byType(GuidedPromptScreen), findsNothing);
      expect(find.byType(ResetCompleteScreen), findsOneWidget);
      expect(h.state.journey.completedAt, isNotNull);
      expect(find.text('Reset complete'), findsOneWidget);
      expect(
        find.text('One day can bring clarity; the rest is practice.'),
        findsOneWidget,
      );
      expect(
        find.text('Your vision, in your words'.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(vision), findsOneWidget);
      expect(find.text('27 answers written'), findsOneWidget);
      expect(find.text('Morning: 14 of 14 answered'), findsOneWidget);
      expect(find.textContaining('still open'), findsNothing);
      expect(
        find.textContaining(RegExp('fixed', caseSensitive: false)),
        findsNothing,
      );

      await _tap(tester, find.text('Build your Compass'));
      expect(find.byType(CompassImportSheet), findsOneWidget);
      await tester.binding.handlePopRoute();
      await pumpFrames(tester, count: 8);
      await _tap(tester, find.text('Later'));
      expect(find.byType(ResetCompleteScreen), findsNothing);
      expect(find.byType(ResetTab), findsOneWidget);
      expect(find.textContaining('Finished on'), findsOneWidget);
      expect(find.text('See what you created'), findsOneWidget);
    });

    testWidgets('open questions are named honestly; completion kept once', (
      tester,
    ) async {
      final done = DateTime(2026, 11, 2, 21);
      final h = await pumpCartha(
        tester,
        data: _data(
          answers: {'morning.01': 'x', 'evening.01': 'y'},
          skipped: {'morning.02'},
          completedAt: done,
        ),
        home: const ResetCompleteScreen(),
        size: _tall,
      );
      expect(find.text('2 answers written'), findsOneWidget);
      expect(find.text('1 question skipped'), findsOneWidget);
      expect(
        find.textContaining('24 core questions are still open'),
        findsOneWidget,
      );
      expect(
        find.text('Your vision, in your words'.toUpperCase()),
        findsNothing,
      );
      expect(h.state.journey.completedAt!.isAtSameMomentAs(done), isTrue);
    });
  });

  group('fits every size (dark + light)', () {
    for (final size in kSizeMatrix) {
      for (final b in Brightness.values) {
        final tag = '$size ${b.name}';

        testWidgets('hub $tag', (tester) async {
          await _pumpHub(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: b,
            englishContent: true,
            data: _data(
              answers: {'morning.01': 'x', 'daytime.02': 'y'},
              skipped: {'daytime.03'},
              past: [_pastJourney()],
              pace: Pace.oneDay,
              lessonsRead: {'lesson.01'},
            ),
          );
          await expectNoOverflow(tester);
        });

        testWidgets('prompt + sheets $tag', (tester) async {
          await _pumpHub(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: b,
            englishContent: true,
            data: _data(skipped: {'morning.06'}),
          );
          await _openPrompt(tester, 'morning.06');
          final list = _listOf<GuidedPromptScreen>();
          await _tap(
            tester,
            find.text('Example — not a right answer'),
            scrollable: list,
          );
          await expectNoOverflow(tester);
          await _tap(tester, find.byTooltip('Jump to a question'));
          await expectNoOverflow(tester);
          await tester.binding.handlePopRoute();
          await pumpFrames(tester, count: 8);
          await _tap(tester, find.text('Feeling heavy?'), scrollable: list);
          await expectNoOverflow(tester);
          await tester.binding.handlePopRoute();
          await pumpFrames(tester, count: 8);
          await _tap(
            tester,
            find.text('What does this mean?'),
            scrollable: list,
          );
          await expectNoOverflow(tester);
        });

        testWidgets('daytime prompt $tag', (tester) async {
          await _pumpHub(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: b,
            englishContent: true,
          );
          await _openPrompt(tester, 'daytime.06');
          await expectNoOverflow(tester);
        });

        testWidgets('complete $tag', (tester) async {
          await pumpCartha(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: b,
            content: englishContent,
            data: _data(
              answers: {
                'evening.04': List.filled(
                  12,
                  'A life I want to wake up to.',
                ).join(' '),
              },
            ),
            home: const ResetCompleteScreen(),
          );
          await expectNoOverflow(tester);
        });

        testWidgets('past reset $tag', (tester) async {
          await pumpCartha(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: b,
            content: englishContent,
            data: _data(past: [_pastJourney()]),
            home: const PastResetScreen(journeyId: 'journey_before'),
          );
          // The shared (Journal) screen builds its list lazily: on a small
          // phone at 200 % text the answer is below the fold.
          final words = find.text('Back then: tired evenings.');
          await tester.scrollUntilVisible(
            words,
            200,
            scrollable: find.byType(Scrollable).first,
          );
          expect(words, findsOneWidget);
          await expectNoOverflow(tester);
        });
      }
    }
  });
}
