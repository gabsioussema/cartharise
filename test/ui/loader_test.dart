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
  group('loader keyframes (loader_reference.svg)', () {
    test('lines: hidden, drawn 10→65 %, held to 85 %, undrawn to 100 %', () {
      expect(loaderFrameAt(0).draw, 0);
      expect(loaderFrameAt(0.0999).draw, 0);
      expect(loaderFrameAt(0.375).draw, closeTo(0.5, 1e-6));
      expect(loaderFrameAt(0.65).draw, 1);
      expect(loaderFrameAt(0.80).draw, 1);
      expect(loaderFrameAt(0.925).draw, closeTo(0.5, 1e-6));
      expect(loaderFrameAt(0.99999).draw, closeTo(0, 1e-3));
      // Ease-in-out: slow start.
      expect(loaderFrameAt(0.15).draw, lessThan((0.15 - 0.10) / 0.55));
    });

    test('line opacity .3 → 1 → .3', () {
      expect(loaderFrameAt(0.05).opacity, closeTo(0.3, 1e-9));
      expect(loaderFrameAt(0.70).opacity, 1);
      expect(loaderFrameAt(0.999999).opacity, closeTo(0.3, 1e-3));
    });

    test(
      'spark pulses .92 → 1.13 (opacity .25 → 1) at 45→70 %, held to 85 %',
      () {
        final rest = loaderFrameAt(0.30);
        expect(rest.sparkScale, closeTo(0.92, 1e-9));
        expect(rest.sparkOpacity, closeTo(0.25, 1e-9));
        final peak = loaderFrameAt(0.78);
        expect(peak.sparkScale, closeTo(1.13, 1e-9));
        expect(peak.sparkOpacity, 1);
        expect(
          loaderFrameAt(0.575).sparkScale,
          closeTo((0.92 + 1.13) / 2, 1e-6),
        );
      },
    );

    test('cycle is 3.4 s and repeats', () {
      expect(kLoaderCycle, const Duration(milliseconds: 3400));
      expect(
        loaderFrameAt(1.375).draw,
        closeTo(loaderFrameAt(0.375).draw, 1e-9),
      );
    });

    test('the still frame is the full emblem with its spark', () {
      expect(LoaderFrame.still.draw, 1);
      expect(LoaderFrame.still.opacity, 1);
      expect(LoaderFrame.still.sparkScale, 1);
    });

    test('emblem geometry matches emblem.svg', () {
      expect(EmblemGeometry.lines, hasLength(4));
      final bounds = EmblemGeometry.lines
          .map((p) => p.getBounds())
          .reduce((a, b) => a.expandToInclude(b));
      expect(bounds, const Rect.fromLTRB(121, 140, 391, 289));
      expect(
        EmblemGeometry.trunk.getBounds(),
        const Rect.fromLTRB(256, 244, 256, 307),
      );
      expect(
        EmblemGeometry.spark.getBounds().center,
        EmblemGeometry.sparkCenter,
      );
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
      expect(find.byType(CarthaLoader), findsOneWidget);
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
