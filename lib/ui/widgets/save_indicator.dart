import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import 'buttons.dart';

/// Honest autosave feedback (F-055), read from `AppState.saveStatus`:
/// nothing before the first change, "Saving…", "Saved on this device", or —
/// on failure — the problem with Retry and "Export a copy". Status changes
/// are announced to screen readers. Static (no spinner), so tests can settle.
class SaveIndicator extends StatelessWidget {
  const SaveIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select((AppState s) => s.saveStatus);
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final small = Theme.of(context).textTheme.bodySmall;
    Widget line(IconData icon, String text, Color color) => Semantics(
      liveRegion: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text, style: small?.copyWith(color: color)),
          ),
        ],
      ),
    );
    return switch (status) {
      SaveStatus.idle => const SizedBox.shrink(),
      SaveStatus.saving => line(
        Icons.more_horiz,
        l.saveStatusSaving,
        p.textSecondary,
      ),
      SaveStatus.saved => line(
        Icons.check_circle_outline,
        l.saveStatusSaved,
        p.textSecondary,
      ),
      SaveStatus.failed => Semantics(
        liveRegion: true,
        container: true,
        child: Container(
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            color: p.errorContainer,
            borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
            border: Border.all(color: p.error),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 20,
                    color: p.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.saveStatusFailed,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: p.onErrorContainer),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l.saveFailedHelp,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: p.textPrimary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextLinkButton(
                    label: l.retry,
                    icon: Icons.refresh,
                    onPressed: () => context.read<AppState>().retrySave(),
                  ),
                  TextLinkButton(
                    label: l.saveExportCopy,
                    icon: Icons.ios_share,
                    onPressed: () => AppNav.openData(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    };
  }
}
