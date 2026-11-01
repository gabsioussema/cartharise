import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/ui/compass/compass_import.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/compass/compass_versions.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// Onboarded data whose current reset has these evening answers.
AppData eveningData({
  Map<String, String> answers = const {},
  LifeCompass compass = const LifeCompass(),
  List<CompassVersion> history = const [],
}) {
  final at = DateTime(2026, 11, 2, 21);
  final journey = Journey(
    id: 'journey_1',
    startedAt: DateTime(2026, 11, 2, 7),
    answers: {
      for (final e in answers.entries)
        e.key: ReflectionAnswer(promptId: e.key, body: e.value, updatedAt: at),
    },
  );
  return onboardedData().copyWith(
    journeys: [journey],
    currentJourneyId: () => journey.id,
    compass: compass,
    compassHistory: history,
  );
}

const _answers = {
  'evening.03': '  I refuse to drift through another year.  ',
  'evening.04': 'A calm, creative life.',
  'evening.06': 'Ship the first version of my app.',
  'evening.07': '- Walk 20 minutes\n- Read 10 pages',
};

/// The text field of a Compass card.
Finder compassField(CompassField field) => find.descendant(
  of: find.byKey(ValueKey('compass-field-${field.name}')),
  matching: find.byType(TextField),
);

String fieldText(WidgetTester tester, CompassField field) =>
    tester.widget<TextField>(compassField(field)).controller!.text;

CheckboxListTile importRow(WidgetTester tester, CompassField field) =>
    tester.widget<CheckboxListTile>(
      find.byKey(ValueKey('compass-import-${field.name}')),
    );

/// A segment of the Compass | Missions pills.
Finder pill(String label) => find.descendant(
  of: find.byType(PillTabs<CompassSection>),
  matching: find.text(label),
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester, count: 4);
}

Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.pump();
  await tester.enterText(field, text);
  await tester.pump();
}

void main() {
  group('compass fields', () {
    for (final brightness in Brightness.values) {
      testWidgets(
        'six explained cards; boundaries are yours (${brightness.name})',
        (tester) async {
          await pumpCartha(
            tester,
            data: onboardedData(),
            home: const CompassTab(),
            brightness: brightness,
          );
          expect(find.text('Compass'), findsWidgets);
          expect(pill('Missions'), findsOneWidget);
          for (final (title, help) in [
            ('Anti-vision', 'What I refuse to let my life become.'),
            ('Vision', "What I'm building toward."),
            (
              'One-year mission',
              'The outcome that would matter most a year from now.',
            ),
            ('One-month project', 'One project for the next four weeks.'),
            ('Daily levers', '2–3 actions, one per line.'),
            ('Boundaries', "What I won't sacrifice."),
          ]) {
            expect(find.text(title), findsOneWidget, reason: title);
            expect(find.text(help), findsOneWidget, reason: help);
          }
          expect(find.text('Written only by you'), findsOneWidget);
          expect(find.text('Only you write this.'), findsOneWidget);
          // Empty Compass, no evening answers: a calm way in, no import offer.
          expect(find.text('Your Compass is empty'), findsOneWidget);
          expect(find.text('Use my evening reflections'), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('typing autosaves exactly as typed after a short pause', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const CompassTab(),
      );
      const text = '  A quiet house,\nwork I care about.  ';
      await typeInto(tester, compassField(CompassField.vision), text);
      await tester.pump(const Duration(milliseconds: 300));
      expect(h.state.compass.vision, isEmpty, reason: 'still debouncing');
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.state.compass.vision, text);
      await tester.pump();
      expect(h.store.saved!.compass.vision, text);
      expect(find.text('Saved on this device'), findsOneWidget);
      // The hero shows the vision and when the Compass changed.
      expect(find.textContaining('Last updated'), findsOneWidget);
    });

    testWidgets('switching to Missions saves typed text at once', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const CompassTab(),
      );
      await typeInto(tester, compassField(CompassField.constraints), 'Sleep');
      // Scroll back up (the field keeps focus) and switch section.
      await tapVisible(tester, pill('Missions'));
      expect(h.state.compass.constraints, 'Sleep');
      expect(find.text('Anytime & upcoming'), findsOneWidget);
    });

    testWidgets('daily levers link to Missions; month project opens', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData().copyWith(
          compass: const LifeCompass(dailyLevers: '- Walk\n- Read'),
        ),
        home: const CompassTab(),
      );
      await tapVisible(tester, find.text('Turn into quests'));
      expect(find.text('Turn your daily levers into quests'), findsOneWidget);
      await tapVisible(tester, pill('Compass'));
      await tapVisible(tester, find.text('Open month project'));
      expect(find.byType(ProjectScreen), findsOneWidget);
    });

    testWidgets('the empty state leads to the evening reflection', (
      tester,
    ) async {
      await pumpCartha(tester, data: onboardedData(), home: const CompassTab());
      await tapVisible(tester, find.text('Go to the evening reflection'));
      final screen = tester.widget<GuidedPromptScreen>(
        find.byType(GuidedPromptScreen),
      );
      expect(screen.promptId, 'evening.01');
    });
  });

  group('import from the evening (F-022, F-024, F-025)', () {
    testWidgets('quotes answers exactly; fields with text are kept', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: eveningData(
          answers: _answers,
          compass: const LifeCompass(vision: 'My own vision'),
        ),
        home: const CompassTab(),
      );
      expect(
        find.text('Evening answers can fill empty fields'),
        findsOneWidget,
      );
      await tapVisible(tester, find.text('Use my evening reflections').last);

      // Exactly as written, leading/trailing spaces included.
      expect(find.text(_answers['evening.03']!), findsOneWidget);
      expect(find.text(_answers['evening.07']!), findsOneWidget);
      expect(find.text('A calm, creative life.'), findsOneWidget);

      // Empty + answered → checked; has text → kept and disabled;
      // unanswered → disabled.
      expect(importRow(tester, CompassField.antiVision).value, isTrue);
      expect(importRow(tester, CompassField.monthProject).value, isTrue);
      expect(importRow(tester, CompassField.dailyLevers).value, isTrue);
      final vision = importRow(tester, CompassField.vision);
      expect(vision.value, isFalse);
      expect(vision.onChanged, isNull);
      expect(find.text('Keeps your current text'), findsOneWidget);
      final year = importRow(tester, CompassField.yearGoal);
      expect(year.onChanged, isNull);
      expect(find.text('No evening answer yet'), findsOneWidget);
      // Boundaries are never offered.
      expect(
        find.byKey(const ValueKey('compass-import-constraints')),
        findsNothing,
      );
      expect(find.text('Boundaries are only written by you.'), findsOneWidget);
      expect(find.text('Fill 3 fields'), findsOneWidget);

      // Untick the levers, confirm.
      await tapVisible(
        tester,
        find.byKey(const ValueKey('compass-import-dailyLevers')),
      );
      expect(find.text('Fill 2 fields'), findsOneWidget);
      await tapVisible(tester, find.text('Fill 2 fields'));
      await pumpFrames(tester, count: 6);

      expect(find.byType(CompassImportSheet), findsNothing);
      expect(
        find.text('2 Compass fields filled from your evening answers.'),
        findsOneWidget,
      );
      final c = h.state.compass;
      expect(c.antiVision, _answers['evening.03']);
      expect(c.monthProject, 'Ship the first version of my app.');
      expect(c.vision, 'My own vision');
      expect(c.dailyLevers, isEmpty, reason: 'unticked');
      expect(c.yearGoal, isEmpty);
      expect(c.constraints, isEmpty);
      expect(
        h.state.data.compassHistory.first.reason,
        CompassVersionReason.beforeImport,
      );
      // The cards on screen show the imported words.
      expect(
        fieldText(tester, CompassField.antiVision),
        _answers['evening.03'],
      );
      expect(fieldText(tester, CompassField.vision), 'My own vision');
    });

    testWidgets('text being typed counts as the field\'s own text', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: eveningData(answers: _answers),
        home: const CompassTab(),
      );
      // Typed but not yet autosaved when the sheet is opened.
      await typeInto(
        tester,
        compassField(CompassField.antiVision),
        'Written by me',
      );
      await tapVisible(tester, find.text('Use my evening reflections').last);
      expect(h.state.compass.antiVision, 'Written by me');
      expect(importRow(tester, CompassField.antiVision).onChanged, isNull);
      await tapVisible(tester, find.text('Fill 3 fields'));
      await pumpFrames(tester, count: 6);
      expect(h.state.compass.antiVision, 'Written by me');
      expect(h.state.compass.vision, 'A calm, creative life.');
      expect(h.state.compass.constraints, isEmpty);
    });

    testWidgets('"Not now" changes nothing', (tester) async {
      final h = await pumpCartha(
        tester,
        data: eveningData(answers: _answers),
        home: const CompassTab(),
      );
      await tapVisible(tester, find.text('Use my evening reflections').last);
      await tapVisible(tester, find.text('Not now'));
      expect(find.byType(CompassImportSheet), findsNothing);
      expect(h.state.compass.isEmpty, isTrue);
      expect(h.state.data.compassHistory, isEmpty);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('showCompassImport works from any screen', (tester) async {
      final h = await pumpCartha(
        tester,
        data: eveningData(answers: {'evening.04': 'Calm'}),
        home: const Scaffold(body: SizedBox.expand()),
      );
      showCompassImport(tester.element(find.byType(SizedBox)));
      await pumpFrames(tester);
      await tapVisible(tester, find.text('Fill 1 field'));
      await pumpFrames(tester);
      expect(h.state.compass.vision, 'Calm');
      expect(
        find.text('1 Compass field filled from your evening answers.'),
        findsOneWidget,
      );
    });

    testWidgets('nothing to import: the sheet says so honestly', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(body: SizedBox.expand()),
      );
      showCompassImport(tester.element(find.byType(SizedBox)));
      await pumpFrames(tester);
      expect(
        find.text(
          'Nothing to bring over yet. Answer the evening questions first.',
        ),
        findsOneWidget,
      );
      final confirm = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(confirm.onPressed, isNull);
    });
  });

  group('versions (F-026)', () {
    testWidgets('save, view read-only, restore after confirming', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData().copyWith(
          compass: const LifeCompass(vision: 'First', constraints: 'Sleep'),
        ),
        home: const CompassTab(),
      );
      await tapVisible(tester, find.text('Save a version'));
      expect(find.text('Version saved'), findsOneWidget);
      expect(h.state.data.compassHistory, hasLength(1));
      expect(
        h.state.data.compassHistory.first.reason,
        CompassVersionReason.manual,
      );
      // Let the snackbar time out so it doesn't cover the buttons below.
      await tester.pump(const Duration(seconds: 5));
      await pumpFrames(tester);

      await typeInto(tester, compassField(CompassField.vision), 'Second');
      await tester.pump(const Duration(milliseconds: 700));
      expect(h.state.compass.vision, 'Second');

      await tapVisible(tester, find.text('Versions (1)'));
      expect(find.byType(CompassVersionsScreen), findsOneWidget);
      expect(find.text('Saved by you'), findsOneWidget);
      expect(find.text('Vision: First'), findsOneWidget);
      await tester.tap(find.text('Vision: First'));
      await pumpFrames(tester);

      expect(find.byType(CompassVersionScreen), findsOneWidget);
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Differs from now'), findsOneWidget);
      expect(find.text('Same as now'), findsNWidgets(5));
      await tapVisible(tester, find.text('Restore this version'));
      expect(find.text('Restore this version?'), findsOneWidget);
      await tester.tap(find.text('Restore'));
      await pumpFrames(tester, count: 8);

      expect(find.byType(CompassVersionScreen), findsNothing);
      expect(find.byType(CompassVersionsScreen), findsNothing);
      expect(h.state.compass.vision, 'First');
      expect(h.state.compass.constraints, 'Sleep');
      final before = h.state.data.compassHistory.first;
      expect(before.reason, CompassVersionReason.beforeRestore);
      expect(before.compass.vision, 'Second');
      expect(fieldText(tester, CompassField.vision), 'First');
      expect(
        find.text('Version restored. The previous one was saved.'),
        findsOneWidget,
      );
    });

    testWidgets('cancelling a restore changes nothing', (tester) async {
      final version = CompassVersion(
        savedAt: DateTime(2026, 11, 1, 20),
        compass: const LifeCompass(vision: 'Old'),
        reason: CompassVersionReason.beforeImport,
      );
      final h = await pumpCartha(
        tester,
        data: onboardedData().copyWith(
          compass: const LifeCompass(vision: 'Now'),
          compassHistory: [version],
        ),
        home: CompassVersionScreen(version: version),
      );
      expect(find.text('Old'), findsOneWidget);
      await tapVisible(tester, find.text('Restore this version'));
      await tester.tap(find.text('Cancel'));
      await pumpFrames(tester);
      expect(h.state.compass.vision, 'Now');
      expect(h.state.data.compassHistory, hasLength(1));
    });

    testWidgets('no versions yet: a calm empty state', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const CompassVersionsScreen(),
      );
      expect(find.text('No versions yet'), findsOneWidget);
    });
  });

  group('shell', () {
    testWidgets(
      'openMissions shows Missions; the pills keep the shell in sync',
      (tester) async {
        final h = await pumpCartha(tester, data: onboardedData());
        AppNav.openMissions(tester.element(find.byType(TodayTab)));
        await pumpFrames(tester);
        expect(h.shell.tab, AppTab.compass);
        expect(find.text('Anytime & upcoming'), findsOneWidget);
        await tapVisible(tester, pill('Compass'));
        expect(h.shell.compassSection.value, CompassSection.compass);
        expect(find.text('Anytime & upcoming'), findsNothing);
        // Asking for Missions again is heard.
        AppNav.openMissions(tester.element(find.byType(CompassTab)));
        await pumpFrames(tester);
        expect(find.text('Anytime & upcoming'), findsOneWidget);
      },
    );

    testWidgets('pushed on its own it starts at the requested section', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(body: SizedBox.expand()),
      );
      Navigator.of(tester.element(find.byType(SizedBox))).push(
        MaterialPageRoute<void>(
          builder: (_) => const CompassTab(initial: CompassSection.missions),
        ),
      );
      await pumpFrames(tester);
      expect(find.text('Anytime & upcoming'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });
  });

  group('screen sizes', () {
    final data = eveningData(
      answers: _answers,
      compass: const LifeCompass(
        vision:
            'A slower, deliberate life with room for long walks, deep work '
            'and the people who matter, written long enough to wrap.',
        constraints: 'Eight hours of sleep.\nSundays with family.',
      ),
      history: [
        CompassVersion(
          savedAt: DateTime(2026, 11, 2, 21, 15),
          compass: const LifeCompass(vision: 'An earlier vision'),
          reason: CompassVersionReason.beforeImport,
        ),
      ],
    );
    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('compass, import sheet and versions fit $size '
            '(${brightness.name})', (tester) async {
          await pumpCartha(
            tester,
            data: data,
            home: const CompassTab(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await expectNoOverflow(tester);
          await tapVisible(
            tester,
            find.text('Use my evening reflections').last,
          );
          await expectNoOverflow(tester);
          await tapVisible(tester, find.text('Not now'));
          await tapVisible(tester, find.text('Versions (1)'));
          await expectNoOverflow(tester);
          await tapVisible(tester, find.text('Vision: An earlier vision'));
          await expectNoOverflow(tester);
        });
      }
    }
  });
}
