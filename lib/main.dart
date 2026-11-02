import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'content/content.dart';
import 'data/backup_exclusion.dart';
import 'data/data_store.dart';
import 'reminders/reminder_scheduler.dart';
import 'services/attachment_store.dart';
import 'services/file_share.dart';
import 'services/media_picker.dart';
import 'services/voice_player.dart';
import 'services/voice_recorder.dart';
import 'state/app_state.dart';
import 'ui/you/font_licenses.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Draw behind the status and navigation bars on every Android version (as
  // Android 15+ enforces anyway); screens pad for the insets.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Reminders fire at local wall-clock time; the zone is re-read every launch.
  await initTimeZone();
  // Bundled Inter + Cinzel (OFL) appear on the licence page app-wide.
  registerFontLicenses();

  final state = AppState(
    // Kept out of OS backups: Android by the manifest, iOS per write.
    store: FileDataStore(excludeFromBackup: platformBackupExclusion()),
    // Photos and recordings: `attachments/` next to the data file, kept out
    // of OS backups the same way.
    attachments: FileAttachmentStore(
      excludeFromBackup: platformBackupExclusion(),
    ),
    content: contentFor(PlatformDispatcher.instance.locale.languageCode),
    reminders: LocalReminderScheduler(),
  );
  // BootScreen calls state.load() behind the animated emblem.
  runApp(
    CarthaApp(
      state: state,
      fileShare: SystemFileShare(),
      mediaPicker: SystemMediaPicker(),
      voiceRecorder: RecordVoiceRecorder(),
      voicePlayer: AudioVoicePlayer(),
    ),
  );
}
