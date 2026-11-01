# Journal: notes, weekly reviews, look back

The Journal tab ("Journal & Reflection" on the board) holds the user's own
writing beyond the guided reset. Three sections in `PillTabs`:
**Notes · Reviews · Look back**. Everything stays on the phone; journal text
never goes into notifications or logs.

## User flow

- **Notes (F-032).** A short intro, a **New note** pill button, then every
  note newest first: title (or the first non-empty line when there is no
  title), a one-line preview when there is a title, and the local date and
  time it was written. With no notes, a calm empty state invites a first note.
  Tapping a note opens **JournalEntryScreen**: an optional title, a body that
  grows as you write, the save indicator, and "Written …" / "Last edited …"
  timestamps. Delete lives in the app bar and always asks first.
- **Reviews (F-033).** An intro, then **Review this week** (or **Open this
  week's review** when one exists for the current week), then the reviews by
  week ("Week of Nov 2, 2026", wins preview). **ReviewScreen** opens a saved
  review read-only (Wins, Friction, Next experiment) with Edit and Delete; a
  new review opens for writing with the current week preselected (Monday
  start, local), "Change week" (date picker), three fields with gentle
  hints, the save indicator and **Save review**.
- **Look back (F-034, F-035).** *Compare your Compass*: the user picks two
  moments, each either a saved Compass version (date · "saved by you" /
  "before an import" / "before a restore") or "Your Compass now". Each
  Compass field filled in either moment is shown side by side (two columns
  from 520 dp wide, stacked with a divider on phones); identical fields say
  "Same in both". *Earlier resets* lists past resets (started, completed,
  number of written answers); **PastResetScreen** shows that reset's
  answers per phase exactly as written, skipped prompts marked "Skipped",
  "Not finished" when it was never completed, "n questions were left open."
  for untouched core prompts, and an optional "Show my current answers too"
  switch that adds the current reset's answer under each one. It is the one
  past-reset screen: Reset › Past resets opens it too.

## Behaviour rules

- **Words are saved exactly as typed** (no trimming of the body). A note's
  title is stored as typed, or as no title when it is blank.
- **Autosave:** text fields save about 600 ms after the last keystroke
  (`Autosaver` in `journal_kit.dart`), and immediately when the screen
  closes or the app goes to the background (`AppLifecycleListener`), so
  switching apps never loses words. `SaveIndicator` shows "Saving…",
  "Saved on this device" or the honest failure with Retry and "Export a copy".
- **No empty items.** A new note or review is created only once something is
  typed; opening and closing an empty editor saves nothing, and "Save
  review" on an empty new review just closes it.
- **One item per editor.** A second autosave while the first create is still
  running waits for it, so a fast typist never creates duplicates.
- **Editing keeps identity:** an edited note or review keeps its id and
  creation time; `editedAt` is stamped by `AppState`.
- **Delete is permanent and confirmed** with the destructive `confirmDialog`.
  Pending autosaves are cancelled first, so nothing is written back after
  a delete.
- **Look back never scores.** No percentages, ratings, streaks or labels;
  only the user's words, side by side. Reading changes nothing.
- Dates and times use the device locale and its 12/24-hour setting.

## Edge cases

- A note or review that no longer exists (deleted, or replaced by an import)
  opens a calm "isn't here any more" state.
- No saved Compass versions: Look back explains and links to Compass
  (`AppNav.openCompass`).
- Answers in an earlier reset to prompts no longer in the content are still
  shown under "Other answers".
- A reset with no written answers says so instead of an empty page.

## Code map

| File | What |
|---|---|
| `lib/ui/journal/journal_tab.dart` | `JournalTab` (§6), sections, note and review cards |
| `lib/ui/journal/journal_entry_screen.dart` | `JournalEntryScreen({String? entryId})` (§6) |
| `lib/ui/journal/review_screen.dart` | `ReviewScreen({String? reviewId})` (§6), view and edit modes |
| `lib/ui/journal/look_back.dart` | `LookBackSection`: Compass comparison and earlier-reset list |
| `lib/ui/journal/past_reset_screen.dart` | `PastResetScreen(journeyId)`, read-only answers |
| `lib/ui/journal/journal_kit.dart` | `AreaListView` (readable width, insets), `AreaSectionLabel`, local date/time formatting, `Autosaver`, look-ups extension on `AppState` (no new state operations) |
| `l10n_src/journal_en.arb` | all `journal…` strings |

Navigation into the area goes through `AppNav.openJournalEntry` and
`AppNav.openReview`; the area leaves it only through `AppNav.openCompass`.

## Tests

`test/ui/journal_test.dart` (through `pumpCartha`):

- note: empty state, create with debounced autosave (exact text,
  persisted), flush on close, newest-first list with headline and local
  time, edit keeps id and creation time and shows "Last edited", delete
  cancel/confirm, missing note;
- review: create for the current week, read-only view, delete with confirm,
  edit keeps id and creation time, empty review not saved, autosave of a new
  review;
- look back: version against now per field, "Same in both", no scores,
  empty state with Compass link, earlier reset read back exactly (special
  characters), "Skipped", optional compare with the current reset;
- `noteHeadline` unit test;
- size matrix (320×568 @ 2.0, 390×844, 1024×1366 @ 1.3) × dark/light,
  walking every Journal screen with `expectNoOverflow`.

`test/screenshots/journal_you_screenshots_test.dart` (tag `screenshots`)
renders the notes, reviews, look back, note, review (view and new) and
earlier reset screens in dark and light to `test/screenshots/out/journal_*`.

## Requirements satisfied

F-032 (free-form journal with timestamps, CRUD), F-033 (weekly review,
3 fields, save/view/edit/delete), F-034 (earlier resets kept and readable),
F-035 (user-chosen comparisons, no scores), F-044 (labels, headers,
selection announced), F-045 (320 dp at 200 % text), F-055 (save indicator),
section 07 "no streak shame, no ratings", section 09 (journal text never in
notifications or logs).
