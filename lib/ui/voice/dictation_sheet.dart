import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/dictation.dart';
import '../media/media_kit.dart';
import '../theme/cartha_theme.dart';
import '../widgets/bidi.dart';
import '../widgets/widgets.dart';

/// What the user chose in the dictation sheet.
enum DictationEnd {
  /// Put the reviewed text into the field ([DictationOutcome.text]).
  insert,

  /// Dictation can't run: record a voice note instead.
  recordInstead,

  /// Dictation can't run (or wasn't wanted): type instead.
  typeInstead,
}

class DictationOutcome {
  const DictationOutcome.insert(String this.text) : end = DictationEnd.insert;
  const DictationOutcome.recordInstead()
    : end = DictationEnd.recordInstead,
      text = null;
  const DictationOutcome.typeInstead()
    : end = DictationEnd.typeInstead,
      text = null;

  final DictationEnd end;

  /// The text to insert, exactly as reviewed (only for [DictationEnd.insert]).
  final String? text;
}

/// Why dictation can't run now, in plain words (never "dictating").
String dictationAvailabilityText(
  AppLocalizations l,
  DictationAvailability availability,
) => switch (availability) {
  DictationAvailability.available => l.voiceFailed,
  DictationAvailability.needsModel => l.voiceNeedsModel,
  DictationAvailability.unsupported => l.voiceUnsupported,
  DictationAvailability.noPermission => l.voiceNoPermission,
  DictationAvailability.tooOld => l.voiceTooOld,
};

/// Why a dictation stopped, in plain words.
String dictationFailureText(AppLocalizations l, DictationFailure failure) =>
    switch (failure) {
      DictationFailure.noPermission => l.voiceNoPermission,
      DictationFailure.unsupported => l.voiceUnsupported,
      DictationFailure.needsModel => l.voiceNeedsModel,
      DictationFailure.tooOld => l.voiceTooOld,
      DictationFailure.noSpeech => l.voiceNothingHeard,
      DictationFailure.interrupted => l.voiceInterrupted,
      DictationFailure.busy => l.voiceBusy,
      DictationFailure.failed => l.voiceFailed,
    };

/// Whether trying again could help (the user may fix it, or it was
/// momentary); never for a phone that can't dictate the language at all.
bool _retryHelps(DictationFailure failure) => switch (failure) {
  DictationFailure.unsupported || DictationFailure.tooOld => false,
  _ => true,
};

DictationFailure _failureOf(DictationAvailability availability) =>
    switch (availability) {
      DictationAvailability.available => DictationFailure.failed,
      DictationAvailability.needsModel => DictationFailure.needsModel,
      DictationAvailability.unsupported => DictationFailure.unsupported,
      DictationAvailability.noPermission => DictationFailure.noPermission,
      DictationAvailability.tooOld => DictationFailure.tooOld,
    };

/// Opens the dictation sheet and starts listening at once (the tap on
/// **Dictate** is the start): the phone checks its on-device recognizer for
/// [languageTag] first, without asking for anything; the microphone and
/// speech permission may be asked for only now.
///
/// While listening: the word "Listening" with a dot, the words heard so
/// far, a calm level meter, **Stop** and **Cancel** — announced to screen
/// readers. Stop shows the full text in an editable field for review:
/// **Insert** returns it ([DictationEnd.insert]); **Discard** (asked first)
/// returns null. Nothing is ever inserted on its own.
///
/// When the phone can't dictate (no on-device recognizer, the language pack
/// missing, permission off, system too old), or dictation fails with
/// nothing heard, one honest line says so, with **Record instead** (when
/// [offerRecord]) and **Type instead**. Text heard before a failure is kept
/// for review, never dropped.
Future<DictationOutcome?> showDictationSheet(
  BuildContext context, {
  required String languageTag,
  bool offerRecord = false,
}) => showMediaSheet<DictationOutcome>(
  context,
  // Stop, Insert, Discard or Close only: a stray swipe never drops words.
  dismissible: false,
  builder: (_) =>
      DictationSheet(languageTag: languageTag, offerRecord: offerRecord),
);

enum _Phase { starting, listening, finishing, review, problem }

class DictationSheet extends StatefulWidget {
  const DictationSheet({
    super.key,
    required this.languageTag,
    this.offerRecord = false,
  });

  /// BCP 47, usually the app's locale.
  final String languageTag;

  /// Offer **Record instead** when dictation can't run.
  final bool offerRecord;

  @override
  State<DictationSheet> createState() => _DictationSheetState();
}

class _DictationSheetState extends State<DictationSheet> {
  /// How long Stop waits for the recognizer's final text before keeping
  /// what was heard so far.
  static const _finishGrace = Duration(seconds: 6);

  late final Dictation _dictation = context.read<Dictation>();
  late AppLocalizations _l;
  late final AppLifecycleListener _lifecycle;
  final _review = TextEditingController();

  _Phase _phase = _Phase.starting;
  bool _disposed = false;
  StreamSubscription<DictationEvent>? _events;
  Timer? _finishing;

  /// The latest text heard (replaced by each partial), the final text, and
  /// the failure, if any.
  String _heard = '';
  String? _final;
  DictationFailure? _failure;
  double _level = 0;

  String? _problem;
  bool _canRetry = true;
  bool _stoppedEarly = false;

  @override
  void initState() {
    super.initState();
    // The app hidden mid-dictation: stop and keep what was heard for review.
    _lifecycle = AppLifecycleListener(onHide: _stop, onPause: _stop);
    _review.addListener(_reviewChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_live) _start();
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
    _finishing?.cancel();
    // Closed from elsewhere while listening: stop the microphone; nothing
    // is inserted.
    if (_phase == _Phase.listening || _phase == _Phase.finishing) {
      unawaited(_dictation.cancel());
    }
    unawaited(_events?.cancel());
    _review.dispose();
    super.dispose();
  }

  bool get _live => !_disposed && mounted;

  void _set(VoidCallback change) {
    if (_live) setState(change);
  }

  void _say(String message) {
    if (_live) announce(context, message);
  }

  void _reviewChanged() => _set(() {});

  Future<void> _start() async {
    _set(() {
      _phase = _Phase.starting;
      _heard = '';
      _final = null;
      _failure = null;
      _level = 0;
      _problem = null;
      _stoppedEarly = false;
    });
    DictationAvailability availability;
    try {
      availability = await _dictation.availability(widget.languageTag);
    } on Object {
      availability = DictationAvailability.unsupported;
    }
    if (!_live || _phase != _Phase.starting) return;
    if (availability != DictationAvailability.available) {
      _fail(
        dictationAvailabilityText(_l, availability),
        retry: _retryHelps(_failureOf(availability)),
      );
      return;
    }
    _events = _dictation
        .start(widget.languageTag)
        .listen(
          _onEvent,
          onError: (Object _) {
            _failure ??= DictationFailure.failed;
            _ended();
          },
          onDone: _ended,
        );
    _set(() => _phase = _Phase.listening);
    _say(_l.voiceListeningStarted);
  }

  void _onEvent(DictationEvent event) {
    switch (event) {
      case DictationPartial(:final text):
        _set(() => _heard = text);
      case DictationLevel(:final level):
        _set(() => _level = level.isNaN ? 0 : level.clamp(0.0, 1.0));
      case DictationFinal(:final text):
        _final = text;
      case DictationError(:final reason):
        _failure = reason;
      case DictationEnded():
        _ended();
    }
  }

  /// The dictation is over: its text goes to review (never into the field),
  /// or, with nothing heard, the reason is said.
  void _ended() {
    if (_phase != _Phase.listening && _phase != _Phase.finishing) return;
    _finishing?.cancel();
    _finishing = null;
    unawaited(_events?.cancel());
    _events = null;
    final finalText = _final;
    final text = finalText != null && finalText.trim().isNotEmpty
        ? finalText
        : _heard;
    final failure = _failure;
    if (text.trim().isNotEmpty) {
      _review.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
      _set(() {
        _phase = _Phase.review;
        _stoppedEarly = failure != null;
      });
      _say(_l.voiceReviewReady);
      return;
    }
    if (failure != null && failure != DictationFailure.noSpeech) {
      _fail(dictationFailureText(_l, failure), retry: _retryHelps(failure));
    } else {
      _fail(_l.voiceNothingHeard);
    }
  }

  void _fail(String message, {bool retry = true}) {
    _set(() {
      _phase = _Phase.problem;
      _problem = message;
      _canRetry = retry;
    });
  }

  /// Stops listening; the full text arrives for review.
  void _stop() {
    if (_phase != _Phase.listening) return;
    _set(() => _phase = _Phase.finishing);
    // If the recognizer never answers, keep what was heard so far.
    _finishing = Timer(_finishGrace, () {
      if (_phase != _Phase.finishing) return;
      unawaited(_dictation.cancel());
      _ended();
    });
    unawaited(
      _dictation.stop().catchError((Object _) {
        _failure ??= DictationFailure.failed;
        _ended();
      }),
    );
  }

  /// Cancel while listening: nothing is inserted (asked first when words
  /// were already heard).
  Future<void> _cancel() async {
    if (_heard.trim().isNotEmpty && !await _confirmDiscard()) return;
    if (!_live) return;
    if (_phase == _Phase.listening || _phase == _Phase.finishing) {
      _phase = _Phase.problem;
      _finishing?.cancel();
      unawaited(_events?.cancel());
      _events = null;
      unawaited(_dictation.cancel());
    }
    _close();
  }

  Future<bool> _confirmDiscard() => confirmDialog(
    context,
    title: _l.voiceDiscardTitle,
    body: _l.voiceDiscardBody,
    action: _l.voiceDiscard,
    cancel: _l.voiceKeep,
    destructive: true,
  );

  Future<void> _discard() async {
    if (_review.text.trim().isNotEmpty && !await _confirmDiscard()) return;
    if (_live) _close();
  }

  void _close([DictationOutcome? outcome]) {
    if (_live) Navigator.of(context).pop(outcome);
  }

  void _insert() {
    final text = _review.text;
    if (text.trim().isEmpty) return;
    _close(DictationOutcome.insert(text));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return PopScope<DictationOutcome>(
      // Back never drops words: while listening it stops (the text goes to
      // review); in review it asks before discarding.
      canPop: _phase == _Phase.problem || _phase == _Phase.starting,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          if (_phase == _Phase.starting) _phase = _Phase.problem;
          return;
        }
        if (_phase == _Phase.listening) _stop();
        if (_phase == _Phase.review) _discard();
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
              child: Text(l.voiceSheetTitle, style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            ...switch (_phase) {
              _Phase.starting => _starting(context),
              _Phase.listening => _listening(context),
              _Phase.finishing => _finishingView(context),
              _Phase.review => _reviewView(context),
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
            Icon(Icons.keyboard_voice_outlined, color: p.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_l.voiceStarting, style: theme.textTheme.bodyLarge),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: TextLinkButton(
          key: const ValueKey('dictation-cancel'),
          label: _l.voiceCancel,
          onPressed: _close,
        ),
      ),
    ];
  }

  /// "Recognised on this phone. Nothing is sent." — quiet, with an icon.
  Widget _onPhone(BuildContext context) {
    final p = CarthaPalette.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 1),
          child: Icon(Icons.lock_outline, size: 16, color: p.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _l.voiceOnPhone,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: p.textSecondary),
          ),
        ),
      ],
    );
  }

  List<Widget> _listening(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return [
      // The state is a word (and a dot), never the colour alone.
      Semantics(
        liveRegion: true,
        container: true,
        child: Row(
          key: const ValueKey('dictation-listening'),
          children: [
            Icon(Icons.fiber_manual_record, size: 16, color: p.error),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _l.voiceListening,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      _onPhone(context),
      const SizedBox(height: 14),
      _HeardBox(text: _heard),
      const SizedBox(height: 12),
      _DictationLevel(level: _level),
      const SizedBox(height: 24),
      PrimaryButton(
        key: const ValueKey('dictation-stop'),
        label: _l.voiceStop,
        icon: Icons.stop,
        expand: true,
        onPressed: _stop,
      ),
      const SizedBox(height: 4),
      Center(
        child: TextLinkButton(
          key: const ValueKey('dictation-cancel'),
          label: _l.voiceCancel,
          onPressed: _cancel,
        ),
      ),
    ];
  }

  List<Widget> _finishingView(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Semantics(
        liveRegion: true,
        child: Text(
          _l.voiceFinishing,
          key: const ValueKey('dictation-finishing'),
          style: theme.textTheme.bodyLarge,
        ),
      ),
      const SizedBox(height: 14),
      _HeardBox(text: _heard),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _reviewView(BuildContext context) => [
    if (_stoppedEarly) ...[
      MediaNotice(
        key: const ValueKey('dictation-stopped-early'),
        message: _l.voiceStoppedEarly,
        tone: NoticeTone.warning,
      ),
      const SizedBox(height: 16),
    ],
    TypedDirection(
      controller: _review,
      builder: (context, direction) => TextField(
        key: const ValueKey('dictation-review'),
        controller: _review,
        textDirection: direction,
        minLines: 3,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: _l.voiceReviewLabel,
          helperText: _l.voiceReviewHint,
          helperMaxLines: 3,
          alignLabelWithHint: true,
        ),
      ),
    ),
    const SizedBox(height: 20),
    PrimaryButton(
      key: const ValueKey('dictation-insert'),
      label: _l.voiceInsert,
      icon: Icons.check,
      expand: true,
      onPressed: _review.text.trim().isEmpty ? null : _insert,
    ),
    const SizedBox(height: 4),
    Center(
      child: TextLinkButton(
        key: const ValueKey('dictation-discard'),
        label: _l.voiceDiscard,
        icon: Icons.delete_outline,
        onPressed: _discard,
      ),
    ),
  ];

  List<Widget> _problemView(BuildContext context) => [
    MediaNotice(
      key: const ValueKey('dictation-problem'),
      message: _problem ?? _l.voiceFailed,
      tone: NoticeTone.warning,
    ),
    const SizedBox(height: 24),
    if (widget.offerRecord) ...[
      PrimaryButton(
        key: const ValueKey('dictation-record-instead'),
        label: _l.voiceRecordInstead,
        icon: Icons.mic_none,
        expand: true,
        onPressed: () => _close(const DictationOutcome.recordInstead()),
      ),
      const SizedBox(height: 8),
      SecondaryButton(
        key: const ValueKey('dictation-type-instead'),
        label: _l.voiceTypeInstead,
        icon: Icons.edit_outlined,
        expand: true,
        onPressed: () => _close(const DictationOutcome.typeInstead()),
      ),
    ] else
      PrimaryButton(
        key: const ValueKey('dictation-type-instead'),
        label: _l.voiceTypeInstead,
        icon: Icons.edit_outlined,
        expand: true,
        onPressed: () => _close(const DictationOutcome.typeInstead()),
      ),
    const SizedBox(height: 4),
    Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        if (_canRetry)
          TextLinkButton(
            key: const ValueKey('dictation-retry'),
            label: _l.tryAgain,
            icon: Icons.refresh,
            onPressed: _start,
          ),
        TextLinkButton(
          key: const ValueKey('dictation-close'),
          label: _l.close,
          onPressed: _close,
        ),
      ],
    ),
  ];
}

/// The words heard so far, in a box like the field they will be reviewed in
/// (never a live region: a screen reader would read every change). Its
/// label says what it is.
class _HeardBox extends StatelessWidget {
  const _HeardBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final empty = text.trim().isEmpty;
    return Semantics(
      container: true,
      label: l.voiceHeardLabel,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 88),
        child: Container(
          key: const ValueKey('dictation-heard'),
          padding: const EdgeInsetsDirectional.all(14),
          decoration: BoxDecoration(
            color: p.input,
            borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
            border: Border.all(color: p.border),
          ),
          child: Text(
            empty ? l.voiceSpeakNow : text,
            style: empty
                ? theme.textTheme.bodyLarge?.copyWith(color: p.textSecondary)
                : theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

/// A calm input-level meter: a row of rounded bars filled up to [level]
/// (0–1). Decorative (the word "Listening" says the state); it moves only
/// as the voice does, never on its own.
class _DictationLevel extends StatelessWidget {
  const _DictationLevel({required this.level});

  static const bars = 20;
  final double level;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final lit = (level * bars).ceil();
    return ExcludeSemantics(
      child: SizedBox(
        key: const ValueKey('dictation-level'),
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
