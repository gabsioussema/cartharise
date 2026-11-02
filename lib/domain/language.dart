/// The app's languages (step 3): the setting (You › Appearance) and how it
/// resolves against the phone's preferred languages. Pure Dart (no Flutter
/// imports): the UI turns a resolved language into a `Locale`
/// (`lib/app_locale.dart`); the content layer picks the matching
/// `ContentLibrary` (`contentFor` in `lib/content/content.dart`).
library;

/// The language Cartharise speaks. Stored by name in the settings: append,
/// never rename; an unknown or missing name loads as [system].
enum AppLanguage {
  /// Follow the phone: its first preferred language Cartharise ships, else
  /// English.
  system,
  en,
  fr,

  /// Written right to left.
  ar;

  /// The ISO 639-1 code (`en`, `fr`, `ar`); null for [system].
  String? get code => this == system ? null : name;

  /// Whether text and layout run right to left.
  bool get isRtl => this == ar;
}

/// The languages Cartharise ships (every [AppLanguage] but
/// [AppLanguage.system]), English first: English is the source of every
/// string and content item, and the fallback for anything not translated.
const List<AppLanguage> kAppLanguages = [
  AppLanguage.en,
  AppLanguage.fr,
  AppLanguage.ar,
];

/// The shipped language for a language code or tag (`fr`, `fr-CA`,
/// `fr_FR`, `AR`), or null when Cartharise doesn't ship it.
AppLanguage? languageForCode(String code) {
  final primary = code.split(RegExp('[-_]')).first.toLowerCase();
  for (final language in kAppLanguages) {
    if (language.code == primary) return language;
  }
  return null;
}

/// The language to show (never [AppLanguage.system]): [setting] itself,
/// or — for [AppLanguage.system] — the first of the phone's preferred
/// languages ([deviceLanguageCodes], most preferred first) that Cartharise
/// ships, else English.
AppLanguage resolveLanguage(
  AppLanguage setting,
  Iterable<String> deviceLanguageCodes,
) {
  if (setting != AppLanguage.system) return setting;
  for (final code in deviceLanguageCodes) {
    final language = languageForCode(code);
    if (language != null) return language;
  }
  return AppLanguage.en;
}
