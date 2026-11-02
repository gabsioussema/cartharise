package app.cartharise.cartharise

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioDeviceInfo
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.speech.tts.Voice
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/**
 * Listen (step 3): reads a lesson, a prompt or — after an explicit tap —
 * the user's own words with the phone's own text-to-speech engine
 * (lib/services/read_aloud_platform.dart is the Dart side).
 *
 * Privacy: only installed voices that need no network connection are used
 * (never a cloud voice); a language without one is "noVoice". The text is
 * handed to the engine and nothing else: it is never logged or stored.
 *
 * Silent mode: with the ringer on silent and the sound coming from the
 * phone's speaker, nothing plays ("silent"); headphones still work. Speech
 * plays on the media volume, asks for transient audio focus (other sound is
 * lowered) and stops when that focus is lost (a call, another app).
 */
class ReadAloudChannel(context: Context, messenger: BinaryMessenger) :
    MethodChannel.MethodCallHandler {

    companion object {
        const val NAME = "app.cartharise/read_aloud"
    }

    private val context = context.applicationContext
    private val channel = MethodChannel(messenger, NAME)
    private val main = Handler(Looper.getMainLooper())
    private val audio = this.context.getSystemService(Context.AUDIO_SERVICE) as AudioManager

    private var engine: TextToSpeech? = null

    /** null while the engine starts, then whether it is usable. */
    private var ready: Boolean? = null
    private val waiting = mutableListOf<(TextToSpeech?) -> Unit>()

    /** The text being read (its Dart id) and its last piece's utterance id. */
    private var current: Int? = null
    private var lastPiece: String? = null
    private var focus: AudioFocusRequest? = null

    private val attributes: AudioAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
        .build()

    private val focusListener = AudioManager.OnAudioFocusChangeListener { change ->
        if (change == AudioManager.AUDIOFOCUS_LOSS ||
            change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT
        ) {
            main.post { stopSpeaking() }
        }
    }

    init {
        channel.setMethodCallHandler(this)
    }

    /** Stops speaking and releases the engine (the activity is going away). */
    fun dispose() {
        channel.setMethodCallHandler(null)
        shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "available" -> {
                val tag = call.argument<String>("tag")
                if (tag == null) {
                    result.error("bad_args", "tag missing", null)
                    return
                }
                withEngine { tts -> result.success(tts != null && voiceFor(tts, tag) != null) }
            }
            "speak" -> speak(call, result)
            "stop" -> {
                stopSpeaking()
                result.success(null)
            }
            "dispose" -> {
                shutdown()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    // ── Engine ──────────────────────────────────────────────────────────────

    /** Runs [action] with a ready engine, or null when there is none. */
    private fun withEngine(action: (TextToSpeech?) -> Unit) {
        when (ready) {
            true -> action(engine)
            false -> {
                // Try again: an engine may have been installed meanwhile.
                shutdown()
                start(action)
            }
            null -> if (engine == null) start(action) else waiting.add(action)
        }
    }

    private fun start(action: (TextToSpeech?) -> Unit) {
        ready = null
        waiting.add(action)
        val created = try {
            TextToSpeech(context) { status ->
                main.post { onInit(status == TextToSpeech.SUCCESS) }
            }
        } catch (e: Exception) {
            null
        }
        if (created == null) {
            onInit(false)
            return
        }
        engine = created
        created.setOnUtteranceProgressListener(progress)
    }

    private fun onInit(ok: Boolean) {
        ready = ok
        if (ok) engine?.setAudioAttributes(attributes)
        val usable = if (ok) engine else null
        val actions = waiting.toList()
        waiting.clear()
        actions.forEach { it(usable) }
    }

    private fun shutdown() {
        stopSpeaking()
        engine?.shutdown()
        engine = null
        ready = null
        val actions = waiting.toList()
        waiting.clear()
        actions.forEach { it(null) }
    }

    private val progress = object : UtteranceProgressListener() {
        override fun onStart(utteranceId: String?) {}

        override fun onDone(utteranceId: String?) {
            main.post { if (utteranceId != null && utteranceId == lastPiece) finish() }
        }

        @Deprecated("Deprecated in Java")
        override fun onError(utteranceId: String?) {
            main.post { if (owns(utteranceId)) finish() }
        }

        override fun onError(utteranceId: String?, errorCode: Int) {
            main.post { if (owns(utteranceId)) finish() }
        }

        override fun onStop(utteranceId: String?, interrupted: Boolean) {
            main.post { if (owns(utteranceId)) finish() }
        }
    }

    private fun owns(utteranceId: String?): Boolean {
        val id = current ?: return false
        return utteranceId != null && utteranceId.startsWith("$id:")
    }

    // ── Voices ──────────────────────────────────────────────────────────────

    /**
     * The best installed, offline voice for [tag]'s language: the user's
     * default voice when it fits, else one of the phone's region for that
     * language, else the best quality. Null when there is none.
     */
    private fun voiceFor(tts: TextToSpeech, tag: String): Voice? {
        val wanted = Locale.forLanguageTag(tag)
        val language = wanted.language
        if (language.isEmpty()) return null
        val voices = try {
            tts.voices
        } catch (e: Exception) {
            null
        } ?: return null
        val local = voices.filter { v ->
            v.locale.language == language &&
                !v.isNetworkConnectionRequired &&
                !v.features.contains(TextToSpeech.Engine.KEY_FEATURE_NOT_INSTALLED)
        }
        if (local.isEmpty()) return null
        val default = try {
            tts.defaultVoice
        } catch (e: Exception) {
            null
        }
        val country = wanted.country.ifEmpty { deviceCountryFor(language) }
        return local.sortedWith(
            compareByDescending<Voice> { it.name == default?.name }
                .thenByDescending { country.isNotEmpty() && it.locale.country == country }
                .thenByDescending { it.quality }
                .thenBy { it.latency }
        ).first()
    }

    /** The region of the phone's first language that is [language]. */
    private fun deviceCountryFor(language: String): String {
        val locales = context.resources.configuration.locales
        for (i in 0 until locales.size()) {
            val locale = locales.get(i)
            if (locale.language == language) return locale.country
        }
        return ""
    }

    // ── Speaking ────────────────────────────────────────────────────────────

    private fun speak(call: MethodCall, result: MethodChannel.Result) {
        val tag = call.argument<String>("tag")
        val id = call.argument<Int>("id")
        val chunks = call.argument<List<String>>("chunks")
        if (tag == null || id == null || chunks == null) {
            result.error("bad_args", "tag, id or chunks missing", null)
            return
        }
        withEngine { tts ->
            if (tts == null) {
                result.error("unavailable", "No text-to-speech engine", null)
                return@withEngine
            }
            val voice = voiceFor(tts, tag)
            if (voice == null) {
                result.error("noVoice", "No offline voice for the language", null)
                return@withEngine
            }
            if (silentOnSpeaker()) {
                result.error("silent", "The phone is on silent", null)
                return@withEngine
            }
            stopSpeaking()
            if (tts.setVoice(voice) != TextToSpeech.SUCCESS) {
                result.error("noVoice", "The voice could not be used", null)
                return@withEngine
            }
            val max = TextToSpeech.getMaxSpeechInputLength()
            val pieces = chunks.flatMap { if (it.length <= max) listOf(it) else it.chunked(max) }
            current = id
            lastPiece = "$id:${pieces.size - 1}"
            requestFocus()
            for ((i, piece) in pieces.withIndex()) {
                val mode = if (i == 0) TextToSpeech.QUEUE_FLUSH else TextToSpeech.QUEUE_ADD
                if (tts.speak(piece, mode, Bundle(), "$id:$i") != TextToSpeech.SUCCESS) {
                    stopSpeaking()
                    result.error("failed", "The engine refused the text", null)
                    return@withEngine
                }
            }
            result.success(null)
        }
    }

    /** Ends the current text at once and tells Dart (no-op when silent). */
    private fun stopSpeaking() {
        val id = current
        current = null
        lastPiece = null
        if (id != null) engine?.stop()
        abandonFocus()
        if (id != null) channel.invokeMethod("done", id)
    }

    /** The current text was read to the end (or the engine gave up). */
    private fun finish() {
        val id = current ?: return
        current = null
        lastPiece = null
        abandonFocus()
        channel.invokeMethod("done", id)
    }

    // ── Silent mode and audio focus ─────────────────────────────────────────

    private fun silentOnSpeaker(): Boolean =
        audio.ringerMode == AudioManager.RINGER_MODE_SILENT && !headphonesConnected()

    private fun headphonesConnected(): Boolean {
        val personal = setOf(
            AudioDeviceInfo.TYPE_WIRED_HEADSET,
            AudioDeviceInfo.TYPE_WIRED_HEADPHONES,
            AudioDeviceInfo.TYPE_BLUETOOTH_A2DP,
            AudioDeviceInfo.TYPE_BLUETOOTH_SCO,
            AudioDeviceInfo.TYPE_USB_HEADSET,
            AudioDeviceInfo.TYPE_HEARING_AID,
            AudioDeviceInfo.TYPE_BLE_HEADSET,
        )
        return audio.getDevices(AudioManager.GET_DEVICES_OUTPUTS).any { it.type in personal }
    }

    private fun requestFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(attributes)
                .setOnAudioFocusChangeListener(focusListener, main)
                .build()
            focus = request
            audio.requestAudioFocus(request)
        } else {
            @Suppress("DEPRECATION")
            audio.requestAudioFocus(
                focusListener,
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK,
            )
        }
    }

    private fun abandonFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            focus?.let { audio.abandonAudioFocusRequest(it) }
            focus = null
        } else {
            @Suppress("DEPRECATION")
            audio.abandonAudioFocus(focusListener)
        }
    }
}
