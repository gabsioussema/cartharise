// French content for Cartharise — a DRAFT until a native speaker reviews it
// (docs/translations.md). Translate by permanent id; structure (order,
// phases, links, Compass mapping, correct answers) always comes from the
// English library, so only words go here. An item missing or incomplete
// here is shown in English (never half translated): `coverageFor` in
// content.dart and `make l10n`'s report say what is left.
//
// Same rules as English: paraphrase, never reproduce the source; short,
// calm, action first; no guilt, streak, score or diagnosis wording.
import '../domain/content.dart';
import '../domain/content_translation.dart';
import 'en.dart';

/// The French translation, keyed by permanent id (empty until translated).
const ContentTranslation frenchTranslation = ContentTranslation(
  languageCode: 'fr',
  version: 1,
);

/// The French library: English structure, French words where translated.
final ContentLibrary frenchContent = translateContent(
  englishContent,
  frenchTranslation,
);
