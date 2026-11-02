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

/// The one-month project (F-030): a title linked to Compass › one-month
/// project (editing offers to update the Compass, never silently), status,
/// milestones and a retrospective — all autosaved. Nothing is stored until
/// the user changes something.
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

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _title = BoundText(_state.projectOrDraft.title);
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
      _title.sync(_state.projectOrDraft.title, pending: _titleSave.hasPending);

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
    await _state.addMilestone(text);
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
      body: l.missionsProjectClearBody,
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
                              onSelected: (_) => _state.setProjectStatus(s),
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
                            onSave: _state.setProjectRetrospective,
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
                      const SizedBox(height: 16),
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
