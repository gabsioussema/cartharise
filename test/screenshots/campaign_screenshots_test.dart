// Renders the Campaign (and its Today card) to PNGs for design review
// (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _at = DateTime(2026, 11, 2, 21, 10);

String _two(int i) => i.toString().padLeft(2, '0');

/// Mid-campaign: the morning written, two check-ins, a Compass, quests done
/// on a few days, path notes and two battle-log attempts.
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
  );
}

void main() {
  for (final b in ['dark', 'light']) {
    final brightness = b == 'dark' ? Brightness.dark : Brightness.light;
    testWidgets('campaign ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        brightness: brightness,
        content: englishContent,
        home: const CompassTab(initial: CompassSection.campaign),
        size: const Size(390, 5200),
      );
      await captureScreenshot(tester, 'campaign_01_campaign_$b');
    });

    testWidgets('campaign on a phone ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        brightness: brightness,
        content: englishContent,
        home: const CompassTab(initial: CompassSection.campaign),
      );
      await captureScreenshot(tester, 'campaign_02_phone_$b');
    });

    testWidgets('battle log and achievements on a phone ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        brightness: brightness,
        content: englishContent,
        home: const CompassTab(initial: CompassSection.campaign),
      );
      await tester.ensureVisible(find.text('Battle log · 2 attempts'));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'campaign_03_log_$b');
    });
  }
}
