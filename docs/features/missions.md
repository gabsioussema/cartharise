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
2. **List | Board** (`SegmentedButton`, List by default; the selected segment
   shows a tick). The quests below are one task list in two views; the
   [Board](#board--questboard) is described below. In List:
3. **Today** (with the local date): every daily quest (ticked only if done
   today) and open one-off quests planned for today or earlier. "Add a quest".
4. **Anytime & upcoming**: open one-offs without a date, then planned ones by date.
5. **Done (n)** — collapsed: finished one-offs, newest first; untick to reopen.
6. **Month project** card → `ProjectScreen` (the direction glyph by its title:
   the project is the Compass's direction in practice).
7. **30-day path**: "Any day is open — go at your own pace.", "n of 30 written",
   then Observe · Days 1–7 / Experiment · 8–15 / Build · 16–23 / Adjust · 24–30,
   each a grid of day cards (Day n, title, "Written" with a tick icon). Any card
   opens `PathDayScreen`.

### Quest tile, sheet and actions

* Tile: accessible checkbox (`semanticLabel` "Mark '<title>' done"), title
  (strike-through when done), calm labels (`QuestLabels`, shared with the board
  cards): "Experiment" (seedling glyph, added from the Playground), the quest's
  **project** (direction glyph + the project's title, current or past, when
  `Quest.projectId` names one that exists), "Every day", "Planned for Tue, Nov 10",
  "Done today" / "Done <date>", "+20 XP" (Campaign on, quest open, today's quest
  XP not used up); options menu (Edit, Delete). Tapping the row edits.
* Completing a one-off moves it to Done → snackbar "'<title>' moved to Done" +
  Undo. Daily quests stay in Today.
* Delete (menu or "Delete quest" in the sheet) is immediate with an **Undo**
  snackbar that puts the quest back at the same position.
* Undo snackbars use `persist: false`: they leave after the usual few seconds
  (Flutter otherwise keeps a snackbar with an action until it is dismissed).
* Sheet (`showQuestSheet`): title (required, "Give the quest a few words."),
  "Repeat every day" switch, optional date via the date picker ("Remove date").
  A new quest starts in the board lane `stage` (Ready by default; the board's
  "Add to …" passes its lane) and is linked to the active project by
  `addQuest`; `onAdded` hears about it once saved.

### Board — `QuestBoard`

Another view of the same quests (plan step 2 · D): lanes **Later → Ready →
Doing → Done** from `MissionsOps.questBoard` (`Quest.laneOn` for today; oldest
first, Done most recently finished first). Copy: "Hold a card to drag it, or use
its move button."

* **Layout.** Stacked lanes on phones; four equal-height columns
  (`IntrinsicHeight` row) when the window is at least `QuestBoard.columnsFrom`
  (840 dp) wide. Each lane is an outlined panel: lane icon + name + count chip
  (announced as one header, e.g. "Doing, 2 quests"), the cards, a calm line when
  empty ("Park ideas here for another time." · "Quests ready to start." · "Move a
  quest here when you start it." · "Finished quests land here."), and **Add to
  Later / Ready / Doing** (`showQuestSheet(stage:)`).
* **Card** (`BoardCard`): title (struck through once done), the list's labels
  (`QuestLabels`) across the full card width, and a **Move to…** button in the
  corner (`PopupMenuButton`, tooltip "Move '<title>' to…", items "Move to <lane>"
  for the three other lanes; keyboard-focusable). Tapping edits (delete is in the
  sheet). No checkbox: completing is moving to Done.
* **Drag.** Hold a card (`LongPressDraggable`) and drop it on any lane; the
  hovered lane gets an accent outline and a "Drop to move here" chip (not colour
  alone); the page scrolls when the finger nears an edge
  (`EdgeDraggingAutoScroller`). Dropping on its own lane does nothing.
* **Screen readers** get "Move to <lane>" custom actions on each card.
* **After a move**: "'<title>' moved to <lane>" (or "'<title>' done for today" for
  a daily quest) with **Undo**, which puts the stored lane *and* the completion
  days back exactly (`undoQuestMove`). A failed save says "Your last change
  couldn't be saved." with **Retry** — never "moved".
* **Done** is folded by default with its count ("Folded away. Drop a card here to
  finish it."); its header is a button with the expanded state announced. Open or
  folded, it takes dropped cards.
* **Doing**: above three cards a gentle line, "Fewer in Doing can feel lighter."
  (spa icon) — never a limit.
* **Today** filter chip (`FilterChip`, tooltip "Only daily quests and those
  planned for today"): every lane keeps only `todayFocus()` — daily quests and
  one-offs planned for today or earlier (plus those finished today), the same set
  the Today tab shows — whatever their stage. Empty lanes say "Nothing here for
  today." A quest added while it hides it says "Added. The Today filter hides it."
  with **Show all**.
* **XP**: moving never earns anything by itself. Moving into Done completes the
  quest for today (`MissionsOps.moveQuest` → `Quest.movedTo`), so it earns exactly
  what ticking it earns (+20 XP up to the daily cap, with the usual Campaign
  moment); moving out of Done un-completes today and the XP goes with it.
* **Daily quests**: in Done for the day they were completed, back in Ready the
  next day; `completedOn` keeps every day.
* **Remembered** while the app runs: List/Board, the Today filter and Done open
  (route `PageStorage`), not saved to the data file.
* **Motion**: the List/Board switch uses `CarthaPageMotion`; the move menu opens
  without animation when the device or Settings › Motion asks for less.

### Month project — `ProjectScreen()`

* Title prefilled from Compass › One-month project with **"Linked to your
  Compass"**. When the title differs, an inline offer: "Your Compass says: … Update
  it to match?" → **Update Compass** / **Keep as is** (or "Add to Compass" when the
  Compass field is empty). The Compass is never changed without that tap.
* Status chips Planned / Active / Paused / Done (tick + label, not colour alone).
* Milestones: add (dialog), tick, rename (dialog), delete with Undo; "n of m
  milestones done". The Project card carries the direction glyph and the
  Milestones card the progress glyph (`SectionCard(glyph: …)`).
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
| `lib/ui/missions/missions_view.dart` | `MissionsView` (`MissionsLayout` List/Board toggle, Today filter chip), the list, Done, project card, path |
| `lib/ui/missions/board_view.dart` | `QuestBoard` (lanes, columns from 840 dp, Today filter, Done fold, Doing note, Add to …), `kBoardDoingCalm` |
| `lib/ui/missions/board_card.dart` | `BoardCard` (drag, Move to…, semantics actions), `moveQuestWithFeedback`, `undoQuestMove`, `laneLabel`, `laneIcon` |
| `lib/ui/missions/missions_logic.dart` | `extension MissionsOps on AppState` (built on `mutate`): `missionSections`, `todayFocus`, `questBoard`, `moveQuest`, `setQuestProject`, `editQuest`, `restoreQuest`, `projectOrDraft`, `updateProject`, `setProjectTitle/Status/Retrospective`, milestones add/done/rename/delete/restore, `pathWritten`, `pathWrittenCount` |
| `lib/ui/missions/quest_tile.dart` | `QuestTile`, `QuestLabels` (shared with the board), `deleteQuestWithUndo`, `setQuestDoneWithFeedback` |
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

`test/ui/board_test.dart` (30): List by default and Board lanes in order with
announced counts, nothing written by viewing; the view kept across sections;
calm empty lanes without judging words; "Add to Later / Doing" stage; cards carry
the experiment, project, every-day, planned and "+20 XP" labels (project label in
the list too), no XP chip with the Campaign off; Move to… (other lanes only) +
snackbar + Undo; drag between lanes and into folded Done; a drop on its own lane
changes nothing; Undo restores a reopened one-off's first done day; the "Move to
Later" semantics action; a failed save said with Retry (no "moved"); XP never
changes for Later/Ready/Doing moves, +20 into Done and back out, the daily cap
respected; a daily quest done for today then in Ready the next day with
`completedOn` kept; the Today filter (daily and planned for today or earlier in
every lane, stages untouched, nothing written) and "Added. The Today filter hides
it." → Show all; Done folded with count, expanded state announced, newest first;
the Doing note above three and still free to add more; the move menu without
animation with Settings › Motion off or device reduce-motion; size matrix × dark
/ light (columns on the tablet, stacked on phones) over the board with Done open,
the move menu and the add sheet; tap-target, label and contrast guidelines on
every lane (dark, light).

Screenshots: `test/screenshots/compass_screenshots_test.dart` (tag
`screenshots`) → `test/screenshots/out/missions_0*_{dark,light}.png`;
`test/screenshots/board_screenshots_test.dart` →
`test/screenshots/out/board_0*_{dark,light}.png` (top with the toggle, phone
lanes, Done open, Today filter, Doing note, dragging, move menu, tablet columns,
320 dp at 200 %).

## Requirements satisfied

Plan step 2 · D (board: List/Board, four lanes, Move to… and drag, gentle Doing
note, Done folded, Today filter, completion XP only), F-027
(add/edit/complete/reopen/delete), F-028 (≤ 3 lever drafts, no exact
duplicates, user may change them), F-029 (completion per local date, daily
recurrence, optional date), F-030 (status, milestones, retrospective, linked to the
Compass), F-031 (non-punitive), F-057 (30 days in four stages, autosaved, any day
open), F-054 (gentle, informational progress only).
