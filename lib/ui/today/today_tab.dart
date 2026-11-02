import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/campaign.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../../state/attachment_ops.dart';
import '../campaign/campaign_invite.dart';
import '../campaign/campaign_ops.dart';
import '../media/recorder_sheet.dart';
import '../media/recovered_media_card.dart';
import '../missions/missions_logic.dart';
import '../missions/quest_tile.dart' show questXpOpenOn;
import '../nav.dart';
import '../persona/avatar_view.dart';
import '../persona/persona_ops.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'next_action.dart';
import 'today_model.dart';

/// The default return view (F-036; evolve plan Step 1 › A, "balanced"):
/// greeting (+ avatar) → one next action with "Choose something else"
/// (F-037) → the Campaign invitation while unanswered → Write · Record
/// (step 2) → the three glance tiles (F-054) → today's quests → the user's
/// direction, collapsed.
/// Everything is derived from stored state; no streaks, scores, missed-day
/// counts or guilt copy (F-031).
class TodayTab extends StatelessWidget {
  const TodayTab({super.key});

  /// Most quests listed before "See all".
  static const maxQuests = 5;

  /// Content column width on tablets.
  static const maxContentWidth = 720.0;

  /// The avatar beside the greeting.
  static const avatarSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l = AppLocalizations.of(context);
    final name = state.data.profile?.displayName ?? l.todayDefaultName;
    final greeting = switch (dayPartAt(state.now())) {
      DayPart.morning => l.todayGreetingMorning(name),
      DayPart.afternoon => l.todayGreetingAfternoon(name),
      DayPart.evening => l.todayGreetingEvening(name),
    };
    final today = state.today;
    final avatar = state.persona?.avatar;
    final hints = FirstUseHints.of(state.data);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final side = math.max(
              20.0,
              (constraints.maxWidth - maxContentWidth) / 2,
            );
            return ListView(
              padding: EdgeInsetsDirectional.fromSTEB(side, 0, side, 32),
              children: [
                ScreenHeader(
                  // The user's own avatar beside the greeting, once they
                  // made one (decorative: the greeting says who it is for).
                  leading: avatar == null
                      ? null
                      : AvatarView(
                          key: const ValueKey('today-avatar'),
                          avatar: avatar,
                          size: avatarSize,
                          showSigil: false,
                          excludeFromSemantics: true,
                        ),
                  title: greeting,
                  subtitle: l.todaySubtitle,
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
                ),
                if (state.saveStatus == SaveStatus.failed) ...[
                  const SaveIndicator(),
                  const SizedBox(height: 16),
                ],
                // A recording cut off when the app closed, or a photo the
                // camera handed back: keep or discard (rare; nothing when
                // there is none).
                const RecoveredMediaCard(),
                const NextActionCard(),
                // The one-time Campaign invitation (new profiles start with
                // the game off), right below the next action.
                if (state.campaignInvitePending) ...[
                  const SizedBox(height: 16),
                  const CampaignInviteCard(key: ValueKey('today-invite')),
                ],
                const SizedBox(height: 16),
                const _WriteCapture(),
                const SizedBox(height: 16),
                _GlanceRow(summary: JourneySummary.of(state)),
                const SizedBox(height: 16),
                _FocusCard(
                  // The same "today" as Missions (missions_logic.dart).
                  quests: state.todayFocus(today),
                  laterCount: state.missionSections(today).later.length,
                  today: today,
                  firstUse: hints.quests,
                ),
                const SizedBox(height: 16),
                _DirectionCard(firstUse: hints.compass),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "Write · Record": quick capture. **Write** opens a new journal note
/// (nothing is saved until something is typed there); **Record** starts a
/// voice note at once and keeps it in a new journal note, saved as soon as
/// it is stopped (step 2). Side by side, stacked when narrow or with large
/// text.
class _WriteCapture extends StatelessWidget {
  const _WriteCapture();

  Future<void> _record(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    String? noteId;
    final outcome = await showRecorderSheet(
      context,
      keep: (recording) async {
        // "Record again" in the same sheet adds to the same note.
        final id = noteId;
        if (id != null && state.holderOf(id) == AttachmentHolder.journal) {
          await state.addAttachment(AttachmentHolder.journal, id, recording);
        } else {
          final note = await state.addJournalEntry(
            body: '',
            attachments: [recording],
          );
          noteId = note.id;
        }
        return state.saveStatus != SaveStatus.failed;
      },
    );
    if (!context.mounted || outcome == null) return;
    void open() {
      if (context.mounted) AppNav.openJournalEntry(context, entryId: noteId);
    }

    switch (outcome.end) {
      case RecorderEnd.writeInstead:
        open();
      case RecorderEnd.saved:
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l.mediaTodayRecordSaved),
            action: SnackBarAction(label: l.mediaTodayOpen, onPressed: open),
            persist: false,
          ),
        );
      case RecorderEnd.notSaved:
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(content: Text(l.mediaTodayRecordNotSaved)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    void write() => AppNav.openJournalEntry(context);
    void record() => _record(context);
    final writePart = Semantics(
      container: true,
      button: true,
      label: l.todayWriteLabel,
      onTap: write,
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('today-write'),
        onTap: write,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 12, 14),
          child: Row(
            children: [
              const GlyphIcon(CarthaGlyph.reflection, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.todayWriteHint,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: p.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.edit_outlined, size: 20, color: p.accent),
            ],
          ),
        ),
      ),
    );
    final recordPart = Semantics(
      container: true,
      button: true,
      label: l.mediaRecordLabel,
      onTap: record,
      excludeSemantics: true,
      child: InkWell(
        key: const ValueKey('today-record'),
        onTap: record,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 88),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_none, size: 20, color: p.accent),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l.mediaRecord,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: p.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return SectionCard(
      key: const ValueKey('today-capture'),
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final stacked = constraints.maxWidth < 300 * scale;
          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                writePart,
                Divider(height: 1, thickness: 1, color: p.border),
                recordPart,
              ],
            );
          }
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: writePart),
                VerticalDivider(width: 1, thickness: 1, color: p.border),
                recordPart,
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A one-line first-use hint ([FirstUseHints]): a bulb and a short line.
class _Hint extends StatelessWidget {
  const _Hint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 1),
          child: Icon(Icons.lightbulb_outline, size: 18, color: p.accent),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// "Today's focus": today's quests with accessible checkboxes.
class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.quests,
    required this.laterCount,
    required this.today,
    this.firstUse = false,
  });

  final List<Quest> quests;

  /// Open quests without a date or planned for later (Missions' "Anytime &
  /// upcoming"): not listed here, only counted, with a way there.
  final int laterCount;
  final String today;

  /// No quest exists yet: say what quests are ([FirstUseHints.quests]).
  final bool firstUse;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final shown = quests.take(TodayTab.maxQuests).toList();
    final add = TextLinkButton(
      label: l.todayFocusAdd,
      icon: Icons.add,
      onPressed: () => AppNav.openMissions(context),
    );
    return SectionCard(
      key: const ValueKey('today-focus'),
      title: l.todayFocusTitle,
      icon: Icons.flag_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (quests.isEmpty) ...[
            Text(l.todayFocusEmptyTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            if (firstUse)
              _Hint(l.todayHintQuests, key: const ValueKey('today-hint-quests'))
            else
              Text(
                l.todayFocusEmptyBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                ),
              ),
            const SizedBox(height: 8),
          ] else
            for (final q in shown) _QuestRow(quest: q, today: today),
          Wrap(
            spacing: 8,
            children: [
              add,
              if (quests.length > shown.length)
                TextLinkButton(
                  label: l.todayFocusSeeAll(quests.length),
                  onPressed: () => AppNav.openMissions(context),
                ),
              if (laterCount > 0)
                TextLinkButton(
                  key: const ValueKey('today-focus-later'),
                  label: l.todayFocusLater(laterCount),
                  onPressed: () => AppNav.openMissions(context),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  const _QuestRow({required this.quest, required this.today});

  final Quest quest;
  final String today;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final done = quest.isDoneOn(today);
    final daily = quest.recurrence == QuestRecurrence.daily;
    // The same XP preview as in Missions: while the game layer is on and
    // today's quest XP isn't used up.
    final xpOpen = context.select<AppState, bool>(
      (s) => questXpOpenOn(s, today),
    );
    final showXp = xpOpen && !done;
    void toggle() =>
        context.read<AppState>().setQuestDone(quest.id, !done, day: today);
    return Semantics(
      container: true,
      checked: done,
      label: l.todayQuestMarkDone(quest.title),
      hint: showXp ? l.campaignQuestXpLabel(kXpPerQuest) : null,
      onTap: toggle,
      excludeSemantics: true,
      child: InkWell(
        onTap: toggle,
        borderRadius: BorderRadius.circular(CarthaTheme.radiusSmall),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
          child: Row(
            children: [
              Checkbox(value: done, onChanged: (_) => toggle()),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quest.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: done ? p.textSecondary : p.textPrimary,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: p.textSecondary,
                        ),
                      ),
                      if (daily || showXp) ...[
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (daily)
                              ChipTag(
                                label: l.todayQuestDaily,
                                icon: Icons.repeat,
                              ),
                            if (showXp)
                              ChipTag(
                                key: ValueKey('today-quest-xp-${quest.id}'),
                                label: l.campaignQuestXp(kXpPerQuest),
                                icon: Icons.auto_awesome,
                                tone: ChipTone.accent,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "At a glance": small tappable tiles — reset progress, the Campaign level
/// (while the game layer is on) and the thirty-day path day (only once the
/// user has written on the path). Each opens its place in the app.
class _GlanceRow extends StatelessWidget {
  const _GlanceRow({required this.summary});

  final JourneySummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<AppState>();
    final s = summary;
    final campaign = state.settings.game ? state.campaign : null;
    final tiles = <Widget>[
      _GlanceTile(
        key: const ValueKey('today-journey'),
        icon: Icons.wb_twilight,
        title: l.todayTileReset,
        value: !s.started
            ? l.todayTileResetStart
            : s.completed
            ? l.todayTileResetDone
            : l.todayTileResetValue(s.answered, s.total),
        detail: l.todayTileResetDetail,
        label: l.todayJourneyWritten(s.answered, s.total),
        progress: s.started ? s.fraction : null,
        action: l.todayJourneyOpenReset,
        onTap: () => AppNav.switchTab(context, AppTab.reset),
      ),
      if (campaign != null)
        _GlanceTile(
          key: const ValueKey('today-campaign'),
          icon: Icons.flag_outlined,
          title: l.todayTileCampaign,
          value: l.todayTileCampaignValue(campaign.level),
          detail: '${campaign.xp} XP',
          progress: campaign.levelXp / kXpPerLevel,
          action: l.campaignTodayOpen,
          onTap: () => AppNav.openCampaign(context),
        ),
      if (s.pathDay != null)
        _GlanceTile(
          key: const ValueKey('today-path-day'),
          icon: Icons.route_outlined,
          title: l.todayTilePath,
          value: l.todayTilePathValue(s.pathDay!),
          detail: l.todayPathStageName(s.pathStage?.name ?? ''),
          action: l.todayPathOpen(s.pathNextDay ?? s.pathDay!),
          onTap: () => AppNav.openPathDay(context, s.pathNextDay ?? s.pathDay!),
        ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final fit = (constraints.maxWidth / (104 * scale)).floor();
        final columns = fit.clamp(1, tiles.length);
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final tile in tiles) SizedBox(width: width, child: tile),
          ],
        );
      },
    );
  }
}

/// One glance tile: icon, title, a big value, one detail line, an optional
/// progress bar. The whole tile is one button.
class _GlanceTile extends StatelessWidget {
  const _GlanceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
    required this.action,
    required this.onTap,
    this.progress,
    this.label,
  });

  final IconData icon;
  final String title;
  final String value;
  final String detail;
  final String action;
  final VoidCallback onTap;
  final double? progress;

  /// What a screen reader hears instead of [detail] (defaults to it).
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: l.todayTileLabel(title, value, label ?? detail),
      hint: action,
      // The card's own tap is hidden by excludeSemantics: give it here.
      onTap: onTap,
      excludeSemantics: true,
      child: SectionCard(
        onTap: onTap,
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: p.accent),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: p.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textSecondary,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: progress, minHeight: 4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Your direction", collapsed by default: a header (and one line saying
/// what is inside) that expands to the vision and this month's project
/// (the Missions project title if set, else the Compass's) → Compass.
class _DirectionCard extends StatefulWidget {
  const _DirectionCard({this.firstUse = false});

  /// The Compass was never written: say what it can become
  /// ([FirstUseHints.compass]).
  final bool firstUse;

  @override
  State<_DirectionCard> createState() => _DirectionCardState();
}

class _DirectionCardState extends State<_DirectionCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    final state = context.watch<AppState>();
    final compass = state.compass;
    final projectTitle = state.data.project?.title.trim() ?? '';
    final month = projectTitle.isNotEmpty ? projectTitle : compass.monthProject;
    final empty = compass.isEmpty && projectTitle.isEmpty;
    final hint = empty && widget.firstUse;
    final summary = !empty
        ? l.todayDirectionSummary
        : hint
        ? l.todayHintCompass
        : l.todayDirectionEmpty;
    void toggle() => setState(() => _open = !_open);

    Widget snippet(String label, String text, String placeholder) {
      final has = text.trim().isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: p.accent,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            has ? text.trim() : placeholder,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: has
                ? theme.textTheme.bodyLarge
                : theme.textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
        ],
      );
    }

    final header = Semantics(
      key: const ValueKey('today-direction-toggle'),
      container: true,
      button: true,
      expanded: _open,
      label: l.todayDirectionLabel(l.todayDirectionTitle, summary),
      onTap: toggle,
      excludeSemantics: true,
      child: InkWell(
        onTap: toggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 16, 12),
            child: Row(
              children: [
                const GlyphIcon(CarthaGlyph.direction, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.todayDirectionTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      if (hint)
                        _Hint(
                          summary,
                          key: const ValueKey('today-hint-compass'),
                        )
                      else
                        Text(
                          summary,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: p.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Open or closed shows by the chevron's direction too.
                Icon(
                  _open ? Icons.expand_less : Icons.expand_more,
                  color: p.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return SectionCard(
      key: const ValueKey('today-direction'),
      padding: EdgeInsets.zero,
      child: AnimatedSize(
        duration: motionEnabled(context)
            ? const Duration(milliseconds: 200)
            : Duration.zero,
        curve: Curves.easeOutCubic,
        alignment: AlignmentDirectional.topStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            if (_open)
              Padding(
                key: const ValueKey('today-direction-body'),
                padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!empty) ...[
                      snippet(
                        l.todayDirectionVision,
                        compass.vision,
                        l.todayDirectionNoVision,
                      ),
                      const SizedBox(height: 14),
                      snippet(
                        l.todayDirectionMonth,
                        month,
                        l.todayDirectionNoMonth,
                      ),
                      const SizedBox(height: 4),
                    ],
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextLinkButton(
                        label: l.todayOpenCompass,
                        trailingIcon: Icons.arrow_forward,
                        onPressed: () => AppNav.openCompass(context),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
