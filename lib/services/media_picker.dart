/// Photos from the system photo picker or the camera — only when the user
/// taps the feature. The picked photo is a temporary copy: import it with
/// `AttachmentStore.importFile`, then [MediaPicker.release] it.
///
/// Permission is asked by the system at that moment (the Android photo
/// picker needs none; a denied camera or library is reported as
/// [MediaFailure.permissionDenied] so the UI can say so and offer the other
/// source or typing instead). Nothing is logged.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Why picking a photo failed.
enum MediaFailure {
  /// The user (or a policy) refused camera or photo access.
  permissionDenied,

  /// No camera, or no picker on this device.
  unavailable,

  /// Anything else.
  failed,
}

class MediaPickerException implements Exception {
  const MediaPickerException(this.reason, [this.cause]);

  final MediaFailure reason;
  final Object? cause;

  @override
  String toString() => 'MediaPickerException: ${reason.name}';
}

/// Provided to the widget tree as `Provider<MediaPicker>`.
abstract class MediaPicker {
  /// Lets the user take ([camera]) or choose a photo. Returns the path of a
  /// temporary copy, or null when they cancelled. Throws
  /// [MediaPickerException].
  Future<String?> pickPhoto({required bool camera});

  /// Android may close the app while the camera is open; the photo taken
  /// then is handed back on the next launch. The path, or null.
  Future<String?> recoverLostPhoto();

  /// Deletes the temporary copy at [path] (only inside the app's temporary
  /// folder; anything else is left alone). Best effort.
  Future<void> release(String path);

  /// Deletes every temporary copy this picker handed out and didn't
  /// release (part of "Delete all data"). Throws if one stays.
  Future<void> clearTemporaryFiles();
}

/// Photos are scaled down to this many pixels on their longest side.
const double kMaxPhotoSide = 2048;

/// JPEG quality of picked photos (they are kept on the phone).
const int kPhotoQuality = 85;

class SystemMediaPicker implements MediaPicker {
  SystemMediaPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;
  final Set<String> _handedOut = {};

  @override
  Future<String?> pickPhoto({required bool camera}) async {
    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: kMaxPhotoSide,
        maxHeight: kMaxPhotoSide,
        imageQuality: kPhotoQuality,
        // iOS: the limited picker, no full photo-library access needed.
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      throw MediaPickerException(_failureOf(e.code), e);
    } on Object catch (e) {
      throw MediaPickerException(MediaFailure.failed, e);
    }
    if (file == null) return null;
    _handedOut.add(file.path);
    return file.path;
  }

  @override
  Future<String?> recoverLostPhoto() async {
    if (!Platform.isAndroid) return null;
    try {
      final lost = await _picker.retrieveLostData();
      final file = lost.file;
      if (lost.isEmpty || file == null) return null;
      _handedOut.add(file.path);
      return file.path;
    } on Object {
      return null;
    }
  }

  static MediaFailure _failureOf(String code) => switch (code) {
    'camera_access_denied' ||
    'photo_access_denied' ||
    'camera_access_restricted' ||
    'photo_access_restricted' => MediaFailure.permissionDenied,
    'no_available_camera' => MediaFailure.unavailable,
    _ => MediaFailure.failed,
  };

  Future<bool> _isTemporary(String path) async {
    final temp = (await getTemporaryDirectory()).absolute.path;
    return File(path).absolute.path.startsWith('$temp/');
  }

  @override
  Future<void> release(String path) async {
    _handedOut.remove(path);
    try {
      if (!await _isTemporary(path)) return;
      final file = File(path);
      if (await file.exists()) await file.delete();
    } on Object {
      // Removed by clearTemporaryFiles / the system's cache cleanup.
    }
  }

  @override
  Future<void> clearTemporaryFiles() async {
    Object? failure;
    for (final path in _handedOut.toList()) {
      try {
        if (await _isTemporary(path)) {
          final file = File(path);
          if (await file.exists()) await file.delete();
        }
        _handedOut.remove(path);
      } on Object catch (e) {
        failure = e;
      }
    }
    if (failure != null) throw failure;
  }
}
