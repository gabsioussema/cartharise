// Renders the Compass + Missions screens to PNGs for design review against
// "Cartharise Brand and App System Board.png" (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/compass/compass_import.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/compass/compass_versions.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/missions/quest_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _at = DateTime(2026, 11, 2, 21, 10);

AppData _data({bool withCompass = true}) {
  final evening = <String, String>{
    'evening.03':
        "I won't let my days slide by on autopilot, too tired to "
        'make anything of my own.',
    'evening.04':
        'Calm mornings, focused work on things I care about, and '
        'evenings with the people I love.',
    'evening.05': 'Publish twelve finished pieces of writing this year.',
    'evening.06': 'Finish and share the first essay.',
    'evening.07':
        '- Write for 30 minutes\n- Walk after lunch\n- Phone away by 22:00',
  };
  final journey = Journey(
    id: 'journey_1',
    startedAt: DateTime(2026, 11, 2, 7),
    answers: {
      for (final e in evening.entries)
        e.key: ReflectionAnswer(promptId: e.key, body: e.value, updatedAt: _at),
    },
  );
  return onboardedData().copyWith(
    journeys: [journey],
    currentJourneyId: () => journey.id,
    compass: withCompass
        ? LifeCompass(
            antiVision: evening['evening.03']!,
            vision: evening['evening.04']!,
            monthProject: 'Finish and share the first essay.',
            dailyLevers: evening['evening.07']!,
            constraints: 'Eight hours of sleep. Sundays stay free.',
            updatedAt: _at,
          )
        : const LifeCompass(),
    compassHistory: [
      CompassVersion(
        savedAt: _at,
        compass: const LifeCompass(vision: 'A quieter life.'),
        reason: CompassVersionReason.beforeImport,
      ),
      CompassVersion(
        savedAt: DateTime(2026, 10, 30, 19, 5),
        compass: const LifeCompass(vision: 'A quieter life.'),
        reason: CompassVersionReason.manual,
      ),
    ],
    quests: [
      Quest(
        id: 'q1',
        title: 'Write for 30 minutes',
        createdAt: DateTime(2026, 11, 2),
        recurrence: QuestRecurrence.daily,
        source: QuestSource.dailyLever,
        completedOn: const {'2026-11-03'},
      ),
      Quest(
        id: 'q2',
        title: 'Walk after lunch',
        createdAt: DateTime(2026, 11, 2),
        recurrence: QuestRecurrence.daily,
        source: QuestSource.dailyLever,
      ),
      Quest(
        id: 'q3',
        title: 'Ask Lina to read the draft',
        createdAt: DateTime(2026, 11, 2),
        dueDate: '2026-11-06',
      ),
      Quest(
        id: 'q4',
        title: 'Clear the desk',
        createdAt: DateTime(2026, 11, 1),
        completedOn: const {'2026-11-02'},
      ),
    ],
    project: () => MonthProject(
      title: 'Finish and share the first essay.',
      status: ProjectStatus.active,
      milestones: const [
        Milestone(id: 'm1', title: 'Outline the argument', done: true),
        Milestone(id: 'm2', title: 'Write a rough draft'),
        Milestone(id: 'm3', title: 'Share it with two friends'),
      ],
      retrospective: '',
      updatedAt: _at,
    ),
    pathAnswers: {
      for (final d in [1, 2, 3])
        d: PathAnswer(day: d, body: 'Noticed something.', updatedAt: _at),
    },
  );
}

void main() {
  for (final brightness in Brightness.values) {
    final b = brightness.name;

    testWidgets('compass ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        content: englishContent,
        home: const CompassTab(),
        brightness: brightness,
      );
      await captureScreenshot(tester, 'compass_01_compass_$b');
    });

    testWidgets('compass empty with import offer + sheet ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(withCompass: false),
        content: englishContent,
        home: const CompassTab(),
        brightness: brightness,
      );
      await captureScreenshot(tester, 'compass_02_empty_offer_$b');
      showCompassImport(tester.element(find.byType(CompassTab)));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'compass_03_import_sheet_$b');
    });

    testWidgets('versions ($b)', (tester) async {
      final data = _data();
      await pumpCartha(
        tester,
        data: data,
        content: englishContent,
        home: const CompassVersionsScreen(),
        brightness: brightness,
      );
      await captureScreenshot(tester, 'compass_04_versions_$b');
      await tester.tap(find.text('Before an import'));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'compass_05_version_$b');
    });

    testWidgets('missions ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data().copyWith(
          compass: const LifeCompass(
            dailyLevers: 'Stretch for 5 minutes\nRead 10 pages',
          ),
        ),
        content: englishContent,
        home: const CompassTab(initial: CompassSection.missions),
        brightness: brightness,
      );
      await captureScreenshot(tester, 'missions_01_missions_$b');
      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, -1100));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'missions_02_path_$b');
    });

    testWidgets('quest sheet ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        content: englishContent,
        home: const CompassTab(initial: CompassSection.missions),
        brightness: brightness,
      );
      showQuestSheet(
        tester.element(find.byType(CompassTab)),
        quest: Quest(
          id: 'q3',
          title: 'Ask Lina to read the draft',
          createdAt: DateTime(2026, 11, 2),
          dueDate: '2026-11-06',
        ),
      );
      await pumpFrames(tester);
      await captureScreenshot(tester, 'missions_03_quest_sheet_$b');
    });

    testWidgets('project ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        content: englishContent,
        home: const ProjectScreen(),
        brightness: brightness,
      );
      await captureScreenshot(tester, 'missions_04_project_$b');
    });

    testWidgets('path day ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        content: englishContent,
        home: const PathDayScreen(day: 4),
        brightness: brightness,
      );
      await captureScreenshot(tester, 'missions_05_path_day_$b');
    });
  }
}
