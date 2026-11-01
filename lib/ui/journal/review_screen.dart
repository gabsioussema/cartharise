import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/stub_screen.dart';

/// STUB (Foundation) — Journal+You agent. Owner replaces the body and keeps the class name
/// and constructor (PLAN.md §6).
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key, this.reviewId});

  /// Null = a new weekly review.
  final String? reviewId;

  @override
  Widget build(BuildContext context) =>
      StubScreen(title: AppLocalizations.of(context).tabJournal, pushed: true);
}
