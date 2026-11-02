import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../domain/content.dart';
import '../../domain/persona.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/formatting.dart';
import '../journal/journal_kit.dart';
import '../nav.dart';
import '../persona/avatar_view.dart';
import '../persona/persona_copy.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'attempt_sheet.dart';
import 'campaign_copy.dart';
import 'campaign_ops.dart';

/// The Campaign section of the Compass tab (F-058–F-064): the article's
/// "life as a game" framing over the user's own reset, Compass and quests.
/// XP and achievements come only from observable participation; nothing is
/// ever taken away, and the whole layer can be turned off in You › Settings.
class CampaignView extends StatefulWidget {
  const CampaignView({
    super.key,
    required this.onOpenCompass,
    required this.onOpenMissions,
  });

  /// Shows the Compass section (to write or revise the strategy).
  final VoidCallback onOpenCompass;

  /// Shows the Missions section (quests and the 30-day path).
  final VoidCallback onOpenMissions;

  @override
  State<CampaignView> createState() => _CampaignViewState();
}

class _CampaignViewState extends State<CampaignView> {
  /// Battle-log entries shown before "Show all".
  static const _logPreview = 5;

  final _attempt = TextEditingController();
  final _learning = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _showAllLog = false;

  @override
  void dispose() {
    _attempt.dispose();
    _learning.dispose();
    super.dispose();
  }

  Future<void> _record() async {
    final l = AppLocalizations.of(context);
    if (_attempt.text.trim().isEmpty) {
      setState(() => _error = l.campaignAttemptRequired);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    await context.read<AppState>().recordAttempt(
      _attempt.text,
      learning: _learning.text,
    );
    if (!mounted) return;
    _attempt.clear();
    _learning.clear();
    setState(() => _busy = false);
    messenger?.showSnackBar(SnackBar(content: Text(l.campaignRecorded)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final progress = state.campaign;
    final log = state.data.campaignLog;
    final shownLog = _showAllLog ? log : log.take(_logPreview).toList();
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: SaveIndicator(),
          ),
          const SizedBox(height: 8),
          _StatusCard(progress: progress, avatar: state.persona?.avatar),
          const SizedBox(height: 16),
          _StrategistCard(progress: progress),

          // Act I: the five chapters of the one-day reset (F-059).
          AreaSectionLabel(l.campaignActOne),
          Text(
            l.campaignChaptersExplored(
              progress.chaptersExplored,
              progress.chapters.length,
            ),
            style: secondary,
          ),
          const SizedBox(height: 12),
          _Grid(
            minWidth: 260,
            children: [
              for (final (i, chapter) in progress.chapters.indexed)
                _ChapterCard(number: i + 1, progress: chapter),
            ],
          ),
          const SizedBox(height: 24),

          // The six Section VII components (F-058, F-063).
          SectionCard(
            title: l.campaignMapTitle,
            icon: Icons.map_outlined,
            child: _StrategistMap(
              compass: state.compass,
              onEdit: widget.onOpenCompass,
              onQuests: widget.onOpenMissions,
            ),
          ),
          const SizedBox(height: 16),

          // The monthly boss and its battle log (F-061).
          SectionCard(
            title: l.campaignBossTitle,
            icon: Icons.shield_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.campaignBossBody, style: secondary),
                const SizedBox(height: 12),
                _Callout(
                  text: state.monthlyBoss.trim().isEmpty
                      ? l.campaignBossNoProject
                      : state.monthlyBoss,
                  muted: state.monthlyBoss.trim().isEmpty,
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
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
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
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  key: const ValueKey('campaign-record'),
                  label: l.campaignRecord,
                  icon: Icons.add,
                  expand: true,
                  busy: _busy,
                  onPressed: _record,
                ),
                const SizedBox(height: 20),
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
                  for (final entry in shownLog)
                    _LogRow(key: ValueKey(entry.id), entry: entry),
                if (log.length > _logPreview)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextLinkButton(
                      label: _showAllLog
                          ? l.campaignLogShowFewer
                          : l.campaignLogShowAll(log.length),
                      onPressed: () =>
                          setState(() => _showAllLog = !_showAllLog),
                    ),
                  ),
              ],
            ),
          ),

          // Article-based achievements (F-062).
          AreaSectionLabel(l.campaignAchievementsTitle),
          Text(l.campaignAchievementsSubtitle, style: secondary),
          const SizedBox(height: 4),
          Text(
            l.campaignAchievementsCount(
              progress.earned.length,
              Achievement.values.length,
            ),
            style: theme.textTheme.labelLarge,
          ),
          if (progress.nextAchievement != null) ...[
            const SizedBox(height: 4),
            Text(
              l.campaignNextAchievement(
                achievementName(l, progress.nextAchievement!),
                achievementBody(l, progress.nextAchievement!),
              ),
              key: const ValueKey('campaign-next-achievement'),
              style: secondary,
            ),
          ],
          const SizedBox(height: 12),
          _Grid(
            minWidth: 170,
            children: [
              for (final a in Achievement.values)
                _AchievementTile(
                  achievement: a,
                  earned: progress.earned.contains(a),
                  extraOpen: switch (_extraOf(a)) {
                    final u? => state.ownsExtra(u),
                    null => false,
                  },
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Act II: the 30-day practice (F-064).
          SectionCard(
            title: l.campaignActTwo,
            icon: Icons.route_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.campaignActTwoBody, style: secondary),
                const SizedBox(height: 12),
                _Grid(
                  minWidth: 96,
                  children: [
                    _Stat(
                      value: progress.questsCompleted,
                      label: l.campaignStatQuests,
                    ),
                    _Stat(
                      value: progress.pathDaysWritten,
                      label: l.campaignStatPath,
                    ),
                    _Stat(
                      value: progress.attempts,
                      label: l.campaignStatAttempts,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    PrimaryButton(
                      label: l.campaignContinuePath,
                      trailingIcon: Icons.arrow_forward,
                      onPressed: widget.onOpenMissions,
                    ),
                    TextLinkButton(
                      label: l.campaignReadArticle,
                      trailingIcon: Icons.open_in_new,
                      onPressed: () => openExternalLink(
                        context,
                        Uri.parse(state.content.credit.articleUrl),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.campaignNote,
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Level, XP towards the next level, and the participation note (F-060).
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.progress, required this.avatar});

  final CampaignProgress progress;

  /// The user's avatar, standing at the current stop (the emblem without
  /// one).
  final Avatar? avatar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return HeroCard(
      eyebrow: l.campaignStatusEyebrow,
      title: l.campaignLevel(progress.level, progress.xp),
      child: OnHeroTheme(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RouteMap(progress: progress, avatar: avatar),
            const SizedBox(height: 12),
            Text(
              l.campaignRouteHere(place(l, progress.waypoint)),
              style: theme.textTheme.titleSmall?.copyWith(color: p.onHero),
            ),
            const SizedBox(height: 2),
            ExcludeSemantics(
              child: Text(
                progress.nextWaypoint == null
                    ? l.campaignRouteEnd
                    : l.campaignRouteNext(
                        progress.xpToNext,
                        place(l, progress.nextWaypoint!),
                      ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.onHeroMuted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.campaignXpNote,
              style: theme.textTheme.bodyMedium?.copyWith(color: p.onHero),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextLinkButton(
                key: const ValueKey('campaign-xp-how'),
                label: l.campaignXpHow,
                icon: Icons.info_outline,
                onPressed: () => _showXpRules(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The waypoint's localized name.
String place(AppLocalizations l, Waypoint w) => l.campaignWaypoint(w.name);

/// Hannibal's route: one stop per level, the road behind filled, the next
/// stretch filled as far as the XP towards it, and the user's avatar (or the
/// emblem) standing above the current stop. Static (no motion); the avatar
/// is decorative here — the route's label says where the user is.
class _RouteMap extends StatelessWidget {
  const _RouteMap({required this.progress, required this.avatar});

  final CampaignProgress progress;
  final Avatar? avatar;

  /// The avatar's diameter above the road.
  static const avatarSize = 36.0;

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
          final x = _RoutePainter.stopX(stop, total, width);
          final left = math.min(
            math.max(0.0, x - avatarSize / 2),
            math.max(0.0, width - avatarSize),
          );
          return SizedBox(
            key: const ValueKey('campaign-route'),
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
                    ),
                  ),
                ),
                // The painter draws left to right, so the avatar is placed
                // in the same (physical) coordinates.
                Positioned(
                  key: const ValueKey('campaign-route-avatar'),
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
  });

  final int stop;
  final double toward;
  final int count;
  final Color road;
  final Color walked;
  final Color current;

  /// Radius of a stop's dot.
  static const r = 6.0;

  /// The horizontal centre of stop [i] of [count] on a road [width] wide.
  static double stopX(int i, int count, double width) {
    final step = (width - 2 * r - 4) / (count - 1);
    return r + 2 + i * step;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    Offset at(int i) => Offset(stopX(i, count, size.width), y);
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
      old.current != current;
}

/// "Your strategist": the user's avatar (or the emblem) and motto, how many
/// of the decorative extras are open, the next one and how to get it, and
/// the way into the builder. Appearance itself is always free; the extras
/// are cosmetic and never taken away.
class _StrategistCard extends StatelessWidget {
  const _StrategistCard({required this.progress});

  final CampaignProgress progress;

  /// Below this text width (scaled with the text size) the avatar sits above
  /// the words instead of beside them.
  static const _minTextWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final persona = state.persona;
    final avatar = persona?.avatar;
    // Extras chosen, kept or worn stay theirs (never taken away); with the
    // game layer off every extra is open.
    final open = {...state.avatarUnlocks, ...wornBy(avatar)};
    final allOpen = open.length == Unlockable.values.length;
    final next = state.gameEnabled ? nextUnlock(progress, owned: open) : null;
    final motto = persona?.motto ?? '';
    final hasMotto = motto.trim().isNotEmpty;
    final secondary = theme.textTheme.bodyMedium?.copyWith(
      color: p.textSecondary,
    );
    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (persona == null)
          Text(l.campaignStrategistEmpty, style: secondary)
        else if (hasMotto)
          // The motto exactly as typed.
          Text(
            motto,
            key: const ValueKey('campaign-strategist-motto'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
        if (persona == null || hasMotto) const SizedBox(height: 6),
        Text(
          l.campaignExtrasCount(open.length, Unlockable.values.length),
          style: theme.textTheme.labelLarge,
        ),
      ],
    );
    // Without an avatar the words say it; the emblem is decoration.
    final portrait = AvatarView(
      avatar: avatar,
      size: 72,
      excludeFromSemantics: avatar == null,
    );
    return SectionCard(
      key: const ValueKey('campaign-strategist'),
      title: l.personaFeatureTitle,
      icon: Icons.person_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(1);
              final beside =
                  constraints.maxWidth - 72 - 16 >= _minTextWidth * scale;
              if (!beside) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [portrait, const SizedBox(height: 12), words],
                );
              }
              return Row(
                children: [
                  portrait,
                  const SizedBox(width: 16),
                  Expanded(child: words),
                ],
              );
            },
          ),
          // Nothing is claimed that isn't so: "Every extra unlocked." only
          // when every extra is the user's.
          if (allOpen || next != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 2),
                  child: Icon(
                    next == null ? Icons.lock_open : Icons.lock_outline,
                    size: 18,
                    color: p.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    next == null
                        ? l.campaignExtrasAll
                        : l.campaignExtraNext(
                            unlockableName(l, next),
                            unlockReason(l, next),
                          ),
                    key: const ValueKey('campaign-strategist-next'),
                    style: secondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SecondaryButton(
              key: const ValueKey('campaign-strategist-open'),
              label: persona == null ? l.personaCreate : l.personaEdit,
              icon: persona == null ? Icons.add : Icons.edit_outlined,
              onPressed: () => AppNav.openPersonaBuilder(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// The avatar extra [a] opens, if any.
Unlockable? _extraOf(Achievement a) {
  for (final u in Unlockable.values) {
    if (unlockSource(u).achievement == a) return u;
  }
  return null;
}

/// The XP rules, stated plainly (F-060).
Future<void> _showXpRules(BuildContext context) {
  final l = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final rules = [
    l.campaignXpRuleReflection(kXpPerReflection),
    l.campaignXpRuleQuest(kXpPerQuest, kQuestDaysCap),
    l.campaignXpRulePath(kXpPerPathDay),
    l.campaignXpRuleAttempt(kXpPerAttemptDay),
    l.campaignXpRuleReview(kXpPerReview),
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

/// One chapter of Act I: its exercises, progress in the current reset and a
/// way into its first open question.
class _ChapterCard extends StatelessWidget {
  const _ChapterCard({required this.number, required this.progress});

  final int number;
  final ChapterProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final journey = state.data.currentJourney;
    final name = chapterName(l, progress.chapter);
    final done = l.campaignChapterDone(progress.answered, progress.total);
    String? target;
    for (final id in progress.promptIds) {
      if (!(journey?.answer(id)?.answered ?? false)) {
        target = id;
        break;
      }
    }
    target ??= progress.promptIds.firstOrNull;
    return SectionCard(
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l.campaignChapterNumber(number).toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: p.accent,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (progress.explored)
                ChipTag(
                  label: l.campaignChapterExplored,
                  icon: Icons.check,
                  tone: ChipTone.success,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Semantics(
            header: true,
            child: Text(name, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 2),
          Text(
            l.campaignChapterReflections(
              chapterArea(l, progress.chapter),
              progress.total,
            ),
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.total == 0
                  ? 0
                  : progress.answered / progress.total,
              minHeight: 6,
              semanticsLabel: done,
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(child: Text(done, style: theme.textTheme.bodySmall)),
          if (target != null) ...[
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: l.campaignChapterExploreLabel(number, name),
              excludeSemantics: true,
              onTap: () => AppNav.openPrompt(context, target!),
              child: SecondaryButton(
                key: ValueKey('campaign-chapter-$number'),
                label: l.campaignChapterExplore,
                trailingIcon: Icons.arrow_forward,
                onPressed: () => AppNav.openPrompt(context, target!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The six Compass components with their game roles (F-058); boundaries
/// stay visible as the rules of engagement (F-063).
class _StrategistMap extends StatelessWidget {
  const _StrategistMap({
    required this.compass,
    required this.onEdit,
    required this.onQuests,
  });

  final LifeCompass compass;
  final VoidCallback onEdit;
  final VoidCallback onQuests;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final rows = [
      (CompassField.antiVision, l.campaignMapAntiVision),
      (CompassField.vision, l.campaignMapVision),
      (CompassField.yearGoal, l.campaignMapYear),
      (CompassField.monthProject, l.campaignMapMonth),
      (CompassField.dailyLevers, l.campaignMapLevers),
      (CompassField.constraints, l.campaignMapBoundaries),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (field, label)) in rows.indexed) ...[
          if (i > 0) Divider(color: p.border, height: 1),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                if (compass.get(field).trim().isEmpty)
                  Text(
                    l.campaignMapEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: p.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Text(compass.get(field), style: theme.textTheme.bodyMedium),
                if (field == CompassField.constraints) ...[
                  const SizedBox(height: 6),
                  ChipTag(
                    label: l.campaignMapBoundariesNote,
                    icon: Icons.shield_outlined,
                    tone: ChipTone.accent,
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PrimaryButton(
              key: const ValueKey('campaign-map-edit'),
              label: l.campaignMapEdit,
              trailingIcon: Icons.arrow_forward,
              onPressed: onEdit,
            ),
            SecondaryButton(
              key: const ValueKey('campaign-map-quests'),
              label: l.campaignMapQuests,
              onPressed: onQuests,
            ),
          ],
        ),
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

/// The monthly project, set off like a quotation.
class _Callout extends StatelessWidget {
  const _Callout({required this.text, required this.muted});

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
            fontStyle: muted ? FontStyle.italic : null,
          ),
        ),
      ),
    );
  }
}

/// One battle-log attempt; tapping it opens the edit sheet.
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

/// An achievement: earned or not shown by icon and words, not colour alone.
class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.earned,
    required this.extraOpen,
  });

  final Achievement achievement;
  final bool earned;

  /// Whether the avatar extra it opens is the user's (kept for good once
  /// opened, even if the achievement's record is gone later).
  final bool extraOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final name = achievementName(l, achievement);
    final body = achievementBody(l, achievement);
    final status = earned ? l.campaignEarned : l.campaignNotYet;
    final extra = _extraOf(achievement);
    final reward = extra == null
        ? null
        : l.campaignAchievementExtra(unlockableName(l, extra));
    return Semantics(
      container: true,
      label: [name, body, status, ?reward].join('. '),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: earned ? p.selection : p.card,
          borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
          border: Border.all(color: earned ? p.accent : p.border),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    earned ? Icons.military_tech : Icons.radio_button_unchecked,
                    color: earned ? p.accent : p.textSecondary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      status,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: earned ? p.accent : p.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(name, style: theme.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: p.textSecondary,
                ),
              ),
              if (reward != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      extraOpen ? Icons.lock_open : Icons.lock_outline,
                      size: 16,
                      color: extraOpen ? p.accent : p.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        reward,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: extraOpen ? p.textPrimary : p.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A count and what it counts.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

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

/// Lays [children] out in as many equal columns as fit [minWidth] each
/// (scaled with the text size), up to three.
class _Grid extends StatelessWidget {
  const _Grid({required this.minWidth, required this.children});

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
