# Translations

Cartharise ships in **English** (the source), **French** and **Arabic** (right to left).

> **French and Arabic are drafts.** Every French and Arabic string and content item is a
> draft until a native speaker has reviewed it. Do not release a build in French or
> Arabic before that review. Record it in the table at the end of this page.

## What gets translated, and where

| What | Source (English) | Translation | Falls back |
|---|---|---|---|
| Interface strings (buttons, titles, errors, reminders, help) | `l10n_src/<area>_en.arb` | `l10n_src/<area>_fr.arb`, `l10n_src/<area>_ar.arb` | per **key**, to the English text, when you run `make l10n` |
| Content (lessons, prompts with their softer wording and examples, the 30-day path, experiments, notices, credit notices) | `lib/content/en.dart` | `lib/content/fr.dart`, `lib/content/ar.dart` | per **item**, by permanent id, to the English item |

The user's own words are never translated, rewritten or summarised. Switching language
changes only `AppSettings.language`. Answers, logs and links are keyed by permanent ids,
so they keep working in every language.

## The language setting

`AppSettings.language` is `system | en | fr | ar`. Files without it, and names from a newer
version, load as `system`. `resolveLanguage` (`lib/domain/language.dart`) turns it into
the language shown:

* an explicit choice is used as it is;
* **system** ("Same as phone") picks the first of the phone's preferred languages that
  Cartharise ships, and English if there is none. For example, `de, fr` gives French and
  `ja` gives English. It follows the phone live: `CarthaApp` forwards `didChangeLocales`
  to `AppState.setDeviceLanguages`.

`AppState.language` holds the result and is never `system`. `MaterialApp.locale`,
`AppState.content`, the text direction and the theme fonts all follow it. The Material,
Widgets and Cupertino localisations make Arabic right to left on their own, so screens
only need `EdgeInsetsDirectional`, `AlignmentDirectional` and `start`/`end`.
`AppState.setLanguage(language)` changes the setting and re-words the check-in
notifications, which carry prompt titles.

The platforms also declare the three languages. iOS lists them in `CFBundleLocalizations`
(`ios/Runner/Info.plist`). Android 13+ lists them in its per-app language setting
(`android/app/src/main/res/xml/locales_config.xml`). If the user picks a language there,
"Same as phone" follows it.

## Interface strings

```
l10n_src/today_en.arb   ← English: keys and @metadata (placeholders, descriptions)
l10n_src/today_fr.arb   ← {"@@locale": "fr", "todayTitle": "Aujourd'hui", …}
l10n_src/today_ar.arb   ← {"@@locale": "ar", "todayTitle": "اليوم", …}
```

`make l10n` runs `dart run tool/merge_arb.dart`, then `flutter gen-l10n`. Run it after
every change.

* `lib/l10n/app_en.arb` is built from the `*_en.arb` fragments. It is the template: every
  key and its metadata. Each language then gets its own `lib/l10n/app_<lang>.arb` with
  **every** English key in it. A key with no translation, or with an empty one, uses the
  English text. The merge counts these keys and prints them each run:
  `0/1189 strings translated (0%), 1189 fall back to English`.
* `dart run tool/merge_arb.dart --report` (or `make l10n-report`) prints coverage per
  language and area. Each area shows as `complete`, `not started`, or
  `in English: key1, key2, …`.
* **The merge fails** (and `make l10n` stops) when a translation:
  * changes placeholders. It must use exactly English's names: `Bonjour {name}` for
    `Hello {name}`.
  * turns a plural or a select into something else. A plural stays a plural with an
    `other` case, but its cases may differ: Arabic uses
    `zero{…} one{…} two{…} few{…} many{…} other{…}`. A select keeps English's cases.
  * has unbalanced braces;
  * translates a key that English doesn't have (a typo, or a key that was removed);
  * says another `@@locale`, defines a key twice, or isn't valid JSON.
* Translations hold only `"key": "text"` pairs. Placeholder types and descriptions come
  from English. Any `@key` metadata in a translation is ignored.
* `test/merge_arb_test.dart` fails when `lib/l10n/` is stale, when an area lacks its
  `_fr`/`_ar` fragment, or when a fragment isn't named `<area>_<lang>.arb` with a shipped
  language.

**A new area** adds three fragments: `<area>_en.arb`, plus `<area>_fr.arb` containing
`{"@@locale": "fr"}` and `<area>_ar.arb` containing `{"@@locale": "ar"}`. The new
strings then show in English until someone translates them.

## Content

`lib/content/fr.dart` and `lib/content/ar.dart` each hold a `ContentTranslation`, keyed by
permanent id. `translateContent(englishContent, translation)` lays it over English. The
classes are in `lib/domain/content_translation.dart`:

```dart
const ContentTranslation frenchTranslation = ContentTranslation(
  languageCode: 'fr',
  version: 1,
  prompts: {
    'morning.01': PromptText(
      title: '…', question: '…', context: '…', help: '…', example: '…',
      softerQuestion: '…', // required when English has a softer wording
    ),
  },
  lessons: {'lesson.01': LessonText(/* …, check: CheckText(options: [3 options, English order]) */)},
  thirtyDays: {1: PathDayText(title: '…', prompt: '…', hint: '…' /* if English has one */)},
  experiments: {'try.terrain.01': ExperimentText(title: '…', steps: ['…'])},
  notices: {'notice.01': NoticeText(title: '…')},
  credit: CreditText(publishedOn: '…', independenceNotice: '…', paraphraseNotice: '…'),
);
```

* **Only words.** The structure always comes from English and is never translated: ids,
  order, phases, groups, the Compass mapping, related prompts, a check's correct answer
  (options keep English's order), chapters, minutes, glyphs, what a notice opens, default
  times, source references, and the article's title, author and links.
* **Whole items only.** An item is used only when every text the English item has is
  there and non-empty: the softer wording, the hint, a check with as many options as
  English, and one to three experiment steps. Otherwise the **whole** item stays in
  English, so a prompt never shows a French question with an English example.
* **Never new items.** An id English doesn't have is ignored and reported as `unknown`.
* **Coverage.** `coverageFor(AppLanguage.fr)` in `lib/content/content.dart` returns a
  `ContentCoverage` for tests and docs. It lists `translated`, `incomplete` (shown in
  English) and `missing` ids per `ContentKind`, plus `unknown`, `ratio` and `complete`.
  Path days appear as `path.07` and the credit as `credit`.
* Bump the translation's `version` on any wording change.
* Same writing rules as English. Paraphrase the source and never reproduce it. Keep it
  short and calm, action first, one or two lines. No guilt, streaks, scores or diagnoses.

## Fonts and right to left

* `CarthaFonts` (`lib/ui/theme/cartha_fonts.dart`, a theme extension) holds the
  families per language. For English and French it is **Cinzel** for display and
  headline, **Inter** for the rest. For **Arabic** it is one Arabic family for every style
  (display and headline too, never Cinzel) with no added letter spacing, because spacing
  pulls joined letters apart.
* `CarthaFonts.arabicFamily` is the bundled Arabic font: **Noto Sans Arabic UI**
  (`assets/fonts/NotoSansArabicUI-{Regular,SemiBold,Bold}.ttf`, from
  [notofonts](https://github.com/notofonts/notofonts.github.io), SIL OFL 1.1 in
  `assets/fonts/NotoSansArabicUI-OFL.txt`, registered in `lib/ui/you/font_licenses.dart`).
  The "UI" cut has Latin-compatible vertical metrics (1.07 + 0.29 em, close to Inter's
  0.97 + 0.24), so an Arabic line is as tall as a Latin one and mixed lines share a
  baseline; the plain Noto Sans Arabic (2.1 em tall) would double every line. Weight 500
  falls back to Regular. If the slot were `null`, Arabic would use Inter and the phone's
  own Arabic font.
* The Arabic font has no Latin letters, quotes, `+`, `/` or `…`, so every Arabic text
  style falls back to **Inter** (`CarthaFonts.fallback`): "Cartharise", "XP" and names
  inside Arabic sentences look like the rest of the app.
* In widgets, write a local `letterSpacing` as `CarthaFonts.of(context).spacing(1.2)`. It
  becomes 0 for Arabic. Write emphasis as `fontStyle: CarthaFonts.of(context).italic`:
  Arabic has no italic, so it stays upright instead of a slanted fake.
* Themes built inside a screen (`OnHeroTheme`, the boot error) take
  `fonts: CarthaFonts.of(context)`, or hero cards would switch back to Inter and Cinzel.
* Test right to left with `pumpCartha(data: onboardedData(settings: const AppSettings(language: AppLanguage.ar)))`.
  To test "Same as phone", set `tester.platformDispatcher.localesTestValue` before pumping.

## French (draft)

> **Draft, needs native review.** Every French string (`l10n_src/*_fr.arb`)
> and content item (`lib/content/fr.dart`) was written for step 3 without a
> native speaker's review. A native French speaker must read all of it, in
> the app, before any release in French.

Coverage: 1193/1193 strings and every content item (7 lessons, 30 prompts
with their softer wording and examples, 30 path days, 15 experiments, 7
notices, the credit). `test/french_test.dart` keeps it at 100 %.

**Voice.** *Vouvoiement* throughout: calm and respectful, never *tu*. Plain,
warm, short; action first. Wording avoids gendering the reader ("quand vous
le souhaitez", not "quand vous serez prêt"; "Vous voici en Italie", not
"Vous êtes entré"); the examples a fictional "quelqu’un" writes in the first
person may agree either way.

**Typography** (checked by `test/french_test.dart`):

* a no-break space (U+00A0) before `:` `;` `!` `?` and inside `« »`. U+00A0,
  not the narrow U+202F, because Cinzel (the headline font) has no U+202F;
* the typographic apostrophe `’`, never `'`; quotes `« »`, with `“ ”` for a
  quote inside a quote;
* times as French writes them ("votre pause de 21 h"), file sizes in Ko /
  Mo / Go;
* counts that English writes "3 of 7 read" become "Lues : 3 sur 7", so the
  noun never disagrees with 0 or 1; plurals use `one{…}` (0 and 1 in French)
  and `other{…}`.

**Glossary** (keep it consistent):

| English | French |
|---|---|
| Today · Reset · Compass · Journal · You | Aujourd’hui · Recentrage · Boussole · Journal · Vous |
| The Reset / a reset | Le Recentrage / un recentrage |
| The Mirror · The Vision · The Interrupt · The Breakthrough | Le Miroir · La Vision · L’Interruption · La Percée |
| Morning · Daytime · Evening | Matin · Journée · Soir |
| daytime check-in | pause (de la journée) |
| softer wording | version plus douce |
| The Awakening · lesson | L’Éveil · leçon |
| Life Compass · anti-vision · vision | Boussole de vie · anti-vision · vision |
| one-year mission · one-month project · daily levers · boundaries | mission d’un an · projet du mois · leviers quotidiens · limites |
| quest · milestone · board (Later, Ready, Doing, Done) | quête · jalon · tableau (Plus tard, Prêtes, En cours, Faites) |
| 30-day path (Observe, Experiment, Build, Adjust) | parcours de 30 jours (Observer, Expérimenter, Construire, Ajuster) |
| weekly review · Look back | bilan de la semaine · Regards |
| Campaign · Playground | Campagne · Terrain de jeu |
| Notice · Try · Make it yours | Remarquer · Essayer · À votre image |
| experiment · attempt · Battle log | expérience · essai · Carnet de bataille |
| achievement · reward pick · extra | haut fait · récompense à choisir · extra |
| XP · level | XP · niveau |
| Traveler (no name given) | âme voyageuse |
| Record (voice note) · Save | Enregistrer · Enregistrer (the recorder's stop button says "Arrêter et garder") |

The Today glance tiles are narrow: their French titles are "Réflexion" and
"Jeu" (not "Recentrage" and "Campagne", which broke mid-word at 390 dp).
French must never use *série*, *score*, *échec*/*échoué*, *en retard*,
*manqué*, *paresse*, *culpabilité* or *auriez dû* (the test lists them);
"diagnostic" appears only in the two "not therapy" notices, as in English.

The language picker shows each language by its own name (English, Français,
العربية) in every language: those names are not in the ARB files.

## Adding a language

1. Append it to `AppLanguage` and `kAppLanguages` (`lib/domain/language.dart`), and to
   `kArbLanguages` (`tool/merge_arb.dart`).
2. Seed `l10n_src/<area>_<lang>.arb` with `{"@@locale": "<lang>"}` for every area, then run
   `make l10n`.
3. Add `lib/content/<lang>.dart` (an empty `ContentTranslation` plus `translateContent`),
   and wire it into `contentFor` and `kContentTranslations`.
4. Add the language to `CFBundleLocalizations` (iOS) and `locales_config.xml` (Android).
   If its script needs a font, add a `CarthaFonts.forLanguage` case.
5. Add it to the review table below and mark it **draft**.

## Review status

| Language | Strings | Content | Native review |
|---|---|---|---|
| English | source | source | n/a |
| French | **draft**, 100 % (1193/1193) | **draft**, every item (100 %) | **not yet: required before release** |
| Arabic | **draft**, 1189/1189 (100 %) | **draft**, every item (100 %) | **not yet: required before release** |

## Arabic (draft: native review required)

> **Draft.** Every Arabic string and content item was written as a first draft (Modern
> Standard Arabic) and has **not** been reviewed by a native speaker. A native review,
> ideally with someone who knows reflective or therapeutic writing, is required before
> any release in Arabic. Pay special attention to the sensitive prompts (morning 04–11,
> evening 01–03), the support and crisis texts (`you_ar.arb`, `reset_ar.arb`) and the
> lessons' "A lens, not a verdict" notes.

Coverage: `l10n_src/*_ar.arb` translate all 1189 keys (`make l10n-report`), and
`lib/content/ar.dart` translates every lesson, prompt (with its softer wording), path day,
experiment, notice and the credit notices (`coverageFor(AppLanguage.ar).complete`).
`test/ui/rtl_test.dart` fails if either drops below 100 %.

### How the Arabic is written

* **Warm and plain**, short sentences, action first, the same calm as English. Nothing
  promises a fixed life; no guilt, streaks, scores, points or diagnoses (the test
  checks Arabic equivalents: سلسلة، فشل، كسول، نقاط، درجة، تشخيص، …).
* **The reader's gender is never assumed.** Arabic marks gender on verbs and
  adjectives, so the texts use forms that read the same for everyone:
  * buttons and steps as verbal nouns: «حفظ», «إضافة مهمّة», «اختيار تاريخ»;
  * "you can …" as «يمكنك» + a verbal noun: «يمكنك تخطّي أي سؤال»;
  * the past tense, which is written the same for both: «ما الذي جرّبته؟»;
  * the "-ك" suffix and a third-person verb: «ما الذي يهمّك؟», «ما الذي يزعجك؟»;
  * nouns instead of "you want": «الحياة المنشودة», «المستقبل المرفوض»;
  * "let's" for starting: «لنبدأ».
  Examples in prompts alternate «قد يكتب أحدهم» and «قد تكتب إحداهن».
* **Achievements** are medals named after a quality («وسام الملاحظة»), not a
  gendered title ("The Observer").
* **Plurals** use Arabic's six categories (`zero one two few many other`): «إجابتان»,
  «3 إجابات», «11 إجابة». Where English interpolates a count without a plural, the
  Arabic avoids number agreement: «الأسئلة الأساسية المُجاب عنها: 3 من 27».
* **Digits** are Western (0–9) everywhere, dates included: `CarthaApp` calls
  `useWesternDigits()` (`lib/app_locale.dart`), because the 'ar' date symbols would
  otherwise print «٣ نوفمبر» next to «20 دقيقة».
* **Punctuation**: «،» «؛» «؟», quotes «…» (‹…› inside). `.zip`, `.ics` and `+20 XP`
  start with an invisible left-to-right mark (`\u200e`) so the dot and the plus stay in
  front.
* **Kept in Latin letters**: Cartharise, XP, Dan Koe (as in the credit line), X,
  findahelpline.com, font names. The article's title, author and links stay English.

### Glossary

| English | Arabic |
|---|---|
| Today · Reset · Compass · Journal · You | اليوم · إعادة ضبط · البوصلة · اليوميات · أنت |
| the reset · check-in | إعادة الضبط · وقفة |
| morning · daytime · evening | الصباح · النهار · المساء |
| anti-vision · vision | الرؤية المضادّة · الرؤية |
| one-year mission · one-month project | مهمّة السنة · مشروع الشهر |
| daily levers · boundaries (constraints) | الروافع اليومية · الحدود |
| quest / task · milestone | مهمّة · محطة |
| note · weekly review | ملاحظة · مراجعة أسبوعية |
| the Awakening · lesson | اليقظة · درس |
| softer wording | صياغة ألطف |
| Campaign · Playground · Collection | الحملة · ساحة اللعب · التذكارات |
| Notice · Try · Make it yours | انتباه · تجربة · على طريقتك |
| XP · level · achievement · battle log | الخبرة (XP) · مستوى · إنجاز (وسام) · سجلّ المعارك |
| avatar · motto | الصورة الرمزية · عبارتك |
| Traveler (default name) | رحّالة |

### Right to left

* Layouts mirror through `Directionality` (`EdgeInsetsDirectional`,
  `AlignmentDirectional`, `start`/`end`); the board's lanes, the lesson strip and the
  tabs start at the right.
* **Arrows and chevrons** mirror themselves: every directional Material icon the app
  uses (`arrow_forward`, `arrow_back`, `chevron_right`, `redo`, `open_in_new`) has
  `matchTextDirection` (tested).
* **Hannibal's route** (`CampaignRouteMap`) reads right to left: Carthage at the right
  edge, the walked line growing leftwards, the avatar above the current stop.
* **Kept as drawn** (pictures of things, not reading order): the scenes, lesson
  illustrations, glyphs, badges, the avatar and the emblem; the progress ring fills
  clockwise from the top like a clock; the wordmark is Latin lettering.
* **Swipes**: onboarding's swipe already follows the direction (swipe right = next in
  Arabic). The board moves cards by drop target or the Move menu, not by direction.
* **Eyebrows** (`toUpperCase` + letter spacing) get no spacing in Arabic, and
  italic placeholders («لم يُكتب بعد») stay upright.
* **The user's words keep their own direction** (`textDirectionOf`,
  `lib/ui/widgets/bidi.dart`, first strong letter): quest titles (list, board, Today) and
  journal rows. An English quest in the Arabic app reads "Read 10 pages of «Dune»"; an
  Arabic note in the English app reads right to left. Text fields and the other places
  that show the user's words still use the app's direction (see "Known gaps").

### Known gaps (for review)

* Text fields (answers, notes, the Compass) take the app's direction, not the typed
  text's: English typed in the Arabic app is right-aligned and a final "." may show at
  the start until the line has an Arabic letter.
* The progress ring is not mirrored (a deliberate clock-wise choice; review with
  native readers).
* Strings added by other step-3 areas after this translation (language picker,
  dictation, Listen) show in English until `_ar.arb` gets them; `make l10n-report`
  lists them.
