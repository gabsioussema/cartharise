import AVFoundation
import Flutter
import UIKit
import UserNotifications
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Listen (step 3): the phone's text-to-speech, see ReadAloudChannel.
  private var readAloud: ReadAloudChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Check-in reminders (flutter_local_notifications): show them while
    // Cartharise is open and deliver taps to the app.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Needed so notification actions can reach plugins in their own isolate.
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerStorageChannel(messenger: engineBridge.applicationRegistrar.messenger())
    // Dictation through the phone's on-device recognizer only (step 3,
    // DictationChannel.swift).
    dictation = DictationChannel(messenger: engineBridge.applicationRegistrar.messenger())
    // Listen: the phone's own voices (ReadAloudChannel, below).
    readAloud = ReadAloudChannel(messenger: engineBridge.applicationRegistrar.messenger())
  }

  /// Kept for the app's lifetime (it answers the dictation channels).
  private var dictation: DictationChannel?

  /// Privacy: the user's writing, photos and recordings stay on this phone.
  /// iOS includes Library/Application Support in iCloud and computer
  /// backups by default, so after every save the Dart side
  /// (lib/data/backup_exclusion.dart) asks to mark the data folder — and the
  /// attachments folder inside it — as excluded from backup. Paths only; no
  /// user text crosses this channel.
  private func registerStorageChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(
      name: "app.cartharise/storage",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "excludeFromBackup", let path = call.arguments as? String else {
        result(FlutterMethodNotImplemented)
        return
      }
      do {
        var url = URL(fileURLWithPath: path)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "exclude_failed",
            message: "Could not exclude the data folder from backup",
            details: nil
          )
        )
      }
    }
  }
}

/// Listen (step 3): reads a lesson, a prompt or — after an explicit tap —
/// the user's own words with AVSpeechSynthesizer, on the phone's own
/// voices (lib/services/read_aloud_platform.dart is the Dart side). The
/// text is spoken and nothing else: never logged or stored.
///
/// Silent mode: on the phone's speaker the speech uses the ambient audio
/// category, which the Ring/Silent switch mutes; with headphones it uses
/// playback (other sound is lowered meanwhile). The app's previous audio
/// category comes back when the speech ends. An interruption (a call)
/// stops it.
final class ReadAloudChannel: NSObject, AVSpeechSynthesizerDelegate {
  private let channel: FlutterMethodChannel
  private let synthesizer = AVSpeechSynthesizer()

  /// The text being read (its Dart id) and its pieces, in order.
  private var current: Int?
  private var pieces: [AVSpeechUtterance] = []

  /// The audio session before speaking (put back after) and the category
  /// set for speaking.
  private var saved: (
    category: AVAudioSession.Category,
    mode: AVAudioSession.Mode,
    options: AVAudioSession.CategoryOptions
  )?
  private var applied: AVAudioSession.Category?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "app.cartharise/read_aloud",
      binaryMessenger: messenger
    )
    super.init()
    synthesizer.delegate = self
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result: result)
    }
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(interrupted(_:)),
      name: AVAudioSession.interruptionNotification,
      object: AVAudioSession.sharedInstance()
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "available":
      guard let tag = args?["tag"] as? String else {
        result(FlutterError(code: "bad_args", message: "tag missing", details: nil))
        return
      }
      result(self.voice(for: tag) != nil)
    case "speak":
      guard let tag = args?["tag"] as? String,
        let id = args?["id"] as? Int,
        let chunks = args?["chunks"] as? [String]
      else {
        result(FlutterError(code: "bad_args", message: "tag, id or chunks missing", details: nil))
        return
      }
      speak(chunks, tag: tag, id: id, result: result)
    case "stop", "dispose":
      stopSpeaking(restore: true)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: Voices

  /// "fr" for "fr-FR", "fr_CA" or "FR".
  private static func primary(_ tag: String) -> String {
    let parts = tag.replacingOccurrences(of: "_", with: "-").split(separator: "-")
    return parts.first.map { $0.lowercased() } ?? ""
  }

  /// The best voice on the phone for `tag`'s language: the exact tag, else
  /// one of the user's preferred regions for it, else the default voice of
  /// its region, else the best quality. Novelty and personal voices are
  /// left out. Nil when the phone has none.
  private func voice(for tag: String) -> AVSpeechSynthesisVoice? {
    let language = Self.primary(tag)
    if language.isEmpty { return nil }
    let voices = AVSpeechSynthesisVoice.speechVoices().filter { voice in
      if Self.primary(voice.language) != language { return false }
      if #available(iOS 17.0, *) {
        if voice.voiceTraits.contains(.isNoveltyVoice)
          || voice.voiceTraits.contains(.isPersonalVoice)
        {
          return false
        }
      }
      return true
    }
    let wanted = tag.replacingOccurrences(of: "_", with: "-").lowercased()
    let preferred = Locale.preferredLanguages.map { $0.lowercased() }
    func score(_ voice: AVSpeechSynthesisVoice) -> Int {
      let code = voice.language.lowercased()
      var value = voice.quality.rawValue
      if code == wanted { value += 100 }
      if preferred.contains(code) { value += 50 }
      if AVSpeechSynthesisVoice(language: voice.language)?.identifier == voice.identifier {
        value += 10
      }
      return value
    }
    return voices.max { score($0) < score($1) }
  }

  // MARK: Speaking

  private func speak(_ chunks: [String], tag: String, id: Int, result: @escaping FlutterResult) {
    guard let chosen = self.voice(for: tag) else {
      result(FlutterError(code: "noVoice", message: "No voice for the language", details: nil))
      return
    }
    // One text at a time: this one replaces what is being read.
    stopSpeaking(restore: false)
    if chunks.isEmpty {
      result(nil)
      return
    }
    useSession()
    current = id
    pieces = chunks.map { text in
      let utterance = AVSpeechUtterance(string: text)
      utterance.voice = chosen
      utterance.postUtteranceDelay = 0.2
      return utterance
    }
    for piece in pieces { synthesizer.speak(piece) }
    result(nil)
  }

  /// Ends the current text at once and tells Dart (nothing when silent).
  private func stopSpeaking(restore: Bool) {
    let id = current
    current = nil
    pieces = []
    if id != nil { synthesizer.stopSpeaking(at: .immediate) }
    if restore { restoreSession() }
    if let id = id { channel.invokeMethod("done", arguments: id) }
  }

  /// The current text was read to the end (or cancelled by the system).
  private func finish() {
    guard let id = current else { return }
    current = nil
    pieces = []
    restoreSession()
    channel.invokeMethod("done", arguments: id)
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self, self.current != nil, utterance === self.pieces.last else { return }
      self.finish()
    }
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self, self.current != nil,
        self.pieces.contains(where: { $0 === utterance })
      else { return }
      self.finish()
    }
  }

  // MARK: Silent mode and the audio session

  /// Ambient on the speaker (the Ring/Silent switch mutes it), playback
  /// with headphones. Remembers the app's session to put it back.
  private func useSession() {
    let session = AVAudioSession.sharedInstance()
    if saved == nil {
      saved = (session.category, session.mode, session.categoryOptions)
    }
    let personal: Set<AVAudioSession.Port> = [
      .headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE, .usbAudio,
    ]
    let onHeadphones = session.currentRoute.outputs.contains { personal.contains($0.portType) }
    do {
      if onHeadphones {
        try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
      } else {
        try session.setCategory(.ambient, mode: .default, options: [])
      }
      applied = session.category
      try session.setActive(true)
    } catch {
      // Speak with the session as it is; the reason is not logged.
    }
  }

  /// Puts the app's session back, unless something else in the app (a
  /// voice note) has changed it since.
  private func restoreSession() {
    guard let saved = saved else { return }
    self.saved = nil
    let session = AVAudioSession.sharedInstance()
    let ours = applied != nil && session.category == applied
    applied = nil
    if !ours { return }
    try? session.setActive(false, options: .notifyOthersOnDeactivation)
    try? session.setCategory(saved.category, mode: saved.mode, options: saved.options)
  }

  /// A call or another app's audio interrupted: stop (never resume alone).
  @objc private func interrupted(_ note: Notification) {
    guard let raw = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt,
      AVAudioSession.InterruptionType(rawValue: raw) == .began
    else { return }
    DispatchQueue.main.async { [weak self] in self?.stopSpeaking(restore: true) }
  }
}
