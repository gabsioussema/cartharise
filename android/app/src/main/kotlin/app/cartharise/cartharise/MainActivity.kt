package app.cartharise.cartharise

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    /** Listen (step 3): the phone's text-to-speech, see ReadAloudChannel. */
    private var readAloud: ReadAloudChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Dictation through the phone's on-device recognizer only (step 3).
        flutterEngine.plugins.add(DictationPlugin())
        readAloud = ReadAloudChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        readAloud?.dispose()
        readAloud = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
