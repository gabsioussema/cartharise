import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../domain/campaign.dart' show Achievement;
import '../../theme/cartha_theme.dart';
import 'glyph_art.dart';

/// The seven achievement badges: a medallion like the avatar's disc (hero
/// surface, bronze rim) carrying one symbol per achievement, drawn in the
/// glyphs' line style.
///
/// * **Earned:** a filled medallion with a double rim and two ribbon tails.
/// * **Not yet:** an empty slot with a dashed rim, no ribbons, and the
///   symbol in outline only.
///
/// So the two states differ in shape, never by colour alone.
abstract final class BadgeArt {
  /// The badge's design space (48 × 48).
  static const double grid = 48;

  /// The medallion's centre and radius in [grid] units.
  static const Offset centre = Offset(24, 20.5);
  static const double radius = 16.5;

  /// How large a 24-unit symbol is drawn inside the medallion.
  static const double symbolSide = 21;

  static GlyphArt symbolOf(Achievement a) => switch (a) {
    Achievement.observer => _observer,
    Achievement.pathfinder => _pathfinder,
    Achievement.visionary => _visionary,
    Achievement.watchful => _watchful,
    Achievement.strategist => _strategist,
    Achievement.practitioner => _practitioner,
    Achievement.challenger => _challenger,
  };

  /// The Observer (present reality): an open eye.
  static final _observer = GlyphArt(
    lines: [
      Path()
        ..moveTo(2.5, 12.5)
        ..quadraticBezierTo(12, 3.7, 21.5, 12.5)
        ..quadraticBezierTo(12, 21.3, 2.5, 12.5)
        ..close(),
    ],
    details: [
      Path()
        ..moveTo(12, 5)
        ..lineTo(12, 2.6),
      Path()
        ..moveTo(7.4, 6.4)
        ..lineTo(6.2, 4.4),
      Path()
        ..moveTo(16.6, 6.4)
        ..lineTo(17.8, 4.4),
    ],
    fills: [
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(12, 12.5), radius: 3.7)),
    ],
    cutouts: [
      Path()..addOval(
        Rect.fromCircle(center: const Offset(13.3, 11.2), radius: 1.15),
      ),
    ],
  );

  /// The Pathfinder (anti-vision and identity): a signpost, two ways.
  static final _pathfinder = GlyphArt(
    lines: [
      Path()
        ..moveTo(12, 4.2)
        ..lineTo(12, 20.6),
      Path()
        ..moveTo(7, 20.6)
        ..lineTo(17, 20.6),
      Path()
        ..moveTo(12, 11.9)
        ..lineTo(5.6, 11.9)
        ..lineTo(3.2, 14.2)
        ..lineTo(5.6, 16.5)
        ..lineTo(12, 16.5),
    ],
    fills: [
      Path()..addPolygon(const [
        Offset(12, 5.2),
        Offset(18.4, 5.2),
        Offset(20.8, 7.5),
        Offset(18.4, 9.8),
        Offset(12, 9.8),
      ], true),
    ],
  );

  /// The Visionary (a possible future): the sun rising, with rays.
  static final GlyphArt _visionary = () {
    const sun = Offset(12, 16);
    return GlyphArt(
      lines: [
        Path()
          ..moveTo(2.5, 16)
          ..lineTo(21.5, 16),
        for (final deg in const [-162.0, -126.0, -90.0, -54.0, -18.0])
          () {
            final a = deg * math.pi / 180;
            final dir = Offset(math.cos(a), math.sin(a));
            return Path()
              ..moveTo((sun + dir * 7.4).dx, (sun + dir * 7.4).dy)
              ..lineTo((sun + dir * 10).dx, (sun + dir * 10).dy);
          }(),
      ],
      details: [
        Path()
          ..moveTo(7.5, 19.2)
          ..lineTo(16.5, 19.2),
      ],
      fills: [
        Path()
          ..moveTo(6.75, 16)
          ..arcToPoint(
            const Offset(17.25, 16),
            radius: const Radius.circular(5.25),
          )
          ..close(),
      ],
    );
  }();

  /// The Watchful (daytime check-ins): an owl on a branch.
  static final _watchful = GlyphArt(
    lines: [
      Path()
        ..moveTo(6.5, 5)
        ..lineTo(9.4, 8)
        ..lineTo(14.6, 8)
        ..lineTo(17.5, 5)
        ..lineTo(17.5, 14.2)
        ..quadraticBezierTo(17.5, 20, 12, 20)
        ..quadraticBezierTo(6.5, 20, 6.5, 14.2)
        ..close(),
      Path()
        ..moveTo(3.5, 22)
        ..lineTo(20.5, 22),
    ],
    fills: [
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(9.8, 11.7), radius: 2.2))
        ..addOval(
          Rect.fromCircle(center: const Offset(14.2, 11.7), radius: 2.2),
        ),
      Path()..addPolygon(const [
        Offset(11.1, 14.3),
        Offset(12.9, 14.3),
        Offset(12, 16.3),
      ], true),
    ],
    cutouts: [
      Path()
        ..addOval(
          Rect.fromCircle(center: const Offset(9.8, 11.7), radius: 0.95),
        )
        ..addOval(
          Rect.fromCircle(center: const Offset(14.2, 11.7), radius: 0.95),
        ),
    ],
  );

  /// The Strategist (the evening plan): a folded map with a route to an X.
  static final _strategist = GlyphArt(
    lines: [
      Path()..addPolygon(const [
        Offset(3, 6.4),
        Offset(9, 4.4),
        Offset(15, 6.4),
        Offset(21, 4.4),
        Offset(21, 17.6),
        Offset(15, 19.6),
        Offset(9, 17.6),
        Offset(3, 19.6),
      ], true),
    ],
    details: [
      Path()
        ..moveTo(9, 4.4)
        ..lineTo(9, 17.6),
      Path()
        ..moveTo(15, 6.4)
        ..lineTo(15, 19.6),
      Path()
        ..moveTo(16.4, 8.6)
        ..lineTo(19.4, 11.6)
        ..moveTo(19.4, 8.6)
        ..lineTo(16.4, 11.6),
    ],
    fills: [
      for (final c in const [
        Offset(5.8, 15.4),
        Offset(9, 13.6),
        Offset(12.2, 12.4),
      ])
        Path()..addOval(Rect.fromCircle(center: c, radius: 1)),
    ],
  );

  /// The Practitioner (a real-world quest): an anvil with sparks, a craft
  /// practised by hand.
  static final _practitioner = GlyphArt(
    lines: [
      Path()
        ..moveTo(5, 20.6)
        ..lineTo(19, 20.6),
    ],
    details: [
      Path()
        ..moveTo(14, 5.4)
        ..lineTo(14, 2.8),
      Path()
        ..moveTo(16.4, 6.2)
        ..lineTo(18.2, 4.4),
      Path()
        ..moveTo(11.6, 6.2)
        ..lineTo(9.8, 4.4),
    ],
    fills: [
      Path()
        ..moveTo(2.6, 8.6)
        ..lineTo(20.6, 8.6)
        ..lineTo(20.6, 11.6)
        ..lineTo(16.6, 11.6)
        ..lineTo(15.2, 14.2)
        ..lineTo(17.6, 17.4)
        ..lineTo(17.6, 19.2)
        ..lineTo(6.4, 19.2)
        ..lineTo(6.4, 17.4)
        ..lineTo(8.8, 14.2)
        ..lineTo(8, 11.6)
        ..quadraticBezierTo(4.4, 11.4, 2.6, 8.6)
        ..close(),
    ],
  );

  /// The Challenger (a first attempt): a summit with a flag.
  static final _challenger = GlyphArt(
    lines: [
      Path()..addPolygon(const [
        Offset(2.4, 20.6),
        Offset(9.6, 9.2),
        Offset(13, 14.2),
        Offset(15.6, 11.2),
        Offset(21.6, 20.6),
      ], true),
      Path()
        ..moveTo(9.6, 9.2)
        ..lineTo(9.6, 2.6),
    ],
    fills: [
      Path()..addPolygon(const [
        Offset(9.6, 2.6),
        Offset(15, 4.3),
        Offset(9.6, 6),
      ], true),
    ],
  );
}

/// Paints [achievement]'s badge, earned or not yet (see [BadgeArt]).
class AchievementBadgePainter extends CustomPainter {
  const AchievementBadgePainter({
    required this.achievement,
    required this.earned,
    required this.palette,
  });

  final Achievement achievement;
  final bool earned;
  final CarthaPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (!side.isFinite || side <= 0) return;
    final scale = side / BadgeArt.grid;
    final px = 1 / scale; // one physical-ish pixel in grid units
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(scale);
    const c = BadgeArt.centre;
    const r = BadgeArt.radius;
    final p = palette;
    if (earned) {
      // Ribbon tails behind the medallion.
      final tail = Paint()..isAntiAlias = true;
      canvas.drawPath(
        Path()..addPolygon(const [
          Offset(16.5, 30),
          Offset(22.5, 33),
          Offset(20.2, 46),
          Offset(17.6, 43.2),
          Offset(14, 45.4),
        ], true),
        tail..color = p.heroAccent,
      );
      canvas.drawPath(
        Path()..addPolygon(const [
          Offset(31.5, 30),
          Offset(25.5, 33),
          Offset(27.8, 46),
          Offset(30.4, 43.2),
          Offset(34, 45.4),
        ], true),
        tail..color = Color.lerp(p.heroAccent, p.hero, 0.35)!,
      );
      canvas.drawCircle(c, r, Paint()..color = p.hero);
      final rimWidth = math.max(2.2, 1.2 * px);
      canvas.drawCircle(c, r - rimWidth / 2, _stroke(p.heroAccent, rimWidth));
      canvas.drawCircle(
        c,
        r - 3.3,
        _stroke(p.heroAccent.withValues(alpha: 0.45), math.max(0.8, 0.8 * px)),
      );
    } else {
      canvas.drawCircle(c, r, Paint()..color = p.raised);
      final ring = _stroke(p.textSecondary, math.max(1.4, 1.1 * px));
      const dashes = 20;
      const sweep = 2 * math.pi / dashes;
      final rect = Rect.fromCircle(center: c, radius: r - 0.9);
      for (var i = 0; i < dashes; i++) {
        canvas.drawArc(
          rect,
          i * sweep - math.pi / 2,
          sweep * 0.55,
          false,
          ring,
        );
      }
    }
    // The symbol, centred in the medallion.
    const k = BadgeArt.symbolSide / GlyphArt.grid;
    canvas.translate(
      c.dx - BadgeArt.symbolSide / 2,
      c.dy - BadgeArt.symbolSide / 2,
    );
    canvas.scale(k);
    final unitPx = 1 / (scale * k); // one pixel in symbol units
    BadgeArt.symbolOf(achievement).paint(
      canvas,
      color: earned ? p.heroAccent : p.textSecondary,
      weight: math.max(earned ? 2.0 : 1.7, 1.1 * unitPx),
      minDetail: 0.9 * unitPx,
      hollow: !earned,
      background: p.hero,
    );
    canvas.restore();
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..isAntiAlias = true;

  @override
  bool shouldRepaint(AchievementBadgePainter old) =>
      old.achievement != achievement ||
      old.earned != earned ||
      old.palette != palette;
}
