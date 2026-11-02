import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/formatting.dart';
import '../journal/journal_kit.dart' show AreaListView, AreaSectionLabel;
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'missions_logic.dart';
import 'project_art.dart';
import 'project_ops.dart';

/// Opens the project history (finished projects, newest first).
Future<void> openProjectHistory(BuildContext context) => Navigator.of(
  context,
).push<void>(MaterialPageRoute(builder: (_) => const ProjectHistoryScreen()));

/// Opens one finished project.
Future<void> openPastProject(BuildContext context, String projectId) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PastProjectScreen(projectId: projectId),
      ),
    );

/// The months a project ran: "Nov 2026", or "Oct 2026 – Nov 2026" (from
/// its start, else its last change, to when it was finished).
String projectMonths(BuildContext context, MonthProject project) {
  final l = AppLocalizations.of(context);
  final format = DateFormat.yMMM(
    Localizations.localeOf(context).toLanguageTag(),
  );
  final end = (project.archivedAt ?? project.updatedAt).toLocal();
  final start = (project.startedAt ?? end).toLocal();
  final a = format.format(start);
  final b = format.format(end);
  return a == b ? a : l.projectsMonths(a, b);
}

String _titleOf(AppLocalizations l, MonthProject project) =>
    project.title.trim().isEmpty ? l.missionsProjectUntitled : project.title;

/// Finished projects, newest first: each with its picture, title, months,
/// milestones done, linked tasks and attempts, and the start of its look
/// back (exactly as typed). A card opens the whole project.
class ProjectHistoryScreen extends StatelessWidget {
  const ProjectHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final past = context.watch<AppState>().pastProjects;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AreaListView(
          children: [
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SaveIndicator(),
            ),
            ScreenHeader(
              title: l.projectsHistoryTitle,
              subtitle: l.projectsHistorySubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
            ),
            if (past.isEmpty)
              EmptyState(
                key: const ValueKey('project-history-empty'),
                icon: Icons.history,
                title: l.projectsHistoryEmptyTitle,
                body: l.projectsHistoryEmptyBody,
              )
            else
              for (final project in past)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 12),
                  child: _PastProjectCard(project: project),
                ),
          ],
        ),
      ),
    );
  }
}

/// The counts of a finished project, as calm labels with words.
class _ProjectCounts extends StatelessWidget {
  const _ProjectCounts({required this.project});

  final MonthProject project;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final milestones = project.milestones;
    final tasks = state.questsOfProject(project.id).length;
    final attempts = state.attemptsOfProject(project.id).length;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ChipTag(
          label: milestones.isEmpty
              ? l.projectsNoMilestones
              : l.missionsProjectMilestones(
                  milestones.where((m) => m.done).length,
                  milestones.length,
                ),
          glyph: CarthaGlyph.progress,
        ),
        ChipTag(
          label: l.projectsTasksCount(tasks),
          icon: Icons.check_box_outlined,
        ),
        ChipTag(
          label: l.projectsAttemptsCount(attempts),
          glyph: CarthaGlyph.experiment,
        ),
      ],
    );
  }
}

class _PastProjectCard extends StatelessWidget {
  const _PastProjectCard({required this.project});

  final MonthProject project;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final art = project.art;
    final retro = project.retrospective.trim();
    return SectionCard(
      key: ValueKey('past-project-${project.id}'),
      onTap: () => openPastProject(context, project.id),
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (art != null) ...[
            ProjectArtBanner(art, height: 110, aspectRatio: 3.2),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _titleOf(l, project),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: p.textSecondary),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            projectMonths(context, project),
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 10),
          _ProjectCounts(project: project),
          if (retro.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              project.retrospective,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

/// One finished project: its picture, title and months, its milestones
/// (each ticked or open, in words), the look back exactly as typed, and the
/// tasks and attempts linked to it. It can be removed from the history (its
/// tasks and attempts stay).
class PastProjectScreen extends StatelessWidget {
  const PastProjectScreen({super.key, required this.projectId});

  final String projectId;

  Future<void> _delete(BuildContext context, MonthProject project) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: l.projectsDeleteTitle,
      body: l.projectsDeleteBody,
      action: l.projectsDeleteConfirm,
      destructive: true,
    );
    if (!ok) return;
    await state.deletePastProject(project.id);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            state.saveStatus == SaveStatus.failed
                ? l.projectsNotSaved
                : l.projectsDeleted,
          ),
        ),
      );
    if (navigator.mounted && navigator.canPop()) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    MonthProject? project;
    for (final x in state.pastProjects) {
      if (x.id == projectId) project = x;
    }
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.history,
          title: l.projectsHistoryEmptyTitle,
        ),
      );
    }
    final art = project.art;
    final archived = project.archivedAt;
    final milestones = project.milestones;
    final tasks = state.questsOfProject(project.id);
    final attempts = state.attemptsOfProject(project.id);
    final day = state.today;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AreaListView(
          children: [
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SaveIndicator(),
            ),
            ScreenHeader(
              title: l.projectsPastTitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 12),
            ),
            if (art != null) ...[
              ProjectArtBanner(
                art,
                height: 160,
                aspectRatio: 2.4,
                semanticLabel: projectArtLabel(l, art),
              ),
              const SizedBox(height: 16),
            ],
            Semantics(
              header: true,
              child: Text(
                _titleOf(l, project),
                key: const ValueKey('past-project-title'),
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 4),
            Text(projectMonths(context, project), style: secondary),
            if (archived != null)
              Text(
                l.projectsFinishedOn(
                  DateFormat.yMMMd(
                    Localizations.localeOf(context).toLanguageTag(),
                  ).format(archived.toLocal()),
                ),
                style: secondary,
              ),
            const SizedBox(height: 12),
            _ProjectCounts(project: project),
            const SizedBox(height: 16),
            SectionCard(
              glyph: CarthaGlyph.progress,
              title: l.missionsMilestones,
              child: milestones.isEmpty
                  ? Text(l.projectsNoMilestones, style: secondary)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final m in milestones)
                          _DoneRow(
                            key: ValueKey('past-milestone-${m.id}'),
                            title: m.title,
                            done: m.done,
                            doneLabel: l.projectsMilestoneDone,
                            openLabel: l.projectsMilestoneOpen,
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              icon: Icons.history_edu_outlined,
              title: l.missionsRetro,
              child: project.retrospective.trim().isEmpty
                  ? Text(l.projectsRetroEmpty, style: secondary)
                  : Text(
                      project.retrospective,
                      key: const ValueKey('past-project-retro'),
                      style: theme.textTheme.bodyLarge,
                    ),
            ),
            AreaSectionLabel(l.projectsTasks),
            if (tasks.isEmpty)
              Text(l.projectsTasksEmpty, style: secondary)
            else
              SectionCard(
                padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final q in tasks)
                      _DoneRow(
                        key: ValueKey('past-task-${q.id}'),
                        title: q.title,
                        done:
                            q.recurrence == QuestRecurrence.none &&
                            q.isDoneOn(day),
                        doneLabel: l.projectsTaskDone,
                        openLabel: q.recurrence == QuestRecurrence.daily
                            ? l.missionsQuestDaily
                            : l.projectsMilestoneOpen,
                        square: true,
                      ),
                  ],
                ),
              ),
            AreaSectionLabel(l.projectsAttempts),
            if (attempts.isEmpty)
              Text(l.projectsAttemptsEmpty, style: secondary)
            else
              for (final e in attempts)
                _AttemptRow(key: ValueKey('past-attempt-${e.id}'), entry: e),
            const SizedBox(height: 24),
            Center(
              child: TextLinkButton(
                key: const ValueKey('past-project-delete'),
                label: l.projectsDelete,
                icon: Icons.delete_outline,
                onPressed: () => _delete(context, project!),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A milestone or a task, done or not: a tick or an empty mark, the words
/// exactly as written and the state in words (never colour alone).
class _DoneRow extends StatelessWidget {
  const _DoneRow({
    super.key,
    required this.title,
    required this.done,
    required this.doneLabel,
    this.openLabel,
    this.square = false,
  });

  final String title;
  final bool done;
  final String doneLabel;

  /// The word for "not done" ("Open", or "Every day" for a daily task).
  final String? openLabel;

  /// Task boxes rather than milestone rings.
  final bool square;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final icon = square
        ? (done ? Icons.check_box : Icons.check_box_outline_blank)
        : (done ? Icons.check_circle : Icons.radio_button_unchecked);
    final word = done ? doneLabel : openLabel;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 1),
            child: Icon(
              icon,
              size: 20,
              color: done ? p.accent : p.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
          if (word != null) ...[
            const SizedBox(width: 8),
            ChipTag(
              label: word,
              tone: done ? ChipTone.success : ChipTone.neutral,
            ),
          ],
        ],
      ),
    );
  }
}

/// One linked attempt: what was tried and learned, exactly as typed, and
/// its day.
class _AttemptRow extends StatelessWidget {
  const _AttemptRow({super.key, required this.entry});

  final BattleLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: p.raised,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          border: BorderDirectional(
            start: BorderSide(color: p.accent, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.attempt, style: theme.textTheme.bodyLarge),
            if (entry.learning.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l.campaignLogLearned(entry.learning),
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              formatDayKey(context, entry.day),
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The finished projects as a keepsake (the Collection): the latest one's
/// picture and title, how many are kept, opening the history. Nothing when
/// none is finished yet.
class PastProjectsKeepsake extends StatelessWidget {
  const PastProjectsKeepsake({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final past = context.select<AppState, List<MonthProject>>(
      (s) => s.data.pastProjects,
    );
    if (past.isEmpty) return const SizedBox.shrink();
    final latest = past.first;
    final art = latest.art;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AreaSectionLabel(l.projectsKeepsakes(past.length)),
        SectionCard(
          key: const ValueKey('collection-projects'),
          onTap: () => openProjectHistory(context),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
          child: Row(
            children: [
              if (art != null)
                ProjectArtThumb(art, size: 48)
              else
                Icon(Icons.flag_outlined, color: p.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleOf(l, latest),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.projectsKeepsakesCount(past.length),
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
      ],
    );
  }
}
