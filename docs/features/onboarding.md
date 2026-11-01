# Onboarding (and the brand scenes)

The entry flow shown while `AppState.needsOnboarding` (first launch, "Replay
welcome", after "Delete all data"). It follows the board's onboarding phones: a
brand page, a four-page carousel, then five short setup pages.
Requirements: F-001, F-002, F-003, F-004, F-043 (summary), D-11 (18+).

## User flow

| # | Page (`OnboardingStep`) | Surface | What it shows |
|---|---|---|---|
| 1 | `brand` | forest hero | Emblem, CARTHARISE lettering + rule (`CarthaWordmark.lettering`), tagline "Master Yourself. Rise With Purpose." in Cinzel, short bronze rule, one-line intro, `DawnRuinsScene` fading into the page. **Begin →**, **Skip**. |
| 2–5 | `understand`, `reset`, `direction`, `steps` | forest hero | `SunriseScene` / `PathScene` / `CompassScene` / `StepsScene`, Cinzel title (Understand Yourself · Reset Your Life · Choose a Direction · Improve Step by Step), short Inter body, page dots, bronze pill **Next →** (last: **Get started →**), **Skip**, Back. Swipe left/right also moves. |
| 6 | `limits` | page background | "What This Is, and Isn't": one day can bring clarity · it can't guarantee a fixed life · an ongoing practice · not therapy or diagnosis (points to You › Support) · you stay in control. **I'm 18 or older** checkbox — required. |
| 7 | `credit` | page background | Article title, "by Dan Koe · 23 December 2025", **Read the original article** and **Read it in the author's newsletter** (open in the browser via `openExternalLink`), the independence and paraphrase notices from `content.credit`, and "You don't need to read it first". |
| 8 | `pace` | page background | **One day** / **At my own pace** (default) as a radio pair; "Either way, nothing ever locks or expires." |
| 9 | `name` | page background | "What Should We Call You?" — optional, never shared, max 40 characters; empty = "Traveler". |
| 10 | `privacy` | page background | "Where your writing lives" = `AppState.storageDescription` (on this device, not encrypted by Cartharise, not synced), no account/ads/analytics, export/delete in You › Your data. **Finish**. |

Finish → `AppState.completeOnboarding(displayName, pace, adultConfirmed: true)`
→ `BootScreen` swaps to `RootShell` (Today) → `onDone` (if given).

## Behaviour rules

- **Back works everywhere and keeps every choice**: the top-left back button,
  a right swipe on the intro pages, and the system back (a `PopScope` turns it
  into "previous page"; on the brand page it leaves the app as usual). The
  18+ tick, pace and typed name live in the flow's state, so going back and
  forth never loses them.
- **Skip** is only on the brand page and carousel and always lands on page 6
  (`OnboardingStep.skipTarget == limits`) — never past the 18+ confirmation.
- **18+ gate**: on page 6, Next is disabled until the box is ticked, and the
  reason is shown in words ("Confirm you're 18 or older to continue.", a live
  region), not by the disabled colour alone. Swiping can't pass it either.
  Finish is guarded the same way.
- **Name**: optional; saved trimmed (empty → no name). Never logged; no
  autocorrect/suggestions on the field.
- **Pace**: stored on the profile. Nothing in the app is locked by time
  (D-08); the copy says so.
- **Replay welcome**: the flow starts from the saved name, pace and 18+ answer.
- **Links** are the only outbound action; if a link can't open, a snackbar
  shows the address so the user can open it themselves.
- **Surfaces**: brand + carousel use the forest hero in both brightnesses
  (`OnHeroTheme` gives them the dark theme: bronze pill, ivory text, light
  bronze links; light status-bar icons). Setup pages use the normal theme so
  longer text reads well in light mode.
- **Motion**: page changes use `CarthaPageMotion`; each scene rises once
  (~1.6 s) when shown. With reduced motion (device) or Settings › Motion off,
  pages switch instantly and scenes are painted finished.
- **Sizes**: every page scrolls; the scene takes at most half the page and
  keeps its proportions; content is centred at ≤ 600 dp on tablets; the
  action bar pads for the system navigation inset.

## Brand scenes (`lib/ui/widgets/scenes.dart`, exported for every area)

`SunriseScene`, `PathScene`, `CompassScene`, `StepsScene`, `DawnRuinsScene`
(each `{aspectRatio = 4/3, semanticLabel, animate}`; `aspectRatio: null` fills
the parent), all built on `BrandScene(kind: SceneKind…)` and `ScenePainter`.

- Vector `CustomPainter`s; colours derived only from palette tokens
  (`hero`, `heroRaised`, `heroAccent`, `onHero`, `onHeroMuted`, `shadow`) via
  `ScenePalette.of(CarthaPalette)`, so they follow the Forest/Olive themes and
  look the same in light and dark (they always sit on hero surfaces).
- No photos, people, weapons or combat. Sky gradients are allowed; the emblem
  is never drawn with a gradient.
- Decorative (excluded from semantics) unless a `semanticLabel` is passed.
- The road in `PathScene` uses horizontal cross-sections along a rising curve,
  so its edges can never fold at any size.
- `OnHeroTheme` (same file): wraps content on a hero surface with the dark
  variant of the current brand theme (used by onboarding and Today's hero).
- Test hooks: `brandSceneProgress(state)`, `isBrandSceneAnimating(state)`.

## Code map

| File | Role |
|---|---|
| `lib/ui/onboarding/onboarding_flow.dart` | `OnboardingFlow({VoidCallback? onDone})` and its private pages |
| `lib/ui/onboarding/onboarding_steps.dart` | `OnboardingStep` — order, skip target, 18+ gate (pure Dart) |
| `lib/ui/widgets/scenes.dart` | Brand scenes, `ScenePalette`, `OnHeroTheme` |
| `l10n_src/onboarding_en.arb` | `onboarding…` strings (tagline reuses `appTagline`, Back reuses `back`) |

## Tests

- `test/ui/onboarding_test.dart` — step rules (order, skip target = page 6,
  only `limits` gates); brand page content; carousel scenes, titles and page
  dots ("Page n of 4"); swipe; Skip lands on the 18+ page and Next/swipe stay
  blocked until it is ticked; semantics of the checkbox and the pace radio
  pair; credit page content and both links opening the exact URLs (mocked
  url_launcher channel); honest snackbar when a link can't open; storage text;
  Back (button and system) keeps 18+, pace and the untrimmed typed name;
  Finish saves pace, trimmed name, 18+ and calls `onDone`; no name → "Good
  morning, Traveler." on Today; replay starts from earlier choices; scenes
  static with reduced motion and rise once otherwise; every page at 320×568
  @200 %, 390×844, 1024×1366 @130 % in dark and light without overflow.
- `test/ui/shell_test.dart` › "onboarding leads into the app" drives the real
  flow (Skip → 18+ → Next ×4 → Finish).
- `test/screenshots/onboarding_today_screenshots_test.dart` (tag
  `screenshots`, skipped by default): every page and all five scenes, dark and
  light → `test/screenshots/out/1x_*.png`, `23_scenes_*.png`
  (`make screenshots`).

## Requirements covered

F-001 (promise and limits, pace and safety note), F-002 (author, title, both
links, independence notice), F-003 (pace stored; nothing time-locked), F-004
(optional name), F-043 (storage disclosure in onboarding), D-11 (18+
confirmation), F-044/F-045 (labels, focus, 320 dp at 200 % text), reduced
motion.
