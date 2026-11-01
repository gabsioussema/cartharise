import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/widgets/emblem.dart';
import 'package:flutter/painting.dart';

/// The brand assets as they follow from [EmblemGeometry]. Written by
/// `test/brand/export_brand_assets_test.dart` (`make brand`) and checked
/// against the committed files by `test/brand_test.dart`.

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

String _num(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(3);

/// The whole emblem (stroked lines + filled tapers) as one SVG group, in
/// [color] (a hex colour or `currentColor`).
String emblemGroup(String color, {String? transform, String? attributes}) {
  final t = transform == null ? '' : ' transform="$transform"';
  final a = attributes == null ? '' : ' $attributes';
  final lines = EmblemGeometry.lineData.map((d) => '<path d="$d"/>').join('\n');
  final fills = EmblemGeometry.fillData.map((d) => '<path d="$d"/>').join('\n');
  return '<g$t$a>'
      '<g fill="none" stroke="$color" '
      'stroke-width="${_num(EmblemGeometry.strokeWidth)}" '
      'stroke-linejoin="miter" '
      'stroke-miterlimit="${_num(EmblemGeometry.miterLimit)}" '
      'stroke-linecap="butt">\n$lines</g>'
      '<g fill="$color">\n$fills</g></g>';
}

/// `assets/brand/emblem.svg`: the bronze emblem in the 512 design space.
String emblemSvg() =>
    '<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" '
    'viewBox="0 0 512 512">${emblemGroup(_hex(CarthaColors.bronze))}</svg>\n';

/// Width of the emblem in a tile (app icons, loader tile): 70 %.
const double tileFill = 0.70;

/// SVG transform placing the emblem at [tileFill] of a 512 tile, centred.
String _tileTransform() {
  const b = EmblemGeometry.tightBounds;
  final s = tileFill * 512 / b.width;
  return 'translate(${_num(256 - b.center.dx * s)} ${_num(256 - b.center.dy * s)}) '
      'scale(${_num(s)})';
}

/// `assets/brand/loader_reference.svg`: the board's "charging" tile that
/// `CarthaLoader` rebuilds (same keyframes; its CSS animation plays in
/// browsers only). Static and fully charged with reduced motion.
String loaderSvg() {
  final warm = Color.lerp(CarthaColors.lightBronze, CarthaColors.ivory, 0.35)!;
  final base = _hex(CarthaColors.lightBronze);
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" '
      'width="512" height="512">\n'
      '<rect width="512" height="512" rx="110" fill="${_hex(CarthaColors.forest)}"/>\n'
      '<defs><filter id="halo" x="-25%" y="-40%" width="150%" height="180%">'
      '<feGaussianBlur stdDeviation="14"/></filter></defs>\n'
      '<style>\n'
      '@keyframes charge{0%,8%{opacity:.28;color:$base}55%{opacity:1;color:$base}70%,80%{color:${_hex(warm)}}88%{opacity:1;color:$base}100%{opacity:.28;color:$base}}\n'
      '@keyframes glow{0%,55%{opacity:0}70%,80%{opacity:.55}88%,100%{opacity:0}}\n'
      '.emblem{color:$base;animation:charge 3.2s ease-in-out infinite}\n'
      '.halo{opacity:0;filter:url(#halo);animation:glow 3.2s ease-in-out infinite}\n'
      '@media (prefers-reduced-motion:reduce){.emblem{animation:none;opacity:1}.halo{animation:none;opacity:0}}\n'
      '</style>\n'
      '<g class="emblem" transform="${_tileTransform()}">'
      '${emblemGroup(_hex(CarthaColors.ivory), attributes: 'class="halo"')}\n'
      '${emblemGroup('currentColor')}</g>\n'
      '</svg>\n';
}

/// The Android status-bar icon for check-in reminders: the emblem as a
/// single-colour vector drawable (Android tints it), filling a 24 dp square.
const String notificationIconPath =
    'android/app/src/main/res/drawable/ic_stat_cartharise.xml';

String notificationIconXml() {
  const b = EmblemGeometry.tightBounds;
  const side = 330.0;
  final shift = _num(side / 2 - b.center.dx);
  final shiftY = _num(side / 2 - b.center.dy);
  final lines = EmblemGeometry.lineData.map(
    (d) =>
        '        <path\n'
        '            android:pathData="$d"\n'
        '            android:strokeColor="#FFFFFFFF" '
        'android:strokeWidth="${_num(EmblemGeometry.strokeWidth)}"\n'
        '            android:strokeLineJoin="miter" '
        'android:strokeMiterLimit="${_num(EmblemGeometry.miterLimit)}"\n'
        '            android:strokeLineCap="butt" />\n',
  );
  final fills = EmblemGeometry.fillData.map(
    (d) =>
        '        <path\n'
        '            android:pathData="$d"\n'
        '            android:fillColor="#FFFFFFFF" />\n',
  );
  return '<?xml version="1.0" encoding="utf-8"?>\n'
      '<!-- Status-bar icon for check-in reminders: the Cartharise emblem as a\n'
      '     single-colour vector (Android tints it). Exported from\n'
      '     EmblemGeometry by `make brand`; do not edit by hand. -->\n'
      '<vector xmlns:android="http://schemas.android.com/apk/res/android"\n'
      '    android:width="24dp"\n'
      '    android:height="24dp"\n'
      '    android:viewportWidth="${_num(side)}"\n'
      '    android:viewportHeight="${_num(side)}">\n'
      '    <group android:translateX="$shift" android:translateY="$shiftY">\n'
      '${lines.join()}${fills.join()}'
      '    </group>\n'
      '</vector>\n';
}

/// Where the emblem sits in each lockup (its ink box in the SVG's own
/// coordinates); the lettering and tagline around it are fixed artwork.
const Map<String, Rect> lockupEmblemBoxes = {
  'assets/brand/wordmark_horizontal.svg': Rect.fromLTRB(
    42.64,
    63.07,
    322,
    242.52,
  ),
  'assets/brand/wordmark_stacked.svg': Rect.fromLTRB(
    228.32,
    196.16,
    620,
    447.76,
  ),
};

const _open = '<!-- emblem -->';
const _close = '<!-- /emblem -->';

/// The emblem block of a lockup: [EmblemGeometry.tightBounds] fitted
/// (contain, centred) into [box], in bronze so `BrandSvgColorMapper` can
/// re-tint it.
String lockupEmblemBlock(Rect box) {
  const b = EmblemGeometry.tightBounds;
  final s = math.min(box.width / b.width, box.height / b.height);
  final tx = box.center.dx - b.center.dx * s;
  final ty = box.center.dy - b.center.dy * s;
  return '$_open${emblemGroup(_hex(CarthaColors.bronze), transform: 'translate(${_num(tx)} ${_num(ty)}) scale(${_num(s)})')}$_close';
}

/// [svg] with its emblem block replaced by [lockupEmblemBlock].
String withLockupEmblem(String svg, Rect box) {
  final start = svg.indexOf(_open);
  final end = svg.indexOf(_close);
  if (start < 0 || end < start) {
    throw const FormatException('Lockup has no <!-- emblem --> block');
  }
  return svg.substring(0, start) +
      lockupEmblemBlock(box) +
      svg.substring(end + _close.length);
}

/// A square PNG tile: [background] with the emblem in [ink], centred on its
/// ink bounds and scaled so it is [width] of the tile wide, or so its
/// farthest pixel is [radius] of the tile from the centre.
class BrandTile {
  const BrandTile(
    this.path,
    this.size,
    this.background,
    this.ink, {
    this.width,
    this.radius,
  }) : assert((width == null) != (radius == null));

  final String path;
  final int size;
  final Color background;
  final Color ink;
  final double? width;
  final double? radius;

  Future<ui.Image> render() async {
    const b = EmblemGeometry.tightBounds;
    final scale = width != null
        ? width! * size / b.width
        : radius! * size / await emblemRadius();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..drawRect(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Paint()..color = background,
      )
      ..translate(size / 2, size / 2)
      ..scale(scale)
      ..translate(-b.center.dx, -b.center.dy);
    EmblemGeometry.paint(canvas, ink);
    return recorder.endRecording().toImage(size, size);
  }

  Future<Uint8List> png() async {
    final image = await render();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
}

/// Renders the emblem at [k] pixels per design unit; returns the image
/// width and its RGBA bytes.
Future<(int, ByteData)> renderEmblem({int k = 2}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(k.toDouble());
  EmblemGeometry.paint(canvas, const Color(0xFF000000));
  final image = await recorder.endRecording().toImage(512 * k, 512 * k);
  return (512 * k, (await image.toByteData())!);
}

/// Farthest ink pixel from the centre of [EmblemGeometry.tightBounds], in
/// design units (mitred tips included).
Future<double> emblemRadius() async {
  const k = 2;
  final (w, bytes) = await renderEmblem(k: k);
  final c = EmblemGeometry.tightBounds.center * k.toDouble();
  var r = 0.0;
  for (var y = 0; y < w; y++) {
    for (var x = 0; x < w; x++) {
      if (bytes.getUint8((y * w + x) * 4 + 3) > 127) {
        r = math.max(r, (Offset(x + 0.5, y + 0.5) - c).distance);
      }
    }
  }
  return r / k;
}

/// Launcher icon source, Appearance tiles and the Android 12 splash icon
/// (which Android masks to a circle a third of its width in radius).
const List<BrandTile> brandTiles = [
  BrandTile(
    'assets/brand/app_icon_1024.png',
    1024,
    CarthaColors.forest,
    CarthaColors.lightBronze,
    width: tileFill,
  ),
  BrandTile(
    'assets/brand/app_icon_forest.png',
    512,
    CarthaColors.forest,
    CarthaColors.lightBronze,
    width: tileFill,
  ),
  BrandTile(
    'assets/brand/app_icon_olive.png',
    512,
    CarthaColors.olive,
    CarthaColors.ivory,
    width: tileFill,
  ),
  BrandTile(
    'assets/brand/app_icon_light.png',
    512,
    CarthaColors.ivory,
    CarthaColors.forest,
    width: tileFill,
  ),
  BrandTile(
    'assets/brand/splash_android12.png',
    960,
    CarthaColors.forest,
    CarthaColors.lightBronze,
    radius: 0.30,
  ),
];

/// Decodes a PNG file to raw RGBA.
Future<(int, ByteData)> decodePng(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final image = (await codec.getNextFrame()).image;
  return (image.width, (await image.toByteData())!);
}

/// Reads [path] relative to the package root.
String readText(String path) => File(path).readAsStringSync();
