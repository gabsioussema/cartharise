// Step 2 › F "media" (docs/plans/evolve.md): photos and voice notes on
// notes, experiments tried and attempts; the recorder (start, stop,
// interrupted, permission denied, failures); playback; the user's own
// transcript; Today's Write · Record; the pinned memory; the zip backup
// copy, round trip and "Delete all data"; sizes, themes and a11y.
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/services/media_picker.dart';
import 'package:cartharise/services/voice_player.dart';
import 'package:cartharise/services/voice_recorder.dart';
import 'package:cartharise/ui/campaign/attempt_sheet.dart';
import 'package:cartharise/ui/campaign/experiment_entry_sheet.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/journal/journal_tab.dart';
import 'package:cartharise/ui/media/media_kit.dart';
import 'package:cartharise/ui/media/photo_viewer.dart';
import 'package:cartharise/ui/media/recorder_sheet.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

final _t = DateTime(2026, 11, 2, 20, 15);

Attachment _photo(String id) => Attachment(
  id: id,
  kind: AttachmentKind.photo,
  fileName: '$id.jpg',
  createdAt: _t,
);

Attachment _voice(String id, {int? ms = 3000, String? transcript}) =>
    Attachment(
      id: id,
      kind: AttachmentKind.audio,
      fileName: '$id.m4a',
      createdAt: _t,
      durationMs: ms,
      transcript: transcript,
    );

const _body = 'I think more clearly outside.';

/// An onboarded user with one note ('n1'), optionally holding [attachments]
/// and a [pin]; an experiment tried ('e1') and an attempt ('a1').
AppData _data({
  List<Attachment> attachments = const [],
  List<Attachment> tryAttachments = const [],
  List<Attachment> attemptAttachments = const [],
  PinnedMemory? pin,
  AppSettings? settings,
}) => onboardedData(settings: settings).copyWith(
  journal: [
    JournalEntry(
      id: 'n1',
      title: 'Evening walk',
      body: _body,
      createdAt: _t,
      attachments: attachments,
    ),
  ],
  experimentLog: [
    ExperimentEntry(
      id: 'e1',
      experimentId: 'try.pattern.01',
      day: '2026-11-02',
      note: 'Walked without my phone',
      createdAt: _t,
      attachments: tryAttachments,
    ),
  ],
  campaignLog: [
    BattleLogEntry(
      id: 'a1',
      day: '2026-11-02',
      attempt: 'Wrote the first page',
      createdAt: _t,
      attachments: attemptAttachments,
    ),
  ],
  pinnedMemory: () => pin,
);

/// An attachments folder "on the phone" holding [files].
MemoryAttachmentStore _files([Map<String, List<int>> files = const {}]) {
  final store = MemoryAttachmentStore(clock: () => kTestNow);
  for (final MapEntry(:key, :value) in files.entries) {
    store.files[key] = Uint8List.fromList(value);
  }
  return store;
}

Finder _key(String key) => find.byKey(ValueKey(key));

/// Taps [f], scrolling the page first when it is below the fold (lists
/// build lazily: at 320 dp and 200 % text it may not be built yet).
Future<void> _tap(WidgetTester tester, Finder f) async {
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
  await tester.pump();
  await tester.tap(f);
  await pumpFrames(tester);
}

Future<CarthaHarness> _note(
  WidgetTester tester, {
  AppData? data,
  MemoryAttachmentStore? files,
  String? entryId = 'n1',
  Size size = const Size(390, 844),
  double textScale = 1,
  Brightness brightness = Brightness.dark,
}) => pumpCartha(
  tester,
  data: data ?? _data(),
  attachments: files,
  home: JournalEntryScreen(entryId: entryId),
  size: size,
  textScale: textScale,
  brightness: brightness,
);

/// A page with one button that opens [open] (sheets need a route below).
Widget _opener(Future<void> Function(BuildContext) open) => Scaffold(
  body: Builder(
    builder: (context) => Center(
      child: TextButton(
        key: const ValueKey('open'),
        onPressed: () => open(context),
        child: const Text('Open'),
      ),
    ),
  ),
);

/// "Picks" a photo: [path] holds [bytes] for the store to copy.
void _pickable(CarthaHarness h, {String path = '/picked/p1.jpg'}) {
  h.attachments.sources[path] = [1, 2, 3];
  h.media.nextPhoto = path;
}

Future<void> _addPhoto(WidgetTester tester, {bool camera = false}) async {
  await _tap(tester, _key('media-add-photo'));
  await _tap(
    tester,
    _key(camera ? 'media-photo-camera' : 'media-photo-library'),
  );
}

/// Screen-reader announcements made from now on.
List<String> _announcements(WidgetTester tester) {
  final said = <String>[];
  final messenger = tester.binding.defaultBinaryMessenger;
  messenger.setMockDecodedMessageHandler<Object?>(
    SystemChannels.accessibility,
    (message) async {
      if (message is Map && message['type'] == 'announce') {
        said.add((message['data'] as Map)['message'] as String);
      }
      return null;
    },
  );
  addTearDown(
    () => messenger.setMockDecodedMessageHandler<Object?>(
      SystemChannels.accessibility,
      null,
    ),
  );
  return said;
}

List<Attachment> _noteMedia(CarthaHarness h) =>
    h.state.data.journal.firstWhere((e) => e.id == 'n1').attachments;

Future<void> _expectAccessible(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  // ── Photos ───────────────────────────────────────────────────────────────

  group('photos on a note', () {
    testWidgets('from the library: copied into the private folder, on the '
        'note, the picker copy released', (tester) async {
      final h = await _note(tester);
      _pickable(h);
      await _addPhoto(tester);
      expect(h.media.requests, [false]);
      final photo = _noteMedia(h).single;
      expect(photo.kind, AttachmentKind.photo);
      expect(h.attachments.files[photo.fileName], [1, 2, 3]);
      expect(h.media.released, ['/picked/p1.jpg']);
      expect(find.text('Photo added.'), findsOneWidget);
      expect(_key('photo-${photo.id}'), findsOneWidget);
      // Saved on the phone, not only on screen.
      expect(h.store.saved!.journal.single.attachments.single.id, photo.id);
      // The note's words are untouched.
      expect(h.state.data.journal.single.body, _body);
    });

    testWidgets('with the camera', (tester) async {
      final h = await _note(tester);
      _pickable(h);
      await _addPhoto(tester, camera: true);
      expect(h.media.requests, [true]);
      expect(_noteMedia(h), hasLength(1));
    });

    testWidgets('a cancelled picker adds nothing and says nothing', (
      tester,
    ) async {
      final h = await _note(tester);
      h.media.nextPhoto = null;
      await _addPhoto(tester);
      expect(_noteMedia(h), isEmpty);
      expect(_key('media-notice'), findsNothing);
    });

    testWidgets('on a new note: the note is created holding the photo', (
      tester,
    ) async {
      final h = await _note(tester, data: onboardedData(), entryId: null);
      await tester.enterText(_key('journal-entry-body'), 'Typed first');
      _pickable(h);
      await _addPhoto(tester);
      final note = h.state.data.journal.single;
      expect(note.body, 'Typed first');
      expect(note.attachments, hasLength(1));
      // Later typing updates the same note.
      await tester.enterText(_key('journal-entry-body'), 'Typed first, more');
      await tester.pump(const Duration(seconds: 1));
      expect(h.state.data.journal, hasLength(1));
      expect(h.state.data.journal.single.attachments, hasLength(1));
      expect(h.state.data.journal.single.body, 'Typed first, more');
    });

    testWidgets('camera denied: said honestly, the library offered instead', (
      tester,
    ) async {
      final h = await _note(tester);
      h.media.error = const MediaPickerException(MediaFailure.permissionDenied);
      await _addPhoto(tester, camera: true);
      expect(
        find.text(
          'Camera access is off. Choose from your photos, or allow the '
          'camera in Settings.',
        ),
        findsOneWidget,
      );
      expect(_noteMedia(h), isEmpty);
      h.media.error = null;
      _pickable(h);
      await _tap(tester, _key('media-notice-action'));
      expect(h.media.requests, [true, false]);
      expect(_noteMedia(h), hasLength(1));
    });

    testWidgets('photos denied: said, with "Write instead" to the note', (
      tester,
    ) async {
      final h = await _note(tester);
      h.media.error = const MediaPickerException(MediaFailure.permissionDenied);
      await _addPhoto(tester);
      expect(
        find.text(
          'Photo access is off. Allow it in Settings, or write instead.',
        ),
        findsOneWidget,
      );
      await _tap(tester, find.text('Write instead'));
      final body = tester.widget<EditableText>(
        find.descendant(
          of: _key('journal-entry-body'),
          matching: find.byType(EditableText),
        ),
      );
      expect(body.focusNode.hasFocus, isTrue);
    });

    testWidgets('a full phone or a huge photo: nothing added, nothing '
        'claimed, the picker copy still released', (tester) async {
      final h = await _note(tester);
      _pickable(h);
      h.attachments.failWrites = true;
      await _addPhoto(tester);
      expect(
        find.text(
          "Couldn't save it on this phone. Storage may be full. "
          'Nothing was added.',
        ),
        findsOneWidget,
      );
      expect(find.text('Photo added.'), findsNothing);
      expect(_noteMedia(h), isEmpty);
      expect(h.attachments.files, isEmpty);
      expect(h.media.released, ['/picked/p1.jpg']);

      h.attachments
        ..failWrites = false
        ..maxBytes = 2;
      await _addPhoto(tester);
      expect(
        find.text('That photo is over 50 MB. Choose a smaller one.'),
        findsOneWidget,
      );
      expect(_noteMedia(h), isEmpty);
    });

    testWidgets('a failed save is said, with Retry that saves it', (
      tester,
    ) async {
      final h = await _note(tester);
      _pickable(h);
      h.store.failWrites = true;
      await _addPhoto(tester);
      expect(find.text('Photo added.'), findsNothing);
      expect(
        find.text('Added, but not saved on this phone yet.'),
        findsOneWidget,
      );
      h.store.failWrites = false;
      await _tap(tester, _key('media-retry-save'));
      expect(
        find.text('Added, but not saved on this phone yet.'),
        findsNothing,
      );
      expect(h.store.saved!.journal.single.attachments, hasLength(1));
    });

    testWidgets('full screen; remove asks first, then deletes the file', (
      tester,
    ) async {
      final h = await _note(
        tester,
        data: _data(attachments: [_photo('p1')]),
        files: _files({
          'p1.jpg': [9],
        }),
      );
      await _tap(tester, _key('photo-p1'));
      expect(find.byType(PhotoViewerScreen), findsOneWidget);
      expect(find.text('Added Mon, Nov 2, 2026, 8:15 PM'), findsOneWidget);

      await _tap(tester, _key('photo-remove'));
      expect(find.text('Remove this photo?'), findsOneWidget);
      await _tap(tester, find.text('Cancel'));
      expect(_noteMedia(h), hasLength(1));
      expect(find.byType(PhotoViewerScreen), findsOneWidget);

      await _tap(tester, _key('photo-remove'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Remove'));
      expect(find.byType(PhotoViewerScreen), findsNothing);
      expect(_noteMedia(h), isEmpty);
      expect(h.attachments.files, isEmpty);
      expect(find.text('Photo removed.'), findsOneWidget);
    });

    testWidgets('a removal that could not be saved is said, file kept', (
      tester,
    ) async {
      final h = await _note(
        tester,
        data: _data(attachments: [_photo('p1')]),
        files: _files({
          'p1.jpg': [9],
        }),
      );
      h.store.failWrites = true;
      await _tap(tester, _key('photo-p1'));
      await _tap(tester, _key('photo-remove'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Remove'));
      expect(
        find.text('Removed, but not saved on this phone yet.'),
        findsOneWidget,
      );
      expect(find.text('Photo removed.'), findsNothing);
      // The saved data still names it, so the file stays.
      expect(h.attachments.files.keys, ['p1.jpg']);
    });

    testWidgets('a photo whose file is gone shows "Missing", never fails', (
      tester,
    ) async {
      await _note(tester, data: _data(attachments: [_photo('p1')]));
      await tester.pump();
      expect(_key('photo-missing'), findsOneWidget);
      expect(find.text('Missing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final add in [true, false]) {
      testWidgets('a photo taken while the app was closed is offered back '
          '(${add ? 'added' : 'discarded'})', (tester) async {
        final h = await pumpCartha(
          tester,
          data: _data(),
          home: _opener(
            (c) => Navigator.of(c).push(
              MaterialPageRoute<void>(
                builder: (_) => const JournalEntryScreen(entryId: 'n1'),
              ),
            ),
          ),
        );
        h.media.lostPhoto = '/picked/lost.jpg';
        h.attachments.sources['/picked/lost.jpg'] = [4, 4];
        await _tap(tester, _key('open'));
        expect(_key('media-lost-photo'), findsOneWidget);
        expect(
          find.text("A photo you took earlier wasn't added yet."),
          findsOneWidget,
        );
        await _tap(tester, find.text(add ? 'Add it here' : 'Discard'));
        expect(_key('media-lost-photo'), findsNothing);
        expect(_noteMedia(h), hasLength(add ? 1 : 0));
        expect(h.media.released, ['/picked/lost.jpg']);
      });
    }
  });

  // ── Voice notes ──────────────────────────────────────────────────────────

  group('recording', () {
    testWidgets('tap to start: a clear recording state, announced; tap Stop: '
        'saved at once', (tester) async {
      final said = _announcements(tester);
      final h = await _note(tester);
      await _tap(tester, _key('media-record'));
      expect(h.recorder.permissionRequests, 1);
      expect(h.recorder.started, hasLength(1));
      expect(find.text('Recording'), findsOneWidget);
      expect(_key('recorder-time'), findsOneWidget);
      expect(find.text('0:00'), findsOneWidget);
      expect(said, ["Recording. Tap Stop and save when you're done."]);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('0:02'), findsOneWidget);

      // The level meter follows the microphone.
      final palette = CarthaPalette.of(tester.element(_key('recorder-level')));
      int lit() => tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: _key('recorder-level'),
              matching: find.byType(DecoratedBox),
            ),
          )
          .where((b) => (b.decoration as BoxDecoration).color == palette.accent)
          .length;
      expect(lit(), 0);
      h.recorder.level(0.5);
      await pumpFrames(tester, count: 2);
      expect(lit(), 10);
      // Every bar is really drawn (has a size), lit or not.
      for (final bar
          in find
              .descendant(
                of: _key('recorder-level'),
                matching: find.byType(DecoratedBox),
              )
              .evaluate()) {
        final size = tester.getSize(find.byWidget(bar.widget));
        expect(size.width, greaterThan(4));
        expect(size.height, greaterThan(4));
      }

      await _tap(tester, _key('recorder-stop'));
      expect(find.byType(RecorderSheet), findsNothing);
      final recording = _noteMedia(h).single;
      expect(recording.kind, AttachmentKind.audio);
      expect(recording.durationMs, 3000);
      expect(recording.transcript, isNull, reason: 'never filled in');
      expect(h.attachments.files[recording.fileName], [1, 2, 3, 4]);
      expect(h.attachments.pendingRecordings, isEmpty);
      expect(h.store.saved!.journal.single.attachments.single.id, recording.id);
      expect(find.text('Voice note saved.'), findsOneWidget);
      expect(said.last, 'Voice note saved.');
      expect(_key('player-${recording.id}'), findsOneWidget);
    });

    testWidgets('a call interrupts: the part recorded is kept and labelled', (
      tester,
    ) async {
      final said = _announcements(tester);
      final h = await _note(tester);
      await _tap(tester, _key('media-record'));
      h.recorder.interrupt();
      await pumpFrames(tester);
      expect(_key('recorder-interrupted'), findsOneWidget);
      expect(
        find.text('Interrupted. The 0:03 recorded before it is saved.'),
        findsOneWidget,
      );
      expect(find.text('Partial'), findsOneWidget);
      expect(
        said.last,
        'Interrupted. The 3 seconds recorded before it is saved.',
      );
      expect(_noteMedia(h).single.kind, AttachmentKind.audio);
      expect(h.store.saved!.journal.single.attachments, hasLength(1));
      await _tap(tester, _key('recorder-done'));
      expect(find.byType(RecorderSheet), findsNothing);
      expect(find.text('Voice note saved.'), findsOneWidget);
    });

    testWidgets('the app goes to the background: kept right away', (
      tester,
    ) async {
      final h = await _note(tester);
      await _tap(tester, _key('media-record'));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await pumpFrames(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await pumpFrames(tester);
      expect(_noteMedia(h), hasLength(1));
      expect(_key('recorder-interrupted'), findsOneWidget);
      expect(h.attachments.pendingRecordings, isEmpty);
    });

    testWidgets('Record again in the same sheet adds a second voice note', (
      tester,
    ) async {
      final h = await _note(tester);
      await _tap(tester, _key('media-record'));
      h.recorder.interrupt();
      await pumpFrames(tester);
      await _tap(tester, _key('recorder-again'));
      expect(find.text('Recording'), findsOneWidget);
      await _tap(tester, _key('recorder-stop'));
      expect(_noteMedia(h), hasLength(2));
    });

    testWidgets('microphone denied: said, nothing kept, "Write instead"', (
      tester,
    ) async {
      final h = await _note(tester);
      h.recorder.permission = false;
      await _tap(tester, _key('media-record'));
      expect(
        find.text(
          'Microphone access is off. Allow it in Settings, or write instead.',
        ),
        findsOneWidget,
      );
      expect(find.text('Recording'), findsNothing);
      expect(h.attachments.pendingRecordings, isEmpty);
      expect(_noteMedia(h), isEmpty);
      await _tap(tester, _key('recorder-write-instead'));
      expect(find.byType(RecorderSheet), findsNothing);
      final body = tester.widget<EditableText>(
        find.descendant(
          of: _key('journal-entry-body'),
          matching: find.byType(EditableText),
        ),
      );
      expect(body.focusNode.hasFocus, isTrue);
    });

    testWidgets('denied, then allowed: Try again records', (tester) async {
      final h = await _note(tester);
      h.recorder.permission = false;
      await _tap(tester, _key('media-record'));
      h.recorder.permission = true;
      await _tap(tester, _key('recorder-retry'));
      expect(find.text('Recording'), findsOneWidget);
      await _tap(tester, _key('recorder-stop'));
      expect(_noteMedia(h), hasLength(1));
    });

    testWidgets('no microphone: said, no Try again', (tester) async {
      final h = await _note(tester);
      h.recorder.failStart = VoiceFailure.unavailable;
      await _tap(tester, _key('media-record'));
      expect(
        find.text(
          "Recording isn't available on this phone. You can write instead.",
        ),
        findsOneWidget,
      );
      expect(_key('recorder-retry'), findsNothing);
      await _tap(tester, _key('recorder-close'));
      expect(_noteMedia(h), isEmpty);
    });

    testWidgets('nothing recorded is never called saved', (tester) async {
      final h = await _note(tester);
      h.recorder.bytes = const [];
      await _tap(tester, _key('media-record'));
      await _tap(tester, _key('recorder-stop'));
      expect(
        find.text('Nothing was recorded. Try again, or write instead.'),
        findsOneWidget,
      );
      expect(find.text('Voice note saved.'), findsNothing);
      expect(_noteMedia(h), isEmpty);
      expect(h.attachments.files, isEmpty);
    });

    testWidgets('storage full: said before anything starts', (tester) async {
      final h = await _note(tester);
      h.attachments.failWrites = true;
      await _tap(tester, _key('media-record'));
      expect(
        find.text("Couldn't save the recording. Storage may be full."),
        findsOneWidget,
      );
      expect(h.recorder.started, isEmpty);
    });

    testWidgets('Discard asks, then deletes what was recorded', (tester) async {
      final h = await _note(tester);
      await _tap(tester, _key('media-record'));
      await _tap(tester, _key('recorder-discard'));
      expect(find.text('Discard this recording?'), findsOneWidget);
      await _tap(tester, find.text('Cancel'));
      expect(find.text('Recording'), findsOneWidget);
      await _tap(tester, _key('recorder-discard'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Discard'));
      expect(find.byType(RecorderSheet), findsNothing);
      expect(h.recorder.cancelCount, 1);
      expect(h.attachments.pendingRecordings, isEmpty);
      expect(_noteMedia(h), isEmpty);
    });

    testWidgets('Back while recording stops and keeps it', (tester) async {
      final h = await _note(tester);
      await _tap(tester, _key('media-record'));
      await tester.binding.handlePopRoute();
      await pumpFrames(tester);
      expect(_noteMedia(h), hasLength(1));
      expect(find.byType(RecorderSheet), findsNothing);
      expect(find.byType(JournalEntryScreen), findsOneWidget);
    });

    testWidgets('a failed save after recording is said, with Retry', (
      tester,
    ) async {
      final h = await _note(tester);
      h.store.failWrites = true;
      await _tap(tester, _key('media-record'));
      await _tap(tester, _key('recorder-stop'));
      // The sheet stays to say so.
      expect(_key('recorder-not-saved'), findsOneWidget);
      expect(_noteMedia(h), hasLength(1));
      h.store.failWrites = false;
      await _tap(tester, _key('media-retry-save'));
      expect(h.store.saved!.journal.single.attachments, hasLength(1));
    });

    for (final motion in [true, false]) {
      testWidgets('the recorder sheet slides only while motion is on '
          '(motion: $motion)', (tester) async {
        await pumpCartha(
          tester,
          data: _data(settings: AppSettings(motion: motion)),
          home: _opener((c) => showRecorderSheet(c, keep: (_) async => true)),
        );
        await _tap(tester, _key('open'));
        final route = ModalRoute.of(tester.element(find.byType(RecorderSheet)));
        expect(
          (route! as ModalBottomSheetRoute<Object?>).sheetAnimationStyle,
          motion ? isNull : AnimationStyle.noAnimation,
        );
        await _tap(tester, _key('recorder-stop'));
      });
    }
  });

  group('playback and the user\'s own words', () {
    AppData withVoice({String? transcript}) =>
        _data(attachments: [_voice('v1', transcript: transcript)]);
    MemoryAttachmentStore voiceFile() => _files({
      'v1.m4a': [1, 2, 3],
    });

    testWidgets('play, pause, resume, position, seek, the end', (tester) async {
      final h = await _note(tester, data: withVoice(), files: voiceFile());
      expect(find.text('0:00 / 0:03'), findsOneWidget);
      await _tap(tester, find.byTooltip('Play voice note'));
      expect(h.player.played, ['${MemoryAttachmentStore.kMemoryRoot}/v1.m4a']);
      expect(find.byTooltip('Pause voice note'), findsOneWidget);

      h.player.positionAt(const Duration(seconds: 1));
      await tester.pump();
      expect(find.text('0:01 / 0:03'), findsOneWidget);

      await _tap(tester, find.byTooltip('Pause voice note'));
      expect(h.player.state, VoicePlayerState.paused);
      expect(find.byTooltip('Play voice note'), findsOneWidget);
      await _tap(tester, find.byTooltip('Play voice note'));
      expect(h.player.state, VoicePlayerState.playing);
      expect(h.player.played, hasLength(1), reason: 'resumed, not restarted');

      // Seek to the end with the slider.
      await tester.drag(_key('voice-slider-v1'), const Offset(600, 0));
      await pumpFrames(tester);
      expect(find.text('0:03 / 0:03'), findsOneWidget);

      h.player.complete();
      await pumpFrames(tester);
      expect(find.text('0:00 / 0:03'), findsOneWidget);
      expect(find.byTooltip('Play voice note'), findsOneWidget);

      // Leaving the note stops playback.
      await _tap(tester, find.byTooltip('Play voice note'));
      expect(h.player.currentPath, isNotNull);
      await tester.pumpWidget(const SizedBox());
      expect(h.player.currentPath, isNull);
    });

    testWidgets('the slider before playing only sets where Play starts', (
      tester,
    ) async {
      final h = await _note(tester, data: withVoice(), files: voiceFile());
      final seeks = <Duration>[];
      final sub = h.player.position.listen(seeks.add);
      addTearDown(sub.cancel);
      await tester.tap(_key('voice-slider-v1'));
      await pumpFrames(tester);
      expect(h.player.played, isEmpty, reason: 'moving never plays');
      expect(seeks, isEmpty);
      expect(find.text('0:01 / 0:03'), findsOneWidget);
      await _tap(tester, find.byTooltip('Play voice note'));
      expect(h.player.played, hasLength(1));
      expect(seeks, hasLength(1));
      expect(
        seeks.single.inMilliseconds,
        inInclusiveRange(1000, 2000),
        reason: 'played from where the slider was set',
      );
    });

    testWidgets('a recording that cannot be played says so', (tester) async {
      final h = await _note(tester, data: withVoice(), files: voiceFile());
      h.player.failPlay = true;
      await _tap(tester, find.byTooltip('Play voice note'));
      expect(find.text("This recording can't be played."), findsOneWidget);
    });

    testWidgets('a recording whose file is gone says so and does not play', (
      tester,
    ) async {
      final h = await _note(tester, data: withVoice());
      await tester.pump();
      expect(
        find.text("This recording isn't on this phone any more."),
        findsOneWidget,
      );
      final play = tester.widget<IconButton>(_key('voice-play-v1'));
      expect(play.onPressed, isNull);
      expect(h.player.played, isEmpty);
    });

    testWidgets('the transcript is only what the user typed, exactly', (
      tester,
    ) async {
      final h = await _note(tester, data: withVoice(), files: voiceFile());
      expect(find.text('Type what you said'), findsOneWidget);
      await _tap(tester, _key('voice-words-edit-v1'));
      expect(find.text('Your words for this recording'), findsOneWidget);
      const typed = '  Walk first,  then   write. ';
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        typed,
      );
      await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
      expect(_noteMedia(h).single.transcript, typed);
      expect(
        h.store.saved!.journal.single.attachments.single.transcript,
        typed,
      );
      expect(find.text(typed), findsOneWidget);
      expect(find.text('Edit your words'), findsOneWidget);

      // Cleared: no words (not an empty transcript).
      await _tap(tester, _key('voice-words-edit-v1'));
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        '',
      );
      await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
      expect(_noteMedia(h).single.transcript, isNull);
      expect(find.text('Type what you said'), findsOneWidget);
    });

    testWidgets('remove a voice note asks first and deletes the file', (
      tester,
    ) async {
      final h = await _note(tester, data: withVoice(), files: voiceFile());
      await _tap(tester, find.byTooltip('Remove voice note'));
      expect(find.text('Remove this voice note?'), findsOneWidget);
      await _tap(tester, find.widgetWithText(FilledButton, 'Remove'));
      expect(_noteMedia(h), isEmpty);
      expect(h.attachments.files, isEmpty);
      expect(find.text('Voice note removed.'), findsOneWidget);
    });
  });

  // ── Experiments tried and attempts ───────────────────────────────────────

  group('on experiments tried and attempts', () {
    testWidgets('a photo on an experiment tried', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(),
        home: _opener(
          (c) => showExperimentEntrySheet(
            c,
            _data().experimentLog.single,
            title: 'Walk',
          ),
        ),
      );
      await _tap(tester, _key('open'));
      expect(_key('media-strip-experiment'), findsOneWidget);
      _pickable(h);
      await _addPhoto(tester);
      expect(
        h.state.data.experimentLog.single.attachments.single.kind,
        AttachmentKind.photo,
      );
      expect(find.text('Photo added.'), findsOneWidget);
      // The try's note is untouched.
      expect(h.state.data.experimentLog.single.note, 'Walked without my phone');
    });

    testWidgets('a voice note on an attempt', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(),
        home: _opener((c) => showAttemptSheet(c, _data().campaignLog.single)),
      );
      await _tap(tester, _key('open'));
      expect(_key('media-strip-attempt'), findsOneWidget);
      await _tap(tester, _key('media-record'));
      await _tap(tester, _key('recorder-stop'));
      final attempt = h.state.data.campaignLog.single;
      expect(attempt.attachments.single.kind, AttachmentKind.audio);
      expect(attempt.attempt, 'Wrote the first page');
      expect(find.text('Voice note saved.'), findsOneWidget);
    });

    testWidgets('no strip for an entry that is not there', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: _opener(
          (c) => showAttemptSheet(
            c,
            BattleLogEntry(
              id: 'gone',
              day: '2026-11-02',
              attempt: 'x',
              createdAt: _t,
            ),
          ),
        ),
      );
      await _tap(tester, _key('open'));
      expect(find.byType(AttemptSheet), findsOneWidget);
      expect(_key('media-add-photo'), findsNothing);
    });
  });

  // ── Today ────────────────────────────────────────────────────────────────

  group('Today: Write · Record', () {
    testWidgets('Record keeps the voice note in a new journal note', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await pumpCartha(tester, data: onboardedData());
      expect(
        tester.getSemantics(find.bySemanticsLabel('Record a voice note')),
        isSemantics(isButton: true, hasTapAction: true),
      );
      // Write still opens a new note: side by side with Record.
      expect(_key('today-write'), findsOneWidget);
      await _tap(tester, _key('today-record'));
      expect(find.text('Recording'), findsOneWidget);
      expect(h.state.data.journal, isEmpty, reason: 'nothing before Stop');
      await _tap(tester, _key('recorder-stop'));
      final note = h.state.data.journal.single;
      expect(note.body, '');
      expect(note.title, isNull);
      expect(note.attachments.single.kind, AttachmentKind.audio);
      expect(find.text('Voice note saved in your Journal.'), findsOneWidget);

      await tester.tap(find.widgetWithText(SnackBarAction, 'Open'));
      await pumpFrames(tester);
      final screen = tester.widget<JournalEntryScreen>(
        find.byType(JournalEntryScreen),
      );
      expect(screen.entryId, note.id);
      expect(_key('player-${note.attachments.single.id}'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('microphone denied on Today: Write instead opens a note', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      h.recorder.permission = false;
      await _tap(tester, _key('today-record'));
      await _tap(tester, _key('recorder-write-instead'));
      expect(find.byType(JournalEntryScreen), findsOneWidget);
      expect(h.state.data.journal, isEmpty);
    });

    testWidgets('a voice-only note reads "Voice note" in the Journal', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _tap(tester, _key('today-record'));
      await _tap(tester, _key('recorder-stop'));
      h.shell.select(AppTab.journal);
      await pumpFrames(tester);
      final id = h.state.data.journal.single.id;
      expect(
        find.descendant(
          of: _key('note-$id'),
          matching: find.text('Voice note'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: _key('note-media-$id'),
          matching: find.text('1 voice note'),
        ),
        findsOneWidget,
      );
    });
  });

  // ── The pinned memory ────────────────────────────────────────────────────

  group('pinned memory', () {
    void select(WidgetTester tester, int from, int to) {
      final field = tester.widget<TextField>(_key('journal-entry-body'));
      field.controller!.selection = TextSelection(
        baseOffset: from,
        extentOffset: to,
      );
    }

    testWidgets('pin the exact words selected in a note', (tester) async {
      final h = await _note(tester);
      select(tester, 1, 14); // " think more c" → trimmed ends only
      await tester.pump();
      await _tap(tester, _key('journal-entry-pin'));
      final pin = h.state.data.pinnedMemory!;
      expect(pin.kind, PinnedKind.passage);
      expect(pin.sourceId, 'n1');
      expect(pin.excerpt, 'think more c');
      expect(_body.contains(pin.excerpt!), isTrue);
      expect(h.store.saved!.pinnedMemory?.excerpt, 'think more c');
      expect(find.text('Pinned to the top of your Journal.'), findsOneWidget);
    });

    testWidgets('Pin in the selection menu', (tester) async {
      final h = await _note(tester);
      await tester.tap(_key('journal-entry-body'));
      await tester.pump();
      select(tester, 2, 7);
      await tester.pump();
      tester
          .state<EditableTextState>(
            find.descendant(
              of: _key('journal-entry-body'),
              matching: find.byType(EditableText),
            ),
          )
          .showToolbar();
      await tester.pump();
      await tester.tap(find.text('Pin'));
      await pumpFrames(tester);
      expect(h.state.data.pinnedMemory?.excerpt, 'think');
    });

    testWidgets('nothing selected: says how, pins nothing', (tester) async {
      final h = await _note(tester);
      await _tap(tester, _key('journal-entry-pin'));
      expect(
        find.text('Select some words first, then tap Pin.'),
        findsOneWidget,
      );
      expect(h.state.data.pinnedMemory, isNull);
    });

    testWidgets('words typed but not saved yet are saved, then pinned', (
      tester,
    ) async {
      final h = await _note(tester);
      await tester.enterText(_key('journal-entry-body'), 'Fresh words here');
      select(tester, 0, 5);
      await _tap(tester, _key('journal-entry-pin'));
      expect(h.state.data.journal.single.body, 'Fresh words here');
      expect(h.state.data.pinnedMemory?.excerpt, 'Fresh');
    });

    testWidgets('at the top of the Journal, compact; opens; Unpin', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _data(
          pin: PinnedMemory(
            kind: PinnedKind.passage,
            sourceId: 'n1',
            excerpt: 'think more clearly',
            pinnedAt: _t,
          ),
        ),
        shell: ShellController(initial: AppTab.journal),
      );
      expect(find.byType(JournalTab), findsOneWidget);
      final card = _key('pinned-memory');
      expect(card, findsOneWidget);
      expect(
        tester.getTopLeft(card).dy,
        lessThan(tester.getTopLeft(_key('journal-sections')).dy),
      );
      expect(find.text('think more clearly'), findsOneWidget);
      expect(find.text('From a note · Nov 2, 2026'), findsOneWidget);

      await _tap(tester, _key('pinned-open'));
      expect(
        tester
            .widget<JournalEntryScreen>(find.byType(JournalEntryScreen))
            .entryId,
        'n1',
      );
      await tester.pageBack();
      await pumpFrames(tester);

      await _tap(tester, _key('pinned-unpin'));
      expect(card, findsNothing);
      expect(h.state.data.pinnedMemory, isNull);
      expect(find.text('Unpinned. Nothing else changed.'), findsOneWidget);
      expect(h.state.data.journal.single.body, _body);
    });

    testWidgets('pin a photo from full screen; shown on the Journal; unpin', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _data(attachments: [_photo('p1')]),
        attachments: _files({
          'p1.jpg': [9],
        }),
        shell: ShellController(initial: AppTab.journal),
      );
      expect(_key('pinned-memory'), findsNothing);
      await _tap(tester, find.text('Evening walk'));
      await _tap(tester, _key('photo-p1'));
      await _tap(tester, find.byTooltip('Pin as memory'));
      final pin = h.state.data.pinnedMemory!;
      expect(pin.kind, PinnedKind.photo);
      expect(pin.attachmentId, 'p1');
      expect(_key('photo-pinned-tag'), findsOneWidget);
      expect(find.byTooltip('Unpin'), findsOneWidget);

      await tester.pageBack();
      await pumpFrames(tester);
      await tester.pageBack();
      await pumpFrames(tester);
      expect(_key('pinned-photo'), findsOneWidget);

      // Removing the photo takes the pin with it.
      await _tap(tester, _key('pinned-photo'));
      await _tap(tester, _key('photo-remove'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Remove'));
      expect(h.state.data.pinnedMemory, isNull);
      expect(_key('pinned-memory'), findsNothing);
    });

    testWidgets('a passage pinned from an attempt opens its sheet', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: _data(
          pin: PinnedMemory(
            kind: PinnedKind.passage,
            sourceId: 'a1',
            excerpt: 'the first page',
            pinnedAt: _t,
          ),
        ),
        shell: ShellController(initial: AppTab.journal),
      );
      expect(find.text('From an attempt · Nov 2, 2026'), findsOneWidget);
      await _tap(tester, _key('pinned-open'));
      expect(find.byType(AttemptSheet), findsOneWidget);
    });
  });

  // ── Your data: the zip backup ────────────────────────────────────────────

  group('Your data (backup v2)', () {
    AppData withMedia() => _data(
      attachments: [
        _photo('p1'),
        _voice('v1', transcript: 'Said'),
      ],
    );
    MemoryAttachmentStore mediaFiles() => _files({
      'p1.jpg': [1, 2],
      'v1.m4a': [3, 4, 5],
    });

    testWidgets('says what a backup includes', (tester) async {
      await pumpCartha(
        tester,
        data: withMedia(),
        attachments: mediaFiles(),
        home: const DataScreen(),
      );
      await tester.pump();
      expect(
        find.text(
          'Includes your words and settings, plus 1 photo and 1 voice note '
          '(1 KB).',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Takes a .zip backup, or an older .json one.'),
        findsOneWidget,
      );
      expect(_key('data-media-too-large'), findsNothing);

      await pumpCartha(tester, data: onboardedData(), home: const DataScreen());
      await tester.pump();
      expect(
        find.text(
          'Includes your words and settings. No photos or recordings yet.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('more than a backup holds is said honestly', (tester) async {
      final huge = _HugeStore()
        ..files['p1.jpg'] = Uint8List.fromList([1])
        ..files['v1.m4a'] = Uint8List.fromList([1]);
      await pumpCartha(
        tester,
        data: withMedia(),
        attachments: huge,
        home: const DataScreen(),
      );
      await tester.pump();
      expect(_key('data-media-too-large'), findsOneWidget);
      expect(find.textContaining('600.0 MB'), findsOneWidget);
    });

    testWidgets('the .zip carries photos and recordings and restores them '
        'on another phone', (tester) async {
      final h = await pumpCartha(
        tester,
        data: withMedia(),
        attachments: mediaFiles(),
        home: const DataScreen(),
      );
      await _tap(tester, _key('data-export'));
      final zip = h.files.shared.single;
      expect(zip.filename, 'cartharise-backup-2026-11-03.zip');
      final contents = decodeBackupBytes(zip.bytes);
      expect(contents.files['p1.jpg'], [1, 2]);
      expect(contents.files['v1.m4a'], [3, 4, 5]);
      expect(contents.notIncluded, isEmpty);

      // Another phone, empty.
      await tester.pumpWidget(const SizedBox());
      final other = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const DataScreen(),
      );
      other.files.pickBytes = zip.bytes;
      await _tap(tester, _key('data-import'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Replace'));
      expect(find.text('Backup restored.'), findsOneWidget);
      expect(other.attachments.files['p1.jpg'], [1, 2]);
      expect(other.attachments.files['v1.m4a'], [3, 4, 5]);
      final note = other.state.data.journal.single;
      expect(note.attachments.map((a) => a.id), ['p1', 'v1']);
      expect(note.attachments.last.transcript, 'Said');

      // The restored recording plays.
      await tester.pumpWidget(const SizedBox());
      final third = await _note(
        tester,
        data: other.state.data,
        files: other.attachments,
      );
      await _tap(tester, find.byTooltip('Play voice note'));
      expect(third.player.played.single, endsWith('/v1.m4a'));
    });

    testWidgets('"Delete all data" removes photos and recordings', (
      tester,
    ) async {
      final files = mediaFiles();
      final h = await pumpCartha(
        tester,
        data: withMedia(),
        attachments: files,
        home: const DataScreen(),
      );
      await _tap(tester, _key('data-delete'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Continue'));
      await _tap(
        tester,
        find.widgetWithText(FilledButton, 'Delete everything'),
      );
      expect(files.files, isEmpty);
      expect(h.media.clearCount, 1);
      expect(h.state.data.pinnedMemory, isNull);
      expect(h.store.raw, isNull);
    });
  });

  // ── Sizes, themes, accessibility ─────────────────────────────────────────

  group('sizes and themes', () {
    AppData full() => _data(
      attachments: [
        _photo('p1'),
        _photo('p2'),
        _voice('v1', transcript: 'Walk first, then write.'),
      ],
      pin: PinnedMemory(
        kind: PinnedKind.passage,
        sourceId: 'n1',
        excerpt: 'I think more clearly outside.',
        pinnedAt: _t,
      ),
    );
    MemoryAttachmentStore fullFiles() => _files({
      'p1.jpg': [1],
      'p2.jpg': [2],
      'v1.m4a': [3],
    });

    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        final name = '$size (${brightness.name})';

        testWidgets('note with photos and a voice note fits $name', (
          tester,
        ) async {
          final h = await _note(
            tester,
            data: full(),
            files: fullFiles(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await expectNoOverflow(tester);
          // A notice on top of it all.
          h.media.error = const MediaPickerException(
            MediaFailure.permissionDenied,
          );
          await _addPhoto(tester, camera: true);
          await expectNoOverflow(tester);
          await _tap(tester, _key('photo-p1'));
          await expectNoOverflow(tester);
        });

        testWidgets('recorder states fit $name', (tester) async {
          final h = await _note(
            tester,
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await _tap(tester, _key('media-record'));
          h.recorder.level(0.7);
          await tester.pump(const Duration(seconds: 1));
          await expectNoOverflow(tester);
          h.recorder.interrupt();
          await pumpFrames(tester);
          await expectNoOverflow(tester);
          await _tap(tester, _key('recorder-done'));
          h.recorder.permission = false;
          await _tap(tester, _key('media-record'));
          await expectNoOverflow(tester);
        });

        testWidgets('Journal with a pinned memory and Today fit $name', (
          tester,
        ) async {
          final h = await pumpCartha(
            tester,
            data: full(),
            attachments: fullFiles(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await expectNoOverflow(tester);
          h.shell.select(AppTab.journal);
          await pumpFrames(tester);
          await expectNoOverflow(tester);
        });

        testWidgets('Your data with photos fits $name', (tester) async {
          await pumpCartha(
            tester,
            data: full(),
            attachments: _HugeStore()
              ..files.addAll({
                'p1.jpg': Uint8List(1),
                'p2.jpg': Uint8List(1),
                'v1.m4a': Uint8List(1),
              }),
            home: const DataScreen(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          await tester.pump();
          await expectNoOverflow(tester);
        });
      }
    }
  });

  group('accessibility', () {
    for (final brightness in Brightness.values) {
      testWidgets('note with media (${brightness.name})', (tester) async {
        final semantics = tester.ensureSemantics();
        await _note(
          tester,
          data: _data(
            attachments: [
              _photo('p1'),
              _voice('v1', transcript: 'Said'),
            ],
          ),
          files: _files({
            'p1.jpg': [1],
            'v1.m4a': [2],
          }),
          brightness: brightness,
        );
        await tester.pump();
        expect(
          tester.getSemantics(_key('photo-p1')),
          isSemantics(
            label: 'Photo, added Nov 2, 2026',
            hint: 'Opens full screen',
            isButton: true,
            isImage: true,
            hasTapAction: true,
          ),
        );
        await _expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('recording and interrupted (${brightness.name})', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final h = await _note(tester, brightness: brightness);
        await _tap(tester, _key('media-record'));
        await _expectAccessible(tester);
        h.recorder.interrupt();
        await pumpFrames(tester);
        await _expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('photo full screen and pinned memory (${brightness.name})', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        final h = await pumpCartha(
          tester,
          data: _data(
            attachments: [_photo('p1')],
            pin: PinnedMemory(
              kind: PinnedKind.photo,
              sourceId: 'n1',
              attachmentId: 'p1',
              excerpt: 'clearly outside',
              pinnedAt: _t,
            ),
          ),
          attachments: _files({
            'p1.jpg': [1],
          }),
          brightness: brightness,
          shell: ShellController(initial: AppTab.journal),
        );
        await tester.pump();
        await _expectAccessible(tester);
        await _tap(tester, _key('pinned-photo'));
        expect(find.byType(PhotoViewerScreen), findsOneWidget);
        await _expectAccessible(tester);
        expect(h.state.data.pinnedMemory, isNotNull);
        semantics.dispose();
      });
    }
  });

  group('helpers', () {
    test('clock and spoken lengths', () {
      expect(formatClock(Duration.zero), '0:00');
      expect(formatClock(const Duration(seconds: 65)), '1:05');
      expect(formatClock(const Duration(hours: 1, seconds: 3)), '1:00:03');
      expect(formatClock(const Duration(seconds: -4)), '0:00');
    });
  });
}

/// A folder whose files take 300 MB each (no real bytes needed).
class _HugeStore extends MemoryAttachmentStore {
  _HugeStore() : super(clock: () => kTestNow);

  @override
  Future<int> sizeOfFile(String fileName) async =>
      files.containsKey(fileName) ? 300 * 1024 * 1024 : 0;
}
