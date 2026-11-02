import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../services/media_picker.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'project_art.dart';

/// Opens the project picture sheet: the nine painted scenes (each with its
/// name), "Choose a photo" / "Take a photo" (the system picker or camera,
/// asked only on that tap) and, when there is one, "Remove picture".
/// [onChoose] saves the choice (null removes the picture); the sheet closes
/// once it was handed over. When the picture is a photo, a painted scene or
/// "Remove picture" first asks "Remove the photo?" (it is deleted). A photo that couldn't be picked or kept is said
/// in the sheet, with another way forward — never shown as chosen.
Future<void> showProjectArtPicker(
  BuildContext context, {
  required ProjectArt? current,
  required Future<void> Function(ProjectArt? art) onChoose,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  // Reduced motion (device or Settings › Motion): no slide.
  sheetAnimationStyle: motionEnabled(context)
      ? null
      : AnimationStyle.noAnimation,
  builder: (_) => ProjectArtPicker(current: current, onChoose: onChoose),
);

class ProjectArtPicker extends StatefulWidget {
  const ProjectArtPicker({
    super.key,
    required this.current,
    required this.onChoose,
  });

  final ProjectArt? current;
  final Future<void> Function(ProjectArt? art) onChoose;

  @override
  State<ProjectArtPicker> createState() => _ProjectArtPickerState();
}

class _ProjectArtPickerState extends State<ProjectArtPicker> {
  bool _busy = false;

  /// Shown while a photo is being picked and copied.
  bool _adding = false;
  String? _error;

  /// Whether the current photo may go: a camera photo may exist nowhere
  /// else, so a painted scene or "Remove picture" asks first (as the
  /// screen's Remove does). Nothing to ask without a photo.
  Future<bool> _photoMayGo() async {
    if (widget.current?.photo == null) return true;
    final l = AppLocalizations.of(context);
    return confirmDialog(
      context,
      title: l.projectsPhotoRemoveTitle,
      body: l.projectsPhotoRemoveBody,
      action: l.projectsPhotoRemoveConfirm,
      destructive: true,
    );
  }

  Future<void> _choose(ProjectArt? art) async {
    if (!await _photoMayGo() || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    await widget.onChoose(art);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _photo({required bool camera}) async {
    final l = AppLocalizations.of(context);
    final media = context.read<MediaPicker>();
    final store = context.read<AppState>().attachmentStore;
    setState(() {
      _busy = true;
      _adding = true;
      _error = null;
    });
    String? path;
    try {
      path = await media.pickPhoto(camera: camera);
      if (path == null) {
        // Cancelled in the picker: nothing changes.
        if (mounted) {
          setState(() {
            _busy = false;
            _adding = false;
          });
        }
        return;
      }
      final photo = await store.importFile(path, kind: AttachmentKind.photo);
      await widget.onChoose(ProjectArt.photo(photo));
      if (mounted) Navigator.of(context).pop();
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _adding = false;
          _error = projectPhotoError(l, e, camera: camera);
        });
      }
    } finally {
      // The picker's temporary copy goes either way (kept or not).
      if (path != null) unawaited(media.release(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final current = widget.current;
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              l.projectsArtSheetTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (current?.photo != null) ...[
            const SizedBox(height: 6),
            Text(l.projectsArtReplacesPhoto, style: secondary),
          ],
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(l.projectsArtPhoto, style: theme.textTheme.titleSmall),
          ),
          const SizedBox(height: 4),
          Text(l.projectsArtPhotoNote, style: secondary),
          if (current?.photo != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                ProjectArtThumb(current!, size: 56),
                const SizedBox(width: 12),
                Icon(Icons.check_circle, size: 18, color: p.accent),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l.projectsArtSelected,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SecondaryButton(
                key: const ValueKey('project-art-gallery'),
                label: l.projectsArtChoosePhoto,
                icon: Icons.photo_library_outlined,
                onPressed: _busy ? null : () => _photo(camera: false),
              ),
              SecondaryButton(
                key: const ValueKey('project-art-camera'),
                label: l.projectsArtTakePhoto,
                icon: Icons.photo_camera_outlined,
                onPressed: _busy ? null : () => _photo(camera: true),
              ),
            ],
          ),
          if (_adding) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  CarthaLoader(size: 20, color: p.accent),
                  const SizedBox(width: 10),
                  Flexible(child: Text(l.projectsArtAdding, style: secondary)),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorNote(key: const ValueKey('project-art-error'), text: _error!),
          ],
          const SizedBox(height: 24),
          Semantics(
            header: true,
            child: Text(l.projectsArtScenes, style: theme.textTheme.titleSmall),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, box) {
              const gap = 10.0;
              final columns = (box.maxWidth / 112).floor().clamp(2, 5);
              const scenes = ProjectIllustration.values;
              // Rows of equal-height tiles (a name may take two lines).
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var row = 0; row < scenes.length; row += columns) ...[
                    if (row > 0) const SizedBox(height: gap),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var col = 0; col < columns; col++) ...[
                            if (col > 0) const SizedBox(width: gap),
                            Expanded(
                              child: row + col < scenes.length
                                  ? _SceneTile(
                                      illustration: scenes[row + col],
                                      selected:
                                          current?.illustration ==
                                          scenes[row + col],
                                      onTap: _busy
                                          ? null
                                          : () => _choose(
                                              ProjectArt.illustration(
                                                scenes[row + col],
                                              ),
                                            ),
                                    )
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
          if (current != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextLinkButton(
                key: const ValueKey('project-art-none'),
                label: l.projectsPictureRemove,
                icon: Icons.hide_image_outlined,
                onPressed: _busy ? null : () => _choose(null),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Center(
            child: TextLinkButton(
              label: l.cancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// One painted scene to choose: the picture and its name; the chosen one
/// has a thicker border and a tick next to "Selected" (not colour alone).
class _SceneTile extends StatelessWidget {
  const _SceneTile({
    required this.illustration,
    required this.selected,
    required this.onTap,
  });

  final ProjectIllustration illustration;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final name = projectIllustrationName(l, illustration);
    // One node: the name (the picture is decorative), the tap, "selected".
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          key: ValueKey('project-art-${illustration.name}'),
          color: selected ? p.selection : p.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
            side: BorderSide(
              color: selected ? p.accent : p.border,
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: ProjectArtView(
                        ProjectArt.illustration(illustration),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4, 8, 4, 4),
                    child: Row(
                      children: [
                        if (selected) ...[
                          Icon(Icons.check_circle, size: 16, color: p.accent),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(name, style: theme.textTheme.labelLarge),
                        ),
                      ],
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

class _ErrorNote extends StatelessWidget {
  const _ErrorNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsetsDirectional.all(12),
        decoration: BoxDecoration(
          color: p.errorContainer,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          border: Border.all(color: p.error),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 20, color: p.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: p.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
