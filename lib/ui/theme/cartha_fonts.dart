import 'package:flutter/material.dart';

import '../../domain/language.dart';

/// The font families for one language (step 3), carried by the theme as a
/// [ThemeExtension] (`CarthaFonts.of(context)`).
///
/// * Latin languages (English, French): Cinzel for display/headline (short
///   brand-voice titles), Inter for everything else.
/// * Arabic: one Arabic family for **every** style, display and headline
///   included — Cinzel has no Arabic letters and is never used for Arabic —
///   and no added letter spacing (it would pull joined letters apart).
@immutable
class CarthaFonts extends ThemeExtension<CarthaFonts> {
  const CarthaFonts({
    required this.text,
    required this.display,
    this.letterSpacing = true,
    this.displayHeight = 1.2,
  });

  /// The bundled Latin families (assets/fonts, OFL).
  static const String inter = 'Inter';
  static const String cinzel = 'Cinzel';

  /// The bundled Arabic family (OFL), declared in pubspec.yaml by the
  /// languages agent. Null until then: Arabic falls back to [inter], whose
  /// missing Arabic letters the phone draws with its own Arabic font.
  static const String? arabicFamily = null;

  /// English and French.
  static const CarthaFonts latin = CarthaFonts(text: inter, display: cinzel);

  /// The fonts for a resolved [language]. Arabic uses [arabic] (default
  /// [arabicFamily]; null → [inter]) for every style.
  static CarthaFonts forLanguage(
    AppLanguage language, {
    String? arabic = arabicFamily,
  }) => switch (language) {
    AppLanguage.ar => CarthaFonts(
      text: arabic ?? inter,
      display: arabic ?? inter,
      letterSpacing: false,
      displayHeight: null,
    ),
    AppLanguage.system || AppLanguage.en || AppLanguage.fr => latin,
  };

  /// The fonts of the current theme ([latin] when the theme has none).
  static CarthaFonts of(BuildContext context) =>
      Theme.of(context).extension<CarthaFonts>() ?? latin;

  /// Every text style except display and headline.
  final String text;

  /// Display and headline styles.
  final String display;

  /// False for scripts whose letters join (Arabic): every added letter
  /// spacing becomes 0 — use [spacing] for a local `letterSpacing`.
  final bool letterSpacing;

  /// Line height of display/headline styles; null leaves it to Material's
  /// type geometry for the script (taller for Arabic, whose marks need
  /// room).
  final double? displayHeight;

  /// [value] where added letter spacing suits the script, else 0.
  double spacing(double value) => letterSpacing ? value : 0;

  @override
  CarthaFonts copyWith({
    String? text,
    String? display,
    bool? letterSpacing,
    double? Function()? displayHeight,
  }) => CarthaFonts(
    text: text ?? this.text,
    display: display ?? this.display,
    letterSpacing: letterSpacing ?? this.letterSpacing,
    displayHeight: displayHeight != null ? displayHeight() : this.displayHeight,
  );

  /// Families don't blend: the theme switches at the halfway point.
  @override
  CarthaFonts lerp(covariant CarthaFonts? other, double t) =>
      other == null || t < 0.5 ? this : other;

  @override
  bool operator ==(Object other) =>
      other is CarthaFonts &&
      other.text == text &&
      other.display == display &&
      other.letterSpacing == letterSpacing &&
      other.displayHeight == displayHeight;

  @override
  int get hashCode => Object.hash(text, display, letterSpacing, displayHeight);
}
