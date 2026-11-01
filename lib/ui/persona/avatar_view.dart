import 'package:flutter/material.dart';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';
import '../widgets/emblem.dart';

/// The user's avatar as a round portrait of [size]. With no [avatar], the
/// Cartharise emblem stands in. [showSigil] draws the banner behind.
///
/// CONTRACT STUB (persona plan, phase 0): the avatar-art agent replaces the
/// body with the real painter; the constructor stays exactly as is.
class AvatarView extends StatelessWidget {
  const AvatarView({
    super.key,
    this.avatar,
    this.size = 64,
    this.showSigil = true,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final Avatar? avatar;
  final double size;
  final bool showSigil;

  /// Defaults to "Your avatar" ("No avatar yet" without one).
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final view = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: p.hero, shape: BoxShape.circle),
        child: Center(
          child: CarthaEmblem(
            size: size * 0.6,
            color: p.heroAccent,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
    if (excludeFromSemantics) return ExcludeSemantics(child: view);
    return Semantics(
      image: true,
      label:
          semanticLabel ??
          (avatar == null ? l.personaNoAvatar : l.personaAvatarLabel),
      child: view,
    );
  }
}
