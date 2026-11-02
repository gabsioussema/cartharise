import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'autosave.dart';
import 'compass_copy.dart';

/// One of the six Compass fields (F-023): monochrome icon, title, one-line
/// explanation and an inline multiline field that autosaves exactly what the
/// user types. Boundaries say plainly that only the user writes them (F-025).
class CompassFieldCard extends StatelessWidget {
  const CompassFieldCard({
    super.key,
    required this.field,
    required this.value,
    this.showSaveStatus = false,
    this.onEdited,
    this.footer,
  });

  final CompassField field;

  /// The stored text of [field].
  final String value;

  /// Show the [SaveIndicator] under the field (the last edited card).
  final bool showSaveStatus;

  /// Called when the user types in this card.
  final VoidCallback? onEdited;

  /// Extra actions under the field (e.g. "Turn into quests").
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final copy = CompassFieldCopy.of(l, field);
    final state = context.read<AppState>();
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 2),
                child: copy.mark(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        copy.title,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      copy.help,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (field == CompassField.constraints) ...[
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: ChipTag(
                label: l.compassConstraintsChip,
                icon: Icons.lock_outline,
                tone: ChipTone.accent,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.compassConstraintsOwnWords,
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          AutosaveTextField(
            key: ValueKey('compass-field-${field.name}'),
            value: value,
            semanticLabel: copy.title,
            decoration: InputDecoration(hintText: copy.hint, hintMaxLines: 3),
            onSave: (text) => state.updateCompassField(field, text),
            onChanged: (_) => onEdited?.call(),
          ),
          if (showSaveStatus) ...[
            const SizedBox(height: 8),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SaveIndicator(),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 4),
            Align(alignment: AlignmentDirectional.centerStart, child: footer),
          ],
        ],
      ),
    );
  }
}
