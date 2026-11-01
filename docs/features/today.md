# Today

The default return view (first tab), like the board's home screen.
Requirements: F-036 (return-home dashboard), F-037 (next best action),
F-054 (gentle progress), F-031 (non-punitive), F-055 (honest save failure).

## Layout (top to bottom)

1. **Greeting** (`ScreenHeader`, Cinzel): "Good morning / afternoon / evening,
   <name>." — the optional name, else "Traveler". Morning 04:00–11:59,
   afternoon 12:00–17:59, evening otherwise (local time). Subtitle
   "Clarity today. Progress tomorrow."
2. **Save problem** (only when the last write failed): the shared
   `SaveIndicator` with Retry and Export a copy.
3. **Your next step** — a forest `HeroCard` with `DawnRuinsScene` (rises once;
   static with reduced motion), eyebrow, title, one or two lines, a bronze pill
   and an optional secondary link.
4. **At a glance** — up to three small tappable tiles (three across on a
   phone, fewer with large text): **Reset** "3/27 reflections" with a bar (→
   Reset tab; "Start" / "Done" before and after), **Campaign** "Level n · x
   XP" with a bar (→ Campaign; only while the game layer is on), **30-day
   path** "Day n · stage" (→ the next day; only once the user wrote on the
   path). Each tile is one button whose label reads the full sentence.
5. **Today's focus** — `todayFocus()` (`lib/ui/missions/missions_logic.dart`):
   exactly Missions' Today section (every daily quest, one-offs planned for
   today or earlier) plus planned one-offs ticked today (shown ticked until
   the day ends), so Today and Missions agree. Up to five, then "See all n
   quests"; undated and later quests are only counted ("n more for anytime
   or later" → Missions); "Add a quest" → Missions. Daily quests carry the
   same "Every day" label as Missions.
6. **Your direction** — the Compass vision and this month's project (the
   Missions project title if set, else Compass › month project) → Compass.

## Next step (pure: `lib/ui/today/next_step.dart`)

`nextStepFor(NextStepFacts)`; `NextStepFacts.of(AppState)` reads only stored
state (current journey answers/skips/active prompt/completion, lessons read,
Compass, lever drafts, the import preview, quests, reviews, today's weekday).
Reading never writes. First rule that matches:

| # | When | Card | Primary → | Secondary → |
|---|---|---|---|---|
| 1 | Nothing answered, skipped or opened in the current reset | "Begin the morning reflection" (n short questions…) | **Begin** → `AppNav.openPrompt(first morning prompt)` | "Learn the 7 ideas (optional)" → `AppNav.openAwakening` — only if no lesson was read |
| 2 | Reset started, not completed, `nextPrompt` exists | "Continue the morning reflection" / "…daytime check-ins" / "…evening reflection", "Next: <prompt title>", "Morning · question 4 of 14" | **Continue** → `openPrompt(nextPrompt)` | "See the whole reset" → Reset tab |
| 3 | Evening all answered/skipped (or reset completed) and Compass empty | "Build your Compass" | with evening words: **Review your answers** → `showCompassImport`; without: **Open Compass** | "Open Compass" (import case) |
| 4 | Compass has daily levers, no quests | "Turn your levers into quests" | **Choose quests** → `AppNav.openMissions` | — |
| 5 | Friday–Sunday and no review for this week | "Look back on your week" | **Start a weekly review** → `AppNav.openReview` | "New note" |
| 6 | Otherwise | "Write a note" | **New note** → `AppNav.openJournalEntry` | "Open the journal" → Journal tab |

The user always chooses; nothing opens by itself, and the suggestion never
assumes anything that isn't stored.

## Behaviour rules

- **Quests**: each row is one accessible checkbox — label "Mark '<title>'
  done", checked state, tap action (row or box). Done = tick + struck-through
  text (not colour alone). Daily quests carry a "Daily" tag. Toggling calls
  `setQuestDone(id, done, day: today)`; a daily quest's other days are
  untouched. No counts of misses, no streaks.
- **Journey**: before anything is written there's no ring, just "Your reset
  hasn't started yet. It's ready whenever you are." Afterwards a
  `ProgressRing` (answered core prompts / all core prompts — bonus never
  counts) with "n of 27 reflections written" and a calm status: waiting where
  you left it · every reflection written or set aside · you finished this
  reset. Phase chips "Morning 3/14" read as "Morning: 3 of 14 written"; a
  finished phase also gets a check icon.
- **Thirty-day path**: "Day n of 30 · <stage>" appears **only** when the user
  has written on the path; n is the most recently written day. "Open day m"
  opens the next unwritten day after it (or n).
- **Empty states**: no quests ("Quests are small actions you choose
  yourself…"), empty Compass ("It holds your vision, a one-month project and a
  few daily levers, in your own words."), unfinished reset (next step +
  journey text). Never guilt copy.
- **Privacy**: answer and journal text are never shown on Today; only quest
  titles, vision and month project (the user's own Compass words, as typed).
- **Sizes**: one `ListView`; content column ≤ 720 dp centred on tablets;
  cards grow with text (no fixed heights); the hero scene keeps a 2:1 ratio.

## Code map

| File | Role |
|---|---|
| `lib/ui/today/today_tab.dart` | `TodayTab()` and its cards |
| `lib/ui/today/next_step.dart` | `NextStepFacts`, `NextStep`, `nextStepFor` (pure) |
| `lib/ui/today/today_model.dart` | `dayPartAt`, `currentPathDay`, `nextPathDay`, `JourneySummary` |
| `l10n_src/today_en.arb` | `today…` strings |

## Tests (`test/ui/today_test.dart`)

- `nextStepFor` unit tests for every rule and the rule order (resume beats
  Compass; a completed reset never resumes; a Compass without levers isn't
  nagged about; weekly review only Friday–Sunday and only once per week).
- `NextStepFacts.of` against a real `AppState` + `MemoryDataStore`, walking
  start → lessons → resume → evening/skips → Compass import → levers → quests →
  note → Friday review → note; reading never writes; a completed reset with a
  skipped evening offers a hand-filled Compass; an opened prompt counts as
  started.
- Model: part of day boundaries; path day (latest written, blanks ignored,
  ties → higher day); `JourneySummary` counts core prompts only.
- Widgets (real app via `pumpCartha`): greetings with and without a name at
  three times; first-day card, lessons link and empty states; resume text and
  `GuidedPromptScreen(promptId: morning.04)`; checkbox semantics and toggling
  (persisted for today); five quests + "See all"; Add a quest / Choose quests →
  Missions; Open day 4 → `PathDayScreen(day: 4)`; Open Compass; Open the
  reset; Build your Compass opens the import sheet; note and Friday review
  open their screens; failed save shown with Retry; no streak/score/guilt
  words on screen in any state nor in the ARB fragments; hero scene rises once
  and is static with Motion off; size matrix (320×568 @200 %, 390×844,
  1024×1366 @130 %) × dark/light × three data states without overflow.
- Screenshots: `test/screenshots/onboarding_today_screenshots_test.dart` →
  `20_today_first_*`, `21_today_in_progress_*`, `22_today_settled_*`.

## Requirements covered

F-036, F-037, F-054, F-031, F-055 (on Today), F-044 (checkbox labels/state),
F-045 (320 dp at 200 % text).
