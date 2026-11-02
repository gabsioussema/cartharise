import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app_locale.dart';
import 'l10n/app_localizations.dart';
import 'services/dictation.dart';
import 'services/file_share.dart';
import 'services/media_picker.dart';
import 'services/read_aloud.dart';
import 'services/voice_player.dart';
import 'services/voice_recorder.dart';
import 'state/app_state.dart';
import 'ui/boot_screen.dart';
import 'ui/nav.dart';
import 'ui/theme/cartha_theme.dart';

/// The app: providers (AppState, FileShare, MediaPicker, VoiceRecorder,
/// VoicePlayer, Dictation, ReadAloud, ShellController) above one
/// MaterialApp whose whole look comes from `CarthaTheme` (lib/ui/theme/),
/// in the language `AppState.language` resolves (strings, content,
/// direction and fonts follow it). The attachment files are the state's
/// (`AppState.attachmentStore`).
class CarthaApp extends StatelessWidget {
  const CarthaApp({
    super.key,
    required this.state,
    required this.fileShare,
    required this.mediaPicker,
    required this.voiceRecorder,
    required this.voicePlayer,
    this.dictation = const UnsupportedDictation(),
    this.readAloud = const UnavailableReadAloud(),
    this.shell,
    this.home,
    this.themeMode,
  });

  final AppState state;
  final FileShare fileShare;

  /// Photos from the system picker or camera (only when the user taps).
  final MediaPicker mediaPicker;

  /// Voice recordings (microphone asked only when the user taps Record).
  final VoiceRecorder voiceRecorder;

  /// Plays the user's recordings back.
  final VoicePlayer voicePlayer;

  /// Speech to text, on the device only (step 3).
  final Dictation dictation;

  /// Listen: the phone's text-to-speech, only on a tap (step 3).
  final ReadAloud readAloud;

  /// Tests may pass their own to drive or inspect tab switching.
  final ShellController? shell;

  /// Defaults to [BootScreen] (tests may show a single screen).
  final Widget? home;

  /// Overrides the user's appearance setting (tests, previews).
  final ThemeMode? themeMode;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<AppState>.value(value: state),
      Provider<FileShare>.value(value: fileShare),
      Provider<MediaPicker>.value(value: mediaPicker),
      Provider<VoiceRecorder>.value(value: voiceRecorder),
      Provider<VoicePlayer>.value(value: voicePlayer),
      Provider<Dictation>.value(value: dictation),
      Provider<ReadAloud>.value(value: readAloud),
      if (shell != null)
        ChangeNotifierProvider<ShellController>.value(value: shell!)
      else
        ChangeNotifierProvider<ShellController>(
          create: (_) => ShellController(),
        ),
    ],
    child: _CarthaMaterialApp(
      home: home ?? const BootScreen(),
      themeMode: themeMode,
    ),
  );
}

class _CarthaMaterialApp extends StatefulWidget {
  const _CarthaMaterialApp({required this.home, this.themeMode});

  final Widget home;
  final ThemeMode? themeMode;

  @override
  State<_CarthaMaterialApp> createState() => _CarthaMaterialAppState();
}

class _CarthaMaterialAppState extends State<_CarthaMaterialApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The phone's languages changed: "Same as phone" follows them.
  @override
  void didChangeLocales(List<Locale>? locales) {
    context.read<AppState>().setDeviceLanguages(
      languageCodesOf(locales ?? const []),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (theme, appearance, language) = context.select(
      (AppState s) => (s.settings.theme, s.settings.appearance, s.language),
    );
    // Strings, content, direction (Arabic is right to left through the
    // global localizations) and fonts all follow the one resolved language.
    final fonts = CarthaFonts.forLanguage(language);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: CarthaTheme.build(theme, Brightness.light, fonts: fonts),
      darkTheme: CarthaTheme.build(theme, Brightness.dark, fonts: fonts),
      themeMode: widget.themeMode ?? CarthaTheme.modeFor(appearance),
      themeAnimationDuration: Duration.zero,
      locale: localeFor(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: kAppLocales,
      builder: (context, child) {
        final motion = context.select((AppState s) => s.settings.motion);
        final dark = Theme.of(context).brightness == Brightness.dark;
        // Transparent system bars with icons readable on the current theme;
        // Settings › Motion off behaves like the device's reduce-motion.
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: CarthaTheme.systemUiStyle(
            dark ? Brightness.dark : Brightness.light,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations:
                  !motion || MediaQuery.disableAnimationsOf(context),
            ),
            child: _LocalizeReminders(child: child!),
          ),
        );
      },
      home: widget.home,
    );
  }
}

/// Gives the reminder scheduler its notification channel text in the
/// user's language (shown in the system's notification settings).
class _LocalizeReminders extends StatefulWidget {
  const _LocalizeReminders({required this.child});

  final Widget child;

  @override
  State<_LocalizeReminders> createState() => _LocalizeRemindersState();
}

class _LocalizeRemindersState extends State<_LocalizeReminders> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l = AppLocalizations.of(context);
    context.read<AppState>().localizeReminders(
      channelName: l.reminderChannelName,
      channelDescription: l.reminderChannelDescription,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
