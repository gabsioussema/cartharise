import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/data_store.dart';
import '../domain/app_data.dart';
import '../domain/backup.dart';
import '../domain/content.dart';
import '../domain/local_date.dart';
import '../reminders/reminder_plan.dart';
import '../reminders/reminder_scheduler.dart';
import '../services/ics_export.dart';
import 'state_types.dart';

export '../reminders/reminder_scheduler.dart' show ReminderPermission;
export '../services/ics_export.dart' show CalendarTexts;
export 'state_types.dart';

/// Most Compass versions kept (newest first).
const int kCompassHistoryLimit = 50;

/// The app's single source of truth (PLAN.md §5). Every mutation goes through
/// [mutate]: it updates [data], notifies listeners, then persists, reporting
/// progress in [saveStatus]. A failed save keeps the new data in memory (the
/// user's words stay on screen) and [retrySave] writes it again.
///
/// Features that need a new operation add an `extension` on [AppState] in
/// their own folder, built on [mutate], [data], [now] and [newId].
class AppState extends ChangeNotifier {
  AppState({
    required this._store,
    required this._content,
    required ReminderScheduler reminders,
    DateTime Function()? clock,
  }) : _scheduler = reminders,
       _clock = clock ?? DateTime.now;

  final DataStore _store;
  final ContentLibrary _content;
  final ReminderScheduler _scheduler;
  final DateTime Function() _clock;
  final _random = Random();
  int _idCounter = 0;

  AppData _data = AppData.empty;
  bool _loaded = false;
  bool _loading = false;
  Object? _loadError;
  SaveStatus _saveStatus = SaveStatus.idle;
  Object? _saveError;
  Object? _reminderError;
  Future<void> _writeQueue = Future.value();
  int _writeGeneration = 0;
  int _dataGeneration = 0;
  Journey? _draftJourney;

  // ── Lifecycle & persistence ─────────────────────────────────────────────

  bool get loaded => _loaded;
  bool get loading => _loading;

  /// Saved data exists but couldn't be read: show an honest notice; nothing
  /// is written (so nothing is overwritten) until [load] succeeds.
  Object? get loadError => _loadError;

  SaveStatus get saveStatus => _saveStatus;

  /// The last write failure, for diagnostics (never shown raw to the user).
  Object? get saveError => _saveError;

  /// The last failure to (re)schedule notifications, if any.
  Object? get reminderError => _reminderError;

  AppData get data => _data;

  /// Changes whenever [data] is replaced wholesale rather than changed by
  /// one action: a load, a restored backup, a fresh start after a load
  /// error, "Delete all data". Whatever celebrates a difference (Campaign
  /// moments) starts over instead of treating the swap as progress.
  int get dataGeneration => _dataGeneration;
  ContentLibrary get content => _content;
  AppSettings get settings => _data.settings;
  DateTime now() => _clock();

  /// Today's local date key (`yyyy-MM-dd`).
  String get today => dateKey(now());

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _loadError = null;
    notifyListeners();
    try {
      // Loaded as saved: avatar extras already kept stay kept; progress
      // gives reward picks, it never adds extras by itself.
      _data = await _store.read() ?? AppData.empty;
      _dataGeneration++;
      _loaded = true;
    } on Object catch (e) {
      _loadError = e;
      _loaded = false;
    } finally {
      _loading = false;
    }
    notifyListeners();
    if (_loaded && _data.settings.remindersEnabled) {
      // The time zone may have changed since the last run.
      await _replan();
    }
  }

  /// After an unreadable file: set it aside (kept, not deleted) and start
  /// empty. Returns where the old file was kept.
  Future<String?> startFreshAfterLoadError() async {
    final kept = await _store.moveAside();
    _data = AppData.empty;
    _dataGeneration++;
    _loadError = null;
    _loaded = true;
    notifyListeners();
    return kept;
  }

  /// Applies [change] to [data], notifies, then persists. Never throws for a
  /// failed write — that is reported through [saveStatus]. Nothing derived
  /// is folded in: avatar extras are added only by an explicit choice
  /// (`chooseReward`) or by wearing them (`savePersona`).
  Future<void> mutate(AppData Function(AppData) change) async {
    if (!_loaded) {
      throw StateError('AppState.mutate before a successful load()');
    }
    _data = change(_data);
    notifyListeners();
    await _persist();
  }

  /// Writes the current data again after a failure.
  Future<void> retrySave() async {
    if (!_loaded) return;
    await _persist();
  }

  Future<void> _persist() {
    final snapshot = _data;
    final generation = ++_writeGeneration;
    _setSaveStatus(SaveStatus.saving);
    final write = _writeQueue.then((_) async {
      try {
        await _store.write(snapshot);
        if (generation == _writeGeneration) {
          _saveError = null;
          _setSaveStatus(SaveStatus.saved);
        }
      } on Object catch (e) {
        _saveError = e;
        _setSaveStatus(SaveStatus.failed);
      }
    });
    _writeQueue = write;
    return write;
  }

  void _setSaveStatus(SaveStatus status) {
    if (_saveStatus == status) return;
    _saveStatus = status;
    notifyListeners();
  }

  /// A new unique id, e.g. `quest_lz3k9a1f`.
  String newId(String prefix) {
    final stamp = now().microsecondsSinceEpoch.toRadixString(36);
    final salt = _random.nextInt(1 << 20).toRadixString(36);
    return '${prefix}_$stamp${(_idCounter++).toRadixString(36)}$salt';
  }

  // ── Onboarding & profile ────────────────────────────────────────────────

  bool get needsOnboarding => _data.profile?.onboardedAt == null;

  /// Finishes onboarding. With [askAboutGame], a brand-new profile starts
  /// with the Campaign off and its one-time invitation pending
  /// (`game: false, gameInvited: false`); a replayed welcome (the profile
  /// already exists) keeps the user's Campaign settings as they are.
  Future<void> completeOnboarding({
    String? displayName,
    required Pace pace,
    required bool adultConfirmed,
    bool askAboutGame = false,
  }) {
    final at = now();
    final name = displayName?.trim();
    return mutate(
      (d) => d.copyWith(
        profile: () => (d.profile ?? UserProfile(createdAt: at)).copyWith(
          displayName: () => name == null || name.isEmpty ? null : name,
          pace: pace,
          onboardedAt: () => at,
          adultConfirmed: adultConfirmed,
        ),
        settings: askAboutGame && d.profile == null
            ? d.settings.copyWith(game: false, gameInvited: false)
            : null,
      ),
    );
  }

  Future<void> updateProfile({String? Function()? displayName, Pace? pace}) {
    final at = now();
    return mutate(
      (d) => d.copyWith(
        profile: () => (d.profile ?? UserProfile(createdAt: at)).copyWith(
          displayName: displayName == null
              ? null
              : () {
                  final name = displayName()?.trim();
                  return name == null || name.isEmpty ? null : name;
                },
          pace: pace,
        ),
      ),
    );
  }

  /// "Replay welcome": shows onboarding again; nothing else changes.
  Future<void> resetOnboarding() => mutate(
    (d) => d.profile == null
        ? d
        : d.copyWith(
            profile: () => d.profile!.copyWith(onboardedAt: () => null),
          ),
  );

  Future<void> updateSettings(AppSettings settings) async {
    final before = _data.settings;
    await mutate((d) => d.copyWith(settings: settings));
    if (before.remindersEnabled != settings.remindersEnabled ||
        before.quietStart != settings.quietStart ||
        before.quietEnd != settings.quietEnd) {
      await _replan();
    }
  }

  // ── Awakening ───────────────────────────────────────────────────────────

  Future<void> markLessonRead(String lessonId) async {
    if (_data.lessonsRead.contains(lessonId)) return;
    await mutate((d) => d.copyWith(lessonsRead: {...d.lessonsRead, lessonId}));
  }

  // ── Reset ───────────────────────────────────────────────────────────────

  /// The current reset. Before the first write it is an unsaved empty draft;
  /// the first answer, skip or [setActivePrompt] makes it real.
  Journey get journey =>
      _data.currentJourney ??
      (_draftJourney ??= Journey(id: '', startedAt: now()));

  /// Earlier resets, newest first, read-only (F-034).
  List<Journey> get pastJourneys {
    final current = _data.currentJourneyId;
    return _data.journeys.where((j) => j.id != current).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  /// Starts a fresh reset. Earlier resets are kept; an untouched current
  /// reset (no answers, not completed) is replaced rather than archived.
  Future<void> startNewJourney() {
    final fresh = Journey(id: newId('journey'), startedAt: now());
    return mutate((d) {
      final current = d.currentJourney;
      final keep = d.journeys.where(
        (j) =>
            j.id != current?.id ||
            j.answers.isNotEmpty ||
            j.completedAt != null,
      );
      return d.copyWith(
        journeys: [...keep, fresh],
        currentJourneyId: () => fresh.id,
      );
    });
  }

  /// [data] with the current journey replaced by `update(current)`, creating
  /// the journey first if needed.
  AppData _withJourney(AppData d, Journey Function(Journey) update) {
    final current = d.currentJourney;
    if (current == null) {
      final created = update(Journey(id: newId('journey'), startedAt: now()));
      _draftJourney = null;
      return d.copyWith(
        journeys: [...d.journeys, created],
        currentJourneyId: () => created.id,
      );
    }
    final updated = update(current);
    return d.copyWith(
      journeys: [for (final j in d.journeys) j.id == current.id ? updated : j],
    );
  }

  ReflectionAnswer? answer(String promptId) => journey.answer(promptId);

  /// Saves [body] exactly as typed (no trimming) and clears `skipped`.
  Future<void> saveAnswer(String promptId, String body) {
    final at = now();
    return mutate(
      (d) => _withJourney(
        d,
        (j) => j.copyWith(
          answers: {
            ...j.answers,
            promptId: ReflectionAnswer(
              promptId: promptId,
              body: body,
              updatedAt: at,
            ),
          },
        ),
      ),
    );
  }

  /// Marks a prompt skipped. Any words already written are kept.
  Future<void> skipPrompt(String promptId) {
    final at = now();
    return mutate(
      (d) => _withJourney(d, (j) {
        final existing = j.answers[promptId];
        return j.copyWith(
          answers: {
            ...j.answers,
            promptId: ReflectionAnswer(
              promptId: promptId,
              body: existing?.body ?? '',
              skipped: true,
              updatedAt: at,
            ),
          },
        );
      }),
    );
  }

  Future<void> setActivePrompt(String promptId) {
    if (_data.currentJourney?.activePromptId == promptId) return Future.value();
    return mutate(
      (d) => _withJourney(d, (j) => j.copyWith(activePromptId: () => promptId)),
    );
  }

  PhaseProgress progressFor(PromptPhase phase) {
    final prompts = _content.byPhase(phase);
    var answered = 0, skipped = 0;
    for (final p in prompts) {
      final a = journey.answer(p.id);
      if (a == null) continue;
      if (a.answered) {
        answered++;
      } else if (a.skipped) {
        skipped++;
      }
    }
    return PhaseProgress(
      answered: answered,
      skipped: skipped,
      total: prompts.length,
    );
  }

  /// Answered core prompts / all core prompts (bonus excluded), 0–1.
  double get coreProgress {
    final core = _content.corePrompts;
    if (core.isEmpty) return 0;
    final answered = core.where((p) => journey.answer(p.id)?.answered ?? false);
    return answered.length / core.length;
  }

  /// Core prompts in reset order: morning, daytime, evening.
  List<Prompt> get _coreInOrder => [
    for (final phase in PromptPhase.values)
      ..._content.byPhase(phase).where((p) => p.core),
  ];

  /// Where to resume (F-037): the active prompt if it is still open, else the
  /// first core prompt after it (wrapping) that is neither answered nor
  /// skipped. Null when every core prompt was answered or skipped.
  Prompt? get nextPrompt {
    bool open(Prompt p) {
      final a = journey.answer(p.id);
      return a == null || (!a.answered && !a.skipped);
    }

    final ordered = _coreInOrder;
    if (ordered.isEmpty) return null;
    final activeId = journey.activePromptId;
    final active = activeId == null ? null : _content.prompt(activeId);
    if (active != null && open(active)) return active;
    final start = active == null
        ? 0
        : ordered.indexWhere((p) => p.id == active.id) + 1;
    for (var i = 0; i < ordered.length; i++) {
      final p = ordered[(start + i) % ordered.length];
      if (open(p)) return p;
    }
    return null;
  }

  Future<void> completeJourney() {
    final at = now();
    return mutate(
      (d) => _withJourney(d, (j) => j.copyWith(completedAt: () => at)),
    );
  }

  // ── Compass ─────────────────────────────────────────────────────────────

  LifeCompass get compass => _data.compass;

  /// Saves [value] exactly as typed.
  Future<void> updateCompassField(CompassField field, String value) {
    final at = now();
    return mutate(
      (d) => d.copyWith(compass: d.compass.withField(field, value, at)),
    );
  }

  /// Evening answers (#3–#7) that could fill a currently EMPTY Compass
  /// field, keyed by field, with the answer text exactly as written (F-024).
  /// Constraints are never mapped (F-025).
  Map<CompassField, String> get compassImportPreview {
    final preview = <CompassField, String>{};
    for (final p in _content.byPhase(PromptPhase.evening)) {
      final field = p.mapsTo;
      if (field == null || field == CompassField.constraints) continue;
      final body = journey.answer(p.id)?.body ?? '';
      if (body.trim().isEmpty) continue;
      if (compass.get(field).trim().isNotEmpty) continue;
      preview[field] = body;
    }
    return preview;
  }

  /// Copies the selected previewed answers into their EMPTY Compass fields,
  /// after saving a `beforeImport` version. Never overwrites a non-empty
  /// field. Returns how many fields were filled.
  Future<int> importCompassFromEvening(Set<CompassField> fields) async {
    final preview = compassImportPreview;
    final chosen = {
      for (final f in fields)
        if (f != CompassField.constraints && preview.containsKey(f))
          f: preview[f]!,
    };
    if (chosen.isEmpty) return 0;
    final at = now();
    await mutate((d) {
      var next = d.compass;
      for (final MapEntry(key: field, value: text) in chosen.entries) {
        if (next.get(field).trim().isEmpty) {
          next = next.withField(field, text, at);
        }
      }
      return d.copyWith(
        compass: next,
        compassHistory: _pushVersion(
          d.compassHistory,
          CompassVersion(
            savedAt: at,
            compass: d.compass,
            reason: CompassVersionReason.beforeImport,
          ),
        ),
      );
    });
    return chosen.length;
  }

  List<CompassVersion> _pushVersion(
    List<CompassVersion> history,
    CompassVersion v,
  ) {
    final next = [v, ...history];
    return next.length > kCompassHistoryLimit
        ? next.sublist(0, kCompassHistoryLimit)
        : next;
  }

  Future<void> saveCompassVersion() {
    final at = now();
    return mutate(
      (d) => d.copyWith(
        compassHistory: _pushVersion(
          d.compassHistory,
          CompassVersion(
            savedAt: at,
            compass: d.compass,
            reason: CompassVersionReason.manual,
          ),
        ),
      ),
    );
  }

  /// Restores [version] after saving the current Compass as `beforeRestore`.
  Future<void> restoreCompassVersion(CompassVersion version) {
    final at = now();
    final c = version.compass;
    return mutate(
      (d) => d.copyWith(
        compass: LifeCompass(
          antiVision: c.antiVision,
          vision: c.vision,
          yearGoal: c.yearGoal,
          monthProject: c.monthProject,
          dailyLevers: c.dailyLevers,
          constraints: c.constraints,
          updatedAt: at,
        ),
        compassHistory: _pushVersion(
          d.compassHistory,
          CompassVersion(
            savedAt: at,
            compass: d.compass,
            reason: CompassVersionReason.beforeRestore,
          ),
        ),
      ),
    );
  }

  // ── Missions ────────────────────────────────────────────────────────────

  /// Quests to show for local [day]: every daily quest created on or before
  /// it, plus one-offs that are still open or were completed on that day.
  List<Quest> questsFor(String day) => [
    for (final q in _data.quests)
      if (q.recurrence == QuestRecurrence.daily
          ? dateKey(q.createdAt).compareTo(day) <= 0
          : !q.isDoneOn(day) || q.completedOn.contains(day))
        q,
  ];

  Quest? questById(String id) {
    for (final q in _data.quests) {
      if (q.id == id) return q;
    }
    return null;
  }

  Future<Quest> addQuest(
    String title, {
    QuestRecurrence recurrence = QuestRecurrence.none,
    String? dueDate,
    QuestSource source = QuestSource.manual,
  }) async {
    final text = title.trim();
    if (text.isEmpty) throw ArgumentError.value(title, 'title', 'is empty');
    if (dueDate != null) parseDateKey(dueDate);
    final quest = Quest(
      id: newId('quest'),
      title: text,
      createdAt: now(),
      recurrence: recurrence,
      dueDate: dueDate,
      source: source,
    );
    await mutate(
      (d) => _questsIntroduced(d).copyWith(quests: [...d.quests, quest]),
    );
    return quest;
  }

  /// Marks the quests hint as seen: once a quest existed, "Quests are small
  /// steps…" never returns, even after every quest is deleted.
  static AppData _questsIntroduced(AppData d) =>
      d.settings.hintsSeen.contains(FirstUseHint.quests)
      ? d
      : d.copyWith(
          settings: d.settings.copyWith(
            hintsSeen: {...d.settings.hintsSeen, FirstUseHint.quests},
          ),
        );

  Future<void> updateQuest(Quest quest) => mutate(
    (d) => d.copyWith(
      quests: [for (final q in d.quests) q.id == quest.id ? quest : q],
    ),
  );

  /// Completes or reopens a quest for local [day] (default today). A one-off
  /// quest reopened is open on every day again.
  Future<void> setQuestDone(String id, bool done, {String? day}) {
    final key = day ?? today;
    parseDateKey(key);
    return mutate(
      (d) => d.copyWith(
        quests: [
          for (final q in d.quests)
            if (q.id != id)
              q
            else if (q.recurrence == QuestRecurrence.daily)
              q.copyWith(
                completedOn: done
                    ? {...q.completedOn, key}
                    : ({...q.completedOn}..remove(key)),
              )
            else
              q.copyWith(completedOn: done ? {key} : const {}),
        ],
      ),
    );
  }

  /// Deletes a quest. A quest existed, so the quests hint stays seen.
  Future<void> deleteQuest(String id) => mutate(
    (d) => _questsIntroduced(d).copyWith(
      quests: [
        for (final q in d.quests)
          if (q.id != id) q,
      ],
    ),
  );

  static final _bullet = RegExp(r'^\s*(?:[-*•]|\d+[.)])\s*');

  /// Up to three draft quests from Compass › daily levers (F-028): one per
  /// line, leading bullets/numbers stripped, trimmed; lines that exactly
  /// (case-insensitively) match an existing quest are left out.
  List<String> get leverDrafts {
    final existing = {
      for (final q in _data.quests) q.title.trim().toLowerCase(),
    };
    final drafts = <String>[];
    for (final line in compass.dailyLevers.split(RegExp(r'\r?\n'))) {
      final text = line.replaceFirst(_bullet, '').trim();
      if (text.isEmpty) continue;
      final key = text.toLowerCase();
      if (existing.contains(key)) continue;
      if (drafts.any((t) => t.toLowerCase() == key)) continue;
      drafts.add(text);
      if (drafts.length == 3) break;
    }
    return drafts;
  }

  /// Adds the approved (possibly edited) lever drafts as daily quests.
  /// Empty titles and titles that already exist are ignored. Returns how many
  /// quests were added.
  Future<int> addQuestsFromLevers(List<String> titles) async {
    final seen = {for (final q in _data.quests) q.title.trim().toLowerCase()};
    final at = now();
    final added = <Quest>[];
    for (final title in titles) {
      final text = title.trim();
      if (text.isEmpty || !seen.add(text.toLowerCase())) continue;
      added.add(
        Quest(
          id: newId('quest'),
          title: text,
          createdAt: at,
          recurrence: QuestRecurrence.daily,
          source: QuestSource.dailyLever,
        ),
      );
    }
    if (added.isEmpty) return 0;
    await mutate(
      (d) => _questsIntroduced(d).copyWith(quests: [...d.quests, ...added]),
    );
    return added.length;
  }

  Future<void> saveProject(MonthProject? project) =>
      mutate((d) => d.copyWith(project: () => project));

  /// Saves the thirty-day path note for [day] (1–30) exactly as typed.
  Future<void> savePathAnswer(int day, String body) {
    if (day < 1 || day > 30) throw RangeError.range(day, 1, 30, 'day');
    final at = now();
    return mutate(
      (d) => d.copyWith(
        pathAnswers: {
          ...d.pathAnswers,
          day: PathAnswer(day: day, body: body, updatedAt: at),
        },
      ),
    );
  }

  // ── Journal & reviews ───────────────────────────────────────────────────

  Future<JournalEntry> addJournalEntry({
    String? title,
    required String body,
  }) async {
    final entry = JournalEntry(
      id: newId('note'),
      title: title,
      body: body,
      createdAt: now(),
    );
    await mutate((d) => d.copyWith(journal: [entry, ...d.journal]));
    return entry;
  }

  /// Replaces the entry with the same id; keeps its creation time and stamps
  /// `editedAt`.
  Future<void> updateJournalEntry(JournalEntry entry) {
    final at = now();
    return mutate(
      (d) => d.copyWith(
        journal: [
          for (final e in d.journal)
            if (e.id == entry.id)
              JournalEntry(
                id: e.id,
                title: entry.title,
                body: entry.body,
                createdAt: e.createdAt,
                editedAt: at,
              )
            else
              e,
        ],
      ),
    );
  }

  Future<void> deleteJournalEntry(String id) => mutate(
    (d) => d.copyWith(
      journal: [
        for (final e in d.journal)
          if (e.id != id) e,
      ],
    ),
  );

  /// Creates (no/unknown [id]) or updates a weekly review. Reviews are kept
  /// newest week first.
  Future<WeeklyReview> saveReview({
    String? id,
    required String weekStart,
    required String wins,
    required String friction,
    required String nextExperiment,
  }) async {
    parseDateKey(weekStart);
    final at = now();
    WeeklyReview? existing;
    for (final r in _data.reviews) {
      if (r.id == id) existing = r;
    }
    final review = WeeklyReview(
      id: existing?.id ?? newId('review'),
      weekStart: weekStart,
      wins: wins,
      friction: friction,
      nextExperiment: nextExperiment,
      createdAt: existing?.createdAt ?? at,
      editedAt: existing == null ? null : at,
    );
    await mutate((d) {
      final others = [
        for (final r in d.reviews)
          if (r.id != review.id) r,
      ];
      return d.copyWith(
        reviews: [review, ...others]
          ..sort((a, b) {
            final byWeek = b.weekStart.compareTo(a.weekStart);
            return byWeek != 0 ? byWeek : b.createdAt.compareTo(a.createdAt);
          }),
      );
    });
    return review;
  }

  Future<void> deleteReview(String id) => mutate(
    (d) => d.copyWith(
      reviews: [
        for (final r in d.reviews)
          if (r.id != id) r,
      ],
    ),
  );

  // ── Reminders (F-016–F-018) ─────────────────────────────────────────────

  /// The six check-in preferences in prompt order: saved ones, else the
  /// daytime prompts' source default times (enabled).
  List<ReminderPreference> get reminders {
    final saved = {for (final r in _data.reminders) r.promptId: r};
    return [
      for (final p in _content.byPhase(PromptPhase.daytime))
        if (p.defaultTime != null)
          saved[p.id] ??
              ReminderPreference(promptId: p.id, time: p.defaultTime!),
    ];
  }

  Future<void> setReminder(ReminderPreference pref) async {
    parseClock(pref.time);
    await mutate(
      (d) => d.copyWith(
        reminders: [
          for (final r in d.reminders)
            if (r.promptId != pref.promptId) r,
          pref,
        ],
      ),
    );
    await _replan();
  }

  /// Asks for permission; only on [ReminderPermission.granted] are reminders
  /// switched on and scheduled. Denial is returned, never hidden.
  Future<ReminderPermission> enableReminders() async {
    final permission = await _scheduler.requestPermission();
    final enabled = permission == ReminderPermission.granted;
    if (settings.remindersEnabled != enabled) {
      await mutate(
        (d) => d.copyWith(
          settings: d.settings.copyWith(remindersEnabled: enabled),
        ),
      );
    }
    await _replan();
    return permission;
  }

  Future<void> disableReminders() async {
    if (settings.remindersEnabled) {
      await mutate(
        (d) =>
            d.copyWith(settings: d.settings.copyWith(remindersEnabled: false)),
      );
    }
    await _replan();
  }

  /// Prompt ids of check-in notifications tapped while the app runs.
  Stream<String> get reminderTaps => _scheduler.taps;

  /// Prompt id of the check-in notification that launched the app, once.
  Future<String?> takeLaunchReminder() => _scheduler.takeLaunchPayload();

  /// The notifications that should exist right now.
  List<PlannedReminder> get plannedReminders => planReminders(
    preferences: reminders,
    titles: {for (final p in _content.prompts) p.id: p.title},
    enabled: settings.remindersEnabled,
    quietStart: settings.quietStart,
    quietEnd: settings.quietEnd,
  );

  Future<void> _replan() async {
    try {
      final plans = plannedReminders;
      if (plans.isEmpty) {
        await _scheduler.cancelAll();
      } else {
        await _scheduler.schedule(plans);
      }
      _reminderError = null;
    } on Object catch (e) {
      _reminderError = e;
    }
    notifyListeners();
  }

  /// Names the Android notification channel in the user's language (the
  /// UI calls this whenever its localizations change).
  void localizeReminders({
    required String channelName,
    required String channelDescription,
  }) => _scheduler.setChannelText(
    name: channelName,
    description: channelDescription,
  );

  /// The 30-day `.ics` of the enabled check-ins (prompt titles only), worded
  /// with [texts] (localized by the UI).
  String calendarExport(CalendarTexts texts) {
    final titles = {for (final p in _content.prompts) p.id: p.title};
    return buildCheckinCalendar(
      texts: texts,
      now: now(),
      checkins: [
        for (final r in reminders)
          if (r.enabled)
            () {
              final (h, m) = parseClock(r.time);
              return IcsCheckin(
                promptId: r.promptId,
                title: titles[r.promptId] ?? '',
                hour: h,
                minute: m,
              );
            }(),
      ],
    );
  }

  // ── Data (F-040–F-043) ──────────────────────────────────────────────────

  /// Everything the user owns, as the documented JSON backup.
  String exportBackup() => encodeBackup(_data, now());

  /// Replaces all data with a backup. The text is fully decoded and
  /// validated first; a [FormatException] leaves current data untouched.
  /// Notification consent is per device, so `remindersEnabled` keeps this
  /// device's value.
  Future<void> importBackup(String text) async {
    final incoming = decodeBackup(text);
    final remindersOn = settings.remindersEnabled;
    _draftJourney = null;
    // A restore replaces everything: nothing in it is a new moment.
    _dataGeneration++;
    await mutate(
      (_) => incoming.copyWith(
        settings: incoming.settings.copyWith(remindersEnabled: remindersOn),
      ),
    );
    await _replan();
  }

  /// Cancels reminders, deletes the saved file and returns to onboarding.
  /// Throws if the file couldn't be deleted (data is then left as it was).
  Future<void> deleteAllData() async {
    try {
      await _scheduler.cancelAll();
    } on Object catch (e) {
      _reminderError = e;
    }
    await _writeQueue;
    await _store.clear();
    _data = AppData.empty;
    _dataGeneration++;
    _draftJourney = null;
    _saveStatus = SaveStatus.idle;
    _saveError = null;
    notifyListeners();
  }
}
