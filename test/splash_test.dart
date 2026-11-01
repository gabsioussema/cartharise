import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// The Android 12+ splash (PLAN §3: native splash → BootScreen hand-off).
/// With `windowSplashScreenIconBackgroundColor` set, Android masks the icon
/// to a centred circle 2/3 of its size (radius = width / 3): every emblem
/// pixel must lie inside it, or the ear tips are clipped.

Future<ui.Image> _decode(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  return (await codec.getNextFrame()).image;
}

/// Distance from the centre of the farthest pixel that differs from the
/// background (the top-left corner colour), as a fraction of the width.
Future<double> _emblemRadius(String path) async {
  final image = await _decode(path);
  final bytes = (await image.toByteData())!;
  final w = image.width, h = image.height;
  int at(int x, int y, int c) => bytes.getUint8((y * w + x) * 4 + c);
  final bg = [for (var c = 0; c < 3; c++) at(2, 2, c)];
  var maxR = 0.0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      var diff = 0;
      for (var c = 0; c < 3; c++) {
        diff += (at(x, y, c) - bg[c]).abs();
      }
      if (diff < 30) continue;
      final r = math.sqrt(
        math.pow(x + 0.5 - w / 2, 2) + math.pow(y + 0.5 - h / 2, 2),
      );
      if (r > maxR) maxR = r;
    }
  }
  return maxR / w;
}

void main() {
  const mask = 1 / 3;

  test(
    'the full app icon would be clipped (why the splash has its own)',
    () async {
      final r = await _emblemRadius('assets/brand/app_icon_1024.png');
      expect(r, greaterThan(mask));
    },
  );

  for (final path in [
    'assets/brand/splash_android12.png',
    'android/app/src/main/res/drawable-xxxhdpi/android12splash.png',
    'android/app/src/main/res/drawable-night-xxxhdpi/android12splash.png',
    'android/app/src/main/res/drawable-mdpi/android12splash.png',
  ]) {
    test('the whole emblem fits the Android 12 mask: $path', () async {
      final r = await _emblemRadius(path);
      expect(r, lessThan(mask * 0.95), reason: 'emblem radius ${r * 100} %');
      // Not shrunk to a speck either.
      expect(r, greaterThan(mask * 0.75));
    });
  }

  test('pubspec points the Android 12 splash at the padded asset', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final section = pubspec.substring(pubspec.indexOf('  android_12:'));
    expect(
      section.substring(0, section.indexOf('icon_background_color')),
      contains('image: assets/brand/splash_android12.png'),
    );
  });
}
