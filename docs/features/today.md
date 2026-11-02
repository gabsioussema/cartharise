# Today

The default return view (first tab), like the board's home screen, in the
"balanced" shape of the evolve plan (`docs/plans/evolve.md`, Step 1 › A): one
useful action and an easy stop; everything else one tap away.
Requirements: F-036 (return-home dashboard), F-037 (next best action),
F-054 (gentle progress), F-031 (non-punitive), F-055 (honest save failure).

## Layout (top to bottom)

1. **Greeting** (`ScreenHeader`, Cinzel): "Good morning / afternoon / evening,
   <name>." — the optional name, else "Traveler". Morning 04:00–11:59,
   afternoon 12:00–17:59, evening otherwise (local time). Subtitle
   "Clarity today. Progress tomorrow." Once the user made an avatar, it
   stands beside the greeting (48 dp `AvatarView`, decorative, no banner).
2. **Save problem** (only when the last write failed): the shared
   `SaveIndicator` with Retry and Export a copy.
3. **Your next step** — `NextActionCard` (`next_action.dart`): a forest
   `HeroCard` with the **compact** dawn scene (`DawnRuinsScene(compact:
   true)`: the same art cropped to its band of interest at 3:1,
   `NextActionCard.sceneAspectRatio = kCompactSceneAspectRatio`; rises once,
   static with reduced motion), eyebrow, title, one or two short lines, a bronze pill, an
   optional secondary link and **Choose something else**. Once the chosen
   kind of action was done today it shows **"Done. That can be enough for
   today."** with a quiet **One more** instead (see below).
4. **Campaign invitation** — `CampaignInviteCard` ("Play the Campaign? XP
   and levels for what you do." with **Play** / **Not now**, see
   `campaign.md`) while `AppSettings.gameInvited` is false, i.e. for a brand-new
   profile until the user answers it once. Existing users never see it.
5. **Write** — a quick capture ("Write a few lines…", read out as "Write a
   new note") that opens a new journal note (`AppNav.openJournalEntry`;
   nothing is saved until something is typed there).
6. **At a glance** — up to three small tappable tiles (three across on a
   phone, fewer with large text): **Reset** "3/27 reflections" with a bar (→
   Reset tab; "Start" / "Done" before and after), **Campaign** "Level n · x
   XP" with a bar (→ Campaign; only while the game layer is on), **30-day
   path** "Day n · stage" (→ the next day; only once the user wrote on the
   path). Each tile is one button whose label reads the full sentence and
   which carries the tap action for screen readers.
7. **Today's focus** — `todayFocus()` (`lib/ui/missions/missions_logic.dart`):
   exactly Missions' Today section (every daily quest, one-offs planned for
   today or earlier) plus planned one-offs ticked today (shown ticked until
   the day ends), so Today and Missions agree. Up to five, then "See all n
   quests"; undated and later quests are only counted ("n more for anytime
   or later" → Missions); "Add a quest" → Missions. Daily quests carry the
   same "Every day" label as Missions, and open quests the same "+20 XP"
   chip (`questXpOpenOn`: game layer on, today's quest XP not used up; read
   out with the row as "Earns 20 XP when done").
8. **Your direction** — **collapsed** by default: the direction glyph,
   "Your direction" and one line ("Your vision and this month's project." /
   the first-use hint / "Your Compass is empty."). A tap (or the screen
   reader's tap; announced with its expanded state) opens the vision and
   this month's project (the Missions project title if set, else Compass ›
   month project) and **Open Compass**. The chevron points up or down too.

## Next step (pure: `lib/ui/today/next_step.dart`)

`nextStepFor(NextStepFacts)`, `stepOptions(NextStepFacts)` and
`doneForToday(NextStepFacts, NextStep)` are pure; `NextStepFacts.of(AppState)`
reads only stored state (current journey answers/skips/active prompt/
completion, lessons read, Compass, lever drafts, the import preview, today's
quests, the month project, reviews, notes, the pace, `settings.todayPin`,
today's weekday and today's activity as `DoneToday`). Reading never writes.

### The app's own order (`TodayPin.auto`)

First rule that matches:

| # | When | Card | Primary → | Secondary → |
|---|---|---|---|---|
| 1 | An open quest in today's focus (Missions' order) | the quest's own title, "One of today's quests." | **Mark done** (✓) → `setQuestDone(id, true, day: today)` | — |
| 2 | Nothing answered, skipped or opened in the current reset (with no quests at all this is the first card) | "Begin the morning reflection" (14 short questions. Skip any, pause anytime.) | **Begin** → `AppNav.openPrompt(first morning prompt)` | "Learn the 7 ideas (optional)" → `AppNav.openAwakening` — only if no lesson was read |
| 3 | Reset started, not completed, `nextPrompt` exists | "Continue the morning reflection" / "…daytime check-ins" / "…evening reflection", "Next: <prompt title>", "Morning · question 4 of 14" | **Continue** → `openPrompt(nextPrompt)` | — |
| 4 | Evening all answered/skipped (or reset completed) and Compass empty | "Build your Compass" | with evening words: **Review your answers** → `showCompassImport`; without: **Open Compass** | "Open Compass" (import case) |
| 5 | Compass has daily levers, no quests | "Turn your levers into quests" | **Choose quests** → `AppNav.openMissions` | — |
| 6 | Friday–Sunday and no review for this week | "Look back on your week" | **Start a weekly review** → `AppNav.openReview` | — |
| 7 | Otherwise | "Write a note" | **New note** → `AppNav.openJournalEntry` | — |

Every card also has **Choose something else**.

### "Help me with" (`TodayPin`, remembered in settings)

Asked in **Choose something else**; it overrides the order while it applies,
else the app's own order decides (the card is then not "pinned"):

| Pin | Card |
|---|---|
| **My project** | "Work on your project": the project title as typed, "Next: <first open milestone>", **Open the project** → `AppNav.openProject`. The project is the saved one unless it is finished, else the Compass's month project (Missions' draft). No project → falls back (the sheet says "No project yet. Today decides for now."). |
| **Reflection** | Begin the reset, else resume it, else the weekly review (Friday–Sunday, none yet this week), else falls back. |
| **Notes** | "Write a note". |
| **Decide for me** | `auto`: the app's own order. |

The project is never chosen by the app itself; it is in the pin and in the
sheet.

### Choose something else (bottom sheet)

"Other steps": every step that makes sense now (`stepOptions`: the app's
order with the project before the note), except the one on the card. Each is
one row with its glyph and title; a tap closes the sheet and starts it (a
quest row, "Do one of today's quests", opens Missions). Then **Help me
with**: four radio rows (announced as a checked/unchecked group, the choice
also shown by its mark); a tap saves `settings.todayPin` with
`updateSettings` and closes the sheet. Dismissing changes nothing. The sheet
scrolls, pads for the system inset and opens without animation when motion
is off.

### Done for today

`doneForToday` — the kind of action the user chose was done today:

* pinned **Notes** → a note written or edited today;
* pinned **Reflection** → an answer with words (a skip is not one) or a
  weekly review today;
* pinned **My project** → the project changed today or one of its quests
  (`QuestSource.project`) completed today;
* the app's own choice → anything Today could suggest, done today: a quest
  completed, an answer, a note, a review, the Compass or the project
  changed.

Then the card says **"Done. That can be enough for today."** (a check icon
plus the words) and a quiet **One more** link (read out as "Show one more
step") that shows the step for the rest of that day. Exception: a reset
under way with the **one day** pace keeps offering "Continue" — the user
chose to do it in one day.

### Long absence

Only today's date counts. Nothing on Today counts days, misses or time
since the last visit; after any absence Today simply shows the next action
(an old planned quest is still just its title).

## First-use hints (replace the old welcome carousel)

`FirstUseHints.of(AppData)` (`today_model.dart`) — derived, nothing extra is
stored; each shows only until the feature is first used, so it never comes
back once used:

| Hint | Where | Shown while |
|---|---|---|
| "Morning, daytime, evening: one day, at your own pace." | start card (detail line) | no reset was ever begun (no answer, skip, opened prompt or completion in any journey) |
| "Quests are small steps you choose. Adjust them each week." (bulb) | Today's focus, instead of "Add a small quest when you're ready." | no quest exists |
| "Your answers can become a Life Compass." (bulb) | Your direction's one line | the Compass is empty and no Compass version was ever saved |

## Behaviour rules

- **Quests**: each row is one accessible checkbox — label "Mark '<title>'
  done", checked state, tap action (row or box). Done = tick + struck-through
  text (not colour alone). Daily quests carry an "Every day" tag. Toggling
  calls `setQuestDone(id, done, day: today)`; a daily quest's other days are
  untouched. No counts of misses, no streaks.
- **The user chooses**: nothing opens by itself, and the suggestion never
  assumes anything that isn't stored. The quest card's title, the project
  and milestone titles are the user's own words as typed.
- **Honest failures**: a failed write (e.g. "Mark done" or the pin) shows
  the shared `SaveIndicator` with Retry; nothing claims it was saved.
- **Privacy**: answer and journal text are never shown on Today; only quest
  titles, vision, month project and milestones (the user's own planning
  words, as typed).
- **Sizes**: one `ListView`; content column ≤ 720 dp centred on tablets;
  cards grow with text (no fixed heights; min heights only); the hero scene
  keeps its 3:1 ratio; the direction opens with `AnimatedSize` (instant
  with motion off).

## Code map

| File | Role |
|---|---|
| `lib/ui/today/today_tab.dart` | `TodayTab()`: layout, Write capture, glance tiles, focus card, collapsed direction |
| `lib/ui/today/next_action.dart` | `NextActionCard()`: hero card, done state, "Choose something else" sheet |
| `lib/ui/today/next_step.dart` | `NextStepFacts`, `DoneToday`, `NextStep`, `nextStepFor`, `stepOptions`, `doneForToday` (pure) |
| `lib/ui/today/today_model.dart` | `dayPartAt`, `currentPathDay`, `nextPathDay`, `JourneySummary`, `FirstUseHints` |
| `l10n_src/today_en.arb` | `today…` strings |

## Tests (`test/ui/today_test.dart`)

- `nextStepFor` unit tests for every rule and the order (open quests before
  the reset; a fresh start with no quests begins the reset; quests but none
  open → begin; resume beats Compass; a completed reset never resumes; a
  Compass without levers isn't nagged about; weekly review only
  Friday–Sunday and once a week; the project never chosen by the app), and
  for every pin (notes → note; reflection → begin / resume / Friday review /
  fall back; project → project + milestone; project without a project →
  falls back; auto = the order).
- `stepOptions`: every valid step once, project before the note.
- `doneForToday`: the app's choice and each pin's own kind; one-day resume;
  nothing done → never "done".
- `NextStepFacts.of` against a real `AppState` + `MemoryDataStore`, walking
  start → lessons → resume → evening/skips → Compass import → levers →
  quests (the quest card) → quests done (note) → Friday (daily quests reopen,
  then the review) → note; today's activity (answers, quests, notes,
  reviews, project, project quests; older days ignored; a skip is no
  answer); the project from the saved project or the Compass draft, not
  when finished; the pin and pace read from storage; reading never writes.
- Model: part of day boundaries; path day; `JourneySummary`; first-use hints
  (fresh, used, opened prompt / saved Compass version count as use).
- Widgets (real app via `pumpCartha`): greetings; the avatar; section order;
  first day with the three hints and the compact scene; hints gone once
  used; "Mark done" → saved → "Done…" → "One more" → the next quest;
  something done today shows the easy stop first; resume text and
  `GuidedPromptScreen(promptId: morning.04)`; direction collapsed/expanded
  with semantics; quest checkboxes; "+20 XP" chips (and not on done rows, a
  used-up day or with the game off); five quests + "See all"; Today and
  Missions agree; Add a quest; path day and Open Compass; reset tile; Write
  opens a new note (and saves nothing); the invitation below the next action
  only while unanswered; Build your Compass sheet; levers → Missions; note
  and Friday review; the sheet's other steps (order, start one; a quest row
  opens Missions); "Help me with" (radio semantics, saved pin, card follows,
  back to auto); dismissing changes nothing; pinned project and pinned notes;
  long absence without counts; failed save with Retry; no
  streak/score/guilt words in any state nor in the ARB fragments; scene
  rises once and is static with Motion off; size matrix (320×568 @200 %,
  390×844, 1024×1366 @130 %) × dark/light × six data states, plus the
  direction open and the sheet, without overflow.
- Screenshots: `test/screenshots/onboarding_today_screenshots_test.dart` →
  `20_today_first_*`, `20b_today_new_user_*`, `21_today_in_progress_*`,
  `21b_today_avatar_*`, `21c_today_done_*`, `21d_today_quest_*`,
  `21e_today_choose_*`, `22_today_settled_*`.

## Requirements covered

F-036, F-037, F-054, F-031, F-055 (on Today), F-044 (checkbox labels/state,
expanded state, radio group), F-045 (320 dp at 200 % text); evolve plan
Step 1 › A (balanced Today, pin, done state, long absence, invitation,
first-use hints).
