# Compass (Life Compass)

The first half of the **Compass** tab: the user's direction in six short fields,
written by them, optionally started from their own evening answers, with a
version history. Requirements: F-022, F-023, F-024, F-025, F-026 (+ the §07
"reflection-to-action mapping" rules and the §11 test "Edit Compass without
overwriting custom text on later import").

## User flow

1. **Compass tab** → Cinzel header "Compass", `PillTabs` **Compass | Missions**.
   `AppNav.openCompass` / `openMissions` pick the section.
2. **My direction** hero (forest surface in both modes): the vision, or a short
   invitation when empty, plus "Last updated …" (local date + clock format).
3. **Start from the evening** — shown only when `compassImportPreview` is not
   empty (an evening answer #3–#7 exists for an *empty* field):
   "Use my evening reflections" opens the import sheet. Otherwise, with an empty
   Compass, a calm empty state links to the first evening prompt.
4. **Six field cards**: monochrome icon, title, one-line explanation, inline
   multiline field (autosave), Save indicator under the last edited card.
   | Field | Explanation |
   |---|---|
   | Anti-vision | What I refuse to let my life become. |
   | Vision | What I'm building toward. |
   | One-year mission | The outcome that would matter most a year from now. |
   | One-month project | One project for the next four weeks … (+ "Open month project") |
   | Daily levers | 2–3 actions, one per line. (+ "Turn into quests" when drafts exist) |
   | Boundaries | What I won't sacrifice. + "Written only by you" — never filled from answers |
5. **Versions** card: "Save a version" (snackbar "Version saved") and
   "Versions (n)" → list (date + reason: *Saved by you*, *Before an import*,
   *Before a restore*) → read-only version with a per-field "Same as now" /
   "Differs from now" comparison → **Restore this version** → confirm dialog →
   restored, the current Compass kept as a *Before a restore* version.

### Import sheet — `showCompassImport(context)` (also used by Reset)

* One row per mappable field (evening #3 → anti-vision, #4 → vision, #5 →
  one-year mission, #6 → one-month project, #7 → daily levers), in prompt order,
  with "From: <prompt title>" and the **answer quoted exactly** (no trimming).
* Checkbox per row, **checked by default only when the field is empty** and an
  answer exists. A field that already has text shows "Keeps your current text"
  and is disabled; an unanswered prompt shows "No evening answer yet".
* Boundaries are never listed; the sheet says so. It also says a version is
  saved first.
* "Fill n fields" → `importCompassFromEvening(selected)` → sheet closes →
  snackbar "n Compass fields filled from your evening answers." "Not now"
  changes nothing and shows nothing. Nothing is ever silent.

## Behaviour rules

* **User words are sacred**: fields save exactly what is typed (no trim). The
  Compass changes only by typing, by the explicit import into empty fields, by an
  explicit restore, or by the user tapping "Update Compass" on the project screen.
* **Autosave** (`lib/ui/compass/autosave.dart`): 600 ms debounce; also on focus
  loss, on switching section, before opening the import sheet / versions /
  project, when the app leaves the foreground, and on dispose (deferred to a
  microtask so no listener fires while the tree unmounts).
* **Outside changes** (import, restore) reach the on-screen fields
  (`BoundText.sync`) unless the user has typed text still waiting to be saved —
  typed text always wins. Pending text is saved before the import sheet reads the
  Compass, so text being typed counts as the field's own text.
* **Shell sync**: inside the shell the tab follows
  `ShellController.compassSection` and writes the visible section back to it
  (instead of resetting it to null — see "Notes"). Pushed without a shell it
  starts at `initial` and shows a back button.

## Edge cases

* No evening answers: the import sheet explains how to get some; the confirm
  button is disabled.
* All mappable fields already written: no import offer at all.
* Very long answers/versions: everything wraps and scrolls; list summaries clamp
  to two lines.
* Save failure: the shared `SaveIndicator` shows the honest failure with Retry and
  "Export a copy".

## Code map

| File | What |
|---|---|
| `lib/ui/compass/compass_tab.dart` | `CompassSection`, `CompassTab({initial})`, pills, shell sync |
| `lib/ui/compass/compass_view.dart` | hero, import offer / empty state, six cards, versions card |
| `lib/ui/compass/compass_field_card.dart` | one field card |
| `lib/ui/compass/compass_import.dart` | `showCompassImport`, `CompassImportSheet` |
| `lib/ui/compass/compass_versions.dart` | `CompassVersionsScreen`, `CompassVersionScreen`, `saveCompassVersionWithFeedback` |
| `lib/ui/compass/autosave.dart` | `Autosaver`, `BoundText`, `AutosaveTextField` (shared with Missions) |
| `lib/ui/compass/compass_copy.dart` | field titles/explanations/hints/icons, version reasons |
| `lib/ui/compass/formatting.dart` | locale-aware day / date-time formatting |
| `l10n_src/compass_en.arb` | strings (`compass…`) |

## Tests

`test/ui/compass_test.dart` (22): six explained cards + boundaries copy (dark,
light); autosave exact text after the debounce, persisted; switching section saves
at once; levers → Missions link, month project link; empty state → evening
prompt; import quotes answers exactly, defaults/keeps/disabled rows, boundaries
never offered, unticking, count snackbar, beforeImport snapshot, cards updated;
typed-but-unsaved text is kept by the import; "Not now" changes nothing;
`showCompassImport` from any screen; honest "nothing to import"; save → view →
restore with confirm (beforeRestore snapshot, field updated); cancelled restore;
versions empty state; `openMissions` + pill/shell sync; pushed tab with `initial`;
size matrix (320×568 @2.0, 390×844, 1024×1366 @1.3) × dark/light over the
Compass, the import sheet, the versions list and a version.

Screenshots: `test/screenshots/compass_screenshots_test.dart` (tag
`screenshots`) → `test/screenshots/out/compass_0*_{dark,light}.png`.

## Requirements satisfied

F-022 (hand-off sheet usable from Reset, never silent), F-023 (six fields, each
saved separately), F-024 (opt-in import of evening #3–7 into empty fields only,
exact text, no inference), F-025 (boundaries explained, never auto-filled),
F-026 (timestamped versions, read-only view, compare with current, restore with
consent), F-055 (honest save status).

## Notes

* `ShellController.compassSection` is kept equal to the visible section rather
  than reset to null, because `test/ui/shell_test.dart` expects the value to stay
  `missions` after `AppNav.openMissions`; syncing it on pill taps keeps later
  requests audible.
* "Last updated" is shown for the Compass as a whole: `LifeCompass` stores one
  `updatedAt`, not one per field.
