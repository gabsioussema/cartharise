import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../missions/missions_view.dart';
import '../nav.dart';
import '../widgets/widgets.dart';
import 'compass_view.dart';

/// The two halves of the Compass tab (PLAN.md §2).
enum CompassSection { compass, missions }

/// The Compass tab: Cinzel header, then `PillTabs` Compass | Missions.
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
    final missions = _section == CompassSection.missions;
    return Scaffold(
      appBar: _pushed ? AppBar() : null,
      body: SafeArea(
        top: !_pushed,
        child: SingleChildScrollView(
          key: PageStorageKey(_section),
          padding: const EdgeInsetsDirectional.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l.compassTitle,
                subtitle: missions
                    ? l.compassMissionsSubtitle
                    : l.compassSubtitle,
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
                  ],
                  selected: _section,
                  onChanged: _select,
                ),
              ),
              CarthaPageMotion(
                page: _section,
                child: missions
                    ? MissionsView(
                        leversHandledFor: _leversHandledFor,
                        onLeversHandled: (levers) =>
                            setState(() => _leversHandledFor = levers),
                      )
                    : CompassView(
                        onOpenMissions: () => _select(CompassSection.missions),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
