# Plan: Persona (avatar) + richer gamification

Goal: the user creates their own avatar ("Your strategist"), sees it across the
app, and the Campaign gains cosmetic, never-punitive rewards around it.

## Principles (research + project rules)

* **Inclusive avatar** — no gender choice (every option for everyone); no
  default skin (the avatar is a neutral silhouette until the user picks a
  tone); skin tones shown in a mixed order, never light → dark; hair textures
  straight → coily, afro, locs, braids, grey; religious headwear (headscarf,
  turban); visible differences (glasses, freckles, beauty mark, vitiligo)
  drawn with respect. (Meta avatar best practices, Toca Life's character
  creator, Owlchemy's customizer, CHI 2025 inclusive-avatar guidelines.)
* **Customization supports identification and enjoyment** (Böffel et al.
  2022), but cosmetic rewards don't reliably raise autonomy — so appearance is
  always free; only decorative extras (banners, some garment colours,
  circlet/laurel, scroll/compass/amulet) unlock along the Campaign. With the
  game layer off everything is open. Nothing unlocked or worn is ever taken
  away.
* **Project rules** (CLAUDE.md): no personality labels or diagnoses — the
  avatar is cosmetic and user-chosen, never inferred; user words (motto) are
  stored exactly as typed; palette tokens only (raw colours only in
  `lib/ui/theme/`); 320 dp at 200 % text to tablets, dark + light; short
  copy (1–2 lines per step, action first); reduced motion honoured.

## Phase 0 — contracts (done on `main`, do not change their shape)

| File | What |
|---|---|
| `lib/domain/persona.dart` | Part enums (`SkinTone` … `Sigil`), `kSkinTonePresentation`, `Avatar` (+ JSON, `uses`), `Persona` (avatar, motto ≤ 60, updatedAt), `Unlockable` (13), `unlockSource`, `unlockedBy(progress, gameOn:)`, `requirementOf(part)` |
| `lib/domain/app_data.dart` | `AppData.persona` (nullable, in backups, cleared by "Delete all data") |
| `lib/ui/persona/persona_ops.dart` | `persona`, `avatarUnlocks`, `canUse(part)`, `savePersona(avatar, motto:)`, `clearPersona()` |
| `lib/ui/persona/persona_copy.dart` | `partName`, `unlockableName`, `unlockReason` |
| `l10n_src/persona_en.arb` | names of every part, categories, unlock reasons, "New for your avatar: …" |
| `lib/ui/persona/avatar_view.dart` | `AvatarView({avatar, size, showSigil, semanticLabel, excludeFromSemantics})` — **stub**, art agent replaces the body |
| `lib/ui/persona/persona_builder.dart` | `PersonaBuilderScreen()` — **stub**, builder agent replaces the body |
| `lib/ui/nav.dart` | `AppNav.openPersonaBuilder(context)` |
| `test/persona_test.dart` | contract tests |

## Phase 1 — three agents in parallel (git worktrees)

### A. `avatar-art` — the portrait
Owns: `lib/ui/persona/avatar_view.dart` (body only), new
`lib/ui/persona/avatar_painter.dart`, new `lib/ui/theme/avatar_palette.dart`
(the only place for skin / hair / garment raw colours), optional
`l10n_src/avatar_en.arb` (`avatar…` keys), `test/ui/avatar_test.dart`,
`test/screenshots/avatar_screenshots_test.dart`, `docs/features/persona.md`
(section "Portrait").

* A calm, flat-vector bust in a circle (brand style: soft shapes, a thin
  bronze rim, no gradients on the emblem), every part drawn: 4 face shapes,
  12 hair styles × 8 colours, facial hair, glasses, marks, 3 calm
  expressions, headwear (headscarf and turban drawn respectfully), 4
  garments × 8 colours, accessories, and the sigil banner behind (the
  elephant sigil reuses `EmblemGeometry`).
* `skinTone == null` → a monochrome silhouette (no skin assumed).
* Reads from 24 px (details simplified below ~40 px) to 240 px, in dark and
  light; `avatar == null` keeps the emblem fallback; screen-reader label
  "Your avatar" (or a passed label).
* Tests: every value of every part paints without exceptions; silhouette;
  sizes 24/48/96/240; semantics; ui_base guard stays green.

### B. `persona-builder` — create and edit
Owns: `lib/ui/persona/persona_builder.dart` (body), new
`lib/ui/persona/builder_*.dart`, `lib/ui/you/you_tab.dart` (profile card),
`l10n_src/personabuilder_en.arb` (`personaBuilder…` keys),
`test/ui/persona_builder_test.dart`, `docs/features/persona.md` (section
"Builder").

* Live preview (`AvatarView`, large) on top; categories as short tabs or
  sections (Skin, Face, Hair, Hair colour, Facial hair, Glasses, Marks,
  Expression, Headwear, Clothing, Colour, Carry, Banner); each option a
  labelled choice (colours = swatch **and** name); selection announced, not
  colour alone; 48 dp targets.
* Skin tones in `kSkinTonePresentation` order, plus "Silhouette".
* Locked extras stay visible with a lock and their reason
  (`unlockReason`), not selectable (`canUse`).
* "Surprise me" (random among usable parts), optional motto (≤ 60, as
  typed), **Save** (`savePersona`; honest failure via `SaveIndicator`),
  **Remove avatar** (confirm → `clearPersona`). Leaving with unsaved changes
  asks first.
* You tab: the profile hero shows the avatar (or the emblem) + name + motto,
  and "Create your avatar" / "Edit your avatar" → `AppNav.openPersonaBuilder`.
* Tests: create, edit, surprise, locked item not selectable, worn locked item
  kept, remove, unsaved-changes prompt, failed save, size matrix dark/light.

### C. `campaign-plus` — gamification around the avatar
Owns: `lib/ui/campaign/campaign_view.dart`, `lib/ui/campaign/campaign_feedback.dart`,
`lib/ui/missions/quest_tile.dart`, `l10n_src/campaign_en.arb` (`campaign…`
keys), `test/ui/campaign_test.dart`, `test/campaign_test.dart`,
`docs/features/campaign.md`.

* Status card: the avatar (small `AvatarView`) stands at the current stop on
  Hannibal's route.
* New "Your strategist" card: avatar + motto, "n of 13 extras unlocked", the
  next extra and how to get it ("Reach the Rhône for the compass"), and
  Create / Edit → `AppNav.openPersonaBuilder`.
* Unlock moments: `CampaignFeedback` adds "New for your avatar: Laurel
  wreath" when `avatarUnlocks` grows (same rules: never while typing, never
  for bulk changes, never with the game off).
* XP preview: open quests show a small "+20 XP" chip while the game layer is
  on and today's quest XP cap isn't reached.
* Tests for each, plus the pure "next unlock" helper.

## Phase 2 — integrate
Merge `swarm/avatar-art`, `swarm/persona-builder`, `swarm/campaign-plus`;
`make l10n`; Today shows the small avatar beside the greeting when one exists;
a journey test (create avatar → You, Campaign and Today show it; backup /
delete include it); screenshots; README (features + a screenshot row);
`make check` green; debug APK builds.

## Phase 3 — audit, then fix
Read-only audit against this plan and CLAUDE.md: inclusiveness and no labels,
non-punitive unlocks, accessibility (labels, targets, contrast, 200 % text),
palette guard, privacy (local only, in backup / delete), copy length,
performance of the painter, tests. Then fix every blocker / major finding.
