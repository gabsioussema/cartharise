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

/// XP per level.
const int kXpPerLevel = 100;

/// The five chapters of the one-day prologue (F-059): the article's own
/// exercises, in order — 4 + 7 + 3 morning questions, the six daytime
/// check-ins and the seven evening questions.
enum CampaignChapter {
  terrain([PromptGroup.currentReality]),
  pattern([PromptGroup.antiVision, PromptGroup.identity]),
  banner([PromptGroup.vision]),
  autopilot([PromptGroup.interrupt]),
  plan([PromptGroup.insight, PromptGroup.direction, PromptGroup.plan]);

  const CampaignChapter(this.groups);

  /// The prompt groups this chapter covers (core prompts only).
  final List<PromptGroup> groups;

  /// The chapter's prompt ids, in reset order.
  List<String> promptIds(ContentLibrary content) => [
    for (final p in content.prompts)
      if (p.core && groups.contains(p.group)) p.id,
  ];
}

/// Article-based achievements (F-062), earned only for observable
/// activities — never for what was written or how it felt.
enum Achievement {
  observer,
  pathfinder,
  visionary,
  watchful,
  strategist,
  practitioner,
  challenger,
}

/// A chapter's progress in the current reset.
class ChapterProgress {
  const ChapterProgress({
    required this.chapter,
    required this.promptIds,
    required this.answered,
  });

  final CampaignChapter chapter;
  final List<String> promptIds;

  /// How many of [promptIds] have an answer in the current reset.
  final int answered;

  int get total => promptIds.length;
  bool get explored => total > 0 && answered == total;
}

/// Everything the Campaign shows, derived from [AppData].
class CampaignProgress {
  const CampaignProgress({
    required this.xp,
    required this.chapters,
    required this.earned,
    required this.questsCompleted,
    required this.pathDaysWritten,
    required this.attempts,
  });

  final int xp;
  final List<ChapterProgress> chapters;
  final Set<Achievement> earned;

  /// Every quest completion (a daily quest counts once per day).
  final int questsCompleted;
  final int pathDaysWritten;

  /// Battle-log entries.
  final int attempts;

  int get level => 1 + xp ~/ kXpPerLevel;

  /// XP gathered towards the next level (0 to [kXpPerLevel] − 1).
  int get levelXp => xp % kXpPerLevel;

  int get chaptersExplored => chapters.where((c) => c.explored).length;
}

/// The Campaign for [data], with the chapters taken from [content].
CampaignProgress campaignProgress(AppData data, ContentLibrary content) {
  final current = data.currentJourney;
  ChapterProgress progressOf(CampaignChapter chapter) {
    final ids = chapter.promptIds(content);
    final answered = current == null
        ? 0
        : ids.where((id) => current.answer(id)?.answered ?? false).length;
    return ChapterProgress(
      chapter: chapter,
      promptIds: ids,
      answered: answered,
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

  final xp =
      reflected.length * kXpPerReflection +
      questXpCount * kXpPerQuest +
      pathDays * kXpPerPathDay +
      attemptDays * kXpPerAttemptDay +
      reviewWeeks * kXpPerReview;

  // Chapter achievements: every chapter question answered in one reset.
  bool everExplored(CampaignChapter chapter) {
    final ids = chapter.promptIds(content);
    if (ids.isEmpty) return false;
    return data.journeys.any(
      (j) => ids.every((id) => j.answer(id)?.answered ?? false),
    );
  }

  final earned = <Achievement>{
    if (everExplored(CampaignChapter.terrain)) Achievement.observer,
    if (everExplored(CampaignChapter.pattern)) Achievement.pathfinder,
    if (everExplored(CampaignChapter.banner)) Achievement.visionary,
    if (everExplored(CampaignChapter.autopilot)) Achievement.watchful,
    if (everExplored(CampaignChapter.plan)) Achievement.strategist,
    if (questsCompleted > 0) Achievement.practitioner,
    if (data.campaignLog.isNotEmpty) Achievement.challenger,
  };

  return CampaignProgress(
    xp: xp,
    chapters: chapters,
    earned: earned,
    questsCompleted: questsCompleted,
    pathDaysWritten: pathDays,
    attempts: data.campaignLog.length,
  );
}
