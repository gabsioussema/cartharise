import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../theme/cartha_theme.dart';
import '../scenes.dart';
import 'glyph_art.dart';

/// What each lesson illustration shows (one memorable scene per lesson, in
/// the brand scenes' hero colours).
enum LessonScene {
  /// lesson.01 "Who you are comes first": a tree at sunrise whose roots,
  /// drawn in the earth below, reach wider than its crown.
  roots,

  /// lesson.02 "Your actions have reasons": an iceberg under the moon, most
  /// of it below the waterline.
  iceberg,

  /// lesson.03 "Why change can feel risky": a walled hilltop town at dusk,
  /// its gate open and light spilling down the path.
  citadel,

  /// lesson.04 "Ways of seeing can widen": arches opening wider and wider
  /// around a calm sea horizon.
  arches,

  /// lesson.05 "Aim, check, adjust": a sailboat tacking toward a
  /// lighthouse, its zigzag wake behind it.
  sailing,

  /// lesson.06 "A day off autopilot": one day's arc, from the morning sun
  /// through short pauses to the evening moon.
  dayArc,

  /// lesson.07 "Your direction as a game": a marked route with waypoints up
  /// to a flag on the summit.
  route;

  /// The scene of `lesson.<nn>`; other ids cycle through the seven.
  static LessonScene of(String lessonId) {
    final match = RegExp(r'(\d+)$').firstMatch(lessonId);
    final n = match == null ? 1 : int.parse(match[1]!);
    return values[(n - 1) % values.length];
  }
}

/// Paints the illustration of a lesson at any width: the scene's subject is
/// composed around the centre at the box's height, and sky, land and sea
/// extend to the sides, so it reads on a narrow card and a wide tablet
/// column alike. Static (no motion); colours from palette tokens only.
class LessonArtPainter extends CustomPainter {
  const LessonArtPainter({required this.scene, required this.palette});

  final LessonScene scene;
  final CarthaPalette palette;

  /// Narrower boxes are drawn at this width / height and cropped at the
  /// sides, so the subject never squeezes.
  static const double minAspect = 1.8;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.isFinite) return;
    final width = math.max(size.width, size.height * minAspect);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - width) / 2, 0);
    final s = _LessonSketch(
      canvas,
      Size(width, size.height),
      ScenePalette.of(palette),
    );
    switch (scene) {
      case LessonScene.roots:
        s.roots();
      case LessonScene.iceberg:
        s.iceberg();
      case LessonScene.citadel:
        s.citadel();
      case LessonScene.arches:
        s.arches();
      case LessonScene.sailing:
        s.sailing();
      case LessonScene.dayArc:
        s.dayArc();
      case LessonScene.route:
        s.route();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(LessonArtPainter old) =>
      old.scene != scene ||
      old.palette.hero != palette.hero ||
      old.palette.heroRaised != palette.heroRaised ||
      old.palette.heroAccent != palette.heroAccent ||
      old.palette.onHero != palette.onHero ||
      old.palette.onHeroMuted != palette.onHeroMuted;
}

/// Scene helpers in focal units: `f(x, y)` is x box-heights from the centre
/// and y box-heights from the top.
class _LessonSketch extends SceneSketch {
  _LessonSketch(Canvas canvas, Size size, ScenePalette c)
    : super(canvas, size, c, 1);

  Offset f(double x, double y) => Offset(w / 2 + x * h, y * h);

  Path poly(List<(double, double)> points) =>
      Path()..addPolygon([for (final (x, y) in points) f(x, y)], true);

  Rect box(double l, double t, double r, double b) =>
      Rect.fromPoints(f(l, t), f(r, b));

  Rect circle(Offset centre, double radius) =>
      Rect.fromCircle(center: centre, radius: radius);

  double px(double fraction, [double min = 1]) => math.max(min, h * fraction);

  /// A smooth curve through [points] (Catmull-Rom as cubic Béziers).
  Path through(List<(double, double)> points) {
    final p = [for (final (x, y) in points) f(x, y)];
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (var i = 0; i < p.length - 1; i++) {
      final p0 = p[math.max(0, i - 1)], p1 = p[i], p2 = p[i + 1];
      final p3 = p[math.min(p.length - 1, i + 2)];
      final c1 = p1 + (p2 - p0) / 6, c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  /// A water surface from [top] to [bottom], lighter toward the horizon.
  void water(double top, double bottom, {double light = 0.35}) {
    canvas.drawRect(
      Rect.fromLTRB(0, top * h, w, bottom * h),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, top * h),
          Offset(0, bottom * h),
          [Color.lerp(c.sea, c.glow, light)!, c.near],
        ),
    );
    canvas.drawLine(
      Offset(0, top * h),
      Offset(w, top * h),
      stroke(c.sun.withValues(alpha: 0.35), px(0.005)),
    );
  }

  /// Shimmering strokes under a light at [x] (focal units).
  void glints(double x, double top, {double width = 0.08, int count = 5}) {
    for (var i = 0; i < count; i++) {
      final half = h * (width - i * width / (count + 1));
      final y = (top + 0.03 + i * 0.04) * h;
      final cx = f(x, 0).dx;
      canvas.drawLine(
        Offset(cx - half, y),
        Offset(cx + half, y),
        stroke(c.sunCore.withValues(alpha: 0.5 - i * 0.07), px(0.007)),
      );
    }
  }

  void stars(List<(double, double, double)> stars, {double alpha = 0.6}) {
    for (final (x, y, r) in stars) {
      canvas.drawCircle(
        Offset(x * w, y * h),
        math.max(0.8, h * r),
        fill(c.sunCore.withValues(alpha: alpha)),
      );
    }
  }

  void crescent(Offset centre, double r) {
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(circle(centre, r)),
        Path()..addOval(circle(centre + Offset(r * 0.45, -r * 0.22), r * 0.86)),
      ),
      fill(c.sunCore),
    );
  }

  // ── lesson.01 ─────────────────────────────────────────────────────────

  void roots() {
    const soil = 0.62;
    sky(0.6, warmth: 0.95);
    sunDisc(f(-0.5, 0.5), h * 0.08);
    ridge([
      (-0.05, 0.53),
      (0.22, 0.47),
      (0.5, 0.52),
      (0.78, 0.46),
      (1.05, 0.51),
    ], c.far);
    hazeLines([(0.18, 0.55, 0.14), (0.84, 0.54, 0.12)]);
    ridge([
      (-0.05, 0.61),
      (0.3, 0.585),
      (0.5, 0.565),
      (0.7, 0.585),
      (1.05, 0.61),
    ], c.mid);
    // The earth, cut away to show the roots.
    canvas.drawRect(Rect.fromLTRB(0, soil * h, w, h), fill(c.nearest));
    canvas.drawLine(
      Offset(0, soil * h),
      Offset(w, soil * h),
      stroke(c.sun.withValues(alpha: 0.28), px(0.005)),
    );
    final root = stroke(c.sun.withValues(alpha: 0.6), px(0.016, 1.2));
    final rootlet = stroke(c.sun.withValues(alpha: 0.34), px(0.009));
    void curve(Paint paint, List<(double, double)> p) {
      final a = f(p[0].$1, p[0].$2);
      final path = Path()..moveTo(a.dx, a.dy);
      if (p.length == 3) {
        final b = f(p[1].$1, p[1].$2), d = f(p[2].$1, p[2].$2);
        path.quadraticBezierTo(b.dx, b.dy, d.dx, d.dy);
      } else {
        final b = f(p[1].$1, p[1].$2),
            cc = f(p[2].$1, p[2].$2),
            d = f(p[3].$1, p[3].$2);
        path.cubicTo(b.dx, b.dy, cc.dx, cc.dy, d.dx, d.dy);
      }
      canvas.drawPath(path, paint);
    }

    const base = (0.0, soil);
    for (final r in const [
      [(-0.04, 0.74), (-0.3, 0.78), (-0.56, 0.93)],
      [(0.0, 0.78), (-0.12, 0.86), (-0.19, 0.99)],
      [(0.02, 0.8), (0.07, 0.9), (0.06, 1.02)],
      [(0.06, 0.74), (0.3, 0.76), (0.5, 0.93)],
      [(0.05, 0.69), (0.42, 0.67), (0.8, 0.8)],
      [(-0.05, 0.69), (-0.45, 0.68), (-0.84, 0.8)],
    ]) {
      curve(root, [base, ...r]);
    }
    for (final r in const [
      [(-0.3, 0.79), (-0.37, 0.86), (-0.35, 0.97)],
      [(0.3, 0.78), (0.37, 0.86), (0.34, 0.98)],
      [(-0.56, 0.73), (-0.63, 0.8), (-0.67, 0.92)],
      [(0.53, 0.72), (0.61, 0.8), (0.64, 0.93)],
      [(-0.12, 0.86), (-0.03, 0.92), (-0.05, 1.0)],
      [(0.36, 0.8), (0.46, 0.84), (0.47, 0.98)],
    ]) {
      curve(rootlet, r);
    }
    // The tree.
    final bark = fill(c.nearest);
    canvas.drawPath(
      poly([
        (-0.03, soil + 0.005),
        (-0.014, 0.38),
        (0.014, 0.38),
        (0.03, soil + 0.005),
      ]),
      bark,
    );
    final branch = stroke(c.nearest, px(0.014, 1.2));
    canvas.drawLine(f(0, 0.47), f(-0.085, 0.36), branch);
    canvas.drawLine(f(0, 0.44), f(0.09, 0.33), branch);
    var crown = Path();
    for (final (x, y, r) in const [
      (0.0, 0.25, 0.15),
      (-0.12, 0.31, 0.105),
      (0.125, 0.3, 0.11),
      (-0.06, 0.16, 0.09),
      (0.07, 0.165, 0.095),
    ]) {
      crown = Path.combine(
        PathOperation.union,
        crown,
        Path()..addOval(circle(f(x, y), r * h)),
      );
    }
    canvas.drawPath(crown, fill(Color.lerp(c.near, c.nearest, 0.25)!));
    // Rim light on the sun's side.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, f(-0.02, 0).dx, h));
    canvas.drawPath(crown, stroke(c.sun.withValues(alpha: 0.45), px(0.007)));
    canvas.restore();
  }

  // ── lesson.02 ─────────────────────────────────────────────────────────

  void iceberg() {
    const sea = 0.5;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, sea * h),
          [c.nearest, c.skyTop, Color.lerp(c.skyMid, c.sea, 0.4)!],
          const [0, 0.55, 1],
        ),
    );
    stars(const [
      (0.05, 0.1, 0.006),
      (0.13, 0.3, 0.004),
      (0.23, 0.08, 0.005),
      (0.31, 0.24, 0.004),
      (0.4, 0.07, 0.006),
      (0.6, 0.12, 0.005),
      (0.66, 0.3, 0.004),
      (0.74, 0.06, 0.004),
      (0.81, 0.2, 0.006),
      (0.89, 0.33, 0.004),
      (0.95, 0.09, 0.005),
    ]);
    final moon = f(-0.62, 0.21);
    final mr = h * 0.065;
    halo(moon, mr * 3.4, 0.4);
    crescent(moon, mr);
    water(sea, 1, light: 0.15);
    glints(-0.62, sea, width: 0.07);
    // Below the waterline: most of it.
    final under = poly(const [
      (-0.21, 0.5),
      (-0.37, 0.6),
      (-0.47, 0.74),
      (-0.39, 0.88),
      (-0.13, 0.97),
      (0.2, 0.95),
      (0.43, 0.84),
      (0.49, 0.68),
      (0.31, 0.56),
      (0.25, 0.5),
    ]);
    canvas.drawPath(under, fill(c.haze.withValues(alpha: 0.13)));
    canvas.drawPath(under, stroke(c.haze.withValues(alpha: 0.3), px(0.006)));
    final facet = stroke(c.haze.withValues(alpha: 0.14), px(0.005));
    canvas.drawPath(
      Path()
        ..addPolygon([f(-0.05, 0.5), f(-0.19, 0.74), f(-0.13, 0.97)], false),
      facet,
    );
    canvas.drawPath(
      Path()..addPolygon([f(0.12, 0.5), f(0.21, 0.72), f(0.43, 0.84)], false),
      facet,
    );
    canvas.drawLine(f(-0.47, 0.74), f(-0.19, 0.74), facet);
    // Above it: only the tip.
    canvas.drawPath(
      poly(const [
        (-0.21, 0.5),
        (-0.13, 0.37),
        (-0.05, 0.34),
        (0.03, 0.2),
        (0.0, 0.5),
      ]),
      fill(c.sunCore.withValues(alpha: 0.92)),
    );
    canvas.drawPath(
      poly(const [
        (0.03, 0.2),
        (0.1, 0.3),
        (0.17, 0.33),
        (0.25, 0.5),
        (0.0, 0.5),
      ]),
      fill(c.haze.withValues(alpha: 0.6)),
    );
  }

  // ── lesson.03 ─────────────────────────────────────────────────────────

  void citadel() {
    sky(0.66);
    stars(const [
      (0.08, 0.12, 0.004),
      (0.2, 0.22, 0.003),
      (0.9, 0.1, 0.004),
    ], alpha: 0.45);
    sunDisc(f(0.72, 0.6), h * 0.07);
    ridge([
      (-0.05, 0.64),
      (0.2, 0.58),
      (0.45, 0.62),
      (0.7, 0.57),
      (1.05, 0.63),
    ], c.far);
    // The hill.
    final a = f(-0.85, 0.86), b = f(-0.75, 0.66), d = f(-0.58, 0.655);
    final e = f(0.75, 0.66), g = f(0.85, 0.86);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, 0.92 * h)
        ..lineTo(a.dx - 0.2 * h, 0.92 * h)
        ..cubicTo(a.dx, a.dy, b.dx, b.dy, d.dx, d.dy)
        ..lineTo(f(0.58, 0.655).dx, d.dy)
        ..cubicTo(e.dx, e.dy, g.dx, g.dy, g.dx + 0.2 * h, 0.92 * h)
        ..lineTo(w, 0.92 * h)
        ..lineTo(w, h)
        ..close(),
      fill(c.near),
    );
    // Light spilling from the open gate down the path.
    canvas.drawPath(
      poly(const [(-0.06, 0.66), (0.06, 0.66), (0.27, 1.0), (-0.27, 1.0)]),
      fill(c.sun.withValues(alpha: 0.14)),
    );
    canvas.drawPath(
      poly(const [(-0.035, 0.66), (0.035, 0.66), (0.12, 1.0), (-0.12, 1.0)]),
      fill(c.sun.withValues(alpha: 0.14)),
    );
    // Walls, towers and the gatehouse.
    final stone = fill(c.nearest);
    canvas.drawRect(box(-0.36, 0.47, 0.36, 0.66), stone);
    for (var x = -0.3; x <= 0.31; x += 0.075) {
      if (x.abs() < 0.12) continue;
      canvas.drawRect(box(x - 0.02, 0.437, x + 0.02, 0.471), stone);
    }
    for (final side in const [-1.0, 1.0]) {
      canvas.drawRect(box(side * 0.33, 0.36, side * 0.5, 0.66), stone);
      for (final x in const [0.355, 0.415, 0.475]) {
        canvas.drawRect(
          box(side * x - 0.016, 0.326, side * x + 0.016, 0.361),
          stone,
        );
      }
      canvas.drawRect(
        box(side * 0.405, 0.43, side * 0.425, 0.475),
        fill(c.sun.withValues(alpha: 0.75)),
      );
    }
    canvas.drawRect(box(-0.115, 0.42, 0.115, 0.66), stone);
    for (final x in const [-0.085, 0.0, 0.085]) {
      canvas.drawRect(box(x - 0.018, 0.388, x + 0.018, 0.421), stone);
    }
    // Rim light from the low sun on the right.
    final rim = stroke(c.sun.withValues(alpha: 0.5), px(0.0045));
    canvas.drawLine(f(0.5, 0.36), f(0.5, 0.66), rim);
    canvas.drawLine(f(0.33, 0.36), f(0.5, 0.36), rim);
    canvas.drawLine(f(-0.5, 0.36), f(-0.33, 0.36), rim);
    canvas.drawLine(f(-0.33, 0.471), f(-0.115, 0.471), rim);
    canvas.drawLine(f(0.115, 0.471), f(0.33, 0.471), rim);
    canvas.drawLine(f(-0.115, 0.421), f(0.115, 0.421), rim);
    // The gate, open: warm light inside, one door swung in.
    halo(f(0, 0.6), h * 0.18, 0.5);
    final r = 0.06 * h;
    canvas.drawPath(
      Path()
        ..moveTo(f(-0.06, 0.66).dx, f(-0.06, 0.66).dy)
        ..lineTo(f(-0.06, 0.56).dx, f(-0.06, 0.56).dy)
        ..arcToPoint(f(0.06, 0.56), radius: Radius.circular(r))
        ..lineTo(f(0.06, 0.66).dx, f(0.06, 0.66).dy)
        ..close(),
      fill(c.sunCore),
    );
    canvas.drawPath(
      poly(const [(0.06, 0.66), (0.06, 0.56), (0.028, 0.582), (0.028, 0.666)]),
      fill(c.nearest),
    );
  }

  // ── lesson.04 ─────────────────────────────────────────────────────────

  void arches() {
    const horizon = 0.6, floor = 0.83;
    sky(horizon, warmth: 0.7);
    sunDisc(f(0, 0.5), h * 0.05);
    water(horizon, floor, light: 0.4);
    glints(0, horizon, width: 0.09);
    canvas.drawRect(Rect.fromLTRB(0, floor * h, w, h), fill(c.nearest));
    canvas.drawLine(
      Offset(0, floor * h),
      Offset(w, floor * h),
      stroke(c.sun.withValues(alpha: 0.4), px(0.005)),
    );
    // Arches, each one wider than the last.
    const spring = 0.52;
    for (var k = 3; k >= 0; k--) {
      final hw = 0.16 + k * 0.2, hv = 0.15 + k * 0.095;
      final alpha = const [0.95, 0.62, 0.42, 0.26][k];
      final color = c.sun.withValues(alpha: alpha);
      final weight = px(0.016 - k * 0.0025, 1.2);
      final left = f(-hw, floor), right = f(hw, floor);
      canvas.drawPath(
        Path()
          ..moveTo(left.dx, left.dy)
          ..lineTo(left.dx, spring * h)
          ..arcToPoint(
            Offset(right.dx, spring * h),
            radius: Radius.elliptical(hw * h, hv * h),
          )
          ..lineTo(right.dx, right.dy),
        stroke(color, weight)..strokeCap = StrokeCap.butt,
      );
      for (final x in [-hw, hw]) {
        canvas.drawRect(
          box(x - 0.022, floor - 0.022, x + 0.022, floor),
          fill(color),
        );
        canvas.drawRect(
          box(x - 0.018, spring - 0.012, x + 0.018, spring),
          fill(color),
        );
      }
    }
  }

  // ── lesson.05 ─────────────────────────────────────────────────────────

  void sailing() {
    const horizon = 0.5;
    sky(horizon);
    sunDisc(f(-0.6, 0.47), h * 0.07);
    water(horizon, 1, light: 0.4);
    glints(-0.6, horizon);
    // Headland and lighthouse.
    canvas.drawPath(
      Path()..addPolygon([
        f(0.34, 0.505),
        f(0.44, 0.465),
        f(0.56, 0.435),
        f(0.7, 0.43),
        f(0.88, 0.45),
        f(1.02, 0.505),
      ], true),
      fill(c.near),
    );
    final lamp = f(0.605, 0.31);
    canvas.drawPath(
      poly(const [(0.582, 0.44), (0.594, 0.33), (0.616, 0.33), (0.628, 0.44)]),
      fill(c.nearest),
    );
    canvas.drawPath(
      poly(const [(0.586, 0.293), (0.624, 0.293), (0.605, 0.268)]),
      fill(c.nearest),
    );
    canvas.drawPath(
      poly(const [(0.605, 0.31), (0.3, 0.27), (0.3, 0.345)]),
      fill(c.sun.withValues(alpha: 0.12)),
    );
    halo(lamp, h * 0.1, 0.8);
    canvas.drawRect(box(0.594, 0.293, 0.616, 0.33), fill(c.sunCore));
    // The wake: aim, check, adjust.
    final wake = stroke(c.haze.withValues(alpha: 0.45), px(0.008));
    dashed(
      Path()..addPolygon([
        f(-0.84, 0.99),
        f(-0.5, 0.9),
        f(-0.66, 0.83),
        f(-0.32, 0.78),
        f(-0.14, 0.75),
      ], false),
      wake,
      dash: h * 0.03,
      gap: h * 0.018,
    );
    // The course ahead.
    dashed(
      Path()
        ..moveTo(f(0.14, 0.72).dx, f(0.14, 0.72).dy)
        ..quadraticBezierTo(
          f(0.4, 0.66).dx,
          f(0.4, 0.66).dy,
          f(0.5, 0.53).dx,
          f(0.5, 0.53).dy,
        ),
      stroke(c.sunCore.withValues(alpha: 0.5), px(0.008))
        ..strokeCap = StrokeCap.round,
      dash: h * 0.004,
      gap: h * 0.03,
    );
    // The boat.
    canvas.drawPath(
      poly(const [(-0.15, 0.725), (0.13, 0.725), (0.09, 0.77), (-0.11, 0.77)]),
      fill(c.nearest),
    );
    canvas.drawLine(
      f(-0.006, 0.725),
      f(-0.006, 0.49),
      stroke(c.nearest, px(0.01)),
    );
    canvas.drawPath(
      poly(const [(0.006, 0.5), (0.006, 0.71), (0.13, 0.71)]),
      fill(c.sunCore),
    );
    canvas.drawPath(
      poly(const [(-0.018, 0.52), (-0.018, 0.71), (-0.13, 0.71)]),
      fill(c.haze.withValues(alpha: 0.75)),
    );
    final ripple = stroke(c.haze.withValues(alpha: 0.25), px(0.006));
    canvas.drawLine(f(-0.12, 0.79), f(0.1, 0.79), ripple);
    canvas.drawLine(f(-0.07, 0.815), f(0.06, 0.815), ripple);
  }

  // ── lesson.06 ─────────────────────────────────────────────────────────

  void dayArc() {
    const horizon = 0.74;
    sky(horizon, warmth: 0.55);
    // Warm at the morning end, cooler toward the evening.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          f(-1, 0),
          f(1, 0),
          [
            c.glow.withValues(alpha: 0.3),
            c.glow.withValues(alpha: 0),
            c.nearest.withValues(alpha: 0),
            c.nearest.withValues(alpha: 0.5),
          ],
          const [0, 0.42, 0.58, 1],
        ),
    );
    final centre = f(0, horizon);
    final rx = 0.78 * h, ry = 0.54 * h;
    Offset at(double a) => centre + Offset(math.cos(a) * rx, math.sin(a) * ry);
    dashed(
      Path()..addArc(
        Rect.fromCenter(center: centre, width: 2 * rx, height: 2 * ry),
        math.pi,
        math.pi,
      ),
      stroke(c.haze.withValues(alpha: 0.35), px(0.006)),
      dash: h * 0.025,
      gap: h * 0.02,
    );
    // Short pauses during the day.
    for (final a in const [1.32, 1.41, 1.59, 1.68]) {
      canvas.drawCircle(
        at(a * math.pi),
        px(0.013, 1.5),
        fill(c.sunCore.withValues(alpha: 0.75)),
      );
    }
    // Morning.
    sunDisc(at(math.pi + 0.3), h * 0.055);
    // Midday.
    final noon = at(1.5 * math.pi);
    final r = h * 0.042;
    for (var k = 0; k < 8; k++) {
      final a = k * math.pi / 4;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        noon + dir * (r * 1.5),
        noon + dir * (r * 2.1),
        stroke(c.sunCore.withValues(alpha: 0.6), px(0.007)),
      );
    }
    canvas.drawCircle(noon, r, fill(c.sunCore));
    // Evening.
    final evening = at(2 * math.pi - 0.3);
    halo(evening, h * 0.14, 0.3);
    crescent(evening, h * 0.045);
    canvas.drawPath(
      GlyphArt.star(f(0.58, 0.42), h * 0.028),
      fill(c.sunCore.withValues(alpha: 0.8)),
    );
    ridge([
      (-0.05, 0.75),
      (0.2, 0.71),
      (0.45, 0.745),
      (0.7, 0.705),
      (1.05, 0.745),
    ], c.far);
    ridge([(-0.05, 0.87), (0.35, 0.81), (0.65, 0.87), (1.05, 0.81)], c.near);
    ridge([(-0.05, 0.96), (0.5, 0.92), (1.05, 0.97)], c.nearest);
  }

  // ── lesson.07 ─────────────────────────────────────────────────────────

  void route() {
    sky(0.62, warmth: 0.8);
    sunDisc(f(-0.56, 0.3), h * 0.05);
    ridge([
      (-0.05, 0.6),
      (0.2, 0.5),
      (0.4, 0.58),
      (0.6, 0.48),
      (0.8, 0.56),
      (1.05, 0.5),
    ], c.far);
    // The mountain: a lit face toward the sun and a shaded one.
    canvas.drawPath(
      poly(const [
        (-0.7, 0.92),
        (-0.26, 0.54),
        (-0.12, 0.6),
        (0.24, 0.18),
        (0.17, 0.46),
        (0.24, 0.92),
      ]),
      fill(c.mid),
    );
    canvas.drawPath(
      poly(const [
        (0.24, 0.18),
        (0.42, 0.4),
        (0.53, 0.36),
        (0.96, 0.92),
        (0.24, 0.92),
        (0.17, 0.46),
      ]),
      fill(c.near),
    );
    canvas.drawPath(
      Path()..addPolygon([
        f(-0.7, 0.92),
        f(-0.26, 0.54),
        f(-0.12, 0.6),
        f(0.24, 0.18),
      ], false),
      stroke(c.sun.withValues(alpha: 0.4), px(0.005))
        ..strokeCap = StrokeCap.butt,
    );
    ridge([
      (-0.05, 0.88),
      (0.25, 0.83),
      (0.55, 0.9),
      (0.8, 0.84),
      (1.05, 0.88),
    ], c.nearest);
    // The route, marked, with waypoints.
    const points = [
      (-0.78, 1.02),
      (-0.44, 0.87),
      (-0.18, 0.79),
      (-0.04, 0.68),
      (0.02, 0.52),
      (0.12, 0.36),
      (0.235, 0.2),
    ];
    dashed(
      through(points),
      stroke(c.sunCore.withValues(alpha: 0.85), px(0.011, 1.2))
        ..strokeCap = StrokeCap.butt,
      dash: h * 0.03,
      gap: h * 0.022,
    );
    for (final (x, y) in [points[2], points[4]]) {
      final p = f(x, y);
      final d = h * 0.026;
      canvas.drawPath(
        Path()..addPolygon([
          p + Offset(0, -d),
          p + Offset(d, 0),
          p + Offset(0, d),
          p + Offset(-d, 0),
        ], true),
        fill(c.sun),
      );
    }
    // The flag on the summit.
    canvas.drawLine(
      f(0.24, 0.19),
      f(0.24, 0.05),
      stroke(c.sunCore, px(0.008))..strokeCap = StrokeCap.butt,
    );
    canvas.drawPath(
      poly(const [(0.24, 0.05), (0.35, 0.085), (0.24, 0.12)]),
      fill(c.sun),
    );
  }
}
