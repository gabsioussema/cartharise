# You: profile, credit, reminders, appearance, data, support

The You tab is a sectioned hub (the qarta settings pattern) with full-screen
detail pages. Nothing here talks to a server: the only outbound actions are
opening the credited article links and the helpline directory in the browser,
and the share sheet / file picker when the user asks for them.

## User flow

- **Hub (`YouTab`).** Cinzel title, then a forest **profile** hero card: the
  avatar (or the emblem), the optional name as its own **Edit name** button
  ("No name set"; it opens `askText`; a blank name clears it), the motto in
  quotes, and **Create / Edit your avatar** (see `persona.md`); then a **Pace** card (One day / Flexible, "nothing is ever locked by
  time"), and grouped rows:
  - *Credit*: **Inspiration**
  - *Settings*: **Reminders** (On/Off), **Appearance** (e.g. "Forest ·
    System"), **Your data**
  - *Care*: **Support & safety**
  - *About*: version, **Open-source licences** (`showLicensePage`, including
    the Inter and Cinzel SIL OFL 1.1 texts), **Replay the welcome** (confirm,
    then `resetOnboarding`; all writing stays).
- **Inspiration (F-002, F-038, F-039).** Hero with the title, author and
  publication date; **Read the article on X** (primary) and **Read the
  newsletter version** (secondary), each with the host it opens; the
  independence notice; the paraphrase notice; "From the source, or added by
  Cartharise?" as two labelled lists. It is two taps from any tab (You →
  Inspiration).
- **Reminders (F-016–F-018).** A **Check-in notifications** switch with the
  privacy note ("only the check-in's title, never your words"); six rows,
  one per daytime check-in, each with its prompt title, an on/off switch, its
  time (device 12/24-hour format, edited with the system time picker), the
  "Source default 13:30" hint and "Use 13:30" when changed; **Quiet hours**
  (From / Until, "Not set", a hint while only one is set, Clear); **Add to
  calendar (.ics)**.
- **Language** (first on Appearance, step 3). Four radio rows: **Same as
  phone** (with "Now: Français", what it gives on this phone), then
  **English**, **Français** and **العربية**, each name written in its own
  language whatever the language on screen (`languageEndonym`, never
  localised) and in its own script's font family, and read by screen
  readers in its own language (a `LocaleStringAttribute` on the name). A tap
  calls `AppState.setLanguage`: strings, content, direction (Arabic is right
  to left) and fonts switch at once, the same page stays open, and only
  `AppSettings.language` changes. One line under the rows says lessons and
  questions change too, and the user's own words stay as written.
- **Appearance.** Six theme swatches in even columns, each with its name,
  and one line under them on what the chosen name stands for
  (`themeLabel`, `themeMeaning`):
  - **Forest** (default): deep forest and bronze, the Cartharise original
  - **Olive**: the olive groves of the Punic countryside
  - **Oasis**: palm green and date gold; mint pill on dark, mint paper on light
  - **Tyrian Rose**: the rose dye of Tyre, Carthage's mother city; wine
    heroes, rose pill, plum-charcoal on dark, blush on light
  - **Alpine**: granite and snow of Hannibal's crossing; slate heroes,
    silver pill, graphite on dark, snow grey on light
  - **Obsidian**: volcanic black glass and gold; true black when dark (kind
    to OLED screens), black heroes and buttons on a warm white

  Then Light or dark (System / Light / Dark pills) and the Interface motion
  switch. Changes apply at once. Every theme passes the contrast tests
  (`test/color_system_test.dart`) and the avatar's disc-edge test.
- **Your data (F-040–F-043, F-055).** Where the data lives
  (`StorageTransparencyText`: only on this phone, private app folder, not
  encrypted by Cartharise, not synced, not in phone or cloud backups);
  **Export backup** with what it includes ("Includes your words and
  settings, plus 3 photos and 2 voice notes (4.2 MB)." or "…No photos or
  recordings yet."); **Choose a backup file** ("Takes a .zip backup, or an
  older .json one."); **Delete all data**. The save indicator sits on top
  (this is also the "Export a copy" target after a failed save).
- **Support & safety (F-047, D-06).** "Not therapy" hero; what to do when a
  question feels heavy (skip, softer wording, pause, talk to someone); "If
  you're in crisis": local emergency services or a crisis line, **Find a
  helpline** (https://findahelpline.com); ongoing professional support.

## Behaviour rules

- **Notifications are opt-in and honest.** Turning the switch on calls
  `enableReminders()`. Only `granted` turns it on. `denied` and
  `unavailable` leave it off and show a warning that says why, with "Add to
  your calendar instead" (and "Try again" after a denial). A scheduling
  failure while on (`reminderError`) is shown the same way.
- Times are stored as local `HH:MM` via `setReminder`; quiet hours via
  `updateSettings` (both bounds needed; `AppState` replans).
- **Calendar file:** `FileShare.shareTextFile('cartharise-checkins.ics',
  calendarExport(calendarTexts(l)), 'text/calendar')` — calendar name, event
  title and notes come from ARB (`youCalendar…`) — only the switched-on
  check-ins (the
  button is disabled with a hint when none are on). Shared / dismissed /
  unavailable outcomes and failures are reported, never claimed as success.
- **Export (backup v2, step 2):** `cartharise-backup-<yyyy-MM-dd>.zip`,
  `application/zip` — `data.json` (the documented JSON, `"format": 2`) plus
  `attachments/<file>` for every photo and recording, from
  `exportBackupArchive()` through `FileShare.shareBytesFile`. Files that
  couldn't be read are said ("…couldn't be read and aren't in it"); the data
  still names them. Before exporting, the card says what a backup includes:
  the words and settings, how many photos and voice notes the data names
  and the space their files take on this phone (`sizeOfFile` per named
  file, so leftovers and pending recordings don't count; KB / MB / GB in the
  device's number format). When those files are more than a backup can be
  restored from (`kMaxBackupBytes`, 256 MB), a warning says so plainly
  ("…too large to restore. Export saves your words only; remove some for a
  full backup."), and **no `.zip` is made**: `exportBackupArchive` measures
  the files first (nothing is read into memory) and also checks the finished
  zip, throwing `BackupTooLargeException`. Export then asks "Too large to
  restore — Export your words and settings only?" and on **Export words
  only** shares the v1 JSON (`cartharise-words-<date>.json`), said as
  "Words and settings shared. Photos and recordings aren't in it." It never
  says "Backup shared." for a file that could never come back (S2-M2).
- **Import:** `FileShare.pickFileBytes` → `previewRestore(bytes)` fully
  decodes and validates a v2 `.zip` or a v1 `.json` → on any problem show
  "This file couldn't be used", the plain reason (not JSON, not a Cartharise
  backup, unsupported version, damaged, too large, not text) and **"Your
  current data was not changed."**, with nothing written → otherwise ask
  "Replace everything on this phone with the backup from <date>?", adding
  how many photos or recordings it names are missing (neither in the backup
  nor on this phone; their entries are kept) → `restoreBackup` writes the
  files first (if that fails: "Its photos and recordings couldn't be saved on
  this phone." and nothing is replaced). Cancel at any point changes
  nothing. If the restored data
  then can't be written (`saveStatus == failed`), the snackbar says "The
  backup is open on screen, but it couldn't be saved on this phone yet…"
  instead of "Backup restored." (F-055); the save indicator offers Retry
  and Export a copy.
- **Delete all:** two destructive confirmations ("Delete all data?" then
  "This can't be undone") → `FileShare.clearTemporaryFiles()` (export copies
  in the private temp folder, ours and share_plus's, and the file picker's
  cached imports) and `MediaPicker.clearTemporaryFiles()` (photo picker
  copies) → `deleteAllData()` (data file, then the `attachments/` folder and
  with it the pinned memory, the held recordings and photos; also any
  unreadable data file and attachments folder set aside earlier —
  `cartharise.unreadable-*.json`, `attachments.unreadable-*` — so no copy of
  the user's words outlives it, S2-m5); `BootScreen` closes the pushed pages and shows
  onboarding. If deleting fails, the user is told the writing is still
  there; if only photos or recordings couldn't be removed, the data is
  still deleted and the user is told so (the next launch removes them); if
  only a temporary copy couldn't be removed, likewise ("Removing the app
  erases it").
- **No copies left behind:** every export's temp file is deleted when the
  share sheet returns (also when dismissed), and the picker's cached copy
  right after an import file is read (`SystemFileShare`).
- **No OS backups:** Android `allowBackup="false"` plus
  `res/xml/data_extraction_rules.xml` / `full_backup_content.xml` exclude
  everything (cloud backup and device transfer); on iOS `FileDataStore`
  marks the data folder `isExcludedFromBackup` after every write through
  the `app.cartharise/storage` channel (`AppDelegate.swift`,
  `lib/data/backup_exclusion.dart`). `test/privacy_test.dart` pins both.
- No analytics, no logging of user text, no network calls.

## Edge cases

- Permission asked again after a denial only when the user taps Try again.
- A 24-hour phone shows 13:30 everywhere (rows, defaults, quiet hours).
- A backup without `exportedAt` is described as "from an unknown date".
- A cancelled file picker does nothing; a picker error is shown honestly.
- The version string comes from `lib/ui/you/app_version.dart` (no
  package-info plugin); a test keeps it equal to `pubspec.yaml`.

## Code map

| File | What |
|---|---|
| `lib/ui/you/you_tab.dart` | `YouTab` (§6): profile, pace, hub rows, about, licences, replay |
| `lib/ui/you/inspiration_screen.dart` | `InspirationScreen` (§6) |
| `lib/ui/you/reminders_screen.dart` | `RemindersScreen` (§6) |
| `lib/ui/you/appearance_screen.dart` | `AppearanceScreen`, `LanguagePicker`, `languageEndonym`, `languageLabel`, `themeLabel`, `appearanceLabel` |
| `lib/ui/you/data_screen.dart` | `DataScreen` (§6) |
| `lib/ui/you/support_screen.dart` | `SupportScreen` (§6), `kHelplineDirectory` |
| `lib/ui/you/backup_preview.dart` | `previewBackup` (validate + date), `backupErrorMessage` |
| `lib/ui/you/font_licenses.dart` | `registerFontLicenses()` (Inter, Cinzel OFL) |
| `lib/ui/you/app_version.dart` | `kAppVersion`, `kAppBuild` |
| `l10n_src/you_en.arb` | all `you…` strings |

Shared helpers come from `lib/ui/journal/journal_kit.dart` (page list,
section label, local time formatting). Other areas reach these pages through
`AppNav.openInspiration`, `openReminders`, `openSupport` and `openData`.

## Tests

`test/ui/you_test.dart` (through `pumpCartha`):

- hub sections, pace, name edit and clear, replay the welcome (data kept),
  licences page, Inter/Cinzel licences registered, version equals pubspec;
- Inspiration in two taps from Today, credit fields and notices, both links
  launched with the exact URLs (mocked url_launcher channel), failed link
  shows the address;
- reminders: denied stays off with explanation and calendar alternative
  (valid .ics, six events), unavailable, granted schedules six and off
  cancels, six rows with source defaults, time edit through the picker and
  back to default, per-row switch, 24-hour format, quiet hours set/clear,
  calendar share;
- appearance: theme, mode, motion;
- data: honest storage text (incl. "not included in phone or cloud
  backups"), export shares valid JSON with the dated name, failed share
  reported, malformed / foreign / damaged imports rejected with data and
  store untouched, import confirm shows the backup date (cancel keeps,
  replace restores), a restore whose save fails is not called "restored"
  (Retry then saves it), cancelled picker, delete all with two confirms
  returns to onboarding with the store cleared, reminders cancelled and
  temporary export/import copies cleared (also right after an export), a
  copy that couldn't be removed is reported, failed delete reported;
  `previewBackup` and error-message unit tests;
- support: not therapy, heavy-question options, crisis text, helpline link;
- size matrix (320×568 @ 2.0, 390×844, 1024×1366 @ 1.3) × dark/light,
  visiting every page including the denied warning and the import error.

Backup v2 (step 2): `test/evolve2_contracts_test.dart` › "Your data screen
(v2)" (the zip carries the photo, an unreadable one is said, missing files
counted on restore, files that can't be written change nothing, delete all
removes the files and the picker copies, files left are said) and
`test/ui/media_test.dart` › "Your data (backup v2)" (what a backup includes,
no photos yet, the too-large warning, the zip round trip to another phone
with the recording playing after the restore, delete all removes photos and
recordings).

Language (step 3): `test/ui/french_ui_test.dart` › "language picker" (the
four rows in order, endonyms, Same as phone selected by default; choosing
Français re-words the same page, the nav and the content at once and saves
only the setting; the choice survives a restart; Same as phone follows a
French phone and an explicit choice wins over it; names spoken in their own
language; tap targets, labels and contrast in French; right to left in
Arabic at every size of the matrix) and › "French on every main screen"
(31 screens and the five-page welcome in French across the size matrix,
dark and light). `test/screenshots/french_screenshots_test.dart` renders
the picker in English, French and Arabic and the main screens in French
(`french_*`).

`test/screenshots/journal_you_screenshots_test.dart` renders the hub,
Inspiration, Reminders, Appearance, Your data and Support in dark and light
to `test/screenshots/out/you_*`; `media_screenshots_test.dart` renders Your
data with photos and voice notes (`media_09_data_*`).

## Requirements satisfied

F-002, F-038, F-039 (credit and independence, two taps away), F-004
(optional, editable name), F-003 (pace, nothing locked), F-016 (six editable
local times, defaults visible), F-017 (opt-in, denial handled, quiet hours),
F-018 (.ics alternative), F-040 (JSON export), F-041 (validated import,
confirm, untouched on failure), F-042 (explicit delete), F-043 (storage
transparency), F-044 (labelled controls, selection and state announced),
F-045 (320 dp at 200 %), F-047 / D-06 (support and safety), F-055 (save
failure → Export a copy).
