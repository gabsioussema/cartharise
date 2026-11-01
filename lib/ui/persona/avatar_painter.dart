import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../domain/persona.dart';
import '../theme/avatar_palette.dart';
import '../theme/cartha_theme.dart';
import '../widgets/emblem.dart';

/// How much detail a portrait of a given size can carry.
enum AvatarDetail {
  /// Under 40 px: shapes and eyes only (no banner, textures or freckles).
  tiny,

  /// 40–119 px: every part, light texture.
  regular,

  /// 120 px and up: hair strands, folds and the finest marks.
  fine,
}

/// The level of detail for a portrait [size] logical pixels wide.
AvatarDetail avatarDetailFor(double size) => size < 40
    ? AvatarDetail.tiny
    : size < 120
    ? AvatarDetail.regular
    : AvatarDetail.fine;

/// The theme's part of the portrait: the disc, the bronze rim, the banner
/// behind and the tint of the silhouette (all palette tokens).
@immutable
class AvatarScene {
  const AvatarScene({
    required this.disc,
    required this.rim,
    required this.banner,
    required this.mono,
  });

  factory AvatarScene.of(CarthaPalette p) => AvatarScene(
    disc: p.hero,
    rim: p.heroAccent,
    banner: p.heroAccent,
    mono: p.onHeroMuted,
  );

  final Color disc;
  final Color rim;
  final Color banner;

  /// The silhouette is drawn in tones between [disc] and this.
  final Color mono;

  @override
  bool operator ==(Object other) =>
      other is AvatarScene &&
      other.disc == disc &&
      other.rim == rim &&
      other.banner == banner &&
      other.mono == mono;

  @override
  int get hashCode => Object.hash(disc, rim, banner, mono);
}

/// Paints [avatar] as a calm, flat bust in a disc with a thin bronze rim.
///
/// Drawn in a 100 × 100 design space (the disc's centre is (50, 50)), back to
/// front: disc, banner, hair behind, body and garment, ears and face, marks,
/// features, facial hair, glasses, hair in front, headwear, rim. With no skin
/// tone the figure is a monochrome silhouette in theme tones: no skin colour
/// is assumed and no face is drawn.
class AvatarPainter extends CustomPainter {
  const AvatarPainter({
    required this.avatar,
    required this.scene,
    this.showSigil = true,
  });

  final Avatar avatar;
  final AvatarScene scene;
  final bool showSigil;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (!side.isFinite || side <= 0) return;
    final scale = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(scale);
    _Artist(
      canvas: canvas,
      scale: scale,
      avatar: avatar,
      scene: scene,
      showSigil: showSigil,
      detail: avatarDetailFor(side),
    ).paint();
    canvas.restore();
  }

  @override
  bool shouldRepaint(AvatarPainter old) =>
      old.avatar != avatar || old.scene != scene || old.showSigil != showSigil;
}

/// The stand-in without an avatar: the Cartharise emblem on the same disc.
class AvatarEmblemPainter extends CustomPainter {
  const AvatarEmblemPainter({required this.scene});

  final AvatarScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    if (!side.isFinite || side <= 0) return;
    final scale = side / 100;
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(scale);
    final rimW = math.max(2.0, 1 / scale);
    canvas.drawCircle(_centre, 50, _fill(scene.disc));
    const box = Rect.fromLTWH(20, 33, 60, 34);
    canvas.save();
    canvas.translate(box.left, box.top);
    EmblemGeometry.fit(canvas, box.size, EmblemGeometry.tightBounds);
    EmblemGeometry.paint(canvas, scene.rim);
    canvas.restore();
    canvas.drawCircle(_centre, 50 - rimW / 2, _line(scene.rim, rimW));
    canvas.restore();
  }

  @override
  bool shouldRepaint(AvatarEmblemPainter old) => old.scene != scene;
}

const _centre = Offset(50, 50);

Paint _fill(Color c) => Paint()
  ..color = c
  ..style = PaintingStyle.fill
  ..isAntiAlias = true;

Paint _line(Color c, double width, {StrokeCap cap = StrokeCap.round}) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = cap
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;

/// x → 100 − x (the portrait is drawn symmetric around x = 50).
final Float64List _mirrorX = Float64List.fromList(<double>[
  -1, 0, 0, 0, //
  0, 1, 0, 0,
  0, 0, 1, 0,
  100, 0, 0, 1,
]);

Path _mirrored(Path p) => p.transform(_mirrorX);

/// Head proportions per face shape (design units).
class _Head {
  const _Head({
    required this.top,
    required this.w,
    required this.cheekY,
    required this.jawY,
    required this.jawW,
    required this.chinY,
    required this.chinW,
    required this.corner,
    required this.eyeY,
    required this.neckW,
  });

  factory _Head.of(FaceShape shape) => switch (shape) {
    FaceShape.oval => const _Head(
      top: 21,
      w: 14.5,
      cheekY: 42,
      jawY: 54,
      jawW: 11.2,
      chinY: 62.5,
      chinW: 4.2,
      corner: 0.5,
      eyeY: 44,
      neckW: 6.2,
    ),
    FaceShape.round => const _Head(
      top: 21.4,
      w: 15.6,
      cheekY: 43,
      jawY: 54.5,
      jawW: 13.2,
      chinY: 61.6,
      chinW: 6.2,
      corner: 0.62,
      eyeY: 44.2,
      neckW: 6.6,
    ),
    FaceShape.square => const _Head(
      top: 21,
      w: 15,
      cheekY: 42,
      jawY: 56.2,
      jawW: 14,
      chinY: 62.6,
      chinW: 7.4,
      corner: 0.08,
      eyeY: 44,
      neckW: 6.8,
    ),
    FaceShape.long => const _Head(
      top: 19.6,
      w: 13.6,
      cheekY: 42,
      jawY: 56,
      jawW: 10.6,
      chinY: 64.4,
      chinW: 4.2,
      corner: 0.5,
      eyeY: 44.6,
      neckW: 6,
    ),
  };

  /// Crown (y) and half width at the cheekbones.
  final double top;
  final double w;
  final double cheekY;
  final double jawY;
  final double jawW;
  final double chinY;
  final double chinW;

  /// 0 = a sharp jaw corner, 1 = a soft one.
  final double corner;
  final double eyeY;
  final double neckW;

  /// Hair and headwear are drawn for the oval head, then fitted.
  double get sx => w / 14.5;
  double get dy => top - 21;

  double get eyeDx => w * 0.425;
  double get browY => eyeY - 4.7;
  double get noseY => eyeY + 5.4;
  double get mouthY => eyeY + 9.6;

  Path get face {
    final c1 = cheekY + (jawY - cheekY) * 0.45;
    final c2y = jawY - (jawY - cheekY) * 0.2;
    final c2x = jawW + (w - jawW) * 0.35;
    final c3y = jawY + (chinY - jawY) * 0.6;
    final c3x = jawW - (jawW - chinW) * corner;
    final c4x = chinW + (jawW - chinW) * 0.4;
    final topY = top + (cheekY - top) * 0.38;
    return Path()
      ..moveTo(50, top)
      ..cubicTo(50 + w * 0.6, top, 50 + w, topY, 50 + w, cheekY)
      ..cubicTo(50 + w, c1, 50 + c2x, c2y, 50 + jawW, jawY)
      ..cubicTo(50 + c3x, c3y, 50 + c4x, chinY, 50 + chinW, chinY)
      ..quadraticBezierTo(50, chinY + 0.9, 50 - chinW, chinY)
      ..cubicTo(50 - c4x, chinY, 50 - c3x, c3y, 50 - jawW, jawY)
      ..cubicTo(50 - c2x, c2y, 50 - w, c1, 50 - w, cheekY)
      ..cubicTo(50 - w, topY, 50 - w * 0.6, top, 50, top)
      ..close();
  }

  /// Neck, widening a little into the chest under any neckline.
  Path get neck => Path()
    ..moveTo(50 - neckW, jawY - 6)
    ..lineTo(50 + neckW, jawY - 6)
    ..lineTo(50 + neckW, 62)
    ..cubicTo(50 + neckW + 0.4, 65, 50 + neckW + 2.5, 66, 59.2, 66.8)
    ..lineTo(59.2, 92)
    ..lineTo(40.8, 92)
    ..lineTo(40.8, 66.8)
    ..cubicTo(50 - neckW - 2.5, 66, 50 - neckW - 0.4, 65, 50 - neckW, 62)
    ..close();
}

/// The colours of one portrait: the avatar's own, or monochrome theme
/// tones for the silhouette.
class _Look {
  const _Look({
    required this.mono,
    required this.skin,
    required this.skinLight,
    required this.hair,
    required this.garment,
    required this.ink,
    required this.catchlight,
    required this.metal,
    required this.metalShade,
    required this.metalShine,
    required this.leather,
    required this.leatherShade,
    required this.stitch,
    required this.parchment,
    required this.parchmentShade,
    required this.ribbon,
    required this.frame,
    required this.lens,
  });

  factory _Look.of(Avatar a, AvatarScene scene) {
    final tone = a.skinTone;
    if (tone == null) {
      Color m(double t) => Color.lerp(scene.disc, scene.mono, t)!;
      return _Look(
        mono: true,
        skin: SkinColors(base: m(0.5), shade: m(0.43), lip: m(0.43)),
        skinLight: m(0.6),
        hair: HairColors(base: m(0.3), shade: m(0.24), shine: m(0.37)),
        garment: GarmentColors(
          base: m(0.37),
          shade: m(0.3),
          trim: m(0.58),
          under: m(0.45),
          underShade: m(0.39),
        ),
        ink: m(0.2),
        catchlight: m(0.9),
        metal: m(0.66),
        metalShade: m(0.52),
        metalShine: m(0.78),
        leather: m(0.27),
        leatherShade: m(0.22),
        stitch: m(0.45),
        parchment: m(0.7),
        parchmentShade: m(0.58),
        ribbon: m(0.3),
        frame: m(0.82),
        lens: m(1).withValues(alpha: 0),
      );
    }
    final skin = AvatarPalette.skin(tone);
    return _Look(
      mono: false,
      skin: skin,
      skinLight: skin.light,
      hair: AvatarPalette.hair(a.hairColor),
      garment: AvatarPalette.garment(a.garmentColor),
      ink: AvatarColors.ink,
      catchlight: AvatarColors.catchlight,
      metal: AvatarColors.metal,
      metalShade: AvatarColors.metalShade,
      metalShine: AvatarColors.metalShine,
      leather: AvatarColors.leather,
      leatherShade: AvatarColors.leatherShade,
      stitch: AvatarColors.leatherStitch,
      parchment: AvatarColors.parchment,
      parchmentShade: AvatarColors.parchmentShade,
      ribbon: AvatarColors.ribbon,
      frame: AvatarPalette.frameFor(skin),
      lens: AvatarColors.lens.withValues(alpha: 0.14),
    );
  }

  final bool mono;
  final SkinColors skin;
  final Color skinLight;
  final HairColors hair;
  final GarmentColors garment;
  final Color ink;
  final Color catchlight;
  final Color metal;
  final Color metalShade;
  final Color metalShine;
  final Color leather;
  final Color leatherShade;
  final Color stitch;
  final Color parchment;
  final Color parchmentShade;
  final Color ribbon;
  final Color frame;
  final Color lens;
}

/// A hanging strand (a loc or a braid) as a quadratic curve.
class _Strand {
  const _Strand(this.from, this.via, this.to);
  final Offset from;
  final Offset via;
  final Offset to;

  Path get path => Path()
    ..moveTo(from.dx, from.dy)
    ..quadraticBezierTo(via.dx, via.dy, to.dx, to.dy);

  Offset at(double t) {
    final u = 1 - t;
    return from * (u * u) + via * (2 * u * t) + to * (t * t);
  }

  _Strand get mirrored => _Strand(_mx(from), _mx(via), _mx(to));
  static Offset _mx(Offset o) => Offset(100 - o.dx, o.dy);
}

class _Artist {
  _Artist({
    required this.canvas,
    required this.scale,
    required this.avatar,
    required this.scene,
    required this.showSigil,
    required this.detail,
  }) : head = _Head.of(avatar.face),
       look = _Look.of(avatar, scene);

  final Canvas canvas;
  final double scale;
  final Avatar avatar;
  final AvatarScene scene;
  final bool showSigil;
  final AvatarDetail detail;
  final _Head head;
  final _Look look;

  bool get tiny => detail == AvatarDetail.tiny;
  bool get fine => detail == AvatarDetail.fine;

  /// [units] wide, but never thinner than [minPx] device pixels.
  double w(double units, [double minPx = 0.9]) =>
      math.max(units, minPx / scale);

  /// A thin bronze rim (brand board), never under one device pixel.
  double get rimW => w(1.5, 1.0);

  void sym(Path p, Paint paint) {
    canvas.drawPath(p, paint);
    canvas.drawPath(_mirrored(p), paint);
  }

  void clipped(Path clip, void Function() draw) {
    canvas.save();
    canvas.clipPath(clip);
    draw();
    canvas.restore();
  }

  /// Draws in the oval head's space, fitted to the chosen face shape.
  void inHeadSpace(void Function() draw) {
    canvas.save();
    canvas.translate(50, head.dy);
    canvas.scale(head.sx, 1);
    canvas.translate(-50, 0);
    draw();
    canvas.restore();
  }

  void paint() {
    canvas.drawCircle(_centre, 50, _fill(scene.disc));
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: _centre, radius: 50 - rimW / 2)),
    );
    if (showSigil && !tiny) _sigil();

    // The figure is drawn at its design size, then grown a little around
    // the shoulders so the face fills the disc.
    canvas.save();
    canvas.translate(_figureAnchor.dx, _figureAnchor.dy);
    canvas.scale(_figureScale);
    canvas.translate(-_figureAnchor.dx, -_figureAnchor.dy);
    final hw = avatar.headwear;
    final hidesHair = hw == Headwear.headscarf || hw == Headwear.turban;
    final draped = hw == Headwear.headscarf || hw == Headwear.hood;
    if (!hidesHair && hw != Headwear.hood) _hairBehind();
    _body();
    if (!draped) _accessory();
    if (hw != Headwear.headscarf) _ears();
    _face();
    _marks();
    _features();
    _facialHair();
    _glasses();
    if (!hidesHair) _hairFront();
    _headwear();
    if (draped) _accessory();
    canvas.restore();
    canvas.restore();
    canvas.drawCircle(_centre, 50 - rimW / 2, _line(scene.rim, rimW));
  }

  static const _figureAnchor = Offset(50, 66);
  static const _figureScale = 1.1;

  // ── Banner ────────────────────────────────────────────────────────────

  void _sigil() {
    final c = scene.banner.withValues(alpha: 0.42);
    final stroke = _line(c, w(1.5, 1.0));
    switch (avatar.sigil) {
      case Sigil.none:
        return;
      case Sigil.elephant:
        // The whole emblem as a crest beside the head. (Large and behind
        // the head, its face lines read as horns or as the person's ears.)
        const crest = Rect.fromLTWH(64.5, 17.5, 23.5, 13.4);
        canvas.save();
        canvas.translate(crest.left, crest.top);
        EmblemGeometry.fit(canvas, crest.size, EmblemGeometry.tightBounds);
        EmblemGeometry.paint(canvas, scene.banner.withValues(alpha: 0.62));
        canvas.restore();
      case Sigil.sun:
        const o = Offset(50, 50);
        canvas.drawArc(
          Rect.fromCircle(center: o, radius: 25),
          math.pi,
          math.pi,
          false,
          stroke,
        );
        for (var i = 0; i < 9; i++) {
          final a = math.pi + math.pi * (i + 0.5) / 9;
          final long = i.isEven;
          final d = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(o + d * 30, o + d * (long ? 41 : 36.5), stroke);
        }
      case Sigil.path:
        // A route on a map: it winds up from behind the shoulder, over
        // the head and ends at a waypoint.
        final route = Path()
          ..moveTo(9, 64)
          ..cubicTo(19, 58, 11, 46, 16, 35)
          ..cubicTo(21, 23, 34, 13, 50, 9.5)
          ..cubicTo(63, 7, 71, 13, 77.5, 21.5);
        final dash = _line(c, w(1.5, 1.0));
        for (final metric in route.computeMetrics()) {
          for (var d = 0.0; d < metric.length; d += 4.6) {
            canvas.drawPath(metric.extractPath(d, d + 2.4), dash);
          }
        }
        canvas.drawCircle(const Offset(9, 64), 1.3, _fill(c));
        canvas.drawCircle(const Offset(80, 24.5), 3.2, stroke);
        canvas.drawCircle(const Offset(80, 24.5), 1.3, _fill(c));
      case Sigil.compass:
        const o = Offset(50, 42);
        canvas.drawCircle(o, 27, stroke);
        for (var i = 0; i < 8; i++) {
          final a = -math.pi / 2 + i * math.pi / 4;
          final r = i.isEven ? 40.0 : 31.0;
          final half = i.isEven ? 3.6 : 2.6;
          final d = Offset(math.cos(a), math.sin(a));
          final n = Offset(-d.dy, d.dx);
          final tip = o + d * r;
          final base = o + d * 14;
          final kite = Path()
            ..moveTo(base.dx, base.dy)
            ..lineTo(base.dx + n.dx * half, base.dy + n.dy * half)
            ..lineTo(tip.dx, tip.dy)
            ..lineTo(base.dx - n.dx * half, base.dy - n.dy * half)
            ..close();
          canvas.drawPath(kite, stroke);
          final halfKite = Path()
            ..moveTo(base.dx, base.dy)
            ..lineTo(base.dx + n.dx * half, base.dy + n.dy * half)
            ..lineTo(tip.dx, tip.dy)
            ..close();
          canvas.drawPath(halfKite, _fill(c));
        }
      case Sigil.star:
        _star(const Offset(77, 23), 12, 2.8, c);
        _star(const Offset(22, 26), 5.5, 1.4, c);
        canvas.drawCircle(const Offset(86, 44), 1.1, _fill(c));
        canvas.drawCircle(const Offset(14, 44), 0.9, _fill(c));
        canvas.drawCircle(const Offset(62, 9), 0.9, _fill(c));
      case Sigil.laurel:
        for (final side in [-1.0, 1.0]) {
          _laurelBranch(
            centre: _centre,
            radius: 41,
            from: side < 0 ? 118 : 62,
            to: side < 0 ? 208 : -28,
            leaf: 6.4,
            color: c,
          );
        }
    }
  }

  void _star(Offset o, double r, double inner, Color c) {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final rr = i.isEven ? r : inner;
      final pt = o + Offset(math.cos(a), math.sin(a)) * rr;
      if (i == 0) {
        p.moveTo(pt.dx, pt.dy);
      } else {
        p.lineTo(pt.dx, pt.dy);
      }
    }
    p.close();
    canvas.drawPath(p, _fill(c));
  }

  /// A laurel branch along a circle from angle [from] to [to] (degrees,
  /// clockwise from +x), leaves pointing towards [to].
  void _laurelBranch({
    required Offset centre,
    required double radius,
    required double from,
    required double to,
    required double leaf,
    required Color color,
    Color? rib,
  }) {
    final a0 = from * math.pi / 180;
    final a1 = to * math.pi / 180;
    Offset at(double t) {
      final a = a0 + (a1 - a0) * t;
      return centre + Offset(math.cos(a), math.sin(a)) * radius;
    }

    final stem = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i <= 24; i++) {
      final p = at(i / 24);
      stem.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(stem, _line(color, w(leaf * 0.16, 0.8)));
    const count = 6;
    for (var i = 0; i < count; i++) {
      final t = 0.08 + i * (0.86 / (count - 1));
      final p = at(t);
      final q = at(t + 0.02);
      final dir = math.atan2(q.dy - p.dy, q.dx - p.dx);
      for (final s in [-1.0, 1.0]) {
        if (i == count - 1 && s > 0) continue;
        _leaf(p, dir + s * 0.62, leaf * (0.78 + 0.22 * (1 - t)), color, rib);
      }
    }
    final tip = at(1);
    _leaf(
      tip,
      math.atan2(tip.dy - at(0.97).dy, tip.dx - at(0.97).dx),
      leaf * 0.8,
      color,
      rib,
    );
  }

  /// An almond leaf growing from [base] in direction [angle].
  void _leaf(Offset base, double angle, double length, Color c, Color? rib) {
    final d = Offset(math.cos(angle), math.sin(angle));
    final n = Offset(-d.dy, d.dx) * (length * 0.24);
    final tip = base + d * length;
    final mid = base + d * (length * 0.5);
    final p = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(mid.dx + n.dx * 2, mid.dy + n.dy * 2, tip.dx, tip.dy)
      ..quadraticBezierTo(
        mid.dx - n.dx * 2,
        mid.dy - n.dy * 2,
        base.dx,
        base.dy,
      )
      ..close();
    canvas.drawPath(p, _fill(c));
    if (rib != null && !tiny) {
      canvas.drawLine(
        base + d * (length * 0.15),
        base + d * (length * 0.8),
        _line(rib, w(0.35, 0.5)),
      );
    }
  }

  // ── Body ──────────────────────────────────────────────────────────────

  void _body() {
    final skin = look.skin;
    final neck = head.neck;
    canvas.drawPath(neck, _fill(skin.base));
    clipped(neck, () {
      canvas.drawPath(head.face.shift(const Offset(0, 2.8)), _fill(skin.shade));
    });
    final g = look.garment;
    switch (avatar.garment) {
      case Garment.tunic:
        final body = _torso(_uNeck);
        canvas.drawPath(body, _fill(g.base));
        _shadeTorso(body, g.shade);
        canvas.drawPath(_uNeckLine, _line(g.trim, w(1.7, 1.0)));
        if (!tiny) {
          sym(
            Path()
              ..moveTo(23.5, 84)
              ..quadraticBezierTo(25.5, 90, 25, 98),
            _line(g.shade, w(0.9, 0.8)),
          );
        }
      case Garment.cloak:
        final under = _torso(_uNeck);
        canvas.drawPath(under, _fill(g.under));
        canvas.drawPath(_uNeckLine, _line(g.underShade, w(1.2, 0.8)));
        final panel = Path()
          ..moveTo(42.2, 65.6)
          ..cubicTo(37.5, 68.2, 30.5, 68.8, 23.8, 71.6)
          ..cubicTo(15.5, 75.4, 11.2, 82.6, 10.2, 94)
          ..lineTo(9.8, 104)
          ..lineTo(38.6, 104)
          ..cubicTo(39.6, 92, 41.4, 78, 44.2, 68.6)
          ..close();
        sym(panel, _fill(g.base));
        clipped(panel, () {
          canvas.drawPath(
            Path()
              ..moveTo(44.2, 68.6)
              ..cubicTo(41.4, 78, 39.6, 92, 38.6, 104)
              ..lineTo(33, 104)
              ..cubicTo(34.6, 92, 36.8, 80, 40, 70)
              ..close(),
            _fill(g.shade),
          );
        });
        clipped(_mirrored(panel), () {
          canvas.drawPath(
            Path()
              ..moveTo(88, 76)
              ..cubicTo(80, 82, 74, 92, 72, 104)
              ..lineTo(92, 104)
              ..close(),
            _fill(g.shade),
          );
        });
        if (!tiny) {
          final edge = Path()
            ..moveTo(44.2, 68.6)
            ..cubicTo(41.4, 78, 39.6, 92, 38.6, 104);
          sym(edge, _line(g.trim, w(1.1, 0.8)));
        }
        _brooch(const Offset(43.2, 72.2));
      case Garment.robe:
        final body = _torso(
          (p) => p
            ..lineTo(50, 81)
            ..lineTo(57.6, 66.4),
        );
        canvas.drawPath(body, _fill(g.base));
        _shadeTorso(body, g.shade);
        final band = _line(g.trim, w(3.0, 1.4), cap: StrokeCap.butt);
        canvas.drawLine(
          const Offset(56.2, 65.8),
          const Offset(49.6, 80.2),
          band,
        );
        canvas.drawLine(
          const Offset(43.8, 65.8),
          const Offset(53.4, 85.6),
          band,
        );
        if (!tiny) {
          final edge = _line(g.shade, w(0.6, 0.6), cap: StrokeCap.butt);
          canvas.drawLine(
            const Offset(45.2, 65.2),
            const Offset(54.6, 84.6),
            edge,
          );
          sym(
            Path()
              ..moveTo(24, 84)
              ..quadraticBezierTo(26, 90, 25.6, 98),
            _line(g.shade, w(0.9, 0.8)),
          );
        }
      case Garment.wrap:
        final under = _torso(_uNeck);
        canvas.drawPath(under, _fill(g.under));
        _shadeTorso(under, g.underShade);
        canvas.drawPath(_uNeckLine, _line(g.underShade, w(1.2, 0.8)));
        final drape = Path()
          ..moveTo(55.4, 65.8)
          ..cubicTo(61.5, 67.4, 70, 69, 76.8, 72)
          ..cubicTo(84.8, 76, 88.8, 83, 89.8, 94)
          ..lineTo(90.4, 104)
          ..lineTo(18, 104)
          ..cubicTo(30, 95, 46, 82, 55.4, 65.8)
          ..close();
        canvas.drawPath(drape, _fill(g.base));
        clipped(drape, () {
          canvas.drawPath(
            Path()
              ..moveTo(92, 78)
              ..cubicTo(82, 84, 76, 94, 74, 104)
              ..lineTo(94, 104)
              ..close(),
            _fill(g.shade),
          );
          if (!tiny) {
            final fold = _line(g.shade, w(1.0, 0.8));
            canvas.drawPath(
              Path()
                ..moveTo(64, 70.5)
                ..cubicTo(56, 82, 46, 92, 36, 104),
              fold,
            );
            canvas.drawPath(
              Path()
                ..moveTo(73, 74)
                ..cubicTo(66, 84, 58, 94, 52, 104),
              fold,
            );
          }
        });
        canvas.drawPath(
          Path()
            ..moveTo(55.4, 65.8)
            ..cubicTo(46, 82, 30, 95, 18, 104),
          _line(g.trim, w(1.5, 1.0)),
        );
    }
  }

  void _uNeck(Path p) => p.cubicTo(43.8, 72.8, 56.2, 72.8, 57.6, 66.4);

  Path get _uNeckLine => Path()
    ..moveTo(42.4, 66.4)
    ..cubicTo(43.8, 72.8, 56.2, 72.8, 57.6, 66.4);

  /// Shoulders and chest, from the left neck base round to the right one;
  /// [neckline] closes the path back to the left.
  Path _torso(void Function(Path p) neckline) {
    final p = Path()
      ..moveTo(57.6, 66.4)
      ..cubicTo(62, 69, 69, 69.6, 75.6, 72.4)
      ..cubicTo(83.6, 76, 87.6, 83, 88.6, 94)
      ..lineTo(89.2, 104)
      ..lineTo(10.8, 104)
      ..lineTo(11.4, 94)
      ..cubicTo(12.4, 83, 16.4, 76, 24.4, 72.4)
      ..cubicTo(31, 69.6, 38, 69, 42.4, 66.4);
    neckline(p);
    return p..close();
  }

  /// Light from the upper left: the far shoulder and arm sit in shade.
  void _shadeTorso(Path body, Color shade) {
    clipped(body, () {
      canvas.drawPath(
        Path()
          ..moveTo(92, 77)
          ..cubicTo(82, 82, 76, 92, 74, 104)
          ..lineTo(94, 104)
          ..close(),
        _fill(shade),
      );
    });
  }

  void _brooch(Offset o) {
    canvas.drawCircle(o, 2.3, _fill(look.metal));
    if (tiny) return;
    canvas.drawCircle(o, 1.25, _fill(look.metalShade));
    canvas.drawCircle(
      o + const Offset(-0.6, -0.6),
      0.5,
      _fill(look.metalShine),
    );
  }

  // ── Accessories ───────────────────────────────────────────────────────

  void _accessory() {
    switch (avatar.accessory) {
      case Accessory.none:
        return;
      case Accessory.satchel:
        final bag = RRect.fromLTRBR(
          53,
          87,
          75,
          106,
          const Radius.circular(2.6),
        );
        canvas.drawRRect(bag, _fill(look.leather));
        final flap = Path()
          ..moveTo(53, 89.6)
          ..quadraticBezierTo(53, 87, 55.6, 87)
          ..lineTo(72.4, 87)
          ..quadraticBezierTo(75, 87, 75, 89.6)
          ..lineTo(75, 94)
          ..quadraticBezierTo(64, 97.8, 53, 94)
          ..close();
        canvas.drawPath(flap, _fill(look.leatherShade));
        canvas.drawLine(
          const Offset(31.6, 70.2),
          const Offset(64.4, 87.6),
          _line(look.leather, w(3.2, 1.4), cap: StrokeCap.butt),
        );
        if (!tiny) {
          canvas.drawLine(
            const Offset(32.2, 70.0),
            const Offset(64.0, 86.9),
            _line(look.stitch, w(0.4, 0.5), cap: StrokeCap.butt),
          );
          canvas.save();
          canvas.translate(44.2, 76.9);
          canvas.rotate(0.488);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: 3.4, height: 4.2),
              const Radius.circular(0.6),
            ),
            _line(look.metal, w(0.8, 0.7)),
          );
          canvas.restore();
          canvas.drawCircle(const Offset(64, 95.8), 1.3, _fill(look.metal));
        }
      case Accessory.scroll:
        canvas.save();
        canvas.translate(35.4, 84.6);
        canvas.rotate(-0.52);
        const body = Rect.fromLTRB(-10, -3.1, 10, 3.1);
        canvas.drawRect(body, _fill(look.parchment));
        canvas.drawRect(
          const Rect.fromLTRB(-10, 1.4, 10, 3.1),
          _fill(look.parchmentShade),
        );
        for (final x in [-10.0, 10.0]) {
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, 0), width: 2.6, height: 6.2),
            _fill(look.parchmentShade),
          );
          if (!tiny) {
            canvas.drawCircle(Offset(x, 0), 0.7, _fill(look.parchment));
          }
        }
        canvas.drawRect(
          const Rect.fromLTRB(-1.6, -3.3, 1.6, 3.3),
          _fill(look.ribbon),
        );
        canvas.restore();
      case Accessory.compass:
        _cord(78.8);
        const o = Offset(50, 84.6);
        canvas.drawCircle(
          o + const Offset(0, -5.9),
          1.0,
          _line(look.metal, w(0.7, 0.7)),
        );
        canvas.drawCircle(o, 5.2, _fill(look.metal));
        canvas.drawCircle(o, 4.0, _fill(look.parchment));
        if (!tiny) {
          final tick = _line(look.metalShade, w(0.5, 0.5));
          for (var i = 0; i < 4; i++) {
            final a = i * math.pi / 2;
            final d = Offset(math.cos(a), math.sin(a));
            canvas.drawLine(o + d * 3.0, o + d * 3.8, tick);
          }
        }
        final north = Path()
          ..moveTo(o.dx, o.dy - 3.3)
          ..lineTo(o.dx + 1.0, o.dy)
          ..lineTo(o.dx - 1.0, o.dy)
          ..close();
        final south = Path()
          ..moveTo(o.dx, o.dy + 3.3)
          ..lineTo(o.dx + 1.0, o.dy)
          ..lineTo(o.dx - 1.0, o.dy)
          ..close();
        canvas.drawPath(north, _fill(look.ribbon));
        canvas.drawPath(south, _fill(look.ink));
        canvas.drawCircle(o, 0.6, _fill(look.metal));
      case Accessory.amulet:
        _cord(78.6);
        // The sign of Tanit: a disc, arms raised at the ends, a triangle.
        final m = _fill(look.metal);
        canvas.drawCircle(const Offset(50, 80.4), 2.0, m);
        canvas.drawPath(
          Path()
            ..moveTo(45.0, 81.2)
            ..lineTo(46.2, 81.2)
            ..lineTo(46.2, 82.4)
            ..lineTo(53.8, 82.4)
            ..lineTo(53.8, 81.2)
            ..lineTo(55.0, 81.2)
            ..lineTo(55.0, 83.7)
            ..lineTo(45.0, 83.7)
            ..close(),
          m,
        );
        canvas.drawPath(
          Path()
            ..moveTo(50, 83.0)
            ..lineTo(54.6, 91.0)
            ..lineTo(45.4, 91.0)
            ..close(),
          m,
        );
        if (!tiny) {
          canvas.drawPath(
            Path()
              ..moveTo(51.2, 85.6)
              ..lineTo(53.2, 89.6)
              ..lineTo(50.6, 89.6)
              ..close(),
            _fill(look.metalShade),
          );
          canvas.drawCircle(
            const Offset(49.4, 79.8),
            0.6,
            _fill(look.metalShine),
          );
        }
    }
  }

  void _cord(double bottom) {
    final cord = _line(look.leatherShade, w(0.7, 0.8));
    canvas.drawPath(
      Path()
        ..moveTo(44.6, 66.6)
        ..quadraticBezierTo(45.6, 75.5, 50, bottom)
        ..quadraticBezierTo(54.4, 75.5, 55.4, 66.6),
      cord,
    );
  }

  // ── Head ──────────────────────────────────────────────────────────────

  void _ears() {
    final y = head.eyeY + 2.2;
    for (final s in [-1.0, 1.0]) {
      final x = 50 + s * (head.w + 0.7);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 4.8, height: 8.2),
        _fill(look.skin.base),
      );
      if (!tiny) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x + s * 0.4, y + 0.2),
            width: 2.0,
            height: 4.6,
          ),
          _fill(look.skin.shade),
        );
      }
    }
  }

  void _face() {
    final face = head.face;
    canvas.drawPath(face, _fill(look.skin.base));
    if (!tiny) {
      clipped(face, () {
        canvas.drawPath(
          Path()
            ..fillType = PathFillType.evenOdd
            ..addRect(const Rect.fromLTRB(0, 0, 100, 100))
            ..addPath(face, const Offset(-1.5, -1.2)),
          _fill(look.skin.shade.withValues(alpha: 0.55)),
        );
      });
    }
    if (avatar.hair == HairStyle.bald &&
        avatar.headwear != Headwear.headscarf &&
        avatar.headwear != Headwear.turban &&
        !tiny) {
      inHeadSpace(() {
        canvas.drawArc(
          const Rect.fromLTRB(38.5, 24.5, 61.5, 52),
          math.pi * 1.16,
          math.pi * 0.24,
          false,
          _line(look.skinLight, w(1.5, 0.8)),
        );
      });
    }
  }

  void _marks() {
    if (look.mono) return;
    final h = head;
    final s = look.skin;
    switch (avatar.mark) {
      case SkinMark.none:
        return;
      case SkinMark.freckles:
        if (tiny) return;
        final c = Color.lerp(s.shade, look.ink, 0.3)!;
        final r = math.max(0.5, 0.5 / scale);
        const spots = [
          Offset(4.2, 3.8),
          Offset(6.4, 4.4),
          Offset(3.0, 5.4),
          Offset(5.2, 6.0),
          Offset(7.4, 6.2),
          Offset(8.2, 3.6),
          Offset(1.8, 3.4),
        ];
        final o = Offset(50, h.eyeY);
        for (final p in spots) {
          if (!fine && p.dx > 7.8) continue;
          canvas.drawCircle(o + p, r, _fill(c));
          canvas.drawCircle(o + Offset(-p.dx, p.dy + 0.3), r, _fill(c));
        }
      case SkinMark.beautyMark:
        if (tiny) return;
        canvas.drawCircle(
          Offset(50 + 4.6, h.mouthY - 2.4),
          math.max(0.6, 0.6 / scale),
          _fill(Color.lerp(s.shade, look.ink, 0.6)!),
        );
      case SkinMark.vitiligo:
        // Where vitiligo often shows: around an eye and the mouth, the
        // temple and the neck. Soft edges, never stark white.
        final paint = _fill(s.patch);
        if (!tiny) {
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
        }
        clipped(h.face, () {
          canvas.drawPath(
            _blob(Offset(50 - h.eyeDx - 0.8, h.eyeY - 0.2), 4.4, 3.4, 0),
            paint,
          );
          canvas.drawPath(
            _blob(Offset(50 + 3.4, h.mouthY + 0.9), 2.5, 1.9, 3),
            paint,
          );
          if (!tiny) {
            canvas.drawPath(
              _blob(Offset(50 + h.w - 1.2, h.browY - 1.2), 2.6, 3.2, 6),
              paint,
            );
          }
        });
        clipped(h.neck, () {
          canvas.drawPath(
            _blob(Offset(47.4, h.chinY + 4.2), 2.8, 2.4, 1),
            paint,
          );
        });
    }
  }

  /// A soft, irregular patch around [c].
  Path _blob(Offset c, double rx, double ry, int seed) {
    const wobble = [1.0, 0.7, 1.16, 0.84, 1.24, 0.76, 1.06, 0.9, 1.2, 0.8];
    const n = 10;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        c +
            Offset(
                  math.cos(i * 2 * math.pi / n) * rx,
                  math.sin(i * 2 * math.pi / n) * ry,
                ) *
                wobble[(i + seed) % n],
    ];
    final p = Path();
    Offset mid(Offset a, Offset b) => (a + b) / 2;
    final start = mid(pts.last, pts.first);
    p.moveTo(start.dx, start.dy);
    for (var i = 0; i < pts.length; i++) {
      final m = mid(pts[i], pts[(i + 1) % pts.length]);
      p.quadraticBezierTo(pts[i].dx, pts[i].dy, m.dx, m.dy);
    }
    return p..close();
  }

  void _features() {
    if (look.mono) return;
    final h = head;
    final ink = look.ink;
    final ex = h.eyeDx;
    final e = avatar.expression;

    // Brows.
    final brow = _line(
      Color.lerp(look.hair.base, ink, 0.35)!,
      w(1.15, tiny ? 0.8 : 0.9),
    );
    final (innerDy, outerDy, arch) = switch (e) {
      Expression.calm => (0.2, 0.4, 0.9),
      Expression.smile => (-0.3, 0.0, 1.3),
      Expression.focused => (0.55, 0.0, 0.5),
    };
    for (final s in [-1.0, 1.0]) {
      final x = 50 + s * ex;
      canvas.drawPath(
        Path()
          ..moveTo(50 + s * (ex - 2.4), h.browY + innerDy)
          ..quadraticBezierTo(
            x,
            h.browY - arch,
            50 + s * (ex + 2.6),
            h.browY + outerDy,
          ),
        brow,
      );
    }

    // Eyes.
    for (final s in [-1.0, 1.0]) {
      final x = 50 + s * ex;
      final y = h.eyeY;
      switch (e) {
        case Expression.calm:
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: 2.9, height: 3.4),
            _fill(ink),
          );
          if (!tiny) {
            canvas.drawCircle(
              Offset(x + 0.55, y - 0.7),
              0.5,
              _fill(look.catchlight),
            );
          }
        case Expression.smile:
          canvas.drawPath(
            Path()
              ..moveTo(x - 1.9, y + 0.6)
              ..quadraticBezierTo(x, y - 1.9, x + 1.9, y + 0.6),
            _line(ink, w(1.2, tiny ? 0.8 : 0.9)),
          );
        case Expression.focused:
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(x, y + 0.3),
              width: 2.9,
              height: 2.6,
            ),
            _fill(ink),
          );
          if (!tiny) {
            canvas.drawPath(
              Path()
                ..moveTo(x - 2.1, y - 0.9)
                ..quadraticBezierTo(x, y - 1.5, x + 2.1, y - 0.9),
              _line(ink, w(0.7, 0.6)),
            );
            canvas.drawCircle(
              Offset(x + 0.55, y - 0.2),
              0.45,
              _fill(look.catchlight),
            );
          }
      }
    }

    // Nose.
    if (!tiny) {
      canvas.drawPath(
        Path()
          ..moveTo(50 - 1.3, h.noseY - 0.6)
          ..quadraticBezierTo(50, h.noseY + 1.0, 50 + 1.3, h.noseY - 0.6),
        _line(look.skin.shade, w(1.0, 0.6)),
      );
    }

    // Mouth.
    final my = h.mouthY;
    final lip = _line(look.skin.lip, w(1.1, tiny ? 0.8 : 0.9));
    switch (e) {
      case Expression.calm:
        canvas.drawPath(
          Path()
            ..moveTo(50 - 2.6, my)
            ..quadraticBezierTo(50, my + 1.3, 50 + 2.6, my),
          lip,
        );
      case Expression.smile:
        canvas.drawPath(
          Path()
            ..moveTo(50 - 3.6, my - 0.5)
            ..quadraticBezierTo(50, my + 4.4, 50 + 3.6, my - 0.5)
            ..quadraticBezierTo(50, my + 0.7, 50 - 3.6, my - 0.5)
            ..close(),
          _fill(Color.lerp(look.skin.lip, ink, 0.4)!),
        );
        if (!tiny) {
          for (final s in [-1.0, 1.0]) {
            canvas.drawOval(
              Rect.fromCenter(
                center: Offset(50 + s * (ex + 1.0), h.eyeY + 5.0),
                width: 4.6,
                height: 2.4,
              ),
              _fill(look.skin.blush.withValues(alpha: 0.5)),
            );
          }
        }
      case Expression.focused:
        canvas.drawPath(
          Path()
            ..moveTo(50 - 2.2, my + 0.5)
            ..quadraticBezierTo(50, my + 0.1, 50 + 2.2, my + 0.5),
          lip,
        );
    }
  }

  void _facialHair() {
    final fh = avatar.facialHair;
    if (fh == FacialHair.none) return;
    final h = head;
    final c = look.hair;
    final my = h.mouthY;
    final mouth = Rect.fromCenter(
      center: Offset(50, my + 0.4),
      width: 7.4,
      height: 2.8,
    );
    switch (fh) {
      case FacialHair.none:
        return;
      case FacialHair.stubble:
        final region = Path()
          ..fillType = PathFillType.evenOdd
          ..moveTo(0, h.eyeY + 2.6)
          ..lineTo(50 - h.w + 2.0, h.eyeY + 2.6)
          ..cubicTo(
            50 - h.w + 3.4,
            my - 3,
            50 - 5,
            my - 3.4,
            50 - 3.2,
            my - 2.2,
          )
          ..quadraticBezierTo(50, my - 3.0, 50 + 3.2, my - 2.2)
          ..cubicTo(
            50 + 5,
            my - 3.4,
            50 + h.w - 3.4,
            my - 3,
            50 + h.w - 2.0,
            h.eyeY + 2.6,
          )
          ..lineTo(100, h.eyeY + 2.6)
          ..lineTo(100, 100)
          ..lineTo(0, 100)
          ..close()
          ..addOval(mouth);
        clipped(h.face, () {
          canvas.drawPath(
            region,
            _fill(c.base.withValues(alpha: look.mono ? 0.5 : 0.34)),
          );
        });
      case FacialHair.moustache:
        canvas.drawPath(_moustache(my), _fill(c.base));
      case FacialHair.beard:
        final region = Path()
          ..moveTo(0, h.eyeY + 1.8)
          ..lineTo(50 - h.w + 1.0, h.eyeY + 1.8)
          ..cubicTo(
            50 - h.w + 2.0,
            my - 1,
            50 - 6.4,
            my + 1.0,
            50 - 4.0,
            my + 1.8,
          )
          ..quadraticBezierTo(50, my + 3.0, 50 + 4.0, my + 1.8)
          ..cubicTo(
            50 + 6.4,
            my + 1.0,
            50 + h.w - 2.0,
            my - 1,
            50 + h.w - 1.0,
            h.eyeY + 1.8,
          )
          ..lineTo(100, h.eyeY + 1.8)
          ..lineTo(100, 100)
          ..lineTo(0, 100)
          ..close();
        final grown = h.face.transform(
          _scaleAbout(Offset(50, h.eyeY), 1.04, 1.07),
        );
        clipped(grown, () => canvas.drawPath(region, _fill(c.base)));
        if (!tiny) _beardTexture(h.chinY - 2.4);
        canvas.drawPath(_moustache(my), _fill(c.base));
      case FacialHair.fullBeard:
        final region = Path()
          ..fillType = PathFillType.evenOdd
          ..moveTo(0, h.eyeY + 1.4)
          ..lineTo(50 - h.w + 0.6, h.eyeY + 1.4)
          ..cubicTo(
            50 - h.w + 2.4,
            my - 3.2,
            50 - 6.6,
            my - 3.0,
            50 - 4.4,
            my - 1.6,
          )
          ..quadraticBezierTo(50, my - 2.2, 50 + 4.4, my - 1.6)
          ..cubicTo(
            50 + 6.6,
            my - 3.0,
            50 + h.w - 2.4,
            my - 3.2,
            50 + h.w - 0.6,
            h.eyeY + 1.4,
          )
          ..lineTo(100, h.eyeY + 1.4)
          ..lineTo(100, 100)
          ..lineTo(0, 100)
          ..close()
          ..addOval(mouth);
        final grown = Path.combine(
          PathOperation.union,
          h.face.transform(_scaleAbout(Offset(50, h.eyeY), 1.05, 1.06)),
          Path()..addOval(
            Rect.fromLTRB(
              50 - h.jawW - 0.8,
              h.jawY - 7,
              50 + h.jawW + 0.8,
              h.chinY + 8.6,
            ),
          ),
        );
        clipped(grown, () => canvas.drawPath(region, _fill(c.base)));
        if (!tiny) _beardTexture(h.chinY + 2.4);
        canvas.drawPath(_moustache(my), _fill(c.base));
    }
  }

  void _beardTexture(double y) {
    final t = _line(look.hair.shade, w(0.6, 0.6));
    for (final x in [-4.6, 0.0, 4.6]) {
      canvas.drawPath(
        Path()
          ..moveTo(50 + x - 0.6, y - 1.6)
          ..quadraticBezierTo(50 + x + 0.6, y, 50 + x, y + 1.6),
        t,
      );
    }
  }

  Path _moustache(double my) => Path()
    ..moveTo(50, my - 2.9)
    ..cubicTo(48, my - 3.4, 45.4, my - 2.6, 44.9, my + 0.4)
    ..cubicTo(46.4, my - 0.7, 48.2, my - 1.0, 50, my - 1.1)
    ..cubicTo(51.8, my - 1.0, 53.6, my - 0.7, 55.1, my + 0.4)
    ..cubicTo(54.6, my - 2.6, 52, my - 3.4, 50, my - 2.9)
    ..close();

  static Float64List _scaleAbout(Offset o, double sx, double sy) =>
      Float64List.fromList(<double>[
        sx, 0, 0, 0, //
        0, sy, 0, 0,
        0, 0, 1, 0,
        o.dx * (1 - sx), o.dy * (1 - sy), 0, 1,
      ]);

  void _glasses() {
    final kind = avatar.eyewear;
    if (kind == Eyewear.none) return;
    final h = head;
    final y = h.eyeY + 0.2;
    final ex = h.eyeDx;
    final frame = _line(look.frame, w(0.85, tiny ? 0.8 : 1.0));
    final half = kind == Eyewear.round ? 3.5 : 3.8;
    for (final s in [-1.0, 1.0]) {
      final x = 50 + s * ex;
      final c = Offset(x, y);
      final lens = kind == Eyewear.round
          ? (Path()..addOval(Rect.fromCircle(center: c, radius: 3.5)))
          : (Path()..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(center: c, width: 7.6, height: 6.0),
                const Radius.circular(1.4),
              ),
            ));
      if (!tiny && !look.mono) canvas.drawPath(lens, _fill(look.lens));
      canvas.drawPath(lens, frame);
      canvas.drawLine(
        Offset(x + s * half, y - 0.9),
        Offset(50 + s * (h.w - 0.1), y - 1.5),
        frame,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(50 - ex + half, y - 0.4)
        ..quadraticBezierTo(50, y - 1.9, 50 + ex - half, y - 0.4),
      frame,
    );
  }

  // ── Hair ──────────────────────────────────────────────────────────────

  /// The skull of the oval head, grown by [v] units of hair volume.
  static Rect _skull(double v) =>
      Rect.fromLTRB(35.4 - v, 21 - v, 64.6 + v, 60 + v);

  /// Everything above the hairline (oval head space). [part] is where the
  /// hairline peaks; [sweep] lifts its right side.
  static Path _scalp({
    double hairline = 31,
    double temple = 36.6,
    double sideburn = 44,
    double part = 50,
    double sweep = 0,
  }) => Path()
    ..moveTo(-10, -10)
    ..lineTo(110, -10)
    ..lineTo(110, sideburn)
    ..lineTo(62.8, sideburn)
    ..lineTo(62.3, temple)
    ..cubicTo(
      61.6,
      hairline + 2 - sweep,
      part + 6,
      hairline + 0.4 - sweep * 0.5,
      part,
      hairline,
    )
    ..cubicTo(part - 6, hairline + 0.4, 38.4, hairline + 2, 37.7, temple)
    ..lineTo(37.2, sideburn)
    ..lineTo(-10, sideburn)
    ..close();

  void _cap(double v, Path region, Color color) {
    clipped(Path()..addOval(_skull(v)), () {
      canvas.drawPath(region, _fill(color));
    });
  }

  void _shine(double v) {
    if (tiny) return;
    canvas.drawArc(
      _skull(v - 2.4),
      math.pi * 1.2,
      math.pi * 0.18,
      false,
      _line(look.hair.shine, w(1.3, 0.8)),
    );
  }

  static const _locsBack = [
    _Strand(Offset(33.4, 30), Offset(31.0, 52), Offset(32.0, 76)),
    _Strand(Offset(36.6, 28), Offset(34.6, 52), Offset(36.0, 79)),
  ];
  static const _locsFront = [
    _Strand(Offset(36.6, 33), Offset(31.6, 50), Offset(33.6, 74)),
    _Strand(Offset(34.6, 31), Offset(28.2, 48), Offset(29.6, 70)),
  ];
  static const _braidsBack = [
    _Strand(Offset(33.0, 30), Offset(31.4, 54), Offset(32.4, 80)),
    _Strand(Offset(35.4, 28), Offset(34.0, 54), Offset(35.2, 82)),
    _Strand(Offset(37.8, 27), Offset(36.8, 54), Offset(38.2, 83)),
  ];
  static const _braidsFront = [
    _Strand(Offset(37.0, 33), Offset(32.8, 50), Offset(34.8, 76)),
    _Strand(Offset(35.2, 31.5), Offset(30.0, 49), Offset(31.6, 74)),
    _Strand(Offset(33.6, 30), Offset(27.4, 48), Offset(28.4, 71)),
  ];

  void _strands(
    List<_Strand> strands,
    double width,
    Color color,
    Color detail, {
    required bool braid,
  }) {
    for (final base in strands) {
      for (final st in [base, base.mirrored]) {
        canvas.drawPath(st.path, _line(color, width));
        if (tiny) continue;
        final mark = _line(detail, w(braid ? 0.5 : 0.55, 0.5));
        final steps = braid ? 9 : 6;
        for (var i = 1; i < steps; i++) {
          final t = i / steps;
          final p = st.at(t);
          final q = st.at(t + 0.01);
          final d = (q - p) / (q - p).distance;
          final n = Offset(-d.dy, d.dx) * (width * 0.42);
          if (braid) {
            canvas.drawPath(
              Path()
                ..moveTo(p.dx - n.dx - d.dx, p.dy - n.dy - d.dy)
                ..lineTo(p.dx, p.dy)
                ..lineTo(p.dx + n.dx - d.dx, p.dy + n.dy - d.dy),
              mark,
            );
          } else {
            canvas.drawLine(p - n, p + n + d * 0.5, mark);
          }
        }
        if (braid) {
          final end = st.at(0.97);
          canvas.drawCircle(end, width * 0.55, _fill(look.metal));
        }
      }
    }
  }

  void _hairBehind() {
    final c = look.hair;
    inHeadSpace(() {
      switch (avatar.hair) {
        case HairStyle.wavy:
          canvas.drawPath(
            Path()
              ..moveTo(50, 21)
              ..cubicTo(37, 21, 31.6, 31, 31.4, 43)
              ..cubicTo(31.2, 50, 30.6, 54, 31.6, 58)
              ..quadraticBezierTo(33.4, 61.6, 36.6, 59.6)
              ..quadraticBezierTo(39.6, 62.2, 42.6, 59.8)
              ..lineTo(57.4, 59.8)
              ..quadraticBezierTo(60.4, 62.2, 63.4, 59.6)
              ..quadraticBezierTo(66.6, 61.6, 68.4, 58)
              ..cubicTo(69.4, 54, 68.8, 50, 68.6, 43)
              ..cubicTo(68.4, 31, 63, 21, 50, 21)
              ..close(),
            _fill(c.shade),
          );
        case HairStyle.curly:
          final m = _fill(c.base);
          canvas.drawOval(const Rect.fromLTRB(32, 19, 68, 56), m);
          for (var a = 150.0; a <= 390; a += 20) {
            final t = a * math.pi / 180;
            canvas.drawCircle(
              Offset(50 + 18.2 * math.cos(t), 37.5 + 19.2 * math.sin(t)),
              5.0,
              m,
            );
          }
          for (final o in const [Offset(32.6, 51), Offset(34.8, 56)]) {
            canvas.drawCircle(o, 4.2, m);
            canvas.drawCircle(Offset(100 - o.dx, o.dy), 4.2, m);
          }
          if (!tiny) {
            final t = _line(c.shade, w(0.8, 0.6));
            for (final o in const [
              Offset(36, 26),
              Offset(44, 18.5),
              Offset(56, 18.5),
              Offset(64, 26),
              Offset(31.5, 37),
              Offset(68.5, 37),
              Offset(31.8, 48),
              Offset(68.2, 48),
            ]) {
              canvas.drawArc(
                Rect.fromCircle(center: o, radius: 1.9),
                0.6,
                3.6,
                false,
                t,
              );
            }
          }
        case HairStyle.afro:
          final m = _fill(c.base);
          const o = Offset(50, 34);
          canvas.drawCircle(o, 21.6, m);
          for (var i = 0; i < 18; i++) {
            final t = 2 * math.pi * i / 18;
            canvas.drawCircle(
              o + Offset(math.cos(t), math.sin(t)) * 21.4,
              3.6,
              m,
            );
          }
          if (!tiny) {
            final t = _line(c.shade, w(0.8, 0.6));
            for (var i = 0; i < 12; i++) {
              final a = math.pi * (0.9 + 1.2 * i / 11);
              final p = o + Offset(math.cos(a), math.sin(a)) * 17.5;
              canvas.drawArc(
                Rect.fromCircle(center: p, radius: 1.7),
                a + 0.8,
                3.4,
                false,
                t,
              );
            }
          }
        case HairStyle.locs:
          canvas.drawPath(
            Path()
              ..moveTo(50, 21.5)
              ..cubicTo(37, 21.5, 32.6, 31, 32.6, 42)
              ..lineTo(33.2, 52)
              ..lineTo(66.8, 52)
              ..lineTo(67.4, 42)
              ..cubicTo(67.4, 31, 63, 21.5, 50, 21.5)
              ..close(),
            _fill(c.shade),
          );
          _strands(_locsBack, 3.6, c.shade, c.base, braid: false);
        case HairStyle.braids:
          canvas.drawPath(
            Path()
              ..moveTo(50, 21.5)
              ..cubicTo(37, 21.5, 32.6, 31, 32.6, 42)
              ..lineTo(33.2, 52)
              ..lineTo(66.8, 52)
              ..lineTo(67.4, 42)
              ..cubicTo(67.4, 31, 63, 21.5, 50, 21.5)
              ..close(),
            _fill(c.shade),
          );
          _strands(_braidsBack, 2.5, c.shade, c.base, braid: true);
        case HairStyle.long:
          canvas.drawPath(
            Path()
              ..moveTo(50, 21.5)
              ..cubicTo(36.5, 21.5, 31, 31.5, 31, 45)
              ..lineTo(30.4, 88)
              ..lineTo(69.6, 88)
              ..lineTo(69, 45)
              ..cubicTo(69, 31.5, 63.5, 21.5, 50, 21.5)
              ..close(),
            _fill(c.shade),
          );
        case HairStyle.ponytail:
          canvas.drawPath(
            Path()
              ..moveTo(58, 25.5)
              ..cubicTo(68.5, 24.5, 75, 31.5, 75.2, 42)
              ..cubicTo(75.3, 52, 72.6, 61, 68.2, 69.5)
              ..cubicTo(68.6, 61, 69.3, 51, 67.8, 43.5)
              ..cubicTo(66.8, 37.5, 64.2, 32.5, 59.6, 30)
              ..close(),
            _fill(c.base),
          );
          if (!tiny) {
            canvas.drawPath(
              Path()
                ..moveTo(70.5, 36)
                ..cubicTo(72.6, 44, 72, 54, 69.6, 63),
              _line(c.shade, w(0.8, 0.6)),
            );
          }
        case HairStyle.bald ||
            HairStyle.buzz ||
            HairStyle.short ||
            HairStyle.coily ||
            HairStyle.bun:
          return;
      }
    });
  }

  void _hairFront() {
    final c = look.hair;
    final base = c.base;
    inHeadSpace(() {
      switch (avatar.hair) {
        case HairStyle.bald:
          return;
        case HairStyle.buzz:
          _cap(
            0.5,
            _scalp(hairline: 31.4, temple: 37.4, sideburn: 42),
            Color.lerp(look.skin.base, base, look.mono ? 1 : 0.62)!,
          );
        case HairStyle.short:
          canvas.drawOval(const Rect.fromLTRB(37.4, 17.0, 55, 26), _fill(base));
          _cap(
            2.4,
            Path()
              ..moveTo(-10, -10)
              ..lineTo(110, -10)
              ..lineTo(110, 43.5)
              ..lineTo(62.8, 43.5)
              ..lineTo(62.4, 36.4)
              ..cubicTo(61.6, 31.4, 54, 32.4, 45.4, 29.2)
              ..cubicTo(41.4, 30.2, 38.6, 32.6, 37.7, 36.4)
              ..lineTo(37.2, 43.5)
              ..lineTo(-10, 43.5)
              ..close(),
            base,
          );
          if (!tiny) {
            final t = _line(c.shade, w(0.8, 0.6));
            canvas.drawPath(
              Path()
                ..moveTo(44.6, 22.4)
                ..quadraticBezierTo(53, 22.8, 59.6, 28),
              t,
            );
            if (fine) {
              canvas.drawPath(
                Path()
                  ..moveTo(46.4, 25.8)
                  ..quadraticBezierTo(54, 27, 60.8, 32.2),
                t,
              );
            }
          }
          _shine(2.4);
        case HairStyle.wavy:
          _cap(3.0, _scalp(hairline: 29.4, temple: 38, sideburn: 39), base);
          final side = Path()
            ..moveTo(39.6, 29.6)
            ..cubicTo(36.6, 35, 35.4, 43, 35.8, 50)
            ..cubicTo(36.1, 54, 37.0, 57, 38.0, 59.6)
            ..quadraticBezierTo(35.4, 60.8, 34.0, 58.2)
            ..quadraticBezierTo(31.6, 59.4, 31.2, 55.6)
            ..cubicTo(30.6, 49, 31.0, 40, 33.0, 33)
            ..cubicTo(34.4, 28.6, 37.2, 26.6, 39.6, 29.6)
            ..close();
          sym(side, _fill(base));
          if (!tiny) {
            final t = _line(c.shade, w(0.8, 0.6));
            sym(
              Path()
                ..moveTo(47, 24)
                ..cubicTo(40, 27, 36.4, 34, 34.6, 42)
                ..quadraticBezierTo(33.6, 48, 35.2, 52),
              t,
            );
          }
          _shine(3.0);
        case HairStyle.curly:
          _cap(1.0, _scalp(hairline: 31, temple: 36.8, sideburn: 41), base);
          for (var i = 0; i < 6; i++) {
            final x = 38.4 + i * 4.64;
            final y = 30.8 - 1.4 * math.sin(math.pi * i / 5);
            canvas.drawCircle(Offset(x, y), 3.0, _fill(base));
          }
          if (!tiny) {
            final t = _line(c.shade, w(0.7, 0.6));
            for (var i = 0; i < 5; i++) {
              final x = 40.7 + i * 4.64;
              canvas.drawArc(
                Rect.fromCircle(center: Offset(x, 31.6), radius: 1.5),
                0.2,
                2.8,
                false,
                t,
              );
            }
          }
        case HairStyle.coily:
          final region = _scalp(hairline: 31, temple: 37, sideburn: 41.5);
          final m = _fill(base);
          _cap(3.4, region, base);
          clipped(region, () {
            for (var a = 186.0; a <= 354; a += 12) {
              final t = a * math.pi / 180;
              canvas.drawCircle(
                Offset(50 + 17.6 * math.cos(t), 40.5 + 22.6 * math.sin(t)),
                2.4,
                m,
              );
            }
          });
          if (!tiny) {
            final t = _line(c.shade, w(0.55, 0.5));
            final r = fine ? 0.9 : 1.1;
            for (final o in const [
              Offset(41, 22),
              Offset(47, 19.6),
              Offset(53, 19.6),
              Offset(59, 22),
              Offset(38, 27.5),
              Offset(44, 25),
              Offset(50, 24.4),
              Offset(56, 25),
              Offset(62, 27.5),
              Offset(36, 33),
              Offset(64, 33),
            ]) {
              canvas.drawArc(
                Rect.fromCircle(center: o, radius: r),
                0.4,
                4.4,
                false,
                t,
              );
            }
          }
        case HairStyle.afro:
          _cap(0.8, _scalp(hairline: 30.4, temple: 36.6, sideburn: 42), base);
        case HairStyle.locs:
          _cap(
            2.2,
            _scalp(hairline: 30.6, temple: 37.2, sideburn: 40.5, part: 46),
            base,
          );
          _strands(_locsFront, 3.6, base, c.shade, braid: false);
          if (!tiny) {
            canvas.drawLine(
              const Offset(46, 30.6),
              const Offset(47.6, 20),
              _line(c.shade, w(0.7, 0.6)),
            );
          }
        case HairStyle.braids:
          _cap(1.4, _scalp(hairline: 30.8, temple: 37, sideburn: 40.5), base);
          if (!tiny) {
            final t = _line(c.shade, w(0.6, 0.5));
            for (final x in [-8.0, -4.0, 0.0, 4.0, 8.0]) {
              canvas.drawPath(
                Path()
                  ..moveTo(50 + x * 1.1, 31.4 - (x.abs() * 0.1))
                  ..quadraticBezierTo(50 + x * 1.2, 24, 50 + x * 0.6, 19.6),
                t,
              );
            }
          }
          _strands(_braidsFront, 2.5, base, c.shade, braid: true);
        case HairStyle.bun:
          canvas.drawCircle(const Offset(50, 16.8), 6.0, _fill(base));
          if (!tiny) {
            final t = _line(c.shade, w(0.8, 0.6));
            canvas.drawArc(
              Rect.fromCircle(center: const Offset(50, 16.8), radius: 3.4),
              math.pi * 0.85,
              math.pi * 0.9,
              false,
              t,
            );
          }
          _cap(1.4, _scalp(hairline: 30.8, temple: 36.9, sideburn: 41.6), base);
          if (!tiny) {
            canvas.drawArc(
              Rect.fromCircle(center: const Offset(50, 24.6), radius: 4.2),
              math.pi * 1.15,
              math.pi * 0.7,
              false,
              _line(c.shade, w(0.8, 0.6)),
            );
          }
          if (fine) {
            final t = _line(c.shade, w(0.6, 0.5));
            sym(
              Path()
                ..moveTo(42.4, 30.6)
                ..quadraticBezierTo(43.2, 25, 46.6, 21.6),
              t,
            );
          }
          _shine(1.4);
        case HairStyle.long:
          _cap(
            2.6,
            _scalp(hairline: 29.8, temple: 38.4, sideburn: 40, part: 47.6),
            base,
          );
          final side = Path()
            ..moveTo(40.4, 28.6)
            ..cubicTo(37, 34, 35.6, 43, 35.9, 51)
            ..cubicTo(36.2, 59, 38.0, 66, 39.0, 72)
            ..cubicTo(39.6, 76, 38.8, 79, 37.2, 81.4)
            ..cubicTo(34.6, 79.6, 31.8, 78.4, 30.6, 76)
            ..cubicTo(31.0, 66, 30.8, 52, 31.3, 44)
            ..cubicTo(31.8, 34, 35.4, 27.4, 40.4, 28.6)
            ..close();
          sym(side, _fill(base));
          if (!tiny) {
            final t = _line(c.shade, w(0.7, 0.6));
            sym(
              Path()
                ..moveTo(36.4, 34)
                ..cubicTo(33.8, 46, 34.2, 62, 35.6, 76),
              t,
            );
            if (fine) {
              canvas.drawPath(
                Path()
                  ..moveTo(47.6, 30)
                  ..quadraticBezierTo(47.2, 24, 49.6, 19.6),
                t,
              );
            }
          }
          _shine(2.6);
        case HairStyle.ponytail:
          _cap(
            1.6,
            _scalp(
              hairline: 30.6,
              temple: 36.8,
              sideburn: 42,
              part: 47,
              sweep: 0.8,
            ),
            base,
          );
          if (!tiny) {
            canvas.save();
            canvas.translate(65.6, 30.4);
            canvas.rotate(0.62);
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset.zero, width: 2.2, height: 3.8),
                const Radius.circular(0.8),
              ),
              _fill(c.shade),
            );
            canvas.restore();
            if (fine) {
              final t = _line(c.shade, w(0.6, 0.5));
              canvas.drawPath(
                Path()
                  ..moveTo(43, 30.4)
                  ..quadraticBezierTo(52, 23.4, 63.4, 28.4),
                t,
              );
            }
          }
          _shine(1.6);
      }
    });
  }

  // ── Headwear ──────────────────────────────────────────────────────────

  void _headwear() {
    final g = look.garment;
    final h = head;
    switch (avatar.headwear) {
      case Headwear.none:
        return;
      case Headwear.headscarf:
        final w0 = h.w + 5.2;
        final opening = Rect.fromLTRB(
          50 - (h.w - 1.4),
          h.top + 6.6,
          50 + (h.w - 1.4),
          h.chinY + 1.8,
        );
        final scarf = Path()
          ..fillType = PathFillType.evenOdd
          ..moveTo(50, h.top - 5.2)
          ..cubicTo(
            50 + w0 * 0.62,
            h.top - 5.2,
            50 + w0,
            h.top + 3,
            50 + w0,
            h.top + 17,
          )
          ..cubicTo(
            50 + w0,
            h.top + 29,
            50 + w0 - 1.6,
            h.chinY - 4,
            50 + w0 - 3.2,
            h.chinY + 0.4,
          )
          ..cubicTo(72, 68.6, 80.6, 71.6, 82.2, 77.6)
          ..cubicTo(83.4, 84, 70, 90.4, 50, 91)
          ..cubicTo(30, 90.4, 16.6, 84, 17.8, 77.6)
          ..cubicTo(19.4, 71.6, 28, 68.6, 50 - w0 + 3.2, h.chinY + 0.4)
          ..cubicTo(
            50 - w0 + 1.6,
            h.chinY - 4,
            50 - w0,
            h.top + 29,
            50 - w0,
            h.top + 17,
          )
          ..cubicTo(
            50 - w0,
            h.top + 3,
            50 - w0 * 0.62,
            h.top - 5.2,
            50,
            h.top - 5.2,
          )
          ..close()
          ..addOval(opening);
        canvas.drawPath(scarf, _fill(g.base));
        if (!tiny) {
          clipped(scarf, () {
            canvas.drawOval(opening.inflate(1.0), _line(g.shade, w(1.6, 0.8)));
            final fold = _line(g.shade, w(1.0, 0.7));
            canvas.drawPath(
              Path()
                ..moveTo(40, h.chinY + 2)
                ..cubicTo(46, 72, 56, 80, 64, 88),
              fold,
            );
            canvas.drawPath(
              Path()
                ..moveTo(50 + w0 - 2.2, h.top + 14)
                ..cubicTo(
                  50 + w0 - 1,
                  h.top + 26,
                  50 + w0 - 1.6,
                  h.chinY - 6,
                  50 + w0 - 3.6,
                  h.chinY - 1,
                ),
              fold,
            );
          });
        }
      case Headwear.turban:
        inHeadSpace(() {
          final turban = Path()
            ..moveTo(34.8, 39.4)
            ..cubicTo(32.6, 33, 32.2, 24.6, 36.4, 18.4)
            ..cubicTo(40, 13, 45, 10.6, 50, 10.6)
            ..cubicTo(55, 10.6, 60, 13, 63.6, 18.4)
            ..cubicTo(67.8, 24.6, 67.4, 33, 65.2, 39.4)
            ..cubicTo(61, 36, 55, 33.2, 50, 31.0)
            ..cubicTo(45, 33.2, 39, 36, 34.8, 39.4)
            ..close();
          canvas.drawPath(turban, _fill(g.base));
          clipped(turban, () {
            canvas.drawPath(
              Path()
                ..moveTo(30, 36)
                ..cubicTo(36, 33.6, 44, 30.6, 50, 28.4)
                ..cubicTo(56, 30.6, 64, 33.6, 70, 36)
                ..lineTo(70, 44)
                ..lineTo(30, 44)
                ..close(),
              _fill(g.shade),
            );
            if (!tiny) {
              final fold = _line(g.shade, w(1.0, 0.7));
              canvas.drawPath(
                Path()
                  ..moveTo(33.6, 29.4)
                  ..cubicTo(42, 25.6, 50, 20, 58.4, 12.4),
                fold,
              );
              canvas.drawPath(
                Path()
                  ..moveTo(66.4, 29.4)
                  ..cubicTo(58, 25.6, 52, 21.4, 46.6, 16.6),
                fold,
              );
              canvas.drawPath(
                Path()
                  ..moveTo(33, 22.4)
                  ..cubicTo(38, 19.6, 43, 16.4, 47.4, 12.2),
                fold,
              );
            }
          });
        });
      case Headwear.hood:
        final w0 = h.w + 7;
        final hood = Path()
          ..fillType = PathFillType.evenOdd
          ..moveTo(50, h.top - 9.4)
          ..cubicTo(
            50 + w0 * 0.66,
            h.top - 9,
            50 + w0,
            h.top + 1,
            50 + w0,
            h.top + 15,
          )
          ..cubicTo(
            50 + w0,
            h.top + 28,
            50 + w0 - 1,
            h.chinY - 4,
            50 + w0,
            h.chinY + 1.6,
          )
          ..cubicTo(78, 68, 86, 73, 88.6, 82)
          ..lineTo(90, 104)
          ..lineTo(10, 104)
          ..lineTo(11.4, 82)
          ..cubicTo(14, 73, 22, 68, 50 - w0, h.chinY + 1.6)
          ..cubicTo(
            50 - w0 + 1,
            h.chinY - 4,
            50 - w0,
            h.top + 28,
            50 - w0,
            h.top + 15,
          )
          ..cubicTo(
            50 - w0,
            h.top + 1,
            50 - w0 * 0.66,
            h.top - 9,
            50,
            h.top - 9.4,
          )
          ..close();
        final opening = Path()
          ..moveTo(50, h.top + 1.6)
          ..cubicTo(
            50 + h.w * 0.8,
            h.top + 1.6,
            50 + h.w + 2.2,
            h.top + 10,
            50 + h.w + 2.2,
            h.eyeY - 1,
          )
          ..cubicTo(
            50 + h.w + 2.2,
            h.jawY - 1,
            50 + h.w - 1,
            h.chinY - 2,
            50 + 9,
            h.chinY + 2.4,
          )
          ..lineTo(50 + 8.4, 104)
          ..lineTo(50 - 8.4, 104)
          ..lineTo(50 - 9, h.chinY + 2.4)
          ..cubicTo(
            50 - h.w + 1,
            h.chinY - 2,
            50 - h.w - 2.2,
            h.jawY - 1,
            50 - h.w - 2.2,
            h.eyeY - 1,
          )
          ..cubicTo(
            50 - h.w - 2.2,
            h.top + 10,
            50 - h.w * 0.8,
            h.top + 1.6,
            50,
            h.top + 1.6,
          )
          ..close();
        hood.addPath(opening, Offset.zero);
        canvas.drawPath(hood, _fill(g.base));
        clipped(hood, () {
          canvas.drawPath(opening, _line(g.shade, w(3.2, 1.2)));
          canvas.drawPath(
            Path()
              ..moveTo(92, 76)
              ..cubicTo(82, 82, 76, 92, 74, 104)
              ..lineTo(94, 104)
              ..close(),
            _fill(g.shade),
          );
          if (!tiny) {
            canvas.drawPath(
              Path()
                ..moveTo(50 - w0 + 3, h.top + 8)
                ..cubicTo(
                  50 - w0 + 1.4,
                  h.top + 20,
                  50 - w0 + 1.6,
                  h.chinY - 8,
                  50 - w0 + 3.4,
                  h.chinY,
                ),
              _line(g.shade, w(1.0, 0.7)),
            );
          }
        });
      case Headwear.circlet:
        inHeadSpace(() {
          clipped(Path()..addOval(_skull(2.2)), () {
            canvas.drawPath(
              Path()
                ..moveTo(32, 30.6)
                ..quadraticBezierTo(50, 37.6, 68, 30.6),
              _line(look.metal, w(1.5, 1.0), cap: StrokeCap.butt),
            );
          });
          const gem = Offset(50, 34.0);
          canvas.drawPath(
            Path()
              ..moveTo(gem.dx, gem.dy - 2.6)
              ..lineTo(gem.dx + 2.0, gem.dy)
              ..lineTo(gem.dx, gem.dy + 2.4)
              ..lineTo(gem.dx - 2.0, gem.dy)
              ..close(),
            _fill(look.metal),
          );
          if (!tiny) {
            canvas.drawCircle(gem, 0.9, _fill(look.ribbon));
            canvas.drawCircle(
              gem + const Offset(-0.3, -0.35),
              0.3,
              _fill(look.metalShine),
            );
          }
        });
      case Headwear.laurel:
        inHeadSpace(() {
          for (final side in [-1.0, 1.0]) {
            final from = side < 0 ? 168.0 : 12.0;
            final to = side < 0 ? 250.0 : -70.0;
            _laurelBranch(
              centre: const Offset(50, 41),
              radius: 17.4,
              from: from,
              to: to,
              leaf: tiny ? 5.0 : 4.6,
              color: look.metal,
              rib: look.metalShade,
            );
          }
        });
    }
  }
}
