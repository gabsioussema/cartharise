/// The visual system's glyphs and art (recognition over recall: one stable
/// cue per idea, always next to a word). These are placeholders drawn with
/// Material icons so every screen runs; the painted brand versions replace
/// the bodies without changing the API. Colours come from palette tokens.
library;

import 'package:flutter/material.dart';

import '../../domain/campaign.dart';
import '../../domain/content.dart' show CarthaGlyph;
import '../theme/cartha_theme.dart';

export '../../domain/content.dart' show CarthaGlyph;

/// One idea's glyph ([CarthaGlyph]). Decorative unless [semanticLabel] is
/// given; [color] defaults to the palette's accent (bronze).
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

  /// The placeholder icon for [glyph].
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
    final icon = Icon(
      placeholderFor(glyph),
      size: size,
      color: color ?? CarthaPalette.of(context).accent,
      semanticLabel: semanticLabel,
    );
    return semanticLabel == null ? ExcludeSemantics(child: icon) : icon;
  }
}

/// The illustration of lesson [lessonId] (`lesson.01` … `lesson.07`), one
/// memorable scene each, on lesson cards and lesson screens. Decorative
/// (the lesson's title says what it is). Takes the width it is given.
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: p.raised,
            borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
            border: Border.all(color: p.border),
          ),
          child: Center(
            child: Icon(
              Icons.auto_stories_outlined,
              size: height * 0.4,
              color: p.accent,
            ),
          ),
        ),
      ),
    );
  }
}

/// The badge of [achievement], each distinct in the painted version.
/// [earned] or not shows by shape as well as colour; decorative (the tile
/// next to it says "Earned" / "Not yet" in words).
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
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return ExcludeSemantics(
      child: SizedBox.square(
        key: ValueKey('achievement-badge-${achievement.name}'),
        dimension: size,
        child: Icon(
          earned ? Icons.military_tech : Icons.military_tech_outlined,
          size: size,
          color: earned ? p.accent : p.textSecondary,
        ),
      ),
    );
  }
}
