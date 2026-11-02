// End-to-end journeys for the evolve plan's Step 3 (docs/plans/evolve.md ›
// "Expand carefully") through the real app (CarthaApp → BootScreen →
// RootShell) with the real content in every language, the fake voice
// services and the phone's languages under the test's control:
//
// * a French phone: the five-page welcome, Today and the Reset in French;
// * an English user switches to Français in You › Appearance: Today, the
//   Reset and a lesson in French; Listen to the lesson (fake voice);
//   Dictate an answer (fake recognizer) → review and edit → Insert → the
//   saved answer is exactly the reviewed text; then العربية: Today, the
//   Reset, the Compass and the Playground right to left in the Arabic font
//   with no overflow at 320 dp and 200 % text; back to Same as phone; the
//   user's own words never change across the switches;
// * dictation unavailable: one honest line, then Record or type instead.
import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/content/fr.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/l10n/app_localizations.dart';
import 'package:cartharise/services/dictation.dart';
import 'package:cartharise/ui/awakening/lesson_card.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/campaign/campaign_view.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/journal/journal_entry_screen.dart';
import 'package:cartharise/ui/media/recorder_sheet.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/reset/reset_tab.dart';
import 'package:cartharise/ui/root_shell.dart';
import 'package:cartharise/ui/theme/cartha_fonts.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/voice/dictation_sheet.dart';
import 'package:cartharise/ui/widgets/route_scenes.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:cartharise/ui/you/appearance_screen.dart';
import 'package:cartharise/ui/you/you_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// A phone tall enough that lazily built rows exist (the journeys still
/// scroll to what they tap).
const _phone = Size(390, 2000);

final _en = lookupAppLocalizations(const Locale('en'));
final _fr = lookupAppLocalizations(const Locale('fr'));
final _ar = lookupAppLocalizations(const Locale('ar'));

final _t = DateTime(2026, 11, 2, 18);

/// Words that must survive every language switch exactly as typed.
const _noteTitle = 'Mardi «calme»';
const _noteBody = 'Saw the sea & <kept> 🌱\n  two spaces kept  ';
const _answer01 = 'أتصفّح الهاتف ليلًا — I scroll too late.';
const _quest = 'Read 10 pages of “Dune”';
const _vision = 'Des matins calmes, honest work.';

AppData _data({AppLanguage language = AppLanguage.system, bool game = true}) =>
    onboardedData(
      name: 'Sam',
      settings: AppSettings(language: language, game: game, gameInvited: true),
    ).copyWith(
      journeys: [
        Journey(
          id: 'j1',
          startedAt: _t,
          activePromptId: 'morning.02',
          answers: {
            'morning.01': ReflectionAnswer(
              promptId: 'morning.01',
              body: _answer01,
              updatedAt: _t,
            ),
          },
        ),
      ],
      currentJourneyId: () => 'j1',
      journal: [
        JournalEntry(
          id: 'note_1',
          title: _noteTitle,
          body: _noteBody,
          createdAt: _t,
        ),
      ],
      quests: [
        Quest(
          id: 'q1',
          title: _quest,
          createdAt: _t,
          recurrence: QuestRecurrence.daily,
        ),
      ],
      compass: LifeCompass(vision: _vision, updatedAt: _t),
    );

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// [finder] inside the widget of type [T] (the shell keeps every tab built).
Finder _in<T>(Finder finder) =>
    find.descendant(of: find.byType(T), matching: finder);

/// The link inside a voice button (the button may span its line).
Finder _link(String key) =>
    find.descendant(of: _key(key), matching: find.byType(TextButton));

Future<void> _settle(WidgetTester tester, {int frames = 6}) async {
  // Storage writes are microtasks; let them land, then draw.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await pumpFrames(tester, count: frames);
}

/// Brings [finder] on screen (scrolling a lazy list to build it first),
/// then taps it like a person would.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  final page = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .first;
  if (finder.evaluate().isEmpty) {
    // Scrolled past: back to the top of the page first.
    await tester.drag(page, const Offset(0, 6000));
    await tester.pump(const Duration(milliseconds: 200));
  }
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: page);
  }
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _settle(tester);
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_nav(label));
  await _settle(tester);
}

/// You › Appearance › [language], from the shell (the You tab is labelled
/// [youLabel] in the language shown now). Stays on Appearance.
Future<void> _pickLanguage(
  WidgetTester tester,
  String youLabel,
  AppLanguage language,
) async {
  await _openTab(tester, youLabel);
  expect(find.byType(YouTab), findsOneWidget);
  await _tap(tester, _key('you-appearance'));
  expect(find.byType(AppearanceScreen), findsOneWidget);
  await _tap(tester, _key('language-${language.name}'));
}

TextDirection _direction(WidgetTester tester, Type type) =>
    Directionality.of(tester.element(find.byType(type).first));

final _arabicLetter = RegExp(r'[؀-ۿ]');

/// Every Arabic paragraph on screen in the bundled Arabic font (Latin falls
/// back to Inter), Cinzel nowhere.
void _expectArabicFont(WidgetTester tester) {
  var arabic = 0;
  for (final paragraph in tester.renderObjectList<RenderParagraph>(
    find.byType(RichText),
  )) {
    final root = paragraph.text;
    final plain = root.toPlainText();
    root.visitChildren((span) {
      expect(span.style?.fontFamily, isNot(CarthaFonts.cinzel), reason: plain);
      return true;
    });
    if (!_arabicLetter.hasMatch(plain)) continue;
    arabic++;
    expect(root.style?.fontFamily, CarthaFonts.arabicFamily, reason: plain);
    expect(root.style?.fontFamilyFallback, contains(CarthaFonts.inter));
  }
  expect(arabic, greaterThan(0), reason: 'no Arabic text shown');
}

void main() {
  testWidgets('a French phone: the welcome, Today and the Reset in French', (
    tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const [
      Locale('fr', 'FR'),
      Locale('en', 'US'),
    ];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    final h = await pumpCartha(
      tester,
      content: englishContent,
      contentFor: contentFor,
      size: _phone,
    );
    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(h.state.language, AppLanguage.fr);

    // 1 · brand + promise → 2 · credit, limits, 18+ (in French).
    await _tap(tester, _key('onboarding-next'));
    expect(find.text(_fr.onboardingLimitsTitle), findsOneWidget);
    expect(find.text('Before you start'), findsNothing);
    await _tap(tester, _key('onboarding-adult'));
    await _tap(tester, _key('onboarding-next'));
    // 3 · pace → 4 · name → 5 · privacy + start.
    await _tap(tester, _key('onboarding-next'));
    await tester.enterText(_key('onboarding-name'), 'Inès');
    await _tap(tester, _key('onboarding-next'));
    await _tap(tester, _key('onboarding-finish'));
    await _settle(tester, frames: 8);
    expect(find.byType(RootShell), findsOneWidget);
    // Still "Same as phone": the phone says French.
    expect(h.state.settings.language, AppLanguage.system);
    expect(h.state.data.profile!.displayName, 'Inès');

    // Today in French.
    expect(_nav(_fr.tabToday), findsOneWidget);
    expect(_in<TodayTab>(find.text(_fr.todayWriteHint)), findsOneWidget);
    expect(_direction(tester, TodayTab), TextDirection.ltr);

    // The Reset in French, down to the question's own words.
    await _openTab(tester, _fr.tabReset);
    await _tap(tester, _in<ResetTab>(find.text(_fr.resetBegin)));
    final id = tester
        .widget<GuidedPromptScreen>(find.byType(GuidedPromptScreen))
        .promptId;
    expect(find.text(frenchContent.prompt(id)!.question), findsOneWidget);
    expect(find.text(englishContent.prompt(id)!.question), findsNothing);
  });

  testWidgets('English → Français: Today, the Reset and a lesson in French; '
      'Listen to the lesson; Dictate an answer, review, Insert — exactly the '
      'reviewed words → العربية: right to left at 320 dp / 200 % in the '
      'Arabic font → Same as phone; the user\'s words never change', (
    tester,
  ) async {
    final h = await pumpCartha(
      tester,
      data: _data(),
      content: englishContent,
      contentFor: contentFor,
      size: _phone,
    );
    expect(_nav(_en.tabToday), findsOneWidget);

    // ── Français ─────────────────────────────────────────────────────────
    await _pickLanguage(tester, _en.tabYou, AppLanguage.fr);
    // The page stays open and is French at once; the choice is saved.
    expect(find.byType(AppearanceScreen), findsOneWidget);
    expect(find.text(_fr.youAppearanceTitle), findsOneWidget);
    expect(h.state.settings.language, AppLanguage.fr);
    expect(h.store.saved!.settings.language, AppLanguage.fr);
    await tester.tap(find.byTooltip(_fr.back));
    await _settle(tester);

    await _openTab(tester, _fr.tabToday);
    expect(_in<TodayTab>(find.text(_fr.todayWriteHint)), findsOneWidget);
    // The user's quest title stays as typed (English in a French app).
    expect(_in<TodayTab>(find.text(_quest)), findsWidgets);

    await _openTab(tester, _fr.tabReset);
    expect(_in<ResetTab>(find.text(_fr.resetContinue)), findsOneWidget);

    // A lesson, in French, from the Reset's lesson strip.
    final lesson = frenchContent.lesson('lesson.01')!;
    await _tap(
      tester,
      _in<ResetTab>(
        find.byWidgetPredicate(
          (w) => w is LessonCard && w.lesson.id == 'lesson.01',
        ),
      ),
    );
    expect(find.byType(LessonScreen), findsOneWidget);
    expect(find.text(lesson.title), findsOneWidget);
    // Listen: nothing is read until the tap; then the lesson, in French.
    expect(h.readAloud.spoken, isEmpty);
    await _tap(tester, _link('lesson-listen'));
    expect(h.readAloud.spoken.single.languageTag, 'fr');
    expect(
      h.readAloud.spoken.single.text,
      startsWith('${lesson.title}\n\n${lesson.summary}'),
    );
    expect(find.text(_fr.listenStop), findsOneWidget);
    // Leaving the lesson stops the voice.
    await tester.tap(find.byTooltip(_fr.back));
    await _settle(tester);
    expect(find.byType(LessonScreen), findsNothing);
    expect(h.readAloud.isSpeaking, isFalse);

    // The next question, in French.
    await _tap(tester, _in<ResetTab>(find.text(_fr.resetContinue)));
    final prompt = frenchContent.prompt('morning.02')!;
    expect(find.byType(GuidedPromptScreen), findsOneWidget);
    expect(find.text(prompt.question), findsOneWidget);

    // Dictate: speak → Stop → the words wait for review → edit → Insert.
    await _tap(tester, _link('reset-answer-dictate'));
    expect(find.byType(DictationSheet), findsOneWidget);
    expect(h.dictation.started, ['fr']);
    expect(find.text(_fr.voiceListening), findsOneWidget);
    expect(find.text(_fr.voiceOnPhone), findsOneWidget);
    h.dictation.partial('je me presse');
    await pumpFrames(tester, count: 2);
    h.dictation.finalText = 'je me presse le matin';
    await _tap(tester, _key('dictation-stop'));
    final review = _key('dictation-review');
    expect(
      tester.widget<TextField>(review).controller!.text,
      'je me presse le matin',
    );
    // Nothing reaches the answer before Insert.
    expect(h.state.answer('morning.02'), isNull);
    const reviewed = 'Je me presse le matin, « sans » raison… 🌅';
    await tester.enterText(review, reviewed);
    await tester.pump();
    await _tap(tester, _key('dictation-insert'));
    expect(find.byType(DictationSheet), findsNothing);
    await tester.pump(kAnswerAutosaveDelay + const Duration(milliseconds: 100));
    await _settle(tester);
    expect(
      tester
          .widget<TextField>(
            _in<GuidedPromptScreen>(find.byType(TextField)).first,
          )
          .controller!
          .text,
      reviewed,
    );
    expect(h.state.answer('morning.02')!.body, reviewed);
    expect(
      h.store.saved!.journeys.single.answers['morning.02']!.body,
      reviewed,
    );

    // Listen to my answer: the words exactly, only on that tap.
    await _tap(tester, _link('reset-answer-listen'));
    expect(h.readAloud.spoken, hasLength(2));
    expect(h.readAloud.spoken.last.text, reviewed);
    expect(h.readAloud.spoken.last.languageTag, 'fr');
    await tester.tap(find.byTooltip(_fr.resetPauseTooltip));
    await _settle(tester);
    expect(find.byType(GuidedPromptScreen), findsNothing);
    expect(h.readAloud.isSpeaking, isFalse);

    // ── العربية ──────────────────────────────────────────────────────────
    await _pickLanguage(tester, _fr.tabYou, AppLanguage.ar);
    expect(find.text(_ar.youAppearanceTitle), findsOneWidget);
    expect(_direction(tester, AppearanceScreen), TextDirection.rtl);
    expect(h.state.settings.language, AppLanguage.ar);
    await tester.tap(find.byTooltip(_ar.back));
    await _settle(tester);

    // The smallest phone at 200 % text.
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    await _settle(tester);

    await _openTab(tester, _ar.tabToday);
    expect(_direction(tester, TodayTab), TextDirection.rtl);
    _expectArabicFont(tester);
    await expectNoOverflow(tester);

    await _openTab(tester, _ar.tabReset);
    expect(_direction(tester, ResetTab), TextDirection.rtl);
    expect(_nav(_ar.tabReset), findsOneWidget);
    _expectArabicFont(tester);
    await expectNoOverflow(tester);

    await _openTab(tester, _ar.tabCompass);
    expect(find.byType(CompassTab), findsOneWidget);
    expect(_direction(tester, CompassTab), TextDirection.rtl);
    _expectArabicFont(tester);
    await expectNoOverflow(tester);

    // The Playground (the Campaign is on): the painted route stop, right
    // to left.
    await _tap(
      tester,
      find.descendant(
        of: find.byType(PillTabs<CompassSection>),
        matching: find.text(_ar.campaignSection),
      ),
    );
    expect(find.byType(CampaignView), findsOneWidget);
    expect(find.byType(RouteSceneWindow), findsOneWidget);
    expect(_direction(tester, CampaignView), TextDirection.rtl);
    _expectArabicFont(tester);
    await expectNoOverflow(tester);

    // ── Same as phone (English here) ─────────────────────────────────────
    tester.view.physicalSize = _phone;
    tester.platformDispatcher.textScaleFactorTestValue = 1.0;
    await _settle(tester);
    await _pickLanguage(tester, _ar.tabYou, AppLanguage.system);
    expect(h.state.settings.language, AppLanguage.system);
    expect(h.state.language, AppLanguage.en);
    expect(find.text(_en.youAppearanceTitle), findsOneWidget);
    expect(_direction(tester, AppearanceScreen), TextDirection.ltr);
    await tester.tap(find.byTooltip(_en.back));
    await _settle(tester);
    expect(_nav(_en.tabToday), findsOneWidget);

    // The user's own words, exactly as typed, through three languages —
    // on screen, in memory and in the saved file.
    for (final data in [h.state.data, h.store.saved!]) {
      final note = data.journal.single;
      expect(note.title, _noteTitle);
      expect(note.body, _noteBody);
      expect(data.quests.single.title, _quest);
      expect(data.compass.vision, _vision);
      final answers = data.journeys.single.answers;
      expect(answers['morning.01']!.body, _answer01);
      expect(answers['morning.02']!.body, reviewed);
      expect(data.profile!.displayName, 'Sam');
    }
    await _openTab(tester, _en.tabJournal);
    expect(find.text(_noteTitle), findsOneWidget);
    // Nothing personal was ever read aloud without its own tap.
    expect(
      [for (final s in h.readAloud.spoken) s.text],
      [startsWith(lesson.title), reviewed],
    );
  });

  testWidgets('dictation unavailable: one honest line, then Record or type '
      'instead; the words already there are untouched', (tester) async {
    final speech = FakeDictation(
      availabilityDefault: DictationAvailability.unsupported,
    );
    final h = await pumpCartha(
      tester,
      data: _data(language: AppLanguage.fr),
      content: englishContent,
      contentFor: contentFor,
      size: _phone,
      dictation: speech,
    );

    // A note (it can hold voice notes): Record instead or Type instead.
    await _openTab(tester, _fr.tabJournal);
    await _tap(tester, _key('note-note_1'));
    expect(find.byType(JournalEntryScreen), findsOneWidget);
    await _tap(tester, _link('journal-entry-dictate'));
    expect(find.text(_fr.voiceUnsupported), findsOneWidget);
    expect(speech.started, isEmpty, reason: 'never started');
    expect(
      find.descendant(
        of: _key('dictation-record-instead'),
        matching: find.text(_fr.voiceRecordInstead),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _key('dictation-type-instead'),
        matching: find.text(_fr.voiceTypeInstead),
      ),
      findsOneWidget,
    );
    // Type instead: the note, ready for the keyboard, unchanged.
    await _tap(tester, _key('dictation-type-instead'));
    expect(find.byType(DictationSheet), findsNothing);
    final body = tester.widget<TextField>(_key('journal-entry-body'));
    expect(body.focusNode!.hasFocus, isTrue);
    expect(body.controller!.text, _noteBody);

    // Record instead: a voice note on this note; its words stay.
    await _tap(tester, _link('journal-entry-dictate'));
    await _tap(tester, _key('dictation-record-instead'));
    expect(find.byType(RecorderSheet), findsOneWidget);
    await _tap(tester, _key('recorder-stop'));
    await _settle(tester);
    final note = h.state.data.journal.single;
    expect(note.attachments.single.kind, AttachmentKind.audio);
    expect(note.body, _noteBody);
    expect(note.title, _noteTitle);
    await tester.tap(find.byTooltip(_fr.back));
    await _settle(tester);

    // A reset answer holds no recordings: Type instead only. An older
    // Android says so too.
    speech.availabilityDefault = DictationAvailability.tooOld;
    await _openTab(tester, _fr.tabReset);
    await _tap(tester, _in<ResetTab>(find.text(_fr.resetContinue)));
    await _tap(tester, _link('reset-answer-dictate'));
    expect(find.text(_fr.voiceTooOld), findsOneWidget);
    expect(_key('dictation-record-instead'), findsNothing);
    expect(_key('dictation-type-instead'), findsOneWidget);
    await _tap(tester, _key('dictation-type-instead'));
    expect(h.state.answer('morning.02'), isNull);
    expect(h.state.answer('morning.01')!.body, _answer01);
  });
}
