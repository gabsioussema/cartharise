// French (step 3, agent "french"): every interface string and every content
// item is translated, keeps English's structure, follows French typography
// and never uses streak, score or guilt wording. The translation is a DRAFT
// until a native speaker reviews it (docs/translations.md).
import 'dart:convert';
import 'dart:io';

import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/content/fr.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/domain/content_translation.dart' show pathDayId;
import 'package:flutter_test/flutter_test.dart';

import '../tool/merge_arb.dart';

List<ArbFragment> _fragmentsOf(String language) => [
  for (final f in Directory('l10n_src').listSync().whereType<File>())
    if (arbLanguageOf(f.uri.pathSegments.last) == language)
      ArbFragment(f.uri.pathSegments.last, f.readAsStringSync()),
];

Map<String, String> _messages(String path) {
  final json =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (!key.startsWith('@')) key: value! as String,
  };
}

/// Every user-facing text of a content library, labelled by id.
Map<String, String> contentText(ContentLibrary c) => {
  for (final l in c.lessons) ...{
    '${l.id}.title': l.title,
    '${l.id}.summary': l.summary,
    '${l.id}.explanation': l.explanation,
    '${l.id}.example': l.example,
    '${l.id}.nuance': l.nuance,
    if (l.check case final check?) ...{
      '${l.id}.check.question': check.question,
      '${l.id}.check.explanation': check.explanation,
      for (var i = 0; i < check.options.length; i++)
        '${l.id}.check.option$i': check.options[i],
    },
  },
  for (final p in c.prompts) ...{
    '${p.id}.title': p.title,
    '${p.id}.question': p.question,
    '${p.id}.context': p.context,
    '${p.id}.help': p.help,
    '${p.id}.example': p.example,
    '${p.id}.softer': ?p.softerQuestion,
  },
  for (final d in c.thirtyDays) ...{
    '${pathDayId(d.day)}.title': d.title,
    '${pathDayId(d.day)}.prompt': d.prompt,
    '${pathDayId(d.day)}.hint': ?d.hint,
  },
  for (final e in c.experiments) ...{
    '${e.id}.title': e.title,
    for (var i = 0; i < e.steps.length; i++) '${e.id}.step$i': e.steps[i],
  },
  for (final n in c.notices) '${n.id}.title': n.title,
  'credit.publishedOn': c.credit.publishedOn,
  'credit.independence': c.credit.independenceNotice,
  'credit.paraphrase': c.credit.paraphraseNotice,
};

const _nbsp = ' ';

/// What breaks French typography in [text]: a plain or missing space
/// before : ; ! ?, « » without a no-break space inside, a straight
/// apostrophe (’ is used) or straight double quotes (« » are used).
List<String> typographyProblems(String text) => [
  if (RegExp(r'[  ][:;!?]').hasMatch(text)) 'plain space before : ; ! ?',
  if (RegExp(r'[^\s ][;!?]').hasMatch(text)) 'no space before ; ! ?',
  // A colon right after a word or a placeholder (times are written 21 h).
  if (RegExp(r'[\p{L}\d)}»…][:]', unicode: true).hasMatch(text))
    'no space before :',
  if (RegExp('«(?!$_nbsp)').hasMatch(text)) '« without a no-break space',
  if (RegExp('(?<!$_nbsp)»').hasMatch(text)) '» without a no-break space',
  if (text.contains("'")) "straight apostrophe (use ’)",
  if (text.contains('"')) 'straight double quote (use « »)',
];

/// Streak, score, failure and guilt wording in French, matched at the start
/// of a word ("échou" → échoué, échouer). English's equivalents are banned
/// by test/content_test.dart and the screens' own tests.
final RegExp bannedFrench = RegExp(
  r'(?<![\p{L}])(série|score|échec|échou|points\b|en retard|paresse|'
  r'paresseu|manqué|raté|auriez dû|auriez pu|devriez avoir|culpabil|honte|'
  r'nul\b|nulle\b|sans valeur|pathétique|répar\w* votre vie|'
  r'changé votre vie|diagnost|trouble)',
  caseSensitive: false,
  unicode: true,
);

/// The two places that say what Cartharise is not ("no diagnosis"), the
/// reassuring mention the English strings make too.
const _notTherapyKeys = {
  'onboardingLimitsNotTherapyBody',
  'youSupportNotTherapyBody',
};

/// French words spelled like English (names, shared words, numbers):
/// everything else must differ from the English text.
const _sameAsEnglish = {
  'appTitle',
  'tabJournal',
  'progressLabel',
  'compassFieldAntiVision',
  'compassFieldVision',
  'compassSectionMissions',
  'compassVersionsTitle',
  'compassVersionTitle',
  'compassViewVersions',
  'journalTitle',
  'journalSectionNotes',
  'journalCompareSecond',
  'journalPhaseBonus',
  'journalVersionLabel',
  'journalEntryTitle',
  'todayDirectionLabel',
  'todayDirectionVision',
  'todayTileResetValue',
  'resetRingLabel',
  'resetGroupVision',
  'resetGroupDirection',
  'resetGroupPlan',
  'resetGroupContemplation',
  'resetPause',
  'campaignLevel',
  'campaignToastXp',
  'campaignQuestXp',
  'campaignLinkRoute',
  'campaignLinkCollection',
  'campaignCollectionTitle',
  'campaignBattleLogTitle',
  'campaignTryPosition',
  'youInspiration',
  'youInspirationTitle',
  'youAppearanceSummary',
  'youThemeOasis',
  'youVersion',
  'personaSilhouette',
  'personaAvatarLabel',
  'personaCategoryExpression',
  'personaBuilderMottoCount',
  'projectsMonths',
  'mediaPhotoTitle',
};

void main() {
  group('interface strings', () {
    final merge = mergeTranslation(
      'fr',
      _fragmentsOf('en'),
      _fragmentsOf('fr'),
    );

    test('every English string has a French translation (100 %)', () {
      expect(merge.missing, isEmpty, reason: 'shown in English');
      expect(merge.translated, merge.total);
      expect(merge.summary, startsWith('${merge.total}/${merge.total} '));
      for (final area in merge.areas) {
        expect(area.missing, isEmpty, reason: area.area);
      }
      expect(coverageReport([merge]), isNot(contains('in English')));
    });

    final english = _messages('lib/l10n/app_en.arb');
    final french = _messages('lib/l10n/app_fr.arb');

    test('placeholders, plurals and selects match English', () {
      for (final MapEntry(:key, :value) in french.entries) {
        expect(
          icuMismatch(english[key]!, value),
          isNull,
          reason: '$key: $value',
        );
      }
    });

    test('French is written out, not left in English', () {
      final same = {
        for (final key in french.keys)
          if (french[key] == english[key] && !_sameAsEnglish.contains(key)) key,
      };
      expect(same, isEmpty);
    });

    test('French typography: no-break spaces, ’ and « »', () {
      for (final MapEntry(:key, :value) in french.entries) {
        expect(typographyProblems(value), isEmpty, reason: '$key: $value');
      }
    });

    test('no streak, score or guilt wording', () {
      for (final MapEntry(:key, :value) in french.entries) {
        final text = _notTherapyKeys.contains(key)
            ? value.replaceAll(RegExp('diagnostic'), '')
            : value;
        expect(
          bannedFrench.firstMatch(text)?[0],
          isNull,
          reason: '$key: $value',
        );
      }
    });

    test('short copy: no French string runs far beyond its English', () {
      // French runs ~20 % longer; anything much longer gets shortened.
      final long = [
        for (final MapEntry(:key, :value) in french.entries)
          if (english[key]!.length >= 24 &&
              !english[key]!.contains('{') &&
              value.length > (english[key]!.length * 1.5).ceil())
            '$key: "$value" (${value.length}) vs "${english[key]}" '
                '(${english[key]!.length})',
      ];
      expect(long, isEmpty);
    });

    test('vouvoiement throughout (no tutoiement)', () {
      final tu = RegExp(
        r'(?<![\p{L}])(tu|toi|ton|ta|tes|te|t’)(?![\p{L}])',
        caseSensitive: false,
        unicode: true,
      );
      for (final MapEntry(:key, :value) in french.entries) {
        expect(tu.firstMatch(value)?[0], isNull, reason: '$key: $value');
      }
    });
  });

  group('content', () {
    test('every lesson, prompt, day, experiment, notice and the credit '
        'is translated', () {
      final coverage = coverageFor(AppLanguage.fr);
      expect(coverage.incompleteIds, isEmpty, reason: 'shown in English');
      expect(coverage.missingIds, isEmpty);
      expect(coverage.unknown, isEmpty);
      expect(coverage.complete, isTrue);
      expect(coverage.ratio, 1);
      expect(identical(contentFor(AppLanguage.fr), frenchContent), isTrue);
      expect(contentForCode('fr-CA').languageCode, 'fr');
    });

    test('the structure stays English: ids, order, links, answers', () {
      final en = englishContent;
      final fr = frenchContent;
      expect(fr.languageCode, 'fr');
      expect(fr.version, frenchTranslation.version);
      expect(
        [for (final l in fr.lessons) l.id],
        [for (final l in en.lessons) l.id],
      );
      for (var i = 0; i < en.lessons.length; i++) {
        final (e, f) = (en.lessons[i], fr.lessons[i]);
        expect(f.relatedPromptIds, e.relatedPromptIds);
        expect(f.check?.correctIndex, e.check?.correctIndex);
        expect(f.check?.options.length, e.check?.options.length);
      }
      for (var i = 0; i < en.prompts.length; i++) {
        final (e, f) = (en.prompts[i], fr.prompts[i]);
        expect(
          (f.id, f.phase, f.group, f.mapsTo, f.defaultTime, f.core),
          (e.id, e.phase, e.group, e.mapsTo, e.defaultTime, e.core),
        );
        expect(f.softerQuestion == null, e.softerQuestion == null);
        expect(f.sourceReference, e.sourceReference);
      }
      expect(
        [for (final d in fr.thirtyDays) (d.day, d.stage)],
        [for (final d in en.thirtyDays) (d.day, d.stage)],
      );
      expect(
        [for (final x in fr.experiments) (x.id, x.chapter, x.minutes)],
        [for (final x in en.experiments) (x.id, x.chapter, x.minutes)],
      );
      expect(
        [for (final n in fr.notices) (n.id, n.glyph, n.promptId, n.lessonId)],
        [for (final n in en.notices) (n.id, n.glyph, n.promptId, n.lessonId)],
      );
      // The article is credited as published, never translated.
      expect(fr.credit.title, en.credit.title);
      expect(fr.credit.author, en.credit.author);
      expect(fr.credit.articleUrl, en.credit.articleUrl);
      expect(fr.credit.newsletterUrl, en.credit.newsletterUrl);
    });

    final french = contentText(frenchContent);
    final english = contentText(englishContent);

    test('every text is written in French', () {
      expect(french.keys, english.keys);
      for (final MapEntry(:key, :value) in french.entries) {
        expect(value.trim(), isNotEmpty, reason: key);
        expect(value, isNot(english[key]), reason: '$key is still English');
      }
    });

    test('French typography: no-break spaces, ’ and « »', () {
      for (final MapEntry(:key, :value) in french.entries) {
        expect(typographyProblems(value), isEmpty, reason: '$key: $value');
      }
    });

    test('no diagnosis, streak, failure or guilt wording', () {
      for (final MapEntry(:key, :value) in french.entries) {
        expect(bannedFrench.firstMatch(value)?[0], isNull, reason: key);
      }
    });

    test('safety copy survives translation', () {
      final fr = frenchContent;
      // Every prompt with a softer wording in English has one in French,
      // and the heavy questions still point to it.
      for (final id in ['morning.04', 'morning.07']) {
        expect(fr.prompt(id)!.help, contains('plus douce'), reason: id);
      }
      expect(fr.lessons[5].nuance, contains('pas une thérapie'));
      expect(fr.credit.paraphraseNotice, contains('reformulées'));
      expect(fr.credit.paraphraseNotice, contains('pas reproduit'));
      // The evening levers example keeps one action per line, like English.
      expect(
        fr.prompt('evening.07')!.example.split('\n').length,
        englishContent.prompt('evening.07')!.example.split('\n').length,
      );
    });

    test('experiment steps stay short (one line each, 1–3 steps)', () {
      for (final e in frenchContent.experiments) {
        expect(e.steps.length, inInclusiveRange(1, 3), reason: e.id);
        for (final s in e.steps) {
          expect(s.length, lessThanOrEqualTo(100), reason: '${e.id}: $s');
        }
      }
    });

    test('vouvoiement throughout (no tutoiement)', () {
      final tu = RegExp(
        r'(?<![\p{L}])(tu|toi|ton|ta|tes|te|t’)(?![\p{L}])',
        caseSensitive: false,
        unicode: true,
      );
      for (final MapEntry(:key, :value) in french.entries) {
        expect(tu.firstMatch(value)?[0], isNull, reason: '$key: $value');
      }
    });
  });

  group('the typography check itself', () {
    test('catches what it should', () {
      expect(typographyProblems('Prêt ?'), isNotEmpty);
      expect(typographyProblems('Prêt?'), isNotEmpty);
      expect(typographyProblems('Note: oui'), isNotEmpty);
      expect(typographyProblems('« mot »'), isNotEmpty);
      expect(typographyProblems("l'app"), isNotEmpty);
      expect(typographyProblems('Prêt$_nbsp?'), isEmpty);
      expect(typographyProblems('Note$_nbsp: «${_nbsp}mot$_nbsp»'), isEmpty);
      expect(typographyProblems('l’app, 21 h, {count}/{max}'), isEmpty);
    });

    test('the banned list catches French equivalents', () {
      expect(bannedFrench.hasMatch('Votre série de 3 jours'), isTrue);
      expect(bannedFrench.hasMatch('Vous avez échoué'), isTrue);
      expect(bannedFrench.hasMatch('Vous êtes en retard'), isTrue);
      expect(bannedFrench.hasMatch('Un point de vue'), isFalse);
      expect(bannedFrench.hasMatch('Une petite collection'), isFalse);
    });
  });
}
