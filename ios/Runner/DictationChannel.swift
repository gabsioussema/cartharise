import AVFoundation
import Flutter
import Speech

/// Dictation, on the phone only — the iOS side of
/// lib/services/dictation_platform.dart (PlatformDictation).
///
/// * `SFSpeechRecognizer` for the language, used only when
///   `supportsOnDeviceRecognition` is true, with
///   `requiresOnDeviceRecognition = true` on every request: audio is never
///   sent to Apple's servers, and there is no fallback to them. Without an
///   on-device recognizer for the language the answer is "unsupported" and the
///   app offers Record or typing instead.
/// * Speech recognition and microphone permission are asked for only when
///   dictation starts (after the user tapped Dictate); `availability` never
///   asks.
/// * Audio comes from `AVAudioEngine`'s input. A call or another app taking the
///   microphone ends the dictation as "interrupted"; what was heard stays the
///   user's (sent as the last partial text) for review in the app.
/// * Privacy: recognised text goes only to the Dart side over the channel.
///   Nothing is logged.
///
/// Channels: methods `app.cartharise/dictation` (availability {tag}, stop,
/// cancel); events `app.cartharise/dictation/events` (listened to with {tag};
/// maps {type: partial|final|level|error|ended, text?, level?, reason?}, then
/// the end of the stream).
///
/// Written without Xcode on the build Mac: compile-check with `make ios` on a
/// Mac with Xcode before release.
final class DictationChannel: NSObject, FlutterStreamHandler {
  static let methodChannelName = "app.cartharise/dictation"
  static let eventChannelName = "app.cartharise/dictation/events"

  private let methods: FlutterMethodChannel
  private let events: FlutterEventChannel
  private var session: DictationSession?

  init(messenger: FlutterBinaryMessenger) {
    methods = FlutterMethodChannel(name: Self.methodChannelName, binaryMessenger: messenger)
    events = FlutterEventChannel(name: Self.eventChannelName, binaryMessenger: messenger)
    super.init()
    methods.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    events.setStreamHandler(self)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "availability":
      let tag = (call.arguments as? [String: Any])?["tag"] as? String ?? ""
      result(Self.availability(tag))
    case "stop":
      session?.stop()
      result(nil)
    case "cancel":
      session?.cancel(notify: true)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Never asks for a permission: only says whether dictation could run.
  static func availability(_ tag: String) -> String {
    switch SFSpeechRecognizer.authorizationStatus() {
    case .denied, .restricted:
      return "noPermission"
    default:
      break
    }
    if AVAudioSession.sharedInstance().recordPermission == .denied {
      return "noPermission"
    }
    guard let locale = resolveLocale(tag),
          let recognizer = SFSpeechRecognizer(locale: locale) else {
      return "unsupported"
    }
    // On the device or not at all.
    return recognizer.supportsOnDeviceRecognition ? "available" : "unsupported"
  }

  /// The recognizer locale for [tag]: the same one, else the same language —
  /// in the phone's own region when it has one (fr-CA on a Canadian phone).
  static func resolveLocale(_ tag: String) -> Locale? {
    let supported = Array(SFSpeechRecognizer.supportedLocales())
    let wanted = tag.replacingOccurrences(of: "_", with: "-").lowercased()
    func normalized(_ locale: Locale) -> String {
      locale.identifier.replacingOccurrences(of: "_", with: "-").lowercased()
    }
    if let exact = supported.first(where: { normalized($0) == wanted }) {
      return exact
    }
    guard let language = Locale(identifier: tag).languageCode else { return nil }
    let same = supported
      .filter { $0.languageCode == language }
      .sorted { $0.identifier < $1.identifier }
    if same.isEmpty { return nil }
    for preferred in Locale.preferredLanguages {
      let phone = Locale(identifier: preferred)
      guard phone.languageCode == language, let region = phone.regionCode else { continue }
      if let match = same.first(where: { $0.regionCode == region }) {
        return match
      }
    }
    return same.first
  }

  // MARK: FlutterStreamHandler (one dictation per listen)

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    let tag = (arguments as? [String: Any])?["tag"] as? String ?? ""
    if session != nil {
      events(["type": "error", "reason": "busy"])
      events(["type": "ended"])
      events(FlutterEndOfEventStream)
      return nil
    }
    let current = DictationSession(sink: events) { [weak self] ended in
      if self?.session === ended { self?.session = nil }
    }
    session = current
    current.start(tag: tag)
    return nil
  }

  /// The app stopped listening (the sheet closed): stop quietly.
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    session?.cancel(notify: false)
    session = nil
    return nil
  }
}

/// One dictation: permissions, the on-device recognizer, partial text and
/// levels, then the final text or an error, then "ended".
final class DictationSession {
  private let sink: FlutterEventSink
  private let onEnd: (DictationSession) -> Void
  private let engine = AVAudioEngine()
  private var recognizer: SFSpeechRecognizer?
  private var request: SFSpeechAudioBufferRecognitionRequest?
  private var task: SFSpeechRecognitionTask?
  private var interruption: NSObjectProtocol?
  private var text = ""
  private var stopping = false
  private var ended = false
  private var tapInstalled = false
  private var lastLevelAt: TimeInterval = 0

  init(sink: @escaping FlutterEventSink, onEnd: @escaping (DictationSession) -> Void) {
    self.sink = sink
    self.onEnd = onEnd
  }

  /// Asks for speech recognition, then the microphone (only now: the user
  /// tapped Dictate), then listens.
  func start(tag: String) {
    SFSpeechRecognizer.requestAuthorization { status in
      DispatchQueue.main.async {
        guard !self.ended else { return }
        guard status == .authorized else {
          self.fail("noPermission")
          return
        }
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
          DispatchQueue.main.async {
            guard !self.ended else { return }
            guard granted else {
              self.fail("noPermission")
              return
            }
            self.begin(tag: tag)
          }
        }
      }
    }
  }

  private func begin(tag: String) {
    if stopping {
      finish()
      return
    }
    guard let locale = DictationChannel.resolveLocale(tag),
          let recognizer = SFSpeechRecognizer(locale: locale),
          recognizer.supportsOnDeviceRecognition else {
      fail("unsupported")
      return
    }
    self.recognizer = recognizer
    let request = SFSpeechAudioBufferRecognitionRequest()
    request.shouldReportPartialResults = true
    // On this phone only: never sent to Apple's servers.
    request.requiresOnDeviceRecognition = true
    self.request = request

    let audio = AVAudioSession.sharedInstance()
    do {
      try audio.setCategory(.record, mode: .measurement, options: .duckOthers)
      try audio.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      fail("busy")
      return
    }

    let input = engine.inputNode
    let format = input.outputFormat(forBus: 0)
    guard format.sampleRate > 0, format.channelCount > 0 else {
      fail("failed")
      return
    }
    input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
      request.append(buffer)
      let level = DictationSession.level(of: buffer)
      DispatchQueue.main.async { self?.sendLevel(level) }
    }
    tapInstalled = true
    engine.prepare()
    do {
      try engine.start()
    } catch {
      fail("failed")
      return
    }

    interruption = NotificationCenter.default.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: audio,
      queue: .main
    ) { [weak self] note in
      guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
            AVAudioSession.InterruptionType(rawValue: raw) == .began else { return }
      self?.fail("interrupted")
    }

    task = recognizer.recognitionTask(with: request) { [weak self] result, error in
      DispatchQueue.main.async {
        guard let self = self, !self.ended else { return }
        if let result = result {
          self.text = result.bestTranscription.formattedString
          if result.isFinal {
            self.finish()
            return
          }
          self.send(["type": "partial", "text": self.text])
        }
        guard let error = error else { return }
        if self.stopping {
          self.finish()
        } else {
          self.fail(DictationSession.reason(for: error as NSError, heard: !self.text.isEmpty))
        }
      }
    }
  }

  /// Stops listening: the final text follows (or, if it doesn't come, what
  /// was heard so far).
  func stop() {
    guard !ended, !stopping else { return }
    stopping = true
    guard task != nil else {
      // Still asking for permission: nothing was heard yet.
      finish()
      return
    }
    stopAudio()
    request?.endAudio()
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
      self?.finish()
    }
  }

  func cancel(notify: Bool) {
    guard !ended else { return }
    ended = true
    task?.cancel()
    teardown()
    if notify {
      send(["type": "ended"])
      sink(FlutterEndOfEventStream)
    }
    onEnd(self)
  }

  /// Ends with [reason]; the words heard before it were already sent as
  /// partial text and stay the user's.
  private func fail(_ reason: String) {
    guard !ended else { return }
    ended = true
    task?.cancel()
    teardown()
    send(["type": "error", "reason": reason])
    send(["type": "ended"])
    sink(FlutterEndOfEventStream)
    onEnd(self)
  }

  /// Ends with the whole text for review (or "nothing heard").
  private func finish() {
    guard !ended else { return }
    ended = true
    task?.cancel()
    teardown()
    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      send(["type": "error", "reason": "noSpeech"])
    } else {
      send(["type": "final", "text": text])
    }
    send(["type": "ended"])
    sink(FlutterEndOfEventStream)
    onEnd(self)
  }

  private func stopAudio() {
    if engine.isRunning { engine.stop() }
    if tapInstalled {
      engine.inputNode.removeTap(onBus: 0)
      tapInstalled = false
    }
  }

  private func teardown() {
    stopAudio()
    request = nil
    task = nil
    recognizer = nil
    if let observer = interruption {
      NotificationCenter.default.removeObserver(observer)
      interruption = nil
    }
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  private func send(_ event: [String: Any]) {
    sink(event)
  }

  /// At most ten levels a second: a calm meter, not a flood.
  private func sendLevel(_ level: Double) {
    guard !ended, !stopping else { return }
    let now = ProcessInfo.processInfo.systemUptime
    if now - lastLevelAt < 0.1 { return }
    lastLevelAt = now
    send(["type": "level", "level": level])
  }

  /// The buffer's loudness, 0 (−50 dB or quieter) to 1 (0 dB).
  static func level(of buffer: AVAudioPCMBuffer) -> Double {
    guard let samples = buffer.floatChannelData?[0] else { return 0 }
    let count = Int(buffer.frameLength)
    if count == 0 { return 0 }
    var sum: Float = 0
    for i in 0..<count { sum += samples[i] * samples[i] }
    let rms = (sum / Float(count)).squareRoot()
    let decibels = 20 * log10(max(rms, 0.000_001))
    return Double(min(max((decibels + 50) / 50, 0), 1))
  }

  /// Nothing heard (Apple's "no speech" codes) or anything else.
  static func reason(for error: NSError, heard: Bool) -> String {
    let noSpeechCodes = [203, 1110]
    if !heard, error.domain == "kAFAssistantErrorDomain", noSpeechCodes.contains(error.code) {
      return "noSpeech"
    }
    return "failed"
  }
}
