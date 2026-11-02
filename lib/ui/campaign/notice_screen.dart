import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'campaign_kit.dart';

/// The Playground's **Notice**: illustrated cards, each opening an existing
/// reflection question or lesson (no new text is stored here). A card says
/// whether its question is already written or its lesson read — in words.
class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final notices = context.select<AppState, List<Notice>>(
      (s) => s.content.notices,
    );
    return CampaignScreen(
      title: l.campaignNoticeTitle,
      subtitle: l.campaignNoticeScreenSubtitle,
      children: [
        if (notices.isEmpty)
          EmptyState(
            icon: GlyphIcon.placeholderFor(CarthaGlyph.notice),
            title: l.campaignNoticeEmpty,
          )
        else
          CampaignGrid(
            minWidth: 280,
            children: [
              for (final n in notices)
                NoticeCard(key: ValueKey('notice-card-${n.id}'), notice: n),
            ],
          ),
      ],
    );
  }
}

/// One notice: its art (the lesson's illustration, or its glyph), what it
/// opens and its short title. The whole card opens it.
class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key, required this.notice});

  final Notice notice;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final content = state.content;
    final promptId = notice.promptId;
    final lessonId = notice.lessonId;
    final String kind;
    final String? opens;
    final bool done;
    if (lessonId != null) {
      kind = l.campaignNoticeKindLesson;
      opens = content.lesson(lessonId)?.title;
      done = state.data.lessonsRead.contains(lessonId);
    } else {
      kind = l.campaignNoticeKindPrompt;
      opens = content.prompt(promptId!)?.title;
      done = state.data.journeys.any(
        (j) => j.answer(promptId)?.answered ?? false,
      );
    }
    final status = !done
        ? null
        : lessonId != null
        ? l.campaignNoticeRead
        : l.campaignNoticeWritten;

    void open() => lessonId != null
        ? AppNav.openLesson(context, lessonId)
        : AppNav.openPrompt(context, promptId!);

    final kindLine = Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          kind.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: p.accent,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (status != null)
          ChipTag(label: status, icon: Icons.check, tone: ChipTone.success),
      ],
    );
    return SectionCard(
      onTap: open,
      padding: const EdgeInsetsDirectional.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lessonId != null) ...[
            LessonIllustration(lessonId, height: 96),
            const SizedBox(height: 12),
            kindLine,
          ] else
            // A question has no scene: its glyph sits in a small tile
            // beside the kind, not alone in a large empty box.
            Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    key: ValueKey('notice-glyph-${notice.id}'),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: p.raised,
                      borderRadius: BorderRadius.circular(
                        CarthaTheme.radiusSmall,
                      ),
                      border: Border.all(color: p.border),
                    ),
                    alignment: Alignment.center,
                    child: GlyphIcon(notice.glyph, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: kindLine),
              ],
            ),
          const SizedBox(height: 6),
          Text(notice.title, style: theme.textTheme.titleMedium),
          if (opens != null) ...[
            const SizedBox(height: 4),
            Text(
              l.campaignNoticeOpens(opens),
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
