/// Calendar-date helpers. Quests, reviews and the 30-day path are tied to the
/// user's *local* date, stored as `yyyy-MM-dd` so a timezone change never moves
/// a completion to another day.
library;

/// `yyyy-MM-dd` for the local calendar day of [time].
String dateKey(DateTime time) {
  final t = time.toLocal();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)}';
}

/// Parses a `yyyy-MM-dd` key into a local midnight [DateTime].
/// Throws [FormatException] for anything else.
DateTime parseDateKey(String key) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key);
  if (m == null) throw FormatException('Invalid date key', key);
  final d = DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
  if (dateKey(d) != key) throw FormatException('Invalid date key', key);
  return d;
}

/// Monday of the week containing [time], as a date key.
String weekStartKey(DateTime time) {
  final t = time.toLocal();
  final day = DateTime(t.year, t.month, t.day);
  return dateKey(day.subtract(Duration(days: day.weekday - DateTime.monday)));
}

/// `HH:MM` 24-hour local time → (hour, minute). Throws [FormatException].
(int, int) parseClock(String hhmm) {
  final m = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$').firstMatch(hhmm);
  if (m == null) throw FormatException('Invalid HH:MM time', hhmm);
  return (int.parse(m[1]!), int.parse(m[2]!));
}

/// (hour, minute) → `HH:MM`.
String formatClock(int hour, int minute) =>
    '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
