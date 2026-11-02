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
5. **Month project** card (`ProjectCard`) → `ProjectScreen` (the direction glyph
   by its title: the project is the Compass's direction in practice), with the
   project's picture as a small square when one is chosen. Without a project it
   shows the Compass's one-month project — or, when that one is already
   finished, "Plan your next project.".
6. **30-day path**: "Any day is open — go at your own pace.", "n of 30 written",
   then Observe · Days 1–7 / Experiment · 8–15 / Build · 16–23 / Adjust · 24–30,
   each a grid of day cards (Day n, title, "Written" with a tick icon). Any card
   opens `PathDayScreen`.

### Quest tile, sheet and actions

* Tile: accessible checkbox (`semanticLabel` "Mark '<title>' done"), title
  (strike-through when done), calm labels: "Every day", "Planned for Tue, Nov 10",
  "Done today" / "Done <date>", and its project (`ProjectTag`: the project's
  picture, round, and its title on one line; read "Project: <title>"); options
  menu (Edit, Delete). Tapping the row edits.
* Completing a one-off moves it to Done → snackbar "'<title>' moved to Done" +
  Undo. Daily quests stay in Today.
* Delete (menu or "Delete quest" in the sheet) is immediate with an **Undo**
  snackbar that puts the quest back at the same position.
* Undo snackbars use `persist: false`: they leave after the usual few seconds
  (Flutter otherwise keeps a snackbar with an action until it is dismissed).
* Sheet (`showQuestSheet`): title (required, "Give the quest a few words."),
  "Repeat every day" switch, optional date via the date picker ("Remove date"),
  and — while there is a project to link — **Part of the month project**
  (`ProjectLinkSwitch`: the project's picture and title). A new quest starts
  linked to the active project (on by default, switch off to keep it loose); an
  existing one can be linked or unlinked (`setQuestProject`). A task of a
  finished project says "Part of a finished project" and can be unlinked.

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
  (destructive confirm) clears the project, never the Compass (the confirm says
  "…and photo" when the project wears one, since the photo is deleted).
* **Picture** card, **Finish this project** and **Project history · n**: see
  Projects below.

### Projects — finish, history, links, picture (Step 2 · E)

* **Finish this project** (shown once a project is saved) → `FinishProjectSheet`:
  the project's picture and title, **Looking back** prefilled with the notes so
  far exactly as typed (optional, skippable), **Finish and keep** / Cancel.
  Notes typed on the page a moment before are saved first (the page unfocuses,
  then flushes). `archiveProject(retrospective: text)` moves it to
  `pastProjects` with its milestones; its quests and attempts keep pointing at
  it. "Kept in your project history." and the **Finished and kept** card (View
  history · Plan the next one) appear only once that reached storage; a failed
  save says "Not saved yet. Use Retry on this page." (the save indicator offers
  Retry). Words changed in the sheet and then cancelled become the project's
  notes, so nothing typed is lost.
* After finishing, the Compass keeps its words, but a draft never restarts
  under a finished project's name (`projectShownTitle`): the title field is
  empty, and the first change (status, milestone, notes, picture) saves the
  title shown first, so what is seen is what is kept. Typing a new title offers
  "Update the Compass to match?" as before.
* **Project history** (`ProjectHistoryScreen`, from "Project history · n" on the
  project page, the Finished card, and the Collection's **Projects finished**
  keepsake): newest first, each card with its picture, title, months ("Oct 2026"
  or "Aug 2026 – Sep 2026", from `startedAt` to `archivedAt`), labels with words
  (milestones done · n tasks · n attempts) and the start of its look back.
  Empty: "Nothing here yet — Finish a month project to keep it here."
* **Past project** (`PastProjectScreen`): picture, title, months, "Finished
  <date>", milestones (tick or ring **and** Done / Open in words), the look back
  exactly as typed, the linked tasks (Done / Open / Every day) and attempts
  (what was tried, "Learned: …", day). **Remove from history** (destructive
  confirm) deletes the project and its photo; its tasks and attempts stay.
* **Attempts** in the battle log show the project they were recorded for
  (`LinkedProjectTag`; `recordAttempt` links to the active project). Labels
  only — linking attempts by hand stays an op (`setAttemptProject`).
* **Picture** (`_PictureCard` → `showProjectArtPicker`): **Your photo** —
  "Choose a photo" (system picker) / "Take a photo" (camera), asked only on
  that tap, "Photos stay on this phone." — then the nine **Painted scenes**,
  each with its name (Sunrise, Winding road, Compass hill, Stone steps, Ruins at
  dawn, Deep roots, Hill town, Sailing, Summit route), mapped by name onto the
  brand scenes (`SceneKind`) and lesson scenes (`LessonScene`) and painted
  static. The chosen tile has a thicker border and a tick, and is announced
  "selected". A photo is copied into the private `attachments/` folder
  (`AttachmentStore.importFile`; the picker's temporary copy is released either
  way) and becomes `ProjectArt.photo`. Refused camera/photos, no camera, a
  failed pick, a photo too large or not kept are said in the sheet with another
  way forward; nothing is shown as chosen then. With a photo on, the sheet warns
  that another choice deletes it; **Remove picture** asks first for a photo. A
  photo missing from the phone shows "Photo not found on this phone".
* The picture shows on the project page (banner), the Missions card, its tasks
  (round, 18 dp), its attempts, the finish sheet, the history and the
  Collection keepsake. Photos are read through the attachment store (never a
  path in the UI), decoded at the size shown, and shared between views of the
  same photo until the data is replaced.

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
| `lib/ui/missions/project_screen.dart` | `ProjectScreen` (title, picture, status, milestones, look back, finish) |
| `lib/ui/missions/project_card.dart` | `ProjectCard` (Missions) |
| `lib/ui/missions/project_finish.dart` | `showFinishProjectSheet`, `FinishProjectSheet` |
| `lib/ui/missions/project_history_screen.dart` | `ProjectHistoryScreen`, `PastProjectScreen`, `PastProjectsKeepsake` (Collection), `openProjectHistory`, `openPastProject`, `projectMonths` |
| `lib/ui/missions/project_art.dart` | `ProjectArtView`, `ProjectArtBanner`, `ProjectArtThumb`, `ProjectPhoto`, `ProjectTag`, `LinkedProjectTag`, `watchProject`, scene names, photo error copy |
| `lib/ui/missions/project_art_picker.dart` | `showProjectArtPicker`, `ProjectArtPicker` |
| `lib/ui/missions/project_link.dart` | `ProjectLinkSwitch` (quest sheet) |
| `lib/ui/missions/project_ops.dart` | `extension ProjectViewOps on AppState` (read-only): `compassProjectFinished`, `projectShownTitle`, `questsOfProject`, `attemptsOfProject`, `linkableProjectFor` |
| `lib/ui/missions/path_grid.dart` | `PathGrid` (responsive equal-height rows) |
| `lib/ui/missions/path_day_screen.dart` | `PathDayScreen` |
| `lib/ui/missions/missions_copy.dart` | status / stage labels and icons |
| `l10n_src/missions_en.arb` | strings (`missions…`) |
| `l10n_src/projects_en.arb` | project history, picture and link strings (`projects…`) |

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

`test/ui/projects_test.dart` (95): look-ups (a finished name starts no draft,
linked quests/attempts, the project a sheet offers, scenes map by name); finish
— look back exactly as typed, archived with milestones and links, saved, the
Finished card, history newest first, the next project under its own name (a
milestone first keeps the title empty), the Compass offer; notes typed a moment
ago reach the sheet, a cancelled sheet keeps its words as the notes; a failed
save never says "kept" (Retry saves it); nothing to finish without a project;
history — order, months, labels, look back as typed, the photo; a past project
in full (Done / Open words, tasks, attempts) and removing it (tasks and attempts
stay; a photo is deleted); empty state; the Collection keepsake (and none before
a project is finished); links — quest tags with the picture and "Project: …",
a new quest linked by default or not, link/unlink from the sheet (a finished
project says so), no switch without a project, attempts labelled (a new one
too), the Missions card's "Plan your next project."; picture — the nine scenes
with names, chosen from the draft (title from the Compass), screen-reader label,
the painter drawn, selected semantics, a brand scene; a photo picked, copied,
released and saved; refused camera / no camera / refused photos; too large and
not kept (nothing stored, temp copy released); cancelled; photo replaced by a
scene then a photo removed after a question (files deleted); missing photo said;
failed save said; sheets slide only while motion is on; restore — a v2 backup
keeps the history, its scene and photo file, links and the current project, and
the history shows it; copy never judges; sizes 320 @ 200 % / 390 / tablet × dark
+ light for the project page, both sheets, history, a past project, the quest
sheet, Missions, the battle log and the Collection; accessibility (tap targets,
labels, contrast) for the page, both sheets, history and a past project in dark
and light.

Screenshots: `test/screenshots/compass_screenshots_test.dart` (tag
`screenshots`) → `test/screenshots/out/missions_0*_{dark,light}.png`;
`test/screenshots/projects_screenshots_test.dart` →
`test/screenshots/out/projects_*_{dark,light}.png` (project with a scene and with
a photo, the picture sheet, finishing, finished, history on a phone, a tablet and
at 200 %, a past project, Missions, the quest sheet, the battle log, the
Collection).

## Requirements satisfied

F-027 (add/edit/complete/reopen/delete), F-028 (≤ 3 lever drafts, no exact
duplicates, user may change them), F-029 (completion per local date, daily
recurrence, optional date), F-030 (status, milestones, retrospective, linked to the
Compass), F-031 (non-punitive), F-057 (30 days in four stages, autosaved, any day
open), F-054 (gentle, informational progress only).
