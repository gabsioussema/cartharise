import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/campaign.dart';
import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../persona/avatar_view.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/route_scenes.dart';
import '../widgets/widgets.dart';
import 'campaign_invite.dart';
import 'campaign_kit.dart';
import 'campaign_ops.dart';
import 'campaign_pages.dart';
import 'route_screen.dart';

/// The Campaign section of the Compass tab (F-058–F-064), as a compact hub
/// while the game layer is on (off, the section is the [PlaygroundView]):
/// where the user is on Hannibal's route, three invitations (**Notice**,
/// **Try**, **Make it yours**) and small links to the Route, the Chapters,
/// the Battle log and the Collection, each on its own page.
///
/// XP and achievements come only from observable participation; nothing is
/// ever taken away, and the whole layer can be turned off in You.
class CampaignView extends StatelessWidget {
  const CampaignView({
    super.key,
    required this.onOpenCompass,
    required this.onOpenMissions,
  });

  /// Shows the Compass section (to write or revise the strategy).
  final VoidCallback onOpenCompass;

  /// Shows the Missions section (quests and the 30-day path).
  final VoidCallback onOpenMissions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final progress = state.campaign;

    void open(CampaignPage page) {
      // Typing elsewhere is saved before the page changes.
      FocusManager.instance.primaryFocus?.unfocus();
      if (page != CampaignPage.route) {
        pushCampaignScreen(context, campaignPageScreen(page));
        return;
      }
      // From the Route page, the map's buttons come back here and switch
      // the section in place.
      final navigator = Navigator.of(context);
      pushCampaignScreen(
        context,
        CampaignRouteScreen(
          onOpenCompass: () {
            navigator.pop();
            onOpenCompass();
          },
          onOpenMissions: () {
            navigator.pop();
            onOpenMissions();
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: SaveIndicator(),
          ),
          const SizedBox(height: 8),
          _StatusCard(progress: progress, avatar: state.persona?.avatar),
          const SizedBox(height: 16),
          PlaygroundInvitations(onOpen: open),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 0,
            children: [
              TextLinkButton(
                key: const ValueKey('campaign-link-route'),
                label: l.campaignLinkRoute,
                icon: Icons.map_outlined,
                onPressed: () => open(CampaignPage.route),
              ),
              TextLinkButton(
                key: const ValueKey('campaign-link-chapters'),
                label: l.campaignLinkChapters,
                icon: Icons.menu_book_outlined,
                onPressed: () => open(CampaignPage.chapters),
              ),
              TextLinkButton(
                key: const ValueKey('campaign-link-log'),
                // A kept draft is said, so the words are easy to find.
                label: state.attemptDraft == null
                    ? l.campaignLinkBattleLog
                    : l.campaignLinkBattleLogDraft,
                icon: Icons.shield_outlined,
                onPressed: () => open(CampaignPage.battleLog),
              ),
              TextLinkButton(
                key: const ValueKey('campaign-link-collection'),
                label: l.campaignLinkCollection,
                icon: Icons.collections_bookmark_outlined,
                onPressed: () => open(CampaignPage.collection),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.campaignNote,
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Level, the route with the avatar at the current stop over that stop's
/// painted landscape, and the XP to the next stop (F-060).
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.progress, required this.avatar});

  final CampaignProgress progress;

  /// The user's avatar (the emblem without one).
  final Avatar? avatar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return HeroCard(
      key: const ValueKey('campaign-status'),
      eyebrow: l.campaignStatusEyebrow,
      title: l.campaignLevel(progress.level, progress.xp),
      child: OnHeroTheme(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The current stop's landscape, the route and the avatar on it.
            RouteSceneWindow(
              key: const ValueKey('campaign-scene'),
              waypoint: progress.waypoint,
              semanticLabel: l.sceneryRouteScene(progress.waypoint.name),
              overlay: CampaignRouteMap(
                id: 'campaign-route',
                progress: progress,
                avatar: avatar,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.campaignRouteHere(place(l, progress.waypoint)),
              style: theme.textTheme.titleSmall?.copyWith(color: p.onHero),
            ),
            const SizedBox(height: 2),
            ExcludeSemantics(
              child: Text(
                progress.nextWaypoint == null
                    ? l.campaignRouteEnd
                    : l.campaignRouteNext(
                        progress.xpToNext,
                        place(l, progress.nextWaypoint!),
                      ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.onHeroMuted,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextLinkButton(
                key: const ValueKey('campaign-xp-how'),
                label: l.campaignXpHow,
                icon: Icons.info_outline,
                onPressed: () => showXpRules(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Playground's three invitations — **Notice** (the mirror), **Try**
/// (the seedling) and **Make it yours** (the user's own avatar, or the
/// emblem) — each a glyph or picture, a short name and one line. Shared by
/// the Campaign hub and, with the game layer off, the [PlaygroundView].
class PlaygroundInvitations extends StatelessWidget {
  const PlaygroundInvitations({super.key, required this.onOpen});

  final void Function(CampaignPage page) onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    // Always 0 with the game layer off (every extra is open then).
    final picks = state.picksLeft;
    return CampaignGrid(
      minWidth: 260,
      children: [
        CampaignInvitation(
          key: const ValueKey('campaign-open-notice'),
          leading: const GlyphIcon(CarthaGlyph.notice, size: 28),
          title: l.campaignNoticeTitle,
          line: l.campaignNoticeLine,
          onTap: () => onOpen(CampaignPage.notice),
        ),
        CampaignInvitation(
          key: const ValueKey('campaign-open-try'),
          leading: const GlyphIcon(CarthaGlyph.experiment, size: 28),
          title: l.campaignTryTitle,
          line: l.campaignTryLine,
          onTap: () => onOpen(CampaignPage.tryIt),
        ),
        CampaignInvitation(
          key: const ValueKey('campaign-open-yours'),
          // The avatar is its own cue (the emblem until there is one).
          leading: AvatarView(
            avatar: state.persona?.avatar,
            size: 32,
            excludeFromSemantics: true,
          ),
          title: l.campaignYoursTitle,
          line: picks > 0 ? l.campaignYoursPicks(picks) : l.campaignYoursLine,
          onTap: () => onOpen(CampaignPage.makeItYours),
        ),
      ],
    );
  }
}

/// The Compass tab's third section while the game layer is off: the
/// Playground without the game — the invitation (while unanswered), then
/// **Notice**, **Try** and **Make it yours**, and the **Collection** of what
/// was tried. No XP, levels, route or achievements.
class PlaygroundView extends StatelessWidget {
  const PlaygroundView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final pending = context.select<AppState, bool>(
      (s) => s.campaignInvitePending,
    );

    void open(CampaignPage page) {
      // Typing elsewhere is saved before the page changes.
      FocusManager.instance.primaryFocus?.unfocus();
      pushCampaignScreen(context, campaignPageScreen(page));
    }

    return Padding(
      key: const ValueKey('playground'),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: SaveIndicator(),
          ),
          const SizedBox(height: 8),
          if (pending) ...[
            const CampaignInviteCard(),
            const SizedBox(height: 16),
          ],
          PlaygroundInvitations(onOpen: open),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextLinkButton(
              key: const ValueKey('campaign-link-collection'),
              label: l.campaignLinkCollection,
              icon: Icons.collections_bookmark_outlined,
              onPressed: () => open(CampaignPage.collection),
            ),
          ),
          if (!pending) ...[
            const SizedBox(height: 8),
            Text(
              l.campaignPlaygroundGameOff,
              key: const ValueKey('playground-game-off'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One of the Playground's invitations: a glyph (or picture), a short name
/// and one line; the whole card opens its page.
class CampaignInvitation extends StatelessWidget {
  const CampaignInvitation({
    super.key,
    required this.leading,
    required this.title,
    required this.line,
    required this.onTap,
  });

  /// The idea's cue: a [GlyphIcon], or the avatar for "Make it yours".
  final Widget leading;
  final String title;
  final String line;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  line,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: p.textSecondary),
        ],
      ),
    );
  }
}
