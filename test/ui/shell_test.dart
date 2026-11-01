import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/boot_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/root_shell.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/widgets/loader.dart';
import 'package:cartharise/ui/widgets/save_indicator.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

const _tabLabels = ['Today', 'Reset', 'Compass', 'Journal', 'You'];

void main() {
  group('boot', () {
    testWidgets('shows the loader, then onboarding when there is no profile', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        readDelay: const Duration(milliseconds: 400),
        frames: 1,
      );
      expect(find.byType(BootScreen), findsOneWidget);
      expect(find.byType(CarthaLoader), findsOneWidget);
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      expect(find.text('MASTER YOURSELF. RISE WITH PURPOSE.'), findsOneWidget);
      await pumpFrames(tester, count: 10);
      expect(find.byType(OnboardingFlow), findsOneWidget);
      expect(find.byType(CarthaLoader), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('onboarding leads into the app', (tester) async {
      final h = await pumpCartha(tester);
      expect(find.byType(OnboardingFlow), findsOneWidget);
      // Skip the intro, confirm 18+ (required), Next through setup, Finish.
      await tester.tap(find.text('Skip'));
      await pumpFrames(tester);
      await tester.ensureVisible(find.text("I'm 18 or older"));
      await pumpFrames(tester, count: 2);
      await tester.tap(find.text("I'm 18 or older"));
      await pumpFrames(tester, count: 2);
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Next'));
        await pumpFrames(tester);
      }
      await tester.tap(find.text('Finish'));
      await pumpFrames(tester);
      expect(h.state.needsOnboarding, isFalse);
      expect(find.byType(RootShell), findsOneWidget);
      expect(find.byType(TodayTab), findsOneWidget);
    });

    testWidgets('unreadable data: honest message, nothing deleted, try again', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      // Simulate a damaged file on the next start.
      h.store.raw = '{ damaged';
      await tester.runAsync(() => h.state.load());
      await pumpFrames(tester);
      expect(find.text('Your saved data couldn\'t be opened'), findsOneWidget);
      expect(find.textContaining('Nothing has been deleted'), findsOneWidget);
      expect(h.store.raw, '{ damaged');
      h.store.raw = null;
      await tester.tap(find.text('Try again'));
      await pumpFrames(tester);
      expect(find.byType(OnboardingFlow), findsOneWidget);
    });
  });

  group('shell', () {
    for (final brightness in Brightness.values) {
      testWidgets('five tabs and switching (${brightness.name})', (
        tester,
      ) async {
        final h = await pumpCartha(
          tester,
          data: onboardedData(),
          brightness: brightness,
        );
        expect(find.byType(RootShell), findsOneWidget);
        for (final label in _tabLabels) {
          expect(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(label),
            ),
            findsOneWidget,
          );
        }
        for (final (i, label) in _tabLabels.indexed) {
          await tester.tap(
            find.descendant(
              of: find.byType(NavigationBar),
              matching: find.text(label),
            ),
          );
          await pumpFrames(tester, count: 3);
          expect(h.shell.tab, AppTab.values[i]);
          final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
          expect(bar.selectedIndex, i);
        }
      });
    }

    testWidgets(
      'AppNav.switchTab and openMissions reach the shell from a pushed screen',
      (tester) async {
        final h = await pumpCartha(tester, data: onboardedData());
        final context = tester.element(find.byType(TodayTab));
        AppNav.openReminders(context);
        await pumpFrames(tester);
        final pushed = tester.element(find.text('You').last);
        AppNav.openMissions(pushed);
        await pumpFrames(tester);
        expect(h.shell.tab, AppTab.compass);
        expect(h.shell.compassSection.value?.name, 'missions');
        expect(find.byType(NavigationBar), findsOneWidget);
      },
    );

    testWidgets('a tapped check-in notification opens its prompt', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      h.reminders.tap('daytime.03');
      await pumpFrames(tester);
      expect(find.text('Daytime 3 title'), findsOneWidget);
    });

    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('fits $size (${brightness.name})', (tester) async {
          await pumpCartha(
            tester,
            data: onboardedData(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          for (final label in _tabLabels) {
            await tester.tap(
              find.descendant(
                of: find.byType(NavigationBar),
                matching: find.text(label),
              ),
            );
            await pumpFrames(tester, count: 3);
            await expectNoOverflow(tester);
          }
        });

        testWidgets(
          'boot loader and load error fit $size (${brightness.name})',
          (tester) async {
            final h = await pumpCartha(
              tester,
              size: size.size,
              textScale: size.textScale,
              brightness: brightness,
              readDelay: const Duration(hours: 1),
              frames: 2,
            );
            expect(find.byType(CarthaLoader), findsOneWidget);
            await expectNoOverflow(tester);
            // Let the pending slow read finish, then fail the next one.
            await tester.pump(const Duration(hours: 1));
            h.store
              ..readDelay = Duration.zero
              ..raw = '{ damaged';
            await tester.runAsync(() => h.state.load());
            await pumpFrames(tester);
            expect(find.text('Try again'), findsOneWidget);
            await expectNoOverflow(tester);
          },
        );

        testWidgets('boot + onboarding fit $size (${brightness.name})', (
          tester,
        ) async {
          await pumpCartha(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await expectNoOverflow(tester);
        });
      }
    }
  });

  group('save indicator', () {
    testWidgets('failure shows message, Retry and Export a copy', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const Scaffold(body: SafeArea(child: SaveIndicator())),
      );
      expect(find.text('Saved on this device'), findsNothing);
      h.store.failWrites = true;
      await tester.runAsync(() => h.state.saveAnswer('morning.01', 'words'));
      await pumpFrames(tester, count: 2);
      expect(find.text("Your last change couldn't be saved."), findsOneWidget);
      h.store.failWrites = false;
      await tester.tap(find.text('Retry'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester, count: 2);
      expect(h.state.saveStatus, SaveStatus.saved);
      expect(find.text('Saved on this device'), findsOneWidget);
      h.store.failWrites = true;
      await tester.runAsync(() => h.state.saveAnswer('morning.01', 'more'));
      await pumpFrames(tester, count: 2);
      await tester.tap(find.text('Export a copy'));
      await pumpFrames(tester);
      expect(find.byType(DataScreen), findsOneWidget);
    });
  });
}
