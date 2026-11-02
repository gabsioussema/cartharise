import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../domain/campaign.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/motion.dart';
import 'campaign_copy.dart';
import 'campaign_ops.dart';

/// Calm Campaign moments (F-060): a short "+20 XP" when a quest, an attempt,
/// a weekly review or a first try of an experiment adds XP, and
/// "Achievement earned: …" when one is earned. Only for an action: never
/// while typing an answer (reflection XP, a chapter it completes, its
/// achievement, and a route stop it reaches all stay quiet; the Campaign
/// shows them), never for a restore (large jumps, or more reward picks at
/// once than one action can earn, are ignored), never with the game layer
/// off. Avatar extras no longer open by themselves (progress gives reward
/// picks, spent by the user), so no extra is announced as new. Shown at the
/// top for about two seconds and announced to screen readers.
class CampaignFeedback extends StatefulWidget {
  const CampaignFeedback({super.key, required this.child});

  final Widget child;

  /// Larger jumps at once (a restored backup) are not celebrated.
  static const maxCelebratedXp = 60;

  /// More reward picks (or achievements) at once than one action can earn
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

  /// The most reward picks seen this session ([rewardPicksEarned]): picks
  /// earned again after progress went down and up are not new.
  int _picks = 0;
  int _pendingXp = 0;
  final _pendingAchievements = <Achievement>[];
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
    _picks = rewardPicksEarned(c);
  }

  void _onChange() {
    final state = _state;
    if (state == null || !state.loaded || !mounted) return;
    // "Delete all data": start over, nothing to celebrate.
    if (state.data.profile == null) return _rebase();
    final c = state.campaign;
    final gained = c.xpFromActions - _actionXp;
    final newly = c.earned.difference(_earned);
    final picks = rewardPicksEarned(c);
    final newPicks = picks - _picks;
    _actionXp = c.xpFromActions;
    _earned = {..._earned, ...c.earned};
    if (picks > _picks) _picks = picks;
    // A bulk change (a restored backup) is not a moment to celebrate.
    const most = CampaignFeedback.maxCelebratedUnlocks;
    final bulk =
        gained > CampaignFeedback.maxCelebratedXp ||
        newly.length > most ||
        newPicks > most;
    if (!state.gameEnabled || bulk) return;
    // Only an action is a moment: what typing answers reaches (a chapter's
    // achievement, a route stop) stays quiet.
    bool byAction(Achievement a) =>
        gained > 0 || _actionAchievements.contains(a);
    if (gained > 0) _pendingXp += gained;
    _pendingAchievements.addAll([
      for (final a in Achievement.values)
        if (newly.contains(a) && byAction(a)) a,
    ]);
    if (_pendingXp == 0 && _pendingAchievements.isEmpty) return;
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
    ];
    _pendingXp = 0;
    _pendingAchievements.clear();
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
