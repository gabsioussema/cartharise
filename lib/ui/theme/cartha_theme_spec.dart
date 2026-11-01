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
  };
}
