import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/bidi.dart';

/// Whether [motto] is longer than a persona allows. The limit counts what
/// `String.length` counts, as `savePersona` does (an emoji can take two or
/// more), so the field never accepts a motto that could not be saved.
bool mottoTooLong(String motto) => motto.length > kPersonaMottoMax;

/// The optional motto, kept exactly as typed (no trimming, no rewriting). An
/// edit that would go over the limit is refused rather than cut, so the
/// user's words are never shortened behind their back.
class BuilderMottoField extends StatelessWidget {
  const BuilderMottoField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tooLong = mottoTooLong(controller.text);
    return TypedDirection(
      controller: controller,
      builder: (context, direction) => TextField(
        key: const ValueKey('persona-motto'),
        controller: controller,
        textDirection: direction,
        minLines: 1,
        maxLines: 3,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        textCapitalization: TextCapitalization.sentences,
        inputFormatters: const [_LengthLimit(kPersonaMottoMax)],
        buildCounter:
            (context, {required currentLength, required isFocused, maxLength}) {
              final count = controller.text.length;
              return Semantics(
                liveRegion: isFocused,
                label: MaterialLocalizations.of(context)
                    .remainingTextFieldCharacterCount(
                      math.max(0, kPersonaMottoMax - count),
                    ),
                child: ExcludeSemantics(
                  child: Text(
                    l.personaBuilderMottoCount(count, kPersonaMottoMax),
                  ),
                ),
              );
            },
        decoration: InputDecoration(
          labelText: l.personaBuilderMottoLabel,
          hintText: l.personaBuilderMottoHint,
          errorText: tooLong ? l.personaBuilderMottoTooLong : null,
          errorMaxLines: 3,
        ),
      ),
    );
  }
}

/// Refuses an edit that grows the text past [max] UTF-16 code units (the
/// unit `savePersona` checks); shortening is always allowed, even while
/// still over the limit (an older backup may hold a longer motto).
class _LengthLimit extends TextInputFormatter {
  const _LengthLimit(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final grows = newValue.text.length > oldValue.text.length;
    return grows && newValue.text.length > max ? oldValue : newValue;
  }
}
