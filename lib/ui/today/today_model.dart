/// What the Today tab shows, derived from stored state: the greeting's part
/// of day and the "Your journey" summary (F-036, F-054). Counts only —
/// never a judgement, a streak or a score.
library;

import 'package:flutter/foundation.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../state/app_state.dart';

enum DayPart { morning, afternoon, evening }

/// Morning 04:00–11:59, afternoon 12:00–17:59, evening otherwise (local).
DayPart dayPartAt(DateTime time) {
  final hour = time.toLocal().hour;
  if (hour >= 4 && hour < 12) return DayPart.morning;
  if (hour >= 12 && hour < 18) return DayPart.afternoon;
  return DayPart.evening;
}

/// One-line first-use hints that introduce a feature where it first shows
/// up on Today; they replace the welcome carousel's pages (reset, direction,
/// small steps). Each is derived from stored data — nothing extra is saved —
/// and shows only until the feature is first used, so once used it never
/// comes back.
@immutable
class FirstUseHints {
  const FirstUseHints({
    required this.reset,
    required this.compass,
    required this.quests,
  });

  factory FirstUseHints.of(AppData data) => FirstUseHints(
    reset: data.journeys.every(
      (j) =>
          j.answers.isEmpty &&
          j.activePromptId == null &&
          j.completedAt == null,
    ),
    compass: data.compass.isEmpty && data.compassHistory.isEmpty,
    quests: data.quests.isEmpty,
  );

  /// No reset was ever begun: the start card says what the reset is.
  final bool reset;

  /// The Compass was never written (nor saved as a version): the direction
  /// card says answers can become a Compass.
  final bool compass;

  /// No quest exists yet: the quests card says what quests are.
  final bool quests;
}

/// The core phases shown on Today (bonus contemplations are optional and
/// never counted).
const kCorePhases = [
  PromptPhase.morning,
  PromptPhase.daytime,
  PromptPhase.evening,
];

/// The thirty-day day the user is "at": the one written most recently
/// (ties → the higher day). Null when no day has words.
int? currentPathDay(Map<int, PathAnswer> answers) {
  PathAnswer? latest;
  for (final a in answers.values) {
    if (a.body.trim().isEmpty) continue;
    if (latest == null ||
        a.updatedAt.isAfter(latest.updatedAt) ||
        (a.updatedAt == latest.updatedAt && a.day > latest.day)) {
      latest = a;
    }
  }
  return latest?.day;
}

/// The first day after [current] without words, else [current] itself.
int nextPathDay(Map<int, PathAnswer> answers, int current) {
  for (var d = current + 1; d <= 30; d++) {
    if ((answers[d]?.body.trim() ?? '').isEmpty) return d;
  }
  return current;
}

@immutable
class PhaseSummary {
  const PhaseSummary(this.phase, this.progress);
  final PromptPhase phase;
  final PhaseProgress progress;
}

/// "Your journey": reset progress in words, and the thirty-day path day only
/// when the user has written on the path.
@immutable
class JourneySummary {
  const JourneySummary({
    required this.answered,
    required this.total,
    required this.started,
    required this.completed,
    required this.allTouched,
    required this.phases,
    this.pathDay,
    this.pathStage,
    this.pathNextDay,
  });

  factory JourneySummary.of(AppState state) {
    final journey = state.journey;
    final core = state.content.corePrompts;
    final answered = core
        .where((p) => journey.answer(p.id)?.answered ?? false)
        .length;
    final day = currentPathDay(state.data.pathAnswers);
    PathStage? stage;
    if (day != null) {
      for (final d in state.content.thirtyDays) {
        if (d.day == day) stage = d.stage;
      }
    }
    final started =
        journey.answers.isNotEmpty || journey.activePromptId != null;
    return JourneySummary(
      answered: answered,
      total: core.length,
      started: started,
      completed: journey.completedAt != null,
      allTouched: started && state.nextPrompt == null,
      phases: [
        for (final phase in kCorePhases)
          PhaseSummary(phase, state.progressFor(phase)),
      ],
      pathDay: day,
      pathStage: stage,
      pathNextDay: day == null
          ? null
          : nextPathDay(state.data.pathAnswers, day),
    );
  }

  /// Core reflections with written words / all core reflections.
  final int answered;
  final int total;
  final bool started;
  final bool completed;

  /// Every core prompt is answered or deliberately skipped.
  final bool allTouched;
  final List<PhaseSummary> phases;

  /// Thirty-day path: where the user is (null = not opened → not shown).
  final int? pathDay;
  final PathStage? pathStage;
  final int? pathNextDay;

  double get fraction => total == 0 ? 0 : answered / total;
}
