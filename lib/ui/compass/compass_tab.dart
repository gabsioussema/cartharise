import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/stub_screen.dart';

/// The two halves of the Compass tab (PLAN.md §2).
enum CompassSection { compass, missions }

/// STUB (Foundation) — Compass+Missions agent. Owner replaces the body and
/// keeps the class name and constructor (PLAN.md §6).
///
/// `AppNav.openCompass/openMissions` set `ShellController.compassSection`;
/// the real tab should listen to it, show that section and reset it to null.
class CompassTab extends StatelessWidget {
  const CompassTab({super.key, this.initial = CompassSection.compass});

  final CompassSection initial;

  @override
  Widget build(BuildContext context) => StubScreen(
    title: AppLocalizations.of(context).tabCompass,
    pushed: ModalRoute.of(context)?.isFirst == false,
  );
}
