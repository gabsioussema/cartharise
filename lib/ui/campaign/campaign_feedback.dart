import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../domain/campaign.dart';
import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../persona/persona_copy.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/motion.dart';
import 'campaign_copy.dart';
import 'campaign_ops.dart';

/// Calm Campaign moments (F-060): a short "+20 XP" when a quest, an attempt
/// or a weekly review adds XP, "Achievement earned: …" when one is earned,
/// and "New for your avatar: …" when an extra opens. Never while typing an
/// answer (reflection XP, and a route stop it reaches, stay quiet), never for
/// a restore (large jumps are ignored), never with the game layer off.
/// Shown at the top for about two seconds and announced to screen readers.
class CampaignFeedback extends StatefulWidget {
  const CampaignFeedback({super.key, required this.child});

  final Widget child;

  /// Larger jumps at once (a restored backup) are not celebrated.
  static const maxCelebratedXp = 60;

  /// More avatar extras (or achievements) at once than one action can open
  /// (a route stop and an achievement) is a bulk change, not a moment.
  static const maxCelebratedUnlocks = 2;

  /// Changes within this window become one moment.
  static const settle = Duration(milliseconds: 700);

  /// How long a moment stays on screen.
  static const visible = Duration(milliseconds: 2200);

  @override
  State<CampaignFeedback> createState() => _CampaignFeedbackState();
}

class _CampaignFeedbackState extends State<CampaignFeedback> {
  AppState? _state;
  int _actionXp = 0;
  Set<Achievement> _earned = const {};
  Set<Unlockable> _unlocks = const {};
  int _pendingXp = 0;
  final _pendingAchievements = <Achievement>[];
  final _pendingUnlocks = <Unlockable>{};
  Timer? _settle;
  Timer? _hide;
  OverlayEntry? _entry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_state != null) return;
    _state = context.read<AppState>()..addListener(_onChange);
    _rebase();
  }

  void _rebase() {
    final state = _state;
    if (state == null || !state.loaded) return;
    final c = state.campaign;
    _actionXp = c.xpFromActions;
    _earned = c.earned;
    _unlocks = unlockedBy(c, gameOn: state.gameEnabled);
  }

  void _onChange() {
    final state = _state;
    if (state == null || !state.loaded || !mounted) return;
    final c = state.campaign;
    final gained = c.xpFromActions - _actionXp;
    final newly = c.earned.difference(_earned);
    // Same derivation as PersonaOps.avatarUnlocks, from the progress above.
    final unlocks = unlockedBy(c, gameOn: state.gameEnabled);
    final opened = unlocks.difference(_unlocks);
    _actionXp = c.xpFromActions;
    _earned = c.earned;
    _unlocks = unlocks;
    // A bulk change (a restored backup) is not a moment to celebrate.
    const most = CampaignFeedback.maxCelebratedUnlocks;
    final bulk =
        gained > CampaignFeedback.maxCelebratedXp ||
        newly.length > most ||
        opened.length > most;
    if (!state.gameEnabled || bulk) return;
    if (gained > 0) _pendingXp += gained;
    _pendingAchievements.addAll(newly);
    final worn = state.persona?.avatar;
    _pendingUnlocks.addAll([
      for (final u in kUnlockOrder)
        if (opened.contains(u) &&
            // Already worn (from before the game layer was on): not new.
            !(worn?.uses(u) ?? false) &&
            // A stop reached by typing answers alone stays quiet.
            (gained > 0 || unlockSource(u).achievement != null))
          u,
    ]);
    if (_pendingXp == 0 &&
        _pendingAchievements.isEmpty &&
        _pendingUnlocks.isEmpty) {
      return;
    }
    _settle?.cancel();
    _settle = Timer(CampaignFeedback.settle, _show);
  }

  void _show() {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final lines = [
      if (_pendingXp > 0) l.campaignToastXp(_pendingXp),
      for (final a in _pendingAchievements)
        l.campaignToastAchievement(achievementName(l, a)),
      for (final u in _pendingUnlocks) l.personaUnlocked(unlockableName(l, u)),
    ];
    _pendingXp = 0;
    _pendingAchievements.clear();
    _pendingUnlocks.clear();
    final overlay = Navigator.maybeOf(context, rootNavigator: true)?.overlay;
    if (overlay == null) return;
    _remove();
    final animate = motionEnabled(context);
    _entry = OverlayEntry(
      builder: (_) => _Toast(lines: lines, animate: animate),
    );
    overlay.insert(_entry!);
    SemanticsService.sendAnnouncement(
      View.of(context),
      lines.join('. '),
      Directionality.of(context),
    );
    _hide = Timer(CampaignFeedback.visible, _remove);
  }

  void _remove() {
    _hide?.cancel();
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _state?.removeListener(_onChange);
    _settle?.cancel();
    _remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The moment itself: a hero pill at the top, fading in unless motion is off.
class _Toast extends StatelessWidget {
  const _Toast({required this.lines, required this.animate});

  final List<String> lines;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final pill = Material(
      key: const ValueKey('campaign-toast'),
      color: p.hero,
      shape: StadiumBorder(side: BorderSide(color: p.heroBorder)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 18, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 18, color: p.heroAccent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                lines.join('  ·  '),
                style: theme.textTheme.labelLarge?.copyWith(color: p.onHero),
              ),
            ),
          ],
        ),
      ),
    );
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: Center(
            child: animate
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 220),
                    builder: (_, t, child) => Opacity(opacity: t, child: child),
                    child: pill,
                  )
                : pill,
          ),
        ),
      ),
    );
  }
}
