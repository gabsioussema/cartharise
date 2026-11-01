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
