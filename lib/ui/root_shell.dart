import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'nav.dart';
import 'widgets/motion.dart';

/// Today · Reset · Compass · Journal · You (PLAN.md §2), board style:
/// monochrome icons, bronze for the selected tab. Tabs stay alive in an
/// [IndexedStack] so half-typed text survives a tab switch. Edge-to-edge:
/// the bar pads itself for the system navigation inset.
///
/// Also opens the daytime prompt of a tapped check-in notification.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  StreamSubscription<String>? _reminderTaps;

  static const _icons = <AppTab, (IconData, IconData)>{
    AppTab.today: (Icons.home_outlined, Icons.home),
    AppTab.reset: (Icons.wb_twilight_outlined, Icons.wb_twilight),
    AppTab.compass: (Icons.explore_outlined, Icons.explore),
    AppTab.journal: (Icons.menu_book_outlined, Icons.menu_book),
    AppTab.you: (Icons.person_outline, Icons.person),
  };

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _reminderTaps = state.reminderTaps.listen(_openReminder);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final payload = await state.takeLaunchReminder();
      if (payload != null) _openReminder(payload);
    });
  }

  void _openReminder(String promptId) {
    if (!mounted) return;
    if (context.read<AppState>().content.prompt(promptId) == null) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    unawaited(AppNav.openPrompt(context, promptId));
  }

  @override
  void dispose() {
    _reminderTaps?.cancel();
    super.dispose();
  }

  String _label(AppLocalizations l, AppTab tab) => switch (tab) {
    AppTab.today => l.tabToday,
    AppTab.reset => l.tabReset,
    AppTab.compass => l.tabCompass,
    AppTab.journal => l.tabJournal,
    AppTab.you => l.tabYou,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shell = context.watch<ShellController>();
    final tab = shell.tab;
    return Scaffold(
      body: CarthaPageMotion(
        page: tab,
        child: IndexedStack(
          index: tab.index,
          children: [
            for (final t in AppTab.values)
              TickerMode(enabled: t == tab, child: AppNav.tabWidget(t)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (i) => shell.select(AppTab.values[i]),
        destinations: [
          for (final t in AppTab.values)
            NavigationDestination(
              icon: Icon(_icons[t]!.$1),
              selectedIcon: Icon(_icons[t]!.$2),
              label: _label(l, t),
            ),
        ],
      ),
    );
  }
}
