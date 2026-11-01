import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/stub_screen.dart';

/// STUB (Foundation) — Compass+Missions agent. Owner replaces the body and keeps the class name
/// and constructor (PLAN.md §6).
class ProjectScreen extends StatelessWidget {
  const ProjectScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      StubScreen(title: AppLocalizations.of(context).tabCompass, pushed: true);
}
