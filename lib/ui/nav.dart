import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'awakening/awakening_screen.dart';
import 'awakening/lesson_screen.dart';
import 'compass/compass_tab.dart';
import 'journal/journal_entry_screen.dart';
import 'journal/journal_tab.dart';
import 'journal/review_screen.dart';
import 'missions/path_day_screen.dart';
import 'missions/project_screen.dart';
import 'reset/guided_prompt_screen.dart';
import 'reset/reset_complete_screen.dart';
import 'reset/reset_tab.dart';
import 'today/today_tab.dart';
import 'you/data_screen.dart';
import 'you/inspiration_screen.dart';
import 'you/reminders_screen.dart';
import 'you/support_screen.dart';
import 'you/you_tab.dart';

/// The five bottom-navigation tabs (PLAN.md §2), in order.
enum AppTab { today, reset, compass, journal, you }

/// Which tab the [RootShell] shows, plus cross-tab requests. Provided above
/// `MaterialApp` (so pushed routes can reach it) as a `ChangeNotifierProvider`.
class ShellController extends ChangeNotifier {
  ShellController({AppTab initial = AppTab.today}) : _tab = initial;

  AppTab _tab;
  AppTab get tab => _tab;

  /// The Compass tab's section (set by [AppNav.openCompass] /
  /// [AppNav.openMissions]). The Compass tab listens and switches; when the
  /// user taps a section pill it writes that section back here, so the next
  /// request is always a real change it hears.
  final ValueNotifier<CompassSection?> compassSection = ValueNotifier(null);

  void select(AppTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    notifyListeners();
  }

  static ShellController? maybeOf(BuildContext context) =>
      Provider.of<ShellController?>(context, listen: false);

  @override
  void dispose() {
    compassSection.dispose();
    super.dispose();
  }
}

/// Cross-area navigation (PLAN.md §6). Detail screens are pushed on the root
/// navigator (full screen, above the bottom bar); tabs are switched through
/// the [ShellController] after returning to the shell.
abstract final class AppNav {
  static Future<T?> _push<T>(BuildContext context, Widget screen) =>
      Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => screen));

  /// Returns to the shell and shows [tab]. Without a shell (isolated tests,
  /// previews) the tab is pushed as a screen instead.
  static Future<void> switchTab(BuildContext context, AppTab tab) async {
    final shell = ShellController.maybeOf(context);
    if (shell == null) {
      await _push<void>(context, tabWidget(tab));
      return;
    }
    Navigator.of(context).popUntil((r) => r.isFirst);
    shell.select(tab);
  }

  /// The widget for [tab].
  static Widget tabWidget(AppTab tab) => switch (tab) {
    AppTab.today => const TodayTab(),
    AppTab.reset => const ResetTab(),
    AppTab.compass => const CompassTab(),
    AppTab.journal => const JournalTab(),
    AppTab.you => const YouTab(),
  };

  static Future<void> openPrompt(BuildContext context, String promptId) =>
      _push<void>(context, GuidedPromptScreen(promptId: promptId));

  static Future<void> openResetComplete(BuildContext context) =>
      _push<void>(context, const ResetCompleteScreen());

  static Future<void> openAwakening(BuildContext context) =>
      _push<void>(context, const AwakeningScreen());

  static Future<void> openLesson(BuildContext context, String lessonId) =>
      _push<void>(context, LessonScreen(lessonId: lessonId));

  static Future<void> openCompass(
    BuildContext context, {
    CompassSection section = CompassSection.compass,
  }) async {
    final shell = ShellController.maybeOf(context);
    if (shell == null) {
      await _push<void>(context, CompassTab(initial: section));
      return;
    }
    shell.compassSection.value = section;
    await switchTab(context, AppTab.compass);
  }

  static Future<void> openMissions(BuildContext context) =>
      openCompass(context, section: CompassSection.missions);

  static Future<void> openPathDay(BuildContext context, int day) =>
      _push<void>(context, PathDayScreen(day: day));

  static Future<void> openProject(BuildContext context) =>
      _push<void>(context, const ProjectScreen());

  /// A journal note; no [entryId] = a new note.
  static Future<void> openJournalEntry(
    BuildContext context, {
    String? entryId,
  }) => _push<void>(context, JournalEntryScreen(entryId: entryId));

  /// A weekly review; no [reviewId] = a new review.
  static Future<void> openReview(BuildContext context, {String? reviewId}) =>
      _push<void>(context, ReviewScreen(reviewId: reviewId));

  static Future<void> openInspiration(BuildContext context) =>
      _push<void>(context, const InspirationScreen());

  static Future<void> openSupport(BuildContext context) =>
      _push<void>(context, const SupportScreen());

  static Future<void> openReminders(BuildContext context) =>
      _push<void>(context, const RemindersScreen());

  /// Your data: export / import / delete (also "Export a copy" after a
  /// failed save).
  static Future<void> openData(BuildContext context) =>
      _push<void>(context, const DataScreen());
}
