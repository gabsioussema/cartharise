import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../reset/reset_flow.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// Lessons in reading order.
List<Lesson> lessonsInOrder(ContentLibrary content) =>
    [...content.lessons]..sort((a, b) => a.ordinal.compareTo(b.ordinal));

/// "Read" (with a tick) or "Not read yet" — text, not colour alone.
class LessonReadTag extends StatelessWidget {
  const LessonReadTag({super.key, required this.read});

  final bool read;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return read
        ? ChipTag(
            label: l.awakeningRead,
            icon: Icons.check,
            tone: ChipTone.success,
          )
        : ChipTag(label: l.awakeningNotRead, icon: Icons.menu_book_outlined);
  }
}

/// One Awakening lesson as a tappable card. [compact] (the Reset strip)
/// leaves out the summary.
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.read,
    required this.onTap,
    this.compact = false,
  });

  final Lesson lesson;
  final bool read;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.awakeningLessonNumber(lesson.ordinal),
          style: theme.textTheme.labelMedium?.copyWith(
            color: p.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(lesson.title, style: theme.textTheme.titleMedium),
        if (!compact) ...[
          const SizedBox(height: 6),
          Text(
            lesson.summary,
            style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
        ],
        const SizedBox(height: 10),
        LessonReadTag(read: read),
      ],
    );
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsetsDirectional.all(16),
      child: compact
          ? text
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: text),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: Icon(Icons.chevron_right, color: p.textSecondary),
                ),
              ],
            ),
    );
  }
}

/// "Learn the ideas first (optional)": a horizontal strip of the seven
/// lessons with read state, plus a link to the full Awakening list. Cards
/// grow with the text size (no fixed height).
class LessonStrip extends StatelessWidget {
  const LessonStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final lessons = lessonsInOrder(state.content);
    if (lessons.isEmpty) return const SizedBox.shrink();
    final read = state.data.lessonsRead;
    final readCount = lessons.where((x) => read.contains(x.id)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l.awakeningStripTitle),
        Text(
          l.awakeningReadCount(readCount, lessons.length),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: CarthaPalette.of(context).textSecondary),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = math.min(260.0, constraints.maxWidth * 0.72);
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, lesson) in lessons.indexed) ...[
                      if (i > 0) const SizedBox(width: 12),
                      SizedBox(
                        width: width,
                        child: LessonCard(
                          lesson: lesson,
                          read: read.contains(lesson.id),
                          compact: true,
                          onTap: () => AppNav.openLesson(context, lesson.id),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextLinkButton(
            label: l.awakeningSeeAll,
            trailingIcon: Icons.arrow_forward,
            onPressed: () => AppNav.openAwakening(context),
          ),
        ),
      ],
    );
  }
}
