/// Today's "Your next step" (F-037): one user-controlled suggestion derived
/// ONLY from what is stored (journey answers, Compass, quests, reviews,
/// lessons read) — never from assumptions about the person.
///
/// [nextStepFor] is a pure function of [NextStepFacts]; [NextStepFacts.of]
/// reads those facts from the app state.
library;

import 'package:flutter/foundation.dart';

import '../../domain/content.dart';
import '../../domain/local_date.dart';
import '../../state/app_state.dart';

enum NextStepKind {
  /// Nothing written yet: begin the morning reflection (lessons optional).
  start,

  /// A reset is under way: continue at the resume point, with its phase.
  resume,

  /// The evening is done and the Compass is still empty.
  buildCompass,

  /// The Compass has daily levers but there are no quests yet.
  leversToQuests,

  /// End of the week and no weekly review saved for it yet.
  weeklyReview,

  /// Otherwise: a journal note.
  journal,
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
  });

  /// Reads the facts from [state] (no writes; the draft journey stays a draft).
  factory NextStepFacts.of(AppState state) {
    final journey = state.journey;
    final evening = state.progressFor(PromptPhase.evening);
    final week = weekStartKey(state.now());
    final morning = state.content.byPhase(PromptPhase.morning);
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
}

/// The suggestion, with what the card needs to act on it.
@immutable
class NextStep {
  const NextStep(
    this.kind, {
    this.prompt,
    this.suggestLessons = false,
    this.canImport = false,
  });

  final NextStepKind kind;

  /// [NextStepKind.start] / [NextStepKind.resume]: the prompt to open.
  final Prompt? prompt;

  /// [NextStepKind.start]: also offer the seven lessons (optional).
  final bool suggestLessons;

  /// [NextStepKind.buildCompass]: evening answers can be imported (else the
  /// Compass is filled by hand).
  final bool canImport;

  @override
  bool operator ==(Object other) =>
      other is NextStep &&
      other.kind == kind &&
      other.prompt?.id == prompt?.id &&
      other.suggestLessons == suggestLessons &&
      other.canImport == canImport;

  @override
  int get hashCode => Object.hash(kind, prompt?.id, suggestLessons, canImport);

  @override
  String toString() =>
      'NextStep(${kind.name}, prompt: ${prompt?.id}, '
      'lessons: $suggestLessons, import: $canImport)';
}

/// Weekly reviews are suggested from Friday on.
const int kReviewSuggestedFrom = DateTime.friday;

/// The next best step, in this order:
/// 1. nothing started → begin the morning reflection (+ lessons if none read);
/// 2. a reset in progress → resume at its next open prompt;
/// 3. evening done and Compass empty → build the Compass;
/// 4. levers but no quests → turn levers into quests;
/// 5. otherwise a weekly review (end of week, none yet) or a journal note.
NextStep nextStepFor(NextStepFacts f) {
  if (!f.resetStarted) {
    return NextStep(
      NextStepKind.start,
      prompt: f.firstPrompt,
      suggestLessons: f.lessonsRead == 0,
    );
  }
  if (!f.resetCompleted && f.nextPrompt != null) {
    return NextStep(NextStepKind.resume, prompt: f.nextPrompt);
  }
  if (f.eveningFinished && f.compassEmpty) {
    return NextStep(NextStepKind.buildCompass, canImport: f.canImportCompass);
  }
  if (f.compassHasLevers && f.questCount == 0) {
    return const NextStep(NextStepKind.leversToQuests);
  }
  if (!f.reviewedThisWeek && f.weekday >= kReviewSuggestedFrom) {
    return const NextStep(NextStepKind.weeklyReview);
  }
  return const NextStep(NextStepKind.journal);
}
