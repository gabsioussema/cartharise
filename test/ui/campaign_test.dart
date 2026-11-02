import 'dart:async';

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/campaign/campaign_feedback.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/campaign/campaign_view.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
import 'package:cartharise/ui/persona/persona_builder.dart';
import 'package:cartharise/ui/persona/persona_ops.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

final _t = DateTime(2026, 11, 3, 9);

String _two(int i) => i.toString().padLeft(2, '0');

/// A user part-way through: the first chapter written (4 × 5 XP), one quest
/// done today (20 XP), one attempt today (15 XP) → 55 XP.
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

final _judgement = RegExp(
  r'streak|score|fail|missed|behind|overdue|lazy|you fixed your life|'
  r'should have|punish',
  caseSensitive: false,
);

List<String> _texts(WidgetTester tester) => [
  for (final w in tester.widgetList<Text>(find.byType(Text)))
    w.data ?? w.textSpan?.toPlainText() ?? '',
];

void main() {
  group('the Campaign section (F-058–F-064)', () {
    testWidgets('shows status, five chapters, the map, the boss and '
        'achievements', (tester) async {
      await _pumpCampaign(tester);
      expect(find.byType(CampaignView), findsOneWidget);
      expect(find.text('Level 1 · 55 XP'), findsOneWidget);
      // Hannibal's route: level 1 is Carthage; 45 XP more reaches the next stop.
      expect(find.text("You're at Carthage"), findsOneWidget);
      expect(find.text('45 XP to New Carthage'), findsOneWidget);
      expect(
        // Read as part of the status card.
        find.bySemanticsLabel(
          RegExp("Hannibal's route: Carthage, stop 1 of 7"),
        ),
        findsOneWidget,
      );
      // The closest achievement not earned yet.
      expect(
        find.text(
          'Next: The Pathfinder · Explored the anti-vision and identity '
          'questions',
        ),
        findsOneWidget,
      );
      // No project milestones yet: a pointer to add some.
      expect(
        find.text('Add milestones to your project to weaken the boss.'),
        findsOneWidget,
      );
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

      // The six Section VII components, with the user's own words.
      expect(find.text('Win condition · Vision'), findsOneWidget);
      expect(find.text('Calm mornings and work I care about.'), findsOneWidget);
      expect(find.text('Rules of engagement · Boundaries'), findsOneWidget);
      expect(find.text('The game never rewards giving these up.'), findsOne);
      expect(find.text('Not written yet.'), findsNWidgets(3));

      // The boss is the month project; the battle log lists the attempt.
      expect(find.text('Finish the first essay'), findsWidgets);
      expect(find.text('Battle log · 1 attempt'), findsOneWidget);
      expect(find.text('Wrote for 25 minutes before work'), findsOneWidget);
      expect(find.text('Learned: Mornings work better'), findsOneWidget);

      // Achievements state their status in words, not colour alone.
      expect(find.text('3 of 7 earned'), findsOneWidget);
      expect(find.text('Earned'), findsNWidgets(3));
      expect(find.text('Not yet'), findsNWidgets(4));
      expect(
        find.bySemanticsLabel(
          'The Observer. Wrote all four present-reality reflections. Earned. '
          'For your avatar: Scroll',
        ),
        findsOneWidget,
      );
      // Each achievement names the avatar extra it opens.
      expect(find.text('For your avatar: Scroll'), findsOneWidget);
      expect(find.text('For your avatar: Amulet of Tanit'), findsOneWidget);

      // Act II stats and the honest note.
      expect(find.text('Quests completed'), findsOneWidget);
      expect(find.textContaining('Cartharise additions'), findsOneWidget);
    });

    testWidgets('records an attempt; a blank one asks for words', (
      tester,
    ) async {
      final h = await _pumpCampaign(tester, data: _data(withAttempt: false));
      expect(
        find.text('No attempts yet. Your first one can be tiny.'),
        findsOne,
      );
      expect(find.text('Level 1 · 40 XP'), findsOneWidget);

      await _tapVisible(tester, find.byKey(const ValueKey('campaign-record')));
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
      // Let the focused field's scroll-into-view finish before tapping.
      FocusManager.instance.primaryFocus?.unfocus();
      await pumpFrames(tester);
      await _tapVisible(tester, find.byKey(const ValueKey('campaign-record')));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester);

      final entry = h.state.data.campaignLog.single;
      expect(entry.attempt, 'Sent the outline to Maya ');
      expect(entry.learning, 'Asking early saves days');
      expect(entry.day, '2026-11-03');
      expect(find.text('Attempt recorded.'), findsOne);
      expect(find.text('Battle log · 1 attempt'), findsOneWidget);
      expect(find.text('Level 1 · 55 XP'), findsOneWidget);
      expect(find.text('The Challenger'), findsOneWidget);
      // The form is ready for the next attempt.
      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('campaign-attempt')),
      );
      expect(field.controller!.text, isEmpty);
    });

    testWidgets('edits and deletes an attempt (delete asks first)', (
      tester,
    ) async {
      final h = await _pumpCampaign(tester);
      await _tapVisible(tester, find.text('Wrote for 25 minutes before work'));
      expect(find.text('Edit attempt'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('attempt-edit-attempt')),
        'Wrote for 40 minutes before work',
      );
      await tester.tap(find.text('Save attempt'));
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester);
      expect(h.state.data.campaignLog.single.attempt, contains('40 minutes'));
      expect(find.text('Wrote for 40 minutes before work'), findsOneWidget);

      await _tapVisible(tester, find.text('Wrote for 40 minutes before work'));
      await tester.tap(find.text('Delete attempt'));
      await pumpFrames(tester);
      expect(find.text('Delete this attempt?'), findsOneWidget);
      await tester.tap(find.text('Delete attempt').last);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester);
      expect(h.state.data.campaignLog, isEmpty);
      expect(find.text('Attempt deleted'), findsOneWidget);
    });

    testWidgets('a chapter opens its first open question', (tester) async {
      await _pumpCampaign(tester);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('campaign-chapter-2')),
      );
      final screen = tester.widget<GuidedPromptScreen>(
        find.byType(GuidedPromptScreen),
      );
      expect(screen.promptId, 'morning.05');
    });

    testWidgets('the map opens the Compass and the quests', (tester) async {
      await _pumpCampaign(tester);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('campaign-map-edit')),
      );
      expect(find.byType(CampaignView), findsNothing);
      expect(find.text('Your direction, in your own words.'), findsWidgets);
    });

    testWidgets('explains how XP is earned', (tester) async {
      await _pumpCampaign(tester);
      await _tapVisible(tester, find.byKey(const ValueKey('campaign-xp-how')));
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.text('+20 XP for each quest you complete, counting up to 3 a day'),
        findsOneWidget,
      );
      expect(find.textContaining('ignores what you write'), findsOne);
      expect(find.textContaining('never cost XP'), findsOneWidget);
    });

    testWidgets('no judgement in any copy', (tester) async {
      for (final data in [_data(), _data(withAttempt: false)]) {
        await _pumpCampaign(tester, data: data);
        for (final text in _texts(tester)) {
          expect(_judgement.hasMatch(text), isFalse, reason: text);
        }
      }
    });
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
      await _pumpCampaign(tester, data: withMilestones([true, false, false]));
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
      await _pumpCampaign(tester, data: withMilestones([true, true]));
      expect(find.text('Every milestone reached. Boss beaten.'), findsOne);
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

    testWidgets('a completed quest shows "+20 XP" and a new achievement', (
      tester,
    ) async {
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
      await tester.pump(CampaignFeedback.visible);
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });

    testWidgets('quiet with the game layer off', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(game: false, withAttempt: false).copyWith(quests: []),
      );
      await completeQuest(h, 'new');
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
      expect(find.textContaining('New for your avatar'), findsNothing);
      expect(h.state.picksLeft, before + 1);
      expect(h.state.canUse(GarmentColor.bronze), isFalse, reason: 'unchosen');
      await tester.pump(CampaignFeedback.visible);
    });

    // Changed by design (reward picks): the stop gives a pick; its extra is
    // only suggested, never claimed open.
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
      expect(find.text('+20 XP'), findsOneWidget);
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
      expect(find.text('+20 XP'), findsOneWidget);
      expect(find.textContaining('New for your avatar'), findsNothing);
    });

    testWidgets('a stop reached by typing answers alone stays quiet', (
      tester,
    ) async {
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
      expect(find.byKey(const ValueKey('campaign-toast')), findsNothing);
    });

    testWidgets('finishing a chapter by typing stays quiet (its achievement '
        'and extra too)', (tester) async {
      ReflectionAnswer answer(String id) =>
          ReflectionAnswer(promptId: id, body: 'Typed', updatedAt: _t);
      // Three of the four "See the terrain" answers; the fourth earns The
      // Observer and opens the Scroll.
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

      // Nor is it saved up for the next action.
      await completeQuest(h, 'next');
      await tester.pump(CampaignFeedback.settle);
      await tester.pump();
      expect(find.byKey(const ValueKey('campaign-toast')), findsOneWidget);
      expect(find.textContaining('Scroll'), findsNothing);
      expect(find.textContaining('The Observer'), findsNothing);
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

      // Tick again: the XP is back, but nothing is "new" a second time.
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

      // A request for the Campaign shows the Compass instead.
      h.shell.compassSection.value = CompassSection.campaign;
      h.shell.select(AppTab.compass);
      await pumpFrames(tester);
      expect(find.byType(CampaignView), findsNothing);
      expect(find.text('Campaign'), findsNothing);
      expect(h.state.data.campaignLog, hasLength(1));
    });

    testWidgets('the switch in You turns it off and on', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(),
        shell: ShellController(initial: AppTab.you),
        size: const Size(390, 2000),
      );
      final tile = find.descendant(
        of: find.byKey(const ValueKey('you-campaign')),
        matching: find.byType(SwitchListTile),
      );
      expect(tester.widget<SwitchListTile>(tile).value, isTrue);
      await _tapVisible(tester, tile);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester);
      expect(h.state.gameEnabled, isFalse);
      expect(tester.widget<SwitchListTile>(tile).value, isFalse);
      expect(h.state.data.campaignLog, hasLength(1));
      await _tapVisible(tester, tile);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester);
      expect(h.state.gameEnabled, isTrue);
    });
  });

  group('your strategist (persona plan C)', () {
    testWidgets('no avatar yet: the emblem on the route, a nudge, the count '
        'and the next extra; Create opens the builder', (tester) async {
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
      expect(find.text('Next: Path · Reach New Carthage'), findsOneWidget);

      await _tapVisible(
        tester,
        find.byKey(const ValueKey('campaign-strategist-open')),
      );
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
      expect(
        tester.getSemantics(find.byKey(const ValueKey('campaign-route'))).label,
        isNot(contains('avatar')),
      );
      expect(find.text('  Steady, not fast  '), findsOneWidget);
      expect(
        find.text('Create an avatar to walk the route with you.'),
        findsNothing,
      );
      expect(find.text('Edit your avatar'), findsOneWidget);
      await _tapVisible(
        tester,
        find.byKey(const ValueKey('campaign-strategist-open')),
      );
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

    testWidgets('a worn extra stays open and is never pointed to as next', (
      tester,
    ) async {
      // Worn while the game layer was off: the Path banner and the laurel.
      await _pumpCampaign(
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
      // Changed by design (reward picks): the two worn extras are the
      // user's; the three earned picks are not spent yet.
      expect(find.text('2 of 13 extras unlocked'), findsOneWidget);
      expect(find.text('Next: Sage · Reach the Ebro'), findsOneWidget);
      // No motto: nothing stands in for the user's words.
      expect(
        find.byKey(const ValueKey('campaign-strategist-motto')),
        findsNothing,
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
      expect(find.text('7 of 7 earned'), findsOneWidget);
      expect(find.text('13 of 13 extras unlocked'), findsOneWidget);
      expect(find.text('Every extra unlocked.'), findsOneWidget);
    });

    testWidgets('every milestone reached, nothing chosen: no false claim', (
      tester,
    ) async {
      final h = await _pumpCampaign(tester, data: everyMilestone());
      expect(h.state.picksLeft, 13);
      expect(find.text('0 of 13 extras unlocked'), findsOneWidget);
      expect(find.text('Every extra unlocked.'), findsNothing);
    });
  });

  group('XP preview on quests', () {
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
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester);
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
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester);
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
        testWidgets('fits $size (${brightness.name})', (tester) async {
          await _pumpCampaign(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          expect(find.byType(CampaignView), findsOneWidget);
          await expectNoOverflow(tester);
          // Achievements and chapters stay readable as one column on the
          // smallest phone at 200 % text.
          expect(find.text('The Challenger'), findsOneWidget);
        });

        testWidgets('with an avatar and a long motto fits $size '
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
          expect(find.byType(CampaignView), findsOneWidget);
          await expectNoOverflow(tester);
          // In Italy the avatar stands at the last stop, inside the road.
          final road = tester.getRect(
            find.byKey(const ValueKey('campaign-route')),
          );
          final avatar = tester.getRect(
            find.byKey(const ValueKey('campaign-route-avatar')),
          );
          expect(avatar.right, lessThanOrEqualTo(road.right + 0.01));
          expect(find.text('Edit your avatar'), findsOneWidget);
        });
      }
    }
  });

  test('the level steps match the rules', () {
    expect(kXpPerLevel, 100);
    expect(Achievement.values, hasLength(7));
  });
}
