import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../ui/theme/cartha_theme.dart';
import 'reminder_plan.dart';

/// Result of asking the OS for notification permission. Never claim success
/// on [denied] or [unavailable] (F-017): offer the `.ics` export instead.
enum ReminderPermission { granted, denied, unavailable }

/// Delivers planned check-ins as local notifications. Nothing leaves the phone.
abstract class ReminderScheduler {
  /// Asks the user to allow notifications (Android 13+, iOS).
  Future<ReminderPermission> requestPermission();

  /// Replaces every scheduled check-in with [plans] (daily, local time).
  Future<void> schedule(List<PlannedReminder> plans);

  Future<void> cancelAll();

  /// Prompt ids of tapped notifications while the app runs.
  Stream<String> get taps;

  /// Prompt id of the notification that launched the app, once.
  Future<String?> takeLaunchPayload();

  /// The notification channel's name and description as shown in the
  /// system settings (Android), in the user's language. Set by the UI.
  void setChannelText({required String name, required String description});
}

bool _timeZoneReady = false;

/// Loads the time-zone database and sets the device's zone, so reminders fire
/// at local wall-clock time (and follow DST). Safe to call more than once.
Future<void> initTimeZone() async {
  if (!_timeZoneReady) {
    tz_data.initializeTimeZones();
    _timeZoneReady = true;
  }
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
  } on Object {
    // Unknown zone name or no platform: keep UTC. Times are re-planned on the
    // next launch, so a later fix of the zone database still applies.
  }
}

/// `flutter_local_notifications` on Android and iOS. Uses inexact daily
/// alarms: a few minutes of drift is fine for a gentle check-in and needs no
/// exact-alarm permission. The notification shows the prompt title only.
class LocalReminderScheduler implements ReminderScheduler {
  /// Localized by the UI through [setChannelText] before anything is
  /// scheduled; the (untranslated) app name is only a fallback.
  String channelName = 'Cartharise';
  String channelDescription = '';

  @override
  void setChannelText({required String name, required String description}) {
    channelName = name;
    channelDescription = description;
  }

  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<String>.broadcast();
  Future<void>? _ready;
  bool _launchTaken = false;

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      'checkins',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'ic_stat_cartharise',
      color: CarthaTheme.notificationAccent,
      visibility: NotificationVisibility.private,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  Future<void> _init() => _ready ??= () async {
    await initTimeZone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_cartharise'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) _taps.add(payload);
      },
    );
  }();

  /// Next local occurrence of [hour]:[minute] (built from calendar fields so
  /// a DST change never shifts it by an hour).
  static tz.TZDateTime nextInstance(int hour, int minute, tz.TZDateTime now) {
    var at = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!at.isAfter(now)) {
      at = tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }
    return at;
  }

  @override
  Future<void> schedule(List<PlannedReminder> plans) async {
    await _init();
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    for (final plan in plans) {
      await _plugin.zonedSchedule(
        id: plan.id,
        title: plan.title,
        payload: plan.promptId,
        scheduledDate: nextInstance(plan.hour, plan.minute, now),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }

  @override
  Future<ReminderPermission> requestPermission() async {
    try {
      await _init();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted == null
            ? ReminderPermission.unavailable
            : granted
            ? ReminderPermission.granted
            : ReminderPermission.denied;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final granted = await ios.requestPermissions(alert: true, sound: true);
        return granted == null
            ? ReminderPermission.unavailable
            : granted
            ? ReminderPermission.granted
            : ReminderPermission.denied;
      }
      return ReminderPermission.unavailable;
    } on Object {
      return ReminderPermission.unavailable;
    }
  }

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> takeLaunchPayload() async {
    if (_launchTaken) return null;
    _launchTaken = true;
    try {
      await _init();
      final details = await _plugin.getNotificationAppLaunchDetails();
      return details?.didNotificationLaunchApp == true
          ? details!.notificationResponse?.payload
          : null;
    } on Object {
      return null;
    }
  }
}
