# You: profile, credit, reminders, appearance, data, support

The You tab is a sectioned hub (the qarta settings pattern) with full-screen
detail pages. Nothing here talks to a server: the only outbound actions are
opening the credited article links and the helpline directory in the browser,
and the share sheet / file picker when the user asks for them.

## User flow

- **Hub (`YouTab`).** Cinzel title, then a forest **profile** hero card (the
  optional name, or "No name set"; tapping opens `askText`; a blank name
  clears it), a **Pace** card (One day / Flexible, "nothing is ever locked by
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
- **Appearance.** Theme swatches (Forest / Olive), Light or dark (System /
  Light / Dark pills), Interface motion switch. Changes apply at once.
- **Your data (F-040–F-043, F-055).** Where the data lives
  (`StorageTransparencyText`: only on this phone, private app folder, not
  encrypted by Cartharise, not synced, not in phone or cloud backups);
  **Export backup**; **Choose a backup file**; **Delete all data**. The save indicator sits on top (this is also
  the "Export a copy" target after a failed save).
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
- **Export:** `cartharise-backup-<yyyy-MM-dd>.json`, `application/json`, the
  documented format from `exportBackup()`.
- **Import:** pick → fully decode and validate (`previewBackup`) → on any
  problem show "This file couldn't be used", the plain reason (not JSON, not
  a Cartharise backup, unsupported version, damaged, too large, not text) and
  **"Your current data was not changed."**, with nothing written → otherwise
  ask "Replace everything on this phone with the backup from <date>?" →
  `importBackup`. Cancel at any point changes nothing. If the restored data
  then can't be written (`saveStatus == failed`), the snackbar says "The
  backup is open on screen, but it couldn't be saved on this phone yet…"
  instead of "Backup restored." (F-055); the save indicator offers Retry
  and Export a copy.
- **Delete all:** two destructive confirmations ("Delete all data?" then
  "This can't be undone") → `FileShare.clearTemporaryFiles()` (export copies
  in the private temp folder, ours and share_plus's, and the file picker's
  cached imports) → `deleteAllData()`; `BootScreen` closes the pushed pages
  and shows onboarding. If deleting fails, the user is told the writing is
  still there; if only a temporary copy couldn't be removed, the data is
  still deleted and the user is told so ("Removing the app erases it").
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
| `lib/ui/you/appearance_screen.dart` | `AppearanceScreen`, `themeLabel`, `appearanceLabel` |
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

`test/screenshots/journal_you_screenshots_test.dart` renders the hub,
Inspiration, Reminders, Appearance, Your data and Support in dark and light
to `test/screenshots/out/you_*`.

## Requirements satisfied

F-002, F-038, F-039 (credit and independence, two taps away), F-004
(optional, editable name), F-003 (pace, nothing locked), F-016 (six editable
local times, defaults visible), F-017 (opt-in, denial handled, quiet hours),
F-018 (.ics alternative), F-040 (JSON export), F-041 (validated import,
confirm, untouched on failure), F-042 (explicit delete), F-043 (storage
transparency), F-044 (labelled controls, selection and state announced),
F-045 (320 dp at 200 %), F-047 / D-06 (support and safety), F-055 (save
failure → Export a copy).
