package app.cartharise.cartharise

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.LocaleList
import android.os.Looper
import android.os.SystemClock
import android.speech.RecognitionListener
import android.speech.RecognitionSupport
import android.speech.RecognitionSupportCallback
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.util.Locale

/**
 * Dictation, on the phone only — the Android side of
 * lib/services/dictation_platform.dart (PlatformDictation).
 *
 * * Uses ONLY [SpeechRecognizer.createOnDeviceSpeechRecognizer] (Android 12+, API 31), after
 *   [SpeechRecognizer.isOnDeviceRecognitionAvailable]. Never the default recognizer (which may
 *   send audio to a server), never RecognizerIntent's "prefer offline" hint as a substitute, and
 *   never a fallback to either: before Android 12 the answer is "tooOld", without an on-device
 *   recognizer "unsupported", and the app offers Record or typing instead.
 * * The language's on-device support comes from checkRecognitionSupport (Android 13+): installed
 *   → "available", downloading or downloadable → "needsModel", else "unsupported". On Android 12
 *   (no support check) the language is tried and a "not supported" error is reported as is.
 * * The microphone is asked for only when dictation starts (after the user tapped Dictate).
 * * Listens until the user taps Stop: each pause's result is kept and listening resumes; a long
 *   silence ends it with what was heard (for review in the app, never inserted on its own).
 * * Privacy: recognised text goes only to the Dart side over the channel. Nothing is logged.
 *
 * Channels: methods `app.cartharise/dictation` (availability {tag}, stop, cancel), events
 * `app.cartharise/dictation/events` (listened to with {tag}; maps {type: partial|final|level|
 * error|ended, text?, level?, reason?}, then the end of the stream).
 */
class DictationPlugin :
    FlutterPlugin,
    ActivityAware,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    PluginRegistry.RequestPermissionsResultListener {

    companion object {
        const val METHOD_CHANNEL = "app.cartharise/dictation"
        const val EVENT_CHANNEL = "app.cartharise/dictation/events"

        private const val PERMISSION_REQUEST = 0x0D1C

        /** Pauses in a row with nothing heard before listening ends on its own. */
        private const val MAX_SILENT_ROUNDS = 3

        /** Input levels are sent at most this often (a calm meter, not a flood). */
        private const val LEVEL_INTERVAL_MS = 100L

        /** How long Stop waits for the last result before keeping what was heard. */
        private const val STOP_GRACE_MS = 2500L

        /** How long a language support check may take before dictation is simply tried. */
        private const val CHECK_TIMEOUT_MS = 3000L

        /**
         * The best of [languages] for [tag]: the same tag, else the same language — in the
         * phone's own region when it lists one (fr-CA on a Canadian phone) — else null.
         */
        fun matchLanguage(tag: String, languages: List<String>, preferred: List<Locale>): String? {
            if (languages.isEmpty()) return null
            val wanted = tag.replace('_', '-')
            languages.firstOrNull { it.replace('_', '-').equals(wanted, ignoreCase = true) }
                ?.let { return it }
            val language = Locale.forLanguageTag(wanted).language
            if (language.isEmpty()) return null
            val same = languages.filter {
                Locale.forLanguageTag(it.replace('_', '-')).language == language
            }
            if (same.isEmpty()) return null
            for (locale in preferred) {
                if (locale.language != language || locale.country.isEmpty()) continue
                same.firstOrNull {
                    Locale.forLanguageTag(it.replace('_', '-')).country
                        .equals(locale.country, ignoreCase = true)
                }?.let { return it }
            }
            return same.first()
        }
    }

    /** What the support check found: an availability name and the tag to listen with. */
    private class LanguageCheck(val availability: String, val language: String?)

    private var context: Context? = null
    private var methods: MethodChannel? = null
    private var events: EventChannel? = null
    private var activity: ActivityPluginBinding? = null
    private val main = Handler(Looper.getMainLooper())

    /** The running dictation (one at a time). Typed loosely: its class needs API 31. */
    private var session: Any? = null
    private var permissionCallback: ((Boolean) -> Unit)? = null

    /** The microphone was refused in this run (with "don't ask again", only Settings can allow it). */
    private var refusedThisRun = false

    // ── FlutterPlugin ───────────────────────────────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        methods = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL).also {
            it.setMethodCallHandler(this)
        }
        events = EventChannel(binding.binaryMessenger, EVENT_CHANNEL).also {
            it.setStreamHandler(this)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        cancelSession(notify = false)
        methods?.setMethodCallHandler(null)
        events?.setStreamHandler(null)
        methods = null
        events = null
        context = null
    }

    // ── ActivityAware (the permission question needs the activity) ─────────────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity?.removeRequestPermissionsResultListener(this)
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) =
        onAttachedToActivity(binding)

    override fun onDetachedFromActivity() {
        activity?.removeRequestPermissionsResultListener(this)
        activity = null
        // The question can't be answered any more: no microphone.
        permissionCallback?.let {
            permissionCallback = null
            it(false)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != PERMISSION_REQUEST) return false
        val callback = permissionCallback ?: return true
        permissionCallback = null
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        if (!granted) refusedThisRun = true
        callback(granted)
        return true
    }

    // ── Methods ────────────────────────────────────────────────────────────────────────────

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "availability" -> availability(call.argument<String>("tag") ?: "") {
                result.success(it)
            }
            "stop" -> {
                stopSession()
                result.success(null)
            }
            "cancel" -> {
                cancelSession(notify = true)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Never asks for anything: only says whether dictation could run. */
    private fun availability(tag: String, answer: (String) -> Unit) {
        val ctx = context
        if (ctx == null) {
            answer("unsupported")
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            answer("tooOld")
            return
        }
        if (!SpeechRecognizer.isOnDeviceRecognitionAvailable(ctx)) {
            answer("unsupported")
            return
        }
        if (microphoneRefusedForGood(ctx)) {
            answer("noPermission")
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            // Android 12 can't say which languages it has: try, and say so if it can't.
            answer("available")
            return
        }
        checkLanguage(ctx, tag) { answer(it.availability) }
    }

    private fun hasMicrophone(ctx: Context) =
        ctx.checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED

    /** Refused, and Android won't ask again: only the system settings can allow it now. */
    private fun microphoneRefusedForGood(ctx: Context): Boolean {
        if (hasMicrophone(ctx) || !refusedThisRun) return false
        val current = activity?.activity ?: return false
        return !current.shouldShowRequestPermissionRationale(Manifest.permission.RECORD_AUDIO)
    }

    private fun preferredLocales(): List<Locale> {
        val list = LocaleList.getDefault()
        return (0 until list.size()).map { list[it] }
    }

    /** [tag] with the phone's region when it has none ("fr" → "fr-CA" on a Canadian phone). */
    private fun phoneTag(tag: String): String {
        val wanted = Locale.forLanguageTag(tag.replace('_', '-'))
        if (wanted.country.isNotEmpty()) return wanted.toLanguageTag()
        val local = preferredLocales().firstOrNull {
            it.language == wanted.language && it.country.isNotEmpty()
        }
        return local?.let { "${it.language}-${it.country}" } ?: tag
    }

    private fun recognitionIntent(ctx: Context, language: String) =
        Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, language)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE, ctx.packageName)
        }

    /** Asks the on-device recognizer whether it has [tag] (installed, coming, or not at all). */
    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun checkLanguage(ctx: Context, tag: String, done: (LanguageCheck) -> Unit) {
        val recognizer = try {
            SpeechRecognizer.createOnDeviceSpeechRecognizer(ctx)
        } catch (e: Exception) {
            done(LanguageCheck("unsupported", null))
            return
        }
        // When the recognizer can't tell: try it (on the device; a failure is said honestly).
        val unknown = LanguageCheck("available", phoneTag(tag))
        var answered = false
        lateinit var timeout: Runnable
        fun reply(check: LanguageCheck) {
            if (answered) return
            answered = true
            main.removeCallbacks(timeout)
            recognizer.destroy()
            done(check)
        }
        timeout = Runnable { reply(unknown) }
        main.postDelayed(timeout, CHECK_TIMEOUT_MS)
        try {
            recognizer.checkRecognitionSupport(
                recognitionIntent(ctx, phoneTag(tag)),
                ctx.mainExecutor,
                object : RecognitionSupportCallback {
                    override fun onSupportResult(support: RecognitionSupport) {
                        reply(classify(support, tag) ?: unknown)
                    }

                    override fun onError(error: Int) {
                        reply(
                            when (error) {
                                SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED ->
                                    LanguageCheck("unsupported", null)
                                SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE ->
                                    LanguageCheck("needsModel", null)
                                else -> unknown
                            },
                        )
                    }
                },
            )
        } catch (e: Exception) {
            reply(unknown)
        }
    }

    /** Null when the recognizer listed no languages at all (it can't tell). */
    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun classify(support: RecognitionSupport, tag: String): LanguageCheck? {
        val installed = support.installedOnDeviceLanguages
        val pending = support.pendingOnDeviceLanguages
        val supported = support.supportedOnDeviceLanguages
        if (installed.isEmpty() && pending.isEmpty() && supported.isEmpty()) return null
        val preferred = preferredLocales()
        matchLanguage(tag, installed, preferred)?.let { return LanguageCheck("available", it) }
        if (matchLanguage(tag, pending, preferred) != null ||
            matchLanguage(tag, supported, preferred) != null
        ) {
            return LanguageCheck("needsModel", null)
        }
        return LanguageCheck("unsupported", null)
    }

    // ── Events: one dictation per listen ───────────────────────────────────────────────────

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        val tag = (arguments as? Map<*, *>)?.get("tag") as? String ?: ""
        val ctx = context
        when {
            session != null -> failAndEnd(events, "busy")
            ctx == null -> failAndEnd(events, "failed")
            Build.VERSION.SDK_INT < Build.VERSION_CODES.S -> failAndEnd(events, "tooOld")
            !SpeechRecognizer.isOnDeviceRecognitionAvailable(ctx) ->
                failAndEnd(events, "unsupported")
            else -> start(ctx, tag, events)
        }
    }

    /** The app stopped listening (the sheet closed): stop quietly, nothing more is sent. */
    override fun onCancel(arguments: Any?) = cancelSession(notify = false)

    private fun failAndEnd(sink: EventChannel.EventSink, reason: String) {
        sink.success(mapOf("type" to "error", "reason" to reason))
        sink.success(mapOf("type" to "ended"))
        sink.endOfStream()
    }

    @RequiresApi(Build.VERSION_CODES.S)
    private fun start(ctx: Context, tag: String, sink: EventChannel.EventSink) {
        val current = Session(ctx, sink)
        session = current
        withMicrophone(ctx) { granted ->
            if (session !== current) return@withMicrophone
            if (!granted) {
                current.fail("noPermission")
                return@withMicrophone
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                checkLanguage(ctx, tag) { check ->
                    if (session !== current) return@checkLanguage
                    if (check.availability == "available") {
                        current.begin(check.language ?: phoneTag(tag))
                    } else {
                        current.fail(check.availability)
                    }
                }
            } else {
                current.begin(phoneTag(tag))
            }
        }
    }

    /** Asks for the microphone only now (the user tapped Dictate); answers on the main thread. */
    private fun withMicrophone(ctx: Context, then: (Boolean) -> Unit) {
        if (hasMicrophone(ctx)) {
            then(true)
            return
        }
        val current = activity?.activity
        if (current == null) {
            then(false)
            return
        }
        permissionCallback?.invoke(false)
        permissionCallback = then
        current.requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), PERMISSION_REQUEST)
    }

    private fun stopSession() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) (session as? Session)?.stop()
    }

    private fun cancelSession(notify: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (session as? Session)?.cancel(notify)
        }
        session = null
    }

    /** One dictation: on-device recognizer, partial text, levels, then final or error, ended. */
    @RequiresApi(Build.VERSION_CODES.S)
    private inner class Session(
        private val ctx: Context,
        private val sink: EventChannel.EventSink,
    ) : RecognitionListener {
        private var recognizer: SpeechRecognizer? = null
        private var language = ""

        /** What was heard in earlier stretches, and in the current one. */
        private val heard = StringBuilder()
        private var current = ""
        private var stopping = false
        private var ended = false
        private var silentRounds = 0
        private var lastLevelAt = 0L
        private val stopGrace = Runnable { finish() }

        fun begin(language: String) {
            if (ended) return
            this.language = language
            val created = try {
                SpeechRecognizer.createOnDeviceSpeechRecognizer(ctx)
            } catch (e: Exception) {
                fail("unsupported")
                return
            }
            recognizer = created
            created.setRecognitionListener(this)
            if (stopping) {
                finish()
                return
            }
            listen()
        }

        private fun listen() {
            if (ended) return
            try {
                recognizer?.startListening(recognitionIntent(ctx, language))
            } catch (e: Exception) {
                fail("failed")
            }
        }

        fun stop() {
            if (ended || stopping) return
            stopping = true
            val active = recognizer
            if (active == null) {
                // Still asking or checking: nothing was heard.
                finish()
                return
            }
            active.stopListening()
            main.postDelayed(stopGrace, STOP_GRACE_MS)
        }

        fun cancel(notify: Boolean) {
            if (ended) return
            ended = true
            teardown(cancel = true)
            if (notify) {
                send(mapOf("type" to "ended"))
                sink.endOfStream()
            }
        }

        /** Ends with [reason]; the words heard before it were already sent and stay the user's. */
        fun fail(reason: String) {
            if (ended) return
            ended = true
            teardown(cancel = true)
            val text = joined()
            if (text.isNotBlank()) send(mapOf("type" to "partial", "text" to text))
            send(mapOf("type" to "error", "reason" to reason))
            send(mapOf("type" to "ended"))
            sink.endOfStream()
        }

        /** Ends with the whole text for review (or "nothing heard"). */
        private fun finish() {
            if (ended) return
            ended = true
            teardown(cancel = false)
            val text = joined()
            if (text.isNotBlank()) {
                send(mapOf("type" to "final", "text" to text))
            } else {
                send(mapOf("type" to "error", "reason" to "noSpeech"))
            }
            send(mapOf("type" to "ended"))
            sink.endOfStream()
        }

        private fun teardown(cancel: Boolean) {
            main.removeCallbacks(stopGrace)
            recognizer?.let {
                if (cancel) it.cancel()
                it.destroy()
            }
            recognizer = null
            if (session === this) session = null
        }

        private fun send(event: Map<String, Any>) = sink.success(event)

        private fun joined(): String {
            val now = current.trim()
            if (now.isEmpty()) return heard.toString()
            if (heard.isEmpty()) return now
            return "$heard $now"
        }

        private fun keep(text: String) {
            val words = text.trim()
            if (words.isEmpty()) return
            if (heard.isNotEmpty()) heard.append(' ')
            heard.append(words)
        }

        private fun firstResult(bundle: Bundle?): String =
            bundle?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)?.firstOrNull() ?: ""

        /** Listening again after a pause, until the user taps Stop. */
        private fun again() {
            main.post { if (!ended && !stopping) listen() }
        }

        override fun onReadyForSpeech(params: Bundle?) {}

        override fun onBeginningOfSpeech() {}

        override fun onRmsChanged(rmsdB: Float) {
            if (ended) return
            val now = SystemClock.uptimeMillis()
            if (now - lastLevelAt < LEVEL_INTERVAL_MS) return
            lastLevelAt = now
            val level = ((rmsdB + 2f) / 12f).coerceIn(0f, 1f)
            send(mapOf("type" to "level", "level" to level.toDouble()))
        }

        override fun onBufferReceived(buffer: ByteArray?) {}

        override fun onEndOfSpeech() {}

        override fun onPartialResults(partialResults: Bundle?) {
            if (ended) return
            current = firstResult(partialResults)
            send(mapOf("type" to "partial", "text" to joined()))
        }

        override fun onResults(results: Bundle?) {
            if (ended) return
            val text = firstResult(results).ifBlank { current }
            current = ""
            keep(text)
            if (stopping) {
                finish()
                return
            }
            silentRounds = if (text.isBlank()) silentRounds + 1 else 0
            if (silentRounds >= MAX_SILENT_ROUNDS) {
                finish()
                return
            }
            send(mapOf("type" to "partial", "text" to joined()))
            again()
        }

        override fun onError(error: Int) {
            if (ended) return
            keep(current)
            current = ""
            if (stopping) {
                finish()
                return
            }
            when (error) {
                SpeechRecognizer.ERROR_NO_MATCH, SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> {
                    // A pause: keep listening, unless the silence goes on.
                    silentRounds++
                    if (silentRounds >= MAX_SILENT_ROUNDS) finish() else again()
                }
                else -> fail(reasonFor(error))
            }
        }

        override fun onEvent(eventType: Int, params: Bundle?) {}

        private fun reasonFor(error: Int) = when (error) {
            SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "noPermission"
            SpeechRecognizer.ERROR_LANGUAGE_NOT_SUPPORTED -> "unsupported"
            SpeechRecognizer.ERROR_LANGUAGE_UNAVAILABLE -> "needsModel"
            SpeechRecognizer.ERROR_RECOGNIZER_BUSY,
            SpeechRecognizer.ERROR_TOO_MANY_REQUESTS -> "busy"
            SpeechRecognizer.ERROR_AUDIO -> "interrupted"
            else -> "failed"
        }
    }
}
