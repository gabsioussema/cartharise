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

  /// Cinzel screen title of the Compass tab.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get compassTitle;

  /// No description provided for @compassSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your direction, in your own words.'**
  String get compassSubtitle;

  /// No description provided for @compassMissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your direction, in action.'**
  String get compassMissionsSubtitle;

  /// No description provided for @compassSectionCompass.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get compassSectionCompass;

  /// No description provided for @compassSectionMissions.
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get compassSectionMissions;

  /// No description provided for @compassHeroEyebrow.
  ///
  /// In en, this message translates to:
  /// **'My direction'**
  String get compassHeroEyebrow;

  /// No description provided for @compassHeroEmpty.
  ///
  /// In en, this message translates to:
  /// **'Six short answers that point your days somewhere you choose. Write them yourself, or start from your evening reflection.'**
  String get compassHeroEmpty;

  /// No description provided for @compassLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {date}'**
  String compassLastUpdated(String date);

  /// No description provided for @compassImportOfferTitleEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start from your evening reflection'**
  String get compassImportOfferTitleEmpty;

  /// No description provided for @compassImportOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'Evening answers can fill empty fields'**
  String get compassImportOfferTitle;

  /// No description provided for @compassImportOfferBody.
  ///
  /// In en, this message translates to:
  /// **'You can bring your own evening words into the empty fields below. You choose which ones, and nothing changes until you confirm.'**
  String get compassImportOfferBody;

  /// No description provided for @compassImportAction.
  ///
  /// In en, this message translates to:
  /// **'Use my evening reflections'**
  String get compassImportAction;

  /// No description provided for @compassEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Compass is empty'**
  String get compassEmptyTitle;

  /// No description provided for @compassEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Write each part yourself below, or answer the evening reflection first and bring your words here.'**
  String get compassEmptyBody;

  /// No description provided for @compassEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Go to the evening reflection'**
  String get compassEmptyAction;

  /// No description provided for @compassFieldAntiVision.
  ///
  /// In en, this message translates to:
  /// **'Anti-vision'**
  String get compassFieldAntiVision;

  /// No description provided for @compassFieldAntiVisionHelp.
  ///
  /// In en, this message translates to:
  /// **'What I refuse to let my life become.'**
  String get compassFieldAntiVisionHelp;

  /// No description provided for @compassFieldAntiVisionHint.
  ///
  /// In en, this message translates to:
  /// **'The life I don\'t want, in a sentence or two'**
  String get compassFieldAntiVisionHint;

  /// No description provided for @compassFieldVision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get compassFieldVision;

  /// No description provided for @compassFieldVisionHelp.
  ///
  /// In en, this message translates to:
  /// **'What I\'m building toward.'**
  String get compassFieldVisionHelp;

  /// No description provided for @compassFieldVisionHint.
  ///
  /// In en, this message translates to:
  /// **'The life I want to grow into'**
  String get compassFieldVisionHint;

  /// No description provided for @compassFieldYearGoal.
  ///
  /// In en, this message translates to:
  /// **'One-year mission'**
  String get compassFieldYearGoal;

  /// No description provided for @compassFieldYearGoalHelp.
  ///
  /// In en, this message translates to:
  /// **'The outcome that would matter most a year from now.'**
  String get compassFieldYearGoalHelp;

  /// No description provided for @compassFieldYearGoalHint.
  ///
  /// In en, this message translates to:
  /// **'By this time next year, I…'**
  String get compassFieldYearGoalHint;

  /// No description provided for @compassFieldMonthProject.
  ///
  /// In en, this message translates to:
  /// **'One-month project'**
  String get compassFieldMonthProject;

  /// No description provided for @compassFieldMonthProjectHelp.
  ///
  /// In en, this message translates to:
  /// **'One project for the next four weeks that moves the mission forward.'**
  String get compassFieldMonthProjectHelp;

  /// No description provided for @compassFieldMonthProjectHint.
  ///
  /// In en, this message translates to:
  /// **'This month I will build or finish…'**
  String get compassFieldMonthProjectHint;

  /// No description provided for @compassFieldDailyLevers.
  ///
  /// In en, this message translates to:
  /// **'Daily levers'**
  String get compassFieldDailyLevers;

  /// No description provided for @compassFieldDailyLeversHelp.
  ///
  /// In en, this message translates to:
  /// **'2–3 actions, one per line.'**
  String get compassFieldDailyLeversHelp;

  /// No description provided for @compassFieldDailyLeversHint.
  ///
  /// In en, this message translates to:
  /// **'Walk 20 minutes\nRead 10 pages'**
  String get compassFieldDailyLeversHint;

  /// No description provided for @compassFieldConstraints.
  ///
  /// In en, this message translates to:
  /// **'Boundaries'**
  String get compassFieldConstraints;

  /// No description provided for @compassFieldConstraintsHelp.
  ///
  /// In en, this message translates to:
  /// **'What I won\'t sacrifice.'**
  String get compassFieldConstraintsHelp;

  /// No description provided for @compassFieldConstraintsHint.
  ///
  /// In en, this message translates to:
  /// **'Sleep, family dinners, one rest day…'**
  String get compassFieldConstraintsHint;

  /// No description provided for @compassConstraintsOwnWords.
  ///
  /// In en, this message translates to:
  /// **'Only you write this. Cartharise never fills it in from your answers.'**
  String get compassConstraintsOwnWords;

  /// No description provided for @compassConstraintsChip.
  ///
  /// In en, this message translates to:
  /// **'Written only by you'**
  String get compassConstraintsChip;

  /// No description provided for @compassLeversToQuests.
  ///
  /// In en, this message translates to:
  /// **'Turn into quests'**
  String get compassLeversToQuests;

  /// No description provided for @compassOpenProject.
  ///
  /// In en, this message translates to:
  /// **'Open month project'**
  String get compassOpenProject;

  /// No description provided for @compassVersionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get compassVersionsTitle;

  /// No description provided for @compassVersionsBody.
  ///
  /// In en, this message translates to:
  /// **'Save a snapshot before big changes. Restoring an older version first keeps a copy of what you have now.'**
  String get compassVersionsBody;

  /// No description provided for @compassSaveVersion.
  ///
  /// In en, this message translates to:
  /// **'Save a version'**
  String get compassSaveVersion;

  /// No description provided for @compassVersionSaved.
  ///
  /// In en, this message translates to:
  /// **'Version saved'**
  String get compassVersionSaved;

  /// No description provided for @compassViewVersions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Versions} other{Versions ({count})}}'**
  String compassViewVersions(int count);

  /// No description provided for @compassVersionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Snapshots of your Compass, newest first.'**
  String get compassVersionsSubtitle;

  /// No description provided for @compassVersionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No versions yet'**
  String get compassVersionsEmptyTitle;

  /// No description provided for @compassVersionsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Save a version whenever you want a snapshot to look back on.'**
  String get compassVersionsEmptyBody;

  /// No description provided for @compassVersionReasonManual.
  ///
  /// In en, this message translates to:
  /// **'Saved by you'**
  String get compassVersionReasonManual;

  /// No description provided for @compassVersionReasonBeforeImport.
  ///
  /// In en, this message translates to:
  /// **'Before an import'**
  String get compassVersionReasonBeforeImport;

  /// No description provided for @compassVersionReasonBeforeRestore.
  ///
  /// In en, this message translates to:
  /// **'Before a restore'**
  String get compassVersionReasonBeforeRestore;

  /// No description provided for @compassVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get compassVersionTitle;

  /// No description provided for @compassVersionEmptyField.
  ///
  /// In en, this message translates to:
  /// **'Empty in this version'**
  String get compassVersionEmptyField;

  /// No description provided for @compassVersionSameAsNow.
  ///
  /// In en, this message translates to:
  /// **'Same as now'**
  String get compassVersionSameAsNow;

  /// No description provided for @compassVersionDiffers.
  ///
  /// In en, this message translates to:
  /// **'Differs from now'**
  String get compassVersionDiffers;

  /// No description provided for @compassVersionReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only. Restoring replaces your current Compass, after saving it as a version.'**
  String get compassVersionReadOnly;

  /// No description provided for @compassRestoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore this version'**
  String get compassRestoreAction;

  /// No description provided for @compassRestoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this version?'**
  String get compassRestoreConfirmTitle;

  /// No description provided for @compassRestoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your Compass will be replaced by this version. What you have now is saved as a version first, so nothing is lost.'**
  String get compassRestoreConfirmBody;

  /// No description provided for @compassRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get compassRestoreConfirm;

  /// No description provided for @compassRestored.
  ///
  /// In en, this message translates to:
  /// **'Version restored. Your previous Compass was saved as a version.'**
  String get compassRestored;

  /// No description provided for @compassImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Use my evening reflections'**
  String get compassImportTitle;

  /// No description provided for @compassImportBody.
  ///
  /// In en, this message translates to:
  /// **'Your evening answers, exactly as you wrote them. Choose which empty fields they should start.'**
  String get compassImportBody;

  /// No description provided for @compassImportFrom.
  ///
  /// In en, this message translates to:
  /// **'From: {prompt}'**
  String compassImportFrom(String prompt);

  /// No description provided for @compassImportKeeps.
  ///
  /// In en, this message translates to:
  /// **'Keeps your current text'**
  String get compassImportKeeps;

  /// No description provided for @compassImportNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No evening answer yet'**
  String get compassImportNoAnswer;

  /// No description provided for @compassImportConstraintsNote.
  ///
  /// In en, this message translates to:
  /// **'Boundaries are never filled from your answers. Only you write them.'**
  String get compassImportConstraintsNote;

  /// No description provided for @compassImportSnapshotNote.
  ///
  /// In en, this message translates to:
  /// **'Your current Compass is saved as a version first.'**
  String get compassImportSnapshotNote;

  /// No description provided for @compassImportConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Choose a field} =1{Fill 1 field} other{Fill {count} fields}}'**
  String compassImportConfirm(int count);

  /// No description provided for @compassImportNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to bring over yet. Answer the evening questions in Reset, then come back.'**
  String get compassImportNothing;

  /// No description provided for @compassImportDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Compass field filled from your evening answers.} other{{count} Compass fields filled from your evening answers.}}'**
  String compassImportDone(int count);

  /// No description provided for @missionsIntro.
  ///
  /// In en, this message translates to:
  /// **'Small actions that move your Compass forward. Rest days are part of it.'**
  String get missionsIntro;

  /// No description provided for @missionsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get missionsToday;

  /// No description provided for @missionsTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned for today. Add a small quest, or rest. Both are fine.'**
  String get missionsTodayEmpty;

  /// No description provided for @missionsLater.
  ///
  /// In en, this message translates to:
  /// **'Anytime & upcoming'**
  String get missionsLater;

  /// No description provided for @missionsLaterEmpty.
  ///
  /// In en, this message translates to:
  /// **'Quests without a date, or planned for later, appear here.'**
  String get missionsLaterEmpty;

  /// No description provided for @missionsDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Done} other{Done ({count})}}'**
  String missionsDone(int count);

  /// No description provided for @missionsAddQuest.
  ///
  /// In en, this message translates to:
  /// **'Add a quest'**
  String get missionsAddQuest;

  /// No description provided for @missionsQuestMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark \'{title}\' done'**
  String missionsQuestMarkDone(String title);

  /// No description provided for @missionsQuestOptions.
  ///
  /// In en, this message translates to:
  /// **'Options for \'{title}\''**
  String missionsQuestOptions(String title);

  /// No description provided for @missionsQuestDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get missionsQuestDaily;

  /// No description provided for @missionsQuestDue.
  ///
  /// In en, this message translates to:
  /// **'Planned for {date}'**
  String missionsQuestDue(String date);

  /// No description provided for @missionsQuestDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get missionsQuestDoneToday;

  /// No description provided for @missionsQuestDoneOn.
  ///
  /// In en, this message translates to:
  /// **'Done {date}'**
  String missionsQuestDoneOn(String date);

  /// No description provided for @missionsQuestMovedToDone.
  ///
  /// In en, this message translates to:
  /// **'\'{title}\' moved to Done'**
  String missionsQuestMovedToDone(String title);

  /// No description provided for @missionsUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get missionsUndo;

  /// No description provided for @missionsQuestDeleted.
  ///
  /// In en, this message translates to:
  /// **'Quest deleted'**
  String get missionsQuestDeleted;

  /// No description provided for @missionsQuestEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get missionsQuestEdit;

  /// No description provided for @missionsQuestDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get missionsQuestDelete;

  /// No description provided for @missionsNewQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'New quest'**
  String get missionsNewQuestTitle;

  /// No description provided for @missionsEditQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit quest'**
  String get missionsEditQuestTitle;

  /// No description provided for @missionsQuestTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'What will you do?'**
  String get missionsQuestTitleLabel;

  /// No description provided for @missionsQuestTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Walk 20 minutes'**
  String get missionsQuestTitleHint;

  /// No description provided for @missionsQuestTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the quest a few words.'**
  String get missionsQuestTitleRequired;

  /// No description provided for @missionsQuestRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat every day'**
  String get missionsQuestRepeat;

  /// No description provided for @missionsQuestRepeatHelp.
  ///
  /// In en, this message translates to:
  /// **'Shows in Today each day. Checking it off counts for that day only.'**
  String get missionsQuestRepeatHelp;

  /// No description provided for @missionsQuestDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Date (optional)'**
  String get missionsQuestDueLabel;

  /// No description provided for @missionsQuestNoDate.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get missionsQuestNoDate;

  /// No description provided for @missionsQuestChooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get missionsQuestChooseDate;

  /// No description provided for @missionsQuestClearDate.
  ///
  /// In en, this message translates to:
  /// **'Remove date'**
  String get missionsQuestClearDate;

  /// No description provided for @missionsQuestSave.
  ///
  /// In en, this message translates to:
  /// **'Save quest'**
  String get missionsQuestSave;

  /// No description provided for @missionsQuestDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete quest'**
  String get missionsQuestDeleteAction;

  /// No description provided for @missionsLeversTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn your daily levers into quests'**
  String get missionsLeversTitle;

  /// No description provided for @missionsLeversBody.
  ///
  /// In en, this message translates to:
  /// **'From your Compass. Change the words if you like; each one you keep becomes a daily quest.'**
  String get missionsLeversBody;

  /// No description provided for @missionsLeversInclude.
  ///
  /// In en, this message translates to:
  /// **'Include \'{title}\''**
  String missionsLeversInclude(String title);

  /// No description provided for @missionsLeversDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Quest {index}'**
  String missionsLeversDraftLabel(int index);

  /// No description provided for @missionsLeversAdd.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Choose at least one} =1{Add 1 daily quest} other{Add {count} daily quests}}'**
  String missionsLeversAdd(int count);

  /// No description provided for @missionsLeversAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing new to add. Those quests already exist.} =1{1 daily quest added.} other{{count} daily quests added.}}'**
  String missionsLeversAdded(int count);

  /// No description provided for @missionsLeversNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get missionsLeversNotNow;

  /// No description provided for @missionsProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Month project'**
  String get missionsProjectTitle;

  /// No description provided for @missionsProjectEmpty.
  ///
  /// In en, this message translates to:
  /// **'Plan one project for the next four weeks, with a few visible milestones.'**
  String get missionsProjectEmpty;

  /// No description provided for @missionsProjectFromCompass.
  ///
  /// In en, this message translates to:
  /// **'From your Compass: {title}'**
  String missionsProjectFromCompass(String title);

  /// No description provided for @missionsProjectUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled project'**
  String get missionsProjectUntitled;

  /// No description provided for @missionsProjectMilestones.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} milestones done'**
  String missionsProjectMilestones(int done, int total);

  /// No description provided for @missionsStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get missionsStatusPlanned;

  /// No description provided for @missionsStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get missionsStatusActive;

  /// No description provided for @missionsStatusPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get missionsStatusPaused;

  /// No description provided for @missionsStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get missionsStatusDone;

  /// No description provided for @missionsProjectScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One project, a few milestones, and a look back.'**
  String get missionsProjectScreenSubtitle;

  /// No description provided for @missionsProjectTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get missionsProjectTitleLabel;

  /// No description provided for @missionsProjectTitleHint.
  ///
  /// In en, this message translates to:
  /// **'What will you build or finish this month?'**
  String get missionsProjectTitleHint;

  /// No description provided for @missionsProjectLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked to your Compass'**
  String get missionsProjectLinked;

  /// No description provided for @missionsProjectOfferUpdate.
  ///
  /// In en, this message translates to:
  /// **'Your Compass says: {title}. Update it to match?'**
  String missionsProjectOfferUpdate(String title);

  /// No description provided for @missionsProjectOfferAdd.
  ///
  /// In en, this message translates to:
  /// **'Add this as the one-month project in your Compass?'**
  String get missionsProjectOfferAdd;

  /// No description provided for @missionsProjectUpdateCompass.
  ///
  /// In en, this message translates to:
  /// **'Update Compass'**
  String get missionsProjectUpdateCompass;

  /// No description provided for @missionsProjectAddCompass.
  ///
  /// In en, this message translates to:
  /// **'Add to Compass'**
  String get missionsProjectAddCompass;

  /// No description provided for @missionsProjectKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep as is'**
  String get missionsProjectKeep;

  /// No description provided for @missionsProjectCompassUpdated.
  ///
  /// In en, this message translates to:
  /// **'Compass updated'**
  String get missionsProjectCompassUpdated;

  /// No description provided for @missionsProjectStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get missionsProjectStatus;

  /// No description provided for @missionsMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get missionsMilestones;

  /// No description provided for @missionsMilestonesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Break the project into a few steps someone could see.'**
  String get missionsMilestonesEmpty;

  /// No description provided for @missionsMilestoneAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a milestone'**
  String get missionsMilestoneAdd;

  /// No description provided for @missionsMilestoneNew.
  ///
  /// In en, this message translates to:
  /// **'New milestone'**
  String get missionsMilestoneNew;

  /// No description provided for @missionsMilestoneRename.
  ///
  /// In en, this message translates to:
  /// **'Rename milestone'**
  String get missionsMilestoneRename;

  /// No description provided for @missionsMilestoneMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark milestone \'{title}\' done'**
  String missionsMilestoneMarkDone(String title);

  /// No description provided for @missionsMilestoneRenameLabel.
  ///
  /// In en, this message translates to:
  /// **'Rename \'{title}\''**
  String missionsMilestoneRenameLabel(String title);

  /// No description provided for @missionsMilestoneDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete \'{title}\''**
  String missionsMilestoneDeleteLabel(String title);

  /// No description provided for @missionsMilestoneDeleted.
  ///
  /// In en, this message translates to:
  /// **'Milestone deleted'**
  String get missionsMilestoneDeleted;

  /// No description provided for @missionsRetro.
  ///
  /// In en, this message translates to:
  /// **'Looking back'**
  String get missionsRetro;

  /// No description provided for @missionsRetroHelp.
  ///
  /// In en, this message translates to:
  /// **'Write any time: what worked, what you learned, what you would do differently.'**
  String get missionsRetroHelp;

  /// No description provided for @missionsRetroHint.
  ///
  /// In en, this message translates to:
  /// **'Your notes'**
  String get missionsRetroHint;

  /// No description provided for @missionsProjectClear.
  ///
  /// In en, this message translates to:
  /// **'Start a new project'**
  String get missionsProjectClear;

  /// No description provided for @missionsProjectClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new project?'**
  String get missionsProjectClearTitle;

  /// No description provided for @missionsProjectClearBody.
  ///
  /// In en, this message translates to:
  /// **'This clears the title, milestones and notes of the current project. Your Compass is not changed.'**
  String get missionsProjectClearBody;

  /// No description provided for @missionsProjectClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear project'**
  String get missionsProjectClearConfirm;

  /// No description provided for @missionsPathTitle.
  ///
  /// In en, this message translates to:
  /// **'30-day path'**
  String get missionsPathTitle;

  /// No description provided for @missionsPathIntro.
  ///
  /// In en, this message translates to:
  /// **'Any day is open — go at your own pace.'**
  String get missionsPathIntro;

  /// No description provided for @missionsPathWrittenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of 30 written'**
  String missionsPathWrittenCount(int count);

  /// No description provided for @missionsStageObserve.
  ///
  /// In en, this message translates to:
  /// **'Observe'**
  String get missionsStageObserve;

  /// No description provided for @missionsStageExperiment.
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get missionsStageExperiment;

  /// No description provided for @missionsStageBuild.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get missionsStageBuild;

  /// No description provided for @missionsStageAdjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get missionsStageAdjust;

  /// No description provided for @missionsStageObserveHelp.
  ///
  /// In en, this message translates to:
  /// **'Notice what happens, without judging it.'**
  String get missionsStageObserveHelp;

  /// No description provided for @missionsStageExperimentHelp.
  ///
  /// In en, this message translates to:
  /// **'Try small changes and see what helps.'**
  String get missionsStageExperimentHelp;

  /// No description provided for @missionsStageBuildHelp.
  ///
  /// In en, this message translates to:
  /// **'Keep what helps and make it easier.'**
  String get missionsStageBuildHelp;

  /// No description provided for @missionsStageAdjustHelp.
  ///
  /// In en, this message translates to:
  /// **'Look back and adjust your direction.'**
  String get missionsStageAdjustHelp;

  /// No description provided for @missionsStageDays.
  ///
  /// In en, this message translates to:
  /// **'Days {from}–{to}'**
  String missionsStageDays(int from, int to);

  /// No description provided for @missionsDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String missionsDayLabel(int day);

  /// No description provided for @missionsDayWritten.
  ///
  /// In en, this message translates to:
  /// **'Written'**
  String get missionsDayWritten;

  /// No description provided for @missionsDayStage.
  ///
  /// In en, this message translates to:
  /// **'Day {day} · {stage}'**
  String missionsDayStage(int day, String stage);

  /// No description provided for @missionsDayAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your note for day {day}'**
  String missionsDayAnswerLabel(int day);

  /// No description provided for @missionsDayAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Write as much or as little as you like.'**
  String get missionsDayAnswerHint;

  /// No description provided for @missionsDayPrevious.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String missionsDayPrevious(int day);

  /// No description provided for @missionsDayNext.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String missionsDayNext(int day);

  /// No description provided for @missionsDayPreviousLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous: day {day}'**
  String missionsDayPreviousLabel(int day);

  /// No description provided for @missionsDayNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next: day {day}'**
  String missionsDayNextLabel(int day);

  /// No description provided for @missionsDayMissing.
  ///
  /// In en, this message translates to:
  /// **'This day isn\'t available.'**
  String get missionsDayMissing;
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
