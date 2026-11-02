import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/formatting.dart';
import '../journal/journal_kit.dart';
import '../persona/persona_copy.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'campaign_copy.dart';
import 'campaign_kit.dart';
import 'campaign_ops.dart';
import 'campaign_pages.dart';
import 'experiment_entry_sheet.dart';
import 'make_it_yours_screen.dart';
import 'try_screen.dart';

/// Keepsakes: the experiments tried (each with its note exactly as typed),
/// the achievements with their badges and how each was earned (by
/// reflecting, by trying or by doing), and the avatar extras chosen.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final progress = state.campaign;
    final log = state.experimentLog;
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    final owned = {
      ...state.data.avatarUnlocked,
      ...wornBy(state.persona?.avatar),
    };
    final next = progress.nextAchievement;
    return CampaignScreen(
      title: l.campaignCollectionTitle,
      subtitle: l.campaignCollectionSubtitle,
      children: [
        // ── Experiments tried ──────────────────────────────────────────
        AreaSectionLabel(l.campaignCollectionTried(progress.experimentsTried)),
        if (log.isEmpty)
          SectionCard(
            key: const ValueKey('collection-tried-empty'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.campaignCollectionTriedEmpty, style: secondary),
                const SizedBox(height: 4),
                TextLinkButton(
                  key: const ValueKey('collection-open-try'),
                  label: l.campaignTryOpen,
                  icon: GlyphIcon.placeholderFor(CarthaGlyph.experiment),
                  onPressed: () =>
                      pushCampaignScreen(context, const TryScreen()),
                ),
              ],
            ),
          )
        else
          for (final entry in log)
            _TriedRow(
              key: ValueKey('collection-tried-${entry.id}'),
              entry: entry,
            ),

        // ── Achievements ───────────────────────────────────────────────
        AreaSectionLabel(l.campaignAchievementsTitle),
        Text(
          l.campaignAchievementsCount(
            progress.earned.length,
            Achievement.values.length,
          ),
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 4),
        Text(l.campaignAchievementsSubtitle, style: secondary),
        const SizedBox(height: 2),
        Text(l.campaignAchievementsRoutes, style: secondary),
        if (next != null) ...[
          const SizedBox(height: 4),
          Text(
            l.campaignNextAchievement(
              achievementName(l, next),
              achievementBody(l, next),
            ),
            key: const ValueKey('campaign-next-achievement'),
            style: secondary,
          ),
        ],
        const SizedBox(height: 12),
        CampaignGrid(
          minWidth: 170,
          children: [
            for (final a in Achievement.values)
              _AchievementTile(
                key: ValueKey('collection-achievement-${a.name}'),
                achievement: a,
                route: progress.earnedBy[a],
              ),
          ],
        ),

        // ── Extras chosen ──────────────────────────────────────────────
        AreaSectionLabel(l.campaignCollectionExtras),
        if (!state.gameEnabled)
          Text(l.campaignRewardGameOff, style: secondary)
        else if (owned.isEmpty)
          Text(l.campaignCollectionExtrasEmpty, style: secondary)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final u in kUnlockOrder)
                if (owned.contains(u))
                  ChipTag(
                    key: ValueKey('collection-extra-${u.name}'),
                    label: unlockableName(l, u),
                    icon: Icons.lock_open,
                    tone: ChipTone.accent,
                  ),
            ],
          ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextLinkButton(
            key: const ValueKey('collection-open-yours'),
            label: l.campaignYoursTitle,
            trailingIcon: Icons.arrow_forward,
            onPressed: () =>
                pushCampaignScreen(context, const MakeItYoursScreen()),
          ),
        ),
      ],
    );
  }
}

/// One try: the experiment, its note exactly as typed, and the day. Tapping
/// it opens a sheet to correct the note or remove the try.
class _TriedRow extends StatelessWidget {
  const _TriedRow({super.key, required this.entry});

  final ExperimentEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.read<AppState>();
    final title =
        state.content.experiment(entry.experimentId)?.title ??
        l.campaignExperimentUnknown;
    final date = formatDayKey(context, entry.day);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Material(
        color: p.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => showExperimentEntrySheet(context, entry, title: title),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 6, 8, 6),
          leading: const GlyphIcon(CarthaGlyph.experiment),
          title: Text(title, style: theme.textTheme.bodyLarge),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.note.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                // The note exactly as typed.
                Text(entry.note, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: 4),
              Text(l.campaignTriedOn(date), style: theme.textTheme.bodySmall),
            ],
          ),
          trailing: Icon(
            Icons.edit_outlined,
            color: p.textSecondary,
            semanticLabel: l.campaignTriedEditLabel(date),
          ),
        ),
      ),
    );
  }
}

/// An achievement: its badge, name, what it asks, and — earned or not, in
/// words and by the badge's shape, never colour alone — how it was earned.
class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    super.key,
    required this.achievement,
    required this.route,
  });

  final Achievement achievement;

  /// How it was earned; null when not yet.
  final EarnedRoute? route;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final earned = route != null;
    final name = achievementName(l, achievement);
    final body = achievementBody(l, achievement);
    final status = route == null ? l.campaignNotYet : earnedByLabel(l, route!);
    return Semantics(
      container: true,
      label: [name, body, status].join('. '),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: earned ? p.selection : p.card,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          border: Border.all(color: earned ? p.accent : p.border),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AchievementBadge(achievement, earned: earned, size: 40),
              const SizedBox(height: 8),
              Text(name, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              CampaignStatusLine(
                icon: earned ? Icons.check_circle_outline : Icons.more_horiz,
                text: status,
                strong: earned,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
