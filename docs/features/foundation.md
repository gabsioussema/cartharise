# Foundation: UI base, state, services, shell

What every feature area stands on. Mirrors the UI base of the sibling app
`../qarta` (role-token palette, ThemeData built from tokens, shared components,
guard and size tests) with the "Carthage Dusk" brand. Visual target:
`Cartharise Brand and App System Board.png`.

## Theme tokens (`lib/ui/theme/`)

`CarthaThemeSpec` holds the raw colours per theme (Forest, Olive) for both
brightnesses; `CarthaPalette` (a `ThemeExtension`) derives role tokens;
`CarthaTheme.build(AppTheme, Brightness)` builds the full `ThemeData`. Screens
read colours only through `CarthaPalette.of(context)` —
`test/ui_base_test.dart` fails on `Color(0x…)`, `Colors.*` (except
`transparent`), `CarthaColors` or `CarthaThemeSpec` anywhere in `lib/ui/`
outside `lib/ui/theme/`.

| Token | Forest dark (board) | Forest light | Use |
|---|---|---|---|
| `background` | `#17261E` deep forest | `#F7F4EC` paper | page |
| `card` / `raised` / `raisedHigh` | `#1E3328` / `#24392D` / `#2B4235` | `#FFFDF8` / `#EFE9DB` / `#E7E0CF` | surfaces |
| `border` / `borderStrong` | ivory 12 % / `#7F9285` | forest 10 % / `#6B7A70` | hairline / control outline (≥ 3:1) |
| `textPrimary` / `textSecondary` | `#F1EBDD` ivory / `#B9C6B8` mist | `#1E3328` / `#4A5A50` | text (≥ 4.5:1 on every surface) |
| `accent` / `onAccent` | `#D4B57B` light bronze / background | `#7A5C30` / card | icons, links, selection, focus |
| `primary` / `onPrimary` | `#B08D57` bronze / deep forest | `#1E3328` forest / ivory | main pill buttons |
| `hero` / `heroRaised` | `#1E3328` / `#24392D` | same (both modes) | hero cards, boot, onboarding |
| `onHero` / `onHeroMuted` / `heroAccent` / `heroBorder` | ivory / mist / light bronze / bronze 35 % | same | on hero surfaces |
| `emblem` | `#B08D57` | `#9B7847` | the brand mark |
| `success` / `error` / `warning` (+ `…Container`, `on…Container`, `onError`) | `#8FD19E` / `#F4A196` / `#E9C46A` | `#2E6B3F` / `#A3322A` / `#7A5200` | status (never alone: pair with text/icon) |
| `selection`, `focus`, `pressed`, `hovered`, `focused`, `shadow`, `scrim` | derived | derived | states |

Olive: olive heroes (`#3F4619`), olive-dark surfaces, sage accent on dark,
olive accent/buttons on light. `test/color_system_test.dart` checks every theme ×
brightness: 4.5:1 for all text roles on every surface (incl. hero and status
containers), 3:1 for control outlines, focus and the emblem.

Type: Inter (bundled) everywhere; Cinzel (bundled) only for `display*` and
`headline*` styles — short titles only. Radii 22 (cards), 24 (hero, sheets,
dialogs), 16 (inputs), pill buttons. Flat, thin borders.

## Shared widgets (`lib/ui/widgets/`, import `widgets.dart`)

| Widget | Notes |
|---|---|
| `CarthaEmblem(size, color)` | CustomPainter of the exact `emblem.svg` paths (stroke 14 round, trunk 13 square). Default colour `emblem`; use `heroAccent` on hero. |
| `CarthaLoader(size, tile, startAt)` | Animated "charging" emblem — see below. |
| `CarthaWordmark(layout, width, onHero)` | `horizontal` / `stacked` lockups and `lettering` (CARTHARISE + rule only) from the brand SVGs, re-tinted per theme (`BrandSvgColorMapper`), tagline in Inter. |
| `PrimaryButton` / `SecondaryButton` / `TextLinkButton` | pill filled / outlined / accent text; `icon`, `trailingIcon`, `expand`, `busy` (a small `CarthaLoader` — the brand loader, still with reduced motion or Settings › Motion off — and taps ignored). Labels wrap at large text. |
| `SectionCard` | card section with optional title/icon/trailing; tappable (announced as button). |
| `HeroCard` | forest hero surface in both modes; `eyebrow`, Cinzel `title`, `trailing`; text defaults to `onHero`. |
| `ProgressRing(value, label, onHero)` | calm progress, labelled "n percent"; never a judgement. |
| `PillTabs<T>` | segmented pills; selected = filled + bold + `selected` semantics; every segment ≥ 48 dp tall (Android tap-target guideline). |
| `EmptyState` | emblem/icon, title, body, optional action. |
| `SaveIndicator` | from `AppState.saveStatus`: "Saving…", "Saved on this device", or the failure with **Retry** and **Export a copy** (→ `AppNav.openData`). Live region; static (tests can settle). |
| `confirmDialog(destructive:)`, `askText` | dialogs (askText returns text as typed). |
| `CarthaPageMotion`, `motionEnabled(context)` | short fade/rise on page change; off with reduce-motion or Settings › Motion. |
| `ScreenHeader(title, subtitle)` | Cinzel title + Inter subtitle, header semantics. |
| `ChipTag(label, icon, tone)` | small non-interactive label. |
| `openExternalLink(context, uri)` | url_launcher (external app); honest snackbar with the address on failure. |
| `DestructiveButton` | outlined pill in the error colour for irreversible actions (Delete all data); always paired with a confirm. |
| `StorageTransparencyText` | where the data lives, from ARB (`storageTransparency`): only on this phone, private app folder, not encrypted by Cartharise, not synced, not in phone or cloud backups. Onboarding privacy page and You › Your data. |

## Loader spec (`CarthaLoader`)

A rebuild of `assets/brand/loader_reference.svg` (its CSS animation does not play
in flutter_svg):

* Paths: the emblem's four head lines + trunk. The SVG animates
  `stroke-dashoffset` 1500→0 with `stroke-dasharray: 1500`; the loader emulates
  that dash exactly: each path shows `extractPath(0, min(length, 1500 × draw))`
  (`LoaderFrame.drawnLength`, `kLoaderDashLength`).
* Cycle 3.4 s, each keyframe segment eased with CSS `ease-in-out`
  (`Curves.easeInOut`): dash progress 0 at 0–10 %, 1 at 65 % (opacity .3→1),
  held to 85 %, back to 0 by 100 % (opacity →.3). As the dash is far longer
  than the lines (≈ 63–293 units), every line draws at the same speed: the
  trunk is complete by ≈ 18 %, the whole emblem by ≈ 27 %, and it only
  retracts after ≈ 95.5 % — like the reference.
* Spark: the four-point star centred at (256, 123), scale .92→1.13 and opacity
  .25→1 between 45 and 70 %, held to 85 %, back by 100 %.
* `tile: true` paints the rounded hero tile (rx 110/512) like the app icon.
* Static full emblem + spark when `MediaQuery.disableAnimations` (device reduce
  motion) or `settings.motion == false`. Semantics label "Loading".
* `startAt: 0.7` starts fully drawn (boot hand-off from the static splash).
* In widget tests, use `pump(duration)` / `pumpFrames`, not `pumpAndSettle`,
  while a loader is on screen.

## State, data & services

See `docs/architecture.md`. AppState implements every member of PLAN.md §5 plus:
`settings`, `loading`, `saveError`, `reminderError`, `newId(prefix)`,
`questById`, `plannedReminders`, `reminderTaps`, `takeLaunchReminder()`,
`startFreshAfterLoadError()`. Types `SaveStatus`, `PhaseProgress`
(`answered`, `skipped`, `total`, `open`, `finished`, `fraction`) and
`ReminderPermission` are exported by `state/app_state.dart`.

Behaviour rules implemented and tested (`test/state_test.dart`): exact text;
journey created lazily; skip keeps words; `nextPrompt` resumes at the active
prompt then the next open core prompt (bonus excluded, wraps); past journeys kept
(an untouched current one is replaced); import preview = evening answers with
`mapsTo`, non-empty, into empty fields only, constraints never; import snapshots
`beforeImport`; versions newest first capped at 50; restore snapshots
`beforeRestore`; quests done per local date key (one-offs once, dailies per day);
lever drafts ≤ 3, bullets/numbers stripped, case-insensitive duplicates of quests
excluded; journal/reviews newest first; reminders default from prompts; denial
never enables; import validates fully first; delete cancels reminders.

`FileShare` (`Provider<FileShare>`): `shareTextFile(filename, content, mimeType)`
via share_plus (temp file in a private `share/` folder, deleted as soon as the
share sheet returns), `pickTextFile()` via file_picker (UTF-8 only, ≤ 20 MB,
null when cancelled; the picker's cached copy is cleared right after reading)
and `clearTemporaryFiles()` (our `share/`, share_plus's Android
`cache/share_plus/` copy and the picker cache), run by "Delete all data".

**Privacy: no OS backups.** `FileDataStore` keeps `cartharise.json` in the app
support folder. Android: `allowBackup="false"` and
`res/xml/data_extraction_rules.xml` / `full_backup_content.xml` exclude every
domain from cloud backup and device transfer. iOS: after every write
`FileDataStore.excludeFromBackup` (main.dart passes
`platformBackupExclusion()`, `lib/data/backup_exclusion.dart`) asks
`AppDelegate.swift` over the `app.cartharise/storage` channel to set
`isExcludedFromBackup` on the folder; a refusal doesn't fail the save and is
retried on the next write. `test/privacy_test.dart` pins all of it.

**Localized platform texts.** The `.ics` words (`CalendarTexts`, built by
`calendarTexts(l)` in the Reminders screen) and the Android notification
channel name/description (`AppState.localizeReminders`, called from `app.dart`
whenever localizations change) come from ARB, never hard-coded English.

## Shell & navigation

`BootScreen` → `OnboardingFlow` | `RootShell` (5 tabs, board icons: home, rising
sun, compass, open book, person; bronze when selected). `ShellController` is
provided above `MaterialApp`; `AppNav` helpers: `switchTab`, `tabWidget`,
`openPrompt`, `openResetComplete`, `openAwakening`, `openLesson`, `openCompass
(section:)`, `openMissions`, `openPathDay`, `openProject`, `openJournalEntry
(entryId:)`, `openReview(reviewId:)`, `openInspiration`, `openSupport`,
`openReminders`, `openData`. The Compass tab should listen to
`ShellController.compassSection` and reset it to null after switching.

## Tests

| File | Covers |
|---|---|
| `test/ui_base_test.dart` | guard (palette tokens only), ThemeData per theme × brightness, Cinzel/Inter split, pill primary, board colours |
| `test/color_system_test.dart` | contrast matrix, every theme × brightness |
| `test/domain_test.dart` | JSON round trip of a fully populated AppData; decodeBackup rejections; date helpers |
| `test/state_test.dart` | every AppState rule above, save failure → retry, import/delete |
| `test/reminder_test.dart` | planning, quiet hours (incl. midnight), DST-safe next occurrence |
| `test/ics_test.dart` | 6 events, COUNT=30, floating DTSTART, stable UIDs, CRLF, folding, escaping, no user text |
| `test/merge_arb_test.dart` | ARB merge order, duplicate/invalid failures, `app_en.arb` up to date |
| `test/ui/shell_test.dart` | boot loader → onboarding, onboarding → app, load error + Try again, 5 tabs & switching (dark + light), AppNav from pushed screens, notification tap, size matrix, SaveIndicator failure, localized notification channel, busy buttons (brand loader, still with reduced motion) |
| `test/ui/loader_test.dart` | keyframes, the SVG's 1500-unit dash per line (trunk first, full emblem by ≈ 27 %, retract after ≈ 95.5 %), emblem geometry, animating vs static (device / setting), lockups render |
| `test/ui/a11y_test.dart` | every main screen (+ onboarding), dark and light: `androidTapTargetGuideline`, `iOSTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`; keyboard-only Tab traversal of the guided prompt (field → Save & continue → Back → Skip → Jump → Pause → Feeling heavy?, Enter activates) |
| `test/privacy_test.dart` | Android manifest/backup rules, iOS backup-exclusion channel, `FileDataStore` exclusion after each write (failure keeps the save, retried), clear |
| `test/splash_test.dart` | the Android 12 splash icon keeps the whole emblem inside the system's circular mask (`assets/brand/splash_android12.png`) |
| `test/screenshots/foundation_screens_test.dart` | tagged `screenshots`: boot, load error, shell, UI-base gallery (Forest + Olive, dark + light) → `test/screenshots/out/` |

Test support (`test/support/`): `pumpCartha(tester, {data, home, size,
textScale, brightness, theme, now, content, readDelay, frames})` returns a
`CarthaHarness` (state, store, reminders, files, shell); `fakeContent` (14/6/3/7
prompts, 7 lessons, 30 days); `FakeReminderScheduler`, `FakeFileShare`;
`onboardedData()`; `kSizeMatrix`; `expectNoOverflow`; `pumpFrames`;
`captureScreenshot`.

## Requirements touched

F-016/F-017/F-018 (reminder plumbing, .ics), F-040–F-043 (export/import/delete/
storage description), F-044/F-045 (semantics, focus, size matrix), F-055 (honest
save failure), plus the loading/saving, interrupted-session and error states of
§07 and the privacy/accessibility bars of §09.
