import 'package:flutter/material.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';
import 'project_art.dart';

/// In the quest sheet: **Part of the month project** — links this task to
/// [project] (its picture then shows on the task) or, switched off, unlinks
/// it. A task of a finished project ([past]) says so and can be unlinked.
class ProjectLinkSwitch extends StatelessWidget {
  const ProjectLinkSwitch({
    super.key,
    required this.project,
    required this.value,
    required this.onChanged,
    this.past = false,
  });

  final MonthProject project;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// [project] is finished (in the history).
  final bool past;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final art = project.art;
    final title = project.title.trim().isEmpty
        ? l.missionsProjectUntitled
        : project.title.trim();
    return SwitchListTile(
      key: const ValueKey('quest-project-link'),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsetsDirectional.zero,
      secondary: art != null
          ? ProjectArtThumb(art, size: 40)
          : Icon(Icons.flag_outlined, color: p.accent),
      title: Text(past ? l.projectsQuestLinkPast : l.projectsQuestLink),
      subtitle: Text(title),
    );
  }
}
