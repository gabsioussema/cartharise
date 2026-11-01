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
  String get journalFieldAntiVision => 'Anti-vision';

  @override
  String get journalFieldVision => 'Vision';

  @override
  String get journalFieldYearGoal => 'One-year goal';

  @override
  String get journalFieldMonthProject => 'One-month project';

  @override
  String get journalFieldDailyLevers => 'Daily levers';

  @override
  String get journalFieldConstraints => 'Constraints';

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
