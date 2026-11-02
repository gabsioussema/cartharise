import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/autosave.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'missions_copy.dart';
import 'missions_logic.dart';
import 'project_art.dart';
import 'project_art_picker.dart';
import 'project_finish.dart';
import 'project_history_screen.dart';
import 'project_ops.dart';

/// The one-month project (F-030): a title linked to Compass › one-month
/// project (editing offers to update the Compass, never silently), a
/// picture (a painted scene or a photo), status, milestones and a
/// retrospective — all autosaved. Nothing is stored until the user changes
/// something. **Finish this project** keeps it in the history (with its
/// milestones, tasks and attempts); the history is one tap away.
class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late final AppState _state;
  late final BoundText _title;
  late final Autosaver _titleSave;
  final _titleFocus = FocusNode();

  /// The title the user chose to keep different from the Compass.
  String? _keptTitle;

  /// The project just finished on this screen (its "kept" card).
  MonthProject? _finished;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _title = BoundText(_state.projectShownTitle);
    _titleSave = Autosaver((text) {
      _title.saved(text);
      return _state.setProjectTitle(text);
    });
    _titleFocus.addListener(() {
      if (!_titleFocus.hasFocus) _titleSave.flush();
    });
    // Outside changes (project cleared, Compass edited) reach the field
    // here, never while building.
    _state.addListener(_syncTitle);
  }

  void _syncTitle() =>
      _title.sync(_state.projectShownTitle, pending: _titleSave.hasPending);

  @override
  void dispose() {
    _state.removeListener(_syncTitle);
    _titleSave.dispose();
    _titleFocus.dispose();
    _title.dispose();
    super.dispose();
  }

  void _snack(String text, {SnackBarAction? action}) =>
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          // Undo stays for the usual few seconds, not until dismissed.
          SnackBar(content: Text(text), action: action, persist: false),
        );

  /// Runs [change], which creates the project from the draft on the first
  /// change. The draft takes the Compass's title; when the screen shows
  /// another one (typed, or none because the Compass names a finished
  /// project), that title is saved first, so what is seen is what is kept.
  Future<void> _withProject(Future<void> Function() change) {
    if (_state.data.project == null) _titleSave.flush();
    if (_state.data.project != null) return change();
    final shown = _title.controller.text;
    if (shown.trim() == _state.compass.monthProject.trim()) return change();
    _title.saved(shown);
    return _state.setProjectTitle(shown).then((_) => change());
  }

  /// Says so when the last change didn't reach the phone's storage (the
  /// save indicator on the page offers Retry).
  bool _reportFailedSave() {
    if (_state.saveStatus != SaveStatus.failed) return false;
    _snack(AppLocalizations.of(context).projectsNotSaved);
    return true;
  }

  Future<void> _chooseArt() async {
    FocusManager.instance.primaryFocus?.unfocus();
    await showProjectArtPicker(
      context,
      current: _state.data.project?.art,
      onChoose: (art) async {
        await _withProject(() => _state.setProjectArt(art));
        if (mounted) _reportFailedSave();
      },
    );
  }

  Future<void> _removeArt() async {
    final l = AppLocalizations.of(context);
    final art = _state.data.project?.art;
    if (art == null) return;
    if (art.photo != null) {
      // A camera photo may exist nowhere else: ask first.
      final ok = await confirmDialog(
        context,
        title: l.projectsPhotoRemoveTitle,
        body: l.projectsPhotoRemoveBody,
        action: l.projectsPhotoRemoveConfirm,
        destructive: true,
      );
      if (!ok) return;
    }
    await _state.setProjectArt(null);
    if (!mounted || _reportFailedSave()) return;
    _snack(l.projectsPictureRemoved);
  }

  /// "Finish this project": the notes typed so far are saved first, the
  /// sheet asks for a short look back, then the project moves to the
  /// history. "Kept" is said only once that reached the phone's storage.
  Future<void> _finish() async {
    final l = AppLocalizations.of(context);
    // Leaving the fields saves what was typed (a focus change is applied
    // in a microtask; the save follows it at once).
    FocusManager.instance.primaryFocus?.unfocus();
    _titleSave.flush();
    await Future<void>.microtask(() {});
    if (!mounted) return;
    final project = _state.data.project;
    if (project == null) return;
    final state = _state;
    final retro = await showFinishProjectSheet(
      context,
      project: project,
      onKeep: (text) {
        if (state.data.project?.id == project.id) {
          state.setProjectRetrospective(text);
        }
      },
    );
    if (retro == null || !mounted) return;
    if (_state.data.project?.id != project.id) return;
    final archived = await _state.archiveProject(retrospective: retro);
    if (!mounted || _reportFailedSave()) return;
    setState(() => _finished = archived);
    _snack(l.projectsFinishedSnack);
  }

  Future<void> _updateCompass() async {
    final l = AppLocalizations.of(context);
    _titleSave.flush();
    await _state.updateCompassField(
      CompassField.monthProject,
      _title.controller.text.trim(),
    );
    if (mounted) _snack(l.missionsProjectCompassUpdated);
  }

  Future<void> _addMilestone() async {
    final l = AppLocalizations.of(context);
    final text = await askText(
      context,
      title: l.missionsMilestoneNew,
      action: l.add,
      requireText: true,
      maxLines: 3,
    );
    if (text == null || text.trim().isEmpty) return;
    await _withProject(() async {
      await _state.addMilestone(text);
    });
  }

  Future<void> _renameMilestone(Milestone m) async {
    final l = AppLocalizations.of(context);
    final text = await askText(
      context,
      title: l.missionsMilestoneRename,
      action: l.save,
      initial: m.title,
      requireText: true,
      maxLines: 3,
    );
    if (text == null || text.trim().isEmpty) return;
    await _state.renameMilestone(m.id, text);
  }

  Future<void> _deleteMilestone(Milestone m) async {
    final l = AppLocalizations.of(context);
    final index = _state.projectOrDraft.milestones.indexWhere(
      (x) => x.id == m.id,
    );
    await _state.deleteMilestone(m.id);
    if (!mounted) return;
    final state = _state;
    _snack(
      l.missionsMilestoneDeleted,
      action: SnackBarAction(
        label: l.missionsUndo,
        onPressed: () => state.restoreMilestone(m, index),
      ),
    );
  }

  Future<void> _clearProject() async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.missionsProjectClearTitle,
      body: _state.data.project?.art?.photo != null
          ? l.projectsClearBodyPhoto
          : l.missionsProjectClearBody,
      action: l.missionsProjectClearConfirm,
      destructive: true,
    );
    if (!ok) return;
    _titleSave.flush();
    await _state.saveProject(null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final saved = state.data.project;
    final project = state.projectOrDraft;
    final past = state.pastProjects;
    final finished = saved == null ? _finished : null;
    final compassTitle = state.compass.monthProject.trim();
    final typed = _title.controller.text.trim();
    final linked = typed.isNotEmpty && typed == compassTitle;
    final offer = typed.isNotEmpty && !linked && typed != _keptTitle;
    final done = project.milestones.where((m) => m.done).length;
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenHeader(
                title: l.missionsProjectTitle,
                subtitle: l.missionsProjectScreenSubtitle,
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (past.isNotEmpty && finished == null) ...[
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextLinkButton(
                          key: const ValueKey('project-history-link'),
                          label: l.projectsHistoryLink(past.length),
                          icon: Icons.history,
                          onPressed: () => openProjectHistory(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (finished != null) ...[
                      _FinishedCard(
                        project: finished,
                        onHistory: () => openProjectHistory(context),
                        onNext: () {
                          setState(() => _finished = null);
                          _titleFocus.requestFocus();
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    SectionCard(
                      glyph: CarthaGlyph.direction,
                      title: l.missionsProjectTitleLabel,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Semantics(
                            label: l.missionsProjectTitleLabel,
                            child: TextField(
                              key: const ValueKey('project-title'),
                              controller: _title.controller,
                              focusNode: _titleFocus,
                              minLines: 1,
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: l.missionsProjectTitleHint,
                                hintMaxLines: 2,
                              ),
                              onChanged: (text) {
                                _titleSave.changed(text);
                                setState(() {});
                              },
                            ),
                          ),
                          if (linked) ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ChipTag(
                                label: l.missionsProjectLinked,
                                icon: Icons.link,
                                tone: ChipTone.accent,
                              ),
                            ),
                          ] else if (offer) ...[
                            const SizedBox(height: 12),
                            _CompassOffer(
                              compassTitle: compassTitle,
                              onUpdate: _updateCompass,
                              onKeep: () => setState(() => _keptTitle = typed),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PictureCard(
                      art: saved?.art,
                      onChoose: _chooseArt,
                      onRemove: _removeArt,
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      icon: Icons.timeline,
                      title: l.missionsProjectStatus,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in ProjectStatus.values)
                            ChoiceChip(
                              key: ValueKey('project-status-${s.name}'),
                              label: Text(projectStatusLabel(l, s)),
                              avatar: Icon(projectStatusIcon(s)),
                              selected: project.status == s,
                              onSelected: (_) => _withProject(
                                () => _state.setProjectStatus(s),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      glyph: CarthaGlyph.progress,
                      title: l.missionsMilestones,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (project.milestones.isEmpty)
                            Text(l.missionsMilestonesEmpty, style: secondary)
                          else ...[
                            for (final m in project.milestones)
                              _MilestoneRow(
                                key: ValueKey(m.id),
                                milestone: m,
                                onDone: (v) => _state.setMilestoneDone(m.id, v),
                                onRename: () => _renameMilestone(m),
                                onDelete: () => _deleteMilestone(m),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              l.missionsProjectMilestones(
                                done,
                                project.milestones.length,
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: SecondaryButton(
                              key: const ValueKey('milestone-add'),
                              label: l.missionsMilestoneAdd,
                              icon: Icons.add,
                              onPressed: _addMilestone,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      icon: Icons.history_edu_outlined,
                      title: l.missionsRetro,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(l.missionsRetroHelp, style: secondary),
                          const SizedBox(height: 12),
                          AutosaveTextField(
                            key: const ValueKey('project-retro'),
                            value: project.retrospective,
                            minLines: 4,
                            semanticLabel: l.missionsRetro,
                            decoration: InputDecoration(
                              hintText: l.missionsRetroHint,
                            ),
                            onSave: (text) => _withProject(
                              () => _state.setProjectRetrospective(text),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: SaveIndicator(),
                    ),
                    if (saved != null) ...[
                      const SizedBox(height: 20),
                      SecondaryButton(
                        key: const ValueKey('project-finish'),
                        label: l.projectsFinish,
                        icon: Icons.flag_outlined,
                        expand: true,
                        onPressed: _finish,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextLinkButton(
                          label: l.missionsProjectClear,
                          icon: Icons.restart_alt,
                          onPressed: _clearProject,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The project's picture: the chosen scene or photo with **Change picture**
/// and **Remove picture**, or a line and **Choose a picture**.
class _PictureCard extends StatelessWidget {
  const _PictureCard({
    required this.art,
    required this.onChoose,
    required this.onRemove,
  });

  final ProjectArt? art;
  final VoidCallback onChoose;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final art = this.art;
    return SectionCard(
      key: const ValueKey('project-picture'),
      icon: Icons.image_outlined,
      title: l.projectsPictureTitle,
      child: art == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.projectsPictureEmpty,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  key: const ValueKey('project-art-choose'),
                  label: l.projectsPictureChoose,
                  icon: Icons.add_photo_alternate_outlined,
                  onPressed: onChoose,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProjectArtBanner(
                  art,
                  key: const ValueKey('project-art'),
                  height: 150,
                  aspectRatio: 2.4,
                  semanticLabel: projectArtLabel(l, art),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    TextLinkButton(
                      key: const ValueKey('project-art-change'),
                      label: l.projectsPictureChange,
                      icon: Icons.image_outlined,
                      onPressed: onChoose,
                    ),
                    TextLinkButton(
                      key: const ValueKey('project-art-remove'),
                      label: l.projectsPictureRemove,
                      icon: Icons.hide_image_outlined,
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// Just finished: "Finished and kept", with the way to the history and to
/// the next project.
class _FinishedCard extends StatelessWidget {
  const _FinishedCard({
    required this.project,
    required this.onHistory,
    required this.onNext,
  });

  final MonthProject project;
  final VoidCallback onHistory;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final art = project.art;
    final title = project.title.trim().isEmpty
        ? l.missionsProjectUntitled
        : project.title.trim();
    return SectionCard(
      key: const ValueKey('project-finished'),
      icon: Icons.check_circle_outline,
      title: l.projectsFinishedTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (art != null) ...[
                ProjectArtThumb(art, size: 48),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  l.projectsFinishedBody(title),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SecondaryButton(
                key: const ValueKey('project-finished-history'),
                label: l.projectsViewHistory,
                icon: Icons.history,
                onPressed: onHistory,
              ),
              TextLinkButton(
                key: const ValueKey('project-finished-next'),
                label: l.projectsPlanNext,
                trailingIcon: Icons.arrow_forward,
                onPressed: onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Update the Compass to match?" — the only way the project title reaches
/// the Compass, and only on the user's tap.
class _CompassOffer extends StatelessWidget {
  const _CompassOffer({
    required this.compassTitle,
    required this.onUpdate,
    required this.onKeep,
  });

  final String compassTitle;
  final VoidCallback onUpdate;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final empty = compassTitle.isEmpty;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: p.raised,
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.explore_outlined, size: 20, color: p.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  empty
                      ? l.missionsProjectOfferAdd
                      : l.missionsProjectOfferUpdate(compassTitle),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 4,
            children: [
              TextLinkButton(
                label: empty
                    ? l.missionsProjectAddCompass
                    : l.missionsProjectUpdateCompass,
                onPressed: onUpdate,
              ),
              TextLinkButton(label: l.missionsProjectKeep, onPressed: onKeep),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    super.key,
    required this.milestone,
    required this.onDone,
    required this.onRename,
    required this.onDelete,
  });

  final Milestone milestone;
  final ValueChanged<bool> onDone;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final m = milestone;
    return Row(
      children: [
        Checkbox(
          key: ValueKey('milestone-check-${m.id}'),
          value: m.done,
          semanticLabel: l.missionsMilestoneMarkDone(m.title),
          onChanged: (v) => onDone(v ?? false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
            child: Text(
              m.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: m.done ? p.textSecondary : p.textPrimary,
                decoration: m.done ? TextDecoration.lineThrough : null,
                decorationColor: p.textSecondary,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: l.missionsMilestoneRenameLabel(m.title),
          icon: const Icon(Icons.edit_outlined),
          onPressed: onRename,
        ),
        IconButton(
          tooltip: l.missionsMilestoneDeleteLabel(m.title),
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
