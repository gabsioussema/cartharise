import 'package:flutter/material.dart';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';
import 'avatar_painter.dart';

/// The user's avatar as a round portrait of [size]. With no [avatar], the
/// Cartharise emblem stands in. [showSigil] draws the banner behind.
///
/// A calm flat-vector bust on the theme's hero disc with a thin bronze rim
/// ([AvatarPainter]); details are simplified below 40 px. With no skin tone
/// chosen the figure is a monochrome silhouette (no skin is assumed).
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
    final scene = AvatarScene.of(CarthaPalette.of(context));
    final a = avatar;
    final view = SizedBox.square(
      dimension: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: a == null
              ? AvatarEmblemPainter(scene: scene)
              : AvatarPainter(avatar: a, scene: scene, showSigil: showSigil),
        ),
      ),
    );
    if (excludeFromSemantics) return ExcludeSemantics(child: view);
    return Semantics(
      image: true,
      label:
          semanticLabel ??
          (a == null ? l.personaNoAvatar : l.personaAvatarLabel),
      child: view,
    );
  }
}
