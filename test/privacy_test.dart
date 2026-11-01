import 'dart:io';

import 'package:cartharise/data/backup_exclusion.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
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
