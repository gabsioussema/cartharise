import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/bidi.dart';
import '../widgets/widgets.dart';

/// "Turn your daily levers into quests" (F-028): the Compass levers as
/// editable, checkable drafts (≤ 3, bullets stripped, exact duplicates of
/// existing quests already left out by `AppState.leverDrafts`). Nothing is
/// added until the user confirms; the result is reported honestly.
class LeverDraftsCard extends StatefulWidget {
  const LeverDraftsCard({
    super.key,
    required this.drafts,
    required this.onFinished,
  });

  final List<String> drafts;

  /// Drafts were added, or the user chose "Not now".
  final VoidCallback onFinished;

  @override
  State<LeverDraftsCard> createState() => _LeverDraftsCardState();
}

class _LeverDraftsCardState extends State<LeverDraftsCard> {
  List<TextEditingController> _controllers = const [];
  List<bool> _checked = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _controllers = [
      for (final d in widget.drafts) TextEditingController(text: d),
    ];
    _checked = [for (final _ in widget.drafts) true];
  }

  @override
  void didUpdateWidget(LeverDraftsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.drafts, widget.drafts)) {
      for (final c in _controllers) {
        c.dispose();
      }
      _reset();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _chosen => [
    for (var i = 0; i < _controllers.length; i++)
      if (_checked[i] && _controllers[i].text.trim().isNotEmpty)
        _controllers[i].text,
  ];

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final state = context.read<AppState>();
    setState(() => _busy = true);
    final added = await state.addQuestsFromLevers(_chosen);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l.missionsLeversAdded(added))));
    if (mounted) setState(() => _busy = false);
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final count = _chosen.length;
    return SectionCard(
      icon: Icons.bolt_outlined,
      title: l.missionsLeversTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.missionsLeversBody,
            style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _controllers.length; i++)
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
              child: Row(
                children: [
                  Checkbox(
                    key: ValueKey('lever-check-$i'),
                    value: _checked[i],
                    semanticLabel: l.missionsLeversInclude(
                      _controllers[i].text,
                    ),
                    onChanged: _busy
                        ? null
                        : (v) => setState(() => _checked[i] = v ?? false),
                  ),
                  Expanded(
                    child: TypedDirection(
                      controller: _controllers[i],
                      builder: (context, direction) => TextField(
                        key: ValueKey('lever-draft-$i'),
                        controller: _controllers[i],
                        textDirection: direction,
                        enabled: !_busy,
                        minLines: 1,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: l.missionsLeversDraftLabel(i + 1),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: l.missionsLeversAdd(count),
            icon: Icons.add_task,
            busy: _busy,
            onPressed: count == 0 ? null : _add,
          ),
          const SizedBox(height: 4),
          Center(
            child: TextLinkButton(
              label: l.missionsLeversNotNow,
              onPressed: _busy ? null : widget.onFinished,
            ),
          ),
        ],
      ),
    );
  }
}
