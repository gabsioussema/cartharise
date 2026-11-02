// Builds lib/l10n/app_<lang>.arb for every language from the per-area
// fragments in l10n_src/ (`<area>_<lang>.arb`).
//
//   dart run tool/merge_arb.dart            (or: make l10n)
//   dart run tool/merge_arb.dart --report   + coverage per language and area
//
// English (`*_en.arb`) is the template: common_en.arb first, then every
// other fragment alphabetically. A missing or empty fragment is skipped.
// Invalid JSON or a key defined twice (in one fragment or across fragments)
// fails loudly, so two areas can never silently overwrite each other's
// strings.
//
// Every other language in [kArbLanguages] (`*_fr.arb`, `*_ar.arb`) gets
// every English key: a key it doesn't translate (or translates as an empty
// string) falls back to the English text at merge time and is counted as
// missing in the summary (`--report` lists it per area). A translation must
// keep English's placeholders, plurals and selects (same names; a plural
// stays a plural with an `other` case; a select keeps English's cases), may
// only translate keys English has, and must say its own `@@locale` if it
// says one — anything else fails the merge.
import 'dart:convert';
import 'dart:io';

const _sourceDir = 'l10n_src';
const _outputDir = 'lib/l10n';

/// The languages the app ships, English (the template) first. Adding one:
/// here, `AppLanguage` (lib/domain/language.dart), a seed `<area>_<lang>.arb`
/// per area, and docs/translations.md.
const List<String> kArbLanguages = ['en', 'fr', 'ar'];

void main(List<String> args) {
  final report = args.contains('--report');
  final dir = Directory(_sourceDir);
  final fragments = <String, List<ArbFragment>>{
    for (final language in kArbLanguages) language: [],
  };
  try {
    if (dir.existsSync()) {
      final files = dir.listSync().whereType<File>().where(
        (f) => f.path.endsWith('.arb'),
      );
      for (final f in files) {
        final name = f.uri.pathSegments.last;
        final language = arbLanguageOf(name);
        final list = language == null ? null : fragments[language];
        if (list == null) {
          throw ArbMergeException(
            '$name: expected <area>_<lang>.arb with <lang> one of '
            '${kArbLanguages.join(', ')} (add a new language to kArbLanguages)',
          );
        }
        list.add(ArbFragment(name, f.readAsStringSync()));
      }
    }
    final english = mergeArbFragments(fragments['en']!);
    _write('en', english);
    final count = (jsonDecode(english) as Map<String, Object?>).keys
        .where((k) => !k.startsWith('@'))
        .length;
    stdout.writeln(
      'merge_arb: ${fragments['en']!.length} fragment(s) → '
      '$_outputDir/app_en.arb ($count strings)',
    );
    final merges = [
      for (final language in kArbLanguages.skip(1))
        mergeTranslation(language, fragments['en']!, fragments[language]!),
    ];
    for (final merge in merges) {
      _write(merge.language, merge.arb);
      stdout.writeln(
        'merge_arb: ${fragments[merge.language]!.length} fragment(s) → '
        '$_outputDir/app_${merge.language}.arb (${merge.summary})',
      );
    }
    if (report) stdout.write(coverageReport(merges));
  } on ArbMergeException catch (e) {
    stderr.writeln('merge_arb: ERROR: ${e.message}');
    exitCode = 1;
  }
}

void _write(String language, String text) =>
    File('$_outputDir/app_$language.arb')
      ..createSync(recursive: true)
      ..writeAsStringSync(text);

/// One `l10n_src/<area>_<lang>.arb` file.
class ArbFragment {
  const ArbFragment(this.name, this.text);
  final String name;
  final String text;
}

class ArbMergeException implements Exception {
  const ArbMergeException(this.message);
  final String message;
  @override
  String toString() => 'ArbMergeException: $message';
}

final _fragmentName = RegExp(r'^([a-z0-9]+(?:_[a-z0-9]+)*)_([a-z]{2,3})\.arb$');

/// The language of a fragment file name (`today_fr.arb` → `fr`), or null.
String? arbLanguageOf(String fileName) =>
    _fragmentName.firstMatch(fileName)?.group(2);

/// The area of a fragment file name (`today_fr.arb` → `today`).
String arbAreaOf(String fileName) =>
    _fragmentName.firstMatch(fileName)?.group(1) ?? fileName;

/// Merges [fragments] into one English ARB (with `"@@locale": "en"`).
/// `common_en.arb` comes first, the rest alphabetically. Throws
/// [ArbMergeException] on invalid JSON or duplicate keys.
String mergeArbFragments(List<ArbFragment> fragments) =>
    _encode(_mergeFragments(fragments, 'en').entries);

/// One translated language, merged.
class TranslationMerge {
  const TranslationMerge({
    required this.language,
    required this.arb,
    required this.areas,
  });

  final String language;

  /// The `app_<language>.arb` text: every English key, translated or
  /// English.
  final String arb;

  /// Coverage per area (the English fragment each key comes from), in
  /// merge order.
  final List<AreaCoverage> areas;

  int get total => areas.fold(0, (n, a) => n + a.total);
  int get translated => areas.fold(0, (n, a) => n + a.translated.length);

  /// Keys shown in English, in merge order.
  List<String> get missing => [for (final a in areas) ...a.missing];

  String get summary {
    final fallback = total - translated;
    return '$translated/$total strings translated (${_percent(translated, total)})'
        '${fallback == 0 ? '' : ', $fallback fall back to English'}';
  }
}

/// How much of one area a language translates.
class AreaCoverage {
  const AreaCoverage({
    required this.area,
    required this.translated,
    required this.missing,
  });

  final String area;
  final List<String> translated;

  /// Keys shown in English.
  final List<String> missing;

  int get total => translated.length + missing.length;
}

/// Merges the [translated] fragments of [language] over the [english]
/// ones: every English key, in English order, with the translation where
/// there is one and the English text where there isn't. Throws
/// [ArbMergeException] on invalid JSON, a duplicate key, a key English
/// doesn't have, a non-string value, a wrong `@@locale`, or a translation
/// whose placeholders, plurals or selects don't match English.
TranslationMerge mergeTranslation(
  String language,
  List<ArbFragment> english,
  List<ArbFragment> translated,
) {
  final en = _mergeFragments(english, 'en');
  final tr = _mergeFragments(translated, language);
  for (final key in tr.entries.keys) {
    if (key == '@@locale' || key.startsWith('@')) continue;
    if (!en.entries.containsKey(key)) {
      throw ArbMergeException(
        '${tr.origin[key]}: "$key" is not an English key '
        '(translate only keys of the *_en.arb fragments)',
      );
    }
  }
  final out = <String, Object?>{'@@locale': language};
  final areas = <String, ({List<String> done, List<String> missing})>{};
  for (final MapEntry(:key, value: source) in en.entries.entries) {
    if (key.startsWith('@')) continue;
    if (source is! String) {
      throw ArbMergeException('${en.origin[key]}: "$key" must be a string');
    }
    final area = arbAreaOf(en.origin[key]!);
    final coverage = areas.putIfAbsent(
      area,
      () => (done: <String>[], missing: <String>[]),
    );
    final value = tr.entries[key];
    if (value != null && value is! String) {
      throw ArbMergeException('${tr.origin[key]}: "$key" must be a string');
    }
    if (value is String && value.trim().isNotEmpty) {
      final mismatch = icuMismatch(source, value);
      if (mismatch != null) {
        throw ArbMergeException('${tr.origin[key]}: "$key" $mismatch');
      }
      out[key] = value;
      coverage.done.add(key);
    } else {
      out[key] = source;
      coverage.missing.add(key);
    }
  }
  return TranslationMerge(
    language: language,
    arb: _encode(out),
    areas: [
      for (final MapEntry(key: area, :value) in areas.entries)
        AreaCoverage(
          area: area,
          translated: value.done,
          missing: value.missing,
        ),
    ],
  );
}

/// The coverage of each merged language, per area: complete areas in one
/// line, untouched ones as "not started", partly translated ones with the
/// keys still in English.
String coverageReport(List<TranslationMerge> merges) {
  final out = StringBuffer();
  for (final merge in merges) {
    out.writeln('\n${merge.language}: ${merge.summary}');
    for (final area in merge.areas) {
      final done = area.translated.length;
      final label = '  ${area.area.padRight(16)} $done/${area.total}';
      if (area.missing.isEmpty) {
        out.writeln('$label  complete');
      } else if (done == 0) {
        out.writeln('$label  not started');
      } else {
        out.writeln('$label  in English: ${area.missing.join(', ')}');
      }
    }
  }
  return out.toString();
}

String _percent(int part, int whole) =>
    whole == 0 ? '100%' : '${(part * 100 / whole).floor()}%';

String _encode(Map<String, Object?> entries) =>
    '${const JsonEncoder.withIndent('  ').convert(entries)}\n';

class _Merged {
  _Merged(this.entries, this.origin);

  /// `@@locale` first, then every key in merge order.
  final Map<String, Object?> entries;

  /// The fragment each key came from.
  final Map<String, String> origin;
}

_Merged _mergeFragments(List<ArbFragment> fragments, String language) {
  final common = 'common_$language.arb';
  final ordered = [...fragments]
    ..sort((a, b) {
      if (a.name == b.name) return 0;
      if (a.name == common) return -1;
      if (b.name == common) return 1;
      return a.name.compareTo(b.name);
    });
  final merged = <String, Object?>{'@@locale': language};
  final origin = <String, String>{};
  for (final fragment in ordered) {
    if (fragment.text.trim().isEmpty) continue;
    final Object? decoded;
    try {
      decoded = jsonDecode(fragment.text);
    } on FormatException catch (e) {
      throw ArbMergeException(
        '${fragment.name} is not valid JSON: ${e.message}',
      );
    }
    if (decoded is! Map) {
      throw ArbMergeException('${fragment.name} must be a JSON object');
    }
    final repeated = _repeatedTopLevelKeys(fragment.text);
    if (repeated.isNotEmpty) {
      throw ArbMergeException(
        '${fragment.name} defines ${repeated.join(', ')} more than once',
      );
    }
    for (final entry in decoded.entries) {
      final key = entry.key as String;
      if (key == '@@locale') {
        if (entry.value != language) {
          throw ArbMergeException(
            '${fragment.name}: "@@locale" is "${entry.value}", '
            'expected "$language"',
          );
        }
        continue;
      }
      if (key.startsWith('@@')) continue; // other per-file markers
      final previous = origin[key];
      if (previous != null) {
        throw ArbMergeException(
          'duplicate key "$key" in ${fragment.name} (already in $previous)',
        );
      }
      origin[key] = fragment.name;
      merged[key] = entry.value;
    }
  }
  return _Merged(merged, origin);
}

/// Keys that appear more than once at the top level of a JSON object
/// (`jsonDecode` silently keeps the last one).
List<String> _repeatedTopLevelKeys(String text) {
  final seen = <String>{};
  final repeated = <String>[];
  var depth = 0;
  var i = 0;
  while (i < text.length) {
    final c = text[i];
    if (c == '"') {
      final buffer = StringBuffer();
      i++;
      while (i < text.length && text[i] != '"') {
        if (text[i] == '\\' && i + 1 < text.length) {
          buffer.write(text[i]);
          i++;
        }
        buffer.write(text[i]);
        i++;
      }
      i++; // closing quote
      if (depth == 1) {
        var j = i;
        while (j < text.length && text[j].trim().isEmpty) {
          j++;
        }
        if (j < text.length && text[j] == ':') {
          final key = buffer.toString();
          if (!seen.add(key)) repeated.add(key);
        }
      }
      continue;
    }
    if (c == '{' || c == '[') depth++;
    if (c == '}' || c == ']') depth--;
    i++;
  }
  return repeated;
}

// ── ICU message shape ─────────────────────────────────────────────────────

/// One argument of an ICU message: how it is used (`plural`, `select`,
/// `number`, … — a plain `{name}` adds nothing) and the cases its plurals
/// and selects list.
class _IcuArgument {
  final Set<String> kinds = {};
  final Set<String> selectCases = {};
  final Set<String> pluralCases = {};
}

/// Why [translation] doesn't fit [english] (different placeholders, a
/// plural or select that isn't one any more, a select with other cases, a
/// plural without `other`, unbalanced braces), or null when it fits.
/// Plural cases may differ (Arabic needs zero/one/two/few/many/other).
String? icuMismatch(String english, String translation) {
  final Map<String, _IcuArgument> en;
  final Map<String, _IcuArgument> tr;
  try {
    en = _icuArguments(english);
  } on FormatException catch (e) {
    return 'has an English text that is not a valid message (${e.message})';
  }
  try {
    tr = _icuArguments(translation);
  } on FormatException catch (e) {
    return 'is not a valid message (${e.message})';
  }
  final enNames = en.keys.toSet();
  final trNames = tr.keys.toSet();
  if (enNames.length != trNames.length || !enNames.containsAll(trNames)) {
    String names(Set<String> s) =>
        s.isEmpty ? 'none' : (s.toList()..sort()).map((n) => '{$n}').join(', ');
    return 'has placeholders ${names(trNames)}; English has ${names(enNames)}';
  }
  for (final name in enNames) {
    final e = en[name]!;
    final t = tr[name]!;
    if (e.kinds.length != t.kinds.length || !e.kinds.containsAll(t.kinds)) {
      String kinds(Set<String> k) => k.isEmpty ? 'plain' : k.join('/');
      return 'uses {$name} as ${kinds(t.kinds)}; English uses it as '
          '${kinds(e.kinds)}';
    }
    if (e.kinds.contains('select') &&
        (e.selectCases.length != t.selectCases.length ||
            !e.selectCases.containsAll(t.selectCases))) {
      return 'select {$name} has cases ${t.selectCases.join(' ')}; '
          'English has ${e.selectCases.join(' ')}';
    }
    if (e.kinds.contains('plural') && !t.pluralCases.contains('other')) {
      return 'plural {$name} needs an "other" case';
    }
  }
  return null;
}

Map<String, _IcuArgument> _icuArguments(String message) {
  final args = <String, _IcuArgument>{};
  _parseMessage(message, 0, message.length, args);
  return args;
}

void _parseMessage(
  String s,
  int start,
  int end,
  Map<String, _IcuArgument> args,
) {
  var i = start;
  while (i < end) {
    final c = s[i];
    if (c == '}') throw FormatException('unexpected "}" at $i');
    if (c == '{') {
      final close = _closing(s, i, end);
      _parseArgument(s, i + 1, close, args);
      i = close + 1;
    } else {
      i++;
    }
  }
}

/// The index of the `}` closing the `{` at [open].
int _closing(String s, int open, int end) {
  var depth = 0;
  for (var j = open; j < end; j++) {
    if (s[j] == '{') depth++;
    if (s[j] == '}' && --depth == 0) return j;
  }
  throw FormatException('unclosed "{" at $open');
}

final _identifier = RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$');

void _parseArgument(
  String s,
  int start,
  int end,
  Map<String, _IcuArgument> args,
) {
  final body = s.substring(start, end);
  final firstComma = body.indexOf(',');
  final name = (firstComma < 0 ? body : body.substring(0, firstComma)).trim();
  if (!_identifier.hasMatch(name)) {
    throw FormatException('"{$name}" is not a placeholder name');
  }
  final arg = args.putIfAbsent(name, _IcuArgument.new);
  if (firstComma < 0) return;
  final rest = body.substring(firstComma + 1);
  final secondComma = rest.indexOf(',');
  final kind = (secondComma < 0 ? rest : rest.substring(0, secondComma)).trim();
  if (kind.isEmpty) throw FormatException('{$name, …} has no type');
  arg.kinds.add(kind);
  if (kind != 'plural' && kind != 'select') return;
  if (secondComma < 0) throw FormatException('{$name, $kind} has no cases');
  // Cases: `key{message}` repeated, messages parsed recursively.
  final casesStart = start + firstComma + 1 + secondComma + 1;
  var i = casesStart;
  while (i < end) {
    if (s[i].trim().isEmpty) {
      i++;
      continue;
    }
    final open = s.indexOf('{', i);
    if (open < 0 || open >= end) {
      throw FormatException('{$name, $kind}: case without a message');
    }
    final key = s.substring(i, open).trim();
    if (key.isEmpty || key.contains(RegExp(r'\s'))) {
      throw FormatException('{$name, $kind}: bad case "$key"');
    }
    (kind == 'plural' ? arg.pluralCases : arg.selectCases).add(key);
    final close = _closing(s, open, end);
    _parseMessage(s, open + 1, close, args);
    i = close + 1;
  }
}
