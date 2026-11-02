import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../state/app_state.dart';

/// Campaign operations on top of [AppState.mutate] (PLAN.md §4: feature
/// extensions live in the feature's folder).
extension CampaignOps on AppState {
  /// Chapters, XP, level and achievements, derived from the saved data.
  CampaignProgress get campaign => campaignProgress(data, content);

  /// Whether the user keeps the Campaign game layer on (F-060).
  bool get gameEnabled => settings.game;

  /// Turns the game layer on or off (You › The Campaign). Choosing there
  /// also answers the one-time invitation, so it isn't asked again.
  Future<void> setGameEnabled(bool enabled) =>
      updateSettings(settings.copyWith(game: enabled, gameInvited: true));

  /// The monthly "boss": the Missions project title if set, else the
  /// Compass's one-month project (as on Today).
  String get monthlyBoss {
    final project = data.project?.title.trim() ?? '';
    return project.isNotEmpty ? project : compass.monthProject;
  }

  // ── Battle log ──────────────────────────────────────────────────────────

  /// The attempt form's unsent words, if any.
  AttemptDraft? get attemptDraft => data.attemptDraft;

  /// Autosaves the attempt form (debounce it in the UI, like the Compass):
  /// both fields exactly as typed. Both blank → the draft is removed.
  /// Nothing is written when nothing changed.
  Future<void> saveAttemptDraft(String attempt, String learning) {
    final current = data.attemptDraft;
    final blank = attempt.trim().isEmpty && learning.trim().isEmpty;
    final unchanged = blank
        ? current == null
        : current?.attempt == attempt && current?.learning == learning;
    if (unchanged) return Future.value();
    final at = now();
    return mutate(
      (d) => d.copyWith(
        attemptDraft: () => blank
            ? null
            : AttemptDraft(attempt: attempt, learning: learning, updatedAt: at),
      ),
    );
  }

  /// Records an attempt at the monthly project for today (F-061). The words
  /// are stored exactly as typed; [attempt] must not be blank. The attempt
  /// draft is removed in the same change.
  Future<BattleLogEntry> recordAttempt(
    String attempt, {
    String learning = '',
  }) async {
    if (attempt.trim().isEmpty) {
      throw ArgumentError.value(attempt, 'attempt', 'must not be blank');
    }
    final entry = BattleLogEntry(
      id: newId('attempt'),
      day: today,
      attempt: attempt,
      learning: learning,
      createdAt: now(),
    );
    await mutate(
      (d) => d.copyWith(
        campaignLog: [entry, ...d.campaignLog],
        attemptDraft: () => null,
      ),
    );
    return entry;
  }

  /// Corrects an attempt (its day stays the day it was recorded).
  Future<void> editAttempt(
    String id, {
    required String attempt,
    required String learning,
  }) {
    if (attempt.trim().isEmpty) {
      throw ArgumentError.value(attempt, 'attempt', 'must not be blank');
    }
    return mutate(
      (d) => d.copyWith(
        campaignLog: [
          for (final e in d.campaignLog)
            if (e.id == id)
              BattleLogEntry(
                id: e.id,
                day: e.day,
                attempt: attempt,
                learning: learning,
                createdAt: e.createdAt,
                editedAt: now(),
              )
            else
              e,
        ],
      ),
    );
  }

  Future<void> deleteAttempt(String id) => mutate(
    (d) => d.copyWith(
      campaignLog: [
        for (final e in d.campaignLog)
          if (e.id != id) e,
      ],
    ),
  );

  // ── The Playground ("Try") ──────────────────────────────────────────────

  /// Experiments tried, newest first.
  List<ExperimentEntry> get experimentLog => data.experimentLog;

  /// Whether [experimentId] was tried at least once.
  bool hasTried(String experimentId) =>
      data.experimentLog.any((e) => e.experimentId == experimentId);

  /// Records that the user tried [experimentId] today, with an optional
  /// [note] stored exactly as typed. Trying it again adds another entry;
  /// XP counts each experiment once ([kXpPerExperiment]). Throws
  /// [ArgumentError] for an id the content does not have.
  Future<ExperimentEntry> tryExperiment(
    String experimentId, {
    String note = '',
  }) async {
    if (content.experiment(experimentId) == null) {
      throw ArgumentError.value(experimentId, 'experimentId', 'is unknown');
    }
    final entry = ExperimentEntry(
      id: newId('try'),
      experimentId: experimentId,
      day: today,
      note: note,
      createdAt: now(),
    );
    await mutate((d) => d.copyWith(experimentLog: [entry, ...d.experimentLog]));
    return entry;
  }

  /// Corrects the note of a tried experiment (exactly as typed; '' = none).
  /// Its day stays the day it was tried.
  Future<void> editExperimentEntry(String id, {required String note}) {
    final at = now();
    return mutate(
      (d) => d.copyWith(
        experimentLog: [
          for (final e in d.experimentLog)
            if (e.id == id)
              ExperimentEntry(
                id: e.id,
                experimentId: e.experimentId,
                day: e.day,
                note: note,
                createdAt: e.createdAt,
                editedAt: at,
              )
            else
              e,
        ],
      ),
    );
  }

  Future<void> deleteExperimentEntry(String id) => mutate(
    (d) => d.copyWith(
      experimentLog: [
        for (final e in d.experimentLog)
          if (e.id != id) e,
      ],
    ),
  );

  /// "Add to my tasks": a one-off quest titled like the experiment, with
  /// [QuestSource.experiment]. While that quest is still open, adding it
  /// again returns it instead of a duplicate. Adding earns nothing; the
  /// quest earns quest XP when done, like any other. Throws [ArgumentError]
  /// for an id the content does not have.
  Future<Quest> addExperimentToTasks(String experimentId) {
    final experiment = content.experiment(experimentId);
    if (experiment == null) {
      throw ArgumentError.value(experimentId, 'experimentId', 'is unknown');
    }
    final title = experiment.title.trim();
    for (final q in data.quests) {
      if (q.source == QuestSource.experiment &&
          q.title == title &&
          !q.isDoneOn(today)) {
        return Future.value(q);
      }
    }
    return addQuest(title, source: QuestSource.experiment);
  }
}
