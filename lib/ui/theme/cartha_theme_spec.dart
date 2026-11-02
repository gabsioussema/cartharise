import 'package:flutter/material.dart';

import '../../domain/app_data.dart';

/// The raw colours that define one app theme ("Carthage Dusk"), for both
/// brightnesses. Everything the UI uses is derived from these by
/// [CarthaPalette.from] — screens never see a spec or a raw colour. To add a
/// theme: add an [AppTheme] value and an entry below, then run
/// `test/color_system_test.dart` (every pair is contrast-checked).
@immutable
class CarthaThemeSpec {
  const CarthaThemeSpec({
    required this.hero,
    required this.heroRaised,
    required this.onHeroMuted,
    required this.heroAccent,
    required this.darkBackground,
    required this.darkCard,
    required this.darkRaised,
    required this.darkRaisedHigh,
    required this.darkTextSecondary,
    required this.darkAccent,
    required this.darkBorderStrong,
    required this.lightBackground,
    required this.lightCard,
    required this.lightRaised,
    required this.lightRaisedHigh,
    required this.lightText,
    required this.lightTextSecondary,
    required this.lightAccent,
    required this.lightBorderStrong,
    required this.lightPrimary,
    required this.swatch,
    this.onHero = const Color(0xFFF1EBDD),
    this.darkText = const Color(0xFFF1EBDD),
    this.darkPrimary = const Color(0xFFB08D57),
    this.lightOnPrimary = const Color(0xFFF1EBDD),
    this.emblemDark = const Color(0xFFB08D57),
    this.emblemLight = const Color(0xFF9B7847),
  });

  /// Deep "hero" surface used in BOTH brightnesses (board style): hero cards,
  /// the boot screen, onboarding.
  final Color hero;
  final Color heroRaised;
  final Color onHero;
  final Color onHeroMuted;

  /// Bronze for icons, the emblem and links on [hero].
  final Color heroAccent;

  final Color darkBackground;
  final Color darkCard;
  final Color darkRaised;
  final Color darkRaisedHigh;
  final Color darkText;
  final Color darkTextSecondary;
  final Color darkAccent;
  final Color darkBorderStrong;

  /// Main buttons in dark mode (antique bronze pill, deep text).
  final Color darkPrimary;

  final Color lightBackground;
  final Color lightCard;
  final Color lightRaised;
  final Color lightRaisedHigh;
  final Color lightText;
  final Color lightTextSecondary;
  final Color lightAccent;
  final Color lightBorderStrong;

  /// Main buttons in light mode (deep pill, ivory text).
  final Color lightPrimary;
  final Color lightOnPrimary;

  final Color emblemDark;
  final Color emblemLight;

  /// Signature colour shown in the theme picker.
  final Color swatch;

  static CarthaThemeSpec of(AppTheme theme) => _specs[theme]!;

  static const _specs = {
    // Forest (default): calm charcoal surfaces with a trace of forest, so the
    // forest hero cards, bronze emblem and accents carry the brand (≈10 %).
    AppTheme.forest: CarthaThemeSpec(
      hero: Color(0xFF1E3328),
      heroRaised: Color(0xFF24392D),
      onHeroMuted: Color(0xFFB9C6B8),
      heroAccent: Color(0xFFD4B57B),
      darkBackground: Color(0xFF151716),
      darkCard: Color(0xFF1C1F1D),
      darkRaised: Color(0xFF242826),
      darkRaisedHigh: Color(0xFF2D322F),
      darkTextSecondary: Color(0xFFBDB9AF),
      darkAccent: Color(0xFFD4B57B),
      darkBorderStrong: Color(0xFF7E837F),
      lightBackground: Color(0xFFF7F4EC),
      lightCard: Color(0xFFFFFDF8),
      lightRaised: Color(0xFFEFE9DB),
      lightRaisedHigh: Color(0xFFE7E0CF),
      lightText: Color(0xFF1D2420),
      lightTextSecondary: Color(0xFF54554F),
      lightAccent: Color(0xFF7A5C30),
      lightBorderStrong: Color(0xFF75766F),
      lightPrimary: Color(0xFF1E3328),
      swatch: Color(0xFF1E3328),
    ),
    // Olive: calm neutral surfaces, military-olive heroes, sage accents on
    // dark, olive on light.
    AppTheme.olive: CarthaThemeSpec(
      hero: Color(0xFF3F4619),
      heroRaised: Color(0xFF454C1D),
      onHeroMuted: Color(0xFFC9CDB6),
      heroAccent: Color(0xFFD4B57B),
      darkBackground: Color(0xFF161714),
      darkCard: Color(0xFF1E1F1B),
      darkRaised: Color(0xFF262723),
      darkRaisedHigh: Color(0xFF2F302B),
      darkTextSecondary: Color(0xFFC0BDB0),
      darkAccent: Color(0xFFC3CBA6),
      darkBorderStrong: Color(0xFF84847B),
      lightBackground: Color(0xFFF6F5EC),
      lightCard: Color(0xFFFFFEF8),
      lightRaised: Color(0xFFEEECDD),
      lightRaisedHigh: Color(0xFFE6E3D0),
      lightText: Color(0xFF262A12),
      lightTextSecondary: Color(0xFF57564C),
      lightAccent: Color(0xFF4B5320),
      lightBorderStrong: Color(0xFF77766C),
      lightPrimary: Color(0xFF4B5320),
      swatch: Color(0xFF4B5320),
    ),
    // Oasis: palm-shade teal heroes with date gold; mint accents and pill on
    // dark, a faint mint paper on light.
    AppTheme.oasis: CarthaThemeSpec(
      hero: Color(0xFF0F4A40),
      heroRaised: Color(0xFF145247),
      onHeroMuted: Color(0xFFB5D3C9),
      heroAccent: Color(0xFFE6C47E),
      darkBackground: Color(0xFF111816),
      darkCard: Color(0xFF18201D),
      darkRaised: Color(0xFF1F2825),
      darkRaisedHigh: Color(0xFF27312D),
      darkTextSecondary: Color(0xFFB5C2BC),
      darkAccent: Color(0xFF7FD1B9),
      darkBorderStrong: Color(0xFF7A8782),
      darkPrimary: Color(0xFF7FD1B9),
      lightBackground: Color(0xFFF3F8F5),
      lightCard: Color(0xFFFCFEFD),
      lightRaised: Color(0xFFE6F0EB),
      lightRaisedHigh: Color(0xFFDAE8E1),
      lightText: Color(0xFF13221D),
      lightTextSecondary: Color(0xFF4B5A54),
      lightAccent: Color(0xFF1B6B5A),
      lightBorderStrong: Color(0xFF6E7C76),
      lightPrimary: Color(0xFF0F4A40),
      swatch: Color(0xFF14705F),
    ),
    // Tyrian Rose: the murex dye of Tyre, Carthage's mother city. Wine
    // heroes with a soft rose glow; plum-charcoal on dark, blush on light.
    AppTheme.tyrian: CarthaThemeSpec(
      hero: Color(0xFF4C1D35),
      heroRaised: Color(0xFF56233D),
      onHeroMuted: Color(0xFFD8BFCA),
      heroAccent: Color(0xFFF2B8CB),
      darkBackground: Color(0xFF1A1417),
      darkCard: Color(0xFF221A1E),
      darkRaised: Color(0xFF2B2126),
      darkRaisedHigh: Color(0xFF34292F),
      darkTextSecondary: Color(0xFFC9BAC0),
      darkAccent: Color(0xFFEFA7C2),
      darkBorderStrong: Color(0xFF8C7E84),
      darkPrimary: Color(0xFFEFA7C2),
      lightBackground: Color(0xFFFBF3F5),
      lightCard: Color(0xFFFFFBFC),
      lightRaised: Color(0xFFF5E7EB),
      lightRaisedHigh: Color(0xFFEEDCE2),
      lightText: Color(0xFF2B1820),
      lightTextSecondary: Color(0xFF5E4A53),
      lightAccent: Color(0xFF9A2F5C),
      lightBorderStrong: Color(0xFF7E6E75),
      lightPrimary: Color(0xFF4C1D35),
      swatch: Color(0xFFC2557F),
    ),
    // Alpine: granite and snow of Hannibal's crossing. Slate heroes with
    // bronze; graphite on dark with a silver pill, snow grey on light.
    AppTheme.alpine: CarthaThemeSpec(
      hero: Color(0xFF2F363D),
      heroRaised: Color(0xFF363E46),
      onHeroMuted: Color(0xFFC3CBD2),
      heroAccent: Color(0xFFD4B57B),
      darkBackground: Color(0xFF16181A),
      darkCard: Color(0xFF1D2023),
      darkRaised: Color(0xFF25292C),
      darkRaisedHigh: Color(0xFF2E3236),
      darkTextSecondary: Color(0xFFBAC0C6),
      darkAccent: Color(0xFFB9C7D4),
      darkBorderStrong: Color(0xFF80878E),
      darkPrimary: Color(0xFFC9D2DA),
      lightBackground: Color(0xFFF2F3F5),
      lightCard: Color(0xFFFDFDFE),
      lightRaised: Color(0xFFE7E9EC),
      lightRaisedHigh: Color(0xFFDDE0E4),
      lightText: Color(0xFF1B1F23),
      lightTextSecondary: Color(0xFF50565C),
      lightAccent: Color(0xFF3E4C5A),
      lightBorderStrong: Color(0xFF737A81),
      lightPrimary: Color(0xFF2F363D),
      swatch: Color(0xFF7D868F),
    ),
    // Obsidian: volcanic glass and gold. True black on dark (kind to OLED
    // screens), black heroes and buttons on a warm white.
    AppTheme.obsidian: CarthaThemeSpec(
      hero: Color(0xFF141414),
      heroRaised: Color(0xFF1C1C1C),
      onHeroMuted: Color(0xFFC4C0B6),
      heroAccent: Color(0xFFD4B57B),
      darkBackground: Color(0xFF000000),
      darkCard: Color(0xFF0E0E0E),
      darkRaised: Color(0xFF171717),
      darkRaisedHigh: Color(0xFF202020),
      darkTextSecondary: Color(0xFFB8B4AB),
      darkAccent: Color(0xFFD4B57B),
      darkBorderStrong: Color(0xFF7A7772),
      darkPrimary: Color(0xFFD4B57B),
      lightBackground: Color(0xFFF4F3F0),
      lightCard: Color(0xFFFFFFFF),
      lightRaised: Color(0xFFEAE8E3),
      lightRaisedHigh: Color(0xFFE5E3DD),
      lightText: Color(0xFF111111),
      lightTextSecondary: Color(0xFF4F4D48),
      lightAccent: Color(0xFF7A5C30),
      lightBorderStrong: Color(0xFF72706B),
      lightPrimary: Color(0xFF141414),
      swatch: Color(0xFF0A0A0A),
    ),
  };
}
