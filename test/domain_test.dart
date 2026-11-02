import 'dart:convert';

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/domain/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fully populated snapshot (every field and list non-default).
AppData fullData() {
  final t = DateTime.utc(2026, 11, 3, 9, 30);
  return AppData(
    profile: UserProfile(
      createdAt: t,
      displayName: 'Sam',
      pace: Pace.oneDay,
      onboardedAt: t,
      adultConfirmed: true,
    ),
    settings: const AppSettings(
      appearance: AppearanceMode.dark,
      theme: AppTheme.olive,
      motion: false,
      remindersEnabled: true,
      quietStart: '22:00',
      quietEnd: '07:00',
    ),
    journeys: [
      Journey(
        id: 'j1',
        startedAt: t,
        completedAt: t,
        activePromptId: 'evening.07',
        answers: {
          'morning.01': ReflectionAnswer(
            promptId: 'morning.01',
            body: '  Exactly as typed, "quotes", émojis 🌅 and\nnew lines  ',
            updatedAt: t,
          ),
          'morning.02': ReflectionAnswer(
            promptId: 'morning.02',
            skipped: true,
            updatedAt: t,
          ),
        },
      ),
      Journey(id: 'j2', startedAt: t),
    ],
    currentJourneyId: 'j2',
    compass: LifeCompass(
      antiVision: 'a',
      vision: 'v',
      yearGoal: 'y',
      monthProject: 'm',
      dailyLevers: '- walk\n- read',
      constraints: 'c',
      updatedAt: t,
    ),
    compassHistory: [
      CompassVersion(
        savedAt: t,
        compass: const LifeCompass(vision: 'old'),
        reason: CompassVersionReason.beforeImport,
      ),
    ],
    quests: [
      Quest(
        id: 'q1',
        title: 'Walk',
        createdAt: t,
        recurrence: QuestRecurrence.daily,
        dueDate: '2026-11-30',
        completedOn: const {'2026-11-02', '2026-11-03'},
        source: QuestSource.dailyLever,
        note: 'outside',
      ),
    ],
    project: MonthProject(
      title: 'Ship it',
      updatedAt: t,
      status: ProjectStatus.active,
      milestones: const [Milestone(id: 'm1', title: 'Draft', done: true)],
      retrospective: 'went well',
    ),
    journal: [
      JournalEntry(
        id: 'n1',
        body: 'note',
        createdAt: t,
        title: 'T',
        editedAt: t,
      ),
    ],
    reviews: [
      WeeklyReview(
        id: 'r1',
        weekStart: '2026-11-02',
        createdAt: t,
        wins: 'w',
        friction: 'f',
        nextExperiment: 'n',
        editedAt: t,
      ),
    ],
    pathAnswers: {3: PathAnswer(day: 3, body: 'day three', updatedAt: t)},
    reminders: const [
      ReminderPreference(promptId: 'daytime.01', time: '10:45', enabled: false),
    ],
    lessonsRead: const {'lesson.01', 'lesson.03'},
  );
}

Map<String, Object?> backupJson(AppData data) =>
    jsonDecode(encodeBackup(data, DateTime.utc(2026))) as Map<String, Object?>;

String withData(void Function(Map<String, Object?> data) change) {
  final root = backupJson(fullData());
  change(root['data']! as Map<String, Object?>);
  return jsonEncode(root);
}

void main() {
  group('JSON round trip', () {
    test('a fully populated AppData survives encode → decode unchanged', () {
      final data = fullData();
      final text = encodeBackup(data, DateTime.utc(2026, 11, 3));
      final back = decodeBackup(text);
      // Re-encoding the decoded data gives the identical document.
      expect(encodeBackup(back, DateTime.utc(2026, 11, 3)), text);
      expect(
        back.currentJourney!.answers.isEmpty,
        isTrue,
        reason: 'j2 is current and empty',
      );
      final first = back.journeys.first.answers['morning.01']!;
      expect(first.body, data.journeys.first.answers['morning.01']!.body);
      expect(back.quests.single.completedOn, {'2026-11-02', '2026-11-03'});
      expect(back.settings.theme, AppTheme.olive);
      for (final theme in AppTheme.values) {
        final s = AppSettings(theme: theme);
        expect(AppSettings.fromJson(s.toJson()).theme, theme);
      }
      expect(back.pathAnswers[3]!.body, 'day three');
      expect(back.lessonsRead, {'lesson.01', 'lesson.03'});
    });

    test('the empty snapshot round-trips', () {
      final back = decodeBackup(
        encodeBackup(AppData.empty, DateTime.utc(2026)),
      );
      expect(back.profile, isNull);
      expect(back.journeys, isEmpty);
      expect(back.compass.isEmpty, isTrue);
    });

    test('backup envelope is the documented format', () {
      final root = backupJson(AppData.empty);
      expect(root['app'], 'cartharise');
      expect(root['format'], 1);
      expect(DateTime.parse(root['exportedAt']! as String).isUtc, isTrue);
      expect((root['data']! as Map)['schemaVersion'], kSchemaVersion);
    });
  });

  group('decodeBackup rejects bad input without partial data', () {
    final cases = <String, String>{
      'not JSON': 'this is not json {',
      'empty': '',
      'JSON array': '[1, 2]',
      'wrong app': jsonEncode({'app': 'other', 'format': 1, 'data': {}}),
      'wrong format': jsonEncode({
        'app': 'cartharise',
        'format': 99,
        'data': backupJson(AppData.empty)['data'],
      }),
      'missing data': jsonEncode({'app': 'cartharise', 'format': 1}),
      'future schema': withData((d) => d['schemaVersion'] = 999),
      'bad ISO date': withData(
        (d) => (d['profile']! as Map)['createdAt'] = 'yesterday',
      ),
      'bad date key': withData(
        (d) => ((d['quests']! as List).first as Map)['completedOn'] = [
          '2026-13-40',
        ],
      ),
      'bad week start': withData(
        (d) =>
            ((d['reviews']! as List).first as Map)['weekStart'] = '02/11/2026',
      ),
      'unknown enum': withData(
        (d) => ((d['quests']! as List).first as Map)['recurrence'] = 'hourly',
      ),
      'unknown theme': withData(
        (d) => (d['settings']! as Map)['theme'] = 'neon',
      ),
      'bad clock': withData(
        (d) => ((d['reminders']! as List).first as Map)['time'] = '25:00',
      ),
      'dangling current journey': withData(
        (d) => d['currentJourneyId'] = 'nope',
      ),
      'path day out of range': withData(
        (d) => ((d['pathAnswers']! as List).first as Map)['day'] = 31,
      ),
      'wrong type': withData((d) => d['journal'] = 'not a list'),
    };
    for (final MapEntry(key: name, value: text) in cases.entries) {
      test(name, () {
        expect(() => decodeBackup(text), throwsFormatException);
      });
    }
  });

  group('date helpers', () {
    test('dateKey uses the local calendar day', () {
      expect(dateKey(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
      expect(dateKey(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('parseDateKey round-trips and rejects impossible dates', () {
      expect(parseDateKey('2026-02-28'), DateTime(2026, 2, 28));
      expect(() => parseDateKey('2026-02-30'), throwsFormatException);
      expect(() => parseDateKey('2026-2-3'), throwsFormatException);
      expect(() => parseDateKey(''), throwsFormatException);
    });

    test('weekStartKey is the Monday of the week', () {
      expect(weekStartKey(DateTime(2026, 11, 3)), '2026-11-02'); // Tuesday
      expect(weekStartKey(DateTime(2026, 11, 2)), '2026-11-02'); // Monday
      expect(weekStartKey(DateTime(2026, 11, 8)), '2026-11-02'); // Sunday
      expect(weekStartKey(DateTime(2027, 1, 1)), '2026-12-28'); // across years
    });

    test('clock parsing is strict 24-hour HH:MM', () {
      expect(parseClock('00:00'), (0, 0));
      expect(parseClock('23:59'), (23, 59));
      for (final bad in ['24:00', '7:00', '12:60', '12-30', '']) {
        expect(() => parseClock(bad), throwsFormatException, reason: bad);
      }
      expect(formatClock(9, 5), '09:05');
    });
  });

  group('content helpers', () {
    test('byPhase sorts by ordinal; corePrompts excludes bonus', () {
      const lib = ContentLibrary(
        languageCode: 'en',
        version: 1,
        lessons: [],
        prompts: [
          Prompt(
            id: 'morning.02',
            phase: PromptPhase.morning,
            ordinal: 2,
            group: PromptGroup.currentReality,
            title: 't',
            question: 'q',
            context: 'c',
            help: 'h',
            example: 'e',
            sourceReference: 's',
          ),
          Prompt(
            id: 'morning.01',
            phase: PromptPhase.morning,
            ordinal: 1,
            group: PromptGroup.currentReality,
            title: 't',
            question: 'q',
            context: 'c',
            help: 'h',
            example: 'e',
            sourceReference: 's',
          ),
          Prompt(
            id: 'bonus.01',
            phase: PromptPhase.bonus,
            ordinal: 1,
            group: PromptGroup.contemplation,
            title: 't',
            question: 'q',
            context: 'c',
            help: 'h',
            example: 'e',
            sourceReference: 's',
            core: false,
          ),
        ],
        thirtyDays: [],
        credit: SourceCredit(
          title: 't',
          author: 'a',
          articleUrl: 'u',
          newsletterUrl: 'n',
          publishedOn: 'p',
          independenceNotice: 'i',
          paraphraseNotice: 'p',
        ),
      );
      expect(lib.byPhase(PromptPhase.morning).map((p) => p.id), [
        'morning.01',
        'morning.02',
      ]);
      expect(lib.corePrompts.map((p) => p.id), isNot(contains('bonus.01')));
    });
  });
}
