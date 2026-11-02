import '../domain/content.dart';
import '../domain/content_translation.dart';
import '../domain/language.dart';
import 'ar.dart';
import 'en.dart';
import 'fr.dart';

export '../domain/content_translation.dart'
    show ContentCoverage, ContentKind, ContentTranslation;

/// The content library for a resolved [language] (see `resolveLanguage`).
/// English is the source; French and Arabic take the English structure and
/// fall back to English per item, by permanent id, until translated.
/// [AppLanguage.system] is not a language: resolve it first (it gets
/// English here).
ContentLibrary contentFor(AppLanguage language) => switch (language) {
  AppLanguage.fr => frenchContent,
  AppLanguage.ar => arabicContent,
  AppLanguage.en || AppLanguage.system => englishContent,
};

/// [contentFor] the language of a code or tag (`fr`, `ar-EG`); English for
/// a language Cartharise doesn't ship.
ContentLibrary contentForCode(String languageCode) =>
    contentFor(languageForCode(languageCode) ?? AppLanguage.en);

/// The content translations, per shipped language other than English.
const Map<AppLanguage, ContentTranslation> kContentTranslations = {
  AppLanguage.fr: frenchTranslation,
  AppLanguage.ar: arabicTranslation,
};

/// Which content ids [language] translates (English: everything), for
/// tests and docs/translations.md.
ContentCoverage coverageFor(AppLanguage language) {
  final translation = kContentTranslations[language];
  return contentCoverage(englishContent, translation ?? _englishAsTranslation);
}

/// English measured against itself: every item complete.
final ContentTranslation _englishAsTranslation = ContentTranslation(
  languageCode: 'en',
  version: englishContent.version,
  lessons: {
    for (final l in englishContent.lessons)
      l.id: LessonText(
        title: l.title,
        summary: l.summary,
        explanation: l.explanation,
        example: l.example,
        nuance: l.nuance,
        check: switch (l.check) {
          null => null,
          final c => CheckText(
            question: c.question,
            options: c.options,
            explanation: c.explanation,
          ),
        },
      ),
  },
  prompts: {
    for (final p in englishContent.prompts)
      p.id: PromptText(
        title: p.title,
        question: p.question,
        context: p.context,
        help: p.help,
        example: p.example,
        softerQuestion: p.softerQuestion,
      ),
  },
  thirtyDays: {
    for (final d in englishContent.thirtyDays)
      d.day: PathDayText(title: d.title, prompt: d.prompt, hint: d.hint),
  },
  experiments: {
    for (final e in englishContent.experiments)
      e.id: ExperimentText(title: e.title, steps: e.steps),
  },
  notices: {
    for (final n in englishContent.notices) n.id: NoticeText(title: n.title),
  },
  credit: CreditText(
    publishedOn: englishContent.credit.publishedOn,
    independenceNotice: englishContent.credit.independenceNotice,
    paraphraseNotice: englishContent.credit.paraphraseNotice,
  ),
);
