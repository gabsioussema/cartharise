import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../nav.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'journal_kit.dart';
import 'past_reset_screen.dart';

/// Journal › Look back (F-035, F-034): the user chooses two Compass moments
/// (a saved version or the Compass now) to place side by side per field, and
/// can read earlier resets. Nothing is scored, rated or labelled.
class LookBackSection extends StatefulWidget {
  const LookBackSection({super.key});

  @override
  State<LookBackSection> createState() => _LookBackSectionState();
}

/// Index into `compassHistory` (newest first), or [_now] for the Compass now.
const int _now = -1;

class _LookBackSectionState extends State<LookBackSection> {
  int _first = 0;
  int _second = _now;

  int _clamp(int choice, int length) =>
      choice == _now || choice < length ? choice : length - 1;

  String _choiceLabel(
    BuildContext context,
    List<CompassVersion> history,
    int i,
  ) {
    final l = AppLocalizations.of(context);
    if (i == _now) return l.journalCompareNow;
    final v = history[i];
    final reason = switch (v.reason) {
      CompassVersionReason.manual => l.journalVersionManual,
      CompassVersionReason.beforeImport => l.journalVersionBeforeImport,
      CompassVersionReason.beforeRestore => l.journalVersionBeforeRestore,
    };
    return l.journalVersionLabel(formatDayTime(context, v.savedAt), reason);
  }

  Future<void> _pick(
    BuildContext context, {
    required String which,
    required List<CompassVersion> history,
    required int current,
    required ValueChanged<int> onPicked,
  }) async {
    final l = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Reduced motion (device or Settings › Motion): no slide.
      sheetAnimationStyle: motionEnabled(context)
          ? null
          : AnimationStyle.noAnimation,
      builder: (sheetContext) {
        final p = CarthaPalette.of(sheetContext);
        final choices = [_now, for (var i = 0; i < history.length; i++) i];
        return SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 16),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                child: Semantics(
                  header: true,
                  child: Text(
                    l.journalComparePick(which),
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                ),
              ),
              for (final c in choices)
                Semantics(
                  selected: c == current,
                  inMutuallyExclusiveGroup: true,
                  child: ListTile(
                    key: ValueKey('compare-choice-$c'),
                    leading: Icon(
                      c == current
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: c == current ? p.accent : p.textSecondary,
                    ),
                    title: Text(_choiceLabel(sheetContext, history, c)),
                    selected: c == current,
                    selectedColor: p.textPrimary,
                    selectedTileColor: p.selection,
                    onTap: () => Navigator.pop(sheetContext, c),
                  ),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null && mounted) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final history = state.data.compassHistory;
    final past = state.pastJourneys;

    final compare = <Widget>[];
    if (history.isEmpty) {
      compare.add(
        SectionCard(
          icon: Icons.compare_arrows,
          title: l.journalCompareTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.journalCompareEmptyTitle,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l.journalCompareEmptyBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextLinkButton(
                label: l.journalOpenCompass,
                icon: Icons.explore_outlined,
                onPressed: () => AppNav.openCompass(context),
              ),
            ],
          ),
        ),
      );
    } else {
      final first = _clamp(_first, history.length);
      final second = _clamp(_second, history.length);
      LifeCompass at(int i) => i == _now ? state.compass : history[i].compass;
      final firstLabel = _choiceLabel(context, history, first);
      final secondLabel = _choiceLabel(context, history, second);
      compare.add(
        SectionCard(
          icon: Icons.compare_arrows,
          title: l.journalCompareTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.journalCompareBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _ChoiceButton(
                key: const ValueKey('compare-first'),
                which: l.journalCompareFirst,
                label: firstLabel,
                onTap: () => _pick(
                  context,
                  which: l.journalCompareFirst,
                  history: history,
                  current: first,
                  onPicked: (c) => setState(() => _first = c),
                ),
              ),
              const SizedBox(height: 8),
              _ChoiceButton(
                key: const ValueKey('compare-second'),
                which: l.journalCompareSecond,
                label: secondLabel,
                onTap: () => _pick(
                  context,
                  which: l.journalCompareSecond,
                  history: history,
                  current: second,
                  onPicked: (c) => setState(() => _second = c),
                ),
              ),
            ],
          ),
        ),
      );
      for (final field in CompassField.values) {
        final a = at(first).get(field);
        final b = at(second).get(field);
        if (a.trim().isEmpty && b.trim().isEmpty) continue;
        compare.add(const SizedBox(height: 12));
        compare.add(
          _FieldComparison(
            key: ValueKey('compare-field-${field.name}'),
            field: compassFieldLabel(l, field),
            firstLabel: firstLabel,
            first: a,
            secondLabel: secondLabel,
            second: b,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.journalLookBackIntro,
          style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: 16),
        ...compare,
        AreaSectionLabel(l.journalPastResetsTitle),
        if (past.isEmpty)
          SectionCard(
            icon: Icons.history,
            child: Text(
              l.journalPastResetsEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
              ),
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 12),
            child: Text(
              l.journalPastResetsBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ),
          for (final j in past)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: _PastResetCard(journey: j),
            ),
        ],
      ],
    );
  }
}

/// One side of the comparison: what it shows, and a tap to change it.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    super.key,
    required this.which,
    required this.label,
    required this.onTap,
  });

  final String which;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.journalComparePickerLabel(which, label),
      excludeSemantics: true,
      child: Material(
        color: p.raised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          side: BorderSide(color: p.borderStrong),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          which,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: p.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(label, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.unfold_more, color: p.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One Compass field, the two chosen moments side by side (stacked on
/// narrow screens).
class _FieldComparison extends StatelessWidget {
  const _FieldComparison({
    super.key,
    required this.field,
    required this.firstLabel,
    required this.first,
    required this.secondLabel,
    required this.second,
  });

  final String field;
  final String firstLabel;
  final String first;
  final String secondLabel;
  final String second;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final same = first == second;

    Widget block(String label, String text) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: p.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (text.trim().isEmpty)
          Text(
            l.journalCompareEmptyField,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: p.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          SelectableText(text, style: theme.textTheme.bodyMedium),
      ],
    );

    return SectionCard(
      title: field,
      trailing: same
          ? ChipTag(label: l.journalCompareSame, icon: Icons.drag_handle)
          : null,
      child: same
          ? SelectableText(first, style: theme.textTheme.bodyMedium)
          : LayoutBuilder(
              builder: (context, constraints) {
                final a = block(firstLabel, first);
                final b = block(secondLabel, second);
                if (constraints.maxWidth >= 520) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: a),
                      const SizedBox(width: 20),
                      Expanded(child: b),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    a,
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        vertical: 12,
                      ),
                      child: Divider(color: p.border),
                    ),
                    b,
                  ],
                );
              },
            ),
    );
  }
}

class _PastResetCard extends StatelessWidget {
  const _PastResetCard({required this.journey});

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final written = journey.answers.values.where((a) => a.answered).length;
    return SectionCard(
      key: ValueKey('past-reset-${journey.id}'),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PastResetScreen(journeyId: journey.id),
        ),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
      child: Row(
        children: [
          Icon(Icons.history, color: p.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.journalResetStarted(formatDay(context, journey.startedAt)),
                  style: theme.textTheme.titleSmall,
                ),
                if (journey.completedAt != null)
                  Text(
                    l.journalResetCompleted(
                      formatDay(context, journey.completedAt!),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                Text(
                  l.journalResetAnswerCount(written),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: p.textSecondary),
        ],
      ),
    );
  }
}
