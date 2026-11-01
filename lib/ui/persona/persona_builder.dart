import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/widgets.dart';

/// Create or edit the avatar and motto.
///
/// CONTRACT STUB (persona plan, phase 0): the persona-builder agent replaces
/// the body; the class name and constructor stay exactly as is.
class PersonaBuilderScreen extends StatelessWidget {
  const PersonaBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: ScreenHeader(title: l.personaFeatureTitle),
    );
  }
}
