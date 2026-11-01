/// Versioned, read-only content: lessons, reflection prompts, the 30-day path
/// and the source credit. Pure Dart (no Flutter imports).
///
/// Content is paraphrased and independently written (F-039). A prompt's [Prompt.id]
/// is permanent: saved answers are keyed by it, so a content update may reword a
/// prompt but must never reuse an id for a different question.
library;

/// When in the reset a prompt is asked.
enum PromptPhase { morning, daytime, bonus, evening }

/// The Reset subflows (the requirement's modules 02–05).
enum ResetSubflow { mirror, vision, interrupt, breakthrough }

/// Thematic group inside a phase, used for section headers and traceability.
enum PromptGroup {
  currentReality(ResetSubflow.mirror),
  antiVision(ResetSubflow.mirror),
  identity(ResetSubflow.mirror),
  vision(ResetSubflow.vision),
  interrupt(ResetSubflow.interrupt),
  contemplation(ResetSubflow.interrupt),
  insight(ResetSubflow.breakthrough),
  direction(ResetSubflow.breakthrough),
  plan(ResetSubflow.breakthrough);

  const PromptGroup(this.subflow);
  final ResetSubflow subflow;
}

/// The six Life Compass components (F-023).
enum CompassField {
  antiVision,
  vision,
  yearGoal,
  monthProject,
  dailyLevers,
  constraints,
}

/// One guided reflection question.
class Prompt {
  const Prompt({
    required this.id,
    required this.phase,
    required this.ordinal,
    required this.group,
    required this.title,
    required this.question,
    required this.context,
    required this.help,
    required this.example,
    required this.sourceReference,
    this.softerQuestion,
    this.defaultTime,
    this.mapsTo,
    this.core = true,
  });

  /// Permanent key, e.g. `morning.01`, `daytime.03`, `bonus.02`, `evening.07`.
  final String id;
  final PromptPhase phase;

  /// 1-based position inside [phase].
  final int ordinal;
  final PromptGroup group;

  /// Short label for lists and progress ("Quiet dissatisfaction").
  final String title;

  /// The question itself, in plain language.
  final String question;

  /// One or two sentences shown above the answer field: why this question.
  final String context;

  /// Plain-language explanation of intent and any unfamiliar term (F-007).
  final String help;

  /// A clearly labelled neutral example — never a "correct answer".
  final String example;

  /// Gentler wording the user can switch to (emotional safety).
  final String? softerQuestion;

  /// Which source segment this covers, e.g. `Morning 01–04 · current reality`.
  final String sourceReference;

  /// Daytime prompts only: the source's default local time, `HH:MM`.
  final String? defaultTime;

  /// Evening #3–#7 only: the Compass field this answer may be imported into (F-024).
  final CompassField? mapsTo;

  /// Bonus contemplations are `false`: excluded from core completion (F-019).
  final bool core;
}

/// A multiple-choice check at the end of a lesson (no score is kept).
class KnowledgeCheck {
  const KnowledgeCheck({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

/// One of the seven Awakening concepts (F-005).
class Lesson {
  const Lesson({
    required this.id,
    required this.ordinal,
    required this.title,
    required this.summary,
    required this.explanation,
    required this.example,
    required this.nuance,
    required this.relatedPromptIds,
    this.check,
  });

  /// e.g. `lesson.01`.
  final String id;
  final int ordinal;
  final String title;

  /// One sentence for the card.
  final String summary;

  /// A few short paragraphs (separated by blank lines).
  final String explanation;

  /// A concrete, neutral illustration.
  final String example;

  /// Limits of the idea: a framework, not a diagnosis or established fact (F-006).
  final String nuance;

  /// Prompts where this concept is put into practice ("Try it" links).
  final List<String> relatedPromptIds;
  final KnowledgeCheck? check;
}

/// The four stages of the optional thirty-day path (F-057).
enum PathStage { observe, experiment, build, adjust }

/// One day of the optional thirty-day reflection path.
class PathDay {
  const PathDay({
    required this.day,
    required this.stage,
    required this.title,
    required this.prompt,
    this.hint,
  });

  /// 1–30.
  final int day;
  final PathStage stage;
  final String title;
  final String prompt;
  final String? hint;
}

/// Attribution for the work that inspired the app (F-002, F-038).
class SourceCredit {
  const SourceCredit({
    required this.title,
    required this.author,
    required this.articleUrl,
    required this.newsletterUrl,
    required this.publishedOn,
    required this.independenceNotice,
    required this.paraphraseNotice,
  });

  final String title;
  final String author;
  final String articleUrl;
  final String newsletterUrl;

  /// Human-readable publication date.
  final String publishedOn;

  /// "Cartharise is independent and not endorsed by …".
  final String independenceNotice;

  /// "Questions are paraphrased, not reproduced …".
  final String paraphraseNotice;
}

/// Everything the app teaches and asks, for one language.
class ContentLibrary {
  const ContentLibrary({
    required this.languageCode,
    required this.version,
    required this.lessons,
    required this.prompts,
    required this.thirtyDays,
    required this.credit,
  });

  final String languageCode;

  /// Bumped on any wording change; saved answers keep working (ids are stable).
  final int version;
  final List<Lesson> lessons;
  final List<Prompt> prompts;
  final List<PathDay> thirtyDays;
  final SourceCredit credit;

  List<Prompt> byPhase(PromptPhase phase) =>
      prompts.where((p) => p.phase == phase).toList()
        ..sort((a, b) => a.ordinal.compareTo(b.ordinal));

  List<Prompt> bySubflow(ResetSubflow subflow) =>
      prompts.where((p) => p.group.subflow == subflow).toList();

  /// Prompts that count toward reset completion (bonus excluded).
  List<Prompt> get corePrompts => prompts.where((p) => p.core).toList();

  Prompt? prompt(String id) {
    for (final p in prompts) {
      if (p.id == id) return p;
    }
    return null;
  }

  Lesson? lesson(String id) {
    for (final l in lessons) {
      if (l.id == id) return l;
    }
    return null;
  }

  /// The evening prompt that feeds [field], if any.
  Prompt? promptFor(CompassField field) {
    for (final p in prompts) {
      if (p.mapsTo == field) return p;
    }
    return null;
  }
}
