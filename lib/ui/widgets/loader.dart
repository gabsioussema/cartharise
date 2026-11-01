import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import 'emblem.dart';

/// One moment of the loader animation (see [loaderFrameAt]).
@immutable
class LoaderFrame {
  const LoaderFrame({required this.charge, required this.glow});

  /// How "charged" the emblem is (0–1): it rises from dim to full strength.
  final double charge;

  /// The halo around the fully charged emblem (0–1).
  final double glow;

  /// Opacity of the emblem: dim (.28) when empty, opaque when charged.
  double get opacity => 0.28 + 0.72 * charge;

  /// The reduced-motion / static look: fully charged, no halo.
  static const still = LoaderFrame(charge: 1, glow: 0);
}

/// Duration of one loader cycle (as `assets/brand/loader_reference.svg`).
const Duration kLoaderCycle = Duration(milliseconds: 3200);

/// The "charging" keyframes of `loader_reference.svg` (the brand board's
/// loading / charging animation), each segment eased with CSS
/// `ease-in-out` (= [Curves.easeInOut]), at cycle position [t] (0–1):
///
/// * charge: dim at 0–8 %, rises to full by 55 %, held to 88 %, back to dim
///   by 100 %;
/// * glow: only while fully charged — blooms from 55 % to 70 %, held to
///   80 %, gone by 88 %.
LoaderFrame loaderFrameAt(double t) {
  final x = t - t.floorToDouble();
  double ease(double from, double to) =>
      Curves.easeInOut.transform(((x - from) / (to - from)).clamp(0.0, 1.0));

  final double charge;
  if (x < 0.08) {
    charge = 0;
  } else if (x < 0.55) {
    charge = ease(0.08, 0.55);
  } else if (x < 0.88) {
    charge = 1;
  } else {
    charge = 1 - ease(0.88, 1.0);
  }

  final double glow;
  if (x < 0.55) {
    glow = 0;
  } else if (x < 0.70) {
    glow = ease(0.55, 0.70);
  } else if (x < 0.80) {
    glow = 1;
  } else {
    glow = 1 - ease(0.80, 0.88);
  }

  return LoaderFrame(charge: charge, glow: glow);
}

/// The animated "charging" emblem from the brand board: the emblem rises
/// from dim to full strength, a warm halo blooms around it, then it settles
/// and starts again. With [showBar], a slim charge bar under the emblem
/// fills with it (the board's app & splash loader).
///
/// Shows the static, fully charged emblem (no halo, no bar) when the device
/// asks for reduced motion or the user switched Settings › Motion off. Use it
/// for any wait > 300 ms.
///
/// Tests: while it animates, use `pump(duration)` rather than `pumpAndSettle`.
class CarthaLoader extends StatefulWidget {
  const CarthaLoader({
    super.key,
    this.size = 64,
    this.tile = false,
    this.showBar = false,
    this.color,
    this.glowColor,
    this.startAt = 0,
    this.semanticLabel,
  });

  /// Width (and, without [showBar], height) of the box it paints in.
  final double size;

  /// Paint the rounded hero tile behind the emblem (app-icon look).
  final bool tile;

  /// Add the charge bar under the emblem (boot screen).
  final bool showBar;

  /// Emblem colour; defaults to `heroAccent` on a tile, else `emblem`.
  final Color? color;

  /// Colour the emblem warms towards at full charge, and of its halo;
  /// defaults to `onHero` on a tile, else [color].
  final Color? glowColor;

  /// Cycle position to start from (0–1). 0.6 starts fully charged, which
  /// hands off seamlessly from the static native splash.
  final double startAt;

  /// Defaults to "Loading".
  final String? semanticLabel;

  /// Height of the box including the charge bar.
  double get height => showBar ? size * 1.16 : size;

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
    final color = widget.color ?? (widget.tile ? p.heroAccent : p.emblem);
    final painter = _LoaderPainter(
      animation: _controller,
      animate: _animate,
      tileColor: widget.tile ? p.hero : null,
      color: color,
      glowColor: widget.glowColor ?? (widget.tile ? p.onHero : color),
      showBar: widget.showBar,
    );
    return Semantics(
      label: widget.semanticLabel ?? AppLocalizations.of(context).loaderLabel,
      image: true,
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(widget.size, widget.height),
          painter: painter,
        ),
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter({
    required this.animation,
    required this.animate,
    required this.color,
    required this.glowColor,
    required this.showBar,
    this.tileColor,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final bool animate;
  final Color color;
  final Color glowColor;
  final bool showBar;
  final Color? tileColor;

  /// The emblem takes 70 % of a tile's width, like the app icon.
  static const double _tileFill = 0.70;

  /// Halo blur, in design units.
  static const double _glowSigma = 14;

  /// The frame currently painted (exposed for tests through the widget tree).
  LoaderFrame get frame =>
      animate ? loaderFrameAt(animation.value) : LoaderFrame.still;

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame;
    final box = Offset.zero & Size(size.width, size.width);
    canvas.save();
    if (tileColor != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, Radius.circular(size.width * 110 / 512)),
        Paint()..color = tileColor!,
      );
    }
    const b = EmblemGeometry.tightBounds;
    final side = tileColor != null
        ? b.width / _tileFill
        : b.width + _glowSigma * 3;
    EmblemGeometry.fit(
      canvas,
      box.size,
      Rect.fromCenter(center: b.center, width: side, height: side),
    );

    // Composite the emblem (and its halo) as one layer, so crossing lines
    // and overlapping tapers fade together instead of doubling up. Only the
    // layer paint's alpha matters.
    final ink = Color.lerp(color, glowColor, 0.35 * f.glow)!;
    canvas.saveLayer(
      b.inflate(_glowSigma * 3),
      Paint()..color = color.withValues(alpha: f.opacity),
    );
    if (f.glow > 0) {
      final halo = glowColor.withValues(alpha: glowColor.a * 0.55 * f.glow);
      final blur = MaskFilter.blur(BlurStyle.normal, _glowSigma);
      final line = EmblemGeometry.linePaint(halo)..maskFilter = blur;
      final fill = EmblemGeometry.fillPaint(halo)..maskFilter = blur;
      for (final path in EmblemGeometry.lines) {
        canvas.drawPath(path, line);
      }
      for (final path in EmblemGeometry.fills) {
        canvas.drawPath(path, fill);
      }
    }
    EmblemGeometry.paint(canvas, ink);
    canvas
      ..restore()
      ..restore();

    if (showBar && animate) _paintBar(canvas, size, f);
  }

  void _paintBar(Canvas canvas, Size size, LoaderFrame f) {
    final width = size.width * 0.7;
    final height = (size.width * 0.022).clamp(2.0, 4.0);
    final left = (size.width - width) / 2;
    final top = size.height - height;
    final radius = Radius.circular(height / 2);
    canvas.drawRRect(
      RRect.fromLTRBR(left, top, left + width, top + height, radius),
      Paint()..color = color.withValues(alpha: color.a * 0.22),
    );
    final filled = lerpDouble(0, width, f.charge)!;
    if (filled <= 0) return;
    canvas.drawRRect(
      RRect.fromLTRBR(left, top, left + filled, top + height, radius),
      Paint()..color = Color.lerp(color, glowColor, 0.35 * f.glow)!,
    );
  }

  @override
  bool shouldRepaint(_LoaderPainter old) =>
      old.animate != animate ||
      old.color != color ||
      old.glowColor != glowColor ||
      old.showBar != showBar ||
      old.tileColor != tileColor;
}

/// Test hook: whether a [CarthaLoader] state is animating.
@visibleForTesting
bool isLoaderAnimating(State state) =>
    state is _CarthaLoaderState && state._controller.isAnimating;

/// Test hook: the frame a [CarthaLoader] state is showing.
@visibleForTesting
LoaderFrame loaderFrameOf(State state) {
  final s = state as _CarthaLoaderState;
  return s._animate ? loaderFrameAt(s._controller.value) : LoaderFrame.still;
}
