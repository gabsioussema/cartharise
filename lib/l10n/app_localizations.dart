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

  /// No description provided for @awakeningTitle.
  ///
  /// In en, this message translates to:
  /// **'The Awakening'**
  String get awakeningTitle;

  /// No description provided for @awakeningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seven ideas behind the reset, in plain words. Optional, and in any order.'**
  String get awakeningSubtitle;

  /// No description provided for @awakeningStripTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn the ideas first (optional)'**
  String get awakeningStripTitle;

  /// No description provided for @awakeningSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all lessons'**
  String get awakeningSeeAll;

  /// No description provided for @awakeningReadCount.
  ///
  /// In en, this message translates to:
  /// **'{read} of {total} read'**
  String awakeningReadCount(int read, int total);

  /// No description provided for @awakeningLessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson {n}'**
  String awakeningLessonNumber(int n);

  /// No description provided for @awakeningLessonOf.
  ///
  /// In en, this message translates to:
  /// **'Lesson {n} of {total}'**
  String awakeningLessonOf(int n, int total);

  /// No description provided for @awakeningRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get awakeningRead;

  /// No description provided for @awakeningNotRead.
  ///
  /// In en, this message translates to:
  /// **'Not read yet'**
  String get awakeningNotRead;

  /// No description provided for @awakeningExample.
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get awakeningExample;

  /// No description provided for @awakeningNuance.
  ///
  /// In en, this message translates to:
  /// **'A lens, not a verdict'**
  String get awakeningNuance;

  /// No description provided for @awakeningCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your understanding'**
  String get awakeningCheckTitle;

  /// No description provided for @awakeningCheckHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the answer that fits best. Nothing is scored or saved.'**
  String get awakeningCheckHint;

  /// No description provided for @awakeningCheckRight.
  ///
  /// In en, this message translates to:
  /// **'That\'s it.'**
  String get awakeningCheckRight;

  /// No description provided for @awakeningCheckNotQuite.
  ///
  /// In en, this message translates to:
  /// **'Not quite, and that\'s fine.'**
  String get awakeningCheckNotQuite;

  /// No description provided for @awakeningTryIt.
  ///
  /// In en, this message translates to:
  /// **'Try it'**
  String get awakeningTryIt;

  /// No description provided for @awakeningTryItBody.
  ///
  /// In en, this message translates to:
  /// **'Put this idea into practice with a reset question.'**
  String get awakeningTryItBody;

  /// No description provided for @awakeningTryItPrompt.
  ///
  /// In en, this message translates to:
  /// **'Try it: {title}'**
  String awakeningTryItPrompt(String title);

  /// No description provided for @awakeningPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous lesson'**
  String get awakeningPrevious;

  /// No description provided for @awakeningNext.
  ///
  /// In en, this message translates to:
  /// **'Next lesson'**
  String get awakeningNext;

  /// No description provided for @awakeningDone.
  ///
  /// In en, this message translates to:
  /// **'Back to the lessons'**
  String get awakeningDone;

  /// No description provided for @awakeningSourceNote.
  ///
  /// In en, this message translates to:
  /// **'Paraphrased in Cartharise\'s own words from “{title}” by {author}. Cartharise is independent.'**
  String awakeningSourceNote(String title, String author);

  /// No description provided for @awakeningSourceLink.
  ///
  /// In en, this message translates to:
  /// **'About the source'**
  String get awakeningSourceLink;

  /// No description provided for @awakeningMissing.
  ///
  /// In en, this message translates to:
  /// **'This lesson isn\'t available.'**
  String get awakeningMissing;

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

  /// Brand page, under the tagline.
  ///
  /// In en, this message translates to:
  /// **'A calm guide to one honest day of reflection, and the small steps that follow it.'**
  String get onboardingBrandIntro;

  /// No description provided for @onboardingBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get onboardingBegin;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Screen-reader label of Skip: it jumps to the setup steps.
  ///
  /// In en, this message translates to:
  /// **'Skip the introduction'**
  String get onboardingSkipLabel;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinish;

  /// No description provided for @onboardingPageDots.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String onboardingPageDots(int current, int total);

  /// No description provided for @onboardingStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Setup {current} of {total}'**
  String onboardingStepCounter(int current, int total);

  /// No description provided for @onboardingUnderstandTitle.
  ///
  /// In en, this message translates to:
  /// **'Understand Yourself'**
  String get onboardingUnderstandTitle;

  /// No description provided for @onboardingUnderstandBody.
  ///
  /// In en, this message translates to:
  /// **'Notice what you want, what you put up with, and what keeps pulling you back.'**
  String get onboardingUnderstandBody;

  /// No description provided for @onboardingResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Life'**
  String get onboardingResetTitle;

  /// No description provided for @onboardingResetBody.
  ///
  /// In en, this message translates to:
  /// **'Spend one honest day with a few questions, morning, daytime and evening, and see your situation clearly.'**
  String get onboardingResetBody;

  /// No description provided for @onboardingDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Direction'**
  String get onboardingDirectionTitle;

  /// No description provided for @onboardingDirectionBody.
  ///
  /// In en, this message translates to:
  /// **'Turn what you discover into a Life Compass: what you move away from, and what you move toward.'**
  String get onboardingDirectionBody;

  /// No description provided for @onboardingStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'Improve Step by Step'**
  String get onboardingStepsTitle;

  /// No description provided for @onboardingStepsBody.
  ///
  /// In en, this message translates to:
  /// **'Small daily actions, looked at each week and adjusted as you learn. No streaks, no scores.'**
  String get onboardingStepsBody;

  /// No description provided for @onboardingLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'What This Is, and Isn\'t'**
  String get onboardingLimitsTitle;

  /// No description provided for @onboardingLimitsIntro.
  ///
  /// In en, this message translates to:
  /// **'Before you begin, a few honest words.'**
  String get onboardingLimitsIntro;

  /// No description provided for @onboardingLimitsClarityTitle.
  ///
  /// In en, this message translates to:
  /// **'One day can bring clarity'**
  String get onboardingLimitsClarityTitle;

  /// No description provided for @onboardingLimitsClarityBody.
  ///
  /// In en, this message translates to:
  /// **'A focused day of questions can show you where you stand and what you would like instead.'**
  String get onboardingLimitsClarityBody;

  /// No description provided for @onboardingLimitsNoGuaranteeTitle.
  ///
  /// In en, this message translates to:
  /// **'It can\'t guarantee a fixed life'**
  String get onboardingLimitsNoGuaranteeTitle;

  /// No description provided for @onboardingLimitsNoGuaranteeBody.
  ///
  /// In en, this message translates to:
  /// **'Change comes from what you keep doing afterwards: small actions, noticed and adjusted over weeks.'**
  String get onboardingLimitsNoGuaranteeBody;

  /// No description provided for @onboardingLimitsPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'An ongoing practice'**
  String get onboardingLimitsPracticeTitle;

  /// No description provided for @onboardingLimitsPracticeBody.
  ///
  /// In en, this message translates to:
  /// **'Come back whenever you like. You can redo the reset, change your goals or simply write.'**
  String get onboardingLimitsPracticeBody;

  /// No description provided for @onboardingLimitsNotTherapyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not therapy or diagnosis'**
  String get onboardingLimitsNotTherapyTitle;

  /// No description provided for @onboardingLimitsNotTherapyBody.
  ///
  /// In en, this message translates to:
  /// **'Cartharise is a self-reflection tool. It doesn\'t diagnose anything or replace professional care. If you\'re having a hard time, Support in the You tab lists places to get help.'**
  String get onboardingLimitsNotTherapyBody;

  /// No description provided for @onboardingLimitsControlTitle.
  ///
  /// In en, this message translates to:
  /// **'You stay in control'**
  String get onboardingLimitsControlTitle;

  /// No description provided for @onboardingLimitsControlBody.
  ///
  /// In en, this message translates to:
  /// **'Every question can be skipped, softened or left for later.'**
  String get onboardingLimitsControlBody;

  /// No description provided for @onboardingAdultConfirm.
  ///
  /// In en, this message translates to:
  /// **'I\'m 18 or older'**
  String get onboardingAdultConfirm;

  /// No description provided for @onboardingAdultConfirmHelp.
  ///
  /// In en, this message translates to:
  /// **'Cartharise is made for adults.'**
  String get onboardingAdultConfirmHelp;

  /// No description provided for @onboardingAdultRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm you\'re 18 or older to continue.'**
  String get onboardingAdultRequired;

  /// No description provided for @onboardingCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspired By'**
  String get onboardingCreditTitle;

  /// No description provided for @onboardingCreditIntro.
  ///
  /// In en, this message translates to:
  /// **'Cartharise is built around the ideas of this article:'**
  String get onboardingCreditIntro;

  /// No description provided for @onboardingCreditByline.
  ///
  /// In en, this message translates to:
  /// **'by {author} · {date}'**
  String onboardingCreditByline(String author, String date);

  /// No description provided for @onboardingCreditArticle.
  ///
  /// In en, this message translates to:
  /// **'Read the original article'**
  String get onboardingCreditArticle;

  /// No description provided for @onboardingCreditNewsletter.
  ///
  /// In en, this message translates to:
  /// **'Read it in the author\'s newsletter'**
  String get onboardingCreditNewsletter;

  /// No description provided for @onboardingCreditNoNeed.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to read it first. Every idea is explained in plain words as you go.'**
  String get onboardingCreditNoNeed;

  /// No description provided for @onboardingPaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Pace'**
  String get onboardingPaceTitle;

  /// No description provided for @onboardingPaceIntro.
  ///
  /// In en, this message translates to:
  /// **'You can change this later in the You tab.'**
  String get onboardingPaceIntro;

  /// No description provided for @onboardingPaceOneDayTitle.
  ///
  /// In en, this message translates to:
  /// **'One day'**
  String get onboardingPaceOneDayTitle;

  /// No description provided for @onboardingPaceOneDayBody.
  ///
  /// In en, this message translates to:
  /// **'Do the morning, daytime and evening reflections within a single day.'**
  String get onboardingPaceOneDayBody;

  /// No description provided for @onboardingPaceFlexibleTitle.
  ///
  /// In en, this message translates to:
  /// **'At my own pace'**
  String get onboardingPaceFlexibleTitle;

  /// No description provided for @onboardingPaceFlexibleBody.
  ///
  /// In en, this message translates to:
  /// **'Spread the reflections over days or weeks and pick up where you left off.'**
  String get onboardingPaceFlexibleBody;

  /// No description provided for @onboardingPaceNoLock.
  ///
  /// In en, this message translates to:
  /// **'Either way, nothing ever locks or expires. Every part stays open.'**
  String get onboardingPaceNoLock;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What Should We Call You?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameIntro.
  ///
  /// In en, this message translates to:
  /// **'Optional, never shared. It stays on this phone and is only used to greet you.'**
  String get onboardingNameIntro;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty and Cartharise will call you Traveler.'**
  String get onboardingNameHelp;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Words Stay Yours'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyStorageHeading.
  ///
  /// In en, this message translates to:
  /// **'Where your writing lives'**
  String get onboardingPrivacyStorageHeading;

  /// No description provided for @onboardingPrivacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account, no ads, no analytics. Nothing you write is sent anywhere.'**
  String get onboardingPrivacyNoAccount;

  /// No description provided for @onboardingPrivacyControl.
  ///
  /// In en, this message translates to:
  /// **'You can export or delete everything at any time in You, under Your data.'**
  String get onboardingPrivacyControl;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'The Reset'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One guided day: look honestly at where you are, picture where you want to go, and choose a first step.'**
  String get resetSubtitle;

  /// No description provided for @resetPaceOneDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pace: one day'**
  String get resetPaceOneDayTitle;

  /// No description provided for @resetPaceOneDayBody.
  ///
  /// In en, this message translates to:
  /// **'Morning questions, a few check-ins during the day, then the evening. Nothing locks if it takes you longer.'**
  String get resetPaceOneDayBody;

  /// No description provided for @resetPaceFlexibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pace: your own'**
  String get resetPaceFlexibleTitle;

  /// No description provided for @resetPaceFlexibleBody.
  ///
  /// In en, this message translates to:
  /// **'Take the parts in any order and come back whenever you like. Nothing locks and nothing expires.'**
  String get resetPaceFlexibleBody;

  /// No description provided for @resetPaceChange.
  ///
  /// In en, this message translates to:
  /// **'Change pace'**
  String get resetPaceChange;

  /// No description provided for @resetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Your reset'**
  String get resetProgressTitle;

  /// No description provided for @resetProgressCount.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} core questions answered'**
  String resetProgressCount(int answered, int total);

  /// No description provided for @resetProgressNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String resetProgressNext(String title);

  /// No description provided for @resetBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get resetBegin;

  /// No description provided for @resetContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resetContinue;

  /// No description provided for @resetAllDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Every core question has been answered or skipped. You can still open and change any of them.'**
  String get resetAllDoneBody;

  /// No description provided for @resetSeeCreated.
  ///
  /// In en, this message translates to:
  /// **'See what you created'**
  String get resetSeeCreated;

  /// No description provided for @resetCompletedOn.
  ///
  /// In en, this message translates to:
  /// **'Finished on {date}. You can still revisit and edit any answer.'**
  String resetCompletedOn(String date);

  /// No description provided for @resetPhasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day'**
  String get resetPhasesTitle;

  /// No description provided for @resetPhaseMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get resetPhaseMorning;

  /// No description provided for @resetPhaseDaytime.
  ///
  /// In en, this message translates to:
  /// **'Daytime'**
  String get resetPhaseDaytime;

  /// No description provided for @resetPhaseBonus.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get resetPhaseBonus;

  /// No description provided for @resetPhaseEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get resetPhaseEvening;

  /// No description provided for @resetSubflowMirror.
  ///
  /// In en, this message translates to:
  /// **'The Mirror'**
  String get resetSubflowMirror;

  /// No description provided for @resetSubflowVision.
  ///
  /// In en, this message translates to:
  /// **'The Vision'**
  String get resetSubflowVision;

  /// No description provided for @resetSubflowInterrupt.
  ///
  /// In en, this message translates to:
  /// **'The Interrupt'**
  String get resetSubflowInterrupt;

  /// No description provided for @resetSubflowBreakthrough.
  ///
  /// In en, this message translates to:
  /// **'The Breakthrough'**
  String get resetSubflowBreakthrough;

  /// No description provided for @resetMirrorBody.
  ///
  /// In en, this message translates to:
  /// **'Current reality, possible futures, identity'**
  String get resetMirrorBody;

  /// No description provided for @resetVisionBody.
  ///
  /// In en, this message translates to:
  /// **'A good ordinary day, who you want to become, one action this week'**
  String get resetVisionBody;

  /// No description provided for @resetInterruptBody.
  ///
  /// In en, this message translates to:
  /// **'Six short check-ins at moments in your day'**
  String get resetInterruptBody;

  /// No description provided for @resetBreakthroughBody.
  ///
  /// In en, this message translates to:
  /// **'Insights, direction and a plan'**
  String get resetBreakthroughBody;

  /// No description provided for @resetGroupCurrentReality.
  ///
  /// In en, this message translates to:
  /// **'Current reality'**
  String get resetGroupCurrentReality;

  /// No description provided for @resetGroupAntiVision.
  ///
  /// In en, this message translates to:
  /// **'A future you don\'t want'**
  String get resetGroupAntiVision;

  /// No description provided for @resetGroupIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get resetGroupIdentity;

  /// No description provided for @resetGroupVision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get resetGroupVision;

  /// No description provided for @resetGroupInterrupt.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get resetGroupInterrupt;

  /// No description provided for @resetGroupContemplation.
  ///
  /// In en, this message translates to:
  /// **'Contemplation'**
  String get resetGroupContemplation;

  /// No description provided for @resetGroupInsight.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get resetGroupInsight;

  /// No description provided for @resetGroupDirection.
  ///
  /// In en, this message translates to:
  /// **'Direction'**
  String get resetGroupDirection;

  /// No description provided for @resetGroupPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get resetGroupPlan;

  /// No description provided for @resetCountAnswered.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} answered'**
  String resetCountAnswered(int answered, int total);

  /// No description provided for @resetCountAnsweredSkipped.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} answered, {skipped} skipped'**
  String resetCountAnsweredSkipped(int answered, int total, int skipped);

  /// No description provided for @resetCountNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started yet'**
  String get resetCountNotStarted;

  /// No description provided for @resetRingLabel.
  ///
  /// In en, this message translates to:
  /// **'{answered}/{total}'**
  String resetRingLabel(int answered, int total);

  /// No description provided for @resetOpenPhase.
  ///
  /// In en, this message translates to:
  /// **'Open the {phase} questions'**
  String resetOpenPhase(String phase);

  /// No description provided for @resetStateAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get resetStateAnswered;

  /// No description provided for @resetStateSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get resetStateSkipped;

  /// No description provided for @resetStateOpen.
  ///
  /// In en, this message translates to:
  /// **'Not answered yet'**
  String get resetStateOpen;

  /// No description provided for @resetStateCurrent.
  ///
  /// In en, this message translates to:
  /// **'You are here'**
  String get resetStateCurrent;

  /// No description provided for @resetCheckinTime.
  ///
  /// In en, this message translates to:
  /// **'Check-in · {time}'**
  String resetCheckinTime(String time);

  /// No description provided for @resetOptionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional contemplations'**
  String get resetOptionalTitle;

  /// No description provided for @resetOptionalBody.
  ///
  /// In en, this message translates to:
  /// **'Three extra questions for a quiet moment. They don\'t count toward your progress.'**
  String get resetOptionalBody;

  /// No description provided for @resetOptionalChip.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get resetOptionalChip;

  /// No description provided for @resetPastTitle.
  ///
  /// In en, this message translates to:
  /// **'Past resets'**
  String get resetPastTitle;

  /// No description provided for @resetPastStarted.
  ///
  /// In en, this message translates to:
  /// **'Started {date}'**
  String resetPastStarted(String date);

  /// No description provided for @resetPastFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished {date}'**
  String resetPastFinished(String date);

  /// No description provided for @resetPastUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Not finished'**
  String get resetPastUnfinished;

  /// No description provided for @resetPastAnswerCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No answers} =1{1 answer} other{{count} answers}}'**
  String resetPastAnswerCount(int count);

  /// No description provided for @resetPastScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Past reset'**
  String get resetPastScreenTitle;

  /// No description provided for @resetPastReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only: this is how you answered then. Your current reset is separate.'**
  String get resetPastReadOnly;

  /// No description provided for @resetPastLeftOpen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question was left open.} other{{count} questions were left open.}}'**
  String resetPastLeftOpen(int count);

  /// No description provided for @resetPastEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing was written in this reset.'**
  String get resetPastEmpty;

  /// No description provided for @resetPastMissing.
  ///
  /// In en, this message translates to:
  /// **'This reset isn\'t available any more.'**
  String get resetPastMissing;

  /// No description provided for @resetNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new reset'**
  String get resetNewTitle;

  /// No description provided for @resetNewBody.
  ///
  /// In en, this message translates to:
  /// **'Want to go through it again? Start fresh: this reset stays readable under Past resets.'**
  String get resetNewBody;

  /// No description provided for @resetNewConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new reset?'**
  String get resetNewConfirmTitle;

  /// No description provided for @resetNewConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your current answers are kept as a past reset you can read at any time. The new reset starts empty. Your Compass, quests and journal don\'t change.'**
  String get resetNewConfirmBody;

  /// No description provided for @resetNewConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Start new reset'**
  String get resetNewConfirmAction;

  /// No description provided for @resetNewStarted.
  ///
  /// In en, this message translates to:
  /// **'A new reset has started. Your earlier one is under Past resets.'**
  String get resetNewStarted;

  /// No description provided for @resetQuestionOf.
  ///
  /// In en, this message translates to:
  /// **'Question {n} of {total}'**
  String resetQuestionOf(int n, int total);

  /// No description provided for @resetPauseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause and return to the Reset'**
  String get resetPauseTooltip;

  /// No description provided for @resetJumpTooltip.
  ///
  /// In en, this message translates to:
  /// **'Jump to a question'**
  String get resetJumpTooltip;

  /// No description provided for @resetJump.
  ///
  /// In en, this message translates to:
  /// **'Jump'**
  String get resetJump;

  /// No description provided for @resetJumpTitle.
  ///
  /// In en, this message translates to:
  /// **'{phase} questions'**
  String resetJumpTitle(String phase);

  /// No description provided for @resetSofter.
  ///
  /// In en, this message translates to:
  /// **'Softer wording'**
  String get resetSofter;

  /// No description provided for @resetSofterHint.
  ///
  /// In en, this message translates to:
  /// **'The same question, asked more gently.'**
  String get resetSofterHint;

  /// No description provided for @resetHelpLink.
  ///
  /// In en, this message translates to:
  /// **'What does this mean?'**
  String get resetHelpLink;

  /// No description provided for @resetExampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Example — not a right answer'**
  String get resetExampleTitle;

  /// No description provided for @resetAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get resetAnswerLabel;

  /// No description provided for @resetAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Write as much or as little as you like.'**
  String get resetAnswerHint;

  /// No description provided for @resetSkippedNote.
  ///
  /// In en, this message translates to:
  /// **'You skipped this one. Write something whenever you like, or leave it.'**
  String get resetSkippedNote;

  /// No description provided for @resetSaveContinue.
  ///
  /// In en, this message translates to:
  /// **'Save & continue'**
  String get resetSaveContinue;

  /// No description provided for @resetSaveFinish.
  ///
  /// In en, this message translates to:
  /// **'Save & finish'**
  String get resetSaveFinish;

  /// No description provided for @resetSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get resetSkip;

  /// No description provided for @resetPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get resetPause;

  /// No description provided for @resetHeavyLink.
  ///
  /// In en, this message translates to:
  /// **'Feeling heavy?'**
  String get resetHeavyLink;

  /// No description provided for @resetHeavyTitle.
  ///
  /// In en, this message translates to:
  /// **'This can be a lot'**
  String get resetHeavyTitle;

  /// No description provided for @resetHeavyBody.
  ///
  /// In en, this message translates to:
  /// **'Some questions touch tender places. You decide how deep to go: soften the wording, skip, or stop here. Your words are saved.'**
  String get resetHeavyBody;

  /// No description provided for @resetHeavySofter.
  ///
  /// In en, this message translates to:
  /// **'Switch to softer wording'**
  String get resetHeavySofter;

  /// No description provided for @resetHeavySkip.
  ///
  /// In en, this message translates to:
  /// **'Skip this question'**
  String get resetHeavySkip;

  /// No description provided for @resetHeavyPause.
  ///
  /// In en, this message translates to:
  /// **'Take a pause'**
  String get resetHeavyPause;

  /// No description provided for @resetHeavySupport.
  ///
  /// In en, this message translates to:
  /// **'Support and safety'**
  String get resetHeavySupport;

  /// No description provided for @resetHeavyCrisis.
  ///
  /// In en, this message translates to:
  /// **'Cartharise is not therapy. If you feel unsafe, contact local emergency services or a crisis line now.'**
  String get resetHeavyCrisis;

  /// No description provided for @resetPromptMissing.
  ///
  /// In en, this message translates to:
  /// **'This question isn\'t available.'**
  String get resetPromptMissing;

  /// No description provided for @resetCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset complete'**
  String get resetCompleteTitle;

  /// No description provided for @resetCompleteLead.
  ///
  /// In en, this message translates to:
  /// **'One day can bring clarity; the rest is practice.'**
  String get resetCompleteLead;

  /// No description provided for @resetCompleteCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'What you created'**
  String get resetCompleteCreatedTitle;

  /// No description provided for @resetCompleteAnswers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No answers written} =1{1 answer written} other{{count} answers written}}'**
  String resetCompleteAnswers(int count);

  /// No description provided for @resetCompleteSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question skipped} other{{count} questions skipped}}'**
  String resetCompleteSkipped(int count);

  /// No description provided for @resetCompletePhaseLine.
  ///
  /// In en, this message translates to:
  /// **'{phase}: {answered} of {total} answered'**
  String resetCompletePhaseLine(String phase, int answered, int total);

  /// No description provided for @resetCompleteVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your vision, in your words'**
  String get resetCompleteVisionTitle;

  /// No description provided for @resetCompleteOpen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 core question is still open. You can return to it from the Reset tab at any time.} other{{count} core questions are still open. You can return to them from the Reset tab at any time.}}'**
  String resetCompleteOpen(int count);

  /// No description provided for @resetCompleteCompassBody.
  ///
  /// In en, this message translates to:
  /// **'Your evening answers can become the first draft of your Life Compass. You choose what to copy, and nothing you already wrote is overwritten.'**
  String get resetCompleteCompassBody;

  /// No description provided for @resetCompleteBuildCompass.
  ///
  /// In en, this message translates to:
  /// **'Build your Compass'**
  String get resetCompleteBuildCompass;

  /// No description provided for @resetCompleteLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get resetCompleteLater;

  /// No description provided for @todayGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}.'**
  String todayGreetingMorning(String name);

  /// No description provided for @todayGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}.'**
  String todayGreetingAfternoon(String name);

  /// No description provided for @todayGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}.'**
  String todayGreetingEvening(String name);

  /// Used in the greeting when the user gave no name.
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get todayDefaultName;

  /// No description provided for @todaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Clarity today. Progress tomorrow.'**
  String get todaySubtitle;

  /// No description provided for @todayNextEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your next step'**
  String get todayNextEyebrow;

  /// No description provided for @todayNextStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Begin the morning reflection'**
  String get todayNextStartTitle;

  /// No description provided for @todayNextStartBody.
  ///
  /// In en, this message translates to:
  /// **'{count} short questions, one at a time. Skip any of them, pause whenever you like.'**
  String todayNextStartBody(int count);

  /// No description provided for @todayNextStartAction.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get todayNextStartAction;

  /// No description provided for @todayNextLessonsAction.
  ///
  /// In en, this message translates to:
  /// **'Learn the {count} ideas (optional)'**
  String todayNextLessonsAction(int count);

  /// No description provided for @todayNextResumeTitle.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, morning{Continue the morning reflection} daytime{Continue the daytime check-ins} evening{Continue the evening reflection} other{Continue your reset}}'**
  String todayNextResumeTitle(String phase);

  /// No description provided for @todayNextResumeBody.
  ///
  /// In en, this message translates to:
  /// **'Next: {title}'**
  String todayNextResumeBody(String title);

  /// No description provided for @todayNextResumePosition.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, morning{Morning} daytime{Daytime} evening{Evening} other{Reset}} · question {ordinal} of {total}'**
  String todayNextResumePosition(String phase, int ordinal, int total);

  /// No description provided for @todayNextResumeAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get todayNextResumeAction;

  /// No description provided for @todayNextSeeReset.
  ///
  /// In en, this message translates to:
  /// **'See the whole reset'**
  String get todayNextSeeReset;

  /// No description provided for @todayNextCompassTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your Compass'**
  String get todayNextCompassTitle;

  /// No description provided for @todayNextCompassImportBody.
  ///
  /// In en, this message translates to:
  /// **'Your evening answers can fill the empty parts of your Life Compass. You choose what goes in.'**
  String get todayNextCompassImportBody;

  /// No description provided for @todayNextCompassManualBody.
  ///
  /// In en, this message translates to:
  /// **'Write your vision, a one-month project and a few daily levers in your own words.'**
  String get todayNextCompassManualBody;

  /// No description provided for @todayNextCompassImportAction.
  ///
  /// In en, this message translates to:
  /// **'Review your answers'**
  String get todayNextCompassImportAction;

  /// No description provided for @todayNextLeversTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn your levers into quests'**
  String get todayNextLeversTitle;

  /// No description provided for @todayNextLeversBody.
  ///
  /// In en, this message translates to:
  /// **'Your daily levers can become a few small actions to check off. You approve each one.'**
  String get todayNextLeversBody;

  /// No description provided for @todayNextLeversAction.
  ///
  /// In en, this message translates to:
  /// **'Choose quests'**
  String get todayNextLeversAction;

  /// No description provided for @todayNextReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Look back on your week'**
  String get todayNextReviewTitle;

  /// No description provided for @todayNextReviewBody.
  ///
  /// In en, this message translates to:
  /// **'Three short questions: what went well, what got in the way, and what to try next.'**
  String get todayNextReviewBody;

  /// No description provided for @todayNextReviewAction.
  ///
  /// In en, this message translates to:
  /// **'Start a weekly review'**
  String get todayNextReviewAction;

  /// No description provided for @todayNextJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get todayNextJournalTitle;

  /// No description provided for @todayNextJournalBody.
  ///
  /// In en, this message translates to:
  /// **'A few lines about today: what you noticed, what you tried, what you learned.'**
  String get todayNextJournalBody;

  /// No description provided for @todayNextJournalAction.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get todayNextJournalAction;

  /// No description provided for @todayOpenJournal.
  ///
  /// In en, this message translates to:
  /// **'Open the journal'**
  String get todayOpenJournal;

  /// No description provided for @todayOpenCompass.
  ///
  /// In en, this message translates to:
  /// **'Open Compass'**
  String get todayOpenCompass;

  /// No description provided for @todayFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s focus'**
  String get todayFocusTitle;

  /// No description provided for @todayFocusEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No quests for today'**
  String get todayFocusEmptyTitle;

  /// No description provided for @todayFocusEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Quests are small actions you choose yourself. Add one whenever you\'re ready.'**
  String get todayFocusEmptyBody;

  /// No description provided for @todayFocusAdd.
  ///
  /// In en, this message translates to:
  /// **'Add a quest'**
  String get todayFocusAdd;

  /// No description provided for @todayFocusSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all {count} quests'**
  String todayFocusSeeAll(int count);

  /// No description provided for @todayQuestMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark \'{title}\' done'**
  String todayQuestMarkDone(String title);

  /// No description provided for @todayQuestDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get todayQuestDaily;

  /// No description provided for @todayJourneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey'**
  String get todayJourneyTitle;

  /// No description provided for @todayJourneyWritten.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} reflections written'**
  String todayJourneyWritten(int answered, int total);

  /// No description provided for @todayJourneyNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Your reset hasn\'t started yet. It\'s ready whenever you are.'**
  String get todayJourneyNotStarted;

  /// No description provided for @todayJourneyInProgress.
  ///
  /// In en, this message translates to:
  /// **'Your reset is waiting where you left it.'**
  String get todayJourneyInProgress;

  /// No description provided for @todayJourneyAllTouched.
  ///
  /// In en, this message translates to:
  /// **'Every reflection is written or set aside. You can revisit any of them.'**
  String get todayJourneyAllTouched;

  /// No description provided for @todayJourneyCompleted.
  ///
  /// In en, this message translates to:
  /// **'You finished this reset. Your answers stay here to revisit.'**
  String get todayJourneyCompleted;

  /// No description provided for @todayJourneyOpenReset.
  ///
  /// In en, this message translates to:
  /// **'Open the reset'**
  String get todayJourneyOpenReset;

  /// No description provided for @todayPhaseProgress.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, morning{Morning} daytime{Daytime} evening{Evening} other{Reset}} {answered}/{total}'**
  String todayPhaseProgress(String phase, int answered, int total);

  /// No description provided for @todayPhaseProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{phase, select, morning{Morning} daytime{Daytime} evening{Evening} other{Reset}}: {answered} of {total} written'**
  String todayPhaseProgressLabel(String phase, int answered, int total);

  /// No description provided for @todayPathDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of 30'**
  String todayPathDay(int day);

  /// No description provided for @todayPathStage.
  ///
  /// In en, this message translates to:
  /// **'Thirty-day path · {stage, select, observe{Observe} experiment{Experiment} build{Build} adjust{Adjust} other{Path}}'**
  String todayPathStage(String stage);

  /// No description provided for @todayPathOpen.
  ///
  /// In en, this message translates to:
  /// **'Open day {day}'**
  String todayPathOpen(int day);

  /// No description provided for @todayDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your direction'**
  String get todayDirectionTitle;

  /// No description provided for @todayDirectionVision.
  ///
  /// In en, this message translates to:
  /// **'Vision'**
  String get todayDirectionVision;

  /// No description provided for @todayDirectionMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get todayDirectionMonth;

  /// No description provided for @todayDirectionNoVision.
  ///
  /// In en, this message translates to:
  /// **'No vision written yet.'**
  String get todayDirectionNoVision;

  /// No description provided for @todayDirectionNoMonth.
  ///
  /// In en, this message translates to:
  /// **'No month project yet.'**
  String get todayDirectionNoMonth;

  /// No description provided for @todayDirectionEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Compass is empty'**
  String get todayDirectionEmptyTitle;

  /// No description provided for @todayDirectionEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'It holds your vision, a one-month project and a few daily levers, in your own words.'**
  String get todayDirectionEmptyBody;

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
