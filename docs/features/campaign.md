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
   you." — then "n of 13 extras unlocked" (extras the user chose with a
   pick, keeps or wears; all 13 with the game layer off), the suggested
   extra of the next milestone and how to reach it ("Next: Compass · Reach
   the Rhône"; "Every extra unlocked." only once every extra really is the
   user's — with every milestone reached but picks unspent the line is left
   out), and **Create your avatar** / **Edit your avatar** →
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
   chapter: every chapter question answered in one reset, **or** one of the
   chapter's Playground experiments tried), The Practitioner (a completed
   quest), The Challenger (a first attempt). Status is an icon **and** the
   word "Earned" / "Not yet", never colour alone. Each tile also names the
   avatar extra it suggests ("For your avatar: Scroll", with an open lock
   once the user has it), read out with the tile. Above them, "Next:
   <achievement> · <how>" points to the closest one not earned yet.
7. **Act II · The 30-day becoming** (F-064): quests completed, 30-day notes
   written, attempts recorded; **Continue the 30-day path** (→ Missions) and
   **Read the article**. Revising the strategy happens in the Compass, which
   keeps versions; the battle log is never erased by a revision.
8. A note: XP, levels, chapters, achievement names and the battle log are
   Cartharise additions, not part of the article.

**Today** shows a Campaign tile (level, XP, bar → Campaign) while the game
layer is on.

**Missions and Today** (XP preview): each open quest shows a small "+20 XP"
chip (read out as "Earns 20 XP when done") while the game layer is on and
fewer than 3
quests are done today (`kQuestDaysCap`, the same count as the XP rules:
each quest once per day). Done quests, a used-up day and the game layer off
show no chip; the quest itself never changes.

## Avatar extras: reward picks (evolve step 1)

Appearance is always free; 13 decorative extras (banners, four garment
colours, circlet, laurel wreath, scroll, compass, amulet) are earned with
**reward picks** while the game layer is on. With the game layer off every
extra is open (unchanged).

* **Picks earned** — `rewardPicksEarned(progress)` (`lib/domain/campaign.dart`)
  = route stops reached after Carthage + achievements earned (0 … 13). It is
  derived from the records, so it can go down.
* **Picks left** — `rewardPicksLeft(progress, kept)`
  (`lib/domain/persona.dart`) = max(0, earned − |`AppData.avatarUnlocked`|)
  (also never more than the extras not kept yet); `PersonaOps.picksLeft` is 0
  with the game layer off.
* **Choosing** — `PersonaOps.chooseReward(extra)` adds the extra to
  `AppData.avatarUnlocked` (game on, a pick left, not owned yet; otherwise it
  throws and writes nothing). `unlockSource` is now the **suggested** extra of
  each milestone: `suggestedReward(progress, owned)` /
  `PersonaOps.suggestedPick` preselects the first reached milestone's extra
  the user doesn't own, and `rewardOptions` / `PersonaOps.rewardChoices` lists
  every extra not owned, suggested first. `suggestedExtras(progress)` is the
  set the reached milestones suggest; `nextUnlock(progress, owned:)` is the
  suggested extra of the next milestone still ahead (`kUnlockOrder`: route
  stops first, then achievements).
* **Kept for good** — `AppData.avatarUnlocked` is the set the user chose,
  plus extras kept from wearing (`savePersona` / `clearPersona` add what the
  old and new avatar wear) and extras an earlier version opened by itself. It
  only grows: nothing kept is taken away when progress goes down (picks left
  simply stay at 0 until it rises again). `AppState.mutate` and `load` no
  longer fold anything derived into it.
* **Locked** = not chosen, not kept and not worn: `PersonaOps.avatarUnlocks`
  is the kept set (everything with the game layer off), `ownsExtra` /
  `canUse` add what the saved avatar wears, and `savePersona` refuses an
  avatar wearing an extra the user doesn't own yet.

It is in the backup and cleared by "Delete all data".

## The invitation (evolve step 1)

A brand-new profile starts with the Campaign off and a one-time invitation
pending: `completeOnboarding(askAboutGame: true)` sets `game: false,
gameInvited: false` only when no profile existed (a replayed welcome keeps
the user's settings). `AppSettings.gameInvited` defaults to true and loads
as true from older files, so existing users never see it.
`CampaignInviteCard` (`lib/ui/campaign/campaign_invite.dart`, a placeholder
that renders nothing until its body lands) is shown by Today and the
Campaign hub while `CampaignInviteOps.campaignInvitePending`;
`answerCampaignInvite(play:)` answers it for good (Play also turns the game
on; Not now leaves it off, switchable in You › The Campaign).

## The Playground's experiments (evolve step 1)

`ContentLibrary.experiments` — `Experiment {id 'try.<chapter>.<nn>'
(permanent), chapter, title, steps (1–3), minutes}` — and
`ContentLibrary.notices` — `Notice {id 'notice.<nn>', glyph, title, promptId
| lessonId}` (a notice opens an existing prompt or lesson). Trying one is
`CampaignOps.tryExperiment(id, note:)` → an `ExperimentEntry {id,
experimentId, day, note (exactly as typed, optional), createdAt, editedAt}` in
`AppData.experimentLog` (newest first; `editExperimentEntry`,
`deleteExperimentEntry`, `hasTried`). **Add to my tasks**
(`addExperimentToTasks`) creates a one-off quest with
`QuestSource.experiment` (the open one is returned instead of a duplicate)
and earns nothing by itself.

## Moments (`CampaignFeedback`, F-060)

A calm pill at the top for about two seconds, announced to screen readers:
"+20 XP" when a quest, an attempt, a weekly review or a first try of an
experiment adds XP, and "Achievement earned: …". Changes within 0.7 s become
one moment. Extras no longer open by themselves (progress gives picks, the
user chooses), so no extra is announced as new.

Only an action is a moment: action XP, or the two action achievements (The
Practitioner, The Challenger). Never while typing an answer: reflection and
path XP stay quiet, and so does what typing reaches — a route stop or a
chapter's achievement (The Observer … The Strategist). These are not saved up
for later either; the Campaign's achievement tiles and the Strategist card
show them. Never twice: an achievement seen this session isn't announced
again. Never for a bulk change such as a restored backup (more than 60 XP,
or 3+ achievements or reward picks at once — picks counted above the most
seen this session), never with the game layer off, never for spending a pick;
no fade with reduced motion.

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
| Playground experiment tried | +10 (`kXpPerExperiment`) | once per distinct experiment, ever; the note never counts |

Level = 1 + XP ÷ 100. XP never looks at what was written, how long it is or
how the user feels; skipped and blank answers earn nothing; starting a new reset
keeps earlier XP and achievements. Deleting a record removes what it counted
for (the user's choice, not a penalty). Action XP (`xpFromActions`) is quests,
attempts, reviews and experiments.

**Achievements and their route.** `CampaignProgress.earnedBy` maps each
earned achievement to an `EarnedRoute`: a chapter's achievement is
`reflecting` (every chapter question *answered* — not skipped — in one reset)
or `trying` (any of that chapter's experiments tried; reflecting is named
when both are true); The Practitioner and The Challenger are `doing`.
`earned` is its key set; `Achievement.chapter` / `Achievement.ofChapter` map
between chapters and their achievements, and `ChapterProgress.tried` counts
the chapter's distinct experiments tried. An experiment id the content
doesn't know (a newer backup) still counts its XP once, but earns no
achievement.

## Turning it off (F-060)

You › Settings › **The Campaign** (switch, on by default). Off hides the
Campaign pill and the Today card (`AppNav.openCampaign` then shows the Compass);
the battle log stays saved, exported and deleted with everything else.

## Data

* `AppSettings.game` (bool, default true; a brand-new profile starts false
  until the invitation's "Play") and `AppSettings.gameInvited` (bool, default
  and JSON fallback true).
* `AppSettings.todayPin` (`TodayPin { auto, project, reflection, notes }`,
  default and fallback for unknown names `auto`) — used by Today.
* `AppData.attemptDraft`: `AttemptDraft {attempt, learning, updatedAt}` or
  null — the attempt form's words, autosaved with
  `saveAttemptDraft(attempt, learning)` (exactly as typed; both blank →
  null; nothing written when unchanged) and removed by `recordAttempt` in the
  same change.
* `AppData.experimentLog` (above) and `QuestSource.experiment` (appended).
* `AppData.campaignLog`: `BattleLogEntry {id, day (yyyy-MM-dd), attempt,
  learning, createdAt, editedAt?}`, newest first. Attempt and learning are
  stored exactly as typed; a blank attempt is refused. Older data and backups
  without these keys load with the game on and an empty log (no schema bump).
* State: `CampaignOps` (`lib/ui/campaign/campaign_ops.dart`) — `campaign`,
  `gameEnabled`, `setGameEnabled`, `monthlyBoss`, `attemptDraft`,
  `saveAttemptDraft`, `recordAttempt`, `editAttempt`, `deleteAttempt`,
  `experimentLog`, `hasTried`, `tryExperiment`, `editExperimentEntry`,
  `deleteExperimentEntry`, `addExperimentToTasks`; `PersonaOps` —
  `picksEarned`, `picksLeft`, `rewardChoices`, `suggestedPick`,
  `chooseReward`; `CampaignInviteOps` — `campaignInvitePending`,
  `answerCampaignInvite`; all on `AppState.mutate`.
* Every new field is in the JSON backup and cleared by "Delete all data";
  older data and backups without them load with the defaults above (no
  schema bump).

## Files

| File | What |
|---|---|
| `lib/domain/campaign.dart` | chapters, achievements, XP rules, `campaignProgress()` (pure Dart) |
| `lib/ui/campaign/campaign_view.dart` | the Campaign section |
| `lib/ui/campaign/attempt_sheet.dart` | correct / delete an attempt |
| `lib/ui/campaign/campaign_card.dart` | the Today card |
| `lib/ui/campaign/campaign_copy.dart` | chapter and achievement names |
| `lib/ui/campaign/campaign_feedback.dart` | the "+XP" / achievement moments |
| `lib/ui/campaign/campaign_invite.dart` | `CampaignInviteCard` (placeholder) + `CampaignInviteOps` |
| `lib/ui/widgets/glyphs.dart` | `CarthaGlyph`, `GlyphIcon`, `LessonIllustration`, `AchievementBadge` (placeholders) |
| `lib/ui/missions/quest_tile.dart` | the "+20 XP" chip (`questsDoneOn`, `questXpOpenOn`) |
| `lib/domain/persona.dart` | the suggestion table (`unlockSource`), `kUnlockOrder`, `nextUnlock`, `suggestedExtras`, `rewardPicksLeft`, `suggestedReward`, `rewardOptions` |
| `lib/domain/content.dart` | `CampaignChapter`, `CarthaGlyph`, `Experiment`, `Notice` |
| `l10n_src/campaign_en.arb` | strings (`campaign…`) |

## Tests

* `test/campaign_test.dart` — chapter counts against the real and fake
  content, every XP rule and cap, levels, rest and new resets never lowering
  XP, achievements across resets, backup round trip and older data,
  record/edit/delete (words as typed, blank refused), the off switch keeping
  the log, the monthly boss, the ARB copy never judging, the extras' order,
  `nextUnlock` (in order, skipping earned and worn extras, none at the end),
  suggestions only ever growing with XP, and the quest XP preview (counted
  once per quest per day, closed at the cap and with the game layer off).
* `test/evolve_contracts_test.dart` — `gameInvited` / `todayPin` JSON and
  fallbacks, onboarding's invitation for new profiles only, Play / Not now,
  attempt drafts (exactly as typed, blank removes, no needless write, cleared
  by `recordAttempt` in the same change), experiments and notices (content
  shape, log round trip, try / edit / delete, unknown ids refused, Add to my
  tasks without duplicates or XP), distinct-experiment XP, achievements by
  trying vs reflecting vs doing, reward picks (earned, left, suggested first,
  choose and its refusals, nothing kept ever taken away, game off opens
  everything, `mutate` / `load` no longer opening extras, a locked extra
  cannot be worn), backup / "Delete all data" with every new field, and the
  glyph / art / invitation stubs in dark and light.
* `test/ui/campaign_test.dart` — the whole section with real numbers, recording
  (and the blank-attempt message), editing and deleting, chapter → first open
  question, map → Compass, the XP rules dialog, no judgement copy, the Today
  card, the off switch (no card, no pill, log kept), the size matrix in dark and
  light (also with an avatar and a long motto, the avatar staying on the road
  in Italy). Persona: the emblem / avatar on the route (excluded from
  semantics, placed at the current stop), the Strategist card (nudge, count,
  next extra, worn extras, "Every extra unlocked." only when every extra is
  the user's, motto as typed, Create / Edit → builder), achievement tiles
  naming their extra, moments with picks (an achievement or a stop gives a
  pick and no extra is claimed as new; not from typing alone; nothing twice;
  not for a restore that earns many), and the quest chips (open vs done, cap
  reached, game off, size matrix).
* `test/ui/a11y_test.dart` — the Campaign in dark and light against the tap
  size, label and contrast guidelines.
* `test/screenshots/campaign_screenshots_test.dart` — full section and a phone
  view, dark and light.
