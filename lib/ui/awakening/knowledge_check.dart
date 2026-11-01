import 'package:flutter/material.dart';

import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// A lesson's three-option check. Picking shows kind feedback and the
/// explanation; the user may pick again. Nothing is scored or stored.
class KnowledgeCheckCard extends StatefulWidget {
  const KnowledgeCheckCard({super.key, required this.check});

  final KnowledgeCheck check;

  @override
  State<KnowledgeCheckCard> createState() => _KnowledgeCheckCardState();
}

class _KnowledgeCheckCardState extends State<KnowledgeCheckCard> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = CarthaPalette.of(context);
    final check = widget.check;
    final picked = _picked;
    final right = picked == check.correctIndex;
    return SectionCard(
      title: l.awakeningCheckTitle,
      icon: Icons.quiz_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(check.question, style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(l.awakeningCheckHint, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          for (final (i, option) in check.options.indexed) ...[
            _Option(
              text: option,
              selected: picked == i,
              onTap: () => setState(() => _picked = i),
            ),
            const SizedBox(height: 8),
          ],
          if (picked != null)
            Semantics(
              liveRegion: true,
              container: true,
              child: Container(
                margin: const EdgeInsetsDirectional.only(top: 4),
                padding: const EdgeInsetsDirectional.all(14),
                decoration: BoxDecoration(
                  color: right ? p.successContainer : p.raised,
                  borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          right
                              ? Icons.check_circle_outline
                              : Icons.lightbulb_outline,
                          size: 20,
                          color: right ? p.onSuccessContainer : p.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            right
                                ? l.awakeningCheckRight
                                : l.awakeningCheckNotQuite,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: right
                                  ? p.onSuccessContainer
                                  : p.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(check.explanation),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One answer option: a radio-like row (selection shown by icon, outline
/// and semantics — not colour alone).
class _Option extends StatelessWidget {
  const _Option({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: Material(
        color: selected ? p.selection : p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          side: p.selectionSide(selected),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: selected ? p.accent : p.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(text)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
