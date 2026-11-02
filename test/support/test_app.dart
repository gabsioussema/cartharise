import 'dart:io';

import 'package:cartharise/app.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_content.dart';
import 'fakes.dart';

export 'fake_content.dart';
export 'fakes.dart';

/// Wraps the app for [captureScreenshot] (`test/support/screenshot.dart`).
const kScreenshotKey = ValueKey('cartha-screenshot');

/// Fixed "now" for widget tests: Tuesday 3 November 2026, 09:30 local.
final kTestNow = DateTime(2026, 11, 3, 9, 30);

/// One screen size of the matrix every new screen is tested on (PLAN.md §9).
class SizeCase {
  const SizeCase(this.name, this.size, this.textScale);
  final String name;
  final Size size;
  final double textScale;
  @override
  String toString() => name;
}

/// Small phone at 200 % text, a regular phone, a tablet at 130 % text.
const kSizeMatrix = [
  SizeCase('320×568 @2.0', Size(320, 568), 2.0),
  SizeCase('390×844 @1.0', Size(390, 844), 1.0),
  SizeCase('1024×1366 @1.3', Size(1024, 1366), 1.3),
];

/// Everything a widget test may want to inspect or drive.
class CarthaHarness {
  CarthaHarness({
    required this.state,
    required this.store,
    required this.reminders,
    required this.files,
    required this.shell,
    required this.attachments,
    required this.media,
    required this.recorder,
    required this.player,
  });

  final AppState state;
  final MemoryDataStore store;
  final FakeReminderScheduler reminders;
  final FakeFileShare files;
  final ShellController shell;

  /// The photos and recordings "on the phone".
  final MemoryAttachmentStore attachments;
  final FakeMediaPicker media;
  final FakeVoiceRecorder recorder;
  final FakeVoicePlayer player;
}

/// Data for a user who finished onboarding (so the app opens on RootShell).
AppData onboardedData({String? name = 'Sam', AppSettings? settings}) => AppData(
  profile: UserProfile(
    createdAt: DateTime(2026, 11, 1, 8),
    onboardedAt: DateTime(2026, 11, 1, 8, 5),
    displayName: name,
    adultConfirmed: true,
  ),
  settings: settings ?? const AppSettings(),
);

bool _fontsLoaded = false;

/// Loads the bundled Inter + Cinzel and the Material icon font, so widget
/// tests measure real text (realistic overflow) and screenshots look real.
Future<void> loadCarthaFonts() async {
  if (_fontsLoaded) return;
  _fontsLoaded = true;
  final inter = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$w.ttf'));
  }
  await inter.load();
  final cinzel = FontLoader('Cinzel');
  for (final w in ['400', '600', '700']) {
    cinzel.addFont(rootBundle.load('assets/fonts/Cinzel-$w.ttf'));
  }
  await cinzel.load();
  final root =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final icons = File(
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    await (FontLoader(
          'MaterialIcons',
        )..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync()))))
        .load();
  }
}

/// Pumps the real app ([CarthaApp]) with in-memory storage and fake
/// services, at [size] / [textScale] with edge-to-edge system insets.
///
/// * [data] — what is "saved" (null = first launch → onboarding).
/// * [home] — a single screen to show instead of the BootScreen flow (the
///   state is loaded first).
/// * [brightness] / [theme] — appearance to render.
/// * [now] — the clock (default [kTestNow]).
/// * [readDelay] / [frames] — slow the first read and pump fewer frames to
///   observe the boot loader.
/// * [attachments] — photos and recordings already "on the phone" (files
///   the saved data names must be in it, or the load's cleanup keeps only
///   the named ones).
/// * [media] — the photo picker (e.g. with a `lostPhoto` the camera hands
///   back at launch).
///
/// The boot loader animates forever, so this pumps a fixed number of frames
/// instead of `pumpAndSettle`; do the same while a `CarthaLoader` is visible.
Future<CarthaHarness> pumpCartha(
  WidgetTester tester, {
  AppData? data,
  Widget? home,
  Size size = const Size(390, 844),
  double textScale = 1.0,
  Brightness brightness = Brightness.dark,
  AppTheme theme = AppTheme.forest,
  DateTime? now,
  ContentLibrary? content,
  EdgeInsets systemPadding = const EdgeInsets.only(top: 24, bottom: 16),
  ShellController? shell,
  Duration readDelay = Duration.zero,
  int frames = 6,
  MemoryAttachmentStore? attachments,
  FakeMediaPicker? media,
}) async {
  await tester.runAsync(loadCarthaFonts);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(
    top: systemPadding.top,
    bottom: systemPadding.bottom,
  );
  tester.view.viewPadding = FakeViewPadding(
    top: systemPadding.top,
    bottom: systemPadding.bottom,
  );
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final base = data ?? AppData.empty;
  final saved = data == null && theme == AppTheme.forest
      ? null
      : base.copyWith(settings: base.settings.copyWith(theme: theme));
  final store = MemoryDataStore(saved)..readDelay = readDelay;
  final reminders = FakeReminderScheduler();
  final files = FakeFileShare();
  final controller = shell ?? ShellController();
  final clock = now ?? kTestNow;
  final attachmentStore =
      attachments ?? MemoryAttachmentStore(clock: () => clock);
  final picker = media ?? FakeMediaPicker();
  final recorder = FakeVoiceRecorder(store: attachmentStore);
  final player = FakeVoicePlayer();
  final state = AppState(
    store: store,
    content: content ?? fakeContent,
    reminders: reminders,
    attachments: attachmentStore,
    clock: () => clock,
  );
  if (home != null) await state.load();
  await tester.pumpWidget(
    RepaintBoundary(
      key: kScreenshotKey,
      child: CarthaApp(
        state: state,
        fileShare: files,
        mediaPicker: picker,
        voiceRecorder: recorder,
        voicePlayer: player,
        shell: controller,
        home: home,
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
      ),
    ),
  );
  await pumpFrames(tester, count: frames);
  return CarthaHarness(
    state: state,
    store: store,
    reminders: reminders,
    files: files,
    shell: controller,
    attachments: attachmentStore,
    media: picker,
    recorder: recorder,
    player: player,
  );
}

/// Pumps [count] frames of [step] (use instead of `pumpAndSettle` while an
/// endless animation such as `CarthaLoader` is on screen).
Future<void> pumpFrames(
  WidgetTester tester, {
  int count = 6,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(step);
  }
}

/// Scrolls every vertical list to its end (so lazily built rows are laid
/// out too) and fails on any layout overflow or other exception.
Future<void> expectNoOverflow(WidgetTester tester) async {
  for (final element in find.byType(Scrollable).evaluate().toList()) {
    if (!element.mounted) continue;
    final state = (element as StatefulElement).state as ScrollableState;
    if (state.position.axis != Axis.vertical) continue;
    var guard = 0;
    while (state.mounted &&
        state.position.pixels < state.position.maxScrollExtent &&
        guard++ < 50) {
      state.position.jumpTo(
        (state.position.pixels + state.position.viewportDimension * 0.8).clamp(
          0,
          state.position.maxScrollExtent,
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }
  expect(tester.takeException(), isNull, reason: 'layout overflow or error');
}
