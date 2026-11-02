# Voice: Dictate (step 3 › G)

Plan: `docs/plans/evolve.md`, step 3 › G "dictation". Principle: **voice is local or
absent**. Dictation runs only through a verified on-device recognizer; where the phone
can't do that, the app says so in one line and offers Record or typing. The user's
words are never inserted, rewritten or summarised on their own: what was heard is
shown for review, and goes into the field only when the user taps **Insert**.

(The **Listen** half of voice, read aloud, is step 3 › H and documented separately.)

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
| `l10n_src/voice_en.arb` | Strings (prefix `voice`); `voice_fr.arb` / `voice_ar.arb` seeded for translators. |
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
  listening, review, unavailable, stopped early and Arabic, dark and light. Arabic
  letters show as boxes in test renders until the bundled Arabic font lands (step 3 ›
  I); the layout is right to left.
