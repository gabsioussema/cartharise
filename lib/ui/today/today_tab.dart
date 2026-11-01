import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../campaign/campaign_ops.dart';
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
                _GlanceRow(summary: JourneySummary.of(state)),
                const SizedBox(height: 16),
                _FocusCard(
                  // The same "today" as Missions (missions_logic.dart).
                  quests: state.todayFocus(today),
                  laterCount: state.missionSections(today).later.length,
                  today: today,
                ),
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

/// "At a glance": small tappable tiles — reset progress, the Campaign level
/// (while the game layer is on) and the thirty-day path day (only once the
/// user has written on the path). Each opens its place in the app.
class _GlanceRow extends StatelessWidget {
  const _GlanceRow({required this.summary});

  final JourneySummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final s = summary;
    final campaign = state.settings.game ? state.campaign : null;
    final tiles = <Widget>[
      _GlanceTile(
        key: const ValueKey('today-journey'),
        icon: Icons.wb_twilight,
        title: l.todayTileReset,
        value: !s.started
            ? l.todayTileResetStart
            : s.completed
            ? l.todayTileResetDone
            : l.todayTileResetValue(s.answered, s.total),
        detail: l.todayTileResetDetail,
        label: l.todayJourneyWritten(s.answered, s.total),
        progress: s.started ? s.fraction : null,
        action: l.todayJourneyOpenReset,
        onTap: () => AppNav.switchTab(context, AppTab.reset),
      ),
      if (campaign != null)
        _GlanceTile(
          key: const ValueKey('today-campaign'),
          icon: Icons.flag_outlined,
          title: l.todayTileCampaign,
          value: l.todayTileCampaignValue(campaign.level),
          detail: '${campaign.xp} XP',
          progress: campaign.levelXp / kXpPerLevel,
          action: l.campaignTodayOpen,
          onTap: () => AppNav.openCampaign(context),
        ),
      if (s.pathDay != null)
        _GlanceTile(
          key: const ValueKey('today-path-day'),
          icon: Icons.route_outlined,
          title: l.todayTilePath,
          value: l.todayTilePathValue(s.pathDay!),
          detail: l.todayPathStageName(s.pathStage?.name ?? ''),
          action: l.todayPathOpen(s.pathNextDay ?? s.pathDay!),
          onTap: () => AppNav.openPathDay(context, s.pathNextDay ?? s.pathDay!),
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final fit = (constraints.maxWidth / (104 * scale)).floor();
        final columns = fit.clamp(1, tiles.length);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

/// One glance tile: icon, title, a big value, one detail line, an optional
/// progress bar. The whole tile is one button.
class _GlanceTile extends StatelessWidget {
  const _GlanceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.action,
    required this.onTap,
    this.progress,
    this.label,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final String action;
  final VoidCallback onTap;
  final double? progress;

  /// What a screen reader hears instead of [detail] (defaults to it).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: l.todayTileLabel(title, value, label ?? detail),
      hint: action,
      excludeSemantics: true,
      child: SectionCard(
        onTap: onTap,
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: p.accent),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: progress, minHeight: 4),
              ),
            ],
          ],
        ),
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
