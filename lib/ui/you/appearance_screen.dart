import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../journal/journal_kit.dart';
import '../theme/cartha_theme.dart';
import '../theme/theme_swatch.dart';
import '../widgets/widgets.dart';

String themeLabel(AppLocalizations l, AppTheme theme) => switch (theme) {
  AppTheme.forest => l.youThemeForest,
  AppTheme.olive => l.youThemeOlive,
  AppTheme.oasis => l.youThemeOasis,
  AppTheme.tyrian => l.youThemeTyrian,
  AppTheme.alpine => l.youThemeAlpine,
  AppTheme.obsidian => l.youThemeObsidian,
};

/// What a theme's name stands for, in one line.
String themeMeaning(AppLocalizations l, AppTheme theme) => switch (theme) {
  AppTheme.forest => l.youThemeAboutForest,
  AppTheme.olive => l.youThemeAboutOlive,
  AppTheme.oasis => l.youThemeAboutOasis,
  AppTheme.tyrian => l.youThemeAboutTyrian,
  AppTheme.alpine => l.youThemeAboutAlpine,
  AppTheme.obsidian => l.youThemeAboutObsidian,
};

String appearanceLabel(AppLocalizations l, AppearanceMode mode) =>
    switch (mode) {
      AppearanceMode.system => l.youModeSystem,
      AppearanceMode.light => l.youModeLight,
      AppearanceMode.dark => l.youModeDark,
    };

/// You › Appearance: theme swatches (Forest, Olive, Oasis, Tyrian Rose,
/// Alpine, Obsidian) with one line on what the chosen name stands for,
/// System / Light / Dark, and interface motion. Every change goes through
/// `updateSettings` and applies at once.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final settings = state.settings;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AreaListView(
          children: [
            ScreenHeader(
              title: l.youAppearanceTitle,
              subtitle: l.youAppearanceSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
            ),
            SectionCard(
              icon: Icons.palette_outlined,
              title: l.youThemeTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final t in AppTheme.values)
                        Semantics(
                          button: true,
                          selected: settings.theme == t,
                          inMutuallyExclusiveGroup: true,
                          label: themeLabel(l, t),
                          excludeSemantics: true,
                          child: InkWell(
                            key: ValueKey('theme-${t.name}'),
                            borderRadius: BorderRadius.circular(
                              CarthaTheme.radiusSmall,
                            ),
                            onTap: () => state.updateSettings(
                              settings.copyWith(theme: t),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              // Even columns, whatever each name's length.
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 76),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ThemeSwatch(
                                      theme: t,
                                      selected: settings.theme == t,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      themeLabel(l, t),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: settings.theme == t
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    themeMeaning(l, settings.theme),
                    key: const ValueKey('theme-meaning'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.contrast,
              title: l.youModeTitle,
              child: PillTabs<AppearanceMode>(
                key: const ValueKey('appearance-mode'),
                tabs: [
                  for (final m in AppearanceMode.values)
                    PillTab(value: m, label: appearanceLabel(l, m)),
                ],
                selected: settings.appearance,
                onChanged: (m) =>
                    state.updateSettings(settings.copyWith(appearance: m)),
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
              child: SwitchListTile(
                key: const ValueKey('appearance-motion'),
                secondary: Icon(Icons.animation, color: p.accent),
                title: Text(l.youMotion),
                subtitle: Text(l.youMotionHint),
                value: settings.motion,
                onChanged: (v) =>
                    state.updateSettings(settings.copyWith(motion: v)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
