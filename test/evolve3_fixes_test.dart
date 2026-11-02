// Step 3 audit fixes (docs/plans/evolve.md, Step 3), the logic: S3-m2 —
// "Add to my tasks" finds the experiment's open quest by the experiment's
// permanent id, so switching language in between never makes a second one
// (and a quest saved before ids were kept is found by its title in any
// shipped language). The widget fixes are in test/ui/evolve3_fixes_test.dart
// and test/ui/rtl_test.dart (section pills).
import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/content/fr.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

final _t = DateTime(2026, 11, 3, 9, 30);

const _id = 'try.terrain.01';

/// The app's state with the real content in every language, as main.dart
/// wires it.
Future<AppState> _open([AppData? data]) async {
  final state = AppState(
    store: MemoryDataStore(data ?? AppData.empty),
    content: englishContent,
    contentFor: contentFor,
    reminders: FakeReminderScheduler(),
    clock: () => _t,
  );
  await state.load();
  return state;
}

String _title(AppLanguage language) =>
    contentFor(language).experiment(_id)!.title;

void main() {
  group('S3-m2: Add to my tasks across languages', () {
    test('the shipped titles differ, so a title match alone would miss', () {
      expect(_title(AppLanguage.fr), isNot(_title(AppLanguage.en)));
      expect(_title(AppLanguage.ar), isNot(_title(AppLanguage.en)));
    });

    test('added in English, switched to French then Arabic, added again: '
        'the same quest', () async {
      final state = await _open();
      final quest = await state.addExperimentToTasks(_id);
      expect(quest.experimentId, _id);
      expect(quest.title, _title(AppLanguage.en));

      await state.setLanguage(AppLanguage.fr);
      final again = await state.addExperimentToTasks(_id);
      expect(again.id, quest.id);
      // The user's task keeps the words it was added with.
      expect(again.title, _title(AppLanguage.en));

      await state.setLanguage(AppLanguage.ar);
      expect((await state.addExperimentToTasks(_id)).id, quest.id);
      expect(state.data.quests, hasLength(1));
    });

    test('a different experiment is still its own quest; a done one makes '
        'room for a new one, titled in the language shown', () async {
      final state = await _open();
      final first = await state.addExperimentToTasks(_id);
      final other = await state.addExperimentToTasks('try.terrain.02');
      expect(other.id, isNot(first.id));
      expect(other.experimentId, 'try.terrain.02');

      await state.setQuestDone(first.id, true);
      await state.setLanguage(AppLanguage.fr);
      final next = await state.addExperimentToTasks(_id);
      expect(next.id, isNot(first.id));
      expect(next.title, _title(AppLanguage.fr));
      expect(next.experimentId, _id);
      expect(state.data.quests, hasLength(3));
    });

    test('a quest saved before ids were kept is found by its title in any '
        'shipped language', () async {
      for (final saved in [AppLanguage.en, AppLanguage.fr, AppLanguage.ar]) {
        final legacy = Quest(
          id: 'q_legacy',
          title: _title(saved),
          createdAt: _t,
          source: QuestSource.experiment,
        );
        final state = await _open(
          AppData(
            quests: [legacy],
            settings: const AppSettings(language: AppLanguage.fr),
          ),
        );
        final again = await state.addExperimentToTasks(_id);
        expect(again.id, 'q_legacy', reason: saved.name);
        expect(state.data.quests, hasLength(1));
      }
    });

    test('only experiment quests count: a task the user typed with the same '
        'words is not this experiment', () async {
      final state = await _open(
        AppData(
          quests: [
            Quest(id: 'q_mine', title: _title(AppLanguage.en), createdAt: _t),
          ],
        ),
      );
      final quest = await state.addExperimentToTasks(_id);
      expect(quest.id, isNot('q_mine'));
      expect(state.data.quests, hasLength(2));
    });

    test(
      'a quest with another experiment\'s id is never matched by title',
      () async {
        // Ids win over words: a quest that names another experiment is that
        // experiment's, even if its words happen to match.
        final state = await _open(
          AppData(
            quests: [
              Quest(
                id: 'q_other',
                title: _title(AppLanguage.en),
                createdAt: _t,
                source: QuestSource.experiment,
                experimentId: 'try.terrain.02',
              ),
            ],
          ),
        );
        final quest = await state.addExperimentToTasks(_id);
        expect(quest.id, isNot('q_other'));
      },
    );

    test('experimentId: JSON round-trip; older files and junk fall back to '
        'none', () {
      final q = Quest(
        id: 'q',
        title: frenchContent.experiment(_id)!.title,
        createdAt: _t,
        source: QuestSource.experiment,
        experimentId: _id,
      );
      final back = Quest.fromJson(q.toJson());
      expect(back.experimentId, _id);
      expect(back.copyWith(title: 'Renamed').experimentId, _id);
      expect(
        Quest.fromJson(q.toJson()..remove('experimentId')).experimentId,
        isNull,
      );
      for (final junk in [2, '', true, <String, Object?>{}]) {
        expect(
          Quest.fromJson(q.toJson()..['experimentId'] = junk).experimentId,
          isNull,
          reason: '$junk',
        );
      }
      final roundTrip = AppData.fromJson(AppData(quests: [q]).toJson())
          .quests
          .single;
      expect(roundTrip.experimentId, _id);
    });
  });
}
