import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'onboarding_steps.dart';

/// Board-style welcome (F-001–F-004, F-043, D-11): brand page, a four-page
/// carousel with the brand scenes, then setup — what this is and isn't
/// (18+ confirmation), the inspiration credit, pace, an optional name and
/// where the data lives. Finish calls `AppState.completeOnboarding`, which
/// switches the app to the shell, then [onDone].
///
/// Back (button, swipe or system back) works on every page and keeps every
/// choice; Skip jumps from the intro to the first setup page, never past the
/// 18+ confirmation.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  OnboardingStep _step = OnboardingStep.brand;
  bool _adult = false;
  Pace _pace = Pace.flexible;
  final _name = TextEditingController();
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    // "Replay welcome": start from what the user chose before.
    final profile = context.read<AppState>().data.profile;
    if (profile != null) {
      _name.text = profile.displayName ?? '';
      _pace = profile.pace;
      _adult = profile.adultConfirmed;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _go(OnboardingStep? step) {
    if (step == null || step == _step) return;
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
  }

  void _next() {
    if (!_step.canAdvance(adultConfirmed: _adult)) return;
    final next = _step.next;
    if (next == null) {
      _finish();
    } else {
      _go(next);
    }
  }

  void _back() => _go(_step.previous);

  void _skip() => _go(OnboardingStep.skipTarget);

  Future<void> _finish() async {
    if (!_adult || _finishing) return;
    setState(() => _finishing = true);
    await context.read<AppState>().completeOnboarding(
      displayName: _name.text,
      pace: _pace,
      adultConfirmed: true,
    );
    if (mounted) setState(() => _finishing = false);
    widget.onDone?.call();
  }

  void _onSwipe(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    if (v.abs() < 250) return;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final forward = rtl ? v > 0 : v < 0;
    forward ? _next() : _back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step.previous == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: CarthaPageMotion(
        page: _step,
        child: KeyedSubtree(key: ValueKey(_step), child: _page(context)),
      ),
    );
  }

  Widget _page(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (_step) {
      OnboardingStep.brand => _IntroPage(
        step: _step,
        onNext: _next,
        onBack: _back,
        onSkip: _skip,
        onSwipe: _onSwipe,
        nextLabel: l.onboardingBegin,
        child: const _BrandContent(),
      ),
      OnboardingStep.understand ||
      OnboardingStep.reset ||
      OnboardingStep.direction ||
      OnboardingStep.steps => _IntroPage(
        step: _step,
        onNext: _next,
        onBack: _back,
        onSkip: _skip,
        onSwipe: _onSwipe,
        nextLabel: _step == OnboardingStep.steps
            ? l.onboardingGetStarted
            : l.onboardingNext,
        child: _CarouselContent(step: _step),
      ),
      OnboardingStep.limits => _SetupPage(
        step: _step,
        title: l.onboardingLimitsTitle,
        subtitle: l.onboardingLimitsIntro,
        onBack: _back,
        action: PrimaryButton(
          key: const ValueKey('onboarding-next'),
          label: l.onboardingNext,
          trailingIcon: Icons.arrow_forward,
          expand: true,
          onPressed: _adult ? _next : null,
        ),
        hint: _adult ? null : l.onboardingAdultRequired,
        children: [
          const _LimitsCard(),
          const SizedBox(height: 16),
          _AdultCard(
            value: _adult,
            onChanged: (v) => setState(() => _adult = v),
          ),
        ],
      ),
      OnboardingStep.credit => _SetupPage(
        step: _step,
        title: l.onboardingCreditTitle,
        onBack: _back,
        action: _nextButton(l),
        children: const [_CreditCard()],
      ),
      OnboardingStep.pace => _SetupPage(
        step: _step,
        title: l.onboardingPaceTitle,
        subtitle: l.onboardingPaceIntro,
        onBack: _back,
        action: _nextButton(l),
        children: [
          _PaceChoice(
            pace: Pace.oneDay,
            selected: _pace == Pace.oneDay,
            icon: Icons.wb_sunny_outlined,
            title: l.onboardingPaceOneDayTitle,
            body: l.onboardingPaceOneDayBody,
            onTap: () => setState(() => _pace = Pace.oneDay),
          ),
          const SizedBox(height: 12),
          _PaceChoice(
            pace: Pace.flexible,
            selected: _pace == Pace.flexible,
            icon: Icons.self_improvement_outlined,
            title: l.onboardingPaceFlexibleTitle,
            body: l.onboardingPaceFlexibleBody,
            onTap: () => setState(() => _pace = Pace.flexible),
          ),
          const SizedBox(height: 16),
          _Point(icon: Icons.lock_open_outlined, body: l.onboardingPaceNoLock),
        ],
      ),
      OnboardingStep.name => _SetupPage(
        step: _step,
        title: l.onboardingNameTitle,
        subtitle: l.onboardingNameIntro,
        onBack: _back,
        action: _nextButton(l),
        children: [
          TextField(
            key: const ValueKey('onboarding-name'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            enableSuggestions: false,
            inputFormatters: [LengthLimitingTextInputFormatter(40)],
            onSubmitted: (_) => _next(),
            decoration: InputDecoration(
              labelText: l.onboardingNameLabel,
              helperText: l.onboardingNameHelp,
              helperMaxLines: 4,
            ),
          ),
        ],
      ),
      OnboardingStep.privacy => _SetupPage(
        step: _step,
        title: l.onboardingPrivacyTitle,
        onBack: _back,
        action: PrimaryButton(
          key: const ValueKey('onboarding-finish'),
          label: l.onboardingFinish,
          trailingIcon: Icons.arrow_forward,
          expand: true,
          busy: _finishing,
          onPressed: _adult ? _finish : null,
        ),
        hint: _adult ? null : l.onboardingAdultRequired,
        children: const [_PrivacyCard()],
      ),
    };
  }

  Widget _nextButton(AppLocalizations l) => PrimaryButton(
    key: const ValueKey('onboarding-next'),
    label: l.onboardingNext,
    trailingIcon: Icons.arrow_forward,
    expand: true,
    onPressed: _next,
  );
}

// ── Intro (hero) pages ──────────────────────────────────────────────────────

/// Brand page and carousel: forest hero surface in both brightnesses, bronze
/// pill, Skip, page dots, swipe.
class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.step,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.onSwipe,
    required this.nextLabel,
    required this.child,
  });

  final OnboardingStep step;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final GestureDragEndCallback onSwipe;
  final String nextLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OnHeroTheme(
      child: Builder(
        builder: (context) {
          final p = CarthaPalette.of(context);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: CarthaTheme.systemUiStyle(Brightness.dark),
            child: Scaffold(
              backgroundColor: p.hero,
              body: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: onSwipe,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      _TopBar(
                        onBack: step.previous == null ? null : onBack,
                        trailing: Semantics(
                          button: true,
                          label: l.onboardingSkipLabel,
                          onTap: onSkip,
                          excludeSemantics: true,
                          child: TextLinkButton(
                            key: const ValueKey('onboarding-skip'),
                            label: l.onboardingSkip,
                            onPressed: onSkip,
                          ),
                        ),
                      ),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: _BottomBar(
                children: [
                  if (step.carouselPosition != null) ...[
                    _PageDots(current: step.carouselPosition!),
                    const SizedBox(height: 16),
                  ],
                  PrimaryButton(
                    key: const ValueKey('onboarding-next'),
                    label: nextLabel,
                    trailingIcon: Icons.arrow_forward,
                    expand: true,
                    onPressed: onNext,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Scrollable column with a centred max width (phones → tablets).
class _Scroll extends StatelessWidget {
  const _Scroll({required this.children, this.padding = EdgeInsets.zero});

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: padding,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    ),
  );
}

class _BrandContent extends StatelessWidget {
  const _BrandContent();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth - 48, 300.0);
        return _Scroll(
          children: [
            const SizedBox(height: 8),
            Center(
              child: CarthaEmblem(
                size: math.min(150, width * 0.55),
                color: p.heroAccent,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: CarthaWordmark(
                layout: WordmarkLayout.lettering,
                width: width,
                onHero: true,
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              child: Text(
                l.appTagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(color: p.onHero),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                key: const ValueKey('onboarding-rule'),
                width: 56,
                height: 2,
                color: p.heroAccent,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 32),
              child: Text(
                l.onboardingBrandIntro,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.onHeroMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _FadedScene(
              fadeTop: true,
              aspectRatio: 16 / 9,
              child: DawnRuinsScene(aspectRatio: null),
            ),
          ],
        );
      },
    );
  }
}

class _CarouselContent extends StatelessWidget {
  const _CarouselContent({required this.step});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final (Widget scene, String title, String body) = switch (step) {
      OnboardingStep.understand => (
        const SunriseScene(aspectRatio: null),
        l.onboardingUnderstandTitle,
        l.onboardingUnderstandBody,
      ),
      OnboardingStep.reset => (
        const PathScene(aspectRatio: null),
        l.onboardingResetTitle,
        l.onboardingResetBody,
      ),
      OnboardingStep.direction => (
        const CompassScene(aspectRatio: null),
        l.onboardingDirectionTitle,
        l.onboardingDirectionBody,
      ),
      _ => (
        const StepsScene(aspectRatio: null),
        l.onboardingStepsTitle,
        l.onboardingStepsBody,
      ),
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        // The scene takes up to ~half the page, keeping its proportions.
        final maxHeight = (constraints.maxHeight * 0.5).clamp(140.0, 520.0);
        final width = math.min(constraints.maxWidth, 600.0);
        final height = math.min(width / kSceneAspectRatio, maxHeight);
        return _Scroll(
          children: [
            Center(
              child: SizedBox(
                width: math.min(width, height * kSceneAspectRatio),
                height: height,
                child: _FadedScene(child: scene),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 28),
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: p.onHero,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 16),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(color: p.onHero),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A scene that melts into the hero background at its bottom (and top).
/// With an [aspectRatio] it sizes itself; otherwise it fills its parent.
class _FadedScene extends StatelessWidget {
  const _FadedScene({
    required this.child,
    this.fadeTop = false,
    this.aspectRatio,
  });

  /// A scene built with `aspectRatio: null` (fills this box).
  final Widget child;
  final bool fadeTop;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final clear = p.hero.withValues(alpha: 0);
    return Stack(
      children: [
        if (aspectRatio != null) AspectRatio(aspectRatio: aspectRatio!),
        Positioned.fill(child: child),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: fadeTop
                      ? [p.hero, clear, clear, p.hero]
                      : [clear, clear, p.hero],
                  stops: fadeTop ? const [0, 0.25, 0.8, 1] : const [0, 0.7, 1],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current});

  /// 1-based.
  final int current;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    const total = OnboardingStep.carouselLength;
    return Semantics(
      label: l.onboardingPageDots(current, total),
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 1; i <= total; i++)
            Container(
              key: ValueKey(
                'onboarding-dot-$i${i == current ? '-active' : ''}',
              ),
              margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
              // The current page is a longer pill, not only another colour.
              width: i == current ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == current
                    ? p.heroAccent
                    : p.onHeroMuted.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Setup pages ─────────────────────────────────────────────────────────────

class _SetupPage extends StatelessWidget {
  const _SetupPage({
    required this.step,
    required this.title,
    required this.onBack,
    required this.action,
    required this.children,
    this.subtitle,
    this.hint,
  });

  final OnboardingStep step;
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget action;

  /// Why the action is disabled (shown in words, not only by its colour).
  final String? hint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              onBack: onBack,
              trailing: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: Text(
                  l.onboardingStepCounter(
                    step.setupPosition!,
                    OnboardingStep.setupLength,
                  ),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _Scroll(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
                children: [
                  ScreenHeader(
                    title: title,
                    subtitle: subtitle,
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 20),
                  ),
                  ...children,
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        children: [
          if (hint != null) ...[
            Semantics(
              liveRegion: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 18, color: p.textSecondary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(hint!, style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          action,
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack, this.trailing});

  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 8, 0),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              key: const ValueKey('onboarding-back'),
              icon: const Icon(Icons.arrow_back),
              tooltip: l.back,
              onPressed: onBack,
            )
          else
            const SizedBox(width: 48, height: 48),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 16),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    ),
  );
}

/// An icon + optional title + body line.
class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.body, this.title});

  final IconData icon;
  final String? title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 2),
          child: Icon(icon, size: 22, color: p.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title!, style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
              ],
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: title == null ? p.textPrimary : p.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LimitsCard extends StatelessWidget {
  const _LimitsCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final points = [
      (
        Icons.wb_twilight_outlined,
        l.onboardingLimitsClarityTitle,
        l.onboardingLimitsClarityBody,
      ),
      (
        Icons.timelapse_outlined,
        l.onboardingLimitsNoGuaranteeTitle,
        l.onboardingLimitsNoGuaranteeBody,
      ),
      (
        Icons.autorenew,
        l.onboardingLimitsPracticeTitle,
        l.onboardingLimitsPracticeBody,
      ),
      (
        Icons.health_and_safety_outlined,
        l.onboardingLimitsNotTherapyTitle,
        l.onboardingLimitsNotTherapyBody,
      ),
      (
        Icons.tune,
        l.onboardingLimitsControlTitle,
        l.onboardingLimitsControlBody,
      ),
    ];
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (icon, title, body)) in points.indexed) ...[
            if (i > 0) const SizedBox(height: 16),
            _Point(icon: icon, title: title, body: body),
          ],
        ],
      ),
    );
  }
}

class _AdultCard extends StatelessWidget {
  const _AdultCard({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    return Material(
      color: value ? p.selection : p.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CarthaTheme.radius),
        side: p.selectionSide(value),
      ),
      clipBehavior: Clip.antiAlias,
      child: CheckboxListTile(
        key: const ValueKey('onboarding-adult'),
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 8, 16, 8),
        title: Text(l.onboardingAdultConfirm),
        subtitle: Text(l.onboardingAdultConfirmHelp),
      ),
    );
  }
}

class _CreditCard extends StatelessWidget {
  const _CreditCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final credit = context.read<AppState>().content.credit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.onboardingCreditIntro,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '“${credit.title}”',
                key: const ValueKey('onboarding-credit-title'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l.onboardingCreditByline(credit.author, credit.publishedOn),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SecondaryButton(
                key: const ValueKey('onboarding-credit-article'),
                label: l.onboardingCreditArticle,
                trailingIcon: Icons.open_in_new,
                expand: true,
                onPressed: () =>
                    openExternalLink(context, Uri.parse(credit.articleUrl)),
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                key: const ValueKey('onboarding-credit-newsletter'),
                label: l.onboardingCreditNewsletter,
                trailingIcon: Icons.open_in_new,
                expand: true,
                onPressed: () =>
                    openExternalLink(context, Uri.parse(credit.newsletterUrl)),
              ),
              const SizedBox(height: 16),
              Text(credit.independenceNotice, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(credit.paraphraseNotice, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Point(icon: Icons.lightbulb_outline, body: l.onboardingCreditNoNeed),
      ],
    );
  }
}

class _PaceChoice extends StatelessWidget {
  const _PaceChoice({
    required this.pace,
    required this.selected,
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final Pace pace;
  final bool selected;
  final IconData icon;
  final String title;
  final String body;
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
        key: ValueKey('onboarding-pace-${pace.name}'),
        color: selected ? p.selection : p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarthaTheme.radius),
          side: p.selectionSide(selected),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selection is a filled radio mark, not only a colour.
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? p.accent : p.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 20, color: p.accent),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        body,
                        style: theme.textTheme.bodyMedium?.copyWith(
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
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: l.onboardingPrivacyStorageHeading,
          icon: Icons.phone_android_outlined,
          child: Text(
            state.storageDescription,
            key: const ValueKey('onboarding-storage'),
          ),
        ),
        const SizedBox(height: 16),
        _Point(
          icon: Icons.cloud_off_outlined,
          body: l.onboardingPrivacyNoAccount,
        ),
        const SizedBox(height: 12),
        _Point(icon: Icons.ios_share, body: l.onboardingPrivacyControl),
      ],
    );
  }
}
