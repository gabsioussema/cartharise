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

  Future<void> setGameEnabled(bool enabled) =>
      updateSettings(settings.copyWith(game: enabled));

  /// The monthly "boss": the Missions project title if set, else the
  /// Compass's one-month project (as on Today).
  String get monthlyBoss {
    final project = data.project?.title.trim() ?? '';
    return project.isNotEmpty ? project : compass.monthProject;
  }

  /// Records an attempt at the monthly project for today (F-061). The words
  /// are stored exactly as typed; [attempt] must not be blank.
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
    await mutate((d) => d.copyWith(campaignLog: [entry, ...d.campaignLog]));
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
}
