import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'services/file_share.dart';
import 'state/app_state.dart';
import 'ui/boot_screen.dart';
import 'ui/nav.dart';
import 'ui/theme/cartha_theme.dart';

/// The app: providers (AppState, FileShare, ShellController) above one
/// MaterialApp whose whole look comes from `CarthaTheme` (lib/ui/theme/).
class CarthaApp extends StatelessWidget {
  const CarthaApp({
    super.key,
    required this.state,
    required this.fileShare,
    this.shell,
    this.home,
    this.themeMode,
  });

  final AppState state;
  final FileShare fileShare;

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

class _CarthaMaterialApp extends StatelessWidget {
  const _CarthaMaterialApp({required this.home, this.themeMode});

  final Widget home;
  final ThemeMode? themeMode;

  @override
  Widget build(BuildContext context) {
    final (theme, appearance) = context.select(
      (AppState s) => (s.settings.theme, s.settings.appearance),
    );
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: CarthaTheme.build(theme, Brightness.light),
      darkTheme: CarthaTheme.build(theme, Brightness.dark),
      themeMode: themeMode ?? CarthaTheme.modeFor(appearance),
      themeAnimationDuration: Duration.zero,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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
      home: home,
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
