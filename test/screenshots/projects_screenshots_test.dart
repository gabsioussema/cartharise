// Renders the project screens (picture, finish, history, links) to PNGs for
// design review (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/missions/project_history_screen.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/missions/quest_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _at = DateTime(2026, 11, 3, 9, 30);

/// A holiday-like photo (sky, sun, hills, a path) as a real PNG, drawn
/// here so no picture file is needed.
Future<Uint8List> _photoPng() async {
  const w = 900.0;
  const h = 600.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, w, h),
    Paint()
      ..shader = ui.Gradient.linear(const Offset(0, 0), const Offset(0, h), [
        const Color(0xFF6E93BF),
        const Color(0xFFE9C9A0),
      ]),
  );
  canvas.drawCircle(
    const Offset(640, 250),
    60,
    Paint()..color = const Color(0xFFFFE6B0),
  );
  final far = Path()
    ..moveTo(0, 360)
    ..quadraticBezierTo(220, 270, 450, 350)
    ..quadraticBezierTo(680, 420, w, 320)
    ..lineTo(w, h)
    ..lineTo(0, h)
    ..close();
  canvas.drawPath(far, Paint()..color = const Color(0xFF7D8F6A));
  final near = Path()
    ..moveTo(0, 470)
    ..quadraticBezierTo(300, 400, 560, 470)
    ..quadraticBezierTo(760, 520, w, 450)
    ..lineTo(w, h)
    ..lineTo(0, h)
    ..close();
  canvas.drawPath(near, Paint()..color = const Color(0xFF4C6142));
  final road = Path()
    ..moveTo(380, h)
    ..quadraticBezierTo(450, 520, 520, 470)
    ..lineTo(540, 472)
    ..quadraticBezierTo(500, 540, 520, h)
    ..close();
  canvas.drawPath(road, Paint()..color = const Color(0xFFD9C7A3));
  final image = await recorder.endRecording().toImage(w.toInt(), h.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return bytes!.buffer.asUint8List();
}

Attachment _photo(String id) => Attachment(
  id: id,
  kind: AttachmentKind.photo,
  fileName: '$id.png',
  createdAt: _at,
);

MonthProject _current({ProjectArt? art}) => MonthProject(
  id: 'project_now',
  title: 'Finish and share the first essay',
  status: ProjectStatus.active,
  updatedAt: _at,
  startedAt: DateTime(2026, 11, 1, 8),
  milestones: const [
    Milestone(id: 'm1', title: 'Outline the three parts', done: true),
    Milestone(id: 'm2', title: 'First full draft'),
    Milestone(id: 'm3', title: 'Send it to two friends'),
  ],
  retrospective: 'Mornings are where the words are.',
  art: art ?? const ProjectArt.illustration(ProjectIllustration.dawnRuins),
);

AppData _data({MonthProject? project, bool current = true}) =>
    onboardedData().copyWith(
      compass: LifeCompass(
        monthProject: 'Finish and share the first essay',
        updatedAt: _at,
      ),
      project: () => current ? (project ?? _current()) : null,
      pastProjects: [
        MonthProject(
          id: 'project_oct',
          title: 'Clear the garage',
          status: ProjectStatus.done,
          updatedAt: DateTime(2026, 10, 31, 18),
          startedAt: DateTime(2026, 10, 2, 9),
          archivedAt: DateTime(2026, 10, 31, 18),
          milestones: const [
            Milestone(id: 'g1', title: 'Sort the shelves', done: true),
            Milestone(id: 'g2', title: 'Sell the old bike', done: true),
            Milestone(id: 'g3', title: 'Paint the back wall'),
          ],
          retrospective:
              'Two weekends were enough once I stopped waiting for a free '
              'Saturday.\nNext time: ask for help sooner.',
          art: const ProjectArt.illustration(ProjectIllustration.citadel),
        ),
        MonthProject(
          id: 'project_sep',
          title: 'Walk to work three days a week',
          updatedAt: DateTime(2026, 9, 28, 19),
          startedAt: DateTime(2026, 8, 20, 7),
          archivedAt: DateTime(2026, 9, 28, 19),
          milestones: const [
            Milestone(id: 'w1', title: 'Find a quiet route', done: true),
          ],
          retrospective: 'The quiet route made it easy.',
          art: ProjectArt.photo(_photo('att_walk')),
        ),
      ],
      quests: [
        Quest(
          id: 'q1',
          title: 'Write for 30 minutes',
          createdAt: _at,
          recurrence: QuestRecurrence.daily,
          projectId: 'project_now',
        ),
        Quest(
          id: 'q2',
          title: 'Read the draft aloud',
          createdAt: _at,
          dueDate: '2026-11-03',
          projectId: 'project_now',
        ),
        Quest(id: 'q3', title: 'Call Mum', createdAt: _at),
        Quest(
          id: 'q4',
          title: 'Sort the shelves',
          createdAt: DateTime(2026, 10, 3),
          completedOn: const {'2026-10-20'},
          projectId: 'project_oct',
        ),
        Quest(
          id: 'q5',
          title: 'Give the bike away',
          createdAt: DateTime(2026, 10, 3),
          projectId: 'project_oct',
        ),
      ],
      campaignLog: [
        BattleLogEntry(
          id: 'a1',
          day: '2026-11-03',
          attempt: 'Wrote the second section before work.',
          learning: 'Mornings are where the words are.',
          createdAt: _at,
          projectId: 'project_now',
        ),
        BattleLogEntry(
          id: 'a2',
          day: '2026-10-12',
          attempt: 'Emptied one corner in twenty minutes.',
          learning: 'Start small.',
          createdAt: DateTime(2026, 10, 12, 18),
          projectId: 'project_oct',
          // Step 2 media on an attempt: shown in the battle log and the
          // project history.
          attachments: [
            _photo('att_corner'),
            Attachment(
              id: 'att_corner_voice',
              kind: AttachmentKind.audio,
              fileName: 'att_corner_voice.m4a',
              createdAt: DateTime(2026, 10, 12, 18),
              durationMs: 42000,
            ),
          ],
        ),
      ],
    );

Widget _opener(Future<void> Function(BuildContext) open) => Scaffold(
  body: Builder(
    builder: (context) => Center(
      child: TextButton(
        key: const ValueKey('open-sheet'),
        onPressed: () => open(context),
        child: const Text('Open'),
      ),
    ),
  ),
);

void main() {
  late Uint8List photo;

  for (final b in ['dark', 'light']) {
    final brightness = b == 'dark' ? Brightness.dark : Brightness.light;

    Future<CarthaHarness> pump(
      WidgetTester tester,
      Widget home, {
      AppData? data,
      Size size = const Size(390, 844),
    }) async {
      photo = (await tester.runAsync(_photoPng))!;
      final files = MemoryAttachmentStore(clock: () => _at)
        ..files['att_walk.png'] = photo
        ..files['att_now.png'] = photo
        ..files['att_corner.png'] = photo
        ..files['att_corner_voice.m4a'] = Uint8List.fromList([1, 2, 3]);
      return pumpCartha(
        tester,
        data: data ?? _data(),
        home: home,
        size: size,
        brightness: brightness,
        content: englishContent,
        attachments: files,
      );
    }

    Future<void> tap(WidgetTester tester, String key) async {
      final f = find.byKey(ValueKey(key));
      await tester.ensureVisible(f);
      await tester.pump();
      await tester.tap(f);
      await pumpFrames(tester);
    }

    testWidgets('the project with a painted scene ($b)', (tester) async {
      await pump(tester, const ProjectScreen(), size: const Size(390, 1900));
      await captureScreenshot(tester, 'projects_01_project_$b');
    });

    testWidgets('the project with a photo ($b)', (tester) async {
      await pump(
        tester,
        const ProjectScreen(),
        data: _data(
          project: _current(art: ProjectArt.photo(_photo('att_now'))),
        ),
      );
      await captureScreenshot(tester, 'projects_02_photo_$b');
    });

    testWidgets('the picture sheet ($b)', (tester) async {
      await pump(tester, const ProjectScreen(), size: const Size(390, 1100));
      await tap(tester, 'project-art-change');
      await captureScreenshot(tester, 'projects_03_picker_$b');
    });

    testWidgets('the picture sheet after a refused camera ($b)', (
      tester,
    ) async {
      final h = await pump(
        tester,
        const ProjectScreen(),
        size: const Size(390, 1100),
      );
      await tap(tester, 'project-art-change');
      h.media.error = null;
      h.media.nextPhoto = null;
      await tester.drag(find.byType(Scrollable).last, const Offset(0, -900));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'projects_04_picker_photo_$b');
    });

    testWidgets('finishing ($b)', (tester) async {
      await pump(tester, const ProjectScreen(), size: const Size(390, 844));
      await tap(tester, 'project-finish');
      await captureScreenshot(tester, 'projects_05_finish_$b');
    });

    testWidgets('finished and kept ($b)', (tester) async {
      await pump(tester, const ProjectScreen(), size: const Size(390, 1100));
      await tap(tester, 'project-finish');
      await tester.tap(find.byKey(const ValueKey('project-finish-confirm')));
      await pumpFrames(tester, count: 2);
      await tester.pump(const Duration(seconds: 6));
      await pumpFrames(tester);
      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, 2000));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'projects_06_finished_$b');
    });

    testWidgets('the history ($b)', (tester) async {
      await pump(
        tester,
        const ProjectHistoryScreen(),
        size: const Size(390, 1300),
      );
      await captureScreenshot(tester, 'projects_07_history_$b');
    });

    testWidgets('one past project ($b)', (tester) async {
      await pump(
        tester,
        const PastProjectScreen(projectId: 'project_oct'),
        size: const Size(390, 1800),
      );
      await captureScreenshot(tester, 'projects_08_past_$b');
    });

    testWidgets('the history on a tablet ($b)', (tester) async {
      await pump(
        tester,
        const ProjectHistoryScreen(),
        size: const Size(1024, 1366),
      );
      await captureScreenshot(tester, 'projects_09_history_tablet_$b');
    });

    testWidgets('Missions with the project and its tasks ($b)', (tester) async {
      await pump(
        tester,
        const CompassTab(initial: CompassSection.missions),
        size: const Size(390, 1500),
      );
      await captureScreenshot(tester, 'projects_10_missions_$b');
    });

    testWidgets('a task linked from its sheet ($b)', (tester) async {
      await pump(
        tester,
        _opener(
          (c) => showQuestSheet(c, quest: c.read<AppState>().questById('q3')),
        ),
      );
      await tap(tester, 'open-sheet');
      await captureScreenshot(tester, 'projects_11_quest_sheet_$b');
    });

    testWidgets('the battle log with project labels ($b)', (tester) async {
      await pump(tester, const BattleLogScreen(), size: const Size(390, 1300));
      await captureScreenshot(tester, 'projects_12_log_$b');
    });

    testWidgets('the Collection keepsake ($b)', (tester) async {
      await pump(tester, const CollectionScreen(), size: const Size(390, 1500));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -2000));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'projects_13_collection_$b');
    });

    // Step 2 audit fixes: deleting offers "Finish and keep instead"; a
    // painted scene over a photo asks first.
    testWidgets('delete asks, offering to finish and keep ($b)', (
      tester,
    ) async {
      await pump(tester, const ProjectScreen(), size: const Size(390, 1900));
      await tap(tester, 'project-delete');
      await captureScreenshot(tester, 'projects_15_delete_$b');
    });

    testWidgets('delete asks at 320 dp and 200 % text ($b)', (tester) async {
      photo = (await tester.runAsync(_photoPng))!;
      await pumpCartha(
        tester,
        data: _data(),
        home: const ProjectScreen(),
        size: const Size(320, 568),
        textScale: 2,
        brightness: brightness,
        content: englishContent,
      );
      await tap(tester, 'project-delete');
      await captureScreenshot(tester, 'projects_16_delete_small_$b');
    });

    testWidgets('a scene over a photo asks first ($b)', (tester) async {
      await pump(
        tester,
        const ProjectScreen(),
        data: _data(
          project: _current(art: ProjectArt.photo(_photo('att_now'))),
        ),
        size: const Size(390, 1100),
      );
      await tap(tester, 'project-art-change');
      await tap(tester, 'project-art-sunrise');
      await captureScreenshot(tester, 'projects_17_photo_confirm_$b');
    });

    testWidgets('a small phone at 200 % text ($b)', (tester) async {
      photo = (await tester.runAsync(_photoPng))!;
      await pumpCartha(
        tester,
        data: _data(),
        home: const ProjectHistoryScreen(),
        size: const Size(320, 900),
        textScale: 2,
        brightness: brightness,
        content: englishContent,
        attachments: MemoryAttachmentStore(clock: () => _at)
          ..files['att_walk.png'] = photo,
      );
      await captureScreenshot(tester, 'projects_14_small_$b');
    });
  }
}
