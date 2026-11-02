import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../domain/campaign.dart' show Waypoint;
import '../../theme/cartha_theme.dart';
import '../scenes.dart';

/// Paints the landscape of one stop on Hannibal's route ([Waypoint]) in the
/// brand scenes' style: hero-family colours only ([ScenePalette]), calm
/// layered ridges, one clear subject per stop.
///
/// * **Carthage** — the round harbour at dawn: the arched ship sheds, the
///   island tower, a ship under sail and the Byrsa hill.
/// * **New Carthage** — white houses stepping up a hill above a sheltered
///   bay, a temple on top, small boats in the morning light.
/// * **The Ebro** — a wide river winding through the plain, poplars on its
///   banks, reeds in front.
/// * **The Pyrenees** — a high pass between snowy peaks at dusk, pines and a
///   trail up to the notch.
/// * **The Rhône** — an elephant crossing the misty river on a raft.
/// * **The Alps** — a path climbing to the snow under the moon, a lantern on
///   the way.
/// * **Italy** — cypresses, a stone pine and fields below the morning sun.
///
/// The subject is composed around the centre at the box's height (focal
/// units: x box-heights from the centre); sky, land and water extend to the
/// sides, so a stop reads on a small thumbnail and a wide tablet card alike.
/// Narrower boxes than [minAspect] are cropped at the sides. [progress] (0 → 1) lifts
/// the light once (sun, moon, glow); [veiled] adds a light mist, for stops
/// still ahead.
class RouteScenePainter extends CustomPainter {
  RouteScenePainter({
    required this.waypoint,
    required this.palette,
    Animation<double>? progress,
    this.veiled = false,
  }) : progress = progress ?? const AlwaysStoppedAnimation(1),
       super(repaint: progress);

  final Waypoint waypoint;
  final CarthaPalette palette;
  final Animation<double> progress;

  /// A soft mist over the scene (a stop still ahead).
  final bool veiled;

  /// Narrower boxes are drawn at this width / height and cropped at the
  /// sides, so the subject never squeezes.
  static const double minAspect = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || !size.isFinite) return;
    final t = Curves.easeOutCubic.transform(progress.value.clamp(0.0, 1.0));
    final width = math.max(size.width, size.height * minAspect);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate((size.width - width) / 2, 0);
    final frame = Size(width, size.height);
    final s = _RouteSketch(canvas, frame, ScenePalette.of(palette), t);
    switch (waypoint) {
      case Waypoint.carthage:
        s.carthage();
      case Waypoint.newCarthage:
        s.newCarthage();
      case Waypoint.ebro:
        s.ebro();
      case Waypoint.pyrenees:
        s.pyrenees();
      case Waypoint.rhone:
        s.rhone();
      case Waypoint.alps:
        s.alps();
      case Waypoint.italy:
        s.italy();
    }
    if (veiled) {
      canvas.drawRect(
        Offset.zero & frame,
        Paint()
          ..shader = ui.Gradient.linear(Offset.zero, Offset(0, frame.height), [
            palette.hero.withValues(alpha: 0.5),
            palette.hero.withValues(alpha: 0.62),
          ]),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(RouteScenePainter old) =>
      old.waypoint != waypoint ||
      old.veiled != veiled ||
      old.progress != progress ||
      old.palette.hero != palette.hero ||
      old.palette.heroRaised != palette.heroRaised ||
      old.palette.heroAccent != palette.heroAccent ||
      old.palette.onHero != palette.onHero ||
      old.palette.onHeroMuted != palette.onHeroMuted;
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Scene helpers in focal units: `f(x, y)` is x box-heights from the centre
/// and y box-heights from the top. The seven route stops.
class _RouteSketch extends SceneSketch {
  _RouteSketch(super.canvas, super.size, super.c, super.t);

  Offset f(double x, double y) => Offset(w / 2 + x * h, y * h);

  Path poly(List<(double, double)> points) =>
      Path()..addPolygon([for (final (x, y) in points) f(x, y)], true);

  Path line(List<(double, double)> points) =>
      Path()..addPolygon([for (final (x, y) in points) f(x, y)], false);

  Rect box(double l, double t, double r, double b) =>
      Rect.fromPoints(f(l, t), f(r, b));

  double px(double fraction, [double min = 1]) => math.max(min, h * fraction);

  /// [from] → [to] as the light lifts.
  double rise(double from, double to) => _lerp(from, to, t);

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
          [Color.lerp(c.sea, c.glow, light * _lerp(0.6, 1, t))!, c.near],
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
    final strength = _lerp(0.45, 1, t);
    for (var i = 0; i < count; i++) {
      final half = h * (width - i * width / (count + 1)) * strength;
      final y = (top + 0.03 + i * 0.04) * h;
      final cx = f(x, 0).dx;
      canvas.drawLine(
        Offset(cx - half, y),
        Offset(cx + half, y),
        stroke(
          c.sunCore.withValues(alpha: (0.5 - i * 0.07) * strength),
          px(0.007),
        ),
      );
    }
  }

  /// Small stars at normalised (x of the width, y of the height, radius of
  /// the height) positions, fading in as the light settles.
  void stars(List<(double, double, double)> stars, {double alpha = 0.6}) {
    final a = alpha * _lerp(0.35, 1, t);
    for (final (x, y, r) in stars) {
      canvas.drawCircle(
        Offset(x * w, y * h),
        math.max(0.8, h * r),
        fill(c.sunCore.withValues(alpha: a)),
      );
    }
  }

  void crescent(Offset centre, double r) {
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: centre, radius: r)),
        Path()..addOval(
          Rect.fromCircle(
            center: centre + Offset(r * 0.45, -r * 0.22),
            radius: r * 0.86,
          ),
        ),
      ),
      fill(c.sunCore),
    );
  }

  /// Wide, soft bands of mist at the given heights.
  void mist(List<(double, double)> bands, {double alpha = 0.12}) {
    for (final (y, thickness) in bands) {
      final top = (y - thickness / 2) * h, bottom = (y + thickness / 2) * h;
      canvas.drawRect(
        Rect.fromLTRB(0, top, w, bottom),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, top),
            Offset(0, bottom),
            [
              c.haze.withValues(alpha: 0),
              c.haze.withValues(alpha: alpha),
              c.haze.withValues(alpha: 0),
            ],
            const [0, 0.5, 1],
          ),
      );
    }
  }

  /// A cypress: a tall flame from [top] down to [bottom] at [x].
  void cypress(double x, double top, double bottom, double half, Paint paint) {
    final mid = (top + bottom) / 2;
    canvas.drawPath(
      Path()
        ..moveTo(f(x, top).dx, f(x, top).dy)
        ..quadraticBezierTo(
          f(x + half * 1.15, mid).dx,
          f(x, mid).dy,
          f(x + half * 0.5, bottom).dx,
          f(x, bottom).dy,
        )
        ..lineTo(f(x - half * 0.5, bottom).dx, f(x, bottom).dy)
        ..quadraticBezierTo(
          f(x - half * 1.15, mid).dx,
          f(x, mid).dy,
          f(x, top).dx,
          f(x, top).dy,
        )
        ..close(),
      paint,
    );
  }

  /// A pine: three stacked tiers on a short trunk, [height] tall.
  void pine(double x, double bottom, double height, Paint paint) {
    final half = height * 0.32;
    for (var k = 0; k < 3; k++) {
      final tierTop = bottom - height + k * height * 0.24;
      final tierBottom = tierTop + height * 0.46;
      final spread = half * (0.55 + k * 0.24);
      canvas.drawPath(
        poly([
          (x, tierTop),
          (x + spread, tierBottom),
          (x - spread, tierBottom),
        ]),
        paint,
      );
    }
    canvas.drawRect(
      box(
        x - height * 0.035,
        bottom - height * 0.1,
        x + height * 0.035,
        bottom,
      ),
      paint,
    );
  }

  /// A small sailing boat on the water at [x], [y] (the waterline), [s]
  /// box-heights long, its sail lit.
  void boat(double x, double y, double s) {
    canvas.drawPath(
      poly([
        (x - s * 0.5, y - s * 0.12),
        (x + s * 0.5, y - s * 0.12),
        (x + s * 0.36, y),
        (x - s * 0.36, y),
      ]),
      fill(c.nearest),
    );
    canvas.drawLine(
      f(x, y - s * 0.12),
      f(x, y - s * 0.95),
      stroke(c.nearest, px(0.006)),
    );
    canvas.drawPath(
      poly([
        (x + s * 0.04, y - s * 0.9),
        (x + s * 0.04, y - s * 0.2),
        (x + s * 0.42, y - s * 0.2),
      ]),
      fill(c.sunCore.withValues(alpha: 0.9)),
    );
    canvas.drawPath(
      poly([
        (x - s * 0.04, y - s * 0.78),
        (x - s * 0.04, y - s * 0.2),
        (x - s * 0.32, y - s * 0.2),
      ]),
      fill(c.haze.withValues(alpha: 0.55)),
    );
  }

  /// A dark foreground bank across the bottom, where the route runs.
  void foreground(double y, {double wave = 0.03}) {
    ridge([
      (-0.05, y + wave),
      (0.3, y),
      (0.62, y + wave * 1.2),
      (0.9, y + wave * 0.2),
      (1.05, y + wave),
    ], c.nearest);
  }

  /// A clump of reeds standing on [base] at [x], about [height] tall: thin
  /// blades and two cattails, rim-lit.
  void reeds(double x, double base, double height) {
    final blade = stroke(c.nearest, px(0.006));
    final head = fill(c.nearest);
    final rim = stroke(c.sun.withValues(alpha: 0.45), px(0.0035));
    for (final (dx, lean, k, cattail) in const [
      (-0.035, -0.05, 0.62, false),
      (-0.015, -0.02, 1.0, true),
      (0.0, 0.025, 0.7, false),
      (0.014, 0.012, 0.86, true),
      (0.03, 0.06, 0.55, false),
    ]) {
      final bottom = f(x + dx, base);
      final top = f(x + dx + lean * height, base - height * k);
      final bend = f(x + dx, base - height * k * 0.6);
      canvas.drawPath(
        Path()
          ..moveTo(bottom.dx, bottom.dy)
          ..quadraticBezierTo(bend.dx, bend.dy, top.dx, top.dy),
        blade,
      );
      if (cattail) {
        final rect = Rect.fromCenter(
          center: Offset.lerp(bend, top, 0.72)!,
          width: math.max(2, h * 0.018),
          height: h * height * 0.26,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.width / 2)),
          head,
        );
        canvas.drawLine(rect.topRight, rect.bottomRight, rim);
      }
    }
  }

  // ── Carthage ─────────────────────────────────────────────────────────────

  void carthage() {
    const horizon = 0.56;
    sky(horizon);
    // The sun comes up out of the sea, behind the harbour's right side.
    sunDisc(f(0.66, rise(0.62, 0.47)), h * 0.065);
    ridge([(0.72, 0.575), (0.84, 0.535), (0.96, 0.55), (1.05, 0.565)], c.far);
    water(horizon, 1, light: 0.42);
    glints(0.66, horizon, width: 0.075);

    // The Byrsa hill on the left, its shore running down into the sea.
    final hill = fill(c.near);
    canvas.drawPath(
      Path()
        ..moveTo(f(-4, 1).dx, h)
        ..lineTo(f(-4, 0.5).dx, f(0, 0.5).dy)
        ..cubicTo(
          f(-1.2, 0.46).dx,
          f(0, 0.4).dy,
          f(-0.98, 0.34).dx,
          f(0, 0.345).dy,
          f(-0.8, 0.345).dx,
          f(0, 0.345).dy,
        )
        ..lineTo(f(-0.6, 0.345).dx, f(0, 0.345).dy)
        ..cubicTo(
          f(-0.48, 0.36).dx,
          f(0, 0.46).dy,
          f(-0.34, 0.58).dx,
          f(0, 0.63).dy,
          f(-0.24, 0.66).dx,
          f(0, 0.66).dy,
        )
        ..quadraticBezierTo(f(-0.3, 0.84).dx, f(0, 0.84).dy, f(-0.74, 1).dx, h)
        ..close(),
      hill,
    );
    final rim = stroke(c.sun.withValues(alpha: 0.45), px(0.0045));
    final dark = fill(c.nearest);
    final lamp = fill(c.sun.withValues(alpha: 0.65 * _lerp(0.5, 1, t)));
    // The temple: steps, four columns, a pediment.
    canvas.drawRect(box(-0.82, 0.325, -0.58, 0.345), dark);
    for (final x in const [-0.79, -0.735, -0.665, -0.61]) {
      canvas.drawRect(box(x - 0.011, 0.255, x + 0.011, 0.326), dark);
    }
    canvas.drawRect(box(-0.81, 0.24, -0.59, 0.257), dark);
    canvas.drawPath(
      poly(const [(-0.82, 0.242), (-0.7, 0.19), (-0.58, 0.242)]),
      dark,
    );
    canvas.drawPath(
      line(const [(-0.82, 0.242), (-0.7, 0.19), (-0.58, 0.242)]),
      rim,
    );
    // Flat-roofed houses clustered down the slope toward the harbour, lit
    // along their sunward edges, a few lamps on.
    for (final (i, (x, y, half, tall)) in const [
      (-0.56, 0.42, 0.05, 0.06),
      (-0.47, 0.44, 0.04, 0.045),
      (-0.62, 0.5, 0.045, 0.05),
      (-0.52, 0.51, 0.05, 0.065),
      (-0.42, 0.5, 0.04, 0.05),
      (-0.58, 0.58, 0.04, 0.045),
      (-0.48, 0.585, 0.05, 0.05),
      (-0.37, 0.565, 0.045, 0.045),
    ].indexed) {
      canvas.drawRect(box(x - half, y - tall, x + half, y), dark);
      canvas.drawLine(f(x - half, y - tall), f(x + half, y - tall), rim);
      canvas.drawLine(f(x + half, y - tall), f(x + half, y), rim);
      if (i % 3 != 1) {
        canvas.drawRect(
          box(x - half * 0.35, y - tall * 0.62, x, y - tall * 0.3),
          lamp,
        );
      }
    }

    // The round harbour: the far ring of arched ship sheds, the island's
    // round admiralty, the near quay.
    const top = 0.58, base = 0.655;
    const left = -0.26, right = 0.6;
    canvas.drawRect(box(left, top, right, base), fill(c.near));
    canvas.drawLine(f(left, top), f(right, top), rim);
    const arches = 13;
    const step = (right - left) / arches;
    for (var i = 0; i < arches; i++) {
      final cx = left + step * (i + 0.5);
      final half = step * 0.3;
      final open = f(cx - half, base);
      final r = half * h;
      canvas.drawPath(
        Path()
          ..moveTo(open.dx, open.dy)
          ..lineTo(open.dx, f(0, top + 0.028).dy)
          ..arcToPoint(
            Offset(f(cx + half, 0).dx, f(0, top + 0.028).dy),
            radius: Radius.circular(r),
          )
          ..lineTo(f(cx + half, base).dx, open.dy)
          ..close(),
        fill(Color.lerp(c.sea, c.glow, _lerp(0.35, 0.6, t))!),
      );
    }
    // The island: a round hall ringed with columns, under a low dome.
    canvas.drawRect(box(-0.1, 0.6, 0.26, base + 0.01), dark);
    canvas.drawRect(box(-0.04, 0.5, 0.2, 0.6), dark);
    canvas.drawPath(
      Path()
        ..moveTo(f(-0.05, 0.502).dx, f(0, 0.502).dy)
        ..arcToPoint(
          f(0.21, 0.502),
          radius: Radius.elliptical(0.13 * h, 0.075 * h),
        )
        ..close(),
      dark,
    );
    canvas.drawRect(box(0.07, 0.41, 0.09, 0.432), dark);
    canvas.drawRect(box(-0.06, 0.49, 0.22, 0.505), dark);
    final column = stroke(
      c.sun.withValues(alpha: _lerp(0.25, 0.45, t)),
      px(0.004),
    );
    for (final x in const [-0.01, 0.035, 0.08, 0.125, 0.17]) {
      canvas.drawLine(f(x, 0.515), f(x, 0.595), column);
    }
    canvas.drawLine(f(0.2, 0.505), f(0.2, 0.6), rim);
    canvas.drawLine(f(-0.06, 0.49), f(0.22, 0.49), rim);
    // The near quay, with the harbour mouth open on the right.
    canvas.drawRect(box(left - 0.04, base, 0.36, base + 0.04), dark);
    canvas.drawRect(box(0.5, base, right + 0.06, base + 0.04), dark);
    canvas.drawLine(f(left - 0.04, base), f(0.36, base), rim);
    canvas.drawLine(f(0.5, base), f(right + 0.06, base), rim);

    // A ship under sail, coming home through the harbour mouth.
    const shipX = 0.43, shipY = 0.8;
    canvas.save();
    final anchor = f(shipX, shipY);
    canvas.translate(anchor.dx, anchor.dy);
    canvas.scale(0.72);
    canvas.translate(-anchor.dx, -anchor.dy);
    canvas.drawPath(
      Path()
        ..moveTo(f(shipX - 0.2, shipY - 0.06).dx, f(0, shipY - 0.06).dy)
        ..quadraticBezierTo(
          f(shipX - 0.16, shipY).dx,
          f(0, shipY).dy,
          f(shipX, shipY).dx,
          f(0, shipY).dy,
        )
        ..quadraticBezierTo(
          f(shipX + 0.16, shipY).dx,
          f(0, shipY).dy,
          f(shipX + 0.22, shipY - 0.075).dx,
          f(0, shipY - 0.075).dy,
        )
        ..lineTo(f(shipX + 0.17, shipY - 0.04).dx, f(0, shipY - 0.04).dy)
        ..lineTo(f(shipX - 0.15, shipY - 0.04).dx, f(0, shipY - 0.04).dy)
        ..close(),
      dark,
    );
    canvas.drawLine(
      f(shipX, shipY - 0.04),
      f(shipX, shipY - 0.25),
      stroke(c.nearest, px(0.01)),
    );
    canvas.drawLine(
      f(shipX - 0.1, shipY - 0.225),
      f(shipX + 0.1, shipY - 0.225),
      stroke(c.nearest, px(0.009)),
    );
    canvas.drawPath(
      Path()
        ..moveTo(f(shipX - 0.095, shipY - 0.22).dx, f(0, shipY - 0.22).dy)
        ..lineTo(f(shipX + 0.095, shipY - 0.22).dx, f(0, shipY - 0.22).dy)
        ..quadraticBezierTo(
          f(shipX + 0.125, shipY - 0.15).dx,
          f(0, shipY - 0.15).dy,
          f(shipX + 0.09, shipY - 0.075).dx,
          f(0, shipY - 0.075).dy,
        )
        ..lineTo(f(shipX - 0.09, shipY - 0.075).dx, f(0, shipY - 0.075).dy)
        ..quadraticBezierTo(
          f(shipX - 0.06, shipY - 0.15).dx,
          f(0, shipY - 0.15).dy,
          f(shipX - 0.095, shipY - 0.22).dx,
          f(0, shipY - 0.22).dy,
        )
        ..close(),
      fill(c.sunCore.withValues(alpha: 0.88)),
    );
    final ripple = stroke(c.haze.withValues(alpha: 0.25), px(0.008));
    canvas.drawLine(
      f(shipX - 0.2, shipY + 0.025),
      f(shipX + 0.16, shipY + 0.025),
      ripple,
    );
    canvas.drawLine(
      f(shipX - 0.1, shipY + 0.055),
      f(shipX + 0.06, shipY + 0.055),
      ripple,
    );
    canvas.restore();
    foreground(0.93, wave: 0.02);
  }

  // ── New Carthage ─────────────────────────────────────────────────────────

  void newCarthage() {
    const horizon = 0.6;
    sky(horizon, warmth: 0.75);
    final sun = f(-0.72, rise(0.4, 0.27));
    sunDisc(sun, h * 0.055);
    ridge([
      (-0.05, 0.56),
      (0.2, 0.5),
      (0.45, 0.55),
      (0.7, 0.49),
      (1.05, 0.54),
    ], c.far);
    hazeLines([(0.22, 0.57, 0.18), (0.78, 0.555, 0.14)]);
    water(horizon, 1, light: 0.36);
    glints(-0.72, horizon, width: 0.06);
    // The left headland, sloping into the bay.
    canvas.drawPath(
      Path()
        ..moveTo(f(-4, 1).dx, h)
        ..lineTo(f(-4, 0.56).dx, f(0, 0.56).dy)
        ..quadraticBezierTo(
          f(-1.1, 0.5).dx,
          f(0, 0.5).dy,
          f(-0.55, 0.68).dx,
          f(0, 0.68).dy,
        )
        ..quadraticBezierTo(f(-0.6, 0.84).dx, f(0, 0.84).dy, f(-0.95, 1).dx, h)
        ..close(),
      fill(c.mid),
    );
    // The town's hill on the right.
    final hillTop = f(0.36, 0.33);
    canvas.drawPath(
      Path()
        ..moveTo(f(0.32, 1).dx, h)
        ..quadraticBezierTo(
          f(-0.22, 0.86).dx,
          f(0, 0.86).dy,
          f(-0.2, 0.7).dx,
          f(0, 0.7).dy,
        )
        ..cubicTo(
          f(0.0, 0.52).dx,
          f(0, 0.4).dy,
          f(0.18, 0.34).dx,
          f(0, 0.34).dy,
          hillTop.dx,
          hillTop.dy,
        )
        ..cubicTo(
          f(0.6, 0.33).dx,
          f(0, 0.4).dy,
          f(0.9, 0.5).dx,
          f(0, 0.5).dy,
          f(4, 0.56).dx,
          f(0, 0.56).dy,
        )
        ..lineTo(f(4, 1).dx, h)
        ..close(),
      fill(c.near),
    );
    // The town wall along the hill's foot.
    final dark = fill(c.nearest);
    final rim = stroke(c.sun.withValues(alpha: 0.45), px(0.0045));
    canvas.drawRect(box(-0.16, 0.64, 4, 0.69), dark);
    final edge = w / 2 / h + 0.1; // the frame's right edge, in focal units
    for (var x = -0.13; x < edge; x += 0.07) {
      canvas.drawRect(box(x - 0.015, 0.625, x + 0.015, 0.641), dark);
    }
    canvas.drawLine(f(-0.16, 0.641), f(4, 0.641), rim);
    // White houses stepping up the hill, lit from the sun on the left.
    final wall = fill(Color.lerp(c.mid, c.sunCore, _lerp(0.4, 0.55, t))!);
    final side = fill(Color.lerp(c.near, c.mid, 0.6)!);
    final window = fill(c.nearest);
    final roof = stroke(c.sunCore.withValues(alpha: 0.5), px(0.004));
    for (final (i, (x, y, s)) in const [
      (0.3, 0.37, 0.045),
      (0.44, 0.38, 0.04),
      (0.2, 0.43, 0.045),
      (0.36, 0.45, 0.05),
      (0.52, 0.44, 0.045),
      (0.66, 0.47, 0.04),
      (0.1, 0.5, 0.045),
      (0.27, 0.52, 0.05),
      (0.45, 0.53, 0.045),
      (0.6, 0.54, 0.05),
      (0.78, 0.55, 0.045),
      (0.02, 0.58, 0.04),
      (0.16, 0.59, 0.05),
      (0.35, 0.6, 0.045),
      (0.52, 0.61, 0.05),
      (0.7, 0.61, 0.045),
      (0.88, 0.6, 0.04),
      (1.0, 0.57, 0.045),
      (1.12, 0.6, 0.04),
    ].indexed) {
      // Heights vary a little, so the town doesn't read as a grid.
      final tall = s * const [1.1, 0.85, 1.3][i % 3];
      canvas.drawRect(box(x - s, y - tall, x + s * 0.45, y), wall);
      canvas.drawRect(box(x + s * 0.45, y - tall, x + s, y), side);
      canvas.drawLine(f(x - s, y - tall), f(x + s * 0.45, y - tall), roof);
      if (i % 3 == 0) {
        canvas.drawRect(
          box(x - s * 0.5, y - tall * 0.66, x - s * 0.3, y - tall * 0.3),
          window,
        );
      } else if (i % 3 == 2) {
        canvas.drawRect(
          box(x - s * 0.2, y - tall * 0.45, x + s * 0.05, y),
          window,
        );
      }
    }
    // The temple on the summit.
    final temple = fill(Color.lerp(c.mid, c.sunCore, _lerp(0.45, 0.6, t))!);
    canvas.drawRect(box(0.25, 0.31, 0.47, 0.33), temple);
    for (final x in const [0.27, 0.32, 0.4, 0.45]) {
      canvas.drawRect(box(x - 0.009, 0.25, x + 0.009, 0.31), temple);
    }
    canvas.drawRect(box(0.255, 0.236, 0.465, 0.252), temple);
    canvas.drawPath(
      poly(const [(0.25, 0.238), (0.36, 0.19), (0.47, 0.238)]),
      temple,
    );
    canvas.drawPath(
      line(const [(0.47, 0.238), (0.47, 0.33)]),
      stroke(c.near, px(0.004)),
    );
    // Boats at anchor in the bay.
    boat(-0.28, 0.76, 0.12);
    boat(-0.06, 0.69, 0.08);
    final ripple = stroke(c.haze.withValues(alpha: 0.22), px(0.005));
    canvas.drawLine(f(-0.36, 0.78), f(-0.2, 0.78), ripple);
    foreground(0.92, wave: 0.025);
  }

  // ── The Ebro ─────────────────────────────────────────────────────────────

  void ebro() {
    const horizon = 0.52;
    sky(horizon, warmth: 0.7);
    sunDisc(f(0.5, rise(0.32, 0.2)), h * 0.05);
    ridge([
      (-0.05, 0.47),
      (0.12, 0.42),
      (0.26, 0.46),
      (0.42, 0.4),
      (0.6, 0.45),
      (0.78, 0.41),
      (1.05, 0.46),
    ], c.far);
    hazeLines([(0.3, 0.49, 0.2), (0.72, 0.485, 0.16)]);
    ridge([
      (-0.05, 0.53),
      (0.25, 0.51),
      (0.5, 0.535),
      (0.75, 0.505),
      (1.05, 0.53),
    ], c.mid);
    // The plain.
    canvas.drawRect(
      Rect.fromLTRB(0, 0.54 * h, w, h),
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, 0.54 * h), Offset(0, h), [
          Color.lerp(c.mid, c.near, 0.3)!,
          c.near,
        ]),
    );
    // Furrows and field edges, faint.
    final furrow = stroke(c.haze.withValues(alpha: 0.07), px(0.004));
    for (final (y, from, to) in const [
      (0.6, -1.6, -0.5),
      (0.66, -1.6, -0.6),
      (0.58, 0.5, 1.6),
      (0.64, 0.7, 1.6),
      (0.72, 0.9, 1.6),
    ]) {
      canvas.drawLine(f(from, y), f(to, y), furrow);
    }

    // The river: a broad meander from the near bank to the horizon, wide in
    // front, foreshortened as it turns, thin in the distance.
    final centre = through(const [
      (-1.4, 1.06),
      (-0.5, 0.9),
      (0.42, 0.79),
      (0.5, 0.71),
      (0.0, 0.64),
      (-0.34, 0.6),
      (-0.1, 0.565),
      (0.2, 0.545),
    ]);
    final left = <Offset>[], right = <Offset>[];
    for (final metric in centre.computeMetrics()) {
      const n = 90;
      for (var i = 0; i <= n; i++) {
        final tan = metric.getTangentForOffset(metric.length * i / n)!;
        final depth = ((tan.position.dy / h - horizon) / (1.06 - horizon))
            .clamp(0.0, 1.0);
        final half = h * (0.006 + 0.17 * math.pow(depth, 1.25));
        final normal = Offset(-tan.vector.dy, tan.vector.dx);
        // Foreshortened: much thinner up and down than across.
        final off = Offset(normal.dx * half * 1.6, normal.dy * half * 0.5);
        left.add(tan.position + off);
        right.add(tan.position - off);
      }
    }
    final river = Path()..addPolygon([...left, ...right.reversed], true);
    // The sky's light on the water, brightest in the distance.
    canvas.drawPath(
      river,
      Paint()
        ..shader = ui.Gradient.linear(Offset(0, horizon * h), Offset(0, h), [
          Color.lerp(c.glow, c.haze, _lerp(0.05, 0.2, t))!,
          Color.lerp(c.sea, c.skyMid, 0.55)!,
        ]),
    );
    final bank = stroke(c.nearest.withValues(alpha: 0.55), px(0.006));
    canvas
      ..drawPath(Path()..addPolygon(left, false), bank)
      ..drawPath(Path()..addPolygon(right, false), bank);
    // Ripples across the current, a few at each bend.
    final ripple = stroke(c.haze.withValues(alpha: 0.32), px(0.0045));
    final glint = stroke(c.sunCore.withValues(alpha: 0.5 * t), px(0.0045));
    for (final metric in centre.computeMetrics()) {
      for (var i = 1; i < 14; i++) {
        final tan = metric.getTangentForOffset(metric.length * i / 15)!;
        final depth = ((tan.position.dy / h - horizon) / (1.06 - horizon))
            .clamp(0.0, 1.0);
        final len = h * (0.012 + 0.07 * depth);
        final shift = h * 0.05 * depth * (i.isEven ? 1 : -1);
        final at = tan.position + Offset(shift, 0);
        canvas.drawLine(
          at - Offset(len / 2, 0),
          at + Offset(len / 2, 0),
          i % 3 == 0 ? glint : ripple,
        );
      }
    }

    // Poplars along the banks.
    final tree = fill(c.nearest);
    final rim = stroke(c.sun.withValues(alpha: 0.35), px(0.004));
    for (final (x, base, height) in const [
      (-0.82, 0.83, 0.3),
      (-0.68, 0.8, 0.25),
      (-0.98, 0.86, 0.33),
      (0.72, 0.75, 0.24),
      (0.84, 0.77, 0.27),
      (0.96, 0.79, 0.3),
      (-0.5, 0.6, 0.09),
      (-0.44, 0.595, 0.08),
      (0.36, 0.565, 0.06),
    ]) {
      final half = height * 0.17;
      cypress(x, base - height, base, half, tree);
      canvas.drawPath(
        Path()
          ..moveTo(f(x, base - height).dx, f(0, base - height).dy)
          ..quadraticBezierTo(
            f(x + half * 1.15, 0).dx,
            f(0, base - height / 2).dy,
            f(x + half * 0.5, 0).dx,
            f(0, base).dy,
          ),
        rim,
      );
    }
    foreground(0.95, wave: 0.02);
    // Reeds in front.
    reeds(0.66, 0.97, 0.24);
    reeds(-1.18, 0.97, 0.22);
  }

  // ── The Pyrenees ─────────────────────────────────────────────────────────

  void pyrenees() {
    const horizon = 0.6;
    sky(horizon, warmth: 0.95);
    stars(const [
      (0.08, 0.08, 0.004),
      (0.18, 0.2, 0.003),
      (0.3, 0.06, 0.004),
      (0.7, 0.07, 0.004),
      (0.82, 0.18, 0.003),
      (0.93, 0.09, 0.004),
    ], alpha: 0.5);
    // The low sun sits in the pass.
    sunDisc(f(0.02, rise(0.56, 0.46)), h * 0.06);
    // Far range with snow on top.
    ridge([
      (-0.05, 0.45),
      (0.1, 0.36),
      (0.2, 0.42),
      (0.3, 0.33),
      (0.4, 0.44),
      (0.6, 0.42),
      (0.72, 0.31),
      (0.84, 0.4),
      (0.95, 0.34),
      (1.05, 0.42),
    ], c.far);
    // The two peaks either side of the pass: a lit face and a shaded one.
    final lit = fill(Color.lerp(c.mid, c.far, 0.35)!);
    final shade = fill(c.near);
    final snowLit = fill(c.sunCore.withValues(alpha: 0.72));
    final snowShade = fill(c.haze.withValues(alpha: 0.32));
    // Left peak (lit from the sun in the pass on its right face).
    canvas.drawPath(
      poly(const [
        (-1.6, 0.8),
        (-0.42, 0.17),
        (-0.3, 0.3),
        (-0.12, 0.42),
        (0.02, 0.5),
        (0.02, 0.8),
      ]),
      shade,
    );
    canvas.drawPath(
      poly(const [
        (-0.42, 0.17),
        (-0.3, 0.3),
        (-0.12, 0.42),
        (0.02, 0.5),
        (0.02, 0.8),
        (-0.35, 0.8),
        (-0.36, 0.45),
      ]),
      lit,
    );
    canvas.drawPath(
      poly(const [
        (-0.42, 0.17),
        (-0.52, 0.25),
        (-0.48, 0.27),
        (-0.44, 0.24),
        (-0.4, 0.28),
      ]),
      snowShade,
    );
    canvas.drawPath(
      poly(const [
        (-0.42, 0.17),
        (-0.4, 0.28),
        (-0.36, 0.25),
        (-0.33, 0.31),
        (-0.3, 0.3),
      ]),
      snowLit,
    );
    // Right peak (lit on its left face, toward the pass).
    canvas.drawPath(
      poly(const [
        (0.02, 0.5),
        (0.2, 0.37),
        (0.36, 0.29),
        (0.52, 0.15),
        (1.7, 0.8),
        (0.02, 0.8),
      ]),
      shade,
    );
    canvas.drawPath(
      poly(const [
        (0.02, 0.5),
        (0.2, 0.37),
        (0.36, 0.29),
        (0.52, 0.15),
        (0.48, 0.45),
        (0.4, 0.8),
        (0.02, 0.8),
      ]),
      lit,
    );
    canvas.drawPath(
      poly(const [
        (0.52, 0.15),
        (0.43, 0.23),
        (0.46, 0.255),
        (0.49, 0.235),
        (0.5, 0.27),
      ]),
      snowLit,
    );
    canvas.drawPath(
      poly(const [
        (0.52, 0.15),
        (0.5, 0.27),
        (0.55, 0.24),
        (0.6, 0.27),
        (0.63, 0.22),
      ]),
      snowShade,
    );
    final rim = stroke(c.sun.withValues(alpha: 0.5), px(0.0045));
    canvas.drawPath(
      line(const [(-0.42, 0.17), (-0.3, 0.3), (-0.12, 0.42), (0.02, 0.5)]),
      rim,
    );
    canvas.drawPath(
      line(const [(0.02, 0.5), (0.2, 0.37), (0.36, 0.29), (0.52, 0.15)]),
      rim,
    );
    // The valley floor below the pass.
    ridge([
      (-0.05, 0.8),
      (0.3, 0.77),
      (0.5, 0.765),
      (0.7, 0.77),
      (1.05, 0.8),
    ], c.near);
    mist([(0.6, 0.08)], alpha: 0.07);
    // The trail, up to the notch.
    dashed(
      through(const [
        (-0.18, 0.98),
        (0.12, 0.86),
        (-0.06, 0.76),
        (0.1, 0.66),
        (-0.02, 0.58),
        (0.02, 0.51),
      ]),
      stroke(c.sunCore.withValues(alpha: 0.7), px(0.008, 1.2))
        ..strokeCap = StrokeCap.butt,
      dash: h * 0.025,
      gap: h * 0.02,
    );
    // Pines in front, on both sides.
    final pines = fill(c.nearest);
    canvas.drawPath(
      Path()
        ..moveTo(0, h)
        ..lineTo(0, 0.84 * h)
        ..lineTo(f(-0.3, 0.86).dx, 0.86 * h)
        ..quadraticBezierTo(f(-0.22, 0.92).dx, 0.92 * h, f(-0.2, 1).dx, h)
        ..close(),
      pines,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, h)
        ..lineTo(w, 0.82 * h)
        ..lineTo(f(0.32, 0.85).dx, 0.85 * h)
        ..quadraticBezierTo(f(0.26, 0.92).dx, 0.92 * h, f(0.24, 1).dx, h)
        ..close(),
      pines,
    );
    for (final (x, base, height) in const [
      (-0.36, 0.88, 0.24),
      (-0.48, 0.86, 0.3),
      (-0.6, 0.87, 0.22),
      (-0.72, 0.85, 0.32),
      (-0.86, 0.86, 0.26),
      (-1.0, 0.85, 0.3),
      (-1.16, 0.86, 0.25),
      (-1.3, 0.85, 0.3),
      (0.38, 0.87, 0.26),
      (0.5, 0.85, 0.32),
      (0.63, 0.86, 0.24),
      (0.76, 0.84, 0.3),
      (0.9, 0.85, 0.27),
      (1.04, 0.84, 0.31),
      (1.2, 0.85, 0.26),
      (1.34, 0.84, 0.3),
    ]) {
      pine(x, base, height, pines);
    }
    foreground(0.94, wave: 0.02);
  }

  // ── The Rhône ────────────────────────────────────────────────────────────

  void rhone() {
    const horizon = 0.5;
    sky(horizon, warmth: 0.85);
    sunDisc(f(0.72, rise(0.48, 0.36)), h * 0.06);
    // The far bank: a wood of round trees, some taller, in the haze.
    // One opaque colour, so the crowns are simply painted over each other.
    final wood = fill(Color.lerp(c.far, c.mid, 0.35)!);
    canvas.drawRect(Rect.fromLTRB(0, 0.44 * h, w, 0.53 * h), wood);
    final count = (w / (h * 0.09)).ceil() + 2;
    for (var i = 0; i < count; i++) {
      final x = -h * 0.04 + i * h * 0.09;
      final r = h * (0.045 + 0.03 * math.sin(i * 2.3).abs());
      final y = h * (0.47 - 0.05 * math.sin(i * 1.3).abs());
      canvas.drawCircle(Offset(x, y), r, wood);
    }
    mist([(0.47, 0.1)], alpha: 0.12);
    water(horizon + 0.01, 0.9, light: 0.46);
    glints(0.72, horizon + 0.01, width: 0.07);
    // The current, running across.
    final current = stroke(c.haze.withValues(alpha: 0.2), px(0.005));
    for (final (x, y, len) in const [
      (-0.9, 0.6, 0.22),
      (-0.45, 0.66, 0.18),
      (0.45, 0.62, 0.16),
      (0.95, 0.68, 0.24),
      (-1.1, 0.78, 0.26),
      (0.62, 0.83, 0.22),
      (-0.6, 0.86, 0.2),
    ]) {
      dashed(
        Path()
          ..moveTo(f(x - len / 2, y).dx, f(0, y).dy)
          ..quadraticBezierTo(
            f(x, y - 0.012).dx,
            f(0, y - 0.012).dy,
            f(x + len / 2, y).dx,
            f(0, y).dy,
          ),
        current,
        dash: h * 0.04,
        gap: h * 0.02,
      );
    }

    // The raft, midstream, with the elephant standing on it.
    final dark = fill(c.nearest);
    final rim = stroke(c.sun.withValues(alpha: 0.55), px(0.0045));
    final deck = Color.lerp(c.near, c.sun, 0.22)!;
    canvas.drawPath(
      poly(const [(-0.26, 0.735), (0.28, 0.735), (0.33, 0.775), (-0.3, 0.775)]),
      fill(deck),
    );
    canvas.drawRect(box(-0.3, 0.775, 0.33, 0.795), dark);
    final log = stroke(c.nearest.withValues(alpha: 0.6), px(0.003));
    for (var x = -0.24; x < 0.3; x += 0.06) {
      canvas.drawLine(f(x, 0.738), f(x * 1.08, 0.774), log);
    }
    canvas.drawLine(f(-0.3, 0.775), f(0.33, 0.775), rim);
    // A steering oar at the stern.
    canvas.drawLine(
      f(-0.24, 0.745),
      f(-0.42, 0.8),
      stroke(c.nearest, px(0.007)),
    );
    _elephant(0.0, 0.738, 0.2);
    // Ripples around the raft.
    final ripple = stroke(c.haze.withValues(alpha: 0.28), px(0.005));
    canvas.drawLine(f(-0.4, 0.81), f(-0.12, 0.81), ripple);
    canvas.drawLine(f(0.1, 0.815), f(0.42, 0.815), ripple);
    canvas.drawLine(f(-0.22, 0.835), f(0.24, 0.835), ripple);
    // The near bank, with reeds.
    foreground(0.91, wave: 0.02);
    reeds(-0.84, 0.95, 0.2);
    reeds(0.9, 0.94, 0.18);
  }

  /// An elephant standing on [floor] (y), facing right, centred at [x],
  /// [s] box-heights tall: a calm silhouette with rim light and a small tusk.
  void _elephant(double x, double floor, double s) {
    final dark = fill(c.nearest);
    double ex(double v) => x + v * s;
    double ey(double v) => floor - v * s;
    // Legs.
    for (final lx in const [-0.42, -0.24, 0.12, 0.3]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          box(ex(lx - 0.075), ey(0.52), ex(lx + 0.075), ey(0)),
          Radius.circular(s * h * 0.03),
        ),
        dark,
      );
    }
    // Body.
    final body = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          box(ex(-0.55), ey(0.92), ex(0.42), ey(0.36)),
          Radius.circular(s * h * 0.26),
        ),
      );
    // Head and trunk.
    final head = Path()
      ..addOval(
        Rect.fromCircle(center: f(ex(0.5), ey(0.78)), radius: s * h * 0.2),
      );
    final trunk = Path()
      ..moveTo(f(ex(0.6), ey(0.8)).dx, f(0, ey(0.8)).dy)
      ..cubicTo(
        f(ex(0.78), ey(0.66)).dx,
        f(0, ey(0.66)).dy,
        f(ex(0.74), ey(0.3)).dx,
        f(0, ey(0.3)).dy,
        f(ex(0.8), ey(0.12)).dx,
        f(0, ey(0.12)).dy,
      )
      ..lineTo(f(ex(0.69), ey(0.12)).dx, f(0, ey(0.12)).dy)
      ..cubicTo(
        f(ex(0.62), ey(0.3)).dx,
        f(0, ey(0.3)).dy,
        f(ex(0.64), ey(0.56)).dx,
        f(0, ey(0.56)).dy,
        f(ex(0.46), ey(0.62)).dx,
        f(0, ey(0.62)).dy,
      )
      ..close();
    final silhouette = Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.union, body, head),
      trunk,
    );
    canvas.drawPath(silhouette, dark);
    // Tail.
    canvas.drawLine(
      f(ex(-0.54), ey(0.78)),
      f(ex(-0.62), ey(0.48)),
      stroke(c.nearest, px(0.005)),
    );
    // Rim light along the back and head, from the sun on the right.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, f(0, ey(0.7)).dy));
    canvas.drawPath(
      silhouette,
      stroke(c.sun.withValues(alpha: 0.6), px(0.0045)),
    );
    canvas.restore();
    // The ear, a shade lighter.
    canvas.drawOval(
      Rect.fromCenter(
        center: f(ex(0.36), ey(0.72)),
        width: s * h * 0.26,
        height: s * h * 0.36,
      ),
      fill(Color.lerp(c.nearest, c.near, 0.7)!),
    );
    // The tusk.
    canvas.drawPath(
      Path()
        ..moveTo(f(ex(0.6), ey(0.58)).dx, f(0, ey(0.58)).dy)
        ..quadraticBezierTo(
          f(ex(0.7), ey(0.46)).dx,
          f(0, ey(0.46)).dy,
          f(ex(0.86), ey(0.5)).dx,
          f(0, ey(0.5)).dy,
        ),
      stroke(c.sunCore, px(0.006, 1.2)),
    );
    // The eye.
    canvas.drawCircle(
      f(ex(0.54), ey(0.84)),
      math.max(0.7, s * h * 0.022),
      fill(c.sunCore.withValues(alpha: 0.8)),
    );
  }

  // ── The Alps ─────────────────────────────────────────────────────────────

  void alps() {
    const horizon = 0.66;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, horizon * h),
          [
            c.nearest,
            c.skyTop,
            Color.lerp(c.skyMid, c.glow, _lerp(0.1, 0.28, t))!,
          ],
          const [0, 0.5, 1],
        ),
    );
    stars(const [
      (0.04, 0.12, 0.004),
      (0.1, 0.32, 0.003),
      (0.16, 0.06, 0.005),
      (0.24, 0.22, 0.003),
      (0.33, 0.1, 0.004),
      (0.4, 0.3, 0.003),
      (0.5, 0.05, 0.004),
      (0.58, 0.14, 0.003),
      (0.66, 0.06, 0.005),
      (0.74, 0.24, 0.003),
      (0.8, 0.1, 0.004),
      (0.88, 0.3, 0.003),
      (0.95, 0.07, 0.004),
    ]);
    final moon = f(-0.68, rise(0.32, 0.22));
    halo(moon, h * 0.22, _lerp(0.25, 0.45, t));
    crescent(moon, h * 0.055);
    // Far peaks.
    ridge([
      (-0.05, 0.56),
      (0.08, 0.44),
      (0.18, 0.52),
      (0.3, 0.4),
      (0.44, 0.5),
      (0.62, 0.46),
      (0.76, 0.36),
      (0.88, 0.47),
      (1.05, 0.42),
    ], Color.lerp(c.far, c.near, 0.5)!);
    // More peaks along the range, for wide frames.
    final range = fill(Color.lerp(c.far, c.near, 0.3)!);
    final tips = fill(c.haze.withValues(alpha: 0.35));
    for (final (x, top, half) in const [
      (-1.0, 0.3, 0.32),
      (-1.55, 0.36, 0.3),
      (-2.1, 0.3, 0.34),
      (0.98, 0.33, 0.3),
      (1.5, 0.28, 0.34),
      (2.05, 0.35, 0.3),
    ]) {
      canvas.drawPath(
        poly([(x - half, 0.72), (x, top), (x + half, 0.72)]),
        range,
      );
      canvas.drawPath(
        poly([
          (x - half * 0.2, top + 0.065),
          (x, top),
          (x + half * 0.2, top + 0.065),
          (x + half * 0.06, top + 0.05),
          (x - half * 0.06, top + 0.07),
        ]),
        tips,
      );
    }
    // The great peak, lit by the moon on its left face.
    final shade = fill(c.near);
    final lit = fill(Color.lerp(c.mid, c.haze, 0.18)!);
    canvas.drawPath(
      poly(const [
        (-1.7, 0.86),
        (-0.5, 0.42),
        (-0.3, 0.36),
        (0.14, 0.08),
        (0.36, 0.3),
        (0.5, 0.26),
        (1.8, 0.86),
      ]),
      shade,
    );
    canvas.drawPath(
      poly(const [
        (-1.7, 0.86),
        (-0.5, 0.42),
        (-0.3, 0.36),
        (0.14, 0.08),
        (0.06, 0.4),
        (0.18, 0.86),
      ]),
      lit,
    );
    final snow = fill(c.sunCore.withValues(alpha: _lerp(0.6, 0.85, t)));
    final snowShade = fill(c.haze.withValues(alpha: 0.3));
    canvas.drawPath(
      poly(const [
        (0.14, 0.08),
        (-0.04, 0.2),
        (0.0, 0.215),
        (0.03, 0.19),
        (0.05, 0.25),
        (0.09, 0.22),
        (0.1, 0.3),
      ]),
      snow,
    );
    canvas.drawPath(
      poly(const [
        (0.14, 0.08),
        (0.1, 0.3),
        (0.16, 0.26),
        (0.21, 0.29),
        (0.26, 0.21),
      ]),
      snowShade,
    );
    canvas.drawPath(
      poly(const [
        (-0.3, 0.36),
        (-0.4, 0.4),
        (-0.36, 0.415),
        (-0.32, 0.4),
        (-0.27, 0.42),
      ]),
      snow,
    );
    canvas.drawPath(
      poly(const [
        (0.5, 0.26),
        (0.44, 0.31),
        (0.48, 0.33),
        (0.52, 0.31),
        (0.58, 0.32),
      ]),
      snowShade,
    );
    canvas.drawPath(
      line(const [(-0.5, 0.42), (-0.3, 0.36), (0.14, 0.08)]),
      stroke(c.sunCore.withValues(alpha: 0.4), px(0.0045)),
    );
    // The switchback path, climbing to a lantern on the way.
    final path = through(const [
      (-0.62, 0.98),
      (-0.2, 0.86),
      (-0.5, 0.78),
      (-0.16, 0.7),
      (-0.36, 0.63),
      (-0.14, 0.57),
    ]);
    dashed(
      path,
      stroke(c.sunCore.withValues(alpha: 0.75), px(0.008, 1.2))
        ..strokeCap = StrokeCap.butt,
      dash: h * 0.024,
      gap: h * 0.018,
    );
    final lantern = f(-0.14, 0.565);
    halo(lantern, h * 0.08, _lerp(0.4, 0.8, t));
    canvas.drawCircle(lantern, px(0.011, 1.5), fill(c.sunCore));
    // Dark rock in front, with snow lying on it.
    ridge([
      (-0.05, 0.92),
      (0.2, 0.86),
      (0.42, 0.9),
      (0.64, 0.85),
      (0.86, 0.89),
      (1.05, 0.86),
    ], c.nearest);
    final drift = stroke(c.haze.withValues(alpha: 0.18), px(0.006));
    canvas.drawLine(f(0.44, 0.9), f(0.6, 0.875), drift);
    canvas.drawLine(f(-0.95, 0.93), f(-0.78, 0.91), drift);
  }

  // ── Italy ────────────────────────────────────────────────────────────────

  void italy() {
    const horizon = 0.56;
    sky(horizon, warmth: 1);
    final sun = f(0.2, rise(0.6, 0.44));
    final r = h * 0.07;
    final rays = stroke(c.sun.withValues(alpha: 0.45 * t), px(0.008, 1.2));
    for (var i = 1; i <= 7; i++) {
      final a = math.pi + i * math.pi / 8;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(sun + dir * (r * 1.55), sun + dir * (r * 2.3), rays);
    }
    sunDisc(sun, r);
    ridge([
      (-0.05, 0.54),
      (0.2, 0.52),
      (0.4, 0.545),
      (0.62, 0.515),
      (0.85, 0.54),
      (1.05, 0.525),
    ], c.far);
    // The plain: fields in bands, furrows leading toward the sun.
    final plain = Rect.fromLTRB(0, (horizon - 0.01) * h, w, h);
    canvas.save();
    canvas.clipRect(plain);
    canvas.drawRect(plain, fill(c.mid));
    final light = fill(Color.lerp(c.mid, c.glow, _lerp(0.12, 0.24, t))!);
    for (final (top, bottom) in const [
      (0.57, 0.6),
      (0.63, 0.67),
      (0.71, 0.76),
    ]) {
      canvas.drawRect(Rect.fromLTRB(0, top * h, w, bottom * h), light);
    }
    final furrow = stroke(c.near.withValues(alpha: 0.35), px(0.003));
    for (var k = -9; k <= 9; k++) {
      canvas.drawLine(sun, f(0.2 + k * 0.26, 1.2), furrow);
    }
    canvas.restore();
    // A small hill town far off, a bell tower over the roofs.
    final town = fill(Color.lerp(c.far, c.near, 0.55)!);
    canvas.drawRect(box(0.56, 0.535, 0.82, 0.57), town);
    canvas.drawRect(box(0.62, 0.48, 0.645, 0.54), town);
    canvas.drawPath(
      poly(const [(0.615, 0.482), (0.6325, 0.46), (0.65, 0.482)]),
      town,
    );
    for (final (x, y) in const [(0.68, 0.525), (0.74, 0.52), (0.79, 0.53)]) {
      canvas.drawRect(box(x - 0.025, y, x + 0.025, 0.54), town);
    }
    // The near hill on the left, the road coming down it into the plain.
    canvas.drawPath(
      Path()
        ..moveTo(f(-4, 1).dx, h)
        ..lineTo(f(-4, 0.6).dx, f(0, 0.6).dy)
        ..cubicTo(
          f(-1.0, 0.56).dx,
          f(0, 0.56).dy,
          f(-0.5, 0.64).dx,
          f(0, 0.64).dy,
          f(-0.1, 0.8).dx,
          f(0, 0.8).dy,
        )
        ..quadraticBezierTo(f(0.1, 0.9).dx, f(0, 0.9).dy, f(0.18, 1).dx, h)
        ..close(),
      fill(c.near),
    );
    final road = through(const [
      (-1.0, 0.62),
      (-0.6, 0.68),
      (-0.36, 0.76),
      (-0.06, 0.82),
      (0.3, 0.88),
      (0.8, 0.98),
    ]);
    canvas.drawPath(
      road,
      stroke(Color.lerp(c.near, c.sun, 0.42)!, px(0.016, 1.5))
        ..strokeCap = StrokeCap.butt,
    );
    canvas.drawPath(
      road,
      stroke(c.sun.withValues(alpha: 0.5), px(0.004))
        ..strokeCap = StrokeCap.butt,
    );
    // Cypresses along the road.
    final dark = fill(c.nearest);
    final rim = stroke(c.sun.withValues(alpha: 0.45), px(0.0045));
    for (final (x, top, bottom) in const [
      (-0.8, 0.36, 0.64),
      (-0.68, 0.42, 0.66),
      (-0.56, 0.4, 0.69),
      (-0.44, 0.47, 0.73),
      (-1.0, 0.38, 0.62),
    ]) {
      final half = (bottom - top) * 0.13;
      cypress(x, top, bottom, half, dark);
      canvas.drawPath(
        Path()
          ..moveTo(f(x, top).dx, f(0, top).dy)
          ..quadraticBezierTo(
            f(x + half * 1.15, 0).dx,
            f(0, (top + bottom) / 2).dy,
            f(x + half * 0.5, 0).dx,
            f(0, bottom).dy,
          ),
        rim,
      );
    }
    // Stone pines on the right: short forked trunks under wide, dense
    // crowns, rim-lit on top.
    void stonePine(double x, double base, double s) {
      final fork = f(x - 0.02 * s, base - 0.4 * s);
      final root = f(x, base);
      final bend = f(x + 0.05 * s, base - 0.22 * s);
      canvas.drawPath(
        Path()
          ..moveTo(root.dx, root.dy)
          ..quadraticBezierTo(bend.dx, bend.dy, fork.dx, fork.dy),
        stroke(c.nearest, px(0.02 * s, 1.5)),
      );
      final limb = stroke(c.nearest, px(0.012 * s, 1.2));
      canvas.drawLine(fork, f(x - 0.13 * s, base - 0.5 * s), limb);
      canvas.drawLine(fork, f(x + 0.1 * s, base - 0.52 * s), limb);
      var crown = Path();
      for (final (dx, dy, rx, ry) in const [
        (0.0, 0.56, 0.22, 0.06),
        (-0.16, 0.53, 0.11, 0.05),
        (0.17, 0.54, 0.12, 0.05),
        (-0.07, 0.61, 0.12, 0.05),
        (0.08, 0.62, 0.12, 0.045),
      ]) {
        crown = Path.combine(
          PathOperation.union,
          crown,
          Path()..addOval(
            Rect.fromCenter(
              center: f(x + dx * s, base - dy * s),
              width: 2 * rx * s * h,
              height: 2 * ry * s * h,
            ),
          ),
        );
      }
      canvas.drawPath(crown, dark);
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, 0, w, f(0, base - 0.58 * s).dy));
      canvas.drawPath(crown, rim);
      canvas.restore();
    }

    stonePine(1.05, 0.8, 0.62);
    stonePine(0.66, 0.92, 1);
    foreground(0.94, wave: 0.02);
  }
}
