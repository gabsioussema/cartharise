import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import 'emblem.dart';

/// One moment of the loader animation (see [loaderFrameAt]).
@immutable
class LoaderFrame {
  const LoaderFrame({
    required this.draw,
    required this.opacity,
    required this.sparkScale,
    required this.sparkOpacity,
  });

  /// Progress of the stroke dash (0–1): `1 - stroke-dashoffset / 1500` in
  /// `loader_reference.svg`. Every line shows its first
  /// `kLoaderDashLength * draw` units (see [drawnLength]), so — as in the
  /// SVG — all lines draw at the same speed, the short trunk finishes first
  /// and the whole emblem is complete long before [draw] reaches 1.
  final double draw;

  /// How much of a path [pathLength] units long is visible in this frame:
  /// the SVG's `stroke-dasharray: 1500` dash, shifted by its offset.
  double drawnLength(double pathLength) =>
      math.min(pathLength, kLoaderDashLength * draw);

  /// Opacity of the emblem lines.
  final double opacity;
  final double sparkScale;
  final double sparkOpacity;

  /// The reduced-motion / static look: full emblem, full spark.
  static const still = LoaderFrame(
    draw: 1,
    opacity: 1,
    sparkScale: 1,
    sparkOpacity: 1,
  );
}

/// Duration of one loader cycle (as `assets/brand/loader_reference.svg`).
const Duration kLoaderCycle = Duration(milliseconds: 3400);

/// `stroke-dasharray` / hidden `stroke-dashoffset` of the reference SVG, in
/// emblem viewBox units (512). Longer than every emblem line (≈ 293 at most).
const double kLoaderDashLength = 1500;

/// The keyframes of `loader_reference.svg`, each segment eased with CSS
/// `ease-in-out` (= [Curves.easeInOut]), at cycle position [t] (0–1):
///
/// * lines: dash offset 1500 (hidden) at 0–10 %, 0 at 65 % (opacity .3→1),
///   held to 85 %, back to 1500 at 100 % (opacity 1→.3). Because the dash
///   (1500) is far longer than the lines, every line is fully drawn by about
///   27 % of the cycle (the trunk by about 18 %) and only retracts in the
///   last few percent — exactly like the SVG;
/// * spark: scale .92 / opacity .25 at 0–45 %, grows to 1.13 / 1 by 70 %,
///   held to 85 %, back by 100 %.
LoaderFrame loaderFrameAt(double t) {
  final x = t - t.floorToDouble();
  double ease(double from, double to) =>
      Curves.easeInOut.transform(((x - from) / (to - from)).clamp(0.0, 1.0));

  final double draw;
  if (x < 0.10) {
    draw = 0;
  } else if (x < 0.65) {
    draw = ease(0.10, 0.65);
  } else if (x < 0.85) {
    draw = 1;
  } else {
    draw = 1 - ease(0.85, 1.0);
  }

  final double spark;
  if (x < 0.45) {
    spark = 0;
  } else if (x < 0.70) {
    spark = ease(0.45, 0.70);
  } else if (x < 0.85) {
    spark = 1;
  } else {
    spark = 1 - ease(0.85, 1.0);
  }

  return LoaderFrame(
    draw: draw,
    opacity: 0.3 + 0.7 * draw,
    sparkScale: 0.92 + (1.13 - 0.92) * spark,
    sparkOpacity: 0.25 + 0.75 * spark,
  );
}

/// The animated "charging" emblem: a rebuild of
/// `assets/brand/loader_reference.svg` (CSS animations don't play in
/// flutter_svg). The emblem lines draw themselves progressively
/// (`PathMetric.extractPath`) while a four-point spark pulses above the head.
///
/// Shows the static full emblem when the device asks for reduced motion or
/// the user switched Settings › Motion off. Use it for any wait > 300 ms.
///
/// Tests: while it animates, use `pump(duration)` rather than `pumpAndSettle`.
class CarthaLoader extends StatefulWidget {
  const CarthaLoader({
    super.key,
    this.size = 64,
    this.tile = false,
    this.color,
    this.sparkColor,
    this.startAt = 0,
    this.semanticLabel,
  });

  /// Width (and height) of the square it paints in.
  final double size;

  /// Paint the rounded hero tile behind the emblem (app-icon look).
  final bool tile;

  /// Line colour; defaults to `heroAccent` on a tile, else `emblem`.
  final Color? color;

  /// Spark colour; defaults to `onHero` on a tile, else `textPrimary`.
  final Color? sparkColor;

  /// Cycle position to start from (0–1). 0.7 starts fully drawn, which hands
  /// off seamlessly from the static native splash.
  final double startAt;

  /// Defaults to "Loading".
  final String? semanticLabel;

  @override
  State<CarthaLoader> createState() => _CarthaLoaderState();
}

class _CarthaLoaderState extends State<CarthaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: kLoaderCycle,
    value: widget.startAt.clamp(0.0, 1.0),
  );
  bool _animate = false;

  void _setAnimating(bool animate) {
    if (animate == _animate) return;
    _animate = animate;
    if (animate) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceReduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final motionSetting = context.select<AppState?, bool>(
      (s) => s?.settings.motion ?? true,
    );
    _setAnimating(!deviceReduced && motionSetting);
    final p = CarthaPalette.of(context);
    final painter = _LoaderPainter(
      animation: _controller,
      animate: _animate,
      tileColor: widget.tile ? p.hero : null,
      lineColor: widget.color ?? (widget.tile ? p.heroAccent : p.emblem),
      sparkColor: widget.sparkColor ?? (widget.tile ? p.onHero : p.textPrimary),
    );
    return Semantics(
      label: widget.semanticLabel ?? AppLocalizations.of(context).loaderLabel,
      image: true,
      child: RepaintBoundary(
        child: CustomPaint(size: Size.square(widget.size), painter: painter),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter({
    required this.animation,
    required this.animate,
    required this.lineColor,
    required this.sparkColor,
    this.tileColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final bool animate;
  final Color lineColor;
  final Color sparkColor;
  final Color? tileColor;

  static final List<PathMetric> _lineMetrics = [
    for (final p in EmblemGeometry.lines) p.computeMetrics().first,
  ];
  static final PathMetric _trunkMetric = EmblemGeometry.trunk
      .computeMetrics()
      .first;

  /// The frame currently painted (exposed for tests through the widget tree).
  LoaderFrame get frame =>
      animate ? loaderFrameAt(animation.value) : LoaderFrame.still;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame;
    canvas.save();
    if (tileColor != null) {
      final scale = size.shortestSide / EmblemGeometry.viewBox;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(110 * scale),
        ),
        Paint()..color = tileColor!,
      );
      EmblemGeometry.fit(
        canvas,
        size,
        const Rect.fromLTWH(
          0,
          0,
          EmblemGeometry.viewBox,
          EmblemGeometry.viewBox,
        ),
      );
    } else {
      EmblemGeometry.fit(canvas, size, EmblemGeometry.sparkBounds);
    }

    if (f.draw > 0) {
      final color = lineColor.withValues(alpha: lineColor.a * f.opacity);
      final line = EmblemGeometry.linePaint(color);
      for (final m in _lineMetrics) {
        canvas.drawPath(m.extractPath(0, f.drawnLength(m.length)), line);
      }
      canvas.drawPath(
        _trunkMetric.extractPath(0, f.drawnLength(_trunkMetric.length)),
        EmblemGeometry.trunkPaint(color),
      );
    }

    final c = EmblemGeometry.sparkCenter;
    canvas
      ..translate(c.dx, c.dy)
      ..scale(f.sparkScale)
      ..translate(-c.dx, -c.dy)
      ..drawPath(
        EmblemGeometry.spark,
        Paint()
          ..color = sparkColor.withValues(alpha: sparkColor.a * f.sparkOpacity),
      );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LoaderPainter old) =>
      old.animate != animate ||
      old.lineColor != lineColor ||
      old.sparkColor != sparkColor ||
      old.tileColor != tileColor;
}

/// Test hook: whether a [CarthaLoader] state is animating.
@visibleForTesting
bool isLoaderAnimating(State state) =>
    state is _CarthaLoaderState && state._controller.isAnimating;
