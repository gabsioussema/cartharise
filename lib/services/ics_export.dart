/// A 30-day iCalendar file of the six daytime check-ins (F-018): the
/// offline alternative to notifications. Pure Dart. Events carry only the
/// prompt titles — never the user's answers.
///
/// Times are *floating* local times (no `Z`, no TZID), so the calendar shows
/// each check-in at the same wall-clock time wherever the user is, as the
/// source intends.
library;

import 'dart:convert';

/// One recurring check-in event.
class IcsCheckin {
  const IcsCheckin({
    required this.promptId,
    required this.title,
    required this.hour,
    required this.minute,
  });

  final String promptId;
  final String title;
  final int hour;
  final int minute;
}

const String kIcsMimeType = 'text/calendar';
const String kIcsFileName = 'cartharise-checkins.ics';

/// Builds the calendar. The first occurrence of every event is on the day
/// after [now] (local), repeating daily [days] times, each lasting 10 minutes.
String buildCheckinCalendar({
  required List<IcsCheckin> checkins,
  required DateTime now,
  int days = 30,
  String calendarName = 'Cartharise check-ins',
  String summaryPrefix = 'Cartharise check-in: ',
  String description =
      'A short daytime pause from your Cartharise reset. Open the app when it '
      'suits you; every check-in is optional.',
}) {
  final local = now.toLocal();
  final first = DateTime(local.year, local.month, local.day + 1);
  final stamp = _utcStamp(now);
  final lines = <String>[
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Cartharise//Check-ins 1.0//EN',
    'CALSCALE:GREGORIAN',
    'METHOD:PUBLISH',
    'X-WR-CALNAME:${escapeIcsText(calendarName)}',
  ];
  for (final c in checkins) {
    final start = DateTime(
      first.year,
      first.month,
      first.day,
      c.hour,
      c.minute,
    );
    lines.addAll([
      'BEGIN:VEVENT',
      'UID:${_uid(c.promptId)}',
      'DTSTAMP:$stamp',
      'DTSTART:${_floating(start)}',
      'DURATION:PT10M',
      'RRULE:FREQ=DAILY;COUNT=$days',
      'SUMMARY:${escapeIcsText('$summaryPrefix${c.title}')}',
      'DESCRIPTION:${escapeIcsText(description)}',
      'TRANSP:TRANSPARENT',
      'END:VEVENT',
    ]);
  }
  lines.add('END:VCALENDAR');
  return '${lines.map(foldIcsLine).join('\r\n')}\r\n';
}

/// Stable per prompt, so re-importing updates instead of duplicating.
String _uid(String promptId) =>
    'cartharise-${promptId.replaceAll(RegExp(r'[^A-Za-z0-9.-]'), '-')}@cartharise.app';

String _two(int v) => v.toString().padLeft(2, '0');

String _floating(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}${_two(t.month)}${_two(t.day)}'
    'T${_two(t.hour)}${_two(t.minute)}00';

String _utcStamp(DateTime t) {
  final u = t.toUtc();
  return '${u.year.toString().padLeft(4, '0')}${_two(u.month)}${_two(u.day)}'
      'T${_two(u.hour)}${_two(u.minute)}${_two(u.second)}Z';
}

/// RFC 5545 TEXT escaping: backslash, semicolon, comma and newlines.
String escapeIcsText(String text) => text
    .replaceAll(r'\', r'\\')
    .replaceAll(';', r'\;')
    .replaceAll(',', r'\,')
    .replaceAll('\r\n', r'\n')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', r'\n');

/// Folds a content line at 75 octets (UTF-8), continuing with CRLF + space,
/// never splitting a multi-byte character.
String foldIcsLine(String line) {
  if (utf8.encode(line).length <= 75) return line;
  final out = StringBuffer();
  var used = 0;
  var limit = 75;
  for (final rune in line.runes) {
    final char = String.fromCharCode(rune);
    final size = utf8.encode(char).length;
    if (used + size > limit) {
      out.write('\r\n ');
      used = 1; // the leading space counts toward the next line
      limit = 75;
    }
    out.write(char);
    used += size;
  }
  return out.toString();
}
