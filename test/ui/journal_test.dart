import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/journal/journal_kit.dart';
import 'package:cartharise/ui/journal/journal_tab.dart';
import 'package:cartharise/ui/journal/past_reset_screen.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// An onboarded user with two notes, a weekly review, a saved Compass
/// version and an earlier reset (kTestNow is Tue 3 Nov 2026, 09:30).
AppData journalData({AppSettings? settings}) {
  final base = onboardedData(settings: settings);
  return base.copyWith(
    journal: [
      JournalEntry(
        id: 'note_b',
        title: 'Evening walk',
        body: 'Noticed I think more clearly outside.\nSecond line.',
        createdAt: DateTime(2026, 11, 2, 20, 15),
      ),
      JournalEntry(
        id: 'note_a',
        body: 'First line becomes the headline\nand this stays inside.',
        createdAt: DateTime(2026, 10, 30, 7, 5),
        editedAt: DateTime(2026, 10, 31, 8),
      ),
    ],
    reviews: [
      WeeklyReview(
        id: 'review_1',
        weekStart: '2026-10-26',
        wins: 'Three calm mornings',
        friction: 'Late nights',
        nextExperiment: 'Phone out of the bedroom',
        createdAt: DateTime(2026, 11, 1, 18),
      ),
    ],
    compass: LifeCompass(
      antiVision: 'The same rushed days',
      vision: 'Calm mornings, focused work',
      updatedAt: DateTime(2026, 11, 2),
    ),
    compassHistory: [
      CompassVersion(
        savedAt: DateTime(2026, 10, 20, 8),
        compass: const LifeCompass(vision: 'Be less busy'),
        reason: CompassVersionReason.manual,
      ),
    ],
    journeys: [
      Journey(
        id: 'journey_old',
        startedAt: DateTime(2026, 9, 1, 7),
        completedAt: DateTime(2026, 9, 2, 21),
        answers: {
          'morning.01': ReflectionAnswer(
            promptId: 'morning.01',
            body: 'Old words, kept <exactly> & as typed',
            updatedAt: DateTime(2026, 9, 1, 7, 30),
          ),
          'morning.02': ReflectionAnswer(
            promptId: 'morning.02',
            skipped: true,
            updatedAt: DateTime(2026, 9, 1, 7, 40),
          ),
        },
      ),
      Journey(
        id: 'journey_now',
        startedAt: DateTime(2026, 10, 30, 7),
        answers: {
          'morning.01': ReflectionAnswer(
            promptId: 'morning.01',
            body: 'New words',
            updatedAt: DateTime(2026, 10, 30, 7, 30),
          ),
        },
      ),
    ],
    currentJourneyId: () => 'journey_now',
  );
}

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> _openJournal(WidgetTester tester) async {
  await tester.tap(_nav('Journal'));
  await pumpFrames(tester);
  expect(find.byType(JournalTab), findsOneWidget);
}

/// Scrolls every visible vertical list back to its start.
Future<void> _scrollToTop(WidgetTester tester) async {
  for (final element in find.byType(Scrollable).evaluate().toList()) {
    final state = (element as StatefulElement).state as ScrollableState;
    if (state.position.axis == Axis.vertical) state.position.jumpTo(0);
  }
  await tester.pump();
}

Future<void> _section(WidgetTester tester, String label) async {
  await _scrollToTop(tester);
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('journal-sections')),
      matching: find.text(label),
    ),
  );
  await pumpFrames(tester, count: 2);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester);
}

void main() {
  group('notes (F-032)', () {
    testWidgets('empty state, then create a note that autosaves', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openJournal(tester);
      expect(find.text('No notes yet'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('journal-new-note')));
      expect(find.byType(JournalEntryScreen), findsOneWidget);
      // Opening an empty note saves nothing.
      expect(h.state.data.journal, isEmpty);

      await tester.enterText(
        find.byKey(const ValueKey('journal-entry-title')),
        'Morning thoughts',
      );
      await tester.enterText(
        find.byKey(const ValueKey('journal-entry-body')),
        '  Words exactly as typed, with  spaces & <symbols>  ',
      );
      // Debounced: nothing yet, then saved after ~600 ms.
      await tester.pump(const Duration(milliseconds: 300));
      expect(h.state.data.journal, isEmpty);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      expect(h.state.data.journal, hasLength(1));
      final note = h.state.data.journal.single;
      expect(note.title, 'Morning thoughts');
      expect(note.body, '  Words exactly as typed, with  spaces & <symbols>  ');
      expect(note.createdAt.isAtSameMomentAs(kTestNow), isTrue);
      expect(find.text('Saved on this device'), findsOneWidget);
      expect(find.textContaining('Written Tue, Nov 3, 2026'), findsOneWidget);

      await tester.pageBack();
      await pumpFrames(tester);
      expect(find.text('Morning thoughts'), findsOneWidget);
      expect(find.textContaining('Tue, Nov 3, 2026'), findsOneWidget);
      // Persisted, not only in memory.
      expect(h.store.saved!.journal.single.body, note.body);
    });

    testWidgets('leaving right after typing still saves (flush on close)', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openJournal(tester);
      await _tap(tester, find.byKey(const ValueKey('journal-new-note')));
      await tester.enterText(
        find.byKey(const ValueKey('journal-entry-body')),
        'Quick thought',
      );
      await tester.pageBack();
      await pumpFrames(tester);
      expect(h.state.data.journal.single.body, 'Quick thought');
      expect(h.state.data.journal.single.title, isNull);
      expect(find.text('Quick thought'), findsOneWidget);
    });

    testWidgets('notes are listed newest first with title or first line', (
      tester,
    ) async {
      await pumpCartha(tester, data: journalData());
      await _openJournal(tester);
      final walk = tester.getTopLeft(find.text('Evening walk'));
      final older = tester.getTopLeft(
        find.text('First line becomes the headline'),
      );
      expect(walk.dy, lessThan(older.dy));
      expect(
        find.textContaining('Noticed I think more clearly'),
        findsOneWidget,
      );
      expect(find.text('Mon, Nov 2, 2026, 8:15 PM'), findsOneWidget);
    });

    testWidgets('edit an existing note: same note, edited time shown', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: journalData());
      await _openJournal(tester);
      await _tap(tester, find.text('Evening walk'));
      expect(find.text('Note'), findsOneWidget);
      expect(find.textContaining('Last edited'), findsNothing);
      await tester.enterText(
        find.byKey(const ValueKey('journal-entry-body')),
        'Rewritten',
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      final note = h.state.data.journal.firstWhere((e) => e.id == 'note_b');
      expect(note.body, 'Rewritten');
      expect(note.title, 'Evening walk');
      expect(
        note.createdAt.isAtSameMomentAs(DateTime(2026, 11, 2, 20, 15)),
        isTrue,
      );
      expect(note.editedAt!.isAtSameMomentAs(kTestNow), isTrue);
      expect(h.state.data.journal, hasLength(2));
      expect(
        find.textContaining('Last edited Tue, Nov 3, 2026'),
        findsOneWidget,
      );
    });

    testWidgets('delete asks first; cancel keeps, confirm removes', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: journalData());
      await _openJournal(tester);
      await _tap(tester, find.text('Evening walk'));
      await tester.tap(find.byTooltip('Delete note'));
      await pumpFrames(tester);
      expect(find.text('Delete this note?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await pumpFrames(tester);
      expect(h.state.data.journal, hasLength(2));

      await tester.tap(find.byTooltip('Delete note'));
      await pumpFrames(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await pumpFrames(tester);
      expect(find.byType(JournalEntryScreen), findsNothing);
      expect(h.state.data.journal.map((e) => e.id), ['note_a']);
      expect(find.text('Evening walk'), findsNothing);
      expect(find.text('Note deleted'), findsOneWidget);
    });

    testWidgets('a deleted note opened later says so calmly', (tester) async {
      await pumpCartha(
        tester,
        data: journalData(),
        home: const JournalEntryScreen(entryId: 'gone'),
      );
      expect(find.text("This note isn't here any more"), findsOneWidget);
      expect(find.byTooltip('Delete note'), findsNothing);
    });
  });

  group('weekly reviews (F-033)', () {
    testWidgets('create this week, view it, then delete it', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openJournal(tester);
      await _section(tester, 'Reviews');
      expect(find.text('No weekly reviews yet'), findsOneWidget);
      await _tap(
        tester,
        find.byKey(const ValueKey('journal-review-this-week')),
      );
      expect(find.byType(ReviewScreen), findsOneWidget);
      // The week defaults to the current one (Monday start).
      expect(find.text('Week of Nov 2, 2026'), findsOneWidget);
      expect(
        find.text('What went well this week, however small?'),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const ValueKey('review-wins')),
        'Walked every day',
      );
      await tester.enterText(
        find.byKey(const ValueKey('review-friction')),
        'Too many late nights',
      );
      await tester.enterText(
        find.byKey(const ValueKey('review-next')),
        'Lights out at 23:00',
      );
      await _tap(tester, find.byKey(const ValueKey('review-save')));
      final review = h.state.data.reviews.single;
      expect(review.weekStart, '2026-11-02');
      expect(review.wins, 'Walked every day');
      expect(review.friction, 'Too many late nights');
      expect(review.nextExperiment, 'Lights out at 23:00');
      // View mode: read-only text with Edit / Delete.
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Walked every day'), findsOneWidget);
      expect(find.byTooltip('Edit review'), findsOneWidget);

      await tester.pageBack();
      await pumpFrames(tester);
      expect(find.text('Week of Nov 2, 2026'), findsOneWidget);
      expect(find.text("Open this week's review"), findsOneWidget);

      await _tap(tester, find.text('Week of Nov 2, 2026'));
      await tester.tap(find.byTooltip('Delete review'));
      await pumpFrames(tester);
      expect(find.text('Delete this review?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await pumpFrames(tester);
      expect(h.state.data.reviews, isEmpty);
      expect(find.text('No weekly reviews yet'), findsOneWidget);
    });

    testWidgets('edit a saved review keeps its id and creation time', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: journalData());
      await _openJournal(tester);
      await _section(tester, 'Reviews');
      await _tap(tester, find.text('Week of Oct 26, 2026'));
      expect(find.text('Three calm mornings'), findsOneWidget);
      await tester.tap(find.byTooltip('Edit review'));
      await pumpFrames(tester);
      await tester.enterText(
        find.byKey(const ValueKey('review-wins')),
        'Four calm mornings',
      );
      await _tap(tester, find.byKey(const ValueKey('review-save')));
      final review = h.state.data.reviews.single;
      expect(review.id, 'review_1');
      expect(review.wins, 'Four calm mornings');
      expect(review.friction, 'Late nights');
      expect(
        review.createdAt.isAtSameMomentAs(DateTime(2026, 11, 1, 18)),
        isTrue,
      );
      expect(review.editedAt!.isAtSameMomentAs(kTestNow), isTrue);
      expect(find.text('Four calm mornings'), findsOneWidget);
    });

    testWidgets('an empty new review is not saved', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openJournal(tester);
      await _section(tester, 'Reviews');
      await _tap(
        tester,
        find.byKey(const ValueKey('journal-review-this-week')),
      );
      await _tap(tester, find.byKey(const ValueKey('review-save')));
      expect(find.byType(ReviewScreen), findsNothing);
      expect(h.state.data.reviews, isEmpty);
    });

    testWidgets('typing in a new review autosaves it', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openJournal(tester);
      await _section(tester, 'Reviews');
      await _tap(
        tester,
        find.byKey(const ValueKey('journal-review-this-week')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('review-friction')),
        'Busy week',
      );
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      expect(h.state.data.reviews.single.friction, 'Busy week');
      await tester.pageBack();
      await pumpFrames(tester);
      expect(h.state.data.reviews, hasLength(1));
    });
  });

  group('look back (F-034, F-035)', () {
    testWidgets('compares a saved Compass version with the Compass now', (
      tester,
    ) async {
      await pumpCartha(tester, data: journalData());
      await _openJournal(tester);
      await _section(tester, 'Look back');
      expect(find.text('Compare your Compass'), findsOneWidget);
      final vision = find.byKey(const ValueKey('compare-field-vision'));
      await tester.ensureVisible(vision);
      expect(
        find.descendant(of: vision, matching: find.text('Be less busy')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: vision,
          matching: find.text('Calm mornings, focused work'),
        ),
        findsOneWidget,
      );
      final anti = find.byKey(const ValueKey('compare-field-antiVision'));
      expect(
        find.descendant(of: anti, matching: find.text('Empty')),
        findsOneWidget,
      );
      // No scores or percentages anywhere.
      expect(find.textContaining(RegExp(r'\d\s*%')), findsNothing);
      expect(find.textContaining(RegExp(r'\bScore')), findsNothing);

      // Choose "Your Compass now" on both sides: the fields are the same.
      await _tap(tester, find.byKey(const ValueKey('compare-first')));
      await tester.tap(find.byKey(const ValueKey('compare-choice--1')));
      await pumpFrames(tester);
      expect(find.text('Same in both'), findsNWidgets(2));
    });

    testWidgets('no saved versions: explains and links to Compass', (
      tester,
    ) async {
      await pumpCartha(tester, data: onboardedData());
      await _openJournal(tester);
      await _section(tester, 'Look back');
      expect(find.text('No saved versions yet'), findsOneWidget);
      expect(find.text('Open Compass'), findsOneWidget);
      expect(find.textContaining('No earlier resets yet'), findsOneWidget);
    });

    testWidgets('an earlier reset reads back exactly, with optional compare', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: journalData());
      await _openJournal(tester);
      await _section(tester, 'Look back');
      await _tap(tester, find.byKey(const ValueKey('past-reset-journey_old')));
      expect(find.byType(PastResetScreen), findsOneWidget);
      expect(find.text('Old words, kept <exactly> & as typed'), findsOneWidget);
      expect(find.text('Skipped'), findsOneWidget);
      expect(find.text('New words'), findsNothing);
      // Read-only: no text fields.
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.byKey(const ValueKey('past-reset-compare')));
      await pumpFrames(tester);
      expect(find.text('New words'), findsOneWidget);
      expect(find.text('Then'), findsWidgets);
      // Reading changes nothing.
      expect(h.state.pastJourneys.single.answers, hasLength(2));
    });
  });

  group('kit', () {
    test('noteHeadline: title, else first non-empty line', () {
      final at = DateTime(2026);
      expect(
        noteHeadline(
          JournalEntry(id: 'a', title: ' T ', body: 'x', createdAt: at),
        ),
        'T',
      );
      expect(
        noteHeadline(
          JournalEntry(id: 'a', body: '\n  \n second \n', createdAt: at),
        ),
        'second',
      );
      expect(
        noteHeadline(JournalEntry(id: 'a', body: ' ', createdAt: at)),
        isNull,
      );
    });
  });

  group('screen sizes', () {
    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('journal screens fit $size (${brightness.name})', (
          tester,
        ) async {
          await pumpCartha(
            tester,
            data: journalData(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await _openJournal(tester);
          await expectNoOverflow(tester);

          await _tap(tester, find.text('Evening walk'));
          await expectNoOverflow(tester);
          await tester.pageBack();
          await pumpFrames(tester);

          await _section(tester, 'Reviews');
          await expectNoOverflow(tester);
          await _tap(tester, find.text('Week of Oct 26, 2026'));
          await expectNoOverflow(tester);
          await tester.tap(find.byTooltip('Edit review'));
          await pumpFrames(tester);
          await expectNoOverflow(tester);
          await tester.pageBack();
          await pumpFrames(tester);

          await _tap(
            tester,
            find.byKey(const ValueKey('journal-review-this-week')),
          );
          await expectNoOverflow(tester);
          await tester.pageBack();
          await pumpFrames(tester);

          await _section(tester, 'Look back');
          await expectNoOverflow(tester);
          await _tap(tester, find.byKey(const ValueKey('compare-second')));
          await expectNoOverflow(tester);
          await _tap(tester, find.byKey(const ValueKey('compare-choice-0')));
          await _tap(
            tester,
            find.byKey(const ValueKey('past-reset-journey_old')),
          );
          await _tap(tester, find.byKey(const ValueKey('past-reset-compare')));
          expect(find.text('New words'), findsOneWidget);
          await expectNoOverflow(tester);
        });
      }
    }
  });
}
