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
  /// **'Your words are still here. Retry, or export a copy.'**
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
  /// **'Cartharise couldn\'t read its file. Nothing was deleted.'**
  String get bootLoadErrorBody;

  /// No description provided for @bootLoadErrorHint.
  ///
  /// In en, this message translates to:
  /// **'Try again. If it keeps failing, free up some storage.'**
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
  /// **'The unreadable file is set aside, not deleted. Cartharise starts empty.'**
  String get bootStartFreshConfirmBody;

  /// Where the user's data lives (onboarding privacy page, You › Your data). Must stay true: Android backups are off in the manifest, iOS excludes the data folder from backup.
  ///
  /// In en, this message translates to:
  /// **'Only on this phone. Not synced, not in phone or cloud backups, and not encrypted by Cartharise. Deleting the app or your data erases it.'**
  String get storageTransparency;

  /// No description provided for @storageErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage problem'**
  String get storageErrorTitle;

  /// No description provided for @storageErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Can\'t save on this phone right now. Your words stay on screen until you leave.'**
  String get storageErrorBody;

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

  /// Android notification channel name (system settings).
  ///
  /// In en, this message translates to:
  /// **'Check-in reminders'**
  String get reminderChannelName;

  /// Android notification channel description (system settings).
  ///
  /// In en, this message translates to:
  /// **'Optional daytime check-ins from your Cartharise reset.'**
  String get reminderChannelDescription;

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
  /// **'Seven ideas behind the reset. Optional, any order.'**
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
  /// **'In Cartharise\'s words, from “{title}” by {author}. Independent app.'**
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

  /// No description provided for @campaignSection.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get campaignSection;

  /// No description provided for @campaignSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your direction, played as a game.'**
  String get campaignSubtitle;

  /// No description provided for @campaignStatusEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Your campaign'**
  String get campaignStatusEyebrow;

  /// No description provided for @campaignLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · {xp} XP'**
  String campaignLevel(int level, int xp);

  /// No description provided for @campaignXpNote.
  ///
  /// In en, this message translates to:
  /// **'XP counts what you do, never your worth. Rest costs nothing.'**
  String get campaignXpNote;

  /// No description provided for @campaignXpHow.
  ///
  /// In en, this message translates to:
  /// **'How XP is earned'**
  String get campaignXpHow;

  /// No description provided for @campaignXpRuleReflection.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP for each reset question you answer (once per question)'**
  String campaignXpRuleReflection(int xp);

  /// No description provided for @campaignXpRuleQuest.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP for each quest you complete, counting up to {max} a day'**
  String campaignXpRuleQuest(int xp, int max);

  /// No description provided for @campaignXpRulePath.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP for each day of the 30-day path you write'**
  String campaignXpRulePath(int xp);

  /// No description provided for @campaignXpRuleAttempt.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP for each day you record an attempt at your monthly project'**
  String campaignXpRuleAttempt(int xp);

  /// No description provided for @campaignXpRuleReview.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP for each weekly review'**
  String campaignXpRuleReview(int xp);

  /// No description provided for @campaignXpRulesNote.
  ///
  /// In en, this message translates to:
  /// **'XP ignores what you write and how you feel. Skipping and resting never cost XP. Every {step} XP is a new level.'**
  String campaignXpRulesNote(int step);

  /// No description provided for @campaignActOne.
  ///
  /// In en, this message translates to:
  /// **'Act I · The one-day awakening'**
  String get campaignActOne;

  /// No description provided for @campaignChaptersExplored.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} chapters explored'**
  String campaignChaptersExplored(int count, int total);

  /// No description provided for @campaignChapterNumber.
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String campaignChapterNumber(int number);

  /// No description provided for @campaignChapterTerrain.
  ///
  /// In en, this message translates to:
  /// **'See the terrain'**
  String get campaignChapterTerrain;

  /// No description provided for @campaignChapterTerrainArea.
  ///
  /// In en, this message translates to:
  /// **'Current reality'**
  String get campaignChapterTerrainArea;

  /// No description provided for @campaignChapterPattern.
  ///
  /// In en, this message translates to:
  /// **'Find the pattern'**
  String get campaignChapterPattern;

  /// No description provided for @campaignChapterPatternArea.
  ///
  /// In en, this message translates to:
  /// **'Anti-vision and identity'**
  String get campaignChapterPatternArea;

  /// No description provided for @campaignChapterBanner.
  ///
  /// In en, this message translates to:
  /// **'Raise your banner'**
  String get campaignChapterBanner;

  /// No description provided for @campaignChapterBannerArea.
  ///
  /// In en, this message translates to:
  /// **'Future vision'**
  String get campaignChapterBannerArea;

  /// No description provided for @campaignChapterAutopilot.
  ///
  /// In en, this message translates to:
  /// **'Break autopilot'**
  String get campaignChapterAutopilot;

  /// No description provided for @campaignChapterAutopilotArea.
  ///
  /// In en, this message translates to:
  /// **'Daytime check-ins'**
  String get campaignChapterAutopilotArea;

  /// No description provided for @campaignChapterPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan the campaign'**
  String get campaignChapterPlan;

  /// No description provided for @campaignChapterPlanArea.
  ///
  /// In en, this message translates to:
  /// **'Evening synthesis'**
  String get campaignChapterPlanArea;

  /// No description provided for @campaignChapterReflections.
  ///
  /// In en, this message translates to:
  /// **'{area} · {count, plural, =1{1 reflection} other{{count} reflections}}'**
  String campaignChapterReflections(String area, int count);

  /// No description provided for @campaignChapterDone.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} written'**
  String campaignChapterDone(int done, int total);

  /// No description provided for @campaignChapterExplored.
  ///
  /// In en, this message translates to:
  /// **'Explored'**
  String get campaignChapterExplored;

  /// No description provided for @campaignChapterExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get campaignChapterExplore;

  /// No description provided for @campaignChapterExploreLabel.
  ///
  /// In en, this message translates to:
  /// **'Explore chapter {number}, {name}'**
  String campaignChapterExploreLabel(int number, String name);

  /// No description provided for @campaignMapTitle.
  ///
  /// In en, this message translates to:
  /// **'The strategist\'s map'**
  String get campaignMapTitle;

  /// No description provided for @campaignMapAntiVision.
  ///
  /// In en, this message translates to:
  /// **'What\'s at stake · Anti-vision'**
  String get campaignMapAntiVision;

  /// No description provided for @campaignMapVision.
  ///
  /// In en, this message translates to:
  /// **'Win condition · Vision'**
  String get campaignMapVision;

  /// No description provided for @campaignMapYear.
  ///
  /// In en, this message translates to:
  /// **'Main campaign · One-year mission'**
  String get campaignMapYear;

  /// No description provided for @campaignMapMonth.
  ///
  /// In en, this message translates to:
  /// **'Monthly boss · One-month project'**
  String get campaignMapMonth;

  /// No description provided for @campaignMapLevers.
  ///
  /// In en, this message translates to:
  /// **'Daily quests · Daily levers'**
  String get campaignMapLevers;

  /// No description provided for @campaignMapBoundaries.
  ///
  /// In en, this message translates to:
  /// **'Rules of engagement · Boundaries'**
  String get campaignMapBoundaries;

  /// No description provided for @campaignMapBoundariesNote.
  ///
  /// In en, this message translates to:
  /// **'The game never rewards giving these up.'**
  String get campaignMapBoundariesNote;

  /// No description provided for @campaignMapEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not written yet.'**
  String get campaignMapEmpty;

  /// No description provided for @campaignMapEdit.
  ///
  /// In en, this message translates to:
  /// **'Build your strategy'**
  String get campaignMapEdit;

  /// No description provided for @campaignMapQuests.
  ///
  /// In en, this message translates to:
  /// **'Open daily quests'**
  String get campaignMapQuests;

  /// No description provided for @campaignBossTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly boss fight'**
  String get campaignBossTitle;

  /// No description provided for @campaignBossBody.
  ///
  /// In en, this message translates to:
  /// **'The boss is a project, never a person. Log what you try.'**
  String get campaignBossBody;

  /// No description provided for @campaignBossNoProject.
  ///
  /// In en, this message translates to:
  /// **'Set a one-month project in your Compass to see it here.'**
  String get campaignBossNoProject;

  /// No description provided for @campaignAttemptLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you actually try?'**
  String get campaignAttemptLabel;

  /// No description provided for @campaignAttemptHint.
  ///
  /// In en, this message translates to:
  /// **'A focus block, a hard message, a first draft…'**
  String get campaignAttemptHint;

  /// No description provided for @campaignAttemptRequired.
  ///
  /// In en, this message translates to:
  /// **'Write a few words about what you tried.'**
  String get campaignAttemptRequired;

  /// No description provided for @campaignLearningLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you learn? (optional)'**
  String get campaignLearningLabel;

  /// No description provided for @campaignLearningHint.
  ///
  /// In en, this message translates to:
  /// **'What worked, what you\'d change.'**
  String get campaignLearningHint;

  /// No description provided for @campaignRecord.
  ///
  /// In en, this message translates to:
  /// **'Record this attempt'**
  String get campaignRecord;

  /// No description provided for @campaignRecorded.
  ///
  /// In en, this message translates to:
  /// **'Attempt recorded.'**
  String get campaignRecorded;

  /// No description provided for @campaignLogTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Battle log} =1{Battle log · 1 attempt} other{Battle log · {count} attempts}}'**
  String campaignLogTitle(int count);

  /// No description provided for @campaignLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No attempts yet. Your first one can be tiny.'**
  String get campaignLogEmpty;

  /// No description provided for @campaignLogLearned.
  ///
  /// In en, this message translates to:
  /// **'Learned: {learning}'**
  String campaignLogLearned(String learning);

  /// No description provided for @campaignLogEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit the attempt from {date}'**
  String campaignLogEditLabel(String date);

  /// No description provided for @campaignAttemptEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit attempt'**
  String get campaignAttemptEditTitle;

  /// No description provided for @campaignAttemptSave.
  ///
  /// In en, this message translates to:
  /// **'Save attempt'**
  String get campaignAttemptSave;

  /// No description provided for @campaignAttemptDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete attempt'**
  String get campaignAttemptDelete;

  /// No description provided for @campaignAttemptDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this attempt?'**
  String get campaignAttemptDeleteTitle;

  /// No description provided for @campaignAttemptDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed. This can\'t be undone.'**
  String get campaignAttemptDeleteBody;

  /// No description provided for @campaignAttemptDeleted.
  ///
  /// In en, this message translates to:
  /// **'Attempt deleted'**
  String get campaignAttemptDeleted;

  /// No description provided for @campaignAchievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Achievements from the article'**
  String get campaignAchievementsTitle;

  /// No description provided for @campaignAchievementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earned by reflecting, trying or doing. Never by what you write.'**
  String get campaignAchievementsSubtitle;

  /// No description provided for @campaignAchievementsCount.
  ///
  /// In en, this message translates to:
  /// **'{earned} of {total} earned'**
  String campaignAchievementsCount(int earned, int total);

  /// No description provided for @campaignNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get campaignNotYet;

  /// No description provided for @campaignAchievementObserver.
  ///
  /// In en, this message translates to:
  /// **'The Observer'**
  String get campaignAchievementObserver;

  /// No description provided for @campaignAchievementObserverBody.
  ///
  /// In en, this message translates to:
  /// **'Answer every present-reality question in one reset, or try one of its experiments'**
  String get campaignAchievementObserverBody;

  /// No description provided for @campaignAchievementPathfinder.
  ///
  /// In en, this message translates to:
  /// **'The Pathfinder'**
  String get campaignAchievementPathfinder;

  /// No description provided for @campaignAchievementPathfinderBody.
  ///
  /// In en, this message translates to:
  /// **'Answer every anti-vision and identity question in one reset, or try one of its experiments'**
  String get campaignAchievementPathfinderBody;

  /// No description provided for @campaignAchievementVisionary.
  ///
  /// In en, this message translates to:
  /// **'The Visionary'**
  String get campaignAchievementVisionary;

  /// No description provided for @campaignAchievementVisionaryBody.
  ///
  /// In en, this message translates to:
  /// **'Answer every future-vision question in one reset, or try one of its experiments'**
  String get campaignAchievementVisionaryBody;

  /// No description provided for @campaignAchievementWatchful.
  ///
  /// In en, this message translates to:
  /// **'The Watchful'**
  String get campaignAchievementWatchful;

  /// No description provided for @campaignAchievementWatchfulBody.
  ///
  /// In en, this message translates to:
  /// **'Answer every daytime check-in in one reset, or try one of its experiments'**
  String get campaignAchievementWatchfulBody;

  /// No description provided for @campaignAchievementStrategist.
  ///
  /// In en, this message translates to:
  /// **'The Strategist'**
  String get campaignAchievementStrategist;

  /// No description provided for @campaignAchievementStrategistBody.
  ///
  /// In en, this message translates to:
  /// **'Answer every evening-planning question in one reset, or try one of its experiments'**
  String get campaignAchievementStrategistBody;

  /// No description provided for @campaignAchievementPractitioner.
  ///
  /// In en, this message translates to:
  /// **'The Practitioner'**
  String get campaignAchievementPractitioner;

  /// No description provided for @campaignAchievementPractitionerBody.
  ///
  /// In en, this message translates to:
  /// **'Complete a real-world quest'**
  String get campaignAchievementPractitionerBody;

  /// No description provided for @campaignAchievementChallenger.
  ///
  /// In en, this message translates to:
  /// **'The Challenger'**
  String get campaignAchievementChallenger;

  /// No description provided for @campaignAchievementChallengerBody.
  ///
  /// In en, this message translates to:
  /// **'Record a first attempt at your monthly project'**
  String get campaignAchievementChallengerBody;

  /// No description provided for @campaignActTwo.
  ///
  /// In en, this message translates to:
  /// **'Act II · The 30-day becoming'**
  String get campaignActTwo;

  /// No description provided for @campaignActTwoBody.
  ///
  /// In en, this message translates to:
  /// **'A direction, not a deadline. Keep the small steps going.'**
  String get campaignActTwoBody;

  /// No description provided for @campaignStatQuests.
  ///
  /// In en, this message translates to:
  /// **'Quests completed'**
  String get campaignStatQuests;

  /// No description provided for @campaignStatPath.
  ///
  /// In en, this message translates to:
  /// **'30-day notes written'**
  String get campaignStatPath;

  /// No description provided for @campaignStatAttempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts recorded'**
  String get campaignStatAttempts;

  /// No description provided for @campaignContinuePath.
  ///
  /// In en, this message translates to:
  /// **'Continue the 30-day path'**
  String get campaignContinuePath;

  /// No description provided for @campaignReadArticle.
  ///
  /// In en, this message translates to:
  /// **'Read the article'**
  String get campaignReadArticle;

  /// No description provided for @campaignNote.
  ///
  /// In en, this message translates to:
  /// **'XP, levels and achievements are Cartharise additions, not part of the article. Turn them off in You.'**
  String get campaignNote;

  /// No description provided for @campaignTodayOpen.
  ///
  /// In en, this message translates to:
  /// **'Open the Campaign'**
  String get campaignTodayOpen;

  /// No description provided for @campaignSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'The Campaign'**
  String get campaignSettingTitle;

  /// No description provided for @campaignSettingHint.
  ///
  /// In en, this message translates to:
  /// **'XP, levels and achievements. Your battle log is kept if you turn it off.'**
  String get campaignSettingHint;

  /// No description provided for @campaignWaypoint.
  ///
  /// In en, this message translates to:
  /// **'{place, select, carthage{Carthage} newCarthage{New Carthage} ebro{the Ebro} pyrenees{the Pyrenees} rhone{the Rhône} alps{the Alps} italy{Italy} other{the road}}'**
  String campaignWaypoint(String place);

  /// No description provided for @campaignRouteHere.
  ///
  /// In en, this message translates to:
  /// **'You\'re at {place}'**
  String campaignRouteHere(String place);

  /// No description provided for @campaignRouteNext.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to {place}'**
  String campaignRouteNext(int xp, String place);

  /// No description provided for @campaignRouteEnd.
  ///
  /// In en, this message translates to:
  /// **'You\'ve crossed into Italy. The campaign goes on.'**
  String get campaignRouteEnd;

  /// No description provided for @campaignRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Hannibal\'s route: {place}, stop {stop} of {total}.'**
  String campaignRouteLabel(String place, int stop, int total);

  /// No description provided for @campaignBossStrength.
  ///
  /// In en, this message translates to:
  /// **'Boss strength'**
  String get campaignBossStrength;

  /// No description provided for @campaignBossMilestones.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} milestones reached'**
  String campaignBossMilestones(int done, int total);

  /// No description provided for @campaignBossBeaten.
  ///
  /// In en, this message translates to:
  /// **'Every milestone reached. Boss beaten.'**
  String get campaignBossBeaten;

  /// No description provided for @campaignBossNoMilestones.
  ///
  /// In en, this message translates to:
  /// **'Add milestones to your project to weaken the boss.'**
  String get campaignBossNoMilestones;

  /// No description provided for @campaignBossOpenProject.
  ///
  /// In en, this message translates to:
  /// **'Open project'**
  String get campaignBossOpenProject;

  /// No description provided for @campaignNextAchievement.
  ///
  /// In en, this message translates to:
  /// **'Next: {name} · {how}'**
  String campaignNextAchievement(String name, String how);

  /// No description provided for @campaignToastXp.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String campaignToastXp(int xp);

  /// No description provided for @campaignToastAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement earned: {name}'**
  String campaignToastAchievement(String name);

  /// No description provided for @campaignStrategistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Create an avatar to walk the route with you.'**
  String get campaignStrategistEmpty;

  /// No description provided for @campaignExtrasCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} extras unlocked'**
  String campaignExtrasCount(int count, int total);

  /// No description provided for @campaignExtrasAll.
  ///
  /// In en, this message translates to:
  /// **'Every extra unlocked.'**
  String get campaignExtrasAll;

  /// No description provided for @campaignQuestXp.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String campaignQuestXp(int xp);

  /// No description provided for @campaignQuestXpLabel.
  ///
  /// In en, this message translates to:
  /// **'Earns {xp} XP when done'**
  String campaignQuestXpLabel(int xp);

  /// No description provided for @campaignXpRuleExperiment.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP for each new experiment you try (once each)'**
  String campaignXpRuleExperiment(int xp);

  /// No description provided for @campaignNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get campaignNoticeTitle;

  /// No description provided for @campaignNoticeLine.
  ///
  /// In en, this message translates to:
  /// **'A question or idea to look at again.'**
  String get campaignNoticeLine;

  /// No description provided for @campaignTryTitle.
  ///
  /// In en, this message translates to:
  /// **'Try'**
  String get campaignTryTitle;

  /// No description provided for @campaignTryLine.
  ///
  /// In en, this message translates to:
  /// **'A tiny experiment for real life.'**
  String get campaignTryLine;

  /// No description provided for @campaignYoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get campaignYoursTitle;

  /// No description provided for @campaignYoursLine.
  ///
  /// In en, this message translates to:
  /// **'Your avatar and motto.'**
  String get campaignYoursLine;

  /// No description provided for @campaignYoursPicks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reward pick to choose} other{{count} reward picks to choose}}'**
  String campaignYoursPicks(int count);

  /// No description provided for @campaignLinkRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get campaignLinkRoute;

  /// No description provided for @campaignLinkChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get campaignLinkChapters;

  /// No description provided for @campaignLinkBattleLog.
  ///
  /// In en, this message translates to:
  /// **'Battle log'**
  String get campaignLinkBattleLog;

  /// No description provided for @campaignLinkBattleLogDraft.
  ///
  /// In en, this message translates to:
  /// **'Battle log · draft kept'**
  String get campaignLinkBattleLogDraft;

  /// No description provided for @campaignLinkCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get campaignLinkCollection;

  /// No description provided for @campaignRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'The route'**
  String get campaignRouteTitle;

  /// No description provided for @campaignRouteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One stop per level. Rest never moves you back.'**
  String get campaignRouteSubtitle;

  /// No description provided for @campaignRouteStops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get campaignRouteStops;

  /// No description provided for @campaignRouteStopHere.
  ///
  /// In en, this message translates to:
  /// **'You\'re here'**
  String get campaignRouteStopHere;

  /// No description provided for @campaignRouteStopReached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get campaignRouteStopReached;

  /// No description provided for @campaignRouteStopAhead.
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to go'**
  String campaignRouteStopAhead(int xp);

  /// No description provided for @campaignChaptersTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get campaignChaptersTitle;

  /// No description provided for @campaignChapterTried.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 experiment tried} other{{count} experiments tried}}'**
  String campaignChapterTried(int count);

  /// No description provided for @campaignChapterTry.
  ///
  /// In en, this message translates to:
  /// **'Try one'**
  String get campaignChapterTry;

  /// No description provided for @campaignChapterTryLabel.
  ///
  /// In en, this message translates to:
  /// **'Try an experiment from chapter {number}, {name}'**
  String campaignChapterTryLabel(int number, String name);

  /// No description provided for @campaignBattleLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Battle log'**
  String get campaignBattleLogTitle;

  /// No description provided for @campaignAttemptDraftNote.
  ///
  /// In en, this message translates to:
  /// **'Kept on this phone as you type.'**
  String get campaignAttemptDraftNote;

  /// No description provided for @campaignAttemptNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Not saved on this phone yet. Your words are still here. Retry at the top.'**
  String get campaignAttemptNotSaved;

  /// No description provided for @campaignNotSavedYet.
  ///
  /// In en, this message translates to:
  /// **'Not saved on this phone yet. Retry at the top.'**
  String get campaignNotSavedYet;

  /// No description provided for @campaignCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get campaignCollectionTitle;

  /// No description provided for @campaignCollectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What you tried, earned and chose.'**
  String get campaignCollectionSubtitle;

  /// No description provided for @campaignCollectionTried.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Experiments tried} =1{1 experiment tried} other{{count} experiments tried}}'**
  String campaignCollectionTried(int count);

  /// No description provided for @campaignCollectionTriedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing tried yet. Try has small experiments.'**
  String get campaignCollectionTriedEmpty;

  /// No description provided for @campaignTryOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Try'**
  String get campaignTryOpen;

  /// No description provided for @campaignExperimentUnknown.
  ///
  /// In en, this message translates to:
  /// **'An experiment'**
  String get campaignExperimentUnknown;

  /// No description provided for @campaignTriedOn.
  ///
  /// In en, this message translates to:
  /// **'Tried {date}'**
  String campaignTriedOn(String date);

  /// No description provided for @campaignTriedEditLabel.
  ///
  /// In en, this message translates to:
  /// **'Edit the note from {date}'**
  String campaignTriedEditLabel(String date);

  /// No description provided for @campaignTriedSave.
  ///
  /// In en, this message translates to:
  /// **'Save note'**
  String get campaignTriedSave;

  /// No description provided for @campaignTriedRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove this try'**
  String get campaignTriedRemove;

  /// No description provided for @campaignTriedRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this try?'**
  String get campaignTriedRemoveTitle;

  /// No description provided for @campaignTriedRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'It leaves your Collection, with its note.'**
  String get campaignTriedRemoveBody;

  /// No description provided for @campaignTriedRemoved.
  ///
  /// In en, this message translates to:
  /// **'Try removed'**
  String get campaignTriedRemoved;

  /// No description provided for @campaignTriedUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your change?'**
  String get campaignTriedUnsavedTitle;

  /// No description provided for @campaignTriedUnsavedBody.
  ///
  /// In en, this message translates to:
  /// **'The note was changed but not saved.'**
  String get campaignTriedUnsavedBody;

  /// No description provided for @campaignTriedDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get campaignTriedDiscard;

  /// No description provided for @campaignEarnedByReflecting.
  ///
  /// In en, this message translates to:
  /// **'Earned by reflecting'**
  String get campaignEarnedByReflecting;

  /// No description provided for @campaignEarnedByTrying.
  ///
  /// In en, this message translates to:
  /// **'Earned by trying'**
  String get campaignEarnedByTrying;

  /// Under an achievement earned by a Playground experiment; {experiment} is its title.
  ///
  /// In en, this message translates to:
  /// **'Earned by trying: {experiment}'**
  String campaignEarnedByTryingWhat(String experiment);

  /// No description provided for @campaignEarnedByDoing.
  ///
  /// In en, this message translates to:
  /// **'Earned by doing'**
  String get campaignEarnedByDoing;

  /// No description provided for @campaignCollectionExtras.
  ///
  /// In en, this message translates to:
  /// **'Extras chosen'**
  String get campaignCollectionExtras;

  /// No description provided for @campaignCollectionExtrasEmpty.
  ///
  /// In en, this message translates to:
  /// **'No extras chosen yet.'**
  String get campaignCollectionExtrasEmpty;

  /// No description provided for @campaignTryScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small experiments. Nothing joins your tasks unless you add it.'**
  String get campaignTryScreenSubtitle;

  /// No description provided for @campaignTryMinutes.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min'**
  String campaignTryMinutes(int minutes);

  /// No description provided for @campaignTryXpLabel.
  ///
  /// In en, this message translates to:
  /// **'Earns {xp} XP the first time'**
  String campaignTryXpLabel(int xp);

  /// No description provided for @campaignTryStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {number}: {step}'**
  String campaignTryStepLabel(int number, String step);

  /// No description provided for @campaignTryNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'A note (optional)'**
  String get campaignTryNoteLabel;

  /// No description provided for @campaignTryNoteHint.
  ///
  /// In en, this message translates to:
  /// **'How did it go? One line is plenty.'**
  String get campaignTryNoteHint;

  /// No description provided for @campaignTryDone.
  ///
  /// In en, this message translates to:
  /// **'I tried it'**
  String get campaignTryDone;

  /// No description provided for @campaignTryRecorded.
  ///
  /// In en, this message translates to:
  /// **'Saved to your Collection.'**
  String get campaignTryRecorded;

  /// No description provided for @campaignTryAddTask.
  ///
  /// In en, this message translates to:
  /// **'Add to my tasks'**
  String get campaignTryAddTask;

  /// No description provided for @campaignTryAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your tasks.'**
  String get campaignTryAdded;

  /// No description provided for @campaignTryAlreadyTask.
  ///
  /// In en, this message translates to:
  /// **'Already in your tasks.'**
  String get campaignTryAlreadyTask;

  /// No description provided for @campaignTryOpenTasks.
  ///
  /// In en, this message translates to:
  /// **'Open tasks'**
  String get campaignTryOpenTasks;

  /// No description provided for @campaignTryPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get campaignTryPrevious;

  /// No description provided for @campaignTryPosition.
  ///
  /// In en, this message translates to:
  /// **'{index} of {total}'**
  String campaignTryPosition(int index, int total);

  /// No description provided for @campaignTryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No experiments here yet.'**
  String get campaignTryEmpty;

  /// No description provided for @campaignNoticeScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick one. Each opens a question or a lesson.'**
  String get campaignNoticeScreenSubtitle;

  /// No description provided for @campaignNoticeKindPrompt.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get campaignNoticeKindPrompt;

  /// No description provided for @campaignNoticeKindLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get campaignNoticeKindLesson;

  /// No description provided for @campaignNoticeOpens.
  ///
  /// In en, this message translates to:
  /// **'Opens: {title}'**
  String campaignNoticeOpens(String title);

  /// No description provided for @campaignNoticeWritten.
  ///
  /// In en, this message translates to:
  /// **'Written'**
  String get campaignNoticeWritten;

  /// No description provided for @campaignNoticeRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get campaignNoticeRead;

  /// No description provided for @campaignNoticeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to notice here yet.'**
  String get campaignNoticeEmpty;

  /// No description provided for @campaignYoursScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your look and motto. Extras are cosmetic and yours to keep.'**
  String get campaignYoursScreenSubtitle;

  /// No description provided for @campaignRewardCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Reward picks'**
  String get campaignRewardCardTitle;

  /// No description provided for @campaignRewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your reward'**
  String get campaignRewardTitle;

  /// No description provided for @campaignRewardPicks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pick to spend. What you choose stays yours.} other{{count} picks to spend. What you choose stays yours.}}'**
  String campaignRewardPicks(int count);

  /// No description provided for @campaignRewardSuggestedLine.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {item}'**
  String campaignRewardSuggestedLine(String item);

  /// Under the suggested reward: the kind of extra (Banner, Carry, Headwear, Colour).
  ///
  /// In en, this message translates to:
  /// **'Suggested · {kind}'**
  String campaignRewardSuggested(String kind);

  /// No description provided for @campaignRewardChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose {item}'**
  String campaignRewardChoose(String item);

  /// No description provided for @campaignRewardChosen.
  ///
  /// In en, this message translates to:
  /// **'{item} is yours to keep.'**
  String campaignRewardChosen(String item);

  /// No description provided for @campaignRewardWear.
  ///
  /// In en, this message translates to:
  /// **'Wear it'**
  String get campaignRewardWear;

  /// No description provided for @campaignRewardPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Your avatar wearing {item}'**
  String campaignRewardPreviewLabel(String item);

  /// No description provided for @campaignRewardNone.
  ///
  /// In en, this message translates to:
  /// **'No pick to spend right now.'**
  String get campaignRewardNone;

  /// No description provided for @campaignRewardGameOff.
  ///
  /// In en, this message translates to:
  /// **'With the Campaign off, every extra is already open.'**
  String get campaignRewardGameOff;

  /// The Compass tab's third pill while the Campaign game is off (Notice, Try, Collection without XP).
  ///
  /// In en, this message translates to:
  /// **'Playground'**
  String get campaignPlaygroundSection;

  /// No description provided for @campaignPlaygroundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Small things to notice and try.'**
  String get campaignPlaygroundSubtitle;

  /// No description provided for @campaignPlaygroundGameOff.
  ///
  /// In en, this message translates to:
  /// **'No XP or levels while the Campaign is off. Turn it on in You.'**
  String get campaignPlaygroundGameOff;

  /// No description provided for @campaignInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Play the Campaign?'**
  String get campaignInviteTitle;

  /// No description provided for @campaignInviteBody.
  ///
  /// In en, this message translates to:
  /// **'XP and levels for what you do.'**
  String get campaignInviteBody;

  /// No description provided for @campaignInvitePlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get campaignInvitePlay;

  /// No description provided for @campaignInvitePlaying.
  ///
  /// In en, this message translates to:
  /// **'The Campaign is on. It lives in Compass.'**
  String get campaignInvitePlaying;

  /// No description provided for @campaignInviteLater.
  ///
  /// In en, this message translates to:
  /// **'You can turn it on in You.'**
  String get campaignInviteLater;

  /// No description provided for @campaignToastPick.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{A new pick for your avatar} other{{count} new picks for your avatar}}'**
  String campaignToastPick(int count);

  /// A small label on a task added from the Playground's "Try".
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get campaignQuestFromTry;

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
  /// **'Six short answers that point your days. Write them, or start from your evening answers.'**
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
  /// **'Bring your evening words into empty fields. Nothing changes until you confirm.'**
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
  /// **'Write each part below, or answer the evening questions first.'**
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
  /// **'One project for the next four weeks.'**
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
  /// **'Only you write this.'**
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
  /// **'Save a snapshot before big changes.'**
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
  /// **'Read-only. Restoring saves your current Compass first.'**
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
  /// **'This replaces your Compass. The current one is saved first.'**
  String get compassRestoreConfirmBody;

  /// No description provided for @compassRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get compassRestoreConfirm;

  /// No description provided for @compassRestored.
  ///
  /// In en, this message translates to:
  /// **'Version restored. The previous one was saved.'**
  String get compassRestored;

  /// No description provided for @compassImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Use my evening reflections'**
  String get compassImportTitle;

  /// No description provided for @compassImportBody.
  ///
  /// In en, this message translates to:
  /// **'Your evening answers, as written. Pick the empty fields to fill.'**
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
  /// **'Boundaries are only written by you.'**
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
  /// **'Nothing to bring over yet. Answer the evening questions first.'**
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
  /// **'Free writing. Stays on this phone.'**
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
  /// **'An idea, a worry, something you noticed.'**
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
  /// **'Once a week: what went well, what got in the way, what to try next.'**
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
  /// **'A few minutes. No right way.'**
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
  /// **'Write as much as you like. It saves as you type.'**
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
  /// **'The review for the week of {date} will be removed. This can\'t be undone.'**
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
  /// **'See how your words have changed.'**
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
  /// **'Save a Compass version to compare it here later.'**
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
  /// **'No earlier resets yet. Starting a new one keeps the old one here.'**
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

  /// No description provided for @journalPastResetUnfinished.
  ///
  /// In en, this message translates to:
  /// **'Not finished'**
  String get journalPastResetUnfinished;

  /// No description provided for @journalPastResetLeftOpen.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question was left open.} other{{count} questions were left open.}}'**
  String journalPastResetLeftOpen(int count);

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
  /// **'Small steps toward your Compass. Rest counts too.'**
  String get missionsIntro;

  /// No description provided for @missionsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get missionsToday;

  /// No description provided for @missionsTodayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned. Add a quest, or rest.'**
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
  /// **'Shows in Today every day.'**
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
  /// **'From your Compass. Edit, then add the ones you want.'**
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
  /// **'Plan one project for the next four weeks.'**
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
  /// **'What worked, what you learned, what you\'d change.'**
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
  /// **'Clears this project\'s title, milestones and notes. Your Compass stays.'**
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

  /// Brand page, under the tagline: the one-line promise.
  ///
  /// In en, this message translates to:
  /// **'One honest day of reflection. Then small steps.'**
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

  /// Last welcome page: finishes the welcome and opens Today.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepCounter(int current, int total);

  /// No description provided for @onboardingLimitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get onboardingLimitsTitle;

  /// No description provided for @onboardingLimitsIntro.
  ///
  /// In en, this message translates to:
  /// **'A few honest words.'**
  String get onboardingLimitsIntro;

  /// No description provided for @onboardingLimitsClarityTitle.
  ///
  /// In en, this message translates to:
  /// **'One day can bring clarity'**
  String get onboardingLimitsClarityTitle;

  /// No description provided for @onboardingLimitsClarityBody.
  ///
  /// In en, this message translates to:
  /// **'See where you stand and what you want.'**
  String get onboardingLimitsClarityBody;

  /// No description provided for @onboardingLimitsNoGuaranteeTitle.
  ///
  /// In en, this message translates to:
  /// **'It won\'t fix your life overnight'**
  String get onboardingLimitsNoGuaranteeTitle;

  /// No description provided for @onboardingLimitsNoGuaranteeBody.
  ///
  /// In en, this message translates to:
  /// **'Change comes from small steps, week by week.'**
  String get onboardingLimitsNoGuaranteeBody;

  /// No description provided for @onboardingLimitsNotTherapyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not therapy'**
  String get onboardingLimitsNotTherapyTitle;

  /// No description provided for @onboardingLimitsNotTherapyBody.
  ///
  /// In en, this message translates to:
  /// **'No diagnosis. For help, see You › Support.'**
  String get onboardingLimitsNotTherapyBody;

  /// No description provided for @onboardingLimitsControlTitle.
  ///
  /// In en, this message translates to:
  /// **'You stay in control'**
  String get onboardingLimitsControlTitle;

  /// No description provided for @onboardingLimitsControlBody.
  ///
  /// In en, this message translates to:
  /// **'Skip, soften or pause any question.'**
  String get onboardingLimitsControlBody;

  /// No description provided for @onboardingAdultConfirm.
  ///
  /// In en, this message translates to:
  /// **'I\'m 18 or older'**
  String get onboardingAdultConfirm;

  /// No description provided for @onboardingAdultConfirmHelp.
  ///
  /// In en, this message translates to:
  /// **'Made for adults.'**
  String get onboardingAdultConfirmHelp;

  /// No description provided for @onboardingAdultRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm you\'re 18 or older to continue.'**
  String get onboardingAdultRequired;

  /// No description provided for @onboardingCreditTitle.
  ///
  /// In en, this message translates to:
  /// **'Inspired by'**
  String get onboardingCreditTitle;

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
  /// **'No need to read it first.'**
  String get onboardingCreditNoNeed;

  /// No description provided for @onboardingPaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your pace'**
  String get onboardingPaceTitle;

  /// No description provided for @onboardingPaceIntro.
  ///
  /// In en, this message translates to:
  /// **'Change it anytime in You.'**
  String get onboardingPaceIntro;

  /// No description provided for @onboardingPaceOneDayTitle.
  ///
  /// In en, this message translates to:
  /// **'One day'**
  String get onboardingPaceOneDayTitle;

  /// No description provided for @onboardingPaceOneDayBody.
  ///
  /// In en, this message translates to:
  /// **'Morning, daytime and evening in one day.'**
  String get onboardingPaceOneDayBody;

  /// No description provided for @onboardingPaceFlexibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get onboardingPaceFlexibleTitle;

  /// No description provided for @onboardingPaceFlexibleBody.
  ///
  /// In en, this message translates to:
  /// **'Spread it out. Pick up anytime.'**
  String get onboardingPaceFlexibleBody;

  /// No description provided for @onboardingPaceNoLock.
  ///
  /// In en, this message translates to:
  /// **'Nothing locks or expires.'**
  String get onboardingPaceNoLock;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameIntro.
  ///
  /// In en, this message translates to:
  /// **'Optional. Stays on this phone.'**
  String get onboardingNameIntro;

  /// No description provided for @onboardingNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get onboardingNameLabel;

  /// No description provided for @onboardingNameHelp.
  ///
  /// In en, this message translates to:
  /// **'Leave it empty and we\'ll call you Traveler.'**
  String get onboardingNameHelp;

  /// No description provided for @onboardingPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your words stay yours'**
  String get onboardingPrivacyTitle;

  /// No description provided for @onboardingPrivacyStorageHeading.
  ///
  /// In en, this message translates to:
  /// **'Where your writing lives'**
  String get onboardingPrivacyStorageHeading;

  /// No description provided for @onboardingPrivacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account, ads or analytics.'**
  String get onboardingPrivacyNoAccount;

  /// No description provided for @onboardingPrivacyControl.
  ///
  /// In en, this message translates to:
  /// **'Export or delete anytime in You › Your data.'**
  String get onboardingPrivacyControl;

  /// No description provided for @personaFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Your strategist'**
  String get personaFeatureTitle;

  /// No description provided for @personaAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Your avatar'**
  String get personaAvatarLabel;

  /// No description provided for @personaNoAvatar.
  ///
  /// In en, this message translates to:
  /// **'No avatar yet'**
  String get personaNoAvatar;

  /// No description provided for @personaCreate.
  ///
  /// In en, this message translates to:
  /// **'Create your avatar'**
  String get personaCreate;

  /// No description provided for @personaEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit your avatar'**
  String get personaEdit;

  /// No description provided for @personaSilhouette.
  ///
  /// In en, this message translates to:
  /// **'Silhouette'**
  String get personaSilhouette;

  /// No description provided for @personaLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get personaLocked;

  /// No description provided for @personaUnlockWithPick.
  ///
  /// In en, this message translates to:
  /// **'Choose it with a reward pick'**
  String get personaUnlockWithPick;

  /// No description provided for @personaNextPickStop.
  ///
  /// In en, this message translates to:
  /// **'Next pick at {place}'**
  String personaNextPickStop(String place);

  /// No description provided for @personaNextPickAchievement.
  ///
  /// In en, this message translates to:
  /// **'Next pick: earn {achievement}'**
  String personaNextPickAchievement(String achievement);

  /// No description provided for @personaCategorySkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get personaCategorySkin;

  /// No description provided for @personaCategoryFace.
  ///
  /// In en, this message translates to:
  /// **'Face'**
  String get personaCategoryFace;

  /// No description provided for @personaCategoryHair.
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get personaCategoryHair;

  /// No description provided for @personaCategoryHairColor.
  ///
  /// In en, this message translates to:
  /// **'Hair colour'**
  String get personaCategoryHairColor;

  /// No description provided for @personaCategoryFacialHair.
  ///
  /// In en, this message translates to:
  /// **'Facial hair'**
  String get personaCategoryFacialHair;

  /// No description provided for @personaCategoryEyewear.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get personaCategoryEyewear;

  /// No description provided for @personaCategoryMark.
  ///
  /// In en, this message translates to:
  /// **'Marks'**
  String get personaCategoryMark;

  /// No description provided for @personaCategoryExpression.
  ///
  /// In en, this message translates to:
  /// **'Expression'**
  String get personaCategoryExpression;

  /// No description provided for @personaCategoryHeadwear.
  ///
  /// In en, this message translates to:
  /// **'Headwear'**
  String get personaCategoryHeadwear;

  /// No description provided for @personaCategoryGarment.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get personaCategoryGarment;

  /// No description provided for @personaCategoryGarmentColor.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get personaCategoryGarmentColor;

  /// No description provided for @personaCategoryAccessory.
  ///
  /// In en, this message translates to:
  /// **'Carry'**
  String get personaCategoryAccessory;

  /// No description provided for @personaCategorySigil.
  ///
  /// In en, this message translates to:
  /// **'Banner'**
  String get personaCategorySigil;

  /// No description provided for @personaSkinTone.
  ///
  /// In en, this message translates to:
  /// **'{value, select, sand{Sand} honey{Honey} clay{Clay} copper{Copper} chestnut{Chestnut} walnut{Walnut} umber{Umber} ebony{Ebony} other{—}}'**
  String personaSkinTone(String value);

  /// No description provided for @personaFace.
  ///
  /// In en, this message translates to:
  /// **'{value, select, oval{Oval} round{Round} square{Square} long{Long} other{—}}'**
  String personaFace(String value);

  /// No description provided for @personaHair.
  ///
  /// In en, this message translates to:
  /// **'{value, select, bald{Bald} buzz{Buzz cut} short{Short} wavy{Wavy} curly{Curly} coily{Coily} afro{Afro} locs{Locs} braids{Braids} bun{Bun} long{Long} ponytail{Ponytail} other{—}}'**
  String personaHair(String value);

  /// No description provided for @personaHairColor.
  ///
  /// In en, this message translates to:
  /// **'{value, select, black{Black} darkBrown{Dark brown} brown{Brown} auburn{Auburn} copper{Copper} blonde{Blonde} grey{Grey} white{White} other{—}}'**
  String personaHairColor(String value);

  /// No description provided for @personaFacialHair.
  ///
  /// In en, this message translates to:
  /// **'{value, select, none{None} stubble{Stubble} moustache{Moustache} beard{Beard} fullBeard{Full beard} other{—}}'**
  String personaFacialHair(String value);

  /// No description provided for @personaEyewear.
  ///
  /// In en, this message translates to:
  /// **'{value, select, none{None} round{Round glasses} square{Square glasses} other{—}}'**
  String personaEyewear(String value);

  /// No description provided for @personaMark.
  ///
  /// In en, this message translates to:
  /// **'{value, select, none{None} freckles{Freckles} beautyMark{Beauty mark} vitiligo{Vitiligo} other{—}}'**
  String personaMark(String value);

  /// No description provided for @personaExpression.
  ///
  /// In en, this message translates to:
  /// **'{value, select, calm{Calm} smile{Smile} focused{Focused} other{—}}'**
  String personaExpression(String value);

  /// No description provided for @personaHeadwear.
  ///
  /// In en, this message translates to:
  /// **'{value, select, none{None} headscarf{Headscarf} turban{Turban} hood{Hood} circlet{Circlet} laurel{Laurel wreath} other{—}}'**
  String personaHeadwear(String value);

  /// No description provided for @personaGarment.
  ///
  /// In en, this message translates to:
  /// **'{value, select, tunic{Tunic} cloak{Cloak} robe{Robe} wrap{Wrap} other{—}}'**
  String personaGarment(String value);

  /// No description provided for @personaGarmentColor.
  ///
  /// In en, this message translates to:
  /// **'{value, select, forest{Forest} olive{Olive} sand{Sand} ivory{Ivory} sage{Sage} indigo{Indigo} crimson{Crimson} bronze{Bronze} other{—}}'**
  String personaGarmentColor(String value);

  /// No description provided for @personaAccessory.
  ///
  /// In en, this message translates to:
  /// **'{value, select, none{None} satchel{Satchel} scroll{Scroll} compass{Compass} amulet{Amulet of Tanit} other{—}}'**
  String personaAccessory(String value);

  /// No description provided for @personaSigil.
  ///
  /// In en, this message translates to:
  /// **'{value, select, none{None} elephant{Elephant} sun{Rising sun} path{Path} compass{Compass} star{North star} laurel{Laurel} other{—}}'**
  String personaSigil(String value);

  /// No description provided for @personaBuilderSurprise.
  ///
  /// In en, this message translates to:
  /// **'Surprise me'**
  String get personaBuilderSurprise;

  /// No description provided for @personaBuilderSurprised.
  ///
  /// In en, this message translates to:
  /// **'New look. Not saved yet.'**
  String get personaBuilderSurprised;

  /// No description provided for @personaBuilderUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get personaBuilderUndo;

  /// No description provided for @personaBuilderParts.
  ///
  /// In en, this message translates to:
  /// **'Avatar parts'**
  String get personaBuilderParts;

  /// One part of the avatar preview's screen-reader description, e.g. 'Hair: Locs'.
  ///
  /// In en, this message translates to:
  /// **'{category}: {value}'**
  String personaBuilderPartLabel(String category, String value);

  /// Screen-reader label of the large live preview; parts is a list of 'Category: value'.
  ///
  /// In en, this message translates to:
  /// **'Avatar preview. {parts}'**
  String personaBuilderPreviewLabel(String parts);

  /// No description provided for @personaBuilderLockedNote.
  ///
  /// In en, this message translates to:
  /// **'Locked extras open with reward picks.'**
  String get personaBuilderLockedNote;

  /// Under an extra the saved avatar already wears but the user has not unlocked: it stays theirs for good, worn or not.
  ///
  /// In en, this message translates to:
  /// **'Yours to keep'**
  String get personaBuilderKept;

  /// Above Marks, Expression, Hair colour and Colour while the avatar is the silhouette (these choices don't show on it yet).
  ///
  /// In en, this message translates to:
  /// **'Pick a skin tone to see the face and colours.'**
  String get personaBuilderHiddenSilhouette;

  /// Above Hair and Hair colour while a headscarf or turban covers the hair.
  ///
  /// In en, this message translates to:
  /// **'Hair is hidden under your headwear.'**
  String get personaBuilderHiddenHeadwear;

  /// No description provided for @personaBuilderMottoLabel.
  ///
  /// In en, this message translates to:
  /// **'Motto (optional)'**
  String get personaBuilderMottoLabel;

  /// No description provided for @personaBuilderMottoHint.
  ///
  /// In en, this message translates to:
  /// **'A few words of your own'**
  String get personaBuilderMottoHint;

  /// No description provided for @personaBuilderMottoCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String personaBuilderMottoCount(int count, int max);

  /// No description provided for @personaBuilderMottoTooLong.
  ///
  /// In en, this message translates to:
  /// **'A little too long. Shorten it to save.'**
  String get personaBuilderMottoTooLong;

  /// The user's motto, shown exactly as typed, in quotes.
  ///
  /// In en, this message translates to:
  /// **'“{motto}”'**
  String personaBuilderMottoQuoted(String motto);

  /// No description provided for @personaBuilderSaved.
  ///
  /// In en, this message translates to:
  /// **'Avatar saved.'**
  String get personaBuilderSaved;

  /// No description provided for @personaBuilderNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Not saved on this phone yet. Retry at the top, or export a copy.'**
  String get personaBuilderNotSaved;

  /// No description provided for @personaBuilderRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove avatar'**
  String get personaBuilderRemove;

  /// No description provided for @personaBuilderRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove your avatar?'**
  String get personaBuilderRemoveTitle;

  /// No description provided for @personaBuilderRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile shows the emblem again. Make a new one anytime.'**
  String get personaBuilderRemoveBody;

  /// No description provided for @personaBuilderRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get personaBuilderRemoveAction;

  /// No description provided for @personaBuilderRemoved.
  ///
  /// In en, this message translates to:
  /// **'Avatar removed.'**
  String get personaBuilderRemoved;

  /// No description provided for @personaBuilderRemovedNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Removed here, but not saved on this phone yet. Retry at the top.'**
  String get personaBuilderRemovedNotSaved;

  /// No description provided for @personaBuilderLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave without saving?'**
  String get personaBuilderLeaveTitle;

  /// No description provided for @personaBuilderLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Your avatar changes won\'t be kept.'**
  String get personaBuilderLeaveBody;

  /// No description provided for @personaBuilderLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get personaBuilderLeaveAction;

  /// No description provided for @personaBuilderKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get personaBuilderKeepEditing;

  /// No description provided for @personaBuilderProfileHint.
  ///
  /// In en, this message translates to:
  /// **'Name and avatar are optional and stay on this phone.'**
  String get personaBuilderProfileHint;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'The Reset'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One day: see where you are, choose where to go.'**
  String get resetSubtitle;

  /// No description provided for @resetPaceOneDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pace: one day'**
  String get resetPaceOneDayTitle;

  /// No description provided for @resetPaceOneDayBody.
  ///
  /// In en, this message translates to:
  /// **'Morning, daytime, evening. Nothing locks if it takes longer.'**
  String get resetPaceOneDayBody;

  /// No description provided for @resetPaceFlexibleTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pace: flexible'**
  String get resetPaceFlexibleTitle;

  /// No description provided for @resetPaceFlexibleBody.
  ///
  /// In en, this message translates to:
  /// **'Any order, any pace. Nothing locks or expires.'**
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
  /// **'Every core question is answered or skipped. You can still edit them.'**
  String get resetAllDoneBody;

  /// No description provided for @resetSeeCreated.
  ///
  /// In en, this message translates to:
  /// **'See what you created'**
  String get resetSeeCreated;

  /// No description provided for @resetCompletedOn.
  ///
  /// In en, this message translates to:
  /// **'Finished on {date}. Answers stay editable.'**
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
  /// **'A good ordinary day, who you want to be, one step'**
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
  /// **'Three extra questions. Optional.'**
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

  /// No description provided for @resetNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new reset'**
  String get resetNewTitle;

  /// No description provided for @resetNewBody.
  ///
  /// In en, this message translates to:
  /// **'Start fresh. This reset stays under Past resets.'**
  String get resetNewBody;

  /// No description provided for @resetNewConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new reset?'**
  String get resetNewConfirmTitle;

  /// No description provided for @resetNewConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Your answers move to Past resets. Compass, quests and journal stay.'**
  String get resetNewConfirmBody;

  /// No description provided for @resetNewConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Start new reset'**
  String get resetNewConfirmAction;

  /// No description provided for @resetNewStarted.
  ///
  /// In en, this message translates to:
  /// **'New reset started. The earlier one is under Past resets.'**
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
  /// **'Skipped. Come back anytime, or leave it.'**
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
  /// **'Go as deep as you like: soften, skip or stop. Your words are saved.'**
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
  /// **'Cartharise isn\'t therapy. If you feel unsafe, contact emergency services or a crisis line now.'**
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
  /// **'{count, plural, =1{1 core question is still open.} other{{count} core questions are still open.}}'**
  String resetCompleteOpen(int count);

  /// No description provided for @resetCompleteCompassBody.
  ///
  /// In en, this message translates to:
  /// **'Your evening answers can start your Life Compass. You choose; nothing is overwritten.'**
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
  /// **'{count} short questions. Skip any, pause anytime.'**
  String todayNextStartBody(int count);

  /// First-use hint on the first reset's start card (replaces the old 'Reset your life' welcome page).
  ///
  /// In en, this message translates to:
  /// **'Morning, daytime, evening: one day, at your own pace.'**
  String get todayNextStartHint;

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

  /// No description provided for @todayNextQuestBody.
  ///
  /// In en, this message translates to:
  /// **'One of today\'s quests.'**
  String get todayNextQuestBody;

  /// No description provided for @todayNextQuestAction.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get todayNextQuestAction;

  /// Row in 'Choose something else' (opens Missions).
  ///
  /// In en, this message translates to:
  /// **'Do one of today\'s quests'**
  String get todayNextQuestOption;

  /// No description provided for @todayNextCompassTitle.
  ///
  /// In en, this message translates to:
  /// **'Build your Compass'**
  String get todayNextCompassTitle;

  /// No description provided for @todayNextCompassImportBody.
  ///
  /// In en, this message translates to:
  /// **'Your evening answers can fill your Compass. You choose.'**
  String get todayNextCompassImportBody;

  /// No description provided for @todayNextCompassManualBody.
  ///
  /// In en, this message translates to:
  /// **'Write your vision, a month project and daily levers.'**
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
  /// **'Turn your daily levers into small quests.'**
  String get todayNextLeversBody;

  /// No description provided for @todayNextLeversAction.
  ///
  /// In en, this message translates to:
  /// **'Choose quests'**
  String get todayNextLeversAction;

  /// No description provided for @todayNextProjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Work on your project'**
  String get todayNextProjectTitle;

  /// No description provided for @todayNextProjectNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {milestone}'**
  String todayNextProjectNext(String milestone);

  /// No description provided for @todayNextProjectAction.
  ///
  /// In en, this message translates to:
  /// **'Open the project'**
  String get todayNextProjectAction;

  /// No description provided for @todayNextReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Look back on your week'**
  String get todayNextReviewTitle;

  /// No description provided for @todayNextReviewBody.
  ///
  /// In en, this message translates to:
  /// **'What went well, what got in the way, what\'s next.'**
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
  /// **'A few lines about today.'**
  String get todayNextJournalBody;

  /// No description provided for @todayNextJournalAction.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get todayNextJournalAction;

  /// No description provided for @todayOpenCompass.
  ///
  /// In en, this message translates to:
  /// **'Open Compass'**
  String get todayOpenCompass;

  /// No description provided for @todayChooseOther.
  ///
  /// In en, this message translates to:
  /// **'Choose something else'**
  String get todayChooseOther;

  /// No description provided for @todayChooseSteps.
  ///
  /// In en, this message translates to:
  /// **'Other steps'**
  String get todayChooseSteps;

  /// Heading of the choice that steers Today's next step.
  ///
  /// In en, this message translates to:
  /// **'Help me with'**
  String get todayPinTitle;

  /// No description provided for @todayPinProject.
  ///
  /// In en, this message translates to:
  /// **'My project'**
  String get todayPinProject;

  /// No description provided for @todayPinReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get todayPinReflection;

  /// No description provided for @todayPinNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get todayPinNotes;

  /// No description provided for @todayPinAuto.
  ///
  /// In en, this message translates to:
  /// **'Decide for me'**
  String get todayPinAuto;

  /// No description provided for @todayPinNoProject.
  ///
  /// In en, this message translates to:
  /// **'No project yet. Today decides for now.'**
  String get todayPinNoProject;

  /// No description provided for @todayDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Done. That can be enough for today.'**
  String get todayDoneTitle;

  /// No description provided for @todayDoneMore.
  ///
  /// In en, this message translates to:
  /// **'One more'**
  String get todayDoneMore;

  /// No description provided for @todayDoneMoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Show one more step'**
  String get todayDoneMoreLabel;

  /// No description provided for @todayWriteHint.
  ///
  /// In en, this message translates to:
  /// **'Write a few lines…'**
  String get todayWriteHint;

  /// No description provided for @todayWriteLabel.
  ///
  /// In en, this message translates to:
  /// **'Write a new note'**
  String get todayWriteLabel;

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
  /// **'Add a small quest when you\'re ready.'**
  String get todayFocusEmptyBody;

  /// First-use hint while no quest exists yet (replaces the old 'Improve step by step' welcome page).
  ///
  /// In en, this message translates to:
  /// **'Quests are small steps you choose. Adjust them each week.'**
  String get todayHintQuests;

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

  /// Link to Missions: open quests without a date or planned for a later day (not listed on Today).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more for anytime or later} other{{count} more for anytime or later}}'**
  String todayFocusLater(int count);

  /// No description provided for @todayQuestMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark \'{title}\' done'**
  String todayQuestMarkDone(String title);

  /// No description provided for @todayQuestDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get todayQuestDaily;

  /// No description provided for @todayJourneyWritten.
  ///
  /// In en, this message translates to:
  /// **'{answered} of {total} reflections written'**
  String todayJourneyWritten(int answered, int total);

  /// No description provided for @todayJourneyOpenReset.
  ///
  /// In en, this message translates to:
  /// **'Open the reset'**
  String get todayJourneyOpenReset;

  /// No description provided for @todayPathDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of 30'**
  String todayPathDay(int day);

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

  /// No description provided for @todayDirectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Your vision and this month\'s project.'**
  String get todayDirectionSummary;

  /// Screen-reader label of the collapsible direction card.
  ///
  /// In en, this message translates to:
  /// **'{title}. {summary}'**
  String todayDirectionLabel(String title, String summary);

  /// No description provided for @todayDirectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Compass is empty.'**
  String get todayDirectionEmpty;

  /// First-use hint while the Compass was never filled (replaces the old 'Choose a direction' welcome page).
  ///
  /// In en, this message translates to:
  /// **'Your answers can become a Life Compass.'**
  String get todayHintCompass;

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

  /// No description provided for @todayTileReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get todayTileReset;

  /// No description provided for @todayTileResetValue.
  ///
  /// In en, this message translates to:
  /// **'{answered}/{total}'**
  String todayTileResetValue(int answered, int total);

  /// No description provided for @todayTileResetStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get todayTileResetStart;

  /// No description provided for @todayTileResetDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get todayTileResetDone;

  /// No description provided for @todayTileResetDetail.
  ///
  /// In en, this message translates to:
  /// **'reflections'**
  String get todayTileResetDetail;

  /// No description provided for @todayTileCampaign.
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get todayTileCampaign;

  /// No description provided for @todayTileCampaignValue.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String todayTileCampaignValue(int level);

  /// No description provided for @todayTilePath.
  ///
  /// In en, this message translates to:
  /// **'30-day path'**
  String get todayTilePath;

  /// No description provided for @todayTilePathValue.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String todayTilePathValue(int day);

  /// No description provided for @todayPathStageName.
  ///
  /// In en, this message translates to:
  /// **'{stage, select, observe{Observe} experiment{Experiment} build{Build} adjust{Adjust} other{Path}}'**
  String todayPathStageName(String stage);

  /// No description provided for @todayTileLabel.
  ///
  /// In en, this message translates to:
  /// **'{title}: {value}. {detail}'**
  String todayTileLabel(String title, String value, String detail);

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
  /// **'Optional, stays on this phone. Tap to change.'**
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
  /// **'Nothing locks. Change anytime.'**
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
  /// **'Independent. Everything stays on this phone.'**
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
  /// **'See the introduction again. Your writing and settings stay.'**
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
  /// **'Notifications show the check-in title only, never your words.'**
  String get youRemindersPrivacy;

  /// No description provided for @youRemindersDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications aren\'t allowed'**
  String get youRemindersDeniedTitle;

  /// No description provided for @youRemindersDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked for Cartharise. Allow them in your phone settings, or add the check-ins to your calendar.'**
  String get youRemindersDeniedBody;

  /// No description provided for @youRemindersUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications aren\'t available'**
  String get youRemindersUnavailableTitle;

  /// No description provided for @youRemindersUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'This phone can\'t show notifications. Add the check-ins to your calendar instead.'**
  String get youRemindersUnavailableBody;

  /// No description provided for @youRemindersScheduleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t schedule the notifications. Try again, or use your calendar.'**
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
  /// **'Local time. Change any to suit your day.'**
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
  /// **'A calendar file with your check-ins for 30 days. Titles only.'**
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

  /// Name of the calendar inside the exported .ics file.
  ///
  /// In en, this message translates to:
  /// **'Cartharise check-ins'**
  String get youCalendarName;

  /// Title of each calendar event; title = the check-in prompt's title.
  ///
  /// In en, this message translates to:
  /// **'Cartharise check-in: {title}'**
  String youCalendarEventTitle(String title);

  /// Notes of each calendar event. Never contains the user's words.
  ///
  /// In en, this message translates to:
  /// **'A short daytime pause from your Cartharise reset. Open the app when it suits you; every check-in is optional.'**
  String get youCalendarEventDescription;

  /// No description provided for @youRemindersCalendarShared.
  ///
  /// In en, this message translates to:
  /// **'Calendar file shared. Open it in your calendar app.'**
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

  /// No description provided for @youThemeOasis.
  ///
  /// In en, this message translates to:
  /// **'Oasis'**
  String get youThemeOasis;

  /// No description provided for @youThemeTyrian.
  ///
  /// In en, this message translates to:
  /// **'Tyrian Rose'**
  String get youThemeTyrian;

  /// No description provided for @youThemeAlpine.
  ///
  /// In en, this message translates to:
  /// **'Alpine'**
  String get youThemeAlpine;

  /// No description provided for @youThemeObsidian.
  ///
  /// In en, this message translates to:
  /// **'Obsidian'**
  String get youThemeObsidian;

  /// No description provided for @youThemeAboutForest.
  ///
  /// In en, this message translates to:
  /// **'Deep forest and bronze: the Cartharise original.'**
  String get youThemeAboutForest;

  /// No description provided for @youThemeAboutOlive.
  ///
  /// In en, this message translates to:
  /// **'The olive groves of the Punic countryside.'**
  String get youThemeAboutOlive;

  /// No description provided for @youThemeAboutOasis.
  ///
  /// In en, this message translates to:
  /// **'Palm green and date gold of the desert oases.'**
  String get youThemeAboutOasis;

  /// No description provided for @youThemeAboutTyrian.
  ///
  /// In en, this message translates to:
  /// **'The rose dye of Tyre, Carthage\'s mother city.'**
  String get youThemeAboutTyrian;

  /// No description provided for @youThemeAboutAlpine.
  ///
  /// In en, this message translates to:
  /// **'Granite and snow, where Hannibal crossed the Alps.'**
  String get youThemeAboutAlpine;

  /// No description provided for @youThemeAboutObsidian.
  ///
  /// In en, this message translates to:
  /// **'Volcanic black glass and gold. True black when dark.'**
  String get youThemeAboutObsidian;

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
  /// **'Screen transitions and the animated emblem. Off when your phone reduces motion.'**
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
  /// **'Saves everything as one JSON file. It isn\'t encrypted, so keep it private.'**
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
  /// **'Replaces everything with a backup. You\'ll confirm first.'**
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

  /// No description provided for @youDataImportedNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup opened but not saved yet. Retry at the top, or export a copy.'**
  String get youDataImportedNotSaved;

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
  /// **'This backup format isn\'t supported by this version.'**
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
  /// **'Erases everything on this phone and cancels reminders. Export first to keep a copy.'**
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
  /// **'Answers, Compass, quests, notes, reviews and settings will be erased.'**
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
  /// **'There\'s no other copy. Only an exported backup can bring it back.'**
  String get youDataDeleteConfirm2Body;

  /// No description provided for @youDataDeleteConfirm2Action.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get youDataDeleteConfirm2Action;

  /// No description provided for @youDataDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete. Your writing is still here; try again.'**
  String get youDataDeleteFailed;

  /// No description provided for @youDataDeleteCopiesLeft.
  ///
  /// In en, this message translates to:
  /// **'Deleted, but a temporary export copy couldn\'t be removed. Removing the app erases it.'**
  String get youDataDeleteCopiesLeft;

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
  /// **'A self-reflection tool. Not therapy, counselling, medical advice or diagnosis.'**
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
  /// **'In danger or thinking of harming yourself? Contact emergency services now, or a crisis line in your country.'**
  String get youSupportCrisisBody;

  /// No description provided for @youSupportFindHelpline.
  ///
  /// In en, this message translates to:
  /// **'Find a helpline'**
  String get youSupportFindHelpline;

  /// No description provided for @youSupportHelplineHint.
  ///
  /// In en, this message translates to:
  /// **'Opens findahelpline.com, helplines by country.'**
  String get youSupportHelplineHint;

  /// No description provided for @youSupportOngoingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ongoing support'**
  String get youSupportOngoingTitle;

  /// No description provided for @youSupportOngoingBody.
  ///
  /// In en, this message translates to:
  /// **'If hard feelings last, a doctor or counsellor can help.'**
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
