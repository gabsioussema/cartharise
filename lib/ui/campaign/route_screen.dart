import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../journal/journal_kit.dart';
import '../nav.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'campaign_kit.dart';
import 'campaign_ops.dart';

/// The Route page: Hannibal's route in full (every stop, reached or how far
/// away), the strategist's map of the user's own Compass (F-058, F-063) and
/// Act II, the 30-day becoming (F-064).
class CampaignRouteScreen extends StatelessWidget {
  const CampaignRouteScreen({
    super.key,
    this.onOpenCompass,
    this.onOpenMissions,
  });

  /// Shows the Compass section (default: [AppNav.openCompass]).
  final VoidCallback? onOpenCompass;

  /// Shows the Missions section (default: [AppNav.openMissions]).
  final VoidCallback? onOpenMissions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final progress = state.campaign;
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    final openCompass = onOpenCompass ?? () => AppNav.openCompass(context);
    final openMissions = onOpenMissions ?? () => AppNav.openMissions(context);
    return CampaignScreen(
      title: l.campaignRouteTitle,
      subtitle: l.campaignRouteSubtitle,
      children: [
        HeroCard(
          eyebrow: l.campaignStatusEyebrow,
          title: l.campaignLevel(progress.level, progress.xp),
          child: OnHeroTheme(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CampaignRouteMap(
                  id: 'route-map',
                  progress: progress,
                  avatar: state.persona?.avatar,
                  avatarSize: 44,
                ),
                const SizedBox(height: 12),
                Text(
                  l.campaignXpNote,
                  style: theme.textTheme.bodyMedium?.copyWith(color: p.onHero),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextLinkButton(
                    key: const ValueKey('route-xp-how'),
                    label: l.campaignXpHow,
                    icon: Icons.info_outline,
                    onPressed: () => showXpRules(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        AreaSectionLabel(l.campaignRouteStops),
        SectionCard(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, w) in Waypoint.values.indexed) ...[
                if (i > 0) Divider(color: p.border, height: 1),
                _StopRow(waypoint: w, progress: progress),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        SectionCard(
          title: l.campaignMapTitle,
          icon: Icons.map_outlined,
          child: _StrategistMap(
            compass: state.compass,
            onEdit: openCompass,
            onQuests: openMissions,
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: l.campaignActTwo,
          icon: Icons.route_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.campaignActTwoBody, style: secondary),
              const SizedBox(height: 12),
              CampaignGrid(
                minWidth: 96,
                children: [
                  CampaignStat(
                    value: progress.questsCompleted,
                    label: l.campaignStatQuests,
                  ),
                  CampaignStat(
                    value: progress.pathDaysWritten,
                    label: l.campaignStatPath,
                  ),
                  CampaignStat(
                    value: progress.attempts,
                    label: l.campaignStatAttempts,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SecondaryButton(
                    key: const ValueKey('route-continue-path'),
                    label: l.campaignContinuePath,
                    trailingIcon: Icons.arrow_forward,
                    onPressed: openMissions,
                  ),
                  TextLinkButton(
                    label: l.campaignReadArticle,
                    trailingIcon: Icons.open_in_new,
                    onPressed: () => openExternalLink(
                      context,
                      Uri.parse(state.content.credit.articleUrl),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l.campaignNote,
          style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
      ],
    );
  }
}

/// One stop of the route: its place and whether it is where the user is,
/// reached, or how much XP away — in words and by icon, never colour alone.
class _StopRow extends StatelessWidget {
  const _StopRow({required this.waypoint, required this.progress});

  final Waypoint waypoint;
  final CampaignProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final i = waypoint.index;
    final here = i == progress.waypoint.index;
    final reached = i < progress.waypoint.index;
    final (icon, status) = here
        ? (Icons.location_on, l.campaignRouteStopHere)
        : reached
        ? (Icons.check_circle_outline, l.campaignRouteStopReached)
        : (
            Icons.radio_button_unchecked,
            l.campaignRouteStopAhead(i * kXpPerLevel - progress.xp),
          );
    final name = place(l, waypoint);
    return MergeSemantics(
      child: Padding(
        key: ValueKey('route-stop-${waypoint.name}'),
        padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: here || reached ? p.accent : p.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Place names start a line: "The Ebro".
                    name.isEmpty
                        ? name
                        : name[0].toUpperCase() + name.substring(1),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: here ? FontWeight.w700 : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
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
    );
  }
}

/// The six Compass components with their game roles (F-058); boundaries
/// stay visible as the rules of engagement (F-063). The user's own words, or
/// "Not written yet."
class _StrategistMap extends StatelessWidget {
  const _StrategistMap({
    required this.compass,
    required this.onEdit,
    required this.onQuests,
  });

  final LifeCompass compass;
  final VoidCallback onEdit;
  final VoidCallback onQuests;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final rows = [
      (CompassField.antiVision, l.campaignMapAntiVision),
      (CompassField.vision, l.campaignMapVision),
      (CompassField.yearGoal, l.campaignMapYear),
      (CompassField.monthProject, l.campaignMapMonth),
      (CompassField.dailyLevers, l.campaignMapLevers),
      (CompassField.constraints, l.campaignMapBoundaries),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (field, label)) in rows.indexed) ...[
          if (i > 0) Divider(color: p.border, height: 1),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                if (compass.get(field).trim().isEmpty)
                  Text(
                    l.campaignMapEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Text(compass.get(field), style: theme.textTheme.bodyMedium),
                if (field == CompassField.constraints) ...[
                  const SizedBox(height: 6),
                  ChipTag(
                    label: l.campaignMapBoundariesNote,
                    icon: Icons.shield_outlined,
                    tone: ChipTone.accent,
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PrimaryButton(
              key: const ValueKey('campaign-map-edit'),
              label: l.campaignMapEdit,
              trailingIcon: Icons.arrow_forward,
              onPressed: onEdit,
            ),
            SecondaryButton(
              key: const ValueKey('campaign-map-quests'),
              label: l.campaignMapQuests,
              onPressed: onQuests,
            ),
          ],
        ),
      ],
    );
  }
}
