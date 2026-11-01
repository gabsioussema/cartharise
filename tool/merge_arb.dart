// Builds lib/l10n/app_en.arb from the per-area fragments in l10n_src/.
//
//   dart run tool/merge_arb.dart        (or: make l10n)
//
// Order: common_en.arb first, then every other `*_en.arb` alphabetically.
// A missing or empty fragment is skipped. Invalid JSON or a key defined twice
// (in one fragment or across fragments) fails loudly, so two areas can never
// silently overwrite each other's strings.
import 'dart:convert';
import 'dart:io';

const _sourceDir = 'l10n_src';
const _output = 'lib/l10n/app_en.arb';

void main(List<String> args) {
  final dir = Directory(_sourceDir);
  final fragments = <ArbFragment>[];
  if (dir.existsSync()) {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('_en.arb'))
        .toList();
    for (final f in files) {
      fragments.add(ArbFragment(f.uri.pathSegments.last, f.readAsStringSync()));
    }
  }
  try {
    final merged = mergeArbFragments(fragments);
    File(_output)
      ..createSync(recursive: true)
      ..writeAsStringSync(merged);
    final count = jsonDecode(merged) as Map<String, Object?>;
    stdout.writeln(
      'merge_arb: ${fragments.length} fragment(s) → $_output '
      '(${count.keys.where((k) => !k.startsWith('@')).length} strings)',
    );
  } on ArbMergeException catch (e) {
    stderr.writeln('merge_arb: ERROR: ${e.message}');
    exitCode = 1;
  }
}

/// One `l10n_src/<area>_en.arb` file.
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

/// Merges [fragments] into one English ARB (with `"@@locale": "en"`).
/// `common_en.arb` comes first, the rest alphabetically. Throws
/// [ArbMergeException] on invalid JSON or duplicate keys.
String mergeArbFragments(List<ArbFragment> fragments) {
  final ordered = [...fragments]
    ..sort((a, b) {
      if (a.name == b.name) return 0;
      if (a.name == 'common_en.arb') return -1;
      if (b.name == 'common_en.arb') return 1;
      return a.name.compareTo(b.name);
    });
  final merged = <String, Object?>{'@@locale': 'en'};
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
      if (key.startsWith('@@')) continue; // per-file locale markers
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
  return '${const JsonEncoder.withIndent('  ').convert(merged)}\n';
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
