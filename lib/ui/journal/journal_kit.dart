/// Small helpers shared by the Journal and You areas: a readable-width page
/// list, local date/time formatting, debounced autosave and look-ups on
/// [AppState]. Nothing here changes the state API.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/app_data.dart';
import '../../domain/content.dart';
import '../../domain/local_date.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_state.dart';
import '../compass/compass_copy.dart';
import '../theme/cartha_fonts.dart';

/// The widest a column of reading or writing gets (tablets).
const double kReadableWidth = 680;

/// How long text fields wait after the last keystroke before saving.
const Duration kAutosaveDelay = Duration(milliseconds: 600);

/// A scrolling page body: 20 dp gutters on phones, content centred at
/// [kReadableWidth] on tablets, and room for the system navigation inset
/// (edge-to-edge). Scrolls instead of using fixed heights.
class AreaListView extends StatelessWidget {
  const AreaListView({
    super.key,
    required this.children,
    this.top = 0,
    this.controller,
  });

  final List<Widget> children;
  final double top;
  final ScrollController? controller;

  /// The side gutter for a page [width] wide: 20 dp on phones, wider on
  /// tablets so the content is centred at [kReadableWidth].
  static double gutterFor(double width) =>
      math.max(20.0, (width - kReadableWidth) / 2);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 32;
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = gutterFor(constraints.maxWidth);
        return ListView(
          controller: controller,
          padding: EdgeInsetsDirectional.fromSTEB(side, top, side, bottom),
          children: children,
        );
      },
    );
  }
}

/// A small header above a group of cards (Inter, secondary colour).
class AreaSectionLabel extends StatelessWidget {
  const AreaSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4, 24, 4, 10),
      child: Semantics(
        header: true,
        child: Text(
          text.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: CarthaFonts.of(context).spacing(1.4),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Local dates and times ──────────────────────────────────────────────────

String _locale(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// A readable local date, e.g. "Tue, Nov 3, 2026".
String formatDay(BuildContext context, DateTime time) =>
    DateFormat.yMMMEd(_locale(context)).format(time.toLocal());

/// A local time in the device's clock format (12 h or 24 h).
String formatTimeOfDay(BuildContext context, TimeOfDay time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// A local time of [time] in the device's clock format.
String formatClockTime(BuildContext context, DateTime time) =>
    formatTimeOfDay(context, TimeOfDay.fromDateTime(time.toLocal()));

/// "Tue, Nov 3, 2026, 9:30 AM" (or 09:30 on a 24-hour phone).
String formatDayTime(BuildContext context, DateTime time) =>
    AppLocalizations.of(
      context,
    ).journalDateTime(formatDay(context, time), formatClockTime(context, time));

/// A `yyyy-MM-dd` key as a readable date, e.g. "Nov 2, 2026".
String formatDateKey(BuildContext context, String key) =>
    DateFormat.yMMMd(_locale(context)).format(parseDateKey(key));

/// A stored `HH:MM` as a local time in the device's clock format.
String formatHhmm(BuildContext context, String hhmm) {
  final (hour, minute) = parseClock(hhmm);
  return formatTimeOfDay(context, TimeOfDay(hour: hour, minute: minute));
}

// ── Labels shared by Journal and You ───────────────────────────────────────

/// The same field names the Compass tab shows.
String compassFieldLabel(AppLocalizations l, CompassField field) =>
    CompassFieldCopy.of(l, field).title;

String phaseLabel(AppLocalizations l, PromptPhase phase) => switch (phase) {
  PromptPhase.morning => l.journalPhaseMorning,
  PromptPhase.daytime => l.journalPhaseDaytime,
  PromptPhase.bonus => l.journalPhaseBonus,
  PromptPhase.evening => l.journalPhaseEvening,
};

/// The first non-empty line of [text], trimmed, or null.
String? firstLine(String text) {
  for (final line in text.split('\n')) {
    if (line.trim().isNotEmpty) return line.trim();
  }
  return null;
}

/// The note's title, else its first non-empty line, else null.
String? noteHeadline(JournalEntry entry) {
  final title = entry.title?.trim() ?? '';
  return title.isNotEmpty ? title : firstLine(entry.body);
}

// ── Autosave ───────────────────────────────────────────────────────────────

/// Debounced autosave for text fields (PLAN.md §5): runs [save]
/// [kAutosaveDelay] after the last [schedule], and at once on [flush] —
/// call it when leaving the screen. Also flushes when the app goes to the
/// background, so switching apps never loses words.
class Autosaver {
  Autosaver(this._save, {this.delay = kAutosaveDelay}) {
    _lifecycle = AppLifecycleListener(
      onStateChange: (s) {
        if (s != AppLifecycleState.resumed) flush();
      },
    );
  }

  final Future<void> Function() _save;
  final Duration delay;
  late final AppLifecycleListener _lifecycle;
  Timer? _timer;

  /// A save is waiting for the user to pause typing.
  bool get pending => _timer?.isActive ?? false;

  void schedule() {
    _timer?.cancel();
    _timer = Timer(delay, _run);
  }

  /// Saves now if a save is waiting.
  void flush() {
    if (!pending) return;
    _timer!.cancel();
    _run();
  }

  /// Drops a waiting save (e.g. the note is being deleted).
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void _run() {
    _timer = null;
    unawaited(_save());
  }

  /// Flushes, then stops listening to the app lifecycle.
  void dispose() {
    flush();
    _lifecycle.dispose();
  }
}

// ── Look-ups (no new state operations) ─────────────────────────────────────

extension JournalAreaLookups on AppState {
  JournalEntry? journalEntryById(String id) {
    for (final e in data.journal) {
      if (e.id == id) return e;
    }
    return null;
  }

  WeeklyReview? reviewById(String id) {
    for (final r in data.reviews) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// The first review saved for the week starting [weekStart], if any.
  WeeklyReview? reviewForWeek(String weekStart) {
    for (final r in data.reviews) {
      if (r.weekStart == weekStart) return r;
    }
    return null;
  }

  /// An earlier (not current) reset by id.
  Journey? pastJourneyById(String id) {
    for (final j in pastJourneys) {
      if (j.id == id) return j;
    }
    return null;
  }

  /// Notes, newest first.
  List<JournalEntry> get notesNewestFirst =>
      [...data.journal]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}
