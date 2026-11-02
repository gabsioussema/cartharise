import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';

/// The vector brand scenes of the board's onboarding carousel and home hero
/// (PLAN.md §8): no photos, no weapons or combat, colours from palette
/// tokens only (hero surface family, so they read in light and dark).
///
/// Each scene rises gently once when first shown (sun/star/road/steps come
/// up over ~1.6 s) and is painted static when the device asks for reduced
/// motion or Settings › Motion is off.
enum SceneKind {
  /// Sun rising over layered hills — "Understand yourself".
  sunrise,

  /// Winding road toward a low sun — "Reset your life".
  path,

  /// Compass star over a hilltop signpost — "Choose a direction".
  compass,

  /// Stone steps ascending toward light — "Improve step by step".
  steps,

  /// Carthaginian arch and colonnade at dawn over the sea — Today hero.
  dawnRuins,
}

/// Default proportions of a scene (width / height).
const double kSceneAspectRatio = 4 / 3;

/// Proportions of the compact scene (Today's next action): shorter, same art.
const double kCompactSceneAspectRatio = 3;

/// The frame a compact scene is composed in: the art is laid out at this
/// width / height and its band of interest is shown (see [BrandScene.compact]).
const double kSceneFrameAspectRatio = 2;

/// One brand scene. Prefer the named wrappers ([SunriseScene], [PathScene],
/// [CompassScene], [StepsScene], [DawnRuinsScene]).
///
/// With an [aspectRatio] the scene sizes itself from the available width;
/// with `null` it fills its parent (give it bounded constraints). Scenes are
/// decorative unless a [semanticLabel] is given.
class BrandScene extends StatefulWidget {
  const BrandScene({
    super.key,
    required this.kind,
    this.aspectRatio = kSceneAspectRatio,
    this.semanticLabel,
    this.animate = true,
    this.compact = false,
  });

  /// The shorter variant (Today's next action): the same art composed at
  /// [kSceneFrameAspectRatio] and cropped to its band of interest, so the sun,
  /// the ruins or the stair stay in view at [kCompactSceneAspectRatio]. With
  /// another [aspectRatio] (or `null` to fill the parent) the same framing
  /// applies to that box.
  const BrandScene.compact({
    super.key,
    required this.kind,
    this.aspectRatio = kCompactSceneAspectRatio,
    this.semanticLabel,
    this.animate = true,
  }) : compact = true;

  final SceneKind kind;
  final double? aspectRatio;
  final String? semanticLabel;

  /// False paints the finished scene straight away (e.g. thumbnails).
  final bool animate;

  /// Frames the art for a short, wide box (see [BrandScene.compact]).
  final bool compact;

  /// How long the one-shot rise takes.
  static const riseDuration = Duration(milliseconds: 1600);

  @override
  State<BrandScene> createState() => _BrandSceneState();
}

class _BrandSceneState extends State<BrandScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BrandScene.riseDuration,
  );
  bool _started = false;

  bool _motionAllowed(BuildContext context) {
    final device = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final setting = context.select<AppState?, bool>(
      (s) => s?.settings.motion ?? true,
    );
    return widget.animate && !device && setting;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = _motionAllowed(context);
    if (!_started) {
      _started = true;
      if (allowed) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1;
      }
    } else if (!allowed && _controller.value < 1) {
      // Motion switched off mid-rise: show the finished scene at once.
      _controller.value = 1;
    }
    final paint = RepaintBoundary(
      child: CustomPaint(
        painter: ScenePainter(
          kind: widget.kind,
          palette: CarthaPalette.of(context),
          progress: _controller,
          compact: widget.compact,
        ),
        child: const SizedBox.expand(),
      ),
    );
    final sized = widget.aspectRatio == null
        ? paint
        : AspectRatio(aspectRatio: widget.aspectRatio!, child: paint);
    final label = widget.semanticLabel;
    if (label == null) return ExcludeSemantics(child: sized);
    return Semantics(image: true, label: label, child: sized);
  }
}

/// Test hook: how far a [BrandScene] has risen (0–1).
@visibleForTesting
double brandSceneProgress(State state) =>
    (state as _BrandSceneState)._controller.value;

/// Test hook: whether a [BrandScene] is still animating.
@visibleForTesting
bool isBrandSceneAnimating(State state) =>
    (state as _BrandSceneState)._controller.isAnimating;

/// Sun rising over layered hills ("Understand yourself").
class SunriseScene extends StatelessWidget {
  const SunriseScene({
    super.key,
    this.aspectRatio = kSceneAspectRatio,
    this.semanticLabel,
    this.animate = true,
    this.compact = false,
  });

  /// Ignored when [compact] (see [BrandScene.compact]).
  final double? aspectRatio;
  final String? semanticLabel;
  final bool animate;

  /// The shorter variant, at [kCompactSceneAspectRatio].
  final bool compact;

  @override
  Widget build(BuildContext context) => compact
      ? BrandScene.compact(
          kind: SceneKind.sunrise,
          semanticLabel: semanticLabel,
          animate: animate,
        )
      : BrandScene(
          kind: SceneKind.sunrise,
          aspectRatio: aspectRatio,
          semanticLabel: semanticLabel,
          animate: animate,
        );
}

/// A winding road toward a low sun ("Reset your life").
class PathScene extends StatelessWidget {
  const PathScene({
    super.key,
    this.aspectRatio = kSceneAspectRatio,
    this.semanticLabel,
    this.animate = true,
    this.compact = false,
  });

  /// Ignored when [compact] (see [BrandScene.compact]).
  final double? aspectRatio;
  final String? semanticLabel;
  final bool animate;

  /// The shorter variant, at [kCompactSceneAspectRatio].
  final bool compact;

  @override
  Widget build(BuildContext context) => compact
      ? BrandScene.compact(
          kind: SceneKind.path,
          semanticLabel: semanticLabel,
          animate: animate,
        )
      : BrandScene(
          kind: SceneKind.path,
          aspectRatio: aspectRatio,
          semanticLabel: semanticLabel,
          animate: animate,
        );
}

/// A compass star over a hilltop signpost ("Choose a direction").
class CompassScene extends StatelessWidget {
  const CompassScene({
    super.key,
    this.aspectRatio = kSceneAspectRatio,
    this.semanticLabel,
    this.animate = true,
    this.compact = false,
  });

  /// Ignored when [compact] (see [BrandScene.compact]).
  final double? aspectRatio;
  final String? semanticLabel;
  final bool animate;

  /// The shorter variant, at [kCompactSceneAspectRatio].
  final bool compact;

  @override
  Widget build(BuildContext context) => compact
      ? BrandScene.compact(
          kind: SceneKind.compass,
          semanticLabel: semanticLabel,
          animate: animate,
        )
      : BrandScene(
          kind: SceneKind.compass,
          aspectRatio: aspectRatio,
          semanticLabel: semanticLabel,
          animate: animate,
        );
}

/// Stone steps ascending toward light ("Improve step by step").
class StepsScene extends StatelessWidget {
  const StepsScene({
    super.key,
    this.aspectRatio = kSceneAspectRatio,
    this.semanticLabel,
    this.animate = true,
    this.compact = false,
  });

  /// Ignored when [compact] (see [BrandScene.compact]).
  final double? aspectRatio;
  final String? semanticLabel;
  final bool animate;

  /// The shorter variant, at [kCompactSceneAspectRatio].
  final bool compact;

  @override
  Widget build(BuildContext context) => compact
      ? BrandScene.compact(
          kind: SceneKind.steps,
          semanticLabel: semanticLabel,
          animate: animate,
        )
      : BrandScene(
          kind: SceneKind.steps,
          aspectRatio: aspectRatio,
          semanticLabel: semanticLabel,
          animate: animate,
        );
}

/// A Carthaginian arch and colonnade silhouette at dawn, with the sea line
/// (Today's hero).
class DawnRuinsScene extends StatelessWidget {
  const DawnRuinsScene({
    super.key,
    this.aspectRatio = kSceneAspectRatio,
    this.semanticLabel,
    this.animate = true,
    this.compact = false,
  });

  /// Ignored when [compact] (see [BrandScene.compact]).
  final double? aspectRatio;
  final String? semanticLabel;
  final bool animate;

  /// The shorter variant, at [kCompactSceneAspectRatio].
  final bool compact;

  @override
  Widget build(BuildContext context) => compact
      ? BrandScene.compact(
          kind: SceneKind.dawnRuins,
          semanticLabel: semanticLabel,
          animate: animate,
        )
      : BrandScene(
          kind: SceneKind.dawnRuins,
          aspectRatio: aspectRatio,
          semanticLabel: semanticLabel,
          animate: animate,
        );
}

/// Gives [child] the dark variant of the current brand theme, for content
/// placed on a hero surface (scenes, onboarding, hero cards) in BOTH
/// brightnesses: bronze pill buttons, ivory text, light-bronze links — the
/// same trick the boot screen uses.
class OnHeroTheme extends StatelessWidget {
  const OnHeroTheme({super.key, required this.child});

  final Widget child;

  static final _themes = <(AppTheme, CarthaFonts), ThemeData>{};

  @override
  Widget build(BuildContext context) {
    final appTheme = context.select<AppState?, AppTheme>(
      (s) => s?.settings.theme ?? AppTheme.forest,
    );
    // The language's fonts too (Arabic on a hero card is still Arabic).
    final fonts = CarthaFonts.of(context);
    final data = _themes[(appTheme, fonts)] ??= CarthaTheme.build(
      appTheme,
      Brightness.dark,
      fonts: fonts,
    );
    return Theme(data: data, child: child);
  }
}

// ── Painting ────────────────────────────────────────────────────────────────

/// The colours of a scene, derived from palette tokens only (hero family:
/// the same in light and dark, like the board's photos).
@immutable
class ScenePalette {
  ScenePalette.of(CarthaPalette p)
    : skyTop = Color.lerp(p.hero, p.shadow, 0.45)!,
      skyMid = p.hero,
      glow = Color.lerp(p.hero, p.heroAccent, 0.62)!,
      sun = p.heroAccent,
      sunCore = Color.lerp(p.heroAccent, p.onHero, 0.6)!,
      far = Color.lerp(p.heroRaised, p.heroAccent, 0.26)!,
      mid = Color.lerp(p.hero, p.heroAccent, 0.1)!,
      near = Color.lerp(p.hero, p.shadow, 0.3)!,
      nearest = Color.lerp(p.hero, p.shadow, 0.55)!,
      sea = Color.lerp(p.heroRaised, p.heroAccent, 0.16)!,
      haze = p.onHeroMuted;

  final Color skyTop;
  final Color skyMid;
  final Color glow;
  final Color sun;
  final Color sunCore;
  final Color far;
  final Color mid;
  final Color near;
  final Color nearest;
  final Color sea;
  final Color haze;
}

/// Paints one [SceneKind] at the rise [progress] (0 → 1).
class ScenePainter extends CustomPainter {
  ScenePainter({
    required this.kind,
    required this.palette,
    required this.progress,
    this.compact = false,
  }) : super(repaint: progress);

  final SceneKind kind;
  final CarthaPalette palette;
  final Animation<double> progress;

  /// Compose at [kSceneFrameAspectRatio] and show the band of interest.
  final bool compact;

  /// Where a compact scene's visible band sits in the composed frame
  /// (0 keeps the top, 1 keeps the bottom).
  static double focusOf(SceneKind kind) => switch (kind) {
    SceneKind.sunrise => 0.5,
    SceneKind.path => 0.62,
    SceneKind.compass => 0.08,
    SceneKind.steps => 0.3,
    SceneKind.dawnRuins => 0.62,
  };

  /// The size the art is composed at for a box of [size].
  static Size frameFor(Size size, {required bool compact}) => compact
      ? Size(
          size.width,
          math.max(size.height, size.width / kSceneFrameAspectRatio),
        )
      : size;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = Curves.easeOutCubic.transform(progress.value.clamp(0.0, 1.0));
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    final frame = frameFor(size, compact: compact);
    if (frame.height > size.height) {
      canvas.translate(0, -(frame.height - size.height) * focusOf(kind));
    }
    final s = _Sketch(canvas, frame, ScenePalette.of(palette), t);
    switch (kind) {
      case SceneKind.sunrise:
        s.sunrise();
      case SceneKind.path:
        s.path();
      case SceneKind.compass:
        s.compass();
      case SceneKind.steps:
        s.steps();
      case SceneKind.dawnRuins:
        s.dawnRuins();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ScenePainter old) =>
      old.kind != kind ||
      old.compact != compact ||
      old.palette.hero != palette.hero ||
      old.palette.heroRaised != palette.heroRaised ||
      old.palette.heroAccent != palette.heroAccent ||
      old.palette.onHero != palette.onHero ||
      old.palette.onHeroMuted != palette.onHeroMuted;
}

double _lerp(double a, double b, double t) => a + (b - a) * t;

/// Drawing helpers for brand scenes in a normalised space (x, y in 0–1 of
/// the size), shared by [ScenePainter] and the lesson illustrations: soft
/// sky, sun, ridges and haze in [ScenePalette] colours only.
class SceneSketch {
  SceneSketch(this.canvas, this.size, this.c, this.t);

  final Canvas canvas;
  final Size size;
  final ScenePalette c;

  /// Eased rise progress, 0–1.
  final double t;

  double get w => size.width;
  double get h => size.height;
  double get unit => math.min(w, h);

  Offset o(double x, double y) => Offset(x * w, y * h);

  Paint fill(Color color) => Paint()
    ..color = color
    ..isAntiAlias = true;

  Paint stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  /// Vertical sky gradient down to [horizon], warmer toward it as the light
  /// rises.
  void sky(double horizon, {double warmth = 1}) {
    final low = Color.lerp(c.skyMid, c.glow, _lerp(0.35, 1, t) * warmth)!;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, h * horizon),
          [c.skyTop, c.skyMid, low],
          const [0, 0.5, 1],
        ),
    );
  }

  /// A soft round glow (sun halo, light source).
  void halo(Offset center, double radius, double strength) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [
            c.sun.withValues(alpha: 0.55 * strength),
            c.sun.withValues(alpha: 0.18 * strength),
            c.sun.withValues(alpha: 0),
          ],
          const [0, 0.35, 1],
        ),
    );
  }

  void sunDisc(Offset center, double r) {
    halo(center, r * 4.2, _lerp(0.45, 1, t));
    canvas.drawCircle(center, r, fill(c.sun));
    canvas.drawCircle(center, r * 0.62, fill(c.sunCore));
  }

  /// A smooth ridge through normalised [points], filled down to the bottom.
  void ridge(List<(double, double)> points, Color color) {
    final pts = [for (final (x, y) in points) o(x, y)];
    final path = Path()
      ..moveTo(pts.first.dx, h)
      ..lineTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length - 1; i++) {
      final mid = Offset.lerp(pts[i], pts[i + 1], 0.5)!;
      path.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
    }
    path
      ..lineTo(pts.last.dx, pts.last.dy)
      ..lineTo(pts.last.dx, h)
      ..close();
    canvas.drawPath(path, fill(color));
  }

  /// Thin horizontal haze strokes between ridges.
  void hazeLines(List<(double, double, double)> lines) {
    for (final (x, y, len) in lines) {
      canvas.drawLine(
        o(x - len / 2, y),
        o(x + len / 2, y),
        stroke(c.haze.withValues(alpha: 0.10), math.max(1, unit * 0.006)),
      );
    }
  }

  /// Draws [path] as dashes of [dash] with [gap] between them.
  void dashed(Path path, Paint paint, {required double dash, double? gap}) {
    final space = gap ?? dash;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + space) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + dash, metric.length)),
          paint,
        );
      }
    }
  }
}

/// The five brand scenes.
class _Sketch extends SceneSketch {
  _Sketch(super.canvas, super.size, super.c, super.t);

  // ── Scenes ──────────────────────────────────────────────────────────────

  void sunrise() {
    sky(0.72);
    final r = unit * 0.1;
    final sun = o(0.5, _lerp(0.82, 0.5, t));
    // Rays above the sun ("The Rise" icon).
    final rayPaint = stroke(
      c.sun.withValues(alpha: 0.5 * t),
      math.max(1.5, unit * 0.012),
    );
    for (var i = 1; i <= 7; i++) {
      final a = math.pi + i * math.pi / 8;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        sun + dir * (r * 1.55),
        sun + dir * (r * (1.6 + 0.75 * t)),
        rayPaint,
      );
    }
    sunDisc(sun, r);
    ridge([
      (-0.05, 0.62),
      (0.16, 0.55),
      (0.36, 0.61),
      (0.6, 0.53),
      (0.83, 0.6),
      (1.05, 0.55),
    ], c.far);
    hazeLines([(0.3, 0.66, 0.22), (0.72, 0.64, 0.18)]);
    ridge([
      (-0.05, 0.72),
      (0.22, 0.66),
      (0.5, 0.73),
      (0.76, 0.65),
      (1.05, 0.71),
    ], c.mid);
    ridge([
      (-0.05, 0.84),
      (0.3, 0.77),
      (0.62, 0.86),
      (0.9, 0.79),
      (1.05, 0.82),
    ], c.near);
    ridge([(-0.05, 0.95), (0.4, 0.9), (0.8, 0.97), (1.05, 0.92)], c.nearest);
  }

  Offset _bezier(List<Offset> p, double s) {
    final u = 1 - s;
    return p[0] * (u * u * u) +
        p[1] * (3 * u * u * s) +
        p[2] * (3 * u * s * s) +
        p[3] * (s * s * s);
  }

  void path() {
    sky(0.64);
    sunDisc(o(0.64, _lerp(0.7, 0.55, t)), unit * 0.075);
    ridge([
      (-0.05, 0.58),
      (0.2, 0.5),
      (0.42, 0.57),
      (0.64, 0.6),
      (0.86, 0.52),
      (1.05, 0.57),
    ], c.far);
    ridge([
      (-0.05, 0.66),
      (0.25, 0.6),
      (0.5, 0.645),
      (0.75, 0.61),
      (1.05, 0.65),
    ], c.mid);
    ridge([(-0.05, 0.7), (0.5, 0.665), (1.05, 0.7)], c.near);

    // The road: a ribbon along a gentle S-shaped cubic centre line that
    // always rises toward the horizon. Its cross-sections are horizontal (as
    // a road looks in perspective), as wide as the distance from the horizon
    // allows, so the edges can never cross. It starts below the frame and is
    // revealed from the foreground toward the horizon.
    const horizon = 0.665;
    final centre = [o(0.3, 1.08), o(0.6, 0.85), o(0.3, 0.72), o(0.62, 0.668)];
    final reveal = _lerp(0.2, 1, t);
    const n = 64;
    double width(Offset p) {
      final f = ((p.dy / h - horizon) / (1.08 - horizon)).clamp(0.0, 1.0);
      return w * (0.004 + 0.4 * math.pow(f, 1.3));
    }

    final left = <Offset>[], right = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final p = _bezier(centre, reveal * i / n);
      final half = Offset(width(p) / 2, 0);
      left.add(p - half);
      right.add(p + half);
    }
    final road = Path()..addPolygon([...left, ...right.reversed], true);
    canvas.drawPath(road, fill(Color.lerp(c.near, c.sun, 0.34)!));
    final edge = stroke(
      c.sun.withValues(alpha: 0.5),
      math.max(1, unit * 0.005),
    );
    canvas
      ..drawPath(Path()..addPolygon(left, false), edge)
      ..drawPath(Path()..addPolygon(right, false), edge);
    // Centre dashes, thinner with distance.
    for (var s = 0.02; s < reveal - 0.03; s += 0.07) {
      final a = _bezier(centre, s);
      final b = _bezier(centre, math.min(s + 0.03, reveal));
      canvas.drawLine(
        a,
        b,
        stroke(c.sunCore.withValues(alpha: 0.5), math.max(1, width(a) * 0.05)),
      );
    }
    // Foreground banks.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.8)
        ..quadraticBezierTo(w * 0.07, h * 0.88, w * 0.09, h)
        ..lineTo(0, h)
        ..close(),
      fill(c.nearest),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, h * 0.74)
        ..quadraticBezierTo(w * 0.86, h * 0.86, w * 0.84, h)
        ..lineTo(w, h)
        ..close(),
      fill(c.nearest),
    );
  }

  void compass() {
    sky(0.72, warmth: 0.8);
    final star = o(0.5, _lerp(0.36, 0.27, t));
    final len = unit * 0.17;
    halo(star, len * 2.6, _lerp(0.3, 0.9, t));
    // Compass ring with four ticks.
    final ringPaint = stroke(
      c.haze.withValues(alpha: 0.32 * t),
      math.max(1, unit * 0.005),
    );
    canvas.drawCircle(star, len * 1.22, ringPaint);
    for (var k = 0; k < 4; k++) {
      final a = k * math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        star + dir * (len * 1.12),
        star + dir * (len * 1.34),
        ringPaint,
      );
    }
    // Eight-point star, faceted (light / dark halves), turning into place.
    canvas.save();
    canvas.translate(star.dx, star.dy);
    canvas.rotate(_lerp(-0.5, 0, t));
    final scale = _lerp(0.55, 1, t);
    canvas.scale(scale);
    final light = fill(c.sunCore.withValues(alpha: _lerp(0.4, 1, t)));
    final dark = fill(c.sun.withValues(alpha: _lerp(0.4, 1, t)));
    for (var k = 0; k < 8; k++) {
      final a = -math.pi / 2 + k * math.pi / 4;
      final r = k.isEven ? len : len * 0.48;
      final tip = Offset(math.cos(a), math.sin(a)) * r;
      final inner = len * 0.13;
      final l = Offset(math.cos(a - math.pi / 8), math.sin(a - math.pi / 8));
      final rr = Offset(math.cos(a + math.pi / 8), math.sin(a + math.pi / 8));
      canvas.drawPath(
        Path()..addPolygon([Offset.zero, tip, l * inner], true),
        light,
      );
      canvas.drawPath(
        Path()..addPolygon([Offset.zero, tip, rr * inner], true),
        dark,
      );
    }
    canvas.restore();

    ridge([
      (-0.05, 0.74),
      (0.24, 0.68),
      (0.5, 0.73),
      (0.78, 0.66),
      (1.05, 0.72),
    ], c.far);
    hazeLines([(0.22, 0.76, 0.2), (0.8, 0.75, 0.16)]);
    // Hilltop.
    canvas.drawPath(
      Path()
        ..moveTo(-0.05 * w, h)
        ..lineTo(-0.05 * w, 0.92 * h)
        ..cubicTo(0.2 * w, 0.86 * h, 0.36 * w, 0.66 * h, 0.5 * w, 0.655 * h)
        ..cubicTo(0.64 * w, 0.66 * h, 0.8 * w, 0.86 * h, 1.05 * w, 0.9 * h)
        ..lineTo(1.05 * w, h)
        ..close(),
      fill(c.near),
    );
    // Signpost: post and two boards, rim-lit from the star above.
    final post = math.max(3.0, unit * 0.022);
    final postRect = Rect.fromLTRB(
      0.5 * w - post / 2,
      0.43 * h,
      0.5 * w + post / 2,
      0.67 * h,
    );
    canvas.drawRect(postRect, fill(c.nearest));
    final rim = stroke(c.sun.withValues(alpha: 0.6), math.max(1, unit * 0.005));
    void board(double y, double from, double to, double tilt) {
      final dir = to > from ? 1.0 : -1.0;
      final bh = 0.055 * h;
      final tipX = to + dir * 0.03;
      canvas.save();
      canvas.translate(0.5 * w, y * h);
      canvas.rotate(tilt);
      canvas.translate(-0.5 * w, -y * h);
      final pts = [
        o(from, y - 0.0275),
        o(to, y - 0.0275),
        o(tipX, y),
        o(to, y + 0.0275),
        o(from, y + 0.0275),
      ];
      canvas.drawPath(Path()..addPolygon(pts, true), fill(c.nearest));
      canvas.drawLine(pts[0], pts[1], rim);
      canvas.drawLine(pts[1], pts[2], rim);
      canvas.drawLine(
        Offset(pts[0].dx, pts[0].dy + bh * 0.5),
        Offset(pts[1].dx, pts[1].dy + bh * 0.5),
        stroke(c.haze.withValues(alpha: 0.12), math.max(1, unit * 0.004)),
      );
      canvas.restore();
    }

    board(0.47, 0.49, 0.71, -0.05);
    board(0.555, 0.51, 0.3, 0.06);
    canvas.drawLine(postRect.topLeft, postRect.topRight, rim);
  }

  void steps() {
    sky(0.5, warmth: 0.9);
    final light = o(0.5, 0.17);
    halo(light, unit * _lerp(0.45, 0.75, t), _lerp(0.5, 1, t));
    canvas.drawCircle(
      light,
      unit * 0.055,
      fill(c.sunCore.withValues(alpha: _lerp(0.3, 1, t))),
    );
    ridge([
      (-0.05, 0.42),
      (0.25, 0.37),
      (0.5, 0.41),
      (0.75, 0.36),
      (1.05, 0.41),
    ], c.far);
    // Cliffs framing the stair.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.38)
        ..cubicTo(w * 0.16, h * 0.42, w * 0.28, h * 0.6, w * 0.33, h)
        ..lineTo(0, h)
        ..close(),
      fill(c.mid),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, h * 0.36)
        ..cubicTo(w * 0.84, h * 0.42, w * 0.72, h * 0.6, w * 0.67, h)
        ..lineTo(w, h)
        ..close(),
      fill(c.mid),
    );
    // Stone steps, smaller toward the light, appearing bottom-up.
    const count = 8;
    var y = h * 1.0;
    double widthAt(int i) =>
        w * _lerp(0.72, 0.1, math.pow(i / count, 0.85).toDouble());
    for (var i = 0; i < count; i++) {
      final shrink = 1 - 0.72 * i / count;
      final riser = h * 0.075 * shrink;
      final tread = h * 0.045 * shrink;
      final shown = (t * (count + 2) - i).clamp(0.0, 1.0);
      if (shown <= 0) break;
      final wb = widthAt(i), wt = widthAt(i + 1);
      final cx = w / 2;
      final riserTop = y - riser;
      final treadTop = riserTop - tread;
      final f = i / count;
      canvas.drawPath(
        Path()..addPolygon([
          Offset(cx - wb / 2, y),
          Offset(cx + wb / 2, y),
          Offset(cx + wb / 2, riserTop),
          Offset(cx - wb / 2, riserTop),
        ], true),
        fill(Color.lerp(c.nearest, c.near, f)!.withValues(alpha: shown)),
      );
      canvas.drawPath(
        Path()..addPolygon([
          Offset(cx - wb / 2, riserTop),
          Offset(cx + wb / 2, riserTop),
          Offset(cx + wt / 2, treadTop),
          Offset(cx - wt / 2, treadTop),
        ], true),
        fill(
          Color.lerp(c.near, c.glow, 0.3 + 0.55 * f)!.withValues(alpha: shown),
        ),
      );
      canvas.drawLine(
        Offset(cx - wb / 2, riserTop),
        Offset(cx + wb / 2, riserTop),
        stroke(
          c.sun.withValues(alpha: 0.45 * shown),
          math.max(1, unit * 0.004),
        ),
      );
      y = treadTop;
    }
  }

  void dawnRuins() {
    const horizon = 0.6;
    sky(horizon);
    final r = unit * 0.075;
    final sun = o(0.28, _lerp(0.68, 0.52, t));
    sunDisc(sun, r);
    // Distant headland on the left.
    ridge([
      (-0.05, 0.56),
      (0.06, 0.53),
      (0.16, 0.565),
      (0.24, 0.6),
      (0.3, 0.62),
    ], c.far);
    // The sea, with the sun's reflection.
    canvas.drawRect(
      Rect.fromLTRB(0, horizon * h, w, 0.82 * h),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, horizon * h),
          Offset(0, 0.82 * h),
          [Color.lerp(c.sea, c.glow, 0.35 * t)!, c.near],
        ),
    );
    canvas.drawLine(
      o(0, horizon),
      o(1, horizon),
      stroke(c.sun.withValues(alpha: 0.35), math.max(1, unit * 0.004)),
    );
    for (var i = 0; i < 7; i++) {
      final y = horizon + 0.018 + i * 0.026;
      final half = r * (1.5 - i * 0.16) * _lerp(0.4, 1, t);
      if (half <= 0) continue;
      canvas.drawLine(
        Offset(sun.dx - half, y * h),
        Offset(sun.dx + half, y * h),
        stroke(
          c.sunCore.withValues(alpha: (0.55 - i * 0.07) * _lerp(0.4, 1, t)),
          math.max(1, unit * 0.007),
        ),
      );
    }
    // Foreground land, rising to a plateau under the ruins.
    ridge([
      (-0.05, 0.86),
      (0.28, 0.83),
      (0.46, 0.8),
      (0.58, 0.765),
      (1.05, 0.755),
    ], c.nearest);

    final ruin = fill(c.nearest);
    final rim = stroke(
      c.sun.withValues(alpha: 0.5),
      math.max(1, unit * 0.0045),
    );
    const base = 0.77;
    // Colonnade: whole and broken columns, one architrave.
    final colW = 0.03;
    final columns = [(0.55, 0.42), (0.63, 0.42), (0.71, 0.53), (0.79, 0.47)];
    for (final (i, (x, top)) in columns.indexed) {
      final shaft = Rect.fromLTRB(
        (x - colW / 2) * w,
        top * h,
        (x + colW / 2) * w,
        base * h,
      );
      canvas.drawRect(shaft, ruin);
      // Base.
      canvas.drawRect(
        Rect.fromLTRB(
          (x - 0.024) * w,
          (base - 0.014) * h,
          (x + 0.024) * w,
          base * h + 1,
        ),
        ruin,
      );
      if (i < 2) {
        // Capital.
        canvas.drawRect(
          Rect.fromLTRB(
            (x - 0.025) * w,
            (top - 0.016) * h,
            (x + 0.025) * w,
            top * h,
          ),
          ruin,
        );
      } else {
        // Broken top.
        canvas.drawPath(
          Path()..addPolygon([
            o(x - colW / 2, top),
            o(x - colW / 6, top - 0.025),
            o(x + colW / 8, top - 0.008),
            o(x + colW / 2, top - 0.03),
            o(x + colW / 2, top + 0.002),
          ], true),
          ruin,
        );
      }
      canvas.drawLine(shaft.topLeft, shaft.bottomLeft, rim);
    }
    // Architrave across the two whole columns.
    final beam = Rect.fromLTRB(0.525 * w, 0.375 * h, 0.66 * w, 0.405 * h);
    canvas.drawRect(beam, ruin);
    canvas.drawLine(beam.topLeft, beam.topRight, rim);
    canvas.drawLine(beam.topLeft, beam.bottomLeft, rim);

    // The arch (partly off the right edge).
    final arch = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromLTRB(0.845 * w, 0.3 * h, 1.06 * w, base * h + 1));
    final ox = 0.945 * w, rad = math.min(0.055 * w, 0.12 * h);
    final openTop = 0.5 * h;
    arch.addPath(
      Path()
        ..moveTo(ox - rad, base * h + 1)
        ..lineTo(ox - rad, openTop)
        ..arcToPoint(Offset(ox + rad, openTop), radius: Radius.circular(rad))
        ..lineTo(ox + rad, base * h + 1)
        ..close(),
      Offset.zero,
    );
    canvas.drawPath(arch, ruin);
    canvas.drawRect(
      Rect.fromLTRB(0.83 * w, 0.29 * h, 1.06 * w, 0.315 * h),
      ruin,
    );
    canvas.drawLine(o(0.845, 0.315), o(0.845, base), rim);
    canvas.drawLine(o(0.83, 0.29), o(1.0, 0.29), rim);
    canvas.drawPath(
      Path()
        ..moveTo(ox - rad, base * h)
        ..lineTo(ox - rad, openTop)
        ..arcToPoint(Offset(ox + rad, openTop), radius: Radius.circular(rad)),
      stroke(c.sun.withValues(alpha: 0.3), math.max(1, unit * 0.004)),
    );

    // Cypresses on the left.
    void cypress(double x, double top, double width) {
      final bottom = 0.86;
      canvas.drawPath(
        Path()
          ..moveTo(x * w, top * h)
          ..quadraticBezierTo(
            (x + width) * w,
            (top + bottom) / 2 * h,
            x * w,
            bottom * h,
          )
          ..quadraticBezierTo(
            (x - width) * w,
            (top + bottom) / 2 * h,
            x * w,
            top * h,
          )
          ..close(),
        ruin,
      );
    }

    cypress(0.1, 0.56, 0.028);
    cypress(0.155, 0.63, 0.022);
  }
}
