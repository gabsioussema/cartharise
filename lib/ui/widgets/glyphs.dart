/// The visual system's glyphs and art (recognition over recall: one stable
/// cue per idea, always next to a word). Painted in the brand line style of
/// `EmblemGeometry` (see `art/`), colours from palette tokens only.
library;

import 'package:flutter/material.dart';

import '../../domain/campaign.dart';
import '../../domain/content.dart' show CarthaGlyph;
import '../theme/cartha_theme.dart';
import 'art/badge_art.dart';
import 'art/glyph_art.dart';
import 'art/lesson_art.dart';

export '../../domain/content.dart' show CarthaGlyph;
export 'art/lesson_art.dart' show LessonScene;

/// One idea's glyph ([CarthaGlyph]): notice = a mirror, direction = a compass
/// and the north star, experiment = a seedling, boundaries = a shelter,
/// reflection = a lantern on a notebook, progress = a path to a landmark.
///
/// Always shown next to the word it stands for. Decorative unless
/// [semanticLabel] is given; [color] defaults to the palette's accent
/// (bronze) — pass `heroAccent` on hero surfaces.
class GlyphIcon extends StatelessWidget {
  const GlyphIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    this.color,
    this.semanticLabel,
  });

  final CarthaGlyph glyph;
  final double size;
  final Color? color;
  final String? semanticLabel;

  /// The nearest Material icon for [glyph], where only an [IconData] fits
  /// (e.g. a navigation bar).
  static IconData placeholderFor(CarthaGlyph glyph) => switch (glyph) {
    CarthaGlyph.notice => Icons.visibility_outlined,
    CarthaGlyph.direction => Icons.explore_outlined,
    CarthaGlyph.experiment => Icons.eco_outlined,
    CarthaGlyph.boundaries => Icons.cottage_outlined,
    CarthaGlyph.reflection => Icons.auto_stories_outlined,
    CarthaGlyph.progress => Icons.route_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      size: Size.square(size),
      painter: GlyphPainter(
        glyph: glyph,
        color: color ?? CarthaPalette.of(context).accent,
      ),
    );
    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: paint);
    return Semantics(
      image: true,
      label: label,
      child: ExcludeSemantics(child: paint),
    );
  }
}

/// A heading row with a glyph: the glyph, then [title] (Inter `titleMedium`,
/// announced as a header), then an optional [trailing] widget. The same
/// layout as a `SectionCard` title, for cards whose idea has a glyph.
class GlyphTitle extends StatelessWidget {
  const GlyphTitle(
    this.glyph,
    this.title, {
    super.key,
    this.trailing,
    this.style,
  });

  final CarthaGlyph glyph;
  final String title;
  final Widget? trailing;

  /// Defaults to `titleMedium`.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      GlyphIcon(glyph, size: 24),
      const SizedBox(width: 12),
      Expanded(
        child: Semantics(
          header: true,
          child: Text(
            title,
            style: style ?? Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      ?trailing,
    ],
  );
}

/// The illustration of lesson [lessonId] (`lesson.01` … `lesson.07`), one
/// memorable scene each ([LessonScene]), on lesson cards and lesson screens.
/// Decorative (the lesson's title says what it is). Takes the width it is
/// given; the subject stays centred at any width.
class LessonIllustration extends StatelessWidget {
  const LessonIllustration(this.lessonId, {super.key, this.height = 120});

  final String lessonId;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        key: ValueKey('lesson-illustration-$lessonId'),
        height: height,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          child: RepaintBoundary(
            child: CustomPaint(
              painter: LessonArtPainter(
                scene: LessonScene.of(lessonId),
                palette: p,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The badge of [achievement]: seven distinct symbols (an eye, a signpost,
/// a rising sun, an owl, a map, an anvil, a summit flag) on a medallion.
/// Earned: a filled medallion with ribbons; not yet: an empty dashed slot
/// with the symbol in outline — the shape differs, not only the colour.
/// Decorative (the tile next to it says "Earned" / "Not yet" in words).
class AchievementBadge extends StatelessWidget {
  const AchievementBadge(
    this.achievement, {
    super.key,
    this.earned = false,
    this.size = 48,
  });

  final Achievement achievement;
  final bool earned;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      key: ValueKey('achievement-badge-${achievement.name}'),
      dimension: size,
      child: CustomPaint(
        painter: AchievementBadgePainter(
          achievement: achievement,
          earned: earned,
          palette: CarthaPalette.of(context),
        ),
      ),
    ),
  );
}
