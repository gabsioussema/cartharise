import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../reset/reset_flow.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'lesson_card.dart';

/// The Awakening (F-005): the seven lessons with read state, optional and in
/// any order, plus where the ideas come from.
class AwakeningScreen extends StatelessWidget {
  const AwakeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final lessons = lessonsInOrder(state.content);
    final read = state.data.lessonsRead;
    final readCount = lessons.where((x) => read.contains(x.id)).length;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ReadingColumn(
          top: 0,
          children: [
            ScreenHeader(
              leading: const GlyphIcon(CarthaGlyph.notice, size: 32),
              title: l.awakeningTitle,
              subtitle: l.awakeningSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
            ),
            Text(
              l.awakeningReadCount(readCount, lessons.length),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: CarthaPalette.of(context).accent),
            ),
            const SizedBox(height: 16),
            for (final lesson in lessons) ...[
              LessonCard(
                lesson: lesson,
                read: read.contains(lesson.id),
                onTap: () => AppNav.openLesson(context, lesson.id),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            const AwakeningSourceNote(),
          ],
        ),
      ),
    );
  }
}

/// "Paraphrased from … by …" with a link to the Inspiration page (credit).
class AwakeningSourceNote extends StatelessWidget {
  const AwakeningSourceNote({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final credit = context.select((AppState s) => s.content.credit);
    final p = CarthaPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.awakeningSourceNote(credit.title, credit.author),
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: p.textSecondary),
        ),
        TextLinkButton(
          label: l.awakeningSourceLink,
          icon: Icons.info_outline,
          onPressed: () => AppNav.openInspiration(context),
        ),
      ],
    );
  }
}
