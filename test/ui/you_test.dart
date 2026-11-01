import 'dart:convert';
import 'dart:io';

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/l10n/app_localizations_en.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/you/app_version.dart';
import 'package:cartharise/ui/you/appearance_screen.dart';
import 'package:cartharise/ui/you/backup_preview.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:cartharise/ui/you/font_licenses.dart';
import 'package:cartharise/ui/you/inspiration_screen.dart';
import 'package:cartharise/ui/you/reminders_screen.dart';
import 'package:cartharise/ui/you/support_screen.dart';
import 'package:cartharise/ui/you/you_tab.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// Scrolls the current page until [finder] is built and on screen (list
/// rows below the fold are built lazily).
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester);
}

Future<void> _openYou(WidgetTester tester) async {
  await tester.tap(_nav('You'));
  await pumpFrames(tester);
  expect(find.byType(YouTab), findsOneWidget);
}

/// Opens a hub row of the You tab by key.
Future<void> _openHub(WidgetTester tester, String key) async {
  await _openYou(tester);
  await _tap(tester, find.byKey(ValueKey(key)));
}

/// Records url_launcher calls (the platform channel used in tests).
List<String> _mockLauncher(WidgetTester tester, {bool opens = true}) {
  final launched = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/url_launcher'),
    (call) async {
      if (call.method == 'launch') {
        launched.add((call.arguments as Map)['url'] as String);
        return opens;
      }
      return true;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      null,
    ),
  );
  return launched;
}

/// Picks hh:mm in the open Material time picker (input mode).
Future<void> _pickTime(WidgetTester tester, int hour, int minute) async {
  await tester.tap(find.byIcon(Icons.keyboard_outlined));
  await pumpFrames(tester, count: 3);
  final fields = find.descendant(
    of: find.byType(Dialog),
    matching: find.byType(TextField),
  );
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  await tester.enterText(fields.at(0), '$h12');
  await tester.enterText(fields.at(1), minute.toString().padLeft(2, '0'));
  final period = find.text(hour < 12 ? 'AM' : 'PM');
  if (period.evaluate().isNotEmpty) {
    await tester.tap(period.last);
    await tester.pump();
  }
  await tester.tap(find.text('OK'));
  await pumpFrames(tester);
}

void main() {
  group('hub', () {
    testWidgets('profile, pace and every section', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openYou(tester);
      expect(find.text('Sam'), findsOneWidget);
      // Pace (nothing is locked by time).
      await _tap(tester, find.text('One day'));
      expect(h.state.data.profile!.pace, Pace.oneDay);
      for (final label in [
        'Inspiration',
        'Reminders',
        'Appearance',
        'Your data',
        'Support & safety',
        'Open-source licences',
        'Replay the welcome',
      ]) {
        await _reveal(tester, find.text(label));
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(
        find.textContaining('Version $kAppVersion (build $kAppBuild)'),
        findsOneWidget,
      );
    });

    testWidgets('edit the optional name (and clear it)', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openYou(tester);
      await _tap(tester, find.byKey(const ValueKey('you-profile')));
      expect(find.text('Your name'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Alex');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await pumpFrames(tester);
      expect(h.state.data.profile!.displayName, 'Alex');
      expect(find.text('Alex'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('you-profile')));
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await pumpFrames(tester);
      expect(h.state.data.profile!.displayName, isNull);
      expect(find.text('No name set'), findsOneWidget);
    });

    testWidgets('replay the welcome returns to onboarding, keeps data', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await h.state.addJournalEntry(body: 'kept');
      await _openYou(tester);
      await _tap(tester, find.byKey(const ValueKey('you-replay')));
      expect(find.text('Replay the welcome?'), findsOneWidget);
      await tester.tap(find.text('Show the welcome'));
      await pumpFrames(tester, count: 10);
      expect(find.byType(OnboardingFlow), findsOneWidget);
      expect(h.state.data.journal.single.body, 'kept');
    });

    testWidgets('licences page opens', (tester) async {
      await pumpCartha(tester, data: onboardedData());
      await _openYou(tester);
      await _tap(tester, find.byKey(const ValueKey('you-licences')));
      expect(find.byType(LicensePage), findsOneWidget);
    });

    test('Inter and Cinzel OFL licences are registered', () async {
      registerFontLicenses();
      registerFontLicenses(); // idempotent
      final entries = await LicenseRegistry.licenses.toList();
      for (final font in ['Inter', 'Cinzel']) {
        final matches = entries.where((e) => e.packages.contains(font));
        expect(matches, hasLength(1), reason: font);
        final text = matches.single.paragraphs.map((p) => p.text).join('\n');
        expect(text, contains('SIL OPEN FONT LICENSE Version 1.1'));
        expect(text, contains('$font Project Authors'));
      }
    });

    test('the shown version matches pubspec.yaml', () {
      final line = File('pubspec.yaml')
          .readAsLinesSync()
          .firstWhere((l) => l.startsWith('version:'));
      expect(line.trim(), 'version: $kAppVersion+$kAppBuild');
    });
  });

  group('inspiration (F-002, F-038, F-039)', () {
    testWidgets('two taps from any tab: credit, links and notices', (
      tester,
    ) async {
      final launched = _mockLauncher(tester);
      await pumpCartha(tester, data: onboardedData());
      // From Today: tap 1 = You, tap 2 = Inspiration.
      await _openHub(tester, 'you-inspiration');
      expect(find.byType(InspirationScreen), findsOneWidget);
      final credit = fakeContent.credit;
      expect(find.text(credit.title), findsOneWidget);
      expect(find.text('by ${credit.author}'), findsOneWidget);
      expect(find.text('Published ${credit.publishedOn}'), findsOneWidget);
      expect(find.text(credit.independenceNotice), findsOneWidget);
      expect(find.text(credit.paraphraseNotice), findsOneWidget);
      expect(find.text('From the article, paraphrased'), findsOneWidget);
      expect(find.text('Added by Cartharise'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('inspiration-article')));
      await _tap(tester, find.byKey(const ValueKey('inspiration-newsletter')));
      expect(launched, [credit.articleUrl, credit.newsletterUrl]);
    });

    testWidgets('a link that cannot open says so with the address', (
      tester,
    ) async {
      _mockLauncher(tester, opens: false);
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: const InspirationScreen(),
      );
      await _tap(tester, find.byKey(const ValueKey('inspiration-article')));
      expect(
        find.textContaining(fakeContent.credit.articleUrl),
        findsOneWidget,
      );
    });
  });

  group('reminders (F-016–F-018)', () {
    testWidgets('denied: stays off, explains, offers the calendar file', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      h.reminders.permission = ReminderPermission.denied;
      await _openHub(tester, 'you-reminders');
      expect(find.byType(RemindersScreen), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('reminders-enabled')));
      expect(h.reminders.permissionRequests, 1);
      expect(h.state.settings.remindersEnabled, isFalse);
      expect(h.reminders.scheduled, isEmpty);
      final toggle = tester.widget<SwitchListTile>(
        find.byKey(const ValueKey('reminders-enabled')),
      );
      expect(toggle.value, isFalse);
      expect(find.text("Notifications aren't allowed"), findsOneWidget);
      expect(find.text('Add to your calendar instead'), findsOneWidget);

      await _tap(
        tester,
        find.byKey(const ValueKey('reminders-calendar-instead')),
      );
      final file = h.files.shared.single;
      expect(file.filename, 'cartharise-checkins.ics');
      expect(file.mimeType, 'text/calendar');
      expect(file.content, startsWith('BEGIN:VCALENDAR'));
      expect('BEGIN:VEVENT'.allMatches(file.content), hasLength(6));
    });

    testWidgets('unavailable: stays off with an honest explanation', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      h.reminders.permission = ReminderPermission.unavailable;
      await _openHub(tester, 'you-reminders');
      await _tap(tester, find.byKey(const ValueKey('reminders-enabled')));
      expect(h.state.settings.remindersEnabled, isFalse);
      expect(find.text("Notifications aren't available"), findsOneWidget);
      expect(find.text('Add to your calendar instead'), findsOneWidget);
    });

    testWidgets('granted: on and scheduled; off cancels', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openHub(tester, 'you-reminders');
      expect(
        find.text(
          'Notifications show only the check-in\'s title, never your words.',
        ),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(const ValueKey('reminders-enabled')));
      expect(h.state.settings.remindersEnabled, isTrue);
      expect(h.reminders.scheduled, hasLength(6));
      expect(find.text("Notifications aren't allowed"), findsNothing);
      await _tap(tester, find.byKey(const ValueKey('reminders-enabled')));
      expect(h.state.settings.remindersEnabled, isFalse);
      expect(h.reminders.scheduled, isEmpty);
    });

    testWidgets('six rows; times editable with the source default shown', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openHub(tester, 'you-reminders');
      for (var i = 1; i <= 6; i++) {
        expect(find.text('Daytime $i title'), findsOneWidget);
      }
      expect(find.text('Source default 1:30 PM'), findsOneWidget);
      expect(find.text('11:00 AM'), findsOneWidget);

      await _tap(
        tester,
        find.byKey(const ValueKey('reminder-time-daytime.01')),
      );
      await _pickTime(tester, 8, 15);
      expect(h.state.reminders.first.time, '08:15');
      expect(find.text('8:15 AM'), findsOneWidget);
      // The source default stays visible, with a way back to it.
      expect(find.text('Source default 11:00 AM'), findsOneWidget);
      await _tap(
        tester,
        find.byKey(const ValueKey('reminder-default-daytime.01')),
      );
      expect(h.state.reminders.first.time, '11:00');

      await _tap(
        tester,
        find.byKey(const ValueKey('reminder-switch-daytime.02')),
      );
      expect(h.state.reminders[1].enabled, isFalse);
      expect(h.state.reminders[1].time, '13:30');
    });

    testWidgets('times follow a 24-hour phone', (tester) async {
      await pumpCartha(
        tester,
        data: onboardedData(),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: const RemindersScreen(),
          ),
        ),
      );
      expect(find.text('13:30'), findsOneWidget);
      expect(find.text('Source default 21:00'), findsOneWidget);
    });

    testWidgets('quiet hours: set both, then clear', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openHub(tester, 'you-reminders');
      await _tap(tester, find.byKey(const ValueKey('quiet-start')));
      await _pickTime(tester, 22, 30);
      expect(h.state.settings.quietStart, '22:30');
      expect(
        find.text('Set both times for quiet hours to apply.'),
        findsOneWidget,
      );
      await _tap(tester, find.byKey(const ValueKey('quiet-end')));
      await _pickTime(tester, 7, 0);
      expect(h.state.settings.quietEnd, '07:00');
      expect(
        find.text('Set both times for quiet hours to apply.'),
        findsNothing,
      );
      await _tap(tester, find.byKey(const ValueKey('quiet-clear')));
      expect(h.state.settings.quietStart, isNull);
      expect(h.state.settings.quietEnd, isNull);
    });

    testWidgets('calendar export shares the .ics through FileShare', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: onboardedData(),
        home: const RemindersScreen(),
      );
      await _tap(tester, find.byKey(const ValueKey('reminders-calendar')));
      final file = h.files.shared.single;
      expect(file.filename, 'cartharise-checkins.ics');
      expect(file.mimeType, 'text/calendar');
      expect(
        file.content,
        h.state.calendarExport(calendarTexts(AppLocalizationsEn())),
      );
      expect(file.content, contains('Cartharise check-ins'));
      expect(find.textContaining('Calendar file shared'), findsOneWidget);
    });
  });

  group('appearance', () {
    testWidgets('theme, mode and motion', (tester) async {
      final h = await pumpCartha(tester, data: onboardedData());
      await _openHub(tester, 'you-appearance');
      expect(find.byType(AppearanceScreen), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('theme-olive')));
      expect(h.state.settings.theme, AppTheme.olive);
      await _tap(tester, find.text('Light'));
      expect(h.state.settings.appearance, AppearanceMode.light);
      await _tap(tester, find.byKey(const ValueKey('appearance-motion')));
      expect(h.state.settings.motion, isFalse);
      await tester.pageBack();
      await pumpFrames(tester);
      expect(find.text('Olive · Light'), findsOneWidget);
    });
  });

  group('your data (F-040–F-043)', () {
    AppData withNote(String body) => onboardedData().copyWith(
      journal: [
        JournalEntry(id: 'n1', body: body, createdAt: DateTime(2026, 11, 1)),
      ],
    );

    testWidgets('storage is described honestly', (tester) async {
      await pumpCartha(tester, data: withNote('x'), home: const DataScreen());
      expect(find.textContaining('Stored only on this phone'), findsOneWidget);
      expect(
        find.textContaining('not encrypted by Cartharise'),
        findsOneWidget,
      );
      // Android backups are off (manifest) and iOS excludes the folder.
      expect(
        find.textContaining('not included in phone or cloud backups'),
        findsOneWidget,
      );
    });

    testWidgets('export shares a complete, valid JSON backup', (tester) async {
      final h = await pumpCartha(tester, data: withNote('My words'));
      await _openHub(tester, 'you-data');
      await _tap(tester, find.byKey(const ValueKey('data-export')));
      final file = h.files.shared.single;
      expect(file.filename, 'cartharise-backup-2026-11-03.json');
      expect(file.mimeType, 'application/json');
      final json = jsonDecode(file.content) as Map<String, Object?>;
      expect(json['app'], 'cartharise');
      expect(decodeBackup(file.content).journal.single.body, 'My words');
      expect(find.text('Backup shared.'), findsOneWidget);
    });

    testWidgets('a failed share is reported honestly', (tester) async {
      final h = await pumpCartha(
        tester,
        data: withNote('x'),
        home: const DataScreen(),
      );
      h.files.failShare = true;
      await _tap(tester, find.byKey(const ValueKey('data-export')));
      expect(
        find.text("Couldn't open the share sheet on this phone."),
        findsOneWidget,
      );
    });

    for (final (name, text, reason) in [
      ('malformed JSON', '{ not json', "It isn't a readable backup file."),
      (
        'another app',
        '{"app":"other","format":1}',
        "It isn't a Cartharise backup.",
      ),
      (
        'damaged backup',
        '{"app":"cartharise","format":1,"data":{"schemaVersion":1,"journal":[{"id":3}]}}',
        'The backup is incomplete or damaged.',
      ),
    ]) {
      testWidgets('import rejects $name; data unchanged', (tester) async {
        final h = await pumpCartha(tester, data: withNote('Keep me'));
        final before = h.store.raw;
        final writes = h.store.writes;
        h.files.pickResult = text;
        await _openHub(tester, 'you-data');
        await _tap(tester, find.byKey(const ValueKey('data-import')));
        expect(find.text("This file couldn't be used"), findsOneWidget);
        expect(find.text(reason), findsOneWidget);
        expect(find.text('Your current data was not changed.'), findsOneWidget);
        expect(find.byType(AlertDialog), findsNothing);
        expect(h.state.data.journal.single.body, 'Keep me');
        expect(h.store.raw, before);
        expect(h.store.writes, writes);
      });
    }

    testWidgets('import asks with the backup date, then replaces', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: withNote('Old'));
      h.files.pickResult = encodeBackup(
        withNote('Restored'),
        DateTime(2026, 10, 1, 12),
      );
      await _openHub(tester, 'you-data');
      await _tap(tester, find.byKey(const ValueKey('data-import')));
      expect(
        find.text(
          'Replace everything on this phone with the backup from '
          'Thu, Oct 1, 2026, 12:00 PM?',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Cancel'));
      await pumpFrames(tester);
      expect(h.state.data.journal.single.body, 'Old');

      await _tap(tester, find.byKey(const ValueKey('data-import')));
      await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
      await pumpFrames(tester);
      expect(h.state.data.journal.single.body, 'Restored');
      expect(h.store.saved!.journal.single.body, 'Restored');
      expect(find.text('Backup restored.'), findsOneWidget);
    });

    testWidgets('a restore that could not be saved is not called restored', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: withNote('Old'));
      h.files.pickResult = encodeBackup(
        withNote('Restored'),
        DateTime(2026, 10, 1, 12),
      );
      await _openHub(tester, 'you-data');
      h.store.failWrites = true;
      await _tap(tester, find.byKey(const ValueKey('data-import')));
      await tester.tap(find.widgetWithText(FilledButton, 'Replace'));
      await pumpFrames(tester);
      expect(h.state.saveStatus, SaveStatus.failed);
      // On screen, but not on disk: say so, never "Backup restored."
      expect(h.state.data.journal.single.body, 'Restored');
      expect(h.store.saved!.journal.single.body, 'Old');
      expect(find.text('Backup restored.'), findsNothing);
      expect(
        find.text(
          "The backup is open on screen, but it couldn't be saved on this "
          'phone yet. Use Retry at the top of this screen, or export a copy.',
        ),
        findsOneWidget,
      );
      expect(find.text("Your last change couldn't be saved."), findsOneWidget);
      // Retry makes it stick.
      h.store.failWrites = false;
      final retry = find.text('Retry');
      await tester.ensureVisible(retry);
      await pumpFrames(tester);
      await tester.tap(retry);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await pumpFrames(tester);
      expect(h.state.saveStatus, SaveStatus.saved);
      expect(h.store.saved!.journal.single.body, 'Restored');
    });

    testWidgets('a cancelled file picker changes nothing', (tester) async {
      final h = await pumpCartha(
        tester,
        data: withNote('x'),
        home: const DataScreen(),
      );
      h.files.pickResult = null;
      await _tap(tester, find.byKey(const ValueKey('data-import')));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text("This file couldn't be used"), findsNothing);
    });

    testWidgets('delete all: two confirmations, then onboarding', (
      tester,
    ) async {
      final h = await pumpCartha(tester, data: withNote('Gone soon'));
      await _openHub(tester, 'you-data');
      await _tap(tester, find.byKey(const ValueKey('data-delete')));
      expect(find.text('Delete all data?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await pumpFrames(tester);
      expect(h.state.data.journal, hasLength(1));

      await _tap(tester, find.byKey(const ValueKey('data-delete')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpFrames(tester);
      expect(find.text("This can't be undone"), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await pumpFrames(tester, count: 10);
      expect(find.byType(OnboardingFlow), findsOneWidget);
      expect(find.byType(DataScreen), findsNothing);
      expect(h.store.raw, isNull);
      expect(h.state.data.journal, isEmpty);
      expect(h.reminders.cancelCount, greaterThan(0));
      // Export and import copies are erased too (share sheet, file picker).
      expect(h.files.clearCount, 1);
    });

    testWidgets('delete all clears export copies even after an export', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: withNote('Exported then deleted'),
        home: const DataScreen(),
      );
      await _tap(tester, find.byKey(const ValueKey('data-export')));
      expect(h.files.shared, hasLength(1));
      expect(h.files.clearCount, 0);
      await _tap(tester, find.byKey(const ValueKey('data-delete')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpFrames(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await pumpFrames(tester);
      expect(h.files.clearCount, 1);
      expect(h.store.raw, isNull);
    });

    testWidgets('a copy that could not be removed is reported honestly', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: withNote('Gone soon'),
        home: const DataScreen(),
      );
      h.files.failClear = true;
      await _tap(tester, find.byKey(const ValueKey('data-delete')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpFrames(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await pumpFrames(tester);
      // The saved data is still deleted, and the leftover copy is named.
      expect(h.store.raw, isNull);
      expect(
        find.textContaining(
          "a temporary copy of an earlier export or import "
          "couldn't be removed",
        ),
        findsOneWidget,
      );
    });

    testWidgets('a failed delete is reported; data stays', (tester) async {
      final h = await pumpCartha(
        tester,
        data: withNote('Still here'),
        home: const DataScreen(),
      );
      h.store.failWrites = true;
      await _tap(tester, find.byKey(const ValueKey('data-delete')));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpFrames(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await pumpFrames(tester);
      expect(find.textContaining("Couldn't delete your data"), findsOneWidget);
      expect(h.state.data.journal.single.body, 'Still here');
    });

    test('previewBackup reads the date and validates fully', () {
      final text = encodeBackup(onboardedData(), DateTime.utc(2026, 10, 1, 12));
      final preview = previewBackup(text);
      expect(preview.exportedAt, DateTime.utc(2026, 10, 1, 12));
      expect(preview.data.profile!.displayName, 'Sam');
      expect(() => previewBackup('[]'), throwsFormatException);
    });

    test('every import error has a plain-language reason', () {
      final l = AppLocalizationsEn();
      expect(
        backupErrorMessage(l, const FormatException('Not a JSON file')),
        l.youDataImportNotJson,
      );
      expect(
        backupErrorMessage(
          l,
          const FormatException('Unsupported schema version'),
        ),
        l.youDataImportUnsupported,
      );
      expect(
        backupErrorMessage(l, const FormatException('The file is too large')),
        l.youDataImportTooLarge,
      );
      expect(
        backupErrorMessage(l, const FormatException('Expected int for "day"')),
        l.youDataImportDamaged,
      );
    });
  });

  group('support & safety (F-047, D-06)', () {
    testWidgets('not therapy, heavy questions, crisis line link', (
      tester,
    ) async {
      final launched = _mockLauncher(tester);
      await pumpCartha(tester, data: onboardedData());
      await _openHub(tester, 'you-support');
      expect(find.byType(SupportScreen), findsOneWidget);
      expect(find.textContaining("isn't therapy"), findsOneWidget);
      expect(find.textContaining('Skip it'), findsOneWidget);
      expect(find.textContaining('local emergency services'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('support-helpline')));
      expect(launched, ['https://findahelpline.com']);
    });
  });

  group('screen sizes', () {
    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('you screens fit $size (${brightness.name})', (
          tester,
        ) async {
          final h = await pumpCartha(
            tester,
            data: onboardedData(),
            size: size.size,
            textScale: size.textScale,
            brightness: brightness,
          );
          h.reminders.permission = ReminderPermission.denied;
          h.files.pickResult = '{ not json';
          await _openYou(tester);
          await expectNoOverflow(tester);

          Future<void> visit(String key, Future<void> Function() inside) async {
            await tester.drag(
              find.byType(Scrollable).first,
              const Offset(0, 4000),
            );
            await pumpFrames(tester, count: 2);
            await _tap(tester, find.byKey(ValueKey(key)));
            await inside();
            await expectNoOverflow(tester);
            await tester.pageBack();
            await pumpFrames(tester);
          }

          await visit('you-inspiration', () async {});
          await visit('you-reminders', () async {
            await _tap(tester, find.byKey(const ValueKey('reminders-enabled')));
            expect(find.text("Notifications aren't allowed"), findsOneWidget);
            await _tap(tester, find.byKey(const ValueKey('quiet-start')));
            await tester.tap(find.text('OK'));
            await pumpFrames(tester);
          });
          await visit('you-appearance', () async {});
          await visit('you-data', () async {
            await _tap(tester, find.byKey(const ValueKey('data-import')));
            expect(
              find.text('Your current data was not changed.'),
              findsOneWidget,
            );
          });
          await visit('you-support', () async {});
        });
      }
    }
  });
}
