// Guards the English content library against the PLAN.md §7 content spec and
// the requirements (F-005–F-010, F-013, F-015, F-016, F-019–F-025, F-038,
// F-057): counts, ids, ordinals, source times, Compass mappings, safety copy.
import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/content.dart';
import 'package:flutter_test/flutter_test.dart';

const ContentLibrary c = englishContent;

/// Words and phrases that must never appear in user-facing content
/// (no diagnosis, no guilt, no punitive gamification, no overpromising).
/// Matched case-insensitively at the start of a word, so stems also catch
/// their forms ("diagnos" → diagnosis/diagnose, "streak" → streaks) while
/// innocent words that merely contain a term ("closer") are not flagged.
const List<String> bannedTerms = [
  'diagnos',
  'disorder',
  'failure',
  'streak',
  'fix your life',
  'worthless',
  'pathetic',
  'loser',
  'lazy',
];

/// The [bannedTerms] that occur in [text].
List<String> bannedIn(String text) => [
  for (final term in bannedTerms)
    if (RegExp(
      r'\b' + RegExp.escape(term),
      caseSensitive: false,
    ).hasMatch(text))
      term,
];

/// The six daytime check-in times as given by the source, in order.
const List<String> sourceDaytimeTimes = [
  '11:00',
  '13:30',
  '15:15',
  '17:00',
  '19:30',
  '21:00',
];

/// Every user-facing string, labelled for readable failures.
Map<String, String> userFacingText() {
  final out = <String, String>{};
  for (final p in c.prompts) {
    out['${p.id}.title'] = p.title;
    out['${p.id}.question'] = p.question;
    out['${p.id}.context'] = p.context;
    out['${p.id}.help'] = p.help;
    out['${p.id}.example'] = p.example;
    out['${p.id}.sourceReference'] = p.sourceReference;
    if (p.softerQuestion != null) {
      out['${p.id}.softerQuestion'] = p.softerQuestion!;
    }
  }
  for (final l in c.lessons) {
    out['${l.id}.title'] = l.title;
    out['${l.id}.summary'] = l.summary;
    out['${l.id}.explanation'] = l.explanation;
    out['${l.id}.example'] = l.example;
    out['${l.id}.nuance'] = l.nuance;
    final check = l.check;
    if (check != null) {
      out['${l.id}.check.question'] = check.question;
      out['${l.id}.check.explanation'] = check.explanation;
      for (var i = 0; i < check.options.length; i++) {
        out['${l.id}.check.option$i'] = check.options[i];
      }
    }
  }
  for (final d in c.thirtyDays) {
    out['day${d.day}.title'] = d.title;
    out['day${d.day}.prompt'] = d.prompt;
    if (d.hint != null) out['day${d.day}.hint'] = d.hint!;
  }
  for (final e in c.experiments) {
    out['${e.id}.title'] = e.title;
    for (var i = 0; i < e.steps.length; i++) {
      out['${e.id}.step$i'] = e.steps[i];
    }
  }
  for (final n in c.notices) {
    out['${n.id}.title'] = n.title;
  }
  final cr = c.credit;
  out['credit.title'] = cr.title;
  out['credit.author'] = cr.author;
  out['credit.publishedOn'] = cr.publishedOn;
  out['credit.independenceNotice'] = cr.independenceNotice;
  out['credit.paraphraseNotice'] = cr.paraphraseNotice;
  return out;
}

/// Expected group for a prompt, from the PLAN.md §7 block table.
PromptGroup expectedGroup(PromptPhase phase, int ordinal) => switch (phase) {
  PromptPhase.morning when ordinal <= 4 => PromptGroup.currentReality,
  PromptPhase.morning when ordinal <= 8 => PromptGroup.antiVision,
  PromptPhase.morning when ordinal <= 11 => PromptGroup.identity,
  PromptPhase.morning => PromptGroup.vision,
  PromptPhase.daytime => PromptGroup.interrupt,
  PromptPhase.bonus => PromptGroup.contemplation,
  PromptPhase.evening when ordinal <= 2 => PromptGroup.insight,
  PromptPhase.evening when ordinal <= 4 => PromptGroup.direction,
  PromptPhase.evening => PromptGroup.plan,
};

/// Expected source reference (mirrors the requirements' §05 coverage rows).
String expectedSourceReference(PromptGroup group) => switch (group) {
  PromptGroup.currentReality => 'Morning 01–04 · current reality',
  PromptGroup.antiVision => 'Morning 05–08 · anti-vision',
  PromptGroup.identity => 'Morning 09–11 · identity',
  PromptGroup.vision => 'Morning 12–14 · vision',
  PromptGroup.interrupt => 'Daytime 01–06 · interrupt',
  PromptGroup.contemplation => 'Bonus 01–03 · contemplation',
  PromptGroup.insight => 'Evening 01–02 · insight',
  PromptGroup.direction => 'Evening 03–04 · direction',
  PromptGroup.plan => 'Evening 05–07 · plan',
};

void main() {
  group('library', () {
    test('is English, versioned', () {
      expect(c.languageCode, 'en');
      expect(c.version, greaterThanOrEqualTo(1));
    });

    test('has 14 morning, 6 daytime, 3 bonus, 7 evening prompts', () {
      expect(c.byPhase(PromptPhase.morning), hasLength(14));
      expect(c.byPhase(PromptPhase.daytime), hasLength(6));
      expect(c.byPhase(PromptPhase.bonus), hasLength(3));
      expect(c.byPhase(PromptPhase.evening), hasLength(7));
      expect(c.prompts, hasLength(30));
    });

    test('has 7 lessons and 30 path days', () {
      expect(c.lessons, hasLength(7));
      expect(c.thirtyDays, hasLength(30));
    });
  });

  group('prompts', () {
    test('ids are unique and well-formed, matching phase and ordinal', () {
      final ids = c.prompts.map((p) => p.id).toList();
      expect(ids.toSet(), hasLength(ids.length), reason: 'duplicate id');
      final pattern = RegExp(r'^(morning|daytime|bonus|evening)\.(\d{2})$');
      for (final p in c.prompts) {
        final m = pattern.firstMatch(p.id);
        expect(m, isNotNull, reason: 'malformed id ${p.id}');
        expect(m!.group(1), p.phase.name, reason: p.id);
        expect(int.parse(m.group(2)!), p.ordinal, reason: p.id);
      }
    });

    test('ordinals are contiguous from 1 in every phase', () {
      for (final phase in PromptPhase.values) {
        final ordinals = c.byPhase(phase).map((p) => p.ordinal).toList();
        expect(
          ordinals,
          List.generate(ordinals.length, (i) => i + 1),
          reason: phase.name,
        );
      }
    });

    test('each prompt sits in the group of its source block', () {
      for (final p in c.prompts) {
        expect(p.group, expectedGroup(p.phase, p.ordinal), reason: p.id);
      }
      expect(c.bySubflow(ResetSubflow.mirror), hasLength(11));
      expect(c.bySubflow(ResetSubflow.vision), hasLength(3));
      expect(c.bySubflow(ResetSubflow.interrupt), hasLength(9));
      expect(c.bySubflow(ResetSubflow.breakthrough), hasLength(7));
    });

    test('source references match the requirement coverage rows', () {
      for (final p in c.prompts) {
        expect(
          p.sourceReference,
          expectedSourceReference(p.group),
          reason: p.id,
        );
      }
    });

    test('daytime prompts carry the six source times, in order', () {
      final daytime = c.byPhase(PromptPhase.daytime);
      expect(daytime.map((p) => p.defaultTime).toList(), sourceDaytimeTimes);
      final hhmm = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
      for (final p in daytime) {
        expect(hhmm.hasMatch(p.defaultTime!), isTrue, reason: p.id);
      }
    });

    test('only daytime prompts have a default time', () {
      for (final p in c.prompts.where((p) => p.phase != PromptPhase.daytime)) {
        expect(p.defaultTime, isNull, reason: p.id);
      }
    });

    test('exactly evening #3–#7 map to the five Compass fields', () {
      final mapped = {
        for (final p in c.prompts.where((p) => p.mapsTo != null))
          p.id: p.mapsTo,
      };
      expect(mapped, {
        'evening.03': CompassField.antiVision,
        'evening.04': CompassField.vision,
        'evening.05': CompassField.yearGoal,
        'evening.06': CompassField.monthProject,
        'evening.07': CompassField.dailyLevers,
      });
      expect(c.promptFor(CompassField.antiVision)?.id, 'evening.03');
      expect(c.promptFor(CompassField.dailyLevers)?.id, 'evening.07');
    });

    test('nothing maps to constraints (F-025)', () {
      expect(c.promptFor(CompassField.constraints), isNull);
      expect(
        c.prompts.where((p) => p.mapsTo == CompassField.constraints),
        isEmpty,
      );
    });

    test('daily levers prompt asks for one action per line', () {
      final levers = c.prompt('evening.07')!;
      expect(
        '${levers.question} ${levers.help}'.toLowerCase(),
        contains('line'),
      );
      expect(levers.example.split('\n').length, greaterThanOrEqualTo(3));
    });

    test('bonus prompts, and only they, are not core', () {
      for (final p in c.prompts) {
        expect(p.core, p.phase != PromptPhase.bonus, reason: p.id);
      }
      expect(c.corePrompts, hasLength(27));
    });

    test('anti-vision and identity prompts offer softer wording', () {
      final sensitive = c.prompts.where(
        (p) =>
            p.group == PromptGroup.antiVision ||
            p.group == PromptGroup.identity,
      );
      expect(sensitive, hasLength(7));
      for (final p in sensitive) {
        expect(p.softerQuestion, isNotNull, reason: p.id);
        expect(p.softerQuestion!.trim(), isNotEmpty, reason: p.id);
        expect(p.softerQuestion, isNot(p.question), reason: p.id);
      }
    });

    test('anti-vision prompts frame the future as possible, not predicted', () {
      final intro = c.prompt('morning.05')!;
      expect(
        '${intro.context} ${intro.help}'.toLowerCase(),
        contains('not a prediction'),
      );
    });

    test('every question is distinct', () {
      final questions = c.prompts.map((p) => p.question).toList();
      expect(questions.toSet(), hasLength(questions.length));
    });
  });

  group('lessons', () {
    test('ids and ordinals are lesson.01–lesson.07 in order', () {
      expect(
        c.lessons.map((l) => l.id).toList(),
        List.generate(7, (i) => 'lesson.0${i + 1}'),
      );
      expect(
        c.lessons.map((l) => l.ordinal).toList(),
        List.generate(7, (i) => i + 1),
      );
      for (final l in c.lessons) {
        expect(c.lesson(l.id), same(l));
      }
    });

    test('explanations have 2–4 paragraphs separated by blank lines', () {
      for (final l in c.lessons) {
        final paragraphs = l.explanation.split('\n\n');
        expect(paragraphs.length, inInclusiveRange(2, 4), reason: l.id);
        for (final para in paragraphs) {
          expect(para.trim(), isNotEmpty, reason: l.id);
        }
      }
    });

    test('every related prompt id exists', () {
      for (final l in c.lessons) {
        expect(l.relatedPromptIds, isNotEmpty, reason: l.id);
        for (final id in l.relatedPromptIds) {
          expect(c.prompt(id), isNotNull, reason: '${l.id} → $id');
        }
      }
    });

    test('every lesson has a 3-option knowledge check', () {
      for (final l in c.lessons) {
        final check = l.check;
        expect(check, isNotNull, reason: l.id);
        expect(check!.options, hasLength(3), reason: l.id);
        expect(check.options.toSet(), hasLength(3), reason: l.id);
        expect(check.correctIndex, inInclusiveRange(0, 2), reason: l.id);
      }
    });
  });

  group('thirty-day path', () {
    test('days 1–30 in order', () {
      expect(
        c.thirtyDays.map((d) => d.day).toList(),
        List.generate(30, (i) => i + 1),
      );
    });

    test('stages: Observe 1–7, Experiment 8–15, Build 16–23, Adjust 24–30', () {
      PathStage expected(int day) => day <= 7
          ? PathStage.observe
          : day <= 15
          ? PathStage.experiment
          : day <= 23
          ? PathStage.build
          : PathStage.adjust;
      for (final d in c.thirtyDays) {
        expect(d.stage, expected(d.day), reason: 'day ${d.day}');
      }
    });

    test('every day has a distinct prompt and a hint', () {
      final prompts = c.thirtyDays.map((d) => d.prompt).toList();
      expect(prompts.toSet(), hasLength(30));
      for (final d in c.thirtyDays) {
        expect(d.hint, isNotNull, reason: 'day ${d.day}');
      }
    });
  });

  group('credit', () {
    test('names the source, author, date and both links', () {
      final cr = c.credit;
      expect(cr.title, 'How to fix your entire life in 1 day');
      expect(cr.author, 'Dan Koe');
      expect(cr.publishedOn, '23 December 2025');
      expect(
        cr.articleUrl,
        'https://x.com/thedankoe/status/2010751592346030461',
      );
      expect(
        cr.newsletterUrl,
        'https://letters.thedankoe.com/p/how-to-fix-your-entire-life-in-1',
      );
      for (final url in [cr.articleUrl, cr.newsletterUrl]) {
        final uri = Uri.parse(url);
        expect(uri.scheme, 'https', reason: url);
        expect(uri.host, isNotEmpty, reason: url);
      }
    });

    test('states independence and paraphrase', () {
      final cr = c.credit;
      expect(cr.independenceNotice.toLowerCase(), contains('independent'));
      expect(cr.independenceNotice.toLowerCase(), contains('not affiliated'));
      expect(cr.independenceNotice.toLowerCase(), contains('endorsed'));
      expect(cr.independenceNotice, contains('Dan Koe'));
      expect(cr.paraphraseNotice.toLowerCase(), contains('paraphrased'));
      expect(cr.paraphraseNotice.toLowerCase(), contains('original'));
    });
  });

  group('safety & quality of copy', () {
    test('no user-facing string is empty', () {
      userFacingText().forEach((key, value) {
        expect(value.trim(), isNotEmpty, reason: key);
      });
    });

    test('banned-term matcher catches word forms, not innocent words', () {
      expect(bannedIn('No STREAKS here'), ['streak']);
      expect(bannedIn('A diagnosis of you'), ['diagnos']);
      expect(bannedIn('Loser.'), ['loser']);
      expect(bannedIn('How to Fix your life fast'), ['fix your life']);
      expect(bannedIn('One step closer to your vision'), isEmpty);
    });

    test('no banned words in any user-facing text', () {
      userFacingText().forEach((key, value) {
        expect(bannedIn(value), isEmpty, reason: key);
      });
    });

    test('examples are framed as someone else’s words, not model answers', () {
      for (final p in c.prompts) {
        expect(p.example, startsWith('Someone might write:'), reason: p.id);
      }
    });
  });
}
