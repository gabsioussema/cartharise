import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../content/content.dart';
import '../../domain/language.dart';
import '../../l10n/app_localizations.dart';
import '../../services/read_aloud.dart';
import '../../services/read_aloud_platform.dart' show isSilentMode;
import '../../state/app_state.dart';
import '../media/media_kit.dart' show announce;
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// Who is reading aloud now, per [ReadAloud] (one text at a time): starting
/// one **Listen** turns every other one back into **Listen**.
class _ListenSession extends ChangeNotifier {
  Object? owner;

  /// Whether a language can be read aloud, asked once per tag.
  final Map<String, Future<bool>> availability = {};

  void take(Object who) {
    if (owner == who) return;
    owner = who;
    notifyListeners();
  }

  /// [notify] is false from `dispose`, where the tree is locked.
  void release(Object who, {bool notify = true}) {
    if (owner != who) return;
    owner = null;
    if (notify) notifyListeners();
  }
}

final _sessions = Expando<_ListenSession>('listen');

_ListenSession _sessionOf(ReadAloud voice) =>
    _sessions[voice] ??= _ListenSession();

/// Coverage per language, worked out once (the content is constant).
final Map<AppLanguage, ContentCoverage> _coverage = {};

/// The language to read the content item [id] in: the app's language when
/// the item is translated, else English (the content falls back to English
/// per item, and an English text read with a French voice is hard to
/// follow).
String contentListenTag(BuildContext context, ContentKind kind, String id) {
  final appTag = Localizations.localeOf(context).toLanguageTag();
  final language = context.read<AppState>().language;
  if (language == AppLanguage.en || language == AppLanguage.system) {
    return appTag;
  }
  final coverage = _coverage[language] ??= coverageFor(language);
  final translated = coverage.translated[kind] ?? const [];
  return translated.contains(id) ? appTag : AppLanguage.en.code!;
}

/// **Listen** (plan step 3 › H): reads a lesson, a question or — only on
/// this explicit tap — the user's own words aloud with the phone's own
/// voice ([ReadAloud]); **Stop reading** ends it at once.
///
/// * One at a time: starting one stops any other.
/// * Stops when the button goes away, when its page is covered or its tab
///   left (`TickerMode`), and when the app is hidden. It is kept alive in a
///   lazy list while it reads, so scrolling doesn't stop it.
/// * Hidden where the phone can't read the language aloud; a failure is one
///   honest line under it (no voice, silent mode, unavailable, failed).
/// * Screen readers hear when reading starts and stops.
/// * The text is passed to the phone's voice only; never logged or kept.
///
/// A quiet link with an icon and the word, at the start of its line (or
/// next to another link in a `Wrap`).
class ListenButton extends StatefulWidget {
  const ListenButton({
    super.key,
    required this.text,
    this.label,
    this.languageTag,
    this.watch,
  });

  /// What to read, asked at the tap (a note being written reads as it is
  /// then). Blank: the button hides.
  final String Function() text;

  /// The button's word: **Listen** by default; **Listen to my note** /
  /// **Listen to my answer** for the user's own words.
  final String? label;

  /// BCP 47 tag of [text]; the app's language when null.
  final String? languageTag;

  /// Rebuilds when this changes (e.g. the field's controller), so the
  /// button shows once there is text.
  final Listenable? watch;

  @override
  State<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<ListenButton>
    with AutomaticKeepAliveClientMixin {
  ReadAloud? _voice;
  _ListenSession? _session;
  StreamSubscription<bool>? _speaking;
  late final AppLifecycleListener _lifecycle;

  /// Null until the phone answered for [_checkedTag].
  bool? _available;
  String? _checkedTag;
  bool _starting = false;

  /// The honest line after a failure.
  String? _problem;

  bool get _reading => _session?.owner == this && (_voice?.isSpeaking ?? false);

  @override
  bool get wantKeepAlive => _starting || _reading;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _stopQuietly);
    widget.watch?.addListener(_changed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final voice = context.read<ReadAloud>();
    if (!identical(voice, _voice)) {
      _session?.removeListener(_changed);
      unawaited(_speaking?.cancel());
      _voice = voice;
      _session = _sessionOf(voice)..addListener(_changed);
      _speaking = voice.speaking.listen(_speakingChanged);
      _checkedTag = null;
    }
    _check();
    // Covered by another page or its tab left: stop.
    if (!TickerMode.valuesOf(context).enabled) _stopQuietly();
  }

  @override
  void didUpdateWidget(ListenButton old) {
    super.didUpdateWidget(old);
    if (old.watch != widget.watch) {
      old.watch?.removeListener(_changed);
      widget.watch?.addListener(_changed);
    }
    if (old.languageTag != widget.languageTag) _check();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    widget.watch?.removeListener(_changed);
    _session?.removeListener(_changed);
    unawaited(_speaking?.cancel());
    // Leaving the page stops the voice (without notifying: tree locked).
    if (_session?.owner == this) {
      _session!.release(this, notify: false);
      unawaited(_voice?.stop());
    }
    super.dispose();
  }

  String get _tag =>
      widget.languageTag ?? Localizations.localeOf(context).toLanguageTag();

  void _check() {
    final tag = _tag;
    if (tag == _checkedTag) return;
    _checkedTag = tag;
    _available = null;
    final voice = _voice!;
    final asked = _session!.availability[tag] ??= voice
        .available(tag)
        .catchError((Object _) => false);
    asked.then((ok) {
      if (mounted && _checkedTag == tag) setState(() => _available = ok);
    });
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _speakingChanged(bool speaking) {
    if (!mounted) return;
    if (!speaking) _session?.release(this, notify: false);
    setState(() {});
    updateKeepAlive();
  }

  /// Stops without a word (page covered, app hidden).
  void _stopQuietly() {
    if (_session?.owner != this) return;
    _session!.release(this, notify: false);
    unawaited(_voice?.stop());
  }

  Future<void> _toggle() async {
    final l = AppLocalizations.of(context);
    final voice = _voice!;
    if (_reading) {
      _session!.release(this);
      await voice.stop();
      if (!mounted) return;
      announce(context, l.listenStopped);
      setState(() {});
      updateKeepAlive();
      return;
    }
    final text = widget.text().trim();
    if (text.isEmpty) return;
    final tag = _tag;
    setState(() {
      _starting = true;
      _problem = null;
    });
    updateKeepAlive();
    _session!.take(this);
    String? problem;
    try {
      await voice.speak(text, languageTag: tag);
    } on ReadAloudException catch (e) {
      _session!.release(this);
      problem = switch (e.reason) {
        ReadAloudFailure.noVoice => l.listenNoVoice,
        ReadAloudFailure.unavailable => l.listenUnavailable,
        ReadAloudFailure.failed when isSilentMode(e) => l.listenSilent,
        ReadAloudFailure.failed => l.listenFailed,
      };
    }
    if (!mounted) return;
    setState(() {
      _starting = false;
      _problem = problem;
    });
    updateKeepAlive();
    // Nothing to say when it was stopped or replaced while starting.
    if (problem != null) {
      announce(context, problem);
    } else if (_reading) {
      announce(context, l.listenStarted);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_available != true) return const SizedBox.shrink();
    final reading = _reading;
    if (!reading && !_starting && widget.text().trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = CarthaPalette.of(context);
    final label = reading ? l.listenStop : (widget.label ?? l.listenAction);
    final onPressed = _starting ? null : _toggle;
    final problem = _problem;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          button: true,
          enabled: onPressed != null,
          label: label,
          excludeSemantics: true,
          onTap: onPressed,
          child: TextLinkButton(
            label: label,
            icon: reading
                ? Icons.stop_circle_outlined
                : Icons.volume_up_outlined,
            onPressed: onPressed,
          ),
        ),
        if (reading)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, bottom: 4),
            child: Text(
              l.listenHearHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ),
        if (problem != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, bottom: 4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                problem,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
