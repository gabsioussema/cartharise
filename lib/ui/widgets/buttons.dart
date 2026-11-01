import 'package:flutter/material.dart';

import '../theme/cartha_theme.dart';
import 'loader.dart';

/// The main action of a screen: a bronze pill (dark) / deep pill (light),
/// like the board's "Next →" / "Get Started →". At most one per view.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    this.busy = false,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final IconData? icon;

  /// E.g. `Icons.arrow_forward` for "Next".
  final IconData? trailingIcon;

  /// Stretch to the available width.
  final bool expand;

  /// Shows the small brand loader ([CarthaLoader], static with reduced
  /// motion) and ignores taps.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: busy ? null : onPressed,
      child: _ButtonContent(
        label: label,
        icon: icon,
        trailingIcon: trailingIcon,
        busy: busy,
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// A secondary action: outlined pill.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      child: _ButtonContent(
        label: label,
        icon: icon,
        trailingIcon: trailingIcon,
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// An irreversible action (e.g. "Delete all data"): an outlined pill in the
/// error colour, with an icon so the meaning is not carried by colour alone.
/// Always pair it with a destructive [confirmDialog].
class DestructiveButton extends StatelessWidget {
  const DestructiveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.delete_forever_outlined,
    this.expand = true,
  });

  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final IconData icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: p.error,
        side: BorderSide(color: onPressed == null ? p.border : p.error),
      ),
      child: _ButtonContent(label: label, icon: icon),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// A quiet action or link, in the accent colour.
class TextLinkButton extends StatelessWidget {
  const TextLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// E.g. `Icons.open_in_new` for external links.
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    child: _ButtonContent(label: label, icon: icon, trailingIcon: trailingIcon),
  );
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.icon,
    this.trailingIcon,
    this.busy = false,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (busy) ...[
            // The brand loader honours reduced motion and Settings › Motion.
            CarthaLoader(
              key: const ValueKey('button-busy'),
              size: 20,
              color: color,
              sparkColor: color,
            ),
            const SizedBox(width: 10),
          ] else if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(label, textAlign: TextAlign.center, softWrap: true),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, size: 20),
          ],
        ],
      ),
    );
  }
}
