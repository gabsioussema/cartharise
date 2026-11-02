import 'package:flutter/material.dart';

import '../theme/cartha_theme.dart';

/// One segment of [PillTabs].
class PillTab<T> {
  const PillTab({required this.value, required this.label, this.icon});
  final T value;
  final String label;
  final IconData? icon;
}

/// A segmented pill control (the board's "Week · Month · Year"): the
/// selected segment is a filled pill. Selection is announced, not shown by
/// colour alone (the selected pill is also bold and filled). Every segment
/// is at least 48 dp tall (Android / Material tap-target guideline).
///
/// Words are never broken: while every word of every label fits its
/// segment the pills share one row (a label may wrap between words); when
/// one doesn't (a small phone at large text, longer words in another
/// language) the pills stack, one per line, each as wide as the control.
/// Breaking inside a word would be unreadable, and in Arabic it would also
/// sever the joined letters.
class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onChanged,
  });

  final List<PillTab<T>> tabs;
  final T selected;
  final ValueChanged<T> onChanged;

  /// The control's own padding (4) plus its border (1), on each side.
  static const double _inset = 5;

  /// A segment's horizontal padding, on each side.
  static const double _segmentPadding = 10;

  /// An icon (18) and the gap after it (6).
  static const double _iconWidth = 24;

  /// Whether the widest word of each label fits its share of [width] on
  /// one row. Measured bold (the selected weight, the wider one) so
  /// choosing a pill never changes the layout.
  bool _wordsFitOneRow(BuildContext context, double width, TextStyle style) {
    if (tabs.isEmpty) return true;
    final segment = (width - 2 * _inset) / tabs.length - 2 * _segmentPadding;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final locale = Localizations.maybeLocaleOf(context);
    for (final tab in tabs) {
      final room = segment - (tab.icon == null ? 0 : _iconWidth);
      for (final word in tab.label.split(RegExp(r'\s+'))) {
        if (word.isEmpty) continue;
        final painter = TextPainter(
          text: TextSpan(text: word, style: style),
          textDirection: direction,
          textScaler: scaler,
          locale: locale,
          maxLines: 1,
        )..layout();
        final wide = painter.width.ceilToDouble() > room;
        painter.dispose();
        if (wide) return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final text = theme.textTheme.labelLarge;
    return LayoutBuilder(
      builder: (context, constraints) {
        // As the segment's Text sees it: Material's default style, then
        // the label style, bold.
        final measured = (theme.textTheme.bodyMedium ?? const TextStyle())
            .merge(text)
            .copyWith(fontWeight: FontWeight.w700);
        final stacked =
            constraints.hasBoundedWidth &&
            !_wordsFitOneRow(context, constraints.maxWidth, measured);
        Widget segment(PillTab<T> tab) => _Segment(
          label: tab.label,
          icon: tab.icon,
          selected: tab.value == selected,
          onTap: () => onChanged(tab.value),
          style: text,
        );
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: p.raised,
            borderRadius: BorderRadius.circular(stacked ? 28 : 999),
            border: Border.all(color: p.border),
          ),
          child: stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final tab in tabs) segment(tab)],
                )
              : Row(
                  children: [
                    for (final tab in tabs) Expanded(child: segment(tab)),
                  ],
                ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.style,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final fg = selected ? p.onPrimary : p.textPrimary;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? p.primary : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: PillTabs._segmentPadding,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: style?.copyWith(
                        color: fg,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
