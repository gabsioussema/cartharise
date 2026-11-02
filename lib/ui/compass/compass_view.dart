import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'compass_field_card.dart';
import 'compass_import.dart';
import 'compass_versions.dart';
import 'formatting.dart';

/// The Compass section (F-022–F-026), board "My Direction" style: a hero with
/// the vision, an explicit offer to start from the evening answers, the six
/// field cards and the version history.
class CompassView extends StatefulWidget {
  const CompassView({super.key, required this.onOpenMissions});

  /// Shows the Missions section (lever drafts live there).
  final VoidCallback onOpenMissions;

  @override
  State<CompassView> createState() => _CompassViewState();
}

class _CompassViewState extends State<CompassView> {
  CompassField? _lastEdited;

  void _edited(CompassField field) {
    if (_lastEdited != field) setState(() => _lastEdited = field);
  }

  /// Ends editing so pending text is saved before another view reads it.
  void _flushEdits() => FocusManager.instance.primaryFocus?.unfocus();

  Future<void> _openImport() async {
    _flushEdits();
    await showCompassImport(context);
  }

  Future<void> _saveVersion() async {
    _flushEdits();
    // The focus change (a microtask) saves typed text before the snapshot.
    await Future<void>.value();
    if (mounted) await saveCompassVersionWithFeedback(context);
  }

  Future<void> _openVersions() async {
    _flushEdits();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const CompassVersionsScreen()),
    );
  }

  void _openEvening() {
    final state = context.read<AppState>();
    final evening = state.content.byPhase(PromptPhase.evening);
    if (evening.isEmpty) {
      AppNav.switchTab(context, AppTab.reset);
    } else {
      AppNav.openPrompt(context, evening.first.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final compass = state.compass;
    final preview = state.compassImportPreview;
    final hasDrafts = state.leverDrafts.isNotEmpty;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DirectionHero(compass: compass),
          const SizedBox(height: 16),
          if (preview.isNotEmpty) ...[
            _ImportOffer(empty: compass.isEmpty, onImport: _openImport),
            const SizedBox(height: 16),
          ] else if (compass.isEmpty) ...[
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlyphTitle(CarthaGlyph.direction, l.compassEmptyTitle),
                  const SizedBox(height: 12),
                  Text(l.compassEmptyBody),
                  const SizedBox(height: 8),
                  TextLinkButton(
                    label: l.compassEmptyAction,
                    trailingIcon: Icons.arrow_forward,
                    onPressed: _openEvening,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          for (final field in CompassField.values) ...[
            CompassFieldCard(
              key: ValueKey(field),
              field: field,
              value: compass.get(field),
              showSaveStatus: _lastEdited == field,
              onEdited: () => _edited(field),
              footer: switch (field) {
                CompassField.dailyLevers when hasDrafts => TextLinkButton(
                  label: l.compassLeversToQuests,
                  icon: Icons.checklist,
                  onPressed: () {
                    _flushEdits();
                    widget.onOpenMissions();
                  },
                ),
                CompassField.monthProject => TextLinkButton(
                  label: l.compassOpenProject,
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    _flushEdits();
                    AppNav.openProject(context);
                  },
                ),
                _ => null,
              },
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          SectionCard(
            icon: Icons.history,
            title: l.compassVersionsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.compassVersionsBody,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CarthaPalette.of(context).textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SecondaryButton(
                      label: l.compassSaveVersion,
                      icon: Icons.bookmark_add_outlined,
                      onPressed: _saveVersion,
                    ),
                    TextLinkButton(
                      label: l.compassViewVersions(
                        state.data.compassHistory.length,
                      ),
                      trailingIcon: Icons.arrow_forward,
                      onPressed: _openVersions,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "My Direction": the vision (or a short invitation) on the forest hero.
class _DirectionHero extends StatelessWidget {
  const _DirectionHero({required this.compass});

  final LifeCompass compass;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final vision = compass.vision.trim();
    final updated = compass.updatedAt;
    return HeroCard(
      eyebrow: l.compassHeroEyebrow,
      trailing: GlyphIcon(CarthaGlyph.direction, size: 32, color: p.heroAccent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vision.isEmpty ? l.compassHeroEmpty : vision,
            maxLines: vision.isEmpty ? null : 6,
            overflow: vision.isEmpty ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(color: p.onHero),
          ),
          if (updated != null) ...[
            const SizedBox(height: 10),
            Text(
              l.compassLastUpdated(formatDateTime(context, updated)),
              style: theme.textTheme.bodySmall?.copyWith(color: p.onHeroMuted),
            ),
          ],
        ],
      ),
    );
  }
}

/// The opt-in "populate Compass" offer (F-024): never automatic.
class _ImportOffer extends StatelessWidget {
  const _ImportOffer({required this.empty, required this.onImport});

  final bool empty;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SectionCard(
      icon: Icons.nights_stay_outlined,
      title: empty ? l.compassImportOfferTitleEmpty : l.compassImportOfferTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.compassImportOfferBody),
          const SizedBox(height: 16),
          PrimaryButton(
            label: l.compassImportAction,
            trailingIcon: Icons.arrow_forward,
            onPressed: onImport,
          ),
        ],
      ),
    );
  }
}
