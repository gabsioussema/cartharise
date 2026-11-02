import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/autosave.dart';
import '../compass/formatting.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'attempt_sheet.dart';
import 'campaign_kit.dart';
import 'campaign_ops.dart';

/// The monthly boss and its battle log (F-061): the month project, the
/// boss's strength (its milestones), **What did you actually try?** and the
/// attempts, newest first.
///
/// The form keeps its words: they are autosaved as a draft exactly as typed
/// (debounced, on leaving, when the app goes to the background) and come
/// back when the page opens again. "Attempt recorded." is said only once the
/// attempt reached the phone's storage; a failed save says so, keeps the
/// words in the form and points to Retry at the top.
class BattleLogScreen extends StatefulWidget {
  const BattleLogScreen({super.key});

  @override
  State<BattleLogScreen> createState() => _BattleLogScreenState();
}

/// An attempt recorded in memory whose save failed, with the words it was
/// recorded with.
typedef _Unsaved = ({String id, String attempt, String learning});

class _BattleLogScreenState extends State<BattleLogScreen> {
  late final AppState _state;
  late final TextEditingController _attempt;
  late final TextEditingController _learning;
  late final Autosaver _draft;
  final _scroll = ScrollController();
  String? _error;
  bool _busy = false;

  /// Set while the last recorded attempt is not saved yet.
  _Unsaved? _unsaved;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    final draft = _state.attemptDraft;
    _attempt = TextEditingController(text: draft?.attempt ?? '');
    _learning = TextEditingController(text: draft?.learning ?? '');
    // Both fields are saved together; the text passed along only marks
    // that something is waiting.
    _draft = Autosaver((_) => _saveDraft());
    _state.addListener(_onState);
  }

  @override
  void dispose() {
    _state.removeListener(_onState);
    _draft.dispose();
    _attempt.dispose();
    _learning.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // Reads the fields when the save runs (a microtask after dispose at the
  // latest; reading a disposed controller's text is harmless).
  Future<void> _saveDraft() =>
      _state.saveAttemptDraft(_attempt.text, _learning.text);

  void _changed() {
    _draft.changed(_attempt.text);
    if (_error != null) setState(() => _error = null);
  }

  /// A Retry from the save indicator that worked: the attempt is saved now,
  /// so the form can clear — unless the words were changed since.
  void _onState() {
    final unsaved = _unsaved;
    // While recording, [_record] says how it went.
    if (unsaved == null || !mounted || _busy) return;
    if (_state.saveStatus != SaveStatus.saved) return;
    _unsaved = null;
    if (_attempt.text == unsaved.attempt &&
        _learning.text == unsaved.learning) {
      _clearForm();
      _snack(AppLocalizations.of(context).campaignRecorded);
    }
  }

  void _clearForm() {
    _attempt.clear();
    _learning.clear();
    if (mounted) setState(() {});
  }

  void _snack(String text) => ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));

  Future<void> _record() async {
    final l = AppLocalizations.of(context);
    if (_attempt.text.trim().isEmpty) {
      setState(() => _error = l.campaignAttemptRequired);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    // A waiting draft save goes first, so it can't bring the draft back
    // after the attempt removed it.
    _draft.flush();
    setState(() => _busy = true);
    final unsaved = _unsaved;
    final attempt = _attempt.text;
    final learning = _learning.text;
    try {
      if (unsaved != null &&
          unsaved.attempt == attempt &&
          unsaved.learning == learning &&
          _state.data.campaignLog.any((e) => e.id == unsaved.id)) {
        // The same words again after a failed save: write again rather than
        // record a second attempt.
        await _state.retrySave();
      } else {
        final entry = await _state.recordAttempt(attempt, learning: learning);
        _unsaved = (id: entry.id, attempt: attempt, learning: learning);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    if (_state.saveStatus == SaveStatus.failed) {
      // Never claim it was recorded: the words stay, Retry is on top.
      _snack(l.campaignAttemptNotSaved);
      scrollToSaveIndicator(context, _scroll);
      return;
    }
    _unsaved = null;
    _clearForm();
    _snack(l.campaignRecorded);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final progress = state.campaign;
    final log = state.data.campaignLog;
    final boss = state.monthlyBoss.trim();
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    return CampaignScreen(
      title: l.campaignBattleLogTitle,
      subtitle: l.campaignBossBody,
      controller: _scroll,
      children: [
        SectionCard(
          title: l.campaignBossTitle,
          icon: Icons.shield_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CampaignCallout(
                text: boss.isEmpty ? l.campaignBossNoProject : boss,
                muted: boss.isEmpty,
              ),
              const SizedBox(height: 12),
              _BossStrength(progress: progress),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('campaign-attempt'),
                controller: _attempt,
                minLines: 2,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.campaignAttemptLabel,
                  hintText: l.campaignAttemptHint,
                  hintMaxLines: 3,
                  errorText: _error,
                  errorMaxLines: 3,
                ),
                onChanged: (_) => _changed(),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('campaign-learning'),
                controller: _learning,
                minLines: 2,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.campaignLearningLabel,
                  hintText: l.campaignLearningHint,
                  hintMaxLines: 3,
                ),
                onChanged: (_) => _changed(),
              ),
              // Only said while it is true (a failed save shows Retry on top).
              if (state.saveStatus != SaveStatus.failed) ...[
                const SizedBox(height: 8),
                Text(
                  l.campaignAttemptDraftNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              PrimaryButton(
                key: const ValueKey('campaign-record'),
                label: l.campaignRecord,
                icon: Icons.add,
                expand: true,
                busy: _busy,
                onPressed: _record,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          child: Text(
            l.campaignLogTitle(log.length),
            style: theme.textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        if (log.isEmpty)
          Text(l.campaignLogEmpty, style: secondary)
        else
          for (final entry in log)
            _LogRow(key: ValueKey(entry.id), entry: entry),
      ],
    );
  }
}

/// The boss weakens only as real project milestones are reached; with none
/// yet, a pointer to add some.
class _BossStrength extends StatelessWidget {
  const _BossStrength({required this.progress});

  final CampaignProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    if (progress.milestones == 0) {
      return Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(
            l.campaignBossNoMilestones,
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          TextLinkButton(
            key: const ValueKey('campaign-boss-project'),
            label: l.campaignBossOpenProject,
            trailingIcon: Icons.arrow_forward,
            onPressed: () => AppNav.openProject(context),
          ),
        ],
      );
    }
    final remaining = progress.milestones - progress.milestonesDone;
    final status = remaining == 0
        ? l.campaignBossBeaten
        : l.campaignBossMilestones(
            progress.milestonesDone,
            progress.milestones,
          );
    return Column(
      key: const ValueKey('campaign-boss-strength'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.campaignBossStrength, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: remaining / progress.milestones,
            minHeight: 8,
            color: p.accent,
            semanticsLabel: '${l.campaignBossStrength}: $status',
          ),
        ),
        const SizedBox(height: 4),
        ExcludeSemantics(child: Text(status, style: theme.textTheme.bodySmall)),
      ],
    );
  }
}

/// One battle-log attempt, its words exactly as typed; tapping it opens the
/// edit sheet.
class _LogRow extends StatelessWidget {
  const _LogRow({super.key, required this.entry});

  final BattleLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final date = formatDayKey(context, entry.day);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Material(
        color: p.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        ),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: p.accent, width: 3),
            ),
          ),
          child: ListTile(
            onTap: () => showAttemptSheet(context, entry),
            contentPadding: const EdgeInsetsDirectional.fromSTEB(14, 6, 8, 6),
            title: Text(entry.attempt, style: theme.textTheme.bodyLarge),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.learning.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(l.campaignLogLearned(entry.learning)),
                ],
                const SizedBox(height: 4),
                Text(date, style: theme.textTheme.bodySmall),
              ],
            ),
            trailing: Icon(
              Icons.edit_outlined,
              color: p.textSecondary,
              semanticLabel: l.campaignLogEditLabel(date),
            ),
          ),
        ),
      ),
    );
  }
}
