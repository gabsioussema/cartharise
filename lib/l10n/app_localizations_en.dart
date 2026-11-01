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
}
