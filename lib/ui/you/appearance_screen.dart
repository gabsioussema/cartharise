import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

import '../../app_locale.dart';
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

/// A shipped language's name in that language ("Français", "العربية").
/// Deliberately not localised: someone who can't read the language on
/// screen still recognises their own. [AppLanguage.system] is not a
/// language; resolve it first (it gets English here).
String languageEndonym(AppLanguage language) => switch (language) {
  AppLanguage.fr => 'Français',
  AppLanguage.ar => 'العربية',
  AppLanguage.en || AppLanguage.system => 'English',
};

/// The picker's label of a [language] setting: "Same as phone" in the
/// language on screen, or the language's own name.
String languageLabel(AppLocalizations l, AppLanguage language) =>
    language == AppLanguage.system
    ? l.youLanguageSystem
    : languageEndonym(language);

/// You › Appearance: the language (Same as phone, English, Français,
/// العربية, each in its own language), theme swatches (Forest, Olive,
/// Oasis, Tyrian Rose, Alpine, Obsidian) with one line on what the chosen
/// name stands for, System / Light / Dark, and interface motion. Every
/// change goes through `updateSettings` and applies at once.
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
            const LanguagePicker(),
            const SizedBox(height: 12),
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

/// The language choice (You › Appearance): Same as phone (with what it
/// gives now), then every shipped language by its own name. A tap switches
/// the whole app at once (strings, content, direction, fonts) through
/// `AppState.setLanguage`; the user's own words are never touched.
class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final setting = state.settings.language;
    return SectionCard(
      key: const ValueKey('appearance-language'),
      icon: Icons.translate,
      title: l.youLanguageTitle,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 20, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final language in [AppLanguage.system, ...kAppLanguages])
            _LanguageOption(
              language: language,
              selected: setting == language,
              current: state.language,
              onTap: () {
                if (setting != language) state.setLanguage(language);
              },
            ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
            child: Text(
              l.youLanguageNote,
              key: const ValueKey('language-note'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One radio-like row of the [LanguagePicker]. A language's name is spoken
/// in that language by screen readers (a locale-attributed label).
class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.current,
    required this.onTap,
  });

  final AppLanguage language;
  final bool selected;

  /// The language on screen (what "Same as phone" gives now).
  final AppLanguage current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final system = language == AppLanguage.system;
    final label = languageLabel(l, language);
    final nowName = languageEndonym(current);
    final subtitle = system ? l.youLanguageSystemNow(nowName) : null;
    // The endonym, wherever it sits in the spoken label, is read in its own
    // language; "Same as phone" is read in the language on screen.
    final named = system ? nowName : label;
    final namedLocale = localeFor(system ? current : language);
    final spoken = subtitle == null ? label : '$label. $subtitle';
    final at = spoken.lastIndexOf(named);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      excludeSemantics: true,
      attributedLabel: AttributedString(
        spoken,
        attributes: [
          if (at >= 0)
            LocaleStringAttribute(
              range: TextRange(start: at, end: at + named.length),
              locale: namedLocale,
            ),
        ],
      ),
      child: InkWell(
        key: ValueKey('language-${language.name}'),
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? p.accent : p.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        locale: system ? null : localeFor(language),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          // Each name in its own script's family (the
                          // bundled Arabic font for العربية, whatever the
                          // language on screen).
                          fontFamily: system
                              ? null
                              : CarthaFonts.forLanguage(language).text,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          key: const ValueKey('language-system-now'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
