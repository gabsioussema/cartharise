import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../domain/content.dart' show ContentLibrary;
import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/formatting.dart';
import '../journal/journal_kit.dart';
import '../media/media_kit.dart' show AttachmentCountLine;
import '../missions/project_history_screen.dart';
import '../persona/persona_copy.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/route_scenes.dart';
import '../widgets/bidi.dart';
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
        // ── Keepsakes (once something was tried) ───────────────────────
        if (groups.isNotEmpty)
          KeepsakeShelf(
            kept: keptKeepsakes(state.experimentLog, state.content),
            showAll: game,
          ),

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
              key: ValueKey(
                'collection-experiment-${tries.first.experimentId}',
              ),
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

/// How many distinct experiments of each chapter [log] holds, for the
/// chapters with at least one (their keepsake is kept). Tries of
/// experiments [content] no longer has are left out.
Map<CampaignChapter, int> keptKeepsakes(
  List<ExperimentEntry> log,
  ContentLibrary content,
) {
  final tried = <CampaignChapter, Set<String>>{};
  for (final entry in log) {
    final experiment = content.experiment(entry.experimentId);
    if (experiment == null) continue;
    (tried[experiment.chapter] ??= {}).add(experiment.id);
  }
  return {
    for (final chapter in CampaignChapter.values)
      if (tried[chapter] case final ids?) chapter: ids.length,
  };
}

/// The chapter keepsakes: a small painting of each chapter's object (a
/// spyglass, a mosaic tile, a banner, an hourglass, a scroll) with its name,
/// its chapter and, in words, "Kept · 2 tried" or "Not yet". With the
/// Campaign off ([showAll] false) only the kept ones show — no empty slots to
/// fill.
class KeepsakeShelf extends StatelessWidget {
  const KeepsakeShelf({super.key, required this.kept, required this.showAll});

  /// Experiments tried per chapter (see [keptKeepsakes]).
  final Map<CampaignChapter, int> kept;

  /// Also show the chapters not kept yet, as empty slots.
  final bool showAll;

  /// The narrowest a keepsake column gets (scaled with the text size).
  static const minItemWidth = 100.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final chapters = [
      for (final c in CampaignChapter.values)
        if (showAll || kept.containsKey(c)) c,
    ];
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Column(
      key: const ValueKey('collection-keepsakes'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AreaSectionLabel(l.sceneryKeepsakesTitle),
        SectionCard(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 16, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
                child: Text(
                  l.sceneryKeepsakesLine,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 8.0;
                  final columns =
                      (constraints.maxWidth / (minItemWidth * scale))
                          .floor()
                          .clamp(1, CampaignChapter.values.length);
                  final width =
                      (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    alignment: WrapAlignment.center,
                    spacing: gap,
                    runSpacing: 16,
                    children: [
                      for (final c in chapters)
                        SizedBox(
                          width: width,
                          child: _KeepsakeTile(chapter: c, tried: kept[c]),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One keepsake: the painting, its name, its chapter and whether it is kept
/// (in words; the painting's shape says it too), read out as one phrase.
class _KeepsakeTile extends StatelessWidget {
  const _KeepsakeTile({required this.chapter, required this.tried});

  final CampaignChapter chapter;

  /// Experiments of the chapter tried; null when none (not yet).
  final int? tried;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final count = tried;
    final name = l.sceneryKeepsakeName(chapter.name);
    final from = chapterName(l, chapter);
    final status = count == null
        ? l.sceneryKeepsakeNotYet
        : l.sceneryKeepsakeKept(count);
    return Semantics(
      key: ValueKey('collection-keepsake-${chapter.name}'),
      container: true,
      label: l.sceneryKeepsakeLabel(name, from, status),
      excludeSemantics: true,
      child: Column(
        children: [
          Keepsake(chapter, kept: count != null),
          const SizedBox(height: 6),
          Text(
            name,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 2),
          Text(
            from,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: count == null ? p.textSecondary : p.accent,
              fontWeight: count == null ? null : FontWeight.w600,
            ),
          ),
        ],
      ),
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
                      Text(
                        entry.note,
                        textDirection: textDirectionOf(entry.note),
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      l.campaignTriedOn(date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                    // Its photos and voice notes, in words.
                    if (entry.attachments.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AttachmentCountLine(
                        entry.attachments,
                        key: ValueKey('try-media-${entry.id}'),
                      ),
                    ],
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
