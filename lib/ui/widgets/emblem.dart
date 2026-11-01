import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';

/// The Cartharise emblem geometry, exactly as in `assets/brand/emblem.svg`
/// (512 × 512 viewBox). Shared by [CarthaEmblem] and `CarthaLoader`.
abstract final class EmblemGeometry {
  static const double viewBox = 512;

  /// Stroke width of the four head lines.
  static const double strokeWidth = 14;

  /// Stroke width of the centre trunk line (square cap).
  static const double trunkStrokeWidth = 13;

  /// The emblem's ink bounds (strokes included), for tight layouts.
  static const Rect tightBounds = Rect.fromLTRB(112, 131, 400, 316);

  /// The ink bounds including the loader's spark above the head.
  static const Rect sparkBounds = Rect.fromLTRB(112, 98, 400, 316);

  /// Centre of the four-point spark (loader).
  static const Offset sparkCenter = Offset(256, 123);

  /// The four round-capped head lines.
  static final List<Path> lines = [
    Path()
      ..moveTo(256, 158)
      ..cubicTo(238, 148, 218, 145, 198, 151)
      ..lineTo(162, 140)
      ..lineTo(121, 188)
      ..lineTo(158, 230)
      ..lineTo(181, 240)
      ..lineTo(198, 211)
      ..lineTo(214, 205),
    Path()
      ..moveTo(256, 158)
      ..cubicTo(274, 148, 294, 145, 314, 151)
      ..lineTo(350, 140)
      ..lineTo(391, 188)
      ..lineTo(354, 230)
      ..lineTo(331, 240)
      ..lineTo(314, 211)
      ..lineTo(298, 205),
    Path()
      ..moveTo(212, 159)
      ..lineTo(230, 175)
      ..lineTo(223, 205)
      ..lineTo(213, 224)
      ..lineTo(237, 249)
      ..lineTo(231, 289)
      ..cubicTo(247, 282, 251, 263, 255, 245),
    Path()
      ..moveTo(300, 159)
      ..lineTo(282, 175)
      ..lineTo(289, 205)
      ..lineTo(299, 224)
      ..lineTo(275, 249)
      ..lineTo(281, 289)
      ..cubicTo(265, 282, 261, 263, 257, 245),
  ];

  /// The centre trunk line (square cap, stroke 13).
  static final Path trunk = Path()
    ..moveTo(256, 244)
    ..lineTo(256, 307);

  /// The loader's four-point spark (filled).
  static final Path spark = Path()
    ..moveTo(256, 103)
    ..lineTo(262, 117)
    ..lineTo(276, 123)
    ..lineTo(262, 129)
    ..lineTo(256, 143)
    ..lineTo(250, 129)
    ..lineTo(236, 123)
    ..lineTo(250, 117)
    ..close();

  static Paint linePaint(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  static Paint trunkPaint(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = trunkStrokeWidth
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true;

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
    final line = EmblemGeometry.linePaint(color);
    for (final p in EmblemGeometry.lines) {
      canvas.drawPath(p, line);
    }
    canvas.drawPath(EmblemGeometry.trunk, EmblemGeometry.trunkPaint(color));
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

  static const double aspectRatio = 288 / 185;

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
