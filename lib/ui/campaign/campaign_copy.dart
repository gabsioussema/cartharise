import '../../domain/campaign.dart';
import '../../l10n/app_localizations.dart';

/// Localized names for the Campaign's chapters and achievements, and how
/// an achievement was earned.

String chapterName(AppLocalizations l, CampaignChapter c) => switch (c) {
  CampaignChapter.terrain => l.campaignChapterTerrain,
  CampaignChapter.pattern => l.campaignChapterPattern,
  CampaignChapter.banner => l.campaignChapterBanner,
  CampaignChapter.autopilot => l.campaignChapterAutopilot,
  CampaignChapter.plan => l.campaignChapterPlan,
};

String chapterArea(AppLocalizations l, CampaignChapter c) => switch (c) {
  CampaignChapter.terrain => l.campaignChapterTerrainArea,
  CampaignChapter.pattern => l.campaignChapterPatternArea,
  CampaignChapter.banner => l.campaignChapterBannerArea,
  CampaignChapter.autopilot => l.campaignChapterAutopilotArea,
  CampaignChapter.plan => l.campaignChapterPlanArea,
};

String achievementName(AppLocalizations l, Achievement a) => switch (a) {
  Achievement.observer => l.campaignAchievementObserver,
  Achievement.pathfinder => l.campaignAchievementPathfinder,
  Achievement.visionary => l.campaignAchievementVisionary,
  Achievement.watchful => l.campaignAchievementWatchful,
  Achievement.strategist => l.campaignAchievementStrategist,
  Achievement.practitioner => l.campaignAchievementPractitioner,
  Achievement.challenger => l.campaignAchievementChallenger,
};

/// What an achievement asks, in the present tense ("Answer every … or try
/// one of its experiments"): never a claim about what the user did, since a
/// chapter's badge can be earned either way; [earnedByLabel] says how.
String achievementBody(AppLocalizations l, Achievement a) => switch (a) {
  Achievement.observer => l.campaignAchievementObserverBody,
  Achievement.pathfinder => l.campaignAchievementPathfinderBody,
  Achievement.visionary => l.campaignAchievementVisionaryBody,
  Achievement.watchful => l.campaignAchievementWatchfulBody,
  Achievement.strategist => l.campaignAchievementStrategistBody,
  Achievement.practitioner => l.campaignAchievementPractitionerBody,
  Achievement.challenger => l.campaignAchievementChallengerBody,
};

/// How an achievement was earned, e.g. "Earned by trying: Leave your
/// phone in another room" — naming the experiment when it is known.
String earnedByLabel(
  AppLocalizations l,
  EarnedRoute route, {
  String? experiment,
}) => switch (route) {
  EarnedRoute.reflecting => l.campaignEarnedByReflecting,
  EarnedRoute.trying =>
    experiment == null || experiment.trim().isEmpty
        ? l.campaignEarnedByTrying
        : l.campaignEarnedByTryingWhat(experiment),
  EarnedRoute.doing => l.campaignEarnedByDoing,
};
