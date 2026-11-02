/// Everything the user owns, as one immutable snapshot, with hand-written JSON.
/// Pure Dart (no Flutter imports). Mirrors the requirement's data model:
/// UserProfile, Journey, ReflectionAnswer (incl. daytime check-ins), LifeCompass
/// (+ versions), Quest, MonthProject, JournalEntry, WeeklyReview,
/// ReminderPreference, the thirty-day path answers, the Campaign's battle log
/// (and its unsent attempt draft), the Playground's experiment log, and
/// (step 2) quest stages, project history, attachments and the pinned memory.
///
/// `fromJson` throws [FormatException] on any malformed input so an import can
/// be rejected without touching current data (F-041).
library;

import 'content.dart';
import 'local_date.dart';
import 'persona.dart';

/// 2 (step 2): quest stages, project ids and history, attachments on notes,
/// experiments and attempts, the pinned memory. Version 1 files load with
/// fallbacks; an older app refuses a version 2 file instead of silently
/// dropping what it doesn't know.
const int kSchemaVersion = 2;

enum Pace { oneDay, flexible }

enum AppearanceMode { system, light, dark }

/// Brand themes. Every theme has a light and a dark variant. Names are
/// stored in the data file: append new ones, never rename.
enum AppTheme { forest, olive, oasis, tyrian, alpine, obsidian }

enum QuestRecurrence { none, daily }

/// Where a quest came from. Stored by name: append new ones, never rename.
/// [experiment]: a Playground experiment the user added to their tasks.
enum QuestSource { manual, dailyLever, pathDay, project, experiment }

enum ProjectStatus { planned, active, paused, done }

enum CompassVersionReason { manual, beforeImport, beforeRestore }

/// What Today's next action leans towards (asked in "Choose something
/// else"). [auto] lets the app decide. Stored by name: append, never rename;
/// an unknown name loads as [auto].
enum TodayPin { auto, project, reflection, notes }

/// One-line first-use hints that, once their feature has been used, never
/// come back — even if what they introduced is emptied again (every quest
/// deleted). Stored by name: append, never rename; unknown names are
/// dropped.
enum FirstUseHint { quests }

/// Where a quest sits on the board (Missions › Board): one task list, many
/// views. Stored by name: append, never rename. A missing or unknown name
/// loads as [ready]; a completed one-off always loads as [done]. A daily
/// quest is [done] only on the days it was completed ([Quest.laneOn]); its
/// stored stage is never [done].
enum QuestStage { later, ready, doing, done }

/// The painted scenes a project can wear (Missions › project). Names match
/// the brand scenes (`SceneKind`) and lesson scenes (`LessonScene`) in
/// `lib/ui/widgets/` so the UI maps them by name. Stored by name: append,
/// never rename; an unknown name loads as no picture.
enum ProjectIllustration {
  sunrise,
  path,
  compass,
  steps,
  dawnRuins,
  roots,
  citadel,
  sailing,
  route,
}

/// A photo (system picker / camera) or a voice recording. Stored by name:
/// append, never rename.
enum AttachmentKind { photo, audio }

/// What holds an attachment: a journal note, an experiment tried, an
/// attempt in the battle log.
enum AttachmentHolder { journal, experiment, attempt }

/// What the pinned memory shows: a passage of the user's own words, or a
/// photo. Stored by name: append, never rename.
enum PinnedKind { passage, photo }

// ── JSON helpers ────────────────────────────────────────────────────────────

Map<String, Object?> _map(Object? v, String what) {
  if (v is Map<String, Object?>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  throw FormatException('Expected object for $what');
}

List<Object?> _list(Object? v, String what) {
  if (v == null) return const [];
  if (v is List) return v;
  throw FormatException('Expected list for $what');
}

String _str(Map<String, Object?> j, String key, {String fallback = ''}) {
  final v = j[key];
  if (v == null) return fallback;
  if (v is String) return v;
  throw FormatException('Expected string for "$key"');
}

String? _optStr(Map<String, Object?> j, String key) {
  final v = j[key];
  if (v == null || v is String) return v as String?;
  throw FormatException('Expected string for "$key"');
}

bool _bool(Map<String, Object?> j, String key, {bool fallback = false}) {
  final v = j[key];
  if (v == null) return fallback;
  if (v is bool) return v;
  throw FormatException('Expected bool for "$key"');
}

int _int(Map<String, Object?> j, String key) {
  final v = j[key];
  if (v is int) return v;
  throw FormatException('Expected int for "$key"');
}

int? _optInt(Map<String, Object?> j, String key) {
  final v = j[key];
  if (v == null || v is int) return v as int?;
  throw FormatException('Expected int for "$key"');
}

DateTime _time(Map<String, Object?> j, String key) {
  final v = j[key];
  if (v is String) {
    final t = DateTime.tryParse(v);
    if (t != null) return t;
  }
  throw FormatException('Expected ISO-8601 time for "$key"');
}

DateTime? _optTime(Map<String, Object?> j, String key) =>
    j[key] == null ? null : _time(j, key);

T _enum<T extends Enum>(
  List<T> values,
  Map<String, Object?> j,
  String key, {
  T? fallback,
}) {
  final v = j[key];
  for (final e in values) {
    if (e.name == v) return e;
  }
  if (v == null && fallback != null) return fallback;
  throw FormatException('Unknown value for "$key": $v');
}

/// Like [_enum], but a missing or unknown name (from a newer version) falls
/// back instead of failing; only a non-string value is malformed.
T _lenientEnum<T extends Enum>(
  List<T> values,
  Map<String, Object?> j,
  String key,
  T fallback,
) {
  final v = j[key];
  if (v == null) return fallback;
  if (v is! String) throw FormatException('Expected string for "$key"');
  for (final e in values) {
    if (e.name == v) return e;
  }
  return fallback;
}

String? _optDateKey(Map<String, Object?> j, String key) {
  final v = _optStr(j, key);
  if (v != null) parseDateKey(v);
  return v;
}

String _iso(DateTime t) => t.toUtc().toIso8601String();

String? _optIso(DateTime? t) => t == null ? null : _iso(t);

List<Attachment> _attachments(Map<String, Object?> j) => [
  for (final a in _list(j['attachments'], 'attachments'))
    Attachment.fromJson(a),
];

List<Map<String, Object?>> _attachmentsJson(List<Attachment> list) => [
  for (final a in list) a.toJson(),
];

// ── Attachments ────────────────────────────────────────────────────────────

/// Whether [name] can be an attachment's file name: one plain name inside
/// the private `attachments/` folder (letters, digits, `_` and `-`, an
/// optional short extension). Never a path, so a backup can't write outside
/// that folder.
bool isSafeAttachmentFileName(String name) =>
    RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,127}(\.[A-Za-z0-9]{1,8})?$')
        .hasMatch(name);

/// A photo or a voice recording the user added, kept as a file in the app's
/// private `attachments/` folder ([fileName]). A recording's [transcript]
/// is kept apart from the recording and is only ever what the user typed or
/// confirmed — never filled in by the app.
class Attachment {
  const Attachment({
    required this.id,
    required this.kind,
    required this.fileName,
    required this.createdAt,
    this.durationMs,
    this.transcript,
    this.interrupted = false,
  });

  final String id;
  final AttachmentKind kind;

  /// The file's name inside `attachments/` (see [isSafeAttachmentFileName]);
  /// never the name the file had on the phone before.
  final String fileName;
  final DateTime createdAt;

  /// A recording's length, when known.
  final int? durationMs;

  /// The user's own words for a recording, exactly as typed; null = none.
  final String? transcript;

  /// A recording cut short (a call, the app hidden or closed): what was
  /// said before that, kept — shown as "Partial" wherever it plays.
  final bool interrupted;

  Attachment copyWith({
    int? Function()? durationMs,
    String? Function()? transcript,
    bool? interrupted,
  }) => Attachment(
    id: id,
    kind: kind,
    fileName: fileName,
    createdAt: createdAt,
    durationMs: durationMs != null ? durationMs() : this.durationMs,
    transcript: transcript != null ? transcript() : this.transcript,
    interrupted: interrupted ?? this.interrupted,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind.name,
    'fileName': fileName,
    'createdAt': _iso(createdAt),
    'durationMs': durationMs,
    'transcript': transcript,
    if (interrupted) 'interrupted': true,
  };

  factory Attachment.fromJson(Object? json) {
    final j = _map(json, 'attachment');
    final id = _str(j, 'id');
    if (id.isEmpty) throw const FormatException('Missing attachment id');
    final fileName = _str(j, 'fileName');
    if (!isSafeAttachmentFileName(fileName)) {
      throw const FormatException('Bad attachment file name');
    }
    final duration = _optInt(j, 'durationMs');
    if (duration != null && duration < 0) {
      throw const FormatException('Bad recording length');
    }
    return Attachment(
      id: id,
      // Strict: a kind this version can't show would otherwise be dropped.
      kind: _enum(AttachmentKind.values, j, 'kind'),
      fileName: fileName,
      createdAt: _time(j, 'createdAt'),
      durationMs: duration,
      transcript: _optStr(j, 'transcript'),
      // Older files have none: complete.
      interrupted: _bool(j, 'interrupted'),
    );
  }
}

/// The one memory the user pinned to come back to: a [PinnedKind.passage]
/// of their own words ([excerpt], copied exactly from the entry
/// [sourceId]) or a [PinnedKind.photo] ([attachmentId] on that entry, with
/// an optional [excerpt]). It points at an entry; it owns no file.
class PinnedMemory {
  const PinnedMemory({
    required this.kind,
    required this.sourceId,
    required this.pinnedAt,
    this.attachmentId,
    this.excerpt,
  });

  final PinnedKind kind;

  /// The id of the journal note, experiment tried or attempt it comes from.
  final String sourceId;

  /// The photo, for [PinnedKind.photo].
  final String? attachmentId;

  /// The user's own words, copied exactly (never rewritten); required for a
  /// passage, optional for a photo.
  final String? excerpt;
  final DateTime pinnedAt;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'sourceId': sourceId,
    'attachmentId': attachmentId,
    'excerpt': excerpt,
    'pinnedAt': _iso(pinnedAt),
  };

  /// Null for a kind from a newer version (a pin is only a pointer; the
  /// words and files stay on their entry).
  static PinnedMemory? fromJson(Object? json) {
    if (json == null) return null;
    final j = _map(json, 'pinnedMemory');
    final sourceId = _str(j, 'sourceId');
    if (sourceId.isEmpty) throw const FormatException('Missing pin source');
    final attachmentId = _optStr(j, 'attachmentId');
    final excerpt = _optStr(j, 'excerpt');
    final pinnedAt = _time(j, 'pinnedAt');
    final kindName = j['kind'];
    if (kindName is! String) throw const FormatException('Bad pin kind');
    PinnedKind? kind;
    for (final k in PinnedKind.values) {
      if (k.name == kindName) kind = k;
    }
    if (kind == null) return null;
    if (kind == PinnedKind.photo && attachmentId == null) {
      throw const FormatException('A pinned photo needs its attachment');
    }
    if (kind == PinnedKind.passage && (excerpt == null || excerpt.isEmpty)) {
      throw const FormatException('A pinned passage needs its words');
    }
    return PinnedMemory(
      kind: kind,
      sourceId: sourceId,
      attachmentId: attachmentId,
      excerpt: excerpt,
      pinnedAt: pinnedAt,
    );
  }
}

// ── Profile & settings ─────────────────────────────────────────────────────

class UserProfile {
  const UserProfile({
    required this.createdAt,
    this.displayName,
    this.pace = Pace.flexible,
    this.onboardedAt,
    this.adultConfirmed = false,
  });

  /// Optional, never required (F-004).
  final String? displayName;
  final Pace pace;
  final DateTime createdAt;

  /// Set when onboarding finishes; null → show onboarding.
  final DateTime? onboardedAt;

  /// The user confirmed they are 18+ (launch audience decision D-11).
  final bool adultConfirmed;

  UserProfile copyWith({
    String? Function()? displayName,
    Pace? pace,
    DateTime? Function()? onboardedAt,
    bool? adultConfirmed,
  }) => UserProfile(
    createdAt: createdAt,
    displayName: displayName != null ? displayName() : this.displayName,
    pace: pace ?? this.pace,
    onboardedAt: onboardedAt != null ? onboardedAt() : this.onboardedAt,
    adultConfirmed: adultConfirmed ?? this.adultConfirmed,
  );

  Map<String, Object?> toJson() => {
    'displayName': displayName,
    'pace': pace.name,
    'createdAt': _iso(createdAt),
    'onboardedAt': onboardedAt == null ? null : _iso(onboardedAt!),
    'adultConfirmed': adultConfirmed,
  };

  factory UserProfile.fromJson(Object? json) {
    final j = _map(json, 'profile');
    return UserProfile(
      displayName: _optStr(j, 'displayName'),
      pace: _enum(Pace.values, j, 'pace', fallback: Pace.flexible),
      createdAt: _time(j, 'createdAt'),
      onboardedAt: _optTime(j, 'onboardedAt'),
      adultConfirmed: _bool(j, 'adultConfirmed'),
    );
  }
}

class AppSettings {
  const AppSettings({
    this.appearance = AppearanceMode.system,
    this.theme = AppTheme.forest,
    this.motion = true,
    this.remindersEnabled = false,
    this.quietStart,
    this.quietEnd,
    this.game = true,
    this.gameInvited = true,
    this.todayPin = TodayPin.auto,
    this.hintsSeen = const {},
  });

  final AppearanceMode appearance;
  final AppTheme theme;

  /// Interface motion; device "reduce motion" also disables it.
  final bool motion;

  /// Opt-in: false until the user enables reminders and grants permission.
  final bool remindersEnabled;

  /// Quiet hours, `HH:MM` local; both null = none.
  final String? quietStart;
  final String? quietEnd;

  /// The Campaign game layer (XP, levels, achievements; F-060). On by
  /// default (old files and tests keep their meaning); a brand-new profile
  /// starts with it off until the user says "Play" on the invitation. Off
  /// hides it everywhere, the battle log is kept.
  final bool game;

  /// Whether the one-time Campaign invitation was answered (or never
  /// needed). True by default and for older files, so existing users never
  /// see it; a brand-new profile starts with it false.
  final bool gameInvited;

  /// What Today's next action leans towards.
  final TodayPin todayPin;

  /// First-use hints whose feature was used: they are not shown again.
  final Set<FirstUseHint> hintsSeen;

  AppSettings copyWith({
    AppearanceMode? appearance,
    AppTheme? theme,
    bool? motion,
    bool? remindersEnabled,
    String? Function()? quietStart,
    String? Function()? quietEnd,
    bool? game,
    bool? gameInvited,
    TodayPin? todayPin,
    Set<FirstUseHint>? hintsSeen,
  }) => AppSettings(
    appearance: appearance ?? this.appearance,
    theme: theme ?? this.theme,
    motion: motion ?? this.motion,
    remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    quietStart: quietStart != null ? quietStart() : this.quietStart,
    quietEnd: quietEnd != null ? quietEnd() : this.quietEnd,
    game: game ?? this.game,
    gameInvited: gameInvited ?? this.gameInvited,
    todayPin: todayPin ?? this.todayPin,
    hintsSeen: hintsSeen ?? this.hintsSeen,
  );

  Map<String, Object?> toJson() => {
    'appearance': appearance.name,
    'theme': theme.name,
    'motion': motion,
    'remindersEnabled': remindersEnabled,
    'quietStart': quietStart,
    'quietEnd': quietEnd,
    'game': game,
    'gameInvited': gameInvited,
    'todayPin': todayPin.name,
    'hintsSeen': [
      for (final h in FirstUseHint.values)
        if (hintsSeen.contains(h)) h.name,
    ],
  };

  factory AppSettings.fromJson(Object? json) {
    if (json == null) return const AppSettings();
    final j = _map(json, 'settings');
    final quietStart = _optStr(j, 'quietStart');
    final quietEnd = _optStr(j, 'quietEnd');
    if (quietStart != null) parseClock(quietStart);
    if (quietEnd != null) parseClock(quietEnd);
    // Older files have none; names from a newer version are dropped.
    final hintsSeen = <FirstUseHint>{};
    for (final h in _list(j['hintsSeen'], 'hintsSeen')) {
      for (final known in FirstUseHint.values) {
        if (known.name == h) hintsSeen.add(known);
      }
    }
    return AppSettings(
      appearance: _enum(
        AppearanceMode.values,
        j,
        'appearance',
        fallback: AppearanceMode.system,
      ),
      theme: _enum(AppTheme.values, j, 'theme', fallback: AppTheme.forest),
      motion: _bool(j, 'motion', fallback: true),
      remindersEnabled: _bool(j, 'remindersEnabled'),
      quietStart: quietStart,
      quietEnd: quietEnd,
      game: _bool(j, 'game', fallback: true),
      gameInvited: _bool(j, 'gameInvited', fallback: true),
      todayPin: _lenientEnum(TodayPin.values, j, 'todayPin', TodayPin.auto),
      hintsSeen: hintsSeen,
    );
  }
}

/// One daytime check-in reminder (F-016). Times are local `HH:MM`.
class ReminderPreference {
  const ReminderPreference({
    required this.promptId,
    required this.time,
    this.enabled = true,
  });

  final String promptId;
  final String time;
  final bool enabled;

  ReminderPreference copyWith({String? time, bool? enabled}) =>
      ReminderPreference(
        promptId: promptId,
        time: time ?? this.time,
        enabled: enabled ?? this.enabled,
      );

  Map<String, Object?> toJson() => {
    'promptId': promptId,
    'time': time,
    'enabled': enabled,
  };

  factory ReminderPreference.fromJson(Object? json) {
    final j = _map(json, 'reminder');
    final time = _str(j, 'time');
    parseClock(time);
    return ReminderPreference(
      promptId: _str(j, 'promptId'),
      time: time,
      enabled: _bool(j, 'enabled', fallback: true),
    );
  }
}

// ── Reset journey ──────────────────────────────────────────────────────────

/// The user's words for one prompt. Daytime answers are the check-ins.
class ReflectionAnswer {
  const ReflectionAnswer({
    required this.promptId,
    required this.updatedAt,
    this.body = '',
    this.skipped = false,
  });

  final String promptId;

  /// Kept exactly as typed — never rewritten by the app.
  final String body;
  final bool skipped;
  final DateTime updatedAt;

  bool get answered => body.trim().isNotEmpty;

  Map<String, Object?> toJson() => {
    'promptId': promptId,
    'body': body,
    'skipped': skipped,
    'updatedAt': _iso(updatedAt),
  };

  factory ReflectionAnswer.fromJson(Object? json) {
    final j = _map(json, 'answer');
    return ReflectionAnswer(
      promptId: _str(j, 'promptId'),
      body: _str(j, 'body'),
      skipped: _bool(j, 'skipped'),
      updatedAt: _time(j, 'updatedAt'),
    );
  }
}

/// One run of the reset. Earlier journeys are kept read-only (F-034).
class Journey {
  const Journey({
    required this.id,
    required this.startedAt,
    this.completedAt,
    this.activePromptId,
    this.answers = const {},
  });

  final String id;
  final DateTime startedAt;
  final DateTime? completedAt;

  /// Where to resume (last prompt the user opened).
  final String? activePromptId;

  /// promptId → answer.
  final Map<String, ReflectionAnswer> answers;

  ReflectionAnswer? answer(String promptId) => answers[promptId];

  Journey copyWith({
    DateTime? Function()? completedAt,
    String? Function()? activePromptId,
    Map<String, ReflectionAnswer>? answers,
  }) => Journey(
    id: id,
    startedAt: startedAt,
    completedAt: completedAt != null ? completedAt() : this.completedAt,
    activePromptId: activePromptId != null
        ? activePromptId()
        : this.activePromptId,
    answers: answers ?? this.answers,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'startedAt': _iso(startedAt),
    'completedAt': completedAt == null ? null : _iso(completedAt!),
    'activePromptId': activePromptId,
    'answers': [for (final a in answers.values) a.toJson()],
  };

  factory Journey.fromJson(Object? json) {
    final j = _map(json, 'journey');
    final answers = <String, ReflectionAnswer>{
      for (final a in _list(
        j['answers'],
        'answers',
      ).map(ReflectionAnswer.fromJson))
        a.promptId: a,
    };
    return Journey(
      id: _str(j, 'id'),
      startedAt: _time(j, 'startedAt'),
      completedAt: _optTime(j, 'completedAt'),
      activePromptId: _optStr(j, 'activePromptId'),
      answers: answers,
    );
  }
}

// ── Life Compass ───────────────────────────────────────────────────────────

/// Six user-authored fields (F-023). Never filled by inference.
class LifeCompass {
  const LifeCompass({
    this.antiVision = '',
    this.vision = '',
    this.yearGoal = '',
    this.monthProject = '',
    this.dailyLevers = '',
    this.constraints = '',
    this.updatedAt,
  });

  final String antiVision;
  final String vision;
  final String yearGoal;
  final String monthProject;

  /// One lever per line; parsed into draft quests (F-028).
  final String dailyLevers;

  /// Non-negotiable boundaries — only ever typed by the user (F-025).
  final String constraints;
  final DateTime? updatedAt;

  String get(CompassField field) => switch (field) {
    CompassField.antiVision => antiVision,
    CompassField.vision => vision,
    CompassField.yearGoal => yearGoal,
    CompassField.monthProject => monthProject,
    CompassField.dailyLevers => dailyLevers,
    CompassField.constraints => constraints,
  };

  LifeCompass withField(CompassField field, String value, DateTime now) =>
      LifeCompass(
        antiVision: field == CompassField.antiVision ? value : antiVision,
        vision: field == CompassField.vision ? value : vision,
        yearGoal: field == CompassField.yearGoal ? value : yearGoal,
        monthProject: field == CompassField.monthProject ? value : monthProject,
        dailyLevers: field == CompassField.dailyLevers ? value : dailyLevers,
        constraints: field == CompassField.constraints ? value : constraints,
        updatedAt: now,
      );

  bool get isEmpty => CompassField.values.every((f) => get(f).trim().isEmpty);

  Map<String, Object?> toJson() => {
    for (final f in CompassField.values) f.name: get(f),
    'updatedAt': updatedAt == null ? null : _iso(updatedAt!),
  };

  factory LifeCompass.fromJson(Object? json) {
    if (json == null) return const LifeCompass();
    final j = _map(json, 'compass');
    return LifeCompass(
      antiVision: _str(j, 'antiVision'),
      vision: _str(j, 'vision'),
      yearGoal: _str(j, 'yearGoal'),
      monthProject: _str(j, 'monthProject'),
      dailyLevers: _str(j, 'dailyLevers'),
      constraints: _str(j, 'constraints'),
      updatedAt: _optTime(j, 'updatedAt'),
    );
  }
}

/// A timestamped Compass snapshot (F-026).
class CompassVersion {
  const CompassVersion({
    required this.savedAt,
    required this.compass,
    required this.reason,
  });

  final DateTime savedAt;
  final LifeCompass compass;
  final CompassVersionReason reason;

  Map<String, Object?> toJson() => {
    'savedAt': _iso(savedAt),
    'compass': compass.toJson(),
    'reason': reason.name,
  };

  factory CompassVersion.fromJson(Object? json) {
    final j = _map(json, 'compassVersion');
    return CompassVersion(
      savedAt: _time(j, 'savedAt'),
      compass: LifeCompass.fromJson(j['compass']),
      reason: _enum(
        CompassVersionReason.values,
        j,
        'reason',
        fallback: CompassVersionReason.manual,
      ),
    );
  }
}

// ── Becoming: quests & month project ───────────────────────────────────────

/// A small action. Completion belongs to a local date (F-029); there is no
/// streak and no penalty for missed days (F-031).
///
/// [stage] places it on the board; "Today" stays a separate filter (due
/// today / daily). Completion stays the source of truth for "done": see
/// [laneOn]. Moving a card never earns anything by itself — only completing
/// it does, by the existing rules.
class Quest {
  const Quest({
    required this.id,
    required this.title,
    required this.createdAt,
    this.recurrence = QuestRecurrence.none,
    this.dueDate,
    this.completedOn = const {},
    this.source = QuestSource.manual,
    this.note,
    this.stage = QuestStage.ready,
    this.projectId,
    this.doneFrom,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final QuestRecurrence recurrence;

  /// `yyyy-MM-dd`, optional.
  final String? dueDate;

  /// Date keys on which the quest was completed.
  final Set<String> completedOn;
  final QuestSource source;
  final String? note;

  /// The stored board stage. Use [laneOn] to show it: a daily quest's
  /// stored stage is never [QuestStage.done].
  final QuestStage stage;

  /// The [MonthProject.id] this quest belongs to, if any (current or past).
  final String? projectId;

  /// For a completed one-off: the lane it was in when it was completed
  /// (Later, Ready or Doing), so reopening it — the checkbox, Today — puts
  /// it back there instead of in Ready. Null = Ready. Never [QuestStage.done];
  /// null whenever the quest is open, and for daily quests.
  final QuestStage? doneFrom;

  /// The lane an open quest shows: its stored stage, or for a stored
  /// [QuestStage.done] the lane it was completed from.
  QuestStage get _openLane =>
      stage == QuestStage.done ? (doneFrom ?? QuestStage.ready) : stage;

  /// What [doneFrom] keeps for [lane]: Later or Doing; Ready is null.
  static QuestStage? _keptLane(QuestStage lane) =>
      lane == QuestStage.later || lane == QuestStage.doing ? lane : null;

  /// One-off quests are done once completed on any day; daily quests per day.
  bool isDoneOn(String day) => recurrence == QuestRecurrence.none
      ? completedOn.isNotEmpty
      : completedOn.contains(day);

  /// The board lane on local [day]: [QuestStage.done] when [isDoneOn] that
  /// day (a completed one-off on every day, a daily quest only on the days
  /// it was completed), else the stored stage (never done).
  QuestStage laneOn(String day) {
    if (isDoneOn(day)) return QuestStage.done;
    return _openLane;
  }

  /// This quest with its stage kept in step with its completion: a one-off
  /// is [QuestStage.done] exactly when completed (remembering in [doneFrom]
  /// the lane it was completed from); a daily quest is never stored as done.
  Quest normalized() {
    final QuestStage next;
    final QuestStage? from;
    if (recurrence == QuestRecurrence.none && completedOn.isNotEmpty) {
      next = QuestStage.done;
      from = stage == QuestStage.done ? doneFrom : _keptLane(stage);
    } else {
      next = _openLane;
      from = null;
    }
    if (next == stage && from == doneFrom) return this;
    return copyWith(stage: next, doneFrom: () => from);
  }

  /// Completes ([done]) or reopens this quest for local [day], as the
  /// checkbox does: a one-off completed is done on every day (reopened, on
  /// none, back in the lane it was completed from); a daily quest gains or
  /// loses that day only, its history kept. A daily quest completed returns
  /// to [QuestStage.ready] for the next day.
  Quest completedFor(String day, bool done) {
    if (recurrence == QuestRecurrence.daily) {
      return copyWith(
        completedOn: done
            ? {...completedOn, day}
            : ({...completedOn}..remove(day)),
        stage: done || stage == QuestStage.done ? QuestStage.ready : stage,
        doneFrom: () => null,
      );
    }
    if (done) {
      return copyWith(
        completedOn: {day},
        stage: QuestStage.done,
        doneFrom: () => stage == QuestStage.done ? doneFrom : _keptLane(stage),
      );
    }
    return copyWith(
      completedOn: const {},
      stage: _openLane,
      doneFrom: () => null,
    );
  }

  /// This quest moved to the board lane [target] on local [day]. Moving
  /// into done completes it for [day] (exactly like [completedFor]); moving
  /// out of done un-completes [day] only (a one-off is reopened, a daily
  /// quest keeps its other days); moving between the other lanes changes
  /// the stage only. Moving to the lane it is in returns it unchanged.
  Quest movedTo(QuestStage target, String day) {
    final lane = laneOn(day);
    if (target == lane) return this;
    if (target == QuestStage.done) return completedFor(day, true);
    if (lane == QuestStage.done) {
      return copyWith(
        completedOn: recurrence == QuestRecurrence.daily
            ? ({...completedOn}..remove(day))
            : const {},
        stage: target,
        doneFrom: () => null,
      );
    }
    return copyWith(stage: target);
  }

  Quest copyWith({
    String? title,
    QuestRecurrence? recurrence,
    String? Function()? dueDate,
    Set<String>? completedOn,
    String? Function()? note,
    QuestStage? stage,
    String? Function()? projectId,
    QuestStage? Function()? doneFrom,
  }) => Quest(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    recurrence: recurrence ?? this.recurrence,
    dueDate: dueDate != null ? dueDate() : this.dueDate,
    completedOn: completedOn ?? this.completedOn,
    source: source,
    note: note != null ? note() : this.note,
    stage: stage ?? this.stage,
    projectId: projectId != null ? projectId() : this.projectId,
    doneFrom: doneFrom != null ? doneFrom() : this.doneFrom,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'createdAt': _iso(createdAt),
    'recurrence': recurrence.name,
    'dueDate': dueDate,
    'completedOn': completedOn.toList()..sort(),
    'source': source.name,
    'note': note,
    'stage': stage.name,
    'projectId': projectId,
    'doneFrom': doneFrom?.name,
  };

  factory Quest.fromJson(Object? json) {
    final j = _map(json, 'quest');
    final done = <String>{};
    for (final d in _list(j['completedOn'], 'completedOn')) {
      if (d is! String) throw const FormatException('Bad completion date');
      parseDateKey(d);
      done.add(d);
    }
    return Quest(
      id: _str(j, 'id'),
      title: _str(j, 'title'),
      createdAt: _time(j, 'createdAt'),
      recurrence: _enum(
        QuestRecurrence.values,
        j,
        'recurrence',
        fallback: QuestRecurrence.none,
      ),
      dueDate: _optDateKey(j, 'dueDate'),
      completedOn: done,
      source: _enum(
        QuestSource.values,
        j,
        'source',
        fallback: QuestSource.manual,
      ),
      note: _optStr(j, 'note'),
      // Older files have none: ready, or done for a completed one-off.
      stage: _lenientEnum(QuestStage.values, j, 'stage', QuestStage.ready),
      projectId: _optStr(j, 'projectId'),
      // Older files have none (reopened quests go back to Ready).
      doneFrom: switch (j['doneFrom']) {
        null => null,
        _ => switch (_lenientEnum(
          QuestStage.values,
          j,
          'doneFrom',
          QuestStage.ready,
        )) {
          QuestStage.done || QuestStage.ready => null,
          final lane => lane,
        },
      },
    ).normalized();
  }
}

class Milestone {
  const Milestone({required this.id, required this.title, this.done = false});

  final String id;
  final String title;
  final bool done;

  Milestone copyWith({String? title, bool? done}) =>
      Milestone(id: id, title: title ?? this.title, done: done ?? this.done);

  Map<String, Object?> toJson() => {'id': id, 'title': title, 'done': done};

  factory Milestone.fromJson(Object? json) {
    final j = _map(json, 'milestone');
    return Milestone(
      id: _str(j, 'id'),
      title: _str(j, 'title'),
      done: _bool(j, 'done'),
    );
  }
}

/// The id an older file's project gets: stable for the same file (derived
/// from its last change), so loading it twice gives the same id.
String legacyProjectId(DateTime updatedAt) =>
    'project_legacy_${updatedAt.toUtc().microsecondsSinceEpoch.toRadixString(36)}';

/// The picture a project wears on its tasks and in its history: one of the
/// painted [illustration]s, or a [photo] the user added (its file lives in
/// `attachments/` like any other attachment).
class ProjectArt {
  const ProjectArt.illustration(ProjectIllustration this.illustration)
    : photo = null;
  const ProjectArt.photo(Attachment this.photo) : illustration = null;

  final ProjectIllustration? illustration;
  final Attachment? photo;

  /// The photo's [Attachment.id], when the art is a photo.
  String? get photoAttachmentId => photo?.id;

  Map<String, Object?> toJson() => {
    'illustration': illustration?.name,
    'photo': photo?.toJson(),
  };

  /// Null for no art, or an illustration this version doesn't know.
  static ProjectArt? fromJson(Object? json) {
    if (json == null) return null;
    final j = _map(json, 'projectArt');
    if (j['photo'] != null) {
      final photo = Attachment.fromJson(j['photo']);
      if (photo.kind != AttachmentKind.photo) {
        throw const FormatException('Project art must be a photo');
      }
      return ProjectArt.photo(photo);
    }
    final name = _optStr(j, 'illustration');
    for (final i in ProjectIllustration.values) {
      if (i.name == name) return ProjectArt.illustration(i);
    }
    return null;
  }
}

/// A one-month project (F-030), linked to Compass › month project: the
/// current one ([AppData.project]) or an archived one
/// ([AppData.pastProjects], with its retrospective).
class MonthProject {
  /// Without an [id] (older code and files) the project gets
  /// [legacyProjectId] of [updatedAt], kept from then on by [copyWith].
  const MonthProject({
    this._id,
    required this.title,
    required this.updatedAt,
    this.status = ProjectStatus.planned,
    this.milestones = const [],
    this.retrospective = '',
    this.startedAt,
    this.archivedAt,
    this.art,
  });

  final String? _id;

  /// Stable for the project's whole life (quests and attempts point at it).
  String get id => _id ?? legacyProjectId(updatedAt);
  final String title;
  final ProjectStatus status;
  final List<Milestone> milestones;
  final String retrospective;
  final DateTime updatedAt;

  /// When it was first saved; null for older files.
  final DateTime? startedAt;

  /// When it was archived into the history; null while it is current.
  final DateTime? archivedAt;

  /// Its chosen picture, if any.
  final ProjectArt? art;

  MonthProject copyWith({
    String? title,
    ProjectStatus? status,
    List<Milestone>? milestones,
    String? retrospective,
    DateTime? Function()? archivedAt,
    ProjectArt? Function()? art,
    required DateTime now,
  }) => MonthProject(
    id: id,
    title: title ?? this.title,
    status: status ?? this.status,
    milestones: milestones ?? this.milestones,
    retrospective: retrospective ?? this.retrospective,
    updatedAt: now,
    startedAt: startedAt,
    archivedAt: archivedAt != null ? archivedAt() : this.archivedAt,
    art: art != null ? art() : this.art,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'status': status.name,
    'milestones': [for (final m in milestones) m.toJson()],
    'retrospective': retrospective,
    'updatedAt': _iso(updatedAt),
    'startedAt': _optIso(startedAt),
    'archivedAt': _optIso(archivedAt),
    'art': art?.toJson(),
  };

  factory MonthProject.fromJson(Object? json) {
    final j = _map(json, 'project');
    final id = _optStr(j, 'id');
    if (id != null && id.isEmpty) throw const FormatException('Empty id');
    return MonthProject(
      id: id,
      title: _str(j, 'title'),
      status: _enum(
        ProjectStatus.values,
        j,
        'status',
        fallback: ProjectStatus.planned,
      ),
      milestones: [
        for (final m in _list(j['milestones'], 'milestones'))
          Milestone.fromJson(m),
      ],
      retrospective: _str(j, 'retrospective'),
      updatedAt: _time(j, 'updatedAt'),
      startedAt: _optTime(j, 'startedAt'),
      archivedAt: _optTime(j, 'archivedAt'),
      art: ProjectArt.fromJson(j['art']),
    );
  }
}

// ── Evolution: journal, reviews, 30-day path ───────────────────────────────

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.body,
    required this.createdAt,
    this.title,
    this.editedAt,
    this.attachments = const [],
  });

  final String id;
  final String? title;
  final String body;
  final DateTime createdAt;
  final DateTime? editedAt;

  /// Photos and recordings added to the note, oldest first.
  final List<Attachment> attachments;

  JournalEntry copyWith({
    String? Function()? title,
    String? body,
    DateTime? Function()? editedAt,
    List<Attachment>? attachments,
  }) => JournalEntry(
    id: id,
    title: title != null ? title() : this.title,
    body: body ?? this.body,
    createdAt: createdAt,
    editedAt: editedAt != null ? editedAt() : this.editedAt,
    attachments: attachments ?? this.attachments,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'createdAt': _iso(createdAt),
    'editedAt': editedAt == null ? null : _iso(editedAt!),
    'attachments': _attachmentsJson(attachments),
  };

  factory JournalEntry.fromJson(Object? json) {
    final j = _map(json, 'journalEntry');
    return JournalEntry(
      id: _str(j, 'id'),
      title: _optStr(j, 'title'),
      body: _str(j, 'body'),
      createdAt: _time(j, 'createdAt'),
      editedAt: _optTime(j, 'editedAt'),
      attachments: _attachments(j),
    );
  }
}

/// Wins, friction, next experiment (F-033).
class WeeklyReview {
  const WeeklyReview({
    required this.id,
    required this.weekStart,
    required this.createdAt,
    this.wins = '',
    this.friction = '',
    this.nextExperiment = '',
    this.editedAt,
  });

  final String id;

  /// Monday, `yyyy-MM-dd`.
  final String weekStart;
  final String wins;
  final String friction;
  final String nextExperiment;
  final DateTime createdAt;
  final DateTime? editedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'weekStart': weekStart,
    'wins': wins,
    'friction': friction,
    'nextExperiment': nextExperiment,
    'createdAt': _iso(createdAt),
    'editedAt': editedAt == null ? null : _iso(editedAt!),
  };

  factory WeeklyReview.fromJson(Object? json) {
    final j = _map(json, 'review');
    final weekStart = _str(j, 'weekStart');
    parseDateKey(weekStart);
    return WeeklyReview(
      id: _str(j, 'id'),
      weekStart: weekStart,
      wins: _str(j, 'wins'),
      friction: _str(j, 'friction'),
      nextExperiment: _str(j, 'nextExperiment'),
      createdAt: _time(j, 'createdAt'),
      editedAt: _optTime(j, 'editedAt'),
    );
  }
}

/// The user's note for one day of the thirty-day path (F-057).
class PathAnswer {
  const PathAnswer({
    required this.day,
    required this.body,
    required this.updatedAt,
  });

  final int day;
  final String body;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    'day': day,
    'body': body,
    'updatedAt': _iso(updatedAt),
  };

  factory PathAnswer.fromJson(Object? json) {
    final j = _map(json, 'pathAnswer');
    final day = _int(j, 'day');
    if (day < 1 || day > 30) {
      throw FormatException('Path day out of range', day);
    }
    return PathAnswer(
      day: day,
      body: _str(j, 'body'),
      updatedAt: _time(j, 'updatedAt'),
    );
  }
}

// ── The Campaign ───────────────────────────────────────────────────────────

/// One attempt at the one-month project — the Campaign's "boss fight"
/// (F-061): what the user tried and, optionally, what they learned, both
/// stored exactly as typed.
class BattleLogEntry {
  const BattleLogEntry({
    required this.id,
    required this.day,
    required this.attempt,
    required this.createdAt,
    this.learning = '',
    this.editedAt,
    this.projectId,
    this.attachments = const [],
  });

  final String id;

  /// Local day of the attempt, `yyyy-MM-dd`.
  final String day;
  final String attempt;
  final String learning;
  final DateTime createdAt;
  final DateTime? editedAt;

  /// The [MonthProject.id] it was an attempt at (the project current when
  /// it was recorded), if any.
  final String? projectId;

  /// Photos and recordings added to the attempt, oldest first.
  final List<Attachment> attachments;

  BattleLogEntry copyWith({
    String? attempt,
    String? learning,
    DateTime? Function()? editedAt,
    String? Function()? projectId,
    List<Attachment>? attachments,
  }) => BattleLogEntry(
    id: id,
    day: day,
    attempt: attempt ?? this.attempt,
    learning: learning ?? this.learning,
    createdAt: createdAt,
    editedAt: editedAt != null ? editedAt() : this.editedAt,
    projectId: projectId != null ? projectId() : this.projectId,
    attachments: attachments ?? this.attachments,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'day': day,
    'attempt': attempt,
    'learning': learning,
    'createdAt': _iso(createdAt),
    'editedAt': editedAt == null ? null : _iso(editedAt!),
    'projectId': projectId,
    'attachments': _attachmentsJson(attachments),
  };

  factory BattleLogEntry.fromJson(Object? json) {
    final j = _map(json, 'battleLogEntry');
    final day = _str(j, 'day');
    parseDateKey(day);
    return BattleLogEntry(
      id: _str(j, 'id'),
      day: day,
      attempt: _str(j, 'attempt'),
      learning: _str(j, 'learning'),
      createdAt: _time(j, 'createdAt'),
      editedAt: _optTime(j, 'editedAt'),
      projectId: _optStr(j, 'projectId'),
      attachments: _attachments(j),
    );
  }
}

/// The attempt form's words while they are being written, autosaved so
/// nothing typed is lost before "Record this attempt". Both fields exactly
/// as typed; recording the attempt removes the draft.
class AttemptDraft {
  const AttemptDraft({
    required this.updatedAt,
    this.attempt = '',
    this.learning = '',
  });

  final String attempt;
  final String learning;
  final DateTime updatedAt;

  /// Nothing worth keeping (both blank).
  bool get isEmpty => attempt.trim().isEmpty && learning.trim().isEmpty;

  Map<String, Object?> toJson() => {
    'attempt': attempt,
    'learning': learning,
    'updatedAt': _iso(updatedAt),
  };

  factory AttemptDraft.fromJson(Object? json) {
    final j = _map(json, 'attemptDraft');
    return AttemptDraft(
      attempt: _str(j, 'attempt'),
      learning: _str(j, 'learning'),
      updatedAt: _time(j, 'updatedAt'),
    );
  }
}

// ── The Playground ─────────────────────────────────────────────────────────

/// One time the user tried a Playground experiment (content id
/// `try.<chapter>.<n>`), with an optional note exactly as typed. Trying the
/// same experiment again adds another entry; XP counts each experiment once.
class ExperimentEntry {
  const ExperimentEntry({
    required this.id,
    required this.experimentId,
    required this.day,
    required this.createdAt,
    this.note = '',
    this.editedAt,
    this.attachments = const [],
  });

  final String id;

  /// The [Experiment] tried (permanent content id).
  final String experimentId;

  /// Local day it was tried, `yyyy-MM-dd`.
  final String day;

  /// Optional, kept exactly as typed ('' = none).
  final String note;
  final DateTime createdAt;
  final DateTime? editedAt;

  /// Photos and recordings added to the try, oldest first.
  final List<Attachment> attachments;

  ExperimentEntry copyWith({
    String? note,
    DateTime? Function()? editedAt,
    List<Attachment>? attachments,
  }) => ExperimentEntry(
    id: id,
    experimentId: experimentId,
    day: day,
    note: note ?? this.note,
    createdAt: createdAt,
    editedAt: editedAt != null ? editedAt() : this.editedAt,
    attachments: attachments ?? this.attachments,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'experimentId': experimentId,
    'day': day,
    'note': note,
    'createdAt': _iso(createdAt),
    'editedAt': editedAt == null ? null : _iso(editedAt!),
    'attachments': _attachmentsJson(attachments),
  };

  factory ExperimentEntry.fromJson(Object? json) {
    final j = _map(json, 'experimentEntry');
    final day = _str(j, 'day');
    parseDateKey(day);
    final experimentId = _str(j, 'experimentId');
    if (experimentId.isEmpty) {
      throw const FormatException('Missing experimentId');
    }
    return ExperimentEntry(
      id: _str(j, 'id'),
      experimentId: experimentId,
      day: day,
      note: _str(j, 'note'),
      createdAt: _time(j, 'createdAt'),
      editedAt: _optTime(j, 'editedAt'),
      attachments: _attachments(j),
    );
  }
}

// ── Root snapshot ──────────────────────────────────────────────────────────

class AppData {
  const AppData({
    this.profile,
    this.settings = const AppSettings(),
    this.journeys = const [],
    this.currentJourneyId,
    this.compass = const LifeCompass(),
    this.compassHistory = const [],
    this.quests = const [],
    this.project,
    this.journal = const [],
    this.reviews = const [],
    this.pathAnswers = const {},
    this.reminders = const [],
    this.lessonsRead = const {},
    this.campaignLog = const [],
    this.persona,
    this.avatarUnlocked = const {},
    this.attemptDraft,
    this.experimentLog = const [],
    this.tryNoteDrafts = const {},
    this.pastProjects = const [],
    this.pinnedMemory,
  });

  /// Null until onboarding creates it.
  final UserProfile? profile;
  final AppSettings settings;

  /// Oldest first. The current one is [currentJourneyId].
  final List<Journey> journeys;
  final String? currentJourneyId;
  final LifeCompass compass;

  /// Newest first, capped by the state layer.
  final List<CompassVersion> compassHistory;
  final List<Quest> quests;
  final MonthProject? project;

  /// Newest first.
  final List<JournalEntry> journal;

  /// Newest first.
  final List<WeeklyReview> reviews;

  /// day (1–30) → answer.
  final Map<int, PathAnswer> pathAnswers;

  /// Empty → defaults from the daytime prompts' `defaultTime`.
  final List<ReminderPreference> reminders;

  /// Lesson ids the user has opened.
  final Set<String> lessonsRead;

  /// The Campaign's battle log, newest first.
  final List<BattleLogEntry> campaignLog;

  /// The user's avatar and motto; null until they create one.
  final Persona? persona;

  /// Avatar extras the user keeps for good: each one they chose with a
  /// Campaign reward pick, each one a saved avatar wore, and each one an
  /// earlier version opened by itself. It only ever grows (nothing chosen
  /// or worn is taken away when progress goes down); "Delete all data"
  /// clears it with everything else.
  final Set<Unlockable> avatarUnlocked;

  /// The Campaign attempt form's unsent words; null when there are none.
  final AttemptDraft? attemptDraft;

  /// Playground experiments tried, newest first.
  final List<ExperimentEntry> experimentLog;

  /// The Playground "Try" note typed but not sent yet, per experiment id,
  /// exactly as typed (a blank note is no draft).
  final Map<String, String> tryNoteDrafts;

  /// Archived month projects with their retrospectives, newest first.
  final List<MonthProject> pastProjects;

  /// The one memory the user pinned, if any.
  final PinnedMemory? pinnedMemory;

  static const empty = AppData();

  /// Every attachment the data holds: on notes, experiments tried and
  /// attempts, and the current and past projects' photos.
  Iterable<Attachment> get allAttachments sync* {
    for (final e in journal) {
      yield* e.attachments;
    }
    for (final e in experimentLog) {
      yield* e.attachments;
    }
    for (final e in campaignLog) {
      yield* e.attachments;
    }
    for (final p in [?project, ...pastProjects]) {
      final photo = p.art?.photo;
      if (photo != null) yield photo;
    }
  }

  /// The attachment files the data refers to: the files that must be kept
  /// (and go into a backup).
  Set<String> get attachmentFileNames => {
    for (final a in allAttachments) a.fileName,
  };

  /// The attachment with [id], wherever it is held.
  Attachment? attachmentById(String id) {
    for (final a in allAttachments) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// The attachments held by the entry [entryId] of [holder] (empty when
  /// there is no such entry).
  List<Attachment> attachmentsOf(AttachmentHolder holder, String entryId) {
    final Iterable<({String id, List<Attachment> attachments})> entries =
        switch (holder) {
          AttachmentHolder.journal => [
            for (final e in journal) (id: e.id, attachments: e.attachments),
          ],
          AttachmentHolder.experiment => [
            for (final e in experimentLog)
              (id: e.id, attachments: e.attachments),
          ],
          AttachmentHolder.attempt => [
            for (final e in campaignLog) (id: e.id, attachments: e.attachments),
          ],
        };
    for (final e in entries) {
      if (e.id == entryId) return e.attachments;
    }
    return const [];
  }

  /// The user's own words on the entry [entryId] — what a pinned passage
  /// may be copied from: a note's title and body, an experiment's note, an
  /// attempt and its learning, and the transcripts of its recordings.
  /// Empty when there is no such entry.
  List<String> entryWords(String entryId) {
    Iterable<String> transcripts(List<Attachment> list) => [
      for (final a in list)
        if (a.transcript != null) a.transcript!,
    ];
    for (final e in journal) {
      if (e.id == entryId) {
        return [?e.title, e.body, ...transcripts(e.attachments)];
      }
    }
    for (final e in experimentLog) {
      if (e.id == entryId) return [e.note, ...transcripts(e.attachments)];
    }
    for (final e in campaignLog) {
      if (e.id == entryId) {
        return [e.attempt, e.learning, ...transcripts(e.attachments)];
      }
    }
    return const [];
  }

  /// This data with its pinned memory still true to its entry: words that
  /// the entry no longer has (edited away, a transcript changed or removed)
  /// are never kept on show — a pinned passage is unpinned, a pinned photo
  /// stays pinned without them. Otherwise unchanged.
  AppData withPinChecked() {
    final pin = pinnedMemory;
    final excerpt = pin?.excerpt;
    if (pin == null || excerpt == null) return this;
    if (entryWords(pin.sourceId).any((w) => w.contains(excerpt))) return this;
    return copyWith(
      pinnedMemory: () => pin.kind == PinnedKind.photo
          ? PinnedMemory(
              kind: pin.kind,
              sourceId: pin.sourceId,
              attachmentId: pin.attachmentId,
              pinnedAt: pin.pinnedAt,
            )
          : null,
    );
  }

  Journey? get currentJourney {
    for (final j in journeys) {
      if (j.id == currentJourneyId) return j;
    }
    return null;
  }

  AppData copyWith({
    UserProfile? Function()? profile,
    AppSettings? settings,
    List<Journey>? journeys,
    String? Function()? currentJourneyId,
    LifeCompass? compass,
    List<CompassVersion>? compassHistory,
    List<Quest>? quests,
    MonthProject? Function()? project,
    List<JournalEntry>? journal,
    List<WeeklyReview>? reviews,
    Map<int, PathAnswer>? pathAnswers,
    List<ReminderPreference>? reminders,
    Set<String>? lessonsRead,
    List<BattleLogEntry>? campaignLog,
    Persona? Function()? persona,
    Set<Unlockable>? avatarUnlocked,
    AttemptDraft? Function()? attemptDraft,
    List<ExperimentEntry>? experimentLog,
    Map<String, String>? tryNoteDrafts,
    List<MonthProject>? pastProjects,
    PinnedMemory? Function()? pinnedMemory,
  }) => AppData(
    profile: profile != null ? profile() : this.profile,
    settings: settings ?? this.settings,
    journeys: journeys ?? this.journeys,
    currentJourneyId: currentJourneyId != null
        ? currentJourneyId()
        : this.currentJourneyId,
    compass: compass ?? this.compass,
    compassHistory: compassHistory ?? this.compassHistory,
    quests: quests ?? this.quests,
    project: project != null ? project() : this.project,
    journal: journal ?? this.journal,
    reviews: reviews ?? this.reviews,
    pathAnswers: pathAnswers ?? this.pathAnswers,
    reminders: reminders ?? this.reminders,
    lessonsRead: lessonsRead ?? this.lessonsRead,
    campaignLog: campaignLog ?? this.campaignLog,
    persona: persona != null ? persona() : this.persona,
    avatarUnlocked: avatarUnlocked ?? this.avatarUnlocked,
    attemptDraft: attemptDraft != null ? attemptDraft() : this.attemptDraft,
    experimentLog: experimentLog ?? this.experimentLog,
    tryNoteDrafts: tryNoteDrafts ?? this.tryNoteDrafts,
    pastProjects: pastProjects ?? this.pastProjects,
    pinnedMemory: pinnedMemory != null ? pinnedMemory() : this.pinnedMemory,
  );

  Map<String, Object?> toJson() => {
    'schemaVersion': kSchemaVersion,
    'profile': profile?.toJson(),
    'settings': settings.toJson(),
    'journeys': [for (final j in journeys) j.toJson()],
    'currentJourneyId': currentJourneyId,
    'compass': compass.toJson(),
    'compassHistory': [for (final v in compassHistory) v.toJson()],
    'quests': [for (final q in quests) q.toJson()],
    'project': project?.toJson(),
    'journal': [for (final e in journal) e.toJson()],
    'reviews': [for (final r in reviews) r.toJson()],
    'pathAnswers': [for (final a in pathAnswers.values) a.toJson()],
    'reminders': [for (final r in reminders) r.toJson()],
    'lessonsRead': lessonsRead.toList()..sort(),
    'campaignLog': [for (final e in campaignLog) e.toJson()],
    'persona': persona?.toJson(),
    'avatarUnlocked': [
      for (final u in Unlockable.values)
        if (avatarUnlocked.contains(u)) u.name,
    ],
    'attemptDraft': attemptDraft?.toJson(),
    'experimentLog': [for (final e in experimentLog) e.toJson()],
    'tryNoteDrafts': {
      for (final id in tryNoteDrafts.keys.toList()..sort())
        id: tryNoteDrafts[id],
    },
    'pastProjects': [for (final p in pastProjects) p.toJson()],
    'pinnedMemory': pinnedMemory?.toJson(),
  };

  factory AppData.fromJson(Object? json) {
    final j = _map(json, 'data');
    final version = j['schemaVersion'];
    if (version is! int || version < 1 || version > kSchemaVersion) {
      throw FormatException('Unsupported schema version', version);
    }
    final journeys = [
      for (final x in _list(j['journeys'], 'journeys')) Journey.fromJson(x),
    ];
    final current = _optStr(j, 'currentJourneyId');
    if (current != null && !journeys.any((x) => x.id == current)) {
      throw const FormatException('currentJourneyId has no journey');
    }
    final lessons = <String>{};
    for (final l in _list(j['lessonsRead'], 'lessonsRead')) {
      if (l is! String) throw const FormatException('Bad lesson id');
      lessons.add(l);
    }
    // Extras from a newer version this one doesn't know are left out.
    final unlocked = <Unlockable>{};
    for (final u in _list(j['avatarUnlocked'], 'avatarUnlocked')) {
      if (u is! String) throw const FormatException('Bad avatar extra');
      for (final known in Unlockable.values) {
        if (known.name == u) unlocked.add(known);
      }
    }
    // Older files have no drafts.
    final tryNoteDrafts = <String, String>{};
    if (j['tryNoteDrafts'] != null) {
      for (final MapEntry(:key, :value) in _map(
        j['tryNoteDrafts'],
        'tryNoteDrafts',
      ).entries) {
        if (value is! String) throw const FormatException('Bad note draft');
        tryNoteDrafts[key] = value;
      }
    }
    final project = j['project'] == null
        ? null
        : MonthProject.fromJson(j['project']);
    var quests = [
      for (final q in _list(j['quests'], 'quests')) Quest.fromJson(q),
    ];
    var campaignLog = [
      for (final e in _list(j['campaignLog'], 'campaignLog'))
        BattleLogEntry.fromJson(e),
    ];
    // Schema 1 had one month project and no links. Every battle-log attempt
    // was, by definition (F-061), an attempt at it, and its "project" quests
    // were its tasks: link them (to its stable legacy id), so finishing it
    // keeps them in its history. Nothing already linked is touched.
    if (version == 1 && project != null) {
      final id = project.id;
      campaignLog = [
        for (final e in campaignLog)
          e.projectId == null ? e.copyWith(projectId: () => id) : e,
      ];
      quests = [
        for (final q in quests)
          q.projectId == null && q.source == QuestSource.project
              ? q.copyWith(projectId: () => id)
              : q,
      ];
    }
    return AppData(
      profile: j['profile'] == null ? null : UserProfile.fromJson(j['profile']),
      settings: AppSettings.fromJson(j['settings']),
      journeys: journeys,
      currentJourneyId: current,
      compass: LifeCompass.fromJson(j['compass']),
      compassHistory: [
        for (final v in _list(j['compassHistory'], 'compassHistory'))
          CompassVersion.fromJson(v),
      ],
      quests: quests,
      project: project,
      journal: [
        for (final e in _list(j['journal'], 'journal'))
          JournalEntry.fromJson(e),
      ],
      reviews: [
        for (final r in _list(j['reviews'], 'reviews'))
          WeeklyReview.fromJson(r),
      ],
      pathAnswers: {
        for (final a in _list(
          j['pathAnswers'],
          'pathAnswers',
        ).map(PathAnswer.fromJson))
          a.day: a,
      },
      reminders: [
        for (final r in _list(j['reminders'], 'reminders'))
          ReminderPreference.fromJson(r),
      ],
      lessonsRead: lessons,
      campaignLog: campaignLog,
      persona: j['persona'] == null ? null : Persona.fromJson(j['persona']),
      avatarUnlocked: unlocked,
      attemptDraft: j['attemptDraft'] == null
          ? null
          : AttemptDraft.fromJson(j['attemptDraft']),
      experimentLog: [
        for (final e in _list(j['experimentLog'], 'experimentLog'))
          ExperimentEntry.fromJson(e),
      ],
      tryNoteDrafts: tryNoteDrafts,
      pastProjects: [
        for (final p in _list(j['pastProjects'], 'pastProjects'))
          MonthProject.fromJson(p),
      ],
      pinnedMemory: PinnedMemory.fromJson(j['pinnedMemory']),
    );
  }
}
