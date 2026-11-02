# Architecture

Cartharise is one Flutter codebase for Android and iOS. Everything stays on the
phone: no account, no backend, no analytics, no network calls (the only outbound
action is opening the credited source links in the browser).

## Layers

```
lib/
  main.dart            bootstrap: edge-to-edge, time zone, AppState, runApp
  app.dart             CarthaApp: providers + MaterialApp (theme, l10n, locale, motion)
  app_locale.dart      Locale per AppLanguage (kAppLocales, localeFor, resolveAppLocale)
  domain/              pure Dart contracts: content (+ content_translation), AppData (+ JSON),
                       language (AppLanguage, resolveLanguage), dates, backup format
  content/             ContentLibrary per language: en.dart (source), fr.dart, ar.dart (English
                       per item until translated); contentFor(AppLanguage), coverageFor
  data/data_store.dart DataStore: FileDataStore (atomic JSON file) · MemoryDataStore (tests)
  state/app_state.dart AppState — the single ChangeNotifier (PLAN.md §5)
  reminders/           reminder_plan.dart (pure planning) · reminder_scheduler.dart (notifications)
  services/            ics_export.dart (pure .ics) · file_share.dart (share sheet / file picker)
                       attachment_store.dart (photos + recordings folder) · media_picker.dart
                       (image_picker) · voice_recorder.dart (record) · voice_player.dart (audioplayers)
                       dictation.dart · read_aloud.dart (step 3 interfaces, pure Dart; stubs)
  l10n/                generated AppLocalizations en · fr · ar (from l10n_src/ fragments)
  ui/                  theme/, widgets/, boot_screen, root_shell, nav + one folder per area
```

Dependencies point downwards only: `ui → state → (data, reminders, services) → domain`.
`domain/` and `reminders/reminder_plan.dart` and `services/ics_export.dart` have no
Flutter imports and are unit-tested directly.

## Data flow

```
widget ──calls──▶ AppState.saveAnswer(...)        (or an area extension built on mutate)
                    │ 1. _data = change(_data)    (immutable AppData snapshot; nothing
                    │                              derived is folded in)
                    │ 2. notifyListeners()        → widgets rebuild with the new words at once
                    │ 3. saveStatus = saving      → SaveIndicator
                    ▼
               DataStore.write(snapshot)          (serialised queue: writes never interleave)
                    ├─ ok    → saveStatus = saved
                    └─ error → saveStatus = failed; data stays in memory;
                               SaveIndicator offers Retry (retrySave) and "Export a copy"
```

* `AppState.mutate(change)` is the only write path; features that need a new
  operation add an `extension` on `AppState` in their own folder built on
  `mutate`, `data`, `now()` and `newId()`.
* Widgets read with `context.watch<AppState>()` / `context.select(...)`.
* The clock is injectable (`AppState(clock: ...)`); quests, reviews and the
  30-day path use local date keys (`yyyy-MM-dd`) so a time-zone change never
  moves a completion to another day.
* User words are stored exactly as typed (no trimming) for answers, Compass
  fields, journal notes, reviews and path notes. Names and quest titles are trimmed.

## Persistence

* One JSON file, `cartharise.json`, in the app's private support directory
  (`getApplicationSupportDirectory()`), not encrypted by Cartharise, not synced,
  and kept out of OS backups: Android `allowBackup="false"` + data-extraction
  rules excluding everything (cloud backup and device transfer); iOS marks the
  folder `isExcludedFromBackup` after every write (`backup_exclusion.dart` →
  `AppDelegate.swift`, channel `app.cartharise/storage`). Removing the app or
  "Delete all data" therefore really erases it; "Delete all data" also clears
  the temporary export/import copies (`FileShare.clearTemporaryFiles`).
* The file uses the documented backup envelope
  (`{"app":"cartharise","format":1,"exportedAt":…,"data":{…}}`, see
  `domain/backup.dart`), so the saved file is itself a valid backup.
* Writes are atomic: `cartharise.json.tmp` is written and flushed, then renamed
  over the real file. A crash mid-write leaves the previous version intact.
* An unreadable or damaged file is never overwritten: `AppState.load()` sets
  `loadError`, `mutate` refuses to write, and the boot screen says honestly that
  nothing was deleted, with **Try again**. "Start fresh" renames the bad file
  to `cartharise.unreadable-<time>.json` (kept, not deleted) and starts empty.
* Export = `exportBackupArchive()` (backup v2 `.zip`, see "Data (step 2)")
  shared through the system share sheet (`FileShare.shareBytesFile`). Import =
  `FileShare.pickFileBytes()` → `previewRestore(bytes)` (v2 `.zip` or v1 JSON)
  → `restoreBackup(preview)`; `importBackup(text)` still takes a v1 JSON. Both
  decode and validate everything before touching state; a `FormatException`
  leaves current data untouched. Notification consent is per device, so an
  import keeps this device's `remindersEnabled`.
* `deleteAllData()` cancels every reminder, deletes the file, then the
  `attachments/` folder, and resets to `AppData.empty` (→ onboarding). If the
  data file can't be deleted it throws and nothing changes; if only attachment
  files stay it returns false (said in the UI; the next load removes them).

## Data (step 2)

* **Schema 2** (`kSchemaVersion`): quest stages (`QuestStage`, lane per day
  via `Quest.laneOn`), project ids + `pastProjects` + `ProjectArt`,
  `Quest.projectId` / `BattleLogEntry.projectId`, attachments on notes,
  experiments tried and attempts, `pinnedMemory`. Version 1 files load with
  fallbacks; an older app refuses a version 2 file rather than dropping data.
* **Attachments folder.** Photos and recordings are files in
  `<app support>/attachments/` next to `cartharise.json` (`AttachmentStore`:
  `FileAttachmentStore` in the app, `MemoryAttachmentStore` in tests). The
  data names each by `Attachment.fileName`, a plain generated name (never a
  path, never the phone's original name). Kept out of OS backups like the
  data file (Android: the `file` domain is excluded; iOS: the folder is marked
  `isExcludedFromBackup` through the same channel). Imports and restores
  write through a temporary file + rename. Recordings are written straight
  into the folder (`newRecordingPath` → `adoptRecording`; an interrupted one
  is kept, an empty one is never claimed).
* **Files follow the data.** Deleting a note, a try, an attempt, an
  attachment or a project photo deletes its file once that change is saved
  (`releaseAttachments`; never a file the data still names). On every load
  the files the saved data doesn't name are removed (`deleteOrphans`; pending
  recordings are kept). An unreadable data file cleans nothing, and "Start
  fresh" sets the folder aside with the file (`attachments.unreadable-<time>`).
* **Backup v2** (`domain/backup.dart`, pure Dart, `archive`): a `.zip` with
  `data.json` (the JSON envelope, `"format": 2`) and `attachments/<fileName>`
  for each file the data names. Restore accepts the v2 `.zip` and the v1 JSON,
  validates everything before asking, ignores zip entries that aren't named
  attachments (no path can escape the folder), checks sizes and CRCs, and
  counts files the data names that are neither in the backup nor on the
  phone (kept on their entries, shown as missing — never dropped).
* **Media services** are injected like `FileShare` (providers in
  `CarthaApp`; fakes in `test/support/fakes.dart`). Permissions are asked by
  the system only when the user taps (Android declares only `RECORD_AUDIO`;
  photos come from the system picker / camera app). No network permission or
  package (`test/privacy_test.dart` pins the allow-lists).

## Reminders

* Opt-in only. `enableReminders()` asks the OS for permission and returns
  `granted | denied | unavailable`; reminders are switched on **only** on
  `granted`. On denial the UI explains and offers the `.ics` export.
* `reminders` = the six daytime check-ins in prompt order, each either saved by
  the user or defaulting to the prompt's `defaultTime` (source times 11:00,
  13:30, 15:15, 17:00, 19:30, 21:00).
* `planReminders(...)` (pure) turns preferences + quiet hours into
  `PlannedReminder`s; a check-in inside quiet hours is skipped; quiet ranges may
  cross midnight (22:00–07:00).
* `LocalReminderScheduler` schedules each as a daily repeating
  `zonedSchedule` at local wall-clock time (`timezone` + `flutter_timezone`,
  next occurrence built from calendar fields so DST never shifts it), with
  **inexact** Android alarms (no exact-alarm permission). The notification shows
  the prompt title only — never the user's words; tapping it opens that prompt.
* AppState re-plans after any reminder/quiet-hour/enable change, after an import,
  and on every launch (the time zone may have changed).
* `calendarExport(texts)` builds a 30-day `.ics` (localized `CalendarTexts`, 6 events, floating local time,
  `RRULE:FREQ=DAILY;COUNT=30`, 10 minutes, stable UIDs, CRLF, 75-octet folding).

## Loading sequence

1. **Native splash** (`flutter_native_splash`): forest `#1E3328` with the app
   icon (Android 12+ uses the system splash API with the same colours).
2. **BootScreen** (first Flutter frame): the same forest background, the animated
   `CarthaLoader` starting fully charged (so the hand-off from the static splash is
   seamless), the CARTHARISE lettering, the tagline and "Preparing your space…".
   `AppState.load()` runs after this first frame.
3. **Then** (cross-fade, instant with reduced motion): `OnboardingFlow` while
   `needsOnboarding`, else `RootShell`. If loading failed: the honest error view.
   Returning to onboarding later (replay welcome / delete all data) closes any
   pushed screens.

## Navigation

`RootShell` holds the five tabs (Today · Reset · Compass · Journal · You) in an
`IndexedStack` so half-typed text survives tab switches. `ShellController`
(provided above `MaterialApp`) owns the selected tab; `AppNav` (lib/ui/nav.dart)
pushes detail screens on the root navigator and switches tabs from anywhere
(`AppNav.switchTab`, `openCompass(section:)`, `openMissions`, …).

## Localisation

Strings live in per-area fragments `l10n_src/<area>_<lang>.arb` (area-prefixed
keys; English is the source, French and Arabic translate it).
`make l10n` runs `tool/merge_arb.dart` (common first, then alphabetical; fails on
invalid JSON or a duplicate key; every English key in every language, falling
back to English and reported; a translation's placeholders, plurals and selects
must match English) and `flutter gen-l10n`. `lib/l10n/` is a build output;
`test/merge_arb_test.dart` fails if it is stale. Prompt and lesson text is
content (`ContentLibrary`), not ARB. Details, the coverage report and how to
add a language: [translations.md](translations.md).

## Languages and voice (step 3)

* **One resolved language.** `AppSettings.language` (`system | en | fr | ar`)
  → `AppState.language` (`resolveLanguage`: the setting, or for system the
  phone's first preferred language Cartharise ships, else English; never
  `system`). The phone's languages come from `main.dart` and, live, from
  `didChangeLocales` → `AppState.setDeviceLanguages`. `MaterialApp.locale`,
  `AppState.content` (`contentFor`), the text direction (Arabic right to left
  through the global localisations) and `CarthaFonts` all follow it, so strings
  and content can never disagree.
* **Content per language** (`lib/content/{en,fr,ar}.dart`): a
  `ContentTranslation` keyed by permanent id laid over English
  (`translateContent`); structure is always English, a missing or incomplete
  item stays English whole. Switching language changes only the setting (and
  re-words the check-in notifications); user data is keyed by ids.
* **Fonts per language** (`CarthaFonts`, a theme extension):
  Cinzel + Inter for Latin; one Arabic family for every style (never Cinzel)
  and no added letter spacing for Arabic. `CarthaFonts.arabicFamily` is the
  bundled Noto Sans Arabic UI (OFL, Latin-compatible line height), with Inter
  as the fallback for Latin inside Arabic (`CarthaFonts.fallback`) and no
  fake italic (`CarthaFonts.italic`). Themes built inside a screen
  (`OnHeroTheme`) pass the ambient fonts on.
* **Arabic and right to left** (`docs/translations.md` › Arabic): every
  string and content item (draft, native review pending), Western digits
  everywhere (`useWesternDigits`), mirrored arrows and route map, the user's
  own words in their own direction (`textDirectionOf`,
  `lib/ui/widgets/bidi.dart`). Tests: `test/ui/rtl_test.dart`.
* **Voice interfaces** (`lib/services/dictation.dart`, `read_aloud.dart`, pure
  Dart, provided like the media services; fakes `FakeDictation`,
  `FakeReadAloud` in `test/support/fakes.dart`). `Dictation` is on-device only
  (never a network recognizer, never a silent fallback): `availability(tag)`,
  `start(tag)` → `Stream<DictationEvent>` (partial, final, level, error with a
  typed reason, ended), `stop()`, `cancel()`; text is shown for review before
  it is inserted. `ReadAloud` speaks only on a tap: `available(tag)`,
  `speak(text, languageTag:)`, `stop()`, `speaking`. The app wires
  `PlatformDictation` (`dictation_platform.dart`: a method + event channel to
  Android's `createOnDeviceSpeechRecognizer` and iOS's
  `requiresOnDeviceRecognition`; **Dictate** in `lib/ui/voice/`, see
  `docs/features/voice.md`) and `PlatformReadAloud` (`read_aloud_platform.dart`:
  a method channel to Android's `TextToSpeech` with offline voices only and iOS's
  `AVSpeechSynthesizer`; **Listen** in `lib/ui/voice/listen_button.dart`).
* Contract tests: `test/evolve3_contracts_test.dart`.

## Tests

* Unit tests for the domain, state, reminders and `.ics` (`test/*_test.dart`).
* One widget-test file per area (`test/ui/<area>_test.dart`), each with the size
  matrix (320×568 @200 %, 390×844, 1024×1366 @130 %) in dark and light.
* `test/ui/journeys_test.dart`: the requirements' §11 acceptance journeys, end
  to end through the real app and the real English content: first launch →
  onboarding → reset (14 morning answers kept when going back, a daytime
  check-in that persists, 7 evening answers) → previewed Compass import, a
  later import that keeps edited text → levers to quests (complete, reopen,
  delete) → note and weekly review create/edit/delete → Inspiration link →
  `.ics` with 6 daily events → JSON export, delete all, restore. Edge cases:
  skip every prompt, malformed imports, 320 dp at 200 % text, a failed save
  leading to "Export a copy", and every `AppNav` route reaching its screen.
* `test/ui_base_test.dart` guards the palette rule; `make screenshots` renders
  every area's screens to `test/screenshots/out/` (git-ignored).
