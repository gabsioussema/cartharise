import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'compass_copy.dart';
import 'formatting.dart';

/// Saves a snapshot of the Compass and says so.
Future<void> saveCompassVersionWithFeedback(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final l = AppLocalizations.of(context);
  await context.read<AppState>().saveCompassVersion();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l.compassVersionSaved)));
}

/// Timestamped Compass versions, newest first (F-026): date + reason, open
/// one to read it and restore it.
class CompassVersionsScreen extends StatelessWidget {
  const CompassVersionsScreen({super.key});

  Future<void> _open(BuildContext context, CompassVersion version) async {
    final restored = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CompassVersionScreen(version: version)),
    );
    if (restored == true && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final versions = context.select((AppState s) => s.data.compassHistory);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsetsDirectional.only(bottom: 24),
          children: [
            ScreenHeader(
              title: l.compassVersionsTitle,
              subtitle: l.compassVersionsSubtitle,
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: SecondaryButton(
                  label: l.compassSaveVersion,
                  icon: Icons.bookmark_add_outlined,
                  onPressed: () => saveCompassVersionWithFeedback(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (versions.isEmpty)
              EmptyState(
                icon: Icons.history,
                title: l.compassVersionsEmptyTitle,
                body: l.compassVersionsEmptyBody,
              )
            else
              for (final v in versions)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                  child: SectionCard(
                    onTap: () => _open(context, v),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatDateTime(context, v.savedAt),
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 6),
                              ChipTag(
                                label: compassVersionReason(l, v.reason),
                                icon: Icons.bookmark_outline,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _summary(l, v.compass),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: p.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: p.textSecondary),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  /// The first written field of a version, labelled.
  static String _summary(AppLocalizations l, LifeCompass c) {
    for (final f in [
      CompassField.vision,
      ...CompassField.values.where((f) => f != CompassField.vision),
    ]) {
      final text = c.get(f).trim();
      if (text.isNotEmpty) {
        return '${CompassFieldCopy.of(l, f).title}: ${text.replaceAll('\n', ' ')}';
      }
    }
    return l.compassVersionEmptyField;
  }
}

/// One Compass version, read-only, compared field by field with the current
/// Compass; "Restore" asks first and keeps the current one as a version.
/// Pops `true` after a restore.
class CompassVersionScreen extends StatelessWidget {
  const CompassVersionScreen({super.key, required this.version});

  final CompassVersion version;

  Future<void> _restore(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.compassRestoreConfirmTitle,
      body: l.compassRestoreConfirmBody,
      action: l.compassRestoreConfirm,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<AppState>().restoreCompassVersion(version);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.compassRestored)));
    navigator.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final current = context.select((AppState s) => s.compass);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l.compassVersionTitle,
                subtitle:
                    '${formatDateTime(context, version.savedAt)} · '
                    '${compassVersionReason(l, version.reason)}',
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 16),
                child: Text(
                  l.compassVersionReadOnly,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ),
              for (final field in CompassField.values)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 12),
                  child: _VersionField(
                    field: field,
                    text: version.compass.get(field),
                    same: version.compass.get(field) == current.get(field),
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 0),
                child: PrimaryButton(
                  label: l.compassRestoreAction,
                  icon: Icons.restore,
                  expand: true,
                  onPressed: () => _restore(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionField extends StatelessWidget {
  const _VersionField({
    required this.field,
    required this.text,
    required this.same,
  });

  final CompassField field;
  final String text;
  final bool same;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final copy = CompassFieldCopy.of(l, field);
    return SectionCard(
      icon: copy.icon,
      title: copy.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text.trim().isEmpty)
            Text(
              l.compassVersionEmptyField,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            SelectableText(text, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 10),
          ChipTag(
            label: same ? l.compassVersionSameAsNow : l.compassVersionDiffers,
            icon: same ? Icons.check : Icons.compare_arrows,
            tone: same ? ChipTone.neutral : ChipTone.accent,
          ),
        ],
      ),
    );
  }
}
