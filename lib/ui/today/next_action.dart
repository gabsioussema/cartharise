import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/compass_import.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'next_step.dart';
import 'today_model.dart';

/// Today's one next action (F-037; evolve plan Step 1 › A) on the forest
/// hero with a compact dawn scene: the step's title, one or two short lines,
/// a bronze pill and "Choose something else" (the other steps that make
/// sense now, and "Help me with", which remembers [TodayPin]).
///
/// Once the chosen kind of action was done today ([doneForToday]) it says
/// "Done. That can be enough for today." with a quiet "One more" that shows
/// the step again (for the rest of the day). Nothing opens by itself.
class NextActionCard extends StatefulWidget {
  const NextActionCard({super.key});

  /// Width / height of the scene: shorter than a regular scene, so the
  /// action stays near the top.
  static const sceneAspectRatio = 3.0;

  @override
  State<NextActionCard> createState() => _NextActionCardState();
}

class _NextActionCardState extends State<NextActionCard> {
  /// The local day "One more" was tapped; the done state returns tomorrow.
  String? _moreOn;

  Future<void> _chooseOther(NextStepFacts facts, NextStep shown) async {
    final state = context.read<AppState>();
    final options = [
      for (final s in stepOptions(facts))
        if (s.kind != shown.kind) s,
    ];
    final choice = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      sheetAnimationStyle: motionEnabled(context)
          ? null
          : AnimationStyle.noAnimation,
      builder: (_) => _ChooseSheet(
        options: options,
        pin: facts.pin,
        hasProject: facts.hasProject,
      ),
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case TodayPin pin when pin != state.settings.todayPin:
        await state.updateSettings(state.settings.copyWith(todayPin: pin));
      case NextStep step:
        await _StepView.of(context, step).choose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final facts = NextStepFacts.of(state);
    final step = nextStepFor(facts);
    final done = _moreOn != state.today && doneForToday(facts, step);
    return HeroCard(
      key: const ValueKey('today-next-step'),
      padding: EdgeInsets.zero,
      child: OnHeroTheme(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Scene(),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 12),
              child: done
                  ? _DoneBody(
                      onMore: () => setState(() => _moreOn = state.today),
                    )
                  : _StepBody(
                      step: step,
                      firstReset: FirstUseHints.of(state.data).reset,
                      onChooseOther: () => _chooseOther(facts, step),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The compact dawn scene, melting into the hero at its bottom.
class _Scene extends StatelessWidget {
  const _Scene();

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return Stack(
      children: [
        const DawnRuinsScene(aspectRatio: NextActionCard.sceneAspectRatio),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.hero.withValues(alpha: 0), p.hero],
                  stops: const [0.6, 1],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// How one step reads and what it does: on the card ([action] / [secondary])
/// and as a row in "Choose something else" ([optionTitle] / [choose]).
class _StepView {
  const _StepView({
    required this.glyph,
    required this.title,
    required this.body,
    required this.action,
    required this.onAction,
    this.actionIcon = Icons.arrow_forward,
    this.optionTitle,
    this.onChoose,
    this.detail,
    this.secondary,
    this.onSecondary,
  });

  factory _StepView.of(
    BuildContext context,
    NextStep step, {
    bool firstReset = false,
  }) {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final content = state.content;
    final prompt = step.prompt;
    Future<void> open() => prompt == null
        ? AppNav.switchTab(context, AppTab.reset)
        : AppNav.openPrompt(context, prompt.id);
    switch (step.kind) {
      case NextStepKind.quest:
        final quest = step.quest!;
        return _StepView(
          glyph: CarthaGlyph.progress,
          // The user's own words, as typed.
          title: quest.title,
          body: l.todayNextQuestBody,
          action: l.todayNextQuestAction,
          actionIcon: Icons.check,
          onAction: () =>
              state.setQuestDone(quest.id, true, day: state.today),
          optionTitle: l.todayNextQuestOption,
          onChoose: () => AppNav.openMissions(context),
        );
      case NextStepKind.start:
        return _StepView(
          glyph: CarthaGlyph.notice,
          title: l.todayNextStartTitle,
          body: l.todayNextStartBody(
            content.byPhase(PromptPhase.morning).length,
          ),
          detail: firstReset ? l.todayNextStartHint : null,
          action: l.todayNextStartAction,
          onAction: open,
          secondary: step.suggestLessons
              ? l.todayNextLessonsAction(content.lessons.length)
              : null,
          onSecondary: () => AppNav.openAwakening(context),
        );
      case NextStepKind.resume:
        final phase = prompt?.phase.name ?? '';
        return _StepView(
          glyph: CarthaGlyph.notice,
          title: l.todayNextResumeTitle(phase),
          body: l.todayNextResumeBody(prompt?.title ?? ''),
          detail: prompt == null
              ? null
              : l.todayNextResumePosition(
                  phase,
                  prompt.ordinal,
                  content.byPhase(prompt.phase).length,
                ),
          action: l.todayNextResumeAction,
          onAction: open,
        );
      case NextStepKind.buildCompass:
        return step.canImport
            ? _StepView(
                glyph: CarthaGlyph.direction,
                title: l.todayNextCompassTitle,
                body: l.todayNextCompassImportBody,
                action: l.todayNextCompassImportAction,
                onAction: () => showCompassImport(context),
                secondary: l.todayOpenCompass,
                onSecondary: () => AppNav.openCompass(context),
              )
            : _StepView(
                glyph: CarthaGlyph.direction,
                title: l.todayNextCompassTitle,
                body: l.todayNextCompassManualBody,
                action: l.todayOpenCompass,
                onAction: () => AppNav.openCompass(context),
              );
      case NextStepKind.leversToQuests:
        return _StepView(
          glyph: CarthaGlyph.direction,
          title: l.todayNextLeversTitle,
          body: l.todayNextLeversBody,
          action: l.todayNextLeversAction,
          onAction: () => AppNav.openMissions(context),
        );
      case NextStepKind.project:
        final milestone = step.nextMilestone;
        return _StepView(
          glyph: CarthaGlyph.direction,
          title: l.todayNextProjectTitle,
          // The project and milestone titles are the user's own words.
          body: step.projectTitle ?? '',
          detail: milestone == null ? null : l.todayNextProjectNext(milestone),
          action: l.todayNextProjectAction,
          onAction: () => AppNav.openProject(context),
        );
      case NextStepKind.weeklyReview:
        return _StepView(
          glyph: CarthaGlyph.reflection,
          title: l.todayNextReviewTitle,
          body: l.todayNextReviewBody,
          action: l.todayNextReviewAction,
          onAction: () => AppNav.openReview(context),
        );
      case NextStepKind.journal:
        return _StepView(
          glyph: CarthaGlyph.reflection,
          title: l.todayNextJournalTitle,
          body: l.todayNextJournalBody,
          action: l.todayNextJournalAction,
          onAction: () => AppNav.openJournalEntry(context),
        );
    }
  }

  final CarthaGlyph glyph;
  final String title;
  final String body;
  final String? detail;
  final String action;

  /// After the pill's label: an arrow when it opens something, a check when
  /// it completes a quest.
  final IconData actionIcon;
  final Future<void> Function() onAction;
  final String? secondary;
  final Future<void> Function()? onSecondary;

  /// The row title in "Choose something else" (default: [title]).
  final String? optionTitle;

  /// What picking it in "Choose something else" does (default: [onAction]).
  final Future<void> Function()? onChoose;

  Future<void> choose() => (onChoose ?? onAction)();
}

/// The step on the card: eyebrow, title, lines, the pill and the links.
class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.step,
    required this.firstReset,
    required this.onChooseOther,
  });

  final NextStep step;
  final bool firstReset;
  final VoidCallback onChooseOther;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final view = _StepView.of(context, step, firstReset: firstReset);
    return Column(
      key: ValueKey('today-step-${step.kind.name}'),
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
            view.title,
            style: theme.textTheme.titleLarge?.copyWith(color: p.onHero),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          view.body,
          style: theme.textTheme.bodyMedium?.copyWith(color: p.onHero),
        ),
        if (view.detail != null) ...[
          const SizedBox(height: 4),
          Text(
            view.detail!,
            style: theme.textTheme.bodySmall?.copyWith(color: p.onHeroMuted),
          ),
        ],
        const SizedBox(height: 16),
        PrimaryButton(
          key: const ValueKey('today-next-action'),
          label: view.action,
          trailingIcon: view.actionIcon,
          expand: true,
          onPressed: view.onAction,
        ),
        const SizedBox(height: 4),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: [
            if (view.secondary != null)
              TextLinkButton(
                label: view.secondary!,
                onPressed: view.onSecondary,
              ),
            TextLinkButton(
              key: const ValueKey('today-choose-other'),
              label: l.todayChooseOther,
              icon: Icons.swap_horiz,
              onPressed: onChooseOther,
            ),
          ],
        ),
      ],
    );
  }
}

/// "Done. That can be enough for today." and a quiet "One more".
class _DoneBody extends StatelessWidget {
  const _DoneBody({required this.onMore});

  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Column(
      key: const ValueKey('today-done'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Said in words; the check only accompanies them.
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 2),
              child: Icon(Icons.check_circle_outline, color: p.heroAccent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l.todayDoneTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: p.onHero,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Semantics(
            container: true,
            button: true,
            label: l.todayDoneMoreLabel,
            onTap: onMore,
            excludeSemantics: true,
            child: TextLinkButton(
              key: const ValueKey('today-one-more'),
              label: l.todayDoneMore,
              onPressed: onMore,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Choose something else ──────────────────────────────────────────────────

/// The other steps that make sense now (each starts at once), then "Help me
/// with" (my project · reflection · notes · decide for me). Pops with the
/// picked [NextStep] or [TodayPin]; dismissing changes nothing.
class _ChooseSheet extends StatelessWidget {
  const _ChooseSheet({
    required this.options,
    required this.pin,
    required this.hasProject,
  });

  final List<NextStep> options;
  final TodayPin pin;
  final bool hasProject;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final pins = [
      (TodayPin.project, CarthaGlyph.direction, l.todayPinProject),
      (TodayPin.reflection, CarthaGlyph.notice, l.todayPinReflection),
      (TodayPin.notes, CarthaGlyph.reflection, l.todayPinNotes),
      (TodayPin.auto, null, l.todayPinAuto),
    ];
    Widget heading(String text) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 4),
      child: Semantics(
        header: true,
        child: Text(
          text,
          style: theme.textTheme.titleSmall?.copyWith(color: p.textSecondary),
        ),
      ),
    );
    return SingleChildScrollView(
      key: const ValueKey('today-choose-sheet'),
      padding: EdgeInsetsDirectional.fromSTEB(
        16,
        0,
        16,
        24 +
            MediaQuery.paddingOf(context).bottom +
            MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 12),
            child: Semantics(
              header: true,
              child: Text(l.todayChooseOther, style: theme.textTheme.titleLarge),
            ),
          ),
          if (options.isNotEmpty) ...[
            heading(l.todayChooseSteps),
            for (final step in options)
              Builder(
                builder: (context) {
                  final view = _StepView.of(context, step);
                  return ListTile(
                    key: ValueKey('today-option-${step.kind.name}'),
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 4,
                    ),
                    leading: GlyphIcon(view.glyph),
                    title: Text(view.optionTitle ?? view.title),
                    trailing: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: p.textSecondary,
                    ),
                    onTap: () => Navigator.of(context).pop(step),
                  );
                },
              ),
            const SizedBox(height: 12),
          ],
          heading(l.todayPinTitle),
          for (final (value, glyph, label) in pins)
            _PinChoice(
              value: value,
              glyph: glyph,
              label: label,
              detail: value == TodayPin.project && !hasProject
                  ? l.todayPinNoProject
                  : null,
              selected: value == pin,
              onTap: () => Navigator.of(context).pop(value),
            ),
        ],
      ),
    );
  }
}

/// One "Help me with" choice: a radio row (the choice shows by its mark and
/// is announced as checked, not only by colour).
class _PinChoice extends StatelessWidget {
  const _PinChoice({
    required this.value,
    required this.glyph,
    required this.label,
    required this.selected,
    required this.onTap,
    this.detail,
  });

  final TodayPin value;
  final CarthaGlyph? glyph;
  final String label;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      selected: selected,
      button: true,
      child: Material(
        key: ValueKey('today-pin-${value.name}'),
        color: selected ? p.selection : Colors.transparent,
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected ? p.accent : p.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  if (glyph != null)
                    GlyphIcon(glyph!, size: 20)
                  else
                    Icon(Icons.auto_awesome_outlined, size: 20, color: p.accent),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: theme.textTheme.bodyLarge),
                        if (detail != null)
                          Text(
                            detail!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: p.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
