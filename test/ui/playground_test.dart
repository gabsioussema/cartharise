// The Playground and its keepsakes (docs/plans/evolve.md, Step 1 › B):
// Try, Notice, Make it yours with "Choose your reward", the Collection, the
// Campaign invitation and the builder's lock text under reward picks.
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/l10n/app_localizations_en.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/campaign/attempt_sheet.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/campaign_invite.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/campaign/campaign_pages.dart';
import 'package:cartharise/ui/campaign/campaign_view.dart';
import 'package:cartharise/ui/campaign/chapters_screen.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/campaign/experiment_entry_sheet.dart';
import 'package:cartharise/ui/campaign/make_it_yours_screen.dart';
import 'package:cartharise/ui/campaign/notice_screen.dart';
import 'package:cartharise/ui/campaign/reward_sheet.dart';
import 'package:cartharise/ui/campaign/route_screen.dart';
import 'package:cartharise/ui/campaign/try_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/missions/quest_sheet.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
import 'package:cartharise/ui/persona/builder_categories.dart';
import 'package:cartharise/ui/persona/builder_options.dart';
import 'package:cartharise/ui/persona/persona_builder.dart';
import 'package:cartharise/ui/persona/persona_ops.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

final _l = AppLocalizationsEn();
final _t = DateTime(2026, 11, 3, 9);

String _two(int i) => i.toString().padLeft(2, '0');

ReflectionAnswer _answer(String id) =>
    ReflectionAnswer(promptId: id, body: 'Answer', updatedAt: _t);

const _avatar = Avatar(
  skinTone: SkinTone.copper,
  hair: HairStyle.coily,
  garment: Garment.robe,
);

/// The first chapter written (the Observer), a quest done (the
/// Practitioner) and an attempt (the Challenger): three reward picks.
AppData _threePicks({
  bool game = true,
  Avatar? avatar = _avatar,
  Set<Unlockable> kept = const {},
}) => onboardedData(settings: AppSettings(game: game)).copyWith(
  journeys: [
    Journey(
      id: 'j1',
      startedAt: _t,
      answers: {
        for (var i = 1; i <= 4; i++)
          'morning.${_two(i)}': _answer('morning.${_two(i)}'),
      },
    ),
  ],
  currentJourneyId: () => 'j1',
  quests: [
    Quest(
      id: 'q1',
      title: 'Walk',
      createdAt: _t,
      completedOn: const {'2026-11-03'},
    ),
  ],
  campaignLog: [
    BattleLogEntry(
      id: 'a1',
      day: '2026-11-03',
      attempt: 'Wrote',
      createdAt: _t,
    ),
  ],
  persona: () =>
      avatar == null ? null : Persona(avatar: avatar, motto: '', updatedAt: _t),
  avatarUnlocked: kept,
);

/// Builds [finder] if the page's list has not yet (rows below the fold are
/// built lazily), scrolling down from where it is.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  final list = find
      .byWidgetPredicate(
        (w) =>
            w is Scrollable &&
            axisDirectionToAxis(w.axisDirection) == Axis.vertical,
      )
      .last;
  await tester.scrollUntilVisible(finder, 200, scrollable: list);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.ensureVisible(finder);
  await pumpFrames(tester, count: 2);
  await tester.tap(finder);
  await pumpFrames(tester);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await pumpFrames(tester);
}

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _waitOutSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await pumpFrames(tester, count: 4);
}

Future<void> _expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  group('Try', () {
    Future<CarthaHarness> pumpTry(
      WidgetTester tester, {
      AppData? data,
      Widget home = const TryScreen(),
    }) => pumpCartha(
      tester,
      data: data ?? onboardedData(),
      home: home,
      size: const Size(390, 1400),
    );

    testWidgets('one experiment at a time: chapter, title, minutes, steps '
        'and "+10 XP" the first time', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpTry(tester);
      expect(_key('try-card-try.terrain.01'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('try-card-try.terrain.02')),
        findsNothing,
      );
      expect(find.text('SEE THE TERRAIN'), findsOneWidget);
      expect(find.text('Try terrain 1'), findsOneWidget);
      expect(find.text('About 5 min'), findsOneWidget);
      expect(find.text('Step one for terrain 1.'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Step 1: Step one for terrain 1.'),
        findsOneWidget,
      );
      expect(find.text('1 of 10'), findsOneWidget);
      expect(_key('try-xp'), findsOneWidget);
      expect(
        tester.getSemantics(_key('try-xp')).label,
        contains('Earns 10 XP the first time'),
      );
      semantics.dispose();
    });

    testWidgets('next and previous go round the list; a typed note waits '
        'for its experiment', (tester) async {
      await pumpTry(tester);
      await tester.enterText(_key('try-note'), 'Half a note');
      await _tap(tester, _key('try-next'));
      expect(_key('try-card-try.terrain.02'), findsOneWidget);
      expect(find.text('2 of 10'), findsOneWidget);
      expect(
        tester.widget<TextField>(_key('try-note')).controller!.text,
        isEmpty,
      );
      await _tap(tester, _key('try-previous'));
      await _tap(tester, _key('try-previous'));
      expect(_key('try-card-try.plan.02'), findsOneWidget);
      expect(find.text('10 of 10'), findsOneWidget);
      await _tap(tester, _key('try-next'));
      expect(_key('try-card-try.terrain.01'), findsOneWidget);
      expect(
        tester.widget<TextField>(_key('try-note')).controller!.text,
        'Half a note',
      );
    });

    testWidgets('a typed note is kept on the phone as a draft: leaving or a '
        'restart never drops it; trying clears it', (tester) async {
      const note = '  Half a note, “kept” & <exact> 🌱 ';
      final h = await pumpTry(tester);
      await tester.enterText(_key('try-note'), note);
      // Debounced autosave, exactly as typed.
      await tester.pump(const Duration(seconds: 1));
      await _settle(tester);
      expect(h.state.data.tryNoteDrafts, {'try.terrain.01': note});
      expect(h.store.saved!.tryNoteDrafts, {'try.terrain.01': note});

      // Another experiment's note is its own draft; switching keeps both.
      await _tap(tester, _key('try-next'));
      await tester.enterText(_key('try-note'), 'Second');
      await tester.pumpWidget(const SizedBox()); // leaving saves at once
      await _settle(tester);
      expect(h.store.saved!.tryNoteDrafts, {
        'try.terrain.01': note,
        'try.terrain.02': 'Second',
      });

      // A restart: the words come back where they were typed.
      final again = await pumpTry(tester, data: h.store.saved);
      expect(
        tester.widget<TextField>(_key('try-note')).controller!.text,
        note,
      );
      // "I tried it" moves the note into the try and clears its draft.
      await _tap(tester, _key('try-done'));
      await _settle(tester);
      expect(again.state.experimentLog.single.note, note);
      expect(again.state.data.tryNoteDrafts, {'try.terrain.02': 'Second'});
      expect(again.store.saved!.tryNoteDrafts, {'try.terrain.02': 'Second'});
      // Blank → no draft at all.
      await _tap(tester, _key('try-next'));
      expect(
        tester.widget<TextField>(_key('try-note')).controller!.text,
        'Second',
      );
      await tester.enterText(_key('try-note'), '   ');
      await tester.pump(const Duration(seconds: 1));
      await _settle(tester);
      expect(again.state.data.tryNoteDrafts, isEmpty);
    });

    testWidgets('starts at the first experiment not tried; or at a chapter', (
      tester,
    ) async {
      await pumpTry(
        tester,
        data: onboardedData().copyWith(
          experimentLog: [
            ExperimentEntry(
              id: 'e1',
              experimentId: 'try.terrain.01',
              day: '2026-11-01',
              createdAt: _t,
            ),
          ],
        ),
      );
      expect(_key('try-card-try.terrain.02'), findsOneWidget);
    });

    testWidgets('"I tried it" keeps the note exactly as typed and adds no '
        'task; "Add to my tasks" adds one and records no try', (tester) async {
      final h = await pumpTry(tester);
      await tester.enterText(_key('try-note'), '  Odd, in a good way ');
      await _tap(tester, _key('try-done'));
      await _settle(tester);
      final entry = h.state.experimentLog.single;
      expect(entry.experimentId, 'try.terrain.01');
      expect(entry.note, '  Odd, in a good way ');
      expect(entry.day, '2026-11-03');
      expect(h.store.saved!.experimentLog.single.note, entry.note);
      expect(h.state.data.quests, isEmpty, reason: 'never automatic');
      expect(find.text('Saved to your Collection.'), findsOneWidget);
      expect(
        tester.widget<TextField>(_key('try-note')).controller!.text,
        isEmpty,
      );
      // Tried: said in words; no more XP to show for it.
      expect(_key('try-tried'), findsOneWidget);
      expect(_key('try-xp'), findsNothing);
      expect(h.state.campaign.xpFromActions, kXpPerExperiment);

      await _waitOutSnackBars(tester);
      await _tap(tester, _key('try-add-task'));
      await _settle(tester);
      final quest = h.state.data.quests.single;
      expect(quest.title, 'Try terrain 1');
      expect(quest.source, QuestSource.experiment);
      expect(h.state.experimentLog, hasLength(1), reason: 'not a try');
      expect(find.text('Added to your tasks.'), findsOneWidget);

      // Again: the open task is reused, never doubled.
      await _waitOutSnackBars(tester);
      await _tap(tester, _key('try-add-task'));
      await _settle(tester);
      expect(h.state.data.quests, hasLength(1));
      expect(find.text('Already in your tasks.'), findsOneWidget);
    });

    testWidgets('adding first, then trying: still separate', (tester) async {
      final h = await pumpTry(tester);
      await _tap(tester, _key('try-add-task'));
      await _settle(tester);
      expect(h.state.data.quests, hasLength(1));
      expect(h.state.experimentLog, isEmpty);
      expect(h.state.campaign.xpFromActions, 0, reason: 'adding earns nothing');
      await _waitOutSnackBars(tester);
      await _tap(tester, _key('try-done'));
      await _settle(tester);
      expect(h.state.experimentLog, hasLength(1));
      expect(h.state.data.quests, hasLength(1));
      expect(h.state.data.quests.single.completedOn, isEmpty);
    });

    testWidgets('a failed save is said so (never "saved"), with Retry on top', (
      tester,
    ) async {
      final h = await pumpTry(tester);
      h.store.failWrites = true;
      await _tap(tester, _key('try-done'));
      await _settle(tester);
      expect(find.text('Saved to your Collection.'), findsNothing);
      expect(
        find.text('Not saved on this phone yet. Retry at the top.'),
        findsOneWidget,
      );
      expect(find.text(_l.saveStatusFailed), findsOneWidget);
      expect(h.store.saved!.experimentLog, isEmpty);

      await _waitOutSnackBars(tester);
      h.store.failWrites = false;
      await _tap(tester, find.text('Retry'));
      await _settle(tester);
      expect(h.store.saved!.experimentLog, hasLength(1));
      expect(find.text(_l.saveStatusFailed), findsNothing);
    });

    testWidgets('no XP chip with the game layer off', (tester) async {
      await pumpTry(
        tester,
        data: onboardedData(settings: const AppSettings(game: false)),
      );
      expect(_key('try-card-try.terrain.01'), findsOneWidget);
      expect(_key('try-xp'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
    });

    testWidgets('a task added from Try is labelled in Missions', (
      tester,
    ) async {
      final h = await pumpTry(tester);
      await _tap(tester, _key('try-add-task'));
      await _settle(tester);
      final id = h.state.data.quests.single.id;
      await tester.pumpWidget(const SizedBox());
      await pumpCartha(
        tester,
        data: h.store.saved,
        home: const CompassTab(initial: CompassSection.missions),
      );
      expect(_key('quest-source-$id'), findsOneWidget);
    });
  });

  group('Notice', () {
    testWidgets('illustrated cards that open their question or lesson, and '
        'say in words what is written or read', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData().copyWith(
          journeys: [
            Journey(
              id: 'j1',
              startedAt: _t,
              answers: {'morning.01': _answer('morning.01')},
            ),
          ],
          currentJourneyId: () => 'j1',
          lessonsRead: const {'lesson.01'},
        ),
        home: const NoticeScreen(),
        size: const Size(390, 1600),
      );
      final first = _key('notice-card-notice.01');
      final second = _key('notice-card-notice.02');
      Finder inCard(Finder card, String text) =>
          find.descendant(of: card, matching: find.text(text));
      expect(inCard(first, 'Notice 1 title'), findsOneWidget);
      expect(inCard(first, 'REFLECTION'), findsOneWidget);
      expect(inCard(first, 'Opens: Morning 1 title'), findsOneWidget);
      expect(inCard(first, 'Written'), findsOneWidget);
      expect(inCard(second, 'LESSON'), findsOneWidget);
      expect(inCard(second, 'Opens: Lesson 1 title'), findsOneWidget);
      expect(inCard(second, 'Read'), findsOneWidget);
      // The lesson's own illustration; the question gets its glyph.
      expect(
        find.descendant(
          of: second,
          matching: _key('lesson-illustration-lesson.01'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: first, matching: find.byType(GlyphIcon)),
        findsOneWidget,
      );
      // A question's glyph sits in a small tile beside its kind, not alone
      // in an empty box the size of a lesson scene.
      final tile = tester.getSize(_key('notice-glyph-notice.01'));
      expect(tile.height, lessThan(56));
      expect(
        tester.getCenter(_key('notice-glyph-notice.01')).dy,
        moreOrLessEquals(
          tester.getCenter(inCard(first, 'REFLECTION')).dy,
          epsilon: 12,
        ),
        reason: 'beside the kind',
      );

      await _tap(tester, first);
      expect(
        tester
            .widget<GuidedPromptScreen>(find.byType(GuidedPromptScreen))
            .promptId,
        'morning.01',
      );
      Navigator.of(tester.element(find.byType(GuidedPromptScreen))).pop();
      await pumpFrames(tester);
      await _tap(tester, second);
      expect(
        tester.widget<LessonScreen>(find.byType(LessonScreen)).lessonId,
        'lesson.01',
      );
    });

    testWidgets('nothing written or read yet: no status chips', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const NoticeScreen(),
      );
      expect(find.text('Written'), findsNothing);
      expect(find.text('Read'), findsNothing);
    });
  });

  group('Choose your reward', () {
    Future<CarthaHarness> openSheet(WidgetTester tester, AppData data) async {
      final h = await pumpCartha(
        tester,
        data: data,
        home: const MakeItYoursScreen(),
        size: const Size(390, 1400),
      );
      await _tap(tester, _key('campaign-reward-open'));
      expect(find.byType(RewardSheet), findsOneWidget);
      return h;
    }

    Avatar previewed(WidgetTester tester) =>
        tester.widget<AvatarView>(_key('reward-preview')).avatar!;

    testWidgets('the user\'s avatar wearing each option, the suggested one '
        'first and preselected; choosing keeps it for good', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await openSheet(tester, _threePicks());
      expect(find.text('Choose your reward'), findsWidgets);
      expect(
        find.text('3 picks to spend. What you choose stays yours.'),
        findsWidgets,
      );
      // Suggested first: The Observer's Scroll.
      final tiles = tester
          .widgetList<BuilderOptionTile>(find.byType(BuilderOptionTile))
          .toList();
      expect(tiles.first.key, const ValueKey('reward-option-accessoryScroll'));
      expect(tiles.first.note, 'Suggested · Carry');
      expect(tiles.first.selected, isTrue);
      expect(tiles, hasLength(Unlockable.values.length));
      expect(previewed(tester), _avatar.copyWith(accessory: Accessory.scroll));

      // Each option's portrait is the user's avatar wearing it.
      for (final u in Unlockable.values) {
        final portrait = tester.widget<AvatarView>(
          find.descendant(
            of: _key('reward-option-${u.name}'),
            matching: find.byType(AvatarView),
          ),
        );
        expect(portrait.avatar, avatarWearing(_avatar, u), reason: '$u');
        expect(portrait.avatar!.uses(u), isTrue, reason: '$u');
      }

      await _tap(tester, _key('reward-option-sigilStar'));
      expect(previewed(tester).sigil, Sigil.star);
      expect(
        tester.getSemantics(_key('reward-preview')).label,
        contains('Your avatar wearing North star'),
      );
      expect(find.text('Choose North star'), findsOneWidget);
      // Nothing is spent before the choice is confirmed.
      expect(h.state.picksLeft, 3);

      await _tap(tester, _key('reward-confirm'));
      await _settle(tester);
      expect(find.byType(RewardSheet), findsNothing);
      expect(h.state.data.avatarUnlocked, {Unlockable.sigilStar});
      expect(h.store.saved!.avatarUnlocked, {Unlockable.sigilStar});
      expect(h.state.picksLeft, 2);
      expect(h.state.canUse(Sigil.star), isTrue);
      expect(find.text('North star is yours to keep.'), findsOneWidget);
      // Choosing is not wearing: the avatar is unchanged until the builder.
      expect(h.state.persona!.avatar, _avatar);
      expect(find.text('1 of 13 extras unlocked'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('extras already kept or worn are not offered', (tester) async {
      await openSheet(
        tester,
        _threePicks(
          avatar: _avatar.copyWith(sigil: Sigil.path),
          kept: {Unlockable.accessoryScroll},
        ),
      );
      expect(_key('reward-option-sigilPath'), findsNothing);
      expect(_key('reward-option-accessoryScroll'), findsNothing);
      // The next reached milestone's extra is suggested instead.
      final first = tester
          .widgetList<BuilderOptionTile>(find.byType(BuilderOptionTile))
          .first;
      expect(first.key, const ValueKey('reward-option-garmentBronze'));
      expect(first.note, 'Suggested · Colour');
    });

    testWidgets('without an avatar the silhouette previews (and colours '
        'carry their swatch)', (tester) async {
      await openSheet(tester, _threePicks(avatar: null));
      expect(previewed(tester).accessory, Accessory.scroll);
      expect(previewed(tester).skinTone, isNull);
      final sage = tester.widget<BuilderOptionTile>(
        _key('reward-option-garmentSage'),
      );
      expect(sage.swatch, isNotNull);
    });

    testWidgets('no pick left: no Choose button, when the next pick comes', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const MakeItYoursScreen(),
      );
      expect(h.state.picksLeft, 0);
      expect(_key('campaign-reward-open'), findsNothing);
      expect(find.text('Next pick at New Carthage'), findsOneWidget);
    });

    testWidgets('game off: everything is already open, nothing to choose', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _threePicks(game: false),
        home: const MakeItYoursScreen(),
      );
      expect(h.state.picksLeft, 0);
      expect(_key('campaign-reward-open'), findsNothing);
      expect(
        find.text('With the Campaign off, every extra is already open.'),
        findsOneWidget,
      );
      expect(find.text('13 of 13 extras unlocked'), findsOneWidget);
    });

    testWidgets('the sheet says so when the game is turned off meanwhile', (
      tester,
    ) async {
      final h = await openSheet(tester, _threePicks());
      await h.state.setGameEnabled(false);
      await _settle(tester);
      expect(_key('reward-confirm'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(RewardSheet),
          matching: find.text(
            'With the Campaign off, every extra is already open.',
          ),
        ),
        findsOneWidget,
      );
      expect(h.state.data.avatarUnlocked, isEmpty);
    });

    testWidgets('a failed save is said so, never "yours to keep"', (
      tester,
    ) async {
      final h = await openSheet(tester, _threePicks());
      h.store.failWrites = true;
      await _tap(tester, _key('reward-confirm'));
      await _settle(tester);
      expect(find.text('Scroll is yours to keep.'), findsNothing);
      expect(
        find.text('Not saved on this phone yet. Retry at the top.'),
        findsOneWidget,
      );
      expect(find.text(_l.saveStatusFailed), findsOneWidget);
      expect(h.store.saved!.avatarUnlocked, isEmpty);
    });

    test('every extra maps to the part it puts on', () {
      for (final u in Unlockable.values) {
        expect(requirementOf(extraPart(u)), u, reason: '$u');
        expect(avatarWearing(const Avatar(), u).uses(u), isTrue, reason: '$u');
        expect(avatarWearing(_avatar, u).skinTone, _avatar.skinTone);
      }
    });
  });

  group('the builder under reward picks', () {
    testWidgets('a pick left: a locked extra says how to open it', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _threePicks(),
        home: const PersonaBuilderScreen(),
        size: const Size(390, 1600),
      );
      expect(h.state.picksLeft, 3);
      await _tap(
        tester,
        _key('persona-category-${BuilderCategory.sigil.name}'),
      );
      final star = _key('persona-option-sigil-star');
      expect(
        find.descendant(
          of: star,
          matching: find.text('Choose it with a reward pick'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: star, matching: find.byIcon(Icons.lock_outline)),
        findsOneWidget,
      );
    });
  });

  group('the Collection', () {
    AppData collected({bool game = true}) =>
        onboardedData(settings: AppSettings(game: game)).copyWith(
          journeys: [
            Journey(
              id: 'j1',
              startedAt: _t,
              answers: {
                for (var i = 1; i <= 4; i++)
                  'morning.${_two(i)}': _answer('morning.${_two(i)}'),
              },
            ),
          ],
          currentJourneyId: () => 'j1',
          quests: [
            Quest(
              id: 'q1',
              title: 'Walk',
              createdAt: _t,
              completedOn: const {'2026-11-02'},
            ),
          ],
          experimentLog: [
            ExperimentEntry(
              id: 'e2',
              experimentId: 'try.pattern.01',
              day: '2026-11-03',
              note: '  Took the long way. ',
              createdAt: _t,
            ),
            ExperimentEntry(
              id: 'e1',
              experimentId: 'try.nowhere.09',
              day: '2026-11-01',
              createdAt: _t,
            ),
          ],
          avatarUnlocked: const {Unlockable.sigilStar},
        );

    Future<CarthaHarness> pumpCollection(
      WidgetTester tester, {
      AppData? data,
    }) => pumpCartha(
      tester,
      data: data ?? collected(),
      home: const CollectionScreen(),
      size: const Size(390, 2600),
    );

    testWidgets('experiments tried, notes exactly as typed', (tester) async {
      await pumpCollection(tester);
      // Section labels are set in capitals.
      expect(find.text('2 EXPERIMENTS TRIED'), findsOneWidget);
      // Changed by design (A10): one row per experiment, each try inside.
      final pattern = _key('collection-experiment-try.pattern.01');
      expect(
        find.descendant(of: pattern, matching: find.text('Try pattern 1')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: pattern,
          matching: _key('collection-tried-e2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _key('collection-tried-e2'),
          matching: find.text('  Took the long way. '),
        ),
        findsOneWidget,
      );
      // An experiment from a newer version still shows, honestly named.
      expect(
        find.descendant(
          of: _key('collection-experiment-try.nowhere.09'),
          matching: find.text('An experiment'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('an experiment tried twice is one row with both tries, and '
        'the count matches the rows', (tester) async {
      final data = collected();
      await pumpCollection(
        tester,
        data: data.copyWith(
          experimentLog: [
            ExperimentEntry(
              id: 'e3',
              experimentId: 'try.pattern.01',
              day: '2026-11-04',
              note: 'Again, shorter.',
              createdAt: _t,
            ),
            ...data.experimentLog,
          ],
        ),
      );
      expect(find.text('2 EXPERIMENTS TRIED'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith(
                'collection-experiment-',
              ),
        ),
        findsNWidgets(2),
      );
      final pattern = _key('collection-experiment-try.pattern.01');
      expect(
        find.descendant(of: pattern, matching: find.text('Try pattern 1')),
        findsOneWidget,
        reason: 'the title once',
      );
      for (final id in ['e3', 'e2']) {
        expect(
          find.descendant(of: pattern, matching: _key('collection-tried-$id')),
          findsOneWidget,
        );
      }
      expect(find.text('Again, shorter.'), findsOneWidget);
    });

    testWidgets('achievements with their badge and how each was earned', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCollection(tester);
      expect(find.text('3 of 7 earned'), findsOneWidget);
      String label(Achievement a) =>
          tester.getSemantics(_key('collection-achievement-${a.name}')).label;
      expect(label(Achievement.observer), endsWith('Earned by reflecting'));
      // Changed by design (A1): trying names the experiment that earned it.
      expect(
        label(Achievement.pathfinder),
        endsWith('Earned by trying: Try pattern 1'),
      );
      expect(label(Achievement.practitioner), endsWith('Earned by doing'));
      expect(label(Achievement.visionary), endsWith('Not yet'));
      expect(find.text('Earned by trying: Try pattern 1'), findsOneWidget);
      final badges = {
        for (final b in tester.widgetList<AchievementBadge>(
          find.byType(AchievementBadge),
        ))
          b.achievement: b.earned,
      };
      expect(badges, hasLength(7));
      expect(badges[Achievement.observer], isTrue);
      expect(badges[Achievement.pathfinder], isTrue);
      expect(badges[Achievement.visionary], isFalse);
      semantics.dispose();
    });

    testWidgets('a badge earned by trying makes no claim about answers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpCollection(tester);
      // The Pathfinder came from an experiment, not from its questions.
      final tile = _key('collection-achievement-pathfinder');
      final label = tester.getSemantics(tile).label;
      final asks = _l.campaignAchievementPathfinderBody;
      expect(label, contains(asks));
      // What it asks, in the present tense — never a past-tense claim.
      expect(asks, startsWith('Answer every'));
      expect(asks, contains('or try one of its experiments'));
      for (final claim in ['Answered', 'Wrote', 'Explored', 'Described']) {
        expect(label, isNot(contains(claim)));
      }
      for (final a in Achievement.values) {
        final body = switch (a) {
          Achievement.observer => _l.campaignAchievementObserverBody,
          Achievement.pathfinder => _l.campaignAchievementPathfinderBody,
          Achievement.visionary => _l.campaignAchievementVisionaryBody,
          Achievement.watchful => _l.campaignAchievementWatchfulBody,
          Achievement.strategist => _l.campaignAchievementStrategistBody,
          Achievement.practitioner => _l.campaignAchievementPractitionerBody,
          Achievement.challenger => _l.campaignAchievementChallengerBody,
        };
        expect(
          RegExp(r'^(Answer|Complete|Record) ').hasMatch(body),
          isTrue,
          reason: '${a.name}: "$body" says what it asks',
        );
      }
      expect(
        find.descendant(
          of: tile,
          matching: find.text('Earned by trying: Try pattern 1'),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Earned by reflecting, trying or doing. Never by what you write.',
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('with the game off: what was tried, no achievements', (
      tester,
    ) async {
      await pumpCollection(tester, data: collected(game: false));
      expect(_key('collection-tried-e2'), findsOneWidget);
      expect(find.byType(AchievementBadge), findsNothing);
      expect(_key('collection-achievement-observer'), findsNothing);
    });

    testWidgets('extras chosen; with the game off, all open', (tester) async {
      await pumpCollection(tester);
      expect(
        find.descendant(
          of: _key('collection-extra-sigilStar'),
          matching: find.text('North star'),
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      await pumpCollection(tester, data: collected(game: false));
      expect(_key('collection-extra-sigilStar'), findsNothing);
      expect(
        find.text('With the Campaign off, every extra is already open.'),
        findsOneWidget,
      );
    });

    testWidgets('nothing tried yet: a way into Try', (tester) async {
      await pumpCollection(tester, data: onboardedData());
      expect(_key('collection-tried-empty'), findsOneWidget);
      await _tap(tester, _key('collection-open-try'));
      expect(find.byType(TryScreen), findsOneWidget);
    });

    testWidgets('a note can be corrected (exactly as typed) or the try '
        'removed (asks first)', (tester) async {
      final h = await pumpCollection(tester);
      await _tap(tester, _key('collection-tried-e2'));
      await tester.enterText(_key('tried-edit-note'), 'Took the long way');
      await _tap(tester, _key('tried-edit-save'));
      await _settle(tester);
      final entry = h.state.experimentLog.firstWhere((e) => e.id == 'e2');
      expect(entry.note, 'Took the long way');
      expect(entry.editedAt, isNotNull);
      expect(entry.day, '2026-11-03');

      await _tap(tester, _key('collection-tried-e2'));
      await _tap(tester, _key('tried-edit-remove'));
      expect(find.text('Remove this try?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Remove this try'));
      await _settle(tester);
      expect(h.state.experimentLog.map((e) => e.id), ['e1']);
      expect(find.text('Try removed'), findsOneWidget);
    });

    testWidgets('a changed note is never dropped silently: closing the '
        'sheet asks to save or discard', (tester) async {
      final h = await pumpCollection(tester);
      ExperimentEntry e2() =>
          h.state.experimentLog.firstWhere((e) => e.id == 'e2');

      // Closed by a tap outside, then "Discard": nothing changes.
      await _tap(tester, _key('collection-tried-e2'));
      await tester.enterText(_key('tried-edit-note'), 'Changed my mind');
      await tester.tapAt(const Offset(195, 20));
      await _settle(tester);
      expect(find.byType(ExperimentEntrySheet), findsNothing);
      expect(find.text('Save your change?'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Discard'));
      await _settle(tester);
      expect(e2().note, '  Took the long way. ');
      expect(e2().editedAt, isNull);

      // Closed with back, then "Save note": saved exactly as typed.
      await _tap(tester, _key('collection-tried-e2'));
      await tester.enterText(_key('tried-edit-note'), ' Kept, as typed ');
      await tester.binding.handlePopRoute();
      await _settle(tester);
      expect(find.text('Save your change?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Save note'));
      await _settle(tester);
      expect(e2().note, ' Kept, as typed ');
      expect(h.store.saved!.experimentLog.first.note, ' Kept, as typed ');

      // Closed without a change: no question.
      await _tap(tester, _key('collection-tried-e2'));
      await tester.binding.handlePopRoute();
      await _settle(tester);
      expect(find.text('Save your change?'), findsNothing);
    });
  });

  group('the Campaign invitation', () {
    Future<CarthaHarness> pumpInvite(
      WidgetTester tester, {
      AppSettings settings = const AppSettings(game: false, gameInvited: false),
    }) => pumpCartha(
      tester,
      data: onboardedData(settings: settings),
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: const [CampaignInviteCard()],
        ),
      ),
    );

    testWidgets('one short question with Play and Not now', (tester) async {
      await pumpInvite(tester);
      expect(find.text('Play the Campaign?'), findsOneWidget);
      expect(find.text('XP and levels for what you do.'), findsOneWidget);
      expect(_key('campaign-invite-play'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('Play turns the Campaign on and answers for good', (
      tester,
    ) async {
      final h = await pumpInvite(tester);
      await _tap(tester, _key('campaign-invite-play'));
      await _settle(tester);
      expect(h.state.gameEnabled, isTrue);
      expect(h.state.campaignInvitePending, isFalse);
      expect(h.store.saved!.settings.gameInvited, isTrue);
      expect(_key('campaign-invite'), findsNothing);
      expect(find.text('The Campaign is on. It lives in Compass.'), findsOne);
    });

    testWidgets('Not now leaves it off and answers for good', (tester) async {
      final h = await pumpInvite(tester);
      await _tap(tester, _key('campaign-invite-later'));
      await _settle(tester);
      expect(h.state.gameEnabled, isFalse);
      expect(h.state.campaignInvitePending, isFalse);
      expect(_key('campaign-invite'), findsNothing);
      expect(find.text('You can turn it on in You.'), findsOneWidget);
    });

    testWidgets('answered already: nothing at all', (tester) async {
      await pumpInvite(tester, settings: const AppSettings());
      expect(_key('campaign-invite'), findsNothing);
      // Zero height (a zero-size row counts as off screen for finders).
      expect(
        tester
            .getSize(find.byType(CampaignInviteCard, skipOffstage: false))
            .height,
        0,
      );
    });

    testWidgets('a failed save is said so', (tester) async {
      final h = await pumpInvite(tester);
      h.store.failWrites = true;
      await _tap(tester, _key('campaign-invite-play'));
      await _settle(tester);
      expect(
        find.text('The Campaign is on. It lives in Compass.'),
        findsNothing,
      );
      expect(
        find.text('Not saved on this phone yet. Retry at the top.'),
        findsOneWidget,
      );
    });

    // Changed by design (A3): the invitation is answered before the game is
    // on, so the section that shows it is the Playground (game off); Play
    // turns that section into the Campaign hub.
    testWidgets('the Playground shows it while unanswered; Play turns the '
        'section into the Campaign', (tester) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(
          settings: const AppSettings(game: false, gameInvited: false),
        ),
        shell: ShellController(initial: AppTab.compass)
          ..compassSection.value = CompassSection.campaign,
        size: const Size(390, 1400),
      );
      Finder pill(String label) => find.descendant(
        of: find.byType(PillTabs<CompassSection>),
        matching: find.text(label),
      );
      expect(find.byType(PlaygroundView), findsOneWidget);
      expect(pill('Playground'), findsOneWidget);
      expect(_key('campaign-invite'), findsOneWidget);
      await _tap(tester, _key('campaign-invite-play'));
      await _settle(tester);
      expect(h.state.campaignInvitePending, isFalse);
      expect(_key('campaign-invite'), findsNothing);
      expect(find.byType(CampaignView), findsOneWidget);
      expect(pill('Campaign'), findsOneWidget);
    });
  });

  group('reduced motion', () {
    /// Opens a sheet from a button and returns how its route animates.
    Future<AnimationStyle?> sheetStyle(
      WidgetTester tester, {
      required bool motion,
      required AppData data,
      required Future<void> Function(BuildContext) open,
      required Type sheet,
    }) async {
      await pumpCartha(
        tester,
        data: data.copyWith(
          settings: data.settings.copyWith(motion: motion),
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                key: const ValueKey('open-sheet'),
                onPressed: () => open(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(_key('open-sheet'));
      await pumpFrames(tester);
      final route = ModalRoute.of(tester.element(find.byType(sheet)));
      return (route! as ModalBottomSheetRoute<Object?>).sheetAnimationStyle;
    }

    final entry = ExperimentEntry(
      id: 'e1',
      experimentId: 'try.pattern.01',
      day: '2026-11-03',
      createdAt: _t,
    );
    final attempt = BattleLogEntry(
      id: 'a1',
      day: '2026-11-03',
      attempt: 'Wrote',
      createdAt: _t,
    );
    final sheets = <(String, Type, Future<void> Function(BuildContext))>[
      ('reward', RewardSheet, showRewardSheet),
      (
        'tried note',
        ExperimentEntrySheet,
        (c) => showExperimentEntrySheet(c, entry, title: 'Try'),
      ),
      ('attempt', AttemptSheet, (c) => showAttemptSheet(c, attempt)),
      ('quest', QuestSheet, (c) => showQuestSheet(c)),
    ];
    for (final (name, type, open) in sheets) {
      testWidgets('the $name sheet slides only while motion is on', (
        tester,
      ) async {
        expect(
          await sheetStyle(
            tester,
            motion: false,
            data: _threePicks(),
            open: open,
            sheet: type,
          ),
          AnimationStyle.noAnimation,
        );
        await tester.pumpWidget(const SizedBox());
        expect(
          await sheetStyle(
            tester,
            motion: true,
            data: _threePicks(),
            open: open,
            sheet: type,
          ),
          isNull,
        );
      });
    }
  });

  group('guidelines and sizes', () {
    final pages = <(String, Widget, AppData Function())>[
      ('Try', const TryScreen(), _threePicks),
      ('Notice', const NoticeScreen(), _threePicks),
      ('Make it yours', const MakeItYoursScreen(), _threePicks),
      (
        'Collection',
        const CollectionScreen(),
        () => _threePicks(kept: {Unlockable.sigilStar}).copyWith(
          experimentLog: [
            ExperimentEntry(
              id: 'e2',
              experimentId: 'try.pattern.01',
              day: '2026-11-04',
              note: 'Tried it again, with a second long note that wraps.',
              createdAt: _t,
            ),
            ExperimentEntry(
              id: 'e1',
              experimentId: 'try.pattern.01',
              day: '2026-11-03',
              note: 'A long note that goes on for a while to see it wrap.',
              createdAt: _t,
            ),
          ],
        ),
      ),
      (
        'Playground (game off, invitation open)',
        const CompassTab(initial: CompassSection.campaign),
        () => _threePicks(game: false).copyWith(
          settings: const AppSettings(game: false, gameInvited: false),
        ),
      ),
      (
        'Playground (game off)',
        const CompassTab(initial: CompassSection.campaign),
        () => _threePicks(game: false),
      ),
      (
        'Invitation',
        const Scaffold(body: SafeArea(child: CampaignInviteCard())),
        () => onboardedData(
          settings: const AppSettings(game: false, gameInvited: false),
        ),
      ),
    ];

    for (final (name, home, data) in pages) {
      for (final brightness in Brightness.values) {
        testWidgets('$name meets the guidelines (${brightness.name})', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          await pumpCartha(
            tester,
            data: data(),
            home: home,
            brightness: brightness,
          );
          await _expectAccessible(tester);
          semantics.dispose();
        });

        for (final size in kSizeMatrix) {
          testWidgets('$name fits $size (${brightness.name})', (tester) async {
            await pumpCartha(
              tester,
              data: data(),
              home: home,
              size: size.size,
              textScale: size.textScale,
              brightness: brightness,
            );
            await expectNoOverflow(tester);
          });
        }
      }
    }

    for (final brightness in Brightness.values) {
      testWidgets('the reward sheet meets the guidelines '
          '(${brightness.name})', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: _threePicks(),
          home: const MakeItYoursScreen(),
          brightness: brightness,
        );
        await _tap(tester, _key('campaign-reward-open'));
        await _expectAccessible(tester);
        semantics.dispose();
      });

      for (final size in kSizeMatrix) {
        testWidgets('the reward sheet fits $size (${brightness.name})', (
          tester,
        ) async {
          await pumpCartha(
            tester,
            data: _threePicks(),
            home: const MakeItYoursScreen(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await _tap(tester, _key('campaign-reward-open'));
          await expectNoOverflow(tester);
          // The confirm button stays reachable below the options.
          expect(_key('reward-confirm').hitTestable(), findsOneWidget);
        });
      }

      testWidgets('the Battle log, Route and Chapters meet the guidelines '
          '(${brightness.name})', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpCartha(
          tester,
          data: _threePicks(),
          shell: ShellController(initial: AppTab.compass)
            ..compassSection.value = CompassSection.campaign,
          brightness: brightness,
        );
        for (final key in [
          'campaign-link-log',
          'campaign-link-route',
          'campaign-link-chapters',
        ]) {
          await _tap(tester, _key(key));
          await _expectAccessible(tester);
          await tester.pageBack();
          await pumpFrames(tester);
        }
        semantics.dispose();
      });
    }
  });

  testWidgets('AppNav opens every Campaign page', (tester) async {
    await pumpCartha(tester, data: _threePicks());
    final context = tester.element(find.byType(NavigationBar));
    for (final (page, screen) in [
      (CampaignPage.notice, NoticeScreen),
      (CampaignPage.tryIt, TryScreen),
      (CampaignPage.makeItYours, MakeItYoursScreen),
      (CampaignPage.route, CampaignRouteScreen),
      (CampaignPage.chapters, ChaptersScreen),
      (CampaignPage.battleLog, BattleLogScreen),
      (CampaignPage.collection, CollectionScreen),
    ]) {
      AppNav.openCampaignPage(context, page);
      await pumpFrames(tester);
      expect(find.byType(screen), findsOneWidget, reason: '$page');
      await tester.pageBack();
      await pumpFrames(tester);
    }
  });
}
