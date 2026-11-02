# Voice: Dictate and Listen (step 3 › G and H)

Plan: `docs/plans/evolve.md`, step 3 › G "dictation". Principle: **voice is local or
absent**. Dictation runs only through a verified on-device recognizer; where the phone
can't do that, the app says so in one line and offers Record or typing. The user's
words are never inserted, rewritten or summarised on their own: what was heard is
shown for review, and goes into the field only when the user taps **Insert**.

The other half is **Listen** (step 3 › H, [below](#listen)): lessons and questions read
aloud with the phone's own voices, and the user's own words only after an explicit tap.

## Dictate

### Where

A quiet **Dictate** link (microphone icon and the word) sits at the start of the line
under each field where people write at length:

| Field | Screen | Record instead |
|---|---|---|
| The answer | Reset › a guided prompt (`GuidedPromptScreen`) | no |
| The note body | Journal › a note (`JournalEntryScreen`) | yes, onto the note (a new note is created the same way as a photo creates it) |
| The note | Playground › Try (`TryScreen`) | no |
| A try's note | Collection › a try (`ExperimentEntrySheet`) | yes, onto the try |
| What you tried, what you learned | Battle log › an attempt (`AttemptSheet`) | yes, onto the attempt |
| A day's note | 30-day path › a day (`PathDayScreen`, `AutosaveTextField(dictation: true)`) | no |
| Wins, Friction, Next experiment | Journal › weekly review (`ReviewScreen`) | no |

Where a screen has several fields, each link is named for screen readers
("Dictate: Wins").

### User flow

1. **Tap Dictate.** The sheet opens and the phone is asked whether it can dictate the
   app's language **on the device** (`Dictation.availability`, which never asks for a
   permission). If it can, listening starts at once: the tap is the start. The system
   may ask for the microphone (and, on iOS, speech recognition) only now.
2. **Listening.** "Listening" with a dot (the word carries the state, never the colour
   alone), "Recognised on this phone. Nothing is sent.", the words heard so far in a box
   like the field they will be checked in ("Speak. Your words appear here." until then),
   a calm level meter that moves only with the voice, **Stop** and **Cancel**. Screen
   readers hear "Listening. Tap Stop when you're done."; the words box is labelled
   "Heard so far" and is not a live region (it would read every change).
3. **Stop** → "Finishing…" → **review**: the whole text in an editable field ("Dictated
   text · Edit it if you like. It goes in only when you tap Insert."), announced as
   "Done listening. Check the text, then Insert." Nothing has touched the field yet.
4. **Insert** puts the reviewed text into the field **at the cursor**, and nothing else
   changes (`insertDictation`):
   * at a collapsed cursor, there; with words selected, right after them (they are
     kept, never replaced); with no cursor yet, at the end;
   * one space only where the text would otherwise run into a word;
   * the cursor lands after the inserted text; "Text inserted." is announced.
   The host autosaves it like typing (`onInserted`): the reset answer, the note, the
   Try draft, the path day and the weekly review save on their own; a try's note and an
   attempt save with their **Save** button, as typed text does.
5. **Discard** (and **Cancel** once words were heard) asks first: "Discard this text?
   It won't be added." · **Keep** / **Discard**. Nothing is inserted.

### When dictation can't run: one honest line

| Why | Line | Try again |
|---|---|---|
| No on-device recognizer for the language (`unsupported`) | "Dictation in this language isn't available on this phone." | no |
| The language pack isn't on the phone (`needsModel`) | "To dictate, add this language for offline speech in your phone's settings." | yes |
| Microphone or speech permission off (`noPermission`) | "Microphone or speech access is off. Allow it in Settings to dictate." | yes |
| System too old: Android before 12 (`tooOld`) | "Dictation needs a newer system version on this phone." | no |

Under the line: **Record instead** (where the field's entry holds voice notes; opens the
recorder, which keeps the recording on that entry, separate from any text) and **Type
instead** (closes the sheet and focuses the field), then **Try again** and **Close**.

### Failures while listening

* **Words were heard** (a call took the microphone, an error): they are kept and shown
  for review with "Dictation stopped early. Here's what was heard." Never dropped.
* **Nothing heard**: the reason in one line: "Nothing was heard. Try again, or type
  instead." / "Dictation stopped: a call or another app took the microphone." /
  "Dictation is busy. Try again in a moment." / "Dictation stopped. Try again, or type
  instead." (or the availability lines above), with Try again and Type instead.
* **The app goes to the background** while listening: dictation stops and the words
  wait for review when the user is back.
* **Back** while listening stops (the words go to review); Back in review asks before
  discarding. The sheet can't be swiped away.
* **Closed from elsewhere** while listening: the microphone stops; nothing is inserted.
* If the recognizer never sends its final text after Stop, what was heard so far is
  kept for review after a few seconds.

## Platforms: on the device only

`PlatformDictation` (`lib/services/dictation_platform.dart`) talks to the phone through
a method channel `app.cartharise/dictation` (`availability {tag}`, `stop`, `cancel`) and
an event channel `app.cartharise/dictation/events` (listened to with `{tag}`; maps
`{type: partial|final|level|error|ended, …}`, then the end of the stream). Unknown
availability names are `unsupported`, unknown failures `failed`, unknown events are
ignored. Without the channel (tests, desktop) every language is `unsupported`. The
language tag is the app's locale (`en`, `fr`, `ar`); the platform picks the matching
recognizer language, in the phone's own region when it has one (`fr-CA` on a Canadian
phone).

### Android (`android/app/src/main/kotlin/…/DictationPlugin.kt`)

* Android 12+ (API 31) only: `SpeechRecognizer.isOnDeviceRecognitionAvailable`, then
  `SpeechRecognizer.createOnDeviceSpeechRecognizer`. **Never** `createSpeechRecognizer`
  (the default recognizer may send audio to a server) and never `EXTRA_PREFER_OFFLINE`
  as a substitute. Before Android 12: `tooOld`.
* Language support (Android 13+): `checkRecognitionSupport` — installed → `available`;
  pending or downloadable → `needsModel`; otherwise `unsupported`. When the recognizer
  can't tell (Android 12, an error, no lists, no answer in 3 s), dictation is tried on
  the device and a "language not supported / unavailable" error is reported as such.
* `RECORD_AUDIO` (already declared for voice notes) is asked for only when dictation
  starts. Refused for good (Android won't ask again) → `noPermission`.
* Listens until Stop: after each pause the result is kept and listening resumes; three
  silent pauses in a row end it with what was heard. Levels at most ten a second.
* Registered in `MainActivity.configureFlutterEngine`. The manifest's `<queries>` lists
  `android.speech.RecognitionService` (package visibility); there is still no `INTERNET`.

### iOS (`ios/Runner/DictationChannel.swift`, registered in `AppDelegate`)

* `SFSpeechRecognizer(locale:)` only when `supportsOnDeviceRecognition`, and every
  request sets `requiresOnDeviceRecognition = true`; otherwise `unsupported`.
* Speech recognition and microphone permission are asked for only on start;
  `NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription` say so
  (Info.plist). Denied or restricted → `noPermission`.
* Audio from `AVAudioEngine`; an audio-session interruption (a call) ends it as
  `interrupted`, keeping what was heard.
* Written without Xcode on the build Mac: **not compiled here**. Run `make ios` on a Mac
  with Xcode before release (the file is in the Runner target's Sources).

### Privacy

* Audio and text never leave the phone; no new permission or dependency.
* Recognised text travels only from the platform to the sheet; nothing is logged on
  either side (tests check there is no logging call in the platform code).
* A recording made instead of dictating is kept as a voice note, never transcribed.

## Code map

| File | What |
|---|---|
| `lib/services/dictation.dart` | The contract (`Dictation`, events, availability, failures). |
| `lib/services/dictation_platform.dart` | `PlatformDictation` and the channel decoding. |
| `lib/ui/voice/dictate_button.dart` | `DictateButton`, `insertDictation`, `keepRecordingOn`. |
| `lib/ui/voice/dictation_sheet.dart` | `showDictationSheet` (listening, review, honest lines). |
| `l10n_src/voice_{en,fr,ar}.arb` | Strings (prefix `voice`); French and Arabic are drafts (`docs/translations.md`). |
| `android/…/DictationPlugin.kt`, `MainActivity.kt` | Android on-device recognizer. |
| `ios/Runner/DictationChannel.swift`, `AppDelegate.swift`, `Info.plist` | iOS on-device recognizer. |

## Tests

* `test/ui/dictation_test.dart`: insertion at the cursor (unit); listening → partial
  text → level → Stop → review → Insert at the cursor, never on its own; Discard and
  Cancel ask first; Insert off for empty text; each availability state (one line,
  Record or type instead, Try again only where it can help, nothing started); Record
  instead keeps a voice note; refused at start; failures with and without words
  heard; Stop with nothing heard; the app hidden; Back; closed from elsewhere; screen
  reader labels, announcements and tap targets; Arabic right to left; the size matrix
  in dark and light, and right to left at 320 dp / 200 %; every hook saves exactly the
  inserted words.
* `test/dictation_platform_test.dart`: channel decoding; `PlatformDictation`
  availability, start / stop / cancel, busy, a missing or failing channel; the
  on-device-only guards in the Kotlin, Swift, manifest, Info.plist and Xcode project.
* `test/screenshots/dictation_screenshots_test.dart` (tag `screenshots`): the link,
  listening, review, unavailable, stopped early and Arabic, dark and light (Arabic in
  the bundled Noto Sans Arabic UI, right to left).

## Listen

Plan: step 3 › H "read-aloud". **Listen** reads a lesson or a reset question aloud with
the phone's own text-to-speech; **Listen to my answer** and **Listen to my note** read the
user's own words, and only on that explicit tap. Nothing is ever read on its own.

### Where

| Link | Screen | Reads |
|---|---|---|
| **Listen** | Awakening › a lesson (`LessonScreen`, under the read tag) | title, summary, explanation, example, the "lens, not a verdict" note |
| **Listen** | Reset › a guided prompt (beside "What does this mean?") | the context line and the question as shown (the softer wording when chosen) |
| **Listen to my answer** | Reset › a guided prompt (under Dictate, once the answer has words) | the answer exactly as typed (trimmed at the ends only) |
| **Listen to my note** | Journal › a note (under Dictate, once the note has words) | the title and the note |

### How it behaves (`lib/ui/voice/listen_button.dart`, `ListenButton`)

* A quiet link (speaker icon and the word). While reading it turns into **Stop
  reading** with a short line under it: "Can't hear it? Check the volume and silent
  mode." Stop ends it at once.
* **One at a time.** Starting another Listen stops the first (its link turns back
  into Listen). **Dictate** stops it too, so the microphone never hears it.
* **Stops by itself** when its page closes, when another page covers it or its tab is
  left (`TickerMode`), and when the app is hidden. While reading it is kept alive in the
  lazy list, so scrolling away doesn't stop it.
* **Hidden** where the phone can't read the language aloud (`ReadAloud.available`,
  asked once per language). A failure is one honest line under the link, and Listen
  stays for another try: no voice for the language, Listen unavailable, the phone on
  silent ("Turn the sound on, or use headphones."), or anything else ("Couldn't read
  this aloud. Try again.").
* **Language:** the app's language for the user's words and for translated content; an
  item still in English (the content falls back per item) is read with an English voice
  (`contentListenTag`, from `coverageFor`).
* **Screen readers** hear "Reading aloud." and "Stopped reading."; the link is one
  button node named by its word.

### Platforms (`lib/services/read_aloud_platform.dart`, channel `app.cartharise/read_aloud`)

* The text is cut into pieces (one per paragraph, at most 1000 characters, cut after a
  sentence, else at a space; never a word lost) and handed to the engine; the platform
  calls back `done` with the text's id (a replaced text's late `done` is ignored).
* **Android** (`ReadAloudChannel.kt`, created in `MainActivity.configureFlutterEngine`,
  released in `cleanUpFlutterEngine`): the system `TextToSpeech`; only installed voices
  that need no network (`isNetworkConnectionRequired == false`). Media volume, transient
  ducking audio focus, stopped when the focus is lost (a call). On silent with sound on
  the phone's speaker nothing plays and the app says so; headphones still work. A
  `TTS_SERVICE` `<queries>` entry, no permission.
* **iOS** (`ReadAloudChannel` in `AppDelegate.swift`): `AVSpeechSynthesizer` with the
  phone's voices (novelty and personal voices left out). On the speaker the `.ambient`
  category, which the Ring/Silent switch mutes; with headphones `.playback` /
  `.spokenAudio` with ducking. The app's audio session is put back afterwards; an
  interruption stops it. **Not compiled here** (no Xcode on the build Mac).
* Errors carry a reason only (never the platform's message, which could quote text);
  nothing is logged on either side.

### Code map

| File | What |
|---|---|
| `lib/services/read_aloud.dart` | The contract (`ReadAloud`, failures). |
| `lib/services/read_aloud_platform.dart` | `PlatformReadAloud`, `speechChunks`, silent mode. |
| `lib/ui/voice/listen_button.dart` | `ListenButton`, `contentListenTag`. |
| `l10n_src/listen_{en,fr,ar}.arb` | Strings (prefix `listen`); French and Arabic are drafts. |
| `android/…/ReadAloudChannel.kt`, `MainActivity.kt` | Android text-to-speech. |
| `ios/Runner/AppDelegate.swift` | iOS speech synthesis. |

### Tests

* `test/ui/listen_test.dart`: nothing read before the tap; the lesson read in the app's
  language and Stop reading; back to Listen when the voice ends; stopped when the page
  closes, is covered, or the app is hidden; kept reading while scrolled away; hidden
  without a voice; each failure line and a retry; silent mode; screen-reader names;
  the question and the answer (exactly as typed, one at a time); no answer → no link;
  Dictate stops Listen; the note; French content read in French and an untranslated
  item in English; the size matrix dark / light, English and Arabic, while reading;
  tap targets, labels and contrast; right to left.
* `test/read_aloud_platform_test.dart`: `speechChunks` (paragraphs, sentence and space
  cuts, a huge word, Arabic punctuation, no word lost); the channel calls, `done`, a
  late `done` ignored, stop and dispose, every error code (silent mode recognisable, the
  message never kept), no platform side → unavailable; the offline-voice, no-logging and
  no-permission guards in the Kotlin, Swift and manifest.
* `test/ui/evolve3_journey_test.dart`: Listen to a French lesson and to a dictated
  answer inside the step 3 journey.
* `test/screenshots/listen_screenshots_test.dart` (tag `screenshots`): a lesson,
  reading, a question with Listen to my answer, no voice, French and Arabic.
