import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../persona/avatar_view.dart';
import '../persona/persona_copy.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/bidi.dart';
import '../widgets/widgets.dart';
import 'campaign_kit.dart';
import 'campaign_ops.dart';
import 'reward_sheet.dart';

/// **Make it yours**: the user's avatar and motto ("Your strategist") with
/// the way into the builder, and **Choose your reward** while a reward pick
/// is left. Appearance is always free; the extras are cosmetic and never
/// taken away. With the Campaign off it says that every extra is open.
class MakeItYoursScreen extends StatelessWidget {
  const MakeItYoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return CampaignScreen(
      title: l.campaignYoursTitle,
      subtitle: l.campaignYoursScreenSubtitle,
      children: const [StrategistCard(), SizedBox(height: 16), _RewardCard()],
    );
  }
}

/// "Your strategist": the avatar (or the emblem), the motto exactly as typed
/// (or a nudge), how many extras are the user's, and Create / Edit.
class StrategistCard extends StatelessWidget {
  const StrategistCard({super.key});

  /// Below this text width (scaled with the text size) the avatar sits above
  /// the words instead of beside them.
  static const _minTextWidth = 150.0;

  static const _portrait = 88.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final persona = state.persona;
    final avatar = persona?.avatar;
    // Extras chosen, kept or worn stay the user's (never taken away); with
    // the game layer off every extra is open.
    final open = {...state.avatarUnlocks, ...wornBy(avatar)};
    final motto = persona?.motto ?? '';
    final hasMotto = motto.trim().isNotEmpty;
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (persona == null)
          Text(
            l.campaignStrategistEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          )
        else if (hasMotto)
          // The motto exactly as typed.
          Text(
            motto,
            key: const ValueKey('campaign-strategist-motto'),
            textDirection: textDirectionOf(motto),
            style: theme.textTheme.titleSmall?.copyWith(
              fontStyle: CarthaFonts.of(context).italic,
            ),
          ),
        if (persona == null || hasMotto) const SizedBox(height: 6),
        Text(
          l.campaignExtrasCount(open.length, Unlockable.values.length),
          key: const ValueKey('campaign-extras-count'),
          style: theme.textTheme.labelLarge,
        ),
      ],
    );
    // Without an avatar the words say it; the emblem is decoration.
    final portrait = AvatarView(
      avatar: avatar,
      size: _portrait,
      excludeFromSemantics: avatar == null,
    );
    return SectionCard(
      key: const ValueKey('campaign-strategist'),
      title: l.personaFeatureTitle,
      icon: Icons.person_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(1);
              final beside =
                  constraints.maxWidth - _portrait - 16 >=
                  _minTextWidth * scale;
              if (!beside) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [portrait, const SizedBox(height: 12), words],
                );
              }
              return Row(
                children: [
                  portrait,
                  const SizedBox(width: 16),
                  Expanded(child: words),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SecondaryButton(
              key: const ValueKey('campaign-strategist-open'),
              label: persona == null ? l.personaCreate : l.personaEdit,
              icon: persona == null ? Icons.add : Icons.edit_outlined,
              onPressed: () => AppNav.openPersonaBuilder(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reward picks: how many are left and **Choose your reward**; with none
/// left, when the next one comes; with every extra the user's, that said
/// plainly — and only then.
class _RewardCard extends StatelessWidget {
  const _RewardCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    final picks = state.picksLeft;
    final choices = state.rewardChoices;
    final Widget body;
    if (!state.gameEnabled) {
      body = Text(l.campaignRewardGameOff, style: secondary);
    } else if (choices.isEmpty) {
      body = Text(
        l.campaignExtrasAll,
        key: const ValueKey('campaign-strategist-next'),
        style: secondary,
      );
    } else if (picks > 0) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.campaignRewardPicks(picks),
            key: const ValueKey('campaign-reward-picks'),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l.campaignRewardSuggestedLine(unlockableName(l, choices.first)),
            style: secondary,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            key: const ValueKey('campaign-reward-open'),
            label: l.campaignRewardTitle,
            icon: Icons.redeem_outlined,
            onPressed: () => showRewardSheet(context),
          ),
        ],
      );
    } else {
      body = Text(
        nextPickReason(l, state.campaign) ?? l.campaignRewardNone,
        key: const ValueKey('campaign-strategist-next'),
        style: secondary,
      );
    }
    return SectionCard(
      key: const ValueKey('campaign-reward'),
      title: l.campaignRewardCardTitle,
      icon: Icons.redeem_outlined,
      child: body,
    );
  }
}
