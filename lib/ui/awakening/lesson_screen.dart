import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../reset/reset_flow.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'awakening_screen.dart';
import 'knowledge_check.dart';
import 'lesson_card.dart';

/// One Awakening lesson (F-005–F-007): title, summary, explanation, an
/// example, the nuance ("a lens, not a verdict"), a knowledge check (no
/// score kept), "Try it" links into the reset, and previous / next.
/// Opening it marks it read.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  void initState() {
    super.initState();
    // Saving notifies listeners: not allowed during the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppState>();
      if (state.content.lesson(widget.lessonId) != null) {
        state.markLessonRead(widget.lessonId);
      }
    });
  }

  void _open(String lessonId) => Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => LessonScreen(lessonId: lessonId)),
  );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final lesson = state.content.lesson(widget.lessonId);
    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          top: false,
          child: ReadingColumn(
            children: [EmptyState(title: l.awakeningMissing)],
          ),
        ),
      );
    }
    final theme = Theme.of(context);
    final p = CarthaPalette.of(context);
    final lessons = lessonsInOrder(state.content);
    final index = lessons.indexWhere((x) => x.id == lesson.id);
    final previous = index > 0 ? lessons[index - 1] : null;
    final next = index >= 0 && index < lessons.length - 1
        ? lessons[index + 1]
        : null;
    final paragraphs = lesson.explanation
        .split(RegExp(r'\n\s*\n'))
        .map((x) => x.trim())
        .where((x) => x.isNotEmpty);
    final related = [
      for (final id in lesson.relatedPromptIds) ?state.content.prompt(id),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ReadingColumn(
          top: 0,
          children: [
            Eyebrow(l.awakeningLessonOf(lesson.ordinal, lessons.length)),
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(lesson.title, style: theme.textTheme.headlineSmall),
            ),
            const SizedBox(height: 10),
            Text(
              lesson.summary,
              style: theme.textTheme.titleMedium?.copyWith(
                color: p.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LessonReadTagFor(lessonId: lesson.id),
            const SizedBox(height: 20),
            for (final paragraph in paragraphs) ...[
              Text(paragraph, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 6),
            SectionCard(
              title: l.awakeningExample,
              icon: Icons.lightbulb_outline,
              child: Text(lesson.example),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: l.awakeningNuance,
              icon: Icons.balance,
              child: Text(lesson.nuance),
            ),
            if (lesson.check case final check?) ...[
              const SizedBox(height: 16),
              KnowledgeCheckCard(key: ValueKey(lesson.id), check: check),
            ],
            if (related.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: l.awakeningTryIt,
                icon: Icons.edit_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.awakeningTryItBody),
                    const SizedBox(height: 4),
                    for (final prompt in related)
                      TextLinkButton(
                        label: l.awakeningTryItPrompt(prompt.title),
                        trailingIcon: Icons.arrow_forward,
                        onPressed: () => AppNav.openPrompt(context, prompt.id),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (next != null)
              PrimaryButton(
                label: l.awakeningNext,
                trailingIcon: Icons.arrow_forward,
                expand: true,
                onPressed: () => _open(next.id),
              )
            else
              PrimaryButton(
                label: l.awakeningDone,
                expand: true,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            if (previous != null) ...[
              const SizedBox(height: 10),
              SecondaryButton(
                label: l.awakeningPrevious,
                icon: Icons.arrow_back,
                expand: true,
                onPressed: () => _open(previous.id),
              ),
            ],
            const SizedBox(height: 20),
            const AwakeningSourceNote(),
          ],
        ),
      ),
    );
  }
}

/// The read state of [lessonId], kept current.
class LessonReadTagFor extends StatelessWidget {
  const LessonReadTagFor({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final read = context.select(
      (AppState s) => s.data.lessonsRead.contains(lessonId),
    );
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: LessonReadTag(read: read),
    );
  }
}
