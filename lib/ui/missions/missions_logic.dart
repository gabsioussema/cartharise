import '../../domain/app_data.dart';
import '../../domain/local_date.dart';
import '../../state/app_state.dart';

/// The three Missions lists for one local day (F-027, F-029, F-031).
class MissionSections {
  const MissionSections({
    required this.today,
    required this.later,
    required this.done,
  });

  /// Every daily quest (checked only if done on that day) plus open one-offs
  /// planned for that day or earlier — shown calmly, never as "missed".
  final List<Quest> today;

  /// Open one-offs without a date (anytime) and those planned for later.
  final List<Quest> later;

  /// Finished one-offs, most recently finished first.
  final List<Quest> done;
}

/// Missions operations on top of [AppState.mutate] (PLAN.md §4: feature
/// extensions live in the feature's folder).
extension MissionsOps on AppState {
  /// Sorts quests into Today / Anytime & upcoming / Done for [day]
  /// (default: today). Daily quests reset per local day.
  MissionSections missionSections([String? day]) {
    final key = day ?? today;
    final todayList = <Quest>[];
    final later = <Quest>[];
    final done = <Quest>[];
    for (final q in data.quests) {
      if (q.recurrence == QuestRecurrence.daily) {
        todayList.add(q);
      } else if (q.completedOn.isNotEmpty) {
        done.add(q);
      } else if (q.dueDate != null && q.dueDate!.compareTo(key) <= 0) {
        todayList.add(q);
      } else {
        later.add(q);
      }
    }
    // Today: open first, then by plan date, then oldest first.
    todayList.sort((a, b) {
      final open = (a.isDoneOn(key) ? 1 : 0) - (b.isDoneOn(key) ? 1 : 0);
      if (open != 0) return open;
      final date = (a.dueDate ?? key).compareTo(b.dueDate ?? key);
      if (date != 0) return date;
      return a.createdAt.compareTo(b.createdAt);
    });
    // Anytime first (oldest first), then upcoming by date.
    later.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) {
        return a.createdAt.compareTo(b.createdAt);
      }
      if (a.dueDate == null) return -1;
      if (b.dueDate == null) return 1;
      final date = a.dueDate!.compareTo(b.dueDate!);
      return date != 0 ? date : a.createdAt.compareTo(b.createdAt);
    });
    String last(Quest q) => (q.completedOn.toList()..sort()).last;
    done.sort((a, b) => last(b).compareTo(last(a)));
    return MissionSections(today: todayList, later: later, done: done);
  }

  /// Today's focus on the Today tab for [day] (default: today), so Today and
  /// Missions agree on what is "for today" (F-029, F-036): exactly
  /// Missions' Today section — every daily quest and the one-offs planned
  /// for that day or earlier — plus such planned one-offs finished that day,
  /// which stay listed (ticked) until the day ends, as daily quests do.
  /// Undated and later quests stay in "Anytime & upcoming".
  List<Quest> todayFocus([String? day]) {
    final key = day ?? today;
    final sections = missionSections(key);
    return [
      ...sections.today,
      for (final q in sections.done)
        if (q.completedOn.contains(key) &&
            q.dueDate != null &&
            q.dueDate!.compareTo(key) <= 0)
          q,
    ];
  }

  /// Saves an edited quest. Switching a daily quest to one-off keeps it done
  /// only if it was done today (an old daily tick must not finish it).
  Future<void> editQuest(
    Quest quest, {
    required String title,
    required QuestRecurrence recurrence,
    String? dueDate,
  }) {
    final text = title.trim();
    if (text.isEmpty) throw ArgumentError.value(title, 'title', 'is empty');
    if (dueDate != null) parseDateKey(dueDate);
    final key = today;
    var completed = quest.completedOn;
    if (quest.recurrence == QuestRecurrence.daily &&
        recurrence == QuestRecurrence.none) {
      completed = completed.contains(key) ? {key} : const {};
    }
    return updateQuest(
      quest.copyWith(
        title: text,
        recurrence: recurrence,
        dueDate: () => recurrence == QuestRecurrence.daily ? null : dueDate,
        completedOn: completed,
      ),
    );
  }

  /// Puts a deleted quest back where it was (the "Undo" of a delete).
  Future<void> restoreQuest(Quest quest, int index) => mutate((d) {
    if (d.quests.any((q) => q.id == quest.id)) return d;
    final list = [...d.quests];
    list.insert(index.clamp(0, list.length), quest);
    return d.copyWith(quests: list);
  });

  /// The saved month project, or an unsaved draft titled from the Compass.
  MonthProject get projectOrDraft =>
      data.project ??
      MonthProject(title: compass.monthProject.trim(), updatedAt: now());

  /// Changes the month project, creating it from the draft on first change.
  Future<void> updateProject(MonthProject Function(MonthProject) change) {
    final at = now();
    return mutate((d) {
      final base =
          d.project ??
          MonthProject(title: d.compass.monthProject.trim(), updatedAt: at);
      return d.copyWith(project: () => change(base));
    });
  }

  Future<void> setProjectTitle(String title) =>
      updateProject((p) => p.copyWith(title: title, now: now()));

  Future<void> setProjectStatus(ProjectStatus status) =>
      updateProject((p) => p.copyWith(status: status, now: now()));

  Future<void> setProjectRetrospective(String text) =>
      updateProject((p) => p.copyWith(retrospective: text, now: now()));

  Future<Milestone> addMilestone(String title) async {
    final text = title.trim();
    if (text.isEmpty) throw ArgumentError.value(title, 'title', 'is empty');
    final m = Milestone(id: newId('milestone'), title: text);
    await updateProject(
      (p) => p.copyWith(milestones: [...p.milestones, m], now: now()),
    );
    return m;
  }

  Future<void> _editMilestone(String id, Milestone Function(Milestone) edit) =>
      updateProject(
        (p) => p.copyWith(
          milestones: [for (final m in p.milestones) m.id == id ? edit(m) : m],
          now: now(),
        ),
      );

  Future<void> setMilestoneDone(String id, bool done) =>
      _editMilestone(id, (m) => m.copyWith(done: done));

  Future<void> renameMilestone(String id, String title) {
    final text = title.trim();
    if (text.isEmpty) throw ArgumentError.value(title, 'title', 'is empty');
    return _editMilestone(id, (m) => m.copyWith(title: text));
  }

  Future<void> deleteMilestone(String id) => updateProject(
    (p) => p.copyWith(
      milestones: [
        for (final m in p.milestones)
          if (m.id != id) m,
      ],
      now: now(),
    ),
  );

  /// Puts a deleted milestone back where it was.
  Future<void> restoreMilestone(Milestone milestone, int index) =>
      updateProject((p) {
        if (p.milestones.any((m) => m.id == milestone.id)) return p;
        final list = [...p.milestones];
        list.insert(index.clamp(0, list.length), milestone);
        return p.copyWith(milestones: list, now: now());
      });

  /// Whether the user wrote something for path [day].
  bool pathWritten(int day) =>
      data.pathAnswers[day]?.body.trim().isNotEmpty ?? false;

  /// How many of the thirty days have a written note.
  int get pathWrittenCount => [
    for (var d = 1; d <= 30; d++)
      if (pathWritten(d)) d,
  ].length;
}
