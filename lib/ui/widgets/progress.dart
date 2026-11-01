import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';

/// A calm ring showing how much of something is done (the board's "40 %").
/// Progress is information, never a judgement: no red, no "missed".
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.label,
    this.size = 64,
    this.strokeWidth = 6,
    this.onHero = false,
    this.semanticLabel,
  });

  /// 0–1 (clamped).
  final double value;

  /// Text in the centre; defaults to the percentage.
  final String? label;
  final double size;
  final double strokeWidth;

  /// Use hero colours (inside a `HeroCard`).
  final bool onHero;

  /// Defaults to "n percent".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final percent = (v * 100).round();
    final text = label ?? '$percent%';
    final fg = onHero ? p.heroAccent : p.accent;
    final track = onHero ? p.heroRaised : p.raisedHigh;
    final textColor = onHero ? p.onHero : p.textPrimary;
    return Semantics(
      label:
          semanticLabel ?? AppLocalizations.of(context).progressLabel(percent),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(
            value: v,
            color: fg,
            track: track,
            strokeWidth: strokeWidth,
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(strokeWidth + 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge
                      ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * math.pi, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * value,
        false,
        paint..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}
