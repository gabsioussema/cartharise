# The Campaign (game version)

An optional game layer over the reset, the Compass and the quests: Section VII
of the article ("life as a game") made playable. It is the third section of the
**Compass** tab (**Compass | Missions | Campaign**), with a small card on Today.
Requirements: F-058–F-064 and §13 "The Campaign" of
`Cartharise_Game_Requirements.html`; the browser prototype is
`Cartharise_Game.html` (`campaign()` view).

## The six components (F-058, F-063)

| Article component | Game role | In the app |
|---|---|---|
| Anti-vision | What's at stake | Compass › Anti-vision |
| Vision | Win condition | Compass › Vision |
| One-year goal | Main campaign | Compass › One-year mission |
| One-month project | Boss fight | Missions project title, else Compass › One-month project; battle log |
| Daily levers | Daily quests | Compass › Daily levers → Missions |
| Constraints | Rules of engagement | Compass › Boundaries, always shown with "The game never rewards giving these up." |

Nothing is copied or inferred: the map shows the user's own Compass words, or
"Not written yet."

## User flow

1. **Status** (forest hero): "Level n · x XP", a bar towards the next level
   ("x / 100 XP to level n+1"), "XP counts participation and practice, never
   your worth. Rest days cost nothing, and nothing is ever taken away." and
   **How XP is earned** (a dialog listing every rule below).
2. **Act I · The one-day awakening** (F-059): five chapter cards with the
   article's counts — See the terrain (4), Find the pattern (7), Raise your
   banner (3), Break autopilot (6 daytime check-ins), Plan the campaign (7
   evening questions). Each card is kept short: name, area · count, progress,
   "n of total written" in the current reset,
   an "Explored" chip when complete, and **Explore** → the chapter's first
   unanswered question (`AppNav.openPrompt`). Bonus prompts never count.
3. **The strategist's map** — the table above; **Build your strategy** (→
   Compass section) and **Open daily quests** (→ Missions).
4. **Monthly boss fight** (F-061): "The boss is the project or obstacle, never
   you or other people." The month project as a callout, then **What did you
   actually try?** (required) and **What did you learn? (optional)** →
   **Record this attempt**. The battle log lists attempts newest first (five,
   then "Show all n"); tapping one opens a sheet to correct it or **Delete
   attempt** (confirmation first).
5. **Achievements from the article** (F-062): seven tiles — The Observer,
   The Pathfinder, The Visionary, The Watchful, The Strategist (one per
   completed chapter, in any reset), The Practitioner (a completed quest), The
   Challenger (a first attempt). Status is an icon **and** the word "Earned" /
   "Not yet", never colour alone.
6. **Act II · The 30-day becoming** (F-064): quests completed, 30-day notes
   written, attempts recorded; **Continue the 30-day path** (→ Missions) and
   **Read the article**. Revising the strategy happens in the Compass, which
   keeps versions; the battle log is never erased by a revision.
7. A note: XP, levels, chapters, achievement names and the battle log are
   Cartharise additions, not part of the article.

**Today** shows "The Campaign" (level, XP bar, "n of 7 achievements",
**Open the Campaign**) while the game layer is on.

## XP rules (`lib/domain/campaign.dart`, F-060)

XP is **derived** from what is saved, never stored or accumulated, so repeating
an action cannot farm it and resting cannot lower it.

| Activity | XP | Counted |
|---|---|---|
| Core reset question answered | +5 | once per question, across every reset (max 27 × 5) |
| Quest completion | +20 | at most 3 completions per local day |
| 30-day path day written | +10 | per day with a non-blank note |
| Attempt recorded | +15 | per local day with at least one attempt |
| Weekly review | +15 | per week |

Level = 1 + XP ÷ 100. XP never looks at what was written, how long it is or
how the user feels; skipped and blank answers earn nothing; starting a new reset
keeps earlier XP and achievements. Deleting a record removes what it counted
for (the user's choice, not a penalty).

## Turning it off (F-060)

You › Settings › **The Campaign** (switch, on by default). Off hides the
Campaign pill and the Today card (`AppNav.openCampaign` then shows the Compass);
the battle log stays saved, exported and deleted with everything else.

## Data

* `AppSettings.game` (bool, default true).
* `AppData.campaignLog`: `BattleLogEntry {id, day (yyyy-MM-dd), attempt,
  learning, createdAt, editedAt?}`, newest first. Attempt and learning are
  stored exactly as typed; a blank attempt is refused. Older data and backups
  without these keys load with the game on and an empty log (no schema bump).
* State: `CampaignOps` (`lib/ui/campaign/campaign_ops.dart`) — `campaign`,
  `gameEnabled`, `setGameEnabled`, `monthlyBoss`, `recordAttempt`,
  `editAttempt`, `deleteAttempt`, all on `AppState.mutate`.

## Files

| File | What |
|---|---|
| `lib/domain/campaign.dart` | chapters, achievements, XP rules, `campaignProgress()` (pure Dart) |
| `lib/ui/campaign/campaign_view.dart` | the Campaign section |
| `lib/ui/campaign/attempt_sheet.dart` | correct / delete an attempt |
| `lib/ui/campaign/campaign_card.dart` | the Today card |
| `lib/ui/campaign/campaign_copy.dart` | chapter and achievement names |
| `l10n_src/campaign_en.arb` | strings (`campaign…`) |

## Tests

* `test/campaign_test.dart` — chapter counts against the real and fake
  content, every XP rule and cap, levels, rest and new resets never lowering
  XP, achievements across resets, backup round trip and older data,
  record/edit/delete (words as typed, blank refused), the off switch keeping
  the log, the monthly boss, and the ARB copy never judging.
* `test/ui/campaign_test.dart` — the whole section with real numbers, recording
  (and the blank-attempt message), editing and deleting, chapter → first open
  question, map → Compass, the XP rules dialog, no judgement copy, the Today
  card, the off switch (no card, no pill, log kept), the size matrix in dark and
  light.
* `test/ui/a11y_test.dart` — the Campaign in dark and light against the tap
  size, label and contrast guidelines.
* `test/screenshots/campaign_screenshots_test.dart` — full section and a phone
  view, dark and light.
