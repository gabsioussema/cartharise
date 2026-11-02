import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/autosave.dart';
import '../compass/formatting.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'campaign_copy.dart';
import 'campaign_kit.dart';
import 'campaign_ops.dart';

/// The Playground's **Try**: one tiny real-world experiment at a time, with
/// **Previous** / **Next** (round the list).
///
/// **I tried it** records the try for today with an optional note, exactly
/// as typed; it lands in the Collection. The note is kept as a draft per
/// experiment while it is typed (debounced, on leaving, when the app goes
/// to the background), so leaving or a restart never drops it.
/// **Add to my tasks** is separate and explicit: it makes a quest only when
/// tapped, and trying never adds one. A save that didn't reach the phone's
/// storage is said so, with Retry on top.
class TryScreen extends StatefulWidget {
  const TryScreen({super.key, this.chapter, this.experimentId});

  /// Start at this chapter's first experiment not tried yet.
  final CampaignChapter? chapter;

  /// Start at this experiment (wins over [chapter]).
  final String? experimentId;

  @override
  State<TryScreen> createState() => _TryScreenState();
}

class _TryScreenState extends State<TryScreen> {
  late final AppState _state;
  late int _index;
  late final TextEditingController _note;
  late final Autosaver _draft;
  final _scroll = ScrollController();

  /// The experiment whose note is waiting to be autosaved.
  String? _draftFor;
  bool _busy = false;

  List<Experiment> get _experiments => _state.content.experiments;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _index = _startIndex();
    final all = _experiments;
    _note = TextEditingController(
      text: all.isEmpty ? '' : _state.tryNoteDraft(all[_index].id),
    );
    _draft = Autosaver((text) async {
      final id = _draftFor;
      if (id != null) await _state.saveTryNoteDraft(id, text);
    });
  }

  @override
  void dispose() {
    _draft.dispose();
    _note.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _noteChanged(String text) {
    final all = _experiments;
    if (all.isEmpty) return;
    _draftFor = all[_index.clamp(0, all.length - 1)].id;
    _draft.changed(text);
  }

  int _startIndex() {
    final all = _experiments;
    final id = widget.experimentId;
    if (id != null) {
      final i = all.indexWhere((e) => e.id == id);
      if (i >= 0) return i;
    }
    final chapter = widget.chapter;
    final candidates = [
      for (final (i, e) in all.indexed)
        if (chapter == null || e.chapter == chapter) i,
    ];
    for (final i in candidates) {
      if (!_state.hasTried(all[i].id)) return i;
    }
    return candidates.firstOrNull ?? 0;
  }

  void _go(int delta) {
    final all = _experiments;
    if (all.isEmpty) return;
    // This experiment's note is kept before showing the next one's.
    _draft.flush();
    setState(() => _index = (_index + delta) % all.length);
    final text = _state.tryNoteDraft(all[_index].id);
    _note.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _snack(String text, {SnackBarAction? action}) =>
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text), action: action));

  /// "I tried it": recorded for today with the note exactly as typed.
  Future<void> _tried(Experiment experiment) async {
    final l = AppLocalizations.of(context);
    FocusManager.instance.primaryFocus?.unfocus();
    // A waiting draft save goes first, so it can't bring the draft back
    // after the try removed it.
    _draft.flush();
    setState(() => _busy = true);
    try {
      await _state.tryExperiment(experiment.id, note: _note.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    // The try (and its note) is in the Collection either way; only a write
    // that worked is called saved.
    _note.clear();
    if (_state.saveStatus == SaveStatus.failed) {
      _snack(l.campaignNotSavedYet);
      scrollToSaveIndicator(context, _scroll);
      return;
    }
    _snack(l.campaignTryRecorded);
  }

  /// "Add to my tasks": one quest, only when asked; never a duplicate of
  /// one still open.
  Future<void> _addToTasks(Experiment experiment) async {
    final l = AppLocalizations.of(context);
    final before = {for (final q in _state.data.quests) q.id};
    setState(() => _busy = true);
    final Quest quest;
    try {
      quest = await _state.addExperimentToTasks(experiment.id);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    if (_state.saveStatus == SaveStatus.failed) {
      _snack(l.campaignNotSavedYet);
      scrollToSaveIndicator(context, _scroll);
      return;
    }
    _snack(
      before.contains(quest.id) ? l.campaignTryAlreadyTask : l.campaignTryAdded,
      action: SnackBarAction(
        label: l.campaignTryOpenTasks,
        onPressed: () => AppNav.openMissions(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final all = state.content.experiments;
    if (all.isEmpty) {
      return CampaignScreen(
        title: l.campaignTryTitle,
        children: [
          EmptyState(
            icon: GlyphIcon.placeholderFor(CarthaGlyph.experiment),
            title: l.campaignTryEmpty,
          ),
        ],
      );
    }
    final index = _index.clamp(0, all.length - 1);
    final experiment = all[index];
    ExperimentEntry? last;
    for (final e in state.experimentLog) {
      if (e.experimentId == experiment.id) {
        last = e;
        break;
      }
    }
    return CampaignScreen(
      title: l.campaignTryTitle,
      subtitle: l.campaignTryScreenSubtitle,
      controller: _scroll,
      children: [
        _ExperimentCard(
          key: ValueKey('try-card-${experiment.id}'),
          experiment: experiment,
          triedOn: last?.day,
          showXp: state.gameEnabled && last == null,
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('try-note'),
          controller: _note,
          minLines: 1,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l.campaignTryNoteLabel,
            hintText: l.campaignTryNoteHint,
            hintMaxLines: 2,
          ),
          onChanged: _noteChanged,
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          key: const ValueKey('try-done'),
          label: l.campaignTryDone,
          icon: Icons.check,
          expand: true,
          busy: _busy,
          onPressed: () => _tried(experiment),
        ),
        const SizedBox(height: 8),
        SecondaryButton(
          key: const ValueKey('try-add-task'),
          label: l.campaignTryAddTask,
          icon: Icons.add_task,
          expand: true,
          onPressed: _busy ? null : () => _addToTasks(experiment),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            TextLinkButton(
              key: const ValueKey('try-previous'),
              label: l.campaignTryPrevious,
              icon: Icons.arrow_back,
              onPressed: all.length < 2 ? null : () => _go(-1),
            ),
            Text(
              l.campaignTryPosition(index + 1, all.length),
              key: const ValueKey('try-position'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: p.textSecondary,
              ),
            ),
            TextLinkButton(
              key: const ValueKey('try-next'),
              label: l.next,
              trailingIcon: Icons.arrow_forward,
              onPressed: all.length < 2 ? null : () => _go(1),
            ),
          ],
        ),
      ],
    );
  }
}

/// One experiment: its chapter, title, about how long it takes, whether it
/// was tried (and when), and its one to three steps.
class _ExperimentCard extends StatelessWidget {
  const _ExperimentCard({
    super.key,
    required this.experiment,
    required this.triedOn,
    required this.showXp,
  });

  final Experiment experiment;

  /// The day it was last tried, or null.
  final String? triedOn;

  /// Whether to show "+10 XP" (game on, not tried yet).
  final bool showXp;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final tried = triedOn;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlyphIcon(CarthaGlyph.experiment, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  chapterName(l, experiment.chapter).toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: p.accent,
                    letterSpacing: CarthaFonts.of(context).spacing(1.4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Semantics(
            header: true,
            child: Text(experiment.title, style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChipTag(
                label: l.campaignTryMinutes(experiment.minutes),
                icon: Icons.schedule,
              ),
              if (tried != null)
                ChipTag(
                  key: const ValueKey('try-tried'),
                  label: l.campaignTriedOn(formatDayKey(context, tried)),
                  icon: Icons.check,
                  tone: ChipTone.success,
                ),
              if (showXp)
                Semantics(
                  label: l.campaignTryXpLabel(kXpPerExperiment),
                  excludeSemantics: true,
                  child: ChipTag(
                    key: const ValueKey('try-xp'),
                    label: l.campaignQuestXp(kXpPerExperiment),
                    icon: Icons.auto_awesome,
                    tone: ChipTone.accent,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          for (final (i, step) in experiment.steps.indexed)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: Semantics(
                container: true,
                label: l.campaignTryStepLabel(i + 1, step),
                excludeSemantics: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      // Grows with the text instead of clipping the digit.
                      constraints: const BoxConstraints(
                        minWidth: 26,
                        minHeight: 26,
                      ),
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 6,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: p.selection,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: p.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(step, style: theme.textTheme.bodyLarge),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
