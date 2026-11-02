/// A project's picture (Missions › project): one of the painted scenes —
/// the brand scenes ([SceneKind]) and lesson scenes ([LessonScene]), mapped
/// by name — or the user's own photo from the private attachments folder.
/// Shown on the project, small on its tasks and attempts, and in the
/// history. Colours from palette tokens only; static (no motion).
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../services/media_picker.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/art/lesson_art.dart' show LessonArtPainter;
import '../widgets/widgets.dart';
import 'missions_logic.dart';

/// The word for [illustration] (always shown next to its picture).
String projectIllustrationName(
  AppLocalizations l,
  ProjectIllustration illustration,
) => switch (illustration) {
  ProjectIllustration.sunrise => l.projectsArtSunrise,
  ProjectIllustration.path => l.projectsArtPath,
  ProjectIllustration.compass => l.projectsArtCompass,
  ProjectIllustration.steps => l.projectsArtSteps,
  ProjectIllustration.dawnRuins => l.projectsArtDawnRuins,
  ProjectIllustration.roots => l.projectsArtRoots,
  ProjectIllustration.citadel => l.projectsArtCitadel,
  ProjectIllustration.sailing => l.projectsArtSailing,
  ProjectIllustration.route => l.projectsArtRoute,
};

/// What [art] shows, for a screen reader ("Project picture: Sunrise").
String projectArtLabel(AppLocalizations l, ProjectArt art) {
  final illustration = art.illustration;
  return l.projectsPictureLabel(
    illustration == null
        ? l.projectsPhotoName
        : projectIllustrationName(l, illustration),
  );
}

/// The brand scene [illustration] names, if it is one.
SceneKind? projectSceneKind(ProjectIllustration illustration) {
  for (final k in SceneKind.values) {
    if (k.name == illustration.name) return k;
  }
  return null;
}

/// The lesson scene [illustration] names, if it is one.
LessonScene? projectLessonScene(ProjectIllustration illustration) {
  for (final s in LessonScene.values) {
    if (s.name == illustration.name) return s;
  }
  return null;
}

/// The project with [id] (current or past), rebuilt when it changes; null
/// when there is no id or the project is gone.
MonthProject? watchProject(BuildContext context, String? id) =>
    context.select<AppState, MonthProject?>(
      (s) => id == null ? null : s.projectById(id),
    );

/// [art] filling its parent (give it bounded constraints). Decorative
/// unless [semanticLabel] is given.
class ProjectArtView extends StatelessWidget {
  const ProjectArtView(this.art, {super.key, this.semanticLabel});

  final ProjectArt art;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final photo = art.photo;
    final illustration = art.illustration;
    final Widget child;
    if (photo != null) {
      child = ProjectPhoto(photo);
    } else if (illustration != null) {
      child = _Illustration(illustration);
    } else {
      child = const SizedBox.expand();
    }
    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: child);
    // Its own node: a picture is read on its own, not merged into a title.
    return Semantics(
      container: true,
      image: true,
      label: label,
      child: ExcludeSemantics(child: child),
    );
  }
}

/// A painted scene at any proportions: brand scenes keep their composition
/// (wide boxes show their band of interest, others are cropped to fill);
/// lesson scenes stay centred at the box's height.
class _Illustration extends StatelessWidget {
  const _Illustration(this.illustration);

  final ProjectIllustration illustration;

  @override
  Widget build(BuildContext context) {
    final scene = projectSceneKind(illustration);
    final lesson = projectLessonScene(illustration);
    return LayoutBuilder(
      builder: (context, box) {
        if (scene == null) {
          return RepaintBoundary(
            child: CustomPaint(
              painter: LessonArtPainter(
                scene: lesson ?? LessonScene.route,
                palette: CarthaPalette.of(context),
              ),
              child: const SizedBox.expand(),
            ),
          );
        }
        final wide =
            box.hasBoundedHeight &&
            box.maxHeight > 0 &&
            box.maxWidth / box.maxHeight >= 1.6;
        if (wide) {
          return BrandScene.compact(
            kind: scene,
            aspectRatio: null,
            animate: false,
          );
        }
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: 240,
              height: 180,
              child: BrandScene(kind: scene, aspectRatio: null, animate: false),
            ),
          ),
        );
      },
    );
  }
}

/// [art] as a small square (or round) thumbnail of [size].
class ProjectArtThumb extends StatelessWidget {
  const ProjectArtThumb(
    this.art, {
    super.key,
    this.size = 40,
    this.round = false,
  });

  final ProjectArt art;
  final double size;
  final bool round;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(round ? size : size * 0.25),
      child: ProjectArtView(art),
    ),
  );
}

/// [art] as a rounded banner [height] tall across the width it is given.
class ProjectArtBanner extends StatelessWidget {
  const ProjectArtBanner(
    this.art, {
    super.key,
    this.height = 140,
    this.aspectRatio,
    this.semanticLabel,
  });

  final ProjectArt art;

  /// The height on a phone; with [aspectRatio], the least height.
  final double height;

  /// Grows the banner with wider screens (tablets), up to twice [height],
  /// so a photo isn't cut to a thin strip.
  final double? aspectRatio;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final ratio = aspectRatio;
      final h = ratio == null || !box.hasBoundedWidth
          ? height
          : (box.maxWidth / ratio).clamp(height, height * 2).toDouble();
      return SizedBox(
        height: h,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          child: ProjectArtView(art, semanticLabel: semanticLabel),
        ),
      );
    },
  );
}

/// The photos read for the screen, per attachment store, shared by every
/// view of the same photo and dropped when the data is replaced (restore,
/// "Delete all data"). Small: a project wears one photo.
class _PhotoBytes {
  int generation = -1;
  final Map<String, Future<Uint8List>> byFile = {};

  static final _perStore = Expando<_PhotoBytes>('project photos');
  static const _limit = 8;

  static Future<Uint8List> read(AppState state, Attachment photo) {
    final store = state.attachmentStore;
    final cache = _perStore[store] ??= _PhotoBytes();
    if (cache.generation != state.dataGeneration) {
      cache.byFile.clear();
      cache.generation = state.dataGeneration;
    }
    final known = cache.byFile[photo.fileName];
    if (known != null) return known;
    if (cache.byFile.length >= _limit) {
      cache.byFile.remove(cache.byFile.keys.first);
    }
    final future = store.readBytes(photo);
    cache.byFile[photo.fileName] = future;
    // A failed read is tried again next time (the file may come back with
    // a restore).
    future.then<void>(
      (_) {},
      onError: (Object _) {
        if (identical(cache.byFile[photo.fileName], future)) {
          cache.byFile.remove(photo.fileName);
        }
      },
    );
    return future;
  }
}

/// A project photo from the private attachments folder, cropped to fill.
/// A photo that can't be read says so in words when there is room ("Photo
/// not found on this phone"), never a blank or a broken image.
class ProjectPhoto extends StatefulWidget {
  const ProjectPhoto(this.photo, {super.key});

  final Attachment photo;

  @override
  State<ProjectPhoto> createState() => _ProjectPhotoState();
}

class _ProjectPhotoState extends State<ProjectPhoto> {
  Future<Uint8List>? _bytes;
  String? _file;
  int? _generation;

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final generation = context.select<AppState, int>((s) => s.dataGeneration);
    if (_file != widget.photo.fileName || _generation != generation) {
      _file = widget.photo.fileName;
      _generation = generation;
      _bytes = _PhotoBytes.read(state, widget.photo);
    }
    return LayoutBuilder(
      builder: (context, box) {
        final ratio = MediaQuery.devicePixelRatioOf(context);
        final width = box.hasBoundedWidth
            ? (box.maxWidth * ratio).ceil().clamp(1, 2048)
            : null;
        return FutureBuilder<Uint8List>(
          future: _bytes,
          builder: (context, snap) {
            if (snap.hasError) return _MissingPhoto(roomy: box.maxHeight >= 72);
            final bytes = snap.data;
            if (bytes == null) {
              return ColoredBox(color: CarthaPalette.of(context).raised);
            }
            return Image.memory(
              bytes,
              key: ValueKey('project-photo-${widget.photo.id}'),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              cacheWidth: width,
              gaplessPlayback: true,
              excludeFromSemantics: true,
              errorBuilder: (_, _, _) =>
                  _MissingPhoto(roomy: box.maxHeight >= 72),
            );
          },
        );
      },
    );
  }
}

class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto({required this.roomy});

  final bool roomy;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final icon = Icon(
      Icons.broken_image_outlined,
      color: p.textSecondary,
      size: roomy ? 28 : 14,
    );
    return ColoredBox(
      key: const ValueKey('project-photo-missing'),
      color: p.raised,
      child: Center(
        child: roomy
            ? Padding(
                padding: const EdgeInsetsDirectional.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context).projectsPhotoMissing,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: p.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            : icon,
      ),
    );
  }
}

/// A small label naming the project a task or an attempt belongs to: its
/// picture (or a flag) and its title on one line. Read as
/// "Project: <title>".
class ProjectTag extends StatelessWidget {
  const ProjectTag(this.project, {super.key});

  final MonthProject project;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final art = project.art;
    final title = project.title.trim().isEmpty
        ? l.missionsProjectUntitled
        : project.title.trim();
    return Semantics(
      container: true,
      label: l.projectsTagLabel(title),
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(art == null ? 8 : 3, 3, 10, 3),
        decoration: BoxDecoration(
          color: p.raised,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (art != null)
              ProjectArtThumb(art, size: 18, round: true)
            else
              Icon(Icons.flag_outlined, size: 14, color: p.textSecondary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: p.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The [ProjectTag] of the project [projectId] names, or nothing when there
/// is none (or it was removed).
class LinkedProjectTag extends StatelessWidget {
  const LinkedProjectTag(this.projectId, {super.key});

  final String? projectId;

  @override
  Widget build(BuildContext context) {
    final project = watchProject(context, projectId);
    return project == null ? const SizedBox.shrink() : ProjectTag(project);
  }
}

/// Why a photo couldn't become the project's picture, in words with a way
/// forward (another source, a painted scene, or trying again).
String projectPhotoError(
  AppLocalizations l,
  Object error, {
  required bool camera,
}) {
  if (error is AttachmentException) {
    return error.reason == AttachmentFailure.tooLarge
        ? l.projectsPhotoTooLarge
        : l.projectsPhotoNotKept;
  }
  if (error is MediaPickerException) {
    return switch (error.reason) {
      MediaFailure.permissionDenied =>
        camera ? l.projectsPhotoDeniedCamera : l.projectsPhotoDeniedLibrary,
      MediaFailure.unavailable =>
        camera ? l.projectsPhotoNoCamera : l.projectsPhotoNoLibrary,
      MediaFailure.failed => l.projectsPhotoFailed,
    };
  }
  return l.projectsPhotoFailed;
}
