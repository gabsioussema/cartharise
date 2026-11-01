import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/empty_state.dart';

/// Shows the "populate Compass from your evening answers" sheet (F-024).
///
/// STUB (Foundation) — Compass+Missions agent replaces the sheet and keeps
/// this function's name and signature (PLAN.md §6).
Future<void> showCompassImport(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CompassImportSheet(),
    );

/// STUB (Foundation) — the import preview sheet.
class CompassImportSheet extends StatelessWidget {
  const CompassImportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SingleChildScrollView(
      child: EmptyState(
        title: l.stubComingSoonTitle,
        body: l.stubComingSoonBody,
      ),
    );
  }
}
