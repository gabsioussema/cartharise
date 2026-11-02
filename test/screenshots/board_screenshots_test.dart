// Renders Missions › Board to PNGs for design review against
// "Cartharise Brand and App System Board.png" (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _at = DateTime(2026, 11, 1, 9);

Quest _q(
  String id,
  String title, {
  QuestStage stage = QuestStage.ready,
  QuestRecurrence recurrence = QuestRecurrence.none,
  String? dueDate,
  Set<String> completedOn = const {},
  QuestSource source = QuestSource.manual,
  String? projectId,
}) => Quest(
  id: id,
  title: title,
  createdAt: _at,
  stage: stage,
  recurrence: recurrence,
  dueDate: dueDate,
  completedOn: completedOn,
  source: source,
  projectId: projectId,
).normalized();

AppData _data({bool crowded = false}) {
  final project = MonthProject(
    id: 'project_essay',
    title: 'Finish the first essay',
    status: ProjectStatus.active,
    updatedAt: _at,
    startedAt: _at,
  );
  return onboardedData().copyWith(
    project: () => project,
    quests: [
      _q('l1', 'Sort the old photos', stage: QuestStage.later),
      _q(
        'l2',
        'Plan the weekend trip',
        stage: QuestStage.later,
        dueDate: '2026-11-20',
      ),
      _q(
        'r1',
        'Walk after lunch',
        recurrence: QuestRecurrence.daily,
        source: QuestSource.dailyLever,
      ),
      _q(
        'r2',
        'Ask Lina to read the draft',
        dueDate: '2026-11-03',
        projectId: project.id,
      ),
      _q(
        'r3',
        'Ten minutes outside without the phone',
        source: QuestSource.experiment,
      ),
      _q(
        'd1',
        'Write the second section',
        stage: QuestStage.doing,
        projectId: project.id,
      ),
      if (crowded) ...[
        _q('d2', 'Fix the bike light', stage: QuestStage.doing),
        _q('d3', 'Call the bank', stage: QuestStage.doing),
        _q('d4', 'Book the dentist', stage: QuestStage.doing),
      ],
      _q(
        'x1',
        'Write for 30 minutes',
        recurrence: QuestRecurrence.daily,
        completedOn: const {'2026-11-03'},
      ),
      _q('x2', 'Clear the desk', completedOn: const {'2026-11-02'}),
    ],
  );
}

Future<void> _board(WidgetTester tester) async {
  // Below the section pills, which stack at 320 dp / 200 % (never a broken
  // word): scrolled into view first.
  await tester.ensureVisible(find.text('Board'));
  await pumpFrames(tester, count: 2);
  await tester.tap(find.text('Board'));
  await pumpFrames(tester);
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await pumpFrames(tester, count: 2);
}

void main() {
  for (final brightness in Brightness.values) {
    final b = brightness.name;

    testWidgets('board on a phone ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        home: const CompassTab(initial: CompassSection.missions),
        brightness: brightness,
      );
      await _board(tester);
      await captureScreenshot(tester, 'board_00_top_$b');
      await _scrollTo(tester, find.byKey(const ValueKey('board-lane-later')));
      await captureScreenshot(tester, 'board_01_phone_$b');
      await _scrollTo(tester, find.byKey(const ValueKey('board-lane-done')));
      await tester.tap(find.byKey(const ValueKey('board-toggle-done')));
      await pumpFrames(tester);
      await _scrollTo(tester, find.byKey(const ValueKey('board-lane-done')));
      await captureScreenshot(tester, 'board_02_phone_done_$b');
    });

    testWidgets('board, Doing crowded and Today filter ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(crowded: true),
        home: const CompassTab(initial: CompassSection.missions),
        brightness: brightness,
      );
      await _board(tester);
      await tester.tap(find.byKey(const ValueKey('board-today-filter')));
      await pumpFrames(tester);
      await _scrollTo(tester, find.byKey(const ValueKey('board-lane-ready')));
      await captureScreenshot(tester, 'board_03_today_filter_$b');
      await _scrollTo(tester, find.byKey(const ValueKey('board-today-filter')));
      await tester.tap(find.byKey(const ValueKey('board-today-filter')));
      await pumpFrames(tester);
      await _scrollTo(tester, find.byKey(const ValueKey('board-doing-note')));
      await captureScreenshot(tester, 'board_04_doing_note_$b');
    });

    testWidgets('board, dragging and the move menu ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        home: const CompassTab(initial: CompassSection.missions),
        brightness: brightness,
      );
      await _board(tester);
      await _scrollTo(tester, find.byKey(const ValueKey('board-lane-ready')));
      final card = find.byKey(const ValueKey('board-card-r3'));
      final gesture = await tester.startGesture(tester.getCenter(card));
      await tester.pump(const Duration(milliseconds: 600));
      final doing = find.byKey(const ValueKey('board-lane-doing'));
      await gesture.moveTo(tester.getCenter(doing) + const Offset(0, -20));
      await tester.pump();
      await gesture.moveBy(const Offset(0, 4));
      await tester.pump();
      await captureScreenshot(tester, 'board_05_dragging_$b');
      await gesture.up();
      await pumpFrames(tester);

      await tester.tap(find.byKey(const ValueKey('board-move-r1')));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'board_06_move_menu_$b');
    });

    testWidgets('board on a tablet ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(crowded: true),
        home: const CompassTab(initial: CompassSection.missions),
        size: const Size(1024, 1366),
        textScale: 1.3,
        brightness: brightness,
      );
      await _board(tester);
      await _scrollTo(tester, find.byKey(const ValueKey('board-lane-ready')));
      await captureScreenshot(tester, 'board_07_tablet_$b');
    });

    testWidgets('board at 320 dp and 200 % text ($b)', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        home: const CompassTab(initial: CompassSection.missions),
        size: const Size(320, 568),
        textScale: 2,
        brightness: brightness,
      );
      await _board(tester);
      await _scrollTo(tester, find.byKey(const ValueKey('board-card-r2')));
      await captureScreenshot(tester, 'board_08_small_$b');
    });
  }
}
