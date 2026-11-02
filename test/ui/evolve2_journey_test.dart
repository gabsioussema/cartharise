// End-to-end journeys for the evolve plan's Step 2 (docs/plans/evolve.md ›
// "Everyday usefulness") through the real app (CarthaApp → BootScreen →
// RootShell) with the real English content and the fake media services:
// quests on the board moved lane by lane (Move to…), a daily quest back in
// Ready the next day; a project finished with its look back and kept in the
// history with its tasks and attempts (and their photos); a photo and a
// voice note on a note, a pinned passage, the v2 .zip backup, "Delete all
// data" removing the files, the restore bringing everything back; and a v1
// JSON backup that still restores.
import 'dart:convert';
import 'dart:typed_data';

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/ui/campaign/attempt_sheet.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/journal/journal_tab.dart';
import 'package:cartharise/ui/media/photo_viewer.dart';
import 'package:cartharise/ui/media/recorder_sheet.dart';
import 'package:cartharise/ui/missions/board_view.dart';
import 'package:cartharise/ui/missions/project_finish.dart';
import 'package:cartharise/ui/missions/project_history_screen.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/root_shell.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// A phone tall enough that lazily built rows exist (the journeys still
/// scroll to what they tap).
const _phone = Size(390, 2000);

const _content = englishContent;

final _t = DateTime(2026, 11, 2, 18);
const _today = '2026-11-03'; // kTestNow
final _tomorrow = DateTime(2026, 11, 4, 9, 30);

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// [finder] inside the widget of type [T] (the shell keeps every tab built,
/// so unscoped text can match a tab that isn't showing).
Finder _in<T>(Finder finder) =>
    find.descendant(of: find.byType(T), matching: finder);

Future<void> _settle(WidgetTester tester, {int frames = 6}) async {
  // Storage writes are microtasks; let them land, then draw.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await pumpFrames(tester, count: frames);
}

/// Brings [finder] on screen, then taps it like a person would.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _settle(tester);
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

Future<void> _back(WidgetTester tester) async {
  await tester.pageBack();
  await _settle(tester);
}

/// Compass › Missions.
Future<void> _openMissions(WidgetTester tester) async {
  await _openTab(tester, 'Compass');
  await _tap(
    tester,
    find.descendant(
      of: find.byType(PillTabs<CompassSection>),
      matching: find.text('Missions'),
    ),
  );
}

Finder _lane(QuestStage lane) => _key('board-lane-${lane.name}');

/// The board card of [id] inside [lane].
Finder _cardIn(QuestStage lane, String id) =>
    find.descendant(of: _lane(lane), matching: _key('board-card-$id'));

/// Moves the card of [id] to [to] with its "Move to…" menu.
Future<void> _moveByMenu(WidgetTester tester, String id, QuestStage to) async {
  await _tap(tester, _key('board-move-$id'));
  await tester.tap(_key('board-move-$id-${to.name}'));
  await _settle(tester);
}

/// Adds a quest through Missions' quest sheet (List view).
Future<Quest> _addQuest(
  WidgetTester tester,
  CarthaHarness h,
  String title, {
  bool daily = false,
}) async {
  await _tap(tester, _key('missions-add-quest'));
  await tester.enterText(_key('quest-title'), title);
  await tester.pump();
  if (daily) await _tap(tester, find.text('Repeat every day'));
  await _tap(tester, find.text('Save quest'));
  await _waitOutSnackBars(tester);
  return h.state.data.quests.firstWhere((q) => q.title == title);
}

/// The five-page welcome, quickly (after "Delete all data").
Future<void> _quickOnboarding(WidgetTester tester) async {
  expect(find.byType(OnboardingFlow), findsOneWidget);
  await _tap(tester, _key('onboarding-next'));
  await _tap(tester, _key('onboarding-adult'));
  for (var i = 0; i < 3; i++) {
    await _tap(tester, _key('onboarding-next'));
  }
  await _tap(tester, _key('onboarding-finish'));
  await _settle(tester, frames: 8);
  expect(find.byType(RootShell), findsOneWidget);
}

/// The one-month project of the journeys (current, with two milestones).
MonthProject _project({ProjectArt? art}) => MonthProject(
  id: 'project_now',
  title: 'Finish the first essay',
  status: ProjectStatus.active,
  updatedAt: _t,
  startedAt: DateTime(2026, 10, 5, 8),
  milestones: const [
    Milestone(id: 'm1', title: 'Outline', done: true),
    Milestone(id: 'm2', title: 'First draft'),
  ],
  art: art,
);

Attachment _photo(String id) => Attachment(
  id: id,
  kind: AttachmentKind.photo,
  fileName: '$id.jpg',
  createdAt: _t,
);

Attachment _voice(String id) => Attachment(
  id: id,
  kind: AttachmentKind.audio,
  fileName: '$id.m4a',
  createdAt: _t,
  durationMs: 4000,
);

/// A real 1×1 PNG (a project photo the app can decode).
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

/// Words that must survive exactly as typed.
const _retro = "  Mornings worked.\nEvenings didn't — keep “drafts” <short>.  ";
const _noteBody = 'I think more clearly outside.\n  Two spaces stay.  ';

void main() {
  testWidgets('quests → the board → Move to… through the lanes → Done; a '
      'daily quest is back in Ready the next day', (tester) async {
    final h = await pumpCartha(
      tester,
      data: onboardedData(settings: const AppSettings(game: true))
          .copyWith(project: () => _project()),
      content: _content,
      size: _phone,
    );
    await _openMissions(tester);

    // Make two quests in the list: a one-off and a daily one. While the
    // project is active, new quests join it by default.
    final draft = await _addQuest(tester, h, 'Draft the outline');
    final walk = await _addQuest(tester, h, 'Walk ten minutes', daily: true);
    expect(draft.stage, QuestStage.ready);
    expect(draft.projectId, 'project_now');
    expect(walk.recurrence, QuestRecurrence.daily);
    final xp0 = h.state.campaign.xp;

    // Board: the same quests, in Ready, with their project label.
    await _tap(tester, find.text('Board'));
    expect(find.byType(QuestBoard), findsOneWidget);
    expect(_cardIn(QuestStage.ready, draft.id), findsOneWidget);
    expect(_cardIn(QuestStage.ready, walk.id), findsOneWidget);
    expect(
      find.descendant(
        of: _key('board-card-${draft.id}'),
        matching: _key('quest-project-${draft.id}'),
      ),
      findsOneWidget,
      reason: 'the project label on board cards, as in the list',
    );
    expect(
      find.descendant(
        of: _key('board-card-${draft.id}'),
        matching: find.text('Finish the first essay'),
      ),
      findsOneWidget,
    );

    // Ready → Later → Doing: moving earns nothing and says where it went.
    await _moveByMenu(tester, draft.id, QuestStage.later);
    expect(_cardIn(QuestStage.later, draft.id), findsOneWidget);
    expect(h.state.questById(draft.id)!.stage, QuestStage.later);
    await _waitOutSnackBars(tester);
    await _moveByMenu(tester, draft.id, QuestStage.doing);
    expect(_cardIn(QuestStage.doing, draft.id), findsOneWidget);
    expect(find.text("'Draft the outline' moved to Doing"), findsOneWidget);
    expect(h.store.saved!.quests.first.stage, QuestStage.doing);
    expect(h.state.campaign.xp, xp0, reason: 'a move earns nothing');
    await _waitOutSnackBars(tester);

    // Doing → Done: completed for today, the usual quest XP.
    await _moveByMenu(tester, draft.id, QuestStage.done);
    await _tap(tester, _key('board-toggle-done'));
    expect(_cardIn(QuestStage.done, draft.id), findsOneWidget);
    final done = h.state.questById(draft.id)!;
    expect(done.stage, QuestStage.done);
    expect(done.completedOn, {_today});
    expect(h.state.campaign.xp, xp0 + 20);
    await _waitOutSnackBars(tester);

    // The daily quest: done for today.
    await _moveByMenu(tester, walk.id, QuestStage.done);
    expect(find.text("'Walk ten minutes' done for today"), findsOneWidget);
    expect(_cardIn(QuestStage.done, walk.id), findsOneWidget);
    expect(h.state.questById(walk.id)!.completedOn, {_today});
    expect(h.state.campaign.xp, xp0 + 40);
    // The list agrees: one task list, two views.
    await _tap(tester, find.text('List'));
    expect(
      tester.widget<Checkbox>(_key('quest-check-${walk.id}')).value,
      isTrue,
    );
    expect(tester.takeException(), isNull);

    // The next day: the daily quest is back in Ready, its history kept; the
    // finished one-off stays in Done.
    final saved = h.store.saved!;
    await tester.pumpWidget(const SizedBox());
    final next = await pumpCartha(
      tester,
      data: saved,
      content: _content,
      size: _phone,
      now: _tomorrow,
    );
    await _openMissions(tester);
    await _tap(tester, find.text('Board'));
    expect(_cardIn(QuestStage.ready, walk.id), findsOneWidget);
    expect(next.state.questById(walk.id)!.completedOn, {_today});
    await _tap(tester, _key('board-toggle-done'));
    expect(_cardIn(QuestStage.done, draft.id), findsOneWidget);
    expect(_cardIn(QuestStage.done, walk.id), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('finish a project with a look back → in the history with its '
      'tasks and attempts, their photos and voice notes', (tester) async {
    final files = MemoryAttachmentStore(clock: () => kTestNow)
      ..files['att_a.jpg'] = Uint8List.fromList([1, 2])
      ..files['att_v.m4a'] = Uint8List.fromList([3, 4, 5]);
    final data =
        onboardedData(
          settings: const AppSettings(game: true, todayPin: TodayPin.project),
        ).copyWith(
          project: () => _project(),
          compass: const LifeCompass(monthProject: 'Finish the first essay'),
          quests: [
            Quest(
              id: 'q1',
              title: 'Write 300 words',
              createdAt: _t,
              projectId: 'project_now',
            ),
            Quest(id: 'q2', title: 'Water the plants', createdAt: _t),
          ],
          campaignLog: [
            BattleLogEntry(
              id: 'a1',
              day: '2026-11-02',
              attempt: 'Wrote before breakfast',
              learning: 'Short sessions work.',
              createdAt: _t,
              projectId: 'project_now',
              attachments: [_photo('att_a'), _voice('att_v')],
            ),
          ],
        );
    final h = await pumpCartha(
      tester,
      data: data,
      attachments: files,
      content: _content,
      size: _phone,
    );

    // Today, asked to help with the project, names it.
    expect(_in<TodayTab>(_key('today-step-project')), findsOneWidget);
    expect(h.state.monthlyBoss, 'Finish the first essay');

    // Missions › the project card → the project → Finish this project.
    await _openMissions(tester);
    await _tap(tester, _key('missions-project'));
    expect(find.byType(ProjectScreen), findsOneWidget);
    await _tap(tester, _key('project-finish'));
    expect(find.byType(FinishProjectSheet), findsOneWidget);
    await tester.enterText(_key('project-finish-retro'), _retro);
    await _tap(tester, _key('project-finish-confirm'));
    expect(find.text('Kept in your project history.'), findsOneWidget);
    expect(h.state.data.project, isNull);
    final kept = h.store.saved!.pastProjects.single;
    expect(kept.id, 'project_now');
    expect(kept.retrospective, _retro, reason: 'exactly as typed');
    expect(kept.milestones.map((m) => m.title), ['Outline', 'First draft']);
    // Its tasks and attempts stay linked.
    expect(h.state.questById('q1')!.projectId, 'project_now');
    expect(h.state.data.campaignLog.single.projectId, 'project_now');

    // The history: the project, then one past project in full.
    await _tap(tester, _key('project-finished-history'));
    expect(find.byType(ProjectHistoryScreen), findsOneWidget);
    await _tap(tester, _key('past-project-project_now'));
    expect(find.byType(PastProjectScreen), findsOneWidget);
    expect(find.text(_retro), findsOneWidget);
    expect(_key('past-milestone-m1'), findsOneWidget);
    expect(_key('past-task-q1'), findsOneWidget);
    expect(_key('past-task-q2'), findsNothing, reason: 'not linked');
    expect(_key('past-attempt-a1'), findsOneWidget);
    // The attempt's photo and voice note show there too.
    expect(
      find.descendant(
        of: _key('past-attempt-media-a1'),
        matching: find.text('1 photo and 1 voice note'),
      ),
      findsOneWidget,
    );
    await _tap(tester, _key('past-attempt-photo-att_a'));
    expect(find.byType(PhotoViewerScreen), findsOneWidget);
    await _back(tester);
    // Opening the attempt: its voice note plays from there, and it says it
    // belongs to a finished project (it can be unlinked).
    await _tap(tester, find.text('Wrote before breakfast'));
    expect(find.byType(AttemptSheet), findsOneWidget);
    expect(_key('player-att_v'), findsOneWidget);
    expect(
      find.descendant(
        of: _key('attempt-project-link'),
        matching: find.text('Part of a finished project'),
      ),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(195, 40)); // close the sheet
    await _settle(tester);
    expect(find.byType(AttemptSheet), findsNothing);
    await _back(tester);
    await _back(tester);
    await _back(tester);

    // Today no longer offers the finished project, and the battle log's
    // boss line doesn't name it (the Compass keeps its words).
    await _openTab(tester, 'Today');
    expect(_in<TodayTab>(_key('today-step-project')), findsNothing);
    expect(h.state.compass.monthProject, 'Finish the first essay');
    expect(h.state.monthlyBoss, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a photo and a voice note on a note → pin a passage → the v2 '
      '.zip → "Delete all data" removes the files → restore brings notes, '
      'files and the project history back', (tester) async {
    final files = MemoryAttachmentStore(clock: () => kTestNow)
      ..files['att_old.jpg'] = _png;
    final past = _project(art: ProjectArt.photo(_photo('att_old'))).copyWith(
      status: ProjectStatus.done,
      retrospective: _retro,
      archivedAt: () => _t,
      now: _t,
    );
    final h = await pumpCartha(
      tester,
      data: onboardedData().copyWith(
        journal: [JournalEntry(id: 'n1', body: _noteBody, createdAt: _t)],
        pastProjects: [past],
      ),
      attachments: files,
      content: _content,
      size: _phone,
    );

    // Journal › the note.
    await _openTab(tester, 'Journal');
    await _tap(tester, _in<JournalTab>(_key('note-n1')));
    expect(find.byType(JournalEntryScreen), findsOneWidget);

    // A photo from the library: copied into the private folder.
    h.attachments.sources['/picked/p1.jpg'] = [1, 2, 3];
    h.media.nextPhoto = '/picked/p1.jpg';
    await _tap(tester, _key('media-add-photo'));
    await _tap(tester, _key('media-photo-library'));
    expect(find.text('Photo added.'), findsOneWidget);
    expect(h.media.released, ['/picked/p1.jpg']);

    // A voice note: the microphone only now, tap Stop → saved at once.
    expect(h.recorder.permissionRequests, 0);
    await _tap(tester, _key('media-record'));
    expect(find.byType(RecorderSheet), findsOneWidget);
    expect(find.text('Recording'), findsOneWidget);
    expect(h.recorder.permissionRequests, 1);
    await _tap(tester, _key('recorder-stop'));
    expect(find.byType(RecorderSheet), findsNothing);
    final media = h.state.data.journal.single.attachments;
    expect(media.map((a) => a.kind), [
      AttachmentKind.photo,
      AttachmentKind.audio,
    ]);
    expect(media.last.transcript, isNull, reason: 'never filled in');
    final photo = media.first;
    final voice = media.last;
    expect(h.attachments.files[photo.fileName], [1, 2, 3]);
    expect(h.attachments.files[voice.fileName], [1, 2, 3, 4]);
    expect(h.state.data.journal.single.body, _noteBody, reason: 'untouched');

    // Pin the exact words selected.
    tester.widget<TextField>(_key('journal-entry-body')).controller!.selection =
        const TextSelection(baseOffset: 2, extentOffset: 18);
    await tester.pump();
    await _tap(tester, _key('journal-entry-pin'));
    final pin = h.state.data.pinnedMemory!;
    expect(pin.kind, PinnedKind.passage);
    expect(pin.sourceId, 'n1');
    expect(pin.excerpt, 'think more clear');
    await _back(tester);
    await _waitOutSnackBars(tester);
    // The Journal: the pinned memory on top, the note says what it holds.
    expect(_in<JournalTab>(_key('pinned-memory')), findsOneWidget);
    expect(
      find.descendant(
        of: _key('note-media-n1'),
        matching: find.text('1 photo and 1 voice note'),
      ),
      findsOneWidget,
    );

    // Export: the v2 .zip with data.json and every file it names.
    await _openTab(tester, 'You');
    await _tap(tester, _key('you-data'));
    expect(find.byType(DataScreen), findsOneWidget);
    await _tap(tester, _key('data-export'));
    final backup = h.files.shared.last;
    expect(backup.mimeType, 'application/zip');
    expect(backup.filename, 'cartharise-backup-2026-11-03.zip');
    final contents = decodeBackupBytes(backup.bytes);
    expect(contents.format, kBackupArchiveFormat);
    expect(contents.files[photo.fileName], [1, 2, 3]);
    expect(contents.files[voice.fileName], [1, 2, 3, 4]);
    expect(contents.files['att_old.jpg'], _png);
    expect(contents.notIncluded, isEmpty);
    expect(contents.data.pinnedMemory!.excerpt, 'think more clear');
    expect(contents.data.pastProjects.single.retrospective, _retro);
    await _waitOutSnackBars(tester);

    // Delete all data: the words, the pin and every file go.
    await _tap(tester, _key('data-delete'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Continue'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Delete everything'));
    await _settle(tester, frames: 10);
    expect(h.store.raw, isNull);
    expect(h.attachments.files, isEmpty);
    expect(h.state.data.journal, isEmpty);
    expect(h.state.data.pinnedMemory, isNull);
    expect(h.state.data.pastProjects, isEmpty);

    // A fresh start, then restore the .zip.
    await _quickOnboarding(tester);
    await _openTab(tester, 'You');
    await _tap(tester, _key('you-data'));
    h.files.pickBytes = backup.bytes;
    await _tap(tester, _key('data-import'));
    expect(find.textContaining('Replace everything on this phone'), findsOne);
    await _tap(tester, find.widgetWithText(FilledButton, 'Replace'));
    expect(find.text('Backup restored.'), findsOneWidget);
    for (final restored in [h.state.data, h.store.saved!]) {
      final note = restored.journal.single;
      expect(note.body, _noteBody);
      expect(note.attachments.map((a) => a.id), [photo.id, voice.id]);
      expect(restored.pinnedMemory!.excerpt, 'think more clear');
      expect(restored.pastProjects.single.retrospective, _retro);
      expect(restored.pastProjects.single.art!.photo!.fileName, 'att_old.jpg');
    }
    expect(h.attachments.files[photo.fileName], [1, 2, 3]);
    expect(h.attachments.files[voice.fileName], [1, 2, 3, 4]);
    expect(h.attachments.files['att_old.jpg'], _png);
    await _back(tester);

    // The Journal shows the pin again; the restored voice note plays.
    await _openTab(tester, 'Journal');
    expect(_in<JournalTab>(_key('pinned-memory')), findsOneWidget);
    await _tap(tester, _in<JournalTab>(_key('note-n1')));
    await _tap(tester, find.byTooltip('Play voice note'));
    expect(h.player.played.single, endsWith('/${voice.fileName}'));
    await _back(tester);

    // The project history is back too, with its photo.
    await tester.pumpWidget(const SizedBox());
    await pumpCartha(
      tester,
      data: h.store.saved,
      attachments: h.attachments,
      home: const ProjectHistoryScreen(),
      content: _content,
      size: _phone,
    );
    expect(_key('past-project-project_now'), findsOneWidget);
    expect(_key('project-photo-att_old'), findsWidgets);
    expect(_key('project-photo-missing'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a v1 JSON backup still restores (quests in their lanes, the '
      'project kept)', (tester) async {
    // What an older Cartharise wrote: format 1, schema 1, no stages,
    // project ids, attachments or history.
    final older = onboardedData(settings: const AppSettings(game: true))
        .copyWith(
          journal: [JournalEntry(id: 'n1', body: _noteBody, createdAt: _t)],
          quests: [
            Quest(
              id: 'q1',
              title: 'Clear the desk',
              createdAt: _t,
              completedOn: const {'2026-11-02'},
            ),
            Quest(id: 'q2', title: 'Call Ana', createdAt: _t),
          ],
          project: () => _project(),
        );
    final json = older.toJson()..['schemaVersion'] = 1;
    for (final q in json['quests']! as List<Object?>) {
      (q! as Map<String, Object?>)
        ..remove('stage')
        ..remove('projectId');
    }
    (json['project']! as Map<String, Object?>)
      ..remove('id')
      ..remove('startedAt')
      ..remove('archivedAt')
      ..remove('art');
    for (final e in json['journal']! as List<Object?>) {
      (e! as Map<String, Object?>).remove('attachments');
    }
    json
      ..remove('pastProjects')
      ..remove('pinnedMemory');
    final v1 = const JsonEncoder.withIndent('  ').convert({
      'app': 'cartharise',
      'format': 1,
      'exportedAt': _t.toUtc().toIso8601String(),
      'data': json,
    });

    final h = await pumpCartha(
      tester,
      data: onboardedData(),
      content: _content,
      size: _phone,
    );
    await _openTab(tester, 'You');
    await _tap(tester, _key('you-data'));
    h.files.pickBytes = Uint8List.fromList(utf8.encode(v1));
    await _tap(tester, _key('data-import'));
    expect(find.textContaining('Replace everything on this phone'), findsOne);
    await _tap(tester, find.widgetWithText(FilledButton, 'Replace'));
    expect(find.text('Backup restored.'), findsOneWidget);
    for (final restored in [h.state.data, h.store.saved!]) {
      expect(restored.journal.single.body, _noteBody);
      expect(restored.journal.single.attachments, isEmpty);
      expect(restored.quests.map((q) => q.title), [
        'Clear the desk',
        'Call Ana',
      ]);
      expect(restored.quests.first.stage, QuestStage.done);
      expect(restored.quests.last.stage, QuestStage.ready);
      expect(restored.project!.title, 'Finish the first essay');
      expect(restored.project!.id, legacyProjectId(_t));
      expect(restored.pastProjects, isEmpty);
      expect(restored.pinnedMemory, isNull);
    }
    await _back(tester);

    // The board shows them in their lanes.
    await _openMissions(tester);
    await _tap(tester, find.text('Board'));
    expect(_cardIn(QuestStage.ready, 'q2'), findsOneWidget);
    await _tap(tester, _key('board-toggle-done'));
    expect(_cardIn(QuestStage.done, 'q1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('across areas', () {
    AppData withMedia() =>
        onboardedData(settings: const AppSettings(game: true)).copyWith(
          project: () => _project(),
          campaignLog: [
            BattleLogEntry(
              id: 'a1',
              day: '2026-11-02',
              attempt: 'Wrote before breakfast',
              createdAt: _t,
              attachments: [_photo('att_a'), _voice('att_v')],
            ),
          ],
          experimentLog: [
            ExperimentEntry(
              id: 'e1',
              experimentId: 'try.pattern.01',
              day: '2026-11-02',
              note: 'Walked without my phone',
              createdAt: _t,
              attachments: [_voice('att_w')],
            ),
          ],
        );
    MemoryAttachmentStore mediaFiles() =>
        MemoryAttachmentStore(clock: () => kTestNow)
          ..files['att_a.jpg'] = _png
          ..files['att_v.m4a'] = Uint8List.fromList([3])
          ..files['att_w.m4a'] = Uint8List.fromList([4]);

    testWidgets('the battle log says what an attempt holds; its sheet links '
        'it to the project or not', (tester) async {
      final h = await pumpCartha(
        tester,
        data: withMedia(),
        attachments: mediaFiles(),
        home: const BattleLogScreen(),
        content: _content,
        size: _phone,
      );
      expect(
        find.descendant(
          of: _key('attempt-media-a1'),
          matching: find.text('1 photo and 1 voice note'),
        ),
        findsOneWidget,
      );
      expect(_key('attempt-project-a1'), findsNothing, reason: 'not linked');

      // Link it from its sheet ("Part of the month project", off).
      await _tap(tester, find.text('Wrote before breakfast'));
      final link = _key('attempt-project-link');
      expect(
        tester
            .widget<SwitchListTile>(
              find.descendant(of: link, matching: find.byType(SwitchListTile)),
            )
            .value,
        isFalse,
      );
      await _tap(tester, link);
      await _tap(tester, find.text('Save attempt'));
      expect(h.state.data.campaignLog.single.projectId, 'project_now');
      expect(h.store.saved!.campaignLog.single.projectId, 'project_now');
      expect(h.state.data.campaignLog.single.attempt, 'Wrote before breakfast');
      expect(_key('attempt-project-a1'), findsOneWidget);

      // And unlink it again.
      await _tap(tester, find.text('Wrote before breakfast'));
      await _tap(tester, _key('attempt-project-link'));
      await _tap(tester, find.text('Save attempt'));
      expect(h.state.data.campaignLog.single.projectId, isNull);
      expect(h.state.data.campaignLog.single.attachments, hasLength(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the Collection says what a try holds', (tester) async {
      await pumpCartha(
        tester,
        data: withMedia(),
        attachments: mediaFiles(),
        home: const CollectionScreen(),
        content: _content,
        size: _phone,
      );
      expect(
        find.descendant(
          of: _key('try-media-e1'),
          matching: find.text('1 voice note'),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
