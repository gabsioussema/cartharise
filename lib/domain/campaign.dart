/// The Campaign (F-058–F-064): the article's "life as a game" framing, as an
/// optional layer over the reset, the Compass and the quests.
///
/// Everything here is derived from what the user already recorded, so it can
/// never be farmed by repeating an action, never drops because of rest, and
/// never looks at what was written — only whether an exercise or action took
/// place.
library;

import 'app_data.dart';
import 'content.dart';

export 'content.dart' show CampaignChapter;

/// XP for each core reset question answered (once per question, ever).
const int kXpPerReflection = 5;

/// XP for each completed quest, counting at most [kQuestDaysCap] a day.
const int kXpPerQuest = 20;

/// Most quest completions that earn XP on one local day.
const int kQuestDaysCap = 3;

/// XP for each day of the thirty-day path the user wrote.
const int kXpPerPathDay = 10;

/// XP for each day with at least one battle-log attempt.
const int kXpPerAttemptDay = 15;

/// XP for each weekly review (one per week).
const int kXpPerReview = 15;

/// XP for each distinct Playground experiment tried (once each, ever).
const int kXpPerExperiment = 10;

/// XP per level.
const int kXpPerLevel = 100;

/// The level route: Hannibal's march from Carthage into Italy (218 BC). Each
/// level is the next waypoint; places, never labels for the person. From
/// [italy] on, levels keep counting — the campaign has no end.
enum Waypoint { carthage, newCarthage, ebro, pyrenees, rhone, alps, italy }

/// The waypoint reached at [level].
Waypoint waypointFor(int level) =>
    Waypoint.values[(level - 1).clamp(0, Waypoint.values.length - 1)];

/// Article-based achievements (F-062), earned only for observable
/// activities — never for what was written or how it felt. The five chapter
/// achievements name their [chapter]; the last two are earned by doing.
enum Achievement {
  observer(CampaignChapter.terrain),
  pathfinder(CampaignChapter.pattern),
  visionary(CampaignChapter.banner),
  watchful(CampaignChapter.autopilot),
  strategist(CampaignChapter.plan),
  practitioner(null),
  challenger(null);

  const Achievement(this.chapter);

  /// The chapter this achievement belongs to; null for the two earned by
  /// doing (a completed quest, a first attempt).
  final CampaignChapter? chapter;

  /// The chapter achievement of [chapter].
  static Achievement ofChapter(CampaignChapter chapter) =>
      values.firstWhere((a) => a.chapter == chapter);
}

/// How an achievement was earned, so the app can say which route it was.
/// A chapter's achievement: [reflecting] (every chapter question answered
/// in one reset) or [trying] (one of its experiments tried); The
/// Practitioner and The Challenger: [doing].
enum EarnedRoute { reflecting, trying, doing }

/// A chapter's progress in the current reset.
class ChapterProgress {
  const ChapterProgress({
    required this.chapter,
    required this.promptIds,
    required this.answered,
    this.tried = 0,
  });

  final CampaignChapter chapter;
  final List<String> promptIds;

  /// How many of [promptIds] have an answer in the current reset.
  final int answered;

  /// How many of the chapter's experiments were tried, ever (each once).
  final int tried;

  int get total => promptIds.length;
  bool get explored => total > 0 && answered == total;
}

/// Everything the Campaign shows, derived from [AppData].
class CampaignProgress {
  const CampaignProgress({
    required this.xp,
    required this.chapters,
    required this.questsCompleted,
    required this.pathDaysWritten,
    required this.attempts,
    this.earnedBy = const {},
    this.earnedByExperiment = const {},
    this.xpFromActions = 0,
    this.experimentsTried = 0,
    this.milestones = 0,
    this.milestonesDone = 0,
  });

  final int xp;

  /// The part of [xp] from discrete actions (quests, attempts, reviews,
  /// experiments tried) — what a "+XP" moment celebrates; typing answers is
  /// never interrupted.
  final int xpFromActions;

  /// The monthly boss's milestones (the Missions project) and how many are
  /// done: the boss weakens only as real milestones are reached.
  final int milestones;
  final int milestonesDone;
  final List<ChapterProgress> chapters;

  /// Every achievement earned, with the route that earned it, in the
  /// article's order.
  final Map<Achievement, EarnedRoute> earnedBy;

  /// For each chapter achievement earned by [EarnedRoute.trying], the id of
  /// the experiment that earned it (the chapter's first one tried), so the
  /// app can name it.
  final Map<Achievement, String> earnedByExperiment;

  /// Every completed quest (a daily quest counts once per day).
  final int questsCompleted;
  final int pathDaysWritten;

  /// Battle-log entries.
  final int attempts;

  /// Distinct Playground experiments tried (each counts once, ever).
  final int experimentsTried;

  /// The achievements earned, in the article's order.
  Set<Achievement> get earned => earnedBy.keys.toSet();

  int get level => 1 + xp ~/ kXpPerLevel;

  /// XP gathered towards the next level (0 to [kXpPerLevel] − 1).
  int get levelXp => xp % kXpPerLevel;

  int get chaptersExplored => chapters.where((c) => c.explored).length;

  Waypoint get waypoint => waypointFor(level);

  /// The next waypoint, or null once in Italy.
  Waypoint? get nextWaypoint => waypoint == Waypoint.values.last
      ? null
      : Waypoint.values[waypoint.index + 1];

  /// XP still to gather for the next level.
  int get xpToNext => kXpPerLevel - levelXp;

  /// The first achievement not earned yet, in the article's order.
  Achievement? get nextAchievement {
    for (final a in Achievement.values) {
      if (!earnedBy.containsKey(a)) return a;
    }
    return null;
  }
}

/// Reward picks the Campaign has given (spent or not): one for each route
/// stop reached after Carthage and one for each achievement earned. The user
/// spends a pick on an avatar extra of their choice (`chooseReward`); this
/// count is derived, so it can go down, but a chosen extra is never taken
/// away.
int rewardPicksEarned(CampaignProgress progress) =>
    progress.waypoint.index + progress.earnedBy.length;

/// The Campaign for [data], with the chapters and experiments taken from
/// [content].
CampaignProgress campaignProgress(AppData data, ContentLibrary content) {
  final current = data.currentJourney;

  // Experiments: each distinct one once, ever (repeating one adds nothing).
  // The log is newest first, so walking it backwards meets each chapter's
  // first try first.
  final tried = <String>{};
  final triedPerChapter = <CampaignChapter, int>{};
  final firstTried = <CampaignChapter, String>{};
  for (final e in data.experimentLog.reversed) {
    if (!tried.add(e.experimentId)) continue;
    final chapter = content.experiment(e.experimentId)?.chapter;
    if (chapter != null) {
      triedPerChapter[chapter] = (triedPerChapter[chapter] ?? 0) + 1;
      firstTried[chapter] ??= e.experimentId;
    }
  }

  ChapterProgress progressOf(CampaignChapter chapter) {
    final ids = chapter.promptIds(content);
    final answered = current == null
        ? 0
        : ids.where((id) => current.answer(id)?.answered ?? false).length;
    return ChapterProgress(
      chapter: chapter,
      promptIds: ids,
      answered: answered,
      tried: triedPerChapter[chapter] ?? 0,
    );
  }

  final chapters = [
    for (final chapter in CampaignChapter.values) progressOf(chapter),
  ];

  // Reflections: each core question once, across every reset.
  final core = {for (final p in content.corePrompts) p.id};
  final reflected = <String>{
    for (final j in data.journeys)
      for (final a in j.answers.values)
        if (a.answered && core.contains(a.promptId)) a.promptId,
  };

  // Quests: every completion, at most [kQuestDaysCap] a day for XP.
  final perDay = <String, int>{};
  for (final q in data.quests) {
    for (final day in q.completedOn) {
      perDay[day] = (perDay[day] ?? 0) + 1;
    }
  }
  final questsCompleted = perDay.values.fold(0, (a, b) => a + b);
  final questXpCount = perDay.values.fold(
    0,
    (a, b) => a + (b < kQuestDaysCap ? b : kQuestDaysCap),
  );

  final pathDays = data.pathAnswers.values
      .where((a) => a.body.trim().isNotEmpty)
      .length;
  final attemptDays = {for (final e in data.campaignLog) e.day}.length;
  final reviewWeeks = {for (final r in data.reviews) r.weekStart}.length;

  final xpFromActions =
      questXpCount * kXpPerQuest +
      attemptDays * kXpPerAttemptDay +
      reviewWeeks * kXpPerReview +
      tried.length * kXpPerExperiment;
  final xp =
      reflected.length * kXpPerReflection +
      pathDays * kXpPerPathDay +
      xpFromActions;

  // A chapter's achievement: every chapter question answered in one reset,
  // or any of the chapter's experiments tried. Reflecting is named when
  // both are true.
  bool everExplored(CampaignChapter chapter) {
    final ids = chapter.promptIds(content);
    if (ids.isEmpty) return false;
    return data.journeys.any(
      (j) => ids.every((id) => j.answer(id)?.answered ?? false),
    );
  }

  EarnedRoute? routeOf(Achievement a) => switch (a) {
    Achievement.practitioner => questsCompleted > 0 ? EarnedRoute.doing : null,
    Achievement.challenger =>
      data.campaignLog.isNotEmpty ? EarnedRoute.doing : null,
    Achievement(chapter: final chapter?) =>
      everExplored(chapter)
          ? EarnedRoute.reflecting
          : (triedPerChapter[chapter] ?? 0) > 0
          ? EarnedRoute.trying
          : null,
    _ => null,
  };

  final earnedBy = <Achievement, EarnedRoute>{};
  final earnedByExperiment = <Achievement, String>{};
  for (final a in Achievement.values) {
    final route = routeOf(a);
    if (route == null) continue;
    earnedBy[a] = route;
    final experiment = firstTried[a.chapter];
    if (route == EarnedRoute.trying && experiment != null) {
      earnedByExperiment[a] = experiment;
    }
  }

  final milestones = data.project?.milestones ?? const [];
  return CampaignProgress(
    xp: xp,
    xpFromActions: xpFromActions,
    chapters: chapters,
    earnedBy: earnedBy,
    earnedByExperiment: earnedByExperiment,
    questsCompleted: questsCompleted,
    pathDaysWritten: pathDays,
    attempts: data.campaignLog.length,
    experimentsTried: tried.length,
    milestones: milestones.length,
    milestonesDone: milestones.where((m) => m.done).length,
  );
}
