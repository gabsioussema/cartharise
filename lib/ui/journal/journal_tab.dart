import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'journal_kit.dart';
import 'look_back.dart';

/// Which part of the Journal tab is shown.
enum JournalSection { notes, reviews, lookBack }

/// Journal & Reflection (board): Notes (F-032) · Reviews (F-033) ·
/// Look back (F-034, F-035). Notes and reviews open full screen through
/// [AppNav]; everything stays on this phone.
class JournalTab extends StatefulWidget {
  const JournalTab({super.key});

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab> {
  JournalSection _section = JournalSection.notes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AreaListView(
          children: [
            ScreenHeader(
              title: l.journalTitle,
              subtitle: l.journalSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
            ),
            PillTabs<JournalSection>(
              key: const ValueKey('journal-sections'),
              tabs: [
                PillTab(
                  value: JournalSection.notes,
                  label: l.journalSectionNotes,
                ),
                PillTab(
                  value: JournalSection.reviews,
                  label: l.journalSectionReviews,
                ),
                PillTab(
                  value: JournalSection.lookBack,
                  label: l.journalSectionLookBack,
                ),
              ],
              selected: _section,
              onChanged: (s) => setState(() => _section = s),
            ),
            const SizedBox(height: 20),
            ...switch (_section) {
              JournalSection.notes => _notes(context),
              JournalSection.reviews => _reviews(context),
              JournalSection.lookBack => const [LookBackSection()],
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _notes(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final notes = context.watch<AppState>().notesNewestFirst;
    return [
      Text(
        l.journalNotesIntro,
        style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
      ),
      const SizedBox(height: 16),
      PrimaryButton(
        key: const ValueKey('journal-new-note'),
        label: l.journalNewNote,
        icon: Icons.add,
        expand: true,
        onPressed: () => AppNav.openJournalEntry(context),
      ),
      const SizedBox(height: 16),
      if (notes.isEmpty)
        EmptyState(
          icon: Icons.edit_note,
          title: l.journalNotesEmptyTitle,
          body: l.journalNotesEmptyBody,
        )
      else
        for (final note in notes)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 12),
            child: _NoteCard(entry: note),
          ),
    ];
  }

  List<Widget> _reviews(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final reviews = state.data.reviews;
    final thisWeek = state.reviewForWeek(weekStartKey(state.now()));
    return [
      Text(
        l.journalReviewsIntro,
        style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
      ),
      const SizedBox(height: 16),
      PrimaryButton(
        key: const ValueKey('journal-review-this-week'),
        label: thisWeek == null
            ? l.journalReviewThisWeek
            : l.journalOpenThisWeek,
        icon: thisWeek == null ? Icons.add : Icons.event_note_outlined,
        expand: true,
        onPressed: () => AppNav.openReview(context, reviewId: thisWeek?.id),
      ),
      const SizedBox(height: 16),
      if (reviews.isEmpty)
        EmptyState(
          icon: Icons.event_note_outlined,
          title: l.journalReviewsEmptyTitle,
          body: l.journalReviewsEmptyBody,
        )
      else
        for (final review in reviews)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 12),
            child: _ReviewCard(review: review),
          ),
    ];
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final headline = noteHeadline(entry);
    final hasTitle = (entry.title?.trim() ?? '').isNotEmpty;
    final preview = hasTitle ? firstLine(entry.body) : null;
    return SectionCard(
      key: ValueKey('note-${entry.id}'),
      onTap: () => AppNav.openJournalEntry(context, entryId: entry.id),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
      child: Row(
        children: [
          const GlyphIcon(CarthaGlyph.reflection),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline ?? l.journalUntitled,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontStyle: headline == null ? FontStyle.italic : null,
                  ),
                ),
                if (preview != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  formatDayTime(context, entry.createdAt),
                  style: theme.textTheme.bodySmall,
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

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final WeeklyReview review;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final wins = review.wins.trim();
    return SectionCard(
      key: ValueKey('review-${review.id}'),
      onTap: () => AppNav.openReview(context, reviewId: review.id),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
      child: Row(
        children: [
          const GlyphIcon(CarthaGlyph.reflection),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.journalWeekOf(formatDateKey(context, review.weekStart)),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  wins.isEmpty
                      ? l.journalReviewNothingWritten
                      : '${l.journalReviewWins}: $wins',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
