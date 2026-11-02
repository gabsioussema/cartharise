import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/awakening/lesson_card.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/compass/compass_import.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/journal/journal_tab.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/widgets/art/badge_art.dart';
import 'package:cartharise/ui/widgets/art/glyph_art.dart';
import 'package:cartharise/ui/widgets/art/lesson_art.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

const _lessonIds = [
  'lesson.01',
  'lesson.02',
  'lesson.03',
  'lesson.04',
  'lesson.05',
  'lesson.06',
  'lesson.07',
];

CarthaPalette _palette(WidgetTester tester) =>
    CarthaPalette.of(tester.element(find.byType(Scaffold).first));

Iterable<T> _painters<T>(WidgetTester tester, [Finder? within]) => tester
    .widgetList<CustomPaint>(
      within == null
          ? find.byType(CustomPaint)
          : find.descendant(of: within, matching: find.byType(CustomPaint)),
    )
    .map((w) => w.painter)
    .whereType<T>();

/// The RGBA pixels under the repaint boundary [key].
Future<Uint8List> _pixels(WidgetTester tester, String key) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(ValueKey(key)),
  );
  late Uint8List bytes;
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    bytes = data!.buffer.asUint8List();
  });
  return bytes;
}

/// Every pair of [images] differs.
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

/// Each placed glyph sits with a word: the nearest row, header or hero card
/// around it holds some text.
void _expectGlyphsWithWords(WidgetTester tester) {
  final glyphs = find.byType(GlyphIcon);
  expect(glyphs, findsWidgets);
  for (var i = 0; i < glyphs.evaluate().length; i++) {
    final holder = find
        .ancestor(
          of: glyphs.at(i),
          matching: find.byWidgetPredicate(
            (w) => w is Row || w is ScreenHeader || w is HeroCard,
          ),
        )
        .first;
    final words = tester
        .widgetList<Text>(
          find.descendant(of: holder, matching: find.byType(Text)),
        )
        .where((t) => (t.data ?? '').trim().isNotEmpty);
    expect(words, isNotEmpty, reason: 'glyph #$i has no word next to it');
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.all(16),
        children: [
          for (final g in CarthaGlyph.values)
            Wrap(
              spacing: 8,
              children: [
                for (final s in const [16.0, 20.0, 24.0, 32.0, 48.0])
                  GlyphIcon(g, size: s),
                Text(g.name),
              ],
            ),
          const GlyphTitle(CarthaGlyph.direction, 'A long heading that wraps'),
          for (final id in _lessonIds) ...[
            const SizedBox(height: 8),
            LessonIllustration(id, height: 96),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in Achievement.values) ...[
                AchievementBadge(a, earned: true),
                AchievementBadge(a, size: 32),
              ],
            ],
          ),
          for (final kind in SceneKind.values)
            BrandScene.compact(kind: kind, animate: false),
        ],
      ),
    ),
  );
}

void main() {
  group('glyphs', () {
    for (final b in Brightness.values) {
      testWidgets('all six paint at 16–48 px in the accent (${b.name})', (
        tester,
      ) async {
        await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: b,
          home: const _Gallery(),
          size: const Size(390, 900),
        );
        expect(tester.takeException(), isNull);
        final p = _palette(tester);
        final glyphs = _painters<GlyphPainter>(tester).toList();
        expect(glyphs, hasLength(6 * 5 + 1));
        expect(glyphs.every((g) => g.color == p.accent), isTrue);
        for (final g in CarthaGlyph.values) {
          final first = find.byWidgetPredicate(
            (w) => w is GlyphIcon && w.glyph == g && w.size == 16,
          );
          expect(tester.getSize(first), const Size.square(16));
          expect(
            tester.renderObject(
              find.descendant(of: first, matching: find.byType(CustomPaint)),
            ),
            paints..path(color: p.accent),
          );
        }
      });
    }

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
              GlyphIcon(CarthaGlyph.notice, semanticLabel: 'Notice'),
              GlyphIcon(CarthaGlyph.direction),
            ],
          ),
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Notice')),
        matchesSemantics(label: 'Notice', isImage: true),
      );
      expect(
        find.descendant(
          of: find.byType(GlyphIcon).last,
          matching: find.byType(ExcludeSemantics),
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('a colour can be given (hero surfaces)', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: Builder(
          builder: (context) => Scaffold(
            body: GlyphIcon(
              CarthaGlyph.progress,
              color: CarthaPalette.of(context).heroAccent,
            ),
          ),
        ),
      );
      expect(
        _painters<GlyphPainter>(tester).single.color,
        _palette(tester).heroAccent,
      );
    });

    testWidgets('six distinct drawings', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: Scaffold(
          body: Wrap(
            children: [
              for (final g in CarthaGlyph.values)
                RepaintBoundary(
                  key: ValueKey('glyph-${g.name}'),
                  child: GlyphIcon(g, size: 32),
                ),
            ],
          ),
        ),
      );
      expect({
        for (final g in CarthaGlyph.values) GlyphArt.of(g),
      }, hasLength(6));
      _expectAllDistinct(
        [
          for (final g in CarthaGlyph.values)
            await _pixels(tester, 'glyph-${g.name}'),
        ],
        [for (final g in CarthaGlyph.values) g.name],
      );
    });

    test('strokes stay crisp small and calm large', () {
      for (final side in const [12.0, 16.0, 20.0, 24.0, 32.0, 48.0, 96.0]) {
        final px = GlyphArt.strokeFor(side) * side / GlyphArt.grid;
        expect(px, greaterThanOrEqualTo(1.2), reason: '$side px');
      }
      expect(GlyphArt.strokeFor(16), greaterThan(GlyphArt.strokeFor(24)));
      expect(GlyphArt.strokeFor(48), lessThan(GlyphArt.strokeFor(24)));
    });
  });

  group('lesson illustrations', () {
    test('one scene per lesson; other ids cycle', () {
      final scenes = [for (final id in _lessonIds) LessonScene.of(id)];
      expect(scenes, LessonScene.values);
      expect(LessonScene.of('lesson.08'), LessonScene.roots);
      expect(LessonScene.of('lesson.14'), LessonScene.route);
      expect(LessonScene.of('something'), LessonScene.roots);
      // Every real lesson has its own scene.
      expect({
        for (final l in englishContent.lessons) LessonScene.of(l.id),
      }, hasLength(englishContent.lessons.length));
    });

    for (final b in Brightness.values) {
      testWidgets('paint narrow, phone and tablet widths (${b.name})', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: b,
          size: const Size(800, 3200),
          home: Scaffold(
            body: ListView(
              children: [
                for (final id in [..._lessonIds, 'lesson.99'])
                  for (final (w, h) in const [
                    (180.0, 64.0),
                    (350.0, 96.0),
                    (720.0, 200.0),
                  ])
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SizedBox(
                        width: w,
                        child: LessonIllustration(id, height: h),
                      ),
                    ),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final art = find.byKey(const ValueKey('lesson-illustration-lesson.03'));
        expect(art, findsNWidgets(3));
        expect(tester.getSize(art.at(0)), const Size(180, 64));
        expect(tester.getSize(art.at(2)), const Size(720, 200));
        expect(
          _painters<LessonArtPainter>(tester).map((x) => x.scene).toSet(),
          LessonScene.values.toSet(),
        );
        // Decorative: the lesson title says what it is.
        expect(
          find.ancestor(of: art.first, matching: find.byType(ExcludeSemantics)),
          findsWidgets,
        );
        semantics.dispose();
      });
    }

    testWidgets('seven distinct scenes', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        size: const Size(390, 1200),
        home: Scaffold(
          body: ListView(
            children: [
              for (final id in _lessonIds)
                RepaintBoundary(
                  key: ValueKey('art-$id'),
                  child: LessonIllustration(id, height: 96),
                ),
            ],
          ),
        ),
      );
      _expectAllDistinct([
        for (final id in _lessonIds) await _pixels(tester, 'art-$id'),
      ], _lessonIds);
    });
  });

  group('achievement badges', () {
    for (final b in Brightness.values) {
      testWidgets('all seven, earned and not yet, 32–72 px (${b.name})', (
        tester,
      ) async {
        await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: b,
          size: const Size(600, 800),
          home: Scaffold(
            body: Wrap(
              children: [
                for (final size in const [32.0, 48.0, 72.0])
                  for (final a in Achievement.values) ...[
                    AchievementBadge(a, earned: true, size: size),
                    AchievementBadge(a, size: size),
                  ],
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final p = _palette(tester);
        final key = find.byKey(const ValueKey('achievement-badge-visionary'));
        expect(key, findsNWidgets(6));
        expect(tester.getSize(key.at(4)), const Size.square(72));
        // Earned: ribbon tails and a filled hero medallion with a bronze rim.
        final earned = tester.renderObject(
          find.descendant(of: key.at(0), matching: find.byType(CustomPaint)),
        );
        expect(
          earned,
          paints
            ..path(color: p.heroAccent)
            ..path()
            ..circle(color: p.hero)
            ..circle(color: p.heroAccent),
        );
        expect(earned, isNot(paints..arc()));
        // Not yet: an empty slot with a dashed rim, no ribbons, no medallion.
        final notYet = tester.renderObject(
          find.descendant(of: key.at(1), matching: find.byType(CustomPaint)),
        );
        expect(
          notYet,
          paints
            ..circle(color: p.raised)
            ..arc(color: p.textSecondary)
            ..arc(color: p.textSecondary),
        );
        expect(notYet, isNot(paints..circle(color: p.hero)));
        // Decorative: the tile next to it says "Earned" / "Not yet".
        expect(
          find.ancestor(of: key.first, matching: find.byType(ExcludeSemantics)),
          findsWidgets,
        );
      });
    }

    testWidgets('seven distinct badges; earned and not yet differ', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        size: const Size(600, 400),
        home: Scaffold(
          body: Wrap(
            children: [
              for (final a in Achievement.values) ...[
                RepaintBoundary(
                  key: ValueKey('earned-${a.name}'),
                  child: AchievementBadge(a, earned: true),
                ),
                RepaintBoundary(
                  key: ValueKey('open-${a.name}'),
                  child: AchievementBadge(a),
                ),
              ],
            ],
          ),
        ),
      );
      expect({
        for (final a in Achievement.values) BadgeArt.symbolOf(a),
      }, hasLength(Achievement.values.length));
      final names = [for (final a in Achievement.values) a.name];
      _expectAllDistinct([
        for (final a in Achievement.values)
          await _pixels(tester, 'earned-${a.name}'),
      ], names);
      _expectAllDistinct([
        for (final a in Achievement.values)
          await _pixels(tester, 'open-${a.name}'),
      ], names);
      for (final a in Achievement.values) {
        expect(
          listEquals(
            await _pixels(tester, 'earned-${a.name}'),
            await _pixels(tester, 'open-${a.name}'),
          ),
          isFalse,
        );
      }
    });
  });

  group('compact scene', () {
    test('composes the art at 2:1 and shows a 3:1 band', () {
      expect(
        ScenePainter.frameFor(const Size(390, 130), compact: true),
        const Size(390, 195),
      );
      expect(
        ScenePainter.frameFor(const Size(390, 130), compact: false),
        const Size(390, 130),
      );
      // Already taller than 2:1: nothing is cropped.
      expect(
        ScenePainter.frameFor(const Size(300, 200), compact: true),
        const Size(300, 200),
      );
      for (final kind in SceneKind.values) {
        expect(ScenePainter.focusOf(kind), inInclusiveRange(0, 1));
      }
    });

    testWidgets('shorter, same art; the existing constructor is unchanged', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(
          body: Column(
            children: [
              DawnRuinsScene(compact: true, animate: false),
              DawnRuinsScene(aspectRatio: 2, animate: false),
            ],
          ),
        ),
      );
      final scenes = find.byType(BrandScene);
      final compact = tester.widget<BrandScene>(scenes.at(0));
      final regular = tester.widget<BrandScene>(scenes.at(1));
      expect(compact.compact, isTrue);
      expect(compact.aspectRatio, kCompactSceneAspectRatio);
      expect(regular.compact, isFalse);
      expect(const BrandScene(kind: SceneKind.path).compact, isFalse);
      expect(
        const BrandScene(kind: SceneKind.path).aspectRatio,
        kSceneAspectRatio,
      );
      expect(tester.getSize(scenes.at(0)).height, closeTo(390 / 3, 0.01));
      expect(tester.getSize(scenes.at(1)).height, closeTo(390 / 2, 0.01));
      final painters = _painters<ScenePainter>(tester).toList();
      expect(painters.map((x) => x.kind).toSet(), {SceneKind.dawnRuins});
      expect(painters.map((x) => x.compact), [true, false]);
    });

    testWidgets('rises once with motion, still without', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(
          body: BrandScene.compact(kind: SceneKind.dawnRuins),
        ),
        frames: 1,
      );
      final moving = tester.state(find.byType(BrandScene));
      expect(isBrandSceneAnimating(moving), isTrue);
      await tester.pump(BrandScene.riseDuration);
      expect(isBrandSceneAnimating(moving), isFalse);

      await pumpCartha(
        tester,
        data: onboardedData(settings: const AppSettings(motion: false)),
        home: const Scaffold(
          body: BrandScene.compact(kind: SceneKind.dawnRuins),
        ),
        frames: 1,
      );
      final still = tester.state(find.byType(BrandScene));
      expect(isBrandSceneAnimating(still), isFalse);
      expect(brandSceneProgress(still), 1);
    });
  });

  group('placement (always with a word)', () {
    testWidgets('Awakening: the mirror by the title, a scene on every card', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        content: englishContent,
        home: const AwakeningScreen(),
        size: const Size(390, 5200),
      );
      expect(
        find.descendant(
          of: find.byType(ScreenHeader),
          matching: find.byWidgetPredicate(
            (w) => w is GlyphIcon && w.glyph == CarthaGlyph.notice,
          ),
        ),
        findsOneWidget,
      );
      for (final lesson in englishContent.lessons) {
        final card = find.ancestor(
          of: find.text(lesson.title),
          matching: find.byType(LessonCard),
        );
        expect(
          find.descendant(
            of: card,
            matching: find.byKey(ValueKey('lesson-illustration-${lesson.id}')),
          ),
          findsOneWidget,
        );
      }
      _expectGlyphsWithWords(tester);
    });

    testWidgets('the Reset strip: shorter scenes and the mirror', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(body: SingleChildScrollView(child: LessonStrip())),
      );
      final art = find.byKey(const ValueKey('lesson-illustration-lesson.01'));
      expect(art, findsOneWidget);
      expect(tester.getSize(art).height, 72);
      expect(find.byType(GlyphIcon), findsOneWidget);
      _expectGlyphsWithWords(tester);
    });

    testWidgets('a lesson opens on its scene, the mirror by "Lesson n of 7"', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const LessonScreen(lessonId: 'lesson.06'),
      );
      expect(
        find.byKey(const ValueKey('lesson-illustration-lesson.06')),
        findsOneWidget,
      );
      expect(
        _painters<LessonArtPainter>(tester).single.scene,
        LessonScene.dayArc,
      );
      final glyph = find.byType(GlyphIcon);
      expect(tester.widget<GlyphIcon>(glyph).glyph, CarthaGlyph.notice);
      expect(
        find.descendant(
          of: find.ancestor(of: glyph, matching: find.byType(Row)).first,
          matching: find.text('LESSON 6 OF 7'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Compass: direction on the hero, the shelter on Boundaries', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const CompassTab(),
        size: const Size(390, 4000),
      );
      final p = _palette(tester);
      final direction = find.byWidgetPredicate(
        (w) => w is GlyphIcon && w.glyph == CarthaGlyph.direction,
      );
      // The hero (in bronze for the hero surface) and the empty-Compass card.
      expect(direction, findsNWidgets(2));
      expect(
        find.ancestor(of: direction.first, matching: find.byType(HeroCard)),
        findsOneWidget,
      );
      expect(tester.widget<GlyphIcon>(direction.first).color, p.heroAccent);
      final shelter = find.byWidgetPredicate(
        (w) => w is GlyphIcon && w.glyph == CarthaGlyph.boundaries,
      );
      expect(shelter, findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(of: shelter, matching: find.byType(Row)).first,
          matching: find.text('Boundaries'),
        ),
        findsOneWidget,
      );
      _expectGlyphsWithWords(tester);
    });

    testWidgets('Compass import: the shelter by the boundaries note', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(body: CompassImportSheet()),
      );
      final shelter = find.byWidgetPredicate(
        (w) => w is GlyphIcon && w.glyph == CarthaGlyph.boundaries,
      );
      expect(shelter, findsOneWidget);
      _expectGlyphsWithWords(tester);
    });

    testWidgets('Journal: the lantern on notes, reviews and the review', (
      tester,
    ) async {
      final data = onboardedData().copyWith(
        journal: [
          JournalEntry(
            id: 'n1',
            title: 'Evening walk',
            body: 'Outside.',
            createdAt: DateTime(2026, 11, 2, 20),
          ),
        ],
        reviews: [
          WeeklyReview(
            id: 'r1',
            weekStart: '2026-10-26',
            wins: 'Calm mornings',
            friction: '',
            nextExperiment: '',
            createdAt: DateTime(2026, 11, 1, 18),
          ),
        ],
      );
      bool lantern(Widget w) =>
          w is GlyphIcon && w.glyph == CarthaGlyph.reflection;
      await pumpCartha(tester, data: data, home: const JournalTab());
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('note-n1')),
          matching: find.byWidgetPredicate(lantern),
        ),
        findsOneWidget,
      );
      _expectGlyphsWithWords(tester);
      await tester.tap(find.text('Reviews'));
      await pumpFrames(tester);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('review-r1')),
          matching: find.byWidgetPredicate(lantern),
        ),
        findsOneWidget,
      );
      _expectGlyphsWithWords(tester);

      await pumpCartha(
        tester,
        data: data,
        home: const ReviewScreen(reviewId: 'r1'),
      );
      expect(
        find.descendant(
          of: find.byType(ScreenHeader),
          matching: find.byWidgetPredicate(lantern),
        ),
        findsOneWidget,
      );
      // The review's next experiment carries the experiment's seedling.
      final seedling = find.byWidgetPredicate(
        (w) => w is GlyphIcon && w.glyph == CarthaGlyph.experiment,
      );
      expect(seedling, findsOneWidget);
      expect(
        find.descendant(
          of: find.ancestor(of: seedling, matching: find.byType(Row)).first,
          matching: find.text('Next experiment'),
        ),
        findsOneWidget,
      );
      _expectGlyphsWithWords(tester);
    });
  });

  group('fits every size (dark + light)', () {
    for (final size in kSizeMatrix) {
      for (final b in Brightness.values) {
        testWidgets('visual system gallery $size ${b.name}', (tester) async {
          await pumpCartha(
            tester,
            data: onboardedData(),
            home: const _Gallery(),
            size: size.size,
            textScale: size.textScale,
            brightness: b,
          );
          await expectNoOverflow(tester);
        });

        testWidgets('Reset strip $size ${b.name}', (tester) async {
          await pumpCartha(
            tester,
            data: onboardedData(),
            content: englishContent,
            home: const Scaffold(
              body: SingleChildScrollView(child: LessonStrip()),
            ),
            size: size.size,
            textScale: size.textScale,
            brightness: b,
          );
          await expectNoOverflow(tester);
        });
      }
    }
  });

  test('the visual system takes colours from palette tokens only', () {
    // test/ui_base_test.dart guards all of lib/ui; this keeps the art files
    // in its scope (outside lib/ui/theme/) and checks them directly.
    final files = [
      File('lib/ui/widgets/glyphs.dart'),
      File('lib/ui/widgets/scenes.dart'),
      ...Directory('lib/ui/widgets/art').listSync().whereType<File>(),
    ];
    expect(files.length, greaterThanOrEqualTo(5));
    final raw = RegExp(
      r'Color\s*\(\s*(?:0x|[0-9])|Color\.fromARGB|Color\.fromRGBO|'
      r'\bColors\.(?!transparent\b)\w+|\bCarthaColors\b|\bCarthaThemeSpec\b',
    );
    for (final f in files) {
      expect(f.path, isNot(contains('/theme/')));
      final lines = f.readAsLinesSync().where(
        (l) => !l.trimLeft().startsWith('//') && raw.hasMatch(l),
      );
      expect(lines, isEmpty, reason: f.path);
    }
  });
}
