import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/ui/awakening/awakening_screen.dart';
import 'package:cartharise/ui/awakening/lesson_screen.dart';
import 'package:cartharise/ui/reset/guided_prompt_screen.dart';
import 'package:cartharise/ui/you/inspiration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// Tall enough that every row is built (ListViews are lazy).
const _tall = Size(390, 4000);

AppData _data({Set<String> read = const {}}) =>
    onboardedData().copyWith(lessonsRead: read);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await pumpFrames(tester, count: 8);
}

void main() {
  group('Awakening list (F-005)', () {
    testWidgets('seven lessons with read state in words', (tester) async {
      await pumpCartha(
        tester,
        data: _data(read: {'lesson.02'}),
        home: const AwakeningScreen(),
        size: _tall,
      );
      expect(find.text('The Awakening'), findsOneWidget);
      for (var i = 1; i <= 7; i++) {
        expect(find.text('Lesson $i title'), findsOneWidget);
        expect(find.text('Summary of lesson $i.'), findsOneWidget);
        expect(find.text('Lesson $i'), findsOneWidget);
      }
      expect(find.text('1 of 7 read'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Not read yet'), findsNWidgets(6));
    });

    testWidgets('opening a lesson marks it read', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(),
        home: const AwakeningScreen(),
        size: _tall,
      );
      await _tap(tester, find.text('Lesson 3 title'));
      expect(find.byType(LessonScreen), findsOneWidget);
      expect(h.state.data.lessonsRead, {'lesson.03'});
      expect(h.store.saved!.lessonsRead, {'lesson.03'});
      await tester.binding.handlePopRoute();
      await pumpFrames(tester, count: 8);
      expect(find.text('1 of 7 read'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('credits the source and links to Inspiration', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        home: const AwakeningScreen(),
        size: _tall,
      );
      expect(
        find.textContaining(
          '“How to fix your entire life in 1 day” by Dan Koe',
        ),
        findsOneWidget,
      );
      await _tap(tester, find.text('About the source'));
      expect(find.byType(InspirationScreen), findsOneWidget);
    });
  });

  group('Lesson (F-005–F-007)', () {
    testWidgets('title in Cinzel, explanation, example and nuance', (
      tester,
    ) async {
      await pumpCartha(
        tester,
        data: _data(),
        home: const LessonScreen(lessonId: 'lesson.01'),
        size: _tall,
      );
      expect(find.text('LESSON 1 OF 7'), findsOneWidget);
      final title = tester.widget<Text>(find.text('Lesson 1 title'));
      expect(title.style?.fontFamily, 'Cinzel');
      expect(find.text('Summary of lesson 1.'), findsOneWidget);
      // Paragraphs are separate blocks, in Inter.
      expect(find.text('Explanation of lesson 1.'), findsOneWidget);
      expect(find.text('A second paragraph.'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('A second paragraph.')).style?.fontFamily,
        'Inter',
      );
      expect(find.text('Example'), findsOneWidget);
      expect(find.text('Example for lesson 1.'), findsOneWidget);
      expect(find.text('A lens, not a verdict'), findsOneWidget);
      expect(find.text('Nuance for lesson 1.'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('knowledge check: kind feedback, explanation, nothing kept', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _data(),
        home: const LessonScreen(lessonId: 'lesson.01'),
        size: _tall,
      );
      final writes = h.store.writes;
      final saved = h.store.raw;
      expect(find.text('Check question 1?'), findsOneWidget);
      expect(find.textContaining('Nothing is scored or saved'), findsOneWidget);
      // lesson.01's best fit is option B (index 1) in the fake content.
      await _tap(tester, find.text('Option A'));
      expect(find.text("Not quite, and that's fine."), findsOneWidget);
      expect(find.text('Why option B fits.'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
      await _tap(tester, find.text('Option B'));
      expect(find.text("That's it."), findsOneWidget);
      expect(find.text("Not quite, and that's fine."), findsNothing);
      expect(find.text('Why option B fits.'), findsOneWidget);
      // No score or answer was stored.
      expect(h.store.writes, writes);
      expect(h.store.raw, saved);
    });

    testWidgets('selected option is announced as selected', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpCartha(
        tester,
        data: _data(),
        home: const LessonScreen(lessonId: 'lesson.02'),
        size: _tall,
      );
      await _tap(tester, find.text('Option C'));
      expect(
        tester.getSemantics(find.text('Option C')),
        isSemantics(
          isSelected: true,
          isButton: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Option A')),
        isSemantics(
          isSelected: false,
          isButton: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('Try it opens the related reset question', (tester) async {
      await pumpCartha(
        tester,
        data: _data(),
        home: const LessonScreen(lessonId: 'lesson.04'),
        size: _tall,
      );
      await _tap(tester, find.text('Try it: Morning 4 title'));
      expect(find.byType(GuidedPromptScreen), findsOneWidget);
      expect(find.text('Question morning 4?'), findsOneWidget);
    });

    testWidgets('next and previous lessons; the last one leads back', (
      tester,
    ) async {
      final h = await pumpCartha(
        tester,
        data: _data(),
        home: const AwakeningScreen(),
        size: _tall,
      );
      await _tap(tester, find.text('Lesson 1 title'));
      expect(find.text('Previous lesson'), findsNothing);
      await _tap(tester, find.text('Next lesson'));
      expect(find.text('LESSON 2 OF 7'), findsOneWidget);
      expect(h.state.data.lessonsRead, {'lesson.01', 'lesson.02'});
      await _tap(tester, find.text('Previous lesson'));
      expect(find.text('LESSON 1 OF 7'), findsOneWidget);
      // Replacing keeps the stack shallow: back returns to the list.
      await tester.binding.handlePopRoute();
      await pumpFrames(tester, count: 8);
      expect(find.byType(AwakeningScreen), findsOneWidget);
      expect(find.byType(LessonScreen), findsNothing);

      await _tap(tester, find.text('Lesson 7 title'));
      expect(find.text('Next lesson'), findsNothing);
      await _tap(tester, find.text('Back to the lessons'));
      expect(find.byType(LessonScreen), findsNothing);
      expect(find.byType(AwakeningScreen), findsOneWidget);
    });

    testWidgets('an unknown lesson id shows a calm message', (tester) async {
      final h = await pumpCartha(
        tester,
        data: _data(),
        home: const LessonScreen(lessonId: 'lesson.99'),
      );
      expect(find.text("This lesson isn't available."), findsOneWidget);
      expect(h.state.data.lessonsRead, isEmpty);
    });

    testWidgets('real English content: every lesson renders', (tester) async {
      for (final lesson in englishContent.lessons) {
        await pumpCartha(
          tester,
          data: _data(),
          content: englishContent,
          home: LessonScreen(lessonId: lesson.id),
          size: _tall,
        );
        expect(find.text(lesson.title), findsOneWidget);
        expect(find.text(lesson.nuance), findsOneWidget);
        for (final id in lesson.relatedPromptIds) {
          final prompt = englishContent.prompt(id)!;
          expect(find.text('Try it: ${prompt.title}'), findsOneWidget);
        }
      }
    });
  });

  group('fits every size (dark + light)', () {
    for (final size in kSizeMatrix) {
      for (final b in Brightness.values) {
        final tag = '$size ${b.name}';

        testWidgets('awakening list $tag', (tester) async {
          await pumpCartha(
            tester,
            data: _data(read: {'lesson.01', 'lesson.05'}),
            content: englishContent,
            home: const AwakeningScreen(),
            size: size.size,
            textScale: size.textScale,
            brightness: b,
          );
          await expectNoOverflow(tester);
        });

        testWidgets('lesson with feedback $tag', (tester) async {
          await pumpCartha(
            tester,
            data: _data(),
            content: englishContent,
            home: const LessonScreen(lessonId: 'lesson.03'),
            size: size.size,
            textScale: size.textScale,
            brightness: b,
          );
          final check = englishContent.lesson('lesson.03')!.check!;
          final option = find.text(check.options.first);
          await tester.scrollUntilVisible(
            option,
            300,
            scrollable: find
                .byWidgetPredicate(
                  (w) =>
                      w is Scrollable &&
                      axisDirectionToAxis(w.axisDirection) == Axis.vertical,
                )
                .first,
          );
          await _tap(tester, option);
          expect(find.text(check.explanation), findsOneWidget);
          await expectNoOverflow(tester);
        });
      }
    }
  });
}
