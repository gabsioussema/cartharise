/// Shared pieces of the media feature (photos and voice notes): the sheet
/// style, plain-language failure texts, clock and size formatting, the
/// inline notice that says honestly what happened, and announcements.
///
/// Nothing here logs: no file name, path or user text ever leaves the
/// widget tree.
library;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../../services/media_picker.dart';
import '../../services/voice_recorder.dart';
import '../../state/app_state.dart';
import '../journal/journal_kit.dart' show formatDateKey;
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// The local day of [time], compact ("Nov 2, 2026"): when a photo was added
/// or a pinned memory was written.
String shortDate(BuildContext context, DateTime time) =>
    formatDateKey(context, dateKey(time.toLocal()));

/// Opens a media sheet: scroll-controlled, inside the safe area, and with no
/// slide while motion is reduced (device or Settings › Motion).
Future<T?> showMediaSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool dismissible = true,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  isDismissible: dismissible,
  enableDrag: dismissible,
  sheetAnimationStyle: motionEnabled(context)
      ? null
      : AnimationStyle.noAnimation,
  builder: builder,
);

/// Says [message] to a screen reader (politely, after what it is reading).
void announce(BuildContext context, String message) {
  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );
}

/// `m:ss` (or `h:mm:ss`) for a recording's length or position.
String formatClock(Duration d) {
  final total = d.isNegative ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = (total % 60).toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$s';
  return '$m:$s';
}

/// A length a screen reader says well ("1 minute 5 seconds").
String spokenDuration(AppLocalizations l, Duration d) {
  final total = d.isNegative ? 0 : d.inSeconds;
  final minutes = total ~/ 60;
  final seconds = total % 60;
  if (minutes == 0) return l.mediaSeconds(seconds);
  if (seconds == 0) return l.mediaMinutes(minutes);
  return '${l.mediaMinutes(minutes)} ${l.mediaSeconds(seconds)}';
}

/// A file size in KB, MB or GB, in the device's number format.
String formatBytes(BuildContext context, int bytes) {
  final l = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;
  if (bytes < mb) {
    final n = bytes <= 0 ? 0 : (bytes / kb).ceil();
    return l.mediaSizeKb(NumberFormat.decimalPattern(locale).format(n));
  }
  final one = NumberFormat('0.0', locale);
  if (bytes < gb) return l.mediaSizeMb(one.format(bytes / mb));
  return l.mediaSizeGb(one.format(bytes / gb));
}

/// "2 photos and 1 voice note" (only the kinds there are), or null.
String? attachmentCountText(AppLocalizations l, int photos, int voice) {
  final parts = [
    if (photos > 0) l.mediaCountPhotos(photos),
    if (voice > 0) l.mediaCountVoice(voice),
  ];
  if (parts.isEmpty) return null;
  if (parts.length == 1) return parts.single;
  return l.mediaAnd(parts[0], parts[1]);
}

/// Why a photo couldn't be added, in plain words (never "added").
String photoFailureText(AppLocalizations l, AttachmentFailure f) => switch (f) {
  AttachmentFailure.sourceMissing ||
  AttachmentFailure.empty ||
  AttachmentFailure.missing ||
  AttachmentFailure.readFailed => l.mediaPhotoUnreadable,
  AttachmentFailure.tooLarge => l.mediaPhotoTooLarge,
  AttachmentFailure.writeFailed ||
  AttachmentFailure.deleteFailed => l.mediaWriteFailed,
};

/// Why the photo picker or camera couldn't be used, with the alternative.
String pickerFailureText(
  AppLocalizations l,
  MediaFailure f, {
  required bool camera,
}) => switch (f) {
  MediaFailure.permissionDenied =>
    camera ? l.mediaCameraDenied : l.mediaPhotosDenied,
  MediaFailure.unavailable =>
    camera ? l.mediaCameraUnavailable : l.mediaPhotosUnavailable,
  MediaFailure.failed => l.mediaPickFailed,
};

/// Why recording couldn't start, with the alternative (writing).
String voiceFailureText(AppLocalizations l, VoiceFailure f) => switch (f) {
  VoiceFailure.permissionDenied => l.mediaMicDenied,
  VoiceFailure.unavailable => l.mediaMicUnavailable,
  VoiceFailure.failed => l.mediaRecordFailed,
};

/// How an inline [MediaNotice] reads. The icon carries it too, never the
/// colour alone.
enum NoticeTone { info, done, warning, error }

/// What to tell the user after a photo or recording action, shown inline
/// as a [MediaNotice].
class MediaMessage {
  const MediaMessage(
    this.text, {
    this.tone = NoticeTone.info,
    this.retry = false,
    this.actionLabel,
    this.action,
  });

  final String text;
  final NoticeTone tone;

  /// The change is on screen but not saved on the phone yet: offer Retry.
  final bool retry;

  /// A practical alternative (e.g. "Choose from your photos").
  final String? actionLabel;
  final VoidCallback? action;
}

/// A short inline message about a photo or recording — what happened,
/// honestly, and what to do instead — announced to screen readers. Used
/// where a snackbar could hide behind a sheet.
class MediaNotice extends StatelessWidget {
  const MediaNotice({
    super.key,
    required this.message,
    this.tone = NoticeTone.info,
    this.actions = const [],
    this.onDismiss,
  });

  final String message;
  final NoticeTone tone;
  final List<Widget> actions;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final (IconData icon, Color bg, Color border, Color fg) = switch (tone) {
      NoticeTone.info => (Icons.info_outline, p.raised, p.border, p.accent),
      NoticeTone.done => (
        Icons.check_circle_outline,
        p.successContainer,
        p.success,
        p.onSuccessContainer,
      ),
      NoticeTone.warning => (
        Icons.warning_amber_outlined,
        p.warningContainer,
        p.warning,
        p.onWarningContainer,
      ),
      NoticeTone.error => (
        Icons.error_outline,
        p.errorContainer,
        p.error,
        p.onErrorContainer,
      ),
    };
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 4, 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 2),
              child: Icon(icon, size: 20, color: fg),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 2, end: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: p.textPrimary,
                      ),
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(spacing: 4, runSpacing: 0, children: actions),
                    ],
                  ],
                ),
              ),
            ),
            if (onDismiss != null)
              IconButton(
                tooltip: l.mediaDismiss,
                icon: Icon(Icons.close, size: 20, color: p.textSecondary),
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}

/// Retry for a change that is on screen but not saved on the phone yet
/// (`AppState.retrySave`); [after] runs once the retry finished.
Widget retrySaveButton(BuildContext context, {VoidCallback? after}) {
  final l = AppLocalizations.of(context);
  final state = context.read<AppState>();
  return TextLinkButton(
    key: const ValueKey('media-retry-save'),
    label: l.retry,
    icon: Icons.refresh,
    onPressed: () async {
      await state.retrySave();
      after?.call();
    },
  );
}

/// A quiet line saying what an entry holds besides its words — "2 photos
/// and 1 voice note" — with a matching icon (never colour alone). Nothing
/// when [attachments] is empty. Used on note cards, attempts and tries.
class AttachmentCountLine extends StatelessWidget {
  const AttachmentCountLine(this.attachments, {super.key});

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final photos = attachments
        .where((a) => a.kind == AttachmentKind.photo)
        .length;
    final voice = attachments.length - photos;
    final text = attachmentCountText(l, photos, voice);
    if (text == null) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(
          voice > 0 ? Icons.graphic_eq : Icons.photo_outlined,
          size: 16,
          color: p.accent,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: p.textSecondary),
          ),
        ),
      ],
    );
  }
}
