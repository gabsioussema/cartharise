import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/campaign.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'campaign_ops.dart';

/// "The Campaign" on Today (only while the game layer is on): level, XP
/// towards the next level and achievements, opening the Campaign.
class CampaignTodayCard extends StatelessWidget {
  const CampaignTodayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final progress = context.watch<AppState>().campaign;
    final toNext = l.campaignLevelProgress(
      progress.levelXp,
      kXpPerLevel,
      progress.level + 1,
    );
    return SectionCard(
      key: const ValueKey('today-campaign'),
      title: l.campaignTodayTitle,
      icon: Icons.flag_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.campaignLevel(progress.level, progress.xp),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.levelXp / kXpPerLevel,
              minHeight: 6,
              semanticsLabel: toNext,
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(
            child: Text(toNext, style: theme.textTheme.bodySmall),
          ),
          const SizedBox(height: 4),
          Text(
            l.campaignTodayAchievements(
              progress.earned.length,
              Achievement.values.length,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextLinkButton(
              key: const ValueKey('today-campaign-open'),
              label: l.campaignTodayOpen,
              trailingIcon: Icons.arrow_forward,
              onPressed: () => AppNav.openCampaign(context),
            ),
          ),
        ],
      ),
    );
  }
}
