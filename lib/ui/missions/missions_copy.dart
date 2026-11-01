import 'package:flutter/material.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';

String projectStatusLabel(AppLocalizations l, ProjectStatus s) => switch (s) {
  ProjectStatus.planned => l.missionsStatusPlanned,
  ProjectStatus.active => l.missionsStatusActive,
  ProjectStatus.paused => l.missionsStatusPaused,
  ProjectStatus.done => l.missionsStatusDone,
};

IconData projectStatusIcon(ProjectStatus s) => switch (s) {
  ProjectStatus.planned => Icons.edit_calendar_outlined,
  ProjectStatus.active => Icons.play_circle_outline,
  ProjectStatus.paused => Icons.pause_circle_outline,
  ProjectStatus.done => Icons.check_circle_outline,
};

String pathStageLabel(AppLocalizations l, PathStage s) => switch (s) {
  PathStage.observe => l.missionsStageObserve,
  PathStage.experiment => l.missionsStageExperiment,
  PathStage.build => l.missionsStageBuild,
  PathStage.adjust => l.missionsStageAdjust,
};

String pathStageHelp(AppLocalizations l, PathStage s) => switch (s) {
  PathStage.observe => l.missionsStageObserveHelp,
  PathStage.experiment => l.missionsStageExperimentHelp,
  PathStage.build => l.missionsStageBuildHelp,
  PathStage.adjust => l.missionsStageAdjustHelp,
};
