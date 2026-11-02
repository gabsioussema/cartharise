import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../services/voice_recorder.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'media_kit.dart';

/// Keeps a finished recording on its entry (adds it to a note, a try or an
/// attempt, or creates the note holding it). Returns false when the change
/// is on screen but couldn't be saved on the phone yet; throws when the
/// entry can't hold it any more (the recording is then deleted).
///
/// Called after the sheet may have closed: capture what it needs (the
/// [AppState]) up front, never a [BuildContext].
typedef KeepRecording = Future<bool> Function(Attachment recording);

/// How the recorder sheet ended.
enum RecorderEnd {
  /// Every recording made in the sheet is saved.
  saved,

  /// At least one recording is on screen but not saved on the phone yet.
  notSaved,

  /// The user chose to write instead (microphone off, nothing recorded…).
  writeInstead,
}

class RecorderOutcome {
  const RecorderOutcome(this.end, {this.kept = const []});

  final RecorderEnd end;

  /// The recordings kept, oldest first.
  final List<Attachment> kept;
}

/// Opens the recorder and starts recording at once (the tap on **Record**
/// is the start): the microphone is asked for only now. Shows a clear
/// recording state — the word "Recording" with a dot, the time, a calm
/// level meter and **Stop and save** — announced to screen readers. Stop
/// saves the recording immediately ([keep]) and closes.
///
/// If the app is hidden or a call takes the microphone, what was recorded
/// so far is kept right away and the sheet says so ("Interrupted…") when
/// the user is back. Denied microphone, a failed start or full storage are
/// said plainly, with **Write instead** when [offerWriteInstead]. Never says
/// "saved" for a recording that wasn't. Null when nothing was kept.
Future<RecorderOutcome?> showRecorderSheet(
  BuildContext context, {
  required KeepRecording keep,
  bool offerWriteInstead = true,
}) => showMediaSheet<RecorderOutcome>(
  context,
  // Stop, Discard or Close only: a stray swipe never ends a recording.
  dismissible: false,
  builder: (_) =>
      RecorderSheet(keep: keep, offerWriteInstead: offerWriteInstead),
);

enum _Phase { starting, recording, saving, kept, problem }

class RecorderSheet extends StatefulWidget {
  const RecorderSheet({
    super.key,
    required this.keep,
    this.offerWriteInstead = true,
  });

  final KeepRecording keep;
  final bool offerWriteInstead;

  @override
  State<RecorderSheet> createState() => _RecorderSheetState();
}

class _RecorderSheetState extends State<RecorderSheet> {
  late final AppState _state = context.read<AppState>();
  late final VoiceRecorder _recorder = context.read<VoiceRecorder>();
  late AppLocalizations _l;
  late final AppLifecycleListener _lifecycle;

  _Phase _phase = _Phase.starting;
  bool _disposed = false;

  /// The pending recording's path while recording.
  String? _path;

  /// Seconds shown while recording (the saved length is the recorder's).
  int _seconds = 0;
  Timer? _tick;
  StreamSubscription<VoiceRecorderState>? _states;
  StreamSubscription<double>? _levels;
  double _level = 0;

  String? _problem;
  bool _canRetry = true;

  /// Recordings kept in this sheet, and how the last one ended.
  final List<Attachment> _kept = [];
  bool _allSaved = true;
  bool _lastInterrupted = false;
  Duration _lastLength = Duration.zero;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _onHidden, onPause: _onHidden);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) _start();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l = AppLocalizations.of(context);
  }

  @override
  void dispose() {
    _disposed = true;
    _lifecycle.dispose();
    _stopListening();
    // Closed from elsewhere while recording (e.g. a notification opened
    // another page): keep what was recorded, never drop it.
    if (_phase == _Phase.recording) unawaited(_stop(interrupted: true));
    super.dispose();
  }

  bool get _live => !_disposed && mounted;

  void _set(VoidCallback change) {
    if (_live) setState(change);
  }

  void _say(String message) {
    if (_live) announce(context, message);
  }

  void _stopListening() {
    _tick?.cancel();
    _tick = null;
    unawaited(_states?.cancel());
    unawaited(_levels?.cancel());
    _states = null;
    _levels = null;
  }

  /// The app went to the background mid-recording: keep it now.
  void _onHidden() {
    if (_phase == _Phase.recording) _stop(interrupted: true);
  }

  Future<void> _start() async {
    _set(() {
      _phase = _Phase.starting;
      _problem = null;
      _level = 0;
    });
    final store = _state.attachmentStore;
    final String path;
    try {
      path = await store.newRecordingPath();
    } on Object {
      _fail(_l.mediaRecordStorageFailed);
      return;
    }
    try {
      await _recorder.start(path);
    } on VoiceRecorderException catch (e) {
      await _discardQuietly(path);
      _fail(
        voiceFailureText(_l, e.reason),
        retry: e.reason != VoiceFailure.unavailable,
      );
      return;
    } on Object {
      await _discardQuietly(path);
      _fail(_l.mediaRecordFailed);
      return;
    }
    if (!_live) {
      // Closed while the microphone was starting: nothing was said yet.
      await _recorder.cancel();
      await _discardQuietly(path);
      return;
    }
    _path = path;
    _seconds = 0;
    _tick = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _set(() => _seconds++),
    );
    _states = _recorder.states.listen((s) {
      // A call or another app took the microphone: keep what was said.
      if (s == VoiceRecorderState.paused) _stop(interrupted: true);
    });
    _levels = _recorder.amplitude.listen(
      (v) => _set(() => _level = v.isNaN ? 0 : v.clamp(0.0, 1.0)),
    );
    _set(() => _phase = _Phase.recording);
    _say(_l.mediaRecorderStarted);
  }

  Future<void> _discardQuietly(String path) async {
    try {
      await _state.attachmentStore.discardRecording(path);
    } on Object {
      // Removed with the orphans on the next load.
    }
  }

  void _fail(String message, {bool retry = true}) {
    _set(() {
      _phase = _Phase.problem;
      _problem = message;
      _canRetry = retry;
    });
  }

  /// Stops and keeps the recording: the whole of it, or what was recorded
  /// before an interruption.
  Future<void> _stop({bool interrupted = false}) async {
    if (_phase != _Phase.recording) return;
    _phase = _Phase.saving;
    _set(() {});
    // Read now: the sheet may close while this finishes.
    final keep = widget.keep;
    final path = _path;
    _path = null;
    final elapsed = Duration(seconds: _seconds);
    _stopListening();
    final store = _state.attachmentStore;
    RecordingResult? result;
    try {
      result = await _recorder.stop();
    } on Object {
      // The file may still hold what was recorded: try to keep it below.
    }
    final file = result?.path ?? path;
    if (file == null) {
      _fail(_l.mediaNothingRecorded);
      return;
    }
    final length = result?.duration ?? elapsed;
    final Attachment recording;
    try {
      recording = await store.adoptRecording(
        file,
        durationMs: length.inMilliseconds,
      );
    } on AttachmentException catch (e) {
      await _discardQuietly(file);
      _fail(switch (e.reason) {
        AttachmentFailure.empty ||
        AttachmentFailure.sourceMissing => _l.mediaNothingRecorded,
        _ => _l.mediaRecordStorageFailed,
      });
      return;
    }
    final bool saved;
    try {
      saved = await keep(recording);
    } on Object {
      try {
        await store.delete(recording);
      } on Object {
        // An orphan now: removed on the next load.
      }
      _fail(_l.mediaEntryGone, retry: false);
      return;
    }
    _kept.add(recording);
    _allSaved = _allSaved && saved;
    _lastInterrupted = interrupted || (result?.interrupted ?? false);
    _lastLength = length;
    if (_lastInterrupted) {
      _say(_l.mediaRecorderInterrupted(spokenDuration(_l, length)));
    } else if (saved) {
      _say(_l.mediaRecorderSaved);
    }
    if (!_lastInterrupted && saved && !_disposed && mounted) {
      // Saved immediately: nothing more to decide here.
      Navigator.of(context).pop(_outcome());
      return;
    }
    _set(() => _phase = _Phase.kept);
  }

  RecorderOutcome? _outcome() {
    if (_kept.isEmpty) return null;
    return RecorderOutcome(
      _allSaved ? RecorderEnd.saved : RecorderEnd.notSaved,
      kept: List.unmodifiable(_kept),
    );
  }

  Future<void> _discard() async {
    final ok = await confirmDialog(
      context,
      title: _l.mediaRecorderDiscardTitle,
      body: _l.mediaRecorderDiscardBody,
      action: _l.mediaRecorderDiscard,
      destructive: true,
    );
    if (!ok || _phase != _Phase.recording) return;
    final path = _path;
    _path = null;
    _stopListening();
    _phase = _Phase.saving;
    try {
      await _recorder.cancel();
    } on Object {
      // The partial file is removed below or with the orphans.
    }
    if (path != null) await _discardQuietly(path);
    if (!_disposed && mounted) Navigator.of(context).pop(_outcome());
  }

  void _close() => Navigator.of(context).pop(_outcome());

  void _writeInstead() =>
      Navigator.of(context)
          .pop(RecorderOutcome(RecorderEnd.writeInstead, kept: List.of(_kept)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final busy =
        _phase == _Phase.recording ||
        _phase == _Phase.saving ||
        _phase == _Phase.starting;
    return PopScope<RecorderOutcome>(
      // Back while recording stops and keeps it (never loses it).
      canPop: !busy,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_phase == _Phase.recording) _stop();
        if (_phase == _Phase.starting) {
          _phase = _Phase.problem;
          _close();
        }
      },
      child: SingleChildScrollView(
        // No drag handle on this sheet (it can't be swiped away): its own
        // top margin instead.
        padding: EdgeInsetsDirectional.fromSTEB(
          20,
          24,
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
                l.mediaRecorderTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            ...switch (_phase) {
              _Phase.starting => _starting(context),
              _Phase.recording => _recording(context),
              _Phase.saving => _saving(context),
              _Phase.kept => _keptView(context),
              _Phase.problem => _problemView(context),
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _starting(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return [
      Semantics(
        liveRegion: true,
        child: Row(
          children: [
            Icon(Icons.mic_none, color: p.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _l.mediaRecorderStarting,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: TextLinkButton(label: _l.cancel, onPressed: _close),
      ),
    ];
  }

  List<Widget> _recording(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final elapsed = Duration(seconds: _seconds);
    return [
      // The state is a word (and a dot), never the colour alone.
      Semantics(
        liveRegion: true,
        container: true,
        child: Row(
          key: const ValueKey('recorder-recording'),
          children: [
            Icon(Icons.fiber_manual_record, size: 16, color: p.error),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _l.mediaRecorderRecording,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Semantics(
        label: spokenDuration(_l, elapsed),
        excludeSemantics: true,
        child: Text(
          formatClock(elapsed),
          key: const ValueKey('recorder-time'),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
      const SizedBox(height: 12),
      _LevelMeter(level: _level),
      const SizedBox(height: 24),
      PrimaryButton(
        key: const ValueKey('recorder-stop'),
        label: _l.mediaRecorderStop,
        icon: Icons.stop,
        expand: true,
        onPressed: () => _stop(),
      ),
      const SizedBox(height: 4),
      Center(
        child: TextLinkButton(
          key: const ValueKey('recorder-discard'),
          label: _l.mediaRecorderDiscard,
          icon: Icons.delete_outline,
          onPressed: _discard,
        ),
      ),
    ];
  }

  List<Widget> _saving(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Semantics(
        liveRegion: true,
        child: Text(_l.mediaRecorderSaving, style: theme.textTheme.bodyLarge),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _keptView(BuildContext context) {
    final clock = formatClock(_lastLength);
    return [
      if (_lastInterrupted) ...[
        MediaNotice(
          key: const ValueKey('recorder-interrupted'),
          message: _l.mediaRecorderInterrupted(clock),
          tone: NoticeTone.warning,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ChipTag(
            label: _l.mediaPartial,
            icon: Icons.content_cut,
            tone: ChipTone.warning,
          ),
        ),
      ] else
        MediaNotice(message: _l.mediaRecorderSaved, tone: NoticeTone.done),
      if (!_allSaved) ...[
        const SizedBox(height: 12),
        MediaNotice(
          key: const ValueKey('recorder-not-saved'),
          message: _l.mediaNotSavedYet,
          tone: NoticeTone.error,
          actions: [retrySaveButton(context, after: () => _set(() {}))],
        ),
      ],
      const SizedBox(height: 24),
      PrimaryButton(
        key: const ValueKey('recorder-done'),
        label: _l.done,
        expand: true,
        onPressed: _close,
      ),
      const SizedBox(height: 4),
      Center(
        child: TextLinkButton(
          key: const ValueKey('recorder-again'),
          label: _l.mediaRecorderAgain,
          icon: Icons.mic_none,
          onPressed: _start,
        ),
      ),
    ];
  }

  List<Widget> _problemView(BuildContext context) => [
    MediaNotice(
      key: const ValueKey('recorder-problem'),
      message: _problem ?? _l.mediaRecordFailed,
      tone: NoticeTone.error,
    ),
    const SizedBox(height: 24),
    if (widget.offerWriteInstead)
      PrimaryButton(
        key: const ValueKey('recorder-write-instead'),
        label: _l.mediaWriteInstead,
        icon: Icons.edit_outlined,
        expand: true,
        onPressed: _writeInstead,
      ),
    const SizedBox(height: 4),
    Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        if (_canRetry)
          TextLinkButton(
            key: const ValueKey('recorder-retry'),
            label: _l.tryAgain,
            icon: Icons.refresh,
            onPressed: _start,
          ),
        TextLinkButton(
          key: const ValueKey('recorder-close'),
          label: _l.close,
          onPressed: _close,
        ),
      ],
    ),
  ];
}

/// A calm input-level meter: a row of rounded bars filled up to [level]
/// (0–1). Decorative (the word "Recording" and the time say the state);
/// it moves only as the input does, never on its own.
class _LevelMeter extends StatelessWidget {
  const _LevelMeter({required this.level});

  static const bars = 20;
  final double level;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final lit = (level * bars).ceil();
    return ExcludeSemantics(
      child: SizedBox(
        key: const ValueKey('recorder-level'),
        height: 24,
        child: Row(
          children: [
            for (var i = 0; i < bars; i++) ...[
              if (i > 0) const SizedBox(width: 3),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 0.35 + 0.65 * (i + 1) / bars,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: i < lit ? p.accent : p.raisedHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
