# Persona: your avatar ("Your strategist")

The user composes their own avatar and an optional motto; it shows in You,
the Campaign and Today. Cosmetic and user-chosen only, never inferred. Plan
and contracts: `docs/plans/persona.md`; domain: `lib/domain/persona.dart`;
operations: `lib/ui/persona/persona_ops.dart`.

## Portrait

`AvatarView` (`lib/ui/persona/avatar_view.dart`) shows an avatar as a round
portrait of `size`. With no avatar it shows the Cartharise emblem on the same
disc. `AvatarPainter` (`lib/ui/persona/avatar_painter.dart`) does the drawing.

**Look.** A calm, flat-vector bust on the theme's hero disc (forest, or
olive in the Olive theme, in both brightnesses) with a thin bronze rim. There
are no gradients and no outlines. Depth comes from one darker tone per
material, with light from the upper left: the far shoulder, the cheek edge and
the shadow under the chin. The face is kept simple and friendly: eyes with a
catchlight (so they read on every skin tone), soft brows, a small nose and a
mouth.

**Every part is drawn** (one shape per enum value):

| Part | Values |
|---|---|
| Face | oval, round, square, long. Hair and headwear are fitted to each shape. |
| Hair | bald, buzz, short, wavy, curly, coily, afro, locs, braids (bronze cuffs), bun, long, ponytail × 8 colours |
| Facial hair | stubble (soft), moustache, beard, full beard. They follow the jaw of each face shape. |
| Glasses | round, square. Frames are dark on lighter skin and gold wire on deeper skin, so they always read. |
| Marks | freckles; a beauty mark; vitiligo as soft, lighter, blurred patches around an eye, the mouth corner, the temple and the neck (never stark white) |
| Expression | calm, smile (closed eyes, rosy cheeks), focused (level brows, eyes a little narrowed; focused, not stern) |
| Headwear | headscarf (frames the face, covers hair and neck, drapes over the shoulders) and turban (layered, covers the hair, keeps the beard). Both are drawn with care. Also: hood (open at the face, the hair shows inside), circlet (gold band with a gem), laurel wreath (gold leaves). Headwear takes the garment colour. |
| Clothing | tunic (round neck, trimmed), cloak (over a linen tunic, with a brooch), robe (crossed collar), wrap (draped over one shoulder) × 8 colours |
| Carry | satchel (strap and bag), scroll (tied with a ribbon), compass (brass pendant), amulet (the sign of Tanit) |
| Banner | elephant (the emblem from `EmblemGeometry`, as a crest beside the head), rising sun (rays around the head), path (a dashed route ending at a waypoint), compass rose, north star, laurel (branches inside the rim) |

The banner is bronze, drawn behind the figure and faint. The elephant is a
small, complete crest, not a large backdrop: drawn large behind a head, the
emblem's face lines read as horns or as the person's ears.

**Silhouette.** With no skin tone (`skinTone == null`) the figure is drawn in
monochrome theme tones. Each tone sits between the disc and `onHeroMuted`. No
face is drawn: no eyes, mouth or marks. The shapes of hair, headwear, glasses,
facial hair, clothing and the carried item still show, so a choice is visible
before a tone is picked. No skin, hair or garment colour is ever assumed.

**Sizes.** The portrait is drawn in a 100 × 100 design space and reads from
24 to 240 px:

* **Under 40 px:** shapes and eyes only, with no banner, texture, freckles,
  beauty mark, nose or lens tint. The rim, brows, mouth and glasses keep a
  minimum width in device pixels, so they never fade out.
* **40–119 px:** every part, with light texture.
* **120 px and up:** the finest detail (hair strands, extra freckles, folds).

**Colours.** Skin tones (base, shade, lip), hair colours (base, shade, shine),
garment colours (base, shade, trim and the linen underneath) and materials
(ink, metal, leather, parchment, ribbon) are named constants in
`lib/ui/theme/avatar_palette.dart`. It is the only place they live. They are
warm and natural, and the garment colours sit beside the brand's forest,
olive, sage, ivory and bronze. A person's colours don't change with the
theme. The disc, rim, banner and silhouette tones come from palette tokens
(`AvatarScene.of(CarthaPalette)`).

**Accessibility.** The screen reader announces "Your avatar", or "No avatar
yet" for the emblem, or the label the caller passes. `excludeFromSemantics`
hides the portrait when a neighbouring text already says it. The portrait
does not animate.

**Performance.** The portrait sits in its own `RepaintBoundary` and
repaints only when the avatar, the theme or `showSigil` changes. Only the
full beard uses a path union.

**Tests.** `test/ui/avatar_test.dart`:

* every value of every part paints at 24, 48, 96 and 240 px;
* each value looks different from the others at 96 px (pixel comparison, so
  a part that isn't drawn fails);
* every headwear over every hair style and face shape;
* every garment with every carried item and banner;
* a headscarf or turban hides the hair;
* the silhouette contains none of the avatar colours, and is monochrome
  (colour choices change nothing, shapes do, and no face is drawn);
* the palette: distinct colours, glasses frames at ≥ 2.5:1 on every skin tone,
  vitiligo patches lighter but never white, trims stand out from their
  garment;
* no raw colours in the persona files;
* level of detail, repaint rules, semantics labels, the emblem fallback, and
  the size matrix in dark and light.

Design review sheets (cast, parts, colours, silhouettes, headwear, a 240 px
detail sheet and a 24–120 px size ladder, in dark and light) come from
`test/screenshots/avatar_screenshots_test.dart` (`make screenshots`).

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
