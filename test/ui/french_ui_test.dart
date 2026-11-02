// French in the app (step 3, agent "french"): the language picker in
// You › Appearance switches the whole app live and persists; "Same as phone"
// follows the phone; every main screen fits in French from 320 dp at 200 %
// text to a tablet, dark and light; the picker works right to left.
import 'dart:ui' show Tristate;

import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/local_date.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/chapters_screen.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/campaign/make_it_yours_screen.dart';
import 'package:cartharise/ui/campaign/notice_screen.dart';
import 'package:cartharise/ui/campaign/route_screen.dart';
import 'package:cartharise/ui/campaign/try_screen.dart';
import 'package:cartharise/ui/journal/past_reset_screen.dart';
import 'package:cartharise/ui/journal/review_screen.dart';
import 'package:cartharise/ui/missions/path_day_screen.dart';
import 'package:cartharise/ui/missions/project_history_screen.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/persona/persona_builder.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/reset/reset_complete_screen.dart';
import 'package:cartharise/ui/you/appearance_screen.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:cartharise/ui/you/inspiration_screen.dart';
import 'package:cartharise/ui/you/reminders_screen.dart';
import 'package:cartharise/ui/you/support_screen.dart';
import 'package:cartharise/ui/you/you_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

final _at = DateTime(2026, 11, 2, 8);

ReflectionAnswer _answer(String id, String body, {bool skipped = false}) =>
    ReflectionAnswer(
      promptId: id,
      body: skipped ? '' : body,
      skipped: skipped,
      updatedAt: _at,
    );

/// A French-speaking user in the middle of things (their own words, typed
/// in French, stay exactly as written).
AppData frenchData({AppLanguage language = AppLanguage.fr}) =>
    onboardedData(
      name: 'Camille',
      settings: AppSettings(language: language),
    ).copyWith(
      journeys: [
        Journey(
          id: 'journey_old',
          startedAt: DateTime(2026, 9, 1, 7),
          completedAt: DateTime(2026, 9, 2, 21),
          answers: {
            'morning.01': _answer('morning.01', 'Je scrolle trop le soir.'),
            'morning.02': _answer('morning.02', '', skipped: true),
          },
        ),
        Journey(
          id: 'journey_now',
          startedAt: _at,
          activePromptId: 'morning.02',
          answers: {
            'morning.01': _answer('morning.01', 'Des soirées sans fin.'),
            'evening.04': _answer('evening.04', 'Une vie calme et créative.'),
          },
        ),
      ],
      currentJourneyId: () => 'journey_now',
      quests: [
        Quest(
          id: 'q1',
          title: 'Marcher 20 minutes',
          createdAt: _at,
          recurrence: QuestRecurrence.daily,
          completedOn: {dateKey(kTestNow)},
        ),
        Quest(
          id: 'q2',
          title: 'Écrire une page',
          createdAt: _at,
          dueDate: '2026-11-03',
        ),
        Quest(id: 'q3', title: 'Ranger le bureau', createdAt: _at),
      ],
      compass: LifeCompass(
        vision: 'Des matins calmes, un travail honnête.',
        monthProject: 'Terminer le carnet de croquis',
        dailyLevers: 'Marcher\nLire',
        updatedAt: _at,
      ),
      project: () => MonthProject(
        title: 'Terminer le carnet de croquis',
        updatedAt: _at,
        status: ProjectStatus.active,
        milestones: const [
          Milestone(id: 'm1', title: 'Dix croquis', done: true),
          Milestone(id: 'm2', title: 'Choisir les meilleurs'),
        ],
      ),
      journal: [
        JournalEntry(id: 'note_1', body: 'Une première note.', createdAt: _at),
      ],
      reviews: [
        WeeklyReview(
          id: 'review_1',
          weekStart: '2026-10-26',
          wins: 'Des matins calmes',
          friction: 'Couchers tardifs',
          nextExperiment: 'Téléphone loin du lit',
          createdAt: _at,
        ),
      ],
      pathAnswers: {
        1: PathAnswer(day: 1, body: 'Beaucoup remarqué.', updatedAt: _at),
      },
      campaignLog: [
        BattleLogEntry(
          id: 'a1',
          day: '2026-11-02',
          attempt: 'Une heure de dessin',
          learning: 'Le matin, c’est plus facile.',
          createdAt: _at,
        ),
      ],
      experimentLog: [
        ExperimentEntry(
          id: 'e1',
          experimentId: 'try.terrain.01',
          day: '2026-11-01',
          note: 'Une fissure au plafond.',
          createdAt: _at,
        ),
      ],
      lessonsRead: const {'lesson.01'},
    );

/// Pumps the real app with the real content, wired per language as
/// `main.dart` does.
Future<CarthaHarness> pumpFrench(
  WidgetTester tester, {
  AppData? data,
  Widget? home,
  AppTab? tab,
  Size size = const Size(390, 844),
  double textScale = 1.0,
  Brightness brightness = Brightness.dark,
}) => pumpCartha(
  tester,
  data: data ?? frenchData(),
  home: home,
  shell: tab == null ? null : ShellController(initial: tab),
  size: size,
  textScale: textScale,
  brightness: brightness,
  content: englishContent,
  contentFor: contentFor,
);

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    // Built lazily: back to the top of the page (the picker leads it).
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000));
    await pumpFrames(tester, count: 2);
  }
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester);
}

/// Opens You › Appearance from the shell.
Future<void> _openAppearance(WidgetTester tester, String youLabel) async {
  await tester.tap(_nav(youLabel));
  await pumpFrames(tester);
  expect(find.byType(YouTab), findsOneWidget);
  final row = find.byKey(const ValueKey('you-appearance'));
  await tester.scrollUntilVisible(
    row,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await _tap(tester, row);
  expect(find.byType(AppearanceScreen), findsOneWidget);
}

Finder _option(AppLanguage language) =>
    find.byKey(ValueKey('language-${language.name}'));

bool _selected(WidgetTester tester, AppLanguage language) =>
    tester
        .getSemantics(_option(language))
        .getSemanticsData()
        .flagsCollection
        .isSelected ==
    Tristate.isTrue;

/// One screen of the French size matrix: a tab (and its section pill) or a
/// pushed screen.
typedef _Screen = ({String name, AppTab? tab, String? pill, Widget? home});

void main() {
  group('language picker', () {
    testWidgets('lists Same as phone, then each language by its own name', (
      tester,
    ) async {
      await pumpFrench(
        tester,
        data: onboardedData(),
        home: const AppearanceScreen(),
      );
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Same as phone'), findsOneWidget);
      expect(find.text('Now: English'), findsOneWidget);
      // Endonyms, whatever the language on screen.
      for (final name in ['English', 'Français', 'العربية']) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      // In order: System · English · Français · العربية.
      final tops = [
        for (final l in [AppLanguage.system, ...kAppLanguages])
          tester.getTopLeft(_option(l)).dy,
      ];
      expect(tops, [...tops]..sort());
      // Same as phone is the default.
      expect(_selected(tester, AppLanguage.system), isTrue);
      expect(_selected(tester, AppLanguage.en), isFalse);
    });

    testWidgets('choosing Français re-words the app at once and persists', (
      tester,
    ) async {
      final h = await pumpFrench(tester, data: onboardedData());
      expect(_nav('Today'), findsOneWidget);
      await _openAppearance(tester, 'You');

      await _tap(tester, _option(AppLanguage.fr));
      // The same screen, now in French: strings, content and settings.
      expect(find.byType(AppearanceScreen), findsOneWidget);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000));
      await pumpFrames(tester, count: 2);
      expect(find.text('Apparence'), findsOneWidget);
      expect(find.text('Langue'), findsOneWidget);
      expect(find.text('Comme le téléphone'), findsOneWidget);
      expect(find.text('Français'), findsOneWidget);
      expect(h.state.settings.language, AppLanguage.fr);
      expect(h.state.language, AppLanguage.fr);
      expect(h.state.content.languageCode, 'fr');
      expect(
        h.state.content.prompt('morning.01')!.title,
        'L’insatisfaction tranquille',
      );
      expect(_selected(tester, AppLanguage.fr), isTrue);
      // Saved, with nothing else touched.
      expect(h.store.raw, contains(RegExp(r'"language":\s*"fr"')));
      expect(h.store.saved!.settings.language, AppLanguage.fr);
      expect(h.store.saved!.profile!.displayName, 'Sam');

      // The back button speaks French too (pageBack looks for "Back").
      await tester.tap(find.byTooltip('Retour'));
      await pumpFrames(tester);
      expect(_nav('Aujourd’hui'), findsOneWidget);
      expect(_nav('Vous'), findsOneWidget);
      expect(find.text('Apparence'), findsOneWidget);

      // And back to English, the same way.
      await _openAppearance(tester, 'Vous');
      await _tap(tester, _option(AppLanguage.en));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000));
      await pumpFrames(tester, count: 2);
      expect(find.text('Appearance'), findsOneWidget);
      expect(h.store.saved!.settings.language, AppLanguage.en);
      expect(
        h.state.content.prompt('morning.01')!.title,
        'Quiet dissatisfaction',
      );
    });

    testWidgets('the choice survives a restart', (tester) async {
      final h = await pumpFrench(tester, data: onboardedData());
      await _openAppearance(tester, 'You');
      await _tap(tester, _option(AppLanguage.fr));
      final reopened = AppState(
        store: h.store,
        content: englishContent,
        contentFor: contentFor,
        reminders: FakeReminderScheduler(),
        clock: () => kTestNow,
        deviceLanguages: const ['en'],
      );
      await reopened.load();
      expect(reopened.language, AppLanguage.fr);
      expect(reopened.content.languageCode, 'fr');
    });

    testWidgets('Same as phone follows a French phone and says so', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [
        Locale('fr', 'BE'),
        Locale('en', 'GB'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      final h = await pumpFrench(tester, data: onboardedData());
      expect(h.state.settings.language, AppLanguage.system);
      expect(h.state.language, AppLanguage.fr);
      expect(_nav('Aujourd’hui'), findsOneWidget);
      await _openAppearance(tester, 'Vous');
      expect(find.text('Actuellement : Français'), findsOneWidget);
      // An explicit English choice wins over the phone.
      await _tap(tester, _option(AppLanguage.en));
      expect(find.text('Same as phone'), findsOneWidget);
      expect(find.text('Now: English'), findsOneWidget);
      // And back to the phone's language.
      await _tap(tester, _option(AppLanguage.system));
      expect(h.state.settings.language, AppLanguage.system);
      expect(find.text('Comme le téléphone'), findsOneWidget);
    });

    testWidgets('screen readers say each name in its own language', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpFrench(
        tester,
        data: onboardedData(),
        home: const AppearanceScreen(),
      );
      Locale? spokenIn(AppLanguage option, String name) {
        final label = tester.getSemantics(_option(option)).attributedLabel;
        for (final a in label.attributes) {
          if (a is LocaleStringAttribute &&
              label.string.substring(a.range.start, a.range.end) == name) {
            return a.locale;
          }
        }
        return null;
      }

      expect(spokenIn(AppLanguage.fr, 'Français'), const Locale('fr'));
      expect(spokenIn(AppLanguage.ar, 'العربية'), const Locale('ar'));
      expect(spokenIn(AppLanguage.en, 'English'), const Locale('en'));
      // "Same as phone. Now: English": the name it gives, in that language.
      expect(spokenIn(AppLanguage.system, 'English'), const Locale('en'));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantics.dispose();
    });

    for (final brightness in Brightness.values) {
      testWidgets('meets text contrast in French (${brightness.name})', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await pumpFrench(
          tester,
          home: const AppearanceScreen(),
          brightness: brightness,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });
    }

    for (final size in kSizeMatrix) {
      testWidgets('works right to left (Arabic) at $size', (tester) async {
        final h = await pumpFrench(
          tester,
          data: frenchData(language: AppLanguage.ar),
          home: const AppearanceScreen(),
          size: size.size,
          textScale: size.textScale,
        );
        final element = tester.element(find.byType(AppearanceScreen));
        expect(Directionality.of(element), TextDirection.rtl);
        // The radio sits at the start: on the right in Arabic.
        final row = tester.getRect(_option(AppLanguage.fr));
        final radio = tester.getRect(
          find.descendant(
            of: _option(AppLanguage.fr),
            matching: find.byType(Icon),
          ),
        );
        expect(radio.center.dx, greaterThan(row.center.dx));
        await expectNoOverflow(tester);
        await _tap(tester, _option(AppLanguage.fr));
        expect(h.state.language, AppLanguage.fr);
        expect(
          Directionality.of(tester.element(find.byType(AppearanceScreen))),
          TextDirection.ltr,
        );
      });
    }
  });

  group('French on every main screen', () {
    const List<_Screen> screens = [
      (name: 'Today', tab: AppTab.today, pill: null, home: null),
      (name: 'Reset', tab: AppTab.reset, pill: null, home: null),
      (name: 'Compass', tab: AppTab.compass, pill: null, home: null),
      (name: 'Missions', tab: AppTab.compass, pill: 'Missions', home: null),
      (name: 'Campaign', tab: AppTab.compass, pill: 'Campagne', home: null),
      (name: 'Journal', tab: AppTab.journal, pill: null, home: null),
      (name: 'Reviews', tab: AppTab.journal, pill: 'Bilans', home: null),
      (name: 'Look back', tab: AppTab.journal, pill: 'Regards', home: null),
      (name: 'You', tab: AppTab.you, pill: null, home: null),
      (
        name: 'Guided prompt',
        tab: null,
        pill: null,
        home: GuidedPromptScreen(promptId: 'morning.09'),
      ),
      (
        name: 'Reset complete',
        tab: null,
        pill: null,
        home: ResetCompleteScreen(),
      ),
      (
        name: 'Past reset',
        tab: null,
        pill: null,
        home: PastResetScreen(journeyId: 'journey_old'),
      ),
      (name: 'Awakening', tab: null, pill: null, home: AwakeningScreen()),
      (
        name: 'Lesson',
        tab: null,
        pill: null,
        home: LessonScreen(lessonId: 'lesson.07'),
      ),
      (name: 'Path day', tab: null, pill: null, home: PathDayScreen(day: 2)),
      (name: 'Month project', tab: null, pill: null, home: ProjectScreen()),
      (
        name: 'Project history',
        tab: null,
        pill: null,
        home: ProjectHistoryScreen(),
      ),
      (name: 'Weekly review', tab: null, pill: null, home: ReviewScreen()),
      (name: 'Try', tab: null, pill: null, home: TryScreen()),
      (name: 'Notice', tab: null, pill: null, home: NoticeScreen()),
      (name: 'Make it yours', tab: null, pill: null, home: MakeItYoursScreen()),
      (name: 'Collection', tab: null, pill: null, home: CollectionScreen()),
      (name: 'Route', tab: null, pill: null, home: CampaignRouteScreen()),
      (name: 'Chapters', tab: null, pill: null, home: ChaptersScreen()),
      (name: 'Battle log', tab: null, pill: null, home: BattleLogScreen()),
      (
        name: 'Persona builder',
        tab: null,
        pill: null,
        home: PersonaBuilderScreen(),
      ),
      (name: 'Inspiration', tab: null, pill: null, home: InspirationScreen()),
      (name: 'Reminders', tab: null, pill: null, home: RemindersScreen()),
      (name: 'Appearance', tab: null, pill: null, home: AppearanceScreen()),
      (name: 'Your data', tab: null, pill: null, home: DataScreen()),
      (name: 'Support', tab: null, pill: null, home: SupportScreen()),
    ];

    for (final size in kSizeMatrix) {
      for (final brightness in Brightness.values) {
        testWidgets('every screen fits $size (${brightness.name})', (
          tester,
        ) async {
          for (final screen in screens) {
            await pumpFrench(
              tester,
              tab: screen.tab,
              home: screen.home,
              size: size.size,
              textScale: size.textScale,
              brightness: brightness,
            );
            if (screen.pill != null) {
              await tester.tap(find.text(screen.pill!).first);
              await pumpFrames(tester);
            }
            expect(
              Localizations.localeOf(
                tester.element(find.byType(Scaffold).first),
              ),
              const Locale('fr'),
              reason: screen.name,
            );
            final error = tester.takeException();
            expect(error, isNull, reason: '${screen.name}: $error');
            await expectNoOverflow(tester);
            // A fresh app for the next screen.
            await tester.pumpWidget(const SizedBox());
          }
        });
      }
    }

    for (final size in kSizeMatrix) {
      testWidgets('the welcome fits in French at $size', (tester) async {
        tester.platformDispatcher.localesTestValue = const [Locale('fr')];
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);
        await pumpCartha(
          tester,
          size: size.size,
          textScale: size.textScale,
          content: englishContent,
          contentFor: contentFor,
        );
        expect(find.text('Commencer'), findsWidgets);
        await expectNoOverflow(tester);
        // Walk the five pages: each fits.
        for (var page = 0; page < 4; page++) {
          final next = find.textContaining(RegExp('^(Commencer|Suivant)\$'));
          if (next.evaluate().isEmpty) break;
          if (find.text('J’ai 18 ans ou plus').evaluate().isNotEmpty) {
            await _tap(tester, find.text('J’ai 18 ans ou plus'));
          }
          await _tap(tester, next.last);
          await expectNoOverflow(tester);
        }
      });
    }
  });
}
