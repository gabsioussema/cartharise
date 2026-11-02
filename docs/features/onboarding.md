# Onboarding (and the brand scenes)

The entry flow shown while `AppState.needsOnboarding` (first launch, "Replay
welcome", after "Delete all data"). Since the evolve plan (Step 1 › A) it is
**five short pages**; the four carousel pages are gone and features are
introduced on first use instead (one-line hints on Today, see
`docs/features/today.md` › First-use hints).
Requirements: F-001, F-002, F-003, F-004, F-043 (summary), D-11 (18+).

## User flow

| # | Page (`OnboardingStep`) | Surface | What it shows |
|---|---|---|---|
| 1 | `brand` | forest hero | Emblem, CARTHARISE lettering + rule (`CarthaWordmark.lettering`), tagline "Master Yourself. Rise With Purpose." in Cinzel, short bronze rule, the one-line promise "One honest day of reflection. Then small steps.", `DawnRuinsScene` fading into the page. **Begin →**; a left swipe does the same. |
| 2 | `limits` | page background | "Before you start" · "A few honest words." **Inspired by** card: “How to fix your entire life in 1 day”, "by Dan Koe · 23 December 2025", **Read the original article** and **Read it in the author's newsletter** (open in the browser via `openExternalLink`), the independence notice from `content.credit`, "No need to read it first." Then the limits: one day can bring clarity · it won't fix your life overnight · not therapy (no diagnosis; points to You › Support) · you stay in control (skip, soften or pause any question). **I'm 18 or older** checkbox — required. |
| 3 | `pace` | page background | **One day** / **Flexible** (default; the same names as in You and Reset) as a radio pair; "Nothing locks or expires." |
| 4 | `name` | page background | "What should we call you?" — optional, stays on the phone, max 40 characters; empty = "Traveler". |
| 5 | `privacy` | page background | "Your words stay yours": "Where your writing lives" = `StorageTransparencyText` (only on this phone, private app folder, not encrypted by Cartharise, not synced, not in phone or cloud backups — Android manifest + iOS backup exclusion make that true), no account/ads/analytics, export/delete in You › Your data. **Start**. |

Pages 2–5 show "Step n of 5" and a Back button.

Start → `AppState.completeOnboarding(displayName, pace, adultConfirmed: true,
askAboutGame: true)` → `BootScreen` swaps to `RootShell` (Today) → `onDone`
(if given).

## The Campaign for new users

`askAboutGame: true` makes a **brand-new** profile start with
`settings.game: false, gameInvited: false`: the Campaign is off and Today
shows its one-time invitation (`CampaignInviteCard`) below the next action
until it is answered (Play / Not now, Campaign area). A **replayed** welcome
(the profile already exists) keeps the user's Campaign settings as they are.

## Behaviour rules

- **Back works everywhere and keeps every choice**: the top-left back button
  on pages 2–5 and the system back (a `PopScope` turns it into "previous
  page"; on the brand page it leaves the app as usual). The 18+ tick, pace and
  typed name live in the flow's state, so going back and forth never loses
  them.
- **18+ gate**: on page 2, Next is disabled until the box is ticked, and the
  reason is shown in words ("Confirm you're 18 or older to continue.", a live
  region), not by the disabled colour alone. Swiping can't pass it either
  (only the brand page swipes). Start is guarded the same way. There is no
  Skip: nothing comes before the gate except the brand page.
- **Name**: optional; saved trimmed (empty → no name). Never logged; no
  autocorrect/suggestions on the field.
- **Pace**: stored on the profile. Nothing in the app is locked by time
  (D-08); the copy says so.
- **Replay welcome**: the flow starts from the saved name, pace and 18+ answer.
- **Links** are the only outbound action; if a link can't open, a snackbar
  shows the address so the user can open it themselves.
- **Surfaces**: the brand page uses the forest hero in both brightnesses
  (`OnHeroTheme` gives it the dark theme: bronze pill, ivory text; light
  status-bar icons). The other pages use the normal theme so longer text
  reads well in light mode.
- **Motion**: page changes use `CarthaPageMotion`; the scene rises once
  (~1.6 s) when shown. With reduced motion (device) or Settings › Motion off,
  pages switch instantly and the scene is painted finished.
- **Sizes**: every page scrolls; content is centred at ≤ 600 dp on tablets;
  the action bar pads for the system navigation inset.

## Brand scenes (`lib/ui/widgets/scenes.dart`, exported for every area)

`SunriseScene`, `PathScene`, `CompassScene`, `StepsScene`, `DawnRuinsScene`
(each `{aspectRatio = 4/3, semanticLabel, animate}`; `aspectRatio: null` fills
the parent), all built on `BrandScene(kind: SceneKind…)` and `ScenePainter`.
Onboarding now uses only `DawnRuinsScene` (brand page); Today uses it in a
compact 3:1 card. The other four stay available to every area (the visual
system owns `scenes.dart`).

- Vector `CustomPainter`s; colours derived only from palette tokens
  (`hero`, `heroRaised`, `heroAccent`, `onHero`, `onHeroMuted`, `shadow`) via
  `ScenePalette.of(CarthaPalette)`, so they follow the themes and look the
  same in light and dark (they always sit on hero surfaces).
- No photos, people, weapons or combat. Sky gradients are allowed; the emblem
  is never drawn with a gradient.
- Decorative (excluded from semantics) unless a `semanticLabel` is passed.
- `OnHeroTheme` (same file): wraps content on a hero surface with the dark
  variant of the current brand theme (used by onboarding and Today's hero).
- Test hooks: `brandSceneProgress(state)`, `isBrandSceneAnimating(state)`.

## Code map

| File | Role |
|---|---|
| `lib/ui/onboarding/onboarding_flow.dart` | `OnboardingFlow({VoidCallback? onDone})` and its private pages |
| `lib/ui/onboarding/onboarding_steps.dart` | `OnboardingStep` — five pages, positions, 18+ gate (pure Dart) |
| `lib/ui/widgets/scenes.dart` | Brand scenes, `ScenePalette`, `OnHeroTheme` |
| `l10n_src/onboarding_en.arb` | `onboarding…` strings (tagline reuses `appTagline`, Back reuses `back`) |

## Tests

- `test/ui/onboarding_test.dart` — step rules (five pages in order,
  positions, only `limits` gates); brand page content (promise, scene, no
  Skip, no carousel scenes); Begin and swipe lead to page 2; "Step n of 5";
  page 2 shows the credit (title, byline, independence notice, not the
  paraphrase notice), the limits incl. not therapy, and Next/swipe stay
  blocked until 18+ is ticked; semantics of the checkbox and the pace radio
  pair; both credit links open the exact URLs (mocked url_launcher channel);
  honest snackbar when a link can't open; storage text; Back (button and
  system) keeps 18+, pace and the untrimmed typed name; Start saves pace,
  trimmed name, 18+ and calls `onDone`; a new profile starts with the
  Campaign off and the invitation on Today; no name → "Good morning,
  Traveler."; replay starts from earlier choices and keeps the Campaign
  settings; the scene is static with reduced motion and rises once
  otherwise; every page at 320×568 @200 %, 390×844, 1024×1366 @130 % in dark
  and light without overflow.
- `test/ui/shell_test.dart` › "onboarding leads into the app" and the
  journeys (`journeys_test.dart`, `persona_journey_test.dart`) drive the real
  flow (Begin → 18+ → Next ×3 → Start).
- `test/screenshots/onboarding_today_screenshots_test.dart` (tag
  `screenshots`, skipped by default): every page and all five scenes, dark and
  light → `test/screenshots/out/1x_*.png`, `23_scenes_*.png`
  (`make screenshots`).

## Requirements covered

F-001 (promise and limits, pace and safety note), F-002 (author, title, both
links, independence notice), F-003 (pace stored; nothing time-locked), F-004
(optional name), F-043 (storage disclosure in onboarding), D-11 (18+
confirmation), F-044/F-045 (labels, focus, 320 dp at 200 % text), reduced
motion; evolve plan Step 1 › A (five pages, first-use hints, Campaign off for
new users).
