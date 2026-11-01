# Cartharise

*Understand yourself. Choose your path. Rise with purpose.*

A native Android + iOS app (Flutter) that makes Dan Koe's article
*How to fix your entire life in 1 day* easy to understand and act on: seven
plain-language lessons, a guided one-question-at-a-time reset, a six-part Life
Compass, gentle daily quests, a 30-day path, a journal and weekly reviews.

Cartharise is independent and not affiliated with or endorsed by Dan Koe; its
questions are paraphrased and credited, never reproduced. Everything stays on the
phone: no account, no backend, no analytics.

## Develop

```bash
make deps        # flutter pub get
make l10n        # merge l10n_src/*_en.arb → lib/l10n, generate AppLocalizations
make check       # flutter analyze + flutter test (must be clean/green)
make run         # run on a device / emulator
make android     # debug APK
make screenshots # design screenshots → test/screenshots/out/
make             # all targets
```

iOS is configured (display name, notifications, icons, splash) but needs Xcode
to build (`make ios`).

## Docs

* `PLAN.md` — build plan and the contract between areas
* `docs/architecture.md` — layers, data flow, persistence, reminders, loading
* `docs/features/` — one page per area (`foundation.md`, …)
* `docs/content-traceability.md` — source segment → prompt → placement
* `Cartharise_Requirements.html` — product requirements (F-001…F-057)
