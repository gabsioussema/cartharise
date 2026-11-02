import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../state/app_state.dart';
import '../missions/project_ops.dart';

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
  /// Compass's one-month project (as on Today) — unless that one is already
  /// finished and kept in the project history.
  String get monthlyBoss {
    final project = data.project?.title.trim() ?? '';
    if (project.isNotEmpty) return project;
    return compassProjectFinished ? '' : compass.monthProject;
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
  /// draft is removed in the same change. While a project is active the
  /// attempt is linked to it ([AppState.activeProjectId]); [attachments]
  /// are photos and recordings already in the attachment store.
  Future<BattleLogEntry> recordAttempt(
    String attempt, {
    String learning = '',
    List<Attachment> attachments = const [],
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
      projectId: activeProjectId,
      attachments: attachments,
    );
    await mutate(
      (d) => d.copyWith(
        campaignLog: [entry, ...d.campaignLog],
        attemptDraft: () => null,
      ),
    );
    return entry;
  }

  /// Corrects an attempt (its day stays the day it was recorded; its
  /// project and attachments are kept).
  Future<void> editAttempt(
    String id, {
    required String attempt,
    required String learning,
  }) {
    if (attempt.trim().isEmpty) {
      throw ArgumentError.value(attempt, 'attempt', 'must not be blank');
    }
    final at = now();
    return mutate(
      (d) => d.copyWith(
        campaignLog: [
          for (final e in d.campaignLog)
            if (e.id == id)
              e.copyWith(
                attempt: attempt,
                learning: learning,
                editedAt: () => at,
              )
            else
              e,
        ],
      ),
    );
  }

  /// Links an attempt to the project [projectId] (current or past), or with
  /// null, unlinks it.
  Future<void> setAttemptProject(String id, String? projectId) => mutate(
    (d) => d.copyWith(
      campaignLog: [
        for (final e in d.campaignLog)
          if (e.id == id) e.copyWith(projectId: () => projectId) else e,
      ],
    ),
  );

  /// Deletes an attempt, its photos and recordings (once saved) and the
  /// pinned memory taken from it.
  Future<void> deleteAttempt(String id) async {
    final removed = data.attachmentsOf(AttachmentHolder.attempt, id);
    await mutate(
      (d) => AppState.withoutPinFrom(
        d.copyWith(
          campaignLog: [
            for (final e in d.campaignLog)
              if (e.id != id) e,
          ],
        ),
        id,
      ),
    );
    await releaseAttachments(removed);
  }

  // ── The Playground ("Try") ──────────────────────────────────────────────

  /// Experiments tried, newest first.
  List<ExperimentEntry> get experimentLog => data.experimentLog;

  /// Whether [experimentId] was tried at least once.
  bool hasTried(String experimentId) =>
      data.experimentLog.any((e) => e.experimentId == experimentId);

  /// The unsent "Try" note for [experimentId] ('' when none).
  String tryNoteDraft(String experimentId) =>
      data.tryNoteDrafts[experimentId] ?? '';

  /// Autosaves the "Try" note for [experimentId] exactly as typed (debounce
  /// it in the UI). A blank note removes the draft; nothing is written when
  /// nothing changed.
  Future<void> saveTryNoteDraft(String experimentId, String note) {
    final blank = note.trim().isEmpty;
    final current = data.tryNoteDrafts[experimentId];
    if (blank ? current == null : current == note) return Future.value();
    return mutate(
      (d) => d.copyWith(
        tryNoteDrafts: {
          for (final e in d.tryNoteDrafts.entries)
            if (e.key != experimentId) e.key: e.value,
          if (!blank) experimentId: note,
        },
      ),
    );
  }

  /// Records that the user tried [experimentId] today, with an optional
  /// [note] stored exactly as typed; the experiment's note draft is removed
  /// in the same change. Trying it again adds another entry; XP counts each
  /// experiment once ([kXpPerExperiment]). Throws [ArgumentError] for an id
  /// the content does not have.
  /// [attachments] are photos and recordings already in the attachment
  /// store.
  Future<ExperimentEntry> tryExperiment(
    String experimentId, {
    String note = '',
    List<Attachment> attachments = const [],
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
      attachments: attachments,
    );
    await mutate(
      (d) => d.copyWith(
        experimentLog: [entry, ...d.experimentLog],
        tryNoteDrafts: d.tryNoteDrafts.containsKey(experimentId)
            ? {
                for (final e in d.tryNoteDrafts.entries)
                  if (e.key != experimentId) e.key: e.value,
              }
            : null,
      ),
    );
    return entry;
  }

  /// Corrects the note of a tried experiment (exactly as typed; '' = none).
  /// Its day stays the day it was tried; its attachments are kept.
  Future<void> editExperimentEntry(String id, {required String note}) {
    final at = now();
    return mutate(
      (d) => d.copyWith(
        experimentLog: [
          for (final e in d.experimentLog)
            if (e.id == id) e.copyWith(note: note, editedAt: () => at) else e,
        ],
      ),
    );
  }

  /// Deletes a tried experiment, its photos and recordings (once saved) and
  /// the pinned memory taken from it.
  Future<void> deleteExperimentEntry(String id) async {
    final removed = data.attachmentsOf(AttachmentHolder.experiment, id);
    await mutate(
      (d) => AppState.withoutPinFrom(
        d.copyWith(
          experimentLog: [
            for (final e in d.experimentLog)
              if (e.id != id) e,
          ],
        ),
        id,
      ),
    );
    await releaseAttachments(removed);
  }

  /// "Add to my tasks": a one-off quest titled like the experiment, with
  /// [QuestSource.experiment]. While that quest is still open, adding it
  /// again returns it instead of a duplicate. Adding earns nothing; the
  /// quest earns quest XP when done, like any other. Playground experiments
  /// stay apart from the month project (not linked to it). Throws
  /// [ArgumentError] for an id the content does not have.
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
    return addQuest(title, source: QuestSource.experiment, linkProject: false);
  }
}
