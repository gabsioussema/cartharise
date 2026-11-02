/// Small pieces shared by the Campaign hub and its pages: the page frame,
/// Hannibal's route, the XP rules, a responsive grid, counts and callouts.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/campaign.dart';
import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../journal/journal_kit.dart';
import '../persona/avatar_view.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';

/// The waypoint's localized name.
String place(AppLocalizations l, Waypoint w) => l.campaignWaypoint(w.name);

/// A pushed Campaign page: a back button, the save indicator (Retry and
/// "Export a copy" after a failed save), a short title with one line under
/// it, then [children] in a scrolling, readable-width list with room for the
/// system navigation inset.
class CampaignScreen extends StatelessWidget {
  const CampaignScreen({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.controller,
  });

  /// Short (Cinzel).
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      top: false,
      bottom: false,
      child: AreaListView(
        controller: controller,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: SaveIndicator(),
          ),
          ScreenHeader(
            title: title,
            subtitle: subtitle,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
          ),
          ...children,
        ],
      ),
    ),
  );
}

/// Scrolls [controller] to the top, where the save indicator offers Retry
/// (a jump when motion is off).
void scrollToSaveIndicator(BuildContext context, ScrollController controller) {
  if (!controller.hasClients) return;
  if (motionEnabled(context)) {
    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  } else {
    controller.jumpTo(0);
  }
}

/// Hannibal's route: one stop per level, the road behind filled, the next
/// stretch filled as far as the XP towards it, and the user's avatar (or the
/// emblem) standing above the current stop. Static (no motion); the avatar
/// is decoration here — the route's label says where the user is.
///
/// [id] keys the road (`ValueKey(id)`) and the avatar (`'$id-avatar'`).
class CampaignRouteMap extends StatelessWidget {
  const CampaignRouteMap({
    super.key,
    required this.id,
    required this.progress,
    required this.avatar,
    this.avatarSize = 36,
  });

  final String id;
  final CampaignProgress progress;
  final Avatar? avatar;

  /// The avatar's diameter above the road.
  final double avatarSize;

  /// The road strip (dots and line).
  static const roadHeight = 28.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final stop = progress.waypoint.index;
    final total = Waypoint.values.length;
    return Semantics(
      label: l.campaignRouteLabel(place(l, progress.waypoint), stop + 1, total),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // The route reads in the language's direction: Carthage at the
          // start edge, Italy at the end (right to left in Arabic).
          final rtl = Directionality.of(context) == TextDirection.rtl;
          final x = _RoutePainter.stopX(stop, total, width, rtl: rtl);
          final left = math.min(
            math.max(0.0, x - avatarSize / 2),
            math.max(0.0, width - avatarSize),
          );
          return SizedBox(
            key: ValueKey(id),
            // The avatar's foot rests just above the current stop's ring.
            height: avatarSize - 4 + roadHeight,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: roadHeight,
                  child: CustomPaint(
                    painter: _RoutePainter(
                      stop: stop,
                      toward: progress.nextWaypoint == null
                          ? 0
                          : progress.levelXp / kXpPerLevel,
                      count: total,
                      road: p.heroBorder,
                      walked: p.heroAccent,
                      current: p.onHero,
                      rtl: rtl,
                    ),
                  ),
                ),
                // The painter works in physical coordinates (mirrored for
                // right to left), so the avatar is placed in the same ones.
                Positioned(
                  key: ValueKey('$id-avatar'),
                  left: left,
                  top: 0,
                  child: AvatarView(
                    avatar: avatar,
                    size: avatarSize,
                    showSigil: false,
                    excludeFromSemantics: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.stop,
    required this.toward,
    required this.count,
    required this.road,
    required this.walked,
    required this.current,
    this.rtl = false,
  });

  final int stop;
  final double toward;
  final int count;
  final Color road;
  final Color walked;
  final Color current;

  /// The road runs from the right edge to the left one (Arabic).
  final bool rtl;

  /// Radius of a stop's dot.
  static const r = 6.0;

  /// The horizontal centre of stop [i] of [count] on a road [width] wide,
  /// counted from the start edge (the right one when [rtl]).
  static double stopX(int i, int count, double width, {bool rtl = false}) {
    final step = (width - 2 * r - 4) / (count - 1);
    final x = r + 2 + i * step;
    return rtl ? width - x : x;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    Offset at(int i) => Offset(stopX(i, count, size.width, rtl: rtl), y);
    final line = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(at(0), at(count - 1), line..color = road);
    final reached = Offset.lerp(
      at(stop),
      at((stop + 1).clamp(0, count - 1)),
      toward,
    )!;
    canvas.drawLine(at(0), reached, line..color = walked);
    for (var i = 0; i < count; i++) {
      final dot = Paint()..color = i <= stop ? walked : road;
      canvas.drawCircle(at(i), i == stop ? r + 2 : r - 1, dot);
    }
    canvas.drawCircle(
      at(stop),
      r + 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = current,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      old.stop != stop ||
      old.toward != toward ||
      old.road != road ||
      old.walked != walked ||
      old.current != current ||
      old.rtl != rtl;
}

/// The XP rules, stated plainly (F-060).
Future<void> showXpRules(BuildContext context) {
  final l = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final rules = [
    l.campaignXpRuleReflection(kXpPerReflection),
    l.campaignXpRuleQuest(kXpPerQuest, kQuestDaysCap),
    l.campaignXpRulePath(kXpPerPathDay),
    l.campaignXpRuleAttempt(kXpPerAttemptDay),
    l.campaignXpRuleReview(kXpPerReview),
    l.campaignXpRuleExperiment(kXpPerExperiment),
  ];
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.campaignXpHow),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 12),
              child: Text(l.campaignXpNote, style: theme.textTheme.bodyMedium),
            ),
            for (final rule in rules)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 8),
                child: Text(rule, style: theme.textTheme.bodyMedium),
              ),
            const SizedBox(height: 4),
            Text(
              l.campaignXpRulesNote(kXpPerLevel),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.close),
        ),
      ],
    ),
  );
}

/// Lays [children] out in as many equal columns as fit [minWidth] each
/// (scaled with the text size), up to three.
class CampaignGrid extends StatelessWidget {
  const CampaignGrid({
    super.key,
    required this.minWidth,
    required this.children,
  });

  final double minWidth;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final columns = (constraints.maxWidth / (minWidth * scale))
            .floor()
            .clamp(1, 3);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

/// A count and what it counts, read out as one phrase.
class CampaignStat extends StatelessWidget {
  const CampaignStat({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: '$value $label',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.raised,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          border: Border.all(color: p.border),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$value', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Words set off like a quotation (the monthly project).
class CampaignCallout extends StatelessWidget {
  const CampaignCallout({super.key, required this.text, this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.selection,
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        border: BorderDirectional(start: BorderSide(color: p.accent, width: 3)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(14),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: muted ? p.textSecondary : p.textPrimary,
            fontStyle: muted ? CarthaFonts.of(context).italic : null,
          ),
        ),
      ),
    );
  }
}

/// A status in words with an icon (never colour alone), e.g. "Earned by
/// trying" or "Not yet".
class CampaignStatusLine extends StatelessWidget {
  const CampaignStatusLine({
    super.key,
    required this.icon,
    required this.text,
    this.strong = false,
  });

  final IconData icon;
  final String text;

  /// Accent colour for a reached state; secondary otherwise.
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final color = strong ? p.accent : p.textSecondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 1),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
