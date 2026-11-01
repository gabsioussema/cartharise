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
