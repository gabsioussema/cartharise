# The Campaign (game version)

An optional game layer over the reset, the Compass and the quests: Section VII
of the article ("life as a game") made playable. It is the third section of the
**Compass** tab (**Compass | Missions | Campaign**), with a small card on Today.
Since evolve step 1 it is a compact hub with the **Playground** (Notice, Try,
Make it yours) and keepsakes (the Collection); see `docs/plans/evolve.md`.
With the game layer off (every new user until "Play", anyone after "Not
now") the third pill reads **Playground** and keeps Notice, Try, Make it
yours and the Collection open, without XP, levels, the route or
achievements (below).
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

## User flow: a compact hub (evolve step 1)

The Campaign section is a short **hub**; the long content lives on its own
pages (`CampaignPage`, opened with `pushCampaignScreen` or, from other areas,
`AppNav.openCampaignPage(context, page)`). Every page shares `CampaignScreen`
(back button, `SaveIndicator` on top, a short Cinzel title with one line,
a readable-width list with the bottom inset).

**The hub** (`campaign_view.dart`), top to bottom:

1. `SaveIndicator`.
2. **Status** (forest hero): "Level n · x XP" and **Hannibal's route** — one
   stop per level (Carthage, New Carthage, the Ebro, the Pyrenees, the Rhône,
   the Alps, Italy; places, never labels for the person), the road walked so
   far and the stretch towards the next stop. The user's avatar
   (`AvatarView`, 36 dp; the emblem until they make one) stands above the
   current stop — decoration only; the route's label ("Hannibal's route: the
   Ebro, stop 3 of 7.") says where they are. "You're at the Ebro", "90 XP to
   the Pyrenees" (from Italy on "The campaign goes on") and **How XP is
   earned** (the rules dialog, which opens with "XP counts what you do, never
   your worth. Rest costs nothing.").
3. Three **invitations** (`PlaygroundInvitations`), each a card with its cue,
   a word and one line, the whole card opening its page: **Notice** (notice
   glyph) "A question or idea to look at again." · **Try** (experiment glyph)
   "A tiny experiment for real life." · **Make it yours** (the user's own
   avatar, the emblem until one exists — not the Campaign's progress glyph)
   "Your avatar and motto." — or "2 reward picks to choose" while picks are
   left. One column on phones, up to three on tablets.
4. Small links: **Route** · **Chapters** · **Battle log** (reads "Battle log ·
   draft kept" while an attempt draft is saved) · **Collection**.
5. The honest note: XP, levels and achievements are Cartharise additions.

**The Playground with the game off** (`PlaygroundView`, audit fix A3): the
pill reads **Playground**, "Small things to notice and try.", then the
**invitation** while it is unanswered, the same three invitations and a
**Collection** link; once the invitation is answered, "No XP or levels while
the Campaign is off. Turn it on in You." No status, route, chapters or
battle log. Try shows no "+10 XP", the Collection shows what was tried and
no achievements, Make it yours says every extra is open. **Play** turns the
section into the hub in place.

**Notice** (`notice_screen.dart`): illustrated cards from
`ContentLibrary.notices` — a lesson's `LessonIllustration`, or, for a
question, the notice's glyph in a small 44 dp tile beside its kind (no large
empty panel) — with what it opens ("REFLECTION" / "LESSON",
"Opens: Quiet dissatisfaction"), its short title, and "Written" (the question
has an answer in any reset) or "Read" (`lessonsRead`) in words. The card opens
the prompt (`AppNav.openPrompt`) or the lesson (`AppNav.openLesson`); nothing
new is stored.

**Try** (`try_screen.dart`): one experiment at a time — the chapter, the
title, "About n min", "+10 XP" (read "Earns 10 XP the first time"; only while
the game is on and the experiment was never tried), "Tried <date>" once tried,
and its numbered steps (read "Step 1: …"). It starts at the first experiment
not tried yet (or at a chapter's, from **Chapters › Try one**).
**Previous** / **Next** go round the list ("3 of 15"). **The note is kept**
(audit fix A6): each experiment's note autosaves as a draft
(`AppData.tryNoteDrafts`, `saveTryNoteDraft`, exactly as typed) 600 ms after
the last keystroke, when switching experiments, when the page closes and
when the app goes to the background; it comes back when the experiment is
shown again, even after a restart. A blank note is no draft; **I tried it**
removes the draft in the same change.
* **I tried it** → `tryExperiment(id, note:)` for today, the optional note
  exactly as typed → "Saved to your Collection." The try never makes a task.
* **Add to my tasks** → `addExperimentToTasks(id)`: explicit only; one
  one-off quest (`QuestSource.experiment`, labelled "Experiment" in Missions)
  → "Added to your tasks." with **Open tasks**; while it is open, tapping
  again reuses it → "Already in your tasks." Adding earns nothing and records
  no try.
* A write that failed says "Not saved on this phone yet. Retry at the top."
  and scrolls to the `SaveIndicator` (never "saved").

**Make it yours** (`make_it_yours_screen.dart`): **Your strategist** — the
avatar (88 dp; the emblem until one exists, then not read out since the words
say it), the motto exactly as typed (or "Create an avatar to walk the route
with you."), "n of 13 extras unlocked" (chosen, kept or worn; all 13 with the
game off) and **Create your avatar** / **Edit your avatar** → the builder. On
narrow screens at large text the avatar sits above the words. Then **Reward
picks**:
* picks left → "2 picks to spend. What you choose stays yours.", "Suggested:
  Scroll" and **Choose your reward** (the sheet below);
* none left → when the next comes ("Next pick at the Ebro", else "Next pick:
  earn The Challenger" — `nextPickReason`);
* every extra the user's → "Every extra unlocked." (only then);
* game off → "With the Campaign off, every extra is already open."

**Choose your reward** (`reward_sheet.dart`): the user's own avatar (or the
silhouette) **wearing** the selected extra at 112 dp (read "Your avatar
wearing North star"), then every extra a pick can buy as tiles
(`BuilderOptionTile`: a 48 dp portrait wearing that option, its name, its kind
— "Banner", "Carry", "Headwear", "Colour" — and a colour swatch for garment
colours), **the suggested extra first and preselected** ("Suggested · Carry";
`PersonaOps.rewardChoices`), extras kept or worn left out. **Choose North
star** (in a bottom bar that stays reachable) → `chooseReward` → "North star
is yours to keep." with **Wear it** (the builder; choosing never changes the
avatar by itself). Nothing is spent before that tap. A failed write says "Not
saved on this phone yet. Retry at the top."; if the game is turned off or the
picks run out while the sheet is open, it says so instead of offering a
choice. `extraPart(u)` / `avatarWearing(avatar, u)` map an extra to the part
it puts on (preview only).

**Route** (`route_screen.dart`): the status hero again (44 dp avatar, the XP
note, **How XP is earned**), **Stops** — each place with an icon and words:
"You're here", "Reached" or "n XP to go" — then **The strategist's map** (the
table above; **Build your strategy** → Compass, **Open daily quests** →
Missions; from the hub these pop back and switch the section in place) and
**Act II · The 30-day becoming** (F-064): quests completed, 30-day notes
written, attempts recorded; **Continue the 30-day path** and **Read the
article**.

**Chapters** (`chapters_screen.dart`, Act I, F-059): "n of 5 chapters
explored" and five cards with the article's counts — See the terrain (4),
Find the pattern (7), Raise your banner (3), Break autopilot (6 daytime
check-ins), Plan the campaign (7 evening questions): area · count, progress
and "n of total written" in the current reset, "Explored" when complete,
"1 experiment tried" when one was, **Explore** → the first unanswered question
and **Try one** → Try at that chapter (the other route to its achievement).
Bonus prompts never count.

**Battle log** (`battle_log_screen.dart`, F-061): "The boss is a project,
never a person. Log what you try." The month project as a callout, **Boss
strength** (the Missions project's milestones: "1 of 3 milestones reached",
then "Every milestone reached. Boss beaten."; with none, "Add milestones…" →
`ProjectScreen`), **What did you actually try?** (required) and **What did you
learn? (optional)** → **Record this attempt**, then every attempt, newest
first; tapping one opens a sheet to correct it or **Delete attempt**
(confirmation first).
* **The draft is kept.** Both fields autosave as `AppData.attemptDraft`
  (`saveAttemptDraft`, exactly as typed) 600 ms after the last keystroke, when
  the page closes and when the app goes to the background (the Compass
  `Autosaver`); the page restores it when it opens, and the hub's link says
  "draft kept". "Kept on this phone as you type." is shown only while no save
  has failed. Clearing both fields removes the draft; recording removes it in
  the same change.
* **Honest recording.** "Attempt recorded." only once the write worked. A
  failed write says "Not saved on this phone yet. Your words are still here.
  Retry at the top.", keeps the words in the form and scrolls to the
  `SaveIndicator`; a Retry that works there clears the form and then says
  "Attempt recorded.". Recording the same words again after a failure writes
  again instead of adding a second attempt. Leaving the page while Retry
  still waits and opening it again shows the same words (kept with the
  `AppState` for the session, since recording removed the draft; audit fix
  A7).

**Collection** (`collection_screen.dart`, keepsakes):
* **Experiments tried** — "n experiments tried" and one card per experiment
  (most recently tried first): its title once, then each try with its note
  exactly as typed and "Tried <date>" (so the count matches the cards; audit
  fix A10). Tapping a try opens a sheet to correct the note or **Remove this
  try** (asks first; `experiment_entry_sheet.dart`); closing the sheet with a
  changed note that wasn't saved (swipe, back, a tap outside) asks **Save
  your change?** — **Save note** or **Discard** (audit fix A6). An
  experiment a newer version added shows as "An experiment". Nothing yet → a
  way into Try.
* **Achievements from the article** (F-062; game on only) — "n of 7
  earned", "Earned by reflecting, trying or doing. Never by what you write."
  and "Next: …". Seven tiles with their `AchievementBadge` (earned or not
  shows by shape), name, **what it asks in the present tense** (e.g. "Answer
  every daytime check-in in one reset, or try one of its experiments";
  never a past-tense claim, since a chapter's badge can be earned either
  way — audit fix A1) and, in words with an icon, **Earned by reflecting** /
  **Earned by trying: Leave your phone in another room** (the experiment
  that earned it, `CampaignProgress.earnedByExperiment`) / **Earned by
  doing** (`CampaignProgress.earnedBy`) or **Not yet**; each tile is read
  out as one phrase.
* **Extras chosen** — the extras the user keeps or wears, as named chips (or
  "No extras chosen yet."; with the game off, every extra is open) and a link
  to Make it yours.

Every bottom sheet here (Choose your reward, a try's note, an attempt, a
quest) opens without sliding when Settings › Motion or the device's reduce
motion is on (`sheetAnimationStyle: AnimationStyle.noAnimation`; audit fix
A5).

**Today** shows a Campaign tile (level, XP, bar → Campaign) while the game
layer is on.

**Missions and Today** (XP preview): each open quest shows a small "+20 XP"
chip (read out as "Earns 20 XP when done") while the game layer is on and
fewer than 3 quests are done today (`kQuestDaysCap`, the same count as the XP
rules: each quest once per day). Done quests, a used-up day and the game layer
off show no chip; the quest itself never changes. A quest added from Try
carries an "Experiment" label (`quest-source-<id>`), with or without the game.

## The Playground's content (`lib/content/en.dart`)

Cartharise additions, not from the article. **Fifteen experiments**, three per
chapter (`try.<chapter>.01–03`): tiny, real-world, safe, a few minutes, never
about sharing personal details, one to three short steps, action first — e.g.
"Walk one room as a guest would", "Do one routine a different way", "Spend ten
minutes like your future self", "Leave your phone in another room", "Write
tomorrow's first step tonight". **Seven notices** (`notice.01–07`), each
opening an existing question or lesson: morning.01, morning.02, lesson.02,
daytime.01, lesson.06, morning.12, lesson.05. Ids are permanent;
`ContentLibrary.version` is 2. `test/content_test.dart` checks the text for
banned words and `test/evolve_contracts_test.dart` the ids, steps and targets.

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
* **In the app** — the hub's Make it yours line counts the picks left, Make
  it yours offers **Choose your reward** (above), a new pick earned by an
  action is a moment, the Collection lists the extras chosen, and the
  builder's locked tiles say "Choose it with a reward pick" while one is
  left, else "Next pick at the Ebro" (`lockedExtraNote`, `nextPickReason`
  in `persona_copy.dart`).

It is in the backup and cleared by "Delete all data".

## The invitation (evolve step 1)

A brand-new profile starts with the Campaign off and a one-time invitation
pending: `completeOnboarding(askAboutGame: true)` sets `game: false,
gameInvited: false` only when no profile existed (a replayed welcome keeps
the user's settings). `AppSettings.gameInvited` defaults to true and loads
as true from older files, so existing users never see it.

`CampaignInviteCard` (`lib/ui/campaign/campaign_invite.dart`) is shown by
Today and the Playground (the Compass tab's third section with the game off)
while `CampaignInviteOps.campaignInvitePending`:
a card with the progress glyph, **Play the Campaign?**, "XP and levels for
what you do." and **Play** / **Not now**. Both answer it for good
(`answerCampaignInvite(play:)`): Play turns the game on ("The Campaign is on.
It lives in Compass." with **Open the Campaign**); Not now leaves it off ("You
can turn it on in You."). A failed write says "Not saved on this phone yet.
Retry at the top." It renders nothing (zero height) once answered. Choosing
in You › The Campaign (`setGameEnabled`) answers it too, so a user who turns
the game on there is never asked again.

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
"+20 XP" when a quest, an attempt or a weekly review adds XP, "+10 XP" for a
first try of an experiment, "Achievement earned: …", and **"A new pick for
your avatar"** ("2 new picks…") when the action earned a reward pick that can
be spent. Changes within 0.7 s become one moment ("+20 XP · A new pick for
your avatar"). The pill leads with the achievement's own `AchievementBadge`
when one is announced, else the progress glyph. Extras never open by
themselves (progress gives picks, the user chooses), so no extra is
announced as new.

Only an action is a moment: action XP, or the two action achievements (The
Practitioner, The Challenger). Never while typing an answer: reflection and
path XP stay quiet, and so does what typing reaches — a route stop, a
chapter's achievement (The Observer … The Strategist) and the picks they
give. These are not saved up for later either; the hub, Make it yours and
the Collection show them. Never twice: an achievement seen this session
isn't announced again, and picks count only above the most seen this
session. A pick is said only while `picksLeft > 0` (a pick that merely
covers extras already kept is nothing new to spend). Never when the data is
replaced wholesale — a load, a restored backup of any size, a fresh start
after a load error, "Delete all data": `AppState.dataGeneration` changes and
the moments start over from the new data (audit fix A2); a bulk jump (more
than 60 XP, or 3+ achievements or reward picks at once) is ignored too.
Never with the game layer off, never for spending a pick; no fade with
reduced motion.

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
`CampaignProgress.earnedByExperiment` names, for each achievement earned by
trying, the experiment that earned it (the chapter's first one tried).
`earned` is its key set; `Achievement.chapter` / `Achievement.ofChapter` map
between chapters and their achievements, and `ChapterProgress.tried` counts
the chapter's distinct experiments tried. An experiment id the content
doesn't know (a newer backup) still counts its XP once, but earns no
achievement.

## Turning it off (F-060)

You › Settings › **The Campaign** (switch). Off hides the hub, its XP,
levels, route and achievements and the Today card; the Compass tab's third
pill becomes **Playground** (`AppNav.openCampaign` then shows it). The
battle log, the experiment log and the kept extras stay saved, exported and
deleted with everything else. Either choice there also answers the
invitation.

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
* `AppData.tryNoteDrafts`: `Map<String, String>` experiment id → the Try
  note not sent yet, exactly as typed (`tryNoteDraft`, `saveTryNoteDraft`;
  blank → removed; nothing written when unchanged; `tryExperiment` removes
  it in the same change). Older files have none.
* `AppState.dataGeneration`: changes whenever the data is replaced wholesale
  (load, restore, fresh start, delete all), never for an action.
* `AppData.campaignLog`: `BattleLogEntry {id, day (yyyy-MM-dd), attempt,
  learning, createdAt, editedAt?}`, newest first. Attempt and learning are
  stored exactly as typed; a blank attempt is refused. Older data and backups
  without these keys load with the game on and an empty log (no schema bump).
* State: `CampaignOps` (`lib/ui/campaign/campaign_ops.dart`) — `campaign`,
  `gameEnabled`, `setGameEnabled` (also answers the invitation),
  `monthlyBoss`, `attemptDraft`, `saveAttemptDraft`, `recordAttempt`,
  `editAttempt`, `deleteAttempt`, `experimentLog`, `hasTried`,
  `tryExperiment`, `tryNoteDraft`, `saveTryNoteDraft`,
  `editExperimentEntry`, `deleteExperimentEntry`, `addExperimentToTasks`; `PersonaOps` — `picksEarned`, `picksLeft`,
  `rewardChoices`, `suggestedPick`, `chooseReward`; `CampaignInviteOps` —
  `campaignInvitePending`, `answerCampaignInvite`; all on `AppState.mutate`.
* Every new field is in the JSON backup and cleared by "Delete all data";
  older data and backups without them load with the defaults above (no
  schema bump).

## Files

| File | What |
|---|---|
| `lib/domain/campaign.dart` | chapters, achievements, XP rules, `campaignProgress()` (pure Dart) |
| `lib/ui/campaign/campaign_view.dart` | the hub: status, the three invitations (`PlaygroundInvitations`, `CampaignInvitation`), the links; `PlaygroundView` (game off) |
| `lib/ui/campaign/campaign_pages.dart` | `CampaignPage`, `campaignPageScreen`, `pushCampaignScreen`, `openTryFor` |
| `lib/ui/campaign/campaign_kit.dart` | `CampaignScreen`, `CampaignRouteMap`, `showXpRules`, `CampaignGrid`, `CampaignStat`, `CampaignCallout`, `CampaignStatusLine`, `place` |
| `lib/ui/campaign/notice_screen.dart` | Notice (`NoticeCard`) |
| `lib/ui/campaign/try_screen.dart` | Try |
| `lib/ui/campaign/make_it_yours_screen.dart` | Make it yours (`StrategistCard`, reward picks) |
| `lib/ui/campaign/reward_sheet.dart` | Choose your reward (`showRewardSheet`, `extraPart`, `avatarWearing`, `extraKind`) |
| `lib/ui/campaign/route_screen.dart` | the Route, the strategist's map, Act II |
| `lib/ui/campaign/chapters_screen.dart` | Act I's chapters |
| `lib/ui/campaign/battle_log_screen.dart` | the boss, the attempt form (draft autosave, honest recording), the log |
| `lib/ui/campaign/collection_screen.dart` | experiments tried, achievements and how earned, extras chosen |
| `lib/ui/campaign/experiment_entry_sheet.dart` | correct a try's note / remove the try; asks before dropping a changed note |
| `lib/ui/campaign/attempt_sheet.dart` | correct / delete an attempt |
| `lib/ui/campaign/campaign_copy.dart` | chapter and achievement names, `earnedByLabel` |
| `lib/ui/campaign/campaign_feedback.dart` | the "+XP" / achievement / new-pick moments |
| `lib/ui/campaign/campaign_invite.dart` | `CampaignInviteCard` + `CampaignInviteOps` |
| `lib/ui/nav.dart` | `AppNav.openCampaignPage` |
| `lib/ui/widgets/glyphs.dart` | `CarthaGlyph`, `GlyphIcon`, `LessonIllustration`, `AchievementBadge` (painted by the visual-system area) |
| `lib/ui/missions/quest_tile.dart` | the "+20 XP" chip (`questsDoneOn`, `questXpOpenOn`) and the "Experiment" label |
| `lib/domain/persona.dart` | the suggestion table (`unlockSource`), `kUnlockOrder`, `nextUnlock`, `suggestedExtras`, `rewardPicksLeft`, `suggestedReward`, `rewardOptions` |
| `lib/domain/content.dart` | `CampaignChapter`, `CarthaGlyph`, `Experiment`, `Notice` |
| `lib/content/en.dart` | the English experiments and notices |
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
  attempt drafts, experiments and notices (content shape, log round trip, try
  / edit / delete, unknown ids refused, Add to my tasks without duplicates or
  XP), distinct-experiment XP, achievements by trying vs reflecting vs doing,
  reward picks (earned, left, suggested first, choose and its refusals,
  nothing kept ever taken away, game off opens everything, `mutate` / `load`
  no longer opening extras, a locked extra cannot be worn), backup / "Delete
  all data" with every new field, the glyph / art / invitation in dark and
  light, and the audit fixes: Try note drafts (round trip, per experiment,
  cleared by a try and by "Delete all data"), `hintsSeen`, `dataGeneration`
  and `earnedByExperiment` (the first experiment tried in the chapter; none
  when reflecting earned it).
* `test/ui/campaign_test.dart` — the hub (status with real numbers, the
  three invitations, the four links, nothing long on it; each opens its page;
  the XP rules dialog with experiments; no judgement copy on the hub and every
  page), the Route (every stop in words, reached stops, the map in the user's
  words, Act II, the map back to the Compass in place), the Chapters (counts,
  Explore → first open question, Try one → that chapter's first untried
  experiment, tried counts), the Battle log (boss, attempts as typed, record /
  blank, edit / delete, boss strength; the draft autosaved as typed, kept when
  leaving at once, restored on open, cleared by emptying or recording, "draft
  kept" on the hub; a failed save never says "recorded", keeps the words, Retry
  then clears; the same words again write again rather than a second attempt),
  moments (+20 / +10 XP, achievements and the new-pick line; not from typing;
  not twice; not for a pick that only covers kept extras; not for a restore,
  however small; the badge leading an announced achievement; not with the
  game off), the Today card and the off switch (which also answers the
  invitation; with it off the section is the Playground), one cue per
  invitation (mirror, seedling, the user's avatar), Make it yours (emblem / avatar on the route and in
  the card, motto as typed, counts, picks and the suggestion, next pick,
  "Every extra unlocked." only when true), the quest chips and the
  "Experiment" label, and the size matrix in dark and light for the hub (also
  with an avatar in Italy), the Route, Chapters and Battle log.
* `test/ui/playground_test.dart` — Try (one at a time, steps read out,
  "+10 XP" only the first time and with the game on, next / previous round the
  list keeping typed notes, the first untried start, **I tried it** and **Add
  to my tasks** strictly separate, no duplicate task, a failed save said
  honestly with Retry), Notice (art, what it opens, Written / Read in words,
  opening the prompt or lesson), Choose your reward (the avatar wearing every
  option, suggested first and preselected, nothing spent before the
  confirmation, kept for good, kept / worn extras not offered, silhouette and
  swatches, no pick left, game off, the game turned off while open, a failed
  save), the builder's lock text with a pick left, the Collection (notes as
  typed, unknown experiments, badges and how earned, extras chosen, editing
  and removing a try), the invitation (Play, Not now, nothing once answered, a
  failed save, on the Playground then the hub after Play),
  `AppNav.openCampaignPage` for every page; the audit fixes: a try's note
  autosaved per experiment (restart, switch, try clears it, blank removes
  it), a changed note never dropped when its sheet closes (Save note /
  Discard), an achievement earned by trying naming its experiment and making
  no claim about answers, present-tense "what it asks" for every
  achievement, repeat tries grouped under one experiment, the Collection
  without achievements when the game is off, every sheet without a slide
  under reduced motion; and the guidelines (tap size, labels, contrast) plus
  the size matrix in dark and light for Try, Notice, Make it yours, the
  Collection, the Playground (game off, with and without the invitation),
  the invitation, the reward sheet (its confirm button reachable at 320 dp and 200 % text), the
  Battle log, Route and Chapters.
* `test/ui/a11y_test.dart` — the hub in dark and light against the tap size,
  label and contrast guidelines.
* `test/ui/persona_journey_test.dart` — the avatar on the hub's route and in
  Make it yours.
* `test/screenshots/campaign_screenshots_test.dart` — the hub, the
  invitation, every page, the reward sheet, the Playground with the game off
  and a moment with its badge, dark and light (`make screenshots`).
