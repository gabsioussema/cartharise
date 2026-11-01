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
/// selected segment is a filled pill. Labels wrap instead of clipping at
/// large text sizes. Selection is announced, not shown by colour alone
/// (the selected pill is also bold and filled). Every segment is at least
/// 48 dp tall (Android / Material tap-target guideline).
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

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final text = Theme.of(context).textTheme.labelLarge;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.raised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.border),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: _Segment(
                label: tab.label,
                icon: tab.icon,
                selected: tab.value == selected,
                onTap: () => onChanged(tab.value),
                style: text,
              ),
            ),
        ],
      ),
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
                horizontal: 10,
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
