// Renders the Campaign (and its Today card) to PNGs for design review
// (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'dart:async';

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/campaign_feedback.dart';
import 'package:cartharise/ui/campaign/campaign_invite.dart';
import 'package:cartharise/ui/campaign/chapters_screen.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/campaign/make_it_yours_screen.dart';
import 'package:cartharise/ui/campaign/notice_screen.dart';
import 'package:cartharise/ui/campaign/route_screen.dart';
import 'package:cartharise/ui/campaign/try_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _at = DateTime(2026, 11, 2, 21, 10);

String _two(int i) => i.toString().padLeft(2, '0');

/// Mid-campaign: the morning written, two check-ins, a Compass, quests done
/// on a few days, path notes, two battle-log attempts and an avatar.
AppData _data() {
  ReflectionAnswer answer(String id) =>
      ReflectionAnswer(promptId: id, body: 'My answer', updatedAt: _at);
  return onboardedData().copyWith(
    journeys: [
      Journey(
        id: 'journey_1',
        startedAt: DateTime(2026, 11, 2, 7),
        answers: {
          for (var i = 1; i <= 14; i++)
            'morning.${_two(i)}': answer('morning.${_two(i)}'),
          for (var i = 1; i <= 2; i++)
            'daytime.${_two(i)}': answer('daytime.${_two(i)}'),
        },
      ),
    ],
    currentJourneyId: () => 'journey_1',
    compass: LifeCompass(
      antiVision:
          "I won't let my days slide by on autopilot, too tired to make "
          'anything of my own.',
      vision:
          'Calm mornings, focused work on things I care about, and evenings '
          'with the people I love.',
      yearGoal: 'Publish twelve finished pieces of writing this year.',
      monthProject: 'Finish and share the first essay.',
      dailyLevers: '- Write for 30 minutes\n- Walk after lunch',
      constraints: 'Sleep by 23:00. Sundays stay with family.',
      updatedAt: _at,
    ),
    quests: [
      Quest(
        id: 'q1',
        title: 'Write for 30 minutes',
        createdAt: _at,
        recurrence: QuestRecurrence.daily,
        completedOn: const {'2026-11-01', '2026-11-02', '2026-11-03'},
      ),
    ],
    pathAnswers: {
      1: PathAnswer(
        day: 1,
        body: 'Noticed the phone first thing.',
        updatedAt: _at,
      ),
      2: PathAnswer(day: 2, body: 'Energy dips after lunch.', updatedAt: _at),
    },
    persona: () => Persona(
      avatar: const Avatar(
        skinTone: SkinTone.copper,
        hair: HairStyle.locs,
        hairColor: HairColor.black,
        garment: Garment.cloak,
        garmentColor: GarmentColor.sand,
        accessory: Accessory.satchel,
      ),
      motto: 'Slow is smooth, smooth is far.',
      updatedAt: _at,
    ),
    campaignLog: [
      BattleLogEntry(
        id: 'a2',
        day: '2026-11-03',
        attempt: 'Wrote the second section before work.',
        learning: 'Mornings are where the words are.',
        createdAt: _at,
      ),
      BattleLogEntry(
        id: 'a1',
        day: '2026-11-01',
        attempt: 'Outlined the essay in 20 minutes.',
        createdAt: _at,
      ),
    ],
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
        experimentId: 'try.autopilot.02',
        day: '2026-11-02',
        note: 'Reached for it four times. Lunch tasted better.',
        createdAt: _at,
      ),
      ExperimentEntry(
        id: 'e1',
        experimentId: 'try.terrain.01',
        day: '2026-11-01',
        createdAt: _at,
      ),
    ],
    lessonsRead: const {'lesson.02'},
    avatarUnlocked: const {Unlockable.accessoryScroll},
  );
}

void main() {
  for (final b in ['dark', 'light']) {
    final brightness = b == 'dark' ? Brightness.dark : Brightness.light;

    Future<void> shoot(
      WidgetTester tester,
      String name,
      Widget home, {
      Size size = const Size(390, 844),
      AppData? data,
    }) async {
      await pumpCartha(
        tester,
        data: data ?? _data(),
        brightness: brightness,
        content: englishContent,
        home: home,
        size: size,
      );
      await captureScreenshot(tester, '${name}_$b');
    }

    testWidgets('the hub on a phone ($b)', (tester) async {
      await shoot(
        tester,
        'campaign_01_hub',
        const CompassTab(initial: CompassSection.campaign),
      );
    });

    testWidgets('the hub with the invitation ($b)', (tester) async {
      await shoot(
        tester,
        'campaign_02_invite',
        const Scaffold(body: SafeArea(child: CampaignInviteCard())),
        size: const Size(390, 320),
        data: onboardedData(
          settings: const AppSettings(game: false, gameInvited: false),
        ),
      );
    });

    for (final (name, home, height) in [
      ('campaign_03_try', const TryScreen(), 844.0),
      ('campaign_04_notice', const NoticeScreen(), 2200.0),
      ('campaign_05_yours', const MakeItYoursScreen(), 844.0),
      ('campaign_06_collection', const CollectionScreen(), 2400.0),
      ('campaign_07_route', const CampaignRouteScreen(), 2600.0),
      ('campaign_08_chapters', const ChaptersScreen(), 2000.0),
      ('campaign_09_log', const BattleLogScreen(), 1400.0),
    ]) {
      testWidgets('$name ($b)', (tester) async {
        await shoot(tester, name, home, size: Size(390, height));
      });
    }

    testWidgets('the Playground with the game off ($b)', (tester) async {
      await shoot(
        tester,
        'campaign_11_playground',
        const CompassTab(initial: CompassSection.campaign),
        size: const Size(390, 1100),
        data: _data().copyWith(
          settings: const AppSettings(game: false, gameInvited: false),
        ),
      );
    });

    testWidgets('a moment with its badge ($b)', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data().copyWith(quests: []),
        brightness: brightness,
        content: englishContent,
        size: const Size(390, 400),
      );
      unawaited(
        h.state.mutate(
          (d) => d.copyWith(
            quests: [
              Quest(
                id: 'q9',
                title: 'Walk after lunch',
                createdAt: _at,
                completedOn: const {'2026-11-03'},
              ),
            ],
          ),
        ),
      );
      await tester.pump(CampaignFeedback.settle);
      await pumpFrames(tester);
      await captureScreenshot(tester, 'campaign_12_moment_$b');
      await tester.pump(CampaignFeedback.visible);
    });

    testWidgets('choose your reward ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        brightness: brightness,
        content: englishContent,
        home: const MakeItYoursScreen(),
      );
      await tester.tap(find.byKey(const ValueKey('campaign-reward-open')));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'campaign_10_reward_$b');
    });
  }
}
