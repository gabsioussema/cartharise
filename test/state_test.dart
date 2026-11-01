import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/l10n/app_localizations.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_content.dart';
import 'support/fakes.dart';

class Rig {
  Rig({AppData? data, DateTime? now})
    : store = MemoryDataStore(data),
      reminders = FakeReminderScheduler() {
    clock = now ?? DateTime(2026, 11, 3, 9, 30);
    state = AppState(
      store: store,
      content: fakeContent,
      reminders: reminders,
      clock: () => clock,
    );
  }

  final MemoryDataStore store;
  final FakeReminderScheduler reminders;
  late DateTime clock;
  late final AppState state;

  Future<AppState> loaded() async {
    await state.load();
    return state;
  }
}

Future<AppState> loadedState({AppData? data}) => Rig(data: data).loaded();

final _calendarTexts = CalendarTexts(
  calendarName: 'Check-ins',
  eventTitle: (title) => 'Check-in: $title',
  description: 'Optional.',
);

void main() {
  group('loading & storage', () {
    test(
      'first launch: empty data, onboarding needed, nothing written',
      () async {
        final rig = Rig();
        await rig.state.load();
        expect(rig.state.loaded, isTrue);
        expect(rig.state.loadError, isNull);
        expect(rig.state.needsOnboarding, isTrue);
        expect(rig.state.saveStatus, SaveStatus.idle);
        expect(rig.store.writes, 0);
      },
    );

    test('unreadable file → honest loadError, never overwritten', () async {
      final rig = Rig()..store.raw = '{"app": "cartharise", "format": 1, "da';
      await rig.state.load();
      expect(rig.state.loaded, isFalse);
      expect(rig.state.loadError, isA<StorageReadException>());
      expect(
        () => rig.state.mutate((d) => d),
        throwsStateError,
        reason: 'no write may replace the unreadable file',
      );
      expect(rig.store.raw, startsWith('{"app": "cartharise"'));
      expect(rig.store.writes, 0);
    });

    test('try again after the storage recovers', () async {
      final rig = Rig(data: AppData.empty)..store.failReads = true;
      await rig.state.load();
      expect(rig.state.loadError, isNotNull);
      rig.store.failReads = false;
      await rig.state.load();
      expect(rig.state.loaded, isTrue);
      expect(rig.state.loadError, isNull);
    });

    test('start fresh sets the unreadable file aside, not deleted', () async {
      final rig = Rig()..store.raw = 'garbage';
      await rig.state.load();
      await rig.state.startFreshAfterLoadError();
      expect(rig.state.loaded, isTrue);
      expect(rig.store.asideRaw, 'garbage');
      expect(rig.state.data.profile, isNull);
    });

    test(
      'save failure → failed, data kept in memory, retrySave → saved',
      () async {
        final rig = Rig();
        final state = await rig.loaded();
        rig.store.failWrites = true;
        await state.saveAnswer('morning.01', 'my words');
        expect(state.saveStatus, SaveStatus.failed);
        expect(state.saveError, isA<StorageWriteException>());
        expect(state.answer('morning.01')!.body, 'my words');
        expect(rig.store.raw, isNull);
        rig.store.failWrites = false;
        await state.retrySave();
        expect(state.saveStatus, SaveStatus.saved);
        expect(
          rig.store.saved!.currentJourney!.answers['morning.01']!.body,
          'my words',
        );
      },
    );

    test('every mutation goes saving → saved and persists', () async {
      final rig = Rig();
      final state = await rig.loaded();
      final seen = <SaveStatus>[];
      state.addListener(() => seen.add(state.saveStatus));
      await state.markLessonRead('lesson.01');
      expect(seen, containsAllInOrder([SaveStatus.saving, SaveStatus.saved]));
      expect(rig.store.saved!.lessonsRead, {'lesson.01'});
    });

    test('storage description is honest (and localized)', () {
      // Shown on onboarding and in You › Your data (StorageTransparencyText).
      final text = lookupAppLocalizations(const Locale('en'))
          .storageTransparency;
      expect(text, contains('Only on this phone'));
      expect(text, contains('not encrypted by Cartharise'));
      expect(text, contains('Not synced'));
      expect(text, contains('not in phone or cloud backups'));
      expect(text, contains('erases it'));
    });
  });

  group('onboarding & profile', () {
    test(
      'completeOnboarding creates the profile; resetOnboarding replays',
      () async {
        final state = await loadedState();
        await state.completeOnboarding(
          displayName: '  Sam  ',
          pace: Pace.oneDay,
          adultConfirmed: true,
        );
        expect(state.needsOnboarding, isFalse);
        expect(state.data.profile!.displayName, 'Sam');
        expect(state.data.profile!.pace, Pace.oneDay);
        expect(state.data.profile!.adultConfirmed, isTrue);
        await state.resetOnboarding();
        expect(state.needsOnboarding, isTrue);
        expect(
          state.data.profile!.displayName,
          'Sam',
          reason: 'nothing else changes',
        );
      },
    );

    test(
      'an empty name is no name; updateProfile changes only what is given',
      () async {
        final state = await loadedState();
        await state.completeOnboarding(
          displayName: '   ',
          pace: Pace.flexible,
          adultConfirmed: true,
        );
        expect(state.data.profile!.displayName, isNull);
        await state.updateProfile(displayName: () => 'Ana');
        expect(state.data.profile!.displayName, 'Ana');
        expect(state.data.profile!.pace, Pace.flexible);
        await state.updateProfile(pace: Pace.oneDay);
        expect(state.data.profile!.displayName, 'Ana');
        await state.updateProfile(displayName: () => null);
        expect(state.data.profile!.displayName, isNull);
      },
    );
  });

  group('reset', () {
    test(
      'answers are saved exactly as typed; journey created lazily',
      () async {
        final rig = Rig();
        final state = await rig.loaded();
        expect(state.data.journeys, isEmpty);
        expect(state.journey.answers, isEmpty);
        const text =
            '  Leading spaces, "quotes", <b>tags</b> & émoji 🌅\n\nline two  ';
        await state.saveAnswer('morning.01', text);
        expect(state.data.journeys, hasLength(1));
        expect(state.answer('morning.01')!.body, text);
        final reloaded = Rig(data: rig.store.saved);
        await reloaded.state.load();
        expect(reloaded.state.answer('morning.01')!.body, text);
      },
    );

    test('skip keeps any words; answering clears skipped', () async {
      final state = await loadedState();
      await state.saveAnswer('morning.02', 'draft');
      await state.skipPrompt('morning.02');
      expect(state.answer('morning.02')!.skipped, isTrue);
      expect(state.answer('morning.02')!.body, 'draft');
      await state.saveAnswer('morning.02', 'draft, finished');
      expect(state.answer('morning.02')!.skipped, isFalse);
    });

    test('progress per phase and core progress (bonus excluded)', () async {
      final state = await loadedState();
      await state.saveAnswer('morning.01', 'a');
      await state.saveAnswer(
        'morning.02',
        '   ',
      ); // whitespace is not an answer
      await state.skipPrompt('morning.03');
      await state.saveAnswer('bonus.01', 'optional');
      expect(
        state.progressFor(PromptPhase.morning),
        const PhaseProgress(answered: 1, skipped: 1, total: 14),
      );
      expect(state.progressFor(PromptPhase.bonus).answered, 1);
      expect(state.coreProgress, closeTo(1 / 27, 1e-9));
    });

    test(
      'nextPrompt resumes at the active prompt, then the next open one',
      () async {
        final state = await loadedState();
        expect(state.nextPrompt!.id, 'morning.01');
        await state.setActivePrompt('morning.05');
        expect(state.nextPrompt!.id, 'morning.05');
        await state.saveAnswer('morning.05', 'done');
        expect(state.nextPrompt!.id, 'morning.06');
        await state.setActivePrompt('evening.07');
        await state.saveAnswer('evening.07', 'x');
        expect(state.nextPrompt!.id, 'morning.01', reason: 'wraps around');
      },
    );

    test(
      'skipping everything: nextPrompt is null, user can still navigate',
      () async {
        final state = await loadedState();
        for (final p in fakeContent.corePrompts) {
          await state.skipPrompt(p.id);
        }
        expect(state.nextPrompt, isNull);
        expect(state.coreProgress, 0);
        expect(state.progressFor(PromptPhase.evening).finished, isTrue);
      },
    );

    test('startNewJourney keeps past journeys (read-only history)', () async {
      final rig = Rig();
      final state = await rig.loaded();
      await state.saveAnswer('morning.01', 'first reset');
      await state.completeJourney();
      final firstId = state.journey.id;
      rig.clock = rig.clock.add(const Duration(days: 7));
      await state.startNewJourney();
      expect(state.journey.id, isNot(firstId));
      expect(state.journey.answers, isEmpty);
      expect(state.pastJourneys.single.id, firstId);
      expect(
        state.pastJourneys.single.answers['morning.01']!.body,
        'first reset',
      );
      // An untouched current reset is replaced, not archived.
      await state.startNewJourney();
      expect(state.pastJourneys, hasLength(1));
      expect(state.data.journeys, hasLength(2));
    });
  });

  group('compass', () {
    Future<AppState> withEvening() async {
      final state = await loadedState();
      await state.saveAnswer('evening.01', 'insight, not mapped');
      await state.saveAnswer('evening.03', 'Anti-vision sentence');
      await state.saveAnswer('evening.04', 'Vision sentence');
      await state.saveAnswer('evening.05', '   '); // blank: not offered
      await state.saveAnswer('evening.06', 'Month project');
      await state.saveAnswer('evening.07', '- walk\n- read');
      return state;
    }

    test('preview offers only non-empty mapped evening answers', () async {
      final state = await withEvening();
      expect(state.compassImportPreview, {
        CompassField.antiVision: 'Anti-vision sentence',
        CompassField.vision: 'Vision sentence',
        CompassField.monthProject: 'Month project',
        CompassField.dailyLevers: '- walk\n- read',
      });
      expect(
        state.compassImportPreview.containsKey(CompassField.constraints),
        isFalse,
      );
    });

    test('import snapshots first, fills only selected EMPTY fields', () async {
      final state = await withEvening();
      await state.updateCompassField(CompassField.vision, 'My own vision');
      expect(
        state.compassImportPreview.containsKey(CompassField.vision),
        isFalse,
      );
      final count = await state.importCompassFromEvening({
        CompassField.antiVision,
        CompassField.vision, // non-empty: must not be overwritten
        CompassField.constraints, // never mapped
      });
      expect(count, 1);
      expect(state.compass.antiVision, 'Anti-vision sentence');
      expect(state.compass.vision, 'My own vision');
      expect(state.compass.monthProject, isEmpty, reason: 'not selected');
      expect(state.compass.constraints, isEmpty);
      final snapshot = state.data.compassHistory.first;
      expect(snapshot.reason, CompassVersionReason.beforeImport);
      expect(snapshot.compass.vision, 'My own vision');
      expect(snapshot.compass.antiVision, isEmpty);
    });

    test('later import never overwrites custom edits', () async {
      final state = await withEvening();
      await state.importCompassFromEvening(
        state.compassImportPreview.keys.toSet(),
      );
      await state.updateCompassField(CompassField.antiVision, 'Edited by me');
      await state.saveAnswer('evening.03', 'A newer evening answer');
      expect(state.compassImportPreview, isEmpty);
      expect(
        await state.importCompassFromEvening({CompassField.antiVision}),
        0,
      );
      expect(state.compass.antiVision, 'Edited by me');
    });

    test(
      'versions: newest first, capped at 50; restore snapshots current',
      () async {
        final state = await loadedState();
        for (var i = 0; i < 55; i++) {
          await state.updateCompassField(CompassField.vision, 'v$i');
          await state.saveCompassVersion();
        }
        expect(state.data.compassHistory, hasLength(kCompassHistoryLimit));
        expect(state.data.compassHistory.first.compass.vision, 'v54');
        final old = state.data.compassHistory.last;
        expect(old.compass.vision, 'v5');
        await state.restoreCompassVersion(old);
        expect(state.compass.vision, 'v5');
        expect(
          state.data.compassHistory.first.reason,
          CompassVersionReason.beforeRestore,
        );
        expect(state.data.compassHistory.first.compass.vision, 'v54');
      },
    );
  });

  group('missions', () {
    test('quests are done per local date; one-offs vs dailies', () async {
      final rig = Rig();
      final state = await rig.loaded();
      final once = await state.addQuest('  Call Ana  ');
      final daily = await state.addQuest(
        'Walk',
        recurrence: QuestRecurrence.daily,
      );
      expect(once.title, 'Call Ana');
      await state.setQuestDone(once.id, true);
      await state.setQuestDone(daily.id, true);
      final today = state.today;
      expect(today, '2026-11-03');
      expect(state.questById(once.id)!.isDoneOn(today), isTrue);
      expect(state.questById(daily.id)!.isDoneOn(today), isTrue);
      expect(state.questsFor(today), hasLength(2));
      // Next day: the daily is open again, the finished one-off is gone.
      rig.clock = DateTime(2026, 11, 4, 8);
      final tomorrow = state.today;
      expect(state.questById(daily.id)!.isDoneOn(tomorrow), isFalse);
      expect(state.questsFor(tomorrow).map((q) => q.id), [daily.id]);
      // Reopen and delete.
      await state.setQuestDone(once.id, false, day: today);
      expect(state.questById(once.id)!.completedOn, isEmpty);
      await state.deleteQuest(once.id);
      expect(state.questById(once.id), isNull);
      expect(() => state.addQuest('   '), throwsArgumentError);
    });

    test(
      'lever drafts: ≤3, bullets stripped, no duplicates of quests',
      () async {
        final state = await loadedState();
        await state.updateCompassField(
          CompassField.dailyLevers,
          '- Walk 20 minutes\n'
          '* Read 10 pages\n'
          '\n'
          '• walk 20 MINUTES\n'
          '1. Write one page\n'
          '2) Call a friend\n'
          'Plan tomorrow',
        );
        expect(state.leverDrafts, [
          'Walk 20 minutes',
          'Read 10 pages',
          'Write one page',
        ]);
        await state.addQuest('read 10 pages');
        expect(state.leverDrafts, [
          'Walk 20 minutes',
          'Write one page',
          'Call a friend',
        ]);
      },
    );

    test(
      'addQuestsFromLevers adds daily lever quests, skipping duplicates',
      () async {
        final state = await loadedState();
        await state.addQuest('Walk');
        final added = await state.addQuestsFromLevers([
          'walk',
          ' Read ',
          '',
          'Read',
        ]);
        expect(added, 1);
        final read = state.data.quests.last;
        expect(read.title, 'Read');
        expect(read.recurrence, QuestRecurrence.daily);
        expect(read.source, QuestSource.dailyLever);
      },
    );

    test('project and path answers', () async {
      final state = await loadedState();
      await state.saveProject(
        MonthProject(title: 'Ship', updatedAt: state.now()),
      );
      expect(state.data.project!.title, 'Ship');
      await state.saveProject(null);
      expect(state.data.project, isNull);
      await state.savePathAnswer(30, ' kept as typed ');
      expect(state.data.pathAnswers[30]!.body, ' kept as typed ');
      expect(() => state.savePathAnswer(0, 'x'), throwsRangeError);
      expect(() => state.savePathAnswer(31, 'x'), throwsRangeError);
    });
  });

  group('journal & reviews', () {
    test('notes newest first; edit keeps createdAt; delete', () async {
      final rig = Rig();
      final state = await rig.loaded();
      final a = await state.addJournalEntry(body: 'first');
      rig.clock = rig.clock.add(const Duration(hours: 1));
      final b = await state.addJournalEntry(title: 'T', body: 'second');
      expect(state.data.journal.map((e) => e.id), [b.id, a.id]);
      rig.clock = rig.clock.add(const Duration(hours: 1));
      await state.updateJournalEntry(
        JournalEntry(
          id: a.id,
          body: 'first, edited',
          createdAt: DateTime(2000),
        ),
      );
      final edited = state.data.journal.last;
      expect(edited.body, 'first, edited');
      expect(edited.createdAt, a.createdAt);
      expect(edited.editedAt, rig.clock);
      await state.deleteJournalEntry(b.id);
      expect(state.data.journal.map((e) => e.id), [a.id]);
    });

    test('weekly reviews: create, edit, newest week first, delete', () async {
      final state = await loadedState();
      final older = await state.saveReview(
        weekStart: '2026-10-26',
        wins: 'w',
        friction: 'f',
        nextExperiment: 'n',
      );
      final newer = await state.saveReview(
        weekStart: '2026-11-02',
        wins: 'w2',
        friction: '',
        nextExperiment: '',
      );
      expect(state.data.reviews.map((r) => r.id), [newer.id, older.id]);
      final edited = await state.saveReview(
        id: older.id,
        weekStart: '2026-10-26',
        wins: 'better',
        friction: 'f',
        nextExperiment: 'n',
      );
      expect(edited.id, older.id);
      expect(edited.createdAt, older.createdAt);
      expect(edited.editedAt, isNotNull);
      expect(state.data.reviews, hasLength(2));
      await state.deleteReview(newer.id);
      expect(state.data.reviews.single.wins, 'better');
      expect(
        () => state.saveReview(
          weekStart: 'bad',
          wins: '',
          friction: '',
          nextExperiment: '',
        ),
        throwsFormatException,
      );
    });
  });

  group('reminders', () {
    test('six preferences default to the source times', () async {
      final state = await loadedState();
      expect(state.reminders.map((r) => r.time), kFakeDaytimeTimes);
      expect(state.reminders.every((r) => r.enabled), isTrue);
    });

    test(
      'enable: granted → scheduled; denied → stays off, never claimed',
      () async {
        final rig = Rig();
        final state = await rig.loaded();
        rig.reminders.permission = ReminderPermission.denied;
        expect(await state.enableReminders(), ReminderPermission.denied);
        expect(state.settings.remindersEnabled, isFalse);
        expect(rig.reminders.scheduled, isEmpty);
        rig.reminders.permission = ReminderPermission.granted;
        expect(await state.enableReminders(), ReminderPermission.granted);
        expect(state.settings.remindersEnabled, isTrue);
        expect(rig.reminders.scheduled, hasLength(6));
        expect(rig.reminders.scheduled.first.title, 'Daytime 1 title');
        expect(rig.reminders.scheduled.first.promptId, 'daytime.01');
      },
    );

    test('editing a time, quiet hours and disabling re-plan', () async {
      final rig = Rig();
      final state = await rig.loaded();
      await state.enableReminders();
      await state.setReminder(
        const ReminderPreference(promptId: 'daytime.01', time: '10:15'),
      );
      expect(rig.reminders.scheduled.first.hour, 10);
      expect(rig.reminders.scheduled.first.minute, 15);
      await state.updateSettings(
        state.settings.copyWith(
          quietStart: () => '19:00',
          quietEnd: () => '08:00',
        ),
      );
      expect(rig.reminders.scheduled.map((r) => r.promptId), [
        'daytime.01',
        'daytime.02',
        'daytime.03',
        'daytime.04',
      ]);
      await state.disableReminders();
      expect(rig.reminders.scheduled, isEmpty);
      expect(state.settings.remindersEnabled, isFalse);
      expect(
        () => state.setReminder(
          const ReminderPreference(promptId: 'daytime.02', time: '7:5'),
        ),
        throwsFormatException,
      );
    });

    test('a scheduling failure is recorded, not thrown', () async {
      final rig = Rig();
      final state = await rig.loaded();
      rig.reminders.failSchedule = true;
      expect(await state.enableReminders(), ReminderPermission.granted);
      expect(state.reminderError, isNotNull);
    });

    test(
      'loading with reminders on re-plans (time zone may have changed)',
      () async {
        final rig = Rig(
          data: const AppData(settings: AppSettings(remindersEnabled: true)),
        );
        await rig.state.load();
        expect(rig.reminders.scheduled, hasLength(6));
      },
    );

    test('calendar export: the six enabled check-ins', () async {
      final state = await loadedState();
      await state.setReminder(
        const ReminderPreference(
          promptId: 'daytime.06',
          time: '21:00',
          enabled: false,
        ),
      );
      final ics = state.calendarExport(_calendarTexts);
      expect('BEGIN:VEVENT'.allMatches(ics), hasLength(5));
      await state.setReminder(
        const ReminderPreference(promptId: 'daytime.06', time: '21:00'),
      );
      expect(
        'BEGIN:VEVENT'.allMatches(state.calendarExport(_calendarTexts)),
        hasLength(6),
      );
    });
  });

  group('backup, import & delete', () {
    test('export → delete all → import restores everything', () async {
      final rig = Rig();
      final state = await rig.loaded();
      await state.completeOnboarding(pace: Pace.flexible, adultConfirmed: true);
      await state.saveAnswer('morning.01', 'keep me');
      await state.addJournalEntry(body: 'note');
      final backup = state.exportBackup();
      await state.deleteAllData();
      expect(state.needsOnboarding, isTrue);
      expect(state.data.journal, isEmpty);
      expect(rig.store.raw, isNull);
      await state.importBackup(backup);
      expect(state.answer('morning.01')!.body, 'keep me');
      expect(state.data.journal.single.body, 'note');
      expect(state.needsOnboarding, isFalse);
      expect(rig.store.saved!.journal.single.body, 'note');
    });

    test('a malformed import is rejected and data is unchanged', () async {
      final rig = Rig();
      final state = await rig.loaded();
      await state.saveAnswer('morning.01', 'precious');
      final before = encodeBackup(state.data, DateTime.utc(2026));
      final writes = rig.store.writes;
      for (final bad in ['{', '[]', '{"app":"other","format":1,"data":{}}']) {
        await expectLater(state.importBackup(bad), throwsFormatException);
      }
      expect(encodeBackup(state.data, DateTime.utc(2026)), before);
      expect(rig.store.writes, writes);
    });

    test('import keeps this device notification consent', () async {
      final rig = Rig();
      final state = await rig.loaded();
      const other = AppData(settings: AppSettings(remindersEnabled: true));
      await state.importBackup(encodeBackup(other, DateTime.utc(2026)));
      expect(state.settings.remindersEnabled, isFalse);
      expect(rig.reminders.scheduled, isEmpty);
    });

    test('deleteAllData cancels reminders and clears the file', () async {
      final rig = Rig();
      final state = await rig.loaded();
      await state.enableReminders();
      expect(rig.reminders.scheduled, isNotEmpty);
      final cancels = rig.reminders.cancelCount;
      await state.deleteAllData();
      expect(rig.reminders.cancelCount, greaterThan(cancels));
      expect(rig.reminders.scheduled, isEmpty);
      expect(rig.store.raw, isNull);
      expect(state.saveStatus, SaveStatus.idle);
      expect(state.data.settings.remindersEnabled, isFalse);
    });

    test('a failed delete is reported and leaves data as it was', () async {
      final rig = Rig();
      final state = await rig.loaded();
      await state.addJournalEntry(body: 'still here');
      rig.store.failWrites = true;
      await expectLater(
        state.deleteAllData(),
        throwsA(isA<StorageWriteException>()),
      );
      expect(state.data.journal.single.body, 'still here');
    });
  });
}
