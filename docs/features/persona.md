# Persona: your strategist

The user composes an avatar (`Avatar` in `lib/domain/persona.dart`) and sees
it in You, the Campaign and Today. Plan and contracts: `docs/plans/persona.md`.

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
