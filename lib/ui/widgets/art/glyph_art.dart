import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../domain/content.dart' show CarthaGlyph;

/// Line art in the brand style of `EmblemGeometry`: one stroke weight with
/// mitred corners and flat ends, plus a few filled shapes, drawn in a
/// 24 × 24 grid (about a 2-unit margin) in a single colour. Used for the six
/// idea glyphs ([GlyphArt.of]) and the symbols on achievement badges.
///
/// Paths are built once.
@immutable
class GlyphArt {
  const GlyphArt({
    required this.lines,
    this.details = const [],
    this.fills = const [],
    this.softFills = const [],
    this.cutouts = const [],
  });

  /// The design grid.
  static const double grid = 24;

  /// Strokes at the full weight.
  final List<Path> lines;

  /// Thinner strokes (glints, folds, inner marks), at [detailRatio].
  final List<Path> details;

  /// Solid shapes.
  final List<Path> fills;

  /// Fills at [softAlpha] of the colour (the shaded half of a needle).
  final List<Path> softFills;

  /// Shapes punched back out of the fills in the background colour (an
  /// eye's highlight); left out when painted hollow.
  final List<Path> cutouts;

  static const double detailRatio = 0.6;
  static const double softAlpha = 0.45;

  /// The stroke weight, in grid units, for art [side] px wide: a little
  /// heavier when small (crisp at 16 px), lighter when large (calm at 48 px),
  /// never under 1.2 px.
  static double strokeFor(double side) {
    final units = side <= 24
        ? 1.8 + (24 - side).clamp(0, 8) / 8 * 0.2
        : math.max(1.45, 1.8 - (side - 24) / 24 * 0.35);
    return math.max(units, 1.2 * grid / side);
  }

  /// Paints this art in grid units (the caller scales the canvas). [weight]
  /// is the stroke weight in grid units and [minDetail] the thinnest detail.
  /// [hollow] draws the fills as outlines (a badge not earned yet: the
  /// difference shows in shape, not only in colour). [background] fills the
  /// [cutouts].
  void paint(
    Canvas canvas, {
    required Color color,
    required double weight,
    double minDetail = 0,
    bool hollow = false,
    Color? background,
  }) {
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = weight
      ..strokeJoin = StrokeJoin.miter
      ..strokeMiterLimit = 4
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;
    for (final p in lines) {
      canvas.drawPath(p, line);
    }
    final detail = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(weight * detailRatio, minDetail)
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    for (final p in details) {
      canvas.drawPath(p, detail);
    }
    final solid = hollow
        ? (Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(weight * 0.75, minDetail)
            ..strokeJoin = StrokeJoin.round
            ..isAntiAlias = true)
        : (Paint()
            ..color = color
            ..isAntiAlias = true);
    for (final p in fills) {
      canvas.drawPath(p, solid);
    }
    if (!hollow) {
      final soft = Paint()
        ..color = color.withValues(alpha: color.a * softAlpha)
        ..isAntiAlias = true;
      for (final p in softFills) {
        canvas.drawPath(p, soft);
      }
      if (background != null) {
        final cut = Paint()
          ..color = background
          ..isAntiAlias = true;
        for (final p in cutouts) {
          canvas.drawPath(p, cut);
        }
      }
    } else {
      for (final p in softFills) {
        canvas.drawPath(p, solid);
      }
    }
  }

  static GlyphArt of(CarthaGlyph glyph) => switch (glyph) {
    CarthaGlyph.notice => _notice,
    CarthaGlyph.direction => _direction,
    CarthaGlyph.experiment => _experiment,
    CarthaGlyph.boundaries => _boundaries,
    CarthaGlyph.reflection => _reflection,
    CarthaGlyph.progress => _progress,
  };

  /// Notice: a standing arched mirror with two glints.
  static final _notice = GlyphArt(
    lines: [
      Path()
        ..moveTo(7, 16.5)
        ..lineTo(7, 9.5)
        ..arcToPoint(const Offset(17, 9.5), radius: const Radius.circular(5))
        ..lineTo(17, 16.5)
        ..close(),
      Path()
        ..moveTo(12, 16.5)
        ..lineTo(12, 19.5),
    ],
    details: [
      Path()
        ..moveTo(9.5, 12.6)
        ..lineTo(12.7, 8.5),
      Path()
        ..moveTo(10.7, 14.7)
        ..lineTo(12.6, 12.3),
    ],
    fills: [
      Path()..addPolygon(const [
        Offset(9.5, 19.1),
        Offset(14.5, 19.1),
        Offset(16, 21),
        Offset(8, 21),
      ], true),
    ],
  );

  /// Direction: a compass ring whose needle points to the north star.
  static final GlyphArt _direction = () {
    const c = Offset(10.5, 13.5);
    const d = Offset(0.7071, -0.7071);
    const n = Offset(0.7071, 0.7071);
    final tip = c + d * 5.1, tail = c - d * 5.1;
    final left = c + n * 1.75, right = c - n * 1.75;
    return GlyphArt(
      lines: [Path()..addOval(Rect.fromCircle(center: c, radius: 7.25))],
      fills: [
        Path()..addPolygon([tip, left, right], true),
        star(const Offset(19.25, 4.75), 3.25),
      ],
      softFills: [
        Path()..addPolygon([tail, left, right], true),
      ],
    );
  }();

  /// Experiment: a seedling, one leaf open and one filled, on a low mound.
  static final _experiment = GlyphArt(
    lines: [
      Path()
        ..moveTo(4.5, 20.75)
        ..quadraticBezierTo(12, 18.75, 19.5, 20.75),
      Path()
        ..moveTo(12, 19.6)
        ..cubicTo(12, 16.2, 11.8, 14, 12.4, 10.9),
      Path()
        ..moveTo(11.9, 14.6)
        ..cubicTo(9.5, 15.3, 5.9, 14, 4.9, 10.2)
        ..cubicTo(8.6, 9.6, 11, 11.4, 11.9, 14.6)
        ..close(),
    ],
    fills: [
      Path()
        ..moveTo(12.2, 11.7)
        ..cubicTo(12.2, 7.5, 15, 4.6, 19.7, 4.4)
        ..cubicTo(19.7, 8.9, 16.8, 11.7, 12.2, 11.7)
        ..close(),
    ],
  );

  /// Boundaries: a shelter, a pitched roof over two walls and a doorway.
  static final _boundaries = GlyphArt(
    lines: [
      Path()
        ..moveTo(2.6, 12.4)
        ..lineTo(12, 4)
        ..lineTo(21.4, 12.4),
      Path()
        ..moveTo(5.6, 9.9)
        ..lineTo(5.6, 20.25)
        ..lineTo(18.4, 20.25)
        ..lineTo(18.4, 9.9),
    ],
    fills: [
      Path()
        ..moveTo(10, 20.25)
        ..lineTo(10, 15.25)
        ..arcToPoint(const Offset(14, 15.25), radius: const Radius.circular(2))
        ..lineTo(14, 20.25)
        ..close(),
    ],
  );

  /// Reflection: a lantern standing on an open notebook.
  static final _reflection = GlyphArt(
    lines: [
      // The notebook, open: two curved pages meeting at the spine.
      Path()
        ..moveTo(12, 17)
        ..quadraticBezierTo(8, 15, 3.4, 15.6)
        ..lineTo(3.4, 19.8)
        ..quadraticBezierTo(8, 19.2, 12, 20.8)
        ..quadraticBezierTo(16, 19.2, 20.6, 19.8)
        ..lineTo(20.6, 15.6)
        ..quadraticBezierTo(16, 15, 12, 17)
        ..close(),
      Path()
        ..moveTo(12, 17)
        ..lineTo(12, 20.8),
      // The lantern's handle and glass.
      Path()
        ..moveTo(10.4, 5.3)
        ..arcToPoint(
          const Offset(13.6, 5.3),
          radius: const Radius.circular(1.6),
        ),
      Path()
        ..moveTo(9.4, 7.3)
        ..lineTo(9.4, 12.8)
        ..lineTo(14.6, 12.8)
        ..lineTo(14.6, 7.3),
    ],
    fills: [
      // Cap.
      Path()..addPolygon(const [
        Offset(10.2, 5),
        Offset(13.8, 5),
        Offset(15.4, 7.3),
        Offset(8.6, 7.3),
      ], true),
      // Flame.
      Path()
        ..moveTo(12, 8.3)
        ..cubicTo(13.25, 9.6, 13.2, 11, 12, 11.5)
        ..cubicTo(10.8, 11, 10.75, 9.6, 12, 8.3)
        ..close(),
      // Base.
      Path()..addRect(const Rect.fromLTRB(8.6, 12.8, 15.4, 14.4)),
    ],
  );

  /// Progress: a winding path, wide near and narrow far, leading to an
  /// obelisk on the horizon.
  static final _progress = GlyphArt(
    lines: [
      Path()
        ..moveTo(11.6, 14.2)
        ..lineTo(19.4, 14.2),
    ],
    fills: [
      taper(
        const [
          [
            Offset(6.4, 22),
            Offset(6.4, 19.2),
            Offset(11.6, 19.4),
            Offset(11, 17.2),
          ],
          [
            Offset(11, 17.2),
            Offset(10.6, 15.6),
            Offset(11.4, 14.6),
            Offset(13.2, 14.2),
          ],
        ],
        from: 3.6,
        to: 0.8,
      ),
      Path()..addPolygon(const [
        Offset(13.4, 14.2),
        Offset(13.4, 6.4),
        Offset(14.9, 3.4),
        Offset(16.4, 6.4),
        Offset(16.4, 14.2),
      ], true),
    ],
  );

  /// A ribbon along the cubic Béziers [segments] (each four points, end to
  /// start), [from] wide at the start and [to] wide at the end: a stroke
  /// that narrows with distance, like the emblem's filled tapers.
  static Path taper(
    List<List<Offset>> segments, {
    required double from,
    required double to,
  }) {
    const steps = 16;
    final points = <Offset>[], normals = <Offset>[];
    for (final (s, c) in segments.indexed) {
      for (var i = s == 0 ? 0 : 1; i <= steps; i++) {
        final t = i / steps, u = 1 - t;
        points.add(
          c[0] * (u * u * u) +
              c[1] * (3 * u * u * t) +
              c[2] * (3 * u * t * t) +
              c[3] * (t * t * t),
        );
        final d =
            (c[1] - c[0]) * (3 * u * u) +
            (c[2] - c[1]) * (6 * u * t) +
            (c[3] - c[2]) * (3 * t * t);
        final length = d.distance == 0 ? 1.0 : d.distance;
        normals.add(Offset(-d.dy / length, d.dx / length));
      }
    }
    final left = <Offset>[], right = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final half = (from + (to - from) * i / (points.length - 1)) / 2;
      left.add(points[i] + normals[i] * half);
      right.add(points[i] - normals[i] * half);
    }
    return Path()..addPolygon([...left, ...right.reversed], true);
  }

  /// A four-point star of [radius] at [centre] (the brand's compass star).
  static Path star(Offset centre, double radius, {double inner = 0.29}) =>
      Path()..addPolygon([
        for (var k = 0; k < 8; k++)
          centre +
              Offset(
                    math.cos(-math.pi / 2 + k * math.pi / 4),
                    math.sin(-math.pi / 2 + k * math.pi / 4),
                  ) *
                  (k.isEven ? radius : radius * inner),
      ], true);
}

/// Paints [glyph] in [color], centred in the box at its shortest side.
class GlyphPainter extends CustomPainter {
  const GlyphPainter({required this.glyph, required this.color});

  final CarthaGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (!side.isFinite || side <= 0) return;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / GlyphArt.grid);
    GlyphArt.of(glyph).paint(
      canvas,
      color: color,
      weight: GlyphArt.strokeFor(side),
      minDetail: GlyphArt.grid / side,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}
