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

## Media: photos, voice notes, the pinned memory (step 2 › F)

Photos and voice recordings live on journal notes, experiments tried
(Collection › a try) and attempts (Battle log › an attempt), through one
widget, `AttachmentStrip`: thumbnails, voice notes, then **Add photo** ·
**Record**. Everything is saved as soon as it is added; files go to the
app's private `attachments/` folder (`AttachmentStore`), which is kept out
of phone and cloud backups like the data file. `AttachmentCountLine`
(media_kit) says what an entry holds in words ("2 photos and 1 voice note")
on note cards, battle-log attempts, Collection tries and a past project's
attempts.

### User flow

- **Add photo** asks *Take a photo* or *Choose from your photos* (the system
  picker or camera, only now; the Android photo picker needs no
  permission). The picked photo (max 2048 px, JPEG 85) is copied into the
  private folder and the picker's temporary copy is released whatever
  happens. On a new note with nothing typed yet, the first photo or
  recording creates the note (with whatever is in the fields).
- A thumbnail opens the photo **full screen** (pinch to zoom, "Added …"),
  with **Pin as memory** / **Unpin** and **Remove** (asks first; the file
  is deleted once the removal is saved). A photo whose file is gone shows
  "Missing" instead of failing.
- **Record** opens the recorder and starts at once: the microphone is asked
  for only then. While recording: a dot and the word **Recording** (never
  colour alone), the time, a calm level meter, **Stop and save** and
  **Discard** (asks first). Screen readers hear "Recording. Tap Stop and
  save when you're done." and "Voice note saved." **Stop** saves it
  immediately and closes. The sheet can't be swiped away; Back stops and
  keeps the recording.
- **Interrupted:** a call taking the microphone, or the app going to the
  background, stops the recording and keeps what was recorded right away;
  the sheet then says "Interrupted. The 0:12 recorded before it is saved."
  with a **Partial** tag, **Done** and **Record again** (adds a second
  voice note). The recording keeps `Attachment.interrupted`, so the
  **Partial** chip (scissors icon and the word) stays on its player in the
  note, the try, the attempt and the history (S2-m3).
- **Cut off by a crash:** a recording is held on disk from its first byte
  (a mark in `attachments/.held/`) until an entry names it. If the app is
  ended mid-recording with no pause or hide event, the next launch never
  cleans it up as an orphan: Today shows "A recording was cut off when the
  app closed. It may be incomplete." with **Keep in a new note** and
  **Discard** (asks first) — `AppState.recoveredMedia`, `keepRecovered`,
  `discardRecovered` (S2-m2).
- **A photo the camera handed back** (Android may close the app while the
  camera is open): asked for once at app level (`RootShell` →
  `recoverLostCameraPhoto`), copied into the private folder and held the
  same way, offered on Today as "A photo you took wasn't added yet." until
  the user keeps or discards it — across launches. It is never put on
  whichever note, try or attempt happens to open first (Android can't say
  what it was taken for, so a project-picture photo is offered here too)
  (S2-m4).
- **Playback:** play / pause, a slider and "0:03 / 0:47"; one recording at
  a time; leaving the page stops it. Moving the slider before playing only
  sets where Play starts (it never starts the sound itself).
- **Your own words for a recording:** **Type what you said** opens a text
  box; what is typed is saved exactly (spaces included) beside the
  recording; clearing it removes it. Never filled in by the app.
- **Today › Write · Record:** Write opens a new note as before; Record
  starts a voice note and keeps it in a new journal note (no title, empty
  body), with "Voice note saved in your Journal." and **Open**. Record
  again in the same sheet adds to the same note. Side by side; stacked
  when narrow or with large text.
- **Pinned memory:** select words in a note and tap **Pin** (in the
  selection menu, or the pin in the app bar) to pin exactly those words
  (the note is saved first; only the spaces around the selection are left
  out). Or pin a photo from full screen. One pinned memory at a time; it
  sits compact at the top of the Journal: the photo (opens full screen),
  the words with a bronze bar, "From a note · Nov 2, 2026" (or an
  experiment / an attempt), **Open where it's from** and **Unpin** (the
  entry is untouched). Deleting the entry or the photo removes the pin.
  Editing the entry so the pinned words are no longer in it (the note, an
  attempt, a try, a recording's typed words, or removing that recording)
  unpins the passage; a pinned photo stays pinned without them
  (`AppData.withPinChecked`, S2-m1).
- **Note cards** say what they hold ("2 photos and 1 voice note"); a note
  with no words reads "Voice note" or "Photo note".

### Honest failures

Every outcome is said inline (snackbars could hide behind a sheet), with
the practical alternative:

| What happened | What the user sees |
|---|---|
| Camera refused / no camera | why, and **Choose from your photos** |
| Photos refused / unavailable | why, and **Write instead** (focuses the text) |
| Microphone refused | "Microphone access is off…", **Write instead**, **Try again** |
| No microphone / encoder | why, **Write instead** (no Try again) |
| Storage full / copy failed | "Couldn't save it on this phone. Storage may be full. Nothing was added." |
| Photo over 50 MB | "That photo is over 50 MB. Choose a smaller one." |
| Nothing recorded (empty file) | "Nothing was recorded. Try again, or write instead." (never "saved") |
| The data save failed | "Added, but not saved on this phone yet." / "Removed, but not saved…" with **Retry** |
| The entry was deleted meanwhile | "This entry isn't here any more. Nothing was added." (the file is deleted) |
| A photo taken while Android closed the app | offered back once: **Add it here** / **Discard** |

Privacy: no file name, path or user text is logged; playback reads local
files only; the recorder writes straight into the private folder.

## Voice (step 3)

* **Dictate** under a note's body (review, then Insert at the cursor; **Record instead**
  keeps a voice note on the note) and under each weekly-review field ("Dictate: Wins").
* **Listen to my note**, once the note has words, reads its title and body aloud with
  the phone's voice, only on that tap; Stop reading anytime, and it stops when the note
  closes. Details and tests: [`voice.md`](voice.md).

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
| `lib/ui/media/attachment_strip.dart` | `AttachmentStrip(holder, entryId, {createWith, onWriteInstead})`: thumbnails, voice notes, Add photo · Record, inline notices |
| `lib/ui/media/recovered_media_card.dart` | `RecoveredMediaCard` (top of Today): recordings cut off by a crash and photos the camera handed back, Keep in a new note / Discard; `recoverLostCameraPhoto` (called once by `RootShell`) |
| `lib/ui/media/photo_tile.dart` | `AttachmentImage` (bytes from the store, decoded at display size, "Missing"), `PhotoTile` |
| `lib/ui/media/photo_viewer.dart` | `openPhotoViewer` / `PhotoViewerScreen`: full screen, pin, remove |
| `lib/ui/media/recorder_sheet.dart` | `showRecorderSheet(context, keep:)` → `RecorderOutcome`; `RecorderSheet` (states, interruptions, failures) |
| `lib/ui/media/voice_note_player.dart` | `VoiceNotePlayer`: play/pause, position, the user's own words, remove |
| `lib/ui/media/pinned_memory_card.dart` | `PinnedMemoryCard` (top of the Journal) |
| `lib/ui/media/media_kit.dart` | `showMediaSheet` (reduced motion), failure texts, `formatClock`, `spokenDuration`, `formatBytes`, `MediaNotice`, `announce` |
| `l10n_src/media_en.arb` | all `media…` strings |

Hooks elsewhere: `JournalEntryScreen` (strip, Pin), `JournalTab` (pinned
memory, note card summary), `ExperimentEntrySheet` and `AttemptSheet`
(strip only), `TodayTab` (Write · Record), `DataScreen` (what a backup
includes). The operations are the step 2.0 contracts: `AttachmentOps`
(`addAttachment`, `removeAttachment`, `setAttachmentTranscript`,
`pinMemory`, `unpinMemory`), `addJournalEntry(attachments:)`, the
`AttachmentStore`, `MediaPicker`, `VoiceRecorder` and `VoicePlayer`
services (faked in `test/support/fakes.dart`).

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

`test/ui/media_test.dart` (fake picker, recorder, player and in-memory
store): photos from library and camera, cancelled picker, new note created
by its first photo, camera / photos denied with their alternatives, full
storage and oversize photos (nothing added, picker copy released), a
failed save with Retry, full screen and remove (cancel / confirm, file
deleted; a failed removal keeps the file), "Missing", a photo the camera
handed back offered on Today (kept / discarded / again at the next launch);
recording (state, time, level meter, announcements, saved at once), a call
and the app going to the background (kept, labelled, Partial on the note
afterwards), the app ended mid-recording (offered on Today, kept as
Partial), Record again,
microphone denied / Try again, no microphone, nothing recorded, storage
full, Discard, Back, a failed save, reduced motion; playback (play, pause,
resume, position, seek, the end, leaving stops it, the slider before
playing), unplayable and missing recordings, the transcript stored exactly
and cleared, removing a voice note; photos and voice notes on an
experiment tried and an attempt; Today's Record (a new note, Open, Write
instead) and the note card; pinning selected words (app bar and selection
menu, unsaved words saved first, nothing selected), the card at the top of
the Journal (open, unpin), pinning a photo and losing the pin with it, a
pin from an attempt; the backup copy, the too-large warning and the
words-only export (never "shared" for a zip that couldn't be restored), the zip round
trip to another phone and playback after restore, "Delete all data";
size matrix × dark/light and a11y guidelines.

`test/screenshots/media_screenshots_test.dart` renders the note with media,
recording, interrupted, full screen, pinned passage and photo, Today's
capture row (regular and 320 dp @ 200 %), Your data, microphone denied,
the try sheet, the photo source sheet, what was kept from before on Today
(regular and 320 dp @ 200 %), a Partial voice note and the too-large backup
question to `test/screenshots/out/media_*`. The logic is unit-tested in
`test/evolve2_fixes_test.dart` (real files in a temporary folder).

## Requirements satisfied

F-032 (free-form journal with timestamps, CRUD), F-033 (weekly review,
3 fields, save/view/edit/delete), F-034 (earlier resets kept and readable),
F-035 (user-chosen comparisons, no scores), F-044 (labels, headers,
selection announced), F-045 (320 dp at 200 % text), F-055 (save indicator),
section 07 "no streak shame, no ratings", section 09 (journal text never in
notifications or logs).
