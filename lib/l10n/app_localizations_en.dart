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
}
