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
