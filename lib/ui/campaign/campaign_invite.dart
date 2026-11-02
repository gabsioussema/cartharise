import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// The one-time invitation to play the Campaign, for users who started with
/// it off (a brand-new profile: `AppSettings.gameInvited` false). Shown by
/// Today and the Campaign hub while [CampaignInviteOps.campaignInvitePending]:
/// "Play the Campaign?", one short line, **Play** and **Not now**. Both
/// answer it for good ([CampaignInviteOps.answerCampaignInvite]); Not now
/// leaves the switch in You › The Campaign. Renders nothing once answered.
class CampaignInviteCard extends StatefulWidget {
  const CampaignInviteCard({super.key});

  @override
  State<CampaignInviteCard> createState() => _CampaignInviteCardState();
}

class _CampaignInviteCardState extends State<CampaignInviteCard> {
  bool _busy = false;

  Future<void> _answer({required bool play}) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    setState(() => _busy = true);
    await state.answerCampaignInvite(play: play);
    if (mounted) setState(() => _busy = false);
    messenger?.hideCurrentSnackBar();
    if (state.saveStatus == SaveStatus.failed) {
      // The answer holds for now; it isn't on the phone yet.
      messenger?.showSnackBar(SnackBar(content: Text(l.campaignNotSavedYet)));
      return;
    }
    messenger?.showSnackBar(
      SnackBar(
        content: Text(play ? l.campaignInvitePlaying : l.campaignInviteLater),
        action: play
            ? SnackBarAction(
                label: l.campaignTodayOpen,
                onPressed: () {
                  // The card stays mounted (it just renders nothing now).
                  if (mounted) AppNav.openCampaign(context);
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = context.select<AppState, bool>(
      (s) => s.campaignInvitePending,
    );
    if (!pending) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return SectionCard(
      key: const ValueKey('campaign-invite'),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlyphIcon(CarthaGlyph.progress, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l.campaignInviteTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.campaignInviteBody,
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
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PrimaryButton(
                key: const ValueKey('campaign-invite-play'),
                label: l.campaignInvitePlay,
                busy: _busy,
                onPressed: () => _answer(play: true),
              ),
              TextLinkButton(
                key: const ValueKey('campaign-invite-later'),
                label: l.notNow,
                onPressed: _busy ? null : () => _answer(play: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The invitation's state and answer, on top of [AppState.updateSettings].
extension CampaignInviteOps on AppState {
  /// Whether the invitation is still unanswered.
  bool get campaignInvitePending => !settings.gameInvited;

  /// Answers the invitation once and for all: [play] turns the Campaign on;
  /// "Not now" leaves it off (You › The Campaign can turn it on later).
  Future<void> answerCampaignInvite({required bool play}) => updateSettings(
    settings.copyWith(gameInvited: true, game: play ? true : null),
  );
}
