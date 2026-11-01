import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/merge_arb.dart';

void main() {
  test('common first, then alphabetical, with @@locale', () {
    final merged = jsonDecode(
      mergeArbFragments(const [
        ArbFragment('zeta_en.arb', '{"zetaHello": "Z"}'),
        ArbFragment('alpha_en.arb', '{"alphaHello": "A", "@alphaHello": {}}'),
        ArbFragment('common_en.arb', '{"@@locale": "en", "save": "Save"}'),
        ArbFragment('empty_en.arb', '  \n'),
      ]),
    ) as Map<String, Object?>;
    expect(merged.keys.toList(), [
      '@@locale',
      'save',
      'alphaHello',
      '@alphaHello',
      'zetaHello',
    ]);
    expect(merged['@@locale'], 'en');
  });

  test('a key defined by two areas fails loudly', () {
    expect(
      () => mergeArbFragments(const [
        ArbFragment('common_en.arb', '{"save": "Save"}'),
        ArbFragment('today_en.arb', '{"save": "Keep"}'),
      ]),
      throwsA(
        isA<ArbMergeException>().having(
          (e) => e.message,
          'message',
          allOf(contains('save'), contains('common_en.arb')),
        ),
      ),
    );
  });

  test('a key repeated inside one fragment fails loudly', () {
    expect(
      () => mergeArbFragments(const [
        ArbFragment(
          'today_en.arb',
          '{"todayA": "1", "x": {"todayA": 2}, "todayA": "3"}',
        ),
      ]),
      throwsA(isA<ArbMergeException>()),
    );
    // Nested metadata keys with the same name are fine.
    expect(
      () => mergeArbFragments(const [
        ArbFragment(
          'today_en.arb',
          '{"a": "1", "@a": {"description": "x"}, "b": "2", "@b": {"description": "y"}}',
        ),
      ]),
      returnsNormally,
    );
  });

  test('invalid JSON fails loudly', () {
    expect(
      () => mergeArbFragments(const [ArbFragment('bad_en.arb', '{"a": ')]),
      throwsA(isA<ArbMergeException>()),
    );
    expect(
      () => mergeArbFragments(const [ArbFragment('bad_en.arb', '[1]')]),
      throwsA(isA<ArbMergeException>()),
    );
  });

  test('lib/l10n/app_en.arb is up to date with l10n_src (run make l10n)', () {
    final fragments = [
      for (final f in Directory('l10n_src').listSync().whereType<File>())
        if (f.path.endsWith('_en.arb'))
          ArbFragment(f.uri.pathSegments.last, f.readAsStringSync()),
    ];
    expect(
      File('lib/l10n/app_en.arb').readAsStringSync(),
      mergeArbFragments(fragments),
    );
  });
}
