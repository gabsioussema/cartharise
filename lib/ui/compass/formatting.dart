import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/local_date.dart';

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toLanguageTag();

/// "Tue, Nov 3" — a local calendar day, in the user's locale.
String formatDay(BuildContext context, DateTime day) =>
    DateFormat.MMMEd(_locale(context)).format(day);

/// [formatDay] for a `yyyy-MM-dd` key.
String formatDayKey(BuildContext context, String key) =>
    formatDay(context, parseDateKey(key));

/// "Nov 3, 2026, 9:30 AM" (or 09:30 with the device's 24-hour setting).
String formatDateTime(BuildContext context, DateTime time) {
  final local = time.toLocal();
  final date = DateFormat.yMMMd(_locale(context)).format(local);
  final clock = MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );
  return '$date, $clock';
}
