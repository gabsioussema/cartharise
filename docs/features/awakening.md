# Awakening: the seven lessons

Optional, plain-language lessons on the article's central ideas (F-005), framed
as lenses rather than facts or diagnoses (F-006). Reachable from the Reset
tab's "Learn the ideas first (optional)" strip and its "See all lessons" link
(`AppNav.openAwakening`), and from anywhere via `AppNav.openLesson`.

## User flow

1. **Awakening list** (`AwakeningScreen`): the Notice glyph (mirror) by "The
   Awakening" + "Seven ideas behind the reset. Optional, any order.", "n of 7
   read", then one card per lesson: its **illustration** (96 dp), Lesson n,
   title, summary, read state as a chip with words ("Read" ✓ / "Not read
   yet"). Footer: "In Cartharise's words, from “{title}” by {author}.
   Independent app." + "About the source" → `AppNav.openInspiration`.
2. **Lesson** (`LessonScreen(lessonId:)`):
   * The lesson's **illustration** across the top (148 dp on phones, 200 dp
     from 600 dp wide).
   * The mirror + `LESSON n OF 7` eyebrow, **Cinzel** title
     (`headlineSmall`), summary, read chip.
   * Explanation split into paragraphs on blank lines (Inter `bodyLarge`).
   * **Example** card and **A lens, not a verdict** card (the nuance).
   * **Check your understanding**: the question, "Pick the answer that fits
     best. Nothing is scored or saved.", three radio-like options. Picking
     shows "That's it." or "Not quite, and that's fine." plus the explanation;
     the user may pick again. Selection is shown by icon, outline, fill and
     `selected` semantics (in a mutually exclusive group) — not colour alone.
   * **Try it**: one link per `relatedPromptIds` entry ("Try it: {prompt
     title}") → `AppNav.openPrompt`.
   * **Next lesson** (primary) / **Previous lesson**; on the last lesson
     "Back to the lessons". Moving between lessons replaces the route, so back
     always returns to where the user came from.
   * The same source note as the list.

The Reset tab's strip (`LessonStrip`) has the mirror by "Learn the ideas
first (optional)" and compact cards with a 72 dp illustration.

## Illustrations

One memorable scene per lesson (`LessonIllustration`, `LessonScene.of`),
painted in the brand scenes' hero colours, calm and static, the same in light
and dark. Decorative: the title next to it says what it is.

| Lesson | Scene | Why |
|---|---|---|
| 1 Who you are comes first | a tree at sunrise, its roots (drawn in the earth below) wider than its crown | actions grow from who you are |
| 2 Your actions have reasons | an iceberg under the moon, most of it below the waterline | reasons are often hidden |
| 3 Why change can feel risky | a walled hilltop town at dusk, the gate open, light spilling down the path | we guard our sense of self; change is a way out |
| 4 Ways of seeing can widen | arches opening wider and wider around a sea horizon | ways of seeing grow broader |
| 5 Aim, check, adjust | a sailboat tacking toward a lighthouse, its zigzag wake behind | steer, check, correct course |
| 6 A day off autopilot | one day's arc: morning sun, short pauses, midday, evening moon | the reset's morning · daytime · evening |
| 7 Your direction as a game | a marked route with waypoints up to a flag on the summit | goal, missions and quests as a game |

The subject stays centred at any width (narrow strip card to tablet column);
see the Visual system in [foundation.md](foundation.md).

## Listen (step 3)

**Listen** under a lesson's read tag reads the lesson aloud (title, summary,
explanation, example, the "lens, not a verdict" note) with the phone's own voice, in
the app's language (English for an item not translated yet). **Stop reading** ends it;
leaving the lesson stops it. Hidden where the phone has no voice for the language.
Details and tests: [`voice.md`](voice.md#listen).

## Behaviour rules

* Opening a lesson calls `markLessonRead` (post-frame); unknown ids show
  "This lesson isn't available." and mark nothing.
* The knowledge check is local widget state only: no score, no stored pick
  (tested: no extra storage writes).
* Lesson order follows `Lesson.ordinal`.
* All copy is the content library's (`lib/content/en.dart`) or ARB strings;
  nothing inferred about the user.

## Code map

| File | What |
|---|---|
| `lib/ui/awakening/awakening_screen.dart` | `AwakeningScreen`, `AwakeningSourceNote` |
| `lib/ui/awakening/lesson_screen.dart` | `LessonScreen`, `LessonReadTagFor` |
| `lib/ui/awakening/knowledge_check.dart` | `KnowledgeCheckCard` |
| `lib/ui/awakening/lesson_card.dart` | `LessonCard` (illustration on top; `compact` for the strip), `LessonReadTag`, `LessonStrip` (used by the Reset tab), `lessonsInOrder` |
| `lib/ui/widgets/glyphs.dart`, `lib/ui/widgets/art/lesson_art.dart` | `LessonIllustration`, `LessonScene`, `LessonArtPainter` (visual system) |
| `l10n_src/awakening_en.arb` | all `awakening…` strings |

Layout helpers (`ReadingColumn`, `Eyebrow`, `SectionTitle`) come from
`lib/ui/reset/reset_flow.dart` (same owner).

## Tests

`test/ui/awakening_test.dart`: seven lessons with read state in words;
opening marks read (and persists); source credit + Inspiration link; Cinzel
title / Inter paragraphs, example, nuance; knowledge check feedback both ways
and nothing stored; selected option semantics; Try it → guided prompt;
next / previous / last lesson navigation and a shallow back stack; unknown
id; every real English lesson renders with its Try-it links; size matrix ×
dark/light for the list and a lesson with feedback shown. Screenshots
`25_awakening_*`, `26_lesson_*` come from
`test/screenshots/reset_screenshots_test.dart`.

`test/ui/visual_system_test.dart`: one distinct scene per lesson (pixels
compared), at narrow, phone and tablet widths in dark and light; every card
carries its lesson's illustration; the strip's cards are 72 dp; a lesson opens
on its scene with the mirror by "Lesson n of 7"; each glyph sits next to a
word; the strip in the size matrix. Screenshots `visual_03`–`visual_05`
(illustrations), `visual_07_awakening_*`, `visual_08_lesson_*` come from
`test/screenshots/visual_system_screenshots_test.dart`.

## Requirements satisfied

F-005 (seven concept cards with summary, example, nuance and exercise links),
F-006 (frameworks, not facts; no stages or hidden motives assigned), F-007
(the guided prompt's help and labelled example — see [reset.md](reset.md)),
F-044/F-045 (semantics, state in words, 320 dp at 200 % text), source credit
visible and linked (§09 content integrity).
