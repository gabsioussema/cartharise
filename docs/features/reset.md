# Reset: hub, guided prompts, completion, past resets

The one-day reset from the article, as Cartharise asks it: 14 morning questions
(The Mirror + The Vision), 6 daytime check-ins (The Interrupt) plus 3 optional
contemplations, and 7 evening questions (The Breakthrough), one question at a
time. Nothing is locked by time or order (F-046). Lessons live in
[awakening.md](awakening.md).

## User flow

1. **Reset tab** (`ResetTab`): "The Reset" header + one-line purpose →
   pace note → "Your reset" card → lesson strip → three phase cards → past
   resets → start a new reset.
   * **Pace note** reads `profile.pace`: *one day* ("Morning questions, a few
     check-ins during the day, then the evening. Nothing locks if it takes you
     longer.") or *flexible* ("Take the parts in any order… Nothing locks and
     nothing expires."). "Change pace" switches to the You tab.
   * **Your reset**: `ProgressRing` of `coreProgress`, "n of 27 core questions
     answered", "Next: {title}" with its phase and position, primary
     **Begin** (nothing written yet) / **Continue** → `AppNav.openPrompt(nextPrompt)`.
     When every core prompt is answered or skipped: "See what you created" →
     `ResetCompleteScreen`. After completion: "Finished on {date}. You can
     still revisit and edit any answer."
   * **Learn the ideas first (optional)**: horizontal strip of the 7 lessons
     (read / not read yet) → `LessonScreen`; "See all lessons" →
     `AwakeningScreen`.
   * **Morning** card (ring "3/14" + counts in words): rows *The Mirror*
     (current reality, possible futures, identity) and *The Vision* (a good
     ordinary day, who you want to become, one action this week), each with
     its own count; tapping opens its first open prompt (or its first prompt
     when all are done).
   * **Daytime** card: six check-in rows, each with a status icon **and** word
     (Answered / Skipped / Not answered yet) and a "Check-in · {time}" chip —
     the reminder time from `AppState.reminders` (user's choice, else the
     source default), formatted with the device clock (13:30 or 1:30 PM).
     Below, **Optional contemplations** (header + "Optional" chip on each row,
     "They don't count toward your progress.").
   * **Evening** card: *The Breakthrough* (insights, direction and a plan).
   * **Past resets** (only when there are some): "Started {date}" / "Finished
     {date}" or "Not finished" / "n answers" → `PastResetScreen` (read-only),
     the same screen as Journal › Look back
     (`lib/ui/journal/past_reset_screen.dart`), so an earlier reset reads the
     same from both places.
   * **Start a new reset** (only when the current reset has answers or was
     finished): confirm dialog ("Your current answers are kept as a past reset
     you can read at any time… Your Compass, quests and journal don't change.")
     → `startNewJourney()` → snackbar.
2. **Guided prompt** (`GuidedPromptScreen(promptId:)`): see below.
3. **Last evening prompt** → **Save & finish** → `ResetCompleteScreen`
   (replaces the prompt route, so back returns to the hub).
4. **Reset complete**: emblem (static), "Reset complete", "One day can bring
   clarity; the rest is practice.", *What you created* (answers written,
   skipped, per phase "Morning: 14 of 14 answered"…), *Your vision, in your
   words* (evening.04's answer — the prompt with `mapsTo: vision` — shown
   exactly as typed, on a forest hero card), an honest line if core questions
   are still open, then **Build your Compass** → `showCompassImport(context)`
   and **Later** (back). Calls `completeJourney()` once (post-frame; never
   re-stamps an already completed reset). No celebration of a "fixed life".

## Guided prompt screen (F-011, F-012, F-007, F-046, F-047)

Top to bottom (one scrolling column; nothing has a fixed height):

* App bar: ✕ (**Pause**, tooltip "Pause and return to the Reset") and ☰
  (**Jump**, tooltip "Jump to a question").
* Eyebrow `MORNING · THE MIRROR` (phase · subflow), "Question n of N" (within
  the phase), a calm linear progress bar (semantics label = the same words).
* Chips: the group ("A future you don't want"), "Check-in · 13:30" for
  daytime prompts, "Optional" for bonus prompts, and the status when not open.
* Prompt title (bronze), context (muted), the **question in large Inter**
  (`titleLarge`, header + live region).
* **Softer wording** switch, only when the prompt has a `softerQuestion`. Once
  on, it stays on for the following prompts until switched off.
* **What does this mean?** → bottom sheet with `prompt.help` and Close.
* **Example — not a right answer**: collapsed panel; tap to expand.
* Answer field: multiline (`minLines: 5`, no max lines, **no max length**),
  plain `TextField` (anything renders as plain text), label "Your answer".
* "You skipped this one…" note when skipped; `SaveIndicator` (Saving… /
  Saved on this device / failure with Retry + Export a copy).
* **Save & continue** (primary; **Save & finish** on evening.07), **Back** and
  **Skip for now** (side by side, stacked when narrow / large text), then
  **Jump**, **Pause**, **Feeling heavy?** links.

### Behaviour rules

* **Order.** Back / Save & continue / Skip walk the core order
  morning.01…14 → daytime.01…06 → evening.01…07. Bonus prompts walk
  bonus.01…03 only; continuing from bonus.03 returns to the hub. Back is
  disabled on morning.01 (and bonus.01). Moving happens in place on one
  route (no growing back stack), with `CarthaPageMotion`.
* **Resume point.** Opening a prompt (and every in-screen move) calls
  `setActivePrompt`, so `nextPrompt` / Today resume there (F-037).
* **Autosave.** Typing marks the text dirty and (re)starts a 600 ms timer
  (`kAnswerAutosaveDelay`), then `saveAnswer(id, text)` — the text exactly as
  typed, never trimmed. Pending text is flushed: before moving to another
  prompt, on Save & continue / Skip / Pause / Jump / Support, on pop (system
  back, via `PopScope`), when the app leaves `resumed` (inactive, hidden,
  paused — `WidgetsBindingObserver`), and on `dispose` (deferred by a
  microtask because notifying listeners is not allowed while the tree is
  being torn down). Nothing is written unless the user typed.
* **Skip** flushes, then `skipPrompt` (words already written are kept, per
  `AppState`), then moves on. Skipped prompts can be reopened from the hub or
  Jump at any time; typing there clears `skipped`.
* **Jump** sheet lists the current phase's prompts: "n. Title", status icon
  **and** words ("You are here · Not answered yet", "Answered", "Skipped",
  plus the check-in time for daytime).
* **Feeling heavy?** sheet: "This can be a lot" + "Switch to softer wording"
  (only if available and not already on), "Skip this question", "Take a
  pause", "Support and safety" (`AppNav.openSupport`), and "Cartharise is not
  therapy. If you feel unsafe, contact local emergency services or a crisis
  line now."
* **Save failure** is shown by `SaveIndicator`; the words stay in the field.
* **Unknown prompt id** → calm "This question isn't available."
* **Reduced motion** (device or Settings › Motion): no page fade, the example
  expands without `AnimatedSize`, sheets open without animation.

## Voice (step 3)

* **Dictate** under the answer: speak, review, then **Insert** puts the words at the
  cursor (autosaved like typing). On-device recognition only; otherwise one honest line
  and **Type instead**.
* **Listen** beside "What does this mean?" reads the context and the question as shown
  (softer wording when chosen); **Listen to my answer**, under Dictate once the answer
  has words, reads it exactly as typed, only on that tap.
* Details and tests: [`voice.md`](voice.md).

## Edge cases

* Very long answers (5 000+ characters) with HTML-like text, emoji, RTL
  scripts, combining marks, zero-width spaces, tabs and blank lines are stored
  and shown exactly (tested at 320 dp / 200 % text).
* A prompt answered and then skipped keeps its words and still counts as
  answered (the `AppState` model: answered = non-empty body).
* Bonus prompts never change `coreProgress`.
* "Start a new reset" on an untouched reset is not offered (`AppState` would
  replace it anyway).
* Past resets are read-only: no text fields; untouched prompts are summarised
  as "n questions were left open."

## Code map

| File | What |
|---|---|
| `lib/ui/reset/reset_tab.dart` | `ResetTab` hub: pace, progress card, phase cards, past resets, new reset |
| `lib/ui/reset/guided_prompt_screen.dart` | `GuidedPromptScreen`, autosave, sheets, `kAnswerAutosaveDelay` |
| `lib/ui/reset/reset_complete_screen.dart` | `ResetCompleteScreen` |
| `lib/ui/journal/past_reset_screen.dart` | `PastResetScreen(journeyId:)` read-only answers — shared with Journal (the former Reset copy was removed) |
| `lib/ui/reset/reset_flow.dart` | `PromptStatus`, sequence/progress helpers, phase/subflow/group names, local time + date formatting, `ReadingColumn` (≤ 720 dp column), `Eyebrow`, `SectionTitle`, `showResetSheet` |
| `l10n_src/reset_en.arb` | all `reset…` strings |

No new `AppState` operations were needed: the screens use only the §5 API
(`journey`, `pastJourneys`, `answer`, `saveAnswer`, `skipPrompt`,
`setActivePrompt`, `progressFor`, `coreProgress`, `nextPrompt`,
`completeJourney`, `startNewJourney`, `reminders`). Cross-area navigation goes
through `AppNav` (`openPrompt`, `openResetComplete`, `openLesson`,
`openAwakening`, `openSupport`, `switchTab`) and `showCompassImport`.

## Tests

`test/ui/reset_test.dart` (through `pumpCartha`):

* Hub: three phases, six check-ins with times (24 h and 12 h clock, a
  user-changed time), optional contemplations labelled and uncounted, pace
  note both ways, counts in words, Begin/Continue → resume point, rows open
  their prompts, lesson strip read state → lesson, start a new reset (cancel
  and confirm; history kept, saved), past reset read-only with exact text.
* Guided prompt: one question with context / position / progress; every
  control present, Back disabled first; **answers persist forward, back, after
  leaving and after a restart**; debounce timing and exact text; **flush on
  dispose**, on app pause and on system back; **skip then return via Jump**;
  Jump states with icons + words and resume point; **softer toggle** (and it
  carries to the next prompt); help sheet open/close; labelled example;
  **very long text with special characters**; long answer at 320 dp/200 %;
  daytime check-in time; Feeling heavy → soften / support / pause / skip;
  Pause keeps words; morning → daytime → back; bonus ends at the hub; save
  failure shown with the words kept; reduced motion; unknown id; real English
  content.
* Completion: Save & finish → completion screen, journey completed, vision
  quoted exactly, counts, no "fixed" copy, Build your Compass opens the import
  sheet, Later returns to the hub; open questions named; completion time kept.
* Size matrix (320×568 @2.0, 390×844, 1024×1366 @1.3) × dark/light with the
  real English content: hub, prompt + example + Jump / heavy / help sheets,
  daytime prompt, completion, past reset.

`test/screenshots/reset_screenshots_test.dart` (tag `screenshots`):
`20_reset_hub`, `21_reset_prompt`, `22_reset_checkin`, `23_reset_jump`,
`24_reset_complete`, `25_awakening`, `26_lesson` in dark and light →
`test/screenshots/out/`.

## Requirements satisfied

F-008, F-009, F-010 (morning sequence: savable, revisitable, skippable,
softer wording for anti-vision/identity), F-011 (one question at a time with
intro, answer, progress, back, next, skip, jump), F-012 (autosave and return;
honest failure), F-013, F-014 (vision prompts; user-written statement shown
as written), F-015 (six check-ins with completion status), F-016 (local
times shown, user changes reflected; editing lives in Reminders), F-019
(three optional notes excluded from core completion), F-020, F-021 (evening
sequence), F-022 (hand-off to the Compass import, never silent overwrite —
the sheet is the Compass area's), F-034 (new reset keeps dated earlier
resets, read-only), F-046 (skip, pause, revisit, move between phases),
F-047 (soften / pause / support, crisis signpost, no diagnosis or
celebration), F-044/F-045 (labels, state in words, 320 dp at 200 %).
