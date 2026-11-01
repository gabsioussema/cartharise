/// Which check-in notifications to schedule (F-016, F-017). Pure Dart: no
/// plugins, no clock — easy to test, including quiet hours across midnight.
library;

import '../domain/app_data.dart';
import '../domain/local_date.dart';

/// One daily repeating local notification.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.promptId,
    required this.title,
  });

  /// Stable notification id (1000 + position of the check-in).
  final int id;
  final int hour;
  final int minute;

  /// The daytime prompt it invites the user to answer (tap payload).
  final String promptId;

  /// The prompt's short title — the only text shown. Never the user's words.
  final String title;

  @override
  bool operator ==(Object other) =>
      other is PlannedReminder &&
      other.id == id &&
      other.hour == hour &&
      other.minute == minute &&
      other.promptId == promptId &&
      other.title == title;

  @override
  int get hashCode => Object.hash(id, hour, minute, promptId, title);

  @override
  String toString() =>
      'PlannedReminder($id, ${formatClock(hour, minute)}, $promptId)';
}

/// Base for reminder notification ids.
const int kReminderIdBase = 1000;

/// True when local [hour]:[minute] falls inside the quiet range
/// [quietStart]–[quietEnd] (`HH:MM`, end exclusive). A range whose end is
/// before its start crosses midnight (e.g. 22:00–07:00). Missing or equal
/// bounds mean no quiet hours.
bool isInQuietHours(
  int hour,
  int minute,
  String? quietStart,
  String? quietEnd,
) {
  if (quietStart == null || quietEnd == null) return false;
  final (sh, sm) = parseClock(quietStart);
  final (eh, em) = parseClock(quietEnd);
  final start = sh * 60 + sm;
  final end = eh * 60 + em;
  final t = hour * 60 + minute;
  if (start == end) return false;
  return start < end ? t >= start && t < end : t >= start || t < end;
}

/// The reminders to schedule. Nothing when [enabled] is false; a disabled
/// preference or one inside quiet hours is skipped. [titles] maps prompt id →
/// prompt title (from the content library).
List<PlannedReminder> planReminders({
  required List<ReminderPreference> preferences,
  required Map<String, String> titles,
  required bool enabled,
  String? quietStart,
  String? quietEnd,
}) {
  if (!enabled) return const [];
  final plans = <PlannedReminder>[];
  for (var i = 0; i < preferences.length; i++) {
    final pref = preferences[i];
    if (!pref.enabled) continue;
    final (hour, minute) = parseClock(pref.time);
    if (isInQuietHours(hour, minute, quietStart, quietEnd)) continue;
    plans.add(
      PlannedReminder(
        id: kReminderIdBase + i,
        hour: hour,
        minute: minute,
        promptId: pref.promptId,
        title: titles[pref.promptId] ?? '',
      ),
    );
  }
  return plans;
}
