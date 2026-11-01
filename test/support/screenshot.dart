import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

/// Writes what [pumpCartha] shows to `test/screenshots/out/<name>.png` for
/// design review. Screenshot tests are tagged `screenshots` (skipped by
/// default, see dart_test.yaml):
///
///   flutter test --tags screenshots --run-skipped   (or: make screenshots)
///
/// Gives async work (SVG lockups, fonts) a moment to finish first.
Future<void> captureScreenshot(
  WidgetTester tester,
  String name, {
  double pixelRatio = 3,
}) async {
  for (var i = 0; i < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(kScreenshotKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File('test/screenshots/out/$name.png')
      ..createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
