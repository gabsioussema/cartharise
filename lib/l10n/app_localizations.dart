import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Cartharise'**
  String get appTitle;

  /// Brand tagline under the wordmark (boot screen, About).
  ///
  /// In en, this message translates to:
  /// **'Master Yourself. Rise With Purpose.'**
  String get appTagline;

  /// No description provided for @appPromise.
  ///
  /// In en, this message translates to:
  /// **'Understand yourself. Choose your path. Rise with purpose.'**
  String get appPromise;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get tabReset;

  /// No description provided for @tabCompass.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get tabCompass;

  /// No description provided for @tabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get tabJournal;

  /// No description provided for @tabYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tabYou;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get keepGoing;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @moreInfo.
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get moreInfo;

  /// No description provided for @saveStatusSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saveStatusSaving;

  /// No description provided for @saveStatusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get saveStatusSaved;

  /// No description provided for @saveStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Your last change couldn\'t be saved.'**
  String get saveStatusFailed;

  /// No description provided for @saveFailedHelp.
  ///
  /// In en, this message translates to:
  /// **'Your words are still here on screen. Try saving again, or export a copy so nothing is lost.'**
  String get saveFailedHelp;

  /// No description provided for @saveExportCopy.
  ///
  /// In en, this message translates to:
  /// **'Export a copy'**
  String get saveExportCopy;

  /// No description provided for @bootLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your space…'**
  String get bootLoading;

  /// No description provided for @bootLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved data couldn\'t be opened'**
  String get bootLoadErrorTitle;

  /// No description provided for @bootLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Cartharise couldn\'t read the file it keeps on this phone. Nothing has been deleted or overwritten.'**
  String get bootLoadErrorBody;

  /// No description provided for @bootLoadErrorHint.
  ///
  /// In en, this message translates to:
  /// **'Try again. If it keeps happening, check that your phone has free storage, then try once more.'**
  String get bootLoadErrorHint;

  /// No description provided for @bootStartFresh.
  ///
  /// In en, this message translates to:
  /// **'Start fresh and keep the unreadable file'**
  String get bootStartFresh;

  /// No description provided for @bootStartFreshConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start fresh?'**
  String get bootStartFreshConfirmTitle;

  /// No description provided for @bootStartFreshConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The unreadable file is set aside on this phone, not deleted. Cartharise then starts empty.'**
  String get bootStartFreshConfirmBody;

  /// No description provided for @storageErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage problem'**
  String get storageErrorTitle;

  /// No description provided for @storageErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Cartharise can\'t write to this phone\'s storage right now. Your current words stay on screen until you leave this screen.'**
  String get storageErrorBody;

  /// No description provided for @stubComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get stubComingSoonTitle;

  /// No description provided for @stubComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This part of Cartharise is still being built. Nothing you have written is affected.'**
  String get stubComingSoonBody;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the link. You can visit it yourself: {url}'**
  String linkOpenFailed(String url);

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open the share sheet on this phone.'**
  String get shareFailed;

  /// No description provided for @loaderLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loaderLabel;

  /// No description provided for @emblemLabel.
  ///
  /// In en, this message translates to:
  /// **'Cartharise emblem'**
  String get emblemLabel;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'{value} percent'**
  String progressLabel(int value);

  /// No description provided for @selectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedLabel;

  /// Journal tab screen title (Cinzel, keep short).
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @journalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Think, reflect and grow, at your own pace.'**
  String get journalSubtitle;

  /// No description provided for @journalSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get journalSectionNotes;

  /// No description provided for @journalSectionReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get journalSectionReviews;

  /// No description provided for @journalSectionLookBack.
  ///
  /// In en, this message translates to:
  /// **'Look back'**
  String get journalSectionLookBack;

  /// A local date followed by a local time.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String journalDateTime(String date, String time);

  /// No description provided for @journalNotesIntro.
  ///
  /// In en, this message translates to:
  /// **'Free writing, beyond the guided questions. Notes stay on this phone.'**
  String get journalNotesIntro;

  /// No description provided for @journalNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get journalNewNote;

  /// No description provided for @journalNotesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get journalNotesEmptyTitle;

  /// No description provided for @journalNotesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Write down anything on your mind: an idea, a worry, something you noticed today.'**
  String get journalNotesEmptyBody;

  /// No description provided for @journalUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled note'**
  String get journalUntitled;

  /// No description provided for @journalEditedBadge.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get journalEditedBadge;

  /// No description provided for @journalEntryNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get journalEntryNewTitle;

  /// No description provided for @journalEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get journalEntryTitle;

  /// No description provided for @journalEntryTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get journalEntryTitleField;

  /// No description provided for @journalEntryBodyField.
  ///
  /// In en, this message translates to:
  /// **'Your note'**
  String get journalEntryBodyField;

  /// No description provided for @journalEntryBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write freely. It saves as you type.'**
  String get journalEntryBodyHint;

  /// No description provided for @journalEntryWritten.
  ///
  /// In en, this message translates to:
  /// **'Written {when}'**
  String journalEntryWritten(String when);

  /// No description provided for @journalEntryEdited.
  ///
  /// In en, this message translates to:
  /// **'Last edited {when}'**
  String journalEntryEdited(String when);

  /// No description provided for @journalEntryPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone. Never shown in notifications.'**
  String get journalEntryPrivacy;

  /// No description provided for @journalEntryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete note'**
  String get journalEntryDelete;

  /// No description provided for @journalEntryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this note?'**
  String get journalEntryDeleteTitle;

  /// No description provided for @journalEntryDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The note is removed from this phone. This can\'t be undone.'**
  String get journalEntryDeleteBody;

  /// No description provided for @journalEntryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note deleted'**
  String get journalEntryDeleted;

  /// No description provided for @journalEntryMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This note isn\'t here any more'**
  String get journalEntryMissingTitle;

  /// No description provided for @journalEntryMissingBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted. Your other notes are unchanged.'**
  String get journalEntryMissingBody;

  /// No description provided for @journalReviewsIntro.
  ///
  /// In en, this message translates to:
  /// **'Once a week, look at what went well, what got in the way and one small thing to try next.'**
  String get journalReviewsIntro;

  /// No description provided for @journalReviewThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Review this week'**
  String get journalReviewThisWeek;

  /// No description provided for @journalOpenThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Open this week\'s review'**
  String get journalOpenThisWeek;

  /// No description provided for @journalReviewsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No weekly reviews yet'**
  String get journalReviewsEmptyTitle;

  /// No description provided for @journalReviewsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'A review takes a few minutes. There is no right way to do it.'**
  String get journalReviewsEmptyBody;

  /// No description provided for @journalWeekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String journalWeekOf(String date);

  /// No description provided for @journalReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly review'**
  String get journalReviewTitle;

  /// No description provided for @journalReviewEditIntro.
  ///
  /// In en, this message translates to:
  /// **'Write as much or as little as you like. It saves as you type.'**
  String get journalReviewEditIntro;

  /// No description provided for @journalReviewChangeWeek.
  ///
  /// In en, this message translates to:
  /// **'Change week'**
  String get journalReviewChangeWeek;

  /// No description provided for @journalReviewWins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get journalReviewWins;

  /// No description provided for @journalReviewWinsHint.
  ///
  /// In en, this message translates to:
  /// **'What went well this week, however small?'**
  String get journalReviewWinsHint;

  /// No description provided for @journalReviewFriction.
  ///
  /// In en, this message translates to:
  /// **'Friction'**
  String get journalReviewFriction;

  /// No description provided for @journalReviewFrictionHint.
  ///
  /// In en, this message translates to:
  /// **'What got in the way? Just notice it. No blame needed.'**
  String get journalReviewFrictionHint;

  /// No description provided for @journalReviewNext.
  ///
  /// In en, this message translates to:
  /// **'Next experiment'**
  String get journalReviewNext;

  /// No description provided for @journalReviewNextHint.
  ///
  /// In en, this message translates to:
  /// **'One small thing to try next week.'**
  String get journalReviewNextHint;

  /// No description provided for @journalReviewSave.
  ///
  /// In en, this message translates to:
  /// **'Save review'**
  String get journalReviewSave;

  /// No description provided for @journalReviewSaved.
  ///
  /// In en, this message translates to:
  /// **'Review saved'**
  String get journalReviewSaved;

  /// No description provided for @journalReviewEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit review'**
  String get journalReviewEdit;

  /// No description provided for @journalReviewDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete review'**
  String get journalReviewDelete;

  /// No description provided for @journalReviewDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this review?'**
  String get journalReviewDeleteTitle;

  /// No description provided for @journalReviewDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The review for the week of {date} is removed from this phone. This can\'t be undone.'**
  String journalReviewDeleteBody(String date);

  /// No description provided for @journalReviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted'**
  String get journalReviewDeleted;

  /// No description provided for @journalReviewNothingWritten.
  ///
  /// In en, this message translates to:
  /// **'Nothing written'**
  String get journalReviewNothingWritten;

  /// No description provided for @journalReviewWritten.
  ///
  /// In en, this message translates to:
  /// **'Saved {when}'**
  String journalReviewWritten(String when);

  /// No description provided for @journalReviewMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This review isn\'t here any more'**
  String get journalReviewMissingTitle;

  /// No description provided for @journalReviewMissingBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted. Your other reviews are unchanged.'**
  String get journalReviewMissingBody;

  /// No description provided for @journalLookBackIntro.
  ///
  /// In en, this message translates to:
  /// **'See how your words have changed over time. Nothing here is scored or labelled.'**
  String get journalLookBackIntro;

  /// No description provided for @journalCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'Compare your Compass'**
  String get journalCompareTitle;

  /// No description provided for @journalCompareBody.
  ///
  /// In en, this message translates to:
  /// **'Choose two moments to place side by side.'**
  String get journalCompareBody;

  /// No description provided for @journalCompareFirst.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get journalCompareFirst;

  /// No description provided for @journalCompareSecond.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get journalCompareSecond;

  /// No description provided for @journalCompareNow.
  ///
  /// In en, this message translates to:
  /// **'Your Compass now'**
  String get journalCompareNow;

  /// No description provided for @journalComparePick.
  ///
  /// In en, this message translates to:
  /// **'Choose what to show as “{which}”'**
  String journalComparePick(String which);

  /// No description provided for @journalComparePickerLabel.
  ///
  /// In en, this message translates to:
  /// **'{which}: {current}. Tap to change.'**
  String journalComparePickerLabel(String which, String current);

  /// No description provided for @journalCompareEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved versions yet'**
  String get journalCompareEmptyTitle;

  /// No description provided for @journalCompareEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save a version of your Compass and you can compare it here later.'**
  String get journalCompareEmptyBody;

  /// No description provided for @journalOpenCompass.
  ///
  /// In en, this message translates to:
  /// **'Open Compass'**
  String get journalOpenCompass;

  /// No description provided for @journalCompareSame.
  ///
  /// In en, this message translates to:
  /// **'Same in both'**
  String get journalCompareSame;

  /// No description provided for @journalCompareEmptyField.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get journalCompareEmptyField;

  /// No description provided for @journalVersionManual.
  ///
  /// In en, this message translates to:
  /// **'saved by you'**
  String get journalVersionManual;

  /// No description provided for @journalVersionBeforeImport.
  ///
  /// In en, this message translates to:
  /// **'before an import'**
  String get journalVersionBeforeImport;

  /// No description provided for @journalVersionBeforeRestore.
  ///
  /// In en, this message translates to:
  /// **'before a restore'**
  String get journalVersionBeforeRestore;

  /// No description provided for @journalVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'{date} · {reason}'**
  String journalVersionLabel(String date, String reason);

  /// No description provided for @journalFieldAntiVision.
  ///
  /// In en, this message translates to:
  /// **'Anti-vision'**
  String get journalFieldAntiVision;

  /// No description provided for @journalFieldVision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get journalFieldVision;

  /// No description provided for @journalFieldYearGoal.
  ///
  /// In en, this message translates to:
  /// **'One-year goal'**
  String get journalFieldYearGoal;

  /// No description provided for @journalFieldMonthProject.
  ///
  /// In en, this message translates to:
  /// **'One-month project'**
  String get journalFieldMonthProject;

  /// No description provided for @journalFieldDailyLevers.
  ///
  /// In en, this message translates to:
  /// **'Daily levers'**
  String get journalFieldDailyLevers;

  /// No description provided for @journalFieldConstraints.
  ///
  /// In en, this message translates to:
  /// **'Constraints'**
  String get journalFieldConstraints;

  /// No description provided for @journalPastResetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earlier resets'**
  String get journalPastResetsTitle;

  /// No description provided for @journalPastResetsBody.
  ///
  /// In en, this message translates to:
  /// **'Starting a new reset keeps the earlier one here to read.'**
  String get journalPastResetsBody;

  /// No description provided for @journalPastResetsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No earlier resets yet. When you start a new reset, the previous one is kept here, unchanged.'**
  String get journalPastResetsEmpty;

  /// No description provided for @journalResetStarted.
  ///
  /// In en, this message translates to:
  /// **'Started {date}'**
  String journalResetStarted(String date);

  /// No description provided for @journalResetCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed {date}'**
  String journalResetCompleted(String date);

  /// No description provided for @journalResetAnswerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No written answers} =1{1 written answer} other{{count} written answers}}'**
  String journalResetAnswerCount(int count);

  /// No description provided for @journalPastResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Earlier reset'**
  String get journalPastResetTitle;

  /// No description provided for @journalPastResetReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only. Your words are kept exactly as you wrote them.'**
  String get journalPastResetReadOnly;

  /// No description provided for @journalPastResetCompare.
  ///
  /// In en, this message translates to:
  /// **'Show my current answers too'**
  String get journalPastResetCompare;

  /// No description provided for @journalPastResetThen.
  ///
  /// In en, this message translates to:
  /// **'Then'**
  String get journalPastResetThen;

  /// No description provided for @journalPastResetNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get journalPastResetNow;

  /// No description provided for @journalPastResetNoCurrent.
  ///
  /// In en, this message translates to:
  /// **'No answer in your current reset'**
  String get journalPastResetNoCurrent;

  /// No description provided for @journalPastResetSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get journalPastResetSkipped;

  /// No description provided for @journalPastResetNone.
  ///
  /// In en, this message translates to:
  /// **'This reset has no written answers.'**
  String get journalPastResetNone;

  /// No description provided for @journalPastResetOther.
  ///
  /// In en, this message translates to:
  /// **'Other answers'**
  String get journalPastResetOther;

  /// No description provided for @journalPastResetMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'This reset isn\'t here any more'**
  String get journalPastResetMissingTitle;

  /// No description provided for @journalPhaseMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get journalPhaseMorning;

  /// No description provided for @journalPhaseDaytime.
  ///
  /// In en, this message translates to:
  /// **'Daytime'**
  String get journalPhaseDaytime;

  /// No description provided for @journalPhaseBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get journalPhaseBonus;

  /// No description provided for @journalPhaseEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get journalPhaseEvening;

  /// You tab screen title (Cinzel, keep short).
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youTitle;

  /// No description provided for @youSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your space, your choices.'**
  String get youSubtitle;

  /// No description provided for @youProfileEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get youProfileEyebrow;

  /// No description provided for @youNoName.
  ///
  /// In en, this message translates to:
  /// **'No name set'**
  String get youNoName;

  /// No description provided for @youProfileBody.
  ///
  /// In en, this message translates to:
  /// **'A name is optional and stays on this phone. Tap to change it.'**
  String get youProfileBody;

  /// No description provided for @youEditName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get youEditName;

  /// No description provided for @youNameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get youNameDialogTitle;

  /// No description provided for @youNameHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get youNameHint;

  /// No description provided for @youPaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get youPaceTitle;

  /// No description provided for @youPaceOneDay.
  ///
  /// In en, this message translates to:
  /// **'One day'**
  String get youPaceOneDay;

  /// No description provided for @youPaceFlexible.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get youPaceFlexible;

  /// No description provided for @youPaceHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing is ever locked by time. Change this whenever you like.'**
  String get youPaceHint;

  /// No description provided for @youSectionCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get youSectionCredit;

  /// No description provided for @youSectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get youSectionSettings;

  /// No description provided for @youSectionCare.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get youSectionCare;

  /// No description provided for @youSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get youSectionAbout;

  /// No description provided for @youInspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get youInspiration;

  /// No description provided for @youInspirationHint.
  ///
  /// In en, this message translates to:
  /// **'The article behind Cartharise'**
  String get youInspirationHint;

  /// No description provided for @youReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get youReminders;

  /// No description provided for @youRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get youRemindersOn;

  /// No description provided for @youRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get youRemindersOff;

  /// No description provided for @youAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get youAppearance;

  /// No description provided for @youAppearanceSummary.
  ///
  /// In en, this message translates to:
  /// **'{theme} · {mode}'**
  String youAppearanceSummary(String theme, String mode);

  /// No description provided for @youData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get youData;

  /// No description provided for @youDataHint.
  ///
  /// In en, this message translates to:
  /// **'Export, restore or delete'**
  String get youDataHint;

  /// No description provided for @youSupport.
  ///
  /// In en, this message translates to:
  /// **'Support & safety'**
  String get youSupport;

  /// No description provided for @youSupportHint.
  ///
  /// In en, this message translates to:
  /// **'Not therapy. Help if things feel heavy.'**
  String get youSupportHint;

  /// No description provided for @youVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {build})'**
  String youVersion(String version, String build);

  /// No description provided for @youAboutBody.
  ///
  /// In en, this message translates to:
  /// **'An independent self-reflection app. Everything stays on this phone.'**
  String get youAboutBody;

  /// No description provided for @youLicences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get youLicences;

  /// No description provided for @youLicencesHint.
  ///
  /// In en, this message translates to:
  /// **'Including the Inter and Cinzel fonts (SIL Open Font License)'**
  String get youLicencesHint;

  /// No description provided for @youLegalese.
  ///
  /// In en, this message translates to:
  /// **'Independent app inspired by “{title}” by {author}. Not affiliated with or endorsed by the author.'**
  String youLegalese(String title, String author);

  /// No description provided for @youReplayWelcome.
  ///
  /// In en, this message translates to:
  /// **'Replay the welcome'**
  String get youReplayWelcome;

  /// No description provided for @youReplayWelcomeHint.
  ///
  /// In en, this message translates to:
  /// **'See the introduction again. Nothing you\'ve written changes.'**
  String get youReplayWelcomeHint;

  /// No description provided for @youReplayConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Replay the welcome?'**
  String get youReplayConfirmTitle;

  /// No description provided for @youReplayConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see the introduction again. Your writing, Compass and settings stay as they are.'**
  String get youReplayConfirmBody;

  /// No description provided for @youReplayConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Show the welcome'**
  String get youReplayConfirmAction;

  /// No description provided for @youInspirationTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspiration'**
  String get youInspirationTitle;

  /// No description provided for @youInspirationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The work that inspired Cartharise'**
  String get youInspirationSubtitle;

  /// No description provided for @youInspirationEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Inspired by'**
  String get youInspirationEyebrow;

  /// No description provided for @youInspirationByline.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String youInspirationByline(String author);

  /// No description provided for @youInspirationPublished.
  ///
  /// In en, this message translates to:
  /// **'Published {date}'**
  String youInspirationPublished(String date);

  /// No description provided for @youInspirationReadArticle.
  ///
  /// In en, this message translates to:
  /// **'Read the article on X'**
  String get youInspirationReadArticle;

  /// No description provided for @youInspirationReadNewsletter.
  ///
  /// In en, this message translates to:
  /// **'Read the newsletter version'**
  String get youInspirationReadNewsletter;

  /// No description provided for @youInspirationLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Opens in your browser: {host}'**
  String youInspirationLinkHint(String host);

  /// No description provided for @youInspirationIndependentTitle.
  ///
  /// In en, this message translates to:
  /// **'An independent app'**
  String get youInspirationIndependentTitle;

  /// No description provided for @youInspirationParaphraseTitle.
  ///
  /// In en, this message translates to:
  /// **'In Cartharise\'s own words'**
  String get youInspirationParaphraseTitle;

  /// No description provided for @youInspirationSplitTitle.
  ///
  /// In en, this message translates to:
  /// **'From the source, or added by Cartharise?'**
  String get youInspirationSplitTitle;

  /// No description provided for @youInspirationFromSource.
  ///
  /// In en, this message translates to:
  /// **'From the article, paraphrased'**
  String get youInspirationFromSource;

  /// No description provided for @youInspirationSource1.
  ///
  /// In en, this message translates to:
  /// **'The seven central ideas behind the Awakening lessons'**
  String get youInspirationSource1;

  /// No description provided for @youInspirationSource2.
  ///
  /// In en, this message translates to:
  /// **'The morning, daytime and evening reset questions'**
  String get youInspirationSource2;

  /// No description provided for @youInspirationSource3.
  ///
  /// In en, this message translates to:
  /// **'The six parts of the Life Compass'**
  String get youInspirationSource3;

  /// No description provided for @youInspirationSource4.
  ///
  /// In en, this message translates to:
  /// **'The six daytime check-in times'**
  String get youInspirationSource4;

  /// No description provided for @youInspirationAdded.
  ///
  /// In en, this message translates to:
  /// **'Added by Cartharise'**
  String get youInspirationAdded;

  /// No description provided for @youInspirationAdded1.
  ///
  /// In en, this message translates to:
  /// **'Examples, help texts and softer wording'**
  String get youInspirationAdded1;

  /// No description provided for @youInspirationAdded2.
  ///
  /// In en, this message translates to:
  /// **'Quests, the Today view and the thirty-day path'**
  String get youInspirationAdded2;

  /// No description provided for @youInspirationAdded3.
  ///
  /// In en, this message translates to:
  /// **'Journal notes, weekly reviews and Look back'**
  String get youInspirationAdded3;

  /// No description provided for @youInspirationAdded4.
  ///
  /// In en, this message translates to:
  /// **'Reminders, calendar export and backups'**
  String get youInspirationAdded4;

  /// No description provided for @youInspirationReadOriginal.
  ///
  /// In en, this message translates to:
  /// **'For the author\'s full reasoning, read the original.'**
  String get youInspirationReadOriginal;

  /// No description provided for @youRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get youRemindersTitle;

  /// No description provided for @youRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Six optional check-ins during the day.'**
  String get youRemindersSubtitle;

  /// No description provided for @youRemindersSwitch.
  ///
  /// In en, this message translates to:
  /// **'Check-in notifications'**
  String get youRemindersSwitch;

  /// No description provided for @youRemindersSwitchOn.
  ///
  /// In en, this message translates to:
  /// **'On, at the times below.'**
  String get youRemindersSwitchOn;

  /// No description provided for @youRemindersSwitchOff.
  ///
  /// In en, this message translates to:
  /// **'Off. Nothing is sent until you turn this on.'**
  String get youRemindersSwitchOff;

  /// No description provided for @youRemindersPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Notifications show only the check-in\'s title, never your words.'**
  String get youRemindersPrivacy;

  /// No description provided for @youRemindersDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications aren\'t allowed'**
  String get youRemindersDeniedTitle;

  /// No description provided for @youRemindersDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Cartharise isn\'t allowed to send notifications on this phone, so reminders stay off. You can allow them in your phone\'s settings and try again, or add the check-ins to your calendar instead.'**
  String get youRemindersDeniedBody;

  /// No description provided for @youRemindersUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications aren\'t available'**
  String get youRemindersUnavailableTitle;

  /// No description provided for @youRemindersUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This phone can\'t show Cartharise notifications, so reminders stay off. You can add the check-ins to your calendar instead.'**
  String get youRemindersUnavailableBody;

  /// No description provided for @youRemindersScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Cartharise couldn\'t schedule the notifications on this phone. Try again, or add the check-ins to your calendar instead.'**
  String get youRemindersScheduleFailed;

  /// No description provided for @youRemindersCalendarInstead.
  ///
  /// In en, this message translates to:
  /// **'Add to your calendar instead'**
  String get youRemindersCalendarInstead;

  /// No description provided for @youRemindersTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Check-in times'**
  String get youRemindersTimesTitle;

  /// No description provided for @youRemindersTimesBody.
  ///
  /// In en, this message translates to:
  /// **'In your phone\'s local time. Change any of them to suit your day.'**
  String get youRemindersTimesBody;

  /// No description provided for @youRemindersSourceDefault.
  ///
  /// In en, this message translates to:
  /// **'Source default {time}'**
  String youRemindersSourceDefault(String time);

  /// No description provided for @youRemindersUseDefault.
  ///
  /// In en, this message translates to:
  /// **'Use {time}'**
  String youRemindersUseDefault(String time);

  /// No description provided for @youRemindersChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Change the time for {title}, now {time}'**
  String youRemindersChangeTime(String title, String time);

  /// No description provided for @youRemindersRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Check-in {title}, {time}'**
  String youRemindersRowLabel(String title, String time);

  /// No description provided for @youRemindersQuietTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get youRemindersQuietTitle;

  /// No description provided for @youRemindersQuietBody.
  ///
  /// In en, this message translates to:
  /// **'No check-in notifications between these times.'**
  String get youRemindersQuietBody;

  /// No description provided for @youRemindersQuietFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get youRemindersQuietFrom;

  /// No description provided for @youRemindersQuietUntil.
  ///
  /// In en, this message translates to:
  /// **'Until'**
  String get youRemindersQuietUntil;

  /// No description provided for @youRemindersQuietNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get youRemindersQuietNotSet;

  /// No description provided for @youRemindersQuietClear.
  ///
  /// In en, this message translates to:
  /// **'Clear quiet hours'**
  String get youRemindersQuietClear;

  /// No description provided for @youRemindersQuietIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Set both times for quiet hours to apply.'**
  String get youRemindersQuietIncomplete;

  /// No description provided for @youRemindersCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to your calendar'**
  String get youRemindersCalendarTitle;

  /// No description provided for @youRemindersCalendarBody.
  ///
  /// In en, this message translates to:
  /// **'A calendar file (.ics) with your switched-on check-ins for the next 30 days. Open it with your calendar app to add them. It contains only the check-in titles.'**
  String get youRemindersCalendarBody;

  /// No description provided for @youRemindersCalendarButton.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar (.ics)'**
  String get youRemindersCalendarButton;

  /// No description provided for @youRemindersCalendarNone.
  ///
  /// In en, this message translates to:
  /// **'Switch on at least one check-in to create the file.'**
  String get youRemindersCalendarNone;

  /// No description provided for @youRemindersCalendarShared.
  ///
  /// In en, this message translates to:
  /// **'Calendar file shared. Open it with your calendar app to add the check-ins.'**
  String get youRemindersCalendarShared;

  /// No description provided for @youShareDismissed.
  ///
  /// In en, this message translates to:
  /// **'Nothing was shared.'**
  String get youShareDismissed;

  /// No description provided for @youAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get youAppearanceTitle;

  /// No description provided for @youAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Colours, light or dark, and motion.'**
  String get youAppearanceSubtitle;

  /// No description provided for @youThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get youThemeTitle;

  /// No description provided for @youThemeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get youThemeForest;

  /// No description provided for @youThemeOlive.
  ///
  /// In en, this message translates to:
  /// **'Olive'**
  String get youThemeOlive;

  /// No description provided for @youModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Light or dark'**
  String get youModeTitle;

  /// No description provided for @youModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get youModeSystem;

  /// No description provided for @youModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get youModeLight;

  /// No description provided for @youModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get youModeDark;

  /// No description provided for @youMotion.
  ///
  /// In en, this message translates to:
  /// **'Interface motion'**
  String get youMotion;

  /// No description provided for @youMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Gentle movement between screens and the animated emblem. Your phone\'s reduce-motion setting always turns it off.'**
  String get youMotionHint;

  /// No description provided for @youDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get youDataTitle;

  /// No description provided for @youDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you write stays on this phone.'**
  String get youDataSubtitle;

  /// No description provided for @youDataWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where your data lives'**
  String get youDataWhereTitle;

  /// No description provided for @youDataExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export a backup'**
  String get youDataExportTitle;

  /// No description provided for @youDataExportBody.
  ///
  /// In en, this message translates to:
  /// **'Saves everything you\'ve written and chosen as one JSON file you can keep or move to another phone. The file isn\'t encrypted, so keep it somewhere private.'**
  String get youDataExportBody;

  /// No description provided for @youDataExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get youDataExportButton;

  /// No description provided for @youDataExported.
  ///
  /// In en, this message translates to:
  /// **'Backup shared.'**
  String get youDataExported;

  /// No description provided for @youDataImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore a backup'**
  String get youDataImportTitle;

  /// No description provided for @youDataImportBody.
  ///
  /// In en, this message translates to:
  /// **'Replaces everything on this phone with a Cartharise backup. You\'ll see the backup\'s date and confirm first.'**
  String get youDataImportBody;

  /// No description provided for @youDataImportButton.
  ///
  /// In en, this message translates to:
  /// **'Choose a backup file'**
  String get youDataImportButton;

  /// No description provided for @youDataImportConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get youDataImportConfirmTitle;

  /// No description provided for @youDataImportConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Replace everything on this phone with the backup from {date}?'**
  String youDataImportConfirmBody(String date);

  /// No description provided for @youDataImportConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get youDataImportConfirmAction;

  /// No description provided for @youDataImportUnknownDate.
  ///
  /// In en, this message translates to:
  /// **'an unknown date'**
  String get youDataImportUnknownDate;

  /// No description provided for @youDataImported.
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get youDataImported;

  /// No description provided for @youDataImportFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'This file couldn\'t be used'**
  String get youDataImportFailedTitle;

  /// No description provided for @youDataImportUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Your current data was not changed.'**
  String get youDataImportUnchanged;

  /// No description provided for @youDataImportNotJson.
  ///
  /// In en, this message translates to:
  /// **'It isn\'t a readable backup file.'**
  String get youDataImportNotJson;

  /// No description provided for @youDataImportNotBackup.
  ///
  /// In en, this message translates to:
  /// **'It isn\'t a Cartharise backup.'**
  String get youDataImportNotBackup;

  /// No description provided for @youDataImportUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This backup\'s format isn\'t supported by this version of Cartharise.'**
  String get youDataImportUnsupported;

  /// No description provided for @youDataImportDamaged.
  ///
  /// In en, this message translates to:
  /// **'The backup is incomplete or damaged.'**
  String get youDataImportDamaged;

  /// No description provided for @youDataImportTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The file is too large to be a Cartharise backup.'**
  String get youDataImportTooLarge;

  /// No description provided for @youDataImportNotText.
  ///
  /// In en, this message translates to:
  /// **'It isn\'t a text file.'**
  String get youDataImportNotText;

  /// No description provided for @youDataImportOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'The file couldn\'t be opened.'**
  String get youDataImportOpenFailed;

  /// No description provided for @youDataDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get youDataDeleteTitle;

  /// No description provided for @youDataDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Erases everything Cartharise keeps on this phone and cancels reminders. Export a backup first if you want to keep a copy.'**
  String get youDataDeleteBody;

  /// No description provided for @youDataDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete all data'**
  String get youDataDeleteButton;

  /// No description provided for @youDataDeleteConfirm1Title.
  ///
  /// In en, this message translates to:
  /// **'Delete all data?'**
  String get youDataDeleteConfirm1Title;

  /// No description provided for @youDataDeleteConfirm1Body.
  ///
  /// In en, this message translates to:
  /// **'Your answers, Compass, quests, notes, reviews and settings will be erased from this phone, and reminders cancelled.'**
  String get youDataDeleteConfirm1Body;

  /// No description provided for @youDataDeleteConfirm1Action.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get youDataDeleteConfirm1Action;

  /// No description provided for @youDataDeleteConfirm2Title.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone'**
  String get youDataDeleteConfirm2Title;

  /// No description provided for @youDataDeleteConfirm2Body.
  ///
  /// In en, this message translates to:
  /// **'Cartharise keeps no copy anywhere else. Once deleted, your writing can only come back from a backup you exported.'**
  String get youDataDeleteConfirm2Body;

  /// No description provided for @youDataDeleteConfirm2Action.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get youDataDeleteConfirm2Action;

  /// No description provided for @youDataDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your data. Your writing is still on this phone; please try again.'**
  String get youDataDeleteFailed;

  /// No description provided for @youSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support & safety'**
  String get youSupportTitle;

  /// No description provided for @youSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection can stir things up. That\'s normal.'**
  String get youSupportSubtitle;

  /// No description provided for @youSupportNotTherapyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not therapy'**
  String get youSupportNotTherapyTitle;

  /// No description provided for @youSupportNotTherapyBody.
  ///
  /// In en, this message translates to:
  /// **'Cartharise is a tool for self-reflection. It isn\'t therapy, counselling or medical advice, and it doesn\'t diagnose anything.'**
  String get youSupportNotTherapyBody;

  /// No description provided for @youSupportHeavyTitle.
  ///
  /// In en, this message translates to:
  /// **'If a question feels heavy'**
  String get youSupportHeavyTitle;

  /// No description provided for @youSupportHeavy1.
  ///
  /// In en, this message translates to:
  /// **'Skip it. Every question is optional.'**
  String get youSupportHeavy1;

  /// No description provided for @youSupportHeavy2.
  ///
  /// In en, this message translates to:
  /// **'Switch to the softer wording where it\'s offered.'**
  String get youSupportHeavy2;

  /// No description provided for @youSupportHeavy3.
  ///
  /// In en, this message translates to:
  /// **'Pause and come back another day. Your words are kept.'**
  String get youSupportHeavy3;

  /// No description provided for @youSupportHeavy4.
  ///
  /// In en, this message translates to:
  /// **'Talk it through with someone you trust.'**
  String get youSupportHeavy4;

  /// No description provided for @youSupportCrisisTitle.
  ///
  /// In en, this message translates to:
  /// **'If you\'re in crisis'**
  String get youSupportCrisisTitle;

  /// No description provided for @youSupportCrisisBody.
  ///
  /// In en, this message translates to:
  /// **'If you\'re in danger or thinking about harming yourself, contact your local emergency services now, or reach a crisis line in your country.'**
  String get youSupportCrisisBody;

  /// No description provided for @youSupportFindHelpline.
  ///
  /// In en, this message translates to:
  /// **'Find a helpline'**
  String get youSupportFindHelpline;

  /// No description provided for @youSupportHelplineHint.
  ///
  /// In en, this message translates to:
  /// **'Opens findahelpline.com, a directory of helplines by country.'**
  String get youSupportHelplineHint;

  /// No description provided for @youSupportOngoingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ongoing support'**
  String get youSupportOngoingTitle;

  /// No description provided for @youSupportOngoingBody.
  ///
  /// In en, this message translates to:
  /// **'If difficult feelings last or get in the way of daily life, a doctor, psychologist or counsellor can help.'**
  String get youSupportOngoingBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
