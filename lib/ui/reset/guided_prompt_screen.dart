import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../widgets/stub_screen.dart';

/// STUB (Foundation) — Reset agent. Owner replaces the body and keeps the class name
/// and constructor (PLAN.md §6).
class GuidedPromptScreen extends StatelessWidget {
  const GuidedPromptScreen({super.key, required this.promptId});

  final String promptId;

  @override
  Widget build(BuildContext context) => StubScreen(
    title:
        context.read<AppState>().content.prompt(promptId)?.title ??
        AppLocalizations.of(context).tabReset,
    pushed: true,
  );
}
