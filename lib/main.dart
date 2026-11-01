import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'content/content.dart';
import 'data/data_store.dart';
import 'reminders/reminder_scheduler.dart';
import 'services/file_share.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status and navigation bars on every Android version (as
  // Android 15+ enforces anyway); screens pad for the insets.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Reminders fire at local wall-clock time; the zone is re-read every launch.
  await initTimeZone();

  final state = AppState(
    store: FileDataStore(),
    content: contentFor(PlatformDispatcher.instance.locale.languageCode),
    reminders: LocalReminderScheduler(),
  );
  // BootScreen calls state.load() behind the animated emblem.
  runApp(CarthaApp(state: state, fileShare: SystemFileShare()));
}
