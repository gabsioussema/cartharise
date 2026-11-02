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
