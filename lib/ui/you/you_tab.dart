import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../campaign/campaign_ops.dart';
import '../journal/journal_kit.dart';
import '../nav.dart';
import '../persona/avatar_view.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'app_version.dart';
import 'appearance_screen.dart';
import 'font_licenses.dart';

/// The You hub (qarta settings pattern, sectioned): profile (avatar or
/// emblem, optional name and motto; pace), then Credit (Inspiration), Settings (Reminders, Appearance, Your
/// data), Care (Support & safety) and About (version, licences, replay the
/// welcome). Detail pages open full screen.
class YouTab extends StatelessWidget {
  const YouTab({super.key});

  Future<void> _editName(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final name = await askText(
      context,
      title: l.youNameDialogTitle,
      action: l.save,
      initial: state.data.profile?.displayName,
      hint: l.youNameHint,
      maxLength: 40,
      textCapitalization: TextCapitalization.words,
    );
    if (name == null) return;
    await state.updateProfile(displayName: () => name);
  }

  Future<void> _replayWelcome(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final ok = await confirmDialog(
      context,
      title: l.youReplayConfirmTitle,
      body: l.youReplayConfirmBody,
      action: l.youReplayConfirmAction,
    );
    if (ok) await state.resetOnboarding();
  }

  void _licences(BuildContext context) {
    final l = AppLocalizations.of(context);
    final credit = context.read<AppState>().content.credit;
    registerFontLicenses();
    showLicensePage(
      context: context,
      applicationName: l.appTitle,
      applicationVersion: l.youVersion(kAppVersion, kAppBuild),
      applicationIcon: const Padding(
        padding: EdgeInsets.all(12),
        child: CarthaEmblem(size: 64, excludeFromSemantics: true),
      ),
      applicationLegalese: l.youLegalese(credit.title, credit.author),
    );
  }

  void _push(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final profile = state.data.profile;
    final settings = state.settings;
    final name = profile?.displayName;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AreaListView(
          children: [
            ScreenHeader(
              title: l.youTitle,
              subtitle: l.youSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
            ),
            _ProfileCard(
              name: name,
              persona: state.persona,
              onEditName: () => _editName(context),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.directions_walk,
              title: l.youPaceTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PillTabs<Pace>(
                    key: const ValueKey('you-pace'),
                    tabs: [
                      PillTab(value: Pace.oneDay, label: l.youPaceOneDay),
                      PillTab(value: Pace.flexible, label: l.youPaceFlexible),
                    ],
                    selected: profile?.pace ?? Pace.flexible,
                    onChanged: (pace) => state.updateProfile(pace: pace),
                  ),
                  const SizedBox(height: 10),
                  Text(l.youPaceHint, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            AreaSectionLabel(l.youSectionCredit),
            _HubGroup(
              tiles: [
                _HubTile(
                  key: const ValueKey('you-inspiration'),
                  icon: Icons.auto_stories_outlined,
                  title: l.youInspiration,
                  subtitle: l.youInspirationHint,
                  onTap: () => AppNav.openInspiration(context),
                ),
              ],
            ),
            AreaSectionLabel(l.youSectionSettings),
            _HubGroup(
              tiles: [
                _HubTile(
                  key: const ValueKey('you-reminders'),
                  icon: Icons.notifications_none,
                  title: l.youReminders,
                  subtitle: settings.remindersEnabled
                      ? l.youRemindersOn
                      : l.youRemindersOff,
                  onTap: () => AppNav.openReminders(context),
                ),
                _HubTile(
                  key: const ValueKey('you-appearance'),
                  icon: Icons.palette_outlined,
                  title: l.youAppearance,
                  subtitle: l.youAppearanceSummary(
                    themeLabel(l, settings.theme),
                    appearanceLabel(l, settings.appearance),
                  ),
                  onTap: () => _push(context, const AppearanceScreen()),
                ),
                _HubSwitchTile(
                  key: const ValueKey('you-campaign'),
                  icon: Icons.flag_outlined,
                  title: l.campaignSettingTitle,
                  subtitle: l.campaignSettingHint,
                  value: settings.game,
                  onChanged: (on) =>
                      context.read<AppState>().setGameEnabled(on),
                ),
                _HubTile(
                  key: const ValueKey('you-data'),
                  icon: Icons.storage_outlined,
                  title: l.youData,
                  subtitle: l.youDataHint,
                  onTap: () => AppNav.openData(context),
                ),
              ],
            ),
            AreaSectionLabel(l.youSectionCare),
            _HubGroup(
              tiles: [
                _HubTile(
                  key: const ValueKey('you-support'),
                  icon: Icons.health_and_safety_outlined,
                  title: l.youSupport,
                  subtitle: l.youSupportHint,
                  onTap: () => AppNav.openSupport(context),
                ),
              ],
            ),
            AreaSectionLabel(l.youSectionAbout),
            _HubGroup(
              tiles: [
                _HubTile(
                  key: const ValueKey('you-version'),
                  icon: Icons.info_outline,
                  title: l.appTitle,
                  subtitle:
                      '${l.youVersion(kAppVersion, kAppBuild)}\n${l.youAboutBody}',
                ),
                _HubTile(
                  key: const ValueKey('you-licences'),
                  icon: Icons.gavel_outlined,
                  title: l.youLicences,
                  subtitle: l.youLicencesHint,
                  onTap: () => _licences(context),
                ),
                _HubTile(
                  key: const ValueKey('you-replay'),
                  icon: Icons.replay,
                  title: l.youReplayWelcome,
                  subtitle: l.youReplayWelcomeHint,
                  onTap: () => _replayWelcome(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Center(
              child: Column(
                children: [
                  const CarthaEmblem(size: 44, excludeFromSemantics: true),
                  const SizedBox(height: 8),
                  Text(
                    l.appTagline.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: p.accent,
                      letterSpacing: CarthaFonts.of(context).spacing(1.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The profile hero: the avatar (or the emblem before one exists), the
/// optional name (tap to edit) and motto, and "Create your avatar" / "Edit
/// your avatar". Two separate targets, never a button inside a button.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.name,
    required this.persona,
    required this.onEditName,
  });

  final String? name;
  final Persona? persona;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final motto = persona?.motto ?? '';
    void openBuilder() => AppNav.openPersonaBuilder(context);
    return HeroCard(
      key: const ValueKey('you-profile'),
      eyebrow: l.youProfileEyebrow,
      child: OnHeroTheme(
        child: Builder(
          builder: (context) {
            final p = CarthaPalette.of(context);
            final theme = Theme.of(context);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    // The portrait opens the builder for a tap; screen
                    // readers get the image here and the button below.
                    Semantics(
                      container: true,
                      image: true,
                      label: persona == null
                          ? l.personaNoAvatar
                          : l.personaAvatarLabel,
                      excludeSemantics: true,
                      child: InkWell(
                        key: const ValueKey('you-portrait'),
                        customBorder: const CircleBorder(),
                        onTap: openBuilder,
                        child: AvatarView(
                          avatar: persona?.avatar,
                          size: 64,
                          excludeFromSemantics: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Semantics(
                        container: true,
                        button: true,
                        label: l.youEditName,
                        child: InkWell(
                          key: const ValueKey('you-edit-name'),
                          borderRadius: BorderRadius.circular(
                            CarthaTheme.radiusSmall - 4,
                          ),
                          onTap: onEditName,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: kMinInteractiveDimension,
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name ?? l.youNoName,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(color: p.onHero),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.edit_outlined,
                                  color: p.heroAccent,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (motto.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    l.personaBuilderMottoQuoted(motto),
                    key: const ValueKey('you-motto'),
                    style: theme.textTheme.bodyLarge?.copyWith(color: p.onHero),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  l.personaBuilderProfileHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.onHeroMuted,
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: persona == null
                      ? PrimaryButton(
                          key: const ValueKey('you-avatar'),
                          label: l.personaCreate,
                          icon: Icons.face_outlined,
                          onPressed: openBuilder,
                        )
                      : SecondaryButton(
                          key: const ValueKey('you-avatar'),
                          label: l.personaEdit,
                          icon: Icons.edit_outlined,
                          onPressed: openBuilder,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A card of hub rows separated by hairlines.
class _HubGroup extends StatelessWidget {
  const _HubGroup({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return SectionCard(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, tile) in tiles.indexed) ...[
            if (i > 0) Divider(color: p.border, indent: 72, endIndent: 16),
            tile,
          ],
        ],
      ),
    );
  }
}

/// A hub row with a switch (tinted icon tile, title, hint).
class _HubSwitchTile extends StatelessWidget {
  const _HubSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return SwitchListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: p.selection,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall - 4),
        ),
        child: Icon(icon, color: p.accent, size: 22),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// One hub row: tinted icon tile, title, hint, chevron when it opens a page.
class _HubTile extends StatelessWidget {
  const _HubTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: p.selection,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall - 4),
        ),
        child: Icon(icon, color: p.accent, size: 22),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: onTap == null
          ? null
          : Icon(Icons.chevron_right, color: p.textSecondary),
      onTap: onTap,
    );
  }
}
