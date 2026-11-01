import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../journal/journal_kit.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'builder_categories.dart';
import 'builder_motto.dart';
import 'builder_options.dart';
import 'builder_preview.dart';
import 'persona_copy.dart';
import 'persona_ops.dart';

/// Create or edit the avatar and motto (persona plan § B).
///
/// The live preview sits on top, then one category at a time (Skin … Banner)
/// as labelled choices, the optional motto, and **Remove avatar** when one
/// exists; **Save** stays reachable in the bottom bar. Nothing is stored until
/// Save. Locked Campaign extras are shown with their lock and reason but
/// can't be chosen; an extra the saved avatar already wears stays usable.
/// Leaving with unsaved changes asks first; a save or removal that didn't
/// reach the phone's storage is said so, with Retry on top.
class PersonaBuilderScreen extends StatefulWidget {
  const PersonaBuilderScreen({super.key});

  @override
  State<PersonaBuilderScreen> createState() => _PersonaBuilderScreenState();
}

class _PersonaBuilderScreenState extends State<PersonaBuilderScreen> {
  late final AppState _state;

  /// The avatar being edited (nothing is stored before Save).
  late Avatar _draft;
  late final TextEditingController _motto;
  final _scroll = ScrollController();
  final _random = Random();
  var _category = BuilderCategory.skin;
  var _busy = false;
  var _leaving = false;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    final saved = _state.persona;
    _draft = saved?.avatar ?? const Avatar();
    _motto = TextEditingController(text: saved?.motto ?? '')
      ..addListener(_onMotto);
  }

  @override
  void dispose() {
    _motto
      ..removeListener(_onMotto)
      ..dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onMotto() => setState(() {});

  /// Whether the draft differs from what is saved (or from a fresh avatar
  /// when nothing is saved yet).
  bool get _dirty {
    final saved = _state.persona;
    return _draft != (saved?.avatar ?? const Avatar()) ||
        _motto.text != (saved?.motto ?? '');
  }

  bool get _canSave =>
      !_busy &&
      !mottoTooLong(_motto.text) &&
      (_state.persona == null || _dirty);

  OptionAccess _accessOf(Enum value) {
    final needed = requirementOf(value);
    if (needed == null || _state.avatarUnlocks.contains(needed)) {
      return OptionAccess.open;
    }
    return _state.canUse(value) ? OptionAccess.kept : OptionAccess.locked;
  }

  void _pick(Enum? value) {
    if (value != null && !_state.canUse(value)) return;
    setState(() => _draft = _category.apply(_draft, value));
  }

  void _surprise() {
    final l = AppLocalizations.of(context);
    final before = _draft;
    setState(() {
      _draft = surpriseAvatar(_random, _state.canUse, current: _draft);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l.personaBuilderSurprised),
          action: SnackBarAction(
            label: l.personaBuilderUndo,
            onPressed: () {
              if (mounted) setState(() => _draft = before);
            },
          ),
        ),
      );
  }

  /// Scrolls up to the save indicator (Retry / Export a copy).
  void _showProblem() {
    if (!_scroll.hasClients) return;
    if (motionEnabled(context)) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scroll.jumpTo(0);
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await _state.savePersona(_draft, motto: _motto.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    messenger.hideCurrentSnackBar();
    // Never claim a save that didn't happen (F-055): stay here, Retry on top.
    if (_state.saveStatus == SaveStatus.failed) {
      messenger.showSnackBar(SnackBar(content: Text(l.personaBuilderNotSaved)));
      _showProblem();
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(l.personaBuilderSaved)));
    _leave(navigator);
  }

  Future<void> _remove() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await confirmDialog(
      context,
      title: l.personaBuilderRemoveTitle,
      body: l.personaBuilderRemoveBody,
      action: l.personaBuilderRemoveAction,
      destructive: true,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await _state.clearPersona();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    messenger.hideCurrentSnackBar();
    if (_state.saveStatus == SaveStatus.failed) {
      // Removed in memory only: start a fresh draft here, Retry on top.
      _motto.text = '';
      setState(() => _draft = const Avatar());
      messenger.showSnackBar(
        SnackBar(content: Text(l.personaBuilderRemovedNotSaved)),
      );
      _showProblem();
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(l.personaBuilderRemoved)));
    _leave(navigator);
  }

  void _leave(NavigatorState navigator) {
    setState(() => _leaving = true);
    if (navigator.canPop()) navigator.pop();
  }

  Future<void> _confirmLeave() async {
    final l = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    final leave = await confirmDialog(
      context,
      title: l.personaBuilderLeaveTitle,
      body: l.personaBuilderLeaveBody,
      action: l.personaBuilderLeaveAction,
      cancel: l.personaBuilderKeepEditing,
      destructive: true,
    );
    if (leave && mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _leave(navigator);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final saved = state.persona;
    final failed = state.saveStatus == SaveStatus.failed;
    final hasLocked =
        _category.hasExtras &&
        _category.options.any(
          (o) => o != null && _accessOf(o) == OptionAccess.locked,
        );

    return PopScope(
      canPop: _leaving || !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(saved == null ? l.personaCreate : l.personaEdit),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: AreaListView(
            controller: _scroll,
            children: [
              if (failed) ...[const SizedBox(height: 8), const SaveIndicator()],
              const SizedBox(height: 8),
              BuilderPreview(avatar: _draft, onSurprise: _surprise),
              const SizedBox(height: 16),
              BuilderCategoryBar(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
              const SizedBox(height: 12),
              if (hasLocked) ...[
                Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: p.textSecondary),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l.personaBuilderLockedNote,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              BuilderOptionGrid(
                key: ValueKey('persona-options-${_category.name}'),
                category: _category,
                draft: _draft,
                accessOf: _accessOf,
                reasonOf: (v) => unlockReason(l, requirementOf(v)!),
                onPick: _pick,
              ),
              const SizedBox(height: 24),
              BuilderMottoField(controller: _motto),
              if (saved != null) ...[
                const SizedBox(height: 24),
                DestructiveButton(
                  key: const ValueKey('persona-remove'),
                  label: l.personaBuilderRemove,
                  icon: Icons.person_remove_outlined,
                  onPressed: _busy ? null : _remove,
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: p.background,
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: kReadableWidth),
                  child: PrimaryButton(
                    key: const ValueKey('persona-save'),
                    label: l.save,
                    icon: Icons.check,
                    expand: true,
                    busy: _busy,
                    onPressed: _canSave ? _save : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
