import 'dart:io';

import 'package:cartharise/ui/widgets/emblem.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/brand_assets.dart';

/// The committed brand assets must follow from [EmblemGeometry]; after a
/// geometry change, `make brand` re-exports them.
void main() {
  const hint = 'stale brand asset: run `make brand`';

  test('emblem.svg is the EmblemGeometry emblem', () {
    expect(readText('assets/brand/emblem.svg'), emblemSvg(), reason: hint);
  });

  test('loader_reference.svg is the EmblemGeometry loader', () {
    expect(
      readText('assets/brand/loader_reference.svg'),
      loaderSvg(),
      reason: hint,
    );
  });

  test('the Android notification icon is the EmblemGeometry emblem', () {
    expect(readText(notificationIconPath), notificationIconXml(), reason: hint);
  });

  for (final MapEntry(key: path, value: box) in lockupEmblemBoxes.entries) {
    test('$path carries the EmblemGeometry emblem', () {
      expect(readText(path), contains(lockupEmblemBlock(box)), reason: hint);
    });
  }

  for (final tile in brandTiles) {
    test('${tile.path} is the EmblemGeometry tile', () async {
      final (width, actual) = await decodePng(
        File(tile.path).readAsBytesSync(),
      );
      final (_, expected) = await decodePng(await tile.png());
      expect(width, tile.size);
      expect(actual.lengthInBytes, expected.lengthInBytes);
      var differing = 0;
      for (var i = 0; i < actual.lengthInBytes; i += 4) {
        var diff = 0;
        for (var c = 0; c < 3; c++) {
          diff += (actual.getUint8(i + c) - expected.getUint8(i + c)).abs();
        }
        if (diff > 24) differing++;
      }
      // Anti-aliasing may differ by a hair between engine versions.
      expect(
        differing / (tile.size * tile.size),
        lessThan(0.002),
        reason: hint,
      );
    });
  }

  group('geometry', () {
    test(
      'the ink bounds are the rendered ones (mitred tips included)',
      () async {
        const k = 4;
        final (w, bytes) = await renderEmblem(k: k);
        var l = w, t = w, r = -1, b = -1;
        for (var y = 0; y < w; y++) {
          for (var x = 0; x < w; x++) {
            if (bytes.getUint8((y * w + x) * 4 + 3) > 127) {
              if (x < l) l = x;
              if (x > r) r = x;
              if (y < t) t = y;
              if (y > b) b = y;
            }
          }
        }
        final measured = Rect.fromLTRB(l / k, t / k, (r + 1) / k, (b + 1) / k);
        const bounds = EmblemGeometry.tightBounds;
        expect(measured.left, closeTo(bounds.left, 0.5));
        expect(measured.top, closeTo(bounds.top, 0.5));
        expect(measured.right, closeTo(bounds.right, 0.5));
        expect(measured.bottom, closeTo(bounds.bottom, 0.5));
      },
    );

    test('centred in the 512 tile', () {
      expect(EmblemGeometry.tightBounds.center, const Offset(256, 256));
    });

    test('the two halves mirror each other around x = 256', () {
      Rect mirrored(Rect r) =>
          Rect.fromLTRB(512 - r.right, r.top, 512 - r.left, r.bottom);
      void same(Rect a, Rect b) {
        expect(a.left, closeTo(b.left, 0.02));
        expect(a.top, closeTo(b.top, 0.02));
        expect(a.right, closeTo(b.right, 0.02));
        expect(a.bottom, closeTo(b.bottom, 0.02));
      }

      final lines = EmblemGeometry.lines.map((p) => p.getBounds()).toList();
      final fills = EmblemGeometry.fills.map((p) => p.getBounds()).toList();
      // The outline is one symmetric path; face and eye lines come in pairs.
      same(lines[0], mirrored(lines[0]));
      same(lines[1], mirrored(lines[2]));
      same(lines[3], mirrored(lines[4]));
      for (var i = 0; i < fills.length; i += 2) {
        same(fills[i], mirrored(fills[i + 1]));
      }
    });

    test('every taper reaches the full stroke width where its line starts', () {
      // Each stroked face / eye line starts (or ends) inside a taper; at that
      // point the taper must be as wide as the stroke, so there is no step.
      final ends = [
        for (final i in [1, 2, 3, 4]) _start(EmblemGeometry.lines[i]),
        for (final i in [3, 4]) _end(EmblemGeometry.lines[i]),
      ];
      for (final (point, direction) in ends) {
        final normal = Offset(-direction.dy, direction.dx);
        for (final side in [-1.0, 1.0]) {
          // Just inside the stroke edge, on both sides.
          final probe =
              point + normal * (side * (EmblemGeometry.strokeWidth / 2 - 0.6));
          expect(
            EmblemGeometry.fills.any((f) => f.contains(probe)),
            isTrue,
            reason: 'taper too narrow at $point',
          );
        }
      }
    });
  });
}

(Offset, Offset) _start(Path p) {
  final m = p.computeMetrics().first;
  final t = m.getTangentForOffset(0)!;
  return (t.position, t.vector);
}

(Offset, Offset) _end(Path p) {
  final m = p.computeMetrics().last;
  final t = m.getTangentForOffset(m.length)!;
  return (t.position, t.vector);
}
