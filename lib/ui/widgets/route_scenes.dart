/// Campaign scenery: a painted landscape for each stop on Hannibal's route
/// ([RouteScene], framed with the route on it by [RouteSceneWindow]) and the
/// chapter keepsakes of the Collection ([Keepsake]). Brand scene style
/// (`ScenePalette`, hero colours), palette tokens only.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/campaign.dart' show Waypoint;
import '../../domain/content.dart' show CampaignChapter;
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import 'art/keepsake_art.dart';
import 'art/route_art.dart';

export 'art/keepsake_art.dart' show KeepsakeArt, KeepsakePainter;
export 'art/route_art.dart' show RouteScenePainter;

/// The landscape of [waypoint] (see [RouteScenePainter]), filling its parent
/// (give it bounded constraints).
///
/// The light lifts once when it is first shown or the stop changes (sun,
/// moon and glow come up over [riseDuration]); it is painted still when the
/// device asks for reduced motion, Settings › Motion is off, or [animate] is
/// false. Decorative unless a [semanticLabel] is given.
class RouteScene extends StatefulWidget {
  const RouteScene(
    this.waypoint, {
    super.key,
    this.semanticLabel,
    this.animate = true,
    this.veiled = false,
  });

  final Waypoint waypoint;
  final String? semanticLabel;

  /// False paints the finished scene straight away (thumbnails).
  final bool animate;

  /// A soft mist over the scene: a stop still ahead.
  final bool veiled;

  /// How long the light takes to lift.
  static const riseDuration = Duration(milliseconds: 1600);

  @override
  State<RouteScene> createState() => _RouteSceneState();
}

class _RouteSceneState extends State<RouteScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: RouteScene.riseDuration,
  );
  bool _started = false;

  bool _motionAllowed(BuildContext context) {
    final device = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final setting = context.select<AppState?, bool>(
      (s) => s?.settings.motion ?? true,
    );
    return widget.animate && !device && setting;
  }

  @override
  void didUpdateWidget(RouteScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new stop: its light lifts again (build decides whether it moves).
    if (oldWidget.waypoint != widget.waypoint) _started = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = _motionAllowed(context);
    if (!_started) {
      _started = true;
      if (allowed) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1;
      }
    } else if (!allowed && _controller.value < 1) {
      // Motion switched off mid-rise: show the finished scene at once.
      _controller
        ..stop()
        ..value = 1;
    }
    final paint = RepaintBoundary(
      child: CustomPaint(
        painter: RouteScenePainter(
          waypoint: widget.waypoint,
          palette: CarthaPalette.of(context),
          progress: _controller,
          veiled: widget.veiled,
        ),
        child: const SizedBox.expand(),
      ),
    );
    final label = widget.semanticLabel;
    if (label == null) return ExcludeSemantics(child: paint);
    // Its own node, so a card around it doesn't become an image.
    return Semantics(container: true, image: true, label: label, child: paint);
  }
}

/// Test hook: how far a [RouteScene]'s light has lifted (0–1).
@visibleForTesting
double routeSceneProgress(State state) =>
    (state as _RouteSceneState)._controller.value;

/// Test hook: whether a [RouteScene] is still animating.
@visibleForTesting
bool isRouteSceneAnimating(State state) =>
    (state as _RouteSceneState)._controller.isAnimating;

/// A stop's landscape in a rounded frame, [width / aspectRatio] tall within
/// [minHeight]–[maxHeight], with [overlay] (the route and the avatar) along
/// its bottom over a soft shade of the hero colour, so the road's dots read
/// on any scene. Used on the hero surface of the Campaign hub and the Route
/// page; the scene's [semanticLabel] describes the picture.
class RouteSceneWindow extends StatelessWidget {
  const RouteSceneWindow({
    super.key,
    required this.waypoint,
    this.overlay,
    this.semanticLabel,
    this.aspectRatio = 2,
    this.minHeight = 112,
    this.maxHeight = 200,
    this.animate = true,
  });

  final Waypoint waypoint;

  /// Laid along the bottom of the frame (its own height).
  final Widget? overlay;
  final String? semanticLabel;
  final double aspectRatio;
  final double minHeight;
  final double maxHeight;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = (constraints.maxWidth / aspectRatio).clamp(
          minHeight,
          maxHeight,
        );
        return SizedBox(
          height: height,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RouteScene(
                  waypoint,
                  key: ValueKey('route-scene-${waypoint.name}'),
                  semanticLabel: semanticLabel,
                  animate: animate,
                ),
                if (overlay != null) ...[
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            p.hero.withValues(alpha: 0),
                            p.hero.withValues(alpha: 0.72),
                          ],
                          stops: const [0.55, 1],
                        ),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    start: 8,
                    end: 8,
                    bottom: 2,
                    child: overlay!,
                  ),
                ],
                // A hairline frame, like the hero card's border.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        CarthaTheme.radiusSmall,
                      ),
                      border: Border.all(
                        color: p.heroBorder.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The keepsake of [chapter] (see [KeepsakePainter]): a spyglass, a mosaic
/// tile, a banner, an hourglass or a scroll on a small stele. Kept: filled,
/// on a plinth; not yet: an empty dashed slot with the object in outline.
/// Decorative (the words next to it say what it is and whether it is kept).
class Keepsake extends StatelessWidget {
  const Keepsake(this.chapter, {super.key, this.kept = false, this.size = 64});

  final CampaignChapter chapter;
  final bool kept;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      key: ValueKey('keepsake-${chapter.name}'),
      dimension: size,
      child: CustomPaint(
        painter: KeepsakePainter(
          chapter: chapter,
          kept: kept,
          palette: CarthaPalette.of(context),
        ),
      ),
    ),
  );
}
