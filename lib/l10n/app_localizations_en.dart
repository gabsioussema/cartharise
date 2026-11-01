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
}
