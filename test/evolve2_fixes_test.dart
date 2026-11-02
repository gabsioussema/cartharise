// Step 2 audit fixes (docs/plans/evolve.md, Step 2): the logic behind
// S2-M2 (no backup that can't be restored), S2-m1 (a pin never shows words
// the entry lost), S2-m2/m4 (recordings cut off by a crash and photos the
// camera hands back are held for the user, never cleaned up silently),
// S2-m3 (a recording cut short stays "Partial"), S2-m5 ("Delete all data"
// also removes set-aside copies), S2-m6 (a one-off reopened goes back to
// its lane) and S2-m7 (schema-1 attempts belong to their project).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/services/attachment_store.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/state/attachment_ops.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/missions/missions_logic.dart';
import 'package:cartharise/ui/missions/project_ops.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_content.dart';
import 'support/fakes.dart';

final _t = DateTime(2026, 11, 3, 9, 30);

Future<AppState> _open(
  DataStore store,
  AttachmentStore files, {
  DateTime? at,
}) async {
  final state = AppState(
    store: store,
    content: fakeContent,
    reminders: FakeReminderScheduler(),
    attachments: files,
    clock: () => at ?? _t,
  );
  await state.load();
  return state;
}

Attachment _photo(String id) => Attachment(
  id: id,
  kind: AttachmentKind.photo,
  fileName: '$id.jpg',
  createdAt: _t,
);

Attachment _audio(String id, {String? transcript}) => Attachment(
  id: id,
  kind: AttachmentKind.audio,
  fileName: '$id.m4a',
  createdAt: _t,
  transcript: transcript,
);

/// A store whose files report [size] bytes each (without holding them).
class _SizedStore extends MemoryAttachmentStore {
  _SizedStore(this.size) : super(clock: () => DateTime(2026));
  final int size;

  @override
  Future<int> sizeOfFile(String fileName) async =>
      files.containsKey(fileName) ? size : 0;
}

void main() {
  group('S2-M2 a backup is never made bigger than a restore accepts', () {
    AppData withPhoto() => AppData(
      journal: [
        JournalEntry(
          id: 'n',
          body: 'b',
          createdAt: _t,
          attachments: [_photo('p')],
        ),
      ],
    );

    test('the files are measured first: over the limit, nothing is read '
        'or built', () async {
      final files = _SizedStore(kMaxBackupBytes + 1)
        ..files['p.jpg'] = Uint8List.fromList([1]);
      files.failReads = true; // would be read only if it got that far
      final state = await _open(MemoryDataStore(withPhoto()), files);
      await expectLater(
        state.exportBackupArchive(),
        throwsA(
          isA<BackupTooLargeException>().having(
            (e) => e.bytes,
            'bytes',
            kMaxBackupBytes + 1,
          ),
        ),
      );
      // The words-only backup is still there to offer.
      expect(decodeBackup(state.exportBackup()).journal.single.body, 'b');
    });

    test(
      'a finished zip over the limit is refused too; under it, made',
      () async {
        final files = MemoryAttachmentStore(clock: () => _t)
          ..files['p.jpg'] = Uint8List.fromList(List.filled(400, 7));
        final state = await _open(MemoryDataStore(withPhoto()), files);
        await expectLater(
          state.exportBackupArchive(maxBytes: 450),
          throwsA(isA<BackupTooLargeException>()),
        );
        final made = await state.exportBackupArchive();
        expect(made.bytes.length, lessThan(kMaxBackupBytes));
        expect(decodeBackupBytes(made.bytes).files['p.jpg'], hasLength(400));
      },
    );
  });

  group('S2-m1 a pinned passage is never words the entry lost', () {
    AppData data({PinnedMemory? pin}) => AppData(
      journal: [
        JournalEntry(
          id: 'n',
          title: 'Walk',
          body: 'A secret line. Then more.',
          createdAt: _t,
          attachments: [
            _photo('p'),
            _audio('v', transcript: 'said by the lake'),
          ],
        ),
      ],
      campaignLog: [
        BattleLogEntry(
          id: 'a',
          day: '2026-11-03',
          attempt: 'Wrote first',
          learning: 'Mornings work.',
          createdAt: _t,
        ),
      ],
      experimentLog: [
        ExperimentEntry(
          id: 'e',
          experimentId: 'try.pattern.01',
          day: '2026-11-03',
          note: 'No phone at lunch',
          createdAt: _t,
        ),
      ],
      pinnedMemory: pin,
    );

    PinnedMemory passage(String source, String words) => PinnedMemory(
      kind: PinnedKind.passage,
      sourceId: source,
      excerpt: words,
      pinnedAt: _t,
    );

    test('a note edited: unpinned when the words are gone, kept when they '
        'stay (saved, too)', () async {
      final store = MemoryDataStore(data(pin: passage('n', 'A secret line.')));
      final state = await _open(store, MemoryAttachmentStore(clock: () => _t));
      final note = state.data.journal.single;
      await state.updateJournalEntry(
        note.copyWith(body: 'Still: A secret line. Edited.'),
      );
      expect(state.data.pinnedMemory?.excerpt, 'A secret line.');
      await state.updateJournalEntry(note.copyWith(body: 'other words'));
      expect(state.data.pinnedMemory, isNull);
      expect(store.saved!.pinnedMemory, isNull);
      expect(store.saved!.journal.single.body, 'other words');
    });

    test('an attempt, a try and a transcript edited the same way', () async {
      final files = MemoryAttachmentStore(clock: () => _t)
        ..files['p.jpg'] = Uint8List.fromList([1])
        ..files['v.m4a'] = Uint8List.fromList([1]);
      final state = await _open(
        MemoryDataStore(data(pin: passage('a', 'Mornings'))),
        files,
      );
      await state.editAttempt('a', attempt: 'Wrote first', learning: 'Nights.');
      expect(state.data.pinnedMemory, isNull);

      await state.pinMemory(
        kind: PinnedKind.passage,
        sourceId: 'e',
        excerpt: 'No phone',
      );
      await state.editExperimentEntry('e', note: 'Phone away at lunch');
      expect(state.data.pinnedMemory, isNull);

      await state.pinMemory(
        kind: PinnedKind.passage,
        sourceId: 'n',
        excerpt: 'by the lake',
      );
      await state.setAttachmentTranscript(
        AttachmentHolder.journal,
        'n',
        'v',
        'said at home',
      );
      expect(state.data.pinnedMemory, isNull);

      // Removing the recording takes words pinned from its transcript.
      await state.setAttachmentTranscript(
        AttachmentHolder.journal,
        'n',
        'v',
        'by the lake',
      );
      await state.pinMemory(
        kind: PinnedKind.passage,
        sourceId: 'n',
        excerpt: 'by the lake',
      );
      await state.removeAttachment(AttachmentHolder.journal, 'n', 'v');
      expect(state.data.pinnedMemory, isNull);
    });

    test('a pinned photo stays pinned without the words it lost', () async {
      final files = MemoryAttachmentStore(clock: () => _t)
        ..files['p.jpg'] = Uint8List.fromList([1]);
      final state = await _open(
        MemoryDataStore(
          data(
            pin: PinnedMemory(
              kind: PinnedKind.photo,
              sourceId: 'n',
              attachmentId: 'p',
              excerpt: 'A secret line.',
              pinnedAt: _t,
            ),
          ),
        ),
        files,
      );
      await state.updateJournalEntry(
        state.data.journal.single.copyWith(body: 'rewritten'),
      );
      final pin = state.data.pinnedMemory!;
      expect(pin.kind, PinnedKind.photo);
      expect(pin.attachmentId, 'p');
      expect(pin.excerpt, isNull);
    });
  });

  group('S2-m2/m4 held recordings and photos survive a restart', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('cartharise_held'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('a recording cut off by a crash is kept and offered, then settled '
        'once kept', () async {
      final data = MemoryDataStore(AppData.empty);
      final before = FileAttachmentStore(directory: dir, clock: () => _t);
      final path = await before.newRecordingPath();
      File(path).writeAsBytesSync([1, 2, 3]);
      // The process ends: no adopt, no discard, no hide event.

      final after = FileAttachmentStore(directory: dir, clock: () => _t);
      final state = await _open(data, after);
      final name = path.split('/').last;
      expect(File(path).existsSync(), isTrue, reason: 'never an orphan');
      final cut = state.recoveredMedia.single;
      expect(cut.fileName, name);
      expect(cut.kind, AttachmentKind.audio);
      expect(cut.interrupted, isTrue);

      final note = await state.keepRecovered(cut);
      expect(note.body, '');
      expect(note.attachments.single.interrupted, isTrue);
      expect(state.recoveredMedia, isEmpty);

      final third = await _open(
        data,
        FileAttachmentStore(directory: dir, clock: () => _t),
      );
      expect(third.recoveredMedia, isEmpty, reason: 'settled');
      expect(File(path).existsSync(), isTrue);
    });

    test('a recording saved on its entry is not offered; an empty one is '
        'removed; discard deletes', () async {
      final data = MemoryDataStore(AppData.empty);
      final files = FileAttachmentStore(directory: dir, clock: () => _t);
      final state = await _open(data, files);
      final kept = await files.newRecordingPath();
      File(kept).writeAsBytesSync([1]);
      final recording = await files.adoptRecording(kept);
      await state.addJournalEntry(body: '', attachments: [recording]);
      final empty = await files.newRecordingPath();
      File(empty).writeAsBytesSync([]);
      final cut = await files.newRecordingPath();
      File(cut).writeAsBytesSync([9]);

      final next = await _open(
        data,
        FileAttachmentStore(directory: dir, clock: () => _t),
      );
      expect(next.recoveredMedia.map((a) => a.fileName), [cut.split('/').last]);
      expect(File(empty).existsSync(), isFalse);
      expect(File(kept).existsSync(), isTrue);
      await next.discardRecovered(next.recoveredMedia.single);
      expect(File(cut).existsSync(), isFalse);
      final last = await _open(
        data,
        FileAttachmentStore(directory: dir, clock: () => _t),
      );
      expect(last.recoveredMedia, isEmpty);
    });

    test('a photo the camera handed back is held across launches until '
        'the user decides', () async {
      final data = MemoryDataStore(AppData.empty);
      final picked = File('${dir.path}/IMG_lost.jpg')..writeAsBytesSync([5, 5]);
      final state = await _open(
        data,
        FileAttachmentStore(directory: dir, clock: () => _t),
      );
      final photo = await state.holdRecoveredPhoto(picked.path);
      expect(photo.fileName, isNot(contains('IMG_lost')));
      expect(state.recoveredMedia.single.id, photo.id);

      final next = await _open(
        data,
        FileAttachmentStore(directory: dir, clock: () => _t),
      );
      final held = next.recoveredMedia.single;
      expect(held.kind, AttachmentKind.photo);
      expect(held.interrupted, isFalse);
      expect(
        File('${dir.path}/attachments/${held.fileName}').readAsBytesSync(),
        [5, 5],
      );
    });

    test('a restore settles what the old data named', () async {
      final files = MemoryAttachmentStore(clock: () => _t);
      final state = await _open(MemoryDataStore(AppData.empty), files);
      final path = await files.newRecordingPath();
      files.writeRecording(path, [1]);
      final rec = await files.adoptRecording(path);
      await state.addJournalEntry(body: '', attachments: [rec]);
      expect(files.held, {rec.fileName});
      await state.importBackup(encodeBackup(AppData.empty, _t));
      expect(files.held, isEmpty);
      expect(files.files, isEmpty, reason: 'gone with the replaced data');
    });
  });

  group('S2-m3 a recording cut short is "Partial" in the data', () {
    test('round-trips; older files and complete recordings are not', () {
      final cut = _audio('v').copyWith(interrupted: true);
      expect(cut.toJson()['interrupted'], true);
      expect(Attachment.fromJson(cut.toJson()).interrupted, isTrue);
      final whole = _audio('w');
      expect(whole.toJson().containsKey('interrupted'), isFalse);
      expect(Attachment.fromJson(whole.toJson()).interrupted, isFalse);
      expect(
        () => Attachment.fromJson(whole.toJson()..['interrupted'] = 'yes'),
        throwsFormatException,
      );
    });
  });

  group('S2-m5 "Delete all data" leaves no set-aside copy', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('cartharise_del'));
    tearDown(() => dir.deleteSync(recursive: true));

    test(
      'unreadable data files and attachment folders set aside go too',
      () async {
        final store = FileDataStore(directory: dir, clock: () => _t);
        final files = FileAttachmentStore(directory: dir, clock: () => _t);
        File('${dir.path}/${FileDataStore.fileName}').writeAsStringSync('junk');
        await files.writeFile('old.jpg', [1]);
        final state = AppState(
          store: store,
          content: fakeContent,
          reminders: FakeReminderScheduler(),
          attachments: files,
          clock: () => _t,
        );
        await state.load();
        expect(state.loadError, isNotNull);
        final kept = await state.startFreshAfterLoadError();
        expect(File(kept!).existsSync(), isTrue);
        expect(
          dir.listSync().whereType<Directory>().map((d) => d.path),
          contains(contains('attachments.unreadable-')),
        );
        // Something unrelated in the same folder is never touched.
        final other = File('${dir.path}/flutter_assets.txt')
          ..writeAsStringSync('x');
        await state.addJournalEntry(body: 'new start');

        expect(await state.deleteAllData(), isTrue);
        final left = dir.listSync().map(
          (e) => e.uri.pathSegments.lastWhere((p) => p.isNotEmpty),
        );
        expect(left, ['flutter_assets.txt']);
        expect(other.existsSync(), isTrue);
      },
    );

    test('the in-memory stores forget their set-aside copies', () async {
      final store = MemoryDataStore()..raw = 'garbage';
      final files = MemoryAttachmentStore(clock: () => _t)
        ..files['x.jpg'] = Uint8List.fromList([1]);
      final state = AppState(
        store: store,
        content: fakeContent,
        reminders: FakeReminderScheduler(),
        attachments: files,
        clock: () => _t,
      );
      await state.load();
      await state.startFreshAfterLoadError();
      expect(store.asideRaw, 'garbage');
      expect(files.asideFiles, isNotNull);
      await state.deleteAllData();
      expect(store.asideRaw, isNull);
      expect(files.asideFiles, isNull);
    });
  });

  group('S2-m6 a one-off reopened goes back to its lane', () {
    test(
      'Doing → ticked → unticked is Doing again; Later too; saved',
      () async {
        final store = MemoryDataStore(AppData.empty);
        final state = await _open(
          store,
          MemoryAttachmentStore(clock: () => _t),
        );
        for (final lane in [QuestStage.doing, QuestStage.later]) {
          final q = await state.addQuest('Pack ${lane.name}');
          await state.moveQuest(q.id, lane);
          await state.setQuestDone(q.id, true);
          expect(state.questById(q.id)!.laneOn(state.today), QuestStage.done);
          expect(store.saved!.quests.last.doneFrom, lane);
          await state.setQuestDone(q.id, false);
          expect(state.questById(q.id)!.laneOn(state.today), lane);
          expect(state.questBoard()[lane]!.map((x) => x.id), contains(q.id));
        }
      },
    );

    test('doneFrom: JSON round-trip, older files and junk', () {
      final q = Quest(
        id: 'q',
        title: 'x',
        createdAt: _t,
        stage: QuestStage.doing,
      ).completedFor('2026-11-03', true);
      final back = Quest.fromJson(jsonDecode(jsonEncode(q.toJson())));
      expect(back.stage, QuestStage.done);
      expect(back.doneFrom, QuestStage.doing);
      final older = q.toJson()..remove('doneFrom');
      expect(Quest.fromJson(older).doneFrom, isNull);
      expect(
        Quest.fromJson(q.toJson()..['doneFrom'] = 'someday').doneFrom,
        isNull,
      );
      expect(
        () => Quest.fromJson(q.toJson()..['doneFrom'] = 2),
        throwsFormatException,
      );
      // An open quest never keeps one.
      final open = Quest.fromJson(
        q.toJson()
          ..['completedOn'] = <String>[]
          ..['doneFrom'] = 'later',
      );
      expect(open.stage, QuestStage.later);
      expect(open.doneFrom, isNull);
    });
  });

  group('S2-m7 schema-1 attempts belong to their project', () {
    Map<String, Object?> v1({bool project = true}) {
      final data = AppData(
        project: project
            ? MonthProject(title: 'Essay', updatedAt: DateTime.utc(2026, 10))
            : null,
        quests: [
          Quest(
            id: 'mine',
            title: 'From the project',
            createdAt: _t,
            source: QuestSource.project,
          ),
          Quest(id: 'other', title: 'Call Ana', createdAt: _t),
        ],
        campaignLog: [
          BattleLogEntry(
            id: 'a1',
            day: '2026-10-02',
            attempt: 'Tried',
            createdAt: _t,
          ),
        ],
      );
      final json =
          jsonDecode(jsonEncode(data.toJson())) as Map<String, Object?>;
      json['schemaVersion'] = 1;
      for (final key in ['quests', 'campaignLog']) {
        for (final e in (json[key]! as List).cast<Map<String, Object?>>()) {
          e.remove('projectId');
        }
      }
      if (json['project'] != null) {
        (json['project']! as Map<String, Object?>).remove('id');
      }
      return json;
    }

    test('attempts and project quests are linked to the legacy id; '
        'finishing keeps them in its history', () async {
      final loaded = AppData.fromJson(v1());
      final id = legacyProjectId(DateTime.utc(2026, 10));
      expect(loaded.project!.id, id);
      expect(loaded.campaignLog.single.projectId, id);
      expect(loaded.quests.map((q) => q.projectId), [
        id,
        null,
      ], reason: 'only the project\'s own quests');
      // Loading twice gives the same links.
      expect(AppData.fromJson(v1()).campaignLog.single.projectId, id);

      final state = await _open(
        MemoryDataStore(loaded),
        MemoryAttachmentStore(clock: () => _t),
      );
      final archived = await state.archiveProject();
      expect(state.attemptsOfProject(archived!.id), hasLength(1));
      expect(state.questsOfProject(archived.id), hasLength(1));
    });

    test('no project in the file: nothing linked; schema 2 untouched', () {
      final none = AppData.fromJson(v1(project: false));
      expect(none.campaignLog.single.projectId, isNull);
      final current = v1()..['schemaVersion'] = 2;
      final two = AppData.fromJson(current);
      expect(two.campaignLog.single.projectId, isNull);
    });
  });
}
