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

1. **Status** (forest hero): "Level n · x XP" and **Hannibal's route** — one
   stop per level (Carthage, New Carthage, the Ebro, the Pyrenees, the Rhône,
   the Alps, Italy; places, never labels for the person), the road walked so
   far and the stretch towards the next stop ("You're at New Carthage", "10 XP
   to the Ebro"; from Italy on "The campaign goes on"). The user's avatar
   (`AvatarView`, 36 dp; the emblem until they make one) stands above the
   current stop and moves along as they level up — decoration only, the
   route's label ("Hannibal's route: the Ebro, stop 3 of 7.") says where they
   are. Then "XP counts what you do, never your worth. Rest costs nothing."
   and **How XP is earned**.
2. **Your strategist** (persona plan, section C): the avatar (72 dp) and the
   motto exactly as typed — or "Create an avatar to walk the route with
   you." — then "n of 13 extras unlocked", the next extra and how to get it
   ("Next: Compass · Reach the Rhône"; "Every extra unlocked." at the end),
   and **Create your avatar** / **Edit your avatar** →
   `AppNav.openPersonaBuilder`. Extras the avatar already wears count as
   open and are never pointed to as "next" (worn items are never taken
   away). On narrow screens at large text the avatar sits above the words.
3. **Act I · The one-day awakening** (F-059): five chapter cards with the
   article's counts — See the terrain (4), Find the pattern (7), Raise your
   banner (3), Break autopilot (6 daytime check-ins), Plan the campaign (7
   evening questions). Each card is kept short: name, area · count, progress,
   "n of total written" in the current reset,
   an "Explored" chip when complete, and **Explore** → the chapter's first
   unanswered question (`AppNav.openPrompt`). Bonus prompts never count.
4. **The strategist's map** — the table above; **Build your strategy** (→
   Compass section) and **Open daily quests** (→ Missions).
5. **Monthly boss fight** (F-061): "The boss is the project or obstacle, never
   you or other people." The month project as a callout, then **What did you
   actually try?** (required). **Boss strength** shows the Missions project's
   milestones: the bar shrinks only as milestones are reached ("1 of 3
   milestones reached", then "Boss beaten"); with none, "Add milestones to
   your project to weaken the boss" → `ProjectScreen`. Then **What did you
   actually try?** (required) and **What did you learn? (optional)** →
   **Record this attempt**. The battle log lists attempts newest first (five,
   then "Show all n"); tapping one opens a sheet to correct it or **Delete
   attempt** (confirmation first).
6. **Achievements from the article** (F-062): seven tiles — The Observer,
   The Pathfinder, The Visionary, The Watchful, The Strategist (one per
   completed chapter, in any reset), The Practitioner (a completed quest), The
   Challenger (a first attempt). Status is an icon **and** the word "Earned" /
   "Not yet", never colour alone. Each tile also names the avatar extra it
   opens ("For your avatar: Scroll", with an open or closed lock), read out
   with the tile. Above them, "Next: <achievement> · <how>" points to the
   closest one not earned yet.
7. **Act II · The 30-day becoming** (F-064): quests completed, 30-day notes
   written, attempts recorded; **Continue the 30-day path** (→ Missions) and
   **Read the article**. Revising the strategy happens in the Compass, which
   keeps versions; the battle log is never erased by a revision.
8. A note: XP, levels, chapters, achievement names and the battle log are
   Cartharise additions, not part of the article.

**Today** shows a Campaign tile (level, XP, bar → Campaign) while the game
layer is on.

**Missions** (XP preview): each open quest shows a small "+20 XP" chip (read
out as "Earns 20 XP when done") while the game layer is on and fewer than 3
quests are done today (`kQuestDaysCap`, the same count as the XP rules:
each quest once per day). Done quests, a used-up day and the game layer off
show no chip; the quest itself never changes.

## Avatar extras (persona plan, section C)

Appearance is always free; 13 decorative extras (banners, four garment
colours, circlet, laurel wreath, scroll, compass, amulet) open along the
Campaign — one per route stop from New Carthage to Italy, one per achievement
(the table is `unlockSource` in `lib/domain/persona.dart`). With the game
layer off everything is open. `kUnlockOrder` lists them as the Campaign
points to them: the route stops along the road first (XP always moves the
user along it), then the achievements in the article's order;
`nextUnlock(progress, owned:)` is the first one not open yet, skipping
extras the avatar already wears.

## Moments (`CampaignFeedback`, F-060)

A calm pill at the top for about two seconds, announced to screen readers:
"+20 XP" when a quest, an attempt or a weekly review adds XP,
"Achievement earned: …", and "New for your avatar: …" when an extra opens
(`PersonaOps.avatarUnlocks` grows; name from `persona_copy.unlockableName`).
Changes within 0.7 s become one moment. Never while typing an answer
(reflection and path XP stay quiet, and so does a route stop they reach — the
Strategist card shows it), never for a bulk change such as a restored backup
(more than 60 XP, or 3+ achievements or extras at once), never with the game
layer off, never for an extra the avatar already wears; no fade with reduced
motion.

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
| `lib/ui/campaign/campaign_feedback.dart` | the "+XP" / achievement / new-extra moments |
| `lib/ui/missions/quest_tile.dart` | the "+20 XP" chip (`questsDoneOn`, `questXpOpenOn`) |
| `lib/domain/persona.dart` | `kUnlockOrder`, `nextUnlock` (with the unlock table) |
| `l10n_src/campaign_en.arb` | strings (`campaign…`) |

## Tests

* `test/campaign_test.dart` — chapter counts against the real and fake
  content, every XP rule and cap, levels, rest and new resets never lowering
  XP, achievements across resets, backup round trip and older data,
  record/edit/delete (words as typed, blank refused), the off switch keeping
  the log, the monthly boss, the ARB copy never judging, the extras' order,
  `nextUnlock` (in order, skipping earned and worn extras, none at the end),
  unlocks only ever growing with XP, and the quest XP preview (counted once
  per quest per day, closed at the cap and with the game layer off).
* `test/ui/campaign_test.dart` — the whole section with real numbers, recording
  (and the blank-attempt message), editing and deleting, chapter → first open
  question, map → Compass, the XP rules dialog, no judgement copy, the Today
  card, the off switch (no card, no pill, log kept), the size matrix in dark and
  light (also with an avatar and a long motto, the avatar staying on the road
  in Italy). Persona: the emblem / avatar on the route (excluded from
  semantics, placed at the current stop), the Strategist card (nudge, count,
  next extra, worn extras, "Every extra unlocked.", motto as typed, Create /
  Edit → builder), achievement tiles naming their extra, the "New for your
  avatar" moment (from an achievement, from a route stop; not for a worn
  extra, not from typing alone, not for a restore that opens many), and the
  quest chips (open vs done, cap reached, game off, size matrix).
* `test/ui/a11y_test.dart` — the Campaign in dark and light against the tap
  size, label and contrast guidelines.
* `test/screenshots/campaign_screenshots_test.dart` — full section and a phone
  view, dark and light.
