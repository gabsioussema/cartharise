/// Everything the user owns, as one immutable snapshot, with hand-written JSON.
/// Pure Dart (no Flutter imports). Mirrors the requirement's data model:
/// UserProfile, Journey, ReflectionAnswer (incl. daytime check-ins), LifeCompass
/// (+ versions), Quest, MonthProject, JournalEntry, WeeklyReview,
/// ReminderPreference, the thirty-day path answers, the Campaign's battle log
/// (and its unsent attempt draft) and the Playground's experiment log.
///
/// `fromJson` throws [FormatException] on any malformed input so an import can
/// be rejected without touching current data (F-041).
library;

import 'content.dart';
import 'local_date.dart';
import 'persona.dart';

const int kSchemaVersion = 1;

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
  };

  factory AppSettings.fromJson(Object? json) {
    if (json == null) return const AppSettings();
    final j = _map(json, 'settings');
    final quietStart = _optStr(j, 'quietStart');
    final quietEnd = _optStr(j, 'quietEnd');
    if (quietStart != null) parseClock(quietStart);
    if (quietEnd != null) parseClock(quietEnd);
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

  /// One-off quests are done once completed on any day; daily quests per day.
  bool isDoneOn(String day) => recurrence == QuestRecurrence.none
      ? completedOn.isNotEmpty
      : completedOn.contains(day);

  Quest copyWith({
    String? title,
    QuestRecurrence? recurrence,
    String? Function()? dueDate,
    Set<String>? completedOn,
    String? Function()? note,
  }) => Quest(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    recurrence: recurrence ?? this.recurrence,
    dueDate: dueDate != null ? dueDate() : this.dueDate,
    completedOn: completedOn ?? this.completedOn,
    source: source,
    note: note != null ? note() : this.note,
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
    );
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

/// The current one-month project (F-030), linked to Compass › month project.
class MonthProject {
  const MonthProject({
    required this.title,
    required this.updatedAt,
    this.status = ProjectStatus.planned,
    this.milestones = const [],
    this.retrospective = '',
  });

  final String title;
  final ProjectStatus status;
  final List<Milestone> milestones;
  final String retrospective;
  final DateTime updatedAt;

  MonthProject copyWith({
    String? title,
    ProjectStatus? status,
    List<Milestone>? milestones,
    String? retrospective,
    required DateTime now,
  }) => MonthProject(
    title: title ?? this.title,
    status: status ?? this.status,
    milestones: milestones ?? this.milestones,
    retrospective: retrospective ?? this.retrospective,
    updatedAt: now,
  );

  Map<String, Object?> toJson() => {
    'title': title,
    'status': status.name,
    'milestones': [for (final m in milestones) m.toJson()],
    'retrospective': retrospective,
    'updatedAt': _iso(updatedAt),
  };

  factory MonthProject.fromJson(Object? json) {
    final j = _map(json, 'project');
    return MonthProject(
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
  });

  final String id;
  final String? title;
  final String body;
  final DateTime createdAt;
  final DateTime? editedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'createdAt': _iso(createdAt),
    'editedAt': editedAt == null ? null : _iso(editedAt!),
  };

  factory JournalEntry.fromJson(Object? json) {
    final j = _map(json, 'journalEntry');
    return JournalEntry(
      id: _str(j, 'id'),
      title: _optStr(j, 'title'),
      body: _str(j, 'body'),
      createdAt: _time(j, 'createdAt'),
      editedAt: _optTime(j, 'editedAt'),
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
  });

  final String id;

  /// Local day of the attempt, `yyyy-MM-dd`.
  final String day;
  final String attempt;
  final String learning;
  final DateTime createdAt;
  final DateTime? editedAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'day': day,
    'attempt': attempt,
    'learning': learning,
    'createdAt': _iso(createdAt),
    'editedAt': editedAt == null ? null : _iso(editedAt!),
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

  Map<String, Object?> toJson() => {
    'id': id,
    'experimentId': experimentId,
    'day': day,
    'note': note,
    'createdAt': _iso(createdAt),
    'editedAt': editedAt == null ? null : _iso(editedAt!),
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

  static const empty = AppData();

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
      quests: [for (final q in _list(j['quests'], 'quests')) Quest.fromJson(q)],
      project: j['project'] == null
          ? null
          : MonthProject.fromJson(j['project']),
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
      campaignLog: [
        for (final e in _list(j['campaignLog'], 'campaignLog'))
          BattleLogEntry.fromJson(e),
      ],
      persona: j['persona'] == null ? null : Persona.fromJson(j['persona']),
      avatarUnlocked: unlocked,
      attemptDraft: j['attemptDraft'] == null
          ? null
          : AttemptDraft.fromJson(j['attemptDraft']),
      experimentLog: [
        for (final e in _list(j['experimentLog'], 'experimentLog'))
          ExperimentEntry.fromJson(e),
      ],
    );
  }
}
