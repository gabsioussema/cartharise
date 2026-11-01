import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/widgets/emblem.dart';
import 'package:cartharise/ui/widgets/loader.dart';
import 'package:cartharise/ui/widgets/wordmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

Widget _host({bool disableAnimations = false}) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: disableAnimations),
    child: const Scaffold(
      body: Center(child: CarthaLoader(size: 120, tile: true)),
    ),
  ),
);

bool _animating(WidgetTester tester) =>
    isLoaderAnimating(tester.state(find.byType(CarthaLoader)));

void main() {
  group('charging keyframes (loader_reference.svg)', () {
    test('charge: dim at 0–8 %, full by 55 %, held to 88 %, dim by 100 %', () {
      expect(loaderFrameAt(0).charge, 0);
      expect(loaderFrameAt(0.0799).charge, 0);
      expect(loaderFrameAt(0.315).charge, closeTo(0.5, 1e-6));
      expect(loaderFrameAt(0.55).charge, 1);
      expect(loaderFrameAt(0.80).charge, 1);
      expect(loaderFrameAt(0.94).charge, closeTo(0.5, 1e-6));
      expect(loaderFrameAt(0.99999).charge, closeTo(0, 1e-3));
      // Ease-in-out: slow start.
      expect(loaderFrameAt(0.12).charge, lessThan((0.12 - 0.08) / 0.47));
    });

    test('opacity follows the charge: .28 when empty, 1 when charged', () {
      expect(loaderFrameAt(0.04).opacity, closeTo(0.28, 1e-9));
      expect(loaderFrameAt(0.60).opacity, 1);
      expect(loaderFrameAt(0.999999).opacity, closeTo(0.28, 1e-3));
    });

    test('glow blooms only once fully charged: 55→70 %, held to 80 %', () {
      expect(loaderFrameAt(0.30).glow, 0);
      expect(loaderFrameAt(0.55).glow, 0);
      expect(loaderFrameAt(0.625).glow, closeTo(0.5, 1e-6));
      expect(loaderFrameAt(0.75).glow, 1);
      expect(loaderFrameAt(0.80).glow, 1);
      expect(loaderFrameAt(0.88).glow, 0);
      // Never a halo around a half-charged emblem.
      for (var t = 0.0; t < 1; t += 0.01) {
        final f = loaderFrameAt(t);
        if (f.glow > 0) expect(f.charge, 1, reason: 't = $t');
      }
    });

    test('cycle is 3.2 s and repeats', () {
      expect(kLoaderCycle, const Duration(milliseconds: 3200));
      expect(
        loaderFrameAt(1.315).charge,
        closeTo(loaderFrameAt(0.315).charge, 1e-9),
      );
    });

    test('the still frame is the fully charged emblem without a halo', () {
      expect(LoaderFrame.still.charge, 1);
      expect(LoaderFrame.still.opacity, 1);
      expect(LoaderFrame.still.glow, 0);
    });

    test('starting at 0.6 is fully charged (seamless after the splash)', () {
      expect(loaderFrameAt(0.6).charge, 1);
    });

    // emblem.svg / loader_reference.svg equality: test/brand_test.dart.
    test('emblem geometry: five lines and six tapers', () {
      expect(EmblemGeometry.lines, hasLength(5));
      expect(EmblemGeometry.fills, hasLength(6));
    });
  });

  group('CarthaLoader widget', () {
    testWidgets('animates normally and is labelled "Loading"', (tester) async {
      await pumpCartha(tester, data: onboardedData(), home: _host());
      expect(_animating(tester), isTrue);
      await tester.pump(const Duration(seconds: 5));
      expect(_animating(tester), isTrue);
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    });

    testWidgets('static when the device asks for reduced motion', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: _host(disableAnimations: true),
      );
      expect(_animating(tester), isFalse);
      await tester.pumpAndSettle();
      final frame = loaderFrameOf(tester.state(find.byType(CarthaLoader)));
      expect(frame.charge, 1);
      expect(frame.glow, 0);
    });

    testWidgets('charges over time while animating', (tester) async {
      await pumpCartha(tester, data: onboardedData(), home: _host());
      State state() => tester.state(find.byType(CarthaLoader));
      expect(loaderFrameOf(state()).charge, lessThan(1));
      await tester.pump(kLoaderCycle * 0.6);
      expect(loaderFrameOf(state()).charge, 1);
      expect(loaderFrameOf(state()).glow, greaterThan(0));
    });

    testWidgets('the charge bar adds room under the emblem', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(
          body: Center(child: CarthaLoader(size: 150, showBar: true)),
        ),
      );
      final size = tester.getSize(
        find.descendant(
          of: find.byType(CarthaLoader),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(size, const Size(150, 150 * 1.16));
      expect(tester.takeException(), isNull);
    });

    testWidgets('static when Settings › Motion is off', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(settings: const AppSettings(motion: false)),
        home: _host(),
      );
      expect(_animating(tester), isFalse);
      await tester.runAsync(
        () => h.state.updateSettings(h.state.settings.copyWith(motion: true)),
      );
      await tester.pump();
      expect(_animating(tester), isTrue);
    });

    for (final brightness in Brightness.values) {
      testWidgets('emblem and lockups render (${brightness.name})', (
        tester,
      ) async {
        await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: brightness,
          home: const Scaffold(
            body: Column(
              children: [
                CarthaEmblem(size: 96),
                CarthaWordmark(width: 240),
                CarthaWordmark(layout: WordmarkLayout.stacked, width: 160),
                CarthaWordmark(layout: WordmarkLayout.lettering, width: 200),
              ],
            ),
          ),
        );
        expect(find.bySemanticsLabel('Cartharise emblem'), findsOneWidget);
        expect(find.bySemanticsLabel('Cartharise'), findsNWidgets(3));
        expect(tester.getSize(find.byType(CarthaEmblem)).width, 96);
        expect(
          tester.getSize(find.byType(CarthaWordmark).first),
          const Size(240, 240 * 340 / 1280),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}
