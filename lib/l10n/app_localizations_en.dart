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
  String get awakeningTitle => 'The Awakening';

  @override
  String get awakeningSubtitle =>
      'Seven ideas behind the reset, in plain words. Optional, and in any order.';

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
    return 'Paraphrased in Cartharise\'s own words from “$title” by $author. Cartharise is independent.';
  }

  @override
  String get awakeningSourceLink => 'About the source';

  @override
  String get awakeningMissing => 'This lesson isn\'t available.';

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
  String get journalNotesIntro =>
      'Free writing, beyond the guided questions. Notes stay on this phone.';

  @override
  String get journalNewNote => 'New note';

  @override
  String get journalNotesEmptyTitle => 'No notes yet';

  @override
  String get journalNotesEmptyBody =>
      'Write down anything on your mind: an idea, a worry, something you noticed today.';

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
      'Once a week, look at what went well, what got in the way and one small thing to try next.';

  @override
  String get journalReviewThisWeek => 'Review this week';

  @override
  String get journalOpenThisWeek => 'Open this week\'s review';

  @override
  String get journalReviewsEmptyTitle => 'No weekly reviews yet';

  @override
  String get journalReviewsEmptyBody =>
      'A review takes a few minutes. There is no right way to do it.';

  @override
  String journalWeekOf(String date) {
    return 'Week of $date';
  }

  @override
  String get journalReviewTitle => 'Weekly review';

  @override
  String get journalReviewEditIntro =>
      'Write as much or as little as you like. It saves as you type.';

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
    return 'The review for the week of $date is removed from this phone. This can\'t be undone.';
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
  String get journalLookBackIntro =>
      'See how your words have changed over time. Nothing here is scored or labelled.';

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
      'Save a version of your Compass and you can compare it here later.';

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
      'No earlier resets yet. When you start a new reset, the previous one is kept here, unchanged.';

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
  String get journalPhaseMorning => 'Morning';

  @override
  String get journalPhaseDaytime => 'Daytime';

  @override
  String get journalPhaseBonus => 'Bonus';

  @override
  String get journalPhaseEvening => 'Evening';

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

  @override
  String get onboardingBrandIntro =>
      'A calm guide to one honest day of reflection, and the small steps that follow it.';

  @override
  String get onboardingBegin => 'Begin';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingSkipLabel => 'Skip the introduction';

  @override
  String get onboardingFinish => 'Finish';

  @override
  String onboardingPageDots(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String onboardingStepCounter(int current, int total) {
    return 'Setup $current of $total';
  }

  @override
  String get onboardingUnderstandTitle => 'Understand Yourself';

  @override
  String get onboardingUnderstandBody =>
      'Notice what you want, what you put up with, and what keeps pulling you back.';

  @override
  String get onboardingResetTitle => 'Reset Your Life';

  @override
  String get onboardingResetBody =>
      'Spend one honest day with a few questions, morning, daytime and evening, and see your situation clearly.';

  @override
  String get onboardingDirectionTitle => 'Choose a Direction';

  @override
  String get onboardingDirectionBody =>
      'Turn what you discover into a Life Compass: what you move away from, and what you move toward.';

  @override
  String get onboardingStepsTitle => 'Improve Step by Step';

  @override
  String get onboardingStepsBody =>
      'Small daily actions, looked at each week and adjusted as you learn. No streaks, no scores.';

  @override
  String get onboardingLimitsTitle => 'What This Is, and Isn\'t';

  @override
  String get onboardingLimitsIntro => 'Before you begin, a few honest words.';

  @override
  String get onboardingLimitsClarityTitle => 'One day can bring clarity';

  @override
  String get onboardingLimitsClarityBody =>
      'A focused day of questions can show you where you stand and what you would like instead.';

  @override
  String get onboardingLimitsNoGuaranteeTitle =>
      'It can\'t guarantee a fixed life';

  @override
  String get onboardingLimitsNoGuaranteeBody =>
      'Change comes from what you keep doing afterwards: small actions, noticed and adjusted over weeks.';

  @override
  String get onboardingLimitsPracticeTitle => 'An ongoing practice';

  @override
  String get onboardingLimitsPracticeBody =>
      'Come back whenever you like. You can redo the reset, change your goals or simply write.';

  @override
  String get onboardingLimitsNotTherapyTitle => 'Not therapy or diagnosis';

  @override
  String get onboardingLimitsNotTherapyBody =>
      'Cartharise is a self-reflection tool. It doesn\'t diagnose anything or replace professional care. If you\'re having a hard time, Support in the You tab lists places to get help.';

  @override
  String get onboardingLimitsControlTitle => 'You stay in control';

  @override
  String get onboardingLimitsControlBody =>
      'Every question can be skipped, softened or left for later.';

  @override
  String get onboardingAdultConfirm => 'I\'m 18 or older';

  @override
  String get onboardingAdultConfirmHelp => 'Cartharise is made for adults.';

  @override
  String get onboardingAdultRequired =>
      'Confirm you\'re 18 or older to continue.';

  @override
  String get onboardingCreditTitle => 'Inspired By';

  @override
  String get onboardingCreditIntro =>
      'Cartharise is built around the ideas of this article:';

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
  String get onboardingCreditNoNeed =>
      'You don\'t need to read it first. Every idea is explained in plain words as you go.';

  @override
  String get onboardingPaceTitle => 'Choose Your Pace';

  @override
  String get onboardingPaceIntro => 'You can change this later in the You tab.';

  @override
  String get onboardingPaceOneDayTitle => 'One day';

  @override
  String get onboardingPaceOneDayBody =>
      'Do the morning, daytime and evening reflections within a single day.';

  @override
  String get onboardingPaceFlexibleTitle => 'At my own pace';

  @override
  String get onboardingPaceFlexibleBody =>
      'Spread the reflections over days or weeks and pick up where you left off.';

  @override
  String get onboardingPaceNoLock =>
      'Either way, nothing ever locks or expires. Every part stays open.';

  @override
  String get onboardingNameTitle => 'What Should We Call You?';

  @override
  String get onboardingNameIntro =>
      'Optional, never shared. It stays on this phone and is only used to greet you.';

  @override
  String get onboardingNameLabel => 'Name (optional)';

  @override
  String get onboardingNameHelp =>
      'Leave it empty and Cartharise will call you Traveler.';

  @override
  String get onboardingPrivacyTitle => 'Your Words Stay Yours';

  @override
  String get onboardingPrivacyStorageHeading => 'Where your writing lives';

  @override
  String get onboardingPrivacyNoAccount =>
      'No account, no ads, no analytics. Nothing you write is sent anywhere.';

  @override
  String get onboardingPrivacyControl =>
      'You can export or delete everything at any time in You, under Your data.';

  @override
  String get resetTitle => 'The Reset';

  @override
  String get resetSubtitle =>
      'One guided day: look honestly at where you are, picture where you want to go, and choose a first step.';

  @override
  String get resetPaceOneDayTitle => 'Your pace: one day';

  @override
  String get resetPaceOneDayBody =>
      'Morning questions, a few check-ins during the day, then the evening. Nothing locks if it takes you longer.';

  @override
  String get resetPaceFlexibleTitle => 'Your pace: your own';

  @override
  String get resetPaceFlexibleBody =>
      'Take the parts in any order and come back whenever you like. Nothing locks and nothing expires.';

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
      'Every core question has been answered or skipped. You can still open and change any of them.';

  @override
  String get resetSeeCreated => 'See what you created';

  @override
  String resetCompletedOn(String date) {
    return 'Finished on $date. You can still revisit and edit any answer.';
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
      'A good ordinary day, who you want to become, one action this week';

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
  String get resetOptionalBody =>
      'Three extra questions for a quiet moment. They don\'t count toward your progress.';

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
  String get resetPastScreenTitle => 'Past reset';

  @override
  String get resetPastReadOnly =>
      'Read-only: this is how you answered then. Your current reset is separate.';

  @override
  String resetPastLeftOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions were left open.',
      one: '1 question was left open.',
    );
    return '$_temp0';
  }

  @override
  String get resetPastEmpty => 'Nothing was written in this reset.';

  @override
  String get resetPastMissing => 'This reset isn\'t available any more.';

  @override
  String get resetNewTitle => 'Start a new reset';

  @override
  String get resetNewBody =>
      'Want to go through it again? Start fresh: this reset stays readable under Past resets.';

  @override
  String get resetNewConfirmTitle => 'Start a new reset?';

  @override
  String get resetNewConfirmBody =>
      'Your current answers are kept as a past reset you can read at any time. The new reset starts empty. Your Compass, quests and journal don\'t change.';

  @override
  String get resetNewConfirmAction => 'Start new reset';

  @override
  String get resetNewStarted =>
      'A new reset has started. Your earlier one is under Past resets.';

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
  String get resetSkippedNote =>
      'You skipped this one. Write something whenever you like, or leave it.';

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
      'Some questions touch tender places. You decide how deep to go: soften the wording, skip, or stop here. Your words are saved.';

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
      'Cartharise is not therapy. If you feel unsafe, contact local emergency services or a crisis line now.';

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
      other:
          '$count core questions are still open. You can return to them from the Reset tab at any time.',
      one: '1 core question is still open. You can return to it from the Reset tab at any time.',
    );
    return '$_temp0';
  }

  @override
  String get resetCompleteCompassBody =>
      'Your evening answers can become the first draft of your Life Compass. You choose what to copy, and nothing you already wrote is overwritten.';

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
    return '$count short questions, one at a time. Skip any of them, pause whenever you like.';
  }

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
  String get todayNextSeeReset => 'See the whole reset';

  @override
  String get todayNextCompassTitle => 'Build your Compass';

  @override
  String get todayNextCompassImportBody =>
      'Your evening answers can fill the empty parts of your Life Compass. You choose what goes in.';

  @override
  String get todayNextCompassManualBody =>
      'Write your vision, a one-month project and a few daily levers in your own words.';

  @override
  String get todayNextCompassImportAction => 'Review your answers';

  @override
  String get todayNextLeversTitle => 'Turn your levers into quests';

  @override
  String get todayNextLeversBody =>
      'Your daily levers can become a few small actions to check off. You approve each one.';

  @override
  String get todayNextLeversAction => 'Choose quests';

  @override
  String get todayNextReviewTitle => 'Look back on your week';

  @override
  String get todayNextReviewBody =>
      'Three short questions: what went well, what got in the way, and what to try next.';

  @override
  String get todayNextReviewAction => 'Start a weekly review';

  @override
  String get todayNextJournalTitle => 'Write a note';

  @override
  String get todayNextJournalBody =>
      'A few lines about today: what you noticed, what you tried, what you learned.';

  @override
  String get todayNextJournalAction => 'New note';

  @override
  String get todayOpenJournal => 'Open the journal';

  @override
  String get todayOpenCompass => 'Open Compass';

  @override
  String get todayFocusTitle => 'Today\'s focus';

  @override
  String get todayFocusEmptyTitle => 'No quests for today';

  @override
  String get todayFocusEmptyBody =>
      'Quests are small actions you choose yourself. Add one whenever you\'re ready.';

  @override
  String get todayFocusAdd => 'Add a quest';

  @override
  String todayFocusSeeAll(int count) {
    return 'See all $count quests';
  }

  @override
  String todayQuestMarkDone(String title) {
    return 'Mark \'$title\' done';
  }

  @override
  String get todayQuestDaily => 'Daily';

  @override
  String get todayJourneyTitle => 'Your journey';

  @override
  String todayJourneyWritten(int answered, int total) {
    return '$answered of $total reflections written';
  }

  @override
  String get todayJourneyNotStarted =>
      'Your reset hasn\'t started yet. It\'s ready whenever you are.';

  @override
  String get todayJourneyInProgress =>
      'Your reset is waiting where you left it.';

  @override
  String get todayJourneyAllTouched =>
      'Every reflection is written or set aside. You can revisit any of them.';

  @override
  String get todayJourneyCompleted =>
      'You finished this reset. Your answers stay here to revisit.';

  @override
  String get todayJourneyOpenReset => 'Open the reset';

  @override
  String todayPhaseProgress(String phase, int answered, int total) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'morning': 'Morning',
      'daytime': 'Daytime',
      'evening': 'Evening',
      'other': 'Reset',
    });
    return '$_temp0 $answered/$total';
  }

  @override
  String todayPhaseProgressLabel(String phase, int answered, int total) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'morning': 'Morning',
      'daytime': 'Daytime',
      'evening': 'Evening',
      'other': 'Reset',
    });
    return '$_temp0: $answered of $total written';
  }

  @override
  String todayPathDay(int day) {
    return 'Day $day of 30';
  }

  @override
  String todayPathStage(String stage) {
    String _temp0 = intl.Intl.selectLogic(stage, {
      'observe': 'Observe',
      'experiment': 'Experiment',
      'build': 'Build',
      'adjust': 'Adjust',
      'other': 'Path',
    });
    return 'Thirty-day path · $_temp0';
  }

  @override
  String todayPathOpen(int day) {
    return 'Open day $day';
  }

  @override
  String get todayDirectionTitle => 'Your direction';

  @override
  String get todayDirectionVision => 'Vision';

  @override
  String get todayDirectionMonth => 'This month';

  @override
  String get todayDirectionNoVision => 'No vision written yet.';

  @override
  String get todayDirectionNoMonth => 'No month project yet.';

  @override
  String get todayDirectionEmptyTitle => 'Your Compass is empty';

  @override
  String get todayDirectionEmptyBody =>
      'It holds your vision, a one-month project and a few daily levers, in your own words.';

  @override
  String get youTitle => 'You';

  @override
  String get youSubtitle => 'Your space, your choices.';

  @override
  String get youProfileEyebrow => 'Profile';

  @override
  String get youNoName => 'No name set';

  @override
  String get youProfileBody =>
      'A name is optional and stays on this phone. Tap to change it.';

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
  String get youPaceHint =>
      'Nothing is ever locked by time. Change this whenever you like.';

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
  String get youAboutBody =>
      'An independent self-reflection app. Everything stays on this phone.';

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
      'You\'ll see the introduction again. Your writing, Compass and settings stay as they are.';

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
      'Notifications show only the check-in\'s title, never your words.';

  @override
  String get youRemindersDeniedTitle => 'Notifications aren\'t allowed';

  @override
  String get youRemindersDeniedBody =>
      'Cartharise isn\'t allowed to send notifications on this phone, so reminders stay off. You can allow them in your phone\'s settings and try again, or add the check-ins to your calendar instead.';

  @override
  String get youRemindersUnavailableTitle => 'Notifications aren\'t available';

  @override
  String get youRemindersUnavailableBody =>
      'This phone can\'t show Cartharise notifications, so reminders stay off. You can add the check-ins to your calendar instead.';

  @override
  String get youRemindersScheduleFailed =>
      'Cartharise couldn\'t schedule the notifications on this phone. Try again, or add the check-ins to your calendar instead.';

  @override
  String get youRemindersCalendarInstead => 'Add to your calendar instead';

  @override
  String get youRemindersTimesTitle => 'Check-in times';

  @override
  String get youRemindersTimesBody =>
      'In your phone\'s local time. Change any of them to suit your day.';

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
      'A calendar file (.ics) with your switched-on check-ins for the next 30 days. Open it with your calendar app to add them. It contains only the check-in titles.';

  @override
  String get youRemindersCalendarButton => 'Add to calendar (.ics)';

  @override
  String get youRemindersCalendarNone =>
      'Switch on at least one check-in to create the file.';

  @override
  String get youRemindersCalendarShared =>
      'Calendar file shared. Open it with your calendar app to add the check-ins.';

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
      'Gentle movement between screens and the animated emblem. Your phone\'s reduce-motion setting always turns it off.';

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
      'Saves everything you\'ve written and chosen as one JSON file you can keep or move to another phone. The file isn\'t encrypted, so keep it somewhere private.';

  @override
  String get youDataExportButton => 'Export backup';

  @override
  String get youDataExported => 'Backup shared.';

  @override
  String get youDataImportTitle => 'Restore a backup';

  @override
  String get youDataImportBody =>
      'Replaces everything on this phone with a Cartharise backup. You\'ll see the backup\'s date and confirm first.';

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
  String get youDataImported => 'Backup restored.';

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
      'This backup\'s format isn\'t supported by this version of Cartharise.';

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
      'Erases everything Cartharise keeps on this phone and cancels reminders. Export a backup first if you want to keep a copy.';

  @override
  String get youDataDeleteButton => 'Delete all data';

  @override
  String get youDataDeleteConfirm1Title => 'Delete all data?';

  @override
  String get youDataDeleteConfirm1Body =>
      'Your answers, Compass, quests, notes, reviews and settings will be erased from this phone, and reminders cancelled.';

  @override
  String get youDataDeleteConfirm1Action => 'Continue';

  @override
  String get youDataDeleteConfirm2Title => 'This can\'t be undone';

  @override
  String get youDataDeleteConfirm2Body =>
      'Cartharise keeps no copy anywhere else. Once deleted, your writing can only come back from a backup you exported.';

  @override
  String get youDataDeleteConfirm2Action => 'Delete everything';

  @override
  String get youDataDeleteFailed =>
      'Couldn\'t delete your data. Your writing is still on this phone; please try again.';

  @override
  String get youSupportTitle => 'Support & safety';

  @override
  String get youSupportSubtitle =>
      'Reflection can stir things up. That\'s normal.';

  @override
  String get youSupportNotTherapyTitle => 'Not therapy';

  @override
  String get youSupportNotTherapyBody =>
      'Cartharise is a tool for self-reflection. It isn\'t therapy, counselling or medical advice, and it doesn\'t diagnose anything.';

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
      'If you\'re in danger or thinking about harming yourself, contact your local emergency services now, or reach a crisis line in your country.';

  @override
  String get youSupportFindHelpline => 'Find a helpline';

  @override
  String get youSupportHelplineHint =>
      'Opens findahelpline.com, a directory of helplines by country.';

  @override
  String get youSupportOngoingTitle => 'Ongoing support';

  @override
  String get youSupportOngoingBody =>
      'If difficult feelings last or get in the way of daily life, a doctor, psychologist or counsellor can help.';
}
