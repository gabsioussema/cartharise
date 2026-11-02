# Plan: lighter days, the Playground, the board, voice and languages

**Status:** step 1 done (contracts, Today + onboarding, the Playground, the visual system, integrated on `main`; audit findings A1–A10 fixed); step 2 done (2.0 contracts; 2.1 board, projects and media integrated on `main` with journeys in `test/ui/evolve2_journey_test.dart`; audit findings S2-M1–M3 and S2-m1–m9 fixed, tests in `test/evolve2_fixes_test.dart`); step 3 done (3.0 contracts: languages, multi-locale strings and content, voice interfaces, tests in `test/evolve3_contracts_test.dart`, guide in `docs/translations.md`; 3.1 Dictate, Listen, French, Arabic + right to left and route scenery integrated on `main` with journeys in `test/ui/evolve3_journey_test.dart`; French and Arabic are **drafts that need native review**, and the iOS voice code is not compiled yet; audit findings S3-m1–m6 fixed: pills never break a word, experiment tasks found by id across languages, Type instead focuses its field everywhere, Dictate on the new attempt form, the user's words in their own direction in fields and on screen, tests in `test/evolve3_fixes_test.dart`, `test/ui/evolve3_fixes_test.dart` and `test/ui/rtl_test.dart`).

Source: an external product review (Nov 2026) of Cartharise. The owner chose to build
**all three steps**, with these decisions:

| Decision | Choice |
|---|---|
| Scope | Steps 1, 2 and 3 |
| Campaign for new users | **Ask once:** off until they say "Play" on a one-time invitation; existing users keep their setting |
| Today | **Balanced:** one chosen next action + "Choose something else", Write capture, smaller scene, keep the three glance tiles, direction collapsed |
| Build | A swarm per step: contracts agent → parallel feature agents (worktrees) → integrate → audit → fix |

The intended feeling: *"This place reflects my choices, and I can see what I've tried."*
Returning should feel easy even after a long absence.

## Principles (on top of CLAUDE.md)

* **Smaller daily job.** Today offers one useful action and an easy stop ("Done. That can be
  enough for today."). Everything else is one tap away, not on top.
* **Explore without obligation.** Playground experiments stay separate from tasks until the user
  taps **Add to my tasks**.
* **Rewards stay cosmetic and fair.** Participation-based XP, daily caps, nothing lost by
  resting, nothing earned by writing more, returning daily, or disclosing more. Basic avatar
  identity is always free. *Answered* and *skipped* stay honestly distinct; a real-world try is an
  alternative route to a chapter's achievement, and the app says which route earned it.
* **One task list, many views.** The board is another view of the same quests; moving a card earns
  nothing.
* **Voice is local or absent.** Dictation only through a verified on-device recognizer; otherwise
  offer Record or typing. Recordings are kept separately from any transcript. Personal text is read
  aloud only after an explicit tap. Never rewrite or summarise the user's words.
* **Recognition over recall.** One stable visual cue per idea, always paired with a word:

  | Idea | Glyph | Where |
  |---|---|---|
  | Notice | mirror | lessons, reflections, Playground "Notice" |
  | Direction | compass + north star | Compass, project context |
  | Experiment | seedling | Playground "Try", experiment cards, attempts |
  | Boundaries | shelter | constraints, planning |
  | Reflection | lantern + notebook | Journal, weekly review |
  | Progress | path + landmark | Campaign, milestones |

* **Honest failures** (existing rule, extended): a failed save never shows "recorded"; drafts are
  kept; failed recordings and imports say so with a practical alternative.

---

## Step 1 — Simplify

### 1.0 Contracts (one agent, on `main`, before the feature agents)

Pure Dart unless noted; JSON hand-written; unknown values fall back; everything in backups and
cleared by "Delete all data". Add tests for each in `test/evolve_contracts_test.dart`.

1. **`AppSettings`**
   * `gameInvited` (bool). Constructor default `true`; JSON fallback `true` (existing users never
     see the invitation).
   * `todayPin` (`enum TodayPin { auto, project, reflection, notes }`, default `auto`).
   * Onboarding's finish (agent A) creates new users with `game: false, gameInvited: false`.
     `AppSettings()`'s `game` default stays `true` so old files and tests keep their meaning.
2. **Attempt drafts:** `AppData.attemptDraft` (nullable `AttemptDraft { attempt, learning, updatedAt }`).
   Ops in `campaign_ops.dart`: `saveAttemptDraft(attempt, learning)` (empty both → null) and
   `recordAttempt` clears the draft **in the same mutate**.
3. **Experiments (Playground "Try"):**
   * Content model `Experiment { id ('try.<chapter>.<n>', permanent), chapter (CampaignChapter), title, steps (1–3 short lines), minutes }`
     in the content layer; `ContentLibrary.experiments` (agent B writes the English content: at least
     two per chapter, tiny, real-world, safe, never about sharing personal details).
   * `ContentLibrary.notices`: `Notice { id ('notice.<n>'), glyph, title, promptId? , lessonId? }`.
     A notice opens an existing prompt or lesson (no new text store).
   * `AppData.experimentLog: List<ExperimentEntry { id, experimentId, day, note, createdAt, editedAt }>`
     (note optional, exactly as typed).
   * `QuestSource.experiment` (appended) for **Add to my tasks**.
4. **Campaign rules (`lib/domain/campaign.dart`)**
   * `kXpPerExperiment = 10` per **distinct** experiment tried (once each), part of `xpFromActions`.
   * Chapter achievements: every chapter question *answered* in one reset **or** any of that
     chapter's experiments *tried*. `CampaignProgress.earnedBy: Map<Achievement, EarnedRoute>`
     with `enum EarnedRoute { reflecting, trying, doing }` so the UI can say how.
   * **Reward picks** replace fixed unlocks: `rewardPicksEarned(progress)` = route stops reached
     after Carthage + achievements earned. `AppData.avatarUnlocked` is the set the user **chose**
     (plus extras kept from wearing, F7). `picksLeft = max(0, earned − |avatarUnlocked|)`.
     `AppState.mutate` no longer folds derived unlocks into `avatarUnlocked`. Op
     `chooseReward(Unlockable)` (game on, `picksLeft > 0`). `unlockSource` stays as the
     **suggested** extra for each milestone (preselected in the choice). Game off → every extra open
     (unchanged). Kept extras are never taken away (unchanged).
5. **Glyph + art stubs** in `lib/ui/widgets/glyphs.dart` (bodies by agent C):
   `enum CarthaGlyph { notice, direction, experiment, boundaries, reflection, progress }`,
   `GlyphIcon(glyph, {size, color, semanticLabel})`, `LessonIllustration(lessonId, {height})`,
   `AchievementBadge(achievement, {earned, size})`. Stubs draw a Material icon so everything runs.
6. **Invitation stub:** `CampaignInviteCard()` in `lib/ui/campaign/campaign_invite.dart`
   (body by agent B; shown by Today and the Campaign hub while `!gameInvited`).
7. Update `docs/features/campaign.md` (rules) and `test/persona_test.dart` /
   `test/campaign_test.dart` expectations that the pick model changes **by design** (keep intent:
   nothing taken away, game off opens everything, no moment for bulk changes).

### 1.1 Feature agents (parallel worktrees)

**A. `today-onboarding`** owns `lib/ui/today/*`, `lib/ui/onboarding/*`, `l10n_src/today_en.arb`,
`l10n_src/onboarding_en.arb`, their tests, `docs/features/today.md`, `docs/features/onboarding.md`.
* Today, balanced: greeting (+ avatar) → **one next action** card with a **smaller** scene and
  **Choose something else** (a sheet of the other valid steps) → **Write** capture (opens a new
  journal note) → the three glance tiles → today's quests → direction **collapsed**.
* Next-step logic considers plans: `TodayPin` overrides; `auto` = nothing started and no quests →
  start; open quests today → do one; reset in progress → resume; then build Compass, levers →
  quests, weekly review, journal. Remember the pin (asked in "Choose something else": *Help me
  with: my project · reflection · notes · decide for me*).
* After the chosen action is done today: **"Done. That can be enough for today."** with a quiet
  "one more" link. Long absence: no counts of missed days, just the next action.
* Shows `CampaignInviteCard` while `!gameInvited` (below the next action).
* Onboarding from ten pages to **five**: brand + one-line promise · source credit + limits
  (not therapy) + 18+ · pace · name (optional) · privacy + start. Features are introduced on first
  use instead (one-line hints, shown once). Finish sets `game: false, gameInvited: false`.

**B. `playground`** owns `lib/ui/campaign/*`, `lib/ui/persona/persona_copy.dart` and the lock text
in `lib/ui/persona/builder_options.dart`, `lib/ui/missions/quest_tile.dart` (experiment source
label only), the experiments/notices content in `lib/content/en.dart`, `l10n_src/campaign_en.arb`,
`l10n_src/persona_en.arb`, their tests, `docs/features/campaign.md`, `docs/features/persona.md`
(rewards).
* The Campaign section becomes a **compact hub**: status (avatar at the route stop, level, XP to
  next) → three invitations **Notice · Try · Make it yours** (glyph + one line each) → small links
  **Route · Chapters · Battle log · Collection** that open their own screens (the current long
  content moves there).
* **Try**: one experiment at a time with **I tried it** (optional one-line note) and
  **Add to my tasks**; tried ones go to the Collection. **Notice**: an illustrated card that opens
  its prompt or lesson. **Make it yours**: the builder, plus **Choose your reward** when
  `picksLeft > 0`, showing your avatar **wearing** each option (suggested one first).
* **Collection (keepsakes)**: experiments tried, achievements (with `AchievementBadge` and how
  they were earned), extras chosen.
* *(Audit fix A3)* With the game off — every new user until **Play** — the section's pill reads
  **Playground**: the invitation, Notice · Try · Make it yours and the Collection, with no XP,
  levels, route or achievements, so experiments stay open to everyone.
* `CampaignInviteCard` body: "Play the Campaign? XP and levels for what you do." **Play** /
  **Not now** (both set `gameInvited`; Play sets `game: true`). Not now leaves You › The Campaign.
* Trust fixes: the attempt form autosaves its draft (`saveAttemptDraft`, debounced like the
  Compass), and after `recordAttempt` a failed save says so (no "recorded", Retry on top).
* Moments: "+10 XP" for an experiment tried; "A new pick for your avatar" when an action earns a
  pick (same quiet rules as today).

**C. `visual-system`** owns `lib/ui/widgets/glyphs.dart` (bodies), `lib/ui/widgets/scenes.dart`,
`lib/ui/awakening/*`, glyph placement in `lib/ui/compass/*` and `lib/ui/journal/*` (icons only),
`l10n_src/visual_en.arb`, their tests and screenshots, `docs/features/awakening.md`.
* Six painted glyphs (brand line style, palette tokens), always with a word.
* **Seven lesson illustrations** (one memorable scene each) on lesson cards and lesson screens.
* **Seven achievement badges**, each distinct (not one medal reused).
* A **compact** scene variant for Today (shorter height, same art).

### 1.2 Integrate · 1.3 Audit · 1.4 Fix
Merge A → B → C; wire leftovers; journey tests (new user: 5-page onboarding → Today → invitation →
Play; returning user: pin + done state; Playground: try → add to tasks → collection → choose a
reward); screenshots; README; debug APK. Audit against this plan and CLAUDE.md, then fix.

---

## Step 2 — Everyday usefulness

### 2.0 Contracts
* `QuestStage { later, ready, doing, done }` on `Quest` (default `ready`; one-off quests completed →
  `done`; daily quests show *done* for today and return to *ready* the next day, keeping
  `completedOn`). "Today" stays a filter (due today / daily), separate from the stage.
* Projects: `MonthProject.id`; `AppData.pastProjects: List<MonthProject>` (archived with their
  retrospective); `Quest.projectId`, `BattleLogEntry.projectId`; the current project keeps working.
* Attachments: `Attachment { id, kind (photo|audio), fileName, createdAt, durationMs?, transcript? }`
  on `JournalEntry`, `ExperimentEntry`, `BattleLogEntry`; files in the app's private
  `attachments/` folder (excluded from OS backups like the data file); `AttachmentStore`
  (save/copy/delete, honest failures). `AppData.pinnedMemory` (`{ kind: passage|photo, ref }`).
* Backup v2: a `.zip` with `data.json` + `attachments/`; restore accepts v2 zip and v1 JSON;
  "Delete all data" removes the folder.

### 2.1 Feature agents
* **D. `board`** — List/Board toggle in Missions; lanes Later → Ready → Doing → Done (stacked or one
  lane on phones, columns on tablets); **Move to…** besides drag; Doing gently suggested small;
  Done collapsed; existing completion XP only.
* **E. `projects`** — archive a project (retrospective), history across months, link quests and
  attempts to a project, a chosen project illustration (or photo once F lands) shown on its tasks
  and history.
* **F. `media`** — photos (system picker / camera) and voice recordings (tap to start/stop,
  clear recording state, interrupted recordings kept, playback) on notes, experiments and attempts;
  **Write · Record** quick capture on Today; pinned memory; backup v2; delete.

---

## Step 3 — Expand carefully

### 3.0 Contracts
* `AppSettings.language` (`system | en | fr | ar`); `ContentLibrary` per language with English
  fallback per item; ARB merge for every language; `TextDirection` from the locale.
* Voice service interfaces (pure Dart, faked in tests): `Dictation` (on-device availability per
  language, start/stop, partial text) and `ReadAloud` (speak/stop).

### 3.1 Feature agents
* **G. `dictation`** — Android `SpeechRecognizer.createOnDeviceSpeechRecognizer` (API 31+,
  `isOnDeviceRecognitionAvailable`) and iOS `requiresOnDeviceRecognition` via a small platform
  channel; **Dictate** shows text for review before inserting it; unavailable → Record or type.
* **H. `read-aloud`** — **Listen** on lessons, prompts and (explicit tap) the user's own notes via
  the platform TTS; stop anytime; respects silent mode.
* **I. `languages`** — language picker in You › Appearance; French and Arabic for every string and
  all content (lessons, prompts, softer wording, examples, errors, reminders, help); a bundled Arabic
  font (OFL); right-to-left layouts and mixed-script tests. Translations are marked **draft, needs
  native review** in `docs/` before any release.
* **J. `scenery`** — richer Playground scenery and keepsake art.

Each step ends with `make check` green, screenshots reviewed, docs updated, and a pushed commit.
