package app.cartharise.cartharise

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Dictation through the phone's on-device recognizer only (step 3).
        flutterEngine.plugins.add(DictationPlugin())
    }
}
