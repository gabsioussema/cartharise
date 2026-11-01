import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/app_data.dart';
import '../../domain/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../theme/cartha_theme.dart';
import '../widgets/widgets.dart';
import 'journal_kit.dart';

/// A weekly review (F-033): wins, friction and one next experiment.
///
/// A saved review opens read-only with Edit and Delete; a new one
/// ([reviewId] null) opens for writing, for the current week by default
/// (Monday start, local). While writing, the three fields autosave
/// (debounced, flushed when leaving or when the app goes to the background)
/// once anything is typed; "Save review" saves at once and shows the review.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, this.reviewId});

  /// Null = a new weekly review.
  final String? reviewId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final AppState _state;
  late final TextEditingController _wins;
  late final TextEditingController _friction;
  late final TextEditingController _next;
  late final Autosaver _autosave;

  String? _id;
  late String _week;
  late bool _editing;
  bool _missing = false;
  bool _deleted = false;
  Future<WeeklyReview>? _creating;

  @override
  void initState() {
    super.initState();
    _state = context.read<AppState>();
    _id = widget.reviewId;
    final review = _id == null ? null : _state.reviewById(_id!);
    _missing = _id != null && review == null;
    _editing = _id == null;
    _week = review?.weekStart ?? weekStartKey(_state.now());
    _wins = TextEditingController(text: review?.wins ?? '');
    _friction = TextEditingController(text: review?.friction ?? '');
    _next = TextEditingController(text: review?.nextExperiment ?? '');
    _autosave = Autosaver(_save);
  }

  @override
  void dispose() {
    _autosave.dispose();
    _wins.dispose();
    _friction.dispose();
    _next.dispose();
    super.dispose();
  }

  bool get _hasText =>
      [_wins, _friction, _next].any((c) => c.text.trim().isNotEmpty);

  void _changed() {
    _autosave.schedule();
    setState(() {});
  }

  /// Saves the fields (exactly as typed). A new review is created only once
  /// something is written.
  Future<void> _save() async {
    if (_missing || _deleted || !_editing) return;
    final week = _week;
    final wins = _wins.text;
    final friction = _friction.text;
    final next = _next.text;
    final hasText = _hasText;
    if (_id == null && _creating != null) await _creating;
    if (_deleted) return;
    final id = _id;
    if (id == null) {
      if (!hasText) return;
      final creating = _state.saveReview(
        weekStart: week,
        wins: wins,
        friction: friction,
        nextExperiment: next,
      );
      _creating = creating;
      _id = (await creating).id;
      if (mounted) setState(() {});
      return;
    }
    final current = _state.reviewById(id);
    if (current == null) return;
    if (current.weekStart == week &&
        current.wins == wins &&
        current.friction == friction &&
        current.nextExperiment == next) {
      return;
    }
    await _state.saveReview(
      id: id,
      weekStart: week,
      wins: wins,
      friction: friction,
      nextExperiment: next,
    );
  }

  Future<void> _saveAndView() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    _autosave.cancel();
    if (_id == null && !_hasText) {
      // Nothing to keep: an empty review is not saved.
      Navigator.of(context).pop();
      return;
    }
    await _save();
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l.journalReviewSaved)));
    setState(() => _editing = false);
  }

  void _edit() {
    final review = _id == null ? null : _state.reviewById(_id!);
    if (review != null) {
      _week = review.weekStart;
      _wins.text = review.wins;
      _friction.text = review.friction;
      _next.text = review.nextExperiment;
    }
    setState(() => _editing = true);
  }

  Future<void> _changeWeek() async {
    final now = _state.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: parseDateKey(_week),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: AppLocalizations.of(context).journalReviewChangeWeek,
    );
    if (picked == null || !mounted) return;
    setState(() => _week = weekStartKey(picked));
    if (_id != null || _hasText) _autosave.schedule();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await confirmDialog(
      context,
      title: l.journalReviewDeleteTitle,
      body: l.journalReviewDeleteBody(formatDateKey(context, _week)),
      action: l.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    _autosave.cancel();
    _deleted = true;
    if (_creating != null) await _creating;
    final id = _id;
    if (id != null) await _state.deleteReview(id);
    messenger.showSnackBar(SnackBar(content: Text(l.journalReviewDeleted)));
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final review = context.select<AppState, WeeklyReview?>(
      (s) => _id == null ? null : s.reviewById(_id!),
    );
    final canDelete = !_missing && (_id != null || _hasText);
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!_editing && review != null)
            IconButton(
              key: const ValueKey('review-edit'),
              tooltip: l.journalReviewEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: _edit,
            ),
          if (canDelete)
            IconButton(
              key: const ValueKey('review-delete'),
              tooltip: l.journalReviewDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: _missing
            ? AreaListView(
                children: [
                  EmptyState(
                    icon: Icons.event_note_outlined,
                    title: l.journalReviewMissingTitle,
                    body: l.journalReviewMissingBody,
                  ),
                ],
              )
            : _editing || review == null
            ? _editor(context)
            : _viewer(context, review),
      ),
    );
  }

  Widget _editor(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget field(
      Key key,
      TextEditingController controller,
      String label,
      String hint,
    ) => Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: TextField(
        key: key,
        controller: controller,
        minLines: 3,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          helperText: hint,
          helperMaxLines: 3,
          alignLabelWithHint: true,
        ),
        onChanged: (_) => _changed(),
      ),
    );
    return AreaListView(
      children: [
        ScreenHeader(
          title: l.journalReviewTitle,
          subtitle: l.journalReviewEditIntro,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
        ),
        SectionCard(
          icon: Icons.date_range_outlined,
          title: l.journalWeekOf(formatDateKey(context, _week)),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextLinkButton(
              key: const ValueKey('review-change-week'),
              label: l.journalReviewChangeWeek,
              icon: Icons.edit_calendar_outlined,
              onPressed: _changeWeek,
            ),
          ),
        ),
        const SizedBox(height: 20),
        field(
          const ValueKey('review-wins'),
          _wins,
          l.journalReviewWins,
          l.journalReviewWinsHint,
        ),
        field(
          const ValueKey('review-friction'),
          _friction,
          l.journalReviewFriction,
          l.journalReviewFrictionHint,
        ),
        field(
          const ValueKey('review-next'),
          _next,
          l.journalReviewNext,
          l.journalReviewNextHint,
        ),
        const SaveIndicator(),
        const SizedBox(height: 16),
        PrimaryButton(
          key: const ValueKey('review-save'),
          label: l.journalReviewSave,
          icon: Icons.check,
          expand: true,
          onPressed: _saveAndView,
        ),
      ],
    );
  }

  Widget _viewer(BuildContext context, WeeklyReview review) {
    final l = AppLocalizations.of(context);
    final p = CarthaPalette.of(context);
    final theme = Theme.of(context);
    Widget part(IconData icon, String title, String text) => Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 16),
      child: SectionCard(
        icon: icon,
        title: title,
        child: text.trim().isEmpty
            ? Text(
                l.journalReviewNothingWritten,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              )
            : SelectableText(text, style: theme.textTheme.bodyLarge),
      ),
    );
    return AreaListView(
      children: [
        ScreenHeader(
          title: l.journalReviewTitle,
          subtitle: l.journalWeekOf(formatDateKey(context, review.weekStart)),
          padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 16),
        ),
        part(Icons.wb_sunny_outlined, l.journalReviewWins, review.wins),
        part(Icons.terrain_outlined, l.journalReviewFriction, review.friction),
        part(
          Icons.science_outlined,
          l.journalReviewNext,
          review.nextExperiment,
        ),
        Text(
          l.journalReviewWritten(formatDayTime(context, review.createdAt)),
          style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
        if (review.editedAt != null)
          Text(
            l.journalEntryEdited(formatDayTime(context, review.editedAt!)),
            style: theme.textTheme.bodySmall?.copyWith(color: p.textSecondary),
          ),
        const SizedBox(height: 20),
        SecondaryButton(
          label: l.journalReviewEdit,
          icon: Icons.edit_outlined,
          expand: true,
          onPressed: _edit,
        ),
      ],
    );
  }
}
