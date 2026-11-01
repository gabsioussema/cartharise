# Awakening: the seven lessons

Optional, plain-language lessons on the article's central ideas (F-005), framed
as lenses rather than facts or diagnoses (F-006). Reachable from the Reset
tab's "Learn the ideas first (optional)" strip and its "See all lessons" link
(`AppNav.openAwakening`), and from anywhere via `AppNav.openLesson`.

## User flow

1. **Awakening list** (`AwakeningScreen`): "The Awakening" + "Seven ideas
   behind the reset, in plain words. Optional, and in any order.", "n of 7
   read", then one card per lesson (Lesson n, title, summary, read state as a
   chip with words: "Read" ✓ / "Not read yet"). Footer: "Paraphrased in
   Cartharise's own words from “{title}” by {author}. Cartharise is
   independent." + "About the source" → `AppNav.openInspiration`.
2. **Lesson** (`LessonScreen(lessonId:)`):
   * `LESSON n OF 7` eyebrow, **Cinzel** title (`headlineSmall`), summary,
     read chip.
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
| `lib/ui/awakening/lesson_card.dart` | `LessonCard`, `LessonReadTag`, `LessonStrip` (used by the Reset tab), `lessonsInOrder` |
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

## Requirements satisfied

F-005 (seven concept cards with summary, example, nuance and exercise links),
F-006 (frameworks, not facts; no stages or hidden motives assigned), F-007
(the guided prompt's help and labelled example — see [reset.md](reset.md)),
F-044/F-045 (semantics, state in words, 320 dp at 200 % text), source credit
visible and linked (§09 content integrity).
