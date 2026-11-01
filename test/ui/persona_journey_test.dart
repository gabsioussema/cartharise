// End-to-end journey for the avatar (docs/plans/persona.md, phase 2): made
// in the builder, then seen on You, the Campaign and Today; carried by the
// exported backup; gone after "Delete all data" (and back with the backup).
import 'dart:async';

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/campaign/campaign_view.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
import 'package:cartharise/ui/persona/persona_builder.dart';
import 'package:cartharise/ui/persona/persona_ops.dart';
import 'package:cartharise/ui/root_shell.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:cartharise/ui/you/you_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// Tall enough that lazily built rows exist (the journey still scrolls to
/// what it taps).
const _phone = Size(390, 2000);

/// A motto with spaces and characters that must survive exactly as typed.
const _motto = '  Slow & “steady” 🐘 ';

const _expected = Avatar(
  skinTone: SkinTone.walnut,
  hair: HairStyle.locs,
  hairColor: HairColor.grey,
  eyewear: Eyewear.round,
  garment: Garment.robe,
);

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> _settle(WidgetTester tester, {int frames = 6}) async {
  // Storage writes are microtasks; let them land, then draw.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await pumpFrames(tester, count: frames);
}

/// The vertical list inside [screen].
Finder _list(Finder screen) => find
    .descendant(
      of: screen,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Scrollable &&
            axisDirectionToAxis(w.axisDirection) == Axis.vertical,
      ),
    )
    .first;

/// Brings [finder] on screen (building it if it is lazily below the fold in
/// [screen]), then taps it like a person would.
Future<void> _tap(WidgetTester tester, Finder finder, {Finder? screen}) async {
  if (finder.evaluate().isEmpty && screen != null) {
    await tester.scrollUntilVisible(finder, 200, scrollable: _list(screen));
  }
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _settle(tester);
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_nav(label));
  await _settle(tester);
}

/// Lets any snackbar time out so it doesn't cover what is tapped next.
Future<void> _waitOutSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await pumpFrames(tester, count: 4);
}

/// Picks [value] in the builder's [category] (chip, then the choice tile).
Future<void> _pick(WidgetTester tester, String category, Enum value) async {
  final builder = find.byType(PersonaBuilderScreen);
  await _tap(
    tester,
    find.byKey(ValueKey('persona-category-$category')),
    screen: builder,
  );
  await _tap(
    tester,
    find.byKey(ValueKey('persona-option-$category-${value.name}')),
    screen: builder,
  );
}

AvatarView _avatarIn(WidgetTester tester, Finder scope) =>
    tester.widget<AvatarView>(
      find.descendant(of: scope, matching: find.byType(AvatarView)).first,
    );

/// The quickest honest way through the welcome after "Delete all data".
Future<void> _quickOnboarding(WidgetTester tester) async {
  expect(find.byType(OnboardingFlow), findsOneWidget);
  await _tap(tester, find.text('Skip'));
  await _tap(tester, find.byKey(const ValueKey('onboarding-adult')));
  for (var i = 0; i < 4; i++) {
    await _tap(tester, find.byKey(const ValueKey('onboarding-next')));
  }
  await _tap(tester, find.byKey(const ValueKey('onboarding-finish')));
  await _settle(tester, frames: 8);
  expect(find.byType(RootShell), findsOneWidget);
}

void main() {
  testWidgets('create an avatar → You, the Campaign and Today show it; '
      'it is in the backup and gone after "Delete all data"', (tester) async {
    final h = await pumpCartha(
      tester,
      data: onboardedData(),
      content: englishContent,
      size: _phone,
    );
    expect(h.state.persona, isNull);
    final todayAvatar = find.byKey(const ValueKey('today-avatar'));
    expect(todayAvatar, findsNothing, reason: 'nothing before one is made');

    // ── You → Create your avatar → the builder ────────────────────────────
    await _openTab(tester, 'You');
    expect(_avatarIn(tester, find.byType(YouTab)).avatar, isNull);
    await _tap(
      tester,
      find.byKey(const ValueKey('you-avatar')),
      screen: find.byType(YouTab),
    );
    expect(find.byType(PersonaBuilderScreen), findsOneWidget);
    // The preview is the real portrait, starting as the silhouette.
    final preview = find.byKey(const ValueKey('persona-preview'));
    expect(tester.widget<AvatarView>(preview).avatar!.skinTone, isNull);

    await _pick(tester, 'skin', SkinTone.walnut);
    await _pick(tester, 'hair', HairStyle.locs);
    await _pick(tester, 'hairColor', HairColor.grey);
    await _pick(tester, 'eyewear', Eyewear.round);
    await _pick(tester, 'garment', Garment.robe);
    expect(tester.widget<AvatarView>(preview).avatar, _expected);
    final motto = find.byKey(const ValueKey('persona-motto'));
    if (motto.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        motto,
        200,
        scrollable: _list(find.byType(PersonaBuilderScreen)),
      );
    }
    await tester.ensureVisible(motto);
    await tester.enterText(motto, _motto);
    await tester.pump();
    await _tap(tester, find.byKey(const ValueKey('persona-save')));

    expect(find.byType(PersonaBuilderScreen), findsNothing);
    expect(h.state.persona!.avatar, _expected);
    expect(h.state.persona!.motto, _motto, reason: 'exactly as typed');
    expect(h.store.saved!.persona!.avatar, _expected, reason: 'on disk');
    expect(h.store.saved!.persona!.motto, _motto);

    // ── You: the portrait, the motto as typed, and "Edit" ─────────────────
    final profile = find.byKey(const ValueKey('you-profile'));
    expect(_avatarIn(tester, profile).avatar, _expected);
    expect(find.text('“$_motto”'), findsOneWidget);
    expect(find.text('Edit your avatar'), findsOneWidget);
    await _waitOutSnackBars(tester);

    // ── The Campaign: on the route and in "Your strategist" ───────────────
    unawaited(AppNav.openCampaign(tester.element(find.byType(YouTab))));
    await _settle(tester);
    final campaign = find.byType(CampaignView);
    expect(campaign, findsOneWidget);
    expect(
      _avatarIn(
        tester,
        find.byKey(const ValueKey('campaign-route-avatar')),
      ).avatar,
      _expected,
    );
    final strategist = find.byKey(const ValueKey('campaign-strategist'));
    if (strategist.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        strategist,
        200,
        scrollable: _list(campaign),
      );
    }
    expect(_avatarIn(tester, strategist).avatar, _expected);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('campaign-strategist-motto')))
          .data,
      _motto,
    );
    expect(find.text('Edit your avatar'), findsWidgets);

    // ── Today: beside the greeting ─────────────────────────────────────────
    await _openTab(tester, 'Today');
    expect(tester.widget<AvatarView>(todayAvatar).avatar, _expected);
    expect(find.text('Good morning, Sam.'), findsOneWidget);

    // ── Export: the avatar and motto are in the backup ────────────────────
    await _openTab(tester, 'You');
    await _tap(
      tester,
      find.byKey(const ValueKey('you-data')),
      screen: find.byType(YouTab),
    );
    expect(find.byType(DataScreen), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('data-export')));
    final backup = h.files.shared.last;
    final exported = decodeBackup(backup.content);
    expect(exported.persona!.avatar, _expected);
    expect(exported.persona!.motto, _motto);
    await _waitOutSnackBars(tester);

    // ── Delete all data: the avatar is gone from storage and every screen ──
    await _tap(tester, find.byKey(const ValueKey('data-delete')));
    await _tap(tester, find.widgetWithText(FilledButton, 'Continue'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Delete everything'));
    await _settle(tester, frames: 10);
    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(h.store.raw, isNull);
    expect(h.state.persona, isNull);

    await _quickOnboarding(tester);
    expect(h.state.persona, isNull);
    expect(h.store.saved?.persona, isNull);
    await _openTab(tester, 'Today');
    expect(find.byType(TodayTab), findsOneWidget);
    expect(find.byKey(const ValueKey('today-avatar')), findsNothing);
    await _openTab(tester, 'You');
    expect(
      _avatarIn(tester, find.byKey(const ValueKey('you-profile'))).avatar,
      isNull,
      reason: 'the emblem again',
    );
    expect(find.text('Create your avatar'), findsOneWidget);

    // ── Restoring the backup brings the avatar back, as it was ────────────
    await _tap(
      tester,
      find.byKey(const ValueKey('you-data')),
      screen: find.byType(YouTab),
    );
    h.files.pickResult = backup.content;
    await _tap(tester, find.byKey(const ValueKey('data-import')));
    await _tap(tester, find.widgetWithText(FilledButton, 'Replace'));
    expect(find.text('Backup restored.'), findsOneWidget);
    expect(h.state.persona!.avatar, _expected);
    expect(h.state.persona!.motto, _motto);
    await tester.pageBack();
    await _settle(tester);
    await _openTab(tester, 'Today');
    expect(
      tester
          .widget<AvatarView>(find.byKey(const ValueKey('today-avatar')))
          .avatar,
      _expected,
    );
    expect(tester.takeException(), isNull);
  });
}
