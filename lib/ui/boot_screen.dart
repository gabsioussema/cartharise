import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'onboarding/onboarding_flow.dart';
import 'root_shell.dart';
import 'theme/cartha_theme.dart';
import 'widgets/buttons.dart';
import 'widgets/dialogs.dart';
import 'widgets/emblem.dart';
import 'widgets/loader.dart';
import 'widgets/motion.dart';
import 'widgets/wordmark.dart';

enum _BootPhase { loading, error, onboarding, app }

/// The first Flutter screen. Same forest background as the native splash, so
/// the hand-off is seamless: the emblem keeps "charging" (`CarthaLoader`)
/// while `AppState.load()` runs, then the app fades in — onboarding first
/// if needed. If the saved data can't be read, says so honestly (nothing was
/// deleted) and offers "Try again".
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  _BootPhase? _last;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    if (!state.loaded && !state.loading && state.loadError == null) {
      // After the first frame, so the loader is on screen while reading.
      WidgetsBinding.instance.addPostFrameCallback((_) => state.load());
    }
  }

  _BootPhase _phase(AppState s) {
    if (s.loadError != null) return _BootPhase.error;
    if (!s.loaded) return _BootPhase.loading;
    return s.needsOnboarding ? _BootPhase.onboarding : _BootPhase.app;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final phase = _phase(state);
    if (_last == _BootPhase.app && phase == _BootPhase.onboarding) {
      // "Replay welcome" or "Delete all data" from a pushed screen: close it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      });
    }
    _last = phase;
    final child = switch (phase) {
      _BootPhase.loading => const _BootView(),
      _BootPhase.error => const _BootView(failed: true),
      _BootPhase.onboarding => const OnboardingFlow(),
      _BootPhase.app => const RootShell(),
    };
    return AnimatedSwitcher(
      duration: motionEnabled(context)
          ? const Duration(milliseconds: 450)
          : Duration.zero,
      child: KeyedSubtree(key: ValueKey(phase), child: child),
    );
  }
}

class _BootView extends StatelessWidget {
  const _BootView({this.failed = false});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CarthaTheme.systemUiStyle(Brightness.dark),
      child: Scaffold(
        backgroundColor: p.hero,
        body: CustomPaint(
          painter: _RingsPainter(p.heroAccent),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: failed
                          ? _LoadError(palette: p, l: l, theme: theme)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 24),
                                CarthaLoader(
                                  size: 150,
                                  startAt: 0.6,
                                  showBar: true,
                                  color: p.heroAccent,
                                  glowColor: p.onHero,
                                ),
                                const SizedBox(height: 28),
                                const CarthaWordmark(
                                  layout: WordmarkLayout.lettering,
                                  width: 230,
                                  onHero: true,
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  l.appTagline.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: p.heroAccent,
                                    letterSpacing: 2.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  l.bootLoading,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: p.onHeroMuted,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.palette,
    required this.l,
    required this.theme,
  });

  final CarthaPalette palette;
  final AppLocalizations l;
  final ThemeData theme;

  Future<void> _startFresh(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: l.bootStartFreshConfirmTitle,
      body: l.bootStartFreshConfirmBody,
      action: l.bootStartFresh,
      destructive: true,
    );
    if (ok && context.mounted) {
      await context.read<AppState>().startFreshAfterLoadError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24),
        CarthaEmblem(size: 96, color: p.heroAccent),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            l.bootLoadErrorTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(color: p.onHero),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l.bootLoadErrorBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: p.onHero),
        ),
        const SizedBox(height: 8),
        Text(
          l.bootLoadErrorHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: p.onHeroMuted),
        ),
        const SizedBox(height: 24),
        Theme(
          // Bronze pill on the forest hero in both brightnesses.
          data: CarthaTheme.dark(),
          child: Builder(
            builder: (context) => Column(
              children: [
                PrimaryButton(
                  label: l.tryAgain,
                  icon: Icons.refresh,
                  expand: true,
                  onPressed: () => context.read<AppState>().load(),
                ),
                const SizedBox(height: 8),
                TextLinkButton(
                  label: l.bootStartFresh,
                  onPressed: () => _startFresh(context),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Faint concentric circles behind the emblem (splash reference).
class _RingsPainter extends CustomPainter {
  const _RingsPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final base = math.min(size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = 1; i <= 3; i++) {
      paint.color = color.withValues(alpha: 0.10 / i);
      canvas.drawCircle(center, base * (0.22 + 0.16 * i), paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => old.color != color;
}
