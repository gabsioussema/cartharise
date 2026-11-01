import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../theme/avatar_palette.dart';
import '../theme/cartha_theme.dart';
import 'avatar_view.dart';
import 'builder_categories.dart';

/// How one choice can be used right now.
enum OptionAccess {
  /// Free, or an extra the user has unlocked.
  open,

  /// A locked extra the saved avatar already wears: it stays usable (nothing
  /// worn is ever taken away).
  kept,

  /// A locked extra: visible with its lock and reason, not selectable.
  locked,
}

/// Size of the small portrait inside each choice.
const double kOptionPortrait = 48;

/// Size of the colour swatch on a colour choice.
const double kOptionSwatch = 18;

/// The plain colour of a colour choice (skin tone, hair colour, garment
/// colour), shown as a swatch next to its name; null for other choices.
Color? optionSwatch(Enum? value) => switch (value) {
  final SkinTone t => AvatarPalette.skin(t).base,
  final HairColor c => AvatarPalette.hair(c).base,
  final GarmentColor c => AvatarPalette.garment(c).base,
  _ => null,
};

/// The choices of one [category] as a grid of labelled tiles. Each tile shows
/// a small portrait of the draft with that choice (so colours are seen in
/// place, next to their name) and announces its selected state.
class BuilderOptionGrid extends StatelessWidget {
  const BuilderOptionGrid({
    super.key,
    required this.category,
    required this.draft,
    required this.accessOf,
    required this.reasonOf,
    required this.onPick,
  });

  final BuilderCategory category;

  /// The avatar being edited.
  final Avatar draft;
  final OptionAccess Function(Enum value) accessOf;

  /// How to unlock a locked extra ("Reach the Alps").
  final String Function(Enum value) reasonOf;
  final ValueChanged<Enum?> onPick;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final selected = category.valueOf(draft);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final tiles = [
      for (final value in category.options) _tile(l, value, value == selected),
    ];
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: category.label(l),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Wider tiles as text grows, so names wrap rather than clip.
          final minTile = 84 * math.min(scale, 1.6);
          final columns = (constraints.maxWidth / minTile).floor().clamp(2, 6);
          const gap = 8.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var row = 0; row < tiles.length; row += columns) ...[
                if (row > 0) const SizedBox(height: gap),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = row; i < row + columns; i++) ...[
                        if (i > row) const SizedBox(width: gap),
                        Expanded(
                          child: i < tiles.length
                              ? tiles[i]
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _tile(AppLocalizations l, Enum? value, bool selected) {
    final access = value == null ? OptionAccess.open : accessOf(value);
    return BuilderOptionTile(
      key: ValueKey(
        'persona-option-${category.name}-${value?.name ?? 'silhouette'}',
      ),
      label: optionName(l, value),
      swatch: optionSwatch(value),
      selected: selected,
      access: access,
      note: switch (access) {
        OptionAccess.open => null,
        OptionAccess.kept => l.personaBuilderKept,
        OptionAccess.locked => reasonOf(value!),
      },
      preview: AvatarView(
        avatar: category.apply(draft, value),
        size: kOptionPortrait,
        showSigil: category == BuilderCategory.sigil,
        excludeFromSemantics: true,
      ),
      onTap: access == OptionAccess.locked ? null : () => onPick(value),
    );
  }
}

/// One choice: small portrait, name, and a badge — a check when selected, a
/// lock (with its reason underneath) when locked. Selection is shown by the
/// check, the bold name and the ring, and announced; never by colour alone.
/// At least 48 dp tall.
class BuilderOptionTile extends StatelessWidget {
  const BuilderOptionTile({
    super.key,
    required this.label,
    required this.preview,
    required this.selected,
    required this.onTap,
    this.access = OptionAccess.open,
    this.note,
    this.swatch,
  });

  final String label;
  final Widget preview;

  /// A colour choice's plain colour, drawn as a dot on the portrait's corner
  /// (always next to its name, never instead of it).
  final Color? swatch;
  final bool selected;
  final OptionAccess access;

  /// Under the name: the unlock reason, or "Yours to keep".
  final String? note;

  /// Null when the choice is locked.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final locked = access == OptionAccess.locked;
    final badge = selected
        ? Icon(Icons.check_circle, size: 20, color: p.accent)
        : switch (access) {
            OptionAccess.locked => Icon(
              Icons.lock_outline,
              size: 18,
              color: p.textSecondary,
              semanticLabel: l.personaLocked,
            ),
            OptionAccess.kept => Icon(
              Icons.lock_open_outlined,
              size: 18,
              color: p.textSecondary,
            ),
            OptionAccess.open => null,
          };
    return Semantics(
      container: true,
      button: true,
      enabled: !locked,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? p.selection : p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          side: p.selectionSide(selected),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Stack(
              alignment: AlignmentDirectional.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(6, 10, 6, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // A fixed square so the grid can size rows without
                      // asking the painter for its intrinsic height.
                      SizedBox.square(
                        dimension: kOptionPortrait,
                        child: Opacity(
                          opacity: locked ? 0.45 : 1,
                          child: swatch == null
                              ? preview
                              : Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned.fill(child: preview),
                                    PositionedDirectional(
                                      end: -4,
                                      bottom: -2,
                                      child: Container(
                                        key: const ValueKey(
                                          'persona-option-swatch',
                                        ),
                                        width: kOptionSwatch,
                                        height: kOptionSwatch,
                                        decoration: BoxDecoration(
                                          color: swatch,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selected
                                                ? p.selection
                                                : p.card,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: locked ? p.textSecondary : p.textPrimary,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      if (note != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          note!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badge != null)
                  PositionedDirectional(top: 4, end: 4, child: badge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
