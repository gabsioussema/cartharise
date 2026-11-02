/// Photos and recordings on notes, experiments tried and attempts, and the
/// pinned memory — operations on top of [AppState.mutate] (step 2.0
/// contracts, used by the media feature).
///
/// Files come from the [AppState.attachmentStore] (`importFile` for a
/// picked photo, `newRecordingPath` + `adoptRecording` for a recording);
/// these ops only record them on an entry, change their transcript, or
/// remove them (the file goes once the removal is saved).
library;

import '../domain/app_data.dart';
import 'app_state.dart';

extension AttachmentOps on AppState {
  /// Which kind of entry [entryId] is, or null when there is none.
  AttachmentHolder? holderOf(String entryId) {
    if (data.journal.any((e) => e.id == entryId)) {
      return AttachmentHolder.journal;
    }
    if (data.experimentLog.any((e) => e.id == entryId)) {
      return AttachmentHolder.experiment;
    }
    if (data.campaignLog.any((e) => e.id == entryId)) {
      return AttachmentHolder.attempt;
    }
    return null;
  }

  /// Adds [attachment] (already in the attachment store) to the entry
  /// [entryId] of [holder], after the ones it has. Throws [ArgumentError]
  /// when there is no such entry.
  Future<void> addAttachment(
    AttachmentHolder holder,
    String entryId,
    Attachment attachment,
  ) {
    if (holderOf(entryId) != holder) {
      throw ArgumentError.value(entryId, 'entryId', 'is not a ${holder.name}');
    }
    return mutate(
      (d) => _withAttachments(d, holder, entryId, (list) {
        if (list.any((a) => a.id == attachment.id)) return list;
        return [...list, attachment];
      }),
    );
  }

  /// Removes the attachment [attachmentId] from the entry, and the pinned
  /// memory showing it; its file is deleted once that is saved.
  Future<void> removeAttachment(
    AttachmentHolder holder,
    String entryId,
    String attachmentId,
  ) async {
    final removed = [
      for (final a in data.attachmentsOf(holder, entryId))
        if (a.id == attachmentId) a,
    ];
    if (removed.isEmpty) return;
    await mutate(
      (d) => AppState.withoutPinFrom(
        _withAttachments(d, holder, entryId, (list) {
          return [
            for (final a in list)
              if (a.id != attachmentId) a,
          ];
        }),
        entryId,
        attachmentId: attachmentId,
      ),
    );
    await releaseAttachments(removed);
  }

  /// Sets the user's own transcript of a recording, exactly as typed (null
  /// removes it). Never filled in by the app. Throws [ArgumentError] for an
  /// attachment the entry doesn't have.
  Future<void> setAttachmentTranscript(
    AttachmentHolder holder,
    String entryId,
    String attachmentId,
    String? transcript,
  ) {
    if (!data.attachmentsOf(holder, entryId).any((a) => a.id == attachmentId)) {
      throw ArgumentError.value(attachmentId, 'attachmentId', 'is unknown');
    }
    return mutate(
      (d) => _withAttachments(d, holder, entryId, (list) {
        return [
          for (final a in list)
            if (a.id == attachmentId)
              a.copyWith(transcript: () => transcript)
            else
              a,
        ];
      }),
    );
  }

  static AppData _withAttachments(
    AppData d,
    AttachmentHolder holder,
    String entryId,
    List<Attachment> Function(List<Attachment>) change,
  ) => switch (holder) {
    AttachmentHolder.journal => d.copyWith(
      journal: [
        for (final e in d.journal)
          if (e.id == entryId)
            e.copyWith(attachments: change(e.attachments))
          else
            e,
      ],
    ),
    AttachmentHolder.experiment => d.copyWith(
      experimentLog: [
        for (final e in d.experimentLog)
          if (e.id == entryId)
            e.copyWith(attachments: change(e.attachments))
          else
            e,
      ],
    ),
    AttachmentHolder.attempt => d.copyWith(
      campaignLog: [
        for (final e in d.campaignLog)
          if (e.id == entryId)
            e.copyWith(attachments: change(e.attachments))
          else
            e,
      ],
    ),
  };

  // ── The pinned memory ────────────────────────────────────────────────────

  PinnedMemory? get pinnedMemory => data.pinnedMemory;

  /// The user's own words on the entry [entryId] — what a pinned passage
  /// may be copied from: a note's title and body, an experiment's note, an
  /// attempt and its learning, and the transcripts of its recordings.
  List<String> entryWords(String entryId) {
    for (final e in data.journal) {
      if (e.id == entryId) {
        return [?e.title, e.body, ..._transcripts(e.attachments)];
      }
    }
    for (final e in data.experimentLog) {
      if (e.id == entryId) return [e.note, ..._transcripts(e.attachments)];
    }
    for (final e in data.campaignLog) {
      if (e.id == entryId) {
        return [e.attempt, e.learning, ..._transcripts(e.attachments)];
      }
    }
    return const [];
  }

  static Iterable<String> _transcripts(List<Attachment> list) => [
    for (final a in list)
      if (a.transcript != null) a.transcript!,
  ];

  /// Pins one memory (replacing the one pinned before):
  ///
  /// * [PinnedKind.passage]: [excerpt] — the user's own words, copied
  ///   exactly from the entry [sourceId] (it must appear there verbatim:
  ///   the app never rewrites or summarises them);
  /// * [PinnedKind.photo]: [attachmentId], a photo on that entry, with an
  ///   optional [excerpt] (verbatim too).
  ///
  /// Throws [ArgumentError] for anything else; nothing changes then.
  Future<void> pinMemory({
    required PinnedKind kind,
    required String sourceId,
    String? attachmentId,
    String? excerpt,
  }) {
    final holder = holderOf(sourceId);
    if (holder == null) {
      throw ArgumentError.value(sourceId, 'sourceId', 'is not an entry');
    }
    if (excerpt != null) {
      if (excerpt.trim().isEmpty) {
        throw ArgumentError.value(excerpt, 'excerpt', 'is blank');
      }
      if (!entryWords(sourceId).any((w) => w.contains(excerpt))) {
        throw ArgumentError.value(
          excerpt,
          'excerpt',
          'is not the entry\'s own words',
        );
      }
    }
    switch (kind) {
      case PinnedKind.passage:
        if (excerpt == null) {
          throw ArgumentError.notNull('excerpt');
        }
      case PinnedKind.photo:
        final photo = [
          for (final a in data.attachmentsOf(holder, sourceId))
            if (a.id == attachmentId && a.kind == AttachmentKind.photo) a,
        ];
        if (photo.isEmpty) {
          throw ArgumentError.value(
            attachmentId,
            'attachmentId',
            'is not a photo on that entry',
          );
        }
    }
    final pin = PinnedMemory(
      kind: kind,
      sourceId: sourceId,
      attachmentId: kind == PinnedKind.photo ? attachmentId : null,
      excerpt: excerpt,
      pinnedAt: now(),
    );
    return mutate((d) => d.copyWith(pinnedMemory: () => pin));
  }

  /// Unpins the memory (its entry is untouched).
  Future<void> unpinMemory() {
    if (data.pinnedMemory == null) return Future.value();
    return mutate((d) => d.copyWith(pinnedMemory: () => null));
  }
}
