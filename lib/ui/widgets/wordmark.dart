import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../theme/brand_svg.dart';
import '../theme/cartha_theme.dart';

enum WordmarkLayout {
  /// Emblem left, lettering + tagline right (`wordmark_horizontal.svg`).
  horizontal,

  /// Emblem above lettering, rule and tagline (`wordmark_stacked.svg`).
  stacked,

  /// Only the outlined CARTHARISE lettering and its rule (cropped from the
  /// stacked lockup) — for under a `CarthaLoader`/`CarthaEmblem`.
  lettering,
}

/// The Cartharise lockups, rendered from the brand SVGs and tinted with
/// palette tokens (bronze → `emblem`, ivory → `textPrimary`; on hero
/// surfaces `heroAccent` / `onHero`) so they read in light and dark.
class CarthaWordmark extends StatelessWidget {
  const CarthaWordmark({
    super.key,
    this.layout = WordmarkLayout.horizontal,
    this.width = 240,
    this.onHero = false,
    this.semanticLabel,
  });

  final WordmarkLayout layout;
  final double width;

  /// Use hero colours (on `HeroCard`, the boot screen, onboarding).
  final bool onHero;

  /// Defaults to the app name.
  final String? semanticLabel;

  static const _horizontal = 'assets/brand/wordmark_horizontal.svg';
  static const _stacked = 'assets/brand/wordmark_stacked.svg';

  // The lettering + rule region of the stacked SVG (1000 × 820 viewBox).
  static const _crop = Rect.fromLTRB(70, 510, 930, 672);

  double get height => switch (layout) {
    WordmarkLayout.horizontal => width * 340 / 1280,
    WordmarkLayout.stacked => width * 820 / 1000,
    WordmarkLayout.lettering => width * _crop.height / _crop.width,
  };

  @override
  Widget build(BuildContext context) {
    final mapper = BrandSvgColorMapper.of(
      CarthaPalette.of(context),
      onHero: onHero,
    );
    final label = semanticLabel ?? AppLocalizations.of(context).appTitle;
    final Widget picture;
    switch (layout) {
      case WordmarkLayout.horizontal:
      case WordmarkLayout.stacked:
        picture = SvgPicture(
          BrandSvgLoader(
            layout == WordmarkLayout.horizontal ? _horizontal : _stacked,
            colorMapper: mapper,
          ),
          width: width,
          height: height,
          excludeFromSemantics: true,
        );
      case WordmarkLayout.lettering:
        final scale = width / _crop.width;
        picture = SizedBox(
          width: width,
          height: height,
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: -_crop.left * scale,
                  top: -_crop.top * scale,
                  width: 1000 * scale,
                  height: 820 * scale,
                  child: SvgPicture(
                    BrandSvgLoader(_stacked, colorMapper: mapper),
                    excludeFromSemantics: true,
                  ),
                ),
              ],
            ),
          ),
        );
    }
    return Semantics(
      label: label,
      image: true,
      child: SizedBox(width: width, height: height, child: picture),
    );
  }
}
