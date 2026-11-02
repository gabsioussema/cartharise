import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/attachment_ops.dart';
import '../campaign/attempt_sheet.dart';
import '../campaign/experiment_entry_sheet.dart';
import '../journal/journal_kit.dart' show formatDateKey;
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'media_kit.dart' show shortDate;
import 'photo_tile.dart';
import 'photo_viewer.dart';

/// The one memory the user pinned — a passage of their own words, exactly
/// as written, or a photo — compact, at the top of the Journal. Says where
/// it is from, opens it there, and **Unpin** (the entry is untouched).
/// Nothing is shown while nothing is pinned.
class PinnedMemoryCard extends StatelessWidget {
  const PinnedMemoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final pin = state.pinnedMemory;
    if (pin == null) return const SizedBox.shrink();
    final holder = state.holderOf(pin.sourceId);
    if (holder == null) return const SizedBox.shrink();
    final photo = pin.attachmentId == null
        ? null
        : _photo(state.data.attachmentsOf(holder, pin.sourceId), pin);
    final from = _fromLine(context, state, holder, pin.sourceId);
    final excerpt = pin.excerpt;
    return SectionCard(
      key: const ValueKey('pinned-memory'),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (photo != null) ...[
                PhotoTile(
                  key: const ValueKey('pinned-photo'),
                  attachment: photo,
                  size: 72,
                  semanticLabel: l.mediaPinnedPhoto,
                  onTap: () => openPhotoViewer(
                    context,
                    holder: holder,
                    entryId: pin.sourceId,
                    attachmentId: photo.id,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.push_pin, size: 16, color: p.accent),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Semantics(
                            header: true,
                            child: Text(
                              l.mediaPinnedTitle,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: p.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (excerpt != null) ...[
                      const SizedBox(height: 8),
                      // The user's own words, exactly as pinned.
                      Container(
                        padding: const EdgeInsetsDirectional.only(start: 10),
                        decoration: BoxDecoration(
                          border: BorderDirectional(
                            start: BorderSide(color: p.accent, width: 2),
                          ),
                        ),
                        child: Text(
                          excerpt,
                          key: const ValueKey('pinned-excerpt'),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                    if (from != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        from,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              TextLinkButton(
                key: const ValueKey('pinned-open'),
                label: l.mediaPinnedOpen,
                trailingIcon: Icons.arrow_forward,
                onPressed: () =>
                    _openSource(context, state, holder, pin.sourceId),
              ),
              TextLinkButton(
                key: const ValueKey('pinned-unpin'),
                label: l.mediaUnpin,
                icon: Icons.push_pin_outlined,
                onPressed: () => _unpin(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Attachment? _photo(List<Attachment> list, PinnedMemory pin) {
    for (final a in list) {
      if (a.id == pin.attachmentId) return a;
    }
    return null;
  }

  static String? _fromLine(
    BuildContext context,
    AppState state,
    AttachmentHolder holder,
    String id,
  ) {
    final l = AppLocalizations.of(context);
    switch (holder) {
      case AttachmentHolder.journal:
        for (final e in state.data.journal) {
          if (e.id == id) {
            return l.mediaPinnedFromNote(shortDate(context, e.createdAt));
          }
        }
      case AttachmentHolder.experiment:
        for (final e in state.data.experimentLog) {
          if (e.id == id) {
            return l.mediaPinnedFromTry(formatDateKey(context, e.day));
          }
        }
      case AttachmentHolder.attempt:
        for (final e in state.data.campaignLog) {
          if (e.id == id) {
            return l.mediaPinnedFromAttempt(formatDateKey(context, e.day));
          }
        }
    }
    return null;
  }

  static Future<void> _openSource(
    BuildContext context,
    AppState state,
    AttachmentHolder holder,
    String id,
  ) async {
    switch (holder) {
      case AttachmentHolder.journal:
        await AppNav.openJournalEntry(context, entryId: id);
      case AttachmentHolder.experiment:
        for (final e in state.data.experimentLog) {
          if (e.id == id) {
            final title = state.content.experiment(e.experimentId)?.title;
            await showExperimentEntrySheet(
              context,
              e,
              title: title ?? AppLocalizations.of(context).mediaPinnedTitle,
            );
            return;
          }
        }
      case AttachmentHolder.attempt:
        for (final e in state.data.campaignLog) {
          if (e.id == id) {
            await showAttemptSheet(context, e);
            return;
          }
        }
    }
  }

  static Future<void> _unpin(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    await state.unpinMemory();
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          state.saveStatus == SaveStatus.failed
              ? l.mediaUnpinnedNotSaved
              : l.mediaUnpinned,
        ),
      ),
    );
  }
}
