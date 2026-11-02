import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/formatting.dart';
import '../journal/journal_kit.dart';
import '../missions/project_history_screen.dart';
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

/// Keepsakes: the experiments tried (each experiment once, with every try
/// and its note exactly as typed), the achievements with their badges and
/// how each was earned (by reflecting, by trying — naming the experiment —
/// or by doing), the avatar extras chosen, and the month projects finished
/// (opening their history). With the Campaign off there are no achievements
/// to show: what was tried stays.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final progress = state.campaign;
    final game = state.gameEnabled;
    final groups = groupTries(state.experimentLog);
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    final owned = {
      ...state.data.avatarUnlocked,
      ...wornBy(state.persona?.avatar),
    };
    final next = progress.nextAchievement;
    String? experimentTitle(Achievement a) {
      final id = progress.earnedByExperiment[a];
      return id == null ? null : state.content.experiment(id)?.title;
    }

    return CampaignScreen(
      title: l.campaignCollectionTitle,
      subtitle: l.campaignCollectionSubtitle,
      children: [
        // ── Experiments tried ──────────────────────────────────────────
        // One row per experiment, so the count matches the rows.
        AreaSectionLabel(l.campaignCollectionTried(groups.length)),
        if (groups.isEmpty)
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
                  trailingIcon: Icons.arrow_forward,
                  onPressed: () =>
                      pushCampaignScreen(context, const TryScreen()),
                ),
              ],
            ),
          )
        else
          for (final tries in groups)
            _TriedGroup(
              key: ValueKey('collection-experiment-${tries.first.experimentId}'),
              tries: tries,
            ),

        // ── Achievements (the game layer only) ─────────────────────────
        if (game) ...[
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
                  experiment: experimentTitle(a),
                ),
            ],
          ),
        ],

        // ── Extras chosen ──────────────────────────────────────────────
        AreaSectionLabel(l.campaignCollectionExtras),
        if (!game)
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

        // ── Projects finished (nothing until one is) ───────────────────
        const PastProjectsKeepsake(),
      ],
    );
  }
}

/// [log] (newest first) grouped by experiment: one list per experiment,
/// its tries newest first, the most recently tried experiment first.
List<List<ExperimentEntry>> groupTries(List<ExperimentEntry> log) {
  final groups = <String, List<ExperimentEntry>>{};
  for (final e in log) {
    (groups[e.experimentId] ??= []).add(e);
  }
  return groups.values.toList();
}

/// One experiment and every try of it: its title once, then each try's day
/// and note exactly as typed. Tapping a try opens a sheet to correct its
/// note or remove it.
class _TriedGroup extends StatelessWidget {
  const _TriedGroup({super.key, required this.tries});

  /// The tries of one experiment, newest first (never empty).
  final List<ExperimentEntry> tries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.read<AppState>();
    final title =
        state.content.experiment(tries.first.experimentId)?.title ??
        l.campaignExperimentUnknown;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Material(
        color: p.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(top: 12, bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlyphIcon(CarthaGlyph.experiment),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title, style: theme.textTheme.bodyLarge),
                      ),
                    ),
                  ],
                ),
              ),
              for (final entry in tries)
                _TryRow(
                  key: ValueKey('collection-tried-${entry.id}'),
                  entry: entry,
                  title: title,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One try: its note exactly as typed and the day; opens the edit sheet.
class _TryRow extends StatelessWidget {
  const _TryRow({super.key, required this.entry, required this.title});

  final ExperimentEntry entry;

  /// The experiment's title (for the sheet).
  final String title;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final date = formatDayKey(context, entry.day);
    return InkWell(
      onTap: () => showExperimentEntrySheet(context, entry, title: title),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Padding(
          // Lined up under the title, past the glyph.
          padding: const EdgeInsetsDirectional.fromSTEB(50, 4, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.note.trim().isNotEmpty) ...[
                      // The note exactly as typed.
                      Text(entry.note, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      l.campaignTriedOn(date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsetsDirectional.all(4),
                child: Icon(
                  Icons.edit_outlined,
                  color: p.textSecondary,
                  semanticLabel: l.campaignTriedEditLabel(date),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An achievement: its badge, name, what it asks (present tense, never a
/// claim), and — earned or not, in words and by the badge's shape, never
/// colour alone — how it was earned, naming the experiment that earned it
/// by trying.
class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    super.key,
    required this.achievement,
    required this.route,
    this.experiment,
  });

  final Achievement achievement;

  /// How it was earned; null when not yet.
  final EarnedRoute? route;

  /// The title of the experiment that earned it by trying, when known.
  final String? experiment;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final earned = route != null;
    final name = achievementName(l, achievement);
    final body = achievementBody(l, achievement);
    final status = route == null
        ? l.campaignNotYet
        : earnedByLabel(l, route!, experiment: experiment);
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
