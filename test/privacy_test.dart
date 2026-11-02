import 'dart:convert';
import 'dart:io';

import 'package:cartharise/data/backup_exclusion.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/services/attachment_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Stays on this phone" (F-043, §09 Privacy): the storage text promises the
/// data is not in phone or cloud backups and that "Delete all data" or
/// removing the app erases it. These tests pin the platform settings that
/// make that true.

String _read(String path) => File(path).readAsStringSync();

/// Every `<exclude domain=… path="."/>` inside [section] of [xml].
Set<String> _excludedDomains(String xml, String section) {
  final match = RegExp(
    '<$section>(.*?)</$section>',
    dotAll: true,
  ).firstMatch(xml);
  expect(match, isNotNull, reason: '<$section> missing');
  return {
    for (final m in RegExp(
      r'<exclude\s+domain="([a-z_]+)"\s+path="\."\s*/>',
    ).allMatches(match!.group(1)!))
      m.group(1)!,
  };
}

const _allDomains = {'root', 'file', 'database', 'sharedpref', 'external'};

/// Every Android permission the release app may hold, from its own manifest
/// or a plugin's. Deliberately short — adding one is a privacy decision:
/// * POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED, VIBRATE: opt-in check-in
///   reminders (flutter_local_notifications);
/// * RECORD_AUDIO: voice notes, asked only when the user taps Record (step 2).
/// Never INTERNET: nothing leaves the phone.
const _allowedPermissions = {
  'android.permission.POST_NOTIFICATIONS',
  'android.permission.RECEIVE_BOOT_COMPLETED',
  'android.permission.VIBRATE',
  'android.permission.RECORD_AUDIO',
};

/// The app's direct dependencies. Deliberately listed: a new one must be
/// local-only (no network client, analytics, crash reporting or cloud).
const _allowedDependencies = {
  'flutter',
  'flutter_localizations',
  'cupertino_icons',
  'provider',
  'path_provider',
  'intl',
  'flutter_svg',
  'url_launcher',
  'share_plus',
  'file_picker',
  'flutter_local_notifications',
  'timezone',
  'flutter_timezone',
  // Step 2: photos, voice notes, backup v2 (.zip) — all on the phone.
  'image_picker',
  'record',
  'audioplayers',
  'archive',
};

Set<String> _permissions(String manifest) => {
  for (final m in RegExp(
    r'<uses-permission[^>]*android:name="([^"]+)"',
  ).allMatches(manifest))
    m.group(1)!,
};

/// The Android manifests of every resolved package that has one.
Map<String, String> _pluginManifests() {
  final config = jsonDecode(
    _read('.dart_tool/package_config.json'),
  ) as Map<String, Object?>;
  final manifests = <String, String>{};
  for (final p in (config['packages']! as List).cast<Map<String, Object?>>()) {
    final root = Uri.parse(p['rootUri']! as String);
    final dir = root.isAbsolute
        ? root.toFilePath()
        : Directory('.dart_tool').uri.resolveUri(root).toFilePath();
    final file = File('$dir/android/src/main/AndroidManifest.xml');
    if (file.existsSync()) {
      manifests[p['name']! as String] = file.readAsStringSync();
    }
  }
  return manifests;
}

void main() {
  group('Android: no OS backup of the user data', () {
    final manifest = _read('android/app/src/main/AndroidManifest.xml');
    final application = RegExp(
      r'<application\b[^>]*>',
      dotAll: true,
    ).firstMatch(manifest)!.group(0)!;

    test('Auto Backup is off', () {
      expect(application, contains('android:allowBackup="false"'));
    });

    test('Android 12+ excludes everything from cloud backup and transfer', () {
      expect(
        application,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
      final rules = _read(
        'android/app/src/main/res/xml/data_extraction_rules.xml',
      );
      expect(rules, isNot(contains('<include')));
      expect(_excludedDomains(rules, 'cloud-backup'), _allDomains);
      expect(_excludedDomains(rules, 'device-transfer'), _allDomains);
    });

    test('only allowed permissions; never INTERNET (app and plugins)', () {
      final own = _permissions(manifest);
      expect(own, isNot(contains('android.permission.INTERNET')));
      expect(own.difference(_allowedPermissions), isEmpty);
      expect(own, contains('android.permission.RECORD_AUDIO'));
      final plugins = _pluginManifests();
      expect(plugins, contains('record_android'));
      for (final MapEntry(key: name, value: xml) in plugins.entries) {
        final declared = _permissions(xml);
        expect(
          declared,
          isNot(contains('android.permission.INTERNET')),
          reason: name,
        );
        expect(declared.difference(_allowedPermissions), isEmpty, reason: name);
      }
      // INTERNET only for the Flutter tool in debug/profile builds.
      for (final variant in ['debug', 'profile']) {
        expect(
          _permissions(_read('android/app/src/$variant/AndroidManifest.xml')),
          {'android.permission.INTERNET'},
        );
      }
    });

    test('older Android excludes everything too', () {
      expect(
        application,
        contains('android:fullBackupContent="@xml/full_backup_content"'),
      );
      final rules = _read(
        'android/app/src/main/res/xml/full_backup_content.xml',
      );
      expect(rules, isNot(contains('<include')));
      expect(_excludedDomains(rules, 'full-backup-content'), _allDomains);
    });
  });

  test('direct dependencies are the deliberate, local-only list', () {
    final pubspec = _read('pubspec.yaml');
    final section = RegExp(
      r'^dependencies:\n(.*?)^dev_dependencies:',
      multiLine: true,
      dotAll: true,
    ).firstMatch(pubspec)!.group(1)!;
    final names = {
      for (final m in RegExp(
        r'^  ([a-z0-9_]+):',
        multiLine: true,
      ).allMatches(section))
        m.group(1)!,
    };
    expect(names, _allowedDependencies);
  });

  group('iOS: the data folder is excluded from iCloud/computer backup', () {
    final delegate = _read('ios/Runner/AppDelegate.swift');

    test('AppDelegate handles the channel the Dart side calls', () {
      expect(delegate, contains('"$kStorageChannelName"'));
      expect(delegate, contains('"$kExcludeFromBackupMethod"'));
      expect(delegate, contains('isExcludedFromBackup = true'));
      expect(delegate, contains('registerStorageChannel('));
    });

    test('the app wires the platform hook into the file store', () {
      expect(
        _read('lib/main.dart'),
        contains('FileDataStore(excludeFromBackup: platformBackupExclusion())'),
      );
    });

    test('… and into the attachments store (photos, recordings)', () {
      expect(
        _read('lib/main.dart').replaceAll(RegExp(r'\s'), ''),
        contains(
          'FileAttachmentStore(excludeFromBackup:platformBackupExclusion(),)',
        ),
      );
    });

    test('photo, camera and microphone are explained, honestly', () {
      final plist = _read('ios/Runner/Info.plist');
      for (final key in [
        'NSMicrophoneUsageDescription',
        'NSPhotoLibraryUsageDescription',
        'NSCameraUsageDescription',
      ]) {
        final value = RegExp('<key>$key</key>\\s*<string>([^<]+)</string>')
            .firstMatch(plist);
        expect(value, isNotNull, reason: key);
        expect(value!.group(1), contains('this phone'), reason: key);
      }
      // Photos go on notes, tries, attempts and projects alike (S2-m9).
      expect(
        RegExp(
          r'<key>NSCameraUsageDescription</key>\s*<string>[^<]*something you write',
        ).hasMatch(plist),
        isTrue,
      );
      expect(plist, isNot(contains('a note or a project')));
      // No exception that would allow plain network traffic.
      expect(plist, isNot(contains('NSAllowsArbitraryLoads')));
    });
  });

  group('FileDataStore', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('cartharise_test'));
    tearDown(() => dir.deleteSync(recursive: true));

    final data = AppData.empty.copyWith(
      journal: [
        JournalEntry(
          id: 'n1',
          body: 'Private words',
          createdAt: DateTime(2026),
        ),
      ],
    );

    test('asks to exclude its folder from backup after every write', () async {
      final excluded = <String>[];
      final store = FileDataStore(
        directory: dir,
        excludeFromBackup: (path) async => excluded.add(path),
      );
      await store.write(data);
      await store.write(data);
      expect(excluded, [dir.path, dir.path]);
      expect((await store.read())!.journal.single.body, 'Private words');
    });

    test(
      'a failed exclusion keeps the save and is retried next time',
      () async {
        var fail = true;
        var calls = 0;
        final store = FileDataStore(
          directory: dir,
          excludeFromBackup: (_) async {
            calls++;
            if (fail) throw StateError('Simulated refusal');
          },
        );
        await store.write(data);
        expect(store.backupExclusionError, isA<StateError>());
        expect((await store.read())!.journal.single.body, 'Private words');
        fail = false;
        await store.write(data);
        expect(calls, 2);
        expect(store.backupExclusionError, isNull);
      },
    );

    test('attachments live in attachments/ next to the data file, and that '
        'folder is excluded from backup too', () async {
      final excluded = <String>[];
      final attachments = FileAttachmentStore(
        directory: dir,
        excludeFromBackup: (path) async => excluded.add(path),
      );
      final source = File('${dir.path}/picked.jpg')
        ..writeAsBytesSync([1, 2, 3]);
      final a = await attachments.importFile(
        source.path,
        kind: AttachmentKind.photo,
      );
      final file = await attachments.fileFor(a);
      expect(file.parent.path, '${dir.path}/attachments');
      expect(file.existsSync(), isTrue);
      expect(excluded, ['${dir.path}/attachments']);
      // The data store's folder holds both: one exclusion covers them.
      await FileDataStore(directory: dir).write(data);
      expect(
        File('${dir.path}/${FileDataStore.fileName}').existsSync(),
        isTrue,
      );
    });

    test('clear removes the saved file and its temporary twin', () async {
      final store = FileDataStore(directory: dir);
      await store.write(data);
      File('${dir.path}/${FileDataStore.fileName}.tmp').writeAsStringSync('x');
      await store.clear();
      expect(dir.listSync(), isEmpty);
      expect(await store.read(), isNull);
    });
  });
}
