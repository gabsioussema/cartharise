# Content traceability

How the source article maps to Cartharise content, and what Cartharise adds on its own.
Mirrors `Cartharise_Requirements.html` §05 (Source traceability). Content lives in
`lib/content/en.dart` (`englishContent`, version 1); `test/content_test.dart` guards it.

**Source:** Dan Koe, *How to fix your entire life in 1 day*, published 23 December 2025.
X article: <https://x.com/thedankoe/status/2010751592346030461> ·
newsletter: <https://letters.thedankoe.com/p/how-to-fix-your-entire-life-in-1>.
Cartharise is independent and not affiliated with or endorsed by Dan Koe.

## Wording policy

Every lesson, question, help text, example and path prompt was written independently in plain
language (about grade 6–8 reading level). Nothing is copied from the article: an automated check of
the English content against the newsletter text found no run of 5 or more consecutive words in common
(the bar in PLAN.md §7 is 6). The article title in the credit is the only source wording, and it
is there as a citation. Examples start with "Someone might write:" so they read as one possible
answer, never a model answer.

> **Before public release:** this wording was written by the content agent and has **not** been through
> the legal, content and emotional-safety review the requirements call for (F-039 Original educational
> content, F-056 Release rights assessment, plus the content/tone review in §11 "Definition of done").
> A human reviewer must approve it before launch, and the rights checklist must be completed.

## Source segment → prompts → placement

| Source segment | Intent (paraphrased) | Prompt ids | Cartharise placement | Data / outcome |
|---|---|---|---|---|
| Morning 01–04 | Tolerated dissatisfaction, repeated complaints, the gap between intentions and behaviour, an uncomfortable truth | `morning.01`–`morning.04` (group `currentReality`) | Reset › Morning › The Mirror / Current reality | 4 reflection answers |
| Morning 05–08 | A possible unchanged future at 5 years, 10 years and later life; similar paths seen around you | `morning.05`–`morning.08` (group `antiVision`, all with `softerQuestion`) | Reset › Morning › The Mirror / Anti-vision | 4 reflection answers, raw material for the anti-vision |
| Morning 09–11 | A role you might have to loosen (and its social cost), the hardest-to-admit reason for not changing, what current habits protect and what that costs | `morning.09`–`morning.11` (group `identity`, all with `softerQuestion`, framed as hypotheses) | Reset › Morning › The Mirror / Identity | 3 reflection answers |
| Morning 12–14 | A positive ordinary weekday three years on, an open identity statement ("I am becoming someone who…"), one action this week | `morning.12`–`morning.14` (group `vision`) | Reset › Morning › The Vision | 3 reflection answers: vision, identity statement, first step |
| Daytime 01–06 | Six timed awareness checks: avoidance (11:00), priorities seen in actions (13:30), direction (15:15), something important set aside (17:00), image-keeping vs wanting (19:30), most alive vs most flat (21:00) | `daytime.01`–`daytime.06` (group `interrupt`, `defaultTime` = source time) | Reset › Daytime › The Interrupt; reminders and `.ics` export use these defaults | 6 optional observational answers, editable times |
| Bonus 01–03 | Others' expectations of the role named in the morning, safety vs aliveness, the smallest next-day version of the person you want to become | `bonus.01`–`bonus.03` (group `contemplation`, `core: false`) | Reset › Daytime › Optional contemplations | 3 optional notes, excluded from core completion |
| Evening 01–02 | A working theory of why you have felt stuck; the inner pattern or belief behind it | `evening.01`–`evening.02` (group `insight`) | Reset › Evening › The Breakthrough / Insights | 2 insight answers |
| Evening 03–04 | The unwanted direction and the desired life, each in one sentence | `evening.03` (`mapsTo: antiVision`), `evening.04` (`mapsTo: vision`) | Reset › Evening › The Breakthrough / Direction → Compass import | Anti-vision and vision drafts |
| Evening 05–07 | One concrete one-year change, a one-month project that keeps it possible, 2–3 actions for tomorrow (one per line) | `evening.05` (`yearGoal`), `evening.06` (`monthProject`), `evening.07` (`dailyLevers`) | Reset › Evening › The Breakthrough / Plan → Compass import; levers → draft quests | Year goal, month project, daily levers |
| Six-part "life as a game" frame | Anti-vision, vision, one-year mission, one-month project, daily levers, constraints | Fields of `CompassField`; explained in `lesson.07` | Compass tab (six fields) + Missions (quests, month project) | 6 editable fields and draft quests |
| Continued reflection (extension) | Weekly learning, notes, a 30-day path, changing direction | — (see Cartharise additions) | Journal, Reviews, Missions › 30-day path | Product additions, not an article checklist |

**Compass mapping rule (F-024, F-025):** only `evening.03`–`evening.07` carry `mapsTo`, and only
into empty fields after an explicit, previewed import. No prompt maps to `constraints`: the user
always writes their own constraints.

**Source references:** every `Prompt.sourceReference` is the segment and group above, e.g.
`Morning 05–08 · anti-vision`. Ids are permanent; wording may be revised in later content versions.

## The seven lessons (Awakening)

Each lesson paraphrases one of the article's seven numbered sections. Every nuance presents the idea
as a framework or lens and states its limits. The lessons never assign stages, labels or motives.

| Id | Title | Source idea it paraphrases | Try it |
|---|---|---|---|
| `lesson.01` | Who you are comes first | §I: change lasts when it starts from identity and lifestyle, not only from new actions | `morning.09`, `morning.13`, `morning.14` |
| `lesson.02` | Your actions have reasons | §II: behaviour serves goals, often unspoken (such as avoiding judgement); a goal shapes what you notice | `morning.03`, `morning.11`, `daytime.02` |
| `lesson.03` | Why change can feel risky | §III: identity forms through a repeating loop and then gets defended; much of it comes from early conditioning | `morning.09`, `morning.11`, `daytime.05`, `bonus.01` |
| `lesson.04` | Ways of seeing can widen | §IV: models of adult/ego development (the article summarises nine stages). Cartharise keeps only the general idea of widening perspective and **never places the user in a stage** | `morning.09`, `evening.02`, `bonus.01` |
| `lesson.05` | Aim, check, adjust | §V: intelligence as steering toward what you want; feedback loops (aim, act, sense, compare, adjust); stepping off the default path | `daytime.03`, `evening.05`, `evening.07` |
| `lesson.06` | A day off autopilot | §VI: change moving through unease, uncertainty and discovery; the one-day protocol (morning excavation, daytime interrupts, evening synthesis); write by hand, think for yourself | `morning.01`, `daytime.01`, `evening.01` |
| `lesson.07` | Your direction as a game | §VII: games and flow; the six components as stakes, win condition, mission, big challenge, quests and rules; goals as lenses rather than finish lines | `evening.03`–`evening.07` |

Each lesson ends with a 3-option knowledge check. No score is kept.

## Cartharise additions (not in the article)

- **Thirty-day path** (`thirtyDays`, F-057): 30 original daily prompts in four stages. Observe (days
  1–7), Experiment (8–15), Build (16–23) and Adjust (24–30). They build on the Compass, quests and
  month project. Any day can be opened at any time.
- **Softer wording** (`softerQuestion`) on all anti-vision and identity prompts and many others, plus
  context, plain-language help and a neutral example on every prompt.
- **Safety framing**: anti-vision prompts say they show a possible future, not a prediction.
  Identity prompts present answers as hypotheses. The identity statement is phrased "I am becoming
  someone who…".
- **Knowledge checks** and nuance sections on the lessons.
- **Product features beyond the protocol**: gentle quests (no points or scores), month project
  milestones and retrospective, journal, weekly reviews, look-back comparisons, reminders, `.ics`
  export, data export/import/delete. The article suggests calendar reminders for the daytime
  questions; the six editable reminders and quiet hours are Cartharise's implementation of that.
- **Flexible pacing**: the article suggests one dedicated day. Cartharise also offers an open-ended
  pace and never locks a phase by time.
- **Playground experiments** (`experiments`, `try.<chapter>.<n>`, evolve plan Step 1): 15 tiny,
  safe, real-world tries, three per Campaign chapter (terrain, pattern, banner, autopilot, plan).
  Original Cartharise text, written to sit beside the chapter's questions; none asks the user to
  share personal details. Trying one is separate from tasks until the user taps "Add to my tasks".
- **Playground notices** (`notices`, `notice.<n>`): 7 cards that only point at existing prompts or
  lessons (`promptId` / `lessonId`); their titles are Cartharise's, the text they open is the
  traced prompt or lesson above.

## Source-structure notes

- The newsletter's ordered lists number the morning questions 1–4, 5–11 and 13–15: the number 12 is
  skipped in the published markup, so the 14 questions run up to 15. Cartharise numbers them
  `morning.01`–`morning.14` in source order, as the requirements do.
- The source puts the 7 identity-and-anti-vision questions (5–11) in one list. The split into
  anti-vision 05–08 and identity 09–11 follows the requirements' §05 coverage table, not a heading
  in the article.
- The first bonus question refers back to the identity written "in question 10". By the article's
  own numbering, question 10 is about the embarrassing reason. The identity you would have to give up
  (a "kind of person I am" statement, with its social cost) is question 9. That is the most likely
  intended reference, and it fits the requirements' "expectations of others". `bonus.01` therefore
  refers to the morning *role* question (`morning.09`) by name, not by number. Its help text says
  what to do if that question was skipped.
- Times: the article gives 11:00am, 1:30pm, 3:15pm, 5:00pm, 7:30pm and 9:00pm. These are stored as
  24-hour `HH:MM` local times.
- The X version of the article could not be read by automated tools. The structure was checked against
  the newsletter version only.
