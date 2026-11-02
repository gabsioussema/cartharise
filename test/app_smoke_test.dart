// End-to-end smoke test of the phase-1 wiring: the real English content
// library + AppState + in-memory storage, then the real app booting on it.
import 'package:cartharise/content/content.dart';
import 'package:cartharise/content/en.dart';
import 'package:cartharise/data/data_store.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/content.dart';
import 'package:cartharise/state/app_state.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/root_shell.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/test_app.dart';

/// Distinct answers for evening #3–#7, as a user might type them (leading
/// space and trailing newline kept on purpose: answers are stored as typed).
const _eveningAnswers = {
  'evening.03': 'Another year of drifting and saying "later".',
  'evening.04': ' Calm mornings, honest work, time outside.\n',
  'evening.05': 'Ship one small project people use.',
  'evening.06': 'Write and publish four short essays.',
  'evening.07': '- Walk 20 minutes\n- Write one page\n- Phone off by 22:00',
};

const _expectedFields = {
  'evening.03': CompassField.antiVision,
  'evening.04': CompassField.vision,
  'evening.05': CompassField.yearGoal,
  'evening.06': CompassField.monthProject,
  'evening.07': CompassField.dailyLevers,
};

void main() {
  test('the app wires the real English content library', () {
    expect(identical(contentFor(AppLanguage.en), englishContent), isTrue);
    expect(identical(contentForCode('en-GB'), englishContent), isTrue);
    // Step 3: French and Arabic are their own libraries, but an item not
    // translated yet falls back to English (by permanent id).
    final fr = contentFor(AppLanguage.fr);
    expect(fr.languageCode, 'fr');
    for (final p in englishContent.prompts) {
      if (coverageFor(AppLanguage.fr).translatedIds.contains(p.id)) continue;
      expect(fr.prompt(p.id)!.question, p.question);
    }
  });

  test('first launch → onboarding → first prompt → answers persist → Compass import', () async {
    final store = MemoryDataStore();
    final reminders = FakeReminderScheduler();
    var clock = DateTime(2026, 11, 3, 7, 45);
    AppState newState() => AppState(
      store: store,
      content: englishContent,
      reminders: reminders,
      clock: () => clock,
    );

    // First launch: nothing saved yet.
    final state = newState();
    expect(state.loaded, isFalse);
    await state.load();
    expect(state.loaded, isTrue);
    expect(state.loadError, isNull);
    expect(state.needsOnboarding, isTrue);
    expect(store.raw, isNull, reason: 'loading never writes');

    await state.completeOnboarding(
      displayName: '  Sam ',
      pace: Pace.flexible,
      adultConfirmed: true,
    );
    expect(state.needsOnboarding, isFalse);
    expect(state.data.profile!.displayName, 'Sam');
    expect(state.data.profile!.adultConfirmed, isTrue);
    expect(state.saveStatus, SaveStatus.saved);
    expect(store.saved!.profile!.onboardedAt, isNotNull);

    // The reset starts at the first morning question.
    expect(state.nextPrompt?.id, 'morning.01');
    expect(state.coreProgress, 0);
    final morning = state.progressFor(PromptPhase.morning);
    expect(morning.total, 14);
    expect(morning.answered, 0);

    // An answer is saved exactly as typed and survives a restart.
    const firstAnswer =
        '  A dull tiredness after work\nthat I stopped noticing. ';
    clock = clock.add(const Duration(minutes: 3));
    await state.saveAnswer('morning.01', firstAnswer);
    expect(state.answer('morning.01')!.body, firstAnswer);
    expect(state.saveStatus, SaveStatus.saved);
    final savedJourney = store.saved!.currentJourney!;
    expect(savedJourney.answers['morning.01']!.body, firstAnswer);
    expect(state.nextPrompt?.id, 'morning.02');
    expect(state.progressFor(PromptPhase.morning).answered, 1);

    final reopened = newState();
    await reopened.load();
    expect(reopened.needsOnboarding, isFalse);
    expect(reopened.answer('morning.01')!.body, firstAnswer);
    expect(reopened.journey.id, savedJourney.id);
    expect(reopened.nextPrompt?.id, 'morning.02');

    // Nothing to import before the evening answers exist.
    expect(reopened.compassImportPreview, isEmpty);

    // Evening #3–#7 map to the five Compass fields; constraints never.
    for (final MapEntry(key: id, value: body) in _eveningAnswers.entries) {
      expect(englishContent.prompt(id)!.mapsTo, _expectedFields[id]);
      await reopened.saveAnswer(id, body);
    }
    final preview = reopened.compassImportPreview;
    expect(preview, {
      for (final MapEntry(key: id, value: field) in _expectedFields.entries)
        field: _eveningAnswers[id]!,
    });
    expect(preview.containsKey(CompassField.constraints), isFalse);

    // A field the user already filled is never offered for overwrite.
    await reopened.updateCompassField(CompassField.vision, 'My own words');
    expect(
      reopened.compassImportPreview.keys,
      isNot(contains(CompassField.vision)),
    );
    expect(reopened.compassImportPreview, hasLength(4));

    // Importing fills only the chosen empty fields, after a snapshot.
    final filled = await reopened.importCompassFromEvening({
      CompassField.antiVision,
      CompassField.vision,
      CompassField.dailyLevers,
    });
    expect(filled, 2);
    expect(reopened.compass.antiVision, _eveningAnswers['evening.03']);
    expect(reopened.compass.vision, 'My own words');
    expect(reopened.compass.dailyLevers, _eveningAnswers['evening.07']);
    expect(reopened.compass.yearGoal, isEmpty);
    expect(reopened.compass.constraints, isEmpty);
    expect(
      reopened.data.compassHistory.first.reason,
      CompassVersionReason.beforeImport,
    );
    expect(reopened.leverDrafts, [
      'Walk 20 minutes',
      'Write one page',
      'Phone off by 22:00',
    ]);

    // And all of it is on "disk".
    final onDisk = store.saved!;
    expect(onDisk.compass.antiVision, _eveningAnswers['evening.03']);
    expect(
      onDisk.currentJourney!.answers['evening.04']!.body,
      _eveningAnswers['evening.04'],
    );
  });

  testWidgets('the real app boots on English content into onboarding', (
    tester,
  ) async {
    final h = await pumpCartha(tester, content: englishContent);
    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(identical(h.state.content, englishContent), isTrue);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'the real app opens the shell for an onboarded user (${brightness.name})',
      (tester) async {
        final h = await pumpCartha(
          tester,
          data: onboardedData(),
          content: englishContent,
          brightness: brightness,
        );
        expect(find.byType(RootShell), findsOneWidget);
        expect(find.byType(TodayTab), findsOneWidget);
        expect(h.state.nextPrompt?.id, 'morning.01');
        expect(h.state.reminders.map((r) => r.time), [
          '11:00',
          '13:30',
          '15:15',
          '17:00',
          '19:30',
          '21:00',
        ]);
        await expectNoOverflow(tester);
      },
    );
  }
}
