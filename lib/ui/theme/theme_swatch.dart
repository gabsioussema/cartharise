import 'package:flutter/material.dart';

import '../../domain/app_data.dart';
import 'cartha_theme.dart';
import 'cartha_theme_spec.dart';

/// A round preview of [theme] — its hero colour with the bronze accent — for
/// the theme picker. Lives in the theme folder because it shows another
/// theme's raw colours.
class ThemeSwatch extends StatelessWidget {
  const ThemeSwatch({
    super.key,
    required this.theme,
    required this.selected,
    this.size = 52,
  });

  final AppTheme theme;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final spec = CarthaThemeSpec.of(theme);
    final current = CarthaPalette.of(context);
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? current.borderActive : current.borderStrong,
          width: selected ? 2.5 : 1,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: spec.swatch),
        child: Center(
          child: Container(
            width: size * 0.42,
            height: size * 0.42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spec.heroAccent,
            ),
            child: selected
                ? Icon(Icons.check, size: size * 0.28, color: spec.hero)
                : null,
          ),
        ),
      ),
    );
  }
}
