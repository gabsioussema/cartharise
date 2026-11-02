import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/media_picker.dart';
import '../state/app_state.dart';
import 'campaign/campaign_feedback.dart';
import 'media/recovered_media_card.dart';
import 'nav.dart';
import 'widgets/motion.dart';

/// Today · Reset · Compass · Journal · You (PLAN.md §2), board style:
/// monochrome icons, bronze for the selected tab. Tabs stay alive in an
/// [IndexedStack] so half-typed text survives a tab switch. Edge-to-edge:
/// the bar pads itself for the system navigation inset.
///
/// Also opens the daytime prompt of a tapped check-in notification, and
/// asks the camera once for a photo it took while Android closed the app
/// (held for the user's decision on Today, never put on an entry by
/// itself).
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
    final picker = context.read<MediaPicker>();
    _reminderTaps = state.reminderTaps.listen(_openReminder);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(recoverLostCameraPhoto(state, picker));
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

  /// The label text scale that keeps every tab name on one line: as large
  /// as the device asks (up to the bar's own cap, 1.3×) where it fits, a
  /// little smaller on narrow phones at large text. Null when the names
  /// can't fit even at [_minLabelScale]: they are hidden then, each tab
  /// keeping its tooltip and spoken name.
  static double? labelScale(BuildContext context, List<String> labels) {
    final media = MediaQuery.of(context);
    final room = media.size.width / labels.length - 8;
    final style =
        NavigationBarTheme.of(context).labelTextStyle
            ?.resolve({WidgetState.selected}) ??
        Theme.of(context).textTheme.labelMedium;
    var widest = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        maxLines: 1,
      )..layout();
      widest = math.max(widest, painter.width);
      painter.dispose();
    }
    final asked = media.textScaler.scale(100) / 100;
    final scale = math.min(math.min(asked, 1.3), room / widest);
    return scale < _minLabelScale ? null : scale;
  }

  static const _minLabelScale = 0.85;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final shell = context.watch<ShellController>();
    final tab = shell.tab;
    final labels = [for (final t in AppTab.values) _label(l, t)];
    final scale = labelScale(context, labels);
    return CampaignFeedback(
      child: Scaffold(
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
        // Tab names stay whole on one line (never "Compas / s"): scaled to
        // fit, or hidden with their tooltips and spoken names kept.
        bottomNavigationBar: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale ?? 1)),
          child: NavigationBar(
            selectedIndex: tab.index,
            onDestinationSelected: (i) => shell.select(AppTab.values[i]),
            labelBehavior: scale == null
                ? NavigationDestinationLabelBehavior.alwaysHide
                : null,
            destinations: [
              for (final t in AppTab.values)
                NavigationDestination(
                  icon: Icon(_icons[t]!.$1),
                  selectedIcon: Icon(_icons[t]!.$2),
                  label: labels[t.index],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
