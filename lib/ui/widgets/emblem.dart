import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';

/// The Cartharise emblem geometry in the 512 × 512 design space: the single
/// source for [CarthaEmblem], `CarthaLoader` and the brand assets
/// (`make brand` writes `assets/brand/*.svg` and the icon PNGs from it;
/// `test/brand_test.dart` fails if they drift apart).
///
/// The geometric elephant head of the brand board's "Icon construction":
/// one outline for the brow and both ears (rounded top corners, sharp outer
/// tips, a hook at the bottom of each ear); per side, a face line that grows
/// from a crescent inside the ear, angles down the cheek and becomes one side
/// of the trunk; and an eye line that starts as a pointed hook, crosses the
/// face line under the eye and sweeps out into a tapered tusk. Lines are one
/// 13-unit stroke with mitred corners and flat ends; the crescents, eye tips
/// and tusks are filled tapers that grow from a point to that stroke width.
abstract final class EmblemGeometry {
  static const double viewBox = 512;

  /// Stroke width of every emblem line (mitred corners, flat ends).
  static const double strokeWidth = 13;

  /// Miter limit (SVG `stroke-miterlimit`) for the sharp ear tips.
  static const double miterLimit = 6;

  /// The emblem's ink bounds (strokes and mitred corners included).
  static const Rect tightBounds = Rect.fromLTRB(101, 167.5, 411, 344.5);

  /// SVG path data of the stroked lines: the brow-and-ears outline, the two
  /// face lines (crescent end → cheek → trunk) and the two eye lines (eye
  /// hook → crossing → tusk).
  static const List<String> lineData = [
    'M202 277.85 L191.5 298.1 L145.15 268.55 L109.75 231.05 '
        'L154.3 183.61 Q165.25 171.95 181.07 174.33 L229.15 181.55 '
        'L256 179.75 L282.85 181.55 L330.93 174.33 '
        'Q346.75 171.95 357.7 183.61 L402.25 231.05 L366.85 268.55 '
        'L320.5 298.1 L310 277.85',
    'M198.06 193.48 Q207.25 200.23 213.25 212.6 L198.25 254.6 '
        'L234.25 295.1 L239.5 343.85',
    'M313.94 193.48 Q304.75 200.23 298.75 212.6 L313.75 254.6 '
        'L277.75 295.1 L272.5 343.85',
    'M227.72 250.7 L236.5 256.1 L223.75 283.85 L219.25 307.85 '
        'Q212.5 320.23 202.38 326.04',
    'M284.27 250.7 L275.5 256.1 L288.25 283.85 L292.75 307.85 '
        'Q299.5 320.23 309.62 326.04',
  ];

  /// SVG path data of the filled tapers: the crescents inside the ears, the
  /// pointed eye-hook tips and the tusks.
  static const List<String> fillData = [
    'M176.5 185.6 C182.85 189.42 188.33 194.26 194.21 198.71 '
        'C200.04 202.98 204.3 209.03 207.42 215.47 L219.08 209.73 '
        'C215.06 201.4 209.42 193.73 201.91 188.24 '
        'C194.71 182.86 184.68 182.27 176.5 185.6 Z',
    'M335.5 185.6 C327.32 182.27 317.29 182.86 310.09 188.24 '
        'C302.58 193.73 296.94 201.4 292.92 209.73 L304.58 215.47 '
        'C307.7 209.03 311.96 202.98 317.79 198.71 '
        'C323.67 194.26 329.15 189.42 335.5 185.6 Z',
    'M217 244.1 C218.1 248.59 220.23 253.68 224.32 256.24 '
        'C227.24 258.04 230.17 259.84 233.09 261.64 L239.91 250.56 '
        'C236.98 248.76 234.06 246.96 231.13 245.16 '
        'C227.01 242.67 221.51 243.06 217 244.1 Z',
    'M295 244.1 C290.49 243.06 284.99 242.67 280.87 245.16 '
        'C277.94 246.96 275.02 248.76 272.09 250.56 L278.91 261.64 '
        'C281.83 259.84 284.76 258.04 287.68 256.24 '
        'C291.77 253.68 293.9 248.59 295 244.1 Z',
    'M178.75 331.1 C186.88 335.54 197.4 336.46 205.61 331.67 '
        'C213.97 326.91 220.38 319.39 224.93 311 L213.57 304.7 '
        'C210.15 311 205.44 316.8 199.14 320.4 '
        'C192.5 324.37 186.02 328.35 178.75 331.1 Z',
    'M333.25 331.1 C325.98 328.35 319.5 324.37 312.86 320.4 '
        'C306.56 316.8 301.85 311 298.43 304.7 L287.07 311 '
        'C291.62 319.39 298.03 326.91 306.39 331.67 '
        'C314.6 336.46 325.12 335.54 333.25 331.1 Z',
  ];

  /// The stroked lines.
  static final List<Path> lines = [for (final d in lineData) _path(d)];

  /// The filled tapers.
  static final List<Path> fills = [for (final d in fillData) _path(d)];

  static Paint linePaint(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeJoin = StrokeJoin.miter
    ..strokeMiterLimit = miterLimit
    ..strokeCap = StrokeCap.butt
    ..isAntiAlias = true;

  static Paint fillPaint(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  /// Paints the whole emblem in one flat colour, in design units.
  static void paint(Canvas canvas, Color color) {
    final line = linePaint(color);
    for (final p in lines) {
      canvas.drawPath(p, line);
    }
    final fill = fillPaint(color);
    for (final p in fills) {
      canvas.drawPath(p, fill);
    }
  }

  /// Maps the [viewport] rect of the 512 design space onto [size], centred
  /// and uniformly scaled (like `BoxFit.contain`).
  static void fit(Canvas canvas, Size size, Rect viewport) {
    final scale =
        (size.width / viewport.width) < (size.height / viewport.height)
        ? size.width / viewport.width
        : size.height / viewport.height;
    final dx = (size.width - viewport.width * scale) / 2;
    final dy = (size.height - viewport.height * scale) / 2;
    canvas
      ..translate(dx, dy)
      ..scale(scale)
      ..translate(-viewport.left, -viewport.top);
  }

  /// Builds a [Path] from the absolute `M L C Q Z` commands used above.
  static Path _path(String data) {
    final tokens = RegExp(r'[MLCQZ]|-?\d+(?:\.\d+)?')
        .allMatches(data)
        .map((m) => m[0]!)
        .toList();
    final path = Path();
    var i = 0;
    var command = 'M';
    double next() => double.parse(tokens[i++]);
    while (i < tokens.length) {
      if (RegExp(r'^[MLCQZ]$').hasMatch(tokens[i])) command = tokens[i++];
      switch (command) {
        case 'M':
          path.moveTo(next(), next());
        case 'L':
          path.lineTo(next(), next());
        case 'C':
          path.cubicTo(next(), next(), next(), next(), next(), next());
        case 'Q':
          path.quadraticBezierTo(next(), next(), next(), next());
        case 'Z':
          path.close();
      }
    }
    return path;
  }
}

/// Paints the static emblem in one flat colour (no gradients: brand rule).
class EmblemPainter extends CustomPainter {
  const EmblemPainter({
    required this.color,
    this.viewport = EmblemGeometry.tightBounds,
  });

  final Color color;
  final Rect viewport;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    EmblemGeometry.fit(canvas, size, viewport);
    EmblemGeometry.paint(canvas, color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(EmblemPainter old) =>
      old.color != color || old.viewport != viewport;
}

/// The static Cartharise emblem, tinted with a palette token (default
/// `emblem`; pass `heroAccent` on hero surfaces). [size] is the width; the
/// height follows the emblem's proportions.
class CarthaEmblem extends StatelessWidget {
  const CarthaEmblem({
    super.key,
    this.size = 48,
    this.color,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final double size;
  final Color? color;

  /// Defaults to "Cartharise emblem".
  final String? semanticLabel;
  final bool excludeFromSemantics;

  static final double aspectRatio =
      EmblemGeometry.tightBounds.width / EmblemGeometry.tightBounds.height;

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      size: Size(size, size / aspectRatio),
      painter: EmblemPainter(color: color ?? CarthaPalette.of(context).emblem),
    );
    if (excludeFromSemantics) return ExcludeSemantics(child: paint);
    return Semantics(
      image: true,
      label: semanticLabel ?? AppLocalizations.of(context).emblemLabel,
      child: paint,
    );
  }
}
