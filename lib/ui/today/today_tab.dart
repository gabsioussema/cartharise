import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/compass_import.dart';
import '../missions/missions_logic.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'next_step.dart';
import 'today_model.dart';

/// The default return view (F-036): greeting, the next best step (F-037),
/// today's quests, gentle reset progress (F-054) and the user's direction.
/// Everything is derived from stored state; no streaks, scores or guilt copy
/// (F-031).
class TodayTab extends StatelessWidget {
  const TodayTab({super.key});

  /// Most quests listed before "See all".
  static const maxQuests = 5;

  /// Content column width on tablets.
  static const maxContentWidth = 720.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final name = state.data.profile?.displayName ?? l.todayDefaultName;
    final greeting = switch (dayPartAt(state.now())) {
      DayPart.morning => l.todayGreetingMorning(name),
      DayPart.afternoon => l.todayGreetingAfternoon(name),
      DayPart.evening => l.todayGreetingEvening(name),
    };
    final today = state.today;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = math.max(
              20.0,
              (constraints.maxWidth - maxContentWidth) / 2,
            );
            return ListView(
              padding: EdgeInsetsDirectional.fromSTEB(side, 0, side, 32),
              children: [
                ScreenHeader(
                  title: greeting,
                  subtitle: l.todaySubtitle,
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                ),
                if (state.saveStatus == SaveStatus.failed) ...[
                  const SaveIndicator(),
                  const SizedBox(height: 16),
                ],
                _NextStepHero(step: nextStepFor(NextStepFacts.of(state))),
                const SizedBox(height: 16),
                _FocusCard(
                  // The same "today" as Missions (missions_logic.dart).
                  quests: state.todayFocus(today),
                  laterCount: state.missionSections(today).later.length,
                  today: today,
                ),
                const SizedBox(height: 16),
                _JourneyCard(summary: JourneySummary.of(state)),
                const SizedBox(height: 16),
                const _DirectionCard(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A labelled action of the next-step card.
typedef _Action = (String label, VoidCallback? onPressed);

/// "Your next step" on the forest hero with the dawn ruins scene.
class _NextStepHero extends StatelessWidget {
  const _NextStepHero({required this.step});

  final NextStep step;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final content = state.content;
    final prompt = step.prompt;
    void open() => prompt == null
        ? AppNav.switchTab(context, AppTab.reset)
        : AppNav.openPrompt(context, prompt.id);

    final String title;
    final String body;
    String? detail;
    final _Action primary;
    _Action? secondary;
    switch (step.kind) {
      case NextStepKind.start:
        title = l.todayNextStartTitle;
        body = l.todayNextStartBody(
          content.byPhase(PromptPhase.morning).length,
        );
        primary = (l.todayNextStartAction, open);
        if (step.suggestLessons) {
          secondary = (
            l.todayNextLessonsAction(content.lessons.length),
            () => AppNav.openAwakening(context),
          );
        }
      case NextStepKind.resume:
        final phase = prompt?.phase.name ?? '';
        title = l.todayNextResumeTitle(phase);
        body = l.todayNextResumeBody(prompt?.title ?? '');
        if (prompt != null) {
          detail = l.todayNextResumePosition(
            phase,
            prompt.ordinal,
            content.byPhase(prompt.phase).length,
          );
        }
        primary = (l.todayNextResumeAction, open);
        secondary = (
          l.todayNextSeeReset,
          () => AppNav.switchTab(context, AppTab.reset),
        );
      case NextStepKind.buildCompass:
        title = l.todayNextCompassTitle;
        if (step.canImport) {
          body = l.todayNextCompassImportBody;
          primary = (
            l.todayNextCompassImportAction,
            () => showCompassImport(context),
          );
          secondary = (l.todayOpenCompass, () => AppNav.openCompass(context));
        } else {
          body = l.todayNextCompassManualBody;
          primary = (l.todayOpenCompass, () => AppNav.openCompass(context));
        }
      case NextStepKind.leversToQuests:
        title = l.todayNextLeversTitle;
        body = l.todayNextLeversBody;
        primary = (l.todayNextLeversAction, () => AppNav.openMissions(context));
      case NextStepKind.weeklyReview:
        title = l.todayNextReviewTitle;
        body = l.todayNextReviewBody;
        primary = (l.todayNextReviewAction, () => AppNav.openReview(context));
        secondary = (
          l.todayNextJournalAction,
          () => AppNav.openJournalEntry(context),
        );
      case NextStepKind.journal:
        title = l.todayNextJournalTitle;
        body = l.todayNextJournalBody;
        primary = (
          l.todayNextJournalAction,
          () => AppNav.openJournalEntry(context),
        );
        secondary = (
          l.todayOpenJournal,
          () => AppNav.switchTab(context, AppTab.journal),
        );
    }

    return HeroCard(
      key: const ValueKey('today-next-step'),
      padding: EdgeInsets.zero,
      child: OnHeroTheme(
        child: Builder(
          builder: (context) {
            final p = CarthaPalette.of(context);
            final theme = Theme.of(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    const DawnRuinsScene(aspectRatio: 2),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [p.hero.withValues(alpha: 0), p.hero],
                              stops: const [0.7, 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.todayNextEyebrow.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: p.heroAccent,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: p.onHero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: p.onHero,
                        ),
                      ),
                      if (detail != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          detail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: p.onHeroMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: primary.$1,
                        trailingIcon: Icons.arrow_forward,
                        expand: true,
                        onPressed: primary.$2,
                      ),
                      if (secondary != null) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: TextLinkButton(
                            label: secondary.$1,
                            onPressed: secondary.$2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "Today's focus": today's quests with accessible checkboxes.
class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.quests,
    required this.laterCount,
    required this.today,
  });

  final List<Quest> quests;

  /// Open quests without a date or planned for later (Missions' "Anytime &
  /// upcoming"): not listed here, only counted, with a way there.
  final int laterCount;
  final String today;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final shown = quests.take(TodayTab.maxQuests).toList();
    final add = TextLinkButton(
      label: l.todayFocusAdd,
      icon: Icons.add,
      onPressed: () => AppNav.openMissions(context),
    );
    return SectionCard(
      key: const ValueKey('today-focus'),
      title: l.todayFocusTitle,
      icon: Icons.flag_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (quests.isEmpty) ...[
            Text(l.todayFocusEmptyTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              l.todayFocusEmptyBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
          ] else
            for (final q in shown) _QuestRow(quest: q, today: today),
          Wrap(
            spacing: 8,
            children: [
              add,
              if (quests.length > shown.length)
                TextLinkButton(
                  label: l.todayFocusSeeAll(quests.length),
                  onPressed: () => AppNav.openMissions(context),
                ),
              if (laterCount > 0)
                TextLinkButton(
                  key: const ValueKey('today-focus-later'),
                  label: l.todayFocusLater(laterCount),
                  onPressed: () => AppNav.openMissions(context),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({required this.quest, required this.today});

  final Quest quest;
  final String today;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final done = quest.isDoneOn(today);
    void toggle() =>
        context.read<AppState>().setQuestDone(quest.id, !done, day: today);
    return Semantics(
      container: true,
      checked: done,
      label: l.todayQuestMarkDone(quest.title),
      onTap: toggle,
      excludeSemantics: true,
      child: InkWell(
        onTap: toggle,
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
          child: Row(
            children: [
              Checkbox(value: done, onChanged: (_) => toggle()),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: done ? p.textSecondary : p.textPrimary,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: p.textSecondary,
                        ),
                      ),
                      if (quest.recurrence == QuestRecurrence.daily) ...[
                        const SizedBox(height: 4),
                        ChipTag(label: l.todayQuestDaily, icon: Icons.repeat),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Your journey": reset progress in words (never a judgement) and the
/// thirty-day path day when the user has written on the path.
class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.summary});

  final JourneySummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final s = summary;
    final status = !s.started
        ? l.todayJourneyNotStarted
        : s.completed
        ? l.todayJourneyCompleted
        : s.allTouched
        ? l.todayJourneyAllTouched
        : l.todayJourneyInProgress;
    final written = l.todayJourneyWritten(s.answered, s.total);
    return SectionCard(
      key: const ValueKey('today-journey'),
      title: l.todayJourneyTitle,
      icon: Icons.route_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (s.started) ...[
                ProgressRing(value: s.fraction, semanticLabel: written),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (s.started) ...[
                      Text(written, style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      status,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final phase in s.phases)
                Semantics(
                  container: true,
                  label: l.todayPhaseProgressLabel(
                    phase.phase.name,
                    phase.progress.answered,
                    phase.progress.total,
                  ),
                  excludeSemantics: true,
                  child: ChipTag(
                    label: l.todayPhaseProgress(
                      phase.phase.name,
                      phase.progress.answered,
                      phase.progress.total,
                    ),
                    icon: phase.progress.finished ? Icons.check : null,
                    tone: phase.progress.finished
                        ? ChipTone.success
                        : ChipTone.neutral,
                  ),
                ),
            ],
          ),
          if (s.pathDay != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              l.todayPathDay(s.pathDay!),
              key: const ValueKey('today-path-day'),
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 2),
            Text(
              l.todayPathStage(s.pathStage?.name ?? ''),
              style: theme.textTheme.bodySmall,
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextLinkButton(
                label: l.todayPathOpen(s.pathNextDay ?? s.pathDay!),
                trailingIcon: Icons.arrow_forward,
                onPressed: () =>
                    AppNav.openPathDay(context, s.pathNextDay ?? s.pathDay!),
              ),
            ),
          ] else
            const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextLinkButton(
              label: l.todayJourneyOpenReset,
              trailingIcon: Icons.arrow_forward,
              onPressed: () => AppNav.switchTab(context, AppTab.reset),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Your direction": the vision and this month's project, from the Compass
/// (or the month project the user set up in Missions).
class _DirectionCard extends StatelessWidget {
  const _DirectionCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final compass = state.compass;
    final projectTitle = state.data.project?.title.trim() ?? '';
    final month = projectTitle.isNotEmpty ? projectTitle : compass.monthProject;
    final empty = compass.isEmpty && projectTitle.isEmpty;
    final open = TextLinkButton(
      label: l.todayOpenCompass,
      trailingIcon: Icons.arrow_forward,
      onPressed: () => AppNav.openCompass(context),
    );

    Widget snippet(String label, String text, String placeholder) {
      final has = text.trim().isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: p.accent,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            has ? text.trim() : placeholder,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: has
                ? theme.textTheme.bodyLarge
                : theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
        ],
      );
    }

    return SectionCard(
      key: const ValueKey('today-direction'),
      title: l.todayDirectionTitle,
      icon: Icons.explore_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (empty) ...[
            Text(l.todayDirectionEmptyTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              l.todayDirectionEmptyBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ] else ...[
            snippet(
              l.todayDirectionVision,
              compass.vision,
              l.todayDirectionNoVision,
            ),
            const SizedBox(height: 14),
            snippet(l.todayDirectionMonth, month, l.todayDirectionNoMonth),
          ],
          const SizedBox(height: 4),
          Align(alignment: AlignmentDirectional.centerStart, child: open),
        ],
      ),
    );
  }
}
