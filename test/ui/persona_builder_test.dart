import 'dart:math';
import 'dart:ui' show Tristate;

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/l10n/app_localizations_en.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
import 'package:cartharise/ui/persona/builder_categories.dart';
import 'package:cartharise/ui/persona/builder_options.dart';
import 'package:cartharise/ui/persona/persona_builder.dart';
import 'package:cartharise/ui/persona/persona_ops.dart';
import 'package:cartharise/ui/theme/avatar_palette.dart';
import 'package:cartharise/ui/you/you_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

final _l = AppLocalizationsEn();
final _t = DateTime(2026, 11, 2, 20);

/// An onboarded user (the game layer on, no Campaign progress yet: every
/// extra is locked) with an optional saved persona.
AppData _data({Persona? persona, bool game = true}) =>
    onboardedData(settings: AppSettings(game: game))
        .copyWith(persona: () => persona);

Persona _persona(Avatar avatar, {String motto = ''}) =>
    Persona(avatar: avatar, motto: motto, updatedAt: _t);

const _saved = Avatar(
  skinTone: SkinTone.honey,
  hair: HairStyle.braids,
  garment: Garment.cloak,
  garmentColor: GarmentColor.olive,
);

Finder _option(BuilderCategory c, Enum? value) => find.byKey(
  ValueKey('persona-option-${c.name}-${value?.name ?? 'silhouette'}'),
);

Finder _chip(BuilderCategory c) =>
    find.byKey(ValueKey('persona-category-${c.name}'));

final _save = find.byKey(const ValueKey('persona-save'));

/// The page's vertical list (not the chip row or the motto field).
final _list = find
    .byWidgetPredicate(
      (w) =>
          w is Scrollable &&
          axisDirectionToAxis(w.axisDirection) == Axis.vertical,
    )
    .first;

/// Builds [finder] if the list has not (rows off screen are built lazily):
/// from the top, scrolling down.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  tester.state<ScrollableState>(_list).position.jumpTo(0);
  await tester.pump();
  if (finder.evaluate().isNotEmpty) return;
  await tester.scrollUntilVisible(finder, 200, scrollable: _list);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester);
}

Future<void> _pick(WidgetTester tester, BuilderCategory c, Enum? value) async {
  await _tap(tester, _chip(c));
  await _tap(tester, _option(c, value));
}

/// Clears floating snack bars (they can cover the end of the list).
Future<void> _clearSnackBars(WidgetTester tester) async {
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
      .clearSnackBars();
  await pumpFrames(tester);
}

Avatar _preview(WidgetTester tester) => tester
    .widget<AvatarView>(find.byKey(const ValueKey('persona-preview')))
    .avatar!;

bool _enabled(WidgetTester tester, Finder button) =>
    tester
        .widget<FilledButton>(
          find.descendant(of: button, matching: find.byType(FilledButton)),
        )
        .onPressed !=
    null;

SemanticsData _semantics(WidgetTester tester, Finder finder) =>
    tester.getSemantics(finder).getSemanticsData();

/// Pumps the app on the You tab.
Future<CarthaHarness> _pumpYou(
  WidgetTester tester, {
  AppData? data,
  Size size = const Size(390, 844),
  double textScale = 1,
  Brightness brightness = Brightness.dark,
}) => pumpCartha(
  tester,
  data: data ?? _data(),
  shell: ShellController(initial: AppTab.you),
  size: size,
  textScale: textScale,
  brightness: brightness,
);

/// Opens the builder from the You profile ("Create / Edit your avatar").
Future<void> _openBuilder(WidgetTester tester) async {
  await _tap(tester, find.byKey(const ValueKey('you-avatar')));
  expect(find.byType(PersonaBuilderScreen), findsOneWidget);
}

/// The You profile card's portrait.
AvatarView _profileAvatar(WidgetTester tester) => tester.widget<AvatarView>(
  find.descendant(
    of: find.byKey(const ValueKey('you-profile')),
    matching: find.byType(AvatarView),
  ),
);

void main() {
  group('create and edit', () {
    testWidgets('create from You: parts and a motto, saved exactly as typed', (
      tester,
    ) async {
      final h = await _pumpYou(tester);
      expect(_profileAvatar(tester).avatar, isNull, reason: 'the emblem');
      expect(find.text('Create your avatar'), findsOneWidget);
      await _openBuilder(tester);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Create your avatar'),
        ),
        findsOneWidget,
      );
      // No skin is assumed: a new avatar starts as the silhouette.
      expect(_preview(tester).skinTone, isNull);
      expect(
        _semantics(
              tester,
              _option(BuilderCategory.skin, null),
            ).flagsCollection.isSelected ==
            Tristate.isTrue,
        isTrue,
      );

      await _pick(tester, BuilderCategory.skin, SkinTone.walnut);
      expect(_preview(tester).skinTone, SkinTone.walnut);
      await _pick(tester, BuilderCategory.hair, HairStyle.locs);
      await _pick(tester, BuilderCategory.hairColor, HairColor.grey);
      await _pick(tester, BuilderCategory.headwear, Headwear.headscarf);
      await _pick(tester, BuilderCategory.eyewear, Eyewear.round);
      final motto = find.byKey(const ValueKey('persona-motto'));
      await _reveal(tester, motto);
      await tester.ensureVisible(motto);
      await tester.enterText(motto, '  Steady, not fast ');
      await pumpFrames(tester);
      expect(find.text('19/60'), findsOneWidget);

      await _tap(tester, _save);
      const expected = Avatar(
        skinTone: SkinTone.walnut,
        hair: HairStyle.locs,
        hairColor: HairColor.grey,
        headwear: Headwear.headscarf,
        eyewear: Eyewear.round,
      );
      expect(h.state.persona!.avatar, expected);
      expect(h.state.persona!.motto, '  Steady, not fast ');
      expect(h.store.saved!.persona!.avatar, expected, reason: 'on disk');
      expect(h.store.saved!.persona!.motto, '  Steady, not fast ');

      // Back on You: the avatar, the motto as typed, and "Edit".
      expect(find.byType(PersonaBuilderScreen), findsNothing);
      expect(find.byType(YouTab), findsOneWidget);
      expect(find.text('Avatar saved.'), findsOneWidget);
      expect(_profileAvatar(tester).avatar, expected);
      expect(find.text('“  Steady, not fast ”'), findsOneWidget);
      expect(find.text('Edit your avatar'), findsOneWidget);
    });

    testWidgets('edit starts from the saved avatar; Save once changed', (
      tester,
    ) async {
      final h = await _pumpYou(
        tester,
        data: _data(persona: _persona(_saved, motto: 'One step')),
      );
      await _openBuilder(tester);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Edit your avatar'),
        ),
        findsOneWidget,
      );
      expect(_preview(tester), _saved);
      expect(
        _semantics(
              tester,
              _option(BuilderCategory.skin, SkinTone.honey),
            ).flagsCollection.isSelected ==
            Tristate.isTrue,
        isTrue,
      );
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('persona-motto')))
            .controller!
            .text,
        'One step',
      );
      expect(_enabled(tester, _save), isFalse, reason: 'nothing to save');

      await _pick(tester, BuilderCategory.garment, Garment.robe);
      expect(_enabled(tester, _save), isTrue);
      await _tap(tester, _save);
      expect(h.state.persona!.avatar, _saved.copyWith(garment: Garment.robe));
      expect(h.state.persona!.motto, 'One step');
      expect(h.state.persona!.updatedAt, kTestNow);
      expect(find.byType(YouTab), findsOneWidget);
    });

    testWidgets('silhouette can be chosen back at any time', (tester) async {
      final h = await _pumpYou(tester, data: _data(persona: _persona(_saved)));
      await _openBuilder(tester);
      await _pick(tester, BuilderCategory.skin, null);
      expect(_preview(tester).skinTone, isNull);
      await _tap(tester, _save);
      expect(h.state.persona!.avatar.skinTone, isNull);
    });

    testWidgets('skin tones are offered in the mixed order, silhouette first', (
      tester,
    ) async {
      await _pumpYou(tester);
      await _openBuilder(tester);
      final xs = [
        for (final tone in [null, ...kSkinTonePresentation])
          tester.getTopLeft(_option(BuilderCategory.skin, tone)),
      ];
      // Reading order: row by row, start to end.
      for (var i = 1; i < xs.length; i++) {
        final before = xs[i - 1];
        final after = xs[i];
        expect(
          after.dy > before.dy ||
              (after.dy == before.dy && after.dx > before.dx),
          isTrue,
          reason: 'option $i',
        );
      }
    });
  });

  group('surprise me', () {
    testWidgets('random usable parts only, never a locked extra; undo', (
      tester,
    ) async {
      final h = await _pumpYou(tester);
      await _openBuilder(tester);
      var before = _preview(tester);
      final surprise = find.byKey(const ValueKey('persona-surprise'));
      for (var i = 0; i < 15; i++) {
        await _tap(tester, surprise);
        final now = _preview(tester);
        expect(now, isNot(before));
        expect(now.skinTone, isNotNull);
        for (final part in now.parts) {
          expect(h.state.canUse(part), isTrue, reason: '$part');
          expect(requirementOf(part), isNull, reason: 'game on, no progress');
        }
        before = now;
      }
      expect(find.text('New look. Not saved yet.'), findsOneWidget);
      final last = _preview(tester);
      await _tap(tester, surprise);
      expect(_preview(tester), isNot(last));
      await tester.tap(find.text('Undo'));
      await pumpFrames(tester);
      expect(_preview(tester), last);
      expect(h.state.persona, isNull, reason: 'nothing saved before Save');
    });

    test(
      'surpriseAvatar: usable parts only, always a tone, never the same',
      () {
        bool free(Enum part) => requirementOf(part) == null;
        const current = Avatar(skinTone: SkinTone.clay);
        final seen = <Enum>{};
        for (var seed = 0; seed < 300; seed++) {
          final a = surpriseAvatar(Random(seed), free, current: current);
          expect(a, isNot(current));
          expect(a.skinTone, isNotNull);
          expect(a.parts.every(free), isTrue);
          seen.addAll(a.parts);
        }
        // Every free choice turns up.
        for (final c in BuilderCategory.values) {
          for (final o in c.options) {
            if (o != null && free(o)) expect(seen, contains(o), reason: '$o');
          }
        }
        // With everything open (game off), extras can be picked too.
        final open = {
          for (var seed = 0; seed < 300; seed++)
            ...surpriseAvatar(Random(seed), (_) => true).parts,
        };
        expect(
          open,
          containsAll([Headwear.laurel, Sigil.star, Accessory.amulet]),
        );
      },
    );
  });

  group('Campaign extras', () {
    testWidgets('locked extras show a lock and reason and cannot be chosen', (
      tester,
    ) async {
      await _pumpYou(tester);
      await _openBuilder(tester);
      await _tap(tester, _chip(BuilderCategory.sigil));
      expect(
        find.text('Locked extras open along the Campaign.'),
        findsOneWidget,
      );
      final star = _option(BuilderCategory.sigil, Sigil.star);
      // Changed by design (reward picks): with no pick to spend yet, a
      // locked extra says when the next pick comes.
      expect(
        find.descendant(
          of: star,
          matching: find.text('Next pick at New Carthage'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: star, matching: find.byIcon(Icons.lock_outline)),
        findsOneWidget,
      );
      final data = _semantics(tester, star);
      expect(data.label, contains('North star'));
      expect(data.label, contains('Locked'));
      expect(data.label, contains('Next pick at New Carthage'));
      expect(data.flagsCollection.isEnabled == Tristate.isTrue, isFalse);
      expect(data.flagsCollection.isSelected == Tristate.isTrue, isFalse);

      await _tap(tester, star);
      expect(_preview(tester).sigil, Sigil.elephant, reason: 'not selectable');
      // Every locked extra opens the same way (any pick buys any extra).
      expect(
        find.descendant(
          of: _option(BuilderCategory.sigil, Sigil.laurel),
          matching: find.text('Next pick at New Carthage'),
        ),
        findsOneWidget,
      );
      // Free choices in the same category stay open.
      await _tap(tester, _option(BuilderCategory.sigil, Sigil.sun));
      expect(_preview(tester).sigil, Sigil.sun);
      // Appearance is never locked.
      await _tap(tester, _chip(BuilderCategory.hair));
      expect(find.byIcon(Icons.lock_outline), findsNothing);
      expect(find.text('Locked extras open along the Campaign.'), findsNothing);
    });

    testWidgets('with the game layer off, every extra is open', (tester) async {
      await _pumpYou(tester, data: _data(game: false));
      await _openBuilder(tester);
      await _pick(tester, BuilderCategory.sigil, Sigil.star);
      expect(_preview(tester).sigil, Sigil.star);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
      await _pick(tester, BuilderCategory.headwear, Headwear.laurel);
      expect(_preview(tester).headwear, Headwear.laurel);
    });

    testWidgets('a worn locked extra stays selected and usable', (
      tester,
    ) async {
      final h = await _pumpYou(
        tester,
        data: _data(persona: _persona(const Avatar(headwear: Headwear.laurel))),
      );
      expect(h.state.avatarUnlocks, isEmpty);
      await _openBuilder(tester);
      await _tap(tester, _chip(BuilderCategory.headwear));
      final laurel = _option(BuilderCategory.headwear, Headwear.laurel);
      var data = _semantics(tester, laurel);
      expect(data.flagsCollection.isSelected == Tristate.isTrue, isTrue);
      expect(data.flagsCollection.isEnabled == Tristate.isTrue, isTrue);
      expect(
        find.descendant(of: laurel, matching: find.text('Yours to keep')),
        findsOneWidget,
      );
      // The circlet is not worn: still locked.
      expect(
        find.descendant(
          of: _option(BuilderCategory.headwear, Headwear.circlet),
          matching: find.text('Next pick at New Carthage'),
        ),
        findsOneWidget,
      );

      // Try another headwear, then come back to the laurel.
      await _tap(tester, _option(BuilderCategory.headwear, Headwear.hood));
      expect(_preview(tester).headwear, Headwear.hood);
      await _tap(tester, laurel);
      expect(_preview(tester).headwear, Headwear.laurel);
      data = _semantics(tester, laurel);
      expect(data.flagsCollection.isSelected == Tristate.isTrue, isTrue);

      await _pick(tester, BuilderCategory.skin, SkinTone.umber);
      await _tap(tester, _save);
      expect(h.state.persona!.avatar.headwear, Headwear.laurel);
      expect(h.state.persona!.avatar.skinTone, SkinTone.umber);
    });
  });

  group('kept extras (never taken away)', () {
    testWidgets('a kept extra stays the user\'s after saving without it', (
      tester,
    ) async {
      final h = await _pumpYou(
        tester,
        data: _data(persona: _persona(const Avatar(headwear: Headwear.laurel))),
      );
      await _openBuilder(tester);
      await _pick(tester, BuilderCategory.headwear, Headwear.hood);
      await _tap(tester, _save);
      expect(h.state.persona!.avatar.headwear, Headwear.hood);
      expect(h.state.canUse(Headwear.laurel), isTrue);
      expect(h.store.saved!.avatarUnlocked, {Unlockable.headwearLaurel});

      // Back in the builder: the laurel is open (no lock), and can be worn.
      await _openBuilder(tester);
      await _tap(tester, _chip(BuilderCategory.headwear));
      final laurel = _option(BuilderCategory.headwear, Headwear.laurel);
      expect(
        find.descendant(of: laurel, matching: find.byIcon(Icons.lock_outline)),
        findsNothing,
      );
      expect(
        find.descendant(of: laurel, matching: find.text('Yours to keep')),
        findsNothing,
      );
      await _tap(tester, laurel);
      expect(_preview(tester).headwear, Headwear.laurel);
    });

    testWidgets('"Surprise me" may drop a kept extra; it stays the user\'s', (
      tester,
    ) async {
      final h = await _pumpYou(
        tester,
        data: _data(persona: _persona(const Avatar(sigil: Sigil.star))),
      );
      await _openBuilder(tester);
      final surprise = find.byKey(const ValueKey('persona-surprise'));
      for (var i = 0; i < 20 && _preview(tester).sigil == Sigil.star; i++) {
        await _tap(tester, surprise);
      }
      expect(_preview(tester).sigil, isNot(Sigil.star));
      await _tap(tester, _save);
      expect(h.state.canUse(Sigil.star), isTrue);
    });
  });

  group('choices that do not show yet', () {
    Finder note(String text) => find.descendant(
      of: find.byKey(const ValueKey('persona-hidden-note')),
      matching: find.text(text),
    );
    const silhouette = 'Pick a skin tone to see the face and colours.';
    const covered = 'Hair is hidden under your headwear.';

    testWidgets('the silhouette: marks, expression and colours say why', (
      tester,
    ) async {
      await _pumpYou(tester);
      await _openBuilder(tester);
      expect(_preview(tester).skinTone, isNull);
      for (final c in [
        BuilderCategory.mark,
        BuilderCategory.expression,
        BuilderCategory.hairColor,
        BuilderCategory.garmentColor,
      ]) {
        await _tap(tester, _chip(c));
        expect(note(silhouette), findsOneWidget, reason: '$c');
      }
      for (final c in [
        BuilderCategory.skin,
        BuilderCategory.face,
        BuilderCategory.hair,
        BuilderCategory.garment,
      ]) {
        await _tap(tester, _chip(c));
        expect(
          find.byKey(const ValueKey('persona-hidden-note')),
          findsNothing,
          reason: '$c',
        );
      }
      // A tone shows the face and the colours.
      await _pick(tester, BuilderCategory.skin, SkinTone.copper);
      await _tap(tester, _chip(BuilderCategory.mark));
      expect(find.byKey(const ValueKey('persona-hidden-note')), findsNothing);
    });

    testWidgets('a headscarf or turban: hair and hair colour say why', (
      tester,
    ) async {
      await _pumpYou(
        tester,
        data: _data(
          persona: _persona(_saved.copyWith(headwear: Headwear.turban)),
        ),
      );
      await _openBuilder(tester);
      for (final c in [BuilderCategory.hair, BuilderCategory.hairColor]) {
        await _tap(tester, _chip(c));
        expect(note(covered), findsOneWidget, reason: '$c');
      }
      await _pick(tester, BuilderCategory.headwear, Headwear.headscarf);
      await _tap(tester, _chip(BuilderCategory.hair));
      expect(note(covered), findsOneWidget);
      // A hood leaves the hair in view.
      await _pick(tester, BuilderCategory.headwear, Headwear.hood);
      await _tap(tester, _chip(BuilderCategory.hair));
      expect(find.byKey(const ValueKey('persona-hidden-note')), findsNothing);
    });

    test('hiddenChoices covers exactly what the portrait leaves out', () {
      const toned = Avatar(skinTone: SkinTone.clay);
      for (final c in BuilderCategory.values) {
        expect(hiddenChoices(c, toned), isNull, reason: '$c');
      }
      expect(
        hiddenChoices(BuilderCategory.hairColor, const Avatar()),
        HiddenChoices.silhouette,
      );
      expect(
        hiddenChoices(
          BuilderCategory.hair,
          const Avatar(headwear: Headwear.headscarf),
        ),
        HiddenChoices.headwear,
      );
      expect(
        hiddenChoices(
          BuilderCategory.hairColor,
          toned.copyWith(headwear: Headwear.turban),
        ),
        HiddenChoices.headwear,
      );
    });
  });

  group('category chips', () {
    /// The chip row's scrollable.
    Finder row() => find.byWidgetPredicate(
      (w) =>
          w is Scrollable &&
          axisDirectionToAxis(w.axisDirection) == Axis.horizontal,
    );

    testWidgets('the row runs to the screen edges', (tester) async {
      await _pumpYou(tester, size: const Size(320, 568), textScale: 2);
      await _openBuilder(tester);
      final rect = tester.getRect(row());
      expect(rect.left, 0);
      expect(rect.right, 320);
      // The first chip starts at the page gutter.
      expect(tester.getRect(_chip(BuilderCategory.skin)).left, 20);
    });

    testWidgets('a chip cut at the edge is scrolled fully into view', (
      tester,
    ) async {
      await _pumpYou(tester, size: const Size(320, 568), textScale: 2);
      await _openBuilder(tester);
      final position = tester.state<ScrollableState>(row()).position;
      final page = tester.state<ScrollableState>(_list).position;
      // Find a chip cut by the right edge of the screen.
      final cut = BuilderCategory.values.firstWhere((c) {
        final r = tester.getRect(_chip(c));
        return r.left < 320 && r.right > 320;
      });
      final before = page.pixels;
      final visible = tester.getRect(_chip(cut));
      await tester.tapAt(Offset((visible.left + 320) / 2, visible.center.dy));
      await pumpFrames(tester);
      await tester.pump(const Duration(milliseconds: 400));
      final after = tester.getRect(_chip(cut));
      expect(after.left, greaterThanOrEqualTo(0));
      expect(after.right, lessThanOrEqualTo(320 - 20 + 0.5));
      expect(position.pixels, greaterThan(0));
      expect(page.pixels, before, reason: 'only the row moves');
      expect(
        _semantics(tester, _chip(cut)).flagsCollection.isSelected ==
            Tristate.isTrue,
        isTrue,
      );
    });
  });

  group('remove and leave', () {
    testWidgets('remove asks first, then the emblem is back', (tester) async {
      final h = await _pumpYou(
        tester,
        data: _data(persona: _persona(_saved, motto: 'Kept')),
      );
      await _openBuilder(tester);
      final remove = find.byKey(const ValueKey('persona-remove'));
      await _tap(tester, remove);
      expect(find.text('Remove your avatar?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await pumpFrames(tester);
      expect(h.state.persona, isNotNull);
      expect(find.byType(PersonaBuilderScreen), findsOneWidget);

      await _tap(tester, remove);
      await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
      await pumpFrames(tester);
      expect(h.state.persona, isNull);
      expect(h.store.saved!.persona, isNull, reason: 'on disk');
      expect(find.byType(PersonaBuilderScreen), findsNothing);
      expect(find.text('Avatar removed.'), findsOneWidget);
      expect(_profileAvatar(tester).avatar, isNull);
      expect(find.text('Create your avatar'), findsOneWidget);
      expect(find.text('“Kept”'), findsNothing);
    });

    testWidgets('no avatar yet: nothing to remove', (tester) async {
      await _pumpYou(tester);
      await _openBuilder(tester);
      expect(find.byKey(const ValueKey('persona-remove')), findsNothing);
    });

    testWidgets('leaving with unsaved changes asks first', (tester) async {
      final h = await _pumpYou(tester);
      // Nothing changed: back leaves at once.
      await _openBuilder(tester);
      await tester.pageBack();
      await pumpFrames(tester);
      expect(find.byType(PersonaBuilderScreen), findsNothing);
      expect(find.text('Leave without saving?'), findsNothing);

      await _openBuilder(tester);
      await _pick(tester, BuilderCategory.skin, SkinTone.ebony);
      await tester.pageBack();
      await pumpFrames(tester);
      expect(find.text('Leave without saving?'), findsOneWidget);
      await tester.tap(find.text('Keep editing'));
      await pumpFrames(tester);
      expect(find.byType(PersonaBuilderScreen), findsOneWidget);
      expect(_preview(tester).skinTone, SkinTone.ebony, reason: 'draft kept');

      // The system back gesture asks too.
      await tester.binding.handlePopRoute();
      await pumpFrames(tester);
      expect(find.text('Leave without saving?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Leave'));
      await pumpFrames(tester);
      expect(find.byType(PersonaBuilderScreen), findsNothing);
      expect(find.byType(YouTab), findsOneWidget);
      expect(h.state.persona, isNull);
    });

    testWidgets('a motto change alone counts as unsaved', (tester) async {
      await _pumpYou(tester, data: _data(persona: _persona(_saved)));
      await _openBuilder(tester);
      final motto = find.byKey(const ValueKey('persona-motto'));
      await _reveal(tester, motto);
      await tester.ensureVisible(motto);
      await tester.enterText(motto, 'Slow is smooth');
      await pumpFrames(tester);
      await tester.pageBack();
      await pumpFrames(tester);
      expect(find.text('Leave without saving?'), findsOneWidget);
    });
  });

  group('honest saving', () {
    testWidgets('a failed save is said so, with Retry; never "saved"', (
      tester,
    ) async {
      final h = await _pumpYou(tester);
      await _openBuilder(tester);
      h.store.failWrites = true;
      await _pick(tester, BuilderCategory.skin, SkinTone.copper);
      await _tap(tester, _save);
      expect(find.text('Avatar saved.'), findsNothing);
      expect(
        find.text(
          'Not saved on this phone yet. Retry at the top, or export a copy.',
        ),
        findsOneWidget,
      );
      expect(find.byType(PersonaBuilderScreen), findsOneWidget);
      expect(find.text(_l.saveStatusFailed), findsOneWidget);
      expect(h.store.saved!.persona, isNull);

      h.store.failWrites = false;
      await _tap(tester, find.text('Retry'));
      expect(h.store.saved!.persona!.avatar.skinTone, SkinTone.copper);
      expect(find.text(_l.saveStatusFailed), findsNothing);
    });

    testWidgets('a failed removal is said so, with Retry', (tester) async {
      final h = await _pumpYou(tester, data: _data(persona: _persona(_saved)));
      await _openBuilder(tester);
      h.store.failWrites = true;
      await _tap(tester, find.byKey(const ValueKey('persona-remove')));
      await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
      await pumpFrames(tester);
      expect(find.text('Avatar removed.'), findsNothing);
      expect(
        find.text(
          'Removed here, but not saved on this phone yet. Retry at the top.',
        ),
        findsOneWidget,
      );
      expect(find.byType(PersonaBuilderScreen), findsOneWidget);
      expect(find.text(_l.saveStatusFailed), findsOneWidget);
      expect(h.store.saved!.persona, isNotNull, reason: 'disk unchanged');
      h.store.failWrites = false;
      await _tap(tester, find.text('Retry'));
      expect(h.store.saved!.persona, isNull);
    });
  });

  group('motto', () {
    testWidgets('never over the limit, never cut', (tester) async {
      await _pumpYou(tester);
      await _openBuilder(tester);
      final motto = find.byKey(const ValueKey('persona-motto'));
      TextEditingController ctl() =>
          tester.widget<TextField>(motto).controller!;
      await _reveal(tester, motto);
      await tester.ensureVisible(motto);
      await tester.enterText(motto, 'x' * 61);
      await pumpFrames(tester);
      expect(ctl().text, isEmpty, reason: 'refused, not truncated');
      await tester.enterText(motto, 'x' * 60);
      await pumpFrames(tester);
      expect(ctl().text, 'x' * 60);
      expect(find.text('60/60'), findsOneWidget);
      // Emoji take more than one unit: 16 × 4 = 64 is refused.
      await tester.enterText(motto, '👍🏽' * 16);
      await pumpFrames(tester);
      expect(ctl().text, 'x' * 60);
    });

    testWidgets('an older, longer motto must be shortened before saving', (
      tester,
    ) async {
      final h = await _pumpYou(
        tester,
        data: _data(persona: _persona(_saved, motto: 'y' * 70)),
      );
      await _openBuilder(tester);
      await _pick(tester, BuilderCategory.hair, HairStyle.afro);
      expect(
        find.text('A little too long. Shorten it to save.'),
        findsOneWidget,
      );
      expect(_enabled(tester, _save), isFalse);
      final motto = find.byKey(const ValueKey('persona-motto'));
      await _reveal(tester, motto);
      await tester.ensureVisible(motto);
      await tester.enterText(motto, 'y' * 59);
      await pumpFrames(tester);
      expect(find.text('A little too long. Shorten it to save.'), findsNothing);
      await _tap(tester, _save);
      expect(h.state.persona!.motto, 'y' * 59);
      expect(h.state.persona!.avatar.hair, HairStyle.afro);
    });
  });

  group('You profile', () {
    testWidgets('shows the avatar, name and motto; opens the builder', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpYou(
        tester,
        data: _data(persona: _persona(_saved, motto: 'Steady')),
      );
      expect(find.byType(YouTab), findsOneWidget);
      expect(_profileAvatar(tester).avatar, _saved);
      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('“Steady”'), findsOneWidget);
      expect(find.text('Edit your avatar'), findsOneWidget);
      expect(find.bySemanticsLabel('Your avatar'), findsOneWidget);
      // The portrait opens the builder too.
      await _tap(tester, find.byKey(const ValueKey('you-portrait')));
      expect(find.byType(PersonaBuilderScreen), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('without an avatar: the emblem and "Create your avatar"', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpYou(tester);
      expect(_profileAvatar(tester).avatar, isNull);
      expect(find.bySemanticsLabel('No avatar yet'), findsOneWidget);
      await _tap(tester, find.text('Create your avatar'));
      expect(find.byType(PersonaBuilderScreen), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a blank motto is not shown', (tester) async {
      await _pumpYou(
        tester,
        data: _data(persona: _persona(_saved, motto: '  ')),
      );
      expect(find.byKey(const ValueKey('you-motto')), findsNothing);
    });
  });

  group('categories', () {
    test('every part of every category is offered, in order', () {
      expect(BuilderCategory.skin.options, [null, ...kSkinTonePresentation]);
      final all = {
        for (final c in BuilderCategory.values) ...c.options.nonNulls,
      };
      for (final values in [
        SkinTone.values,
        FaceShape.values,
        HairStyle.values,
        HairColor.values,
        FacialHair.values,
        Eyewear.values,
        SkinMark.values,
        Expression.values,
        Headwear.values,
        Garment.values,
        GarmentColor.values,
        Accessory.values,
        Sigil.values,
      ]) {
        expect(all, containsAll(values));
      }
    });

    test('apply and valueOf agree for every choice', () {
      for (final c in BuilderCategory.values) {
        for (final o in c.options) {
          expect(c.valueOf(c.apply(const Avatar(), o)), o, reason: '$c $o');
        }
      }
    });

    test('the preview description names the parts, without "None"', () {
      final text = previewDescription(_l, _saved);
      expect(text, startsWith('Avatar preview. Skin: Honey, Face: Oval'));
      expect(text, contains('Hair: Braids'));
      expect(text, isNot(contains('None')));
      expect(
        previewDescription(_l, const Avatar()),
        contains('Skin: Silhouette'),
      );
    });

    testWidgets('categories are chips with their selected state', (
      tester,
    ) async {
      await _pumpYou(tester);
      await _openBuilder(tester);
      for (final c in BuilderCategory.values) {
        await _tap(tester, _chip(c));
        expect(find.text(c.label(_l)), findsWidgets);
        expect(
          _semantics(tester, _chip(c)).flagsCollection.isSelected ==
              Tristate.isTrue,
          isTrue,
          reason: '$c',
        );
        expect(
          find.byKey(ValueKey('persona-options-${c.name}')),
          findsOneWidget,
        );
      }
    });
  });

  group('colour swatches', () {
    test('colour choices carry their own colour; other choices none', () {
      expect(
        optionSwatch(SkinTone.ebony),
        AvatarPalette.skin(SkinTone.ebony).base,
      );
      expect(
        optionSwatch(HairColor.grey),
        AvatarPalette.hair(HairColor.grey).base,
      );
      expect(
        optionSwatch(GarmentColor.crimson),
        AvatarPalette.garment(GarmentColor.crimson).base,
      );
      expect(optionSwatch(null), isNull, reason: 'silhouette: no skin');
      expect(optionSwatch(HairStyle.afro), isNull);
      expect(optionSwatch(Sigil.elephant), isNull);
    });

    testWidgets('colour tiles show a swatch next to the name', (tester) async {
      await _pumpYou(tester);
      await _openBuilder(tester);
      Finder swatchIn(BuilderCategory c, Enum? value) => find.descendant(
        of: _option(c, value),
        matching: find.byKey(const ValueKey('persona-option-swatch')),
      );
      for (final (c, value, name) in <(BuilderCategory, Enum, String)>[
        (BuilderCategory.skin, SkinTone.umber, 'Umber'),
        (BuilderCategory.hairColor, HairColor.auburn, 'Auburn'),
        (BuilderCategory.garmentColor, GarmentColor.sand, 'Sand'),
      ]) {
        await _tap(tester, _chip(c));
        await _reveal(tester, _option(c, value));
        final dot = tester.widget<Container>(swatchIn(c, value));
        expect(
          (dot.decoration! as BoxDecoration).color,
          optionSwatch(value),
          reason: '$c',
        );
        expect(
          find.descendant(of: _option(c, value), matching: find.text(name)),
          findsOneWidget,
          reason: 'never colour alone',
        );
      }
      await _tap(tester, _chip(BuilderCategory.skin));
      expect(swatchIn(BuilderCategory.skin, null), findsNothing);
      await _tap(tester, _chip(BuilderCategory.hair));
      expect(swatchIn(BuilderCategory.hair, HairStyle.afro), findsNothing);
    });
  });

  group('accessibility', () {
    for (final brightness in Brightness.values) {
      testWidgets('guidelines (${brightness.name})', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: _data(
            persona: _persona(
              const Avatar(headwear: Headwear.laurel),
              motto: 'Steady',
            ),
          ),
          home: const PersonaBuilderScreen(),
          brightness: brightness,
        );
        Future<void> check() async {
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        }

        await check();
        // Locked and kept extras.
        for (final c in [BuilderCategory.headwear, BuilderCategory.sigil]) {
          await _tap(tester, _chip(c));
          await check();
        }
        expect(
          find.bySemanticsLabel(RegExp(r'^Avatar preview\. Skin: Silhouette')),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel(RegExp(r'Save')), findsWidgets);
        semantics.dispose();
      });
    }
  });

  group('screen sizes', () {
    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('builder and profile fit $size (${brightness.name})', (
          tester,
        ) async {
          final h = await _pumpYou(
            tester,
            data: _data(
              persona: _persona(
                const Avatar(
                  skinTone: SkinTone.chestnut,
                  hair: HairStyle.ponytail,
                  headwear: Headwear.laurel,
                ),
                motto: 'Steady, not fast — one honest step a day.',
              ),
            ),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await expectNoOverflow(tester);
          await _openBuilder(tester);
          await expectNoOverflow(tester);
          for (final c in BuilderCategory.values) {
            await _tap(tester, _chip(c));
            await expectNoOverflow(tester);
          }
          // The honest failure state and the dialogs fit too.
          h.store.failWrites = true;
          await _tap(tester, _option(BuilderCategory.sigil, Sigil.sun));
          await _tap(tester, _save);
          expect(find.text(_l.saveStatusFailed), findsOneWidget);
          await expectNoOverflow(tester);
          await _clearSnackBars(tester);
          await _tap(tester, find.byKey(const ValueKey('persona-remove')));
          await expectNoOverflow(tester);
          await tester.tap(find.text('Cancel'));
          await pumpFrames(tester);
        });
      }
    }
  });
}
