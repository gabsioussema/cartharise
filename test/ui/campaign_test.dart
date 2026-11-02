import 'dart:async';

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/l10n/app_localizations_en.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/campaign_feedback.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/campaign/campaign_view.dart';
import 'package:cartharise/ui/campaign/chapters_screen.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/campaign/make_it_yours_screen.dart';
import 'package:cartharise/ui/campaign/notice_screen.dart';
import 'package:cartharise/ui/campaign/route_screen.dart';
import 'package:cartharise/ui/campaign/try_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
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

/// A user part-way through: the first chapter written (4 × 5 XP), one quest
/// done today (20 XP), one attempt today (15 XP) → 55 XP. The Observer, the
/// Practitioner and the Challenger are earned: three reward picks.
AppData _data({bool game = true, bool withAttempt = true}) =>
    onboardedData(settings: AppSettings(game: game)).copyWith(
      journeys: [
        Journey(
          id: 'j1',
          startedAt: _t,
          answers: {
            for (var i = 1; i <= 4; i++)
              'morning.${_two(i)}': ReflectionAnswer(
                promptId: 'morning.${_two(i)}',
                body: 'Answer $i',
                updatedAt: _t,
              ),
          },
        ),
      ],
      currentJourneyId: () => 'j1',
      compass: const LifeCompass(
        vision: 'Calm mornings and work I care about.',
        monthProject: 'Finish the first essay',
        constraints: 'Sleep by 23:00. Sundays with family.',
      ),
      quests: [
        Quest(
          id: 'q1',
          title: 'Walk 20 minutes',
          createdAt: _t,
          completedOn: const {'2026-11-03'},
        ),
      ],
      campaignLog: withAttempt
          ? [
              BattleLogEntry(
                id: 'a1',
                day: '2026-11-03',
                attempt: 'Wrote for 25 minutes before work',
                learning: 'Mornings work better',
                createdAt: _t,
              ),
            ]
          : const [],
    );

/// [base] plus one quest completed on each of [days] October days (20 XP
/// each).
AppData _withQuestDays(AppData base, int days) => base.copyWith(
  quests: [
    ...base.quests,
    for (var d = 1; d <= days; d++)
      Quest(
        id: 'oct$d',
        title: 'October $d',
        createdAt: _t,
        completedOn: {'2026-10-${_two(d)}'},
      ),
  ],
);

const _avatar = Avatar(
  skinTone: SkinTone.walnut,
  hair: HairStyle.locs,
  hairColor: HairColor.grey,
  garment: Garment.cloak,
);

Persona _persona({Avatar avatar = _avatar, String motto = ''}) =>
    Persona(avatar: avatar, motto: motto, updatedAt: _t);

Finder _inRoute(Finder f) => find.descendant(
  of: find.byKey(const ValueKey('campaign-route')),
  matching: f,
);

Finder _inStrategist(Finder f) => find.descendant(
  of: find.byKey(const ValueKey('campaign-strategist')),
  matching: f,
);

ShellController _onCampaign() =>
    ShellController(initial: AppTab.compass)
      ..compassSection.value = CompassSection.campaign;

Future<CarthaHarness> _pumpCampaign(
  WidgetTester tester, {
  AppData? data,
  Size size = const Size(390, 1400),
  double textScale = 1,
  Brightness brightness = Brightness.dark,
}) => pumpCartha(
  tester,
  data: data ?? _data(),
  shell: _onCampaign(),
  size: size,
  textScale: textScale,
  brightness: brightness,
);

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await pumpFrames(tester, count: 2);
  await tester.tap(finder);
  await pumpFrames(tester);
}

/// Lets storage writes (microtasks) land, then draws.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await pumpFrames(tester);
}

/// Opens one of the hub's invitations or links by key.
Future<void> _open(WidgetTester tester, String key) =>
    _tapVisible(tester, find.byKey(ValueKey(key)));

final _judgement = RegExp(
  r'streak|score|fail|missed|behind|overdue|lazy|you fixed your life|'
  r'should have|punish',
  caseSensitive: false,
);

List<String> _texts(WidgetTester tester) => [
  for (final w in tester.widgetList<Text>(find.byType(Text)))
    w.data ?? w.textSpan?.toPlainText() ?? '',
];

TextEditingController _field(WidgetTester tester, String key) =>
    tester.widget<TextField>(find.byKey(ValueKey(key))).controller!;

void main() {
  group('the Campaign hub (evolve step 1)', () {
    testWidgets('status, three invitations and four small links; the long '
        'content lives on its own pages', (tester) async {
      await _pumpCampaign(tester);
      expect(find.byType(CampaignView), findsOneWidget);
      expect(find.text('Level 1 · 55 XP'), findsOneWidget);
      // Hannibal's route: level 1 is Carthage; 45 XP more reaches the next.
      expect(find.text("You're at Carthage"), findsOneWidget);
      expect(find.text('45 XP to New Carthage'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp("Hannibal's route: Carthage, stop 1 of 7"),
        ),
        findsOneWidget,
      );

      // Notice · Try · Make it yours: a word and one line each.
      expect(find.text('Notice'), findsOneWidget);
      expect(find.text('A question or idea to look at again.'), findsOne);
      expect(find.text('Try'), findsOneWidget);
      expect(find.text('A tiny experiment for real life.'), findsOneWidget);
      expect(find.text('Make it yours'), findsOneWidget);
      // The three achievements gave three reward picks, not spent yet.
      expect(find.text('3 reward picks to choose'), findsOneWidget);

      for (final link in ['Route', 'Chapters', 'Battle log', 'Collection']) {
        expect(find.text(link), findsOneWidget, reason: link);
      }
      // Compact: chapters, the map, the boss and achievements are elsewhere.
      expect(find.text('See the terrain'), findsNothing);
      expect(find.text('Win condition · Vision'), findsNothing);
      expect(find.byKey(const ValueKey('campaign-attempt')), findsNothing);
      expect(find.text('The Challenger'), findsNothing);
      // The honest note stays.
      expect(find.textContaining('Cartharise additions'), findsOneWidget);
    });

    testWidgets('no pick left: the invitation names the avatar and motto', (
      tester,
    ) async {
      await _pumpCampaign(tester, data: onboardedData());
      expect(find.text('Your avatar and motto.'), findsOneWidget);
      expect(find.textContaining('reward pick'), findsNothing);
    });

    testWidgets('one cue per idea: the mirror, the seedling and the user\'s '
        'own avatar (not the Campaign\'s progress path)', (tester) async {
      await _pumpCampaign(tester);
      GlyphIcon? glyphIn(String key) {
        final found = find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(GlyphIcon),
        );
        return found.evaluate().isEmpty ? null : tester.widget(found);
      }

      expect(glyphIn('campaign-open-notice')?.glyph, CarthaGlyph.notice);
      expect(glyphIn('campaign-open-try')?.glyph, CarthaGlyph.experiment);
      expect(glyphIn('campaign-open-yours'), isNull);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('campaign-open-yours')),
          matching: find.byType(AvatarView),
        ),
        findsOneWidget,
      );
    });

    testWidgets('each invitation and link opens its own page', (tester) async {
      await _pumpCampaign(tester);
      for (final (key, screen) in [
        ('campaign-open-notice', NoticeScreen),
        ('campaign-open-try', TryScreen),
        ('campaign-open-yours', MakeItYoursScreen),
        ('campaign-link-route', CampaignRouteScreen),
        ('campaign-link-chapters', ChaptersScreen),
        ('campaign-link-log', BattleLogScreen),
        ('campaign-link-collection', CollectionScreen),
      ]) {
        await _open(tester, key);
        expect(find.byType(screen), findsOneWidget, reason: key);
        await tester.pageBack();
        await pumpFrames(tester);
        expect(find.byType(screen), findsNothing, reason: key);
      }
    });

    testWidgets('explains how XP is earned, experiments included', (
      tester,
    ) async {
      await _pumpCampaign(tester);
      await _open(tester, 'campaign-xp-how');
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('+20 XP for each quest you complete, counting up to 3 a day'),
        findsOneWidget,
      );
      expect(
        find.text('+10 XP for each new experiment you try (once each)'),
        findsOneWidget,
      );
      expect(find.textContaining('Rest costs nothing'), findsOneWidget);
      expect(find.textContaining('ignores what you write'), findsOne);
      expect(find.textContaining('never cost XP'), findsOneWidget);
    });

    for (final withAttempt in [true, false]) {
      testWidgets('no judgement in any copy, on the hub and every page '
          '(${withAttempt ? 'with' : 'without'} an attempt)', (tester) async {
        await _pumpCampaign(tester, data: _data(withAttempt: withAttempt));
        for (final text in _texts(tester)) {
          expect(_judgement.hasMatch(text), isFalse, reason: text);
        }
        for (final key in [
          'campaign-open-notice',
          'campaign-open-try',
          'campaign-open-yours',
          'campaign-link-route',
          'campaign-link-chapters',
          'campaign-link-log',
          'campaign-link-collection',
        ]) {
          await _open(tester, key);
          for (final text in _texts(tester)) {
            expect(_judgement.hasMatch(text), isFalse, reason: '$key: $text');
          }
          await tester.pageBack();
          await pumpFrames(tester);
        }
      });
    }
  });

  group('the Route page', () {
    testWidgets('every stop in words, the map in the user\'s words, Act II', (
      tester,
    ) async {
      // Tall enough that the whole page is built.
      await _pumpCampaign(tester, data: _data(), size: const Size(390, 3200));
      await _open(tester, 'campaign-link-route');
      Finder stop(Waypoint w) => find.byKey(ValueKey('route-stop-${w.name}'));
      Finder inStop(Waypoint w, String text) =>
          find.descendant(of: stop(w), matching: find.text(text));
      expect(inStop(Waypoint.carthage, 'Carthage'), findsOneWidget);
      expect(inStop(Waypoint.carthage, "You're here"), findsOneWidget);
      expect(inStop(Waypoint.newCarthage, '45 XP to go'), findsOneWidget);
      expect(inStop(Waypoint.ebro, 'The Ebro'), findsOneWidget);
      expect(inStop(Waypoint.ebro, '145 XP to go'), findsOneWidget);
      expect(inStop(Waypoint.italy, '545 XP to go'), findsOneWidget);

      // The six Section VII components, with the user's own words.
      expect(find.text('Win condition · Vision'), findsOneWidget);
      expect(find.text('Calm mornings and work I care about.'), findsOneWidget);
      expect(find.text('Rules of engagement · Boundaries'), findsOneWidget);
      expect(find.text('The game never rewards giving these up.'), findsOne);
      expect(find.text('Not written yet.'), findsNWidgets(3));

      // Act II stats.
      expect(find.text('Quests completed'), findsOneWidget);
      expect(find.bySemanticsLabel('1 Attempts recorded'), findsOneWidget);
    });

    testWidgets('a reached stop says so', (tester) async {
      // 40 XP + 14 quest days (280 XP) = 320 XP: level 4, the Pyrenees.
      await _pumpCampaign(
        tester,
        data: _withQuestDays(_data(withAttempt: false), 14),
      );
      await _open(tester, 'campaign-link-route');
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('route-stop-ebro')),
          matching: find.text('Reached'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('route-stop-pyrenees')),
          matching: find.text("You're here"),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the map opens the Compass section in place', (tester) async {
      await _pumpCampaign(tester);
      await _open(tester, 'campaign-link-route');
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('campaign-map-edit')),
      );
      expect(find.byType(CampaignRouteScreen), findsNothing);
      expect(find.byType(CampaignView), findsNothing);
      expect(find.text('Your direction, in your own words.'), findsWidgets);
    });
  });

  group('the Chapters page', () {
    testWidgets('five chapters with the article\'s counts', (tester) async {
      await _pumpCampaign(tester);
      await _open(tester, 'campaign-link-chapters');
      expect(find.text('1 of 5 chapters explored'), findsOneWidget);
      for (final name in [
        'See the terrain',
        'Find the pattern',
        'Raise your banner',
        'Break autopilot',
        'Plan the campaign',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Current reality · 4 reflections'), findsOneWidget);
      expect(find.text('Daytime check-ins · 6 reflections'), findsOneWidget);
      expect(find.text('4 of 4 written'), findsOneWidget);
      expect(find.text('Explored'), findsOneWidget);
    });

    testWidgets('a chapter opens its first open question', (tester) async {
      await _pumpCampaign(tester);
      await _open(tester, 'campaign-link-chapters');
      await _open(tester, 'campaign-chapter-2');
      final screen = tester.widget<GuidedPromptScreen>(
        find.byType(GuidedPromptScreen),
      );
      expect(screen.promptId, 'morning.05');
    });

    testWidgets('"Try one" opens the chapter\'s first experiment not tried; '
        'tried ones are counted', (tester) async {
      await _pumpCampaign(
        tester,
        data: _data().copyWith(
          experimentLog: [
            ExperimentEntry(
              id: 'e1',
              experimentId: 'try.banner.01',
              day: '2026-11-02',
              createdAt: _t,
            ),
          ],
        ),
      );
      await _open(tester, 'campaign-link-chapters');
      expect(find.text('1 experiment tried'), findsOneWidget);
      await _open(tester, 'campaign-chapter-try-3');
      expect(find.byType(TryScreen), findsOneWidget);
      expect(
        find.byKey(const ValueKey('try-card-try.banner.02')),
        findsOneWidget,
      );
    });
  });

  group('the Battle log page', () {
    Future<CarthaHarness> openLog(WidgetTester tester, {AppData? data}) async {
      final h = await _pumpCampaign(tester, data: data);
      await _open(tester, 'campaign-link-log');
      expect(find.byType(BattleLogScreen), findsOneWidget);
      return h;
    }

    testWidgets('the boss and the attempts, exactly as typed', (tester) async {
      await openLog(tester);
      expect(find.text('Finish the first essay'), findsWidgets);
      expect(
        find.text('Add milestones to your project to weaken the boss.'),
        findsOneWidget,
      );
      expect(find.text('Battle log · 1 attempt'), findsOneWidget);
      expect(find.text('Wrote for 25 minutes before work'), findsOneWidget);
      expect(find.text('Learned: Mornings work better'), findsOneWidget);
    });

    testWidgets('records an attempt; a blank one asks for words', (
      tester,
    ) async {
      final h = await openLog(tester, data: _data(withAttempt: false));
      expect(
        find.text('No attempts yet. Your first one can be tiny.'),
        findsOne,
      );
      await _open(tester, 'campaign-record');
      expect(find.text('Write a few words about what you tried.'), findsOne);
      expect(h.state.data.campaignLog, isEmpty);

      await tester.enterText(
        find.byKey(const ValueKey('campaign-attempt')),
        'Sent the outline to Maya ',
      );
      await tester.enterText(
        find.byKey(const ValueKey('campaign-learning')),
        'Asking early saves days',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await pumpFrames(tester);
      await _open(tester, 'campaign-record');
      await _settle(tester);

      final entry = h.state.data.campaignLog.single;
      expect(entry.attempt, 'Sent the outline to Maya ');
      expect(entry.learning, 'Asking early saves days');
      expect(entry.day, '2026-11-03');
      expect(h.store.saved!.campaignLog.single.attempt, entry.attempt);
      expect(find.text('Attempt recorded.'), findsOne);
      expect(find.text('Battle log · 1 attempt'), findsOneWidget);
      expect(h.state.campaign.xp, 55);
      // The form is ready for the next attempt, and no draft is left.
      expect(_field(tester, 'campaign-attempt').text, isEmpty);
      expect(_field(tester, 'campaign-learning').text, isEmpty);
      expect(h.state.attemptDraft, isNull);
      expect(h.store.saved!.attemptDraft, isNull);
    });

    testWidgets('edits and deletes an attempt (delete asks first)', (
      tester,
    ) async {
      final h = await openLog(tester);
      await _tapVisible(tester, find.text('Wrote for 25 minutes before work'));
      expect(find.text('Edit attempt'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('attempt-edit-attempt')),
        'Wrote for 40 minutes before work',
      );
      await tester.tap(find.text('Save attempt'));
      await _settle(tester);
      expect(h.state.data.campaignLog.single.attempt, contains('40 minutes'));
      expect(find.text('Wrote for 40 minutes before work'), findsOneWidget);

      await _tapVisible(tester, find.text('Wrote for 40 minutes before work'));
      await tester.tap(find.text('Delete attempt'));
      await pumpFrames(tester);
      expect(find.text('Delete this attempt?'), findsOneWidget);
      await tester.tap(find.text('Delete attempt').last);
      await _settle(tester);
      expect(h.state.data.campaignLog, isEmpty);
      expect(find.text('Attempt deleted'), findsOneWidget);
    });

    group('boss strength', () {
      AppData withMilestones(List<bool> done) => _data().copyWith(
        project: () => MonthProject(
          title: 'Finish the first essay',
          updatedAt: _t,
          milestones: [
            for (final (i, d) in done.indexed)
              Milestone(id: 'm$i', title: 'Step $i', done: d),
          ],
        ),
      );

      testWidgets('weakens as milestones are reached', (tester) async {
        await openLog(tester, data: withMilestones([true, false, false]));
        expect(find.byKey(const ValueKey('campaign-boss-strength')), findsOne);
        expect(find.text('1 of 3 milestones reached'), findsOneWidget);
        final bar = tester.widget<LinearProgressIndicator>(
          find.descendant(
            of: find.byKey(const ValueKey('campaign-boss-strength')),
            matching: find.byType(LinearProgressIndicator),
          ),
        );
        expect(bar.value, closeTo(2 / 3, 1e-9));
      });

      testWidgets('beaten when every milestone is reached', (tester) async {
        await openLog(tester, data: withMilestones([true, true]));
        expect(find.text('Every milestone reached. Boss beaten.'), findsOne);
      });
    });

    group('the draft (trust fix)', () {
      testWidgets('autosaved exactly as typed; back when the page opens; the '
          'hub says it is kept', (tester) async {
        final h = await openLog(tester, data: _data(withAttempt: false));
        expect(find.text('Kept on this phone as you type.'), findsOneWidget);
        await tester.enterText(
          find.byKey(const ValueKey('campaign-attempt')),
          '  Half a thought, ',
        );
        await tester.enterText(
          find.byKey(const ValueKey('campaign-learning')),
          'still forming',
        );
        // Not before the pause…
        await tester.pump(const Duration(milliseconds: 200));
        expect(h.state.attemptDraft, isNull);
        // …then saved, exactly as typed.
        await tester.pump(const Duration(milliseconds: 700));
        await _settle(tester);
        expect(h.state.attemptDraft!.attempt, '  Half a thought, ');
        expect(h.state.attemptDraft!.learning, 'still forming');
        expect(h.store.saved!.attemptDraft!.attempt, '  Half a thought, ');

        await tester.pageBack();
        await pumpFrames(tester);
        expect(find.text('Battle log · draft kept'), findsOneWidget);
        await _open(tester, 'campaign-link-log');
        expect(_field(tester, 'campaign-attempt').text, '  Half a thought, ');
        expect(_field(tester, 'campaign-learning').text, 'still forming');
      });

      testWidgets('leaving before the pause still keeps the words', (
        tester,
      ) async {
        final h = await openLog(tester, data: _data(withAttempt: false));
        await tester.enterText(
          find.byKey(const ValueKey('campaign-attempt')),
          'Typed and gone at once',
        );
        await tester.pageBack();
        await _settle(tester);
        expect(h.state.attemptDraft!.attempt, 'Typed and gone at once');
        expect(h.store.saved!.attemptDraft!.attempt, 'Typed and gone at once');
      });

      testWidgets('a saved draft (e.g. after a restart) is restored', (
        tester,
      ) async {
        await openLog(
          tester,
          data: _data(withAttempt: false).copyWith(
            attemptDraft: () => AttemptDraft(
              attempt: 'From yesterday ',
              learning: '',
              updatedAt: _t,
            ),
          ),
        );
        expect(_field(tester, 'campaign-attempt').text, 'From yesterday ');
        expect(_field(tester, 'campaign-learning').text, isEmpty);
      });

      testWidgets('clearing both fields removes the draft', (tester) async {
        final h = await openLog(
          tester,
          data: _data(withAttempt: false).copyWith(
            attemptDraft: () => AttemptDraft(attempt: 'Gone', updatedAt: _t),
          ),
        );
        await tester.enterText(
          find.byKey(const ValueKey('campaign-attempt')),
          '',
        );
        await tester.pump(const Duration(milliseconds: 700));
        await _settle(tester);
        expect(h.state.attemptDraft, isNull);
        expect(h.store.saved!.attemptDraft, isNull);
      });
    });

    group('a failed save (trust fix)', () {
      Future<CarthaHarness> recordWhileFailing(WidgetTester tester) async {
        final h = await openLog(tester, data: _data(withAttempt: false));
        await tester.enterText(
          find.byKey(const ValueKey('campaign-attempt')),
          'Wrote the intro',
        );
        await tester.enterText(
          find.byKey(const ValueKey('campaign-learning')),
          'Short is fine',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await pumpFrames(tester);
        h.store.failWrites = true;
        await _open(tester, 'campaign-record');
        await _settle(tester);
        return h;
      }

      testWidgets('is said so: never "recorded", the words stay, Retry on '
          'top; a Retry that works clears the form', (tester) async {
        final h = await recordWhileFailing(tester);
        expect(find.text('Attempt recorded.'), findsNothing);
        expect(
          find.text(
            'Not saved on this phone yet. Your words are still here. Retry '
            'at the top.',
          ),
          findsOneWidget,
        );
        expect(find.text(_l.saveStatusFailed), findsOneWidget);
        // Not claimed while it isn't so.
        expect(find.text('Kept on this phone as you type.'), findsNothing);
        expect(_field(tester, 'campaign-attempt').text, 'Wrote the intro');
        expect(_field(tester, 'campaign-learning').text, 'Short is fine');
        expect(h.store.saved!.campaignLog, isEmpty);

        // Wait out the message so Retry (at the top) can be reached.
        await tester.pump(const Duration(seconds: 5));
        await pumpFrames(tester);
        h.store.failWrites = false;
        await _tapVisible(tester, find.text('Retry'));
        await _settle(tester);
        expect(h.store.saved!.campaignLog.single.attempt, 'Wrote the intro');
        expect(find.text(_l.saveStatusFailed), findsNothing);
        expect(find.text('Attempt recorded.'), findsOneWidget);
        expect(_field(tester, 'campaign-attempt').text, isEmpty);
        expect(h.state.data.campaignLog, hasLength(1));
      });

      testWidgets('recording the same words again writes again, never a '
          'second attempt', (tester) async {
        final h = await recordWhileFailing(tester);
        h.store.failWrites = false;
        await tester.pump(const Duration(seconds: 5));
        await pumpFrames(tester);
        await _open(tester, 'campaign-record');
        await _settle(tester);
        expect(h.state.data.campaignLog, hasLength(1));
        expect(h.store.saved!.campaignLog, hasLength(1));
        expect(find.text('Attempt recorded.'), findsOneWidget);
        expect(_field(tester, 'campaign-attempt').text, isEmpty);
      });
    });
  });

  group('XP moments (CampaignFeedback)', () {
    Future<void> completeQuest(CarthaHarness h, String id) async {
      unawaited(
        h.state.mutate(
          (d) => d.copyWith(
            quests: [
              ...d.quests,
              Quest(
                id: id,
                title: 'Quest $id',
                createdAt: _t,
                completedOn: const {'2026-11-03'},
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('a completed quest shows "+20 XP", a new achievement and its '
        'pick', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(withAttempt: false).copyWith(quests: []),
      );
      await completeQuest(h, 'new');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsOneWidget);
      expect(find.textContaining('+20 XP'), findsOneWidget);
      expect(
        find.textContaining('Achievement earned: The Practitioner'),
        findsOneWidget,
      );
      expect(find.textContaining('A new pick for your avatar'), findsOneWidget);
      await tester.pump(CampaignFeedback.visible);
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });

    testWidgets('a first try of an experiment shows "+10 XP"; trying it '
        'again stays quiet', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      unawaited(h.state.tryExperiment('try.plan.01'));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.textContaining('+10 XP'), findsOneWidget);
      // Trying is the other route to a chapter's achievement.
      expect(
        find.textContaining('Achievement earned: The Strategist'),
        findsOneWidget,
      );
      expect(find.textContaining('A new pick for your avatar'), findsOne);
      await tester.pump(CampaignFeedback.visible);

      unawaited(h.state.tryExperiment('try.plan.01', note: 'Again'));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });

    testWidgets('quiet with the game layer off', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(game: false, withAttempt: false).copyWith(quests: []),
      );
      await completeQuest(h, 'new');
      unawaited(h.state.tryExperiment('try.plan.01'));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });

    testWidgets('quiet for a restore-sized jump', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(withAttempt: false).copyWith(quests: []),
      );
      unawaited(
        h.state.mutate(
          (d) => d.copyWith(
            quests: [
              for (var i = 1; i <= 6; i++)
                Quest(
                  id: 'r$i',
                  title: 'Restored $i',
                  createdAt: _t,
                  completedOn: {'2026-10-${_two(i)}'},
                ),
            ],
          ),
        ),
      );
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });

    testWidgets('quiet for a small restored backup (no size threshold '
        'needed: a restore is never a moment)', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(withAttempt: false).copyWith(quests: []),
      );
      // Two completed quests: +40 XP, the Practitioner and its pick — what
      // one action could earn, yet a restore all the same.
      final backup = encodeBackup(
        h.state.data.copyWith(
          quests: [
            for (final id in ['b1', 'b2'])
              Quest(
                id: id,
                title: 'Restored $id',
                createdAt: _t,
                completedOn: const {'2026-11-02'},
              ),
          ],
        ),
        _t,
      );
      final generation = h.state.dataGeneration;
      unawaited(h.state.importBackup(backup));
      await tester.pump();
      expect(h.state.dataGeneration, isNot(generation));
      expect(h.state.campaign.earned, contains(Achievement.practitioner));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);

      // After the restore, a real action is a moment again.
      await completeQuest(h, 'after');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsOneWidget);
      expect(find.textContaining('+20 XP'), findsOneWidget);
      await tester.pump(CampaignFeedback.visible);
    });

    testWidgets('an announced achievement leads with its own badge', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _data(withAttempt: false).copyWith(quests: []),
      );
      await completeQuest(h, 'new');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      final toast = find.byKey(const ValueKey('campaign-toast'));
      expect(
        tester
            .widget<AchievementBadge>(
              find.descendant(of: toast, matching: find.byType(AchievementBadge)),
            )
            .achievement,
        Achievement.practitioner,
      );
      expect(
        find.descendant(of: toast, matching: find.byIcon(Icons.auto_awesome)),
        findsNothing,
      );
      await tester.pump(CampaignFeedback.visible);
    });

    /// 80 XP from four October quest days (the Practitioner earned), on the
    /// game layer, no attempts.
    AppData nearNewCarthage({Persona? persona}) =>
        _withQuestDays(onboardedData(), 4).copyWith(persona: () => persona);

    // Changed by design (reward picks): an achievement gives a pick, so no
    // extra is announced as open; the user chooses it.
    testWidgets('an achievement gives a pick; no extra is claimed as new', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _data(withAttempt: false).copyWith(quests: []),
      );
      final before = h.state.picksLeft;
      await completeQuest(h, 'new');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(
        find.textContaining('Achievement earned: The Practitioner'),
        findsOneWidget,
      );
      expect(find.textContaining('A new pick for your avatar'), findsOne);
      expect(find.textContaining('New for your avatar'), findsNothing);
      expect(h.state.picksLeft, before + 1);
      expect(h.state.canUse(GarmentColor.bronze), isFalse, reason: 'unchosen');
      await tester.pump(CampaignFeedback.visible);
    });

    // Changed by design (reward picks): the stop gives a pick; its extra is
    // only suggested, never claimed open. The pick itself is now a moment.
    testWidgets('reaching a route stop with a quest: XP and a pick', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: nearNewCarthage());
      expect(h.state.campaign.level, 1);
      final before = h.state.picksLeft;
      await completeQuest(h, 'new');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(h.state.campaign.waypoint, Waypoint.newCarthage);
      expect(
        find.text('+20 XP  ·  A new pick for your avatar'),
        findsOneWidget,
      );
      expect(h.state.picksLeft, before + 1);
      expect(h.state.suggestedPick, Unlockable.sigilPath);
      expect(h.state.canUse(Sigil.path), isFalse, reason: 'unchosen');
      await tester.pump(CampaignFeedback.visible);
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });

    testWidgets('an extra already worn is not announced as new', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: nearNewCarthage(
          persona: _persona(avatar: _avatar.copyWith(sigil: Sigil.path)),
        ),
      );
      await completeQuest(h, 'new');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.textContaining('+20 XP'), findsOneWidget);
      expect(find.textContaining('New for your avatar'), findsNothing);
      expect(find.textContaining('Path'), findsNothing);
    });

    testWidgets('a pick that only covers extras already kept is not '
        'announced', (tester) async {
      // Two extras kept (worn while the game was off), one pick so far.
      final h = await pumpCartha(
        tester,
        data: nearNewCarthage().copyWith(
          avatarUnlocked: {Unlockable.sigilStar, Unlockable.headwearLaurel},
        ),
      );
      expect(h.state.picksLeft, 0);
      await completeQuest(h, 'new');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(h.state.picksLeft, 0);
      expect(find.text('+20 XP'), findsOneWidget);
      expect(find.textContaining('pick'), findsNothing);
      await tester.pump(CampaignFeedback.visible);
    });

    testWidgets('a stop reached by typing answers alone stays quiet (its '
        'pick too)', (tester) async {
      ReflectionAnswer answer(String id) =>
          ReflectionAnswer(promptId: id, body: 'Typed', updatedAt: _t);
      // 80 quest XP + 3 answers (15 XP) = 95; one more answer reaches 100.
      final h = await pumpCartha(
        tester,
        data: nearNewCarthage().copyWith(
          journeys: [
            Journey(
              id: 'j1',
              startedAt: _t,
              answers: {
                for (final id in ['morning.01', 'morning.02', 'morning.03'])
                  id: answer(id),
              },
            ),
          ],
          currentJourneyId: () => 'j1',
        ),
      );
      expect(h.state.campaign.level, 1);
      final before = h.state.picksLeft;
      unawaited(
        h.state.mutate(
          (d) => d.copyWith(
            journeys: [
              for (final j in d.journeys)
                Journey(
                  id: j.id,
                  startedAt: j.startedAt,
                  answers: {...j.answers, 'morning.05': answer('morning.05')},
                ),
            ],
          ),
        ),
      );
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(h.state.campaign.waypoint, Waypoint.newCarthage);
      expect(h.state.picksLeft, before + 1);
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });

    testWidgets('finishing a chapter by typing stays quiet (its achievement '
        'and pick too)', (tester) async {
      ReflectionAnswer answer(String id) =>
          ReflectionAnswer(promptId: id, body: 'Typed', updatedAt: _t);
      // Three of the four "See the terrain" answers; the fourth earns The
      // Observer and a pick.
      final h = await pumpCartha(
        tester,
        data: onboardedData().copyWith(
          journeys: [
            Journey(
              id: 'j1',
              startedAt: _t,
              answers: {
                for (final id in ['morning.01', 'morning.02', 'morning.03'])
                  id: answer(id),
              },
            ),
          ],
          currentJourneyId: () => 'j1',
        ),
      );
      // The same path as the answer screen's autosave.
      unawaited(h.state.saveAnswer('morning.04', 'Typed'));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(h.state.campaign.earned, contains(Achievement.observer));
      // Changed by design (reward picks): The Observer gives a pick; the
      // Scroll is only suggested until chosen.
      expect(h.state.picksLeft, 1);
      expect(h.state.canUse(Accessory.scroll), isFalse);
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
      expect(find.textContaining('The Observer'), findsNothing);
      expect(find.textContaining('New for your avatar'), findsNothing);

      // Nor is it saved up for the next action: that one says only what it
      // earned itself (+20 XP, The Practitioner and its one pick).
      await completeQuest(h, 'next');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsOneWidget);
      expect(find.textContaining('Scroll'), findsNothing);
      expect(find.textContaining('The Observer'), findsNothing);
      expect(find.textContaining('A new pick for your avatar'), findsOne);
      expect(find.textContaining('2 new picks'), findsNothing);
      await tester.pump(CampaignFeedback.visible);
    });

    // Changed by design (reward picks): the extra is chosen, not opened by
    // the achievement; the intent stays — nothing is announced twice and a
    // chosen extra stays when its record goes.
    testWidgets('an achievement earned again is not announced again; a chosen '
        'extra stays', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(withAttempt: false).copyWith(quests: []),
      );
      Future<void> setDone(bool done) => h.state.mutate(
        (d) => d.copyWith(
          quests: [
            Quest(
              id: 'q',
              title: 'Walk',
              createdAt: _t,
              completedOn: done ? const {'2026-11-03'} : const {},
            ),
          ],
        ),
      );
      unawaited(setDone(true));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(
        find.textContaining('Achievement earned: The Practitioner'),
        findsOneWidget,
      );
      await tester.pump(CampaignFeedback.visible);
      // Spending a pick is the user's choice, not a moment.
      unawaited(h.state.chooseReward(Unlockable.garmentBronze));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);

      // Untick: Bronze stays open, nothing to say.
      unawaited(setDone(false));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(h.state.canUse(GarmentColor.bronze), isTrue);
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);

      // Tick again: the XP is back, but nothing is "new" a second time —
      // neither the achievement nor its pick.
      unawaited(setDone(true));
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.text('+20 XP'), findsOneWidget);
      expect(find.textContaining('New for your avatar'), findsNothing);
      expect(find.textContaining('Achievement earned'), findsNothing);
      await tester.pump(CampaignFeedback.visible);
    });

    testWidgets('quiet when a restore opens many extras at once', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      // 30 path notes (300 XP) and one quest today: three stops and the
      // Practitioner at once, with only 20 XP from actions.
      unawaited(
        h.state.mutate(
          (d) => d.copyWith(
            pathAnswers: {
              for (var day = 1; day <= 30; day++)
                day: PathAnswer(day: day, body: 'Noted', updatedAt: _t),
            },
            quests: [
              Quest(
                id: 'r',
                title: 'Restored',
                createdAt: _t,
                completedOn: const {'2026-11-03'},
              ),
            ],
          ),
        ),
      );
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(h.state.campaign.waypoint, Waypoint.pyrenees);
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });
  });

  group('turning the game layer off (F-060)', () {
    testWidgets('Today shows the Campaign card while it is on', (tester) async {
      await pumpCartha(tester, data: _data(), size: const Size(390, 2400));
      expect(find.byKey(const ValueKey('today-campaign')), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);
      expect(find.text('55 XP'), findsOneWidget);
      await _tapVisible(tester, find.byKey(const ValueKey('today-campaign')));
      expect(find.byType(CampaignView), findsOneWidget);
    });

    testWidgets('off: no card, no pill, battle log kept', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(game: false),
        size: const Size(390, 2400),
      );
      expect(find.byKey(const ValueKey('today-campaign')), findsNothing);

      // Changed by design (A3): a request for the Campaign shows the
      // Playground — no XP, levels or route, and no "Campaign" anywhere.
      h.shell.compassSection.value = CompassSection.campaign;
      h.shell.select(AppTab.compass);
      await pumpFrames(tester);
      expect(find.byType(CampaignView), findsNothing);
      expect(find.byType(PlaygroundView), findsOneWidget);
      expect(find.byKey(const ValueKey('campaign-status')), findsNothing);
      expect(find.textContaining(RegExp(r'\d+ XP|Level \d')), findsNothing);
      expect(find.text('Campaign'), findsNothing);
      expect(h.state.data.campaignLog, hasLength(1));
    });

    testWidgets('the switch in You turns it off and on (and answers the '
        'invitation)', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data().copyWith(
          settings: const AppSettings(game: false, gameInvited: false),
        ),
        shell: ShellController(initial: AppTab.you),
        size: const Size(390, 2000),
      );
      final tile = find.descendant(
        of: find.byKey(const ValueKey('you-campaign')),
        matching: find.byType(SwitchListTile),
      );
      expect(tester.widget<SwitchListTile>(tile).value, isFalse);
      await _tapVisible(tester, tile);
      await _settle(tester);
      expect(h.state.gameEnabled, isTrue);
      // Chosen in You: the one-time question isn't asked any more.
      expect(h.state.settings.gameInvited, isTrue);
      expect(tester.widget<SwitchListTile>(tile).value, isTrue);
      await _tapVisible(tester, tile);
      await _settle(tester);
      expect(h.state.gameEnabled, isFalse);
      expect(h.state.data.campaignLog, hasLength(1));
    });
  });

  group('Make it yours: your strategist and reward picks', () {
    testWidgets('no avatar yet: the emblem on the route; the page nudges, '
        'counts, offers the picks; Create opens the builder', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpCampaign(tester);
      // The emblem stands at the current stop (no avatar to show).
      final onRoute = tester.widget<AvatarView>(
        _inRoute(find.byType(AvatarView)),
      );
      expect(onRoute.avatar, isNull);
      expect(onRoute.excludeFromSemantics, isTrue);
      // The route keeps its own label; the figure on it is decoration.
      final route = tester
          .getSemantics(find.byKey(const ValueKey('campaign-route')))
          .label;
      expect(route, contains("Hannibal's route: Carthage, stop 1 of 7."));
      expect(route, isNot(contains('avatar')));

      await _open(tester, 'campaign-open-yours');
      expect(find.text('Your strategist'), findsOneWidget);
      expect(
        find.text('Create an avatar to walk the route with you.'),
        findsOneWidget,
      );
      // The words say there is no avatar yet; the emblem is not read out.
      final card = tester.widget<AvatarView>(
        _inStrategist(find.byType(AvatarView)),
      );
      expect(card.avatar, isNull);
      expect(card.excludeFromSemantics, isTrue);
      // Changed by design (reward picks): the Observer, the Practitioner and
      // the Challenger gave three picks; nothing is open until chosen.
      expect(h.state.picksLeft, 3);
      expect(find.text('0 of 13 extras unlocked'), findsOneWidget);
      expect(
        find.text('3 picks to spend. What you choose stays yours.'),
        findsOneWidget,
      );
      // The first reached milestone's extra is suggested.
      expect(find.text('Suggested: Scroll'), findsOneWidget);
      expect(find.byKey(const ValueKey('campaign-reward-open')), findsOne);

      await _open(tester, 'campaign-strategist-open');
      expect(find.byType(PersonaBuilderScreen), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('with an avatar: it stands on the route and in the card, the '
        'motto exactly as typed; Edit opens the builder', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpCampaign(
        tester,
        data: _data().copyWith(
          persona: () => _persona(motto: '  Steady, not fast  '),
        ),
      );
      expect(
        tester.widget<AvatarView>(_inRoute(find.byType(AvatarView))).avatar,
        _avatar,
      );
      expect(
        tester.getSemantics(find.byKey(const ValueKey('campaign-route'))).label,
        isNot(contains('avatar')),
      );
      await _open(tester, 'campaign-open-yours');
      final card = tester.widget<AvatarView>(
        _inStrategist(find.byType(AvatarView)),
      );
      expect(card.avatar, _avatar);
      // Only the card's portrait is read out; on the route it is decoration.
      expect(card.excludeFromSemantics, isFalse);
      expect(
        tester.getSemantics(_inStrategist(find.byType(AvatarView))).label,
        contains('Your avatar'),
      );
      expect(find.text('  Steady, not fast  '), findsOneWidget);
      expect(
        find.text('Create an avatar to walk the route with you.'),
        findsNothing,
      );
      expect(find.text('Edit your avatar'), findsOneWidget);
      await _open(tester, 'campaign-strategist-open');
      expect(find.byType(PersonaBuilderScreen), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('the avatar moves to the stop the user has reached', (
      tester,
    ) async {
      // 40 XP + 14 quest days (280 XP) = 320 XP: level 4, the Pyrenees.
      await _pumpCampaign(
        tester,
        data: _withQuestDays(
          _data(withAttempt: false),
          14,
        ).copyWith(persona: () => _persona()),
      );
      expect(find.text("You're at the Pyrenees"), findsOneWidget);
      final road = tester.getRect(find.byKey(const ValueKey('campaign-route')));
      final avatar = tester.getCenter(
        find.byKey(const ValueKey('campaign-route-avatar')),
      );
      // The painter's stop 3 of 0…6 (dots 6 px, 2 px margin each side).
      final stopX = road.left + 8 + 3 * (road.width - 16) / 6;
      expect(avatar.dx, closeTo(stopX, 0.5));
      expect(avatar.dy, lessThan(road.center.dy));
    });

    testWidgets('worn extras count as the user\'s and are never offered', (
      tester,
    ) async {
      // Worn while the game layer was off: the Path banner and the laurel.
      final h = await _pumpCampaign(
        tester,
        data: _data().copyWith(
          persona: () => _persona(
            avatar: _avatar.copyWith(
              sigil: Sigil.path,
              headwear: Headwear.laurel,
            ),
          ),
        ),
      );
      await _open(tester, 'campaign-open-yours');
      // Changed by design (reward picks): the two worn extras are the
      // user's; the three earned picks are not spent yet.
      expect(find.text('2 of 13 extras unlocked'), findsOneWidget);
      expect(h.state.rewardChoices, isNot(contains(Unlockable.sigilPath)));
      expect(h.state.rewardChoices, isNot(contains(Unlockable.headwearLaurel)));
      // No motto: nothing stands in for the user's words.
      expect(
        find.byKey(const ValueKey('campaign-strategist-motto')),
        findsNothing,
      );
    });

    testWidgets('no pick left: when the next one comes', (tester) async {
      final h = await _pumpCampaign(tester, data: onboardedData());
      await _open(tester, 'campaign-open-yours');
      expect(h.state.picksLeft, 0);
      expect(find.byKey(const ValueKey('campaign-reward-open')), findsNothing);
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('campaign-strategist-next')),
            )
            .data,
        'Next pick at New Carthage',
      );
    });

    /// Every milestone reached: Italy and all seven achievements (13 picks).
    AppData everyMilestone() {
      String id(String phase, int i) => '$phase.${_two(i)}';
      final every = [
        for (var i = 1; i <= 14; i++) id('morning', i),
        for (var i = 1; i <= 6; i++) id('daytime', i),
        for (var i = 1; i <= 7; i++) id('evening', i),
      ];
      return _withQuestDays(
        _data().copyWith(
          journeys: [
            Journey(
              id: 'j1',
              startedAt: _t,
              answers: {
                for (final p in every)
                  p: ReflectionAnswer(promptId: p, body: 'Yes', updatedAt: _t),
              },
            ),
          ],
        ),
        23,
      );
    }

    // Changed by design (reward picks): every extra is open once every pick
    // is spent on one.
    testWidgets('every extra open: said plainly', (tester) async {
      await _pumpCampaign(
        tester,
        data: everyMilestone().copyWith(
          avatarUnlocked: Unlockable.values.toSet(),
        ),
      );
      expect(find.text("You're at Italy"), findsOneWidget);
      await _open(tester, 'campaign-open-yours');
      expect(find.text('13 of 13 extras unlocked'), findsOneWidget);
      expect(find.text('Every extra unlocked.'), findsOneWidget);
    });

    testWidgets('every milestone reached, nothing chosen: no false claim', (
      tester,
    ) async {
      final h = await _pumpCampaign(tester, data: everyMilestone());
      expect(h.state.picksLeft, 13);
      await _open(tester, 'campaign-open-yours');
      expect(find.text('0 of 13 extras unlocked'), findsOneWidget);
      expect(find.text('Every extra unlocked.'), findsNothing);
      expect(
        find.text('13 picks to spend. What you choose stays yours.'),
        findsOneWidget,
      );
    });
  });

  group('quests', () {
    Future<CarthaHarness> pumpQuests(
      WidgetTester tester,
      List<Quest> quests, {
      bool game = true,
      Size size = const Size(390, 1400),
      double textScale = 1,
      Brightness brightness = Brightness.dark,
    }) => pumpCartha(
      tester,
      data: onboardedData(settings: AppSettings(game: game))
          .copyWith(quests: quests),
      home: const CompassTab(initial: CompassSection.missions),
      size: size,
      textScale: textScale,
      brightness: brightness,
    );

    Quest open(String id) => Quest(id: id, title: 'Open $id', createdAt: _t);
    Quest daily(String id, {Set<String> done = const {}}) => Quest(
      id: id,
      title: 'Daily $id',
      createdAt: _t,
      recurrence: QuestRecurrence.daily,
      completedOn: done,
    );
    Quest fromTry(String id) => Quest(
      id: id,
      title: 'Walk one room as a guest would',
      createdAt: _t,
      source: QuestSource.experiment,
    );
    Finder chip(String id) => find.byKey(ValueKey('quest-xp-$id'));

    testWidgets('open quests show "+20 XP"; done ones do not', (tester) async {
      final semantics = tester.ensureSemantics();
      final h = await pumpQuests(tester, [
        open('a'),
        daily('w', done: {'2026-11-02'}),
        daily('d', done: {'2026-11-03'}),
      ]);
      expect(chip('a'), findsOneWidget);
      // Done yesterday, open again today.
      expect(chip('w'), findsOneWidget);
      expect(chip('d'), findsNothing);
      expect(find.text('+20 XP'), findsNWidgets(2));
      // Read out in words rather than "+20 XP".
      for (final id in ['a', 'w']) {
        final label = tester.getSemantics(chip(id)).label;
        expect(label, contains('Earns 20 XP when done'));
        expect(label, isNot(contains('+20 XP')));
      }

      // Completing one takes its chip away; the rest keep theirs.
      await _tapVisible(tester, find.byKey(const ValueKey('quest-check-w')));
      await _settle(tester);
      expect(h.state.questById('w')!.isDoneOn('2026-11-03'), isTrue);
      expect(chip('w'), findsNothing);
      expect(chip('a'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets("none once today's quest XP is used up", (tester) async {
      final h = await pumpQuests(tester, [
        open('a'),
        daily('x', done: {'2026-11-03'}),
        daily('y', done: {'2026-11-03'}),
        daily('z'),
      ]);
      expect(chip('a'), findsOneWidget);
      expect(chip('z'), findsOneWidget);
      // The third completion today is the last that counts.
      await _tapVisible(tester, find.byKey(const ValueKey('quest-check-z')));
      await _settle(tester);
      expect(h.state.questById('z')!.isDoneOn('2026-11-03'), isTrue);
      expect(chip('a'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
      // The quest itself stays as it was: open, with its checkbox.
      expect(find.text('Open a'), findsOneWidget);
    });

    testWidgets('none with the game layer off', (tester) async {
      await pumpQuests(tester, [open('a'), daily('w')], game: false);
      expect(find.text('Open a'), findsOneWidget);
      expect(chip('a'), findsNothing);
      expect(chip('w'), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
    });

    testWidgets('a quest added from "Try" says so, in words', (tester) async {
      await pumpQuests(tester, [open('a'), fromTry('t')], game: false);
      expect(find.byKey(const ValueKey('quest-source-t')), findsOneWidget);
      expect(find.byKey(const ValueKey('quest-source-a')), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('quest-source-t')),
          matching: find.text('Experiment'),
        ),
        findsOneWidget,
      );
      // The same painted seedling as on Try, not a stand-in icon.
      expect(
        tester
            .widget<GlyphIcon>(
              find.descendant(
                of: find.byKey(const ValueKey('quest-source-t')),
                matching: find.byType(GlyphIcon),
              ),
            )
            .glyph,
        CarthaGlyph.experiment,
      );
    });

    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('quest chips fit $size (${brightness.name})', (
          tester,
        ) async {
          await pumpQuests(
            tester,
            [
              open('a'),
              daily('w'),
              fromTry('t'),
              Quest(
                id: 'p',
                title: 'Book the long-planned weekend away with the family',
                createdAt: _t,
                dueDate: '2026-11-20',
              ),
            ],
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          expect(chip('a'), findsOneWidget);
          await expectNoOverflow(tester);
        });
      }
    }
  });

  group('screen sizes', () {
    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('the hub fits $size (${brightness.name})', (tester) async {
          await _pumpCampaign(
            tester,
            data: _data().copyWith(
              attemptDraft: () => AttemptDraft(attempt: 'Half', updatedAt: _t),
            ),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          expect(find.byType(CampaignView), findsOneWidget);
          expect(find.text('Battle log · draft kept'), findsOneWidget);
          await expectNoOverflow(tester);
        });

        testWidgets('with an avatar in Italy the hub fits $size '
            '(${brightness.name})', (tester) async {
          await _pumpCampaign(
            tester,
            data: _withQuestDays(_data(), 30).copyWith(
              persona: () => _persona(
                motto: 'Steady steps, every single day, towards the Alps!',
              ),
            ),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await expectNoOverflow(tester);
          // In Italy the avatar stands at the last stop, inside the road.
          final road = tester.getRect(
            find.byKey(const ValueKey('campaign-route')),
          );
          final avatar = tester.getRect(
            find.byKey(const ValueKey('campaign-route-avatar')),
          );
          expect(avatar.right, lessThanOrEqualTo(road.right + 0.01));
        });

        for (final (name, screen) in [
          ('Route', const CampaignRouteScreen()),
          ('Chapters', const ChaptersScreen()),
          ('Battle log', const BattleLogScreen()),
        ]) {
          testWidgets('the $name page fits $size (${brightness.name})', (
            tester,
          ) async {
            await pumpCartha(
              tester,
              data: _withQuestDays(_data(), 30).copyWith(
                persona: () => _persona(),
                project: () => MonthProject(
                  title: 'Finish the first essay',
                  updatedAt: _t,
                  milestones: const [
                    Milestone(id: 'm1', title: 'Outline', done: true),
                    Milestone(id: 'm2', title: 'Draft'),
                  ],
                ),
              ),
              home: screen,
              size: size.size,
              textScale: size.textScale,
              brightness: brightness,
            );
            expect(find.byWidget(screen), findsOneWidget);
            await expectNoOverflow(tester);
          });
        }
      }
    }
  });

  test('the level steps match the rules', () {
    expect(kXpPerLevel, 100);
    expect(kXpPerExperiment, 10);
    expect(Achievement.values, hasLength(7));
  });
}
