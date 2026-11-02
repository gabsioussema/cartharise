import 'package:flutter/material.dart';

import '../theme/cartha_theme.dart';
import 'glyphs.dart';

/// A screen's title block: Cinzel title (short!) + Inter subtitle, like the
/// board's "Good morning, Traveler. / Clarity today. Progress tomorrow."
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 12),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: theme.textTheme.headlineSmall),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

enum ChipTone { neutral, accent, success, warning }

/// A small, non-interactive label ("Optional", "11:00", "Answered"). Pair
/// colour with text/icon — never colour alone.
class ChipTag extends StatelessWidget {
  const ChipTag({
    super.key,
    required this.label,
    this.icon,
    this.glyph,
    this.tone = ChipTone.neutral,
  }) : assert(icon == null || glyph == null, 'An icon or a glyph, not both');

  final String label;
  final IconData? icon;

  /// A painted glyph instead of [icon], for a label that names one of the
  /// visual system's ideas (e.g. an experiment's seedling).
  final CarthaGlyph? glyph;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final (bg, fg) = switch (tone) {
      ChipTone.neutral => (p.raised, p.textSecondary),
      ChipTone.accent => (p.selection, p.accent),
      ChipTone.success => (p.successContainer, p.onSuccessContainer),
      ChipTone.warning => (p.warningContainer, p.onWarningContainer),
    };
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (glyph != null) ...[
            GlyphIcon(glyph!, size: 16, color: fg),
            const SizedBox(width: 4),
          ] else if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
