import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/onboarding/onboarding_steps.dart';
import 'package:cartharise/ui/root_shell.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/widgets/scenes.dart';
import 'package:cartharise/ui/widgets/wordmark.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

const _next = ValueKey('onboarding-next');
const _finish = ValueKey('onboarding-finish');
const _back = ValueKey('onboarding-back');
const _skip = ValueKey('onboarding-skip');
const _adult = ValueKey('onboarding-adult');

/// Titles that identify each page.
const _titles = {
  OnboardingStep.understand: 'Understand Yourself',
  OnboardingStep.reset: 'Reset Your Life',
  OnboardingStep.direction: 'Choose a Direction',
  OnboardingStep.steps: 'Improve Step by Step',
  OnboardingStep.limits: "What This Is, and Isn't",
  OnboardingStep.credit: 'Inspired By',
  OnboardingStep.pace: 'Choose Your Pace',
  OnboardingStep.name: 'What Should We Call You?',
  OnboardingStep.privacy: 'Your Words Stay Yours',
};

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await pumpFrames(tester, count: 2);
  await tester.tap(finder);
  await pumpFrames(tester, count: 4);
}

Future<void> _tapNext(WidgetTester tester) => _tap(tester, find.byKey(_next));

/// Moves from the brand page to [step] with Next (confirming 18+ on the way).
Future<void> _goTo(WidgetTester tester, OnboardingStep step) async {
  var at = OnboardingStep.brand;
  while (at != step) {
    if (at == OnboardingStep.limits &&
        !tester.widget<CheckboxListTile>(find.byKey(_adult)).value!) {
      await _tap(tester, find.byKey(_adult));
    }
    await _tapNext(tester);
    at = at.next!;
  }
}

FilledButton _button(WidgetTester tester, ValueKey<String> key) =>
    tester.widget<FilledButton>(
      find.descendant(of: find.byKey(key), matching: find.byType(FilledButton)),
    );

void main() {
  group('OnboardingStep (pure)', () {
    test('ten pages: brand, four carousel pages, five setup pages', () {
      expect(OnboardingStep.values, hasLength(10));
      expect(OnboardingStep.values.where((s) => s.isIntro), hasLength(5));
      expect(
        OnboardingStep.values.where((s) => s.isCarousel),
        hasLength(OnboardingStep.carouselLength),
      );
      expect(
        OnboardingStep.values.where((s) => s.setupPosition != null),
        hasLength(OnboardingStep.setupLength),
      );
      expect(OnboardingStep.understand.carouselPosition, 1);
      expect(OnboardingStep.steps.carouselPosition, 4);
      expect(OnboardingStep.brand.carouselPosition, isNull);
      expect(OnboardingStep.limits.setupPosition, 1);
      expect(OnboardingStep.privacy.setupPosition, 5);
    });

    test('next / previous walk the pages in order; ends are null', () {
      expect(OnboardingStep.brand.previous, isNull);
      expect(OnboardingStep.privacy.next, isNull);
      for (final s in OnboardingStep.values.skip(1)) {
        expect(s.previous!.next, s);
      }
    });

    test('Skip only from the intro, and never past the 18+ page', () {
      expect(OnboardingStep.skipTarget, OnboardingStep.limits);
      expect(OnboardingStep.skipTarget.index, 5, reason: 'page 6 of 10');
      for (final s in OnboardingStep.values) {
        expect(s.canSkip, s.index < OnboardingStep.limits.index);
      }
    });

    test('only the limits page waits for the 18+ confirmation', () {
      for (final s in OnboardingStep.values) {
        expect(s.canAdvance(adultConfirmed: true), isTrue);
        expect(s.canAdvance(adultConfirmed: false), s != OnboardingStep.limits);
      }
    });
  });

  group('OnboardingFlow', () {
    testWidgets('first launch opens on the brand page', (tester) async {
      await pumpCartha(tester);
      expect(find.byType(OnboardingFlow), findsOneWidget);
      expect(find.byType(CarthaWordmark), findsOneWidget);
      expect(find.text('Master Yourself. Rise With Purpose.'), findsOneWidget);
      expect(find.byKey(const ValueKey('onboarding-rule')), findsOneWidget);
      expect(find.byType(DawnRuinsScene), findsOneWidget);
      expect(find.text('Begin'), findsOneWidget);
      expect(find.byKey(_skip), findsOneWidget);
      expect(find.byKey(_back), findsNothing);
    });

    testWidgets('the carousel shows the four scenes with page dots', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCartha(tester);
      final scenes = [SunriseScene, PathScene, CompassScene, StepsScene];
      for (final (i, step) in [
        OnboardingStep.understand,
        OnboardingStep.reset,
        OnboardingStep.direction,
        OnboardingStep.steps,
      ].indexed) {
        await _tapNext(tester);
        expect(find.text(_titles[step]!), findsOneWidget);
        expect(find.byType(scenes[i]), findsOneWidget);
        expect(find.bySemanticsLabel('Page ${i + 1} of 4'), findsOneWidget);
        expect(
          find.byKey(ValueKey('onboarding-dot-${i + 1}-active')),
          findsOneWidget,
        );
        expect(find.byKey(_back), findsOneWidget);
        expect(find.byKey(_skip), findsOneWidget);
      }
      expect(find.text('Get started'), findsOneWidget);
      await _tapNext(tester);
      expect(find.text(_titles[OnboardingStep.limits]!), findsOneWidget);
      expect(find.byKey(_skip), findsNothing);
      semantics.dispose();
    });

    testWidgets('swipe moves forward and back through the intro', (
      tester,
    ) async {
      await pumpCartha(tester);
      await tester.fling(
        find.text('Master Yourself. Rise With Purpose.'),
        const Offset(-300, 0),
        1200,
      );
      await pumpFrames(tester);
      expect(find.text('Understand Yourself'), findsOneWidget);
      await tester.fling(
        find.text('Understand Yourself'),
        const Offset(300, 0),
        1200,
      );
      await pumpFrames(tester);
      expect(find.text('Master Yourself. Rise With Purpose.'), findsOneWidget);
    });

    testWidgets('Skip lands on the 18+ page, which must be confirmed', (
      tester,
    ) async {
      final h = await pumpCartha(tester);
      await _tapNext(tester);
      await _tap(tester, find.byKey(_skip));
      expect(find.text(_titles[OnboardingStep.limits]!), findsOneWidget);
      expect(
        find.text('One day can bring clarity'),
        findsOneWidget,
        reason: 'promise',
      );
      expect(find.text("It can't guarantee a fixed life"), findsOneWidget);
      expect(find.text('Not therapy or diagnosis'), findsOneWidget);

      // Not confirmed: Next is disabled and the reason is said in words.
      expect(_button(tester, _next).onPressed, isNull);
      expect(
        find.text("Confirm you're 18 or older to continue."),
        findsOneWidget,
      );
      await tester.tap(find.byKey(_next), warnIfMissed: false);
      await pumpFrames(tester);
      expect(find.text(_titles[OnboardingStep.limits]!), findsOneWidget);
      // Swiping can't get past it either.
      await tester.fling(
        find.text(_titles[OnboardingStep.limits]!),
        const Offset(-300, 0),
        1200,
      );
      await pumpFrames(tester);
      expect(find.text(_titles[OnboardingStep.limits]!), findsOneWidget);

      await _tap(tester, find.byKey(_adult));
      expect(
        find.text("Confirm you're 18 or older to continue."),
        findsNothing,
      );
      expect(_button(tester, _next).onPressed, isNotNull);
      await _tapNext(tester);
      expect(find.text(_titles[OnboardingStep.credit]!), findsOneWidget);
      expect(h.state.needsOnboarding, isTrue);
    });

    testWidgets('the 18+ checkbox and pace choices are announced properly', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCartha(tester);
      await _goTo(tester, OnboardingStep.limits);
      await tester.ensureVisible(find.byKey(_adult));
      await pumpFrames(tester, count: 2);
      expect(
        tester.getSemantics(find.byKey(_adult)),
        isSemantics(
          label: "I'm 18 or older\nCartharise is made for adults.",
          hasCheckedState: true,
          isChecked: false,
          hasTapAction: true,
        ),
      );
      await _goTo(tester, OnboardingStep.pace);
      expect(
        tester.getSemantics(
          find.byKey(const ValueKey('onboarding-pace-flexible')),
        ),
        isSemantics(
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: true,
        ),
      );
      expect(
        tester.getSemantics(
          find.byKey(const ValueKey('onboarding-pace-oneDay')),
        ),
        isSemantics(
          isInMutuallyExclusiveGroup: true,
          hasCheckedState: true,
          isChecked: false,
        ),
      );
      semantics.dispose();
    });

    testWidgets(
      'credit: title, author, both links, independence, no need to read',
      (tester) async {
        final opened = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          (call) async {
            final args = call.arguments as Map<Object?, Object?>;
            opened.add(args['url']! as String);
            return true;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/url_launcher'),
            null,
          ),
        );
        await pumpCartha(tester, content: englishContent);
        await _goTo(tester, OnboardingStep.credit);
        final credit = englishContent.credit;
        expect(find.text('“${credit.title}”'), findsOneWidget);
        expect(find.text('by Dan Koe · 23 December 2025'), findsOneWidget);
        expect(find.text(credit.independenceNotice), findsOneWidget);
        expect(find.text(credit.paraphraseNotice), findsOneWidget);
        expect(
          find.text(
            "You don't need to read it first. Every idea is explained in plain "
            'words as you go.',
          ),
          findsOneWidget,
        );
        await _tap(
          tester,
          find.byKey(const ValueKey('onboarding-credit-article')),
        );
        await _tap(
          tester,
          find.byKey(const ValueKey('onboarding-credit-newsletter')),
        );
        expect(opened, [credit.articleUrl, credit.newsletterUrl]);
      },
    );

    testWidgets('a link that cannot open says so, with the address', (
      tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/url_launcher'),
        (call) async => false,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/url_launcher'),
          null,
        ),
      );
      await pumpCartha(tester);
      await _goTo(tester, OnboardingStep.credit);
      await _tap(
        tester,
        find.byKey(const ValueKey('onboarding-credit-article')),
      );
      expect(
        find.text(
          "Couldn't open the link. You can visit it yourself: "
          '${fakeContent.credit.articleUrl}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('privacy page states where the data lives, honestly', (
      tester,
    ) async {
      final h = await pumpCartha(tester);
      await _goTo(tester, OnboardingStep.privacy);
      expect(find.text(h.state.storageDescription), findsOneWidget);
      expect(h.state.storageDescription, contains('not encrypted'));
      expect(
        find.text(
          'No account, no ads, no analytics. Nothing you write is sent '
          'anywhere.',
        ),
        findsOneWidget,
      );
      expect(find.text('Finish'), findsOneWidget);
    });

    testWidgets('Back keeps every choice, with the button and system back', (
      tester,
    ) async {
      await pumpCartha(tester);
      await _goTo(tester, OnboardingStep.pace);
      await _tap(tester, find.byKey(const ValueKey('onboarding-pace-oneDay')));
      await _tapNext(tester);
      await tester.enterText(find.byType(TextField), '  Ana ');
      await pumpFrames(tester, count: 2);

      // Button back to the 18+ page: still confirmed.
      for (var i = 0; i < 3; i++) {
        await _tap(tester, find.byKey(_back));
      }
      expect(find.text(_titles[OnboardingStep.limits]!), findsOneWidget);
      expect(tester.widget<CheckboxListTile>(find.byKey(_adult)).value, isTrue);

      // System back goes to the previous page, not out of the app.
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await pumpFrames(tester);
      expect(find.text(_titles[OnboardingStep.steps]!), findsOneWidget);

      // Forward again (steps → limits → credit → pace): choices as left.
      await _tapNext(tester);
      await _tapNext(tester);
      await _tapNext(tester);
      expect(find.text(_titles[OnboardingStep.pace]!), findsOneWidget);
      expect(
        tester.getSemantics(
          find.byKey(const ValueKey('onboarding-pace-oneDay')),
        ),
        isSemantics(isChecked: true),
      );
      await _tapNext(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '  Ana ',
      );
    });

    testWidgets('Finish saves pace, trimmed name and 18+, then calls onDone', (
      tester,
    ) async {
      var done = 0;
      final h = await pumpCartha(
        tester,
        data: AppData.empty,
        home: OnboardingFlow(onDone: () => done++),
      );
      await _goTo(tester, OnboardingStep.pace);
      await _tap(tester, find.byKey(const ValueKey('onboarding-pace-oneDay')));
      await _tapNext(tester);
      await tester.enterText(find.byType(TextField), '  Ana  ');
      await _tapNext(tester);
      await _tap(tester, find.byKey(_finish));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester, count: 2);
      expect(done, 1);
      final profile = h.store.saved!.profile!;
      expect(profile.displayName, 'Ana');
      expect(profile.pace, Pace.oneDay);
      expect(profile.adultConfirmed, isTrue);
      expect(profile.onboardedAt, isNotNull);
      expect(h.state.needsOnboarding, isFalse);
    });

    testWidgets('no name: optional, the app greets "Traveler"', (tester) async {
      final h = await pumpCartha(tester);
      await _goTo(tester, OnboardingStep.privacy);
      await _tap(tester, find.byKey(_finish));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester, count: 8);
      expect(h.state.data.profile!.displayName, isNull);
      expect(h.state.data.profile!.pace, Pace.flexible);
      expect(find.byType(RootShell), findsOneWidget);
      expect(find.byType(TodayTab), findsOneWidget);
      expect(find.text('Good morning, Traveler.'), findsOneWidget);
    });

    testWidgets('replaying the welcome starts from the earlier choices', (
      tester,
    ) async {
      final data = onboardedData(name: 'Sam');
      final h = await pumpCartha(
        tester,
        data: data.copyWith(
          profile: () => data.profile!.copyWith(
            pace: Pace.oneDay,
            onboardedAt: () => null,
          ),
        ),
      );
      expect(find.byType(OnboardingFlow), findsOneWidget);
      await _tap(tester, find.byKey(_skip));
      expect(tester.widget<CheckboxListTile>(find.byKey(_adult)).value, isTrue);
      await _tapNext(tester); // credit
      await _tapNext(tester); // pace
      await _tapNext(tester); // name
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Sam',
      );
      await _tapNext(tester);
      await _tap(tester, find.byKey(_finish));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester, count: 8);
      expect(h.state.data.profile!.pace, Pace.oneDay);
      expect(find.text('Good morning, Sam.'), findsOneWidget);
    });

    testWidgets('scenes are static with reduced motion', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpCartha(tester, frames: 1);
      await _tapNext(tester);
      final scene = tester.state(find.byType(BrandScene));
      expect(isBrandSceneAnimating(scene), isFalse);
      expect(brandSceneProgress(scene), 1);
    });

    testWidgets('scenes rise once with motion on', (tester) async {
      await pumpCartha(tester);
      await tester.tap(find.byKey(_next));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final scene = tester.state(find.byType(BrandScene));
      expect(isBrandSceneAnimating(scene), isTrue);
      await pumpFrames(tester, count: 20);
      expect(isBrandSceneAnimating(scene), isFalse);
      expect(brandSceneProgress(scene), 1);
    });

    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('every page fits $size (${brightness.name})', (
          tester,
        ) async {
          await pumpCartha(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
            content: englishContent,
          );
          await expectNoOverflow(tester);
          for (final step in OnboardingStep.values.skip(1)) {
            await _advanceTo(tester, step);
            expect(find.text(_titles[step]!), findsOneWidget, reason: '$step');
            await expectNoOverflow(tester);
          }
        });
      }
    }
  });
}

/// One step forward to [step] from the page before it (confirming 18+ when
/// leaving the limits page).
Future<void> _advanceTo(WidgetTester tester, OnboardingStep step) async {
  if (step.previous == OnboardingStep.limits &&
      !tester.widget<CheckboxListTile>(find.byKey(_adult)).value!) {
    await _tap(tester, find.byKey(_adult));
  }
  await _tapNext(tester);
}
