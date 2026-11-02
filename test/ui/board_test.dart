import 'dart:ui' show Tristate;

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/missions/board_view.dart';
import 'package:cartharise/ui/missions/missions_logic.dart';
import 'package:cartharise/ui/missions/quest_sheet.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// Missions › Board (plan step 2 · D): lanes Later → Ready → Doing → Done,
/// "Move to…" and drag, the Today filter, Done folded, the gentle Doing
/// note, XP only from completing, every size, dark and light, a11y.

final _created = DateTime(2026, 11, 1, 9);
const _today = '2026-11-03'; // kTestNow

Quest _q(
  String id,
  String title, {
  QuestStage stage = QuestStage.ready,
  QuestRecurrence recurrence = QuestRecurrence.none,
  String? dueDate,
  Set<String> completedOn = const {},
  QuestSource source = QuestSource.manual,
  String? projectId,
  DateTime? createdAt,
}) => Quest(
  id: id,
  title: title,
  createdAt: createdAt ?? _created,
  stage: stage,
  recurrence: recurrence,
  dueDate: dueDate,
  completedOn: completedOn,
  source: source,
  projectId: projectId,
).normalized();

AppData _data(
  List<Quest> quests, {
  bool game = true,
  bool motion = true,
  MonthProject? project,
}) => onboardedData(
  settings: AppSettings(game: game, motion: motion),
).copyWith(quests: quests, project: () => project);

/// A tall window, so every lane is on screen at once (drag tests).
const _tall = Size(480, 2400);

Future<CarthaHarness> _pumpBoard(
  WidgetTester tester, {
  required AppData data,
  DateTime? now,
  Size size = _tall,
  double textScale = 1,
  Brightness brightness = Brightness.dark,
}) async {
  final h = await pumpCartha(
    tester,
    data: data,
    home: const CompassTab(initial: CompassSection.missions),
    now: now,
    size: size,
    textScale: textScale,
    brightness: brightness,
  );
  await _tap(tester, find.text('Board'));
  return h;
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester, count: 4);
}

Finder _lane(QuestStage lane) =>
    find.byKey(ValueKey('board-lane-${lane.name}'));

Finder _card(String id) => find.byKey(ValueKey('board-card-$id'));

/// The quest card [id] shown inside [lane].
Finder _cardIn(QuestStage lane, String id) =>
    find.descendant(of: _lane(lane), matching: _card(id));

Finder _textIn(QuestStage lane, String text) =>
    find.descendant(of: _lane(lane), matching: find.text(text));

Future<void> _moveByMenu(WidgetTester tester, String id, QuestStage to) async {
  await _tap(tester, find.byKey(ValueKey('board-move-$id')));
  await tester.tap(find.byKey(ValueKey('board-move-$id-${to.name}')));
  await pumpFrames(tester, count: 4);
}

Future<void> _drag(WidgetTester tester, String id, QuestStage to) async {
  final card = _card(id);
  final gesture = await tester.startGesture(tester.getCenter(card));
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
  await gesture.moveTo(tester.getCenter(_lane(to)));
  await tester.pump();
  await gesture.moveBy(const Offset(0, 2));
  await tester.pump();
  expect(find.text('Drop to move here'), findsOneWidget);
  await gesture.up();
  await pumpFrames(tester, count: 4);
}

void main() {
  group('lanes', () {
    testWidgets('List by default; Board shows each quest in its lane', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await pumpCartha(
        tester,
        data: _data([
          _q('l', 'Sort photos', stage: QuestStage.later),
          _q('r', 'Call Ana'),
          _q('g', 'Write the intro', stage: QuestStage.doing),
          _q('x', 'Clear the desk', completedOn: {'2026-11-02'}),
          _q(
            'w',
            'Walk',
            recurrence: QuestRecurrence.daily,
            completedOn: {_today},
          ),
        ]),
        home: const CompassTab(initial: CompassSection.missions),
        size: _tall,
      );
      // The list comes first; the board is one tap away.
      expect(find.text('Anytime & upcoming'), findsOneWidget);
      expect(find.byType(QuestBoard), findsNothing);
      await _tap(tester, find.text('Board'));
      expect(find.byType(QuestBoard), findsOneWidget);
      expect(find.text('Anytime & upcoming'), findsNothing);

      expect(_cardIn(QuestStage.later, 'l'), findsOneWidget);
      expect(_cardIn(QuestStage.ready, 'r'), findsOneWidget);
      expect(_cardIn(QuestStage.doing, 'g'), findsOneWidget);
      // Lanes run Later → Ready → Doing → Done.
      final tops = [
        for (final s in QuestStage.values) tester.getTopLeft(_lane(s)).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      // Each lane is announced with its name and count.
      expect(find.bySemanticsLabel('Later, 1 quest'), findsOneWidget);
      expect(find.bySemanticsLabel('Doing, 1 quest'), findsOneWidget);
      expect(find.bySemanticsLabel('Done, 2 quests'), findsOneWidget);
      // One task list: the board is a view, nothing was written.
      expect(h.store.writes, 0);

      await _tap(tester, find.text('List'));
      expect(find.text('Anytime & upcoming'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('the view is kept while switching sections', (tester) async {
      await _pumpBoard(tester, data: _data([_q('r', 'Call Ana')]));
      await _tap(tester, find.text('Campaign').first);
      expect(find.byType(QuestBoard), findsNothing);
      await _tap(tester, find.text('Missions').first);
      expect(find.byType(QuestBoard), findsOneWidget);
    });

    testWidgets('empty lanes say what they hold, calmly', (tester) async {
      await _pumpBoard(tester, data: _data(const []));
      expect(find.text('Park ideas here for another time.'), findsOneWidget);
      expect(find.text('Quests ready to start.'), findsOneWidget);
      expect(find.text('Move a quest here when you start it.'), findsOneWidget);
      expect(find.text('Finished quests land here.'), findsOneWidget);
      expect(
        find.textContaining(
          RegExp(r'streak|missed|points|score|fail', caseSensitive: false),
        ),
        findsNothing,
      );
    });

    testWidgets('"Add to …" adds a quest in that lane', (tester) async {
      final h = await _pumpBoard(tester, data: _data(const []));
      await _tap(tester, find.byKey(const ValueKey('board-add-later')));
      expect(find.byType(QuestSheet), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('quest-title')),
        'Sort photos',
      );
      await _tap(tester, find.text('Save quest'));
      final added = h.state.data.quests.single;
      expect(added.title, 'Sort photos');
      expect(added.stage, QuestStage.later);
      expect(_textIn(QuestStage.later, 'Sort photos'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('board-add-doing')));
      await tester.enterText(find.byKey(const ValueKey('quest-title')), 'Go');
      await _tap(tester, find.text('Save quest'));
      expect(h.state.data.quests.last.stage, QuestStage.doing);
      expect(find.byKey(const ValueKey('board-add-done')), findsNothing);
    });

    testWidgets('cards carry the list labels: source, project, XP', (
      tester,
    ) async {
      final project = MonthProject(
        id: 'project_shed',
        title: 'Build the shed',
        status: ProjectStatus.active,
        updatedAt: _created,
      );
      await _pumpBoard(
        tester,
        data: _data([
          _q('t', 'Ten minutes outside', source: QuestSource.experiment),
          _q('p', 'Buy the wood', projectId: project.id),
          _q('d', 'Walk', recurrence: QuestRecurrence.daily),
          _q('u', 'Plan the trip', dueDate: '2026-11-20'),
        ], project: project),
      );
      expect(find.byKey(const ValueKey('quest-source-t')), findsOneWidget);
      expect(find.text('Experiment'), findsOneWidget);
      expect(find.byKey(const ValueKey('quest-project-p')), findsOneWidget);
      expect(_textIn(QuestStage.ready, 'Build the shed'), findsOneWidget);
      expect(find.text('Every day'), findsOneWidget);
      expect(find.text('Planned for Fri, Nov 20'), findsOneWidget);
      for (final id in ['t', 'p', 'd', 'u']) {
        expect(find.byKey(ValueKey('quest-xp-$id')), findsOneWidget);
      }
      // The same project label in the list.
      await _tap(tester, find.text('List'));
      expect(find.byKey(const ValueKey('quest-project-p')), findsOneWidget);
    });

    testWidgets('no XP chip with the Campaign off', (tester) async {
      await _pumpBoard(tester, data: _data([_q('r', 'Call Ana')], game: false));
      expect(find.byKey(const ValueKey('quest-xp-r')), findsNothing);
      expect(find.textContaining('XP'), findsNothing);
    });
  });

  group('moving cards', () {
    testWidgets('"Move to…" moves a card, says so, and Undo puts it back', (
      tester,
    ) async {
      final h = await _pumpBoard(tester, data: _data([_q('r', 'Call Ana')]));
      await _tap(tester, find.byTooltip("Move 'Call Ana' to…"));
      // The other three lanes, never the one it is in.
      expect(find.text('Move to Later'), findsOneWidget);
      expect(find.text('Move to Doing'), findsOneWidget);
      expect(find.text('Move to Done'), findsOneWidget);
      expect(find.text('Move to Ready'), findsNothing);
      await tester.tap(find.text('Move to Doing'));
      await pumpFrames(tester, count: 4);
      expect(h.state.questById('r')!.stage, QuestStage.doing);
      expect(h.state.questById('r')!.completedOn, isEmpty);
      expect(_cardIn(QuestStage.doing, 'r'), findsOneWidget);
      expect(find.text("'Call Ana' moved to Doing"), findsOneWidget);
      expect(h.store.saved!.quests.single.stage, QuestStage.doing);

      await tester.tap(find.text('Undo'));
      await pumpFrames(tester, count: 4);
      expect(h.state.questById('r')!.stage, QuestStage.ready);
      expect(_cardIn(QuestStage.ready, 'r'), findsOneWidget);
    });

    testWidgets('drag a card to another lane', (tester) async {
      final h = await _pumpBoard(
        tester,
        data: _data([
          _q('l', 'Sort photos', stage: QuestStage.later),
          _q('r', 'Call Ana'),
        ]),
      );
      await _drag(tester, 'l', QuestStage.doing);
      expect(h.state.questById('l')!.stage, QuestStage.doing);
      expect(_cardIn(QuestStage.doing, 'l'), findsOneWidget);
      expect(find.text("'Sort photos' moved to Doing"), findsOneWidget);
      expect(find.text('Drop to move here'), findsNothing);

      // Into Done (folded) completes it today.
      await _drag(tester, 'r', QuestStage.done);
      expect(h.state.questById('r')!.completedOn, {_today});
      expect(h.state.questById('r')!.stage, QuestStage.done);
      expect(_textIn(QuestStage.done, '1'), findsOneWidget); // its count
    });

    testWidgets('a card dropped back on its own lane changes nothing', (
      tester,
    ) async {
      final h = await _pumpBoard(tester, data: _data([_q('r', 'Call Ana')]));
      final gesture = await tester.startGesture(tester.getCenter(_card('r')));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      expect(find.text('Drop to move here'), findsNothing);
      await gesture.up();
      await pumpFrames(tester);
      expect(h.state.questById('r')!.stage, QuestStage.ready);
      expect(h.store.writes, 0);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a reopened one-off: Undo restores its first done day', (
      tester,
    ) async {
      final h = await _pumpBoard(
        tester,
        data: _data([
          _q('x', 'Clear the desk', completedOn: {'2026-11-01'}),
        ]),
      );
      await _tap(tester, find.byKey(const ValueKey('board-toggle-done')));
      await _moveByMenu(tester, 'x', QuestStage.ready);
      expect(h.state.questById('x')!.completedOn, isEmpty);
      expect(_cardIn(QuestStage.ready, 'x'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await pumpFrames(tester, count: 4);
      final x = h.state.questById('x')!;
      expect(x.completedOn, {'2026-11-01'});
      expect(x.stage, QuestStage.done);
    });

    testWidgets('screen readers get "Move to …" actions on the card', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpBoard(tester, data: _data([_q('r', 'Call Ana')]));
      final node = find.semantics.byPredicate((n) {
        final d = n.getSemanticsData();
        return d.label.contains('Call Ana') &&
            d.hasAction(SemanticsAction.customAction);
      });
      expect(node, findsOne);
      tester.semantics.customAction(
        node,
        const CustomSemanticsAction(label: 'Move to Later'),
      );
      await pumpFrames(tester, count: 4);
      expect(h.state.questById('r')!.stage, QuestStage.later);
      semantics.dispose();
    });

    testWidgets('a failed save is said honestly, with Retry', (tester) async {
      final h = await _pumpBoard(tester, data: _data([_q('r', 'Call Ana')]));
      h.store.failWrites = true;
      await _moveByMenu(tester, 'r', QuestStage.doing);
      expect(find.text("Your last change couldn't be saved."), findsWidgets);
      expect(find.textContaining('moved to'), findsNothing);
      h.store.failWrites = false;
      await tester.tap(find.widgetWithText(SnackBarAction, 'Retry'));
      await pumpFrames(tester, count: 4);
      expect(h.state.saveStatus, SaveStatus.saved);
      expect(h.store.saved!.quests.single.stage, QuestStage.doing);
    });
  });

  group('completion and XP', () {
    testWidgets('moving between Later, Ready and Doing never earns XP', (
      tester,
    ) async {
      final h = await _pumpBoard(
        tester,
        data: _data([
          _q('a', 'Call Ana', stage: QuestStage.later),
          _q('b', 'Book dentist'),
        ]),
      );
      final xp = h.state.campaign.xp;
      await _moveByMenu(tester, 'a', QuestStage.ready);
      await _moveByMenu(tester, 'a', QuestStage.doing);
      await _drag(tester, 'b', QuestStage.later);
      await _drag(tester, 'b', QuestStage.doing);
      expect(h.state.campaign.xp, xp);
      expect(h.state.campaign.questsCompleted, 0);

      // Into Done: the same as ticking it — +20 XP by the existing rule.
      await _moveByMenu(tester, 'a', QuestStage.done);
      expect(h.state.campaign.xp, xp + kXpPerQuest);
      expect(h.state.campaign.questsCompleted, 1);
      // Out of Done: un-completed, the XP goes with it.
      await _tap(tester, find.byKey(const ValueKey('board-toggle-done')));
      await _moveByMenu(tester, 'a', QuestStage.doing);
      expect(h.state.campaign.xp, xp);
      expect(h.state.questById('a')!.stage, QuestStage.doing);
    });

    testWidgets('Done respects the daily quest cap, like the checkbox', (
      tester,
    ) async {
      final h = await _pumpBoard(
        tester,
        data: _data([
          for (var i = 0; i < kQuestDaysCap; i++)
            _q('done$i', 'Done $i', completedOn: {_today}),
          _q('n', 'Call Ana'),
        ]),
      );
      final xp = h.state.campaign.xp;
      // Today's quest XP is used up: no "+20 XP" promise on the card.
      expect(find.byKey(const ValueKey('quest-xp-n')), findsNothing);
      await _moveByMenu(tester, 'n', QuestStage.done);
      expect(h.state.campaign.xp, xp);
      expect(h.state.questById('n')!.completedOn, {_today});
    });

    testWidgets('a daily quest: done for today, back in Ready tomorrow', (
      tester,
    ) async {
      final h = await _pumpBoard(
        tester,
        data: _data([
          _q(
            'w',
            'Walk',
            recurrence: QuestRecurrence.daily,
            stage: QuestStage.doing,
            completedOn: {'2026-11-01'},
          ),
        ]),
      );
      await _moveByMenu(tester, 'w', QuestStage.done);
      expect(find.text("'Walk' done for today"), findsOneWidget);
      var w = h.state.questById('w')!;
      expect(w.completedOn, {'2026-11-01', _today});
      expect(w.laneOn(_today), QuestStage.done);
      await _tap(tester, find.byKey(const ValueKey('board-toggle-done')));
      expect(_cardIn(QuestStage.done, 'w'), findsOneWidget);
      expect(_textIn(QuestStage.done, 'Done today'), findsOneWidget);

      // The next day it waits in Ready, its history kept.
      final next = await _pumpBoard(
        tester,
        data: h.state.data,
        now: DateTime(2026, 11, 4, 8),
      );
      w = next.state.questById('w')!;
      expect(w.completedOn, {'2026-11-01', _today});
      expect(_cardIn(QuestStage.ready, 'w'), findsOneWidget);
      expect(find.text('Done today'), findsNothing);
      expect(find.text('Finished quests land here.'), findsOneWidget);
    });
  });

  group('Today filter', () {
    final quests = [
      _q(
        'daily',
        'Walk',
        recurrence: QuestRecurrence.daily,
        stage: QuestStage.later,
      ),
      _q('due', 'Due today', dueDate: _today),
      _q('soon', 'Due next week', dueDate: '2026-11-10'),
      _q('any', 'Anytime', stage: QuestStage.doing),
      _q('past', 'From Monday', dueDate: '2026-11-02', stage: QuestStage.doing),
      _q('fin', 'Finished today', dueDate: _today, completedOn: {_today}),
      _q('old', 'Finished before', completedOn: {'2026-11-01'}),
    ];

    testWidgets('keeps today\'s quests in every lane, stages untouched', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await _pumpBoard(tester, data: _data(quests));
      await _tap(tester, find.byKey(const ValueKey('board-toggle-done')));
      expect(_card('soon'), findsOneWidget);
      expect(_card('old'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('board-today-filter')));
      final chip = tester.widget<FilterChip>(
        find.byKey(const ValueKey('board-today-filter')),
      );
      expect(chip.selected, isTrue);
      // Daily and planned for today (or earlier, never "missed"), in their
      // own lanes; finished today stays in Done.
      expect(_cardIn(QuestStage.later, 'daily'), findsOneWidget);
      expect(_cardIn(QuestStage.ready, 'due'), findsOneWidget);
      expect(_cardIn(QuestStage.doing, 'past'), findsOneWidget);
      expect(_cardIn(QuestStage.done, 'fin'), findsOneWidget);
      expect(_card('soon'), findsNothing);
      expect(_card('any'), findsNothing);
      expect(_card('old'), findsNothing);
      expect(find.bySemanticsLabel('Doing, 1 quest'), findsOneWidget);
      // The filter is a view: nothing moved, nothing written.
      expect(h.state.questById('any')!.stage, QuestStage.doing);
      expect(h.store.writes, 0);

      await _tap(tester, find.byKey(const ValueKey('board-today-filter')));
      expect(_card('any'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a new quest the filter hides is said, with "Show all"', (
      tester,
    ) async {
      final h = await _pumpBoard(tester, data: _data(const []));
      await _tap(tester, find.byKey(const ValueKey('board-today-filter')));
      expect(find.text('Nothing here for today.'), findsNWidgets(4));

      // A daily quest is for today: shown, nothing to say.
      await _tap(tester, find.byKey(const ValueKey('board-add-ready')));
      await tester.enterText(find.byKey(const ValueKey('quest-title')), 'Walk');
      await _tap(tester, find.text('Repeat every day'));
      await _tap(tester, find.text('Save quest'));
      expect(find.text('Added. The Today filter hides it.'), findsNothing);
      expect(_textIn(QuestStage.ready, 'Walk'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('board-add-later')));
      await tester.enterText(
        find.byKey(const ValueKey('quest-title')),
        'Sort photos',
      );
      await _tap(tester, find.text('Save quest'));
      expect(h.state.data.quests.last.stage, QuestStage.later);
      expect(find.text('Added. The Today filter hides it.'), findsOneWidget);
      expect(_textIn(QuestStage.later, 'Sort photos'), findsNothing);
      await tester.tap(find.text('Show all'));
      await pumpFrames(tester, count: 4);
      expect(
        tester
            .widget<FilterChip>(
              find.byKey(const ValueKey('board-today-filter')),
            )
            .selected,
        isFalse,
      );
      expect(_textIn(QuestStage.later, 'Sort photos'), findsOneWidget);
    });
  });

  group('Done and Doing', () {
    testWidgets('Done is folded with its count until opened', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpBoard(
        tester,
        data: _data([
          _q('x', 'Clear the desk', completedOn: {'2026-11-02'}),
          _q('y', 'Pay the bill', completedOn: {_today}),
        ]),
      );
      expect(find.text('Done (2)'), findsNothing); // the count is a chip
      expect(_textIn(QuestStage.done, '2'), findsOneWidget);
      expect(
        find.text('Folded away. Drop a card here to finish it.'),
        findsOneWidget,
      );
      expect(_card('x'), findsNothing);
      final header = find.semantics.byLabel('Done, 2 quests');
      expect(header, findsOne);
      expect(
        header.evaluate().single.getSemanticsData().flagsCollection.isExpanded,
        Tristate.isFalse,
      );

      tester.semantics.tap(header);
      await pumpFrames(tester, count: 4);
      expect(_cardIn(QuestStage.done, 'x'), findsOneWidget);
      expect(_cardIn(QuestStage.done, 'y'), findsOneWidget);
      // Most recently finished first.
      expect(
        tester.getTopLeft(_card('y')).dy,
        lessThan(tester.getTopLeft(_card('x')).dy),
      );
      expect(_textIn(QuestStage.done, 'Done today'), findsOneWidget);
      expect(_textIn(QuestStage.done, 'Done Mon, Nov 2'), findsOneWidget);
      expect(
        find.semantics
            .byLabel('Done, 2 quests')
            .evaluate()
            .single
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        Tristate.isTrue,
      );

      await _tap(tester, find.byKey(const ValueKey('board-toggle-done')));
      expect(_card('x'), findsNothing);
      semantics.dispose();
    });

    testWidgets('more than three in Doing: a gentle note, never a limit', (
      tester,
    ) async {
      final h = await _pumpBoard(
        tester,
        data: _data([
          for (var i = 0; i < 3; i++)
            _q('d$i', 'Doing $i', stage: QuestStage.doing),
          _q('r', 'Call Ana'),
          _q('s', 'Book dentist'),
        ]),
      );
      expect(find.byKey(const ValueKey('board-doing-note')), findsNothing);
      await _moveByMenu(tester, 'r', QuestStage.doing);
      expect(find.text('Fewer in Doing can feel lighter.'), findsOneWidget);
      // Still free to add more.
      await _drag(tester, 's', QuestStage.doing);
      expect(h.state.questBoard()[QuestStage.doing], hasLength(5));
      expect(find.text('Fewer in Doing can feel lighter.'), findsOneWidget);
    });
  });

  group('motion', () {
    for (final motion in [true, false]) {
      testWidgets('the move menu honours Settings › Motion ($motion)', (
        tester,
      ) async {
        await _pumpBoard(
          tester,
          data: _data([_q('r', 'Call Ana')], motion: motion),
        );
        final menu = tester.widget<PopupMenuButton<QuestStage>>(
          find.byKey(const ValueKey('board-move-r')),
        );
        expect(
          menu.popUpAnimationStyle,
          motion ? isNull : AnimationStyle.noAnimation,
        );
      });
    }

    testWidgets('the move menu honours the device reduce-motion setting', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await _pumpBoard(tester, data: _data([_q('r', 'Call Ana')]));
      final menu = tester.widget<PopupMenuButton<QuestStage>>(
        find.byKey(const ValueKey('board-move-r')),
      );
      expect(menu.popUpAnimationStyle, AnimationStyle.noAnimation);
    });
  });

  group('screen sizes and accessibility', () {
    final quests = [
      _q(
        'l',
        'Sort the old photos from the trip to the coast last summer',
        stage: QuestStage.later,
        dueDate: '2026-11-20',
      ),
      _q(
        'r',
        'Ten minutes outside without the phone, even when it rains',
        source: QuestSource.experiment,
        projectId: 'project_shed',
      ),
      _q(
        'w',
        'Walk after lunch',
        recurrence: QuestRecurrence.daily,
        stage: QuestStage.doing,
      ),
      for (var i = 0; i < 3; i++)
        _q('d$i', 'Doing $i', stage: QuestStage.doing),
      _q('x', 'Clear the desk', completedOn: {'2026-11-02'}),
    ];
    final project = MonthProject(
      id: 'project_shed',
      title: 'Finish the garden shed before the first frost',
      status: ProjectStatus.active,
      updatedAt: _created,
    );

    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('board, move menu and add sheet fit $size '
            '(${brightness.name})', (tester) async {
          await _pumpBoard(
            tester,
            data: _data(quests, project: project),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          final columns = size.size.width >= QuestBoard.columnsFrom;
          // Columns side by side on a tablet, stacked lanes on a phone.
          final later = tester.getTopLeft(_lane(QuestStage.later));
          final done = tester.getTopLeft(_lane(QuestStage.done));
          expect(later.dy == done.dy, columns);
          expect(find.byKey(const ValueKey('board-doing-note')), findsOne);
          await _tap(tester, find.byKey(const ValueKey('board-toggle-done')));
          await expectNoOverflow(tester);

          await _tap(tester, find.byKey(const ValueKey('board-move-r')));
          expect(find.text('Move to Doing'), findsOneWidget);
          await expectNoOverflow(tester);
          Navigator.of(tester.element(find.text('Move to Doing'))).pop();
          await pumpFrames(tester);

          await _tap(tester, find.byKey(const ValueKey('board-add-doing')));
          expect(find.byType(QuestSheet), findsOneWidget);
          await expectNoOverflow(tester);
        });
      }
    }

    for (final brightness in Brightness.values) {
      testWidgets('board meets tap-target, label and contrast guidelines '
          '(${brightness.name})', (tester) async {
        final semantics = tester.ensureSemantics();
        await _pumpBoard(
          tester,
          data: _data(quests, project: project),
          size: const Size(390, 844),
          brightness: brightness,
        );
        await _tap(tester, find.byKey(const ValueKey('board-today-filter')));
        await _tap(tester, find.byKey(const ValueKey('board-today-filter')));
        await _tap(tester, find.byKey(const ValueKey('board-toggle-done')));
        for (final lane in QuestStage.values) {
          await tester.ensureVisible(_lane(lane));
          await tester.pump();
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));
        }
        semantics.dispose();
      });
    }
  });
}
