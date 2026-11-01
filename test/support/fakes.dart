import 'dart:async';

import 'package:cartharise/reminders/reminder_plan.dart';
import 'package:cartharise/reminders/reminder_scheduler.dart';
import 'package:cartharise/services/file_share.dart';

/// Records what would be scheduled; answers permission with [permission].
class FakeReminderScheduler implements ReminderScheduler {
  FakeReminderScheduler({this.permission = ReminderPermission.granted});

  ReminderPermission permission;
  List<PlannedReminder> scheduled = const [];
  int permissionRequests = 0;
  int cancelCount = 0;
  bool failSchedule = false;
  String? launchPayload;
  final _taps = StreamController<String>.broadcast();

  @override
  Future<ReminderPermission> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> schedule(List<PlannedReminder> plans) async {
    if (failSchedule) throw StateError('Simulated scheduling failure');
    scheduled = List.of(plans);
  }

  @override
  Future<void> cancelAll() async {
    cancelCount++;
    scheduled = const [];
  }

  /// Simulates the user tapping a notification for [promptId].
  void tap(String promptId) => _taps.add(promptId);

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<String?> takeLaunchPayload() async {
    final p = launchPayload;
    launchPayload = null;
    return p;
  }
}

/// A shared file, as the fake share sheet saw it.
class SharedFile {
  const SharedFile(this.filename, this.content, this.mimeType);
  final String filename;
  final String content;
  final String mimeType;
}

/// Records shares; [pickResult] is what the "file picker" returns.
class FakeFileShare implements FileShare {
  final List<SharedFile> shared = [];
  ShareOutcome outcome = ShareOutcome.shared;
  bool failShare = false;
  String? pickResult;
  Object? pickError;

  @override
  Future<ShareOutcome> shareTextFile(
    String filename,
    String content,
    String mimeType,
  ) async {
    if (failShare) throw StateError('Simulated share failure');
    shared.add(SharedFile(filename, content, mimeType));
    return outcome;
  }

  @override
  Future<String?> pickTextFile() async {
    if (pickError != null) throw pickError!;
    return pickResult;
  }
}
