import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../content/content.dart' show ContentKind;
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../voice/dictate_button.dart';
import '../voice/listen_button.dart';
import '../widgets/widgets.dart';
import 'reset_complete_screen.dart';
import 'reset_flow.dart';

/// How long typing must pause before the answer is written (PLAN.md §5).
const Duration kAnswerAutosaveDelay = Duration(milliseconds: 600);

/// One reset question at a time (F-011): context, the question (with an
/// optional softer wording), help, a labelled example, and an answer field
/// that autosaves (F-012) — debounced while typing, and flushed when moving
/// on, leaving, the app going to the background, or the screen being
/// disposed. Back / Skip / Save & continue / Jump / Pause, and "Feeling
/// heavy?" → soften, pause or Support (F-046, F-047).
///
/// Moving between prompts happens in place (one route), along the core
/// order morning → daytime → evening, or within the optional
/// contemplations. After the last evening prompt → [ResetCompleteScreen].
class GuidedPromptScreen extends StatefulWidget {
  const GuidedPromptScreen({super.key, required this.promptId});

  final String promptId;

  @override
  State<GuidedPromptScreen> createState() => _GuidedPromptScreenState();
}

enum _HeavyChoice { softer, skip, pause, support }

class _GuidedPromptScreenState extends State<GuidedPromptScreen>
    with WidgetsBindingObserver {
  late final AppState _state = context.read<AppState>();
  late String _promptId = widget.promptId;
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;

  /// Typed text that hasn't been handed to [AppState.saveAnswer] yet.
  bool _dirty = false;

  /// Softer wording stays on for the following prompts until switched off.
  bool _softer = false;

  @override
  void initState() {
    super.initState();
    _loadAnswer();
    WidgetsBinding.instance.addObserver(this);
    // Saving notifies listeners, which must not happen during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _markActive();
    });
  }

  Prompt? get _prompt => _state.content.prompt(_promptId);

  void _loadAnswer() {
    _controller.text = _state.answer(_promptId)?.body ?? '';
    _dirty = false;
  }

  void _markActive() {
    if (_prompt != null) _state.setActivePrompt(_promptId);
  }

  void _onChanged(String _) {
    _dirty = true;
    _debounce?.cancel();
    _debounce = Timer(kAnswerAutosaveDelay, _flush);
  }

  /// Writes pending text now (exactly as typed).
  void _flush() {
    _debounce?.cancel();
    _debounce = null;
    if (!_dirty) return;
    _dirty = false;
    _state.saveAnswer(_promptId, _controller.text);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _flush();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    if (_dirty) {
      // The tree is locked while it is torn down and saving notifies
      // listeners, so write right after instead. Nothing typed is lost.
      final state = _state, id = _promptId, text = _controller.text;
      _dirty = false;
      scheduleMicrotask(() => state.saveAnswer(id, text));
    }
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  void _goTo(String id) {
    _flush();
    if (id == _promptId) return;
    setState(() {
      _promptId = id;
      _loadAnswer();
    });
    _markActive();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  List<Prompt> _sequence(Prompt prompt) =>
      resetSequenceFor(_state.content, prompt);

  void _advance() {
    final prompt = _prompt;
    if (prompt == null) return;
    final seq = _sequence(prompt);
    final i = seq.indexWhere((p) => p.id == prompt.id);
    if (i >= 0 && i < seq.length - 1) {
      _goTo(seq[i + 1].id);
    } else if (prompt.core) {
      _flush();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ResetCompleteScreen()),
      );
    } else {
      _pause();
    }
  }

  void _back() {
    final prompt = _prompt;
    if (prompt == null) return;
    final seq = _sequence(prompt);
    final i = seq.indexWhere((p) => p.id == prompt.id);
    if (i > 0) _goTo(seq[i - 1].id);
  }

  void _saveAndContinue() {
    _flush();
    _advance();
  }

  void _skip() {
    _flush();
    _state.skipPrompt(_promptId);
    _advance();
  }

  void _pause() {
    _flush();
    Navigator.of(context).maybePop();
  }

  // ── Sheets ──────────────────────────────────────────────────────────────

  void _showHelp(Prompt prompt) {
    final l = AppLocalizations.of(context);
    showResetSheet<void>(
      context,
      title: l.resetHelpLink,
      motion: motionEnabled(context),
      children: (sheet) => [
        Text(prompt.help, style: Theme.of(sheet).textTheme.bodyLarge),
        const SizedBox(height: 20),
        SecondaryButton(
          label: l.close,
          expand: true,
          onPressed: () => Navigator.of(sheet).pop(),
        ),
      ],
    );
  }

  Future<void> _showJump(Prompt current) async {
    final l = AppLocalizations.of(context);
    final prompts = _state.content.byPhase(current.phase);
    final id = await showResetSheet<String>(
      context,
      title: l.resetJumpTitle(phaseName(l, current.phase)),
      motion: motionEnabled(context),
      children: (sheet) => [
        for (final p in prompts)
          _JumpRow(
            prompt: p,
            current: p.id == current.id,
            onTap: () => Navigator.of(sheet).pop(p.id),
          ),
      ],
    );
    if (id != null && mounted) _goTo(id);
  }

  Future<void> _showHeavy(Prompt prompt) async {
    final l = AppLocalizations.of(context);
    final canSoften = prompt.softerQuestion != null && !_softer;
    final choice = await showResetSheet<_HeavyChoice>(
      context,
      title: l.resetHeavyTitle,
      motion: motionEnabled(context),
      children: (sheet) {
        void pick(_HeavyChoice c) => Navigator.of(sheet).pop(c);
        final theme = Theme.of(sheet);
        return [
          Text(l.resetHeavyBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          if (canSoften) ...[
            SecondaryButton(
              label: l.resetHeavySofter,
              icon: Icons.spa_outlined,
              expand: true,
              onPressed: () => pick(_HeavyChoice.softer),
            ),
            const SizedBox(height: 10),
          ],
          SecondaryButton(
            label: l.resetHeavySkip,
            icon: Icons.redo,
            expand: true,
            onPressed: () => pick(_HeavyChoice.skip),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: l.resetHeavyPause,
            icon: Icons.pause,
            expand: true,
            onPressed: () => pick(_HeavyChoice.pause),
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: l.resetHeavySupport,
            icon: Icons.support_outlined,
            expand: true,
            onPressed: () => pick(_HeavyChoice.support),
          ),
          const SizedBox(height: 16),
          Text(l.resetHeavyCrisis, style: theme.textTheme.bodyMedium),
        ];
      },
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case _HeavyChoice.softer:
        setState(() => _softer = true);
      case _HeavyChoice.skip:
        _skip();
      case _HeavyChoice.pause:
        _pause();
      case _HeavyChoice.support:
        _flush();
        unawaited(AppNav.openSupport(context));
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final prompt = state.content.prompt(_promptId);
    if (prompt == null) {
      return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          top: false,
          child: ReadingColumn(
            children: [EmptyState(title: l.resetPromptMissing)],
          ),
        ),
      );
    }
    final theme = Theme.of(context);
    final p = CarthaPalette.of(context);
    final phasePrompts = state.content.byPhase(prompt.phase);
    final n = phasePrompts.indexWhere((x) => x.id == prompt.id) + 1;
    final total = phasePrompts.length;
    final seq = _sequence(prompt);
    final index = seq.indexWhere((x) => x.id == prompt.id);
    final isLast = prompt.core && index == seq.length - 1;
    final status = statusOf(state.answer(prompt.id));
    final softer = prompt.softerQuestion;
    final question = _softer && softer != null ? softer : prompt.question;
    final time = checkinTimeOf(state, prompt);
    final position = l.resetQuestionOf(n, total);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _flush();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: l.resetPauseTooltip,
            onPressed: _pause,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              tooltip: l.resetJumpTooltip,
              onPressed: () => _showJump(prompt),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          top: false,
          child: CarthaPageMotion(
            page: prompt.id,
            child: ReadingColumn(
              controller: _scroll,
              top: 0,
              children: [
                Eyebrow(
                  '${phaseName(l, prompt.phase)} · '
                  '${subflowName(l, prompt.group.subflow)}',
                ),
                const SizedBox(height: 8),
                Text(position, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : n / total,
                    minHeight: 6,
                    semanticsLabel: position,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // A daytime prompt's group is "Check-in": the timed
                    // chip below says it already.
                    if (time == null)
                      ChipTag(label: groupName(l, prompt.group)),
                    if (time != null)
                      ChipTag(
                        label: l.resetCheckinTime(
                          formatLocalTime(context, time),
                        ),
                        icon: Icons.schedule,
                        tone: ChipTone.accent,
                      ),
                    if (!prompt.core) ChipTag(label: l.resetOptionalChip),
                    if (status != PromptStatus.open)
                      PromptStatusTag(status: status),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  prompt.title,
                  style: theme.textTheme.titleSmall?.copyWith(color: p.accent),
                ),
                const SizedBox(height: 6),
                Text(
                  prompt.context,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Semantics(
                  header: true,
                  liveRegion: true,
                  child: Text(
                    question,
                    style: theme.textTheme.titleLarge?.copyWith(height: 1.35),
                  ),
                ),
                if (softer != null) ...[
                  const SizedBox(height: 4),
                  SwitchListTile(
                    value: _softer,
                    onChanged: (v) => setState(() => _softer = v),
                    title: Text(l.resetSofter),
                    subtitle: Text(l.resetSofterHint),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
                Wrap(
                  spacing: 4,
                  children: [
                    TextLinkButton(
                      label: l.resetHelpLink,
                      icon: Icons.help_outline,
                      onPressed: () => _showHelp(prompt),
                    ),
                    // Listen: the question as shown (softer if chosen).
                    ListenButton(
                      key: ValueKey('reset-question-listen-${prompt.id}'),
                      text: () => [
                        prompt.context,
                        _softer && softer != null ? softer : prompt.question,
                      ].join('\n\n'),
                      languageTag: contentListenTag(
                        context,
                        ContentKind.prompt,
                        prompt.id,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _ExamplePanel(
                  key: ValueKey(prompt.id),
                  example: prompt.example,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  onChanged: _onChanged,
                  minLines: 5,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l.resetAnswerLabel,
                    hintText: l.resetAnswerHint,
                    alignLabelWithHint: true,
                  ),
                ),
                // Speak, review, then it goes in at the cursor (autosaved).
                DictateButton(
                  key: const ValueKey('reset-answer-dictate'),
                  controller: _controller,
                  onInserted: _onChanged,
                ),
                // The user's own answer, read aloud only on this tap.
                ListenButton(
                  key: const ValueKey('reset-answer-listen'),
                  text: () => _controller.text,
                  label: l.listenMyAnswer,
                  watch: _controller,
                ),
                if (status == PromptStatus.skipped) ...[
                  const SizedBox(height: 8),
                  Text(l.resetSkippedNote, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 8),
                const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SaveIndicator(),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: isLast ? l.resetSaveFinish : l.resetSaveContinue,
                  trailingIcon: Icons.arrow_forward,
                  expand: true,
                  onPressed: _saveAndContinue,
                ),
                const SizedBox(height: 12),
                _ButtonPair(
                  first: SecondaryButton(
                    label: l.back,
                    icon: Icons.arrow_back,
                    expand: true,
                    onPressed: index > 0 ? _back : null,
                  ),
                  second: SecondaryButton(
                    label: l.resetSkip,
                    expand: true,
                    onPressed: _skip,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  children: [
                    TextLinkButton(
                      label: l.resetJump,
                      icon: Icons.format_list_bulleted,
                      onPressed: () => _showJump(prompt),
                    ),
                    TextLinkButton(
                      label: l.resetPause,
                      icon: Icons.pause,
                      onPressed: _pause,
                    ),
                    TextLinkButton(
                      label: l.resetHeavyLink,
                      icon: Icons.spa_outlined,
                      onPressed: () => _showHeavy(prompt),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two buttons side by side, or stacked when the row would be too narrow
/// for their labels (small phones, large text).
class _ButtonPair extends StatelessWidget {
  const _ButtonPair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      if (constraints.maxWidth / scale < 300) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [first, const SizedBox(height: 10), second],
        );
      }
      return Row(
        children: [
          Expanded(child: first),
          const SizedBox(width: 12),
          Expanded(child: second),
        ],
      );
    },
  );
}

/// "Example — not a right answer", collapsed until asked for.
class _ExamplePanel extends StatefulWidget {
  const _ExamplePanel({super.key, required this.example});

  final String example;

  @override
  State<_ExamplePanel> createState() => _ExamplePanelState();
}

class _ExamplePanelState extends State<_ExamplePanel> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final motion = motionEnabled(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            onTap: () => setState(() => _open = !_open),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        Icons.lightbulb_outline,
                        size: 20,
                        color: p.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.resetExampleTitle,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    ExcludeSemantics(
                      child: Icon(
                        _open ? Icons.expand_less : Icons.expand_more,
                        color: p.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
            child: Text(widget.example, style: theme.textTheme.bodyMedium),
          ),
      ],
    );
    return Material(
      color: p.raised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        side: BorderSide(color: p.border),
      ),
      clipBehavior: Clip.antiAlias,
      // No AnimatedSize at all when motion is off (a zero-length one would
      // complete inside layout).
      child: motion
          ? AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional.topStart,
              child: content,
            )
          : content,
    );
  }
}

/// A row of the Jump sheet: number + title, status icon AND words.
class _JumpRow extends StatelessWidget {
  const _JumpRow({
    required this.prompt,
    required this.current,
    required this.onTap,
  });

  final Prompt prompt;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final status = statusOf(state.answer(prompt.id));
    final time = checkinTimeOf(state, prompt);
    final details = [
      if (current) l.resetStateCurrent,
      statusLabel(l, status),
      if (time != null) l.resetCheckinTime(formatLocalTime(context, time)),
    ].join(' · ');
    return ListTile(
      selected: current,
      selectedTileColor: p.selection,
      selectedColor: p.textPrimary,
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
      leading: PromptStatusIcon(status: status),
      title: Text('${prompt.ordinal}. ${prompt.title}'),
      subtitle: Text(details),
      onTap: onTap,
    );
  }
}
