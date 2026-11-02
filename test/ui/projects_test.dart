// Projects (docs/plans/evolve.md, Step 2 → E): finishing a month project
// into the history with its retrospective exactly as typed, the history
// and one past project, quests and attempts linked to a project, the
// project's picture (a painted scene or a photo), restore keeping the
// history, sizes (dark + light) and accessibility.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart' show CompassField;
import 'package:cartharise/services/attachment_store.dart';
import 'package:cartharise/services/media_picker.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/missions/missions_logic.dart';
import 'package:cartharise/ui/missions/project_art.dart';
import 'package:cartharise/ui/missions/project_art_picker.dart';
import 'package:cartharise/ui/missions/project_finish.dart';
import 'package:cartharise/ui/missions/project_history_screen.dart';
import 'package:cartharise/ui/missions/project_ops.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/missions/quest_sheet.dart';
import 'package:cartharise/ui/widgets/art/lesson_art.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/test_app.dart';

final _t = kTestNow;

/// A real (1×1) PNG, so photos decode like a phone's would.
final Uint8List kPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

Attachment _photo(String id) => Attachment(
  id: id,
  kind: AttachmentKind.photo,
  fileName: '$id.jpg',
  createdAt: _t,
);

MonthProject _current({ProjectArt? art}) => MonthProject(
  id: 'project_now',
  title: 'Finish the first essay',
  status: ProjectStatus.active,
  updatedAt: _t,
  startedAt: DateTime(2026, 11, 1, 8),
  milestones: const [
    Milestone(id: 'm1', title: 'Outline', done: true),
    Milestone(id: 'm2', title: 'First draft'),
  ],
  retrospective: 'Mornings help.',
  art: art,
);

final _october = MonthProject(
  id: 'project_oct',
  title: 'Clear the garage',
  status: ProjectStatus.done,
  updatedAt: DateTime(2026, 10, 31, 18),
  startedAt: DateTime(2026, 10, 2, 9),
  archivedAt: DateTime(2026, 10, 31, 18),
  milestones: const [
    Milestone(id: 'g1', title: 'Sort the shelves', done: true),
    Milestone(id: 'g2', title: 'Sell the bike', done: true),
    Milestone(id: 'g3', title: 'Paint the wall'),
  ],
  retrospective: '  Two weekends were enough.\nAsk for help sooner.  ',
  art: const ProjectArt.illustration(ProjectIllustration.citadel),
);

final _september = MonthProject(
  id: 'project_sep',
  title: 'Walk to work',
  updatedAt: DateTime(2026, 9, 28, 19),
  startedAt: DateTime(2026, 8, 20, 7),
  archivedAt: DateTime(2026, 9, 28, 19),
  art: ProjectArt.photo(_photo('att_sep')),
);

Quest _quest(
  String id,
  String title, {
  String? projectId,
  QuestRecurrence recurrence = QuestRecurrence.none,
  Set<String> completedOn = const {},
}) => Quest(
  id: id,
  title: title,
  createdAt: DateTime(2026, 10, 2, 9),
  recurrence: recurrence,
  completedOn: completedOn,
  projectId: projectId,
);

/// A user with a current project, two finished ones (a scene, a photo),
/// quests and attempts linked to them, and one of each without a project.
AppData _data({
  MonthProject? project,
  bool current = true,
  List<MonthProject>? past,
  String compass = 'Finish the first essay',
}) => onboardedData().copyWith(
  compass: LifeCompass(monthProject: compass, updatedAt: _t),
  project: () => current ? (project ?? _current()) : null,
  pastProjects: past ?? [_october, _september],
  quests: [
    _quest(
      'q1',
      'Write 300 words',
      projectId: 'project_now',
      recurrence: QuestRecurrence.daily,
    ),
    _quest(
      'q2',
      'Sort the shelves',
      projectId: 'project_oct',
      completedOn: const {'2026-10-20'},
    ),
    _quest('q3', 'Give the bike away', projectId: 'project_oct'),
    _quest('q4', 'Call Mum'),
  ],
  campaignLog: [
    BattleLogEntry(
      id: 'a1',
      day: '2026-11-03',
      attempt: 'Wrote before work.',
      createdAt: _t,
      projectId: 'project_now',
    ),
    BattleLogEntry(
      id: 'a2',
      day: '2026-10-12',
      attempt: 'Emptied one corner.',
      learning: 'Start small.',
      createdAt: DateTime(2026, 10, 12, 18),
      projectId: 'project_oct',
    ),
    BattleLogEntry(
      id: 'a3',
      day: '2026-10-01',
      attempt: 'Just tried.',
      createdAt: DateTime(2026, 10, 1, 18),
    ),
  ],
);

/// The phone's attachments folder with the September photo in it.
MemoryAttachmentStore _folder() =>
    MemoryAttachmentStore(clock: () => _t)..files['att_sep.jpg'] = kPng;

Future<CarthaHarness> _pump(
  WidgetTester tester,
  Widget home, {
  AppData? data,
  MemoryAttachmentStore? attachments,
  Size size = const Size(390, 844),
  double textScale = 1,
  Brightness brightness = Brightness.dark,
}) => pumpCartha(
  tester,
  data: data ?? _data(),
  home: home,
  attachments: attachments ?? _folder(),
  size: size,
  textScale: textScale,
  brightness: brightness,
);

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester, count: 4);
}

double _top(WidgetTester tester, Finder f) => tester.getTopLeft(f).dy;

String _titleField(WidgetTester tester) =>
    tester.widget<TextField>(_key('project-title')).controller!.text;

/// Opens a button that shows a sheet from a plain page.
Widget _opener(Future<void> Function(BuildContext) open) => Scaffold(
  body: Builder(
    builder: (context) => Center(
      child: TextButton(
        key: const ValueKey('open-sheet'),
        onPressed: () => open(context),
        child: const Text('Open'),
      ),
    ),
  ),
);

Future<AppState> _phone(AppData? data, MemoryAttachmentStore files) async {
  final state = AppState(
    store: MemoryDataStore(data),
    content: fakeContent,
    reminders: FakeReminderScheduler(),
    attachments: files,
    clock: () => _t,
  );
  await state.load();
  return state;
}

void main() {
  group('look-ups', () {
    test('a finished name in the Compass starts no draft under it', () async {
      final state = await _phone(_data(current: false), _folder());
      expect(state.compassProjectFinished, isFalse);
      expect(state.projectShownTitle, 'Finish the first essay');
      await state.updateCompassField(CompassField.monthProject, 'Walk to work');
      expect(state.compassProjectFinished, isTrue);
      expect(state.projectShownTitle, isEmpty);
      await state.setProjectTitle('Read two books');
      expect(state.projectShownTitle, 'Read two books');
    });

    test('linked quests and attempts; the project a sheet offers', () async {
      final state = await _phone(_data(), _folder());
      expect(state.questsOfProject('project_oct').map((q) => q.id), [
        'q2',
        'q3',
      ]);
      expect(state.attemptsOfProject('project_now').map((e) => e.id), ['a1']);
      expect(state.attemptsOfProject('project_sep'), isEmpty);
      expect(state.linkableProjectFor(null)!.id, 'project_now');
      expect(
        state.linkableProjectFor(state.questById('q2'))!.id,
        'project_oct',
      );
      expect(
        state.linkableProjectFor(state.questById('q4'))!.id,
        'project_now',
      );
      // A finished (status) project collects no new tasks.
      await state.setProjectStatus(ProjectStatus.done);
      expect(state.linkableProjectFor(state.questById('q4')), isNull);
    });

    test('scenes map by name onto the brand and lesson scenes', () {
      for (final i in ProjectIllustration.values) {
        final scene = projectSceneKind(i);
        final lesson = projectLessonScene(i);
        expect(
          (scene == null) != (lesson == null),
          isTrue,
          reason: '${i.name} is exactly one painted scene',
        );
      }
      expect(
        projectSceneKind(ProjectIllustration.dawnRuins),
        SceneKind.dawnRuins,
      );
      expect(
        projectLessonScene(ProjectIllustration.sailing),
        LessonScene.sailing,
      );
    });
  });

  group('finish a project', () {
    testWidgets('the look back as typed; archived with its links; the next '
        'project starts under its own name', (tester) async {
      final h = await _pump(tester, const ProjectScreen());
      expect(_key('project-history-link'), findsOneWidget);
      expect(find.text('Project history · 2'), findsOneWidget);
      await _tap(tester, _key('project-finish'));
      expect(find.byType(FinishProjectSheet), findsOneWidget);
      final field = _key('project-finish-retro');
      expect(
        tester.widget<TextField>(field).controller!.text,
        'Mornings help.',
        reason: 'the notes so far, exactly',
      );
      const typed = "  Mornings help.\nEvenings don't.  ";
      await tester.enterText(field, typed);
      await tester.tap(_key('project-finish-confirm'));
      await pumpFrames(tester);

      expect(h.state.data.project, isNull);
      final archived = h.state.pastProjects.first;
      expect(archived.id, 'project_now');
      expect(archived.retrospective, typed);
      expect(archived.archivedAt, _t);
      expect(archived.milestones.map((m) => m.title), [
        'Outline',
        'First draft',
      ]);
      expect(h.store.saved!.pastProjects.first.retrospective, typed);
      expect(h.state.questById('q1')!.projectId, 'project_now');
      expect(h.state.attemptsOfProject('project_now'), hasLength(1));
      expect(find.text('Kept in your project history.'), findsOneWidget);
      expect(_key('project-finished'), findsOneWidget);
      expect(
        find.text('“Finish the first essay” is in your project history.'),
        findsOneWidget,
      );
      // The Compass keeps its words; the next draft doesn't reuse them.
      expect(h.state.compass.monthProject, 'Finish the first essay');
      expect(_titleField(tester), isEmpty);
      expect(_key('project-finish'), findsNothing);

      await _tap(tester, _key('project-finished-history'));
      expect(find.byType(ProjectHistoryScreen), findsOneWidget);
      expect(_key('past-project-project_now'), findsOneWidget);
      expect(
        _top(tester, _key('past-project-project_now')),
        lessThan(_top(tester, _key('past-project-project_oct'))),
        reason: 'newest first',
      );
      await tester.pageBack();
      await pumpFrames(tester);

      await _tap(tester, _key('project-finished-next'));
      expect(_key('project-finished'), findsNothing);
      // A milestone first: the new project has no name yet, not the old one.
      await _tap(tester, _key('milestone-add'));
      await tester.enterText(find.byType(TextField).last, 'Pick a topic');
      await tester.tap(find.text('Add'));
      await pumpFrames(tester);
      final next = h.state.data.project!;
      expect(next.id, isNot('project_now'));
      expect(next.title, isEmpty);
      expect(next.milestones.single.title, 'Pick a topic');
      await tester.enterText(_key('project-title'), 'Read two books');
      await tester.pump(const Duration(milliseconds: 700));
      expect(h.state.data.project!.title, 'Read two books');
      expect(
        find.text(
          'Your Compass says: Finish the first essay. Update it to match?',
        ),
        findsOneWidget,
      );
    });

    testWidgets('notes typed a moment ago come along; leaving the sheet '
        'keeps its words as the notes', (tester) async {
      final h = await _pump(tester, const ProjectScreen());
      final retro = find.descendant(
        of: _key('project-retro'),
        matching: find.byType(TextField),
      );
      await tester.ensureVisible(retro);
      await tester.enterText(retro, 'Typed just now');
      // No wait for the autosave: Finish saves it first.
      await _tap(tester, _key('project-finish'));
      expect(
        tester.widget<TextField>(_key('project-finish-retro')).controller!.text,
        'Typed just now',
      );
      expect(h.state.data.project!.retrospective, 'Typed just now');
      await tester.enterText(_key('project-finish-retro'), 'Half a thought');
      await tester.tap(_key('project-finish-cancel'));
      await pumpFrames(tester);
      expect(find.byType(FinishProjectSheet), findsNothing);
      expect(h.state.data.project!.id, 'project_now', reason: 'not finished');
      expect(h.state.pastProjects, hasLength(2));
      expect(h.state.data.project!.retrospective, 'Half a thought');
      expect(
        tester.widget<TextField>(retro).controller!.text,
        'Half a thought',
      );
    });

    testWidgets('a failed save never says "kept"', (tester) async {
      final h = await _pump(tester, const ProjectScreen());
      h.store.failWrites = true;
      await _tap(tester, _key('project-finish'));
      await tester.tap(_key('project-finish-confirm'));
      await pumpFrames(tester);
      expect(
        find.text('Not saved yet. Use Retry on this page.'),
        findsOneWidget,
      );
      expect(find.text('Kept in your project history.'), findsNothing);
      expect(_key('project-finished'), findsNothing);
      expect(h.state.saveStatus, SaveStatus.failed);
      h.store.failWrites = false;
      await _tap(tester, find.text('Retry'));
      expect(h.store.saved!.pastProjects.first.id, 'project_now');
    });

    testWidgets('"Delete this project" says it is for good and offers '
        '"Finish and keep instead"; Cancel changes nothing', (tester) async {
      final h = await _pump(tester, const ProjectScreen());
      // The old "Start a new project" dropped the project silently.
      expect(find.text('Start a new project'), findsNothing);
      await _tap(tester, _key('project-delete'));
      expect(find.text('Delete this project?'), findsOneWidget);
      expect(
        find.text(
          'Its title, milestones and notes go for good. Your Compass, tasks '
          'and attempts stay.',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancel'),
        ),
      );
      await pumpFrames(tester);
      expect(h.state.data.project!.id, 'project_now');
      expect(h.state.pastProjects, hasLength(2));

      await _tap(tester, _key('project-delete'));
      await tester.tap(_key('dialog-alternative'));
      await pumpFrames(tester);
      expect(find.byType(FinishProjectSheet), findsOneWidget);
      await tester.tap(_key('project-finish-confirm'));
      await pumpFrames(tester);
      expect(h.state.data.project, isNull);
      final kept = h.state.pastProjects.first;
      expect(kept.id, 'project_now');
      expect(kept.milestones, hasLength(2));
      expect(kept.retrospective, 'Mornings help.');
      expect(h.store.saved!.pastProjects.first.id, 'project_now');
      expect(find.text('Kept in your project history.'), findsOneWidget);
    });

    testWidgets('a project is deleted only by an explicit "Delete": its '
        'photo goes, its tasks and attempts stay', (tester) async {
      final photo = _photo('att_now');
      final files = _folder()..files['att_now.jpg'] = kPng;
      final h = await _pump(
        tester,
        const ProjectScreen(),
        data: _data(project: _current(art: ProjectArt.photo(photo))),
        attachments: files,
      );
      await _tap(tester, _key('project-delete'));
      expect(
        find.text(
          'Its title, milestones, notes and photo go for good. Your Compass, '
          'tasks and attempts stay.',
        ),
        findsOneWidget,
      );
      await tester.tap(_key('dialog-confirm'));
      await pumpFrames(tester);
      expect(h.state.data.project, isNull);
      expect(h.state.pastProjects, hasLength(2), reason: 'deleted, not kept');
      expect(h.attachments.files.containsKey('att_now.jpg'), isFalse);
      expect(find.text('Project deleted'), findsOneWidget);
      expect(h.state.questById('q1'), isNotNull);
      expect(h.state.data.campaignLog.map((e) => e.id), contains('a1'));
    });

    testWidgets('no saved project: nothing to finish', (tester) async {
      await _pump(
        tester,
        const ProjectScreen(),
        data: _data(current: false, past: const []),
      );
      expect(_key('project-finish'), findsNothing);
      expect(_key('project-history-link'), findsNothing);
    });
  });

  group('history', () {
    testWidgets('newest first: picture, title, months, milestones, links, '
        'the look back', (tester) async {
      await _pump(tester, const ProjectHistoryScreen());
      expect(find.text('Past projects'), findsOneWidget);
      final oct = _key('past-project-project_oct');
      final sep = _key('past-project-project_sep');
      expect(_top(tester, oct), lessThan(_top(tester, sep)));
      Finder inCard(Finder card, String text) =>
          find.descendant(of: card, matching: find.text(text));
      expect(inCard(oct, 'Clear the garage'), findsOneWidget);
      expect(inCard(oct, 'Oct 2026'), findsOneWidget);
      expect(inCard(oct, '2 of 3 milestones done'), findsOneWidget);
      expect(inCard(oct, '2 tasks'), findsOneWidget);
      expect(inCard(oct, '1 attempt'), findsOneWidget);
      expect(
        inCard(oct, '  Two weekends were enough.\nAsk for help sooner.  '),
        findsOneWidget,
        reason: 'exactly as typed',
      );
      expect(inCard(sep, 'Aug 2026 – Sep 2026'), findsOneWidget);
      expect(inCard(sep, 'No milestones'), findsOneWidget);
      expect(inCard(sep, 'No tasks'), findsOneWidget);
      expect(inCard(sep, 'No attempts'), findsOneWidget);
      await tester.ensureVisible(sep);
      await tester.pump();
      expect(
        find.descendant(of: sep, matching: _key('project-photo-att_sep')),
        findsOneWidget,
      );
    });

    testWidgets('one past project in full; removing it keeps its tasks', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        const ProjectHistoryScreen(),
        size: const Size(390, 3000),
      );
      await _tap(tester, _key('past-project-project_oct'));
      final screen = find.byType(PastProjectScreen);
      expect(screen, findsOneWidget);
      Finder onScreen(String text) =>
          find.descendant(of: screen, matching: find.text(text));
      expect(onScreen('Past project'), findsOneWidget);
      expect(onScreen('Clear the garage'), findsOneWidget);
      expect(onScreen('Oct 2026'), findsOneWidget);
      expect(onScreen('Finished Oct 31, 2026'), findsOneWidget);
      Finder row(String key, String word) =>
          find.descendant(of: _key(key), matching: find.text(word));
      expect(row('past-milestone-g1', 'Done'), findsOneWidget);
      expect(row('past-milestone-g3', 'Open'), findsOneWidget);
      expect(
        onScreen('  Two weekends were enough.\nAsk for help sooner.  '),
        findsOneWidget,
      );
      expect(row('past-task-q2', 'Sort the shelves'), findsOneWidget);
      expect(row('past-task-q2', 'Done'), findsOneWidget);
      expect(row('past-task-q3', 'Open'), findsOneWidget);
      expect(find.text('Call Mum'), findsNothing);
      expect(row('past-attempt-a2', 'Emptied one corner.'), findsOneWidget);
      expect(row('past-attempt-a2', 'Learned: Start small.'), findsOneWidget);
      expect(find.text('Wrote before work.'), findsNothing);

      await _tap(tester, _key('past-project-delete'));
      expect(find.text('Remove this project?'), findsOneWidget);
      await tester.tap(find.text('Remove'));
      await pumpFrames(tester);
      expect(find.byType(PastProjectScreen), findsNothing);
      expect(find.text('Project removed'), findsOneWidget);
      expect(h.state.pastProjects.map((p) => p.id), ['project_sep']);
      expect(h.state.questById('q2')!.title, 'Sort the shelves');
      expect(h.state.data.campaignLog.map((e) => e.id), contains('a2'));
      expect(_key('past-project-project_oct'), findsNothing);
    });

    testWidgets('removing a project with a photo deletes the photo', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        const PastProjectScreen(projectId: 'project_sep'),
      );
      expect(h.attachments.files.keys, ['att_sep.jpg']);
      await _tap(tester, _key('past-project-delete'));
      await tester.tap(find.text('Remove'));
      await pumpFrames(tester);
      expect(h.state.pastProjects.map((p) => p.id), ['project_oct']);
      expect(h.attachments.files, isEmpty);
    });

    testWidgets('empty: a calm line', (tester) async {
      await _pump(
        tester,
        const ProjectHistoryScreen(),
        data: _data(past: const []),
      );
      expect(_key('project-history-empty'), findsOneWidget);
      expect(find.text('Finish a month project to keep it here.'), findsOne);
    });

    testWidgets('reachable from the Collection', (tester) async {
      await _pump(
        tester,
        const CollectionScreen(),
        size: const Size(390, 3000),
      );
      final card = _key('collection-projects');
      expect(find.text('PROJECTS FINISHED'), findsOneWidget);
      expect(
        find.descendant(of: card, matching: find.text('Clear the garage')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('2 projects kept')),
        findsOneWidget,
      );
      await _tap(tester, card);
      expect(find.byType(ProjectHistoryScreen), findsOneWidget);
    });

    testWidgets('nothing in the Collection before a project is finished', (
      tester,
    ) async {
      await _pump(
        tester,
        const CollectionScreen(),
        data: _data(past: const []),
      );
      expect(_key('collection-projects'), findsNothing);
    });
  });

  group('links', () {
    testWidgets('quests show their project, small, with its picture', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pump(
        tester,
        const CompassTab(initial: CompassSection.missions),
        data: _data(
          project: _current(
            art: const ProjectArt.illustration(ProjectIllustration.sunrise),
          ),
        ),
        size: const Size(390, 2400),
      );
      final tag = _key('quest-project-q1');
      expect(
        find.descendant(of: tag, matching: find.byType(ProjectArtThumb)),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Project: Finish the first essay'),
        findsOne,
      );
      expect(_key('quest-project-q4'), findsNothing);
      // The card shows the picture too.
      expect(_key('missions-project-art'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a new quest joins the active project unless switched off', (
      tester,
    ) async {
      final h = await _pump(tester, _opener((c) => showQuestSheet(c)));
      await tester.tap(_key('open-sheet'));
      await pumpFrames(tester);
      final link = _key('quest-project-link');
      expect(tester.widget<SwitchListTile>(link).value, isTrue);
      expect(find.text('Part of the month project'), findsOneWidget);
      expect(
        find.descendant(
          of: link,
          matching: find.text('Finish the first essay'),
        ),
        findsOneWidget,
      );
      await tester.enterText(_key('quest-title'), 'Draft the intro');
      await _tap(tester, find.text('Save quest'));
      final added = h.state.data.quests.last;
      expect(added.title, 'Draft the intro');
      expect(added.projectId, 'project_now');

      await tester.tap(_key('open-sheet'));
      await pumpFrames(tester);
      await tester.enterText(_key('quest-title'), 'Buy stamps');
      await _tap(tester, _key('quest-project-link'));
      await _tap(tester, find.text('Save quest'));
      expect(h.state.data.quests.last.projectId, isNull);
    });

    testWidgets('link and unlink from the sheet; a finished project says so', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        _opener((c) async {
          final s = c.read<AppState>();
          await showQuestSheet(c, quest: s.questById(_open));
        }),
      );
      // q4: no project yet → offered the active one, off.
      _open = 'q4';
      await tester.tap(_key('open-sheet'));
      await pumpFrames(tester);
      expect(
        tester.widget<SwitchListTile>(_key('quest-project-link')).value,
        isFalse,
      );
      await _tap(tester, _key('quest-project-link'));
      await _tap(tester, find.text('Save quest'));
      expect(h.state.questById('q4')!.projectId, 'project_now');

      // q2 belongs to October's finished project: unlink it.
      _open = 'q2';
      await tester.tap(_key('open-sheet'));
      await pumpFrames(tester);
      expect(find.text('Part of a finished project'), findsOneWidget);
      expect(find.text('Clear the garage'), findsOneWidget);
      await _tap(tester, _key('quest-project-link'));
      await _tap(tester, find.text('Save quest'));
      expect(h.state.questById('q2')!.projectId, isNull);
      expect(h.state.questById('q2')!.title, 'Sort the shelves');
    });

    testWidgets('no project to link: no switch', (tester) async {
      await _pump(
        tester,
        _opener((c) => showQuestSheet(c)),
        data: _data(current: false),
      );
      await tester.tap(_key('open-sheet'));
      await pumpFrames(tester);
      expect(_key('quest-project-link'), findsNothing);
    });

    testWidgets('attempts show the project they were recorded for', (
      tester,
    ) async {
      final h = await _pump(
        tester,
        const BattleLogScreen(),
        size: const Size(390, 2000),
      );
      Finder tag(String id, String title) => find.descendant(
        of: _key('attempt-project-$id'),
        matching: find.text(title),
      );
      expect(tag('a1', 'Finish the first essay'), findsOneWidget);
      expect(tag('a2', 'Clear the garage'), findsOneWidget);
      expect(_key('attempt-project-a3'), findsNothing);

      await tester.enterText(_key('campaign-attempt'), 'Read it aloud.');
      await _tap(tester, _key('campaign-record'));
      final entry = h.state.data.campaignLog.first;
      expect(entry.projectId, 'project_now');
      expect(tag(entry.id, 'Finish the first essay'), findsOneWidget);
    });

    testWidgets('the Missions card invites the next project once finished', (
      tester,
    ) async {
      await _pump(
        tester,
        const CompassTab(initial: CompassSection.missions),
        data: _data(current: false, compass: 'Walk to work'),
        size: const Size(390, 2400),
      );
      expect(find.text('Plan your next project.'), findsOneWidget);
      expect(find.text('From your Compass: Walk to work'), findsNothing);
    });
  });

  group('picture', () {
    Future<CarthaHarness> openPicker(
      WidgetTester tester, {
      AppData? data,
      MemoryAttachmentStore? attachments,
    }) async {
      final h = await _pump(
        tester,
        const ProjectScreen(),
        data: data,
        attachments: attachments,
      );
      final open = _key('project-art-choose').evaluate().isNotEmpty
          ? _key('project-art-choose')
          : _key('project-art-change');
      await _tap(tester, open);
      expect(find.byType(ProjectArtPicker), findsOneWidget);
      return h;
    }

    testWidgets('a painted scene: chosen from the draft, shown with its '
        'name for screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await openPicker(
        tester,
        data: _data(current: false, past: const [], compass: 'Ship it'),
      );
      expect(find.text('Painted scenes'), findsOneWidget);
      for (final name in [
        'Sunrise',
        'Winding road',
        'Compass hill',
        'Stone steps',
        'Ruins at dawn',
        'Deep roots',
        'Hill town',
        'Sailing',
        'Summit route',
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      await _tap(tester, _key('project-art-citadel'));
      expect(find.byType(ProjectArtPicker), findsNothing);
      final project = h.state.data.project!;
      expect(project.title, 'Ship it');
      expect(project.art!.illustration, ProjectIllustration.citadel);
      expect(
        find.bySemanticsLabel('Project picture: Hill town'),
        findsOneWidget,
      );
      final painter = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: _key('project-art'),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((w) => w.painter)
          .whereType<LessonArtPainter>()
          .single;
      expect(painter.scene, LessonScene.citadel);

      // Changed to a brand scene; the chosen tile is marked.
      await _tap(tester, _key('project-art-change'));
      expect(
        tester.getSemantics(_key('project-art-citadel')),
        isSemantics(
          label: 'Hill town',
          isButton: true,
          isSelected: true,
          hasTapAction: true,
        ),
      );
      expect(
        tester.getSemantics(_key('project-art-sunrise')),
        isSemantics(label: 'Sunrise', isSelected: false),
      );
      await _tap(tester, _key('project-art-sunrise'));
      expect(
        h.state.data.project!.art!.illustration,
        ProjectIllustration.sunrise,
      );
      final scene = tester
          .widgetList<CustomPaint>(
            find.descendant(
              of: _key('project-art'),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((w) => w.painter)
          .whereType<ScenePainter>()
          .single;
      expect(scene.kind, SceneKind.sunrise);
      semantics.dispose();
    });

    testWidgets('a photo: picked, copied into the app, the picker copy '
        'released; shown on the project', (tester) async {
      final h = await openPicker(tester);
      const picked = '/picker/tmp/IMG_0042.jpg';
      h.media.nextPhoto = picked;
      h.attachments.sources[picked] = kPng;
      await _tap(tester, _key('project-art-gallery'));
      expect(h.media.requests, [false]);
      expect(h.media.released, [picked]);
      final photo = h.state.data.project!.art!.photo!;
      expect(photo.kind, AttachmentKind.photo);
      expect(photo.fileName, isNot(contains('IMG_0042')));
      expect(h.attachments.files[photo.fileName], kPng);
      expect(find.byType(ProjectArtPicker), findsNothing);
      expect(_key('project-photo-${photo.id}'), findsOneWidget);
      expect(h.store.saved!.project!.art!.photoAttachmentId, photo.id);
    });

    testWidgets('a camera that is refused says so and offers the others', (
      tester,
    ) async {
      final h = await openPicker(tester);
      h.media.error = const MediaPickerException(MediaFailure.permissionDenied);
      await _tap(tester, _key('project-art-camera'));
      expect(h.media.requests, [true]);
      expect(
        find.text(
          'Camera access is off. Allow it in Settings, or choose a photo or '
          'a painted scene.',
        ),
        findsOneWidget,
      );
      expect(find.byType(ProjectArtPicker), findsOneWidget);
      expect(h.state.data.project!.art, isNull);

      h.media.error = const MediaPickerException(MediaFailure.unavailable);
      await _tap(tester, _key('project-art-camera'));
      expect(
        find.text('No camera here. Choose a photo or a painted scene.'),
        findsOneWidget,
      );
      h.media.error = const MediaPickerException(MediaFailure.permissionDenied);
      await _tap(tester, _key('project-art-gallery'));
      expect(
        find.text(
          'Photo access is off. Allow it in Settings, or pick a painted '
          'scene.',
        ),
        findsOneWidget,
      );
      expect(h.attachments.files.keys, ['att_sep.jpg']);
    });

    testWidgets('a photo too large or not kept: said, nothing stored', (
      tester,
    ) async {
      final h = await openPicker(tester);
      const picked = '/picker/tmp/big.jpg';
      h.media.nextPhoto = picked;
      h.attachments.sources[picked] = kPng;
      h.attachments.maxBytes = 10;
      await _tap(tester, _key('project-art-gallery'));
      expect(
        find.text('That photo is too large to keep. Try another one.'),
        findsOneWidget,
      );
      expect(h.media.released, [picked]);
      expect(h.attachments.files.keys, ['att_sep.jpg']);
      expect(h.state.data.project!.art, isNull);

      h.attachments.maxBytes = kMaxAttachmentBytes;
      h.attachments.failWrites = true;
      await _tap(tester, _key('project-art-gallery'));
      expect(
        find.text(
          "Couldn't keep the photo on this phone. Check free space and try "
          'again.',
        ),
        findsOneWidget,
      );
      expect(h.state.data.project!.art, isNull);
    });

    testWidgets('cancelled in the picker: nothing changes', (tester) async {
      final h = await openPicker(tester);
      h.media.nextPhoto = null;
      await _tap(tester, _key('project-art-gallery'));
      expect(find.byType(ProjectArtPicker), findsOneWidget);
      expect(_key('project-art-error'), findsNothing);
      expect(h.state.data.project!.art, isNull);
    });

    testWidgets('a photo replaced by a scene, then removed: files go', (
      tester,
    ) async {
      final photo = _photo('att_now');
      final files = _folder()..files['att_now.jpg'] = kPng;
      final h = await openPicker(
        tester,
        data: _data(project: _current(art: ProjectArt.photo(photo))),
        attachments: files,
      );
      expect(
        find.text('Choosing another picture deletes your photo from the app.'),
        findsOneWidget,
      );
      await _tap(tester, _key('project-art-route'));
      // A camera photo may exist nowhere else: asked first.
      expect(find.text('Remove the photo?'), findsOneWidget);
      expect(h.attachments.files.keys, contains('att_now.jpg'));
      await tester.tap(find.text('Remove photo'));
      await pumpFrames(tester);
      expect(h.attachments.files.keys, ['att_sep.jpg']);

      // Back to a photo, then removed after a question.
      await _tap(tester, _key('project-art-change'));
      const picked = '/picker/tmp/p.jpg';
      h.media.nextPhoto = picked;
      h.attachments.sources[picked] = kPng;
      await _tap(tester, _key('project-art-gallery'));
      final kept = h.state.data.project!.art!.photo!;
      await _tap(tester, _key('project-art-remove'));
      expect(find.text('Remove the photo?'), findsOneWidget);
      await tester.tap(find.text('Remove photo'));
      await pumpFrames(tester);
      expect(h.state.data.project!.art, isNull);
      expect(h.attachments.files.containsKey(kept.fileName), isFalse);
      expect(find.text('Picture removed'), findsOneWidget);
      expect(_key('project-art-choose'), findsOneWidget);
    });

    for (final route in ['project-art-sunrise', 'project-art-none']) {
      testWidgets('with a photo, $route asks first: Cancel keeps the photo, '
          'Remove photo lets it go', (tester) async {
        final photo = _photo('att_now');
        final files = _folder()..files['att_now.jpg'] = kPng;
        final h = await openPicker(
          tester,
          data: _data(project: _current(art: ProjectArt.photo(photo))),
          attachments: files,
        );
        await _tap(tester, _key(route));
        expect(find.text('Remove the photo?'), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Cancel'),
          ),
        );
        await pumpFrames(tester);
        expect(find.byType(ProjectArtPicker), findsOneWidget);
        expect(h.state.data.project!.art!.photo!.id, 'att_now');
        expect(h.attachments.files.containsKey('att_now.jpg'), isTrue);

        await _tap(tester, _key(route));
        await tester.tap(find.text('Remove photo'));
        await pumpFrames(tester);
        expect(find.byType(ProjectArtPicker), findsNothing);
        expect(h.state.data.project!.art?.photo, isNull);
        expect(
          h.state.data.project!.art?.illustration,
          route == 'project-art-sunrise' ? ProjectIllustration.sunrise : null,
        );
        expect(h.attachments.files.containsKey('att_now.jpg'), isFalse);
      });
    }

    testWidgets('a scene over a scene asks nothing', (tester) async {
      final h = await openPicker(
        tester,
        data: _data(
          project: _current(
            art: const ProjectArt.illustration(ProjectIllustration.path),
          ),
        ),
      );
      await _tap(tester, _key('project-art-roots'));
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        h.state.data.project!.art!.illustration,
        ProjectIllustration.roots,
      );
    });

    testWidgets('a photo missing from the phone says so', (tester) async {
      await _pump(
        tester,
        const ProjectScreen(),
        data: _data(project: _current(art: ProjectArt.photo(_photo('gone')))),
      );
      expect(find.text('Photo not found on this phone'), findsOneWidget);
    });

    testWidgets('a failed save is said', (tester) async {
      final h = await openPicker(tester);
      h.store.failWrites = true;
      await _tap(tester, _key('project-art-steps'));
      expect(
        find.text('Not saved yet. Use Retry on this page.'),
        findsOneWidget,
      );
    });

    testWidgets('the sheets slide only while motion is on', (tester) async {
      for (final motion in [false, true]) {
        for (final (type, open)
            in <(Type, Future<void> Function(BuildContext))>[
              (
                ProjectArtPicker,
                (c) => showProjectArtPicker(
                  c,
                  current: null,
                  onChoose: (_) async {},
                ),
              ),
              (
                FinishProjectSheet,
                (c) => showFinishProjectSheet(
                  c,
                  project: _current(),
                  onKeep: (_) {},
                ),
              ),
            ]) {
          final data = _data();
          await _pump(
            tester,
            _opener(open),
            data: data.copyWith(
              settings: data.settings.copyWith(motion: motion),
            ),
          );
          await tester.tap(_key('open-sheet'));
          await pumpFrames(tester);
          final route = ModalRoute.of(tester.element(find.byType(type)));
          expect(
            (route! as ModalBottomSheetRoute<Object?>).sheetAnimationStyle,
            motion ? isNull : AnimationStyle.noAnimation,
            reason: '$type, motion $motion',
          );
          await tester.pumpWidget(const SizedBox());
        }
      }
    });
  });

  group('restore', () {
    test(
      'a backup restored keeps the history, its pictures and links',
      () async {
        final a = await _phone(_data(), _folder());
        final archive = await a.exportBackupArchive();
        expect(archive.missing, isEmpty);

        final filesB = MemoryAttachmentStore(clock: () => _t);
        final b = await _phone(null, filesB);
        final preview = await b.previewRestore(archive.bytes);
        await b.restoreBackup(preview);
        expect(b.pastProjects.map((p) => p.id), ['project_oct', 'project_sep']);
        expect(
          b.pastProjects.first.retrospective,
          '  Two weekends were enough.\nAsk for help sooner.  ',
        );
        expect(
          b.pastProjects.first.art!.illustration,
          ProjectIllustration.citadel,
        );
        expect(b.pastProjects.last.art!.photoAttachmentId, 'att_sep');
        expect(filesB.files['att_sep.jpg'], kPng);
        expect(b.questsOfProject('project_oct').map((q) => q.id), ['q2', 'q3']);
        expect(
          b.attemptsOfProject('project_oct').single.learning,
          'Start small.',
        );
        expect(b.data.project!.id, 'project_now');
      },
    );

    testWidgets('and the history shows it', (tester) async {
      final a = await tester.runAsync(() => _phone(_data(), _folder()));
      final archive = await tester.runAsync(a!.exportBackupArchive);
      final filesB = MemoryAttachmentStore(clock: () => _t);
      final b = await tester.runAsync(() => _phone(null, filesB));
      await tester.runAsync(() async {
        await b!.restoreBackup(await b.previewRestore(archive!.bytes));
      });
      await _pump(
        tester,
        const ProjectHistoryScreen(),
        data: b!.data,
        attachments: filesB,
      );
      expect(_key('past-project-project_oct'), findsOneWidget);
      await tester.ensureVisible(_key('past-project-project_sep'));
      await tester.pump();
      expect(_key('project-photo-att_sep'), findsOneWidget);
      expect(find.text('Photo not found on this phone'), findsNothing);
    });
  });

  test('projects copy never judges', () {
    final text = File('l10n_src/projects_en.arb').readAsStringSync();
    final strings = (jsonDecode(text) as Map<String, Object?>).entries
        .where((e) => !e.key.startsWith('@'))
        .map((e) => e.value! as String);
    for (final s in strings) {
      expect(
        s,
        isNot(
          matches(
            RegExp(
              r'streak|missed|points|score|fail|behind|lazy|should have|'
              r'you must|you fixed',
              caseSensitive: false,
            ),
          ),
        ),
      );
    }
  });

  group('fits every size (dark + light)', () {
    final screens = <(String, Widget, AppData Function(), String?)>[
      (
        'project',
        const ProjectScreen(),
        () =>
            _data(project: _current(art: ProjectArt.photo(_photo('att_sep')))),
        null,
      ),
      ('finish sheet', const ProjectScreen(), _data, 'project-finish'),
      ('picture sheet', const ProjectScreen(), _data, 'project-art-choose'),
      ('history', const ProjectHistoryScreen(), _data, null),
      (
        'past project',
        const PastProjectScreen(projectId: 'project_oct'),
        _data,
        null,
      ),
      (
        'quest sheet',
        _opener(
          (c) => showQuestSheet(c, quest: c.read<AppState>().questById('q2')),
        ),
        _data,
        'open-sheet',
      ),
      (
        'missions',
        const CompassTab(initial: CompassSection.missions),
        () => _data(
          project: _current(
            art: const ProjectArt.illustration(ProjectIllustration.dawnRuins),
          ),
        ),
        null,
      ),
      ('battle log', const BattleLogScreen(), _data, null),
      ('collection', const CollectionScreen(), _data, null),
    ];
    for (final size in kSizeMatrix) {
      for (final b in Brightness.values) {
        for (final (name, home, data, open) in screens) {
          testWidgets('$name $size ${b.name}', (tester) async {
            await _pump(
              tester,
              home,
              data: data(),
              size: size.size,
              textScale: size.textScale,
              brightness: b,
            );
            if (open != null) await _tap(tester, _key(open));
            await expectNoOverflow(tester);
          });
        }
      }
    }
  });

  group('accessibility (dark + light)', () {
    final screens = <(String, Widget, String?)>[
      ('project', const ProjectScreen(), null),
      ('finish sheet', const ProjectScreen(), 'project-finish'),
      ('picture sheet', const ProjectScreen(), 'project-art-choose'),
      ('history', const ProjectHistoryScreen(), null),
      ('past project', const PastProjectScreen(projectId: 'project_oct'), null),
    ];
    for (final b in Brightness.values) {
      for (final (name, home, open) in screens) {
        testWidgets('$name ${b.name}', (tester) async {
          final semantics = tester.ensureSemantics();
          await _pump(tester, home, brightness: b);
          if (open != null) await _tap(tester, _key(open));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          semantics.dispose();
        });
      }
    }
  });
}

/// Which quest the link test's sheet opens.
String _open = 'q4';
