import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../domain/content.dart' show CampaignChapter;
import '../../theme/cartha_theme.dart';
import 'glyph_art.dart';

/// The five chapter keepsakes, one object per chapter, each standing on a
/// small stele (the pointed stone tablets of ancient Carthage):
///
/// * **See the terrain** — a spyglass.
/// * **Find the pattern** — a mosaic tile.
/// * **Raise your banner** — a banner with a sun on it.
/// * **Break autopilot** — an hourglass.
/// * **Plan the campaign** — a scroll with a short list and a seal.
///
/// * **Kept** (an experiment of that chapter tried): a filled hero stele with
///   a bronze rim on a plinth, the object painted in bronze and light.
/// * **Not yet:** an empty slot with a dashed rim, no plinth, the object in
///   outline only.
///
/// So the two states differ in shape, never by colour alone.
abstract final class KeepsakeArt {
  /// The design space (64 × 64).
  static const double grid = 64;

  /// The stele's outline in [grid] units.
  static Path stele() => Path()
    ..addPolygon(const [
      Offset(15, 59),
      Offset(15, 19),
      Offset(32, 6),
      Offset(49, 19),
      Offset(49, 59),
    ], true);

  /// The plinth under a kept stele.
  static const Rect plinth = Rect.fromLTRB(11, 58, 53, 62);
}

/// Paints the keepsake of [chapter], kept or not yet, centred in the box at
/// its shortest side. Colours from palette tokens only.
class KeepsakePainter extends CustomPainter {
  const KeepsakePainter({
    required this.chapter,
    required this.kept,
    required this.palette,
  });

  final CampaignChapter chapter;
  final bool kept;
  final CarthaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (!side.isFinite || side <= 0) return;
    final scale = side / KeepsakeArt.grid;
    final unit = 1 / scale; // one logical pixel in grid units
    final p = palette;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(scale);
    final stele = KeepsakeArt.stele();
    if (kept) {
      canvas.drawRect(
        KeepsakeArt.plinth,
        Paint()..color = Color.lerp(p.heroAccent, p.hero, 0.35)!,
      );
      canvas.drawPath(
        stele,
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(0, 6),
            const Offset(0, 59),
            [p.heroRaised, p.hero],
          ),
      );
      // A soft light behind the object.
      canvas.drawCircle(
        const Offset(32, 37),
        17,
        Paint()
          ..shader = ui.Gradient.radial(const Offset(32, 37), 17, [
            p.heroAccent.withValues(alpha: 0.22),
            p.heroAccent.withValues(alpha: 0),
          ]),
      );
      canvas.drawPath(stele, _stroke(p.heroAccent, math.max(1.8, 1.1 * unit)));
      canvas.drawPath(
        Path()..addPolygon(const [
          Offset(18.5, 56),
          Offset(18.5, 20.6),
          Offset(32, 10.3),
          Offset(45.5, 20.6),
          Offset(45.5, 56),
        ], true),
        _stroke(
          p.heroAccent.withValues(alpha: 0.35),
          math.max(0.7, 0.8 * unit),
        ),
      );
    } else {
      canvas.drawPath(stele, Paint()..color = p.raised);
      final rim = _stroke(p.textSecondary, math.max(1.3, 1.1 * unit));
      for (final metric in stele.computeMetrics()) {
        const dash = 3.2, gap = 2.4;
        for (var d = 0.0; d < metric.length; d += dash + gap) {
          canvas.drawPath(
            metric.extractPath(d, math.min(d + dash, metric.length)),
            rim,
          );
        }
      }
    }
    final ink = _Ink(canvas, kept, p, unit);
    switch (chapter) {
      case CampaignChapter.terrain:
        _spyglass(ink);
      case CampaignChapter.pattern:
        _mosaic(ink);
      case CampaignChapter.banner:
        _fitted(canvas, 0.88, 4, () => _banner(ink));
      case CampaignChapter.autopilot:
        _fitted(canvas, 0.86, 0, () => _hourglass(ink));
      case CampaignChapter.plan:
        _fitted(canvas, 0.9, 1.5, () => _scroll(ink));
    }
    canvas.restore();
  }

  /// Draws [body] scaled by [k] about the stele's middle and moved down by
  /// [dy], so a tall object clears the pointed top and the rims.
  static void _fitted(Canvas canvas, double k, double dy, VoidCallback body) {
    canvas.save();
    canvas.translate(32, 38 + dy);
    canvas.scale(k);
    canvas.translate(-32, -38);
    body();
    canvas.restore();
  }

  /// See the terrain: a brass spyglass, its lens catching the light.
  static void _spyglass(_Ink ink) {
    final canvas = ink.canvas;
    canvas.save();
    canvas.translate(31, 40);
    canvas.rotate(-0.62);
    RRect seg(double l, double half, double r, double radius) =>
        RRect.fromLTRBR(l, -half, r, half, Radius.circular(radius));
    ink.fill(Path()..addRRect(seg(-16, 2.1, -8.6, 0.8)), ink.shade);
    ink.fill(Path()..addRRect(seg(-9.2, 3, 0.6, 0.9)), ink.light);
    ink.fill(Path()..addRRect(seg(0, 4.2, 12.8, 1)), ink.body);
    ink.fill(Path()..addRRect(seg(12.2, 5.1, 15.6, 1)), ink.shade);
    // Bands and a highlight along the tube.
    ink.fill(
      Path()..addRect(const Rect.fromLTRB(5.2, -4.2, 6.6, 4.2)),
      ink.shade,
      detail: true,
    );
    ink.fill(
      Path()..addRect(const Rect.fromLTRB(-1.2, -3, 0, 3)),
      ink.shade,
      detail: true,
    );
    ink.line(
      Path()
        ..moveTo(1.4, -2.5)
        ..lineTo(11.4, -2.5),
      ink.light,
      0.9,
      detail: true,
    );
    // The lens.
    ink.fill(
      Path()..addOval(
        Rect.fromCenter(center: const Offset(15.9, 0), width: 2, height: 8.4),
      ),
      ink.light,
      detail: true,
    );
    canvas.restore();
    // A glint of what it sees.
    ink.fill(
      GlyphArt.star(const Offset(45, 22.5), 3.6),
      ink.light,
      detail: true,
    );
  }

  /// Find the pattern: a mosaic tile, its tesserae set in a repeating pattern.
  static void _mosaic(_Ink ink) {
    const l = 19.5, t = 25.0, side = 25.0, gap = 1.1, n = 5;
    const cell = (side - gap * (n - 1)) / n;
    if (!ink.kept) {
      ink.line(
        Path()..addRect(const Rect.fromLTWH(l, t, side, side)),
        ink.body,
        1,
      );
      for (var i = 1; i < n; i++) {
        final x = l + i * (cell + gap) - gap / 2;
        ink.line(
          Path()
            ..moveTo(x, t)
            ..lineTo(x, t + side),
          ink.body,
          0.7,
        );
        final y = t + i * (cell + gap) - gap / 2;
        ink.line(
          Path()
            ..moveTo(l, y)
            ..lineTo(l + side, y),
          ink.body,
          0.7,
        );
      }
      return;
    }
    // S shade, L light, B bronze, C the light centre.
    const pattern = ['SLSLS', 'LBBBL', 'SBCBS', 'LBBBL', 'SLSLS'];
    ink.line(
      Path()..addRect(
        const Rect.fromLTWH(l - 1.6, t - 1.6, side + 3.2, side + 3.2),
      ),
      ink.body,
      0.9,
    );
    for (var row = 0; row < n; row++) {
      for (var col = 0; col < n; col++) {
        final color = switch (pattern[row][col]) {
          'S' => ink.shade,
          'L' => ink.light,
          'C' => ink.light,
          _ => ink.body,
        };
        final rect = Rect.fromLTWH(
          l + col * (cell + gap),
          t + row * (cell + gap),
          cell,
          cell,
        );
        ink.fill(
          Path()..addRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(0.6)),
          ),
          color,
        );
      }
    }
    // The centre tessera, set apart.
    final centre = Rect.fromLTWH(
      l + 2 * (cell + gap),
      t + 2 * (cell + gap),
      cell,
      cell,
    );
    ink.line(Path()..addRect(centre.deflate(1.2)), ink.body, 0.7, detail: true);
  }

  /// Raise your banner: a banner on a pole, a sun on the cloth.
  static void _banner(_Ink ink) {
    // The pole and its round finial.
    ink.line(
      Path()
        ..moveTo(22, 14.5)
        ..lineTo(22, 54),
      ink.shade,
      2.2,
    );
    ink.fill(
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(22, 13), radius: 2.2)),
      ink.light,
    );
    // The crossbar and the cloth, cut in a swallowtail.
    ink.line(
      Path()
        ..moveTo(19, 19)
        ..lineTo(46.5, 19),
      ink.shade,
      1.8,
    );
    final cloth = Path()
      ..moveTo(24.5, 19.8)
      ..lineTo(44.5, 19.8)
      ..lineTo(44.5, 45)
      ..lineTo(34.5, 39.5)
      ..lineTo(24.5, 45)
      ..close();
    ink.fill(cloth, ink.body);
    // A fold, the sun and its horizon.
    ink.line(
      Path()
        ..moveTo(29, 21)
        ..quadraticBezierTo(28, 31, 29.5, 41.5),
      ink.shade,
      0.8,
      detail: true,
    );
    ink.fill(
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(34.5, 28.5), radius: 4)),
      ink.light,
    );
    ink.line(
      Path()
        ..moveTo(28.5, 34.4)
        ..lineTo(40.5, 34.4),
      ink.light,
      1.1,
      detail: true,
    );
    // Tassels.
    for (final x in const [24.5, 44.5]) {
      ink.line(
        Path()
          ..moveTo(x, 45)
          ..lineTo(x, 49.5),
        ink.light,
        1,
        detail: true,
      );
    }
  }

  /// Break autopilot: an hourglass, sand running.
  static void _hourglass(_Ink ink) {
    // The glass.
    final glass = Path()
      ..moveTo(24.5, 20.5)
      ..quadraticBezierTo(24.5, 31.5, 31, 36.6)
      ..lineTo(31, 38.4)
      ..quadraticBezierTo(24.5, 43.5, 24.5, 54.5)
      ..lineTo(39.5, 54.5)
      ..quadraticBezierTo(39.5, 43.5, 33, 38.4)
      ..lineTo(33, 36.6)
      ..quadraticBezierTo(39.5, 31.5, 39.5, 20.5)
      ..close();
    ink.fill(glass, ink.glass, detail: true);
    // Sand: what is left above, the stream, the pile below.
    ink.fill(
      Path()
        ..moveTo(26.6, 29)
        ..lineTo(37.4, 29)
        ..quadraticBezierTo(36, 33.5, 32, 37)
        ..quadraticBezierTo(28, 33.5, 26.6, 29)
        ..close(),
      ink.body,
      detail: true,
    );
    ink.line(
      Path()
        ..moveTo(32, 37)
        ..lineTo(32, 50),
      ink.light,
      0.8,
      detail: true,
    );
    ink.fill(
      Path()
        ..moveTo(25.2, 54.5)
        ..quadraticBezierTo(32, 44.5, 38.8, 54.5)
        ..close(),
      ink.body,
      detail: true,
    );
    ink.line(glass, ink.light, 1);
    // The frame: two plates and two posts.
    ink.line(
      Path()
        ..moveTo(21.5, 20.5)
        ..lineTo(21.5, 54.5),
      ink.shade,
      1.6,
    );
    ink.line(
      Path()
        ..moveTo(42.5, 20.5)
        ..lineTo(42.5, 54.5),
      ink.shade,
      1.6,
    );
    ink.fill(
      Path()
        ..addRRect(RRect.fromLTRBR(19, 17, 45, 21, const Radius.circular(1))),
      ink.body,
    );
    ink.fill(
      Path()
        ..addRRect(RRect.fromLTRBR(19, 54, 45, 58, const Radius.circular(1))),
      ink.body,
    );
  }

  /// Plan the campaign: a scroll with a short list and a wax seal.
  static void _scroll(_Ink ink) {
    // The sheet.
    ink.fill(Path()..addRect(const Rect.fromLTRB(23, 21, 41, 52)), ink.light);
    // The two rolls with their knobs.
    for (final y in const [18.5, 53.5]) {
      ink.fill(
        Path()..addRRect(
          RRect.fromLTRBR(20, y - 2.6, 44, y + 2.6, const Radius.circular(2.4)),
        ),
        ink.body,
      );
      for (final x in const [18.4, 45.6]) {
        ink.fill(
          Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: 1.7)),
          ink.shade,
        );
      }
    }
    // A short list: a dot and a line each.
    for (final (y, length) in const [
      (26.5, 9.5),
      (31.5, 7.0),
      (36.5, 10.0),
      (41.5, 5.5),
    ]) {
      ink.fill(
        Path()..addOval(Rect.fromCircle(center: Offset(26.6, y), radius: 1)),
        ink.inkOnLight,
        detail: true,
      );
      ink.line(
        Path()
          ..moveTo(29, y)
          ..lineTo(29 + length, y),
        ink.inkOnLight,
        1,
        detail: true,
      );
    }
    if (!ink.kept) {
      // The list, in outline: three lines.
      for (final y in const [28.0, 34.0, 40.0]) {
        ink.line(
          Path()
            ..moveTo(26.5, y)
            ..lineTo(37.5, y),
          ink.body,
          0.8,
        );
      }
    }
    // The seal, with two ribbon tails.
    ink.fill(
      Path()..addPolygon(const [
        Offset(37.5, 47),
        Offset(36, 52.5),
        Offset(37.8, 51.4),
        Offset(39.2, 53),
        Offset(39.4, 48),
      ], true),
      ink.shade,
      detail: true,
    );
    ink.fill(
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(39.5, 46), radius: 3.4)),
      ink.body,
    );
    ink.line(
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(39.5, 46), radius: 1.8)),
      ink.light,
      0.7,
      detail: true,
    );
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  @override
  bool shouldRepaint(KeepsakePainter old) =>
      old.chapter != chapter || old.kept != kept || old.palette != palette;
}

/// How a keepsake's parts are drawn: kept, filled in bronze and light; not
/// yet, every part in outline (details left out) in the secondary colour.
class _Ink {
  _Ink(this.canvas, this.kept, this.p, this.unit);

  final Canvas canvas;
  final bool kept;
  final CarthaPalette p;

  /// One logical pixel in grid units (so lines stay at least that wide).
  final double unit;

  Color get body => p.heroAccent;
  Color get light => Color.lerp(p.heroAccent, p.onHero, 0.62)!;
  Color get shade => Color.lerp(p.heroAccent, p.hero, 0.42)!;
  Color get glass => p.onHeroMuted.withValues(alpha: 0.22);
  Color get inkOnLight => Color.lerp(p.hero, p.heroAccent, 0.3)!;

  double get _outline => math.max(1.15, 1.05 * unit);

  /// Fills [path]; not yet, outlines it (or leaves a [detail] out).
  void fill(Path path, Color color, {bool detail = false}) {
    if (kept) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..isAntiAlias = true,
      );
    } else if (!detail) {
      canvas.drawPath(path, KeepsakePainter._stroke(p.textSecondary, _outline));
    }
  }

  /// Strokes [path] [width] wide; not yet, thinner in the secondary colour
  /// (or leaves a [detail] out).
  void line(Path path, Color color, double width, {bool detail = false}) {
    if (!kept && detail) return;
    canvas.drawPath(
      path,
      KeepsakePainter._stroke(
        kept ? color : p.textSecondary,
        math.max(kept ? width : math.min(width, _outline), unit),
      ),
    );
  }
}
