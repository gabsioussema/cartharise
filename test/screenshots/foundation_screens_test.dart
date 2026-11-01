// Renders the foundation screens and the UI-base gallery to PNGs for design
// review against "Cartharise Brand and App System Board.png" (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/theme/theme_swatch.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

class _Gallery extends StatefulWidget {
  const _Gallery();
  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  String _range = 'Month';

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 24),
        children: [
          const ScreenHeader(
            title: 'Good morning, Sam.',
            subtitle: 'Clarity today. Progress tomorrow.',
            trailing: SaveIndicator(),
          ),
          HeroCard(
            eyebrow: 'Your reset',
            title: 'Day 12 of 30',
            trailing: const ProgressRing(value: 0.4, onHero: true),
            child: const Text('Build a focused, healthy and fulfilling life.'),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: "Today's focus",
            icon: Icons.wb_twilight_outlined,
            child: Column(
              children: [
                for (final (t, done) in [
                  ('Deep work (90 min)', true),
                  ('Reflect in journal (10 min)', false),
                ])
                  CheckboxListTile(
                    value: done,
                    onChanged: (_) {},
                    title: Text(t),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PillTabs<String>(
            tabs: const [
              PillTab(value: 'Week', label: 'Week'),
              PillTab(value: 'Month', label: 'Month'),
              PillTab(value: 'Year', label: 'Year'),
            ],
            selected: _range,
            onChanged: (v) => setState(() => _range = v),
          ),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChipTag(label: 'Optional'),
              ChipTag(
                label: '11:00',
                icon: Icons.schedule,
                tone: ChipTone.accent,
              ),
              ChipTag(
                label: 'Answered',
                icon: Icons.check,
                tone: ChipTone.success,
              ),
              ChipTag(label: 'Paused', tone: ChipTone.warning),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Next',
            trailingIcon: Icons.arrow_forward,
            onPressed: () {},
            expand: true,
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Skip for now',
            onPressed: () {},
            expand: true,
          ),
          TextLinkButton(
            label: 'Read the original article',
            trailingIcon: Icons.open_in_new,
            onPressed: () {},
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Your answer'),
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final t in AppTheme.values) ...[
                ThemeSwatch(theme: t, selected: t == AppTheme.forest),
                const SizedBox(width: 12),
              ],
              const CarthaEmblem(size: 56),
              const SizedBox(width: 12),
              const CarthaLoader(size: 56, tile: true, startAt: 0.75),
            ],
          ),
          const SizedBox(height: 16),
          const CarthaWordmark(width: 300),
          const EmptyState(
            title: 'No quests yet',
            body: 'Turn a daily lever into a small action when you are ready.',
            actionLabel: 'Add a quest',
            onAction: _noop,
          ),
        ],
      ),
    ),
  );
}

void _noop() {}

void main() {
  for (final b in Brightness.values) {
    testWidgets('boot ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        readDelay: const Duration(hours: 1),
        frames: 2,
      );
      await captureScreenshot(tester, '01_boot_${b.name}');
      await tester.pump(const Duration(hours: 1));
    });

    testWidgets('load error ${b.name}', (tester) async {
      final h = await pumpCartha(tester, brightness: b);
      h.store.raw = '{ damaged';
      await tester.runAsync(() => h.state.load());
      await pumpFrames(tester);
      await captureScreenshot(tester, '02_load_error_${b.name}');
    });

    testWidgets('shell ${b.name}', (tester) async {
      await pumpCartha(tester, brightness: b, data: onboardedData());
      await captureScreenshot(tester, '03_shell_${b.name}');
    });

    testWidgets('gallery ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: onboardedData(),
        home: const _Gallery(),
        size: const Size(390, 1500),
      );
      await captureScreenshot(tester, '04_gallery_${b.name}');
    });

    testWidgets('gallery olive ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        theme: AppTheme.olive,
        data: onboardedData(),
        home: const _Gallery(),
        size: const Size(390, 1500),
      );
      await captureScreenshot(tester, '05_gallery_olive_${b.name}');
    });

    // The board's "loading / charging" strip: frozen frames of the loader
    // (dim → charging → charged → glowing), then the boot loader with its
    // charge bar.
    testWidgets('charging frames ${b.name}', (tester) async {
      await pumpCartha(
        tester,
        brightness: b,
        data: onboardedData(),
        home: Scaffold(
          body: TickerMode(
            enabled: false,
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  for (final t in [0.04, 0.3, 0.6, 0.75])
                    CarthaLoader(size: 84, tile: true, startAt: t),
                  const CarthaLoader(size: 150, showBar: true, startAt: 0.4),
                ],
              ),
            ),
          ),
        ),
      );
      await captureScreenshot(tester, '06_charging_${b.name}');
    });
  }
}
