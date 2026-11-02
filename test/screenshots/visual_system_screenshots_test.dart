// Renders the visual system (glyphs, lesson illustrations, achievement
// badges, compact scenes) to PNGs for design review (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

const _words = {
  CarthaGlyph.notice: 'Notice',
  CarthaGlyph.direction: 'Direction',
  CarthaGlyph.experiment: 'Experiment',
  CarthaGlyph.boundaries: 'Boundaries',
  CarthaGlyph.reflection: 'Reflection',
  CarthaGlyph.progress: 'Progress',
};

class _GlyphSheet extends StatelessWidget {
  const _GlyphSheet();

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
          children: [
            SectionCard(
              child: Column(
                children: [
                  for (final g in CarthaGlyph.values)
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          for (final s in const [16.0, 24.0, 32.0, 48.0]) ...[
                            GlyphIcon(g, size: s),
                            const SizedBox(width: 14),
                          ],
                          Expanded(
                            child: Text(
                              _words[g]!,
                              style: theme.textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            HeroCard(
              child: Wrap(
                spacing: 18,
                runSpacing: 12,
                children: [
                  for (final g in CarthaGlyph.values)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GlyphIcon(g, size: 32, color: p.heroAccent),
                        const SizedBox(height: 4),
                        Text(
                          _words[g]!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: p.onHero,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const GlyphTitle(CarthaGlyph.direction, 'Your direction'),
                  const SizedBox(height: 8),
                  const GlyphTitle(CarthaGlyph.boundaries, 'Boundaries'),
                  const SizedBox(height: 8),
                  const GlyphTitle(CarthaGlyph.reflection, 'Weekly review'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final g in CarthaGlyph.values)
                        GlyphIcon(g, size: 16, color: p.textSecondary),
                      for (final g in CarthaGlyph.values)
                        GlyphIcon(g, size: 20),
                    ],
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

class _BadgeSheet extends StatelessWidget {
  const _BadgeSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
          children: [
            for (final size in const [72.0, 48.0, 32.0])
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 12),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$size', style: theme.textTheme.labelSmall),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final a in Achievement.values)
                            AchievementBadge(a, earned: true, size: size),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final a in Achievement.values)
                            AchievementBadge(a, size: size),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LessonSheet extends StatelessWidget {
  const _LessonSheet({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
        children: [
          for (var i = 1; i <= 7; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: SizedBox(
                  width: width,
                  child: LessonIllustration('lesson.0$i', height: height),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _CompactScenes extends StatelessWidget {
  const _CompactScenes();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
        children: [
          for (final kind in SceneKind.values) ...[
            BrandScene.compact(kind: kind, animate: false),
            const SizedBox(height: 10),
          ],
          const DawnRuinsScene(aspectRatio: 2, animate: false),
        ],
      ),
    ),
  );
}

void main() {
  for (final b in Brightness.values) {
    final tag = b.name;

    testWidgets('glyphs $tag', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        brightness: b,
        size: const Size(390, 760),
        home: const _GlyphSheet(),
      );
      await captureScreenshot(tester, 'visual_01_glyphs_$tag');
    });

    testWidgets('badges $tag', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        brightness: b,
        size: const Size(700, 640),
        home: const _BadgeSheet(),
      );
      await captureScreenshot(tester, 'visual_02_badges_$tag', pixelRatio: 2);
    });

    testWidgets('lesson art $tag', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        brightness: b,
        size: const Size(390, 1000),
        home: const _LessonSheet(height: 120),
      );
      await captureScreenshot(tester, 'visual_03_lessons_$tag', pixelRatio: 2);
    });

    testWidgets('compact scenes $tag', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        brightness: b,
        size: const Size(390, 900),
        home: const _CompactScenes(),
      );
      await captureScreenshot(tester, 'visual_06_compact_$tag', pixelRatio: 2);
    });

    testWidgets('awakening $tag', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData().copyWith(lessonsRead: {'lesson.02'}),
        content: englishContent,
        brightness: b,
        size: const Size(390, 1400),
        home: const AwakeningScreen(),
      );
      await captureScreenshot(
        tester,
        'visual_07_awakening_$tag',
        pixelRatio: 2,
      );
    });

    testWidgets('lesson $tag', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        content: englishContent,
        brightness: b,
        size: const Size(390, 844),
        home: const LessonScreen(lessonId: 'lesson.05'),
      );
      await captureScreenshot(tester, 'visual_08_lesson_$tag', pixelRatio: 2);
    });
  }

  testWidgets('lesson art: narrow strip and wide tablet', (tester) async {
    await pumpCartha(
      tester,
      data: onboardedData(),
      size: const Size(1024, 1000),
      home: const _LessonSheet(height: 112),
    );
    await captureScreenshot(tester, 'visual_04_lessons_wide', pixelRatio: 1);
    await pumpCartha(
      tester,
      data: onboardedData(),
      brightness: Brightness.light,
      size: const Size(260, 700),
      home: const _LessonSheet(height: 80, width: 200),
    );
    await captureScreenshot(tester, 'visual_05_lessons_narrow', pixelRatio: 2);
  });
}
