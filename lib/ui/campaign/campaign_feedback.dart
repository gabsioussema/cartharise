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
/// and "New for your avatar: …" when an extra opens. Only for an action
/// (a quest, an attempt, a review): never while typing an answer (reflection
/// XP, a chapter it completes, its achievement and extra, and a route stop
/// it reaches all stay quiet; the Campaign shows them), never twice for the
/// same extra (extras are kept for good), never for a restore (large jumps
/// are ignored), never with the game layer off. Shown at the top for about
/// two seconds and announced to screen readers.
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

/// Achievements earned by a discrete action (a quest, an attempt), not by
/// typing answers: the only ones a moment may announce on their own.
const _actionAchievements = {Achievement.practitioner, Achievement.challenger};

class _CampaignFeedbackState extends State<CampaignFeedback> {
  AppState? _state;
  int _actionXp = 0;

  /// Achievements seen this session: earning one again (a quest unticked,
  /// then ticked) is not a new moment.
  Set<Achievement> _earned = const {};

  /// Extras open before the last change (kept for good, so it only grows
  /// while the game layer is on).
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
    _unlocks = state.avatarUnlocks;
  }

  void _onChange() {
    final state = _state;
    if (state == null || !state.loaded || !mounted) return;
    // "Delete all data": start over, nothing to celebrate.
    if (state.data.profile == null) return _rebase();
    final c = state.campaign;
    final gained = c.xpFromActions - _actionXp;
    final newly = c.earned.difference(_earned);
    // Opened by progress just now, and not kept from before (the change has
    // already been folded into the kept set, so compare with the last one).
    final opened = unlockedBy(
      c,
      gameOn: state.gameEnabled,
    ).difference(_unlocks);
    _actionXp = c.xpFromActions;
    _earned = {..._earned, ...c.earned};
    _unlocks = state.avatarUnlocks;
    // A bulk change (a restored backup) is not a moment to celebrate.
    const most = CampaignFeedback.maxCelebratedUnlocks;
    final bulk =
        gained > CampaignFeedback.maxCelebratedXp ||
        newly.length > most ||
        opened.length > most;
    if (!state.gameEnabled || bulk) return;
    // Only an action is a moment: what typing answers opens (a chapter's
    // achievement and its extra, a route stop) stays quiet.
    bool byAction(Achievement? a) =>
        gained > 0 || (a != null && _actionAchievements.contains(a));
    if (gained > 0) _pendingXp += gained;
    _pendingAchievements.addAll([
      for (final a in Achievement.values)
        if (newly.contains(a) && byAction(a)) a,
    ]);
    final worn = state.persona?.avatar;
    _pendingUnlocks.addAll([
      for (final u in kUnlockOrder)
        if (opened.contains(u) &&
            // Already worn (from before the game layer was on): not new.
            !(worn?.uses(u) ?? false) &&
            byAction(unlockSource(u).achievement))
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
