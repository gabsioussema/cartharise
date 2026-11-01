import 'dart:math' as math;

import 'package:flutter/material.dart';

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
class BuilderCategoryBar extends StatelessWidget {
  const BuilderCategoryBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final BuilderCategory selected;
  final ValueChanged<BuilderCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: l.personaBuilderParts,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final (i, c) in BuilderCategory.values.indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              ChoiceChip(
                key: ValueKey('persona-category-${c.name}'),
                label: Text(c.label(l)),
                selected: c == selected,
                onSelected: (_) => onChanged(c),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
