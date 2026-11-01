# Cartharise

Native Android + iOS app (Flutter) that makes Dan Koe's article *How to fix your entire life in 1 day*
understandable and actionable: lessons, a guided reset, a Life Compass, gentle quests, a journal.
Independent product; the source is credited and paraphrased, never reproduced.

**`PLAN.md` is the build plan and the contract between areas** (IA, design tokens, AppState API,
file ownership, content spec, acceptance per area). Requirements: `Cartharise_Requirements.html`.
Visual target: `Cartharise Brand and App System Board.png`, `CARTHARISE_Brand_Guide.html`.
UI base is mirrored from the sibling app `../qarta` (read its `lib/ui/theme/`, `lib/ui/widgets/`, tests).

## Commands

```bash
make l10n        # dart run tool/merge_arb.dart && flutter gen-l10n
make check       # flutter analyze + flutter test (must be clean/green)
flutter run      # Android device/emulator
flutter build apk --debug
```
Xcode is not installed on this machine: iOS is configured but `flutter build ios` must run elsewhere.

## Key rules

- **Privacy.** Local only: no account, backend, analytics, crash reporting or network calls (the only
  outbound action is opening the credited source links in the browser). Journal/answer text never goes
  into notifications, logs or debugPrint. "Delete all data" removes the file and cancels reminders.
- **User words are sacred.** Save answers exactly as typed; never rewrite, summarise or infer. The
  Compass is filled only by the user or by an explicit, previewed import into *empty* fields;
  constraints are never auto-filled.
- **Emotional safety.** Every prompt is skippable; soften/pause/support always reachable. No
  diagnoses, personality labels, streaks, scores, guilt copy, countdowns or "you fixed your life".
- **Never claim success that didn't happen.** Save failures, denied notification permission and bad
  imports are shown honestly with a practical alternative (retry / export / .ics).
- **UI base.** Every colour comes from `CarthaPalette.of(context)` tokens. No `Color(0x…)`, `Colors.*`
  (except `transparent`), `CarthaColors` or `CarthaThemeSpec` in `lib/ui/` outside `lib/ui/theme/` —
  `test/ui_base_test.dart` enforces it. Reuse the shared widgets in `lib/ui/widgets/` instead of
  restyling locally; add a palette token (to every theme) if a new role is needed.
- **Type.** Cinzel for display/headline/brand only, Inter for everything else. Never long text in Cinzel.
- **Screen sizes.** 320 dp phones to tablets, up to 200 % text, edge-to-edge: scroll, `Flexible` text in
  rows, min (not fixed) heights, bottom inset padding.
- **Strings** go through `AppLocalizations`; add them to your area's fragment `l10n_src/<area>_en.arb`
  (area-prefixed keys), then `make l10n`. `lib/l10n/app_en.arb` + generated Dart are build outputs.
  Prompt/lesson text lives in `lib/content/` (`ContentLibrary`), not ARB.
- **Domain is pure Dart** (`lib/domain/`, no Flutter imports). Ids of prompts are permanent.
- **Motion** honours device reduce-motion and Settings › Motion. The animated emblem is
  `CarthaLoader` (CustomPainter rebuild of `assets/brand/loader_reference.svg`).

## Definition of done

Implement → tests in the same change (widget tests via `test/support` `pumpCartha`, unit tests for
logic, size matrix for new screens, dark + light) → `make check` green → update `docs/features/<area>.md`.
Never delete, skip or loosen a test to get green.

## Conventions

`flutter_lints`, `const` constructors, no `dynamic` in models, hand-written `toJson/fromJson`,
`EdgeInsetsDirectional`. Don't add network/analytics dependencies.
