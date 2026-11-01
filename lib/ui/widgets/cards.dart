import 'package:flutter/material.dart';

import '../theme/cartha_theme.dart';

/// A rounded card section (radius 22, thin border, flat). Tappable when
/// [onTap] is set (then announced as a button).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(20),
    this.semanticLabel,
  });

  final Widget child;

  /// Optional heading row (Inter titleMedium).
  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || icon != null || trailing != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: p.accent, size: 22),
                  const SizedBox(width: 12),
                ],
                if (title != null)
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(title!, style: theme.textTheme.titleMedium),
                    ),
                  )
                else
                  const Spacer(),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(CarthaTheme.radius),
      side: BorderSide(color: p.border),
    );
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: p.card,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

/// The board's deep forest (or olive) hero surface, in both brightnesses:
/// greeting cards, "Your Journey", lesson heroes. Text inside defaults to
/// `onHero`, icons to `heroAccent`.
class HeroCard extends StatelessWidget {
  const HeroCard({
    super.key,
    required this.child,
    this.eyebrow,
    this.title,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsetsDirectional.all(20),
    this.semanticLabel,
  });

  final Widget child;

  /// Small uppercase label above the title (bronze, tracking-wide).
  final String? eyebrow;

  /// Cinzel title (keep it short).
  final String? title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (eyebrow != null || title != null || trailing != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null)
                        Text(
                          eyebrow!.toUpperCase(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: p.heroAccent,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (eyebrow != null && title != null)
                        const SizedBox(height: 6),
                      if (title != null)
                        Semantics(
                          header: true,
                          child: Text(
                            title!,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: p.onHero,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(CarthaTheme.radiusLarge),
      side: BorderSide(color: p.heroBorder),
    );
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: p.hero,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: p.onHero),
          child: IconTheme.merge(
            data: IconThemeData(color: p.heroAccent),
            child: onTap == null
                ? content
                : InkWell(
                    onTap: onTap,
                    splashColor: p.heroAccent.withValues(alpha: 0.12),
                    highlightColor: p.heroAccent.withValues(alpha: 0.08),
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}
