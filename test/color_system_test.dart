import 'dart:math' as math;

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.2 contrast after compositing a (possibly translucent) foreground
/// over its surface.
double contrast(Color foreground, Color background) {
  final a = Color.alphaBlend(foreground, background).computeLuminance();
  final b = background.computeLuminance();
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05);
}

String hex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

/// Every theme × brightness: 4.5:1 for text, 3:1 for meaningful controls and
/// graphics (WCAG 2.2 AA, PLAN.md §3).
void main() {
  for (final theme in AppTheme.values) {
    for (final brightness in Brightness.values) {
      final p = CarthaTheme.build(
        theme,
        brightness,
      ).extension<CarthaPalette>()!;
      final name = '${theme.name} ${brightness.name}';
      final surfaces = {
        'background': p.background,
        'card': p.card,
        'raised': p.raised,
        'raisedHigh': p.raisedHigh,
        'selection': p.selection,
      };

      void pair(String label, Color fg, Color bg, double minimum) {
        final ratio = contrast(fg, bg);
        expect(
          ratio,
          greaterThanOrEqualTo(minimum),
          reason:
              '$name: $label ${hex(fg)} on ${hex(bg)} = ${ratio.toStringAsFixed(2)}',
        );
      }

      test('$name: text is readable on every surface (4.5:1)', () {
        for (final MapEntry(key: s, value: bg) in surfaces.entries) {
          pair('textPrimary on $s', p.textPrimary, bg, 4.5);
          pair('textSecondary on $s', p.textSecondary, bg, 4.5);
          pair('accent on $s', p.accent, bg, 4.5);
          pair('error on $s', p.error, bg, 4.5);
          pair('success on $s', p.success, bg, 4.5);
          pair('warning on $s', p.warning, bg, 4.5);
        }
        pair('onPrimary on primary', p.onPrimary, p.primary, 4.5);
        pair('onAccent on accent', p.onAccent, p.accent, 4.5);
        pair('onError on error', p.onError, p.error, 4.5);
        pair(
          'textInverse on inverseSurface',
          p.textInverse,
          p.inverseSurface,
          4.5,
        );
        pair(
          'onSuccessContainer',
          p.onSuccessContainer,
          p.successContainer,
          4.5,
        );
        pair('onErrorContainer', p.onErrorContainer, p.errorContainer, 4.5);
        pair(
          'onWarningContainer',
          p.onWarningContainer,
          p.warningContainer,
          4.5,
        );
        pair(
          'textPrimary on errorContainer',
          p.textPrimary,
          p.errorContainer,
          4.5,
        );
      });

      test('$name: hero surfaces are readable (4.5:1)', () {
        for (final MapEntry(key: s, value: bg) in {
          'hero': p.hero,
          'heroRaised': p.heroRaised,
        }.entries) {
          pair('onHero on $s', p.onHero, bg, 4.5);
          pair('onHeroMuted on $s', p.onHeroMuted, bg, 4.5);
          pair('heroAccent on $s', p.heroAccent, bg, 4.5);
        }
      });

      test('$name: controls and graphics stand out (3:1)', () {
        for (final MapEntry(key: s, value: bg) in surfaces.entries) {
          if (s == 'selection') continue;
          pair('borderStrong on $s', p.borderStrong, bg, 3);
          pair('focus on $s', p.focus, bg, 3);
          pair('emblem on $s', p.emblem, bg, 3);
        }
        pair('primary button on background', p.primary, p.background, 3);
        pair('heroBorder… emblem on hero', p.heroAccent, p.hero, 3);
      });
    }
  }
}
