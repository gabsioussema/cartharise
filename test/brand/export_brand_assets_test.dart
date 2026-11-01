// Writes the brand assets from EmblemGeometry (not CI):
//   flutter test --tags brand --run-skipped    (make brand)
// `make brand` then regenerates the launcher icons and native splash screens
// from the new PNGs. test/brand_test.dart checks the committed files.
@Tags(['brand'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/brand_assets.dart';

void main() {
  test('emblem.svg and loader_reference.svg', () {
    File('assets/brand/emblem.svg').writeAsStringSync(emblemSvg());
    File('assets/brand/loader_reference.svg').writeAsStringSync(loaderSvg());
  });

  test('the Android notification icon', () {
    File(notificationIconPath).writeAsStringSync(notificationIconXml());
  });

  test('the emblem in both lockups', () {
    for (final MapEntry(key: path, value: box) in lockupEmblemBoxes.entries) {
      File(path).writeAsStringSync(withLockupEmblem(readText(path), box));
    }
  });

  for (final tile in brandTiles) {
    test(tile.path, () async {
      File(tile.path).writeAsBytesSync(await tile.png());
    });
  }
}
