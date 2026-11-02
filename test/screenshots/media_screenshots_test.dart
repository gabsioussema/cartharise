// Renders the media screens (photos, voice notes, the recorder, the pinned
// memory, Today's Write · Record, Your data) to PNGs for design review
// against "Cartharise Brand and App System Board.png" (not CI):
//   flutter test --tags screenshots --run-skipped    (make screenshots)
@Tags(['screenshots'])
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/services/media_picker.dart';
import 'package:cartharise/ui/campaign/experiment_entry_sheet.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/screenshot.dart';
import '../support/test_app.dart';

final _t = DateTime(2026, 11, 2, 20, 15);

/// A small landscape "photo" (sky, sun, two hills) as PNG bytes.
Future<Uint8List> _landscape(
  WidgetTester tester, {
  required List<Color> sky,
  required Color sun,
  required Color far,
  required Color near,
  Offset sunAt = const Offset(0.7, 0.34),
}) async {
  final bytes = await tester.runAsync(() async {
    const w = 640.0;
    const h = 480.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, h * 0.75), [
          sky.first,
          sky.last,
        ]),
    );
    canvas.drawCircle(
      Offset(w * sunAt.dx, h * sunAt.dy),
      40,
      Paint()..color = sun,
    );
    final farHills = Path()
      ..moveTo(0, h * 0.62)
      ..quadraticBezierTo(w * 0.25, h * 0.46, w * 0.5, h * 0.6)
      ..quadraticBezierTo(w * 0.78, h * 0.72, w, h * 0.54)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(farHills, Paint()..color = far);
    final nearHill = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.42, h * 0.66, w, h * 0.84)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(nearHill, Paint()..color = near);
    final image = await recorder.endRecording().toImage(w.toInt(), h.toInt());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  return bytes!;
}

Attachment _photo(String id) => Attachment(
  id: id,
  kind: AttachmentKind.photo,
  fileName: '$id.png',
  createdAt: _t,
);

Attachment _voice(String id, {String? transcript}) => Attachment(
  id: id,
  kind: AttachmentKind.audio,
  fileName: '$id.m4a',
  createdAt: _t,
  durationMs: 47000,
  transcript: transcript,
);

/// Two photos and a voice note on the evening note, a try and an attempt.
AppData _data({PinnedMemory? pin, bool media = true}) =>
    onboardedData().copyWith(
      journal: [
        JournalEntry(
          id: 'n1',
          title: 'Evening walk',
          body:
              'I think more clearly outside. The hill path, no phone, '
              'twenty minutes.',
          createdAt: _t,
          attachments: media
              ? [
                  _photo('p1'),
                  _photo('p2'),
                  _voice('v1', transcript: 'Walk first, then write.'),
                ]
              : const [],
        ),
        JournalEntry(
          id: 'n2',
          body: '',
          createdAt: DateTime(2026, 11, 1, 7, 40),
          attachments: [_voice('v2')],
        ),
      ],
      experimentLog: [
        ExperimentEntry(
          id: 'e1',
          experimentId: 'try.pattern.01',
          day: '2026-11-02',
          note: 'Walked without my phone',
          createdAt: _t,
          attachments: [_photo('p3')],
        ),
      ],
      pinnedMemory: () => pin,
    );

Future<MemoryAttachmentStore> _files(WidgetTester tester) async {
  final store = MemoryAttachmentStore(clock: () => kTestNow);
  store.files['p1.png'] = await _landscape(
    tester,
    sky: const [Color(0xFFF3C58A), Color(0xFFFBE7C6)],
    sun: const Color(0xFFFFF4DC),
    far: const Color(0xFF8C9A78),
    near: const Color(0xFF3F5A3C),
  );
  store.files['p2.png'] = await _landscape(
    tester,
    sky: const [Color(0xFF5E7FA6), Color(0xFFBFD3E6)],
    sun: const Color(0xFFFFFFFF),
    far: const Color(0xFF6E8A70),
    near: const Color(0xFF2C4232),
    sunAt: const Offset(0.25, 0.3),
  );
  store.files['p3.png'] = await _landscape(
    tester,
    sky: const [Color(0xFFE7A27A), Color(0xFFF6D9B8)],
    sun: const Color(0xFFFFEBC2),
    far: const Color(0xFFA08C62),
    near: const Color(0xFF5B4A2E),
    sunAt: const Offset(0.5, 0.42),
  );
  store.files['v1.m4a'] = Uint8List.fromList([1, 2, 3]);
  store.files['v2.m4a'] = Uint8List.fromList([4, 5, 6]);
  return store;
}

Finder _key(String key) => find.byKey(ValueKey(key));

Future<void> _tap(WidgetTester tester, Finder f) async {
  await _reveal(tester, f);
  await tester.tap(f);
  await pumpFrames(tester);
}

/// Scrolls the page until [f] is built and on screen.
Future<void> _reveal(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
  await tester.ensureVisible(f);
  await pumpFrames(tester);
}

void main() {
  for (final b in Brightness.values) {
    final suffix = b.name;

    Future<CarthaHarness> pump(
      WidgetTester tester, {
      Widget? home,
      AppData? data,
      ShellController? shell,
      Size size = const Size(390, 844),
    }) async {
      final files = await _files(tester);
      return pumpCartha(
        tester,
        brightness: b,
        data: data ?? _data(),
        content: englishContent,
        attachments: files,
        home: home,
        shell: shell,
        size: size,
      );
    }

    testWidgets('media note $suffix', (tester) async {
      await pump(tester, home: const JournalEntryScreen(entryId: 'n1'));
      await tester.ensureVisible(_key('media-record'));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'media_01_note_$suffix');
    });

    testWidgets('media recording $suffix', (tester) async {
      final h = await pump(
        tester,
        home: const JournalEntryScreen(entryId: 'n1'),
      );
      await _tap(tester, _key('media-record'));
      await tester.pump(const Duration(seconds: 7));
      h.recorder.level(0.62);
      await pumpFrames(tester, count: 2);
      await captureScreenshot(tester, 'media_02_recording_$suffix');
      await _tap(tester, _key('recorder-stop'));
    });

    testWidgets('media interrupted $suffix', (tester) async {
      final h = await pump(
        tester,
        home: const JournalEntryScreen(entryId: 'n1'),
      );
      await _tap(tester, _key('media-record'));
      h.recorder.elapsed = const Duration(seconds: 12);
      h.recorder.interrupt();
      await pumpFrames(tester);
      await captureScreenshot(tester, 'media_03_interrupted_$suffix');
    });

    testWidgets('media photo viewer $suffix', (tester) async {
      await pump(
        tester,
        home: const JournalEntryScreen(entryId: 'n1'),
        data: _data(
          pin: PinnedMemory(
            kind: PinnedKind.photo,
            sourceId: 'n1',
            attachmentId: 'p1',
            pinnedAt: _t,
          ),
        ),
      );
      await _tap(tester, _key('photo-p1'));
      await captureScreenshot(tester, 'media_04_viewer_$suffix');
    });

    testWidgets('media journal pinned passage $suffix', (tester) async {
      await pump(
        tester,
        data: _data(
          pin: PinnedMemory(
            kind: PinnedKind.passage,
            sourceId: 'n1',
            excerpt: 'I think more clearly outside.',
            pinnedAt: _t,
          ),
        ),
        shell: ShellController(initial: AppTab.journal),
      );
      await captureScreenshot(tester, 'media_05_journal_pinned_$suffix');
    });

    testWidgets('media journal pinned photo $suffix', (tester) async {
      await pump(
        tester,
        data: _data(
          pin: PinnedMemory(
            kind: PinnedKind.photo,
            sourceId: 'e1',
            attachmentId: 'p3',
            excerpt: 'Walked without my phone',
            pinnedAt: _t,
          ),
        ),
        shell: ShellController(initial: AppTab.journal),
      );
      await captureScreenshot(tester, 'media_06_journal_pinned_photo_$suffix');
    });

    testWidgets('media today capture $suffix', (tester) async {
      await pump(tester, data: _data(media: false));
      await tester.ensureVisible(_key('today-capture'));
      await pumpFrames(tester);
      await captureScreenshot(tester, 'media_07_today_capture_$suffix');
    });

    testWidgets('media today capture small $suffix', (tester) async {
      final files = await _files(tester);
      await pumpCartha(
        tester,
        brightness: b,
        data: _data(media: false),
        content: englishContent,
        attachments: files,
        size: const Size(320, 568),
        textScale: 2,
      );
      await _reveal(tester, _key('today-capture'));
      await captureScreenshot(tester, 'media_08_today_capture_small_$suffix');
    });

    testWidgets('media your data $suffix', (tester) async {
      await pump(tester, home: const DataScreen());
      await captureScreenshot(tester, 'media_09_data_$suffix');
    });

    testWidgets('media microphone denied $suffix', (tester) async {
      final h = await pump(
        tester,
        home: const JournalEntryScreen(entryId: 'n1'),
      );
      h.recorder.permission = false;
      await _tap(tester, _key('media-record'));
      await captureScreenshot(tester, 'media_10_mic_denied_$suffix');
    });

    testWidgets('media try sheet $suffix', (tester) async {
      final h = await pump(
        tester,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                key: const ValueKey('open'),
                onPressed: () => showExperimentEntrySheet(
                  context,
                  _data().experimentLog.single,
                  title: 'Leave the phone in another room',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await _tap(tester, _key('open'));
      h.media.error = const MediaPickerException(MediaFailure.permissionDenied);
      await _tap(tester, _key('media-add-photo'));
      await _tap(tester, _key('media-photo-camera'));
      await captureScreenshot(tester, 'media_11_try_sheet_$suffix');
    });

    testWidgets('media photo source $suffix', (tester) async {
      await pump(tester, home: const JournalEntryScreen(entryId: 'n1'));
      await _tap(tester, _key('media-add-photo'));
      await captureScreenshot(tester, 'media_12_photo_source_$suffix');
    });

    // Step 2 audit fixes: what was kept from before waits on Today; a
    // recording cut short stays "Partial"; a backup too large to restore
    // offers the words only.
    testWidgets('media kept from before on Today $suffix', (tester) async {
      final files = await _files(tester);
      final cut = await files.newRecordingPath();
      files.writeRecording(cut, [7, 7, 7]);
      files.restart();
      files.sources['/picked/lost.png'] = files.files['p2.png']!;
      await pumpCartha(
        tester,
        brightness: b,
        data: _data(),
        content: englishContent,
        attachments: files,
        media: FakeMediaPicker()..lostPhoto = '/picked/lost.png',
      );
      await pumpFrames(tester);
      await captureScreenshot(tester, 'media_13_recovered_$suffix');
    });

    testWidgets('media kept from before small $suffix', (tester) async {
      final files = await _files(tester);
      final cut = await files.newRecordingPath();
      files.writeRecording(cut, [7, 7, 7]);
      files.restart();
      await pumpCartha(
        tester,
        brightness: b,
        data: _data(),
        content: englishContent,
        attachments: files,
        size: const Size(320, 568),
        textScale: 2,
      );
      await pumpFrames(tester);
      await captureScreenshot(tester, 'media_14_recovered_small_$suffix');
    });

    testWidgets('media partial voice note $suffix', (tester) async {
      final data = _data();
      await pump(
        tester,
        home: const JournalEntryScreen(entryId: 'n2'),
        data: data.copyWith(
          journal: [
            for (final e in data.journal)
              e.id == 'n2'
                  ? e.copyWith(
                      attachments: [
                        for (final a in e.attachments)
                          a.copyWith(interrupted: true),
                      ],
                    )
                  : e,
          ],
        ),
      );
      await captureScreenshot(tester, 'media_15_partial_$suffix');
    });

    testWidgets('media backup too large $suffix', (tester) async {
      final files = _TooLarge();
      for (final name in ['p1.png', 'p2.png', 'p3.png', 'v1.m4a', 'v2.m4a']) {
        files.files[name] = Uint8List.fromList([1]);
      }
      await pumpCartha(
        tester,
        brightness: b,
        data: _data(),
        content: englishContent,
        attachments: files,
        home: const DataScreen(),
      );
      await pumpFrames(tester);
      await _tap(tester, _key('data-export'));
      await captureScreenshot(tester, 'media_16_backup_too_large_$suffix');
    });
  }
}

/// Files that together are more than a restore accepts.
class _TooLarge extends MemoryAttachmentStore {
  _TooLarge() : super(clock: () => kTestNow);

  @override
  Future<int> sizeOfFile(String fileName) async =>
      files.containsKey(fileName) ? 80 * 1024 * 1024 : 0;
}
