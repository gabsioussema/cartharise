import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../campaign/campaign_view.dart';
import '../missions/missions_view.dart';
import '../nav.dart';
import '../widgets/widgets.dart';
import 'compass_view.dart';

/// The sections of the Compass tab (PLAN.md §2): the Compass, Missions and,
/// while the game layer is on, the Campaign.
enum CompassSection { compass, missions, campaign }

/// The Compass tab: Cinzel header, then `PillTabs` Compass | Missions |
/// Campaign (the last only while Settings › The Campaign is on).
///
/// Inside the shell it follows `ShellController.compassSection`
/// (`AppNav.openCompass` / `openMissions`) and keeps that notifier in sync
/// with the section on screen, so a later request for the other section is
/// always a change it hears. Pushed on its own (no shell), it starts at
/// [initial] and gets a back button.
class CompassTab extends StatefulWidget {
  const CompassTab({super.key, this.initial = CompassSection.compass});

  final CompassSection initial;

  @override
  State<CompassTab> createState() => _CompassTabState();
}

class _CompassTabState extends State<CompassTab> {
  late CompassSection _section = widget.initial;
  ShellController? _shell;
  bool _pushed = false;
  bool _attached = false;

  /// Lever drafts already added or put aside this session, keyed by the
  /// daily-levers text they came from (survives section switches).
  String? _leversHandledFor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_attached) return;
    _attached = true;
    _pushed = ModalRoute.of(context)?.isFirst == false;
    if (_pushed) return;
    _shell = ShellController.maybeOf(context);
    final requested = _shell?.compassSection.value;
    if (requested != null) _section = requested;
    _shell?.compassSection.addListener(_onRequest);
  }

  void _onRequest() {
    final requested = _shell?.compassSection.value;
    if (requested == null || requested == _section || !mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _section = requested);
  }

  void _select(CompassSection section) {
    if (section == _section) return;
    // Ending the edit saves any typed text before the section changes.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _section = section);
    _shell?.compassSection.value = section;
  }

  @override
  void dispose() {
    _shell?.compassSection.removeListener(_onRequest);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final game = context.select<AppState, bool>((s) => s.settings.game);
    // With the game layer off, a request for the Campaign shows the Compass.
    final section = _section == CompassSection.campaign && !game
        ? CompassSection.compass
        : _section;
    return Scaffold(
      appBar: _pushed ? AppBar() : null,
      body: SafeArea(
        top: !_pushed,
        child: SingleChildScrollView(
          key: PageStorageKey(section),
          padding: const EdgeInsetsDirectional.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l.compassTitle,
                subtitle: switch (section) {
                  CompassSection.compass => l.compassSubtitle,
                  CompassSection.missions => l.compassMissionsSubtitle,
                  CompassSection.campaign => l.campaignSubtitle,
                },
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
                child: PillTabs<CompassSection>(
                  tabs: [
                    PillTab(
                      value: CompassSection.compass,
                      label: l.compassSectionCompass,
                    ),
                    PillTab(
                      value: CompassSection.missions,
                      label: l.compassSectionMissions,
                    ),
                    if (game)
                      PillTab(
                        value: CompassSection.campaign,
                        label: l.campaignSection,
                      ),
                  ],
                  selected: section,
                  onChanged: _select,
                ),
              ),
              CarthaPageMotion(
                page: section,
                child: switch (section) {
                  CompassSection.compass => CompassView(
                    onOpenMissions: () => _select(CompassSection.missions),
                  ),
                  CompassSection.missions => MissionsView(
                    leversHandledFor: _leversHandledFor,
                    onLeversHandled: (levers) =>
                        setState(() => _leversHandledFor = levers),
                  ),
                  CompassSection.campaign => CampaignView(
                    onOpenCompass: () => _select(CompassSection.compass),
                    onOpenMissions: () => _select(CompassSection.missions),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
