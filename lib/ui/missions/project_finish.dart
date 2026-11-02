import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';
import '../widgets/bidi.dart';
import '../widgets/widgets.dart';
import 'project_art.dart';

/// "Finish this project": a short look back — prefilled with the project's
/// notes so far, exactly as typed, and optional — then **Finish and keep**.
/// Returns the look-back text exactly as typed, or null when the sheet was
/// left without finishing; words changed then are handed to [onKeep] (the
/// project's notes), so nothing typed is lost.
Future<String?> showFinishProjectSheet(
  BuildContext context, {
  required MonthProject project,
  required void Function(String retrospective) onKeep,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  // Reduced motion (device or Settings › Motion): no slide.
  sheetAnimationStyle: motionEnabled(context)
      ? null
      : AnimationStyle.noAnimation,
  builder: (_) => FinishProjectSheet(project: project, onKeep: onKeep),
);

class FinishProjectSheet extends StatefulWidget {
  const FinishProjectSheet({
    super.key,
    required this.project,
    required this.onKeep,
  });

  final MonthProject project;
  final void Function(String retrospective) onKeep;

  @override
  State<FinishProjectSheet> createState() => _FinishProjectSheetState();
}

class _FinishProjectSheetState extends State<FinishProjectSheet> {
  late final _retro = TextEditingController(text: widget.project.retrospective);
  bool _finishing = false;

  @override
  void dispose() {
    final text = _retro.text;
    if (!_finishing && text != widget.project.retrospective) {
      // Saving notifies listeners: not while the sheet is being unmounted.
      final keep = widget.onKeep;
      scheduleMicrotask(() => keep(text));
    }
    _retro.dispose();
    super.dispose();
  }

  void _finish() {
    _finishing = true;
    Navigator.of(context).pop(_retro.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final project = widget.project;
    final art = project.art;
    final title = project.title.trim().isEmpty
        ? l.missionsProjectUntitled
        : project.title;
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
            child: Text(l.projectsFinish, style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 6),
          Text(
            l.projectsFinishSheetBody,
            style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsetsDirectional.all(12),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                if (art != null) ...[
                  ProjectArtThumb(art, size: 44),
                  const SizedBox(width: 12),
                ] else ...[
                  Icon(Icons.flag_outlined, color: p.accent),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TypedDirection(
            controller: _retro,
            builder: (context, direction) => TextField(
              key: const ValueKey('project-finish-retro'),
              controller: _retro,
              textDirection: direction,
              minLines: 3,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.missionsRetro,
                hintText: l.missionsRetroHelp,
                hintMaxLines: 3,
                alignLabelWithHint: true,
              ),
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            key: const ValueKey('project-finish-confirm'),
            label: l.projectsFinishConfirm,
            icon: Icons.flag_outlined,
            expand: true,
            onPressed: _finish,
          ),
          const SizedBox(height: 4),
          Center(
            child: TextLinkButton(
              key: const ValueKey('project-finish-cancel'),
              label: l.cancel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
