import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/campaign.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'campaign_copy.dart';
import 'campaign_kit.dart';
import 'campaign_ops.dart';
import 'campaign_pages.dart';

/// Act I, the one-day awakening (F-059): the five chapters with their
/// progress in the current reset, a way into each chapter's first open
/// question, and — the other route to a chapter's achievement — one of its
/// experiments to try.
class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final progress = context.watch<AppState>().campaign;
    return CampaignScreen(
      title: l.campaignChaptersTitle,
      subtitle: l.campaignActOne,
      children: [
        Text(
          l.campaignChaptersExplored(
            progress.chaptersExplored,
            progress.chapters.length,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: 12),
        CampaignGrid(
          minWidth: 260,
          children: [
            for (final (i, chapter) in progress.chapters.indexed)
              _ChapterCard(number: i + 1, progress: chapter),
          ],
        ),
      ],
    );
  }
}

/// One chapter: its questions' progress in the current reset, experiments
/// tried, **Explore** (its first open question) and **Try one**.
class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.number, required this.progress});

  final int number;
  final ChapterProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final journey = state.data.currentJourney;
    final name = chapterName(l, progress.chapter);
    final done = l.campaignChapterDone(progress.answered, progress.total);
    final canTry = state.content.experimentsFor(progress.chapter).isNotEmpty;
    String? target;
    for (final id in progress.promptIds) {
      if (!(journey?.answer(id)?.answered ?? false)) {
        target = id;
        break;
      }
    }
    target ??= progress.promptIds.firstOrNull;
    return SectionCard(
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.campaignChapterNumber(number).toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: p.accent,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (progress.explored)
                ChipTag(
                  label: l.campaignChapterExplored,
                  icon: Icons.check,
                  tone: ChipTone.success,
                ),
              if (progress.tried > 0)
                ChipTag(
                  key: ValueKey('campaign-chapter-tried-$number'),
                  label: l.campaignChapterTried(progress.tried),
                  icon: GlyphIcon.placeholderFor(CarthaGlyph.experiment),
                  tone: ChipTone.accent,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Semantics(
            header: true,
            child: Text(name, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 2),
          Text(
            l.campaignChapterReflections(
              chapterArea(l, progress.chapter),
              progress.total,
            ),
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.total == 0
                  ? 0
                  : progress.answered / progress.total,
              minHeight: 6,
              semanticsLabel: done,
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(child: Text(done, style: theme.textTheme.bodySmall)),
          if (target != null || canTry) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (target != null)
                  Semantics(
                    button: true,
                    label: l.campaignChapterExploreLabel(number, name),
                    excludeSemantics: true,
                    onTap: () => AppNav.openPrompt(context, target!),
                    child: SecondaryButton(
                      key: ValueKey('campaign-chapter-$number'),
                      label: l.campaignChapterExplore,
                      trailingIcon: Icons.arrow_forward,
                      onPressed: () => AppNav.openPrompt(context, target!),
                    ),
                  ),
                if (canTry)
                  Semantics(
                    button: true,
                    label: l.campaignChapterTryLabel(number, name),
                    excludeSemantics: true,
                    onTap: () => openTryFor(context, progress.chapter),
                    child: TextLinkButton(
                      key: ValueKey('campaign-chapter-try-$number'),
                      label: l.campaignChapterTry,
                      icon: GlyphIcon.placeholderFor(CarthaGlyph.experiment),
                      onPressed: () => openTryFor(context, progress.chapter),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
