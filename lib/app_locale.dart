/// Locales for the app's languages (step 3): what `MaterialApp` is given.
/// The resolution itself is pure Dart (`resolveLanguage` in
/// `domain/language.dart`); `AppState.language` holds the result.
library;

import 'dart:ui' show Locale;

import 'domain/language.dart';

/// The locales Cartharise ships, in [kAppLanguages] order (English first).
/// `AppLocalizations.supportedLocales` holds the same set.
final List<Locale> kAppLocales = [
  for (final language in kAppLanguages) Locale(language.code!),
];

/// The locale of a resolved [language] (English for
/// [AppLanguage.system], which should have been resolved first).
Locale localeFor(AppLanguage language) =>
    Locale(language.code ?? AppLanguage.en.code!);

/// The language codes of the phone's preferred [locales], most preferred
/// first (what `AppState` resolves [AppLanguage.system] against).
List<String> languageCodesOf(Iterable<Locale> locales) => [
  for (final locale in locales) locale.languageCode,
];

/// The locale to show for the [setting] on a phone whose preferred locales
/// are [deviceLocales]: the setting itself, or for system the first
/// preferred language Cartharise ships, else English.
Locale resolveAppLocale(AppLanguage setting, Iterable<Locale> deviceLocales) =>
    localeFor(resolveLanguage(setting, languageCodesOf(deviceLocales)));
