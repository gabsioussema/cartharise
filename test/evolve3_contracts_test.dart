// Step 3.0 contracts (docs/plans/evolve.md): the language setting and its
// resolution (incl. "Same as phone"), strings merged for every language with
// English fallback, a coverage report and strict placeholder checks, content
// per language falling back to English per item by permanent id, right to
// left for Arabic, a per-language font slot, and the voice service
// interfaces with their stubs and fakes.
import 'dart:io';

import 'package:cartharise/app_locale.dart';
import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/domain/content_translation.dart';
import 'package:cartharise/l10n/app_localizations.dart';
import 'package:cartharise/services/dictation.dart';
import 'package:cartharise/services/read_aloud.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../tool/merge_arb.dart';
import 'support/test_app.dart';

final _t = DateTime(2026, 11, 3, 9, 30);

Map<String, Object?> _settingsJson(AppSettings s) =>
    (const AppData().copyWith(settings: s).toJson()['settings']!
            as Map<String, Object?>)
        .cast<String, Object?>();

AppSettings _settingsFrom(Map<String, Object?> settings) =>
    AppData.fromJson({...const AppData().toJson(), 'settings': settings})
        .settings;

/// A French draft of a few fake items: complete ones, an incomplete prompt
/// (no softer wording though English has one), a check with the wrong
/// number of options, and an id English doesn't have.
const _frDraft = ContentTranslation(
  languageCode: 'fr',
  version: 3,
  prompts: {
    'morning.01': PromptText(
      title: 'Titre matin 1',
      question: 'Question matin 1 ?',
      context: 'Contexte matin 1.',
      help: 'Aide matin 1.',
      example: 'Exemple matin 1.',
    ),
    'morning.05': PromptText(
      title: 'Titre matin 5',
      question: 'Question matin 5 ?',
      context: 'Contexte.',
      help: 'Aide.',
      example: 'Exemple.',
      // English has a softer wording: incomplete → stays English.
    ),
    'daytime.01': PromptText(
      title: 'Pause 1',
      question: 'Que fuis-tu ?',
      context: 'Contexte.',
      help: 'Aide.',
      example: 'Exemple.',
    ),
    'evening.03': PromptText(
      title: 'Soir 3',
      question: 'Question soir 3 ?',
      context: 'Contexte.',
      help: 'Aide.',
      example: 'Exemple.',
    ),
    'morning.99': PromptText(
      title: 'x',
      question: 'x',
      context: 'x',
      help: 'x',
      example: 'x',
    ),
  },
  lessons: {
    'lesson.01': LessonText(
      title: 'Leçon 1',
      summary: 'Résumé 1.',
      explanation: 'Explication 1.',
      example: 'Exemple 1.',
      nuance: 'Nuance 1.',
      check: CheckText(
        question: 'Question ?',
        options: ['A', 'B', 'C'],
        explanation: 'Parce que.',
      ),
    ),
    'lesson.02': LessonText(
      title: 'Leçon 2',
      summary: 'Résumé 2.',
      explanation: 'Explication 2.',
      example: 'Exemple 2.',
      nuance: 'Nuance 2.',
      check: CheckText(
        question: 'Question ?',
        options: ['A', 'B'],
        explanation: 'Parce que.',
      ),
    ),
  },
  thirtyDays: {
    2: PathDayText(
      title: 'Jour 2',
      prompt: 'Question du jour 2 ?',
      hint: 'Indice.',
    ),
    4: PathDayText(title: 'Jour 4', prompt: 'Question du jour 4 ?'),
  },
  experiments: {
    'try.terrain.01': ExperimentText(
      title: 'Essaie terrain',
      steps: ['Une étape.'],
    ),
  },
  notices: {'notice.02': NoticeText(title: 'Remarque 2')},
  credit: CreditText(
    publishedOn: '23 décembre 2025',
    independenceNotice: 'Indépendant.',
    paraphraseNotice: 'Questions reformulées.',
  ),
);

void main() {
  group('AppSettings.language', () {
    test('defaults to system and round-trips every language', () {
      expect(const AppSettings().language, AppLanguage.system);
      expect(AppData.empty.settings.language, AppLanguage.system);
      for (final language in AppLanguage.values) {
        final json = _settingsJson(AppSettings(language: language));
        expect(json['language'], language.name);
        expect(_settingsFrom(json).language, language);
      }
    });

    test(
      'older files, and languages from a newer version, follow the phone',
      () {
        final json = _settingsJson(const AppSettings(language: AppLanguage.ar))
          ..remove('language');
        expect(_settingsFrom(json).language, AppLanguage.system);
        json['language'] = 'de';
        expect(_settingsFrom(json).language, AppLanguage.system);
        json['language'] = 7;
        expect(() => _settingsFrom(json), throwsFormatException);
      },
    );

    test('copyWith keeps it unless given', () {
      const s = AppSettings(language: AppLanguage.fr);
      expect(s.copyWith(theme: AppTheme.olive).language, AppLanguage.fr);
      expect(s.copyWith(language: AppLanguage.en).language, AppLanguage.en);
    });

    test('codes and direction', () {
      expect(AppLanguage.system.code, isNull);
      expect([for (final l in kAppLanguages) l.code], ['en', 'fr', 'ar']);
      expect(
        [for (final l in AppLanguage.values) l.isRtl],
        [false, false, false, true],
      );
    });
  });

  group('language resolution', () {
    test('an explicit setting wins over the phone', () {
      expect(resolveLanguage(AppLanguage.en, ['fr', 'ar']), AppLanguage.en);
      expect(resolveLanguage(AppLanguage.ar, ['en']), AppLanguage.ar);
      expect(resolveLanguage(AppLanguage.fr, const []), AppLanguage.fr);
    });

    test(
      'system: the first preferred language Cartharise ships, else English',
      () {
        expect(resolveLanguage(AppLanguage.system, ['fr']), AppLanguage.fr);
        expect(
          resolveLanguage(AppLanguage.system, ['de', 'ar', 'fr']),
          AppLanguage.ar,
        );
        expect(
          resolveLanguage(AppLanguage.system, ['de', 'es']),
          AppLanguage.en,
        );
        expect(resolveLanguage(AppLanguage.system, const []), AppLanguage.en);
        for (final setting in AppLanguage.values) {
          for (final device in [
            const <String>[],
            ['de'],
            ['ar'],
          ]) {
            expect(resolveLanguage(setting, device), isNot(AppLanguage.system));
          }
        }
      },
    );

    test('codes and tags', () {
      expect(languageForCode('fr'), AppLanguage.fr);
      expect(languageForCode('fr-CA'), AppLanguage.fr);
      expect(languageForCode('ar_EG'), AppLanguage.ar);
      expect(languageForCode('EN'), AppLanguage.en);
      expect(languageForCode('de'), isNull);
      expect(languageForCode('system'), isNull);
    });

    test('locales: what MaterialApp gets', () {
      expect(kAppLocales, const [Locale('en'), Locale('fr'), Locale('ar')]);
      expect(
        AppLocalizations.supportedLocales.toSet(),
        kAppLocales.toSet(),
        reason: 'every shipped language has generated strings',
      );
      expect(localeFor(AppLanguage.ar), const Locale('ar'));
      expect(localeFor(AppLanguage.system), const Locale('en'));
      expect(
        resolveAppLocale(AppLanguage.system, const [
          Locale('de', 'DE'),
          Locale('ar', 'EG'),
        ]),
        const Locale('ar'),
      );
      expect(
        resolveAppLocale(AppLanguage.system, const [Locale('ja')]),
        const Locale('en'),
      );
      expect(
        resolveAppLocale(AppLanguage.fr, const [Locale('ar')]),
        const Locale('fr'),
      );
      expect(lookupAppLocalizations(const Locale('ar')).localeName, 'ar');
      expect(lookupAppLocalizations(const Locale('fr')).localeName, 'fr');
    });

    test('iOS and Android declare the same languages', () {
      final codes = [for (final l in kAppLanguages) l.code];
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      final ios = RegExp(
        r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
        dotAll: true,
      ).firstMatch(plist);
      expect(ios, isNotNull, reason: 'CFBundleLocalizations');
      expect([
        for (final m in RegExp(
          r'<string>([^<]+)</string>',
        ).allMatches(ios!.group(1)!))
          m.group(1),
      ], codes);
      final android = File('android/app/src/main/res/xml/locales_config.xml')
          .readAsStringSync();
      expect([
        for (final m in RegExp(
          r'<locale android:name="([^"]+)"',
        ).allMatches(android))
          m.group(1),
      ], codes);
      expect(
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
        contains('android:localeConfig="@xml/locales_config"'),
      );
    });
  });

  group('strings for every language (tool/merge_arb.dart)', () {
    const english = [
      ArbFragment('common_en.arb', '''{
        "save": "Save",
        "@save": {"description": "Button."},
        "hello": "Hello {name}",
        "@hello": {"placeholders": {"name": {"type": "String"}}}
      }'''),
      ArbFragment('today_en.arb', '''{
        "todayDays": "{count, plural, =1{1 day} other{{count} days}}",
        "todayPlace": "{place, select, home{At home} work{At work} other{Out}}",
        "todayDone": "Done"
      }'''),
    ];

    test('a key not translated falls back to English, in English order', () {
      final merge = mergeTranslation('fr', english, const [
        ArbFragment('today_fr.arb', '''{
          "@@locale": "fr",
          "todayDone": "Fini",
          "@todayDone": {"description": "ignored in translations"},
          "todayPlace": "{place, select, work{Au travail} home{À la maison} other{Dehors}}"
        }'''),
        ArbFragment('common_fr.arb', '{"@@locale": "fr", "save": ""}'),
      ]);
      expect(merge.arb, '''{
  "@@locale": "fr",
  "save": "Save",
  "hello": "Hello {name}",
  "todayDays": "{count, plural, =1{1 day} other{{count} days}}",
  "todayPlace": "{place, select, work{Au travail} home{À la maison} other{Dehors}}",
  "todayDone": "Fini"
}
''');
      expect(merge.total, 5);
      expect(merge.translated, 2);
      expect(merge.missing, ['save', 'hello', 'todayDays']);
      expect(merge.summary, contains('2/5'));
      expect(merge.summary, contains('3 fall back to English'));
      expect([for (final a in merge.areas) a.area], ['common', 'today']);
    });

    test('the report: complete, not started, and what is still English', () {
      final fr = mergeTranslation('fr', english, const [
        ArbFragment(
          'common_fr.arb',
          '{"save": "Enregistrer", "hello": "Bonjour {name}"}',
        ),
        ArbFragment('today_fr.arb', '{"todayDone": "Fini"}'),
      ]);
      final ar = mergeTranslation('ar', english, const []);
      final report = coverageReport([fr, ar]);
      expect(report, contains('fr: 3/5'));
      expect(report, contains('complete'));
      expect(report, contains('in English: todayDays, todayPlace'));
      expect(report, contains('ar: 0/5'));
      expect(report, contains('not started'));
      expect(ar.arb, contains('"@@locale": "ar"'));
      expect(ar.missing, hasLength(5));
    });

    test('placeholders, plurals and selects must match English', () {
      void fails(String key, String value, Matcher message) => expect(
        () => mergeTranslation('fr', english, [
          ArbFragment('x_fr.arb', '{"$key": ${_quote(value)}}'),
        ]),
        throwsA(
          isA<ArbMergeException>().having((e) => e.message, 'message', message),
        ),
        reason: value,
      );
      fails('hello', 'Bonjour', contains('placeholders'));
      fails('hello', 'Bonjour {nom}', contains('{name}'));
      fails('hello', 'Bonjour {name', contains('not a valid message'));
      fails('todayDone', 'Fini {count}', contains('placeholders'));
      fails('todayDays', '{count} jours', contains('plural'));
      fails('todayDays', '{count, plural, =1{1 jour}}', contains('other'));
      fails(
        'todayPlace',
        '{place, select, home{Maison} other{Dehors}}',
        contains('cases'),
      );
      fails('todayPlace', '{place, plural, other{x}}', contains('plural'));
      // Plural cases may differ from English (Arabic needs six).
      expect(
        mergeTranslation('ar', english, const [
          ArbFragment(
            'today_ar.arb',
            '{"todayDays": "{count, plural, zero{لا أيام} one{يوم} two{يومان} few{{count} أيام} many{{count} يومًا} other{{count} يوم}}"}',
          ),
        ]).translated,
        1,
      );
      expect(icuMismatch('Hello {name}', 'Bonjour {name} !'), isNull);
    });

    test('anything else wrong fails the merge loudly', () {
      void fails(List<ArbFragment> fr, Matcher message) => expect(
        () => mergeTranslation('fr', english, fr),
        throwsA(
          isA<ArbMergeException>().having((e) => e.message, 'message', message),
        ),
      );
      fails(const [
        ArbFragment('today_fr.arb', '{"todayDon": "Fini"}'),
      ], contains('todayDon'));
      fails(const [
        ArbFragment('today_fr.arb', '{"@@locale": "ar"}'),
      ], contains('@@locale'));
      fails(const [
        ArbFragment('today_fr.arb', '{"todayDone": 3}'),
      ], contains('string'));
      fails(const [
        ArbFragment('today_fr.arb', '{"todayDone": "Fini"'),
      ], contains('JSON'));
      fails(const [
        ArbFragment('common_fr.arb', '{"todayDone": "Fini"}'),
        ArbFragment('today_fr.arb', '{"todayDone": "Terminé"}'),
      ], contains('duplicate'));
    });

    test('fragment names say area and language', () {
      expect(arbLanguageOf('today_fr.arb'), 'fr');
      expect(arbLanguageOf('read_aloud_ar.arb'), 'ar');
      expect(arbAreaOf('read_aloud_ar.arb'), 'read_aloud');
      expect(arbLanguageOf('today.arb'), isNull);
      expect(kArbLanguages, [for (final l in kAppLanguages) l.code]);
    });
  });

  group('content per language', () {
    final fr = translateContent(fakeContent, _frDraft);

    test('a complete translation is used; structure stays English', () {
      expect(fr.languageCode, 'fr');
      expect(fr.version, 3);
      final m1 = fr.prompt('morning.01')!;
      final en1 = fakeContent.prompt('morning.01')!;
      expect(m1.question, 'Question matin 1 ?');
      expect(m1.title, 'Titre matin 1');
      expect(m1.example, 'Exemple matin 1.');
      expect(m1.phase, en1.phase);
      expect(m1.ordinal, en1.ordinal);
      expect(m1.group, en1.group);
      expect(m1.sourceReference, en1.sourceReference);
      expect(fr.prompt('daytime.01')!.defaultTime, '11:00');
      expect(fr.prompt('evening.03')!.mapsTo, CompassField.antiVision);
      final l1 = fr.lesson('lesson.01')!;
      expect(l1.title, 'Leçon 1');
      expect(l1.check!.options, ['A', 'B', 'C']);
      expect(
        l1.check!.correctIndex,
        fakeContent.lesson('lesson.01')!.check!.correctIndex,
      );
      expect(l1.relatedPromptIds, ['morning.01']);
      expect(fr.thirtyDays[1].title, 'Jour 2');
      expect(fr.thirtyDays[1].hint, 'Indice.');
      final tried = fr.experiment('try.terrain.01')!;
      expect(tried.title, 'Essaie terrain');
      expect(tried.steps, ['Une étape.']);
      expect(tried.minutes, 5);
      expect(tried.chapter, CampaignChapter.terrain);
      final n2 = fr.notice('notice.02')!;
      expect(n2.title, 'Remarque 2');
      expect(n2.lessonId, 'lesson.01');
      expect(n2.glyph, CarthaGlyph.reflection);
      expect(fr.credit.publishedOn, '23 décembre 2025');
      expect(fr.credit.title, fakeContent.credit.title);
      expect(fr.credit.articleUrl, fakeContent.credit.articleUrl);
    });

    test('missing or incomplete items fall back to English, whole', () {
      expect(fr.prompt('morning.02')!.question, 'Question morning 2?');
      final m5 = fr.prompt('morning.05')!;
      expect(m5.question, 'Question morning 5?', reason: 'never half French');
      expect(m5.softerQuestion, 'Softer question morning 5?');
      expect(fr.lesson('lesson.02')!.title, 'Lesson 2 title');
      expect(fr.thirtyDays[3].title, 'Day 4 title', reason: 'hint missing');
      expect(fr.notice('notice.01')!.title, 'Notice 1 title');
      expect(fr.prompt('morning.99'), isNull, reason: 'never a new item');
    });

    test('ids, order and counts never change across languages', () {
      List<String> ids(ContentLibrary c) => [
        for (final l in c.lessons) l.id,
        for (final p in c.prompts) p.id,
        for (final d in c.thirtyDays) pathDayId(d.day),
        for (final e in c.experiments) e.id,
        for (final n in c.notices) n.id,
      ];
      expect(ids(fr), ids(fakeContent));
      for (final language in kAppLanguages) {
        final library = contentFor(language);
        expect(library.languageCode, language.code);
        expect(ids(library), ids(englishContent), reason: language.name);
        expect(library.corePrompts.length, englishContent.corePrompts.length);
      }
      expect(identical(contentFor(AppLanguage.system), englishContent), isTrue);
      expect(contentForCode('ar-EG').languageCode, 'ar');
      expect(identical(contentForCode('de'), englishContent), isTrue);
    });

    test('coverage says which ids are translated', () {
      final coverage = contentCoverage(fakeContent, _frDraft);
      expect(coverage.languageCode, 'fr');
      expect(coverage.translated[ContentKind.prompt], [
        'morning.01',
        'daytime.01',
        'evening.03',
      ]);
      expect(coverage.incomplete[ContentKind.prompt], ['morning.05']);
      expect(coverage.translated[ContentKind.lesson], ['lesson.01']);
      expect(coverage.incomplete[ContentKind.lesson], ['lesson.02']);
      expect(coverage.translated[ContentKind.pathDay], ['path.02']);
      expect(coverage.incomplete[ContentKind.pathDay], ['path.04']);
      expect(coverage.translated[ContentKind.experiment], ['try.terrain.01']);
      expect(coverage.translated[ContentKind.notice], ['notice.02']);
      expect(coverage.translated[ContentKind.credit], [kCreditId]);
      expect(coverage.unknown, ['morning.99']);
      expect(coverage.missingIds, contains('morning.02'));
      expect(coverage.total, 7 + 30 + 30 + 10 + 2 + 1);
      expect(coverage.complete, isFalse);

      // English measured against itself is complete (and so every English
      // item meets the completeness rules a translation must meet).
      final en = coverageFor(AppLanguage.en);
      expect(en.complete, isTrue, reason: '${en.incompleteIds}');
      expect(en.ratio, 1);
      for (final language in [AppLanguage.fr, AppLanguage.ar]) {
        final c = coverageFor(language);
        expect(c.unknown, isEmpty, reason: language.name);
        expect(c.total, en.total);
      }
    });

    test(
      'AppState follows the language without touching the user data',
      () async {
        final store = MemoryDataStore(onboardedData());
        final reminders = FakeReminderScheduler();
        final state = AppState(
          store: store,
          content: fakeContent,
          reminders: reminders,
          clock: () => _t,
          contentFor: (l) => l == AppLanguage.fr ? fr : fakeContent,
          deviceLanguages: const ['de'],
        );
        await state.load();
        expect(state.language, AppLanguage.en);
        await state.saveAnswer('morning.01', '  Mes mots, tels quels.\n');
        await state.enableReminders();
        expect(reminders.scheduled.first.title, 'Daytime 1 title');
        final before = state.data;

        await state.setLanguage(AppLanguage.fr);
        expect(state.settings.language, AppLanguage.fr);
        expect(state.language, AppLanguage.fr);
        expect(
          state.content.prompt('morning.01')!.question,
          'Question matin 1 ?',
        );
        expect(
          state.data.copyWith(settings: before.settings).toJson(),
          before.toJson(),
          reason: 'only the setting changed',
        );
        expect(state.answer('morning.01')!.body, '  Mes mots, tels quels.\n');
        expect(store.saved!.settings.language, AppLanguage.fr);
        expect(
          reminders.scheduled.first.title,
          'Pause 1',
          reason: 'check-ins re-worded in the new language',
        );

        // "Same as phone" follows the phone's languages as they change.
        await state.setLanguage(AppLanguage.system);
        expect(state.language, AppLanguage.en);
        var notified = 0;
        state.addListener(() => notified++);
        state.setDeviceLanguages(const ['fr', 'en']);
        expect(state.language, AppLanguage.fr);
        expect(notified, greaterThan(0));
        await pumpEventQueue();
        expect(reminders.scheduled.first.title, 'Pause 1');
        notified = 0;
        state.setDeviceLanguages(const ['fr']);
        expect(notified, 0, reason: 'nothing to rebuild');
        await state.setLanguage(AppLanguage.en);
        notified = 0;
        state.setDeviceLanguages(const ['ar']);
        expect(notified, 0, reason: 'an explicit setting ignores the phone');
        expect(state.content, same(fakeContent));
      },
    );

    test('without contentFor (tests), the library passed in is used', () async {
      final state = AppState(
        store: MemoryDataStore(
          onboardedData(settings: const AppSettings(language: AppLanguage.ar)),
        ),
        content: fakeContent,
        reminders: FakeReminderScheduler(),
        clock: () => _t,
      );
      await state.load();
      expect(state.language, AppLanguage.ar);
      expect(state.content, same(fakeContent));
    });
  });

  group('the app in each language', () {
    Future<BuildContext> pumpIn(
      WidgetTester tester, {
      AppLanguage language = AppLanguage.system,
    }) async {
      late BuildContext captured;
      await pumpCartha(
        tester,
        data: onboardedData(settings: AppSettings(language: language)),
        home: Builder(
          builder: (context) {
            captured = context;
            return const Scaffold(body: Text('ok'));
          },
        ),
      );
      return captured;
    }

    testWidgets('Arabic: right to left, Arabic strings, no Cinzel', (
      tester,
    ) async {
      final context = await pumpIn(tester, language: AppLanguage.ar);
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Localizations.localeOf(context), const Locale('ar'));
      expect(AppLocalizations.of(context).localeName, 'ar');
      final theme = Theme.of(context);
      expect(theme.extension<CarthaFonts>()!.letterSpacing, isFalse);
      for (final style in [
        theme.textTheme.displayLarge,
        theme.textTheme.headlineSmall,
        theme.textTheme.titleLarge,
        theme.textTheme.bodyLarge,
        theme.textTheme.labelLarge,
      ]) {
        expect(style!.fontFamily, isNot(CarthaFonts.cinzel));
        expect(style.fontFamily, CarthaFonts.arabicFamily ?? CarthaFonts.inter);
        expect(style.letterSpacing ?? 0, 0, reason: 'joined letters');
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('French: left to right, Cinzel titles', (tester) async {
      final context = await pumpIn(tester, language: AppLanguage.fr);
      expect(Directionality.of(context), TextDirection.ltr);
      expect(Localizations.localeOf(context), const Locale('fr'));
      expect(
        Theme.of(context).textTheme.headlineSmall!.fontFamily,
        CarthaFonts.cinzel,
      );
    });

    testWidgets('Same as phone: follows the phone, live', (tester) async {
      tester.platformDispatcher.localesTestValue = const [
        Locale('de'),
        Locale('ar', 'EG'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      var context = await pumpIn(tester);
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Localizations.localeOf(context), const Locale('ar'));

      tester.platformDispatcher.localesTestValue = const [Locale('ja')];
      await tester.pump();
      await tester.pump();
      context = tester.element(find.text('ok'));
      expect(Directionality.of(context), TextDirection.ltr);
      expect(Localizations.localeOf(context), const Locale('en'));
    });

    testWidgets('choosing a language switches the whole app at once', (
      tester,
    ) async {
      final harness = await pumpCartha(
        tester,
        data: onboardedData(),
        contentFor: (l) => l == AppLanguage.fr
            ? translateContent(fakeContent, _frDraft)
            : fakeContent,
        home: Builder(
          builder: (context) {
            final state = context.watch<AppState>();
            return Scaffold(
              body: Text(state.content.prompt('morning.01')!.title),
            );
          },
        ),
      );
      expect(find.text('Morning 1 title'), findsOneWidget);
      await harness.state.setLanguage(AppLanguage.fr);
      await tester.pump();
      await tester.pump();
      expect(find.text('Titre matin 1'), findsOneWidget);
      expect(
        Localizations.localeOf(tester.element(find.text('Titre matin 1'))),
        const Locale('fr'),
      );
    });
  });

  group('fonts per language (theme slot)', () {
    void expectEveryStyle(ThemeData theme, String family) {
      final t = theme.textTheme;
      for (final style in [
        t.displayLarge,
        t.displayMedium,
        t.displaySmall,
        t.headlineLarge,
        t.headlineMedium,
        t.headlineSmall,
        t.titleLarge,
        t.titleMedium,
        t.titleSmall,
        t.bodyLarge,
        t.bodyMedium,
        t.bodySmall,
        t.labelLarge,
        t.labelMedium,
        t.labelSmall,
      ]) {
        expect(style!.fontFamily, family);
        expect(style.letterSpacing ?? 0, 0);
      }
      expect(theme.appBarTheme.titleTextStyle!.fontFamily, family);
      expect(theme.dialogTheme.contentTextStyle!.fontFamily, family);
    }

    test('Arabic uses the slot for every style, display and headline too', () {
      final fonts = CarthaFonts.forLanguage(
        AppLanguage.ar,
        arabic: 'TestArabic',
      );
      expect(fonts.text, 'TestArabic');
      expect(fonts.display, 'TestArabic');
      expect(fonts.spacing(1.2), 0);
      for (final brightness in Brightness.values) {
        final theme = CarthaTheme.build(
          AppTheme.forest,
          brightness,
          fonts: fonts,
        );
        expectEveryStyle(theme, 'TestArabic');
        expect(theme.extension<CarthaFonts>(), fonts);
      }
    });

    test('an empty slot (null) means the default family, never Cinzel', () {
      final fonts = CarthaFonts.forLanguage(AppLanguage.ar, arabic: null);
      expect(fonts.text, CarthaFonts.inter);
      expect(fonts.display, CarthaFonts.inter);
      expectEveryStyle(
        CarthaTheme.build(AppTheme.obsidian, Brightness.light, fonts: fonts),
        CarthaFonts.inter,
      );
      expect(
        CarthaFonts.forLanguage(AppLanguage.ar).text,
        CarthaFonts.arabicFamily ?? CarthaFonts.inter,
      );
    });

    test('Latin languages keep Cinzel titles and Inter text', () {
      for (final language in [
        AppLanguage.en,
        AppLanguage.fr,
        AppLanguage.system,
      ]) {
        expect(CarthaFonts.forLanguage(language), CarthaFonts.latin);
      }
      final theme = CarthaTheme.build(AppTheme.forest, Brightness.dark);
      expect(theme.extension<CarthaFonts>(), CarthaFonts.latin);
      expect(theme.textTheme.headlineSmall!.fontFamily, 'Cinzel');
      expect(theme.textTheme.headlineSmall!.letterSpacing, 0.4);
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Inter');
      expect(CarthaFonts.latin.spacing(1.2), 1.2);
    });
  });

  group('voice interfaces', () {
    test('the stubs say "not on this phone" honestly', () async {
      const dictation = UnsupportedDictation();
      expect(
        await dictation.availability('fr-FR'),
        DictationAvailability.unsupported,
      );
      final events = await dictation.start('fr-FR').toList();
      expect(events, hasLength(2));
      expect(
        (events.first as DictationError).reason,
        DictationFailure.unsupported,
      );
      expect(events.last, isA<DictationEnded>());
      expect(dictation.isListening, isFalse);

      const readAloud = UnavailableReadAloud();
      expect(await readAloud.available('en-US'), isFalse);
      await expectLater(
        readAloud.speak('My private note', languageTag: 'en-US'),
        throwsA(
          isA<ReadAloudException>()
              .having((e) => e.reason, 'reason', ReadAloudFailure.unavailable)
              .having((e) => e.toString(), 'text', isNot(contains('private'))),
        ),
      );
      expect(readAloud.isSpeaking, isFalse);
    });

    test(
      'FakeDictation: partial text, levels, a final text for review',
      () async {
        final dictation = FakeDictation(
          availabilityFor: {'ar': DictationAvailability.needsModel},
        )..finalText = 'Hello there';
        expect(
          await dictation.availability('en-US'),
          DictationAvailability.available,
        );
        expect(
          await dictation.availability('ar'),
          DictationAvailability.needsModel,
        );
        final events = <DictationEvent>[];
        final done = dictation
            .start('en-US')
            .listen(events.add)
            .asFuture<void>();
        expect(dictation.isListening, isTrue);
        dictation
          ..partial('Hel')
          ..level(0.4)
          ..partial('Hello');
        final busy = await dictation.start('en-US').toList();
        expect((busy.first as DictationError).reason, DictationFailure.busy);
        await dictation.stop();
        await done;
        expect(
          [
            for (final e in events)
              switch (e) {
                DictationPartial(:final text) => 'partial:$text',
                DictationLevel(:final level) => 'level:$level',
                DictationFinal(:final text) => 'final:$text',
                DictationError(:final reason) => 'error:${reason.name}',
                DictationEnded() => 'ended',
              },
          ],
          [
            'partial:Hel',
            'level:0.4',
            'partial:Hello',
            'final:Hello there',
            'ended',
          ],
        );
        expect(dictation.isListening, isFalse);
        expect(dictation.started, ['en-US', 'en-US']);

        final needsModel = await dictation.start('ar').toList();
        expect(
          (needsModel.first as DictationError).reason,
          DictationFailure.needsModel,
        );

        // Cancel: no final text. Fail: the reason, then the end.
        final cancelled = dictation.start('en-US').toList();
        await dictation.cancel();
        expect(await cancelled, [isA<DictationEnded>()]);
        final failed = dictation.start('en-US').toList();
        await dictation.fail(DictationFailure.interrupted);
        expect(
          ((await failed).first as DictationError).reason,
          DictationFailure.interrupted,
        );
        expect(dictation.cancelCount, 1);
      },
    );

    test('FakeReadAloud: speaks on request, stops, reports', () async {
      final voice = FakeReadAloud(availableTags: {'en-US', 'fr-FR'});
      final states = <bool>[];
      voice.speaking.listen(states.add);
      expect(await voice.available('fr-FR'), isTrue);
      expect(await voice.available('ar'), isFalse);
      await voice.speak('A lesson', languageTag: 'fr-FR');
      expect(voice.isSpeaking, isTrue);
      await voice.stop();
      expect(voice.isSpeaking, isFalse);
      await voice.speak('Another', languageTag: 'en-US');
      voice.finish();
      await expectLater(
        voice.speak('x', languageTag: 'ar'),
        throwsA(isA<ReadAloudException>()),
      );
      await pumpEventQueue();
      expect(states, [true, false, true, false]);
      expect(voice.spoken.map((s) => s.languageTag), ['fr-FR', 'en-US']);
      expect(voice.stopCount, 1);
    });

    testWidgets('both are provided to the app like the other services', (
      tester,
    ) async {
      late BuildContext context;
      final harness = await pumpCartha(
        tester,
        data: onboardedData(),
        home: Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      expect(context.read<Dictation>(), same(harness.dictation));
      expect(context.read<ReadAloud>(), same(harness.readAloud));
    });
  });
}

String _quote(String s) =>
    '"${s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')}"';
