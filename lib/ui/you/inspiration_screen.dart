import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../journal/journal_kit.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// The persistent source credit (F-002, F-038, F-039): title, author,
/// publication date, both links (opened in the browser — the app's only
/// outbound action), the independence and paraphrase notices, and what comes
/// from the source versus what Cartharise added. Two taps from any tab
/// (You › Inspiration).
class InspirationScreen extends StatelessWidget {
  const InspirationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final credit = context.read<AppState>().content.credit;
    final article = Uri.parse(credit.articleUrl);
    final newsletter = Uri.parse(credit.newsletterUrl);

    Widget linkHint(Uri uri) => Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 6, 8, 0),
      child: Text(
        l.youInspirationLinkHint(uri.host),
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AreaListView(
          children: [
            ScreenHeader(
              title: l.youInspirationTitle,
              subtitle: l.youInspirationSubtitle,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
            ),
            HeroCard(
              eyebrow: l.youInspirationEyebrow,
              title: credit.title,
              trailing: CarthaEmblem(
                size: 44,
                color: p.heroAccent,
                excludeFromSemantics: true,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.youInspirationByline(credit.author),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: p.onHero,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.youInspirationPublished(credit.publishedOn),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: p.onHeroMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              key: const ValueKey('inspiration-article'),
              label: l.youInspirationReadArticle,
              trailingIcon: Icons.open_in_new,
              expand: true,
              onPressed: () => openExternalLink(context, article),
            ),
            linkHint(article),
            const SizedBox(height: 12),
            SecondaryButton(
              key: const ValueKey('inspiration-newsletter'),
              label: l.youInspirationReadNewsletter,
              trailingIcon: Icons.open_in_new,
              expand: true,
              onPressed: () => openExternalLink(context, newsletter),
            ),
            linkHint(newsletter),
            const SizedBox(height: 20),
            SectionCard(
              icon: Icons.verified_outlined,
              title: l.youInspirationIndependentTitle,
              child: Text(
                credit.independenceNotice,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.translate,
              title: l.youInspirationParaphraseTitle,
              child: Text(
                credit.paraphraseNotice,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              icon: Icons.call_split,
              title: l.youInspirationSplitTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ListHeading(
                    icon: Icons.menu_book_outlined,
                    text: l.youInspirationFromSource,
                  ),
                  for (final s in [
                    l.youInspirationSource1,
                    l.youInspirationSource2,
                    l.youInspirationSource3,
                    l.youInspirationSource4,
                  ])
                    _Bullet(s),
                  const SizedBox(height: 16),
                  _ListHeading(
                    icon: Icons.add_circle_outline,
                    text: l.youInspirationAdded,
                  ),
                  for (final s in [
                    l.youInspirationAdded1,
                    l.youInspirationAdded2,
                    l.youInspirationAdded3,
                    l.youInspirationAdded4,
                  ])
                    _Bullet(s),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l.youInspirationReadOriginal,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: p.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListHeading extends StatelessWidget {
  const _ListHeading({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: p.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              header: true,
              child: Text(text, style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
        ],
      ),
    );
  }
}

/// A list item with a small bronze dot.
class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final style = Theme.of(context).textTheme.bodyMedium;
    final lineHeight = (style?.fontSize ?? 14) * (style?.height ?? 1.4);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 0, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.textScalerOf(context).scale(lineHeight),
            child: Center(child: Icon(Icons.circle, size: 6, color: p.accent)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
