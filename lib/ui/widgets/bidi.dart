/// Mixed scripts (step 3): the user's own words keep their own direction in
/// either app language. An English quest in the Arabic app reads
/// "Read 10 pages of «Dune»", not "«Read 10 pages of «Dune"; an Arabic note
/// in the English app reads right to left.
library;

import 'package:flutter/widgets.dart';

final _letter = RegExp(r'\p{L}', unicode: true);

bool _isRtl(int rune) =>
    (rune >= 0x0590 && rune <= 0x08FF) || // Hebrew, Arabic, Syriac, Thaana…
    (rune >= 0xFB1D && rune <= 0xFDFF) || // Hebrew + Arabic presentation A
    (rune >= 0xFE70 && rune <= 0xFEFF) || // Arabic presentation forms B
    (rune >= 0x10800 && rune <= 0x10FFF) || // historic RTL scripts
    (rune >= 0x1E800 && rune <= 0x1EFFF); // Adlam, Arabic math, …

/// The direction of [text] by its first strong letter (Unicode's "first
/// strong" rule): right to left for Arabic or Hebrew, left to right for
/// any other script, null when it has no letter (digits, emoji, empty) so
/// the ambient direction applies. Use it as `Text.textDirection` for words
/// the user wrote, never for the app's own strings (an Arabic sentence
/// starting with "Cartharise" is still Arabic).
TextDirection? textDirectionOf(String text) {
  for (final rune in text.runes) {
    if (_isRtl(rune)) return TextDirection.rtl;
    if (_letter.hasMatch(String.fromCharCode(rune))) return TextDirection.ltr;
  }
  return null;
}

/// [words] (the user's) for a sentence of the app's, such as
/// "Learned: {learning}": wrapped in Unicode's first-strong isolate
/// (U+2068 … U+2069) when they run the other way from [ambient], the
/// sentence's direction, so their own punctuation stays at their own end
/// ("تعلّمت: Mornings work better." keeps its full stop after "better").
/// Unchanged when they run the same way or have no letter. Only for
/// display: what is saved is never touched.
String isolateUserWords(String words, TextDirection ambient) {
  final direction = textDirectionOf(words);
  if (direction == null || direction == ambient) return words;
  return '\u2068$words\u2069';
}

/// Builds a text field with the direction of what is typed in
/// [controller] ([textDirectionOf]: null until there is a letter, so the
/// app's direction applies) for its `textDirection`. English typed in the
/// Arabic app runs left to right with its full stop at its end; Arabic
/// typed in the English app runs right to left. Rebuilds only when that
/// direction changes, not on every keystroke; the label, hint and helper
/// keep the app's direction.
class TypedDirection extends StatefulWidget {
  const TypedDirection({
    super.key,
    required this.controller,
    required this.builder,
  });

  final TextEditingController controller;
  final Widget Function(BuildContext context, TextDirection? direction) builder;

  @override
  State<TypedDirection> createState() => _TypedDirectionState();
}

class _TypedDirectionState extends State<TypedDirection> {
  late TextDirection? _direction = textDirectionOf(widget.controller.text);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(TypedDirection old) {
    super.didUpdateWidget(old);
    if (old.controller == widget.controller) return;
    old.controller.removeListener(_changed);
    widget.controller.addListener(_changed);
    _direction = textDirectionOf(widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    final next = textDirectionOf(widget.controller.text);
    if (next != _direction) setState(() => _direction = next);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _direction);
}
