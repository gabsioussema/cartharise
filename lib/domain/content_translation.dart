/// Content in another language (step 3): the translated words of each
/// lesson, prompt, path day, experiment, notice and the credit, keyed by the
/// item's permanent id, laid over the English library. Pure Dart.
///
/// * **Structure always comes from English.** Ids, phases, order, groups,
///   Compass mapping, related prompts, the correct answer of a check,
///   chapters, minutes, glyphs, what a notice opens, source references,
///   default times, the article's title, author and links: none of it is
///   translated, so saved answers, achievements and links keep working in
///   every language.
/// * **Per item, never half.** An item is used only when its translation is
///   complete (every text the English item has, non-empty; a check with as
///   many options as English). Otherwise the whole item stays English and
///   [contentCoverage] lists it as incomplete — a prompt is never shown with
///   a French question and an English example.
/// * Translations are drafts until a native speaker reviews them
///   (docs/translations.md).
library;

import 'content.dart';

/// The translated words of a [Prompt].
class PromptText {
  const PromptText({
    required this.title,
    required this.question,
    required this.context,
    required this.help,
    required this.example,
    this.softerQuestion,
  });

  final String title;
  final String question;
  final String context;
  final String help;
  final String example;

  /// Required when the English prompt has a softer wording.
  final String? softerQuestion;
}

/// The translated words of a [KnowledgeCheck] ([options] in the English
/// order: the correct index is English's).
class CheckText {
  const CheckText({
    required this.question,
    required this.options,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final String explanation;
}

/// The translated words of a [Lesson].
class LessonText {
  const LessonText({
    required this.title,
    required this.summary,
    required this.explanation,
    required this.example,
    required this.nuance,
    this.check,
  });

  final String title;
  final String summary;

  /// Short paragraphs separated by blank lines, like English.
  final String explanation;
  final String example;
  final String nuance;

  /// Required when the English lesson has a check.
  final CheckText? check;
}

/// The translated words of a [PathDay].
class PathDayText {
  const PathDayText({required this.title, required this.prompt, this.hint});

  final String title;
  final String prompt;

  /// Required when the English day has a hint.
  final String? hint;
}

/// The translated words of an [Experiment].
class ExperimentText {
  const ExperimentText({required this.title, required this.steps});

  final String title;

  /// One to three short lines (need not match the English count).
  final List<String> steps;
}

/// The translated words of a [Notice].
class NoticeText {
  const NoticeText({required this.title});

  final String title;
}

/// The translated words of the [SourceCredit]. The article's title, its
/// author and the links stay as published.
class CreditText {
  const CreditText({
    required this.publishedOn,
    required this.independenceNotice,
    required this.paraphraseNotice,
  });

  final String publishedOn;
  final String independenceNotice;
  final String paraphraseNotice;
}

/// One language's translation of the content, keyed by permanent id
/// (`lesson.01`, `morning.01`, `try.terrain.01`, `notice.01`; path days by
/// their day number 1–30). Anything absent stays English.
class ContentTranslation {
  const ContentTranslation({
    required this.languageCode,
    required this.version,
    this.lessons = const {},
    this.prompts = const {},
    this.thirtyDays = const {},
    this.experiments = const {},
    this.notices = const {},
    this.credit,
  });

  /// `fr`, `ar`, …
  final String languageCode;

  /// Bumped on any wording change of this translation.
  final int version;
  final Map<String, LessonText> lessons;
  final Map<String, PromptText> prompts;
  final Map<int, PathDayText> thirtyDays;
  final Map<String, ExperimentText> experiments;
  final Map<String, NoticeText> notices;
  final CreditText? credit;
}

/// The coverage id of path day [day] (`path.07`).
String pathDayId(int day) => 'path.${day.toString().padLeft(2, '0')}';

/// The coverage id of the source credit.
const String kCreditId = 'credit';

/// [english] in [t]'s language: each item whose translation is complete
/// takes the translated words, everything else stays English.
ContentLibrary translateContent(ContentLibrary english, ContentTranslation t) {
  final lessons = [
    for (final l in english.lessons)
      switch (t.lessons[l.id]) {
        final tr? when _lessonComplete(l, tr) => Lesson(
          id: l.id,
          ordinal: l.ordinal,
          title: tr.title,
          summary: tr.summary,
          explanation: tr.explanation,
          example: tr.example,
          nuance: tr.nuance,
          relatedPromptIds: l.relatedPromptIds,
          check: switch (l.check) {
            null => null,
            final check => KnowledgeCheck(
              question: tr.check!.question,
              options: tr.check!.options,
              correctIndex: check.correctIndex,
              explanation: tr.check!.explanation,
            ),
          },
        ),
        _ => l,
      },
  ];
  final prompts = [
    for (final p in english.prompts)
      switch (t.prompts[p.id]) {
        final tr? when _promptComplete(p, tr) => Prompt(
          id: p.id,
          phase: p.phase,
          ordinal: p.ordinal,
          group: p.group,
          title: tr.title,
          question: tr.question,
          context: tr.context,
          help: tr.help,
          example: tr.example,
          sourceReference: p.sourceReference,
          softerQuestion: p.softerQuestion == null ? null : tr.softerQuestion,
          defaultTime: p.defaultTime,
          mapsTo: p.mapsTo,
          core: p.core,
        ),
        _ => p,
      },
  ];
  final days = [
    for (final d in english.thirtyDays)
      switch (t.thirtyDays[d.day]) {
        final tr? when _dayComplete(d, tr) => PathDay(
          day: d.day,
          stage: d.stage,
          title: tr.title,
          prompt: tr.prompt,
          hint: d.hint == null ? null : tr.hint,
        ),
        _ => d,
      },
  ];
  final experiments = [
    for (final e in english.experiments)
      switch (t.experiments[e.id]) {
        final tr? when _experimentComplete(tr) => Experiment(
          id: e.id,
          chapter: e.chapter,
          title: tr.title,
          steps: tr.steps,
          minutes: e.minutes,
        ),
        _ => e,
      },
  ];
  final notices = [
    for (final n in english.notices)
      switch (t.notices[n.id]) {
        final tr? when _filled(tr.title) => Notice(
          id: n.id,
          glyph: n.glyph,
          title: tr.title,
          promptId: n.promptId,
          lessonId: n.lessonId,
        ),
        _ => n,
      },
  ];
  final c = english.credit;
  final credit = switch (t.credit) {
    final tr? when _creditComplete(tr) => SourceCredit(
      title: c.title,
      author: c.author,
      articleUrl: c.articleUrl,
      newsletterUrl: c.newsletterUrl,
      publishedOn: tr.publishedOn,
      independenceNotice: tr.independenceNotice,
      paraphraseNotice: tr.paraphraseNotice,
    ),
    _ => c,
  };
  return ContentLibrary(
    languageCode: t.languageCode,
    version: t.version,
    lessons: lessons,
    prompts: prompts,
    thirtyDays: days,
    credit: credit,
    experiments: experiments,
    notices: notices,
  );
}

/// The kinds of content item, for [ContentCoverage].
enum ContentKind { lesson, prompt, pathDay, experiment, notice, credit }

/// Which content items a translation covers, by id (path days as
/// `path.<nn>`, the credit as [kCreditId]), for tests and docs.
class ContentCoverage {
  const ContentCoverage({
    required this.languageCode,
    required this.translated,
    required this.incomplete,
    required this.missing,
    required this.unknown,
  });

  final String languageCode;

  /// Complete translations (shown translated), per kind, in English order.
  final Map<ContentKind, List<String>> translated;

  /// Translated in part: shown in English until every text is there.
  final Map<ContentKind, List<String>> incomplete;

  /// Not translated yet: shown in English.
  final Map<ContentKind, List<String>> missing;

  /// Translated ids that English doesn't have (a typo, or an item that was
  /// removed): never shown.
  final List<String> unknown;

  List<String> get translatedIds => [
    for (final ids in translated.values) ...ids,
  ];
  List<String> get incompleteIds => [
    for (final ids in incomplete.values) ...ids,
  ];
  List<String> get missingIds => [for (final ids in missing.values) ...ids];

  /// Every English item.
  int get total =>
      translatedIds.length + incompleteIds.length + missingIds.length;

  /// Share of items shown translated, 0–1.
  double get ratio => total == 0 ? 1 : translatedIds.length / total;

  bool get complete => incompleteIds.isEmpty && missingIds.isEmpty;
}

/// How much of [english] the translation [t] covers.
ContentCoverage contentCoverage(ContentLibrary english, ContentTranslation t) {
  final translated = {for (final k in ContentKind.values) k: <String>[]};
  final incomplete = {for (final k in ContentKind.values) k: <String>[]};
  final missing = {for (final k in ContentKind.values) k: <String>[]};
  void sort(ContentKind kind, String id, Object? tr, bool complete) {
    (tr == null
            ? missing
            : complete
            ? translated
            : incomplete)[kind]!
        .add(id);
  }

  for (final l in english.lessons) {
    final tr = t.lessons[l.id];
    sort(ContentKind.lesson, l.id, tr, tr != null && _lessonComplete(l, tr));
  }
  for (final p in english.prompts) {
    final tr = t.prompts[p.id];
    sort(ContentKind.prompt, p.id, tr, tr != null && _promptComplete(p, tr));
  }
  for (final d in english.thirtyDays) {
    final tr = t.thirtyDays[d.day];
    sort(
      ContentKind.pathDay,
      pathDayId(d.day),
      tr,
      tr != null && _dayComplete(d, tr),
    );
  }
  for (final e in english.experiments) {
    final tr = t.experiments[e.id];
    sort(
      ContentKind.experiment,
      e.id,
      tr,
      tr != null && _experimentComplete(tr),
    );
  }
  for (final n in english.notices) {
    final tr = t.notices[n.id];
    sort(ContentKind.notice, n.id, tr, tr != null && _filled(tr.title));
  }
  final credit = t.credit;
  sort(
    ContentKind.credit,
    kCreditId,
    credit,
    credit != null && _creditComplete(credit),
  );

  final known = {
    for (final l in english.lessons) l.id,
    for (final p in english.prompts) p.id,
    for (final d in english.thirtyDays) pathDayId(d.day),
    for (final e in english.experiments) e.id,
    for (final n in english.notices) n.id,
  };
  final unknown = [
    for (final id in [
      ...t.lessons.keys,
      ...t.prompts.keys,
      for (final day in t.thirtyDays.keys) pathDayId(day),
      ...t.experiments.keys,
      ...t.notices.keys,
    ])
      if (!known.contains(id)) id,
  ];
  return ContentCoverage(
    languageCode: t.languageCode,
    translated: translated,
    incomplete: incomplete,
    missing: missing,
    unknown: unknown,
  );
}

bool _filled(String? s) => s != null && s.trim().isNotEmpty;

bool _promptComplete(Prompt p, PromptText t) =>
    _filled(t.title) &&
    _filled(t.question) &&
    _filled(t.context) &&
    _filled(t.help) &&
    _filled(t.example) &&
    (p.softerQuestion == null || _filled(t.softerQuestion));

bool _lessonComplete(Lesson l, LessonText t) {
  if (!(_filled(t.title) &&
      _filled(t.summary) &&
      _filled(t.explanation) &&
      _filled(t.example) &&
      _filled(t.nuance))) {
    return false;
  }
  final check = l.check;
  if (check == null) return true;
  final tr = t.check;
  return tr != null &&
      _filled(tr.question) &&
      _filled(tr.explanation) &&
      tr.options.length == check.options.length &&
      tr.options.every(_filled);
}

bool _dayComplete(PathDay d, PathDayText t) =>
    _filled(t.title) &&
    _filled(t.prompt) &&
    (d.hint == null || _filled(t.hint));

bool _experimentComplete(ExperimentText t) =>
    _filled(t.title) &&
    t.steps.isNotEmpty &&
    t.steps.length <= 3 &&
    t.steps.every(_filled);

bool _creditComplete(CreditText t) =>
    _filled(t.publishedOn) &&
    _filled(t.independenceNotice) &&
    _filled(t.paraphraseNotice);
