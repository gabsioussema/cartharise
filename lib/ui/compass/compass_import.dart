import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'compass_copy.dart';

/// Shows the "populate Compass from your evening answers" sheet (F-022,
/// F-024): every mappable field with the evening answer quoted exactly, a
/// checkbox per field (checked by default only when the field is empty),
/// fields that already have text kept and disabled. Confirming imports the
/// chosen fields and reports how many were filled; cancelling changes
/// nothing. Boundaries are never offered (F-025).
Future<void> showCompassImport(BuildContext context) async {
  // End any edit first so typed-but-unsaved Compass text counts as "current".
  FocusManager.instance.primaryFocus?.unfocus();
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l = AppLocalizations.of(context);
  final filled = await showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const CompassImportSheet(),
  );
  if (filled == null || filled == 0) return;
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(l.compassImportDone(filled))));
}

/// The import preview sheet. Pops with the number of fields filled, or null
/// when dismissed.
class CompassImportSheet extends StatefulWidget {
  const CompassImportSheet({super.key});

  @override
  State<CompassImportSheet> createState() => _CompassImportSheetState();
}

/// One mappable field: its evening prompt, the answer and the current text.
class _Row {
  const _Row(this.field, this.prompt, this.answer, this.current);

  final CompassField field;
  final Prompt prompt;
  final String answer;
  final String current;

  bool get hasAnswer => answer.trim().isNotEmpty;
  bool get hasText => current.trim().isNotEmpty;
  bool get importable => hasAnswer && !hasText;
}

class _CompassImportSheetState extends State<CompassImportSheet> {
  late final AppState _state;
  late Set<CompassField> _selected;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    // Default: checked only where the field is empty and an answer exists.
    _selected = _state.compassImportPreview.keys.toSet();
  }

  List<_Row> _rows(AppState state) => [
    for (final p in state.content.byPhase(PromptPhase.evening))
      if (p.mapsTo != null && p.mapsTo != CompassField.constraints)
        _Row(
          p.mapsTo!,
          p,
          state.answer(p.id)?.body ?? '',
          state.compass.get(p.mapsTo!),
        ),
  ];

  Future<void> _confirm(Set<CompassField> chosen) async {
    setState(() => _busy = true);
    final filled = await _state.importCompassFromEvening(chosen);
    if (mounted) Navigator.of(context).pop(filled);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final rows = _rows(context.watch<AppState>());
    final chosen = {
      for (final r in rows)
        if (r.importable && _selected.contains(r.field)) r.field,
    };
    final anyAnswer = rows.any((r) => r.hasAnswer);
    Widget note(Widget icon, String text) => Padding(
      padding: const EdgeInsetsDirectional.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          icon,
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            header: true,
            child: Text(
              l.compassImportTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.compassImportBody,
            style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 8),
          for (final row in rows) ...[
            _ImportRowTile(
              row: row,
              selected: row.importable && _selected.contains(row.field),
              onChanged: row.importable
                  ? (v) => setState(() {
                      v
                          ? _selected.add(row.field)
                          : _selected.remove(row.field);
                    })
                  : null,
            ),
            const Divider(),
          ],
          if (!anyAnswer)
            note(
              Icon(Icons.info_outline, size: 18, color: p.accent),
              l.compassImportNothing,
            ),
          note(
            const GlyphIcon(CarthaGlyph.boundaries, size: 18),
            l.compassImportConstraintsNote,
          ),
          note(
            Icon(Icons.history, size: 18, color: p.accent),
            l.compassImportSnapshotNote,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: l.compassImportConfirm(chosen.length),
            icon: Icons.check,
            expand: true,
            busy: _busy,
            onPressed: chosen.isEmpty ? null : () => _confirm(chosen),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextLinkButton(
              label: l.notNow,
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportRowTile extends StatelessWidget {
  const _ImportRowTile({
    required this.row,
    required this.selected,
    required this.onChanged,
  });

  final _Row row;
  final bool selected;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final copy = CompassFieldCopy.of(l, row.field);
    return CheckboxListTile(
      key: ValueKey('compass-import-${row.field.name}'),
      value: selected,
      onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsetsDirectional.zero,
      title: Text(
        copy.title,
        style: theme.textTheme.titleMedium?.copyWith(color: p.textPrimary),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            l.compassImportFrom(row.prompt.title),
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          if (row.hasAnswer) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
              decoration: BoxDecoration(
                border: BorderDirectional(
                  start: BorderSide(color: p.accent, width: 3),
                ),
              ),
              // The answer exactly as written — never trimmed or rewritten.
              child: Text(
                row.answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textPrimary,
                ),
              ),
            ),
          ],
          if (row.hasText || !row.hasAnswer) ...[
            const SizedBox(height: 8),
            ChipTag(
              label: row.hasText
                  ? l.compassImportKeeps
                  : l.compassImportNoAnswer,
              icon: row.hasText ? Icons.lock_outline : Icons.edit_off_outlined,
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
