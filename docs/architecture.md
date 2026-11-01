# Architecture

Cartharise is one Flutter codebase for Android and iOS. Everything stays on the
phone: no account, no backend, no analytics, no network calls (the only outbound
action is opening the credited source links in the browser).

## Layers

```
lib/
  main.dart            bootstrap: edge-to-edge, time zone, AppState, runApp
  app.dart             CarthaApp: providers + MaterialApp (theme, l10n, motion)
  domain/              pure Dart contracts: content, AppData (+ JSON), dates, backup format
  content/             ContentLibrary per language (English) — prompts, lessons, 30-day path, credit
  data/data_store.dart DataStore: FileDataStore (atomic JSON file) · MemoryDataStore (tests)
  state/app_state.dart AppState — the single ChangeNotifier (PLAN.md §5)
  reminders/           reminder_plan.dart (pure planning) · reminder_scheduler.dart (notifications)
  services/            ics_export.dart (pure .ics) · file_share.dart (share sheet / file picker)
  l10n/                generated AppLocalizations (from l10n_src/ fragments)
  ui/                  theme/, widgets/, boot_screen, root_shell, nav + one folder per area
```

Dependencies point downwards only: `ui → state → (data, reminders, services) → domain`.
`domain/` and `reminders/reminder_plan.dart` and `services/ics_export.dart` have no
Flutter imports and are unit-tested directly.

## Data flow

```
widget ──calls──▶ AppState.saveAnswer(...)        (or an area extension built on mutate)
                    │ 1. _data = change(_data)    (immutable AppData snapshot)
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
  (`getApplicationSupportDirectory()`), not encrypted by Cartharise, not synced.
* The file uses the documented backup envelope
  (`{"app":"cartharise","format":1,"exportedAt":…,"data":{…}}`, see
  `domain/backup.dart`), so the saved file is itself a valid backup.
* Writes are atomic: `cartharise.json.tmp` is written and flushed, then renamed
  over the real file. A crash mid-write leaves the previous version intact.
* An unreadable or damaged file is never overwritten: `AppState.load()` sets
  `loadError`, `mutate` refuses to write, and the boot screen says honestly that
  nothing was deleted, with **Try again**. "Start fresh" renames the bad file
  to `cartharise.unreadable-<time>.json` (kept, not deleted) and starts empty.
* Export = `exportBackup()` shared through the system share sheet
  (`FileShare.shareTextFile`). Import = `FileShare.pickTextFile()` →
  `importBackup(text)`, which decodes and validates everything before touching
  state; a `FormatException` leaves current data untouched. Notification consent
  is per device, so an import keeps this device's `remindersEnabled`.
* `deleteAllData()` cancels every reminder, deletes the file and resets to
  `AppData.empty` (→ onboarding). If deletion fails it throws and nothing changes.

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
* `calendarExport()` builds a 30-day `.ics` (6 events, floating local time,
  `RRULE:FREQ=DAILY;COUNT=30`, 10 minutes, stable UIDs, CRLF, 75-octet folding).

## Loading sequence

1. **Native splash** (`flutter_native_splash`): forest `#1E3328` with the app
   icon (Android 12+ uses the system splash API with the same colours).
2. **BootScreen** (first Flutter frame): the same forest background, the animated
   `CarthaLoader` starting fully drawn (so the hand-off from the static splash is
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

Strings live in per-area fragments `l10n_src/<area>_en.arb` (area-prefixed keys).
`make l10n` runs `tool/merge_arb.dart` (common first, then alphabetical; fails on
invalid JSON or a duplicate key) and `flutter gen-l10n`. `lib/l10n/` is a build
output; `test/merge_arb_test.dart` fails if it is stale. Prompt and lesson text
is content (`ContentLibrary`), not ARB.
