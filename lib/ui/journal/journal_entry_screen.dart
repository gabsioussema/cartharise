import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/stub_screen.dart';

/// STUB (Foundation) — Journal+You agent. Owner replaces the body and keeps the class name
/// and constructor (PLAN.md §6).
class JournalEntryScreen extends StatelessWidget {
  const JournalEntryScreen({super.key, this.entryId});

  /// Null = a new note.
  final String? entryId;

  @override
  Widget build(BuildContext context) =>
      StubScreen(title: AppLocalizations.of(context).tabJournal, pushed: true);
}
