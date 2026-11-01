import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';

/// True when interface motion may play: the device doesn't ask for reduced
/// motion and Settings › Motion is on.
bool motionEnabled(BuildContext context) {
  final device = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final setting =
      Provider.of<AppState?>(context, listen: false)?.settings.motion ?? true;
  return !device && setting;
}

/// Brief spatial continuity when [page] changes (tab switches, steps):
/// a short fade + rise. Nothing moves when motion is off.
class CarthaPageMotion extends StatefulWidget {
  const CarthaPageMotion({super.key, required this.page, required this.child});

  final Object page;
  final Widget child;

  @override
  State<CarthaPageMotion> createState() => _CarthaPageMotionState();
}

class _CarthaPageMotionState extends State<CarthaPageMotion>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutQuart,
  );

  @override
  void didUpdateWidget(CarthaPageMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      if (motionEnabled(context)) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final setting = context.select<AppState?, bool>(
      (s) => s?.settings.motion ?? true,
    );
    if (device || !setting) return widget.child;
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, .02),
          end: Offset.zero,
        ).animate(_curve),
        child: widget.child,
      ),
    );
  }
}
