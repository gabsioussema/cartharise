import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Where the user's data lives, honestly and in their language (F-043):
/// only on this phone, in the app's private folder, not encrypted by
/// Cartharise, not synced, left out of phone and cloud backups (Android
/// manifest, iOS `isExcludedFromBackup`), erased by removing the app or by
/// "Delete all data". Shown on onboarding and in You › Your data.
class StorageTransparencyText extends StatelessWidget {
  const StorageTransparencyText({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) =>
      Text(AppLocalizations.of(context).storageTransparency, style: style);
}
