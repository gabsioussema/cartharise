import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'empty_state.dart';
import 'headers.dart';

/// Placeholder body for a screen whose owner hasn't built it yet (PLAN.md §6
/// stubs). Tabs ([pushed] false) have no app bar; pushed screens get a back
/// button. Feature agents replace the stub's body and drop this import.
class StubScreen extends StatelessWidget {
  const StubScreen({super.key, required this.title, this.pushed = true});

  final String title;
  final bool pushed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: pushed ? AppBar() : null,
      body: SafeArea(
        top: !pushed,
        child: ListView(
          children: [
            ScreenHeader(title: title),
            EmptyState(
              title: l.stubComingSoonTitle,
              body: l.stubComingSoonBody,
            ),
          ],
        ),
      ),
    );
  }
}
