import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../journal/journal_kit.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// The international helpline directory (opened in the browser).
final Uri kHelplineDirectory = Uri.parse('https://findahelpline.com');

/// Support & safety (F-047, D-06): Cartharise is self-reflection, not
/// therapy or diagnosis; heavy questions can be skipped, softened or paused;
/// in a crisis, local emergency services or a crisis line (helpline
/// directory link). Reachable from the guided prompts via
/// `AppNav.openSupport`.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AreaListView(
          children: [
            ScreenHeader(
              title: l.youSupportTitle,
              subtitle: l.youSupportSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
            ),
            HeroCard(
              eyebrow: l.youSupportNotTherapyTitle,
              trailing: CarthaEmblem(
                size: 40,
                color: p.heroAccent,
                excludeFromSemantics: true,
              ),
              child: Text(
                l.youSupportNotTherapyBody,
                style: theme.textTheme.bodyLarge?.copyWith(color: p.onHero),
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.spa_outlined,
              title: l.youSupportHeavyTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (icon, text) in [
                    (Icons.redo, l.youSupportHeavy1),
                    (Icons.tune, l.youSupportHeavy2),
                    (Icons.pause_circle_outline, l.youSupportHeavy3),
                    (Icons.people_outline, l.youSupportHeavy4),
                  ])
                    Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, size: 20, color: p.accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              text,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              key: const ValueKey('support-crisis'),
              icon: Icons.health_and_safety_outlined,
              title: l.youSupportCrisisTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l.youSupportCrisisBody,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    key: const ValueKey('support-helpline'),
                    label: l.youSupportFindHelpline,
                    trailingIcon: Icons.open_in_new,
                    expand: true,
                    onPressed: () =>
                        openExternalLink(context, kHelplineDirectory),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l.youSupportHelplineHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.local_hospital_outlined,
              title: l.youSupportOngoingTitle,
              child: Text(
                l.youSupportOngoingBody,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
