import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'cartha_theme.dart';

/// Re-tints the brand SVGs (`assets/brand/wordmark_*.svg`, drawn for the
/// forest background) with palette tokens so they read in light and dark.
/// Lives in the theme folder because it matches the files' raw colours.
@immutable
class BrandSvgColorMapper extends ColorMapper {
  const BrandSvgColorMapper({
    required this.emblem,
    required this.lettering,
    required this.tagline,
  });

  /// For a lockup on the page background / cards.
  factory BrandSvgColorMapper.of(CarthaPalette p, {bool onHero = false}) =>
      BrandSvgColorMapper(
        emblem: onHero ? p.heroAccent : p.emblem,
        lettering: onHero ? p.onHero : p.textPrimary,
        tagline: onHero ? p.heroAccent : p.accent,
      );

  /// Replaces antique bronze (emblem strokes, the rule).
  final Color emblem;

  /// Replaces ivory (the outlined CARTHARISE lettering).
  final Color lettering;

  /// Replaces bronze on `<text>` (the small tagline: text-safe colour).
  final Color tagline;

  @override
  Color substitute(
    String? id,
    String elementName,
    String attributeName,
    Color color,
  ) {
    final argb = color.toARGB32();
    if (argb == CarthaColors.bronze.toARGB32()) {
      return elementName == 'text' ? tagline : emblem;
    }
    if (argb == CarthaColors.ivory.toARGB32()) return lettering;
    return color;
  }

  @override
  bool operator ==(Object other) =>
      other is BrandSvgColorMapper &&
      other.emblem == emblem &&
      other.lettering == lettering &&
      other.tagline == tagline;

  @override
  int get hashCode => Object.hash(emblem, lettering, tagline);
}

/// Loads a brand SVG asset and points its `<text>` (the tagline) at the
/// bundled Inter, so it renders in the brand font offline instead of an
/// arbitrary system fallback.
class BrandSvgLoader extends SvgAssetLoader {
  const BrandSvgLoader(super.assetName, {super.colorMapper});

  @override
  String provideSvg(ByteData? message) => super
      .provideSvg(message)
      .replaceAll(
        'font-family="Inter,Arial,sans-serif"',
        'font-family="Inter"',
      );
}
