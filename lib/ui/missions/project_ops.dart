import '../../domain/app_data.dart';
import '../../state/app_state.dart';
import 'missions_logic.dart';

/// Read-only look-ups for the project screens (history, links, art) on top
/// of [MissionsOps]. Nothing here writes.
extension ProjectViewOps on AppState {
  /// Whether the Compass's one-month project names a project already
  /// finished (archived): its words stay in the Compass, but a new draft
  /// shouldn't start under the same name.
  bool get compassProjectFinished {
    final title = compass.monthProject.trim();
    if (title.isEmpty) return false;
    return data.pastProjects.any((p) => p.title.trim() == title);
  }

  /// The title the project screen shows: the saved project's, else the
  /// Compass's one-month project — unless that one is already finished,
  /// then nothing (the next project gets its own name).
  String get projectShownTitle {
    final saved = data.project;
    if (saved != null) return saved.title;
    return compassProjectFinished ? '' : compass.monthProject.trim();
  }

  /// The quests linked to project [id], in list order.
  List<Quest> questsOfProject(String id) => [
    for (final q in data.quests)
      if (q.projectId == id) q,
  ];

  /// The battle-log attempts linked to project [id], newest first.
  List<BattleLogEntry> attemptsOfProject(String id) => [
    for (final e in data.campaignLog)
      if (e.projectId == id) e,
  ];

  /// The project a quest sheet offers to link: the quest's own project
  /// (current or past) when it still exists, else the active project.
  MonthProject? linkableProjectFor(Quest? quest) {
    final own = quest?.projectId;
    if (own != null) {
      final project = projectById(own);
      if (project != null) return project;
    }
    final active = activeProjectId;
    return active == null ? null : data.project;
  }
}
