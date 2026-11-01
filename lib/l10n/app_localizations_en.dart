// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
      'Your words are still here on screen. Try saving again, or export a copy so nothing is lost.';

  @override
  String get saveExportCopy => 'Export a copy';

  @override
  String get bootLoading => 'Preparing your space…';

  @override
  String get bootLoadErrorTitle => 'Your saved data couldn\'t be opened';

  @override
  String get bootLoadErrorBody =>
      'Cartharise couldn\'t read the file it keeps on this phone. Nothing has been deleted or overwritten.';

  @override
  String get bootLoadErrorHint =>
      'Try again. If it keeps happening, check that your phone has free storage, then try once more.';

  @override
  String get bootStartFresh => 'Start fresh and keep the unreadable file';

  @override
  String get bootStartFreshConfirmTitle => 'Start fresh?';

  @override
  String get bootStartFreshConfirmBody =>
      'The unreadable file is set aside on this phone, not deleted. Cartharise then starts empty.';

  @override
  String get storageErrorTitle => 'Storage problem';

  @override
  String get storageErrorBody =>
      'Cartharise can\'t write to this phone\'s storage right now. Your current words stay on screen until you leave this screen.';

  @override
  String get stubComingSoonTitle => 'Coming soon';

  @override
  String get stubComingSoonBody =>
      'This part of Cartharise is still being built. Nothing you have written is affected.';

  @override
  String linkOpenFailed(String url) {
    return 'Couldn\'t open the link. You can visit it yourself: $url';
  }

  @override
  String get shareFailed => 'Couldn\'t open the share sheet on this phone.';

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
      'Six short answers that point your days somewhere you choose. Write them yourself, or start from your evening reflection.';

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
      'You can bring your own evening words into the empty fields below. You choose which ones, and nothing changes until you confirm.';

  @override
  String get compassImportAction => 'Use my evening reflections';

  @override
  String get compassEmptyTitle => 'Your Compass is empty';

  @override
  String get compassEmptyBody =>
      'Write each part yourself below, or answer the evening reflection first and bring your words here.';

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
      'One project for the next four weeks that moves the mission forward.';

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
  String get compassConstraintsOwnWords =>
      'Only you write this. Cartharise never fills it in from your answers.';

  @override
  String get compassConstraintsChip => 'Written only by you';

  @override
  String get compassLeversToQuests => 'Turn into quests';

  @override
  String get compassOpenProject => 'Open month project';

  @override
  String get compassVersionsTitle => 'Versions';

  @override
  String get compassVersionsBody =>
      'Save a snapshot before big changes. Restoring an older version first keeps a copy of what you have now.';

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
      'Read-only. Restoring replaces your current Compass, after saving it as a version.';

  @override
  String get compassRestoreAction => 'Restore this version';

  @override
  String get compassRestoreConfirmTitle => 'Restore this version?';

  @override
  String get compassRestoreConfirmBody =>
      'Your Compass will be replaced by this version. What you have now is saved as a version first, so nothing is lost.';

  @override
  String get compassRestoreConfirm => 'Restore';

  @override
  String get compassRestored =>
      'Version restored. Your previous Compass was saved as a version.';

  @override
  String get compassImportTitle => 'Use my evening reflections';

  @override
  String get compassImportBody =>
      'Your evening answers, exactly as you wrote them. Choose which empty fields they should start.';

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
      'Boundaries are never filled from your answers. Only you write them.';

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
      'Nothing to bring over yet. Answer the evening questions in Reset, then come back.';

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
  String get missionsIntro =>
      'Small actions that move your Compass forward. Rest days are part of it.';

  @override
  String get missionsToday => 'Today';

  @override
  String get missionsTodayEmpty =>
      'Nothing planned for today. Add a small quest, or rest. Both are fine.';

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
  String get missionsQuestRepeatHelp =>
      'Shows in Today each day. Checking it off counts for that day only.';

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
      'From your Compass. Change the words if you like; each one you keep becomes a daily quest.';

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
      'Plan one project for the next four weeks, with a few visible milestones.';

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
      'Write any time: what worked, what you learned, what you would do differently.';

  @override
  String get missionsRetroHint => 'Your notes';

  @override
  String get missionsProjectClear => 'Start a new project';

  @override
  String get missionsProjectClearTitle => 'Start a new project?';

  @override
  String get missionsProjectClearBody =>
      'This clears the title, milestones and notes of the current project. Your Compass is not changed.';

  @override
  String get missionsProjectClearConfirm => 'Clear project';

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
}
