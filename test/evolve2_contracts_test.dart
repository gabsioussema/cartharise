// Step 2.0 contracts (docs/plans/evolve.md): quest stages and the board,
// project ids and history, attachments on notes / experiments / attempts,
// the pinned memory, the attachment store and media services, backup v2
// (.zip) with v1 still restoring, "Delete all data" and orphan cleanup.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/l10n/app_localizations_en.dart';
import 'package:cartharise/services/attachment_store.dart';
import 'package:cartharise/services/media_picker.dart';
import 'package:cartharise/services/voice_player.dart';
import 'package:cartharise/services/voice_recorder.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/state/attachment_ops.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/missions/missions_logic.dart';
import 'package:cartharise/ui/you/backup_preview.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

final _t = DateTime(2026, 11, 3, 9, 30);
const _day1 = '2026-11-03';
const _day2 = '2026-11-04';

/// One phone: a data file and an attachments folder, in memory.
class _Phone {
  _Phone([AppData? data])
    : store = MemoryDataStore(data),
      files = MemoryAttachmentStore(clock: () => _t);

  final MemoryDataStore store;
  final MemoryAttachmentStore files;

  Future<AppState> open({DateTime? at}) async {
    final clock = at ?? _t;
    final state = AppState(
      store: store,
      content: fakeContent,
      reminders: FakeReminderScheduler(),
      attachments: files,
      clock: () => clock,
    );
    await state.load();
    return state;
  }
}

AppData _roundTrip(AppData data) => decodeBackup(encodeBackup(data, _t));

/// A JSON copy of [data] with [edit] applied to the encoded map.
Map<String, Object?> _json(
  AppData data,
  void Function(Map<String, Object?>) edit,
) {
  final json = jsonDecode(jsonEncode(data.toJson())) as Map<String, Object?>;
  edit(json);
  return json;
}

Attachment _photo(String id, {String? fileName}) => Attachment(
  id: id,
  kind: AttachmentKind.photo,
  fileName: fileName ?? '$id.jpg',
  createdAt: _t,
);

Attachment _audio(String id, {int? durationMs, String? transcript}) =>
    Attachment(
      id: id,
      kind: AttachmentKind.audio,
      fileName: '$id.m4a',
      createdAt: _t,
      durationMs: durationMs,
      transcript: transcript,
    );

Quest _quest(
  String id, {
  QuestRecurrence recurrence = QuestRecurrence.none,
  Set<String> completedOn = const {},
  QuestStage stage = QuestStage.ready,
}) => Quest(
  id: id,
  title: 'Quest $id',
  createdAt: DateTime(2026, 11, 1),
  recurrence: recurrence,
  completedOn: completedOn,
  stage: stage,
);

/// Imports [bytes] as a photo into [state]'s store (as the picker would).
Future<Attachment> _import(
  AppState state,
  String name,
  List<int> bytes, {
  AttachmentKind kind = AttachmentKind.photo,
}) {
  final store = state.attachmentStore as MemoryAttachmentStore;
  final path = '/picked/$name';
  store.sources[path] = bytes;
  return store.importFile(path, kind: kind);
}

void main() {
  // ── Quest stages ─────────────────────────────────────────────────────────

  group('quest stages: JSON', () {
    test('every stage and the project link round-trip', () {
      for (final stage in [
        QuestStage.later,
        QuestStage.ready,
        QuestStage.doing,
      ]) {
        final q = Quest(
          id: 'q',
          title: 'Walk',
          createdAt: _t,
          stage: stage,
          projectId: 'project_1',
        );
        final back = _roundTrip(AppData(quests: [q])).quests.single;
        expect(back.stage, stage);
        expect(back.projectId, 'project_1');
      }
      final done = _roundTrip(
        AppData(
          quests: [
            _quest('d', completedOn: {_day1}),
          ],
        ),
      ).quests.single;
      expect(done.stage, QuestStage.done);
    });

    test('older files: ready, a completed one-off loads as done, daily '
        'quests are never stored as done', () {
      final data = AppData(
        quests: [
          _quest('open'),
          _quest('finished', completedOn: {_day1}),
          _quest(
            'daily',
            recurrence: QuestRecurrence.daily,
            completedOn: {_day1},
          ),
        ],
      );
      final old = _json(data, (j) {
        for (final q in (j['quests']! as List).cast<Map<String, Object?>>()) {
          q.remove('stage');
          q.remove('projectId');
        }
      });
      final back = AppData.fromJson(old).quests;
      expect(back[0].stage, QuestStage.ready);
      expect(back[1].stage, QuestStage.done);
      expect(back[2].stage, QuestStage.ready);
      expect(back[2].completedOn, {_day1});
      expect(back.every((q) => q.projectId == null), isTrue);
    });

    test('unknown names fall back to ready; a stored "done" follows the '
        'completion; junk is refused', () {
      final data = AppData(
        quests: [
          _quest('a'),
          _quest('b'),
          _quest('c', recurrence: QuestRecurrence.daily),
        ],
      );
      final json = _json(data, (j) {
        final qs = (j['quests']! as List).cast<Map<String, Object?>>();
        qs[0]['stage'] = 'someday';
        qs[1]['stage'] = 'done'; // never completed
        qs[2]['stage'] = 'done'; // daily
      });
      final back = AppData.fromJson(json).quests;
      expect(back.map((q) => q.stage), [
        QuestStage.ready,
        QuestStage.ready,
        QuestStage.ready,
      ]);
      final junk = _json(data, (j) {
        ((j['quests']! as List).first as Map)['stage'] = 3;
      });
      expect(() => AppData.fromJson(junk), throwsFormatException);
    });
  });

  group('quest stages: lanes per day (pure)', () {
    test('a one-off: its stage until completed, then done on every day; '
        'reopened, back in the lane it was completed from', () {
      final q = _quest('q', stage: QuestStage.doing);
      expect(q.laneOn(_day1), QuestStage.doing);
      final finished = q.completedFor(_day1, true);
      expect(finished.stage, QuestStage.done);
      expect(finished.doneFrom, QuestStage.doing);
      expect(finished.laneOn(_day1), QuestStage.done);
      expect(finished.laneOn(_day2), QuestStage.done);
      final reopened = finished.completedFor(_day2, false);
      expect(reopened.completedOn, isEmpty);
      // Step 2 audit (S2-m6): the user's placement is kept (was Ready).
      expect(reopened.laneOn(_day2), QuestStage.doing);
      expect(reopened.stage, QuestStage.doing);
      expect(reopened.doneFrom, isNull);
      // From Ready (or an older file) it goes back to Ready.
      final plain = _quest('r').completedFor(_day1, true);
      expect(plain.doneFrom, isNull);
      expect(plain.completedFor(_day1, false).laneOn(_day1), QuestStage.ready);
    });

    test('a daily quest: done on the day it was done, ready the next day, '
        'its history kept', () {
      final q = _quest(
        'd',
        recurrence: QuestRecurrence.daily,
        stage: QuestStage.doing,
      );
      expect(q.laneOn(_day1), QuestStage.doing);
      final done = q.completedFor(_day1, true);
      expect(done.laneOn(_day1), QuestStage.done);
      expect(done.laneOn(_day2), QuestStage.ready);
      expect(done.stage, isNot(QuestStage.done));
      final again = done.completedFor(_day2, true);
      expect(again.completedOn, {_day1, _day2});
      final undone = again.completedFor(_day2, false);
      expect(undone.completedOn, {_day1});
    });

    test('movedTo: lanes change the stage only; into done completes; out '
        'of done un-completes that day only', () {
      final q = _quest('q');
      expect(identical(q.movedTo(QuestStage.ready, _day1), q), isTrue);
      final later = q.movedTo(QuestStage.later, _day1);
      expect(later.stage, QuestStage.later);
      expect(later.completedOn, isEmpty);
      final done = later.movedTo(QuestStage.done, _day1);
      expect(done.completedOn, {_day1});
      expect(done.laneOn(_day1), QuestStage.done);
      final back = done.movedTo(QuestStage.doing, _day2);
      expect(back.completedOn, isEmpty, reason: 'a one-off is reopened');
      expect(back.laneOn(_day2), QuestStage.doing);

      final daily = _quest(
        'd',
        recurrence: QuestRecurrence.daily,
        completedOn: {_day1},
      );
      final dailyDone = daily.movedTo(QuestStage.done, _day2);
      expect(dailyDone.completedOn, {_day1, _day2});
      final dailyOut = dailyDone.movedTo(QuestStage.later, _day2);
      expect(dailyOut.completedOn, {_day1}, reason: 'other days kept');
      expect(dailyOut.laneOn(_day2), QuestStage.later);
    });
  });

  group('moveQuest and the board (Missions ops)', () {
    test('moving between Later, Ready and Doing earns nothing', () async {
      final phone = _Phone(AppData(quests: [_quest('q')]));
      final state = await phone.open();
      final xp = state.campaign.xp;
      for (final stage in [
        QuestStage.later,
        QuestStage.doing,
        QuestStage.ready,
        QuestStage.doing,
      ]) {
        await state.moveQuest('q', stage);
        expect(state.questById('q')!.laneOn(state.today), stage);
        expect(state.questById('q')!.completedOn, isEmpty);
        expect(state.campaign.xp, xp);
      }
      expect(phone.store.saved!.quests.single.stage, QuestStage.doing);
    });

    test('into Done earns exactly what ticking it earns; repeated moves '
        'the same day add nothing', () async {
      final moved = await _Phone(AppData(quests: [_quest('q')])).open();
      final ticked = await _Phone(AppData(quests: [_quest('q')])).open();
      await moved.moveQuest('q', QuestStage.done);
      await ticked.setQuestDone('q', true);
      expect(moved.questById('q')!.completedOn, {_day1});
      expect(moved.campaign.xp, ticked.campaign.xp);
      expect(moved.campaign.xp, greaterThan(0));
      final once = moved.campaign.xp;
      await moved.moveQuest('q', QuestStage.ready);
      await moved.moveQuest('q', QuestStage.done);
      await moved.moveQuest('q', QuestStage.doing);
      await moved.moveQuest('q', QuestStage.done);
      expect(moved.campaign.xp, once);
    });

    test('the daily quest XP cap holds for moves too', () async {
      final state = await _Phone(
        AppData(quests: [for (var i = 0; i < 5; i++) _quest('q$i')]),
      ).open();
      for (var i = 0; i < 5; i++) {
        await state.moveQuest('q$i', QuestStage.done);
      }
      final ticked = await _Phone(
        AppData(quests: [for (var i = 0; i < 5; i++) _quest('q$i')]),
      ).open();
      for (var i = 0; i < 5; i++) {
        await ticked.setQuestDone('q$i', true);
      }
      expect(state.campaign.xp, ticked.campaign.xp);
    });

    test(
      'out of Done un-completes today only (a daily keeps other days)',
      () async {
        final phone = _Phone(
          AppData(
            quests: [
              _quest(
                'd',
                recurrence: QuestRecurrence.daily,
                completedOn: {'2026-11-02', _day1},
              ),
            ],
          ),
        );
        final state = await phone.open();
        await state.moveQuest('d', QuestStage.doing);
        expect(state.questById('d')!.completedOn, {'2026-11-02'});
        expect(state.questById('d')!.laneOn(_day1), QuestStage.doing);
      },
    );

    test(
      'to the lane it is in, or an unknown quest: nothing is written',
      () async {
        final phone = _Phone(AppData(quests: [_quest('q')]));
        final state = await phone.open();
        final writes = phone.store.writes;
        await state.moveQuest('q', QuestStage.ready);
        await state.moveQuest('nope', QuestStage.done);
        expect(phone.store.writes, writes);
      },
    );

    test('the board: one list, every quest in its lane for the day', () async {
      final phone = _Phone(
        AppData(
          quests: [
            _quest('later', stage: QuestStage.later),
            _quest('ready'),
            _quest('doing', stage: QuestStage.doing),
            _quest('done', completedOn: {'2026-11-02'}),
            _quest(
              'daily',
              recurrence: QuestRecurrence.daily,
              completedOn: {_day1},
            ),
          ],
        ),
      );
      final today = await phone.open();
      final board = today.questBoard();
      expect(board[QuestStage.later]!.map((q) => q.id), ['later']);
      expect(board[QuestStage.ready]!.map((q) => q.id), ['ready']);
      expect(board[QuestStage.doing]!.map((q) => q.id), ['doing']);
      expect(board[QuestStage.done]!.map((q) => q.id), ['daily', 'done']);
      // Tomorrow the daily quest is ready again; "Today" stays a filter.
      final tomorrow = await phone.open(at: DateTime(2026, 11, 4, 9));
      expect(
        tomorrow.questBoard()[QuestStage.ready]!.map((q) => q.id),
        containsAll(['ready', 'daily']),
      );
      expect(tomorrow.todayFocus().map((q) => q.id), contains('daily'));
    });

    test('the checkbox keeps the stage in step; a quest may start in a '
        'lane but not as done', () async {
      final state = await _Phone().open();
      final q = await state.addQuest('Pack', stage: QuestStage.later);
      expect(q.stage, QuestStage.later);
      await state.setQuestDone(q.id, true);
      expect(state.questById(q.id)!.stage, QuestStage.done);
      await state.setQuestDone(q.id, false);
      // Step 2 audit (S2-m6): unticked, it returns to its own lane.
      expect(state.questById(q.id)!.stage, QuestStage.later);
      expect(
        () => state.addQuest('x', stage: QuestStage.done),
        throwsArgumentError,
      );
      // Switching a done-today daily quest to one-off keeps it done.
      final d = await state.addQuest(
        'Stretch',
        recurrence: QuestRecurrence.daily,
      );
      await state.setQuestDone(d.id, true);
      await state.editQuest(
        state.questById(d.id)!,
        title: 'Stretch',
        recurrence: QuestRecurrence.none,
      );
      expect(state.questById(d.id)!.stage, QuestStage.done);
    });
  });

  // ── Projects ─────────────────────────────────────────────────────────────

  group('projects: ids, art, history (JSON)', () {
    test('an older project gets a stable legacy id, kept from then on', () {
      final p = MonthProject(title: 'Ship', updatedAt: _t);
      final json = _json(AppData(project: p), (j) {
        (j['project']! as Map).remove('id');
      });
      final a = AppData.fromJson(json).project!;
      final b = AppData.fromJson(json).project!;
      expect(a.id, b.id);
      expect(a.id, legacyProjectId(_t));
      final edited = a.copyWith(title: 'Ship it', now: DateTime(2027));
      expect(edited.id, a.id, reason: 'copyWith keeps the id');
      expect(_roundTrip(AppData(project: edited)).project!.id, a.id);
    });

    test('ids, dates, art and the history round-trip', () {
      final photo = _photo('att_cover');
      final current = MonthProject(
        id: 'project_now',
        title: 'Now',
        updatedAt: _t,
        startedAt: _t,
        art: const ProjectArt.illustration(ProjectIllustration.citadel),
      );
      final past = MonthProject(
        id: 'project_then',
        title: 'Then',
        updatedAt: _t,
        retrospective: '  It went  ',
        archivedAt: _t,
        art: ProjectArt.photo(photo),
      );
      final back = _roundTrip(AppData(project: current, pastProjects: [past]));
      expect(back.project!.id, 'project_now');
      expect(back.project!.startedAt!.isAtSameMomentAs(_t), isTrue);
      expect(back.project!.art!.illustration, ProjectIllustration.citadel);
      expect(back.project!.art!.photoAttachmentId, isNull);
      final then = back.pastProjects.single;
      expect(then.id, 'project_then');
      expect(then.retrospective, '  It went  ');
      expect(then.archivedAt!.isAtSameMomentAs(_t), isTrue);
      expect(then.art!.photoAttachmentId, 'att_cover');
      expect(back.attachmentFileNames, {'att_cover.jpg'});
      // Older files have no history.
      final old = _json(AppData(project: current), (j) {
        j.remove('pastProjects');
      });
      expect(AppData.fromJson(old).pastProjects, isEmpty);
    });

    test('an unknown illustration is no picture; a recording is no cover', () {
      final p = MonthProject(
        id: 'p',
        title: 'P',
        updatedAt: _t,
        art: const ProjectArt.illustration(ProjectIllustration.sunrise),
      );
      final unknown = _json(AppData(project: p), (j) {
        ((j['project']! as Map)['art']! as Map)['illustration'] = 'volcano';
      });
      expect(AppData.fromJson(unknown).project!.art, isNull);
      final audio = _json(AppData(project: p), (j) {
        (j['project']! as Map)['art'] = {'photo': _audio('a').toJson()};
      });
      expect(() => AppData.fromJson(audio), throwsFormatException);
    });
  });

  group('projects: ops', () {
    test('the first change gives the project a new id and start; later '
        'changes keep it', () async {
      final state = await _Phone().open();
      await state.setProjectTitle('Write the guide');
      final p = state.data.project!;
      expect(p.id, startsWith('project_'));
      expect(p.id, isNot(startsWith('project_legacy')));
      expect(p.startedAt, _t);
      await state.addMilestone('Outline');
      await state.setProjectStatus(ProjectStatus.active);
      expect(state.data.project!.id, p.id);
    });

    test('new quests and attempts get the active project; finished, '
        'none, Playground tasks and levers do not', () async {
      final state = await _Phone().open();
      final before = await state.addQuest('Before any project');
      expect(before.projectId, isNull);
      await state.setProjectTitle('Launch');
      final id = state.data.project!.id;
      expect(state.activeProjectId, id);
      expect((await state.addQuest('Draft page')).projectId, id);
      expect(
        (await state.addQuest('Unlinked', linkProject: false)).projectId,
        isNull,
      );
      expect((await state.recordAttempt('Called two shops')).projectId, id);
      final tried = await state.addExperimentToTasks('try.terrain.01');
      expect(tried.projectId, isNull);
      await state.updateCompassField(CompassField.dailyLevers, 'Walk');
      await state.addQuestsFromLevers(state.leverDrafts);
      expect(
        state.data.quests.firstWhere((q) => q.title == 'Walk').projectId,
        isNull,
      );
      await state.setProjectStatus(ProjectStatus.done);
      expect(state.activeProjectId, isNull);
      expect((await state.addQuest('After')).projectId, isNull);
      expect((await state.recordAttempt('Later try')).projectId, isNull);
    });

    test('archive: into the history newest first, with the retrospective '
        'exactly as typed; none current after; links kept', () async {
      final phone = _Phone();
      final state = await phone.open();
      expect(await state.archiveProject(), isNull, reason: 'nothing yet');
      await state.setProjectTitle('First');
      final firstId = state.data.project!.id;
      final quest = await state.addQuest('Part of first');
      final archived = await state.archiveProject(
        retrospective: ' Learned to ask early. ',
      );
      expect(archived!.id, firstId);
      expect(state.data.project, isNull);
      expect(
        state.pastProjects.single.retrospective,
        ' Learned to ask early. ',
      );
      expect(state.pastProjects.single.archivedAt, _t);
      expect(state.questById(quest.id)!.projectId, firstId);
      expect(state.projectById(firstId)!.title, 'First');
      // The existing project ops keep working: a new project starts.
      await state.setProjectTitle('Second');
      final secondId = state.data.project!.id;
      expect(secondId, isNot(firstId));
      await state.setProjectRetrospective('kept as it was');
      await state.archiveProject();
      expect(state.pastProjects.map((p) => p.id), [secondId, firstId]);
      expect(state.pastProjects.first.retrospective, 'kept as it was');
      expect(phone.store.saved!.pastProjects, hasLength(2));
    });

    test('link and unlink quests and attempts by hand', () async {
      final state = await _Phone().open();
      final q = await state.addQuest('Loose');
      final a = await state.recordAttempt('Loose try');
      await state.setQuestProject(q.id, 'project_x');
      await state.setAttemptProject(a.id, 'project_x');
      expect(state.questById(q.id)!.projectId, 'project_x');
      expect(state.data.campaignLog.single.projectId, 'project_x');
      await state.setQuestProject(q.id, null);
      expect(state.questById(q.id)!.projectId, isNull);
    });

    test('a project picture: replacing a photo deletes the old file; a past '
        'project deleted takes its photo with it', () async {
      final phone = _Phone();
      final state = await phone.open();
      final first = await _import(state, 'one.jpg', [1]);
      final second = await _import(state, 'two.jpg', [2]);
      await state.setProjectArt(ProjectArt.photo(first));
      expect(state.data.project!.art!.photoAttachmentId, first.id);
      await state.setProjectArt(ProjectArt.photo(second));
      expect(phone.files.files.keys, {second.fileName});
      await state.setProjectArt(
        const ProjectArt.illustration(ProjectIllustration.route),
      );
      expect(phone.files.files, isEmpty);
      final third = await _import(state, 'three.jpg', [3]);
      await state.setProjectArt(ProjectArt.photo(third));
      final archived = await state.archiveProject();
      expect(phone.files.files.keys, {third.fileName}, reason: 'still named');
      await state.deletePastProject(archived!.id);
      expect(state.pastProjects, isEmpty);
      expect(phone.files.files, isEmpty);
    });
  });

  // ── Attachments ──────────────────────────────────────────────────────────

  group('attachments: JSON', () {
    test('photo and recording round-trip; transcript exactly as typed', () {
      final note = JournalEntry(
        id: 'n',
        body: 'b',
        createdAt: _t,
        attachments: [
          _photo('att_p'),
          _audio('att_a', durationMs: 4200, transcript: '  um, the lake  '),
        ],
      );
      final tried = ExperimentEntry(
        id: 't',
        experimentId: 'try.plan.01',
        day: _day1,
        createdAt: _t,
        attachments: [_photo('att_t')],
      );
      final attempt = BattleLogEntry(
        id: 'a',
        day: _day1,
        attempt: 'x',
        createdAt: _t,
        projectId: 'project_1',
        attachments: [_audio('att_b')],
      );
      final back = _roundTrip(
        AppData(
          journal: [note],
          experimentLog: [tried],
          campaignLog: [attempt],
        ),
      );
      final a = back.journal.single.attachments;
      expect(a.map((x) => x.kind), [
        AttachmentKind.photo,
        AttachmentKind.audio,
      ]);
      expect(a[1].durationMs, 4200);
      expect(a[1].transcript, '  um, the lake  ');
      expect(a[0].transcript, isNull);
      expect(back.experimentLog.single.attachments.single.id, 'att_t');
      expect(back.campaignLog.single.attachments.single.fileName, 'att_b.m4a');
      expect(back.campaignLog.single.projectId, 'project_1');
      expect(back.attachmentFileNames, {
        'att_p.jpg',
        'att_a.m4a',
        'att_t.jpg',
        'att_b.m4a',
      });
      expect(back.attachmentById('att_a')!.transcript, '  um, the lake  ');
      expect(
        back.attachmentsOf(AttachmentHolder.attempt, 'a').single.id,
        'att_b',
      );
    });

    test('older entries have none', () {
      final data = AppData(
        journal: [JournalEntry(id: 'n', body: 'b', createdAt: _t)],
        campaignLog: [
          BattleLogEntry(id: 'a', day: _day1, attempt: 'x', createdAt: _t),
        ],
        experimentLog: [
          ExperimentEntry(
            id: 't',
            experimentId: 'try.plan.01',
            day: _day1,
            createdAt: _t,
          ),
        ],
      );
      final old = _json(data, (j) {
        for (final key in ['journal', 'campaignLog', 'experimentLog']) {
          for (final e in (j[key]! as List).cast<Map<String, Object?>>()) {
            e.remove('attachments');
            e.remove('projectId');
          }
        }
        j.remove('pinnedMemory');
        j['schemaVersion'] = 1;
      });
      final back = AppData.fromJson(old);
      expect(back.journal.single.attachments, isEmpty);
      expect(back.campaignLog.single.attachments, isEmpty);
      expect(back.campaignLog.single.projectId, isNull);
      expect(back.experimentLog.single.attachments, isEmpty);
      expect(back.pinnedMemory, isNull);
    });

    test('a file name is one plain name — never a path; unknown kinds and '
        'bad lengths are refused', () {
      for (final bad in [
        '',
        '../x.jpg',
        'a/b.jpg',
        r'a\b.jpg',
        '.hidden',
        'x.jpg/..',
        'x..jpg',
      ]) {
        expect(isSafeAttachmentFileName(bad), isFalse, reason: bad);
        final json = _photo('p').toJson()..['fileName'] = bad;
        expect(() => Attachment.fromJson(json), throwsFormatException);
      }
      expect(isSafeAttachmentFileName('att_lz3k-9.m4a'), isTrue);
      expect(
        () => Attachment.fromJson(_photo('p').toJson()..['kind'] = 'video'),
        throwsFormatException,
      );
      expect(
        () => Attachment.fromJson(_audio('a').toJson()..['durationMs'] = -1),
        throwsFormatException,
      );
    });

    test('a newer file is refused by an older schema; v1 files load', () {
      expect(kSchemaVersion, 2);
      final v1 = _json(AppData.empty, (j) => j['schemaVersion'] = 1);
      expect(AppData.fromJson(v1).journal, isEmpty);
      final future = _json(AppData.empty, (j) => j['schemaVersion'] = 3);
      expect(() => AppData.fromJson(future), throwsFormatException);
    });
  });

  group('attachments: ops on entries', () {
    test('notes, tries and attempts hold them; editing words keeps them; '
        'transcripts exactly as typed', () async {
      final phone = _Phone();
      final state = await phone.open();
      final photo = await _import(state, 'lake.jpg', [9, 9]);
      final note = await state.addJournalEntry(
        body: 'At the lake',
        attachments: [photo],
      );
      await state.updateJournalEntry(
        JournalEntry(
          id: note.id,
          title: 'Lake',
          body: 'At the lake, again',
          createdAt: note.createdAt,
        ),
      );
      final edited = state.data.journal.single;
      expect(edited.body, 'At the lake, again');
      expect(edited.attachments.single.id, photo.id);

      final tried = await state.tryExperiment('try.plan.01', note: 'n');
      final voice = await _import(state, 'v.m4a', [
        1,
        2,
      ], kind: AttachmentKind.audio);
      await state.addAttachment(AttachmentHolder.experiment, tried.id, voice);
      await state.addAttachment(AttachmentHolder.experiment, tried.id, voice);
      await state.editExperimentEntry(tried.id, note: 'better note');
      expect(state.data.experimentLog.single.attachments, hasLength(1));
      await state.setAttachmentTranscript(
        AttachmentHolder.experiment,
        tried.id,
        voice.id,
        ' I tried it twice ',
      );
      expect(
        state.data.attachmentById(voice.id)!.transcript,
        ' I tried it twice ',
      );

      final attempt = await state.recordAttempt('Asked for feedback');
      final shot = await _import(state, 'shot.png', [3]);
      await state.addAttachment(AttachmentHolder.attempt, attempt.id, shot);
      await state.editAttempt(attempt.id, attempt: 'Asked', learning: 'l');
      expect(state.data.campaignLog.single.attachments.single.id, shot.id);
      expect(phone.store.saved!.attachmentFileNames, {
        photo.fileName,
        voice.fileName,
        shot.fileName,
      });
      expect(
        () => state.addAttachment(AttachmentHolder.journal, tried.id, shot),
        throwsArgumentError,
        reason: 'wrong holder',
      );
    });

    test('removing one deletes its file once saved', () async {
      final phone = _Phone();
      final state = await phone.open();
      final a = await _import(state, 'a.jpg', [1]);
      final b = await _import(state, 'b.jpg', [2]);
      final note = await state.addJournalEntry(body: 'x', attachments: [a, b]);
      await state.removeAttachment(AttachmentHolder.journal, note.id, a.id);
      expect(state.data.journal.single.attachments.single.id, b.id);
      expect(phone.files.files.keys, {b.fileName});
    });
  });

  group('the pinned memory', () {
    test(
      'round-trips; needs its words or its photo; a newer kind is no pin',
      () {
        final pin = PinnedMemory(
          kind: PinnedKind.photo,
          sourceId: 'note_1',
          attachmentId: 'att_1',
          excerpt: 'the lake',
          pinnedAt: _t,
        );
        final back = _roundTrip(AppData(pinnedMemory: pin)).pinnedMemory!;
        expect(back.kind, PinnedKind.photo);
        expect(back.sourceId, 'note_1');
        expect(back.attachmentId, 'att_1');
        expect(back.excerpt, 'the lake');
        expect(
          () => PinnedMemory.fromJson(pin.toJson()..['attachmentId'] = null),
          throwsFormatException,
        );
        expect(
          () => PinnedMemory.fromJson(
            pin.toJson()
              ..['kind'] = 'passage'
              ..['excerpt'] = null,
          ),
          throwsFormatException,
        );
        expect(PinnedMemory.fromJson(pin.toJson()..['kind'] = 'song'), isNull);
      },
    );

    test('a passage is the user\'s words copied exactly; anything else is '
        'refused and nothing changes', () async {
      final phone = _Phone();
      final state = await phone.open();
      final note = await state.addJournalEntry(
        title: 'Sunday',
        body: 'I want  slower mornings.',
      );
      await state.pinMemory(
        kind: PinnedKind.passage,
        sourceId: note.id,
        excerpt: 'want  slower mornings',
      );
      expect(state.pinnedMemory!.excerpt, 'want  slower mornings');
      expect(phone.store.saved!.pinnedMemory!.sourceId, note.id);
      final writes = phone.store.writes;
      for (final excerpt in [
        'want slower mornings', // spacing changed
        'I need slower mornings', // reworded
        '   ',
      ]) {
        expect(
          () => state.pinMemory(
            kind: PinnedKind.passage,
            sourceId: note.id,
            excerpt: excerpt,
          ),
          throwsArgumentError,
          reason: excerpt,
        );
      }
      expect(
        () => state.pinMemory(kind: PinnedKind.passage, sourceId: note.id),
        throwsArgumentError,
      );
      expect(
        () => state.pinMemory(
          kind: PinnedKind.passage,
          sourceId: 'note_nope',
          excerpt: 'x',
        ),
        throwsArgumentError,
      );
      expect(phone.store.writes, writes);
      await state.unpinMemory();
      expect(state.pinnedMemory, isNull);
    });

    test('a photo must be a photo on that entry; removing it or the entry '
        'unpins', () async {
      final state = await _Phone().open();
      final photo = await _import(state, 'p.jpg', [1]);
      final voice = await _import(state, 'v.m4a', [
        2,
      ], kind: AttachmentKind.audio);
      final note = await state.addJournalEntry(
        body: 'Look',
        attachments: [photo, voice],
      );
      expect(
        () => state.pinMemory(
          kind: PinnedKind.photo,
          sourceId: note.id,
          attachmentId: voice.id,
        ),
        throwsArgumentError,
      );
      await state.pinMemory(
        kind: PinnedKind.photo,
        sourceId: note.id,
        attachmentId: photo.id,
      );
      expect(state.pinnedMemory!.attachmentId, photo.id);
      await state.removeAttachment(AttachmentHolder.journal, note.id, voice.id);
      expect(state.pinnedMemory, isNotNull, reason: 'another attachment');
      await state.removeAttachment(AttachmentHolder.journal, note.id, photo.id);
      expect(state.pinnedMemory, isNull);

      final attempt = await state.recordAttempt('Tried', learning: 'Slowly');
      await state.pinMemory(
        kind: PinnedKind.passage,
        sourceId: attempt.id,
        excerpt: 'Slowly',
      );
      await state.deleteAttempt(attempt.id);
      expect(state.pinnedMemory, isNull);
    });
  });

  // ── The attachment store ─────────────────────────────────────────────────

  group('MemoryAttachmentStore (the fake)', () {
    test('imports copy the picked bytes; empty, too large and failed writes '
        'are typed', () async {
      final store = MemoryAttachmentStore(clock: () => _t);
      store.sources['/p/a.HEIC'] = [1, 2, 3];
      final a = await store.importFile('/p/a.HEIC', kind: AttachmentKind.photo);
      expect(a.fileName, endsWith('.heic'));
      expect(a.id, startsWith('att_'));
      expect(a.createdAt, _t);
      expect(await store.readBytes(a), [1, 2, 3]);
      expect(await store.sizeOf(a), 3);
      store.sources['/p/odd.exe'] = [1];
      expect(
        (await store.importFile(
          '/p/odd.exe',
          kind: AttachmentKind.photo,
        )).fileName,
        endsWith('.jpg'),
      );
      Future<AttachmentFailure> failure(Future<void> Function() f) async {
        try {
          await f();
        } on AttachmentException catch (e) {
          return e.reason;
        }
        fail('no exception');
      }

      store.sources['/p/empty.jpg'] = [];
      expect(
        await failure(
          () => store.importFile('/p/empty.jpg', kind: AttachmentKind.photo),
        ),
        AttachmentFailure.empty,
      );
      expect(
        await failure(
          () => store.importFile('/p/gone.jpg', kind: AttachmentKind.photo),
        ),
        AttachmentFailure.sourceMissing,
      );
      store.maxBytes = 2;
      expect(
        await failure(
          () => store.importFile('/p/a.HEIC', kind: AttachmentKind.photo),
        ),
        AttachmentFailure.tooLarge,
      );
      store
        ..maxBytes = kMaxAttachmentBytes
        ..failWrites = true;
      expect(
        await failure(
          () => store.importFile('/p/a.HEIC', kind: AttachmentKind.photo),
        ),
        AttachmentFailure.writeFailed,
      );
      expect(
        await failure(() => store.readFile('nope.jpg')),
        AttachmentFailure.missing,
      );
    });

    test('a recording: kept whole, kept when interrupted, never claimed when '
        'nothing was recorded, gone when cancelled', () async {
      final store = MemoryAttachmentStore(clock: () => _t);
      final recorder = FakeVoiceRecorder(store: store);

      final path = await store.newRecordingPath();
      await recorder.start(path);
      expect(recorder.isRecording, isTrue);
      final result = (await recorder.stop())!;
      final kept = await store.adoptRecording(
        result.path,
        durationMs: result.duration.inMilliseconds,
      );
      expect(kept.kind, AttachmentKind.audio);
      expect(kept.durationMs, 3000);
      expect(kept.transcript, isNull, reason: 'never filled in by the app');
      expect(await store.readBytes(kept), recorder.bytes);

      final interrupted = await store.newRecordingPath();
      await recorder.start(interrupted);
      recorder.interrupt();
      expect(recorder.state, VoiceRecorderState.paused);
      final partial = (await recorder.stop())!;
      expect(partial.interrupted, isTrue);
      expect(await store.adoptRecording(partial.path), isA<Attachment>());

      final nothing = await store.newRecordingPath();
      expect(
        () => store.adoptRecording(nothing),
        throwsA(isA<AttachmentException>()),
      );

      final cancelled = await store.newRecordingPath();
      await recorder.start(cancelled);
      await recorder.cancel();
      await store.discardRecording(cancelled);
      expect(store.pendingRecordings, isEmpty);
      expect(store.files, hasLength(2));
    });

    test('a pending recording survives the orphan cleanup', () async {
      final store = MemoryAttachmentStore(clock: () => _t);
      await store.writeFile('old.jpg', [1]);
      final path = await store.newRecordingPath();
      expect(await store.deleteOrphans({}), 1);
      store.writeRecording(path, [5]);
      expect((await store.adoptRecording(path)).fileName, path.split('/').last);
    });
  });

  group('FileAttachmentStore (real files, private folder)', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('cartharise_att'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('import copies (the source stays), reads, sizes, deletes', () async {
      final store = FileAttachmentStore(directory: dir, clock: () => _t);
      final source = File('${dir.path}/IMG_0042.JPG')
        ..writeAsBytesSync([7, 7, 7]);
      final a = await store.importFile(source.path, kind: AttachmentKind.photo);
      expect(a.fileName, isNot(contains('IMG_0042')), reason: 'no file names');
      expect(a.fileName, endsWith('.jpg'));
      expect(source.existsSync(), isTrue);
      expect(await store.exists(a), isTrue);
      expect(await store.readBytes(a), [7, 7, 7]);
      expect(await store.sizeOf(a), 3);
      expect(await store.totalSize(), 3);
      expect(await store.fileNames(), {a.fileName});
      await store.delete(a);
      expect(await store.exists(a), isFalse);
      await store.delete(a); // a missing file is fine
      expect(
        () => store.importFile(
          '${dir.path}/none.jpg',
          kind: AttachmentKind.photo,
        ),
        throwsA(
          isA<AttachmentException>().having(
            (e) => e.reason,
            'reason',
            AttachmentFailure.sourceMissing,
          ),
        ),
      );
    });

    test('recordings are written inside the folder; an empty one is not '
        'kept; a path elsewhere is refused', () async {
      final store = FileAttachmentStore(directory: dir, clock: () => _t);
      final path = await store.newRecordingPath();
      expect(File(path).parent.path, '${dir.path}/attachments');
      File(path).writeAsBytesSync([1, 2]);
      final kept = await store.adoptRecording(path, durationMs: 10);
      expect(kept.kind, AttachmentKind.audio);
      expect(kept.fileName, path.split('/').last);

      final empty = await store.newRecordingPath();
      File(empty).writeAsBytesSync([]);
      await expectLater(
        store.adoptRecording(empty),
        throwsA(
          isA<AttachmentException>().having(
            (e) => e.reason,
            'reason',
            AttachmentFailure.empty,
          ),
        ),
      );
      expect(File(empty).existsSync(), isFalse);
      final elsewhere = File('${dir.path}/x.m4a')..writeAsBytesSync([1]);
      await expectLater(
        store.adoptRecording(elsewhere.path),
        throwsA(isA<AttachmentException>()),
      );
    });

    test('orphan cleanup keeps named and pending files; writeFile is '
        'atomic and refuses paths; deleteAll and moveAside', () async {
      final store = FileAttachmentStore(directory: dir, clock: () => _t);
      await store.writeFile('keep.jpg', [1]);
      await store.writeFile('orphan.jpg', [2]);
      final pending = await store.newRecordingPath();
      File(pending).writeAsBytesSync([3]);
      expect(await store.deleteOrphans({'keep.jpg'}), 1);
      expect(await store.fileNames(), {'keep.jpg', pending.split('/').last});
      expect(
        Directory('${dir.path}/attachments')
            .listSync()
            .where((f) => f.path.endsWith('.tmp')),
        isEmpty,
      );
      expect(() => store.writeFile('../out.jpg', [1]), throwsArgumentError);
      expect(File('${dir.path}/out.jpg').existsSync(), isFalse);

      final aside = await store.moveAside();
      expect(aside, contains('attachments.unreadable-'));
      expect(Directory(aside!).existsSync(), isTrue);
      expect(await store.fileNames(), isEmpty);
      await store.writeFile('again.jpg', [1]);
      await store.deleteAll();
      expect(Directory('${dir.path}/attachments').existsSync(), isFalse);
    });
  });

  group('media fakes and helpers', () {
    test('photo picker: a path, a cancel, an honest refusal', () async {
      final picker = FakeMediaPicker()..nextPhoto = '/tmp/p.jpg';
      expect(await picker.pickPhoto(camera: true), '/tmp/p.jpg');
      picker.nextPhoto = null;
      expect(await picker.pickPhoto(camera: false), isNull);
      picker.error = const MediaPickerException(MediaFailure.permissionDenied);
      expect(
        () => picker.pickPhoto(camera: true),
        throwsA(
          isA<MediaPickerException>().having(
            (e) => e.reason,
            'reason',
            MediaFailure.permissionDenied,
          ),
        ),
      );
      expect(picker.requests, [true, false, true]);
      await picker.release('/tmp/p.jpg');
      expect(picker.released, ['/tmp/p.jpg']);
    });

    test('recorder: a refused microphone is said, nothing starts', () async {
      final recorder = FakeVoiceRecorder()..permission = false;
      expect(
        () => recorder.start('/x.m4a'),
        throwsA(
          isA<VoiceRecorderException>().having(
            (e) => e.reason,
            'reason',
            VoiceFailure.permissionDenied,
          ),
        ),
      );
      expect(recorder.isRecording, isFalse);
      expect(await recorder.stop(), isNull);
    });

    test('player: plays, pauses, stops; a failure is typed', () async {
      final player = FakeVoicePlayer();
      await player.play('/memory/attachments/a.m4a');
      expect(player.state, VoicePlayerState.playing);
      await player.pause();
      expect(player.state, VoicePlayerState.paused);
      await player.stop();
      expect(player.currentPath, isNull);
      player.failPlay = true;
      expect(() => player.play('/x'), throwsA(isA<VoicePlayerException>()));
    });

    test('the level meter maps dBFS calmly to 0–1', () {
      expect(levelOfDb(-160), 0);
      expect(levelOfDb(double.nan), 0);
      expect(levelOfDb(0), 1);
      final mid = levelOfDb(-20);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(1));
      expect(levelOfDb(-10), greaterThan(mid));
    });
  });

  // ── Garbage ──────────────────────────────────────────────────────────────

  group('files follow their entries', () {
    test('deleting a note, a try or an attempt deletes its files — never '
        'one still named elsewhere', () async {
      final phone = _Phone();
      final state = await phone.open();
      final shared = await _import(state, 'shared.jpg', [1]);
      final own = await _import(state, 'own.jpg', [2]);
      final note = await state.addJournalEntry(
        body: 'x',
        attachments: [shared, own],
      );
      await state.setProjectArt(ProjectArt.photo(shared));
      await state.deleteJournalEntry(note.id);
      expect(phone.files.files.keys, {shared.fileName});

      final voice = await _import(state, 'v.m4a', [
        3,
      ], kind: AttachmentKind.audio);
      final tried = await state.tryExperiment(
        'try.plan.01',
        attachments: [voice],
      );
      await state.deleteExperimentEntry(tried.id);
      expect(phone.files.files.keys, {shared.fileName});

      final shot = await _import(state, 's.jpg', [4]);
      final attempt = await state.recordAttempt('x', attachments: [shot]);
      await state.deleteAttempt(attempt.id);
      expect(phone.files.files.keys, {shared.fileName});
    });

    test('a delete that could not be saved keeps the files the saved data '
        'still names', () async {
      final phone = _Phone();
      final state = await phone.open();
      final photo = await _import(state, 'p.jpg', [1]);
      final note = await state.addJournalEntry(body: 'x', attachments: [photo]);
      phone.store.failWrites = true;
      await state.deleteJournalEntry(note.id);
      expect(state.saveStatus, SaveStatus.failed);
      expect(phone.files.files.keys, {photo.fileName});
      // The app is closed; the saved data still has the note and its photo.
      phone.store.failWrites = false;
      final reopened = await phone.open();
      expect(reopened.data.journal.single.attachments.single.id, photo.id);
      expect(phone.files.files.keys, {photo.fileName});
    });

    test('orphans are cleaned on load, never a named file', () async {
      final photo = _photo('att_named');
      final phone = _Phone(
        AppData(
          journal: [
            JournalEntry(
              id: 'n',
              body: 'b',
              createdAt: _t,
              attachments: [photo],
            ),
          ],
        ),
      );
      await phone.files.writeFile('att_named.jpg', [1]);
      await phone.files.writeFile('att_orphan.jpg', [2]);
      await phone.open();
      expect(phone.files.files.keys, {'att_named.jpg'});
    });

    test('an unreadable data file: nothing is cleaned; starting fresh sets '
        'the files aside with it', () async {
      final phone = _Phone();
      phone.store.raw = '{ damaged';
      await phone.files.writeFile('att_maybe.jpg', [1]);
      final state = AppState(
        store: phone.store,
        content: fakeContent,
        reminders: FakeReminderScheduler(),
        attachments: phone.files,
        clock: () => _t,
      );
      await state.load();
      expect(state.loadError, isNotNull);
      expect(phone.files.files.keys, {'att_maybe.jpg'});
      await state.startFreshAfterLoadError();
      expect(phone.files.files, isEmpty);
      expect(phone.files.asideFiles!.keys, {'att_maybe.jpg'});
    });
  });

  // ── Backup v2 ────────────────────────────────────────────────────────────

  group('backup v2 (pure)', () {
    final photo = _photo('att_p');
    final data = AppData(
      journal: [
        JournalEntry(
          id: 'n',
          body: '  words ',
          createdAt: _t,
          attachments: [photo, _audio('att_a')],
        ),
      ],
    );

    test('a zip of data.json and the files, round trip byte for byte', () {
      final zip = encodeBackupArchive(data, _t, {
        'att_p.jpg': [1, 2, 3],
        'att_a.m4a': [4, 5],
        'att_unnamed.jpg': [9], // not referenced: left out
      });
      expect(isZipBytes(zip), isTrue);
      final archive = ZipDecoder().decodeBytes(zip);
      expect(archive.files.map((f) => f.name).toSet(), {
        'data.json',
        'attachments/att_a.m4a',
        'attachments/att_p.jpg',
      });
      final envelope = jsonDecode(
        utf8.decode(archive.find('data.json')!.readBytes()!),
      ) as Map<String, Object?>;
      expect(envelope['app'], 'cartharise');
      expect(envelope['format'], kBackupArchiveFormat);
      final back = decodeBackupBytes(zip);
      expect(back.format, kBackupArchiveFormat);
      expect(back.exportedAt, _t.toUtc());
      expect(back.data.journal.single.body, '  words ');
      expect(back.files['att_p.jpg'], [1, 2, 3]);
      expect(back.files['att_a.m4a'], [4, 5]);
      expect(back.notIncluded, isEmpty);
    });

    test('a file the data names but the zip lacks is reported, never '
        'dropped', () {
      final zip = encodeBackupArchive(data, _t, {
        'att_p.jpg': [1],
      });
      final back = decodeBackupBytes(zip);
      expect(back.notIncluded, {'att_a.m4a'});
      expect(back.data.journal.single.attachments, hasLength(2));
    });

    test('entries outside attachments/ or with path names are ignored', () {
      final archive = Archive()
        ..add(
          ArchiveFile.string(
            'data.json',
            encodeBackup(data, _t, format: kBackupArchiveFormat),
          ),
        )
        ..add(ArchiveFile.bytes('attachments/../evil.jpg', [6]))
        ..add(ArchiveFile.bytes('att_p.jpg', [7]))
        ..add(ArchiveFile.bytes('attachments/att_p.jpg', [8]));
      final back = decodeBackupBytes(ZipEncoder().encodeBytes(archive));
      expect(back.files.keys, {'att_p.jpg'});
      expect(back.files['att_p.jpg'], [8]);
    });

    test('v1 JSON files (bytes) still decode; bad files are refused', () {
      final v1 = utf8.encode(encodeBackup(data, _t));
      final back = decodeBackupBytes(v1);
      expect(back.format, kBackupFormat);
      expect(back.files, isEmpty);
      expect(back.notIncluded, {'att_p.jpg', 'att_a.m4a'});

      String reason(List<int> bytes) {
        try {
          decodeBackupBytes(bytes);
        } on FormatException catch (e) {
          return e.message;
        }
        fail('accepted');
      }

      expect(reason([0xff, 0xfe, 0x00]), 'Not a text file');
      expect(reason(utf8.encode('{ nope')), 'Not a JSON file');
      final noData = ZipEncoder().encodeBytes(
        Archive()..add(ArchiveFile.string('notes.txt', 'hi')),
      );
      expect(reason(noData), 'Not a Cartharise backup');
      final zip = encodeBackupArchive(data, _t, const {});
      expect(reason(zip.sublist(0, zip.length ~/ 2)), 'Damaged archive');
      final flipped = Uint8List.fromList(zip);
      for (var i = 40; i < 80; i++) {
        flipped[i] ^= 0xff; // inside data.json's compressed bytes
      }
      expect(reason(flipped), 'Damaged archive');
      final l = AppLocalizationsEn();
      expect(
        backupErrorMessage(l, const FormatException('Damaged archive')),
        l.youDataImportDamaged,
      );
    });
  });

  group('backup v2 through AppState', () {
    test(
      'export → a new phone → restore: data and files, byte for byte',
      () async {
        final phone = _Phone();
        final state = await phone.open();
        final photo = await _import(state, 'p.jpg', [1, 2, 3]);
        final voice = await _import(state, 'v.m4a', [
          4,
          5,
        ], kind: AttachmentKind.audio);
        final note = await state.addJournalEntry(
          body: 'Exactly  this',
          attachments: [photo],
        );
        final attempt = await state.recordAttempt('x', attachments: [voice]);
        await state.pinMemory(
          kind: PinnedKind.passage,
          sourceId: note.id,
          excerpt: 'Exactly  this',
        );
        await state.setProjectTitle('Now');
        await state.archiveProject(retrospective: 'done');
        final export = await state.exportBackupArchive();
        expect(export.missing, isEmpty);

        final other = _Phone();
        final fresh = await other.open();
        final preview = await fresh.previewRestore(export.bytes);
        expect(preview.missing, isEmpty);
        await fresh.restoreBackup(preview);
        expect(fresh.data.journal.single.body, 'Exactly  this');
        expect(fresh.data.campaignLog.single.id, attempt.id);
        expect(fresh.pinnedMemory!.excerpt, 'Exactly  this');
        expect(fresh.pastProjects.single.retrospective, 'done');
        expect(other.files.files[photo.fileName], [1, 2, 3]);
        expect(other.files.files[voice.fileName], [4, 5]);
        expect(other.store.saved!.attachmentFileNames, {
          photo.fileName,
          voice.fileName,
        });
      },
    );

    test('a file that could not be read is said at export, and counted as '
        'missing at restore; its entry is kept', () async {
      final phone = _Phone();
      final state = await phone.open();
      final photo = await _import(state, 'p.jpg', [1]);
      await state.addJournalEntry(body: 'x', attachments: [photo]);
      phone.files.files.remove(photo.fileName);
      final export = await state.exportBackupArchive();
      expect(export.missing, {photo.fileName});
      final other = await _Phone().open();
      final preview = await other.previewRestore(export.bytes);
      expect(preview.missing, {photo.fileName});
      await other.restoreBackup(preview);
      expect(other.data.journal.single.attachments.single.id, photo.id);
    });

    test('v1 JSON still restores; on the same phone its named files are '
        'not missing', () async {
      final phone = _Phone();
      final state = await phone.open();
      final photo = await _import(state, 'p.jpg', [1]);
      await state.addJournalEntry(body: 'v1', attachments: [photo]);
      final json = state.exportBackup();
      final preview = await state.previewRestore(utf8.encode(json));
      expect(preview.contents.format, kBackupFormat);
      expect(preview.missing, isEmpty);
      await state.importBackup(json);
      expect(state.data.journal.single.body, 'v1');
      expect(phone.files.files.keys, {photo.fileName});
      final elsewhere = await _Phone().open();
      expect((await elsewhere.previewRestore(utf8.encode(json))).missing, {
        photo.fileName,
      });
    });

    test('files that cannot be written: nothing is replaced', () async {
      final source = await _Phone().open();
      final photo = await _import(source, 'p.jpg', [1]);
      await source.addJournalEntry(body: 'new', attachments: [photo]);
      final export = await source.exportBackupArchive();

      final phone = _Phone(
        AppData(
          journal: [JournalEntry(id: 'old', body: 'old', createdAt: _t)],
        ),
      );
      final state = await phone.open();
      final preview = await state.previewRestore(export.bytes);
      phone.files.failWrites = true;
      await expectLater(
        state.restoreBackup(preview),
        throwsA(isA<AttachmentException>()),
      );
      expect(state.data.journal.single.body, 'old');
      expect(phone.store.saved!.journal.single.body, 'old');
    });

    test(
      'a restore removes the files only the old data named, once saved',
      () async {
        final phone = _Phone();
        final state = await phone.open();
        final mine = await _import(state, 'mine.jpg', [1]);
        await state.addJournalEntry(body: 'mine', attachments: [mine]);
        final other = await _Phone().open();
        final theirs = await _import(other, 'theirs.jpg', [2]);
        await other.addJournalEntry(body: 'theirs', attachments: [theirs]);
        final export = await other.exportBackupArchive();
        await state.restoreBackup(await state.previewRestore(export.bytes));
        expect(phone.files.files.keys, {theirs.fileName});
      },
    );
  });

  group('"Delete all data"', () {
    test('removes the photos, recordings and the pinned memory', () async {
      final phone = _Phone();
      final state = await phone.open();
      final photo = await _import(state, 'p.jpg', [1]);
      final note = await state.addJournalEntry(body: 'b', attachments: [photo]);
      await state.pinMemory(
        kind: PinnedKind.photo,
        sourceId: note.id,
        attachmentId: photo.id,
      );
      await phone.files.newRecordingPath();
      expect(await state.deleteAllData(), isTrue);
      expect(phone.files.files, isEmpty);
      expect(phone.files.pendingRecordings, isEmpty);
      expect(state.pinnedMemory, isNull);
      expect(state.pastProjects, isEmpty);
      expect(phone.store.raw, isNull);
    });

    test('files that could not be removed are said; the data is gone and '
        'the next launch removes them', () async {
      final phone = _Phone();
      final state = await phone.open();
      final photo = await _import(state, 'p.jpg', [1]);
      await state.addJournalEntry(body: 'b', attachments: [photo]);
      phone.files.failDeletes = true;
      expect(await state.deleteAllData(), isFalse);
      expect(state.data.journal, isEmpty);
      expect(phone.store.raw, isNull);
      expect(phone.files.files, isNotEmpty);
      phone.files.failDeletes = false;
      await phone.open();
      expect(phone.files.files, isEmpty);
    });

    test('a data file that could not be deleted leaves everything', () async {
      final phone = _Phone();
      final state = await phone.open();
      final photo = await _import(state, 'p.jpg', [1]);
      await state.addJournalEntry(body: 'b', attachments: [photo]);
      phone.store.failWrites = true;
      await expectLater(
        state.deleteAllData(),
        throwsA(isA<StorageWriteException>()),
      );
      expect(phone.files.files.keys, {photo.fileName});
      expect(state.data.journal, hasLength(1));
    });
  });

  // ── You › Your data with backup v2 (fakes through the real app) ──────────

  group('Your data screen (v2)', () {
    Future<void> tap(WidgetTester tester, Finder f) async {
      await tester.ensureVisible(f);
      await pumpFrames(tester);
      await tester.tap(f);
      await pumpFrames(tester);
    }

    AppData withPhoto(String fileName) => onboardedData().copyWith(
      journal: [
        JournalEntry(
          id: 'n',
          body: 'With a photo',
          createdAt: _t,
          attachments: [_photo('att_x', fileName: fileName)],
        ),
      ],
    );

    for (final brightness in Brightness.values) {
      testWidgets('export carries the photo; an unreadable one is said '
          '(${brightness.name})', (tester) async {
        final files = MemoryAttachmentStore(clock: () => _t);
        await files.writeFile('att_x.jpg', [1, 2]);
        final h = await pumpCartha(
          tester,
          data: withPhoto('att_x.jpg'),
          home: const DataScreen(),
          attachments: files,
          brightness: brightness,
        );
        await tap(tester, find.byKey(const ValueKey('data-export')));
        final zip = h.files.shared.single;
        expect(zip.mimeType, kBackupZipMimeType);
        expect(decodeBackupBytes(zip.bytes).files['att_x.jpg'], [1, 2]);
        expect(find.text('Backup shared.'), findsOneWidget);

        files.failReads = true;
        await tester.pump(const Duration(seconds: 5));
        await tap(tester, find.byKey(const ValueKey('data-export')));
        expect(
          find.text(
            "Backup shared, but some photos or recordings couldn't be read "
            "and aren't in it.",
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('restore says how many photos or recordings are missing', (
      tester,
    ) async {
      final h = await pumpCartha(tester, home: const DataScreen());
      // A v1 JSON naming a photo this phone doesn't have.
      h.files.pickResult = encodeBackup(withPhoto('att_x.jpg'), _t);
      await tap(tester, find.byKey(const ValueKey('data-import')));
      expect(
        find.textContaining(
          'One photo or recording it names is missing. Its entry is kept.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
      await pumpFrames(tester);
      expect(find.text('Backup restored.'), findsOneWidget);
      expect(h.state.data.journal.single.attachments, hasLength(1));
    });

    testWidgets('restore whose files cannot be saved changes nothing', (
      tester,
    ) async {
      final source = MemoryAttachmentStore(clock: () => _t);
      await source.writeFile('att_x.jpg', [1]);
      final zip = encodeBackupArchive(withPhoto('att_x.jpg'), _t, {
        'att_x.jpg': [1],
      });
      final files = MemoryAttachmentStore(clock: () => _t)..failWrites = true;
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const DataScreen(),
        attachments: files,
      );
      h.files.pickBytes = zip;
      await tap(tester, find.byKey(const ValueKey('data-import')));
      await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
      await pumpFrames(tester);
      expect(
        find.text("Its photos and recordings couldn't be saved on this phone."),
        findsOneWidget,
      );
      expect(find.text('Your current data was not changed.'), findsOneWidget);
      expect(h.state.data.journal, isEmpty);
    });

    testWidgets('delete all removes the files and the picker copies', (
      tester,
    ) async {
      final files = MemoryAttachmentStore(clock: () => _t);
      await files.writeFile('att_x.jpg', [1]);
      final h = await pumpCartha(
        tester,
        data: withPhoto('att_x.jpg'),
        home: const DataScreen(),
        attachments: files,
      );
      await tap(tester, find.byKey(const ValueKey('data-delete')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpFrames(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await pumpFrames(tester);
      expect(files.files, isEmpty);
      expect(h.media.clearCount, 1);
      expect(h.store.raw, isNull);
    });

    testWidgets('files left after delete all are said honestly', (
      tester,
    ) async {
      final files = MemoryAttachmentStore(clock: () => _t);
      await files.writeFile('att_x.jpg', [1]);
      await pumpCartha(
        tester,
        data: withPhoto('att_x.jpg'),
        home: const DataScreen(),
        attachments: files,
      );
      files.failDeletes = true;
      await tap(tester, find.byKey(const ValueKey('data-delete')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpFrames(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await pumpFrames(tester);
      expect(
        find.text(
          "Deleted, but some photos or recordings couldn't be removed yet. "
          'Opening the app again removes them.',
        ),
        findsOneWidget,
      );
    });

    for (final size in kSizeMatrix) {
      testWidgets('fits $size with the new texts', (tester) async {
        await pumpCartha(
          tester,
          home: const DataScreen(),
          size: size.size,
          textScale: size.textScale,
          brightness: Brightness.light,
        );
        await expectNoOverflow(tester);
      });
    }
  });
}
