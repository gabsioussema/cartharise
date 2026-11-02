import 'dart:async';

import 'package:flutter/material.dart';

import '../voice/dictate_button.dart';
import '../widgets/bidi.dart';

/// Debounced autosave for the Compass + Missions text fields (PLAN.md §5):
/// saves the text exactly as typed ~600 ms after the last keystroke, on
/// [flush] (focus lost, day switched, sheet opened), when the app leaves the
/// foreground, and on [dispose] — so switching apps or screens never loses
/// input.
///
/// Create it in `State.initState` (it registers an [AppLifecycleListener]).
class Autosaver {
  Autosaver(this._save, {this.delay = const Duration(milliseconds: 600)}) {
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        if (state != AppLifecycleState.resumed) flush();
      },
    );
  }

  final FutureOr<void> Function(String text) _save;
  final Duration delay;
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;
  String? _pending;

  /// True while typed text is waiting to be saved.
  bool get hasPending => _pending != null;

  /// Call on every edit.
  void changed(String text) {
    _pending = text;
    _timer?.cancel();
    _timer = Timer(delay, flush);
  }

  /// Saves pending text now.
  void flush() {
    _timer?.cancel();
    _timer = null;
    final text = _pending;
    _pending = null;
    if (text != null) unawaited(Future.sync(() => _save(text)));
  }

  /// Flushes and stops listening. The save is deferred to a microtask:
  /// saving notifies listeners, which must not happen while the widget tree
  /// is being unmounted.
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _lifecycle.dispose();
    final text = _pending;
    _pending = null;
    if (text != null) scheduleMicrotask(() => _save(text));
  }
}

/// Keeps a [TextEditingController] bound to a stored value that can also
/// change elsewhere (an import, a restore, another screen) without ever
/// overwriting what the user is typing.
///
/// [stored] is the value the field was last synced to or saved as. Call
/// [saved] when sending text to the store and [sync] with the latest stored
/// value on every rebuild.
class BoundText {
  BoundText(String initial)
    : controller = TextEditingController(text: initial),
      _stored = initial;

  final TextEditingController controller;
  String _stored;

  String get stored => _stored;

  /// The text about to be stored.
  void saved(String text) => _stored = text;

  /// Adopts [value] when it changed outside this field and nothing typed is
  /// waiting to be saved.
  void sync(String value, {required bool pending}) {
    if (value == _stored || pending) return;
    _stored = value;
    if (controller.text != value) {
      controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  void dispose() => controller.dispose();
}

/// A multiline [TextField] bound to a stored value with [Autosaver] +
/// [BoundText]: saves exactly what is typed (debounced, on focus loss, on
/// backgrounding, on dispose) and adopts outside changes (import, restore)
/// only when nothing typed is waiting.
class AutosaveTextField extends StatefulWidget {
  const AutosaveTextField({
    super.key,
    required this.value,
    required this.onSave,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.minLines = 2,
    this.maxLines,
    this.semanticLabel,
    this.textCapitalization = TextCapitalization.sentences,
    this.style,
    this.dictation = false,
  });

  /// The stored text.
  final String value;

  /// Persists the text exactly as typed.
  final Future<void> Function(String text) onSave;

  /// Every edit (e.g. to update a hint next to the field).
  final ValueChanged<String>? onChanged;
  final InputDecoration decoration;
  final int minLines;

  /// Null = grows with the text.
  final int? maxLines;

  /// What a screen reader announces for the field.
  final String? semanticLabel;
  final TextCapitalization textCapitalization;
  final TextStyle? style;

  /// Offer **Dictate** under the field (step 3): the reviewed text goes in
  /// at the cursor and is autosaved like typing.
  final bool dictation;

  @override
  State<AutosaveTextField> createState() => _AutosaveTextFieldState();
}

class _AutosaveTextFieldState extends State<AutosaveTextField> {
  late final BoundText _text;
  late final Autosaver _autosave;
  late Future<void> Function(String) _onSave;
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _text = BoundText(widget.value);
    _onSave = widget.onSave;
    _autosave = Autosaver((text) {
      _text.saved(text);
      return _onSave(text);
    });
    _focus.addListener(() {
      if (!_focus.hasFocus) _autosave.flush();
    });
  }

  @override
  void didUpdateWidget(AutosaveTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _onSave = widget.onSave;
    _text.sync(widget.value, pending: _autosave.hasPending);
  }

  @override
  void dispose() {
    _autosave.dispose();
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TypedDirection(
      controller: _text.controller,
      builder: (context, direction) => TextField(
        controller: _text.controller,
        textDirection: direction,
        focusNode: _focus,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        keyboardType: TextInputType.multiline,
        textCapitalization: widget.textCapitalization,
        style: widget.style,
        decoration: widget.decoration,
        onChanged: (text) {
          _autosave.changed(text);
          widget.onChanged?.call(text);
        },
      ),
    );
    final label = widget.semanticLabel;
    final labelled = label == null
        ? field
        : Semantics(label: label, child: field);
    if (!widget.dictation) return labelled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        labelled,
        DictateButton(
          controller: _text.controller,
          focusNode: _focus,
          fieldLabel: label,
          onInserted: (text) {
            _autosave.changed(text);
            widget.onChanged?.call(text);
          },
        ),
      ],
    );
  }
}
