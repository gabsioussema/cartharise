import 'dart:convert';

import 'package:cartharise/l10n/app_localizations_en.dart';
import 'package:cartharise/services/ics_export.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/you/reminders_screen.dart' show calendarTexts;
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_content.dart';
import 'support/fakes.dart';

import 'package:cartharise/data/data_store.dart';

const _checkins = [
  IcsCheckin(promptId: 'daytime.01', title: 'Avoidance', hour: 11, minute: 0),
  IcsCheckin(promptId: 'daytime.02', title: 'Priorities', hour: 13, minute: 30),
  IcsCheckin(promptId: 'daytime.03', title: 'Direction', hour: 15, minute: 15),
  IcsCheckin(promptId: 'daytime.04', title: 'Neglected', hour: 17, minute: 0),
  IcsCheckin(promptId: 'daytime.05', title: 'Identity', hour: 19, minute: 30),
  IcsCheckin(promptId: 'daytime.06', title: 'Energy', hour: 21, minute: 0),
];

/// The English calendar wording, exactly as the app builds it from ARB.
final _texts = calendarTexts(AppLocalizationsEn());

/// Unfolds RFC 5545 content lines.
List<String> _unfold(String ics) =>
    ics.replaceAll('\r\n ', '').split('\r\n')..removeLast();

void main() {
  final now = DateTime(2026, 11, 3, 9, 30);
  final ics = buildCheckinCalendar(
    checkins: _checkins,
    now: now,
    texts: _texts,
  );
  final lines = _unfold(ics);

  test('a calendar with six daily events × 30, starting tomorrow', () {
    expect(lines.first, 'BEGIN:VCALENDAR');
    expect(lines.last, 'END:VCALENDAR');
    expect(lines, contains('VERSION:2.0'));
    expect(lines.where((l) => l == 'BEGIN:VEVENT'), hasLength(6));
    expect(lines.where((l) => l == 'END:VEVENT'), hasLength(6));
    expect(lines.where((l) => l == 'RRULE:FREQ=DAILY;COUNT=30'), hasLength(6));
    expect(lines.where((l) => l == 'DURATION:PT10M'), hasLength(6));
    final starts = [
      for (final l in lines)
        if (l.startsWith('DTSTART')) l,
    ];
    expect(starts, [
      'DTSTART:20261104T110000',
      'DTSTART:20261104T133000',
      'DTSTART:20261104T151500',
      'DTSTART:20261104T170000',
      'DTSTART:20261104T193000',
      'DTSTART:20261104T210000',
    ], reason: 'floating local time (no Z, no TZID) on the next day');
  });

  test('UIDs are stable per prompt and unique', () {
    final uids = [
      for (final l in lines)
        if (l.startsWith('UID:')) l,
    ];
    expect(uids.toSet(), hasLength(6));
    expect(uids.first, 'UID:cartharise-daytime.01@cartharise.app');
    final again = _unfold(
      buildCheckinCalendar(
        checkins: _checkins,
        now: now.add(const Duration(days: 9)),
        texts: _texts,
      ),
    );
    expect([
      for (final l in again)
        if (l.startsWith('UID:')) l,
    ], uids);
  });

  test('summary names the check-in', () {
    expect(lines, contains('SUMMARY:Cartharise check-in: Avoidance'));
  });

  test('calendar name and notes come from the localized texts', () {
    expect(lines, contains('X-WR-CALNAME:Cartharise check-ins'));
    final custom = _unfold(
      buildCheckinCalendar(
        checkins: _checkins.take(1).toList(),
        now: now,
        texts: CalendarTexts(
          calendarName: 'Mes pauses',
          eventTitle: (t) => 'Pause : $t',
          description: 'Facultatif.',
        ),
      ),
    );
    expect(custom, contains('X-WR-CALNAME:Mes pauses'));
    expect(custom, contains('SUMMARY:Pause : Avoidance'));
    expect(custom, contains('DESCRIPTION:Facultatif.'));
    expect(custom.join('\n'), isNot(contains('Cartharise check-in')));
  });

  test('CRLF line endings only, every physical line ≤ 75 octets', () {
    expect(ics.endsWith('\r\n'), isTrue);
    expect(ics.replaceAll('\r\n', '').contains('\n'), isFalse);
    expect(ics.replaceAll('\r\n', '').contains('\r'), isFalse);
    for (final physical in ics.split('\r\n')) {
      expect(
        utf8.encode(physical).length,
        lessThanOrEqualTo(75),
        reason: physical,
      );
    }
  });

  test('long lines fold without splitting multi-byte characters', () {
    final long = 'SUMMARY:${'é' * 60}🌅${'a' * 40}';
    final folded = foldIcsLine(long);
    expect(folded.replaceAll('\r\n ', ''), long);
    for (final part in folded.split('\r\n')) {
      expect(utf8.encode(part).length, lessThanOrEqualTo(75));
      utf8.decode(utf8.encode(part)); // each part is valid UTF-8
    }
  });

  test('text is escaped', () {
    expect(
      escapeIcsText(
        r'a\b;c,d'
        '\nе',
      ),
      r'a\\b\;c\,d\nе',
    );
    final odd = buildCheckinCalendar(
      checkins: const [
        IcsCheckin(
          promptId: 'x',
          title: 'Pause; breathe, look\\around',
          hour: 9,
          minute: 0,
        ),
      ],
      now: now,
      texts: _texts,
    );
    expect(
      _unfold(odd),
      contains(r'SUMMARY:Cartharise check-in: Pause\; breathe\, look\\around'),
    );
  });

  test(
    'the app export contains prompt titles only — never the user text',
    () async {
      final state = AppState(
        store: MemoryDataStore(),
        content: fakeContent,
        reminders: FakeReminderScheduler(),
        clock: () => now,
      );
      await state.load();
      await state.saveAnswer('daytime.01', 'SECRET-ANSWER private words');
      await state.addJournalEntry(body: 'SECRET-JOURNAL');
      final export = state.calendarExport(_texts);
      expect(export, isNot(contains('SECRET')));
      expect(
        _unfold(export),
        contains('SUMMARY:Cartharise check-in: Daytime 1 title'),
      );
      expect('BEGIN:VEVENT'.allMatches(export), hasLength(6));
    },
  );
}
