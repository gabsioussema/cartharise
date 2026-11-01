import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../widgets/buttons.dart';
import '../widgets/empty_state.dart';

/// STUB (Foundation) — Onboarding+Today agent. Owner replaces the body and
/// keeps the class name and constructor (PLAN.md §6).
///
/// Shown by `BootScreen` while `AppState.needsOnboarding`; finishing calls
/// `AppState.completeOnboarding(...)`, which switches the app to `RootShell`
/// (and then [onDone], if given).
class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.all(24),
          children: [
            EmptyState(
              title: l.stubComingSoonTitle,
              body: l.stubComingSoonBody,
            ),
            PrimaryButton(
              label: l.keepGoing,
              trailingIcon: Icons.arrow_forward,
              expand: true,
              onPressed: () async {
                await context.read<AppState>().completeOnboarding(
                  pace: Pace.flexible,
                  adultConfirmed: false,
                );
                onDone?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}
