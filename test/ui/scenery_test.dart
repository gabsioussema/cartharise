// The Campaign scenery (evolve plan step 3 › J): the seven route landscapes
// on the hub and the Route page, and the chapter keepsakes in the Collection.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/campaign/route_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/theme/cartha_theme_spec.dart';
import 'package:cartharise/ui/widgets/route_scenes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

final _t = DateTime(2026, 11, 2, 20);

Finder _key(String key) => find.byKey(ValueKey(key));

/// [xp] XP from completed one-off quests (20 each, one per day), so the
/// user stands at stop `1 + xp ~/ 100`; plus an avatar and [log].
AppData _data({
  int xp = 0,
  List<ExperimentEntry> log = const [],
  AppSettings settings = const AppSettings(),
}) {
  assert(xp % 20 == 0);
  return onboardedData(settings: settings).copyWith(
    quests: [
      for (var d = 0; d < xp ~/ 20; d++)
        Quest(
          id: 'q$d',
          title: 'Quest $d',
          createdAt: _t,
          completedOn: {
            '2026-${(9 + d ~/ 28).toString().padLeft(2, '0')}-'
                '${(1 + d % 28).toString().padLeft(2, '0')}',
          },
        ),
    ],
    persona: () => Persona(
      avatar: const Avatar(skinTone: SkinTone.copper),
      motto: '',
      updatedAt: _t,
    ),
    experimentLog: log,
  );
}

ExperimentEntry _try(String id, String experimentId) => ExperimentEntry(
  id: id,
  experimentId: experimentId,
  day: '2026-11-02',
  createdAt: _t,
);

/// Two tries of one autopilot experiment, one of another, one terrain
/// experiment and a try of an experiment the content no longer has.
final _log = [
  _try('e5', 'try.autopilot.02'),
  _try('e4', 'try.autopilot.02'),
  _try('e3', 'try.autopilot.01'),
  _try('e2', 'try.terrain.01'),
  _try('e1', 'try.nowhere.09'),
];

/// The RGBA pixels under the repaint boundary [key].
Future<Uint8List> _pixels(WidgetTester tester, String key) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(_key(key));
  late Uint8List bytes;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    bytes = data!.buffer.asUint8List();
  });
  return bytes;
}

void _expectAllDistinct(List<Uint8List> images, List<String> names) {
  for (var i = 0; i < images.length; i++) {
    for (var j = i + 1; j < images.length; j++) {
      expect(
        listEquals(images[i], images[j]),
        isFalse,
        reason: '${names[i]} and ${names[j]} look the same',
      );
    }
  }
}

Future<void> _expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

/// Paints [painter] at [size] on a throwaway canvas.
void _paint(CustomPainter painter, Size size) {
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), size);
  recorder.endRecording().dispose();
}

const _sizes = [
  Size(72, 48), // a Route thumbnail
  Size(120, 110), // narrower than the composition: cropped at the sides
  Size(240, 120), // the hub on a 320 dp phone
  Size(350, 175), // the hub on a phone
  Size(940, 200), // the hub on a wide tablet
  Size(200, 320), // taller than wide
  Size(1, 1),
  Size.zero,
];

void main() {
  group('painters', () {
    test('every stop paints in every theme, both brightnesses, at every '
        'size, rising and still, clear and veiled', () {
      for (final theme in AppTheme.values) {
        for (final b in Brightness.values) {
          final palette = CarthaPalette.from(CarthaThemeSpec.of(theme), b);
          for (final w in Waypoint.values) {
            for (final size in _sizes) {
              for (final veiled in const [false, true]) {
                for (final t in const [0.0, 0.4, 1.0]) {
                  expect(
                    () => _paint(
                      RouteScenePainter(
                        waypoint: w,
                        palette: palette,
                        progress: AlwaysStoppedAnimation(t),
                        veiled: veiled,
                      ),
                      size,
                    ),
                    returnsNormally,
                    reason: '${w.name} ${theme.name} ${b.name} $size',
                  );
                }
              }
            }
          }
        }
      }
    });

    test('every keepsake paints in every theme, kept and not yet', () {
      for (final theme in AppTheme.values) {
        for (final b in Brightness.values) {
          final palette = CarthaPalette.from(CarthaThemeSpec.of(theme), b);
          for (final c in CampaignChapter.values) {
            for (final kept in const [false, true]) {
              for (final side in const [0.0, 1.0, 24.0, 44.0, 64.0, 128.0]) {
                expect(
                  () => _paint(
                    KeepsakePainter(chapter: c, kept: kept, palette: palette),
                    Size(side, side * 1.3),
                  ),
                  returnsNormally,
                  reason: '${c.name} kept: $kept ${theme.name} ${b.name}',
                );
              }
            }
          }
        }
      }
    });

    test('repaint only when what is shown changes', () {
      final p = CarthaPalette.from(
        CarthaThemeSpec.of(AppTheme.forest),
        Brightness.dark,
      );
      final other = CarthaPalette.from(
        CarthaThemeSpec.of(AppTheme.tyrian),
        Brightness.dark,
      );
      const still = AlwaysStoppedAnimation(1.0);
      RouteScenePainter scene({
        Waypoint w = Waypoint.ebro,
        CarthaPalette? palette,
        bool veiled = false,
      }) => RouteScenePainter(
        waypoint: w,
        palette: palette ?? p,
        progress: still,
        veiled: veiled,
      );
      expect(scene().shouldRepaint(scene()), isFalse);
      expect(scene().shouldRepaint(scene(w: Waypoint.alps)), isTrue);
      expect(scene().shouldRepaint(scene(veiled: true)), isTrue);
      expect(scene().shouldRepaint(scene(palette: other)), isTrue);
      KeepsakePainter keepsake({bool kept = true}) => KeepsakePainter(
        chapter: CampaignChapter.plan,
        kept: kept,
        palette: p,
      );
      expect(keepsake().shouldRepaint(keepsake()), isFalse);
      expect(keepsake().shouldRepaint(keepsake(kept: false)), isTrue);
    });

    test('lib/ui scenery files take colours from palette tokens only', () {
      // The repo-wide guard is test/ui_base_test.dart; these files are in
      // its scope (lib/ui, outside theme/) and hold no raw colour either.
      final forbidden = RegExp(
        r'Color\s*\(\s*(?:0x|[0-9])|Color\.fromARGB|Color\.fromRGBO|'
        r'\bColors\.(?!transparent\b)\w+|\bCarthaColors\b|\bCarthaThemeSpec\b',
      );
      for (final path in const [
        'lib/ui/widgets/route_scenes.dart',
        'lib/ui/widgets/art/route_art.dart',
        'lib/ui/widgets/art/keepsake_art.dart',
      ]) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: path);
        expect(path.contains('/theme/'), isFalse);
        final lines = file.readAsLinesSync();
        for (final (i, line) in lines.indexed) {
          if (line.trimLeft().startsWith('//')) continue;
          expect(
            forbidden.hasMatch(line),
            isFalse,
            reason: '$path:${i + 1} $line',
          );
        }
      }
    });
  });

  group('drawings', () {
    for (final b in Brightness.values) {
      testWidgets('seven distinct landscapes; veiled differs (${b.name})', (
        tester,
      ) async {
        await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: b,
          size: const Size(700, 1300),
          home: Scaffold(
            body: Wrap(
              children: [
                for (final w in Waypoint.values) ...[
                  RepaintBoundary(
                    key: ValueKey('scene-${w.name}'),
                    child: SizedBox(
                      width: 300,
                      height: 150,
                      child: RouteScene(w, animate: false),
                    ),
                  ),
                  RepaintBoundary(
                    key: ValueKey('veiled-${w.name}'),
                    child: SizedBox(
                      width: 300,
                      height: 150,
                      child: RouteScene(w, animate: false, veiled: true),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final names = [for (final w in Waypoint.values) w.name];
        _expectAllDistinct([
          for (final w in Waypoint.values)
            await _pixels(tester, 'scene-${w.name}'),
        ], names);
        for (final w in Waypoint.values) {
          expect(
            listEquals(
              await _pixels(tester, 'scene-${w.name}'),
              await _pixels(tester, 'veiled-${w.name}'),
            ),
            isFalse,
            reason: '${w.name}: veiled looks the same',
          );
        }
      });

      testWidgets('five distinct keepsakes; kept and not yet differ '
          '(${b.name})', (tester) async {
        await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: b,
          size: const Size(600, 400),
          home: Scaffold(
            body: Wrap(
              children: [
                for (final c in CampaignChapter.values) ...[
                  RepaintBoundary(
                    key: ValueKey('kept-${c.name}'),
                    child: Keepsake(c, kept: true),
                  ),
                  RepaintBoundary(
                    key: ValueKey('open-${c.name}'),
                    child: Keepsake(c),
                  ),
                ],
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final names = [for (final c in CampaignChapter.values) c.name];
        _expectAllDistinct([
          for (final c in CampaignChapter.values)
            await _pixels(tester, 'kept-${c.name}'),
        ], names);
        _expectAllDistinct([
          for (final c in CampaignChapter.values)
            await _pixels(tester, 'open-${c.name}'),
        ], names);
        final p = CarthaPalette.of(tester.element(find.byType(Scaffold)));
        for (final c in CampaignChapter.values) {
          expect(
            listEquals(
              await _pixels(tester, 'kept-${c.name}'),
              await _pixels(tester, 'open-${c.name}'),
            ),
            isFalse,
          );
          // Kept: a plinth and a filled hero stele; not yet: an empty slot
          // in the raised colour, no hero fill — the shape differs, not
          // only the colour.
          final kept = tester.renderObject(
            find.descendant(
              of: _key('kept-${c.name}'),
              matching: find.byType(CustomPaint),
            ),
          );
          expect(
            kept,
            paints
              ..rect()
              ..path()
              ..circle()
              ..path(color: p.heroAccent),
          );
          final open = tester.renderObject(
            find.descendant(
              of: _key('open-${c.name}'),
              matching: find.byType(CustomPaint),
            ),
          );
          expect(open, paints..path(color: p.raised));
          expect(open, isNot(paints..rect()));
          expect(open, isNot(paints..path(color: p.heroAccent)));
        }
        // Decorative: the words next to them say what they are.
        expect(
          find.ancestor(
            of: _key('keepsake-plan').first,
            matching: find.byType(ExcludeSemantics),
          ),
          findsWidgets,
        );
      });
    }
  });

  group('RouteScene', () {
    testWidgets('a label makes it an image; without one it is decorative', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: 100,
                child: RouteScene(Waypoint.rhone, semanticLabel: 'A raft'),
              ),
              SizedBox(height: 100, child: RouteScene(Waypoint.alps)),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('A raft')),
        matchesSemantics(label: 'A raft', isImage: true),
      );
      expect(
        find.descendant(
          of: find.byType(RouteScene).last,
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('the light lifts once with motion, then stays', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        frames: 1,
        home: const Scaffold(
          body: SizedBox(height: 120, child: RouteScene(Waypoint.ebro)),
        ),
      );
      final state = tester.state(find.byType(RouteScene));
      expect(isRouteSceneAnimating(state), isTrue);
      expect(routeSceneProgress(state), lessThan(1));
      await tester.pump(RouteScene.riseDuration);
      expect(isRouteSceneAnimating(state), isFalse);
      expect(routeSceneProgress(state), 1);
      // pumpAndSettle finishes: nothing loops.
      await tester.pumpAndSettle();
    });

    testWidgets('a new stop lifts its light again', (tester) async {
      final stop = ValueNotifier(Waypoint.ebro);
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: Scaffold(
          body: ValueListenableBuilder<Waypoint>(
            valueListenable: stop,
            builder: (_, w, _) => SizedBox(height: 120, child: RouteScene(w)),
          ),
        ),
      );
      await tester.pump(RouteScene.riseDuration);
      final state = tester.state(find.byType(RouteScene));
      expect(isRouteSceneAnimating(state), isFalse);
      stop.value = Waypoint.pyrenees;
      await tester.pump();
      expect(isRouteSceneAnimating(state), isTrue);
      await tester.pump(RouteScene.riseDuration);
      expect(routeSceneProgress(state), 1);
    });

    testWidgets('still with Settings › Motion off', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(settings: const AppSettings(motion: false)),
        frames: 1,
        home: const Scaffold(
          body: SizedBox(height: 120, child: RouteScene(Waypoint.ebro)),
        ),
      );
      final state = tester.state(find.byType(RouteScene));
      expect(isRouteSceneAnimating(state), isFalse);
      expect(routeSceneProgress(state), 1);
    });

    testWidgets('still when the device asks for reduced motion', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpCartha(
        tester,
        data: onboardedData(),
        frames: 1,
        home: const Scaffold(
          body: SizedBox(height: 120, child: RouteScene(Waypoint.italy)),
        ),
      );
      final state = tester.state(find.byType(RouteScene));
      expect(isRouteSceneAnimating(state), isFalse);
      expect(routeSceneProgress(state), 1);
    });

    testWidgets('motion switched off mid-rise shows the finished scene', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        frames: 2,
        home: const Scaffold(
          body: SizedBox(height: 120, child: RouteScene(Waypoint.carthage)),
        ),
      );
      final state = tester.state(find.byType(RouteScene));
      expect(isRouteSceneAnimating(state), isTrue);
      await h.state.updateSettings(h.state.settings.copyWith(motion: false));
      await tester.pump();
      expect(isRouteSceneAnimating(state), isFalse);
      expect(routeSceneProgress(state), 1);
    });

    testWidgets('the window sizes to its width within its bounds and lays '
        'the overlay along its bottom', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        size: const Size(1200, 900),
        home: const Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 300,
                child: RouteSceneWindow(
                  key: ValueKey('w300'),
                  waypoint: Waypoint.alps,
                  overlay: SizedBox(key: ValueKey('overlay'), height: 40),
                ),
              ),
              SizedBox(
                width: 180,
                child: RouteSceneWindow(
                  key: ValueKey('w180'),
                  waypoint: Waypoint.alps,
                ),
              ),
              SizedBox(
                width: 1000,
                child: RouteSceneWindow(
                  key: ValueKey('w1000'),
                  waypoint: Waypoint.alps,
                ),
              ),
            ],
          ),
        ),
      );
      expect(tester.getSize(_key('w300')), const Size(300, 150));
      expect(tester.getSize(_key('w180')).height, 112); // the minimum
      expect(tester.getSize(_key('w1000')).height, 200); // the maximum
      final frame = tester.getRect(_key('w300'));
      final overlay = tester.getRect(_key('overlay'));
      expect(overlay.bottom, closeTo(frame.bottom - 2, 0.01));
      expect(overlay.left, closeTo(frame.left + 8, 0.01));
      expect(overlay.right, closeTo(frame.right - 8, 0.01));
    });
  });

  group('the hub', () {
    for (final (i, w) in Waypoint.values.indexed) {
      testWidgets('shows the landscape of the stop the user is at: ${w.name}', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: _data(xp: i * 100 + 20),
          content: englishContent,
          home: const CompassTab(initial: CompassSection.campaign),
        );
        final window = _key('campaign-scene');
        expect(window, findsOneWidget);
        final scene = tester.widget<RouteScene>(
          find.descendant(of: window, matching: find.byType(RouteScene)),
        );
        expect(scene.waypoint, w);
        expect(scene.veiled, isFalse);
        // The route and the avatar stand in the picture.
        final frame = tester.getRect(window);
        for (final part in ['campaign-route', 'campaign-route-avatar']) {
          final rect = tester.getRect(_key(part));
          expect(frame.contains(rect.topLeft), isTrue, reason: part);
          expect(
            frame.inflate(0.01).contains(rect.bottomRight),
            isTrue,
            reason: part,
          );
        }
        // The picture is described in words.
        final label = switch (w) {
          Waypoint.carthage => 'Carthage: ships in the round harbour at dawn',
          Waypoint.newCarthage =>
            'New Carthage: white houses above a quiet bay',
          Waypoint.ebro => 'The Ebro: a wide river winding through the plain',
          Waypoint.pyrenees => 'The Pyrenees: a high pass between snowy peaks',
          Waypoint.rhone =>
            'The Rhône: an elephant crossing the river on a raft',
          Waypoint.alps =>
            'The Alps: a path climbing toward the snow by moonlight',
          Waypoint.italy => 'Italy: cypresses and fields in the morning sun',
        };
        expect(
          tester.getSemantics(find.bySemanticsLabel(label)),
          matchesSemantics(label: label, isImage: true),
        );
        semantics.dispose();
      });
    }

    testWidgets('no route, so no landscape, while the Campaign is off', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: _data(
          xp: 300,
          settings: const AppSettings(game: false, gameInvited: true),
        ),
        home: const CompassTab(initial: CompassSection.campaign),
      );
      expect(_key('playground'), findsOneWidget);
      expect(find.byType(RouteScene), findsNothing);
    });

    for (final b in Brightness.values) {
      testWidgets('meets the guidelines (${b.name})', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: _data(xp: 220, log: _log),
          content: englishContent,
          brightness: b,
          home: const CompassTab(initial: CompassSection.campaign),
        );
        await tester.pump(RouteScene.riseDuration);
        await _expectAccessible(tester);
        semantics.dispose();
      });
    }
  });

  group('the Route page', () {
    testWidgets('the current stop in the hero; every stop with its '
        'landscape, misty while ahead', (tester) async {
      await pumpCartha(
        tester,
        data: _data(xp: 240), // the Ebro
        content: englishContent,
        size: const Size(390, 2400),
        home: const CampaignRouteScreen(),
      );
      final hero = tester.widget<RouteScene>(
        find.descendant(
          of: _key('route-scene'),
          matching: find.byType(RouteScene),
        ),
      );
      expect(hero.waypoint, Waypoint.ebro);
      for (final w in Waypoint.values) {
        final thumb = _key('route-stop-scene-${w.name}');
        expect(thumb, findsOneWidget, reason: w.name);
        expect(tester.getSize(thumb), const Size(72, 48));
        final scene = tester.widget<RouteScene>(
          find.descendant(of: thumb, matching: find.byType(RouteScene)),
        );
        expect(scene.waypoint, w);
        expect(scene.animate, isFalse);
        expect(scene.veiled, w.index > Waypoint.ebro.index, reason: w.name);
        // Decorative: the row says the place and its status in words.
        expect(scene.semanticLabel, isNull);
      }
    });

    testWidgets('no thumbnails where the words need the room', (tester) async {
      await pumpCartha(
        tester,
        data: _data(xp: 240),
        content: englishContent,
        size: const Size(320, 568),
        textScale: 2,
        home: const CampaignRouteScreen(),
      );
      expect(_key('route-scene'), findsOneWidget);
      for (final w in Waypoint.values) {
        await tester.scrollUntilVisible(
          _key('route-stop-${w.name}'),
          120,
          scrollable: find.byType(Scrollable).first,
        );
        expect(_key('route-stop-${w.name}'), findsOneWidget);
        expect(_key('route-stop-scene-${w.name}'), findsNothing);
      }
    });

    testWidgets('right to left in Arabic: the thumbnail at the start', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: _data(
          xp: 240,
          settings: const AppSettings(language: AppLanguage.ar),
        ),
        content: englishContent,
        size: const Size(390, 2400),
        home: const CampaignRouteScreen(),
      );
      expect(
        Directionality.of(tester.element(find.byType(CampaignRouteScreen))),
        TextDirection.rtl,
      );
      final row = tester.getRect(_key('route-stop-ebro'));
      final thumb = tester.getRect(_key('route-stop-scene-ebro'));
      // The start is on the right: the thumbnail sits in the row's right
      // half, past the status icon.
      expect(thumb.center.dx, greaterThan(row.center.dx));
      expect(thumb.right, lessThan(row.right));
      await expectNoOverflow(tester);
    });

    for (final b in Brightness.values) {
      testWidgets('meets the guidelines (${b.name})', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: _data(xp: 240),
          content: englishContent,
          brightness: b,
          home: const CampaignRouteScreen(),
        );
        await tester.pump(RouteScene.riseDuration);
        await _expectAccessible(tester);
        semantics.dispose();
      });
    }
  });

  group('keepsakes', () {
    test('one per chapter with a distinct experiment tried', () {
      final kept = keptKeepsakes(_log, englishContent);
      expect(kept, {
        CampaignChapter.autopilot: 2, // two experiments, three tries
        CampaignChapter.terrain: 1,
      });
      // An experiment the content no longer has keeps nothing.
      expect(
        keptKeepsakes([_try('x', 'try.nowhere.09')], englishContent),
        isEmpty,
      );
      expect(keptKeepsakes(const [], englishContent), isEmpty);
      // In chapter order.
      expect(
        keptKeepsakes([
          _try('a', 'try.plan.01'),
          _try('b', 'try.terrain.02'),
        ], englishContent).keys,
        [CampaignChapter.terrain, CampaignChapter.plan],
      );
    });

    testWidgets('the Collection shows all five with the Campaign on: kept '
        'ones with their count, the others "Not yet", in words', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCartha(
        tester,
        data: _data(log: _log),
        content: englishContent,
        home: const CollectionScreen(),
      );
      expect(_key('collection-keepsakes'), findsOneWidget);
      expect(find.text('Keepsakes'.toUpperCase()), findsOneWidget);
      for (final c in CampaignChapter.values) {
        final tile = _key('collection-keepsake-${c.name}');
        expect(tile, findsOneWidget);
        final keepsake = tester.widget<Keepsake>(
          find.descendant(of: tile, matching: find.byType(Keepsake)),
        );
        expect(keepsake.chapter, c);
      }
      Keepsake keepsakeOf(CampaignChapter c) => tester.widget<Keepsake>(
        find.descendant(
          of: _key('collection-keepsake-${c.name}'),
          matching: find.byType(Keepsake),
        ),
      );
      expect(keepsakeOf(CampaignChapter.autopilot).kept, isTrue);
      expect(keepsakeOf(CampaignChapter.terrain).kept, isTrue);
      expect(keepsakeOf(CampaignChapter.pattern).kept, isFalse);
      expect(
        tester.getSemantics(_key('collection-keepsake-autopilot')),
        matchesSemantics(label: 'Hourglass, Break autopilot: Kept · 2 tried'),
      );
      expect(
        tester.getSemantics(_key('collection-keepsake-terrain')),
        matchesSemantics(label: 'Spyglass, See the terrain: Kept · 1 tried'),
      );
      expect(
        tester.getSemantics(_key('collection-keepsake-pattern')),
        matchesSemantics(label: 'Mosaic tile, Find the pattern: Not yet'),
      );
      expect(
        tester.getSemantics(_key('collection-keepsake-banner')),
        matchesSemantics(label: 'Banner, Raise your banner: Not yet'),
      );
      expect(
        tester.getSemantics(_key('collection-keepsake-plan')),
        matchesSemantics(label: 'Scroll, Plan the campaign: Not yet'),
      );
      // Above the experiments tried.
      expect(
        tester.getRect(_key('collection-keepsakes')).top,
        lessThan(
          tester.getRect(_key('collection-experiment-try.autopilot.02')).top,
        ),
      );
      semantics.dispose();
    });

    testWidgets('with the Campaign off only the kept ones show', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: _data(
          log: _log,
          settings: const AppSettings(game: false, gameInvited: true),
        ),
        content: englishContent,
        home: const CollectionScreen(),
      );
      expect(_key('collection-keepsake-autopilot'), findsOneWidget);
      expect(_key('collection-keepsake-terrain'), findsOneWidget);
      for (final c in const [
        CampaignChapter.pattern,
        CampaignChapter.banner,
        CampaignChapter.plan,
      ]) {
        expect(_key('collection-keepsake-${c.name}'), findsNothing);
      }
      expect(find.text('Not yet'), findsNothing);
    });

    testWidgets('nothing tried, no shelf (the empty state invites a try)', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: _data(),
        content: englishContent,
        home: const CollectionScreen(),
      );
      expect(_key('collection-keepsakes'), findsNothing);
      expect(_key('collection-tried-empty'), findsOneWidget);
    });

    testWidgets('a try of an experiment the content no longer has shows the '
        'shelf with nothing kept', (tester) async {
      await pumpCartha(
        tester,
        data: _data(log: [_try('x', 'try.nowhere.09')]),
        content: englishContent,
        home: const CollectionScreen(),
      );
      expect(_key('collection-keepsakes'), findsOneWidget);
      expect(
        tester.widgetList<Keepsake>(find.byType(Keepsake)).any((k) => k.kept),
        isFalse,
      );
    });

    testWidgets('right to left in Arabic: the first chapter at the start', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: _data(
          log: _log,
          settings: const AppSettings(language: AppLanguage.ar),
        ),
        content: englishContent,
        home: const CollectionScreen(),
      );
      final terrain = tester.getRect(_key('collection-keepsake-terrain'));
      final pattern = tester.getRect(_key('collection-keepsake-pattern'));
      expect(terrain.center.dx, greaterThan(pattern.center.dx));
      await expectNoOverflow(tester);
    });

    for (final b in Brightness.values) {
      testWidgets('the Collection meets the guidelines (${b.name})', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: _data(log: _log),
          content: englishContent,
          brightness: b,
          home: const CollectionScreen(),
        );
        await _expectAccessible(tester);
        semantics.dispose();
      });
    }
  });

  group('sizes', () {
    for (final b in Brightness.values) {
      for (final size in kSizeMatrix) {
        for (final (name, home) in [
          ('hub', const CompassTab(initial: CompassSection.campaign) as Widget),
          ('Route', const CampaignRouteScreen()),
          ('Collection', const CollectionScreen()),
        ]) {
          for (final language in const [AppLanguage.en, AppLanguage.ar]) {
            testWidgets('the $name fits $size, ${language.name} (${b.name})', (
              tester,
            ) async {
              await pumpCartha(
                tester,
                data: _data(
                  xp: 560,
                  log: _log,
                  settings: AppSettings(language: language),
                ),
                content: englishContent,
                brightness: b,
                size: size.size,
                textScale: size.textScale,
                home: home,
              );
              await tester.pump(RouteScene.riseDuration);
              await expectNoOverflow(tester);
              // Every keepsake keeps a 64 dp picture; the hub's window
              // stays within its bounds.
              for (final k in tester.widgetList<Keepsake>(
                find.byType(Keepsake),
              )) {
                expect(k.size, 64);
              }
              final window = find.byType(RouteSceneWindow);
              if (window.evaluate().isNotEmpty) {
                final height = tester.getSize(window.first).height;
                expect(height, inInclusiveRange(112, 240));
              }
            });
          }
        }
      }
    }
  });
}
