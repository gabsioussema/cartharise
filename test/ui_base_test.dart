import 'dart:io';

import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/theme/cartha_theme_spec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UI base guard', () {
    // Every screen and widget takes colours from CarthaPalette (the UI base),
    // so a theme change reaches the whole app. Only lib/ui/theme/ may define
    // colours.
    final forbidden = <String, RegExp>{
      'raw Color literal': RegExp(
        r'Color\s*\(\s*(?:0x|[0-9])|Color\.fromARGB|Color\.fromRGBO',
      ),
      'Material Colors (use a palette token)': RegExp(
        r'\bColors\.(?!transparent\b)\w+',
      ),
      'CarthaColors (theme-internal)': RegExp(r'\bCarthaColors\b'),
      'theme spec (theme-internal)': RegExp(r'\bCarthaThemeSpec\b'),
    };

    final files = Directory('lib/ui')
        .listSync(recursive: true)
        .whereType<File>()
        .where(
          (f) =>
              f.path.endsWith('.dart') &&
              !f.path.contains(
                '${Platform.pathSeparator}theme${Platform.pathSeparator}',
              ),
        );

    test('lib/ui outside theme/ uses only palette tokens', () {
      final violations = <String>[];
      for (final f in files) {
        final lines = f.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.trimLeft().startsWith('//')) continue;
          for (final MapEntry(key: what, value: re) in forbidden.entries) {
            if (re.hasMatch(line)) {
              violations.add('${f.path}:${i + 1}  $what\n    ${line.trim()}');
            }
          }
        }
      }
      expect(
        violations,
        isEmpty,
        reason:
            'Use CarthaPalette.of(context) tokens instead:\n${violations.join('\n')}',
      );
    });

    test('the guard itself catches violations', () {
      const samples = [
        'color: Color(0xFF123456),',
        'color: Colors.red,',
        'CarthaColors.bronze',
        'CarthaThemeSpec.of(theme)',
        'Color.fromARGB(255, 1, 2, 3)',
      ];
      for (final s in samples) {
        expect(forbidden.values.any((re) => re.hasMatch(s)), isTrue, reason: s);
      }
      expect(
        forbidden.values.any((re) => re.hasMatch('Colors.transparent')),
        isFalse,
      );
    });
  });

  group('themes', () {
    for (final theme in AppTheme.values) {
      for (final brightness in Brightness.values) {
        testWidgets(
          '${theme.name} ${brightness.name}: builds a full ThemeData',
          (tester) async {
            final data = CarthaTheme.build(theme, brightness);
            final p = data.extension<CarthaPalette>()!;
            expect(data.brightness, brightness);
            expect(p.isDark, brightness == Brightness.dark);
            // Cinzel only for display/headline, Inter for everything else.
            expect(data.textTheme.headlineSmall?.fontFamily, 'Cinzel');
            expect(data.textTheme.displaySmall?.fontFamily, 'Cinzel');
            expect(data.textTheme.bodyMedium?.fontFamily, 'Inter');
            expect(data.textTheme.titleMedium?.fontFamily, 'Inter');
            expect(data.textTheme.labelLarge?.fontFamily, 'Inter');
            // Board style: pill main buttons in the primary token.
            final filled = data.filledButtonTheme.style!;
            expect(filled.shape?.resolve({}), isA<StadiumBorder>());
            expect(filled.backgroundColor?.resolve({}), p.primary);
            expect(filled.foregroundColor?.resolve({}), p.onPrimary);
            // Hero surfaces are deep in both brightnesses.
            expect(p.hero.computeLuminance(), lessThan(0.1));
            await tester.pumpWidget(
              MaterialApp(
                theme: data,
                home: const Scaffold(body: Text('ok')),
              ),
            );
            expect(find.text('ok'), findsOneWidget);
          },
        );
      }
    }

    test('dark Forest: calm neutral surfaces, forest heroes, bronze buttons, '
        'ivory text', () {
      final p = CarthaPalette.from(
        CarthaThemeSpec.of(AppTheme.forest),
        Brightness.dark,
      );
      // The brand colour is kept for heroes and accents (≈10 %); the
      // surfaces around them stay close to neutral so the app isn't green.
      for (final surface in [p.background, p.card, p.raised]) {
        expect(
          HSLColor.fromColor(surface).saturation,
          lessThan(0.12),
          reason: '$surface',
        );
      }
      expect(p.hero, CarthaColors.forest);
      expect(p.primary, CarthaColors.bronze);
      expect(p.textPrimary, CarthaColors.ivory);
      expect(p.accent, CarthaColors.lightBronze);
      expect(p.emblem, CarthaColors.bronze);
    });

    test('appearance setting maps to ThemeMode', () {
      expect(CarthaTheme.modeFor(AppearanceMode.system), ThemeMode.system);
      expect(CarthaTheme.modeFor(AppearanceMode.light), ThemeMode.light);
      expect(CarthaTheme.modeFor(AppearanceMode.dark), ThemeMode.dark);
    });
  });
}
