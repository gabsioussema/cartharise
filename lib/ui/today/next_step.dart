/// Today's one next action (F-037; evolve plan, Step 1 › A): a single
/// user-controlled suggestion derived ONLY from what is stored (journey
/// answers, Compass, quests, the month project, reviews, notes, lessons
/// read) and the user's own "Help me with" choice ([TodayPin]) — never from
/// assumptions about the person.
///
/// [nextStepFor], [stepOptions] and [doneForToday] are pure functions of
/// [NextStepFacts]; [NextStepFacts.of] reads those facts from the app state.
library;

import 'package:flutter/foundation.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../domain/local_date.dart';
import '../../state/app_state.dart';
import '../missions/missions_logic.dart';

enum NextStepKind {
  /// One of today's open quests: do it.
  quest,

  /// Nothing written yet: begin the morning reflection (lessons optional).
  start,

  /// A reset is under way: continue at the resume point, with its phase.
  resume,

  /// The evening is done and the Compass is still empty.
  buildCompass,

  /// The Compass has daily levers but there are no quests yet.
  leversToQuests,

  /// The month project (asked for with "Help me with: my project", or
  /// picked in "Choose something else"; never chosen by the app itself).
  project,

  /// End of the week and no weekly review saved for it yet.
  weeklyReview,

  /// Otherwise: a journal note.
  journal,
}

/// What was done today, per kind of action Today can suggest. Only today's
/// local date counts, so a long absence never shows up as anything missed.
@immutable
class DoneToday {
  const DoneToday({
    this.quest = false,
    this.answer = false,
    this.note = false,
    this.review = false,
    this.compass = false,
    this.project = false,
  });

  static const nothing = DoneToday();

  /// Reads today's activity from [state] (no writes).
  factory DoneToday.of(AppState state) {
    final today = state.today;
    bool on(DateTime? t) => t != null && dateKey(t) == today;
    final data = state.data;
    final project = data.project;
    return DoneToday(
      quest: data.quests.any((q) => q.completedOn.contains(today)),
      answer: data.journeys.any(
        (j) => j.answers.values.any((a) => a.answered && on(a.updatedAt)),
      ),
      note: data.journal.any((e) => on(e.createdAt) || on(e.editedAt)),
      review: data.reviews.any((r) => on(r.createdAt) || on(r.editedAt)),
      compass: on(data.compass.updatedAt),
      project:
          (project != null && on(project.updatedAt)) ||
          data.quests.any(
            (q) =>
                q.source == QuestSource.project &&
                q.completedOn.contains(today),
          ),
    );
  }

  /// A quest was completed today.
  final bool quest;

  /// A reflection answer with words was written today (a skip is not one).
  final bool answer;

  /// A journal note was written or edited today.
  final bool note;

  /// A weekly review was written or edited today.
  final bool review;

  /// The Compass was changed today.
  final bool compass;

  /// The month project was worked on today (changed, or one of its quests
  /// completed).
  final bool project;

  /// Any of them.
  bool get anything => quest || answer || note || review || compass || project;
}

/// The stored facts the suggestion depends on.
@immutable
class NextStepFacts {
  const NextStepFacts({
    required this.lessonsRead,
    required this.resetStarted,
    required this.resetCompleted,
    required this.nextPrompt,
    required this.firstPrompt,
    required this.eveningFinished,
    required this.compassEmpty,
    required this.compassHasLevers,
    required this.canImportCompass,
    required this.questCount,
    required this.reviewedThisWeek,
    required this.weekday,
    this.openQuest,
    this.projectTitle,
    this.nextMilestone,
    this.pin = TodayPin.auto,
    this.oneDayPace = false,
    this.doneToday = DoneToday.nothing,
  });

  /// Reads the facts from [state] (no writes; the draft journey stays a draft).
  factory NextStepFacts.of(AppState state) {
    final journey = state.journey;
    final evening = state.progressFor(PromptPhase.evening);
    final week = weekStartKey(state.now());
    final morning = state.content.byPhase(PromptPhase.morning);
    final today = state.today;
    Quest? open;
    for (final q in state.todayFocus(today)) {
      if (!q.isDoneOn(today)) {
        open = q;
        break;
      }
    }
    // The saved project (unless finished), else the Compass's month project
    // (Missions shows it as the project draft).
    final saved = state.data.project;
    final String title;
    String? milestone;
    if (saved != null) {
      title = saved.status == ProjectStatus.done ? '' : saved.title.trim();
      for (final m in saved.milestones) {
        if (!m.done && m.title.trim().isNotEmpty) {
          milestone = m.title;
          break;
        }
      }
    } else {
      title = state.compass.monthProject.trim();
    }
    return NextStepFacts(
      lessonsRead: state.data.lessonsRead.length,
      resetStarted:
          journey.answers.isNotEmpty || journey.activePromptId != null,
      resetCompleted: journey.completedAt != null,
      nextPrompt: state.nextPrompt,
      firstPrompt: morning.isEmpty ? state.nextPrompt : morning.first,
      eveningFinished: evening.finished || journey.completedAt != null,
      compassEmpty: state.compass.isEmpty,
      compassHasLevers: state.leverDrafts.isNotEmpty,
      canImportCompass: state.compassImportPreview.isNotEmpty,
      questCount: state.data.quests.length,
      reviewedThisWeek: state.data.reviews.any((r) => r.weekStart == week),
      weekday: state.now().weekday,
      openQuest: open,
      projectTitle: title.isEmpty ? null : title,
      nextMilestone: title.isEmpty ? null : milestone,
      pin: state.settings.todayPin,
      oneDayPace: state.data.profile?.pace == Pace.oneDay,
      doneToday: DoneToday.of(state),
    );
  }

  final int lessonsRead;

  /// Any answer or skip in the current reset, or a prompt was opened.
  final bool resetStarted;

  /// The user marked the current reset complete.
  final bool resetCompleted;

  /// `AppState.nextPrompt`: the resume point, null when every core prompt
  /// was answered or skipped.
  final Prompt? nextPrompt;

  /// The first morning prompt (where a fresh reset begins).
  final Prompt? firstPrompt;

  /// Every evening prompt answered or skipped, or the reset completed.
  final bool eveningFinished;
  final bool compassEmpty;

  /// The Compass's daily levers would give at least one draft quest.
  final bool compassHasLevers;

  /// Evening answers exist that could fill empty Compass fields.
  final bool canImportCompass;
  final int questCount;

  /// A weekly review exists for the current week (Monday start).
  final bool reviewedThisWeek;

  /// `DateTime.weekday` of today (1 = Monday … 7 = Sunday).
  final int weekday;

  /// The first open quest of today's focus (as in Missions), if any.
  final Quest? openQuest;

  /// The month project's title, as typed; null when there is none (or it
  /// is finished).
  final String? projectTitle;

  /// The project's first open milestone, as typed.
  final String? nextMilestone;

  /// What the user asked Today to help with.
  final TodayPin pin;

  /// The user chose to do the reset in one day.
  final bool oneDayPace;

  /// What was done today.
  final DoneToday doneToday;

  bool get hasProject => projectTitle != null;

  /// A weekly review makes sense: none yet this week, and it is the end of
  /// the week.
  bool get reviewDue => !reviewedThisWeek && weekday >= kReviewSuggestedFrom;
}

/// The suggestion, with what the card needs to act on it.
@immutable
class NextStep {
  const NextStep(
    this.kind, {
    this.prompt,
    this.quest,
    this.projectTitle,
    this.nextMilestone,
    this.suggestLessons = false,
    this.canImport = false,
    this.pinned = false,
  });

  final NextStepKind kind;

  /// [NextStepKind.start] / [NextStepKind.resume]: the prompt to open.
  final Prompt? prompt;

  /// [NextStepKind.quest]: the quest to do.
  final Quest? quest;

  /// [NextStepKind.project]: its title and next milestone, as typed.
  final String? projectTitle;
  final String? nextMilestone;

  /// [NextStepKind.start]: also offer the seven lessons (optional).
  final bool suggestLessons;

  /// [NextStepKind.buildCompass]: evening answers can be imported (else the
  /// Compass is filled by hand).
  final bool canImport;

  /// Chosen because of the user's [TodayPin], not by the app's own order.
  final bool pinned;

  NextStep _asPinned() => NextStep(
    kind,
    prompt: prompt,
    quest: quest,
    projectTitle: projectTitle,
    nextMilestone: nextMilestone,
    suggestLessons: suggestLessons,
    canImport: canImport,
    pinned: true,
  );

  @override
  bool operator ==(Object other) =>
      other is NextStep &&
      other.kind == kind &&
      other.prompt?.id == prompt?.id &&
      other.quest?.id == quest?.id &&
      other.projectTitle == projectTitle &&
      other.nextMilestone == nextMilestone &&
      other.suggestLessons == suggestLessons &&
      other.canImport == canImport &&
      other.pinned == pinned;

  @override
  int get hashCode => Object.hash(
    kind,
    prompt?.id,
    quest?.id,
    projectTitle,
    nextMilestone,
    suggestLessons,
    canImport,
    pinned,
  );

  @override
  String toString() =>
      'NextStep(${kind.name}, prompt: ${prompt?.id}, quest: ${quest?.id}, '
      'project: $projectTitle, lessons: $suggestLessons, '
      'import: $canImport, pinned: $pinned)';
}

/// Weekly reviews are suggested from Friday on.
const int kReviewSuggestedFrom = DateTime.friday;

NextStep _start(NextStepFacts f) => NextStep(
  NextStepKind.start,
  prompt: f.firstPrompt,
  suggestLessons: f.lessonsRead == 0,
);

bool _inProgress(NextStepFacts f) =>
    f.resetStarted && !f.resetCompleted && f.nextPrompt != null;

NextStep _project(NextStepFacts f) => NextStep(
  NextStepKind.project,
  projectTitle: f.projectTitle,
  nextMilestone: f.nextMilestone,
);

/// Every step that makes sense now, in the app's own order:
/// 1. an open quest for today → do one;
/// 2. nothing started in the current reset → begin the morning reflection
///    (+ lessons if none read) — with no quests at all this comes first;
/// 3. a reset in progress → resume at its next open prompt;
/// 4. evening done and Compass empty → build the Compass;
/// 5. levers but no quests → turn levers into quests;
/// 6. the end of the week without a review → a weekly review;
/// 7. a journal note (always possible).
List<NextStep> _autoSteps(NextStepFacts f) => [
  if (f.openQuest != null) NextStep(NextStepKind.quest, quest: f.openQuest),
  if (!f.resetStarted) _start(f),
  if (_inProgress(f)) NextStep(NextStepKind.resume, prompt: f.nextPrompt),
  if (f.eveningFinished && f.compassEmpty)
    NextStep(NextStepKind.buildCompass, canImport: f.canImportCompass),
  if (f.compassHasLevers && f.questCount == 0)
    const NextStep(NextStepKind.leversToQuests),
  if (f.reviewDue) const NextStep(NextStepKind.weeklyReview),
  const NextStep(NextStepKind.journal),
];

/// The step the user's pin asks for, or null when it doesn't apply (then
/// the app's own order decides):
/// * notes → a journal note;
/// * reflection → begin or resume the reset, else the weekly review at the
///   end of the week;
/// * project → the month project, while there is an unfinished one.
NextStep? _pinnedStep(NextStepFacts f) {
  final step = switch (f.pin) {
    TodayPin.auto => null,
    TodayPin.notes => const NextStep(NextStepKind.journal),
    TodayPin.project => f.hasProject ? _project(f) : null,
    TodayPin.reflection =>
      !f.resetStarted
          ? _start(f)
          : _inProgress(f)
          ? NextStep(NextStepKind.resume, prompt: f.nextPrompt)
          : f.reviewDue
          ? const NextStep(NextStepKind.weeklyReview)
          : null,
  };
  return step?._asPinned();
}

/// The one next step: what the pin asks for when it applies, else the first
/// of the app's own order (see [_autoSteps]).
NextStep nextStepFor(NextStepFacts f) =>
    _pinnedStep(f) ?? _autoSteps(f).first;

/// Everything that makes sense now, for "Choose something else": the app's
/// own order with the month project (when there is one) before the note.
/// Each kind appears once.
List<NextStep> stepOptions(NextStepFacts f) {
  final auto = _autoSteps(f);
  if (!f.hasProject) return auto;
  return [...auto.take(auto.length - 1), _project(f), auto.last];
}

/// Whether Today shows "Done. That can be enough for today." instead of
/// [step]: the kind of action the user chose was already done today.
/// * pinned notes → a note today; pinned reflection → an answer or a weekly
///   review today; pinned project → the project worked on today;
/// * the app's own choice → anything Today could suggest was done today
///   (a quest completed, an answer, a note, a review, the Compass or the
///   project changed).
///
/// A one-day reset under way keeps offering "Continue": the user chose to
/// do it in one day. Only today counts: a long absence is never mentioned.
bool doneForToday(NextStepFacts f, NextStep step) {
  if (step.kind == NextStepKind.resume && f.oneDayPace) return false;
  final d = f.doneToday;
  if (!step.pinned) return d.anything;
  return switch (f.pin) {
    TodayPin.notes => d.note,
    TodayPin.reflection => d.answer || d.review,
    TodayPin.project => d.project,
    TodayPin.auto => d.anything,
  };
}
