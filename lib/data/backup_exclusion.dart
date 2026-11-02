/// Keeps the user's data out of operating-system backups (F-043, privacy:
/// "stays on this phone").
///
/// * Android: nothing to do at run time — `AndroidManifest.xml` sets
///   `allowBackup="false"` and excludes everything from cloud backup and
///   device transfer (`res/xml/data_extraction_rules.xml`).
/// * iOS: `Library/Application Support` is in iCloud and computer backups
///   by default, so after every save [FileDataStore] asks the native side
///   (`ios/Runner/AppDelegate.swift`) to mark the data folder
///   `isExcludedFromBackup`, and `FileAttachmentStore` does the same for its
///   `attachments/` folder inside it. Only a folder path crosses the
///   channel.
library;

import 'dart:io';

import 'package:flutter/services.dart';

/// Must match the channel registered in `ios/Runner/AppDelegate.swift`.
const String kStorageChannelName = 'app.cartharise/storage';

/// Must match the method handled in `ios/Runner/AppDelegate.swift`.
const String kExcludeFromBackupMethod = 'excludeFromBackup';

const MethodChannel _channel = MethodChannel(kStorageChannelName);

/// Marks [path] (a file or folder) as excluded from iCloud / computer
/// backups. Throws a [PlatformException] when iOS refuses.
Future<void> excludeFromIosBackup(String path) =>
    _channel.invokeMethod<void>(kExcludeFromBackupMethod, path);

/// The exclusion hook [FileDataStore] should call after each write on this
/// platform, or null when the platform needs none (Android: manifest).
Future<void> Function(String path)? platformBackupExclusion() =>
    Platform.isIOS ? excludeFromIosBackup : null;
