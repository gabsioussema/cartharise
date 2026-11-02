// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cartharise';

  @override
  String get appTagline => 'Master Yourself. Rise With Purpose.';

  @override
  String get appPromise =>
      'Understand yourself. Choose your path. Rise with purpose.';

  @override
  String get tabToday => 'Today';

  @override
  String get tabReset => 'Reset';

  @override
  String get tabCompass => 'Compass';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabYou => 'You';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get skip => 'Skip';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get keepGoing => 'Continue';

  @override
  String get tryAgain => 'Try again';

  @override
  String get notNow => 'Not now';

  @override
  String get moreInfo => 'More information';

  @override
  String get saveStatusSaving => 'Saving…';

  @override
  String get saveStatusSaved => 'Saved on this device';

  @override
  String get saveStatusFailed => 'Your last change couldn\'t be saved.';

  @override
  String get saveFailedHelp =>
      'Your words are still here. Retry, or export a copy.';

  @override
  String get saveExportCopy => 'Export a copy';

  @override
  String get bootLoading => 'Preparing your space…';

  @override
  String get bootLoadErrorTitle => 'Your saved data couldn\'t be opened';

  @override
  String get bootLoadErrorBody =>
      'Cartharise couldn\'t read its file. Nothing was deleted.';

  @override
  String get bootLoadErrorHint =>
      'Try again. If it keeps failing, free up some storage.';

  @override
  String get bootStartFresh => 'Start fresh and keep the unreadable file';

  @override
  String get bootStartFreshConfirmTitle => 'Start fresh?';

  @override
  String get bootStartFreshConfirmBody =>
      'The unreadable file is set aside, not deleted. Cartharise starts empty.';

  @override
  String get storageTransparency =>
      'Only on this phone. Not synced, not in phone or cloud backups, and not encrypted by Cartharise. Deleting the app or your data erases it.';

  @override
  String get storageErrorTitle => 'Storage problem';

  @override
  String get storageErrorBody =>
      'Can\'t save on this phone right now. Your words stay on screen until you leave.';

  @override
  String linkOpenFailed(String url) {
    return 'Couldn\'t open the link. You can visit it yourself: $url';
  }

  @override
  String get shareFailed => 'Couldn\'t open the share sheet on this phone.';

  @override
  String get reminderChannelName => 'Check-in reminders';

  @override
  String get reminderChannelDescription =>
      'Optional daytime check-ins from your Cartharise reset.';

  @override
  String get loaderLabel => 'Loading';

  @override
  String get emblemLabel => 'Cartharise emblem';

  @override
  String progressLabel(int value) {
    return '$value percent';
  }

  @override
  String get selectedLabel => 'Selected';

  @override
  String get awakeningTitle => 'The Awakening';

  @override
  String get awakeningSubtitle =>
      'Seven ideas behind the reset. Optional, any order.';

  @override
  String get awakeningStripTitle => 'Learn the ideas first (optional)';

  @override
  String get awakeningSeeAll => 'See all lessons';

  @override
  String awakeningReadCount(int read, int total) {
    return '$read of $total read';
  }

  @override
  String awakeningLessonNumber(int n) {
    return 'Lesson $n';
  }

  @override
  String awakeningLessonOf(int n, int total) {
    return 'Lesson $n of $total';
  }

  @override
  String get awakeningRead => 'Read';

  @override
  String get awakeningNotRead => 'Not read yet';

  @override
  String get awakeningExample => 'Example';

  @override
  String get awakeningNuance => 'A lens, not a verdict';

  @override
  String get awakeningCheckTitle => 'Check your understanding';

  @override
  String get awakeningCheckHint =>
      'Pick the answer that fits best. Nothing is scored or saved.';

  @override
  String get awakeningCheckRight => 'That\'s it.';

  @override
  String get awakeningCheckNotQuite => 'Not quite, and that\'s fine.';

  @override
  String get awakeningTryIt => 'Try it';

  @override
  String get awakeningTryItBody =>
      'Put this idea into practice with a reset question.';

  @override
  String awakeningTryItPrompt(String title) {
    return 'Try it: $title';
  }

  @override
  String get awakeningPrevious => 'Previous lesson';

  @override
  String get awakeningNext => 'Next lesson';

  @override
  String get awakeningDone => 'Back to the lessons';

  @override
  String awakeningSourceNote(String title, String author) {
    return 'In Cartharise\'s words, from “$title” by $author. Independent app.';
  }

  @override
  String get awakeningSourceLink => 'About the source';

  @override
  String get awakeningMissing => 'This lesson isn\'t available.';

  @override
  String get campaignSection => 'Campaign';

  @override
  String get campaignSubtitle => 'Your direction, played as a game.';

  @override
  String get campaignStatusEyebrow => 'Your campaign';

  @override
  String campaignLevel(int level, int xp) {
    return 'Level $level · $xp XP';
  }

  @override
  String get campaignXpNote =>
      'XP counts what you do, never your worth. Rest costs nothing.';

  @override
  String get campaignXpHow => 'How XP is earned';

  @override
  String campaignXpRuleReflection(int xp) {
    return '+$xp XP for each reset question you answer (once per question)';
  }

  @override
  String campaignXpRuleQuest(int xp, int max) {
    return '+$xp XP for each quest you complete, counting up to $max a day';
  }

  @override
  String campaignXpRulePath(int xp) {
    return '+$xp XP for each day of the 30-day path you write';
  }

  @override
  String campaignXpRuleAttempt(int xp) {
    return '+$xp XP for each day you record an attempt at your monthly project';
  }

  @override
  String campaignXpRuleReview(int xp) {
    return '+$xp XP for each weekly review';
  }

  @override
  String campaignXpRulesNote(int step) {
    return 'XP ignores what you write and how you feel. Skipping and resting never cost XP. Every $step XP is a new level.';
  }

  @override
  String get campaignActOne => 'Act I · The one-day awakening';

  @override
  String campaignChaptersExplored(int count, int total) {
    return '$count of $total chapters explored';
  }

  @override
  String campaignChapterNumber(int number) {
    return 'Chapter $number';
  }

  @override
  String get campaignChapterTerrain => 'See the terrain';

  @override
  String get campaignChapterTerrainArea => 'Current reality';

  @override
  String get campaignChapterPattern => 'Find the pattern';

  @override
  String get campaignChapterPatternArea => 'Anti-vision and identity';

  @override
  String get campaignChapterBanner => 'Raise your banner';

  @override
  String get campaignChapterBannerArea => 'Future vision';

  @override
  String get campaignChapterAutopilot => 'Break autopilot';

  @override
  String get campaignChapterAutopilotArea => 'Daytime check-ins';

  @override
  String get campaignChapterPlan => 'Plan the campaign';

  @override
  String get campaignChapterPlanArea => 'Evening synthesis';

  @override
  String campaignChapterReflections(String area, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reflections',
      one: '1 reflection',
    );
    return '$area · $_temp0';
  }

  @override
  String campaignChapterDone(int done, int total) {
    return '$done of $total written';
  }

  @override
  String get campaignChapterExplored => 'Explored';

  @override
  String get campaignChapterExplore => 'Explore';

  @override
  String campaignChapterExploreLabel(int number, String name) {
    return 'Explore chapter $number, $name';
  }

  @override
  String get campaignMapTitle => 'The strategist\'s map';

  @override
  String get campaignMapAntiVision => 'What\'s at stake · Anti-vision';

  @override
  String get campaignMapVision => 'Win condition · Vision';

  @override
  String get campaignMapYear => 'Main campaign · One-year mission';

  @override
  String get campaignMapMonth => 'Monthly boss · One-month project';

  @override
  String get campaignMapLevers => 'Daily quests · Daily levers';

  @override
  String get campaignMapBoundaries => 'Rules of engagement · Boundaries';

  @override
  String get campaignMapBoundariesNote =>
      'The game never rewards giving these up.';

  @override
  String get campaignMapEmpty => 'Not written yet.';

  @override
  String get campaignMapEdit => 'Build your strategy';

  @override
  String get campaignMapQuests => 'Open daily quests';

  @override
  String get campaignBossTitle => 'Monthly boss fight';

  @override
  String get campaignBossBody =>
      'The boss is a project, never a person. Log what you try.';

  @override
  String get campaignBossNoProject =>
      'Set a one-month project in your Compass to see it here.';

  @override
  String get campaignAttemptLabel => 'What did you actually try?';

  @override
  String get campaignAttemptHint =>
      'A focus block, a hard message, a first draft…';

  @override
  String get campaignAttemptRequired =>
      'Write a few words about what you tried.';

  @override
  String get campaignLearningLabel => 'What did you learn? (optional)';

  @override
  String get campaignLearningHint => 'What worked, what you\'d change.';

  @override
  String get campaignRecord => 'Record this attempt';

  @override
  String get campaignRecorded => 'Attempt recorded.';

  @override
  String campaignLogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Battle log · $count attempts',
      one: 'Battle log · 1 attempt',
      zero: 'Battle log',
    );
    return '$_temp0';
  }

  @override
  String get campaignLogEmpty => 'No attempts yet. Your first one can be tiny.';

  @override
  String campaignLogLearned(String learning) {
    return 'Learned: $learning';
  }

  @override
  String campaignLogEditLabel(String date) {
    return 'Edit the attempt from $date';
  }

  @override
  String get campaignAttemptEditTitle => 'Edit attempt';

  @override
  String get campaignAttemptSave => 'Save attempt';

  @override
  String get campaignAttemptDelete => 'Delete attempt';

  @override
  String get campaignAttemptDeleteTitle => 'Delete this attempt?';

  @override
  String get campaignAttemptDeleteBody =>
      'It will be removed. This can\'t be undone.';

  @override
  String get campaignAttemptDeleted => 'Attempt deleted';

  @override
  String get campaignAchievementsTitle => 'Achievements from the article';

  @override
  String get campaignAchievementsSubtitle =>
      'Earned by reflecting, trying or doing. Never by what you write.';

  @override
  String campaignAchievementsCount(int earned, int total) {
    return '$earned of $total earned';
  }

  @override
  String get campaignNotYet => 'Not yet';

  @override
  String get campaignAchievementObserver => 'The Observer';

  @override
  String get campaignAchievementObserverBody =>
      'Answer every present-reality question in one reset, or try one of its experiments';

  @override
  String get campaignAchievementPathfinder => 'The Pathfinder';

  @override
  String get campaignAchievementPathfinderBody =>
      'Answer every anti-vision and identity question in one reset, or try one of its experiments';

  @override
  String get campaignAchievementVisionary => 'The Visionary';

  @override
  String get campaignAchievementVisionaryBody =>
      'Answer every future-vision question in one reset, or try one of its experiments';

  @override
  String get campaignAchievementWatchful => 'The Watchful';

  @override
  String get campaignAchievementWatchfulBody =>
      'Answer every daytime check-in in one reset, or try one of its experiments';

  @override
  String get campaignAchievementStrategist => 'The Strategist';

  @override
  String get campaignAchievementStrategistBody =>
      'Answer every evening-planning question in one reset, or try one of its experiments';

  @override
  String get campaignAchievementPractitioner => 'The Practitioner';

  @override
  String get campaignAchievementPractitionerBody =>
      'Complete a real-world quest';

  @override
  String get campaignAchievementChallenger => 'The Challenger';

  @override
  String get campaignAchievementChallengerBody =>
      'Record a first attempt at your monthly project';

  @override
  String get campaignActTwo => 'Act II · The 30-day becoming';

  @override
  String get campaignActTwoBody =>
      'A direction, not a deadline. Keep the small steps going.';

  @override
  String get campaignStatQuests => 'Quests completed';

  @override
  String get campaignStatPath => '30-day notes written';

  @override
  String get campaignStatAttempts => 'Attempts recorded';

  @override
  String get campaignContinuePath => 'Continue the 30-day path';

  @override
  String get campaignReadArticle => 'Read the article';

  @override
  String get campaignNote =>
      'XP, levels and achievements are Cartharise additions, not part of the article. Turn them off in You.';

  @override
  String get campaignTodayOpen => 'Open the Campaign';

  @override
  String get campaignSettingTitle => 'The Campaign';

  @override
  String get campaignSettingHint =>
      'XP, levels and achievements. Your battle log is kept if you turn it off.';

  @override
  String campaignWaypoint(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'carthage': 'Carthage',
      'newCarthage': 'New Carthage',
      'ebro': 'the Ebro',
      'pyrenees': 'the Pyrenees',
      'rhone': 'the Rhône',
      'alps': 'the Alps',
      'italy': 'Italy',
      'other': 'the road',
    });
    return '$_temp0';
  }

  @override
  String campaignRouteHere(String place) {
    return 'You\'re at $place';
  }

  @override
  String campaignRouteNext(int xp, String place) {
    return '$xp XP to $place';
  }

  @override
  String get campaignRouteEnd =>
      'You\'ve crossed into Italy. The campaign goes on.';

  @override
  String campaignRouteLabel(String place, int stop, int total) {
    return 'Hannibal\'s route: $place, stop $stop of $total.';
  }

  @override
  String get campaignBossStrength => 'Boss strength';

  @override
  String campaignBossMilestones(int done, int total) {
    return '$done of $total milestones reached';
  }

  @override
  String get campaignBossBeaten => 'Every milestone reached. Boss beaten.';

  @override
  String get campaignBossNoMilestones =>
      'Add milestones to your project to weaken the boss.';

  @override
  String get campaignBossOpenProject => 'Open project';

  @override
  String campaignNextAchievement(String name, String how) {
    return 'Next: $name · $how';
  }

  @override
  String campaignToastXp(int xp) {
    return '+$xp XP';
  }

  @override
  String campaignToastAchievement(String name) {
    return 'Achievement earned: $name';
  }

  @override
  String get campaignStrategistEmpty =>
      'Create an avatar to walk the route with you.';

  @override
  String campaignExtrasCount(int count, int total) {
    return '$count of $total extras unlocked';
  }

  @override
  String get campaignExtrasAll => 'Every extra unlocked.';

  @override
  String campaignQuestXp(int xp) {
    return '+$xp XP';
  }

  @override
  String campaignQuestXpLabel(int xp) {
    return 'Earns $xp XP when done';
  }

  @override
  String campaignXpRuleExperiment(int xp) {
    return '+$xp XP for each new experiment you try (once each)';
  }

  @override
  String get campaignNoticeTitle => 'Notice';

  @override
  String get campaignNoticeLine => 'A question or idea to look at again.';

  @override
  String get campaignTryTitle => 'Try';

  @override
  String get campaignTryLine => 'A tiny experiment for real life.';

  @override
  String get campaignYoursTitle => 'Make it yours';

  @override
  String get campaignYoursLine => 'Your avatar and motto.';

  @override
  String campaignYoursPicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reward picks to choose',
      one: '1 reward pick to choose',
    );
    return '$_temp0';
  }

  @override
  String get campaignLinkRoute => 'Route';

  @override
  String get campaignLinkChapters => 'Chapters';

  @override
  String get campaignLinkBattleLog => 'Battle log';

  @override
  String get campaignLinkBattleLogDraft => 'Battle log · draft kept';

  @override
  String get campaignLinkCollection => 'Collection';

  @override
  String get campaignRouteTitle => 'The route';

  @override
  String get campaignRouteSubtitle =>
      'One stop per level. Rest never moves you back.';

  @override
  String get campaignRouteStops => 'Stops';

  @override
  String get campaignRouteStopHere => 'You\'re here';

  @override
  String get campaignRouteStopReached => 'Reached';

  @override
  String campaignRouteStopAhead(int xp) {
    return '$xp XP to go';
  }

  @override
  String get campaignChaptersTitle => 'Chapters';

  @override
  String campaignChapterTried(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count experiments tried',
      one: '1 experiment tried',
    );
    return '$_temp0';
  }

  @override
  String get campaignChapterTry => 'Try one';

  @override
  String campaignChapterTryLabel(int number, String name) {
    return 'Try an experiment from chapter $number, $name';
  }

  @override
  String get campaignBattleLogTitle => 'Battle log';

  @override
  String get campaignAttemptDraftNote => 'Kept on this phone as you type.';

  @override
  String get campaignAttemptNotSaved =>
      'Not saved on this phone yet. Your words are still here. Retry at the top.';

  @override
  String get campaignNotSavedYet =>
      'Not saved on this phone yet. Retry at the top.';

  @override
  String get campaignCollectionTitle => 'Collection';

  @override
  String get campaignCollectionSubtitle => 'What you tried, earned and chose.';

  @override
  String campaignCollectionTried(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count experiments tried',
      one: '1 experiment tried',
      zero: 'Experiments tried',
    );
    return '$_temp0';
  }

  @override
  String get campaignCollectionTriedEmpty =>
      'Nothing tried yet. Try has small experiments.';

  @override
  String get campaignTryOpen => 'Open Try';

  @override
  String get campaignExperimentUnknown => 'An experiment';

  @override
  String campaignTriedOn(String date) {
    return 'Tried $date';
  }

  @override
  String campaignTriedEditLabel(String date) {
    return 'Edit the note from $date';
  }

  @override
  String get campaignTriedSave => 'Save note';

  @override
  String get campaignTriedRemove => 'Remove this try';

  @override
  String get campaignTriedRemoveTitle => 'Remove this try?';

  @override
  String get campaignTriedRemoveBody =>
      'It leaves your Collection, with its note.';

  @override
  String get campaignTriedRemoved => 'Try removed';

  @override
  String get campaignTriedUnsavedTitle => 'Save your change?';

  @override
  String get campaignTriedUnsavedBody => 'The note was changed but not saved.';

  @override
  String get campaignTriedDiscard => 'Discard';

  @override
  String get campaignEarnedByReflecting => 'Earned by reflecting';

  @override
  String get campaignEarnedByTrying => 'Earned by trying';

  @override
  String campaignEarnedByTryingWhat(String experiment) {
    return 'Earned by trying: $experiment';
  }

  @override
  String get campaignEarnedByDoing => 'Earned by doing';

  @override
  String get campaignCollectionExtras => 'Extras chosen';

  @override
  String get campaignCollectionExtrasEmpty => 'No extras chosen yet.';

  @override
  String get campaignTryScreenSubtitle =>
      'Small experiments. Nothing joins your tasks unless you add it.';

  @override
  String campaignTryMinutes(int minutes) {
    return 'About $minutes min';
  }

  @override
  String campaignTryXpLabel(int xp) {
    return 'Earns $xp XP the first time';
  }

  @override
  String campaignTryStepLabel(int number, String step) {
    return 'Step $number: $step';
  }

  @override
  String get campaignTryNoteLabel => 'A note (optional)';

  @override
  String get campaignTryNoteHint => 'How did it go? One line is plenty.';

  @override
  String get campaignTryDone => 'I tried it';

  @override
  String get campaignTryRecorded => 'Saved to your Collection.';

  @override
  String get campaignTryAddTask => 'Add to my tasks';

  @override
  String get campaignTryAdded => 'Added to your tasks.';

  @override
  String get campaignTryAlreadyTask => 'Already in your tasks.';

  @override
  String get campaignTryOpenTasks => 'Open tasks';

  @override
  String get campaignTryPrevious => 'Previous';

  @override
  String campaignTryPosition(int index, int total) {
    return '$index of $total';
  }

  @override
  String get campaignTryEmpty => 'No experiments here yet.';

  @override
  String get campaignNoticeScreenSubtitle =>
      'Pick one. Each opens a question or a lesson.';

  @override
  String get campaignNoticeKindPrompt => 'Reflection';

  @override
  String get campaignNoticeKindLesson => 'Lesson';

  @override
  String campaignNoticeOpens(String title) {
    return 'Opens: $title';
  }

  @override
  String get campaignNoticeWritten => 'Written';

  @override
  String get campaignNoticeRead => 'Read';

  @override
  String get campaignNoticeEmpty => 'Nothing to notice here yet.';

  @override
  String get campaignYoursScreenSubtitle =>
      'Your look and motto. Extras are cosmetic and yours to keep.';

  @override
  String get campaignRewardCardTitle => 'Reward picks';

  @override
  String get campaignRewardTitle => 'Choose your reward';

  @override
  String campaignRewardPicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count picks to spend. What you choose stays yours.',
      one: '1 pick to spend. What you choose stays yours.',
    );
    return '$_temp0';
  }

  @override
  String campaignRewardSuggestedLine(String item) {
    return 'Suggested: $item';
  }

  @override
  String campaignRewardSuggested(String kind) {
    return 'Suggested · $kind';
  }

  @override
  String campaignRewardChoose(String item) {
    return 'Choose $item';
  }

  @override
  String campaignRewardChosen(String item) {
    return '$item is yours to keep.';
  }

  @override
  String get campaignRewardWear => 'Wear it';

  @override
  String campaignRewardPreviewLabel(String item) {
    return 'Your avatar wearing $item';
  }

  @override
  String get campaignRewardNone => 'No pick to spend right now.';

  @override
  String get campaignRewardGameOff =>
      'With the Campaign off, every extra is already open.';

  @override
  String get campaignPlaygroundSection => 'Playground';

  @override
  String get campaignPlaygroundSubtitle => 'Small things to notice and try.';

  @override
  String get campaignPlaygroundGameOff =>
      'No XP or levels while the Campaign is off. Turn it on in You.';

  @override
  String get campaignInviteTitle => 'Play the Campaign?';

  @override
  String get campaignInviteBody => 'XP and levels for what you do.';

  @override
  String get campaignInvitePlay => 'Play';

  @override
  String get campaignInvitePlaying =>
      'The Campaign is on. It lives in Compass.';

  @override
  String get campaignInviteLater => 'You can turn it on in You.';

  @override
  String campaignToastPick(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new picks for your avatar',
      one: 'A new pick for your avatar',
    );
    return '$_temp0';
  }

  @override
  String get campaignQuestFromTry => 'Experiment';

  @override
  String get compassTitle => 'Compass';

  @override
  String get compassSubtitle => 'Your direction, in your own words.';

  @override
  String get compassMissionsSubtitle => 'Your direction, in action.';

  @override
  String get compassSectionCompass => 'Compass';

  @override
  String get compassSectionMissions => 'Missions';

  @override
  String get compassHeroEyebrow => 'My direction';

  @override
  String get compassHeroEmpty =>
      'Six short answers that point your days. Write them, or start from your evening answers.';

  @override
  String compassLastUpdated(String date) {
    return 'Last updated $date';
  }

  @override
  String get compassImportOfferTitleEmpty =>
      'Start from your evening reflection';

  @override
  String get compassImportOfferTitle => 'Evening answers can fill empty fields';

  @override
  String get compassImportOfferBody =>
      'Bring your evening words into empty fields. Nothing changes until you confirm.';

  @override
  String get compassImportAction => 'Use my evening reflections';

  @override
  String get compassEmptyTitle => 'Your Compass is empty';

  @override
  String get compassEmptyBody =>
      'Write each part below, or answer the evening questions first.';

  @override
  String get compassEmptyAction => 'Go to the evening reflection';

  @override
  String get compassFieldAntiVision => 'Anti-vision';

  @override
  String get compassFieldAntiVisionHelp =>
      'What I refuse to let my life become.';

  @override
  String get compassFieldAntiVisionHint =>
      'The life I don\'t want, in a sentence or two';

  @override
  String get compassFieldVision => 'Vision';

  @override
  String get compassFieldVisionHelp => 'What I\'m building toward.';

  @override
  String get compassFieldVisionHint => 'The life I want to grow into';

  @override
  String get compassFieldYearGoal => 'One-year mission';

  @override
  String get compassFieldYearGoalHelp =>
      'The outcome that would matter most a year from now.';

  @override
  String get compassFieldYearGoalHint => 'By this time next year, I…';

  @override
  String get compassFieldMonthProject => 'One-month project';

  @override
  String get compassFieldMonthProjectHelp =>
      'One project for the next four weeks.';

  @override
  String get compassFieldMonthProjectHint =>
      'This month I will build or finish…';

  @override
  String get compassFieldDailyLevers => 'Daily levers';

  @override
  String get compassFieldDailyLeversHelp => '2–3 actions, one per line.';

  @override
  String get compassFieldDailyLeversHint => 'Walk 20 minutes\nRead 10 pages';

  @override
  String get compassFieldConstraints => 'Boundaries';

  @override
  String get compassFieldConstraintsHelp => 'What I won\'t sacrifice.';

  @override
  String get compassFieldConstraintsHint =>
      'Sleep, family dinners, one rest day…';

  @override
  String get compassConstraintsOwnWords => 'Only you write this.';

  @override
  String get compassConstraintsChip => 'Written only by you';

  @override
  String get compassLeversToQuests => 'Turn into quests';

  @override
  String get compassOpenProject => 'Open month project';

  @override
  String get compassVersionsTitle => 'Versions';

  @override
  String get compassVersionsBody => 'Save a snapshot before big changes.';

  @override
  String get compassSaveVersion => 'Save a version';

  @override
  String get compassVersionSaved => 'Version saved';

  @override
  String compassViewVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Versions ($count)',
      zero: 'Versions',
    );
    return '$_temp0';
  }

  @override
  String get compassVersionsSubtitle =>
      'Snapshots of your Compass, newest first.';

  @override
  String get compassVersionsEmptyTitle => 'No versions yet';

  @override
  String get compassVersionsEmptyBody =>
      'Save a version whenever you want a snapshot to look back on.';

  @override
  String get compassVersionReasonManual => 'Saved by you';

  @override
  String get compassVersionReasonBeforeImport => 'Before an import';

  @override
  String get compassVersionReasonBeforeRestore => 'Before a restore';

  @override
  String get compassVersionTitle => 'Version';

  @override
  String get compassVersionEmptyField => 'Empty in this version';

  @override
  String get compassVersionSameAsNow => 'Same as now';

  @override
  String get compassVersionDiffers => 'Differs from now';

  @override
  String get compassVersionReadOnly =>
      'Read-only. Restoring saves your current Compass first.';

  @override
  String get compassRestoreAction => 'Restore this version';

  @override
  String get compassRestoreConfirmTitle => 'Restore this version?';

  @override
  String get compassRestoreConfirmBody =>
      'This replaces your Compass. The current one is saved first.';

  @override
  String get compassRestoreConfirm => 'Restore';

  @override
  String get compassRestored => 'Version restored. The previous one was saved.';

  @override
  String get compassImportTitle => 'Use my evening reflections';

  @override
  String get compassImportBody =>
      'Your evening answers, as written. Pick the empty fields to fill.';

  @override
  String compassImportFrom(String prompt) {
    return 'From: $prompt';
  }

  @override
  String get compassImportKeeps => 'Keeps your current text';

  @override
  String get compassImportNoAnswer => 'No evening answer yet';

  @override
  String get compassImportConstraintsNote =>
      'Boundaries are only written by you.';

  @override
  String get compassImportSnapshotNote =>
      'Your current Compass is saved as a version first.';

  @override
  String compassImportConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fill $count fields',
      one: 'Fill 1 field',
      zero: 'Choose a field',
    );
    return '$_temp0';
  }

  @override
  String get compassImportNothing =>
      'Nothing to bring over yet. Answer the evening questions first.';

  @override
  String compassImportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Compass fields filled from your evening answers.',
      one: '1 Compass field filled from your evening answers.',
    );
    return '$_temp0';
  }

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalSubtitle => 'Think, reflect and grow, at your own pace.';

  @override
  String get journalSectionNotes => 'Notes';

  @override
  String get journalSectionReviews => 'Reviews';

  @override
  String get journalSectionLookBack => 'Look back';

  @override
  String journalDateTime(String date, String time) {
    return '$date, $time';
  }

  @override
  String get journalNotesIntro => 'Free writing. Stays on this phone.';

  @override
  String get journalNewNote => 'New note';

  @override
  String get journalNotesEmptyTitle => 'No notes yet';

  @override
  String get journalNotesEmptyBody =>
      'An idea, a worry, something you noticed.';

  @override
  String get journalUntitled => 'Untitled note';

  @override
  String get journalEditedBadge => 'Edited';

  @override
  String get journalEntryNewTitle => 'New note';

  @override
  String get journalEntryTitle => 'Note';

  @override
  String get journalEntryTitleField => 'Title (optional)';

  @override
  String get journalEntryBodyField => 'Your note';

  @override
  String get journalEntryBodyHint => 'Write freely. It saves as you type.';

  @override
  String journalEntryWritten(String when) {
    return 'Written $when';
  }

  @override
  String journalEntryEdited(String when) {
    return 'Last edited $when';
  }

  @override
  String get journalEntryPrivacy =>
      'Only on this phone. Never shown in notifications.';

  @override
  String get journalEntryDelete => 'Delete note';

  @override
  String get journalEntryDeleteTitle => 'Delete this note?';

  @override
  String get journalEntryDeleteBody =>
      'The note is removed from this phone. This can\'t be undone.';

  @override
  String get journalEntryDeleted => 'Note deleted';

  @override
  String get journalEntryMissingTitle => 'This note isn\'t here any more';

  @override
  String get journalEntryMissingBody =>
      'It may have been deleted. Your other notes are unchanged.';

  @override
  String get journalReviewsIntro =>
      'Once a week: what went well, what got in the way, what to try next.';

  @override
  String get journalReviewThisWeek => 'Review this week';

  @override
  String get journalOpenThisWeek => 'Open this week\'s review';

  @override
  String get journalReviewsEmptyTitle => 'No weekly reviews yet';

  @override
  String get journalReviewsEmptyBody => 'A few minutes. No right way.';

  @override
  String journalWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get journalReviewTitle => 'Weekly review';

  @override
  String get journalReviewEditIntro =>
      'Write as much as you like. It saves as you type.';

  @override
  String get journalReviewChangeWeek => 'Change week';

  @override
  String get journalReviewWins => 'Wins';

  @override
  String get journalReviewWinsHint =>
      'What went well this week, however small?';

  @override
  String get journalReviewFriction => 'Friction';

  @override
  String get journalReviewFrictionHint =>
      'What got in the way? Just notice it. No blame needed.';

  @override
  String get journalReviewNext => 'Next experiment';

  @override
  String get journalReviewNextHint => 'One small thing to try next week.';

  @override
  String get journalReviewSave => 'Save review';

  @override
  String get journalReviewSaved => 'Review saved';

  @override
  String get journalReviewEdit => 'Edit review';

  @override
  String get journalReviewDelete => 'Delete review';

  @override
  String get journalReviewDeleteTitle => 'Delete this review?';

  @override
  String journalReviewDeleteBody(String date) {
    return 'The review for the week of $date will be removed. This can\'t be undone.';
  }

  @override
  String get journalReviewDeleted => 'Review deleted';

  @override
  String get journalReviewNothingWritten => 'Nothing written';

  @override
  String journalReviewWritten(String when) {
    return 'Saved $when';
  }

  @override
  String get journalReviewMissingTitle => 'This review isn\'t here any more';

  @override
  String get journalReviewMissingBody =>
      'It may have been deleted. Your other reviews are unchanged.';

  @override
  String get journalLookBackIntro => 'See how your words have changed.';

  @override
  String get journalCompareTitle => 'Compare your Compass';

  @override
  String get journalCompareBody => 'Choose two moments to place side by side.';

  @override
  String get journalCompareFirst => 'First';

  @override
  String get journalCompareSecond => 'Second';

  @override
  String get journalCompareNow => 'Your Compass now';

  @override
  String journalComparePick(String which) {
    return 'Choose what to show as “$which”';
  }

  @override
  String journalComparePickerLabel(String which, String current) {
    return '$which: $current. Tap to change.';
  }

  @override
  String get journalCompareEmptyTitle => 'No saved versions yet';

  @override
  String get journalCompareEmptyBody =>
      'Save a Compass version to compare it here later.';

  @override
  String get journalOpenCompass => 'Open Compass';

  @override
  String get journalCompareSame => 'Same in both';

  @override
  String get journalCompareEmptyField => 'Empty';

  @override
  String get journalVersionManual => 'saved by you';

  @override
  String get journalVersionBeforeImport => 'before an import';

  @override
  String get journalVersionBeforeRestore => 'before a restore';

  @override
  String journalVersionLabel(String date, String reason) {
    return '$date · $reason';
  }

  @override
  String get journalPastResetsTitle => 'Earlier resets';

  @override
  String get journalPastResetsBody =>
      'Starting a new reset keeps the earlier one here to read.';

  @override
  String get journalPastResetsEmpty =>
      'No earlier resets yet. Starting a new one keeps the old one here.';

  @override
  String journalResetStarted(String date) {
    return 'Started $date';
  }

  @override
  String journalResetCompleted(String date) {
    return 'Completed $date';
  }

  @override
  String journalResetAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count written answers',
      one: '1 written answer',
      zero: 'No written answers',
    );
    return '$_temp0';
  }

  @override
  String get journalPastResetTitle => 'Earlier reset';

  @override
  String get journalPastResetReadOnly =>
      'Read-only. Your words are kept exactly as you wrote them.';

  @override
  String get journalPastResetCompare => 'Show my current answers too';

  @override
  String get journalPastResetThen => 'Then';

  @override
  String get journalPastResetNow => 'Now';

  @override
  String get journalPastResetNoCurrent => 'No answer in your current reset';

  @override
  String get journalPastResetSkipped => 'Skipped';

  @override
  String get journalPastResetNone => 'This reset has no written answers.';

  @override
  String get journalPastResetOther => 'Other answers';

  @override
  String get journalPastResetMissingTitle => 'This reset isn\'t here any more';

  @override
  String get journalPastResetUnfinished => 'Not finished';

  @override
  String journalPastResetLeftOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions were left open.',
      one: '1 question was left open.',
    );
    return '$_temp0';
  }

  @override
  String get journalPhaseMorning => 'Morning';

  @override
  String get journalPhaseDaytime => 'Daytime';

  @override
  String get journalPhaseBonus => 'Bonus';

  @override
  String get journalPhaseEvening => 'Evening';

  @override
  String get listenAction => 'Écouter';

  @override
  String get listenStop => 'Arrêter la lecture';

  @override
  String get listenMyNote => 'Écouter ma note';

  @override
  String get listenMyAnswer => 'Écouter ma réponse';

  @override
  String get listenStarted => 'Lecture à voix haute.';

  @override
  String get listenStopped => 'Lecture arrêtée.';

  @override
  String get listenHearHint =>
      'Pas de son ? Vérifiez le volume et le mode silencieux.';

  @override
  String get listenNoVoice =>
      'Aucune voix pour cette langue sur ce téléphone. Vous pouvez en ajouter une dans ses réglages de synthèse vocale.';

  @override
  String get listenUnavailable =>
      'L\'écoute n\'est pas disponible sur ce téléphone.';

  @override
  String get listenSilent =>
      'Votre téléphone est en mode silencieux. Activez le son ou utilisez des écouteurs.';

  @override
  String get listenFailed =>
      'Impossible de lire ce texte à voix haute. Réessayez.';

  @override
  String get mediaAddPhoto => 'Add photo';

  @override
  String get mediaRecord => 'Record';

  @override
  String get mediaRecordLabel => 'Record a voice note';

  @override
  String get mediaPhotoSourceTitle => 'Add a photo';

  @override
  String get mediaTakePhoto => 'Take a photo';

  @override
  String get mediaChoosePhoto => 'Choose from your photos';

  @override
  String get mediaPhotoAdded => 'Photo added.';

  @override
  String get mediaNotSavedYet => 'Added, but not saved on this phone yet.';

  @override
  String mediaPhotoLabel(String date) {
    return 'Photo, added $date';
  }

  @override
  String get mediaPhotoOpenHint => 'Opens full screen';

  @override
  String get mediaPhotoMissing => 'Missing';

  @override
  String get mediaPhotoMissingLabel =>
      'This photo isn\'t on this phone any more.';

  @override
  String get mediaPhotoTitle => 'Photo';

  @override
  String mediaPhotoAddedOn(String date) {
    return 'Added $date';
  }

  @override
  String get mediaPhotoRemove => 'Remove photo';

  @override
  String get mediaPhotoRemoveTitle => 'Remove this photo?';

  @override
  String get mediaPhotoRemoveBody =>
      'It\'s deleted from this phone. This can\'t be undone.';

  @override
  String get mediaRemove => 'Remove';

  @override
  String get mediaPhotoRemoved => 'Photo removed.';

  @override
  String get mediaRemovedNotSaved =>
      'Removed, but not saved on this phone yet.';

  @override
  String get mediaCameraDenied =>
      'Camera access is off. Choose from your photos, or allow the camera in Settings.';

  @override
  String get mediaPhotosDenied =>
      'Photo access is off. Allow it in Settings, or write instead.';

  @override
  String get mediaCameraUnavailable =>
      'No camera here. Choose from your photos instead.';

  @override
  String get mediaPhotosUnavailable =>
      'Photos can\'t be opened here. You can write instead.';

  @override
  String get mediaPickFailed => 'Couldn\'t open photos. Try again.';

  @override
  String get mediaPhotoUnreadable =>
      'That photo couldn\'t be read. Nothing was added.';

  @override
  String get mediaPhotoTooLarge =>
      'That photo is over 50 MB. Choose a smaller one.';

  @override
  String get mediaWriteFailed =>
      'Couldn\'t save it on this phone. Storage may be full. Nothing was added.';

  @override
  String get mediaEntryGone =>
      'This entry isn\'t here any more. Nothing was added.';

  @override
  String get mediaRecoveredPhoto => 'A photo you took wasn\'t added yet.';

  @override
  String get mediaRecoveredRecording =>
      'A recording was cut off when the app closed. It may be incomplete.';

  @override
  String get mediaRecoveredKeep => 'Keep in a new note';

  @override
  String get mediaRecoveredDiscard => 'Discard';

  @override
  String get mediaRecoveredDiscardTitle => 'Discard it?';

  @override
  String get mediaRecoveredDiscardBody => 'It\'s deleted from this phone.';

  @override
  String get mediaRecoveredKept => 'Kept in a new note in your Journal.';

  @override
  String get mediaDismiss => 'Dismiss';

  @override
  String get mediaRecorderTitle => 'Voice note';

  @override
  String get mediaRecorderStarting => 'Getting the microphone ready…';

  @override
  String get mediaRecorderRecording => 'Recording';

  @override
  String get mediaRecorderStop => 'Stop and save';

  @override
  String get mediaRecorderDiscard => 'Discard';

  @override
  String get mediaRecorderDiscardTitle => 'Discard this recording?';

  @override
  String get mediaRecorderDiscardBody => 'What you recorded is deleted.';

  @override
  String get mediaRecorderSaving => 'Saving…';

  @override
  String get mediaRecorderStarted =>
      'Recording. Tap Stop and save when you\'re done.';

  @override
  String get mediaRecorderSaved => 'Voice note saved.';

  @override
  String mediaRecorderInterrupted(String time) {
    return 'Interrupted. The $time recorded before it is saved.';
  }

  @override
  String get mediaRecorderAgain => 'Record again';

  @override
  String get mediaMicDenied =>
      'Microphone access is off. Allow it in Settings, or write instead.';

  @override
  String get mediaMicUnavailable =>
      'Recording isn\'t available on this phone. You can write instead.';

  @override
  String get mediaRecordFailed =>
      'The recording couldn\'t start. Try again, or write instead.';

  @override
  String get mediaNothingRecorded =>
      'Nothing was recorded. Try again, or write instead.';

  @override
  String get mediaRecordStorageFailed =>
      'Couldn\'t save the recording. Storage may be full.';

  @override
  String get mediaWriteInstead => 'Write instead';

  @override
  String get mediaVoiceNote => 'Voice note';

  @override
  String get mediaPartial => 'Partial';

  @override
  String get mediaPlay => 'Play voice note';

  @override
  String get mediaPause => 'Pause voice note';

  @override
  String mediaPositionOf(String position, String length) {
    return '$position of $length';
  }

  @override
  String get mediaVoiceMissing =>
      'This recording isn\'t on this phone any more.';

  @override
  String get mediaPlayFailed => 'This recording can\'t be played.';

  @override
  String get mediaVoiceRemove => 'Remove voice note';

  @override
  String get mediaVoiceRemoveTitle => 'Remove this voice note?';

  @override
  String get mediaVoiceRemoveBody =>
      'The recording is deleted from this phone. This can\'t be undone.';

  @override
  String get mediaVoiceRemoved => 'Voice note removed.';

  @override
  String get mediaTranscriptAdd => 'Type what you said';

  @override
  String get mediaTranscriptEdit => 'Edit your words';

  @override
  String get mediaTranscriptTitle => 'Your words for this recording';

  @override
  String get mediaTranscriptLabel => 'What you said (optional)';

  @override
  String get mediaTranscriptSaved => 'Your words are saved with the recording.';

  @override
  String mediaMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String mediaSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String get mediaPinnedTitle => 'Pinned memory';

  @override
  String mediaPinnedFromNote(String date) {
    return 'From a note · $date';
  }

  @override
  String mediaPinnedFromTry(String date) {
    return 'From an experiment · $date';
  }

  @override
  String mediaPinnedFromAttempt(String date) {
    return 'From an attempt · $date';
  }

  @override
  String get mediaPinnedOpen => 'Open where it\'s from';

  @override
  String get mediaPinnedPhoto => 'Pinned photo';

  @override
  String get mediaPinPhoto => 'Pin as memory';

  @override
  String get mediaUnpin => 'Unpin';

  @override
  String get mediaPinned => 'Pinned to the top of your Journal.';

  @override
  String get mediaPinnedNotSaved => 'Pinned, but not saved on this phone yet.';

  @override
  String get mediaUnpinned => 'Unpinned. Nothing else changed.';

  @override
  String get mediaUnpinnedNotSaved =>
      'Unpinned, but not saved on this phone yet.';

  @override
  String get mediaPinWords => 'Pin';

  @override
  String get mediaPinWordsTooltip => 'Pin selected words';

  @override
  String get mediaPinSelectFirst => 'Select some words first, then tap Pin.';

  @override
  String get mediaPinNotFound =>
      'Those words couldn\'t be pinned. Select them again.';

  @override
  String mediaCountPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String mediaCountVoice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voice notes',
      one: '1 voice note',
    );
    return '$_temp0';
  }

  @override
  String mediaAnd(String first, String second) {
    return '$first and $second';
  }

  @override
  String get mediaNoteVoiceOnly => 'Voice note';

  @override
  String get mediaNotePhotoOnly => 'Photo note';

  @override
  String get mediaNoteDeleteBody =>
      'The note, its photos and its recordings are removed from this phone. This can\'t be undone.';

  @override
  String get mediaTodayRecordSaved => 'Voice note saved in your Journal.';

  @override
  String get mediaTodayRecordNotSaved =>
      'Recorded, but not saved yet. Retry at the top.';

  @override
  String get mediaTodayOpen => 'Open';

  @override
  String get mediaDataNoFiles =>
      'Includes your words and settings. No photos or recordings yet.';

  @override
  String mediaDataWithFiles(String files, String size) {
    return 'Includes your words and settings, plus $files ($size).';
  }

  @override
  String get mediaDataTooLarge =>
      'Photos and recordings are over 256 MB, too large to restore. Export saves your words only; remove some for a full backup.';

  @override
  String get mediaBackupTooLargeTitle => 'Too large to restore';

  @override
  String get mediaBackupTooLargeBody =>
      'Your photos and recordings are over 256 MB, more than a backup can bring back. Export your words and settings only?';

  @override
  String get mediaBackupWordsOnly => 'Export words only';

  @override
  String get mediaBackupWordsShared =>
      'Words and settings shared. Photos and recordings aren\'t in it.';

  @override
  String get mediaDataImportFormats =>
      'Takes a .zip backup, or an older .json one.';

  @override
  String mediaSizeKb(String size) {
    return '$size KB';
  }

  @override
  String mediaSizeMb(String size) {
    return '$size MB';
  }

  @override
  String mediaSizeGb(String size) {
    return '$size GB';
  }

  @override
  String get missionsIntro =>
      'Small steps toward your Compass. Rest counts too.';

  @override
  String get missionsToday => 'Today';

  @override
  String get missionsTodayEmpty => 'Nothing planned. Add a quest, or rest.';

  @override
  String get missionsLater => 'Anytime & upcoming';

  @override
  String get missionsLaterEmpty =>
      'Quests without a date, or planned for later, appear here.';

  @override
  String missionsDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Done ($count)',
      zero: 'Done',
    );
    return '$_temp0';
  }

  @override
  String get missionsAddQuest => 'Add a quest';

  @override
  String missionsQuestMarkDone(String title) {
    return 'Mark \'$title\' done';
  }

  @override
  String missionsQuestOptions(String title) {
    return 'Options for \'$title\'';
  }

  @override
  String get missionsQuestDaily => 'Every day';

  @override
  String missionsQuestDue(String date) {
    return 'Planned for $date';
  }

  @override
  String get missionsQuestDoneToday => 'Done today';

  @override
  String missionsQuestDoneOn(String date) {
    return 'Done $date';
  }

  @override
  String missionsQuestMovedToDone(String title) {
    return '\'$title\' moved to Done';
  }

  @override
  String get missionsUndo => 'Undo';

  @override
  String get missionsQuestDeleted => 'Quest deleted';

  @override
  String get missionsQuestEdit => 'Edit';

  @override
  String get missionsQuestDelete => 'Delete';

  @override
  String get missionsViewLabel => 'Show quests as';

  @override
  String get missionsViewList => 'List';

  @override
  String get missionsViewBoard => 'Board';

  @override
  String get missionsBoardHint =>
      'Hold a card to drag it, or use its move button.';

  @override
  String get missionsBoardTodayFilter => 'Today';

  @override
  String get missionsBoardTodayFilterTooltip =>
      'Only daily quests and those planned for today';

  @override
  String get missionsLaneLater => 'Later';

  @override
  String get missionsLaneReady => 'Ready';

  @override
  String get missionsLaneDoing => 'Doing';

  @override
  String get missionsLaneDone => 'Done';

  @override
  String missionsLaneSummary(String lane, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quests',
      one: '1 quest',
      zero: 'no quests',
    );
    return '$lane, $_temp0';
  }

  @override
  String get missionsLaneLaterEmpty => 'Park ideas here for another time.';

  @override
  String get missionsLaneReadyEmpty => 'Quests ready to start.';

  @override
  String get missionsLaneDoingEmpty => 'Move a quest here when you start it.';

  @override
  String get missionsLaneDoneEmpty => 'Finished quests land here.';

  @override
  String get missionsLaneTodayEmpty => 'Nothing here for today.';

  @override
  String get missionsLaneDoneFolded =>
      'Folded away. Drop a card here to finish it.';

  @override
  String get missionsBoardDoingNote => 'Fewer in Doing can feel lighter.';

  @override
  String missionsBoardAddTo(String lane) {
    return 'Add to $lane';
  }

  @override
  String missionsBoardMoveTooltip(String title) {
    return 'Move \'$title\' to…';
  }

  @override
  String missionsBoardMoveToLane(String lane) {
    return 'Move to $lane';
  }

  @override
  String missionsBoardMoved(String title, String lane) {
    return '\'$title\' moved to $lane';
  }

  @override
  String missionsBoardDoneForToday(String title) {
    return '\'$title\' done for today';
  }

  @override
  String get missionsBoardDropHere => 'Drop to move here';

  @override
  String get missionsBoardHiddenByFilter => 'Added. The Today filter hides it.';

  @override
  String get missionsBoardShowAll => 'Show all';

  @override
  String get missionsNewQuestTitle => 'New quest';

  @override
  String get missionsEditQuestTitle => 'Edit quest';

  @override
  String get missionsQuestTitleLabel => 'What will you do?';

  @override
  String get missionsQuestTitleHint => 'Walk 20 minutes';

  @override
  String get missionsQuestTitleRequired => 'Give the quest a few words.';

  @override
  String get missionsQuestRepeat => 'Repeat every day';

  @override
  String get missionsQuestRepeatHelp => 'Shows in Today every day.';

  @override
  String get missionsQuestDueLabel => 'Date (optional)';

  @override
  String get missionsQuestNoDate => 'Anytime';

  @override
  String get missionsQuestChooseDate => 'Choose a date';

  @override
  String get missionsQuestClearDate => 'Remove date';

  @override
  String get missionsQuestSave => 'Save quest';

  @override
  String get missionsQuestDeleteAction => 'Delete quest';

  @override
  String get missionsLeversTitle => 'Turn your daily levers into quests';

  @override
  String get missionsLeversBody =>
      'From your Compass. Edit, then add the ones you want.';

  @override
  String missionsLeversInclude(String title) {
    return 'Include \'$title\'';
  }

  @override
  String missionsLeversDraftLabel(int index) {
    return 'Quest $index';
  }

  @override
  String missionsLeversAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count daily quests',
      one: 'Add 1 daily quest',
      zero: 'Choose at least one',
    );
    return '$_temp0';
  }

  @override
  String missionsLeversAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count daily quests added.',
      one: '1 daily quest added.',
      zero: 'Nothing new to add. Those quests already exist.',
    );
    return '$_temp0';
  }

  @override
  String get missionsLeversNotNow => 'Not now';

  @override
  String get missionsProjectTitle => 'Month project';

  @override
  String get missionsProjectEmpty =>
      'Plan one project for the next four weeks.';

  @override
  String missionsProjectFromCompass(String title) {
    return 'From your Compass: $title';
  }

  @override
  String get missionsProjectUntitled => 'Untitled project';

  @override
  String missionsProjectMilestones(int done, int total) {
    return '$done of $total milestones done';
  }

  @override
  String get missionsStatusPlanned => 'Planned';

  @override
  String get missionsStatusActive => 'Active';

  @override
  String get missionsStatusPaused => 'Paused';

  @override
  String get missionsStatusDone => 'Done';

  @override
  String get missionsProjectScreenSubtitle =>
      'One project, a few milestones, and a look back.';

  @override
  String get missionsProjectTitleLabel => 'Project';

  @override
  String get missionsProjectTitleHint =>
      'What will you build or finish this month?';

  @override
  String get missionsProjectLinked => 'Linked to your Compass';

  @override
  String missionsProjectOfferUpdate(String title) {
    return 'Your Compass says: $title. Update it to match?';
  }

  @override
  String get missionsProjectOfferAdd =>
      'Add this as the one-month project in your Compass?';

  @override
  String get missionsProjectUpdateCompass => 'Update Compass';

  @override
  String get missionsProjectAddCompass => 'Add to Compass';

  @override
  String get missionsProjectKeep => 'Keep as is';

  @override
  String get missionsProjectCompassUpdated => 'Compass updated';

  @override
  String get missionsProjectStatus => 'Status';

  @override
  String get missionsMilestones => 'Milestones';

  @override
  String get missionsMilestonesEmpty =>
      'Break the project into a few steps someone could see.';

  @override
  String get missionsMilestoneAdd => 'Add a milestone';

  @override
  String get missionsMilestoneNew => 'New milestone';

  @override
  String get missionsMilestoneRename => 'Rename milestone';

  @override
  String missionsMilestoneMarkDone(String title) {
    return 'Mark milestone \'$title\' done';
  }

  @override
  String missionsMilestoneRenameLabel(String title) {
    return 'Rename \'$title\'';
  }

  @override
  String missionsMilestoneDeleteLabel(String title) {
    return 'Delete \'$title\'';
  }

  @override
  String get missionsMilestoneDeleted => 'Milestone deleted';

  @override
  String get missionsRetro => 'Looking back';

  @override
  String get missionsRetroHelp =>
      'What worked, what you learned, what you\'d change.';

  @override
  String get missionsRetroHint => 'Your notes';

  @override
  String get missionsProjectClear => 'Delete this project';

  @override
  String get missionsProjectClearTitle => 'Delete this project?';

  @override
  String get missionsProjectClearBody =>
      'Its title, milestones and notes go for good. Your Compass, tasks and attempts stay.';

  @override
  String get missionsProjectClearConfirm => 'Delete';

  @override
  String get missionsPathTitle => '30-day path';

  @override
  String get missionsPathIntro => 'Any day is open — go at your own pace.';

  @override
  String missionsPathWrittenCount(int count) {
    return '$count of 30 written';
  }

  @override
  String get missionsStageObserve => 'Observe';

  @override
  String get missionsStageExperiment => 'Experiment';

  @override
  String get missionsStageBuild => 'Build';

  @override
  String get missionsStageAdjust => 'Adjust';

  @override
  String get missionsStageObserveHelp =>
      'Notice what happens, without judging it.';

  @override
  String get missionsStageExperimentHelp =>
      'Try small changes and see what helps.';

  @override
  String get missionsStageBuildHelp => 'Keep what helps and make it easier.';

  @override
  String get missionsStageAdjustHelp => 'Look back and adjust your direction.';

  @override
  String missionsStageDays(int from, int to) {
    return 'Days $from–$to';
  }

  @override
  String missionsDayLabel(int day) {
    return 'Day $day';
  }

  @override
  String get missionsDayWritten => 'Written';

  @override
  String missionsDayStage(int day, String stage) {
    return 'Day $day · $stage';
  }

  @override
  String missionsDayAnswerLabel(int day) {
    return 'Your note for day $day';
  }

  @override
  String get missionsDayAnswerHint => 'Write as much or as little as you like.';

  @override
  String missionsDayPrevious(int day) {
    return 'Day $day';
  }

  @override
  String missionsDayNext(int day) {
    return 'Day $day';
  }

  @override
  String missionsDayPreviousLabel(int day) {
    return 'Previous: day $day';
  }

  @override
  String missionsDayNextLabel(int day) {
    return 'Next: day $day';
  }

  @override
  String get missionsDayMissing => 'This day isn\'t available.';

  @override
  String get onboardingBrandIntro =>
      'One honest day of reflection. Then small steps.';

  @override
  String get onboardingBegin => 'Begin';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingLimitsTitle => 'Before you start';

  @override
  String get onboardingLimitsIntro => 'A few honest words.';

  @override
  String get onboardingLimitsClarityTitle => 'One day can bring clarity';

  @override
  String get onboardingLimitsClarityBody =>
      'See where you stand and what you want.';

  @override
  String get onboardingLimitsNoGuaranteeTitle =>
      'It won\'t fix your life overnight';

  @override
  String get onboardingLimitsNoGuaranteeBody =>
      'Change comes from small steps, week by week.';

  @override
  String get onboardingLimitsNotTherapyTitle => 'Not therapy';

  @override
  String get onboardingLimitsNotTherapyBody =>
      'No diagnosis. For help, see You › Support.';

  @override
  String get onboardingLimitsControlTitle => 'You stay in control';

  @override
  String get onboardingLimitsControlBody =>
      'Skip, soften or pause any question.';

  @override
  String get onboardingAdultConfirm => 'I\'m 18 or older';

  @override
  String get onboardingAdultConfirmHelp => 'Made for adults.';

  @override
  String get onboardingAdultRequired =>
      'Confirm you\'re 18 or older to continue.';

  @override
  String get onboardingCreditTitle => 'Inspired by';

  @override
  String onboardingCreditByline(String author, String date) {
    return 'by $author · $date';
  }

  @override
  String get onboardingCreditArticle => 'Read the original article';

  @override
  String get onboardingCreditNewsletter =>
      'Read it in the author\'s newsletter';

  @override
  String get onboardingCreditNoNeed => 'No need to read it first.';

  @override
  String get onboardingPaceTitle => 'Choose your pace';

  @override
  String get onboardingPaceIntro => 'Change it anytime in You.';

  @override
  String get onboardingPaceOneDayTitle => 'One day';

  @override
  String get onboardingPaceOneDayBody =>
      'Morning, daytime and evening in one day.';

  @override
  String get onboardingPaceFlexibleTitle => 'Flexible';

  @override
  String get onboardingPaceFlexibleBody => 'Spread it out. Pick up anytime.';

  @override
  String get onboardingPaceNoLock => 'Nothing locks or expires.';

  @override
  String get onboardingNameTitle => 'What should we call you?';

  @override
  String get onboardingNameIntro => 'Optional. Stays on this phone.';

  @override
  String get onboardingNameLabel => 'Name (optional)';

  @override
  String get onboardingNameHelp =>
      'Leave it empty and we\'ll call you Traveler.';

  @override
  String get onboardingPrivacyTitle => 'Your words stay yours';

  @override
  String get onboardingPrivacyStorageHeading => 'Where your writing lives';

  @override
  String get onboardingPrivacyNoAccount => 'No account, ads or analytics.';

  @override
  String get onboardingPrivacyControl =>
      'Export or delete anytime in You › Your data.';

  @override
  String get personaFeatureTitle => 'Your strategist';

  @override
  String get personaAvatarLabel => 'Your avatar';

  @override
  String get personaNoAvatar => 'No avatar yet';

  @override
  String get personaCreate => 'Create your avatar';

  @override
  String get personaEdit => 'Edit your avatar';

  @override
  String get personaSilhouette => 'Silhouette';

  @override
  String get personaLocked => 'Locked';

  @override
  String get personaUnlockWithPick => 'Choose it with a reward pick';

  @override
  String personaNextPickStop(String place) {
    return 'Next pick at $place';
  }

  @override
  String personaNextPickAchievement(String achievement) {
    return 'Next pick: earn $achievement';
  }

  @override
  String get personaCategorySkin => 'Skin';

  @override
  String get personaCategoryFace => 'Face';

  @override
  String get personaCategoryHair => 'Hair';

  @override
  String get personaCategoryHairColor => 'Hair colour';

  @override
  String get personaCategoryFacialHair => 'Facial hair';

  @override
  String get personaCategoryEyewear => 'Glasses';

  @override
  String get personaCategoryMark => 'Marks';

  @override
  String get personaCategoryExpression => 'Expression';

  @override
  String get personaCategoryHeadwear => 'Headwear';

  @override
  String get personaCategoryGarment => 'Clothing';

  @override
  String get personaCategoryGarmentColor => 'Colour';

  @override
  String get personaCategoryAccessory => 'Carry';

  @override
  String get personaCategorySigil => 'Banner';

  @override
  String personaSkinTone(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'sand': 'Sand',
      'honey': 'Honey',
      'clay': 'Clay',
      'copper': 'Copper',
      'chestnut': 'Chestnut',
      'walnut': 'Walnut',
      'umber': 'Umber',
      'ebony': 'Ebony',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaFace(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'oval': 'Oval',
      'round': 'Round',
      'square': 'Square',
      'long': 'Long',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHair(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'bald': 'Bald',
      'buzz': 'Buzz cut',
      'short': 'Short',
      'wavy': 'Wavy',
      'curly': 'Curly',
      'coily': 'Coily',
      'afro': 'Afro',
      'locs': 'Locs',
      'braids': 'Braids',
      'bun': 'Bun',
      'long': 'Long',
      'ponytail': 'Ponytail',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHairColor(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'black': 'Black',
      'darkBrown': 'Dark brown',
      'brown': 'Brown',
      'auburn': 'Auburn',
      'copper': 'Copper',
      'blonde': 'Blonde',
      'grey': 'Grey',
      'white': 'White',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaFacialHair(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'None',
      'stubble': 'Stubble',
      'moustache': 'Moustache',
      'beard': 'Beard',
      'fullBeard': 'Full beard',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaEyewear(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'None',
      'round': 'Round glasses',
      'square': 'Square glasses',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaMark(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'None',
      'freckles': 'Freckles',
      'beautyMark': 'Beauty mark',
      'vitiligo': 'Vitiligo',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaExpression(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'calm': 'Calm',
      'smile': 'Smile',
      'focused': 'Focused',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHeadwear(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'None',
      'headscarf': 'Headscarf',
      'turban': 'Turban',
      'hood': 'Hood',
      'circlet': 'Circlet',
      'laurel': 'Laurel wreath',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaGarment(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'tunic': 'Tunic',
      'cloak': 'Cloak',
      'robe': 'Robe',
      'wrap': 'Wrap',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaGarmentColor(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'forest': 'Forest',
      'olive': 'Olive',
      'sand': 'Sand',
      'ivory': 'Ivory',
      'sage': 'Sage',
      'indigo': 'Indigo',
      'crimson': 'Crimson',
      'bronze': 'Bronze',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaAccessory(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'None',
      'satchel': 'Satchel',
      'scroll': 'Scroll',
      'compass': 'Compass',
      'amulet': 'Amulet of Tanit',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaSigil(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'None',
      'elephant': 'Elephant',
      'sun': 'Rising sun',
      'path': 'Path',
      'compass': 'Compass',
      'star': 'North star',
      'laurel': 'Laurel',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String get personaBuilderSurprise => 'Surprise me';

  @override
  String get personaBuilderSurprised => 'New look. Not saved yet.';

  @override
  String get personaBuilderUndo => 'Undo';

  @override
  String get personaBuilderParts => 'Avatar parts';

  @override
  String personaBuilderPartLabel(String category, String value) {
    return '$category: $value';
  }

  @override
  String personaBuilderPreviewLabel(String parts) {
    return 'Avatar preview. $parts';
  }

  @override
  String get personaBuilderLockedNote =>
      'Locked extras open with reward picks.';

  @override
  String get personaBuilderKept => 'Yours to keep';

  @override
  String get personaBuilderHiddenSilhouette =>
      'Pick a skin tone to see the face and colours.';

  @override
  String get personaBuilderHiddenHeadwear =>
      'Hair is hidden under your headwear.';

  @override
  String get personaBuilderMottoLabel => 'Motto (optional)';

  @override
  String get personaBuilderMottoHint => 'A few words of your own';

  @override
  String personaBuilderMottoCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get personaBuilderMottoTooLong =>
      'A little too long. Shorten it to save.';

  @override
  String personaBuilderMottoQuoted(String motto) {
    return '“$motto”';
  }

  @override
  String get personaBuilderSaved => 'Avatar saved.';

  @override
  String get personaBuilderNotSaved =>
      'Not saved on this phone yet. Retry at the top, or export a copy.';

  @override
  String get personaBuilderRemove => 'Remove avatar';

  @override
  String get personaBuilderRemoveTitle => 'Remove your avatar?';

  @override
  String get personaBuilderRemoveBody =>
      'Your profile shows the emblem again. Make a new one anytime.';

  @override
  String get personaBuilderRemoveAction => 'Remove';

  @override
  String get personaBuilderRemoved => 'Avatar removed.';

  @override
  String get personaBuilderRemovedNotSaved =>
      'Removed here, but not saved on this phone yet. Retry at the top.';

  @override
  String get personaBuilderLeaveTitle => 'Leave without saving?';

  @override
  String get personaBuilderLeaveBody => 'Your avatar changes won\'t be kept.';

  @override
  String get personaBuilderLeaveAction => 'Leave';

  @override
  String get personaBuilderKeepEditing => 'Keep editing';

  @override
  String get personaBuilderProfileHint =>
      'Name and avatar are optional and stay on this phone.';

  @override
  String get projectsPictureTitle => 'Picture';

  @override
  String get projectsPictureEmpty =>
      'A painted scene or a photo. It shows on this project\'s tasks.';

  @override
  String get projectsPictureChoose => 'Choose a picture';

  @override
  String get projectsPictureChange => 'Change picture';

  @override
  String get projectsPictureRemove => 'Remove picture';

  @override
  String get projectsPictureRemoved => 'Picture removed';

  @override
  String get projectsPhotoRemoveTitle => 'Remove the photo?';

  @override
  String get projectsPhotoRemoveBody =>
      'It\'s deleted from the app. Photos in your gallery aren\'t touched.';

  @override
  String get projectsPhotoRemoveConfirm => 'Remove photo';

  @override
  String get projectsClearBodyPhoto =>
      'Its title, milestones, notes and photo go for good. Your Compass, tasks and attempts stay.';

  @override
  String get projectsDeleteFinishInstead => 'Finish and keep instead';

  @override
  String get projectsDeletedCurrent => 'Project deleted';

  @override
  String projectsPictureLabel(String name) {
    return 'Project picture: $name';
  }

  @override
  String get projectsPhotoName => 'your photo';

  @override
  String get projectsPhotoMissing => 'Photo not found on this phone';

  @override
  String get projectsArtSheetTitle => 'Project picture';

  @override
  String get projectsArtScenes => 'Painted scenes';

  @override
  String get projectsArtPhoto => 'Your photo';

  @override
  String get projectsArtPhotoNote => 'Photos stay on this phone.';

  @override
  String get projectsArtChoosePhoto => 'Choose a photo';

  @override
  String get projectsArtTakePhoto => 'Take a photo';

  @override
  String get projectsArtAdding => 'Adding the photo…';

  @override
  String get projectsArtSelected => 'Selected';

  @override
  String get projectsArtReplacesPhoto =>
      'Choosing another picture deletes your photo from the app.';

  @override
  String get projectsArtSunrise => 'Sunrise';

  @override
  String get projectsArtPath => 'Winding road';

  @override
  String get projectsArtCompass => 'Compass hill';

  @override
  String get projectsArtSteps => 'Stone steps';

  @override
  String get projectsArtDawnRuins => 'Ruins at dawn';

  @override
  String get projectsArtRoots => 'Deep roots';

  @override
  String get projectsArtCitadel => 'Hill town';

  @override
  String get projectsArtSailing => 'Sailing';

  @override
  String get projectsArtRoute => 'Summit route';

  @override
  String get projectsPhotoDeniedCamera =>
      'Camera access is off. Allow it in Settings, or choose a photo or a painted scene.';

  @override
  String get projectsPhotoDeniedLibrary =>
      'Photo access is off. Allow it in Settings, or pick a painted scene.';

  @override
  String get projectsPhotoNoCamera =>
      'No camera here. Choose a photo or a painted scene.';

  @override
  String get projectsPhotoNoLibrary =>
      'Photos aren\'t available here. Pick a painted scene.';

  @override
  String get projectsPhotoFailed =>
      'Couldn\'t get the photo. Try again, or pick a painted scene.';

  @override
  String get projectsPhotoTooLarge =>
      'That photo is too large to keep. Try another one.';

  @override
  String get projectsPhotoNotKept =>
      'Couldn\'t keep the photo on this phone. Check free space and try again.';

  @override
  String get projectsNotSaved => 'Not saved yet. Use Retry on this page.';

  @override
  String get projectsFinish => 'Finish this project';

  @override
  String get projectsFinishSheetBody =>
      'It moves to your history with its milestones, tasks and attempts.';

  @override
  String get projectsFinishConfirm => 'Finish and keep';

  @override
  String get projectsFinishedSnack => 'Kept in your project history.';

  @override
  String get projectsFinishedTitle => 'Finished and kept';

  @override
  String projectsFinishedBody(String title) {
    return '“$title” is in your project history.';
  }

  @override
  String get projectsPlanNext => 'Plan the next one';

  @override
  String get projectsViewHistory => 'View history';

  @override
  String projectsHistoryLink(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Project history · $count',
      one: 'Project history · 1',
    );
    return '$_temp0';
  }

  @override
  String get projectsCardNext => 'Plan your next project.';

  @override
  String get projectsHistoryTitle => 'Past projects';

  @override
  String get projectsHistorySubtitle => 'What you built, month by month.';

  @override
  String get projectsHistoryEmptyTitle => 'Nothing here yet';

  @override
  String get projectsHistoryEmptyBody =>
      'Finish a month project to keep it here.';

  @override
  String projectsMonths(String start, String end) {
    return '$start – $end';
  }

  @override
  String projectsTasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String projectsAttemptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts',
      one: '1 attempt',
      zero: 'No attempts',
    );
    return '$_temp0';
  }

  @override
  String get projectsNoMilestones => 'No milestones';

  @override
  String get projectsRetroEmpty => 'No notes written.';

  @override
  String get projectsPastTitle => 'Past project';

  @override
  String projectsFinishedOn(String date) {
    return 'Finished $date';
  }

  @override
  String get projectsMilestoneDone => 'Done';

  @override
  String get projectsMilestoneOpen => 'Open';

  @override
  String get projectsTasks => 'Tasks';

  @override
  String get projectsTasksEmpty => 'No tasks linked to it.';

  @override
  String get projectsAttempts => 'Attempts';

  @override
  String get projectsAttemptsEmpty => 'No attempts linked to it.';

  @override
  String get projectsTaskDone => 'Done';

  @override
  String get projectsDelete => 'Remove from history';

  @override
  String get projectsDeleteTitle => 'Remove this project?';

  @override
  String get projectsDeleteBody =>
      'Its title, milestones, notes and picture go. Its tasks and attempts stay.';

  @override
  String get projectsDeleteConfirm => 'Remove';

  @override
  String get projectsDeleted => 'Project removed';

  @override
  String projectsTagLabel(String title) {
    return 'Project: $title';
  }

  @override
  String get projectsQuestLink => 'Part of the month project';

  @override
  String get projectsQuestLinkPast => 'Part of a finished project';

  @override
  String projectsKeepsakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Projects finished',
      one: 'Project finished',
    );
    return '$_temp0';
  }

  @override
  String projectsKeepsakesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projects kept',
      one: '1 project kept',
    );
    return '$_temp0';
  }

  @override
  String get resetTitle => 'The Reset';

  @override
  String get resetSubtitle => 'One day: see where you are, choose where to go.';

  @override
  String get resetPaceOneDayTitle => 'Your pace: one day';

  @override
  String get resetPaceOneDayBody =>
      'Morning, daytime, evening. Nothing locks if it takes longer.';

  @override
  String get resetPaceFlexibleTitle => 'Your pace: flexible';

  @override
  String get resetPaceFlexibleBody =>
      'Any order, any pace. Nothing locks or expires.';

  @override
  String get resetPaceChange => 'Change pace';

  @override
  String get resetProgressTitle => 'Your reset';

  @override
  String resetProgressCount(int answered, int total) {
    return '$answered of $total core questions answered';
  }

  @override
  String resetProgressNext(String title) {
    return 'Next: $title';
  }

  @override
  String get resetBegin => 'Begin';

  @override
  String get resetContinue => 'Continue';

  @override
  String get resetAllDoneBody =>
      'Every core question is answered or skipped. You can still edit them.';

  @override
  String get resetSeeCreated => 'See what you created';

  @override
  String resetCompletedOn(String date) {
    return 'Finished on $date. Answers stay editable.';
  }

  @override
  String get resetPhasesTitle => 'Your day';

  @override
  String get resetPhaseMorning => 'Morning';

  @override
  String get resetPhaseDaytime => 'Daytime';

  @override
  String get resetPhaseBonus => 'Optional';

  @override
  String get resetPhaseEvening => 'Evening';

  @override
  String get resetSubflowMirror => 'The Mirror';

  @override
  String get resetSubflowVision => 'The Vision';

  @override
  String get resetSubflowInterrupt => 'The Interrupt';

  @override
  String get resetSubflowBreakthrough => 'The Breakthrough';

  @override
  String get resetMirrorBody => 'Current reality, possible futures, identity';

  @override
  String get resetVisionBody =>
      'A good ordinary day, who you want to be, one step';

  @override
  String get resetInterruptBody => 'Six short check-ins at moments in your day';

  @override
  String get resetBreakthroughBody => 'Insights, direction and a plan';

  @override
  String get resetGroupCurrentReality => 'Current reality';

  @override
  String get resetGroupAntiVision => 'A future you don\'t want';

  @override
  String get resetGroupIdentity => 'Identity';

  @override
  String get resetGroupVision => 'Vision';

  @override
  String get resetGroupInterrupt => 'Check-in';

  @override
  String get resetGroupContemplation => 'Contemplation';

  @override
  String get resetGroupInsight => 'Insights';

  @override
  String get resetGroupDirection => 'Direction';

  @override
  String get resetGroupPlan => 'Plan';

  @override
  String resetCountAnswered(int answered, int total) {
    return '$answered of $total answered';
  }

  @override
  String resetCountAnsweredSkipped(int answered, int total, int skipped) {
    return '$answered of $total answered, $skipped skipped';
  }

  @override
  String get resetCountNotStarted => 'Not started yet';

  @override
  String resetRingLabel(int answered, int total) {
    return '$answered/$total';
  }

  @override
  String resetOpenPhase(String phase) {
    return 'Open the $phase questions';
  }

  @override
  String get resetStateAnswered => 'Answered';

  @override
  String get resetStateSkipped => 'Skipped';

  @override
  String get resetStateOpen => 'Not answered yet';

  @override
  String get resetStateCurrent => 'You are here';

  @override
  String resetCheckinTime(String time) {
    return 'Check-in · $time';
  }

  @override
  String get resetOptionalTitle => 'Optional contemplations';

  @override
  String get resetOptionalBody => 'Three extra questions. Optional.';

  @override
  String get resetOptionalChip => 'Optional';

  @override
  String get resetPastTitle => 'Past resets';

  @override
  String resetPastStarted(String date) {
    return 'Started $date';
  }

  @override
  String resetPastFinished(String date) {
    return 'Finished $date';
  }

  @override
  String get resetPastUnfinished => 'Not finished';

  @override
  String resetPastAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers',
      one: '1 answer',
      zero: 'No answers',
    );
    return '$_temp0';
  }

  @override
  String get resetNewTitle => 'Start a new reset';

  @override
  String get resetNewBody => 'Start fresh. This reset stays under Past resets.';

  @override
  String get resetNewConfirmTitle => 'Start a new reset?';

  @override
  String get resetNewConfirmBody =>
      'Your answers move to Past resets. Compass, quests and journal stay.';

  @override
  String get resetNewConfirmAction => 'Start new reset';

  @override
  String get resetNewStarted =>
      'New reset started. The earlier one is under Past resets.';

  @override
  String resetQuestionOf(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get resetPauseTooltip => 'Pause and return to the Reset';

  @override
  String get resetJumpTooltip => 'Jump to a question';

  @override
  String get resetJump => 'Jump';

  @override
  String resetJumpTitle(String phase) {
    return '$phase questions';
  }

  @override
  String get resetSofter => 'Softer wording';

  @override
  String get resetSofterHint => 'The same question, asked more gently.';

  @override
  String get resetHelpLink => 'What does this mean?';

  @override
  String get resetExampleTitle => 'Example — not a right answer';

  @override
  String get resetAnswerLabel => 'Your answer';

  @override
  String get resetAnswerHint => 'Write as much or as little as you like.';

  @override
  String get resetSkippedNote => 'Skipped. Come back anytime, or leave it.';

  @override
  String get resetSaveContinue => 'Save & continue';

  @override
  String get resetSaveFinish => 'Save & finish';

  @override
  String get resetSkip => 'Skip for now';

  @override
  String get resetPause => 'Pause';

  @override
  String get resetHeavyLink => 'Feeling heavy?';

  @override
  String get resetHeavyTitle => 'This can be a lot';

  @override
  String get resetHeavyBody =>
      'Go as deep as you like: soften, skip or stop. Your words are saved.';

  @override
  String get resetHeavySofter => 'Switch to softer wording';

  @override
  String get resetHeavySkip => 'Skip this question';

  @override
  String get resetHeavyPause => 'Take a pause';

  @override
  String get resetHeavySupport => 'Support and safety';

  @override
  String get resetHeavyCrisis =>
      'Cartharise isn\'t therapy. If you feel unsafe, contact emergency services or a crisis line now.';

  @override
  String get resetPromptMissing => 'This question isn\'t available.';

  @override
  String get resetCompleteTitle => 'Reset complete';

  @override
  String get resetCompleteLead =>
      'One day can bring clarity; the rest is practice.';

  @override
  String get resetCompleteCreatedTitle => 'What you created';

  @override
  String resetCompleteAnswers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count answers written',
      one: '1 answer written',
      zero: 'No answers written',
    );
    return '$_temp0';
  }

  @override
  String resetCompleteSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions skipped',
      one: '1 question skipped',
    );
    return '$_temp0';
  }

  @override
  String resetCompletePhaseLine(String phase, int answered, int total) {
    return '$phase: $answered of $total answered';
  }

  @override
  String get resetCompleteVisionTitle => 'Your vision, in your words';

  @override
  String resetCompleteOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count core questions are still open.',
      one: '1 core question is still open.',
    );
    return '$_temp0';
  }

  @override
  String get resetCompleteCompassBody =>
      'Your evening answers can start your Life Compass. You choose; nothing is overwritten.';

  @override
  String get resetCompleteBuildCompass => 'Build your Compass';

  @override
  String get resetCompleteLater => 'Later';

  @override
  String todayGreetingMorning(String name) {
    return 'Good morning, $name.';
  }

  @override
  String todayGreetingAfternoon(String name) {
    return 'Good afternoon, $name.';
  }

  @override
  String todayGreetingEvening(String name) {
    return 'Good evening, $name.';
  }

  @override
  String get todayDefaultName => 'Traveler';

  @override
  String get todaySubtitle => 'Clarity today. Progress tomorrow.';

  @override
  String get todayNextEyebrow => 'Your next step';

  @override
  String get todayNextStartTitle => 'Begin the morning reflection';

  @override
  String todayNextStartBody(int count) {
    return '$count short questions. Skip any, pause anytime.';
  }

  @override
  String get todayNextStartHint =>
      'Morning, daytime, evening: one day, at your own pace.';

  @override
  String get todayNextStartAction => 'Begin';

  @override
  String todayNextLessonsAction(int count) {
    return 'Learn the $count ideas (optional)';
  }

  @override
  String todayNextResumeTitle(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'morning': 'Continue the morning reflection',
      'daytime': 'Continue the daytime check-ins',
      'evening': 'Continue the evening reflection',
      'other': 'Continue your reset',
    });
    return '$_temp0';
  }

  @override
  String todayNextResumeBody(String title) {
    return 'Next: $title';
  }

  @override
  String todayNextResumePosition(String phase, int ordinal, int total) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'morning': 'Morning',
      'daytime': 'Daytime',
      'evening': 'Evening',
      'other': 'Reset',
    });
    return '$_temp0 · question $ordinal of $total';
  }

  @override
  String get todayNextResumeAction => 'Continue';

  @override
  String get todayNextQuestBody => 'One of today\'s quests.';

  @override
  String get todayNextQuestAction => 'Mark done';

  @override
  String get todayNextQuestOption => 'Do one of today\'s quests';

  @override
  String get todayNextCompassTitle => 'Build your Compass';

  @override
  String get todayNextCompassImportBody =>
      'Your evening answers can fill your Compass. You choose.';

  @override
  String get todayNextCompassManualBody =>
      'Write your vision, a month project and daily levers.';

  @override
  String get todayNextCompassImportAction => 'Review your answers';

  @override
  String get todayNextLeversTitle => 'Turn your levers into quests';

  @override
  String get todayNextLeversBody => 'Turn your daily levers into small quests.';

  @override
  String get todayNextLeversAction => 'Choose quests';

  @override
  String get todayNextProjectTitle => 'Work on your project';

  @override
  String todayNextProjectNext(String milestone) {
    return 'Next: $milestone';
  }

  @override
  String get todayNextProjectAction => 'Open the project';

  @override
  String get todayNextReviewTitle => 'Look back on your week';

  @override
  String get todayNextReviewBody =>
      'What went well, what got in the way, what\'s next.';

  @override
  String get todayNextReviewAction => 'Start a weekly review';

  @override
  String get todayNextJournalTitle => 'Write a note';

  @override
  String get todayNextJournalBody => 'A few lines about today.';

  @override
  String get todayNextJournalAction => 'New note';

  @override
  String get todayOpenCompass => 'Open Compass';

  @override
  String get todayChooseOther => 'Choose something else';

  @override
  String get todayChooseSteps => 'Other steps';

  @override
  String get todayPinTitle => 'Help me with';

  @override
  String get todayPinProject => 'My project';

  @override
  String get todayPinReflection => 'Reflection';

  @override
  String get todayPinNotes => 'Notes';

  @override
  String get todayPinAuto => 'Decide for me';

  @override
  String get todayPinNoProject => 'No project yet. Today decides for now.';

  @override
  String get todayDoneTitle => 'Done. That can be enough for today.';

  @override
  String get todayDoneMore => 'One more';

  @override
  String get todayDoneMoreLabel => 'Show one more step';

  @override
  String get todayWriteHint => 'Write a few lines…';

  @override
  String get todayWriteLabel => 'Write a new note';

  @override
  String get todayFocusTitle => 'Today\'s focus';

  @override
  String get todayFocusEmptyTitle => 'No quests for today';

  @override
  String get todayFocusEmptyBody => 'Add a small quest when you\'re ready.';

  @override
  String get todayHintQuests =>
      'Quests are small steps you choose. Adjust them each week.';

  @override
  String get todayFocusAdd => 'Add a quest';

  @override
  String todayFocusSeeAll(int count) {
    return 'See all $count quests';
  }

  @override
  String todayFocusLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more for anytime or later',
      one: '1 more for anytime or later',
    );
    return '$_temp0';
  }

  @override
  String todayQuestMarkDone(String title) {
    return 'Mark \'$title\' done';
  }

  @override
  String get todayQuestDaily => 'Every day';

  @override
  String todayJourneyWritten(int answered, int total) {
    return '$answered of $total reflections written';
  }

  @override
  String get todayJourneyOpenReset => 'Open the reset';

  @override
  String todayPathDay(int day) {
    return 'Day $day of 30';
  }

  @override
  String todayPathOpen(int day) {
    return 'Open day $day';
  }

  @override
  String get todayDirectionTitle => 'Your direction';

  @override
  String get todayDirectionSummary => 'Your vision and this month\'s project.';

  @override
  String todayDirectionLabel(String title, String summary) {
    return '$title. $summary';
  }

  @override
  String get todayDirectionEmpty => 'Your Compass is empty.';

  @override
  String get todayHintCompass => 'Your answers can become a Life Compass.';

  @override
  String get todayDirectionVision => 'Vision';

  @override
  String get todayDirectionMonth => 'This month';

  @override
  String get todayDirectionNoVision => 'No vision written yet.';

  @override
  String get todayDirectionNoMonth => 'No month project yet.';

  @override
  String get todayTileReset => 'Reset';

  @override
  String todayTileResetValue(int answered, int total) {
    return '$answered/$total';
  }

  @override
  String get todayTileResetStart => 'Start';

  @override
  String get todayTileResetDone => 'Done';

  @override
  String get todayTileResetDetail => 'reflections';

  @override
  String get todayTileCampaign => 'Campaign';

  @override
  String todayTileCampaignValue(int level) {
    return 'Level $level';
  }

  @override
  String get todayTilePath => '30-day path';

  @override
  String todayTilePathValue(int day) {
    return 'Day $day';
  }

  @override
  String todayPathStageName(String stage) {
    String _temp0 = intl.Intl.selectLogic(stage, {
      'observe': 'Observe',
      'experiment': 'Experiment',
      'build': 'Build',
      'adjust': 'Adjust',
      'other': 'Path',
    });
    return '$_temp0';
  }

  @override
  String todayTileLabel(String title, String value, String detail) {
    return '$title: $value. $detail';
  }

  @override
  String get youTitle => 'You';

  @override
  String get youSubtitle => 'Your space, your choices.';

  @override
  String get youProfileEyebrow => 'Profile';

  @override
  String get youNoName => 'No name set';

  @override
  String get youProfileBody => 'Optional, stays on this phone. Tap to change.';

  @override
  String get youEditName => 'Edit name';

  @override
  String get youNameDialogTitle => 'Your name';

  @override
  String get youNameHint => 'Optional';

  @override
  String get youPaceTitle => 'Pace';

  @override
  String get youPaceOneDay => 'One day';

  @override
  String get youPaceFlexible => 'Flexible';

  @override
  String get youPaceHint => 'Nothing locks. Change anytime.';

  @override
  String get youSectionCredit => 'Credit';

  @override
  String get youSectionSettings => 'Settings';

  @override
  String get youSectionCare => 'Care';

  @override
  String get youSectionAbout => 'About';

  @override
  String get youInspiration => 'Inspiration';

  @override
  String get youInspirationHint => 'The article behind Cartharise';

  @override
  String get youReminders => 'Reminders';

  @override
  String get youRemindersOn => 'On';

  @override
  String get youRemindersOff => 'Off';

  @override
  String get youAppearance => 'Appearance';

  @override
  String youAppearanceSummary(String theme, String mode) {
    return '$theme · $mode';
  }

  @override
  String get youData => 'Your data';

  @override
  String get youDataHint => 'Export, restore or delete';

  @override
  String get youSupport => 'Support & safety';

  @override
  String get youSupportHint => 'Not therapy. Help if things feel heavy.';

  @override
  String youVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get youAboutBody => 'Independent. Everything stays on this phone.';

  @override
  String get youLicences => 'Open-source licences';

  @override
  String get youLicencesHint =>
      'Including the Inter and Cinzel fonts (SIL Open Font License)';

  @override
  String youLegalese(String title, String author) {
    return 'Independent app inspired by “$title” by $author. Not affiliated with or endorsed by the author.';
  }

  @override
  String get youReplayWelcome => 'Replay the welcome';

  @override
  String get youReplayWelcomeHint =>
      'See the introduction again. Nothing you\'ve written changes.';

  @override
  String get youReplayConfirmTitle => 'Replay the welcome?';

  @override
  String get youReplayConfirmBody =>
      'See the introduction again. Your writing and settings stay.';

  @override
  String get youReplayConfirmAction => 'Show the welcome';

  @override
  String get youInspirationTitle => 'Inspiration';

  @override
  String get youInspirationSubtitle => 'The work that inspired Cartharise';

  @override
  String get youInspirationEyebrow => 'Inspired by';

  @override
  String youInspirationByline(String author) {
    return 'by $author';
  }

  @override
  String youInspirationPublished(String date) {
    return 'Published $date';
  }

  @override
  String get youInspirationReadArticle => 'Read the article on X';

  @override
  String get youInspirationReadNewsletter => 'Read the newsletter version';

  @override
  String youInspirationLinkHint(String host) {
    return 'Opens in your browser: $host';
  }

  @override
  String get youInspirationIndependentTitle => 'An independent app';

  @override
  String get youInspirationParaphraseTitle => 'In Cartharise\'s own words';

  @override
  String get youInspirationSplitTitle =>
      'From the source, or added by Cartharise?';

  @override
  String get youInspirationFromSource => 'From the article, paraphrased';

  @override
  String get youInspirationSource1 =>
      'The seven central ideas behind the Awakening lessons';

  @override
  String get youInspirationSource2 =>
      'The morning, daytime and evening reset questions';

  @override
  String get youInspirationSource3 => 'The six parts of the Life Compass';

  @override
  String get youInspirationSource4 => 'The six daytime check-in times';

  @override
  String get youInspirationAdded => 'Added by Cartharise';

  @override
  String get youInspirationAdded1 => 'Examples, help texts and softer wording';

  @override
  String get youInspirationAdded2 =>
      'Quests, the Today view and the thirty-day path';

  @override
  String get youInspirationAdded3 =>
      'Journal notes, weekly reviews and Look back';

  @override
  String get youInspirationAdded4 => 'Reminders, calendar export and backups';

  @override
  String get youInspirationReadOriginal =>
      'For the author\'s full reasoning, read the original.';

  @override
  String get youRemindersTitle => 'Reminders';

  @override
  String get youRemindersSubtitle => 'Six optional check-ins during the day.';

  @override
  String get youRemindersSwitch => 'Check-in notifications';

  @override
  String get youRemindersSwitchOn => 'On, at the times below.';

  @override
  String get youRemindersSwitchOff =>
      'Off. Nothing is sent until you turn this on.';

  @override
  String get youRemindersPrivacy =>
      'Notifications show the check-in title only, never your words.';

  @override
  String get youRemindersDeniedTitle => 'Notifications aren\'t allowed';

  @override
  String get youRemindersDeniedBody =>
      'Notifications are blocked for Cartharise. Allow them in your phone settings, or add the check-ins to your calendar.';

  @override
  String get youRemindersUnavailableTitle => 'Notifications aren\'t available';

  @override
  String get youRemindersUnavailableBody =>
      'This phone can\'t show notifications. Add the check-ins to your calendar instead.';

  @override
  String get youRemindersScheduleFailed =>
      'Couldn\'t schedule the notifications. Try again, or use your calendar.';

  @override
  String get youRemindersCalendarInstead => 'Add to your calendar instead';

  @override
  String get youRemindersTimesTitle => 'Check-in times';

  @override
  String get youRemindersTimesBody =>
      'Local time. Change any to suit your day.';

  @override
  String youRemindersSourceDefault(String time) {
    return 'Source default $time';
  }

  @override
  String youRemindersUseDefault(String time) {
    return 'Use $time';
  }

  @override
  String youRemindersChangeTime(String title, String time) {
    return 'Change the time for $title, now $time';
  }

  @override
  String youRemindersRowLabel(String title, String time) {
    return 'Check-in $title, $time';
  }

  @override
  String get youRemindersQuietTitle => 'Quiet hours';

  @override
  String get youRemindersQuietBody =>
      'No check-in notifications between these times.';

  @override
  String get youRemindersQuietFrom => 'From';

  @override
  String get youRemindersQuietUntil => 'Until';

  @override
  String get youRemindersQuietNotSet => 'Not set';

  @override
  String get youRemindersQuietClear => 'Clear quiet hours';

  @override
  String get youRemindersQuietIncomplete =>
      'Set both times for quiet hours to apply.';

  @override
  String get youRemindersCalendarTitle => 'Add to your calendar';

  @override
  String get youRemindersCalendarBody =>
      'A calendar file with your check-ins for 30 days. Titles only.';

  @override
  String get youRemindersCalendarButton => 'Add to calendar (.ics)';

  @override
  String get youRemindersCalendarNone =>
      'Switch on at least one check-in to create the file.';

  @override
  String get youCalendarName => 'Cartharise check-ins';

  @override
  String youCalendarEventTitle(String title) {
    return 'Cartharise check-in: $title';
  }

  @override
  String get youCalendarEventDescription =>
      'A short daytime pause from your Cartharise reset. Open the app when it suits you; every check-in is optional.';

  @override
  String get youRemindersCalendarShared =>
      'Calendar file shared. Open it in your calendar app.';

  @override
  String get youShareDismissed => 'Nothing was shared.';

  @override
  String get youAppearanceTitle => 'Appearance';

  @override
  String get youAppearanceSubtitle => 'Colours, light or dark, and motion.';

  @override
  String get youThemeTitle => 'Theme';

  @override
  String get youThemeForest => 'Forest';

  @override
  String get youThemeOlive => 'Olive';

  @override
  String get youThemeOasis => 'Oasis';

  @override
  String get youThemeTyrian => 'Tyrian Rose';

  @override
  String get youThemeAlpine => 'Alpine';

  @override
  String get youThemeObsidian => 'Obsidian';

  @override
  String get youThemeAboutForest =>
      'Deep forest and bronze: the Cartharise original.';

  @override
  String get youThemeAboutOlive => 'The olive groves of the Punic countryside.';

  @override
  String get youThemeAboutOasis =>
      'Palm green and date gold of the desert oases.';

  @override
  String get youThemeAboutTyrian =>
      'The rose dye of Tyre, Carthage\'s mother city.';

  @override
  String get youThemeAboutAlpine =>
      'Granite and snow, where Hannibal crossed the Alps.';

  @override
  String get youThemeAboutObsidian =>
      'Volcanic black glass and gold. True black when dark.';

  @override
  String get youModeTitle => 'Light or dark';

  @override
  String get youModeSystem => 'System';

  @override
  String get youModeLight => 'Light';

  @override
  String get youModeDark => 'Dark';

  @override
  String get youMotion => 'Interface motion';

  @override
  String get youMotionHint =>
      'Screen transitions and the animated emblem. Off when your phone reduces motion.';

  @override
  String get youDataTitle => 'Your data';

  @override
  String get youDataSubtitle => 'Everything you write stays on this phone.';

  @override
  String get youDataWhereTitle => 'Where your data lives';

  @override
  String get youDataExportTitle => 'Export a backup';

  @override
  String get youDataExportBody =>
      'Saves everything, photos and recordings too, as one .zip file. It isn\'t encrypted, so keep it private.';

  @override
  String get youDataExportButton => 'Export backup';

  @override
  String get youDataExported => 'Backup shared.';

  @override
  String get youDataExportedPartial =>
      'Backup shared, but some photos or recordings couldn\'t be read and aren\'t in it.';

  @override
  String get youDataImportTitle => 'Restore a backup';

  @override
  String get youDataImportBody =>
      'Replaces everything with a backup. You\'ll confirm first.';

  @override
  String get youDataImportButton => 'Choose a backup file';

  @override
  String get youDataImportConfirmTitle => 'Restore this backup?';

  @override
  String youDataImportConfirmBody(String date) {
    return 'Replace everything on this phone with the backup from $date?';
  }

  @override
  String get youDataImportConfirmAction => 'Replace';

  @override
  String get youDataImportUnknownDate => 'an unknown date';

  @override
  String youDataImportMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count photos or recordings it names are missing. Their entries are kept.',
      one: 'One photo or recording it names is missing. Its entry is kept.',
    );
    return '$_temp0';
  }

  @override
  String get youDataImportFilesFailed =>
      'Its photos and recordings couldn\'t be saved on this phone.';

  @override
  String get youDataImported => 'Backup restored.';

  @override
  String get youDataImportedNotSaved =>
      'Backup opened but not saved yet. Retry at the top, or export a copy.';

  @override
  String get youDataImportFailedTitle => 'This file couldn\'t be used';

  @override
  String get youDataImportUnchanged => 'Your current data was not changed.';

  @override
  String get youDataImportNotJson => 'It isn\'t a readable backup file.';

  @override
  String get youDataImportNotBackup => 'It isn\'t a Cartharise backup.';

  @override
  String get youDataImportUnsupported =>
      'This backup format isn\'t supported by this version.';

  @override
  String get youDataImportDamaged => 'The backup is incomplete or damaged.';

  @override
  String get youDataImportTooLarge =>
      'The file is too large to be a Cartharise backup.';

  @override
  String get youDataImportNotText => 'It isn\'t a text file.';

  @override
  String get youDataImportOpenFailed => 'The file couldn\'t be opened.';

  @override
  String get youDataDeleteTitle => 'Delete all data';

  @override
  String get youDataDeleteBody =>
      'Erases everything on this phone and cancels reminders. Export first to keep a copy.';

  @override
  String get youDataDeleteButton => 'Delete all data';

  @override
  String get youDataDeleteConfirm1Title => 'Delete all data?';

  @override
  String get youDataDeleteConfirm1Body =>
      'Answers, Compass, quests, notes, photos, recordings, reviews and settings will be erased.';

  @override
  String get youDataDeleteConfirm1Action => 'Continue';

  @override
  String get youDataDeleteConfirm2Title => 'This can\'t be undone';

  @override
  String get youDataDeleteConfirm2Body =>
      'There\'s no other copy. Only an exported backup can bring it back.';

  @override
  String get youDataDeleteConfirm2Action => 'Delete everything';

  @override
  String get youDataDeleteFailed =>
      'Couldn\'t delete. Your writing is still here; try again.';

  @override
  String get youDataDeleteCopiesLeft =>
      'Deleted, but a temporary export copy couldn\'t be removed. Removing the app erases it.';

  @override
  String get youDataDeleteFilesLeft =>
      'Deleted, but some photos or recordings couldn\'t be removed yet. Opening the app again removes them.';

  @override
  String get youSupportTitle => 'Support & safety';

  @override
  String get youSupportSubtitle =>
      'Reflection can stir things up. That\'s normal.';

  @override
  String get youSupportNotTherapyTitle => 'Not therapy';

  @override
  String get youSupportNotTherapyBody =>
      'A self-reflection tool. Not therapy, counselling, medical advice or diagnosis.';

  @override
  String get youSupportHeavyTitle => 'If a question feels heavy';

  @override
  String get youSupportHeavy1 => 'Skip it. Every question is optional.';

  @override
  String get youSupportHeavy2 =>
      'Switch to the softer wording where it\'s offered.';

  @override
  String get youSupportHeavy3 =>
      'Pause and come back another day. Your words are kept.';

  @override
  String get youSupportHeavy4 => 'Talk it through with someone you trust.';

  @override
  String get youSupportCrisisTitle => 'If you\'re in crisis';

  @override
  String get youSupportCrisisBody =>
      'In danger or thinking of harming yourself? Contact emergency services now, or a crisis line in your country.';

  @override
  String get youSupportFindHelpline => 'Find a helpline';

  @override
  String get youSupportHelplineHint =>
      'Opens findahelpline.com, helplines by country.';

  @override
  String get youSupportOngoingTitle => 'Ongoing support';

  @override
  String get youSupportOngoingBody =>
      'If hard feelings last, a doctor or counsellor can help.';
}
