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
    // Forest (default): deep forest surfaces, bronze emblem and accents.
    AppTheme.forest: CarthaThemeSpec(
      hero: Color(0xFF1E3328),
      heroRaised: Color(0xFF24392D),
      onHeroMuted: Color(0xFFB9C6B8),
      heroAccent: Color(0xFFD4B57B),
      darkBackground: Color(0xFF17261E),
      darkCard: Color(0xFF1E3328),
      darkRaised: Color(0xFF24392D),
      darkRaisedHigh: Color(0xFF2B4235),
      darkTextSecondary: Color(0xFFB9C6B8),
      darkAccent: Color(0xFFD4B57B),
      darkBorderStrong: Color(0xFF7F9285),
      lightBackground: Color(0xFFF7F4EC),
      lightCard: Color(0xFFFFFDF8),
      lightRaised: Color(0xFFEFE9DB),
      lightRaisedHigh: Color(0xFFE7E0CF),
      lightText: Color(0xFF1E3328),
      lightTextSecondary: Color(0xFF4A5A50),
      lightAccent: Color(0xFF7A5C30),
      lightBorderStrong: Color(0xFF6B7A70),
      lightPrimary: Color(0xFF1E3328),
      swatch: Color(0xFF1E3328),
    ),
    // Olive: military-olive heroes, sage accents on dark, olive on light.
    AppTheme.olive: CarthaThemeSpec(
      hero: Color(0xFF3F4619),
      heroRaised: Color(0xFF454C1D),
      onHeroMuted: Color(0xFFC9CDB6),
      heroAccent: Color(0xFFD4B57B),
      darkBackground: Color(0xFF181B0F),
      darkCard: Color(0xFF21251A),
      darkRaised: Color(0xFF282D1F),
      darkRaisedHigh: Color(0xFF303626),
      darkTextSecondary: Color(0xFFBFC4AE),
      darkAccent: Color(0xFFC3CBA6),
      darkBorderStrong: Color(0xFF858C72),
      lightBackground: Color(0xFFF6F5EC),
      lightCard: Color(0xFFFFFEF8),
      lightRaised: Color(0xFFEEECDD),
      lightRaisedHigh: Color(0xFFE6E3D0),
      lightText: Color(0xFF262A12),
      lightTextSecondary: Color(0xFF4F5539),
      lightAccent: Color(0xFF4B5320),
      lightBorderStrong: Color(0xFF6E745A),
      lightPrimary: Color(0xFF4B5320),
      swatch: Color(0xFF4B5320),
    ),
  };
}
