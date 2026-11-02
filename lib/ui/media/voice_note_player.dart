import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../services/voice_player.dart';
import '../../state/app_state.dart';
import '../../state/attachment_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'media_kit.dart';

/// One voice note on an entry: play / pause, the position (a slider to
/// move through it) and the length ("Partial" when it was cut short); the
/// user's own words for it, only ever
/// what they typed (**Type what you said**); and **Remove** (asks first).
///
/// Plays only on a tap, one recording at a time (the shared [VoicePlayer]);
/// leaving the page stops it. A recording whose file is gone says so.
class VoiceNotePlayer extends StatefulWidget {
  const VoiceNotePlayer({
    super.key,
    required this.attachment,
    required this.holder,
    required this.entryId,
    this.onMessage,
  });

  final Attachment attachment;
  final AttachmentHolder holder;
  final String entryId;

  /// What to tell the user after a removal or a transcript change.
  final ValueChanged<MediaMessage>? onMessage;

  @override
  State<VoiceNotePlayer> createState() => _VoiceNotePlayerState();
}

class _VoiceNotePlayerState extends State<VoiceNotePlayer> {
  late final VoicePlayer _player = context.read<VoicePlayer>();
  late final AppState _app = context.read<AppState>();
  final List<StreamSubscription<Object?>> _subs = [];

  /// The file's path once known; null while checking.
  String? _path;
  bool _exists = true;
  bool _failed = false;
  VoicePlayerState _state = VoicePlayerState.stopped;
  Duration _position = Duration.zero;
  Duration? _playerLength;

  /// The slider while it is being dragged.
  double? _dragMs;

  @override
  void initState() {
    super.initState();
    _subs
      ..add(_player.states.listen(_onState))
      ..add(
        _player.position.listen((d) {
          if (_mine && mounted) setState(() => _position = d);
        }),
      )
      ..add(
        _player.duration.listen((d) {
          if (_mine && mounted && d > Duration.zero) {
            setState(() => _playerLength = d);
          }
        }),
      );
    _resolve();
  }

  @override
  void didUpdateWidget(VoiceNotePlayer old) {
    super.didUpdateWidget(old);
    if (old.attachment.fileName != widget.attachment.fileName) _resolve();
  }

  Future<void> _resolve() async {
    final store = _app.attachmentStore;
    final file = await store.fileFor(widget.attachment);
    final exists = await store.exists(widget.attachment);
    if (!mounted) return;
    setState(() {
      _path = file.path;
      _exists = exists;
      if (_mine) _state = _player.state;
    });
  }

  bool get _mine => _path != null && _player.currentPath == _path;

  void _onState(VoicePlayerState s) {
    if (!mounted) return;
    setState(() {
      if (!_mine) {
        // Another recording plays, or this one was stopped. (A start
        // position chosen before playing is kept.)
        if (_state != VoicePlayerState.stopped) _position = Duration.zero;
        _state = VoicePlayerState.stopped;
        return;
      }
      _state = s;
      if (s == VoicePlayerState.completed) _position = Duration.zero;
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    if (_mine) unawaited(_player.stop());
    super.dispose();
  }

  bool get _playing => _mine && _state == VoicePlayerState.playing;

  Duration get _length =>
      _playerLength ??
      Duration(milliseconds: widget.attachment.durationMs ?? 0);

  Future<void> _toggle() async {
    final path = _path;
    if (path == null) return;
    try {
      if (_playing) {
        await _player.pause();
      } else if (_mine && _state == VoicePlayerState.paused) {
        await _player.resume();
      } else {
        // From the start, or from where the slider was set before playing.
        final from = _position;
        await _player.play(path);
        if (from > Duration.zero && from < _length) await _player.seek(from);
      }
      if (mounted && _failed) setState(() => _failed = false);
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// Moves playback there; before playing (or after the end) it only sets
  /// where Play starts: moving the slider never starts the sound itself.
  Future<void> _seek(double ms) async {
    final to = Duration(milliseconds: ms.round());
    setState(() {
      _dragMs = null;
      _position = to;
    });
    if (_mine && _state != VoicePlayerState.completed) {
      await _player.seek(to);
    }
  }

  Future<void> _editWords() async {
    final l = AppLocalizations.of(context);
    final before = widget.attachment.transcript;
    final text = await askText(
      context,
      title: l.mediaTranscriptTitle,
      label: l.mediaTranscriptLabel,
      action: l.save,
      initial: before,
      maxLines: 6,
    );
    if (text == null) return;
    // Exactly as typed; nothing typed = no words.
    final words = text.trim().isEmpty ? null : text;
    if (words == before) return;
    try {
      await _app.setAttachmentTranscript(
        widget.holder,
        widget.entryId,
        widget.attachment.id,
        words,
      );
    } on ArgumentError {
      widget.onMessage?.call(
        MediaMessage(l.mediaEntryGone, tone: NoticeTone.error),
      );
      return;
    }
    widget.onMessage?.call(
      _app.saveStatus == SaveStatus.failed
          ? MediaMessage(
              l.mediaNotSavedYet,
              tone: NoticeTone.error,
              retry: true,
            )
          : MediaMessage(l.mediaTranscriptSaved, tone: NoticeTone.done),
    );
  }

  Future<void> _remove() async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.mediaVoiceRemoveTitle,
      body: l.mediaVoiceRemoveBody,
      action: l.mediaRemove,
      destructive: true,
    );
    if (!ok) return;
    if (_mine) await _player.stop();
    await _app.removeAttachment(
      widget.holder,
      widget.entryId,
      widget.attachment.id,
    );
    widget.onMessage?.call(
      _app.saveStatus == SaveStatus.failed
          ? MediaMessage(
              l.mediaRemovedNotSaved,
              tone: NoticeTone.error,
              retry: true,
            )
          : MediaMessage(l.mediaVoiceRemoved, tone: NoticeTone.done),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final id = widget.attachment.id;
    final length = _length;
    final lengthMs = length.inMilliseconds.toDouble();
    final positionMs = (_dragMs ?? _position.inMilliseconds.toDouble()).clamp(
      0.0,
      lengthMs <= 0 ? 0.0 : lengthMs,
    );
    final canSeek = _path != null && lengthMs > 0 && _exists;
    final words = widget.attachment.transcript;
    final tabular = theme.textTheme.bodySmall?.copyWith(
      color: p.textSecondary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Container(
      key: ValueKey('voice-note-$id'),
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 4, 8),
      decoration: BoxDecoration(
        color: p.raised,
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                key: ValueKey('voice-play-$id'),
                tooltip: _playing ? l.mediaPause : l.mediaPlay,
                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
                onPressed: _path == null || !_exists ? null : _toggle,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Voice note" and where it is, on one line (two when
                    // the text is large); the slider under them.
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.graphic_eq, size: 16, color: p.accent),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  l.mediaVoiceNote,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          // A recording cut short says so wherever it
                          // plays (a word and an icon, not colour alone).
                          if (widget.attachment.interrupted)
                            ChipTag(
                              key: ValueKey('voice-partial-$id'),
                              label: l.mediaPartial,
                              icon: Icons.content_cut,
                              tone: ChipTone.warning,
                            ),
                          Text(
                            '${formatClock(Duration(milliseconds: positionMs.round()))}'
                            ' / ${formatClock(length)}',
                            key: ValueKey('voice-time-$id'),
                            style: tabular,
                            semanticsLabel: l.mediaPositionOf(
                              spokenDuration(
                                l,
                                Duration(milliseconds: positionMs.round()),
                              ),
                              spokenDuration(l, length),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      key: ValueKey('voice-slider-$id'),
                      value: lengthMs <= 0 ? 0 : positionMs,
                      max: lengthMs <= 0 ? 1 : lengthMs,
                      semanticFormatterCallback: (v) => l.mediaPositionOf(
                        spokenDuration(l, Duration(milliseconds: v.round())),
                        spokenDuration(l, length),
                      ),
                      onChanged: canSeek
                          ? (v) => setState(() => _dragMs = v)
                          : null,
                      onChangeEnd: canSeek ? _seek : null,
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('voice-remove-$id'),
                tooltip: l.mediaVoiceRemove,
                icon: Icon(Icons.delete_outline, color: p.textSecondary),
                onPressed: _remove,
              ),
            ],
          ),
          if (!_exists || _failed)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
              child: Semantics(
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18,
                      color: p.onErrorContainer,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        !_exists ? l.mediaVoiceMissing : l.mediaPlayFailed,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (words != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 8, 0),
              // The user's own words, exactly as typed.
              child: Text(
                words,
                key: ValueKey('voice-words-$id'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextLinkButton(
              key: ValueKey('voice-words-edit-$id'),
              label: words == null
                  ? l.mediaTranscriptAdd
                  : l.mediaTranscriptEdit,
              icon: words == null
                  ? Icons.keyboard_outlined
                  : Icons.edit_outlined,
              onPressed: _editWords,
            ),
          ),
        ],
      ),
    );
  }
}
