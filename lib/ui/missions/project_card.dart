import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/bidi.dart';
import '../widgets/widgets.dart';
import 'missions_copy.dart';
import 'project_art.dart';
import 'project_ops.dart';

/// The month project at a glance in Missions (F-030) → `ProjectScreen`:
/// its picture (when chosen), title, status and milestones; without a
/// project, the Compass's one-month project as a starting point — or, when
/// that one is already finished, an invitation to plan the next.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final project = state.data.project;
    final fromCompass = state.compass.monthProject.trim();
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    final art = project?.art;
    return SectionCard(
      key: const ValueKey('missions-project'),
      glyph: CarthaGlyph.direction,
      title: l.missionsProjectTitle,
      trailing: Icon(Icons.chevron_right, color: p.textSecondary),
      onTap: () => AppNav.openProject(context),
      child: project == null
          ? Text(
              fromCompass.isEmpty
                  ? l.missionsProjectEmpty
                  : state.compassProjectFinished
                  ? l.projectsCardNext
                  : l.missionsProjectFromCompass(fromCompass),
              style: secondary,
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (art != null) ...[
                  ProjectArtThumb(
                    art,
                    key: const ValueKey('missions-project-art'),
                    size: 56,
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title.trim().isEmpty
                            ? l.missionsProjectUntitled
                            : project.title,
                        textDirection: project.title.trim().isEmpty
                            ? null
                            : textDirectionOf(project.title),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChipTag(
                            label: projectStatusLabel(l, project.status),
                            icon: projectStatusIcon(project.status),
                            tone: ChipTone.accent,
                          ),
                          if (project.milestones.isNotEmpty)
                            ChipTag(
                              label: l.missionsProjectMilestones(
                                project.milestones.where((m) => m.done).length,
                                project.milestones.length,
                              ),
                              icon: Icons.flag_outlined,
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
