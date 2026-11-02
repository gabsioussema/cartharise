import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/autosave.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'missions_copy.dart';

/// One day of the thirty-day path (F-057): stage, title, prompt, hint and an
/// autosaved note, with previous / next day. Every day is open (D-08).
class PathDayScreen extends StatefulWidget {
  const PathDayScreen({super.key, required this.day});

  /// 1–30.
  final int day;

  @override
  State<PathDayScreen> createState() => _PathDayScreenState();
}

class _PathDayScreenState extends State<PathDayScreen> {
  late int _day = widget.day.clamp(1, 30);

  @override
  void didUpdateWidget(PathDayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.day != oldWidget.day) _day = widget.day.clamp(1, 30);
  }

  void _go(int day) {
    // The note field of the day being left saves on dispose.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _day = day);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final days = state.content.thirtyDays;
    PathDay? pathDay;
    for (final d in days) {
      if (d.day == _day) pathDay = d;
    }
    if (pathDay == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.missionsPathTitle)),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: EmptyState(title: l.missionsDayMissing),
          ),
        ),
      );
    }
    final day = _day;
    final hasPrevious = days.any((d) => d.day == day - 1);
    final hasNext = days.any((d) => d.day == day + 1);
    final hint = pathDay.hint;
    return Scaffold(
      appBar: AppBar(title: Text(l.missionsPathTitle)),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          key: PageStorageKey(day),
          padding: const EdgeInsetsDirectional.only(bottom: 32),
          child: CarthaPageMotion(
            page: day,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  title: pathDay.title,
                  subtitle: l.missionsDayStage(
                    day,
                    pathStageLabel(l, pathDay.stage),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(pathDay.prompt, style: theme.textTheme.titleMedium),
                      if (hint != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsetsDirectional.all(14),
                          decoration: BoxDecoration(
                            color: p.raised,
                            borderRadius: BorderRadius.circular(
                              CarthaTheme.radiusSmall,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 20,
                                color: p.accent,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  hint,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      AutosaveTextField(
                        key: ValueKey('path-answer-$day'),
                        value: state.data.pathAnswers[day]?.body ?? '',
                        minLines: 6,
                        dictation: true,
                        semanticLabel: l.missionsDayAnswerLabel(day),
                        decoration: InputDecoration(
                          hintText: l.missionsDayAnswerHint,
                        ),
                        onSave: (text) => state.savePathAnswer(day, text),
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: SaveIndicator(),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (hasPrevious)
                            Tooltip(
                              message: l.missionsDayPreviousLabel(day - 1),
                              child: SecondaryButton(
                                key: const ValueKey('path-previous'),
                                label: l.missionsDayPrevious(day - 1),
                                icon: Icons.arrow_back,
                                onPressed: () => _go(day - 1),
                              ),
                            ),
                          if (hasNext)
                            Tooltip(
                              message: l.missionsDayNextLabel(day + 1),
                              child: SecondaryButton(
                                key: const ValueKey('path-next'),
                                label: l.missionsDayNext(day + 1),
                                trailingIcon: Icons.arrow_forward,
                                onPressed: () => _go(day + 1),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l.missionsPathIntro,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
