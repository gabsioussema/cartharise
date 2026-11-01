import '../../domain/campaign.dart';
import '../../l10n/app_localizations.dart';

/// Localized names for the Campaign's chapters and achievements.

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

String achievementBody(AppLocalizations l, Achievement a) => switch (a) {
  Achievement.observer => l.campaignAchievementObserverBody,
  Achievement.pathfinder => l.campaignAchievementPathfinderBody,
  Achievement.visionary => l.campaignAchievementVisionaryBody,
  Achievement.watchful => l.campaignAchievementWatchfulBody,
  Achievement.strategist => l.campaignAchievementStrategistBody,
  Achievement.practitioner => l.campaignAchievementPractitionerBody,
  Achievement.challenger => l.campaignAchievementChallengerBody,
};
