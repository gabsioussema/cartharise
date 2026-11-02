// Arabic and right to left (plan step 3 › I): every string and content item
// in Arabic, the bundled Arabic font on every style (never Cinzel), mirrored
// arrows and route, mixed Arabic/Latin text, no judging words, and the main
// screens at every size of the matrix in dark and light without overflow.
import 'dart:convert';
import 'dart:io';

import 'package:cartharise/content/ar.dart';
import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/local_date.dart';
import 'package:cartharise/l10n/app_localizations.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/campaign/campaign_pages.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/theme/cartha_theme.dart';
import 'package:cartharise/ui/widgets/bidi.dart';
import 'package:cartharise/ui/you/font_licenses.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/merge_arb.dart';
import '../support/test_app.dart';

final _at = DateTime(2026, 11, 2, 8);

/// An Arabic user mid-way: an Arabic name, a reset in progress, an Arabic
/// Compass, quests on the board, a month project, notes (one mixing Arabic
/// and Latin), a path day and the Campaign on — so every main screen has
/// real Arabic content to lay out.
AppData arabicData({bool game = true}) =>
    onboardedData(
      name: 'سارة',
      settings: AppSettings(
        language: AppLanguage.ar,
        game: game,
        gameInvited: true,
      ),
    ).copyWith(
      journeys: [
        Journey(
          id: 'journey_1',
          startedAt: _at,
          activePromptId: 'morning.04',
          answers: {
            'morning.01': ReflectionAnswer(
              promptId: 'morning.01',
              body: 'أتصفّح الهاتف حتى وقت متأخر كل مساء.',
              updatedAt: _at,
            ),
            'morning.02': ReflectionAnswer(
              promptId: 'morning.02',
              body: 'My commute is too long (45 min).',
              updatedAt: _at,
            ),
            'morning.03': ReflectionAnswer(
              promptId: 'morning.03',
              body: 'ربما أحتاج إلى الراحة أكثر من التدريب.',
              updatedAt: _at,
            ),
          },
        ),
      ],
      currentJourneyId: () => 'journey_1',
      lessonsRead: {'lesson.01'},
      quests: [
        Quest(
          id: 'q1',
          title: 'المشي 20 دقيقة',
          createdAt: _at,
          recurrence: QuestRecurrence.daily,
          source: QuestSource.dailyLever,
        ),
        Quest(
          id: 'q2',
          title: 'Read 10 pages of «Dune»',
          createdAt: _at,
          dueDate: dateKey(kTestNow),
        ),
        Quest(
          id: 'q3',
          title: 'كتابة صفحة واحدة من المشروع',
          createdAt: _at,
          stage: QuestStage.doing,
        ),
      ],
      compass: LifeCompass(
        antiVision: 'سنة أخرى من التأجيل والانشغال.',
        vision: 'صباحات هادئة، وعمل مركّز، ووقت للعائلة.',
        yearGoal: 'إطلاق مشروع صغير يستخدمه الناس.',
        monthProject: 'النسخة الأولى من تطبيقي',
        dailyLevers: 'المشي 20 دقيقة\nقراءة 10 صفحات',
        constraints: 'النوم، وعشاء العائلة',
        updatedAt: _at,
      ),
      project: () => MonthProject(
        title: 'النسخة الأولى من تطبيقي',
        updatedAt: _at,
        status: ProjectStatus.active,
        milestones: const [
          Milestone(id: 'm1', title: 'رسم الشاشات', done: true),
          Milestone(id: 'm2', title: 'Beta on TestFlight'),
        ],
      ),
      journal: [
        JournalEntry(
          id: 'note_1',
          title: 'نزهة المساء',
          body: 'لاحظت أنني أفكّر بوضوح أكبر في الخارج.',
          createdAt: DateTime(2026, 11, 2, 20, 15),
        ),
        JournalEntry(
          id: 'note_2',
          body: 'Mixed: كان اليوم جيدًا، thanks to Sam (3 km).',
          createdAt: DateTime(2026, 10, 30, 7, 5),
        ),
      ],
      pathAnswers: {
        3: PathAnswer(
          day: 3,
          body: 'ألتقط هاتفي أول شيء في الصباح.',
          updatedAt: _at,
        ),
      },
    );

/// Pumps the real app in Arabic with the real (Arabic) content.
Future<CarthaHarness> pumpArabic(
  WidgetTester tester, {
  AppData? data,
  Widget? home,
  Size size = const Size(390, 844),
  double textScale = 1,
  Brightness brightness = Brightness.dark,
}) => pumpCartha(
  tester,
  data: data ?? arabicData(),
  home: home,
  size: size,
  textScale: textScale,
  brightness: brightness,
  content: englishContent,
  contentFor: contentFor,
);

final _arabicLetter = RegExp(r'[\u0600-\u06FF]');

/// Arabic-Indic digits (Cartharise writes 0–9 in every language).
final _easternDigits = RegExp(r'[\u0660-\u0669\u06F0-\u06F9]');

/// Every painted paragraph's spans: Arabic text in the Arabic family,
/// Cinzel nowhere, and Western digits only (dates included).
void expectArabicFonts(WidgetTester tester) {
  var arabicParagraphs = 0;
  for (final paragraph in tester.renderObjectList<RenderParagraph>(
    find.byType(RichText),
  )) {
    final root = paragraph.text;
    final plain = root.toPlainText();
    expect(
      _easternDigits.hasMatch(plain),
      isFalse,
      reason: '"$plain" mixes in Arabic-Indic digits',
    );
    root.visitChildren((span) {
      expect(
        span.style?.fontFamily,
        isNot(CarthaFonts.cinzel),
        reason: 'Cinzel has no Arabic letters: "$plain"',
      );
      return true;
    });
    if (_arabicLetter.hasMatch(plain)) {
      arabicParagraphs++;
      expect(
        root.style?.fontFamily,
        CarthaFonts.arabicFamily,
        reason: '"$plain" is not in the Arabic font',
      );
      expect(
        root.style?.fontFamilyFallback,
        contains(CarthaFonts.inter),
        reason: 'Latin inside "$plain" falls back to Inter',
      );
    }
  }
  expect(arabicParagraphs, greaterThan(0), reason: 'no Arabic text shown');
}

/// Scroll-safe tap.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await pumpFrames(tester, count: 2);
  await tester.tap(finder);
  await pumpFrames(tester, count: 4);
}

/// The Arabic strings of [area] (`l10n_src/<area>_ar.arb`).
Map<String, Object?> _fragment(String area, String lang) =>
    jsonDecode(File('l10n_src/${area}_$lang.arb').readAsStringSync())
        as Map<String, Object?>;

List<String> _areas() => [
  for (final f in Directory('l10n_src').listSync().whereType<File>())
    if (f.path.endsWith('_en.arb'))
      f.uri.pathSegments.last.replaceAll('_en.arb', ''),
]..sort();

/// Every Arabic interface string, keyed `area.key`.
Map<String, String> _arabicStrings() => {
  for (final area in _areas())
    for (final MapEntry(:key, :value) in _fragment(area, 'ar').entries)
      if (!key.startsWith('@') && value is String) '$area.$key': value,
};

/// Every Arabic content text, keyed by id and field.
Map<String, String> _arabicContentText() {
  final c = arabicContent;
  return {
    for (final l in c.lessons) ...{
      '${l.id}.title': l.title,
      '${l.id}.summary': l.summary,
      '${l.id}.explanation': l.explanation,
      '${l.id}.example': l.example,
      '${l.id}.nuance': l.nuance,
      if (l.check case final check?) ...{
        '${l.id}.check': check.question,
        '${l.id}.check.explanation': check.explanation,
        for (final (i, o) in check.options.indexed) '${l.id}.check.$i': o,
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
      'path.${d.day}.title': d.title,
      'path.${d.day}.prompt': d.prompt,
      'path.${d.day}.hint': ?d.hint,
    },
    for (final e in c.experiments) ...{
      '${e.id}.title': e.title,
      for (final (i, s) in e.steps.indexed) '${e.id}.step$i': s,
    },
    for (final n in c.notices) '${n.id}.title': n.title,
    'credit.publishedOn': c.credit.publishedOn,
    'credit.independence': c.credit.independenceNotice,
    'credit.paraphrase': c.credit.paraphraseNotice,
  };
}

/// Arabic equivalents of the English banned lists (test/content_test.dart,
/// test/campaign_test.dart, test/ui/campaign_test.dart): no streaks, no
/// failure or laziness, no insults, no "fixed your life", anywhere.
final _bannedEverywhere = RegExp(
  'سلسلة|متتالي|فشل|فاشل|كسول|كسل|خاسر|عديم القيمة|مثير للشفقة|'
  'أصلحت حياتك|تم إصلاح حياتك|عقاب|معاقبة|يجب عليك|كان عليك',
);

/// Content (the English content ban adds diagnoses, disorders and "fix
/// your life").
final _bannedInContent = RegExp(
  'تشخيص|اضطراب|إصلاح حياتك|يُصلح حياتك|يصلح حياتك|أصلح حياتك',
);

/// The Campaign never speaks of points, scores, missed or late days.
final _bannedInCampaign = RegExp('نقاط|نقطة|درجة|درجات|فاتك|فائت|متأخر|تأخّر');

void main() {
  group('Arabic strings', () {
    test('every English string has an Arabic translation (100 %)', () {
      final english = [
        for (final area in _areas())
          ArbFragment(
            '${area}_en.arb',
            File('l10n_src/${area}_en.arb').readAsStringSync(),
          ),
      ];
      final arabic = [
        for (final area in _areas())
          ArbFragment(
            '${area}_ar.arb',
            File('l10n_src/${area}_ar.arb').readAsStringSync(),
          ),
      ];
      final merge = mergeTranslation('ar', english, arabic);
      expect(merge.missing, isEmpty);
      expect(merge.translated, merge.total);
      expect(
        merge.summary,
        '${merge.total}/${merge.total} strings '
        'translated (100%)',
      );
    });

    test('every string that has words is written in Arabic', () {
      // Only symbols, placeholders and the brand stay as they are.
      final words = RegExp('[A-Za-z]{2,}');
      String bare(String s) => s
          .replaceAll(RegExp(r'\{[a-zA-Z]+\}'), '')
          .replaceAll(RegExp('Cartharise|XP'), '');
      for (final area in _areas()) {
        final en = _fragment(area, 'en');
        final ar = _fragment(area, 'ar');
        for (final MapEntry(:key, :value) in en.entries) {
          if (key.startsWith('@') || value is! String) continue;
          if (!words.hasMatch(bare(value))) continue;
          expect(
            _arabicLetter.hasMatch(ar[key]! as String),
            isTrue,
            reason: '$area.$key is not in Arabic: ${ar[key]}',
          );
        }
      }
    });

    test('plurals use the six Arabic categories', () {
      final l = lookupAppLocalizations(const Locale('ar'));
      expect(l.localeName, 'ar');
      expect(l.resetPastAnswerCount(0), 'لا إجابات');
      expect(l.resetPastAnswerCount(1), 'إجابة واحدة');
      expect(l.resetPastAnswerCount(2), 'إجابتان');
      expect(l.resetPastAnswerCount(3), '3 إجابات');
      expect(l.resetPastAnswerCount(11), '11 إجابة');
      expect(l.resetPastAnswerCount(100), '100 إجابة');
      expect(l.todayFocusLater(2), contains('مهمّتان'));
      expect(l.mediaMinutes(5), '5 دقائق');
      // Selects keep English's cases.
      expect(l.campaignWaypoint('alps'), 'جبال الألب');
      expect(l.todayNextResumeTitle('evening'), 'متابعة تأمّل المساء');
      // Western digits throughout, as the 'ar' locale formats them.
      expect(l.todayPathDay(12), 'اليوم 12 من 30');
    });

    test('no judging words in any Arabic string', () {
      for (final MapEntry(:key, :value) in _arabicStrings().entries) {
        expect(_bannedEverywhere.hasMatch(value), isFalse, reason: key);
        if (key.startsWith('campaign.')) {
          expect(_bannedInCampaign.hasMatch(value), isFalse, reason: key);
        }
      }
    });
  });

  group('Arabic content', () {
    test('every lesson, prompt, path day, experiment, notice and the credit '
        '(100 %)', () {
      final coverage = coverageFor(AppLanguage.ar);
      expect(coverage.languageCode, 'ar');
      expect(coverage.missingIds, isEmpty);
      expect(coverage.incompleteIds, isEmpty);
      expect(coverage.unknown, isEmpty);
      expect(coverage.complete, isTrue);
      expect(coverage.ratio, 1);
      expect(coverage.total, greaterThan(80));
    });

    test('every content text is Arabic; structure stays English', () {
      for (final MapEntry(:key, :value) in _arabicContentText().entries) {
        expect(_arabicLetter.hasMatch(value), isTrue, reason: key);
      }
      final ar = arabicContent;
      final en = englishContent;
      expect(
        [for (final p in ar.prompts) p.id],
        [for (final p in en.prompts) p.id],
      );
      expect(
        [for (final l in ar.lessons) l.check?.correctIndex],
        [for (final l in en.lessons) l.check?.correctIndex],
      );
      expect(
        [for (final p in ar.prompts) p.mapsTo],
        [for (final p in en.prompts) p.mapsTo],
      );
      expect(ar.credit.title, en.credit.title);
      expect(ar.credit.articleUrl, en.credit.articleUrl);
      expect(contentFor(AppLanguage.ar), same(arabicContent));
    });

    test('no judging words in the Arabic content', () {
      for (final MapEntry(:key, :value) in _arabicContentText().entries) {
        expect(_bannedEverywhere.hasMatch(value), isFalse, reason: key);
        expect(_bannedInContent.hasMatch(value), isFalse, reason: key);
      }
    });

    test('the banned-word lists catch what they should', () {
      expect(_bannedEverywhere.hasMatch('لا تكسر السلسلة'), isTrue);
      expect(_bannedEverywhere.hasMatch('محاولة فاشلة'), isTrue);
      expect(_bannedInContent.hasMatch('هذا تشخيص'), isTrue);
      expect(_bannedInCampaign.hasMatch('+10 نقاط'), isTrue);
      expect(_bannedEverywhere.hasMatch('خطوة صغيرة نحو رؤيتك'), isFalse);
    });
  });

  group('Arabic font', () {
    test('bundled, declared in pubspec.yaml and licensed (OFL)', () async {
      expect(CarthaFonts.arabicFamily, 'NotoSansArabicUI');
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('family: ${CarthaFonts.arabicFamily}'));
      for (final w in ['Regular', 'SemiBold', 'Bold']) {
        final file = File('assets/fonts/NotoSansArabicUI-$w.ttf');
        expect(file.existsSync(), isTrue, reason: w);
        expect(pubspec, contains(file.path));
      }
      final licence = File('assets/fonts/NotoSansArabicUI-OFL.txt')
          .readAsStringSync();
      expect(licence, contains('SIL Open Font License, Version 1.1'));
      expect(licence, contains('The Noto Project Authors'));

      registerFontLicenses();
      final entries = await LicenseRegistry.licenses.toList();
      final noto = entries.where(
        (e) => e.packages.contains('Noto Sans Arabic UI'),
      );
      expect(noto, hasLength(1));
      final text = noto.single.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('SIL OPEN FONT LICENSE Version 1.1'));
      expect(text, contains('The Noto Project Authors'));
    });

    test('Arabic: every style in the Arabic family, Inter for Latin, no '
        'italic, no spacing; Latin unchanged', () {
      final ar = CarthaFonts.forLanguage(AppLanguage.ar);
      expect(ar.text, 'NotoSansArabicUI');
      expect(ar.display, 'NotoSansArabicUI');
      expect(ar.fallback, [CarthaFonts.inter]);
      expect(ar.italic, FontStyle.normal);
      expect(ar.spacing(1.6), 0);
      expect(CarthaFonts.latin.fallback, isNull);
      expect(CarthaFonts.latin.italic, FontStyle.italic);

      final theme = CarthaTheme.build(
        AppTheme.forest,
        Brightness.light,
        fonts: ar,
      );
      final t = theme.textTheme;
      for (final style in [
        t.displayLarge,
        t.headlineMedium,
        t.titleLarge,
        t.bodyMedium,
        t.labelSmall,
        theme.filledButtonTheme.style?.textStyle?.resolve({}),
      ]) {
        expect(style!.fontFamily, 'NotoSansArabicUI');
        expect(style.fontFamilyFallback, [CarthaFonts.inter]);
        expect(style.letterSpacing ?? 0, 0);
      }
      final latin = CarthaTheme.build(AppTheme.forest, Brightness.light);
      expect(latin.textTheme.headlineMedium!.fontFamily, CarthaFonts.cinzel);
      expect(latin.textTheme.bodyMedium!.fontFamilyFallback, isNull);
    });
  });

  group('right to left', () {
    testWidgets('the shell: RTL, Arabic labels, Arabic font, no Cinzel', (
      tester,
    ) async {
      await pumpArabic(tester);
      final context = tester.element(find.byType(NavigationBar));
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Localizations.localeOf(context), const Locale('ar'));
      for (final label in ['اليوم', 'إعادة ضبط', 'البوصلة', 'اليوميات']) {
        expect(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(label),
          ),
          findsOneWidget,
        );
      }
      // The first tab sits at the right edge.
      final today = tester.getCenter(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('اليوم'),
        ),
      );
      final you = tester.getCenter(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('أنت'),
        ),
      );
      expect(today.dx, greaterThan(you.dx));
      expect(find.textContaining('سارة'), findsWidgets);
      expectArabicFonts(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('forward arrows and chevrons are mirrored', (tester) async {
      Future<void> expectMirrored(IconData icon) async {
        final icons = find.byIcon(icon);
        expect(icons, findsWidgets, reason: '$icon');
        for (final element in icons.evaluate()) {
          final transforms = find.descendant(
            of: find.byWidget(element.widget),
            matching: find.byType(Transform),
          );
          expect(transforms, findsOneWidget, reason: '$icon not mirrored');
          final matrix = tester.widget<Transform>(transforms).transform;
          expect(matrix.storage[0], -1, reason: '$icon not mirrored');
        }
      }

      // A lesson's "Next lesson" and "Previous lesson" buttons.
      await pumpArabic(tester, home: const LessonScreen(lessonId: 'lesson.03'));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -4000));
      await pumpFrames(tester, count: 2);
      await expectMirrored(Icons.arrow_forward);
      await expectMirrored(Icons.arrow_back);
      // The Journal's note rows.
      final h = await pumpArabic(tester);
      h.shell.select(AppTab.journal);
      await pumpFrames(tester);
      await expectMirrored(Icons.chevron_right);
    });

    test('every directional icon in lib/ui mirrors itself', () {
      // Icons whose meaning has a direction; each must set
      // matchTextDirection (Material's arrows and chevrons do).
      const directional = <String, IconData>{
        'arrow_forward': Icons.arrow_forward,
        'arrow_back': Icons.arrow_back,
        'chevron_right': Icons.chevron_right,
        'chevron_left': Icons.chevron_left,
        'redo': Icons.redo,
        'undo': Icons.undo,
        'open_in_new': Icons.open_in_new,
        'arrow_forward_ios': Icons.arrow_forward_ios,
        'arrow_back_ios': Icons.arrow_back_ios,
        'send': Icons.send,
        'trending_up': Icons.trending_up,
        'navigate_next': Icons.navigate_next,
        'navigate_before': Icons.navigate_before,
        'keyboard_arrow_right': Icons.keyboard_arrow_right,
        'keyboard_arrow_left': Icons.keyboard_arrow_left,
        'east': Icons.east,
        'west': Icons.west,
        'last_page': Icons.last_page,
        'first_page': Icons.first_page,
      };
      final used = <String>{};
      for (final file in Directory('lib/ui').listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        for (final m in RegExp(
          r'Icons\.([a-z_]+)',
        ).allMatches(file.readAsStringSync())) {
          if (directional.containsKey(m[1])) used.add(m[1]!);
        }
      }
      expect(used, containsAll(['arrow_forward', 'chevron_right']));
      for (final name in used) {
        expect(
          directional[name]!.matchTextDirection,
          isTrue,
          reason: 'Icons.$name points the wrong way in Arabic',
        );
      }
    });

    testWidgets('Hannibal\'s route reads from the right in Arabic', (
      tester,
    ) async {
      // At Carthage (no XP yet) the avatar stands at the start edge.
      final data = arabicData().copyWith(
        journeys: const [],
        currentJourneyId: () => null,
      );
      await pumpArabic(
        tester,
        data: data,
        home: campaignPageScreen(CampaignPage.route),
      );
      final map = tester.getRect(find.byKey(const ValueKey('route-map')));
      final avatar = tester.getCenter(
        find.byKey(const ValueKey('route-map-avatar')),
      );
      expect(avatar.dx, greaterThan(map.center.dx), reason: 'right edge');

      await pumpCartha(
        tester,
        data: data.copyWith(
          settings: data.settings.copyWith(language: AppLanguage.en),
        ),
        home: campaignPageScreen(CampaignPage.route),
      );
      final ltrMap = tester.getRect(find.byKey(const ValueKey('route-map')));
      final ltrAvatar = tester.getCenter(
        find.byKey(const ValueKey('route-map-avatar')),
      );
      expect(ltrAvatar.dx, lessThan(ltrMap.center.dx), reason: 'left edge');
    });

    testWidgets('Same as phone: an Arabic phone gets Arabic onboarding', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ar', 'TN')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await pumpCartha(tester, content: englishContent, contentFor: contentFor);
      final context = tester.element(
        find.byKey(const ValueKey('onboarding-next')),
      );
      expect(Directionality.of(context), TextDirection.rtl);
      expect(
        find.text('يوم واحد صادق من التأمّل. ثم خطوات صغيرة.'),
        findsOneWidget,
      );
      expectArabicFonts(tester);
    });

    testWidgets('mixed Arabic and Latin keeps each word readable', (
      tester,
    ) async {
      await pumpArabic(tester);
      // Latin words, digits and brackets inside Arabic text are laid out
      // without errors, in Inter (the Arabic font's fallback).
      expect(find.textContaining('Read 10 pages'), findsWidgets);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.textContaining('Read 10 pages').first,
      );
      expect(paragraph.text.style?.fontFamilyFallback, [CarthaFonts.inter]);
      // The user's English quest keeps its own direction (its closing «»
      // stays at its end); an Arabic quest reads right to left.
      expect(paragraph.textDirection, TextDirection.ltr);
      expect(
        tester
            .renderObject<RenderParagraph>(find.text('المشي 20 دقيقة').first)
            .textDirection,
        TextDirection.rtl,
      );
      expect(tester.takeException(), isNull);
    });

    test(
      'the direction of the user\'s words comes from their first letter',
      () {
        expect(textDirectionOf('Read 10 pages of «Dune»'), TextDirection.ltr);
        expect(textDirectionOf('المشي 20 دقيقة'), TextDirection.rtl);
        expect(textDirectionOf('20 دقيقة of walking'), TextDirection.rtl);
        expect(textDirectionOf('«Dune», ثم النوم'), TextDirection.ltr);
        expect(textDirectionOf('שלום'), TextDirection.rtl);
        expect(textDirectionOf('Éte'), TextDirection.ltr);
        expect(textDirectionOf('123 – 45'), isNull);
        expect(textDirectionOf(''), isNull);
      },
    );

    testWidgets('Arabic dates use Western digits', (tester) async {
      await pumpArabic(
        tester,
        home: const CompassTab(initial: CompassSection.missions),
      );
      // "الثلاثاء، 3 نوفمبر", not "٣".
      expect(find.textContaining('3 نوفمبر'), findsWidgets);
      expectArabicFonts(tester);
    });

    testWidgets('the reset question shows the Arabic content', (tester) async {
      await pumpArabic(
        tester,
        home: const GuidedPromptScreen(promptId: 'morning.04'),
      );
      final prompt = arabicContent.prompts.firstWhere(
        (p) => p.id == 'morning.04',
      );
      expect(find.text(prompt.question), findsOneWidget);
      expect(find.text(prompt.title), findsWidgets);
      expectArabicFonts(tester);
      await _tap(tester, find.text('صياغة ألطف'));
      expect(find.text(prompt.softerQuestion!), findsOneWidget);
    });
  });

  group('Arabic size matrix (no overflow)', () {
    final screens =
        <String, Future<void> Function(WidgetTester, SizeCase, Brightness)>{
          'today': (tester, size, b) async {
            await pumpArabic(
              tester,
              size: size.size,
              textScale: size.textScale,
              brightness: b,
            );
          },
          for (final tab in [AppTab.reset, AppTab.journal, AppTab.you])
            tab.name: (tester, size, b) async {
              final h = await pumpArabic(
                tester,
                size: size.size,
                textScale: size.textScale,
                brightness: b,
              );
              h.shell.select(tab);
              await pumpFrames(tester);
            },
          for (final section in CompassSection.values)
            'compass ${section.name}': (tester, size, b) async {
              await pumpArabic(
                tester,
                home: CompassTab(initial: section),
                size: size.size,
                textScale: size.textScale,
                brightness: b,
              );
            },
          'onboarding': (tester, size, b) async {
            await pumpCartha(
              tester,
              data: AppData.empty.copyWith(
                settings: const AppSettings(language: AppLanguage.ar),
              ),
              size: size.size,
              textScale: size.textScale,
              brightness: b,
              content: englishContent,
              contentFor: contentFor,
            );
            await expectNoOverflow(tester);
            await _tap(tester, find.byKey(const ValueKey('onboarding-next')));
            await expectNoOverflow(tester);
            await _tap(tester, find.byKey(const ValueKey('onboarding-adult')));
            for (var page = 3; page <= 5; page++) {
              await _tap(tester, find.byKey(const ValueKey('onboarding-next')));
              await expectNoOverflow(tester);
            }
          },
          'reset question': (tester, size, b) async {
            await pumpArabic(
              tester,
              home: const GuidedPromptScreen(promptId: 'morning.05'),
              size: size.size,
              textScale: size.textScale,
              brightness: b,
            );
          },
          'lesson': (tester, size, b) async {
            await pumpArabic(
              tester,
              home: const LessonScreen(lessonId: 'lesson.07'),
              size: size.size,
              textScale: size.textScale,
              brightness: b,
            );
          },
          'path day': (tester, size, b) async {
            await pumpArabic(
              tester,
              home: const PathDayScreen(day: 3),
              size: size.size,
              textScale: size.textScale,
              brightness: b,
            );
          },
          for (final page in [
            CampaignPage.tryIt,
            CampaignPage.route,
            CampaignPage.collection,
          ])
            'campaign ${page.name}': (tester, size, b) async {
              await pumpArabic(
                tester,
                home: campaignPageScreen(page),
                size: size.size,
                textScale: size.textScale,
                brightness: b,
              );
            },
        };

    for (final size in kSizeMatrix) {
      for (final b in Brightness.values) {
        for (final MapEntry(key: name, value: open) in screens.entries) {
          testWidgets('$name fits $size (${b.name})', (tester) async {
            await open(tester, size, b);
            await expectNoOverflow(tester);
            expect(
              Directionality.of(tester.element(find.byType(Scaffold).first)),
              TextDirection.rtl,
            );
            expectArabicFonts(tester);
          });
        }
      }
    }
  });
}
