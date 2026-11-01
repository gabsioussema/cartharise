import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/widgets.dart';
import 'avatar_view.dart';
import 'builder_categories.dart';

/// The live preview on top of the builder: the draft as a large portrait on
/// the hero surface, with "Surprise me" under it.
class BuilderPreview extends StatelessWidget {
  const BuilderPreview({
    super.key,
    required this.avatar,
    required this.onSurprise,
  });

  final Avatar avatar;
  final VoidCallback onSurprise;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return HeroCard(
      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 8),
      child: OnHeroTheme(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = (constraints.maxWidth * 0.45).clamp(96.0, 200.0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarView(
                  key: const ValueKey('persona-preview'),
                  avatar: avatar,
                  size: math.min(size, constraints.maxWidth),
                  semanticLabel: previewDescription(l, avatar),
                ),
                const SizedBox(height: 4),
                TextLinkButton(
                  key: const ValueKey('persona-surprise'),
                  label: l.personaBuilderSurprise,
                  icon: Icons.shuffle,
                  onPressed: onSurprise,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The categories as one row of short, scrollable choice chips (Skin, Face,
/// Hair … Banner). The chip shows its selected state with a check.
///
/// The row runs to the screen edges, with [padding] (the page gutter)
/// inside the scroll view, so a chip scrolled part-way is cut at the edge of
/// the screen, never in the middle of the page. A newly selected chip is
/// scrolled fully into view (sideways only).
class BuilderCategoryBar extends StatefulWidget {
  const BuilderCategoryBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.padding = 0,
  });

  final BuilderCategory selected;
  final ValueChanged<BuilderCategory> onChanged;

  /// Space before the first chip and after the last one.
  final double padding;

  @override
  State<BuilderCategoryBar> createState() => _BuilderCategoryBarState();
}

class _BuilderCategoryBarState extends State<BuilderCategoryBar> {
  /// How long a chip takes to grow or shrink its check mark (Material's
  /// select animation, a little under this): the row is measured after.
  static const _settle = Duration(milliseconds: 220);

  final _scroll = ScrollController();
  final _chips = {for (final c in BuilderCategory.values) c: GlobalKey()};
  Timer? _revealLater;

  @override
  void didUpdateWidget(BuilderCategoryBar old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      // The old chip loses its check and the new one gains it, which moves
      // the chips; reveal once they have settled.
      _revealLater?.cancel();
      _revealLater = Timer(_settle, () => _reveal(widget.selected));
    }
  }

  @override
  void dispose() {
    _revealLater?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  /// Scrolls the row (only the row: the page stays where it is) so [c]'s
  /// chip is fully in view with the gutter around it.
  void _reveal(BuilderCategory c) {
    if (!mounted || !_scroll.hasClients) return;
    final chip = _chips[c]!.currentContext?.findRenderObject();
    if (chip is! RenderBox || !chip.attached) return;
    final viewport = RenderAbstractViewport.maybeOf(chip);
    if (viewport == null) return;
    final position = _scroll.position;
    final gap = widget.padding;
    // The offsets that put the chip's start at the row's start (after the
    // gutter), and its end at the row's end (before the gutter).
    final startAt = viewport.getOffsetToReveal(chip, 0).offset - gap;
    final endAt = viewport.getOffsetToReveal(chip, 1).offset + gap;
    final wanted = endAt <= startAt
        ? position.pixels.clamp(endAt, startAt)
        : startAt;
    final target = wanted.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((target - position.pixels).abs() < 0.5) return;
    if (motionEnabled(context)) {
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scroll.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l.personaBuilderParts,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsetsDirectional.symmetric(horizontal: widget.padding),
        child: Row(
          children: [
            for (final (i, c) in BuilderCategory.values.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              KeyedSubtree(
                key: _chips[c],
                child: ChoiceChip(
                  key: ValueKey('persona-category-${c.name}'),
                  label: Text(c.label(l)),
                  selected: c == widget.selected,
                  onSelected: (_) => widget.onChanged(c),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
