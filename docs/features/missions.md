# Missions (quests, levers, month project, 30-day path)

The second half of the **Compass** tab ("Your direction, in action."): gentle
quests, the daily-lever drafts, the one-month project and the optional thirty-day
path. Requirements: F-027, F-028, F-029, F-030, F-031, F-057 (+ §07 "parse daily
levers as draft quests; users approve or change them", §11 "Convert daily levers
to tasks; complete, reopen, and delete a task").

## User flow

1. **Turn your daily levers into quests** (when `leverDrafts` is not empty): up
   to three drafts from Compass › Daily levers as editable text fields with a
   checkbox each (ticked by default). "Add n daily quests" →
   `addQuestsFromLevers` → snackbar with the real count ("Nothing new to add …"
   when every title already exists). "Not now" puts the card aside.
2. **Today** (with the local date): every daily quest (ticked only if done
   today) and open one-off quests planned for today or earlier. "Add a quest".
3. **Anytime & upcoming**: open one-offs without a date, then planned ones by date.
4. **Done (n)** — collapsed: finished one-offs, newest first; untick to reopen.
5. **Month project** card → `ProjectScreen`.
6. **30-day path**: "Any day is open — go at your own pace.", "n of 30 written",
   then Observe · Days 1–7 / Experiment · 8–15 / Build · 16–23 / Adjust · 24–30,
   each a grid of day cards (Day n, title, "Written" with a tick icon). Any card
   opens `PathDayScreen`.

### Quest tile, sheet and actions

* Tile: accessible checkbox (`semanticLabel` "Mark '<title>' done"), title
  (strike-through when done), calm labels: "Every day", "Planned for Tue, Nov 10",
  "Done today" / "Done <date>"; options menu (Edit, Delete). Tapping the row edits.
* Completing a one-off moves it to Done → snackbar "'<title>' moved to Done" +
  Undo. Daily quests stay in Today.
* Delete (menu or "Delete quest" in the sheet) is immediate with an **Undo**
  snackbar that puts the quest back at the same position.
* Undo snackbars use `persist: false`: they leave after the usual few seconds
  (Flutter otherwise keeps a snackbar with an action until it is dismissed).
* Sheet (`showQuestSheet`): title (required, "Give the quest a few words."),
  "Repeat every day" switch, optional date via the date picker ("Remove date").

### Month project — `ProjectScreen()`

* Title prefilled from Compass › One-month project with **"Linked to your
  Compass"**. When the title differs, an inline offer: "Your Compass says: … Update
  it to match?" → **Update Compass** / **Keep as is** (or "Add to Compass" when the
  Compass field is empty). The Compass is never changed without that tap.
* Status chips Planned / Active / Paused / Done (tick + label, not colour alone).
* Milestones: add (dialog), tick, rename (dialog), delete with Undo; "n of m
  milestones done".
* Looking back (retrospective): autosaved text.
* Nothing is stored until the user changes something; "Start a new project"
  (destructive confirm) clears the project, never the Compass.

### Path day — `PathDayScreen({required int day})`

Cinzel title, "Day n · Stage", the prompt, the hint, an autosaved note, previous
/ next day buttons (the note of the day being left is saved at once).

## Behaviour rules

* **No streaks, points, scores, red "missed" states or guilt copy** (F-031): a
  past-dated quest just sits in Today with its date; counts are information only.
  A unit test scans `compass_en.arb` + `missions_en.arb` for judging words.
* **Per local day** (F-029): completions are date keys; a daily quest's tick
  belongs to that day only and the history is kept. Changing a daily quest to a
  one-off keeps it done only if it was done today; daily quests never keep a date.
* **Exact text**: quest titles are trimmed (state rule); notes, retrospective and
  path answers are saved exactly as typed with the shared autosave
  (`lib/ui/compass/autosave.dart`: 600 ms debounce, focus loss, backgrounding,
  dispose).
* Lever drafts handled ("added" or "Not now") stay hidden for the same levers
  text for the rest of the session (kept in `CompassTab` state); editing the
  levers shows the card again.

## Code map

| File | What |
|---|---|
| `lib/ui/missions/missions_view.dart` | `MissionsView`: lists, Done, project card, path |
| `lib/ui/missions/missions_logic.dart` | `extension MissionsOps on AppState` (built on `mutate`): `missionSections`, `editQuest`, `restoreQuest`, `projectOrDraft`, `updateProject`, `setProjectTitle/Status/Retrospective`, milestones add/done/rename/delete/restore, `pathWritten`, `pathWrittenCount` |
| `lib/ui/missions/quest_tile.dart` | `QuestTile`, `deleteQuestWithUndo`, `setQuestDoneWithFeedback` |
| `lib/ui/missions/quest_sheet.dart` | `showQuestSheet`, `QuestSheet` |
| `lib/ui/missions/lever_drafts_card.dart` | `LeverDraftsCard` |
| `lib/ui/missions/project_screen.dart` | `ProjectScreen` |
| `lib/ui/missions/path_grid.dart` | `PathGrid` (responsive equal-height rows) |
| `lib/ui/missions/path_day_screen.dart` | `PathDayScreen` |
| `lib/ui/missions/missions_copy.dart` | status / stage labels and icons |
| `l10n_src/missions_en.arb` | strings (`missions…`) |

## Tests

`test/ui/missions_test.dart` (30): logic — sections (dailies, past/today/future
dates, Done order, next-day reset), daily→one-off edit rule, undo-delete position,
project draft from the Compass + milestones + exact retrospective, path
"written"; copy guard; widget — calm empty state without judging words (dark,
light); add one-off + daily (validation, sections); complete → Done (collapsed)
→ reopen → delete → Undo with the semantic checkbox label; daily quest reset per
local day with history kept; edit with the date picker and "Remove date"; delete
from the sheet + Undo; lever drafts (≤ 3, duplicates skipped, edited, unticked one
left out, real count, card hidden); edited-into-duplicate reported; "Not now";
project linked/offer/Update Compass/Keep as is; status, milestones
add/tick/rename/delete+Undo with semantic label, retrospective, start a new
project; path grid groups, any day open, exact autosaved note saved when leaving
at once, previous/next, "Written" marker, persisted; first/last day buttons; real
English path content; size matrix × dark/light over Missions (Done open), quest
sheet, project and a path day, plus the project with the Compass offer.

Screenshots: `test/screenshots/compass_screenshots_test.dart` (tag
`screenshots`) → `test/screenshots/out/missions_0*_{dark,light}.png`.

## Requirements satisfied

F-027 (add/edit/complete/reopen/delete), F-028 (≤ 3 lever drafts, no exact
duplicates, user may change them), F-029 (completion per local date, daily
recurrence, optional date), F-030 (status, milestones, retrospective, linked to the
Compass), F-031 (non-punitive), F-057 (30 days in four stages, autosaved, any day
open), F-054 (gentle, informational progress only).
