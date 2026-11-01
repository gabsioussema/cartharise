import 'dart:convert';
import 'dart:io';

import 'package:cartharise/content/en.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/missions/missions_logic.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/missions/quest_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

final _created = DateTime(2026, 11, 1, 9);

Quest quest(
  String id,
  String title, {
  QuestRecurrence recurrence = QuestRecurrence.none,
  String? dueDate,
  Set<String> completedOn = const {},
  DateTime? createdAt,
}) => Quest(
  id: id,
  title: title,
  createdAt: createdAt ?? _created,
  recurrence: recurrence,
  dueDate: dueDate,
  completedOn: completedOn,
);

AppData missionsData({
  List<Quest> quests = const [],
  LifeCompass compass = const LifeCompass(),
  MonthProject? project,
  Map<int, String> path = const {},
}) => onboardedData().copyWith(
  quests: quests,
  compass: compass,
  project: () => project,
  pathAnswers: {
    for (final e in path.entries)
      e.key: PathAnswer(
        day: e.key,
        body: e.value,
        updatedAt: DateTime(2026, 11, 2, 20),
      ),
  },
);

Future<CarthaHarness> pumpMissions(
  WidgetTester tester, {
  AppData? data,
  DateTime? now,
  Size size = const Size(390, 844),
  double textScale = 1,
  Brightness brightness = Brightness.dark,
}) => pumpCartha(
  tester,
  data: data ?? onboardedData(),
  home: const CompassTab(initial: CompassSection.missions),
  now: now,
  size: size,
  textScale: textScale,
  brightness: brightness,
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

Finder textFieldIn(Finder parent) =>
    find.descendant(of: parent, matching: find.byType(TextField));

double top(WidgetTester tester, Finder f) => tester.getTopLeft(f).dy;

Future<AppState> loadedState({
  AppData? data,
  DateTime Function()? clock,
}) async {
  final state = AppState(
    store: MemoryDataStore(data ?? onboardedData()),
    content: fakeContent,
    reminders: FakeReminderScheduler(),
    clock: clock ?? () => kTestNow,
  );
  await state.load();
  return state;
}

void main() {
  group('missions logic', () {
    test(
      'sections: dailies in Today, dated one-offs by date, Done apart',
      () async {
        final state = await loadedState(
          data: missionsData(
            quests: [
              quest('later', 'Upcoming', dueDate: '2026-11-10'),
              quest('anytime', 'Anytime'),
              quest('daily', 'Walk', recurrence: QuestRecurrence.daily),
              quest('past', 'From Monday', dueDate: '2026-11-02'),
              quest('today', 'Due today', dueDate: '2026-11-03'),
              quest('doneOld', 'Done before', completedOn: {'2026-11-01'}),
              quest('doneNew', 'Done today', completedOn: {'2026-11-03'}),
              quest(
                'dailyDone',
                'Read',
                recurrence: QuestRecurrence.daily,
                completedOn: {'2026-11-03'},
              ),
            ],
          ),
        );
        final s = state.missionSections();
        expect(s.today.map((q) => q.id), [
          'past',
          'daily',
          'today',
          'dailyDone',
        ]);
        expect(s.later.map((q) => q.id), ['anytime', 'later']);
        expect(s.done.map((q) => q.id), ['doneNew', 'doneOld']);
        // Next day: the daily tick does not carry over.
        final tomorrow = state.missionSections('2026-11-04');
        expect(tomorrow.today.where((q) => q.isDoneOn('2026-11-04')), isEmpty);
      },
    );

    test('editing daily → one-off keeps it done only if done today', () async {
      final state = await loadedState(
        data: missionsData(
          quests: [
            quest(
              'a',
              'Old tick',
              recurrence: QuestRecurrence.daily,
              completedOn: {'2026-11-01'},
            ),
            quest(
              'b',
              'Ticked today',
              recurrence: QuestRecurrence.daily,
              completedOn: {'2026-11-01', '2026-11-03'},
            ),
          ],
        ),
      );
      await state.editQuest(
        state.questById('a')!,
        title: ' Old tick ',
        recurrence: QuestRecurrence.none,
        dueDate: '2026-11-05',
      );
      final a = state.questById('a')!;
      expect(a.title, 'Old tick');
      expect(a.completedOn, isEmpty);
      expect(a.dueDate, '2026-11-05');
      await state.editQuest(
        state.questById('b')!,
        title: 'Ticked today',
        recurrence: QuestRecurrence.none,
      );
      expect(state.questById('b')!.completedOn, {'2026-11-03'});
      // Daily quests never keep a date.
      await state.editQuest(
        state.questById('a')!,
        title: 'Old tick',
        recurrence: QuestRecurrence.daily,
        dueDate: '2026-11-05',
      );
      expect(state.questById('a')!.dueDate, isNull);
      expect(
        () => state.editQuest(a, title: '  ', recurrence: QuestRecurrence.none),
        throwsArgumentError,
      );
    });

    test('restoreQuest puts a deleted quest back in place, once', () async {
      final state = await loadedState(
        data: missionsData(
          quests: [quest('a', 'A'), quest('b', 'B'), quest('c', 'C')],
        ),
      );
      final b = state.questById('b')!;
      await state.deleteQuest('b');
      await state.restoreQuest(b, 1);
      await state.restoreQuest(b, 1);
      expect(state.data.quests.map((q) => q.id), ['a', 'b', 'c']);
    });

    test('project: draft from the Compass, created on first change', () async {
      final state = await loadedState(
        data: missionsData(
          compass: const LifeCompass(monthProject: '  Launch the newsletter '),
        ),
      );
      expect(state.data.project, isNull);
      expect(state.projectOrDraft.title, 'Launch the newsletter');
      await state.setProjectStatus(ProjectStatus.active);
      expect(state.data.project!.title, 'Launch the newsletter');
      expect(state.data.project!.status, ProjectStatus.active);
      final outline = await state.addMilestone(' Outline ');
      final draft = await state.addMilestone('Draft');
      expect(outline.title, 'Outline');
      await state.setMilestoneDone(outline.id, true);
      await state.renameMilestone(draft.id, 'First draft');
      expect(state.data.project!.milestones.map((m) => (m.title, m.done)), [
        ('Outline', true),
        ('First draft', false),
      ]);
      await state.deleteMilestone(outline.id);
      expect(state.data.project!.milestones, hasLength(1));
      await state.restoreMilestone(outline.copyWith(done: true), 0);
      expect(state.data.project!.milestones.first.id, outline.id);
      await state.setProjectRetrospective(' kept as typed ');
      expect(state.data.project!.retrospective, ' kept as typed ');
      expect(() => state.addMilestone(' '), throwsArgumentError);
      // The Compass itself is never changed by project edits.
      expect(state.compass.monthProject, '  Launch the newsletter ');
    });

    test('path: written means non-blank words', () async {
      final state = await loadedState(
        data: missionsData(path: {1: 'Noticed a lot', 2: '   ', 30: 'x'}),
      );
      expect(state.pathWritten(1), isTrue);
      expect(state.pathWritten(2), isFalse);
      expect(state.pathWritten(3), isFalse);
      expect(state.pathWrittenCount, 2);
    });
  });

  test('Compass + Missions copy never judges (F-031)', () {
    final guilt = RegExp(
      r'streak|missed|points|score|fail|behind|lazy|should have|you must',
      caseSensitive: false,
    );
    for (final file in ['compass_en.arb', 'missions_en.arb']) {
      final arb = jsonDecode(
        File('l10n_src/$file').readAsStringSync(),
      ) as Map<String, Object?>;
      for (final MapEntry(:key, :value) in arb.entries) {
        if (key.startsWith('@') || value is! String) continue;
        expect(guilt.hasMatch(value), isFalse, reason: '$file $key: $value');
      }
    }
  });

  group('quests (F-027, F-029, F-031)', () {
    for (final brightness in Brightness.values) {
      testWidgets(
        'calm empty state, no streaks or scores (${brightness.name})',
        (tester) async {
          await pumpMissions(tester, brightness: brightness);
          expect(find.text('Today'), findsOneWidget);
          expect(find.text('Tue, Nov 3'), findsOneWidget);
          expect(
            find.text(
              'Nothing planned for today. Add a small quest, or rest. Both are fine.',
            ),
            findsOneWidget,
          );
          expect(find.text('Anytime & upcoming'), findsOneWidget);
          expect(find.text('Month project'), findsOneWidget);
          expect(find.text('30-day path'), findsOneWidget);
          expect(
            find.textContaining(
              RegExp(r'streak|missed|points|score|fail', caseSensitive: false),
            ),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('add a one-off and a daily quest', (tester) async {
      final h = await pumpMissions(tester);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('missions-add-quest')),
      );
      expect(find.text('New quest'), findsOneWidget);
      // A title is needed.
      await tapVisible(tester, find.text('Save quest'));
      expect(find.text('Give the quest a few words.'), findsOneWidget);
      await typeInto(
        tester,
        find.byKey(const ValueKey('quest-title')),
        'Call Ana',
      );
      await tapVisible(tester, find.text('Save quest'));
      expect(find.byType(QuestSheet), findsNothing);

      await tapVisible(
        tester,
        find.byKey(const ValueKey('missions-add-quest')),
      );
      await typeInto(
        tester,
        find.byKey(const ValueKey('quest-title')),
        'Walk 20 minutes',
      );
      await tapVisible(tester, find.text('Repeat every day'));
      await tapVisible(tester, find.text('Save quest'));

      final quests = h.state.data.quests;
      expect(quests.map((q) => (q.title, q.recurrence)), [
        ('Call Ana', QuestRecurrence.none),
        ('Walk 20 minutes', QuestRecurrence.daily),
      ]);
      // The daily one is in Today, the undated one-off under Anytime.
      final later = top(tester, find.text('Anytime & upcoming'));
      expect(top(tester, find.text('Walk 20 minutes')), lessThan(later));
      expect(top(tester, find.text('Call Ana')), greaterThan(later));
      expect(find.text('Every day'), findsOneWidget);
    });

    testWidgets('complete, reopen, delete and undo', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await pumpMissions(
        tester,
        data: missionsData(
          quests: [quest('a', 'Call Ana'), quest('b', 'Book dentist')],
        ),
      );
      expect(find.bySemanticsLabel("Mark 'Call Ana' done"), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('quest-check-a')));
      expect(h.state.questById('a')!.isDoneOn('2026-11-03'), isTrue);
      expect(find.text("'Call Ana' moved to Done"), findsOneWidget);
      expect(find.text('Done (1)'), findsOneWidget);
      // Done is collapsed until opened.
      expect(find.byKey(const ValueKey('quest-check-a')), findsNothing);
      await tapVisible(tester, find.text('Done (1)'));
      expect(find.text('Done today'), findsOneWidget);
      final box = tester.widget<Checkbox>(
        find.byKey(const ValueKey('quest-check-a')),
      );
      expect(box.value, isTrue);
      // Reopen.
      await tapVisible(tester, find.byKey(const ValueKey('quest-check-a')));
      expect(h.state.questById('a')!.completedOn, isEmpty);
      expect(find.textContaining('Done ('), findsNothing);

      // Delete from the menu, then undo.
      await tester.pump(const Duration(seconds: 5));
      await tapVisible(tester, find.byTooltip("Options for 'Call Ana'"));
      await tapVisible(tester, find.text('Delete').last);
      expect(h.state.questById('a'), isNull);
      expect(find.text('Quest deleted'), findsOneWidget);
      await pumpFrames(tester); // the earlier snackbar leaves first
      await tester.tap(find.text('Undo'));
      await pumpFrames(tester);
      expect(h.state.data.quests.map((q) => q.id), ['a', 'b']);
      semantics.dispose();
    });

    testWidgets('daily quests reset each local day; history is kept', (
      tester,
    ) async {
      final data = missionsData(
        quests: [
          quest(
            'w',
            'Walk',
            recurrence: QuestRecurrence.daily,
            completedOn: {'2026-11-03'},
          ),
        ],
      );
      await pumpMissions(tester, data: data);
      final today = find.byKey(const ValueKey('quest-check-w'));
      expect(tester.widget<Checkbox>(today).value, isTrue);
      expect(find.text('Done today'), findsOneWidget);

      final h = await pumpMissions(
        tester,
        data: data,
        now: DateTime(2026, 11, 4, 7),
      );
      expect(tester.widget<Checkbox>(today).value, isFalse);
      expect(find.text('Done today'), findsNothing);
      expect(h.state.questById('w')!.completedOn, {'2026-11-03'});
      await tapVisible(tester, today);
      expect(h.state.questById('w')!.completedOn, {'2026-11-03', '2026-11-04'});
      // A daily quest is never "moved to Done".
      expect(find.textContaining('moved to Done'), findsNothing);
    });

    testWidgets('edit: rename, pick a date, then it shows as planned', (
      tester,
    ) async {
      final h = await pumpMissions(
        tester,
        data: missionsData(quests: [quest('r', 'Read')]),
      );
      await tapVisible(tester, find.text('Read'));
      expect(find.text('Edit quest'), findsOneWidget);
      await typeInto(
        tester,
        find.byKey(const ValueKey('quest-title')),
        'Read 10 pages',
      );
      await tapVisible(tester, find.byKey(const ValueKey('quest-date')));
      await tester.tap(find.text('10'));
      await tester.tap(find.text('OK'));
      await pumpFrames(tester);
      expect(find.text('Tue, Nov 10'), findsOneWidget);
      await tapVisible(tester, find.text('Save quest'));
      final r = h.state.questById('r')!;
      expect(r.title, 'Read 10 pages');
      expect(r.dueDate, '2026-11-10');
      expect(find.text('Planned for Tue, Nov 10'), findsOneWidget);

      // Planned for today → it moves into Today.
      await tapVisible(tester, find.text('Read 10 pages'));
      await tapVisible(tester, find.text('Remove date'));
      expect(find.text('Anytime'), findsOneWidget);
      await tapVisible(tester, find.text('Save quest'));
      expect(h.state.questById('r')!.dueDate, isNull);
      await h.state.editQuest(
        h.state.questById('r')!,
        title: 'Read 10 pages',
        recurrence: QuestRecurrence.none,
        dueDate: '2026-11-03',
      );
      await pumpFrames(tester);
      expect(
        top(tester, find.text('Read 10 pages')),
        lessThan(top(tester, find.text('Anytime & upcoming'))),
      );
    });

    testWidgets('delete from the edit sheet offers undo', (tester) async {
      final h = await pumpMissions(
        tester,
        data: missionsData(quests: [quest('r', 'Read')]),
      );
      await tapVisible(tester, find.text('Read'));
      await tapVisible(tester, find.text('Delete quest'));
      expect(h.state.data.quests, isEmpty);
      await tester.tap(find.text('Undo'));
      await pumpFrames(tester);
      expect(h.state.questById('r'), isNotNull);
    });
  });

  group('lever drafts (F-028)', () {
    testWidgets('≤3 drafts, duplicates skipped, editable, only ticked added', (
      tester,
    ) async {
      final h = await pumpMissions(
        tester,
        data: missionsData(
          compass: const LifeCompass(
            dailyLevers:
                '- Walk 20 minutes\n- Read 10 pages\n• Write one page\n'
                '1. Call a friend\n2. Stretch',
          ),
          quests: [quest('x', 'read 10 pages')],
        ),
      );
      expect(find.text('Turn your daily levers into quests'), findsOneWidget);
      String draft(int i) => tester
          .widget<TextField>(find.byKey(ValueKey('lever-draft-$i')))
          .controller!
          .text;
      expect(
        [draft(0), draft(1), draft(2)],
        ['Walk 20 minutes', 'Write one page', 'Call a friend'],
      );
      expect(find.byKey(const ValueKey('lever-draft-3')), findsNothing);
      expect(find.text('Add 3 daily quests'), findsOneWidget);

      await typeInto(
        tester,
        find.byKey(const ValueKey('lever-draft-0')),
        'Walk 15 minutes',
      );
      await tapVisible(tester, find.byKey(const ValueKey('lever-check-2')));
      expect(find.text('Add 2 daily quests'), findsOneWidget);
      await tapVisible(tester, find.text('Add 2 daily quests'));

      expect(find.text('2 daily quests added.'), findsOneWidget);
      final added = h.state.data.quests.skip(1).toList();
      expect(added.map((q) => q.title), ['Walk 15 minutes', 'Write one page']);
      expect(added.every((q) => q.recurrence == QuestRecurrence.daily), isTrue);
      expect(added.every((q) => q.source == QuestSource.dailyLever), isTrue);
      // Handled: the card stays away for these levers this session.
      expect(find.text('Turn your daily levers into quests'), findsNothing);
    });

    testWidgets('a draft edited into an existing quest is reported', (
      tester,
    ) async {
      final h = await pumpMissions(
        tester,
        data: missionsData(
          compass: const LifeCompass(dailyLevers: 'Stretch'),
          quests: [quest('x', 'Walk')],
        ),
      );
      await typeInto(
        tester,
        find.byKey(const ValueKey('lever-draft-0')),
        'walk',
      );
      await tapVisible(tester, find.text('Add 1 daily quest'));
      expect(
        find.text('Nothing new to add. Those quests already exist.'),
        findsOneWidget,
      );
      expect(h.state.data.quests, hasLength(1));
    });

    testWidgets('"Not now" puts the drafts aside without adding', (
      tester,
    ) async {
      final h = await pumpMissions(
        tester,
        data: missionsData(compass: const LifeCompass(dailyLevers: 'Stretch')),
      );
      await tapVisible(tester, find.text('Not now'));
      expect(find.text('Turn your daily levers into quests'), findsNothing);
      expect(h.state.data.quests, isEmpty);
    });
  });

  group('month project (F-030)', () {
    testWidgets('prefilled and linked; editing offers to update the Compass', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: missionsData(
          compass: const LifeCompass(monthProject: 'Launch the newsletter'),
        ),
        home: const ProjectScreen(),
      );
      final title = find.byKey(const ValueKey('project-title'));
      expect(
        tester.widget<TextField>(title).controller!.text,
        'Launch the newsletter',
      );
      expect(find.text('Linked to your Compass'), findsOneWidget);
      expect(h.state.data.project, isNull, reason: 'nothing saved yet');

      await typeInto(tester, title, 'Launch the newsletter, issue one');
      expect(
        find.text(
          'Your Compass says: Launch the newsletter. Update it to match?',
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 700));
      expect(h.state.data.project!.title, 'Launch the newsletter, issue one');
      expect(h.state.compass.monthProject, 'Launch the newsletter');

      await tapVisible(tester, find.text('Update Compass'));
      expect(h.state.compass.monthProject, 'Launch the newsletter, issue one');
      expect(find.text('Compass updated'), findsOneWidget);
      expect(find.text('Linked to your Compass'), findsOneWidget);

      // "Keep as is" hides the offer and changes nothing.
      await typeInto(tester, title, 'Something else');
      await tapVisible(tester, find.text('Keep as is'));
      expect(find.text('Update Compass'), findsNothing);
      expect(h.state.compass.monthProject, 'Launch the newsletter, issue one');
    });

    testWidgets('status, milestones, retrospective; start a new project', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await pumpCartha(
        tester,
        data: missionsData(compass: const LifeCompass(monthProject: 'Ship')),
        home: const ProjectScreen(),
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('project-status-active')),
      );
      expect(h.state.data.project!.status, ProjectStatus.active);
      expect(h.state.data.project!.title, 'Ship');

      for (final name in ['Outline', 'Draft']) {
        await tapVisible(tester, find.byKey(const ValueKey('milestone-add')));
        await tester.enterText(find.byType(TextField).last, name);
        await tester.tap(find.text('Add'));
        await pumpFrames(tester);
      }
      final ms = h.state.data.project!.milestones;
      expect(ms.map((m) => m.title), ['Outline', 'Draft']);
      expect(
        find.bySemanticsLabel("Mark milestone 'Outline' done"),
        findsOneWidget,
      );
      await tapVisible(
        tester,
        find.byKey(ValueKey('milestone-check-${ms.first.id}')),
      );
      expect(h.state.data.project!.milestones.first.done, isTrue);
      expect(find.text('1 of 2 milestones done'), findsOneWidget);

      await tapVisible(tester, find.byTooltip("Rename 'Draft'"));
      await tester.enterText(find.byType(TextField).last, 'First draft');
      await tester.tap(find.text('Save'));
      await pumpFrames(tester);
      expect(h.state.data.project!.milestones.last.title, 'First draft');

      await tapVisible(tester, find.byTooltip("Delete 'Outline'"));
      expect(h.state.data.project!.milestones, hasLength(1));
      await tester.tap(find.text('Undo'));
      await pumpFrames(tester);
      expect(h.state.data.project!.milestones.map((m) => m.title), [
        'Outline',
        'First draft',
      ]);

      final retro = textFieldIn(find.byKey(const ValueKey('project-retro')));
      await typeInto(tester, retro, ' Worked: mornings. ');
      await tester.pump(const Duration(milliseconds: 700));
      expect(h.state.data.project!.retrospective, ' Worked: mornings. ');

      await tester.pump(const Duration(seconds: 5));
      await tapVisible(tester, find.text('Start a new project'));
      expect(find.text('Start a new project?'), findsOneWidget);
      await tester.tap(find.text('Clear project'));
      await pumpFrames(tester);
      expect(h.state.data.project, isNull);
      expect(h.state.compass.monthProject, 'Ship');
      expect(tester.widget<TextField>(retro).controller!.text, isEmpty);
      semantics.dispose();
    });
  });

  group('30-day path (F-057)', () {
    testWidgets('grouped grid, any day open, autosaved note, prev/next', (
      tester,
    ) async {
      final h = await pumpMissions(tester, data: missionsData(path: {1: 'x'}));
      for (final header in [
        'Observe · Days 1–7',
        'Experiment · Days 8–15',
        'Build · Days 16–23',
        'Adjust · Days 24–30',
      ]) {
        expect(find.text(header), findsOneWidget, reason: header);
      }
      for (var d = 1; d <= 30; d++) {
        expect(find.byKey(ValueKey('path-day-$d')), findsOneWidget);
      }
      expect(
        find.text('Any day is open — go at your own pace.'),
        findsOneWidget,
      );
      expect(find.text('1 of 30 written'), findsOneWidget);
      expect(find.text('Written'), findsOneWidget);

      // Day 12 is open even though day 2 isn't written.
      await tapVisible(tester, find.byKey(const ValueKey('path-day-12')));
      expect(find.byType(PathDayScreen), findsOneWidget);
      Finder onDay(String text) => find.descendant(
        of: find.byType(PathDayScreen),
        matching: find.text(text),
      );
      expect(onDay('Day 12 title'), findsOneWidget);
      expect(onDay('Day 12 · Experiment'), findsOneWidget);
      expect(onDay('Day 12 prompt?'), findsOneWidget);
      expect(onDay('Hint for day 12.'), findsOneWidget);

      final field = find.descendant(
        of: find.byType(PathDayScreen),
        matching: find.byType(TextField),
      );
      await typeInto(tester, field, '  My note.  ');
      // Leave at once: the note is saved without waiting.
      await tapVisible(tester, find.byKey(const ValueKey('path-next')));
      expect(onDay('Day 13 title'), findsOneWidget);
      expect(h.state.data.pathAnswers[12]!.body, '  My note.  ');
      expect(tester.widget<TextField>(field).controller!.text, isEmpty);
      await tapVisible(tester, find.byKey(const ValueKey('path-previous')));
      expect(tester.widget<TextField>(field).controller!.text, '  My note.  ');

      await tester.pageBack();
      await pumpFrames(tester);
      expect(find.text('2 of 30 written'), findsOneWidget);
      expect(find.text('Written'), findsNWidgets(2));
      expect(h.store.saved!.pathAnswers[12]!.body, '  My note.  ');
    });

    testWidgets('first and last days have one way to go', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const PathDayScreen(day: 1),
      );
      expect(find.byKey(const ValueKey('path-previous')), findsNothing);
      expect(find.byKey(const ValueKey('path-next')), findsOneWidget);
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const PathDayScreen(day: 30),
      );
      expect(find.byKey(const ValueKey('path-next')), findsNothing);
      expect(find.byKey(const ValueKey('path-previous')), findsOneWidget);
    });

    testWidgets('shows the real English path content', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        content: englishContent,
        home: const PathDayScreen(day: 1),
      );
      expect(find.text(englishContent.thirtyDays.first.title), findsOneWidget);
      expect(find.text('Day 1 · Observe'), findsOneWidget);
    });
  });

  group('screen sizes', () {
    final data = missionsData(
      compass: const LifeCompass(
        dailyLevers:
            '- A long lever that wraps over several lines on a phone\n'
            '- Read\n- Stretch',
        monthProject: 'Finish the garden shed before the first frost',
      ),
      quests: [
        quest(
          'd',
          'Walk twenty minutes after lunch, even when it rains a little',
          recurrence: QuestRecurrence.daily,
          completedOn: {'2026-11-03'},
        ),
        quest('t', 'Call the plumber', dueDate: '2026-11-02'),
        quest('u', 'Plan the weekend trip', dueDate: '2026-11-20'),
        quest('a', 'Anytime quest'),
        quest('x', 'Finished quest', completedOn: {'2026-11-01'}),
      ],
      project: MonthProject(
        title: 'Finish the garden shed',
        status: ProjectStatus.active,
        milestones: const [
          Milestone(id: 'm1', title: 'Buy the wood and the screws', done: true),
          Milestone(id: 'm2', title: 'Build the frame'),
        ],
        retrospective: 'Mornings worked best.',
        updatedAt: DateTime(2026, 11, 2),
      ),
      path: {1: 'Noticed', 2: 'More', 9: 'Tried'},
    );
    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('missions, quest sheet, project and path day fit $size '
            '(${brightness.name})', (tester) async {
          await pumpMissions(
            tester,
            data: data,
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await tapVisible(tester, find.text('Done (1)'));
          await expectNoOverflow(tester);

          await tapVisible(tester, find.text('Call the plumber'));
          await tapVisible(tester, find.text('Repeat every day'));
          await tapVisible(tester, find.text('Repeat every day'));
          await expectNoOverflow(tester);
          Navigator.of(tester.element(find.byType(QuestSheet))).pop();
          await pumpFrames(tester);

          await tapVisible(
            tester,
            find.byKey(const ValueKey('missions-project')),
          );
          expect(find.byType(ProjectScreen), findsOneWidget);
          await expectNoOverflow(tester);
          await tester.pageBack();
          await pumpFrames(tester);

          await tapVisible(tester, find.byKey(const ValueKey('path-day-2')));
          expect(find.byType(PathDayScreen), findsOneWidget);
          await expectNoOverflow(tester);
        });
      }
    }

    for (final size in kSizeMatrix) {
      testWidgets('project with the Compass offer fits $size', (tester) async {
        await pumpCartha(
          tester,
          data: data,
          home: const ProjectScreen(),
          size: size.size,
          textScale: size.textScale,
        );
        expect(find.text('Update Compass'), findsOneWidget);
        await expectNoOverflow(tester);
      });
    }
  });
}
