# Cartharise — build plan & contracts

Cartharise is a native Android + iOS app (Flutter) that makes Dan Koe's article
*How to fix your entire life in 1 day* easy to understand and act on: seven plain-language
lessons, a guided one-question-at-a-time reset (14 morning · 6 daytime · 3 bonus · 7 evening),
a six-part Life Compass, gentle daily quests, a 30-day path, a journal and weekly reviews.

**Sources of truth (read them, they are in the repo root):**

| File | What it decides |
|---|---|
| `Cartharise_Requirements.html` | Product requirements v1.0. The JS arrays at the bottom (`modules`, `coverage`, `req` = F-001…F-057, `choices` = D-01…D-12) are the backlog. Sections 07 (interaction rules), 09 (quality bars), 11 (acceptance tests) are binding. |
| `Cartharise Brand and App System Board.png` | Visual target: dark forest surfaces, bronze emblem + accents, ivory text, Cinzel headlines, card-based screens, bottom nav, onboarding carousel, loading/charging emblem sequence. |
| `CARTHARISE_Brand_Guide.html` | Palette, type, usage rules (no weapons/camouflage, no gradients on the emblem, ivory for small text, progress never judges worth). Its embedded assets are already extracted to `assets/brand/`. |
| `../qarta` (sibling Flutter app) | **UI base to mirror**: role-token palette (`QartaPalette` → our `CarthaPalette`), `ThemeData` built from tokens, shared components, `test/ui_base_test.dart` guard, screen-size tests, l10n via ARB, Makefile, definition of done. Read `../qarta/lib/ui/theme/qarta_theme.dart`, `../qarta/lib/ui/widgets/brand.dart`, `../qarta/lib/ui/widgets/motion.dart`, `../qarta/lib/ui/root_shell.dart`, `../qarta/test/ui_base_test.dart`, `../qarta/test/ui/screen_sizes_test.dart`. Copy patterns, not Qarta-specific features. |

## 1. Decisions (defaults for the open questions D-01…D-12)

| # | Decision |
|---|---|
| Stack | Flutter 3.47 / Dart 3.13, `provider` ChangeNotifier, same lint set as qarta. Bundle id `app.cartharise.cartharise`. |
| D-01 | Native iOS + Android from day one (one Flutter codebase). |
| D-02 | Local-first, **no account, no backend, no network calls** except opening the source links in the browser. |
| D-03 | Paraphrase + credit. Never reproduce the article's wording. |
| D-04 | Both: opt-in local notifications for the six check-ins **and** a 30-day `.ics` export. |
| D-05 | No AI. |
| D-06 | Human-reviewed safeguards: skip/soften/pause everywhere + a "Support" page signposting professional help. |
| D-07 | Everything free, no monetisation code. |
| D-08 | User-directed: any 30-day card is open on any day. |
| D-09 | **No analytics at all** in this build. |
| D-11 | 18+ confirmation in onboarding. |
| D-12 | Trademark check is a launch task, not code. |

Launch language English; all UI strings through ARB (l10n-ready); prompt content via `ContentLibrary`.

## 2. Information architecture

Bottom nav (5 tabs, like the board): **Today · Reset · Compass · Journal · You**.
The nine requirement modules map into them; Mirror/Vision/Interrupt/Breakthrough are Reset subflows.

| Tab | Contains | Requirement modules |
|---|---|---|
| Today | Greeting, next best step, today's quests, vision + month project, reset progress, today's 30-day card, empty states | Today (F-036, F-037) |
| Reset | Awakening lessons strip → Morning (Mirror + Vision) · Daytime (Interrupt + bonus) · Evening (Breakthrough) → hand-off to Compass; past resets; start a new reset | Awakening, Mirror, Vision, Interrupt, Breakthrough |
| Compass | Segmented: **Compass** (6 fields, import from evening, versions) · **Missions** (quests, lever drafts, month project + milestones, 30-day path) | Life Compass, Becoming |
| Journal | Segmented: **Notes** (free journal) · **Reviews** (weekly) · **Look back** (compare Compass versions / past resets) | Evolution |
| You | Profile, Inspiration (credit), Reminders, Appearance, Your data (export/import/delete, storage transparency), Support & safety, About, replay welcome | Inspiration, Settings |

Onboarding is a separate entry flow shown while `AppState.needsOnboarding`.

## 3. Design system ("Carthage Dusk")

Mirror qarta's UI base exactly in structure: `lib/ui/theme/cartha_theme_spec.dart` (raw colours per
theme), `lib/ui/theme/cartha_theme.dart` (`CarthaColors` internal, `CarthaPalette extends
ThemeExtension` with role tokens, `CarthaTheme.build(AppTheme, Brightness)`), and a guard test
forbidding raw colours in `lib/ui/` outside `lib/ui/theme/`.

Brand colours: forest `#1E3328`, deep forest `#17261E`, olive `#4B5320`, sage `#A3AD8C`,
bronze `#B08D57`, light bronze `#D4B57B`, deep bronze `#9B7847`, ivory `#F1EBDD`, paper `#F7F4EC`,
cream `#FFFDF8`, green-grey `#687870`, mist `#B9C6B8`.

| Token (minimum set) | Dark (default look of the board) | Light |
|---|---|---|
| `background` | deep forest `#17261E` | paper `#F7F4EC` |
| `card` / `raised` / `raisedHigh` | forest `#1E3328` / `#24392D` / `#2B4235` | cream `#FFFDF8` / `#EFE9DB` / `#E7E0CF` |
| `border` / `borderStrong` | ≥3:1 vs card for strong | ≥3:1 vs card for strong |
| `textPrimary` / `textSecondary` | ivory / mist (≥4.5:1) | forest / `#4A5A50` (≥4.5:1) |
| `accent` (icons, links, selected) | light bronze `#D4B57B` | text-safe bronze (≈ `#7A5C30`, ≥4.5:1 on paper) |
| `primary` / `onPrimary` (main buttons) | bronze `#B08D57` / deep forest | forest `#1E3328` / ivory |
| `hero` / `onHero` / `onHeroMuted` | forest hero cards in **both** modes (board style) | same |
| `emblem` | bronze on dark, deep bronze on light | |
| `success`, `error`, `onError`, `warning`, status containers | AA-checked | AA-checked |
| `focus`, `selection`, `shadow`, `scrim` | | |

Themes: **Forest** (default) and **Olive** (olive heroes/accents), each light + dark, plus
System/Light/Dark. Contrast tested automatically: 4.5:1 text, 3:1 meaningful controls.

Type: **Cinzel** (`assets/fonts/Cinzel-400/600/700.ttf`, OFL) for display/headline styles, the
onboarding titles and section heroes only; **Inter** (bundled, OFL) for everything else, including
questions and body. Never set long text in Cinzel. Radii 20–24 (cards), 16 (small), pill buttons.
Mostly flat, thin borders, subtle shadows, monochrome icons tinted with tokens.

Usage rules (brand guide): no weapons, combat or camouflage imagery; no gradients on the emblem;
ivory (not bronze) for paragraphs on dark; progress is never a judgement of worth (no red
"missed", no streaks, no scores).

### Brand assets (already in `assets/brand/`)

| File | Use |
|---|---|
| `emblem.svg` | Geometric elephant head (512 viewBox, bronze stroke 14, round joins) — **source of the emblem paths** |
| `loader_reference.svg` | The animated "charging" emblem: stroke-draw (`dasharray 1500`, 3.4 s ease-in-out, opacity .3→1, holds 65–85 %) + a 4-point spark above the head pulsing scale .92→1.13. Reduced motion → static. **CSS animation does not play in flutter_svg: rebuild it as `CarthaLoader` (CustomPainter + `PathMetric.extractPath`) from these exact paths and timings.** |
| `wordmark_horizontal.svg`, `wordmark_stacked.svg` | Lockups (emblem + outlined CARTHARISE lettering) — render with `flutter_svg`, tinted per theme |
| `app_icon_1024.png` | Launcher icon source (forest bg, bronze emblem) and native splash image |
| `app_icon_forest/olive/light.png` | Alternate tiles (Appearance previews) |
| `splash_android_reference.png` | Splash composition target: forest bg, faint concentric circles, emblem, Cinzel CARTHARISE, bronze tracking-wide tagline, short bronze rule |
| `social_preview.png` | Store/marketing only |

Loading moments: native splash (static emblem on forest, `flutter_native_splash`) → Flutter
`BootScreen` showing `CarthaLoader` + wordmark while `AppState.load()` runs (seamless hand-off,
same background) → app. Reuse `CarthaLoader` (small) for any wait > 300 ms.

## 4. Architecture & file ownership

```
lib/
  main.dart / app.dart          bootstrap, theme, l10n, BootScreen → Onboarding | RootShell   [Foundation]
  domain/                       PURE DART contracts — content.dart, app_data.dart, local_date.dart, backup.dart
                                (written in phase 0; others may ADD members, never rename/remove)  [Phase 0]
  content/content.dart, en.dart ContentLibrary for English                                     [Content]
  data/data_store.dart          DataStore interface; FileDataStore (atomic tmp+rename JSON in app support dir); MemoryDataStore   [Foundation]
  state/app_state.dart          single ChangeNotifier, full API below                           [Foundation]
  reminders/                    reminder_plan.dart (pure: which notifications, quiet hours) + reminder_scheduler.dart (flutter_local_notifications, timezone)  [Foundation]
  services/ics_export.dart      pure Dart .ics builder (6 daily events × 30 days, floating local time)  [Foundation]
  services/file_share.dart      export via share sheet (share_plus), import via file_picker      [Foundation]
  ui/theme/                     palette, theme spec, theme swatch                               [Foundation]
  ui/widgets/                   shared components (list below)                                   [Foundation]
  ui/root_shell.dart, ui/nav.dart, ui/boot_screen.dart                                           [Foundation]
  ui/onboarding/, ui/today/, ui/widgets/scenes.dart                                              [Onboarding+Today agent]
  ui/reset/, ui/awakening/                                                                        [Reset agent]
  ui/compass/, ui/missions/                                                                       [Compass+Missions agent]
  ui/journal/, ui/you/                                                                            [Journal+You agent]
l10n_src/<area>_en.arb          per-area string fragments; tool/merge_arb.dart builds lib/l10n/app_en.arb  [each owner its own fragment]
test/support/                   pumpCartha(), fake content, fake scheduler, size matrix          [Foundation]
test/ui/<area>_test.dart        widget tests per area                                             [area owner]
```

**Rules for parallel work**
- Touch only files you own. If you need a new state operation, add it as an `extension` in your own
  folder built on `AppState.mutate(...)` — do not edit `app_state.dart` (report any bug you find in it).
- Strings: add keys only to your fragment `l10n_src/<area>_en.arb`, keys prefixed with the area
  (`today…`, `onboarding…`, `reset…`, `awakening…`, `compass…`, `missions…`, `journal…`, `you…`).
  Run `make l10n` (= `dart run tool/merge_arb.dart && flutter gen-l10n`). `lib/l10n/app_en.arb` and the
  generated Dart files are build outputs; on merge conflicts, regenerate them.
- Keep stub class names and constructor signatures listed in §6 — other areas navigate to them.

### Shared widgets (Foundation provides, everyone reuses)
`CarthaEmblem` (static painter, size, colour token), `CarthaLoader` (animated, honours device
reduce-motion and `settings.motion`), `CarthaWordmark` (horizontal/stacked), `PrimaryButton`,
`SecondaryButton`, `TextLinkButton`, `SectionCard`, `HeroCard` (forest hero surface),
`ProgressRing` (fraction + label, never a judgement), `PillTabs` (segmented), `EmptyState`,
`SaveIndicator` (reads `AppState.saveStatus`; failure shows message + Retry + "Export a copy"),
`confirmDialog` (destructive variant), `askText`, `CarthaPageMotion`, `ScreenHeader` (Cinzel title +
subtitle), `ChipTag`.

## 5. AppState API (Foundation implements all of it; features consume it)

```dart
class AppState extends ChangeNotifier {
  AppState({required DataStore store, required ContentLibrary content,
            required ReminderScheduler reminders, DateTime Function()? clock});
  bool get loaded;  Object? get loadError;            // storage unreadable → honest notice
  SaveStatus get saveStatus;                          // idle | saving | saved | failed  (F-055)
  Future<void> retrySave();
  Future<void> load();
  AppData get data;  ContentLibrary get content;  DateTime now();  String get today; // dateKey
  Future<void> mutate(AppData Function(AppData) change); // persist + notify; extension hook

  // Onboarding & profile
  bool get needsOnboarding;
  Future<void> completeOnboarding({String? displayName, required Pace pace, required bool adultConfirmed});
  Future<void> updateProfile({String? Function()? displayName, Pace? pace});
  Future<void> resetOnboarding();                        // replay welcome
  Future<void> updateSettings(AppSettings settings);

  // Awakening
  Future<void> markLessonRead(String lessonId);

  // Reset
  Journey get journey;                                   // current; created lazily on first write
  List<Journey> get pastJourneys;                        // read-only history (F-034)
  Future<void> startNewJourney();                        // keeps prior journeys
  ReflectionAnswer? answer(String promptId);
  Future<void> saveAnswer(String promptId, String body); // exact text, clears `skipped`
  Future<void> skipPrompt(String promptId);
  Future<void> setActivePrompt(String promptId);
  PhaseProgress progressFor(PromptPhase phase);          // answered, skipped, total
  double get coreProgress;                               // answered core / core total
  Prompt? get nextPrompt;                                // resume point (F-037)
  Future<void> completeJourney();

  // Compass
  LifeCompass get compass;
  Future<void> updateCompassField(CompassField field, String value);
  Map<CompassField, String> get compassImportPreview;    // evening #3–7 → only EMPTY fields (F-024)
  Future<int> importCompassFromEvening(Set<CompassField> fields); // snapshots first; never overwrites non-empty
  Future<void> saveCompassVersion();
  Future<void> restoreCompassVersion(CompassVersion v);  // snapshots current first

  // Missions
  List<Quest> questsFor(String day);                     // open + done-today, one-offs and dailies
  Future<Quest> addQuest(String title, {QuestRecurrence recurrence, String? dueDate, QuestSource source});
  Future<void> updateQuest(Quest quest);
  Future<void> setQuestDone(String id, bool done, {String? day});
  Future<void> deleteQuest(String id);
  List<String> get leverDrafts;                          // ≤3 lines from dailyLevers, bullets stripped, no exact dup titles (F-028)
  Future<int> addQuestsFromLevers(List<String> titles);
  Future<void> saveProject(MonthProject? project);
  Future<void> savePathAnswer(int day, String body);

  // Journal & reviews
  Future<JournalEntry> addJournalEntry({String? title, required String body});
  Future<void> updateJournalEntry(JournalEntry entry);
  Future<void> deleteJournalEntry(String id);
  Future<WeeklyReview> saveReview({String? id, required String weekStart, required String wins,
                                   required String friction, required String nextExperiment});
  Future<void> deleteReview(String id);

  // Reminders (F-016–F-018)
  List<ReminderPreference> get reminders;               // six, defaults from prompt.defaultTime
  Future<void> setReminder(ReminderPreference pref);
  Future<ReminderPermission> enableReminders();          // granted | denied | unavailable — never claims success on denial
  Future<void> disableReminders();
  String calendarExport();                               // .ics text

  // Data (F-040–F-043)
  String exportBackup();
  Future<void> importBackup(String text);                // validate fully first; FormatException leaves data untouched
  Future<void> deleteAllData();                          // file + reminders; returns to onboarding
  String get storageDescription;                         // honest: "on this device, not encrypted by Cartharise, not synced"
}
```

Autosave: text fields debounce ~600 ms then `saveAnswer`/`updateCompassField`/…; flush on
`dispose` and on `AppLifecycleState.paused` so switching apps never loses input.

## 6. Cross-area navigation contract (`lib/ui/nav.dart`, Foundation)

Foundation creates these classes as compiling stubs; the owning agent replaces the body and keeps
the name + constructor:

| Class (file) | Owner |
|---|---|
| `OnboardingFlow({VoidCallback? onDone})` (`ui/onboarding/onboarding_flow.dart`) | Onboarding+Today |
| `TodayTab()` (`ui/today/today_tab.dart`) | Onboarding+Today |
| `ResetTab()` (`ui/reset/reset_tab.dart`), `GuidedPromptScreen({required String promptId})` (`ui/reset/guided_prompt_screen.dart`), `ResetCompleteScreen()` (`ui/reset/reset_complete_screen.dart`) | Reset |
| `AwakeningScreen()` (`ui/awakening/awakening_screen.dart`), `LessonScreen({required String lessonId})` (`ui/awakening/lesson_screen.dart`) | Reset |
| `CompassTab({CompassSection initial})` (`ui/compass/compass_tab.dart`), `CompassImportSheet` via `showCompassImport(context)` (`ui/compass/compass_import.dart`) | Compass+Missions |
| `PathDayScreen({required int day})` (`ui/missions/path_day_screen.dart`), `ProjectScreen()` (`ui/missions/project_screen.dart`) | Compass+Missions |
| `JournalTab()` (`ui/journal/journal_tab.dart`), `JournalEntryScreen({String? entryId})`, `ReviewScreen({String? reviewId})` | Journal+You |
| `YouTab()` (`ui/you/you_tab.dart`), `InspirationScreen()` (`ui/you/inspiration_screen.dart`), `RemindersScreen()`, `DataScreen()`, `SupportScreen()` | Journal+You |

`nav.dart` exposes `AppNav.openPrompt(context, id)`, `openLesson`, `openAwakening`, `openCompass`,
`openMissions`, `openPathDay`, `openProject`, `openJournalEntry`, `openInspiration`, `openSupport`,
`openReminders`, `switchTab(context, AppTab)`.

## 7. Content spec (Content agent → `lib/content/en.dart`)

Read the source to understand it, then **write every user-facing sentence originally**: no sentence
or distinctive phrase copied (no run of 6+ consecutive words from the source), simpler reading level,
neutral and non-judgemental, no diagnosis, no "fix your life" promises. Fetch for understanding:
`https://letters.thedankoe.com/p/how-to-fix-your-entire-life-in-1` (newsletter, readable) — the X
article (`https://x.com/thedankoe/status/2010751592346030461`) may block automated readers.

| Block | Ids | Count | Group / mapping |
|---|---|---|---|
| Morning 01–04 | `morning.01`–`04` | 4 | `currentReality` — tolerated dissatisfaction, repeated complaints, intention-vs-behaviour gap, uncomfortable truth |
| Morning 05–08 | `morning.05`–`08` | 4 | `antiVision` — unchanged future at 5 y, 10 y, later life, similar trajectories around you (gentle framing + softer wording) |
| Morning 09–11 | `morning.09`–`11` | 3 | `identity` — restrictive roles, difficult fears, self-protection patterns (hypotheses, not diagnosis) |
| Morning 12–14 | `morning.12`–`14` | 3 | `vision` — positive 3-year ordinary weekday, flexible identity statement, one action this week |
| Daytime 01–06 | `daytime.01`–`06` | 6 | `interrupt`, `defaultTime` 11:00, 13:30, 15:15, 17:00, 19:30, 21:00 — avoidance, observed priorities, direction, neglected importance, identity-driven action, energy (alive vs flat) |
| Bonus 01–03 | `bonus.01`–`03` | 3 | `contemplation`, `core: false` — others' expectations, safety vs aliveness, smallest next-day expression of the desired self |
| Evening 01–02 | `evening.01`–`02` | 2 | `insight` — working theory of stuckness, limiting internal pattern |
| Evening 03–04 | `evening.03`–`04` | 2 | `direction` — one-sentence anti-vision (`mapsTo: antiVision`), one-sentence vision (`mapsTo: vision`) |
| Evening 05–07 | `evening.05`–`07` | 3 | `plan` — one-year outcome (`yearGoal`), one-month project (`monthProject`), 2–3 actions for tomorrow, one per line (`dailyLevers`) |

Constraints/boundaries are **never** mapped (F-025). Every prompt: title, question, context, help,
example (labelled "Example", neutral, not a model answer), `sourceReference`; anti-vision and identity
prompts also a `softerQuestion`.

Lessons: exactly **7**, the article's central ideas in plain language, each with summary,
explanation, example, nuance (framed as a lens/framework, not science or diagnosis; no personality
stages assigned to the user), related prompt ids, and a 3-option knowledge check.
Thirty-day path: **30** original prompts — Observe days 1–7, Experiment 8–15, Build 16–23, Adjust 24–30.
Credit: title, author, both URLs, date 23 December 2025, independence notice ("independent, not
affiliated with or endorsed by Dan Koe"), paraphrase notice.
Also write `docs/content-traceability.md`: source segment → prompt ids → Cartharise placement
(mirrors the requirements' §05 table) and a list of Cartharise additions (30-day path, reviews…).

## 8. Feature acceptance (per area; F-ids from the requirements)

- **Onboarding** (F-001–F-004, F-043 summary, D-11): promise + limits ("one day can create clarity; it
  can't guarantee a fixed life"), inspiration credit with links + independence, pace choice
  (one day / flexible — nothing is ever locked by time), optional name, 18+ confirm, privacy summary
  ("stays on this phone"), not-therapy note. Board-style carousel: Understand yourself → Reset your
  life → Choose a direction → Improve step by step, vector brand scenes (`ui/widgets/scenes.dart`:
  rising sun, winding path, compass star, steps — tokens only, no photos), skippable.
- **Today** (F-036, F-037, F-054): greeting (name optional), next best step derived from stored state
  only, today's quests with check/uncheck, vision & month project snippets, gentle progress
  ("Day n of 30" only if the user opened the path; reset progress ring), empty states for no compass /
  no quests / unfinished reset.
- **Reset & Awakening** (F-005–F-016, F-019–F-022, F-046, F-047): lessons list + lesson screen
  (explanation, example, nuance, knowledge check, "Try it" → prompt); phase hub with progress per
  phase; guided prompt screen = one question at a time: context, question (toggle softer wording),
  help sheet, labelled example, autosave field with `SaveIndicator`, Back / Skip / Next / Jump (list
  of prompts) / Pause; "This feels heavy" → soften, pause, or Support. Daytime list shows each
  check-in with its local time and answered state; bonus marked optional. End of evening →
  `ResetCompleteScreen` (calm, no "you fixed your life") → offer `showCompassImport`.
  Past resets view (read-only) + "Start a new reset" (confirm; keeps history).
- **Compass & Missions** (F-022–F-031, F-057): six field cards with explanations, inline edit +
  autosave; import sheet previews evening #3–7 into empty fields only, per-field checkboxes, never
  silent overwrite; constraints explained and never auto-filled; version list (save version, view,
  restore with confirm). Missions: today/all quests, add/edit/complete/reopen/delete, daily
  recurrence option, lever drafts → approve/edit → quests; no streaks/scores/guilt; month project
  (title linked to Compass, status, milestones, retrospective); 30-day path grid grouped by stage,
  any day open, autosaved answers.
- **Journal & You** (F-032–F-035, F-038, F-040–F-043, F-016–F-018, F-044, F-055): notes CRUD with
  timestamps and confirm-delete; weekly review (3 fields) create/view/edit/delete; look back (choose
  two Compass versions or past resets to compare, no scores). You: profile name/pace, Inspiration
  (title, author, two working links via url_launcher, independence + paraphrase notices, "what is
  source vs Cartharise addition"), Reminders (enable → permission; denied → explain + offer .ics;
  six editable times with source defaults shown; quiet hours; export .ics via share sheet),
  Appearance (theme, mode, motion), Your data (storage transparency, export JSON via share sheet,
  import with validation + confirm-replace, delete all with typed/explicit confirm), Support & safety
  (not therapy; if in crisis contact local emergency services or a crisis line; findahelpline.com
  link), About + replay welcome.

Cross-cutting: every screen fits 320 dp → tablet at 200 % text, edge-to-edge, scrolls instead of
fixed heights; semantic labels on icon buttons and checkboxes ("Mark 'Walk 20 minutes' done");
state not by colour alone; reduced motion honoured; no streak/score/"failed" copy anywhere;
journal text never in notifications or logs.

## 9. Definition of done (every agent)

1. Implement. 2. Tests in the same change (`test/ui/<area>_test.dart` widget tests through
`pumpCartha`, unit tests for logic; size matrix 320×568 @2.0 text, 390×844, 1024×1366 for each new
screen; dark + light). 3. `flutter analyze` clean and `flutter test` green — report real failures,
never skip/loosen a test. 4. Update `docs/` (the area's page in `docs/features/<area>.md`: user flow,
behaviour rules, edge cases, code map, tests, F-ids satisfied).

## 10. The swarm

| Phase | Agents | Isolation | Output |
|---|---|---|---|
| 0 Scaffold (done by lead) | — | — | Flutter project, assets, fonts, domain contracts, this plan, commit |
| 1 Foundation ‖ Content | 2 in parallel | shared tree, disjoint files | UI base, state, services, shell, stubs, tests ‖ full English content + traceability |
| 1b Gate | 1 | shared tree | analyze/test green, wire content, commit `phase-1` |
| 2 Features | 4 in parallel | git worktrees (own branch each) | Onboarding+Today ‖ Reset+Awakening ‖ Compass+Missions ‖ Journal+You |
| 3 Integrate | 1 | main tree | merge branches, regenerate l10n, analyze/test, debug APK, commit |
| 4 Audit → Fix | 1 → 1 | main tree | requirement/brand/a11y/safety findings → fixes, final green build |

iOS: Xcode is not installed on this machine, so iOS is configured (Info.plist, notifications,
display name, icons, splash) and kept compiling via Dart analysis/tests, but `flutter build ios`
must be run later on a Mac with Xcode.
