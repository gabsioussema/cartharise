import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/app_data.dart';
import 'cartha_fonts.dart';
import 'cartha_theme_spec.dart';

export 'cartha_fonts.dart';

/// Brand colours and the few colours that are the same in every theme.
/// Theme-internal: screens use [CarthaPalette] tokens instead (enforced by
/// `test/ui_base_test.dart`).
abstract final class CarthaColors {
  static const forest = Color(0xFF1E3328);
  static const deepForest = Color(0xFF17261E);
  static const olive = Color(0xFF4B5320);
  static const sage = Color(0xFFA3AD8C);
  static const bronze = Color(0xFFB08D57);
  static const lightBronze = Color(0xFFD4B57B);
  static const deepBronze = Color(0xFF9B7847);
  static const ivory = Color(0xFFF1EBDD);
  static const paper = Color(0xFFF7F4EC);
  static const cream = Color(0xFFFFFDF8);
  static const greenGrey = Color(0xFF687870);
  static const mist = Color(0xFFB9C6B8);

  static const successDark = Color(0xFF8FD19E);
  static const errorDark = Color(0xFFF4A196);
  static const warningDark = Color(0xFFE9C46A);
  static const successLight = Color(0xFF2E6B3F);
  static const errorLight = Color(0xFFA3322A);
  static const warningLight = Color(0xFF7A5200);
  static const onSuccessContainerLight = Color(0xFF245532);
  static const onErrorContainerLight = Color(0xFF8A2820);
  static const onWarningContainerLight = Color(0xFF664400);

  static const black = Color(0xFF000000);
}

/// The UI base: every colour a screen may use, by role. Read it with
/// `CarthaPalette.of(context)`; never use raw colours in `lib/ui/` outside
/// `lib/ui/theme/`.
@immutable
class CarthaPalette extends ThemeExtension<CarthaPalette> {
  const CarthaPalette({
    required this.isDark,
    required this.background,
    required this.card,
    required this.raised,
    required this.raisedHigh,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.onAccent,
    required this.primary,
    required this.onPrimary,
    required this.hero,
    required this.heroRaised,
    required this.onHero,
    required this.onHeroMuted,
    required this.heroAccent,
    required this.heroBorder,
    required this.emblem,
    required this.success,
    required this.error,
    required this.onError,
    required this.warning,
    required this.onSuccessContainer,
    required this.onErrorContainer,
    required this.onWarningContainer,
    required this.selection,
    required this.shadow,
    required this.swatch,
  });

  final bool isDark;

  /// Page background and card surfaces (lowest → highest).
  final Color background;
  final Color card;
  final Color raised;
  final Color raisedHigh;

  /// Decorative hairline (cards, dividers).
  final Color border;

  /// Boundary of interactive controls (≥ 3:1 against every surface).
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;

  /// Icons, links, selected states and focus on [background]/[card]
  /// (text-safe: ≥ 4.5:1 on every surface).
  final Color accent;

  /// Text and icons on an [accent] fill (checkbox tick, selected chips).
  final Color onAccent;

  /// Main buttons: bronze pill on dark, deep pill on light.
  final Color primary;
  final Color onPrimary;

  /// Deep forest (or olive) hero surfaces, used in BOTH brightnesses.
  final Color hero;
  final Color heroRaised;
  final Color onHero;
  final Color onHeroMuted;

  /// Bronze for icons, links and the emblem on [hero].
  final Color heroAccent;
  final Color heroBorder;

  /// The brand emblem on [background]/[card] (bronze on dark, deep bronze on light).
  final Color emblem;

  final Color success;
  final Color error;
  final Color onError;
  final Color warning;
  final Color onSuccessContainer;
  final Color onErrorContainer;
  final Color onWarningContainer;

  /// Fill behind selected rows, chips and text selection.
  final Color selection;
  final Color shadow;

  /// This theme's signature colour (theme picker).
  final Color swatch;

  // ── Derived roles ───────────────────────────────────────────────────────

  Color get surface => card;
  Color get dialog => raised;
  Color get input => card;
  Color get navigation => card;
  Color get textMuted => textSecondary;
  Color get textDisabled => textSecondary.withValues(alpha: 0.6);
  Color get textPlaceholder => textSecondary;
  Color get disabledSurface => raised;
  Color get inverseSurface => isDark ? textPrimary : hero;
  Color get textInverse => isDark ? background : onHero;

  Color get borderSubtle => border;
  Color get borderActive => accent;
  Color get borderError => error;
  Color get divider => border;

  /// Keyboard focus ring.
  Color get focus => accent;
  Color get pressed => accent.withValues(alpha: 0.10);
  Color get hovered => accent.withValues(alpha: 0.06);
  Color get focused => accent.withValues(alpha: 0.24);
  Color get scrim => CarthaColors.black.withValues(alpha: 0.60);

  Color _container(Color signal) =>
      Color.alphaBlend(signal.withValues(alpha: isDark ? 0.16 : 0.12), card);
  Color get successContainer => _container(success);
  Color get errorContainer => _container(error);
  Color get warningContainer => _container(warning);

  static CarthaPalette of(BuildContext context) =>
      Theme.of(context).extension<CarthaPalette>()!;

  /// The outline of a selectable card or chip: accent ring when selected.
  BorderSide selectionSide(bool selected) => BorderSide(
    color: selected ? borderActive : borderStrong,
    width: selected ? 1.5 : 1,
  );

  factory CarthaPalette.from(CarthaThemeSpec s, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final card = dark ? s.darkCard : s.lightCard;
    final accent = dark ? s.darkAccent : s.lightAccent;
    final background = dark ? s.darkBackground : s.lightBackground;
    return CarthaPalette(
      isDark: dark,
      background: background,
      card: card,
      raised: dark ? s.darkRaised : s.lightRaised,
      raisedHigh: dark ? s.darkRaisedHigh : s.lightRaisedHigh,
      border: dark
          ? s.darkText.withValues(alpha: 0.12)
          : s.lightText.withValues(alpha: 0.10),
      borderStrong: dark ? s.darkBorderStrong : s.lightBorderStrong,
      textPrimary: dark ? s.darkText : s.lightText,
      textSecondary: dark ? s.darkTextSecondary : s.lightTextSecondary,
      accent: accent,
      onAccent: dark ? background : card,
      primary: dark ? s.darkPrimary : s.lightPrimary,
      onPrimary: dark ? background : s.lightOnPrimary,
      hero: s.hero,
      heroRaised: s.heroRaised,
      onHero: s.onHero,
      onHeroMuted: s.onHeroMuted,
      heroAccent: s.heroAccent,
      heroBorder: Color.alphaBlend(
        s.heroAccent.withValues(alpha: 0.35),
        s.hero,
      ),
      emblem: dark ? s.emblemDark : s.emblemLight,
      success: dark ? CarthaColors.successDark : CarthaColors.successLight,
      error: dark ? CarthaColors.errorDark : CarthaColors.errorLight,
      onError: dark ? background : CarthaColors.cream,
      warning: dark ? CarthaColors.warningDark : CarthaColors.warningLight,
      onSuccessContainer: dark
          ? CarthaColors.successDark
          : CarthaColors.onSuccessContainerLight,
      onErrorContainer: dark
          ? CarthaColors.errorDark
          : CarthaColors.onErrorContainerLight,
      onWarningContainer: dark
          ? CarthaColors.warningDark
          : CarthaColors.onWarningContainerLight,
      selection: Color.alphaBlend(
        accent.withValues(alpha: dark ? 0.14 : 0.10),
        card,
      ),
      shadow: CarthaColors.black,
      swatch: s.swatch,
    );
  }

  @override
  CarthaPalette copyWith() => this;

  /// Themes switch instantly; there is nothing meaningful to interpolate.
  @override
  CarthaPalette lerp(CarthaPalette? other, double t) =>
      other == null || t < 0.5 ? this : other;
}

abstract final class CarthaTheme {
  static const radius = 22.0;
  static const radiusLarge = 24.0;
  static const radiusSmall = 16.0;

  /// Native splash / boot background (`flutter_native_splash` uses the same).
  static const bootBackground = CarthaColors.forest;

  /// Android notification accent.
  static const notificationAccent = CarthaColors.bronze;

  static SystemUiOverlayStyle systemUiStyle(Brightness brightness) =>
      (brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
          );

  /// The [ThemeMode] for the user's appearance choice.
  static ThemeMode modeFor(AppearanceMode appearance) => switch (appearance) {
    AppearanceMode.system => ThemeMode.system,
    AppearanceMode.light => ThemeMode.light,
    AppearanceMode.dark => ThemeMode.dark,
  };

  static ThemeData light([AppTheme theme = AppTheme.forest]) =>
      build(theme, Brightness.light);
  static ThemeData dark([AppTheme theme = AppTheme.forest]) =>
      build(theme, Brightness.dark);

  /// The theme for [theme] in [brightness], written in [fonts] (the
  /// language's families: `CarthaFonts.forLanguage`; Latin by default).
  static ThemeData build(
    AppTheme theme,
    Brightness brightness, {
    CarthaFonts fonts = CarthaFonts.latin,
  }) => _build(
    brightness,
    CarthaPalette.from(CarthaThemeSpec.of(theme), brightness),
    fonts,
  );

  /// For a script whose letters join (Arabic): letter spacing 0 on every
  /// style, so Material's own type geometry can't pull letters apart.
  static TextTheme _joinedScript(CarthaFonts fonts, TextTheme t) {
    if (fonts.letterSpacing) return t;
    TextStyle? none(TextStyle? s) => s?.copyWith(letterSpacing: 0);
    return t.copyWith(
      displayLarge: none(t.displayLarge),
      displayMedium: none(t.displayMedium),
      displaySmall: none(t.displaySmall),
      headlineLarge: none(t.headlineLarge),
      headlineMedium: none(t.headlineMedium),
      headlineSmall: none(t.headlineSmall),
      titleLarge: none(t.titleLarge),
      titleMedium: none(t.titleMedium),
      titleSmall: none(t.titleSmall),
      bodyLarge: none(t.bodyLarge),
      bodyMedium: none(t.bodyMedium),
      bodySmall: none(t.bodySmall),
      labelLarge: none(t.labelLarge),
      labelMedium: none(t.labelMedium),
      labelSmall: none(t.labelSmall),
    );
  }

  static ThemeData _build(
    Brightness brightness,
    CarthaPalette p,
    CarthaFonts fonts,
  ) {
    final font = fonts.text;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.selection,
      onPrimaryContainer: p.textPrimary,
      secondary: p.accent,
      onSecondary: p.onAccent,
      secondaryContainer: p.selection,
      onSecondaryContainer: p.accent,
      tertiary: p.textSecondary,
      onTertiary: p.onAccent,
      tertiaryContainer: p.raised,
      onTertiaryContainer: p.textPrimary,
      error: p.error,
      onError: p.onError,
      errorContainer: p.errorContainer,
      onErrorContainer: p.onErrorContainer,
      surface: p.surface,
      onSurface: p.textPrimary,
      onSurfaceVariant: p.textSecondary,
      surfaceDim: p.background,
      surfaceBright: p.raisedHigh,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.card,
      surfaceContainer: p.card,
      surfaceContainerHigh: p.raised,
      surfaceContainerHighest: p.raisedHigh,
      outline: p.borderStrong,
      outlineVariant: p.borderSubtle,
      shadow: p.shadow,
      scrim: p.scrim,
      surfaceTint: Colors.transparent,
      inverseSurface: p.inverseSurface,
      onInverseSurface: p.textInverse,
      inversePrimary: p.heroAccent,
    );

    final base = ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      fontFamily: font,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      disabledColor: p.textDisabled,
      focusColor: p.focused,
      hoverColor: p.hovered,
      splashColor: p.pressed,
      highlightColor: p.pressed,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [p, fonts],
    );
    final text = base.textTheme.apply(
      bodyColor: p.textPrimary,
      displayColor: p.textPrimary,
      fontFamily: font,
    );
    // Cinzel only for display/headline (short brand-voice titles); the
    // language's own family for every style where Cinzel has no letters.
    TextStyle? cinzel(TextStyle? s, {FontWeight weight = FontWeight.w600}) =>
        s?.copyWith(
          fontFamily: fonts.display,
          fontWeight: weight,
          letterSpacing: fonts.spacing(0.4),
          height: fonts.displayHeight,
        );
    const pill = StadiumBorder();
    final buttonText = TextStyle(
      fontFamily: font,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: fonts.spacing(0.2),
    );

    Color? overlay(Set<WidgetState> states) =>
        states.contains(WidgetState.disabled)
        ? Colors.transparent
        : states.contains(WidgetState.pressed)
        ? p.pressed
        : states.contains(WidgetState.focused)
        ? p.focused
        : states.contains(WidgetState.hovered)
        ? p.hovered
        : null;
    WidgetStateProperty<Color?> foreground(Color enabled) =>
        WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled) ? p.textDisabled : enabled,
        );
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      textTheme: _joinedScript(
        fonts,
        text.copyWith(
          displayLarge: cinzel(text.displayLarge, weight: FontWeight.w400),
          displayMedium: cinzel(text.displayMedium, weight: FontWeight.w400),
          displaySmall: cinzel(text.displaySmall),
          headlineLarge: cinzel(text.headlineLarge),
          headlineMedium: cinzel(text.headlineMedium),
          headlineSmall: cinzel(text.headlineSmall),
          titleLarge: text.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: fonts.spacing(-0.2),
          ),
          titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          bodyLarge: text.bodyLarge?.copyWith(height: 1.5),
          bodyMedium: text.bodyMedium?.copyWith(height: 1.45),
          bodySmall: text.bodySmall?.copyWith(color: p.textSecondary),
        ),
      ),
      iconTheme: IconThemeData(color: p.textSecondary),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.selection,
        selectionHandleColor: p.accent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        systemOverlayStyle: systemUiStyle(brightness),
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: p.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: p.divider, thickness: 1, space: 1),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              backgroundColor: p.primary,
              foregroundColor: p.onPrimary,
              disabledBackgroundColor: p.disabledSurface,
              disabledForegroundColor: p.textDisabled,
              minimumSize: const Size(64, 52),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              shape: pill,
              textStyle: buttonText,
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.focused)
                    ? BorderSide(color: p.focus, width: 3)
                    : BorderSide.none,
              ),
            ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 52),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              minimumSize: const Size(64, 52),
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              shape: pill,
              foregroundColor: p.textPrimary,
              disabledForegroundColor: p.textDisabled,
              textStyle: buttonText,
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (s) => BorderSide(
                  color: s.contains(WidgetState.disabled)
                      ? p.borderSubtle
                      : s.contains(WidgetState.focused)
                      ? p.focus
                      : p.borderStrong,
                  width: s.contains(WidgetState.focused) ? 3 : 1,
                ),
              ),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: p.accent,
              disabledForegroundColor: p.textDisabled,
              minimumSize: const Size(48, 48),
              shape: pill,
              textStyle: buttonText.copyWith(fontSize: 15),
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (s) => s.contains(WidgetState.focused)
                    ? BorderSide(color: p.focus, width: 2)
                    : BorderSide.none,
              ),
            ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        focusColor: p.focused,
        elevation: 2,
        highlightElevation: 4,
        shape: const StadiumBorder(),
        extendedTextStyle: buttonText,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.navigation,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.selection,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: font,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? p.accent
                : p.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? p.accent
                : p.textSecondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.input,
        hintStyle: TextStyle(color: p.textPlaceholder),
        labelStyle: TextStyle(color: p.textSecondary),
        helperStyle: TextStyle(color: p.textSecondary),
        errorStyle: TextStyle(color: p.error),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.error)
                ? p.error
                : states.contains(WidgetState.focused)
                ? p.accent
                : p.textSecondary,
          ),
        ),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        contentPadding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: inputBorder(p.borderStrong),
        enabledBorder: inputBorder(p.borderStrong),
        disabledBorder: inputBorder(p.borderSubtle),
        focusedBorder: inputBorder(p.focus, 2),
        errorBorder: inputBorder(p.borderError),
        focusedErrorBorder: inputBorder(p.borderError, 2),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(pill),
          side: WidgetStateProperty.resolveWith(
            (s) => BorderSide(
              color: s.contains(WidgetState.disabled)
                  ? p.borderSubtle
                  : s.contains(WidgetState.focused)
                  ? p.focus
                  : p.borderStrong,
              width: s.contains(WidgetState.focused) ? 2 : 1,
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? p.textDisabled
                : s.contains(WidgetState.selected)
                ? p.accent
                : p.textPrimary,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? p.disabledSurface
                : s.contains(WidgetState.selected)
                ? p.selection
                : p.card,
          ),
          overlayColor: WidgetStateProperty.resolveWith(overlay),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: const StadiumBorder(),
        side: WidgetStateBorderSide.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.disabled)
                ? p.borderSubtle
                : s.contains(WidgetState.focused)
                ? p.focus
                : s.contains(WidgetState.selected)
                ? p.borderActive
                : p.borderStrong,
            width: s.contains(WidgetState.focused) ? 2 : 1,
          ),
        ),
        backgroundColor: p.card,
        selectedColor: p.selection,
        disabledColor: p.disabledSurface,
        checkmarkColor: p.accent,
        iconTheme: IconThemeData(color: p.accent, size: 18),
        labelStyle: TextStyle(
          fontFamily: font,
          fontWeight: FontWeight.w500,
          color: WidgetStateColor.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? p.textDisabled
                : s.contains(WidgetState.selected)
                ? p.accent
                : p.textPrimary,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.dialog,
        modalBackgroundColor: p.dialog,
        modalBarrierColor: p.scrim,
        dragHandleColor: p.textSecondary,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.dialog,
        barrierColor: p.scrim,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 15,
          height: 1.45,
          color: p.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.inverseSurface,
        contentTextStyle: TextStyle(fontFamily: font, color: p.textInverse),
        actionTextColor: p.isDark ? p.hero : p.heroAccent,
        closeIconColor: p.textInverse,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.accent,
        textColor: p.textPrimary,
        subtitleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 13,
          color: p.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent,
        linearTrackColor: p.raisedHigh,
        circularTrackColor: p.raisedHigh,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: foreground(p.textPrimary),
          overlayColor: WidgetStateProperty.resolveWith(overlay),
          side: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.focused)
                ? BorderSide(color: p.focus, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? p.disabledSurface
              : s.contains(WidgetState.selected)
              ? p.accent
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(p.onAccent),
        side: WidgetStateBorderSide.resolveWith(
          (s) => BorderSide(
            color: s.contains(WidgetState.disabled)
                ? p.borderSubtle
                : s.contains(WidgetState.focused)
                ? p.focus
                : p.borderStrong,
            width: 2,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        overlayColor: WidgetStateProperty.resolveWith(overlay),
      ),
      radioTheme: RadioThemeData(
        fillColor: foreground(p.accent),
        overlayColor: WidgetStateProperty.resolveWith(overlay),
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? p.disabledSurface
              : s.contains(WidgetState.selected)
              ? p.accent
              : p.raised,
        ),
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? p.textDisabled
              : s.contains(WidgetState.selected)
              ? p.onAccent
              : p.borderStrong,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? p.borderSubtle
              : s.contains(WidgetState.focused)
              ? p.focus
              : s.contains(WidgetState.selected)
              ? p.accent
              : p.borderStrong,
        ),
        overlayColor: WidgetStateProperty.resolveWith(overlay),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: p.accent,
        inactiveTrackColor: p.borderStrong,
        thumbColor: p.accent,
        overlayColor: p.focused,
        valueIndicatorColor: p.primary,
        valueIndicatorTextStyle: TextStyle(color: p.onPrimary),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.dialog,
        surfaceTintColor: Colors.transparent,
        textStyle: TextStyle(fontFamily: font, color: p.textPrimary),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(p.dialog),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(fontFamily: font, color: p.textInverse),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.dialog,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: p.dialog,
        headerForegroundColor: p.textPrimary,
        dividerColor: p.divider,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: p.dialog,
        dialBackgroundColor: p.card,
        dialHandColor: p.accent,
        dialTextColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onAccent : p.textPrimary,
        ),
        hourMinuteColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.selection : p.card,
        ),
        hourMinuteTextColor: WidgetStateColor.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : p.textPrimary,
        ),
        dayPeriodColor: p.selection,
        dayPeriodTextColor: p.textPrimary,
        entryModeIconColor: p.accent,
      ),
    );
  }
}
