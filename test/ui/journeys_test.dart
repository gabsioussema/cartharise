// End-to-end journeys through the real app (CarthaApp → BootScreen →
// Onboarding | RootShell) with the real English content: the requirements'
// critical acceptance tests (Cartharise_Requirements.html §11), happy path
// and edge cases, across every feature area.
import 'dart:async';
import 'dart:convert';

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/compass/compass_import.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/journal/journal_tab.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/persona/persona_builder.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/reset/reset_complete_screen.dart';
import 'package:cartharise/ui/reset/reset_tab.dart';
import 'package:cartharise/ui/root_shell.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:cartharise/ui/you/inspiration_screen.dart';
import 'package:cartharise/ui/you/reminders_screen.dart';
import 'package:cartharise/ui/you/support_screen.dart';
import 'package:cartharise/ui/you/you_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// A phone tall enough that lazily built rows exist (the journeys still
/// scroll to what they tap).
const _phone = Size(390, 2000);

const _content = englishContent;

const _next = ValueKey('onboarding-next');
const _adult = ValueKey('onboarding-adult');
const _finish = ValueKey('onboarding-finish');

Prompt _prompt(String id) => _content.prompt(id)!;

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// [finder] inside the tab or screen of type [T] (the shell keeps every tab
/// built, so unscoped text can match a tab that isn't showing).
Finder _in<T>(Finder finder) =>
    find.descendant(of: find.byType(T), matching: finder);

Finder _button(String label) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

Future<void> _settle(WidgetTester tester, {int frames = 6}) async {
  // Storage writes are microtasks; let them land, then draw.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await pumpFrames(tester, count: frames);
}

/// Brings [finder] on screen, then taps it like a person would.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  // A focused field scrolls its caret back into view after a change; let
  // that finish, then bring the target back.
  await tester.pump(const Duration(milliseconds: 200));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _settle(tester);
}

Future<void> _type(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.pump();
  await tester.enterText(field, text);
  await tester.pump();
}

/// Scrolls every visible vertical list back to its start.
Future<void> _scrollToTop(WidgetTester tester) async {
  for (final element in find.byType(Scrollable).evaluate().toList()) {
    final state = (element as StatefulElement).state as ScrollableState;
    if (state.position.axis == Axis.vertical) state.position.jumpTo(0);
  }
  await pumpFrames(tester, count: 2);
}

/// Scrolls the main list of [screen] until the lazily built [finder] exists.
Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder,
  Finder screen,
) async {
  if (finder.evaluate().isNotEmpty) return;
  final list = find
      .descendant(
        of: screen,
        matching: find.byWidgetPredicate(
          (w) =>
              w is Scrollable &&
              axisDirectionToAxis(w.axisDirection) == Axis.vertical,
        ),
      )
      .first;
  await tester.scrollUntilVisible(finder, 200, scrollable: list);
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_nav(label));
  await _settle(tester);
}

/// Lets any snackbar time out so it doesn't cover what is tapped next.
Future<void> _waitOutSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await pumpFrames(tester, count: 4);
}

String _answerField(WidgetTester tester) => tester
    .widget<TextField>(_in<GuidedPromptScreen>(find.byType(TextField)))
    .controller!
    .text;

/// Records url_launcher calls (the platform channel used in tests).
List<String> _mockLauncher(WidgetTester tester) {
  final launched = <String>[];
  const channel = MethodChannel('plugins.flutter.io/url_launcher');
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(channel, (call) async {
    if (call.method == 'launch') {
      launched.add((call.arguments as Map)['url'] as String);
    }
    return true;
  });
  addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  return launched;
}

/// The quickest honest way through the five-page welcome: Begin, confirm
/// 18+ (required), Next through the setup pages, Start.
Future<void> _quickOnboarding(WidgetTester tester) async {
  expect(find.byType(OnboardingFlow), findsOneWidget);
  await _tap(tester, find.byKey(_next)); // Begin
  await _tap(tester, find.byKey(_adult));
  for (var i = 0; i < 3; i++) {
    await _tap(tester, find.byKey(_next));
  }
  await _tap(tester, find.byKey(_finish));
  await _settle(tester, frames: 8);
  expect(find.byType(RootShell), findsOneWidget);
}

/// An answer with the characters that must survive exactly as typed.
String _answer(String id) =>
    'My words for $id: “exact” & <kept> 🌱\n  second line, spaces kept  ';

const _evening = {
  'evening.01': 'I wait for certainty before I start.',
  'evening.02': 'If I try and it fails, it proves something about me.',
  'evening.03': 'I refuse to drift through another year of almost.',
  'evening.04': 'Calm mornings, honest work, people I love nearby.',
  'evening.05': 'A small app that real people use every week.',
  'evening.06': 'Ship the first version of my app.',
  'evening.07': 'Walk 20 minutes\nRead 10 pages\nCall a friend',
};

void main() {
  testWidgets('happy path: first launch → reset → Compass → missions → '
      'journal → reminders → backup round trip', (tester) async {
    final launched = _mockLauncher(tester);
    final h = await pumpCartha(tester, content: _content, size: _phone);
    final credit = _content.credit;

    // ── First launch → the five-page welcome (F-001–F-004, D-11) ───────────
    expect(find.byType(OnboardingFlow), findsOneWidget);
    await _tap(tester, find.byKey(_next)); // the brand page
    expect(find.text("Before you start"), findsOneWidget);
    // Inspired by: title, author and the exact article link.
    expect(find.text('“${credit.title}”'), findsOneWidget);
    expect(
      find.text('by ${credit.author} · ${credit.publishedOn}'),
      findsOneWidget,
    );
    await _tap(tester, find.byKey(const ValueKey('onboarding-credit-article')));
    expect(launched, [credit.articleUrl]);
    await _tap(tester, find.byKey(_adult));
    await _tap(tester, find.byKey(_next));
    await _tap(tester, find.byKey(const ValueKey('onboarding-pace-oneDay')));
    await _tap(tester, find.byKey(_next));
    await _type(tester, find.byKey(const ValueKey('onboarding-name')), 'Ana');
    await _tap(tester, find.byKey(_next));
    expect(find.textContaining('not encrypted'), findsWidgets);
    await _tap(tester, find.byKey(_finish));
    await _settle(tester, frames: 8);
    expect(find.byType(RootShell), findsOneWidget);
    expect(find.text('Good morning, Ana.'), findsOneWidget);
    final profile = h.store.saved!.profile!;
    expect(profile.displayName, 'Ana');
    expect(profile.pace, Pace.oneDay);
    expect(profile.adultConfirmed, isTrue);

    // ── Start the reset from Today → the response is saved ────────────────
    await _tap(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('today-next-step')),
        matching: find.text('Begin'),
      ),
    );
    expect(find.byType(GuidedPromptScreen), findsOneWidget);
    final morning = _content.byPhase(PromptPhase.morning);
    expect(morning, hasLength(14));
    expect(find.text(morning.first.question), findsOneWidget);
    await _type(tester, find.byType(TextField), _answer(morning.first.id));
    await _tap(tester, find.text('Save & continue'));
    expect(
      h.store.saved!.currentJourney!.answer(morning.first.id)!.body,
      _answer(morning.first.id),
      reason: 'written to storage exactly as typed',
    );

    // ── Answer all 14 morning prompts, then go back: text unchanged ────────
    for (final p in morning.skip(1)) {
      expect(find.text(p.question), findsOneWidget, reason: p.id);
      await _type(tester, find.byType(TextField), _answer(p.id));
      await _tap(tester, find.text('Save & continue'));
    }
    // The morning flows into the first daytime check-in.
    final daytime1 = _prompt('daytime.01');
    expect(find.text(daytime1.question), findsOneWidget);
    expect(h.state.progressFor(PromptPhase.morning).answered, 14);
    for (final p in morning.reversed) {
      await _tap(tester, _button('Back'));
      expect(find.text(p.question), findsOneWidget, reason: p.id);
      expect(_answerField(tester), _answer(p.id), reason: p.id);
    }
    for (final p in morning) {
      expect(h.store.saved!.currentJourney!.answer(p.id)!.body, _answer(p.id));
    }
    // Pause returns to where the reset was opened from.
    await _tap(tester, find.text('Pause'));
    expect(find.byType(GuidedPromptScreen), findsNothing);
    expect(find.byType(RootShell), findsOneWidget);

    // ── Record a daytime check-in; return later, still there ──────────────
    await _openTab(tester, 'Reset');
    expect(find.text('14 of 27 core questions answered'), findsOneWidget);
    await _tap(tester, _in<ResetTab>(find.text(daytime1.title)).last);
    expect(find.text(daytime1.question), findsOneWidget);
    const checkIn = 'Avoided the hard email; answered easy messages instead.';
    await _type(tester, find.byType(TextField), checkIn);
    await _tap(tester, find.text('Pause'));
    expect(h.store.saved!.currentJourney!.answer('daytime.01')!.body, checkIn);
    await _openTab(tester, 'Today');
    await _openTab(tester, 'Journal');
    await _openTab(tester, 'Reset');
    await _tap(tester, _in<ResetTab>(find.text(daytime1.title)).last);
    expect(_answerField(tester), checkIn);
    await _tap(tester, find.text('Pause'));

    // ── Seven evening prompts → Compass, with confirmation ─────────────────
    // The evening card's row (the card subtitle repeats the name).
    await _tap(tester, _in<ResetTab>(find.text('The Breakthrough')).last);
    final evening = _content.byPhase(PromptPhase.evening);
    expect(evening, hasLength(7));
    for (final p in evening) {
      expect(find.text(p.question), findsOneWidget, reason: p.id);
      await _type(tester, find.byType(TextField), _evening[p.id]!);
      await _tap(
        tester,
        find.text(p == evening.last ? 'Save & finish' : 'Save & continue'),
      );
    }
    expect(find.byType(ResetCompleteScreen), findsOneWidget);
    expect(h.state.journey.completedAt, isNotNull);
    expect(find.text(_evening['evening.04']!), findsOneWidget);
    expect(
      find.textContaining(RegExp('fixed your life', caseSensitive: false)),
      findsNothing,
    );
    await _tap(tester, find.text('Build your Compass'));
    expect(find.byType(CompassImportSheet), findsOneWidget);
    // Previewed exactly; nothing has changed before confirming.
    expect(find.text(_evening['evening.03']!), findsOneWidget);
    expect(h.state.compass.isEmpty, isTrue);
    // Keep the one-year goal for later.
    await _tap(tester, find.byKey(const ValueKey('compass-import-yearGoal')));
    await _tap(tester, find.text('Fill 4 fields'));
    expect(find.byType(CompassImportSheet), findsNothing);
    expect(
      find.text('4 Compass fields filled from your evening answers.'),
      findsOneWidget,
    );
    var compass = h.state.compass;
    expect(compass.antiVision, _evening['evening.03']);
    expect(compass.vision, _evening['evening.04']);
    expect(compass.monthProject, _evening['evening.06']);
    expect(compass.dailyLevers, _evening['evening.07']);
    expect(compass.yearGoal, isEmpty, reason: 'unticked');
    expect(compass.constraints, isEmpty, reason: 'never auto-filled');
    await _tap(tester, find.text('Later'));
    await _waitOutSnackBars(tester);

    // ── Edit the Compass; a later import never overwrites it ───────────────
    await _openTab(tester, 'Compass');
    expect(find.byType(CompassTab), findsOneWidget);
    const myVision = 'Calm mornings and honest work, in my own words now.';
    final visionField = find.descendant(
      of: find.byKey(const ValueKey('compass-field-vision')),
      matching: find.byType(TextField),
    );
    await _type(tester, visionField, myVision);
    await tester.pump(const Duration(milliseconds: 700));
    await _settle(tester);
    expect(h.state.compass.vision, myVision);
    await _tap(tester, find.text('Use my evening reflections').last);
    final visionRow = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('compass-import-vision')),
    );
    expect(visionRow.onChanged, isNull, reason: 'has text: kept');
    expect(find.text('Keeps your current text'), findsWidgets);
    await _tap(tester, find.text('Fill 1 field'));
    compass = h.state.compass;
    expect(compass.vision, myVision);
    expect(compass.yearGoal, _evening['evening.05']);
    expect(compass.antiVision, _evening['evening.03']);
    expect(h.store.saved!.compass.vision, myVision);
    await _waitOutSnackBars(tester);

    // ── Daily levers → quests; complete, reopen, delete ────────────────────
    await _tap(
      tester,
      find.descendant(
        of: find.byType(PillTabs<CompassSection>),
        matching: find.text('Missions'),
      ),
    );
    expect(find.text('Turn your daily levers into quests'), findsOneWidget);
    await _tap(tester, find.text('Add 3 daily quests'));
    expect(find.text('3 daily quests added.'), findsOneWidget);
    expect(h.state.data.quests.map((q) => q.title), [
      'Walk 20 minutes',
      'Read 10 pages',
      'Call a friend',
    ]);
    await _waitOutSnackBars(tester);
    final walk = h.state.data.quests.first;
    final walkCheck = find.byKey(ValueKey('quest-check-${walk.id}'));
    await _tap(tester, walkCheck);
    expect(h.state.questById(walk.id)!.isDoneOn(h.state.today), isTrue);
    await _waitOutSnackBars(tester);
    if (walkCheck.evaluate().isEmpty) {
      await _tap(tester, find.text('Done (1)')); // collapsed Done section
    }
    expect(tester.widget<Checkbox>(walkCheck).value, isTrue);
    await _tap(tester, walkCheck); // reopen
    expect(h.state.questById(walk.id)!.isDoneOn(h.state.today), isFalse);
    await _waitOutSnackBars(tester);
    await _tap(tester, find.byTooltip("Options for 'Walk 20 minutes'"));
    await _tap(tester, find.text('Delete').last);
    expect(h.state.questById(walk.id), isNull);
    expect(h.store.saved!.quests.map((q) => q.title), [
      'Read 10 pages',
      'Call a friend',
    ]);
    await _waitOutSnackBars(tester);
    // Today lists the remaining quests, each a labelled checkbox.
    await _openTab(tester, 'Today');
    expect(_in<TodayTab>(find.text('Read 10 pages')), findsOneWidget);
    expect(_in<TodayTab>(find.text('Walk 20 minutes')), findsNothing);

    // ── Journal: create, edit, delete a note ───────────────────────────────
    await _openTab(tester, 'Journal');
    expect(find.byType(JournalTab), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('journal-new-note')));
    expect(find.byType(JournalEntryScreen), findsOneWidget);
    await _type(
      tester,
      find.byKey(const ValueKey('journal-entry-title')),
      'After the reset',
    );
    await _type(
      tester,
      find.byKey(const ValueKey('journal-entry-body')),
      'Lighter than expected.',
    );
    await tester.pageBack();
    await _settle(tester);
    expect(h.state.data.journal.single.body, 'Lighter than expected.');
    await _tap(tester, _in<JournalTab>(find.text('After the reset')));
    await _type(
      tester,
      find.byKey(const ValueKey('journal-entry-body')),
      'Lighter than expected. Tomorrow: walk first.',
    );
    await tester.pageBack();
    await _settle(tester);
    final note = h.store.saved!.journal.single;
    expect(note.body, 'Lighter than expected. Tomorrow: walk first.');
    expect(note.editedAt, isNotNull);
    await _tap(tester, _in<JournalTab>(find.text('After the reset')));
    await _tap(tester, find.byTooltip('Delete note'));
    expect(find.text('Delete this note?'), findsOneWidget);
    await _tap(tester, find.widgetWithText(FilledButton, 'Delete'));
    expect(h.state.data.journal, isEmpty);
    expect(h.store.saved!.journal, isEmpty);
    await _waitOutSnackBars(tester);

    // ── Weekly review: create, then delete ─────────────────────────────────
    await _tap(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('journal-sections')),
        matching: find.text('Reviews'),
      ),
    );
    await _tap(tester, find.byKey(const ValueKey('journal-review-this-week')));
    expect(find.byType(ReviewScreen), findsOneWidget);
    await _type(tester, find.byKey(const ValueKey('review-wins')), 'Began');
    await _type(tester, find.byKey(const ValueKey('review-friction')), 'Sleep');
    await _type(tester, find.byKey(const ValueKey('review-next')), 'Walk at 8');
    await _tap(tester, find.byKey(const ValueKey('review-save')));
    expect(h.store.saved!.reviews.single.wins, 'Began');
    await tester.pageBack();
    await _settle(tester);
    await _tap(tester, _in<JournalTab>(find.text('Week of Nov 2, 2026')));
    await _tap(tester, find.byTooltip('Delete review'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Delete'));
    expect(h.store.saved!.reviews, isEmpty);
    await _waitOutSnackBars(tester);

    // ── Inspiration: author and the exact link ─────────────────────────────
    await _openTab(tester, 'You');
    expect(find.byType(YouTab), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('you-inspiration')));
    expect(find.byType(InspirationScreen), findsOneWidget);
    expect(find.text(credit.title), findsOneWidget);
    expect(find.text('by ${credit.author}'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('inspiration-article')));
    expect(launched.last, credit.articleUrl);
    await tester.pageBack();
    await _settle(tester);

    // ── .ics export: six recurring check-in events ─────────────────────────
    await _tap(tester, find.byKey(const ValueKey('you-reminders')));
    expect(find.byType(RemindersScreen), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('reminders-calendar')));
    final ics = h.files.shared.single;
    expect(ics.filename, endsWith('.ics'));
    expect(ics.mimeType, 'text/calendar');
    final lines = const LineSplitter().convert(ics.content);
    expect(lines.first, 'BEGIN:VCALENDAR');
    expect(lines.where((l) => l == 'BEGIN:VEVENT'), hasLength(6));
    expect(lines.where((l) => l.startsWith('RRULE:FREQ=DAILY')), hasLength(6));
    final daytime = _content.byPhase(PromptPhase.daytime);
    for (final p in daytime) {
      final hhmm = p.defaultTime!.replaceAll(':', '');
      expect(
        lines.where((l) => l.startsWith('DTSTART') && l.contains('T${hhmm}00')),
        hasLength(1),
        reason: p.id,
      );
    }
    await tester.pageBack();
    await _settle(tester);
    await _waitOutSnackBars(tester);

    // ── Export the backup → delete all → restore it ────────────────────────
    // (Step 2, by design: the backup is the v2 .zip with data.json.)
    await _tap(tester, find.byKey(const ValueKey('you-data')));
    expect(find.byType(DataScreen), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('data-export')));
    final backup = h.files.shared.last;
    expect(backup.mimeType, 'application/zip');
    expect(backup.filename, 'cartharise-backup-2026-11-03.zip');
    final exported = decodeBackupBytes(backup.bytes).data;
    expect(exported.profile!.displayName, 'Ana');
    expect(exported.compass.vision, myVision);
    await _waitOutSnackBars(tester);

    await _tap(tester, find.byKey(const ValueKey('data-delete')));
    await _tap(tester, find.widgetWithText(FilledButton, 'Continue'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Delete everything'));
    await _settle(tester, frames: 10);
    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(h.store.raw, isNull);
    expect(h.state.compass.isEmpty, isTrue);

    await _quickOnboarding(tester);
    await _openTab(tester, 'You');
    await _tap(tester, find.byKey(const ValueKey('you-data')));
    h.files.pickBytes = backup.bytes;
    await _tap(tester, find.byKey(const ValueKey('data-import')));
    expect(find.textContaining('Replace everything on this phone'), findsOne);
    await _tap(tester, find.widgetWithText(FilledButton, 'Replace'));
    expect(find.text('Backup restored.'), findsOneWidget);
    final restored = h.state.data;
    expect(restored.profile!.displayName, 'Ana');
    expect(h.state.answer('morning.01')!.body, _answer('morning.01'));
    expect(h.state.answer('daytime.01')!.body, checkIn);
    expect(h.state.compass.vision, myVision);
    expect(h.state.compass.yearGoal, _evening['evening.05']);
    expect(restored.quests.map((q) => q.title), [
      'Read 10 pages',
      'Call a friend',
    ]);
    expect(h.store.saved!.compass.vision, myVision);
    await tester.pageBack();
    await _settle(tester);
    await _openTab(tester, 'Today');
    expect(find.text('Good morning, Ana.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('edge cases', () {
    testWidgets('skip every prompt: still navigate, return later', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        content: _content,
        size: _phone,
      );
      await _openTab(tester, 'Reset');
      await _tap(tester, _in<ResetTab>(find.text('Begin')));
      final core = _content.corePrompts;
      expect(core, hasLength(27));
      for (final p in core) {
        expect(find.text(p.question), findsOneWidget, reason: p.id);
        await _tap(tester, find.text('Skip for now'));
      }
      // Skipping everything still ends calmly, and says what is open.
      expect(find.byType(ResetCompleteScreen), findsOneWidget);
      for (final phase in [
        PromptPhase.morning,
        PromptPhase.daytime,
        PromptPhase.evening,
      ]) {
        final progress = h.state.progressFor(phase);
        expect(progress.answered, 0, reason: phase.name);
        expect(progress.skipped, progress.total, reason: phase.name);
      }
      await _tap(tester, find.text('Later'));
      expect(find.byType(RootShell), findsOneWidget);

      // Every tab still works.
      for (final (label, type) in [
        ('Today', TodayTab),
        ('Compass', CompassTab),
        ('Journal', JournalTab),
        ('You', YouTab),
        ('Reset', ResetTab),
      ]) {
        await _openTab(tester, label);
        expect(find.byType(type), findsOneWidget, reason: label);
      }

      // Return later to a skipped question and answer it.
      await _tap(tester, _in<ResetTab>(find.text('The Mirror')));
      final first = _prompt('morning.01');
      expect(find.text(first.question), findsOneWidget);
      expect(find.textContaining('Skipped. Come back anytime'), findsOneWidget);
      await _type(tester, find.byType(TextField), 'Ready now.');
      await _tap(tester, find.text('Save & continue'));
      final a = h.store.saved!.currentJourney!.answer('morning.01')!;
      expect(a.body, 'Ready now.');
      expect(a.skipped, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a malformed import is rejected; nothing is lost', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        content: _content,
        size: _phone,
      );
      await _openTab(tester, 'Journal');
      await _tap(tester, find.byKey(const ValueKey('journal-new-note')));
      await _type(
        tester,
        find.byKey(const ValueKey('journal-entry-body')),
        'Keep these words.',
      );
      await tester.pageBack();
      await _settle(tester);
      final before = h.store.raw;
      final writes = h.store.writes;

      await _openTab(tester, 'You');
      await _tap(tester, find.byKey(const ValueKey('you-data')));
      for (final bad in [
        '{ this is not json',
        '{"app":"something-else","format":1}',
        '',
      ]) {
        h.files.pickResult = bad;
        await _tap(tester, find.byKey(const ValueKey('data-import')));
        expect(find.byType(AlertDialog), findsNothing, reason: bad);
        expect(find.text("This file couldn't be used"), findsOneWidget);
        expect(find.text('Your current data was not changed.'), findsOneWidget);
        expect(h.state.data.journal.single.body, 'Keep these words.');
        expect(h.store.raw, before);
        expect(h.store.writes, writes);
      }
    });

    testWidgets('320 dp at 200 % text: the core loop stays usable', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        content: _content,
        size: const Size(320, 568),
        textScale: 2.0,
      );
      await _quickOnboarding(tester);
      await expectNoOverflow(tester);
      await _scrollToTop(tester);

      await _tap(
        tester,
        find.descendant(
          of: find.byKey(const ValueKey('today-next-step')),
          matching: find.text('Begin'),
        ),
      );
      final prompt = find.byType(GuidedPromptScreen);
      expect(prompt, findsOneWidget);
      // Lazily built below the fold on a small phone with large text.
      await _scrollTo(tester, find.byType(TextField), prompt);
      await _type(tester, find.byType(TextField), 'Small screen, big text.');
      await _scrollTo(tester, find.text('Save & continue'), prompt);
      await _tap(tester, find.text('Save & continue'));
      expect(h.state.answer('morning.01')!.body, 'Small screen, big text.');
      await expectNoOverflow(tester);
      await _tap(tester, find.byTooltip('Pause and return to the Reset'));

      for (final label in ['Reset', 'Compass', 'Journal', 'You', 'Today']) {
        await _openTab(tester, label);
        await expectNoOverflow(tester);
      }
      await _openTab(tester, 'Compass');
      final vision = find.descendant(
        of: find.byKey(const ValueKey('compass-field-vision')),
        matching: find.byType(TextField),
      );
      await _scrollTo(tester, vision, find.byType(CompassTab));
      await _type(tester, vision, 'Typed at 320 dp');
      await tester.pump(const Duration(milliseconds: 700));
      await _settle(tester);
      expect(h.state.compass.vision, 'Typed at 320 dp');
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failed save says so; "Export a copy" opens Your data', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        content: _content,
        size: _phone,
      );
      await _tap(
        tester,
        find.descendant(
          of: find.byKey(const ValueKey('today-next-step')),
          matching: find.text('Begin'),
        ),
      );
      h.store.failWrites = true;
      await _type(tester, find.byType(TextField), 'Words that must not vanish');
      await tester.pump(const Duration(milliseconds: 700));
      await _settle(tester);
      expect(find.text("Your last change couldn't be saved."), findsOneWidget);
      expect(_answerField(tester), 'Words that must not vanish');
      await _tap(tester, find.text('Export a copy'));
      expect(find.byType(DataScreen), findsOneWidget);
      h.store.failWrites = false;
    });

    testWidgets('every AppNav route reaches its real screen', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        content: _content,
        size: _phone,
      );
      final routes = <(String, Future<void> Function(BuildContext), Type)>[
        (
          'prompt',
          (c) => AppNav.openPrompt(c, 'morning.01'),
          GuidedPromptScreen,
        ),
        ('complete', AppNav.openResetComplete, ResetCompleteScreen),
        ('awakening', AppNav.openAwakening, AwakeningScreen),
        ('lesson', (c) => AppNav.openLesson(c, 'lesson.01'), LessonScreen),
        ('path day', (c) => AppNav.openPathDay(c, 5), PathDayScreen),
        ('project', AppNav.openProject, ProjectScreen),
        ('note', (c) => AppNav.openJournalEntry(c), JournalEntryScreen),
        ('review', (c) => AppNav.openReview(c), ReviewScreen),
        ('inspiration', AppNav.openInspiration, InspirationScreen),
        ('support', AppNav.openSupport, SupportScreen),
        ('reminders', AppNav.openReminders, RemindersScreen),
        ('data', AppNav.openData, DataScreen),
        ('avatar', AppNav.openPersonaBuilder, PersonaBuilderScreen),
      ];
      for (final (name, open, type) in routes) {
        unawaited(open(tester.element(find.byType(TodayTab))));
        await _settle(tester);
        expect(find.byType(type), findsOneWidget, reason: name);
        expect(find.text('Coming soon'), findsNothing, reason: name);
        await tester.binding.handlePopRoute();
        await _settle(tester);
        expect(find.byType(type), findsNothing, reason: name);
      }
      for (final (open, section) in [
        (AppNav.openMissions, CompassSection.missions),
        (AppNav.openCompass, CompassSection.compass),
      ]) {
        unawaited(open(tester.element(find.byType(TodayTab))));
        await _settle(tester);
        final pills = tester.widget<PillTabs<CompassSection>>(
          find.byType(PillTabs<CompassSection>),
        );
        expect(pills.selected, section);
        await _openTab(tester, 'Today');
      }
      expect(tester.takeException(), isNull);
    });
  });
}
