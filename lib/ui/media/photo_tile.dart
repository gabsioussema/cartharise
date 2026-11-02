import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import 'media_kit.dart' show shortDate;

/// A photo the user added, read from the private attachments folder
/// (`AttachmentStore.readBytes`) and decoded at the size it is shown. A file
/// that is gone or unreadable shows a calm "Missing" placeholder (a word and
/// an icon, never colour alone) instead of failing.
class AttachmentImage extends StatefulWidget {
  const AttachmentImage({
    super.key,
    required this.attachment,
    this.fit = BoxFit.cover,
    this.decodeWidth,
  });

  final Attachment attachment;
  final BoxFit fit;

  /// Logical width to decode at (thumbnails); null = full size.
  final double? decodeWidth;

  @override
  State<AttachmentImage> createState() => _AttachmentImageState();
}

class _AttachmentImageState extends State<AttachmentImage> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _read();
  }

  @override
  void didUpdateWidget(AttachmentImage old) {
    super.didUpdateWidget(old);
    if (old.attachment.fileName != widget.attachment.fileName) {
      _bytes = _read();
    }
  }

  Future<Uint8List> _read() =>
      context.read<AppState>().attachmentStore.readBytes(widget.attachment);

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final ratio = MediaQuery.devicePixelRatioOf(context);
    final width = widget.decodeWidth;
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snapshot) {
        if (snapshot.hasError) return const _MissingPhoto();
        final bytes = snapshot.data;
        if (bytes == null) return ColoredBox(color: p.raised);
        return Image.memory(
          bytes,
          fit: widget.fit,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          cacheWidth: width == null ? null : (width * ratio).round(),
          frameBuilder: (context, child, frame, sync) =>
              frame == null && !sync ? ColoredBox(color: p.raised) : child,
          errorBuilder: (context, error, stack) => const _MissingPhoto(),
        );
      },
    );
  }
}

class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return ColoredBox(
      key: const ValueKey('photo-missing'),
      color: p.raised,
      child: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  color: p.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  l.mediaPhotoMissing,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A square thumbnail of a photo, rounded like the cards, that opens it
/// full screen. Announced as "Photo, added (date)" with an "Opens full
/// screen" hint. At least 48 dp.
class PhotoTile extends StatelessWidget {
  const PhotoTile({
    super.key,
    required this.attachment,
    this.size = 88,
    this.onTap,
    this.semanticLabel,
  });

  final Attachment attachment;
  final double size;
  final VoidCallback? onTap;

  /// Defaults to "Photo, added (date)".
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final side = size < 48 ? 48.0 : size;
    final radius = BorderRadius.circular(CarthaTheme.radiusSmall);
    return Semantics(
      container: true,
      button: onTap != null,
      image: true,
      label:
          semanticLabel ??
          l.mediaPhotoLabel(shortDate(context, attachment.createdAt)),
      hint: onTap == null ? null : l.mediaPhotoOpenHint,
      onTap: onTap,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: side,
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AttachmentImage(attachment: attachment, decodeWidth: side),
              // The ripple above the photo, then the card's thin border.
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    border: Border.all(color: p.border),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
