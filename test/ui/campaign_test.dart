import 'dart:async';

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/ui/campaign/campaign_feedback.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/campaign/campaign_view.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/nav.dart';
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
          'The Observer. Wrote all four present-reality reflections. Earned',
        ),
        findsOneWidget,
      );

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
      }
    }
  });

  test('the level steps match the rules', () {
    expect(kXpPerLevel, 100);
    expect(Achievement.values, hasLength(7));
  });
}
