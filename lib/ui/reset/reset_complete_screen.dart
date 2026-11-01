import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/content.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/compass_import.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'reset_flow.dart';

/// The calm end of a reset (F-022): what the user created (counts, their
/// one-sentence vision quoted exactly), an honest note on any open
/// questions, and the hand-off to the Compass import. Marks the journey
/// complete once. No "you fixed your life" celebration.
class ResetCompleteScreen extends StatefulWidget {
  const ResetCompleteScreen({super.key});

  @override
  State<ResetCompleteScreen> createState() => _ResetCompleteScreenState();
}

class _ResetCompleteScreenState extends State<ResetCompleteScreen> {
  @override
  void initState() {
    super.initState();
    // Completing notifies listeners: not allowed during the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<AppState>();
      if (state.journey.completedAt == null) state.completeJourney();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final p = CarthaPalette.of(context);
    final content = state.content;
    final journey = state.journey;

    final all = progressOf(content.prompts, journey);
    final openCore = content.corePrompts
        .where((x) => statusOf(journey.answer(x.id)) == PromptStatus.open)
        .length;
    final visionPrompt = content.promptFor(CompassField.vision);
    final visionAnswer = visionPrompt == null
        ? null
        : journey.answer(visionPrompt.id);
    final vision = visionAnswer != null && visionAnswer.answered
        ? visionAnswer.body
        : null;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: ReadingColumn(
          top: 0,
          children: [
            const Center(child: CarthaEmblem(size: 72)),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                l.resetCompleteTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.resetCompleteLead,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: p.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SectionCard(
              title: l.resetCompleteCreatedTitle,
              icon: Icons.edit_note,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.resetCompleteAnswers(all.answered),
                    style: theme.textTheme.titleSmall,
                  ),
                  if (all.skipped > 0) ...[
                    const SizedBox(height: 2),
                    Text(l.resetCompleteSkipped(all.skipped)),
                  ],
                  const SizedBox(height: 10),
                  for (final phase in PromptPhase.values)
                    if (content.byPhase(phase).isNotEmpty)
                      _PhaseLine(
                        text: () {
                          final pr = progressOf(
                            content.byPhase(phase),
                            journey,
                          );
                          return l.resetCompletePhaseLine(
                            phaseName(l, phase),
                            pr.answered,
                            pr.total,
                          );
                        }(),
                      ),
                ],
              ),
            ),
            if (vision != null) ...[
              const SizedBox(height: 16),
              HeroCard(
                eyebrow: l.resetCompleteVisionTitle,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Icon(Icons.format_quote, color: p.heroAccent),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      // The user's words, exactly as written.
                      child: Text(
                        vision,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: p.onHero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (openCore > 0) ...[
              const SizedBox(height: 16),
              Text(l.resetCompleteOpen(openCore)),
            ],
            const SizedBox(height: 24),
            Text(l.resetCompleteCompassBody, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l.resetCompleteBuildCompass,
              icon: Icons.explore_outlined,
              expand: true,
              onPressed: () => showCompassImport(context),
            ),
            const SizedBox(height: 10),
            SecondaryButton(
              label: l.resetCompleteLater,
              expand: true,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseLine extends StatelessWidget {
  const _PhaseLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 2),
            child: Icon(
              Icons.circle,
              size: 8,
              color: CarthaPalette.of(context).accent,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
