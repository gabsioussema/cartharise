// Renders the Campaign scenery (the seven route landscapes, the chapter
// keepsakes, and where they are shown) to PNGs for design review (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/local_date.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/campaign/route_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/widgets/route_scenes.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _at = DateTime(2026, 11, 2, 21, 10);

const _avatar = Avatar(
  skinTone: SkinTone.copper,
  hair: HairStyle.locs,
  hairColor: HairColor.black,
  garment: Garment.cloak,
  garmentColor: GarmentColor.sand,
  accessory: Accessory.satchel,
);

/// [questDays] days of a daily quest done (20 XP each; 4 experiments add 40), the avatar, and experiments tried
/// from three chapters.
AppData _data({int questDays = 21, AppSettings? settings}) {
  final days = [
    for (var i = 0; i < questDays; i++)
      dateKey(DateTime(2026, 10, 1).add(Duration(days: i))),
  ];
  return onboardedData(settings: settings).copyWith(
    quests: [
      Quest(
        id: 'q1',
        title: 'Walk',
        createdAt: _at,
        recurrence: QuestRecurrence.daily,
        completedOn: days.toSet(),
      ),
    ],
    persona: () => Persona(avatar: _avatar, motto: '', updatedAt: _at),
    experimentLog: [
      ExperimentEntry(
        id: 'e3',
        experimentId: 'try.autopilot.02',
        day: '2026-11-03',
        note: 'Easier the second time.',
        createdAt: _at,
      ),
      ExperimentEntry(
        id: 'e2',
        experimentId: 'try.autopilot.01',
        day: '2026-11-02',
        createdAt: _at,
      ),
      ExperimentEntry(
        id: 'e1',
        experimentId: 'try.terrain.01',
        day: '2026-11-01',
        createdAt: _at,
      ),
      ExperimentEntry(
        id: 'e0',
        experimentId: 'try.plan.02',
        day: '2026-10-30',
        createdAt: _at,
      ),
    ],
  );
}

class _SceneSheet extends StatelessWidget {
  const _SceneSheet({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
        children: [
          for (final w in Waypoint.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: Center(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      CarthaTheme.radiusSmall,
                    ),
                    child: RouteScene(w, animate: false),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _ThumbSheet extends StatelessWidget {
  const _ThumbSheet();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
        children: [
          for (final veiled in const [false, true])
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final w in Waypoint.values)
                  SizedBox(
                    width: 72,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: RouteScene(w, animate: false, veiled: veiled),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          for (final size in const [96.0, 64.0, 44.0])
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: SectionCard(
                child: Column(
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in CampaignChapter.values)
                          Keepsake(c, kept: true, size: size),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final c in CampaignChapter.values)
                          Keepsake(c, size: size),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Every theme in one [brightness]: each row in that theme's own colours,
/// a stop's landscape beside the keepsakes, kept and not yet.
class _ThemeSheet extends StatelessWidget {
  const _ThemeSheet(this.brightness);

  final Brightness brightness;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          for (final theme in AppTheme.values)
            Theme(
              data: CarthaTheme.build(theme, brightness),
              child: Builder(
                builder: (context) => ColoredBox(
                  color: CarthaPalette.of(context).background,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 200,
                          height: 96,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              CarthaTheme.radiusSmall,
                            ),
                            child: RouteScene(
                              Waypoint.values[theme.index],
                              animate: false,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        for (final c in CampaignChapter.values)
                          Keepsake(c, kept: c.index.isEven, size: 52),
                        const SizedBox(width: 8),
                        Text(
                          theme.name,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

void main() {
  for (final b in Brightness.values) {
    final tag = b.name;

    testWidgets('scenes on a phone ($tag)', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        brightness: b,
        size: const Size(390, 1400),
        home: const _SceneSheet(width: 350, height: 175),
      );
      await captureScreenshot(tester, 'scenery_01_scenes_$tag', pixelRatio: 2);
    });

    testWidgets('thumbnails and keepsakes ($tag)', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        brightness: b,
        size: const Size(600, 640),
        home: const _ThumbSheet(),
      );
      await captureScreenshot(tester, 'scenery_02_keepsakes_$tag');
    });

    for (final (name, home, height, questDays) in [
      (
        'scenery_04_hub',
        const CompassTab(initial: CompassSection.campaign) as Widget,
        844.0,
        21,
      ),
      ('scenery_05_route', const CampaignRouteScreen(), 1200.0, 13),
      ('scenery_06_collection', const CollectionScreen(), 1300.0, 21),
    ]) {
      testWidgets('$name ($tag)', (tester) async {
        await pumpCartha(
          tester,
          data: _data(questDays: questDays),
          content: englishContent,
          brightness: b,
          size: Size(390, height),
          home: home,
        );
        await tester.pump(RouteScene.riseDuration);
        await captureScreenshot(tester, '${name}_$tag');
      });
    }
  }

  testWidgets('scenes on a tablet', (tester) async {
    await pumpCartha(
      tester,
      data: onboardedData(),
      size: const Size(760, 1900),
      home: const _SceneSheet(width: 700, height: 240),
    );
    await captureScreenshot(tester, 'scenery_03_scenes_tablet', pixelRatio: 1);
    // The hub's frame on a wide tablet: as wide as 4.7 : 1.
    await pumpCartha(
      tester,
      data: onboardedData(),
      size: const Size(980, 1600),
      home: const _SceneSheet(width: 940, height: 200),
    );
    await captureScreenshot(tester, 'scenery_03_scenes_wide', pixelRatio: 1);
  });

  for (final b in Brightness.values) {
    testWidgets('a stop and the keepsakes in every theme (${b.name})', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        brightness: b,
        size: const Size(560, 760),
        home: _ThemeSheet(b),
      );
      await captureScreenshot(
        tester,
        'scenery_07_themes_${b.name}',
        pixelRatio: 2,
      );
    });
  }

  testWidgets('the hub on a small phone at 200 % text, Arabic', (tester) async {
    await pumpCartha(
      tester,
      data: _data(
        questDays: 7,
        settings: const AppSettings(language: AppLanguage.ar),
      ),
      content: englishContent,
      size: const Size(320, 1100),
      textScale: 2,
      home: const CompassTab(initial: CompassSection.campaign),
    );
    await tester.pump(RouteScene.riseDuration);
    await captureScreenshot(tester, 'scenery_08_hub_small_ar', pixelRatio: 2);
  });

  testWidgets('the route and the collection in Arabic', (tester) async {
    for (final (name, home) in [
      ('scenery_09_route_ar', const CampaignRouteScreen() as Widget),
      ('scenery_10_collection_ar', const CollectionScreen()),
    ]) {
      await pumpCartha(
        tester,
        data: _data(
          questDays: 1,
          settings: const AppSettings(language: AppLanguage.ar),
        ),
        content: englishContent,
        size: const Size(390, 1300),
        home: home,
      );
      await tester.pump(RouteScene.riseDuration);
      await captureScreenshot(tester, name);
    }
  });

  testWidgets('the hub on a tablet', (tester) async {
    await pumpCartha(
      tester,
      data: _data(questDays: 26),
      content: englishContent,
      size: const Size(1024, 1000),
      textScale: 1.3,
      home: const CompassTab(initial: CompassSection.campaign),
    );
    await tester.pump(RouteScene.riseDuration);
    await captureScreenshot(tester, 'scenery_11_hub_tablet', pixelRatio: 1);
  });
}
