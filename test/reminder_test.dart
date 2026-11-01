import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/reminders/reminder_plan.dart';
import 'package:cartharise/reminders/reminder_scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

const _times = ['11:00', '13:30', '15:15', '17:00', '19:30', '21:00'];

List<ReminderPreference> _prefs({Set<int> disabled = const {}}) => [
  for (var i = 0; i < _times.length; i++)
    ReminderPreference(
      promptId: 'daytime.0${i + 1}',
      time: _times[i],
      enabled: !disabled.contains(i),
    ),
];

final _titles = {for (var i = 1; i <= 6; i++) 'daytime.0$i': 'Check-in $i'};

List<String> _planned({
  bool enabled = true,
  String? quietStart,
  String? quietEnd,
  Set<int> disabled = const {},
}) => [
  for (final r in planReminders(
    preferences: _prefs(disabled: disabled),
    titles: _titles,
    enabled: enabled,
    quietStart: quietStart,
    quietEnd: quietEnd,
  ))
    '${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}',
];

void main() {
  group('planReminders', () {
    test('all six when enabled, none when disabled', () {
      expect(_planned(), _times);
      expect(_planned(enabled: false), isEmpty);
    });

    test('ids are stable per position; title only, payload = prompt id', () {
      final plans = planReminders(
        preferences: _prefs(),
        titles: _titles,
        enabled: true,
      );
      expect(plans.map((p) => p.id), [1000, 1001, 1002, 1003, 1004, 1005]);
      expect(plans.first.title, 'Check-in 1');
      expect(plans.first.promptId, 'daytime.01');
    });

    test('a disabled check-in is skipped', () {
      expect(_planned(disabled: {1, 5}), ['11:00', '15:15', '17:00', '19:30']);
    });

    test('quiet hours inside one day (12:00–16:00)', () {
      expect(_planned(quietStart: '12:00', quietEnd: '16:00'), [
        '11:00',
        '17:00',
        '19:30',
        '21:00',
      ]);
    });

    test('quiet hours crossing midnight (19:00–08:00)', () {
      expect(_planned(quietStart: '19:00', quietEnd: '08:00'), [
        '11:00',
        '13:30',
        '15:15',
        '17:00',
      ]);
    });

    test('the end of quiet hours is exclusive, the start inclusive', () {
      expect(_planned(quietStart: '21:00', quietEnd: '11:00'), [
        '11:00',
        '13:30',
        '15:15',
        '17:00',
        '19:30',
      ]);
    });

    test('equal or missing bounds mean no quiet hours', () {
      expect(_planned(quietStart: '10:00', quietEnd: '10:00'), _times);
      expect(_planned(quietStart: '10:00'), _times);
    });
  });

  group('isInQuietHours', () {
    test('midnight-crossing range', () {
      expect(isInQuietHours(23, 30, '22:00', '07:00'), isTrue);
      expect(isInQuietHours(0, 0, '22:00', '07:00'), isTrue);
      expect(isInQuietHours(6, 59, '22:00', '07:00'), isTrue);
      expect(isInQuietHours(7, 0, '22:00', '07:00'), isFalse);
      expect(isInQuietHours(21, 59, '22:00', '07:00'), isFalse);
    });
  });

  group('next local occurrence (DST-safe)', () {
    setUpAll(tz_data.initializeTimeZones);

    test('later today, else tomorrow, at the same wall-clock time', () {
      final paris = tz.getLocation('Europe/Paris');
      final now = tz.TZDateTime(paris, 2026, 3, 28, 12, 0);
      final later = LocalReminderScheduler.nextInstance(13, 30, now);
      expect((later.day, later.hour, later.minute), (28, 13, 30));
      // 11:00 has passed: tomorrow 11:00, across the spring DST change.
      final tomorrow = LocalReminderScheduler.nextInstance(11, 0, now);
      expect((tomorrow.day, tomorrow.hour, tomorrow.minute), (29, 11, 0));
      expect(tomorrow.timeZoneOffset, const Duration(hours: 2));
    });

    test('month rollover', () {
      final utc = tz.UTC;
      final now = tz.TZDateTime(utc, 2026, 1, 31, 22, 0);
      final next = LocalReminderScheduler.nextInstance(11, 0, now);
      expect((next.month, next.day, next.hour), (2, 1, 11));
    });
  });
}
