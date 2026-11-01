# Persona: your avatar ("Your strategist")

The user composes their own avatar and an optional motto; it shows in You,
the Campaign and Today. Cosmetic and user-chosen only, never inferred. Plan
and contracts: `docs/plans/persona.md`; domain: `lib/domain/persona.dart`;
operations: `lib/ui/persona/persona_ops.dart`.

## Builder

`PersonaBuilderScreen` (`lib/ui/persona/persona_builder.dart`), opened with
`AppNav.openPersonaBuilder` from the You profile (and the Campaign).

### User flow

1. **Preview** (forest hero): the draft as a large `AvatarView`, updated live,
   with **Surprise me** under it. Its screen-reader label lists the parts
   ("Avatar preview. Skin: Copper, Face: Oval, Hair: Locs, …"; "None" choices
   left out).
2. **Categories**: one row of scrollable choice chips — Skin, Face, Hair, Hair
   colour, Facial hair, Glasses, Marks, Expression, Headwear, Clothing, Colour,
   Carry, Banner. One category is shown at a time, so the screen stays short.
3. **Choices** of that category as a grid of tiles: a small portrait of the
   draft wearing that choice (colours are seen in place, next to their name)
   and the name. The selected tile has a check, a bold name and an accent
   ring, and is announced as selected. Skin starts with **Silhouette** (no
   skin assumed), then the tones in `kSkinTonePresentation`'s mixed order.
   No gender choice: every option is open to everyone.
4. **Motto (optional)**, then **Remove avatar** when one is saved.
5. **Save** stays in the bottom bar (disabled while nothing changed on an
   existing avatar, or while the motto is too long).

`builder_categories.dart` (the category table, `surpriseAvatar`,
`previewDescription`), `builder_options.dart` (grid and tile),
`builder_preview.dart` (preview and chips), `builder_motto.dart` (the field).

### Rules

- **Nothing is stored before Save.** Save calls `savePersona(draft, motto:)`;
  on success the builder closes with "Avatar saved.".
- **Campaign extras.** A locked extra (game layer on, not earned yet) stays
  visible with a lock, a dimmed portrait and its reason ("Reach the Alps",
  "Earn The Challenger" — `unlockReason`), and cannot be chosen (no tap
  action; announced as disabled). Categories with a locked choice say
  "Locked extras open along the Campaign." With the game layer off everything
  is open. An extra the saved avatar already wears stays selected and usable,
  marked "Yours while worn" (`PersonaOps.canUse`).
- **Surprise me** picks a random choice in every category among usable parts
  only, always a skin tone, never the same avatar twice in a row; "New look.
  Not saved yet." with **Undo**.
- **Motto, as typed.** Stored exactly as typed (no trimming). The limit is
  `kPersonaMottoMax` (60) in the same unit `savePersona` checks
  (`String.length`), shown as "n/60". An edit that would go over is refused,
  never cut. An older, longer motto (e.g. from a backup) shows "A little too
  long. Shorten it to save." and Save waits.
- **Remove avatar** asks first ("Remove your avatar?", destructive), then
  `clearPersona` and back to the profile with the emblem ("Avatar removed.").
- **Leaving with unsaved changes asks first** (`PopScope`; back button and the
  system gesture): "Leave without saving?" — **Keep editing** / **Leave**.
  A motto change alone counts. Nothing changed → leaves at once.
- **Honest failures (F-055).** If the write fails, the builder stays open,
  says "Not saved on this phone yet. Retry at the top, or export a copy." and
  shows the `SaveIndicator` (Retry / Export a copy) on top. A failed removal
  says "Removed here, but not saved on this phone yet." the same way.

### You profile

The profile hero (`you_tab.dart`) shows the avatar (`AvatarView`, or the
emblem before one exists), the optional name (its own button, "Edit name" →
the name dialog), the motto in quotes when it isn't blank, "Name and avatar
are optional and stay on this phone.", and **Create your avatar** (primary) /
**Edit your avatar** (secondary) → the builder. The portrait opens the builder
too; screen readers get it as an image ("Your avatar" / "No avatar yet") and
use the button. Two separate targets, never a button inside a button.

### Accessibility and sizes

Every tile, chip and button is at least 48 dp and labelled; selection and
locks are announced and shown by icon and text, not colour alone; tiles grow
wider as text grows (2–6 columns) and rows take the height of their tallest
tile; the page scrolls (320 dp at 200 % text to tablets, centred at the
readable width). No motion of its own (the scroll to Retry jumps when motion
is off).

### Tests

`test/ui/persona_builder_test.dart`: create from You, edit, silhouette,
tone order, Surprise me (+ unit test of `surpriseAvatar`), locked extras,
game off, worn locked kept, remove with confirm, unsaved-changes prompt
(button and system back), failed save and failed removal, motto limits, You
profile, categories, guidelines (dark + light), size matrix (dark + light).
Screenshots: `test/screenshots/persona_builder_screenshots_test.dart`.
