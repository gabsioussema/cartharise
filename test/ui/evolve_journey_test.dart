// End-to-end journeys for the evolve plan's Step 1 (docs/plans/evolve.md
// › 1.2) through the real app (CarthaApp → BootScreen → Onboarding |
// RootShell) with the real English content: the five-page welcome and the
// one-time Campaign invitation, Today's pin and its done state, the
// Playground (Try → tasks only on request → Collection → a reward pick),
// the honest battle log, and backups that carry the new fields.
import 'package:cartharise/content/en.dart';
import 'package:cartharise/domain/app_data.dart';
import 'package:cartharise/domain/backup.dart';
import 'package:cartharise/domain/campaign.dart';
import 'package:cartharise/domain/persona.dart';
import 'package:cartharise/ui/campaign/battle_log_screen.dart';
import 'package:cartharise/ui/campaign/campaign_feedback.dart';
import 'package:cartharise/ui/campaign/campaign_ops.dart';
import 'package:cartharise/ui/campaign/campaign_view.dart';
import 'package:cartharise/ui/campaign/collection_screen.dart';
import 'package:cartharise/ui/campaign/make_it_yours_screen.dart';
import 'package:cartharise/ui/campaign/reward_sheet.dart';
import 'package:cartharise/ui/campaign/try_screen.dart';
import 'package:cartharise/ui/compass/compass_tab.dart';
import 'package:cartharise/ui/missions/project_screen.dart';
import 'package:cartharise/ui/nav.dart';
import 'package:cartharise/ui/onboarding/onboarding_flow.dart';
import 'package:cartharise/ui/onboarding/onboarding_steps.dart';
import 'package:cartharise/ui/persona/avatar_view.dart';
import 'package:cartharise/ui/persona/builder_options.dart';
import 'package:cartharise/ui/persona/persona_ops.dart';
import 'package:cartharise/ui/root_shell.dart';
import 'package:cartharise/ui/today/today_tab.dart';
import 'package:cartharise/ui/widgets/widgets.dart';
import 'package:cartharise/ui/you/data_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// A phone tall enough that lazily built rows exist (the journeys still
/// scroll to what they tap).
const _phone = Size(390, 2000);

const _content = englishContent;

final _t = DateTime(2026, 11, 3, 9);
final _yesterday = DateTime(2026, 11, 2, 18);

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _nav(String label) =>
    find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

/// [finder] inside the widget of type [T] (the shell keeps every tab built,
/// so unscoped text can match a tab that isn't showing).
Finder _in<T>(Finder finder) =>
    find.descendant(of: find.byType(T), matching: finder);

Future<void> _settle(WidgetTester tester, {int frames = 6}) async {
  // Storage writes are microtasks; let them land, then draw.
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await pumpFrames(tester, count: frames);
}

/// Brings [finder] on screen, then taps it like a person would.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await _settle(tester);
}

Future<void> _type(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.pump();
  await tester.enterText(field, text);
  await tester.pump();
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(_nav(label));
  await _settle(tester);
}

/// Lets any snackbar time out so it doesn't cover what is tapped next.
Future<void> _waitOutSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await pumpFrames(tester, count: 4);
}

Future<void> _back(WidgetTester tester) async {
  await tester.pageBack();
  await _settle(tester);
}

String _fieldText(WidgetTester tester, String key) =>
    tester.widget<TextField>(_key(key)).controller!.text;

/// Compass › Campaign (the pill only exists with the game layer on).
Future<void> _openCampaignHub(WidgetTester tester) async {
  await _openTab(tester, 'Compass');
  await _tap(
    tester,
    find.descendant(
      of: find.byType(PillTabs<CompassSection>),
      matching: find.text('Campaign'),
    ),
  );
  expect(find.byType(CampaignView), findsOneWidget);
}

/// Today's next action card.
Finder _inNextStep(Finder finder) =>
    find.descendant(of: _key('today-next-step'), matching: finder);

/// Words that must survive exactly as typed.
const _note = 'Saw the hallway “fresh” & <kept> 🌱\n  two spaces kept  ';
const _attempt = 'Wrote 200 words “before” coffee & <kept>';
const _learning = 'Starting small worked.\n  Spaces stay.  ';

void main() {
  group('a new user', () {
    /// The five-page welcome, page by page, with a name.
    Future<CarthaHarness> welcome(WidgetTester tester) async {
      final h = await pumpCartha(tester, content: _content, size: _phone);
      expect(find.byType(OnboardingFlow), findsOneWidget);
      expect(OnboardingStep.length, 5);
      // No carousel and no way to skip the limits and the 18+ question.
      expect(_key('onboarding-skip'), findsNothing);

      // 1 · brand + promise
      await _tap(tester, _key('onboarding-next')); // Begin
      // 2 · credit + limits (not therapy) + 18+
      expect(find.text('Before you start'), findsOneWidget);
      await _tap(tester, _key('onboarding-adult'));
      await _tap(tester, _key('onboarding-next'));
      // 3 · pace
      await _tap(tester, _key('onboarding-pace-oneDay'));
      await _tap(tester, _key('onboarding-next'));
      // 4 · name (optional)
      await _type(tester, find.byType(TextField).last, 'Ana');
      await _tap(tester, _key('onboarding-next'));
      // 5 · privacy + Start
      expect(_key('onboarding-next'), findsNothing, reason: 'the last page');
      expect(find.text('Start'), findsOneWidget);
      await _tap(tester, _key('onboarding-finish'));
      await _settle(tester, frames: 8);
      expect(find.byType(RootShell), findsOneWidget);

      // A new profile starts with the Campaign off and the question open.
      final settings = h.state.settings;
      expect(settings.game, isFalse);
      expect(settings.gameInvited, isFalse);
      expect(settings.todayPin, TodayPin.auto);
      expect(h.store.saved!.settings.gameInvited, isFalse);
      expect(h.state.data.profile!.displayName, 'Ana');
      return h;
    }

    testWidgets('five pages → Today: one next action and the invitation → '
        'Play turns the Campaign on', (tester) async {
      final h = await welcome(tester);

      // Today: one next action (begin the reset), the invitation below it,
      // the Write capture, nothing else on top.
      expect(find.byType(TodayTab), findsOneWidget);
      expect(_key('today-next-step'), findsOneWidget);
      expect(_key('today-step-start'), findsOneWidget);
      expect(_key('today-next-action'), findsOneWidget);
      expect(_key('today-choose-other'), findsOneWidget);
      expect(_key('today-done'), findsNothing);
      expect(
        tester.widget<BrandScene>(_in<TodayTab>(find.byType(BrandScene))).compact,
        isTrue,
        reason: 'the smaller scene',
      );
      final invite = _key('today-invite');
      expect(invite, findsOneWidget);
      expect(
        find.descendant(of: invite, matching: find.text('Play the Campaign?')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: invite,
          matching: find.text('XP and levels for what you do.'),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(invite).dy,
        greaterThanOrEqualTo(
          tester.getBottomLeft(_key('today-next-step')).dy,
        ),
        reason: 'below the next action',
      );
      // While the game is off, there's no Campaign anywhere but the question.
      await _openTab(tester, 'Compass');
      expect(
        find.descendant(
          of: find.byType(PillTabs<CompassSection>),
          matching: find.text('Campaign'),
        ),
        findsNothing,
      );
      expect(find.byType(CampaignView), findsNothing);
      await _openTab(tester, 'Today');

      await _tap(tester, _key('campaign-invite-play'));
      expect(h.state.settings.game, isTrue);
      expect(h.state.settings.gameInvited, isTrue);
      expect(h.store.saved!.settings.game, isTrue);
      expect(h.store.saved!.settings.gameInvited, isTrue);
      expect(_key('today-invite'), findsNothing, reason: 'asked once');
      expect(find.text('The Campaign is on. It lives in Compass.'), findsOne);
      await _waitOutSnackBars(tester);

      // The Campaign is there now, and doesn't ask again.
      await _openCampaignHub(tester);
      expect(_key('campaign-status'), findsOneWidget);
      expect(_key('campaign-invite'), findsNothing);
      expect(_key('campaign-open-try'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Not now leaves the Campaign off; You can still turn it on', (
      tester,
    ) async {
      final h = await welcome(tester);
      await _tap(tester, _key('campaign-invite-later'));
      expect(h.state.settings.game, isFalse);
      expect(h.state.settings.gameInvited, isTrue);
      expect(h.store.saved!.settings.gameInvited, isTrue);
      expect(_key('today-invite'), findsNothing, reason: 'asked once');
      expect(find.text('You can turn it on in You.'), findsOneWidget);
      // Today keeps its one next action, with no Campaign chips.
      expect(_key('today-step-start'), findsOneWidget);
      await _waitOutSnackBars(tester);

      await _openTab(tester, 'Compass');
      expect(
        find.descendant(
          of: find.byType(PillTabs<CompassSection>),
          matching: find.text('Campaign'),
        ),
        findsNothing,
      );

      // The Playground stays open without the game: Notice, Try and the
      // Collection, with no XP, levels or achievements.
      await _tap(
        tester,
        find.descendant(
          of: find.byType(PillTabs<CompassSection>),
          matching: find.text('Playground'),
        ),
      );
      expect(find.byType(PlaygroundView), findsOneWidget);
      expect(_key('campaign-status'), findsNothing);
      expect(_key('campaign-open-notice'), findsOneWidget);
      await _tap(tester, _key('campaign-open-try'));
      expect(find.byType(TryScreen), findsOneWidget);
      expect(_key('try-xp'), findsNothing, reason: 'no XP with the game off');
      await _back(tester);
      await _tap(tester, _key('campaign-link-collection'));
      expect(find.byType(CollectionScreen), findsOneWidget);
      expect(find.byType(AchievementBadge), findsNothing);
      await _back(tester);

      // You › The Campaign: off, and switching it on works.
      await _openTab(tester, 'You');
      final toggle = _key('you-campaign');
      await tester.ensureVisible(toggle);
      final tile = find.descendant(
      of: toggle,
      matching: find.byType(SwitchListTile),
    );
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);
      await _tap(tester, toggle);
      expect(h.state.settings.game, isTrue);
      expect(h.store.saved!.settings.game, isTrue);
      await _openTab(tester, 'Today');
      expect(_key('today-invite'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a returning user: the pin is remembered, Today follows it, '
      'then "Done. That can be enough for today."', (tester) async {
    // A reset under way (answered yesterday), and a month project.
    final data = onboardedData().copyWith(
      journeys: [
        Journey(
          id: 'j1',
          startedAt: _yesterday,
          answers: {
            'morning.01': ReflectionAnswer(
              promptId: 'morning.01',
              body: 'Yesterday’s words',
              updatedAt: _yesterday,
            ),
          },
        ),
      ],
      currentJourneyId: () => 'j1',
      project: () => MonthProject(
        title: 'Four short essays',
        status: ProjectStatus.active,
        updatedAt: _yesterday,
        milestones: const [
          Milestone(id: 'm1', title: 'Pick topics', done: true),
          Milestone(id: 'm2', title: 'First draft'),
        ],
      ),
    );
    final h = await pumpCartha(
      tester,
      data: data,
      content: _content,
      size: _phone,
    );
    // The app's own order: continue the reset. Nothing was done today.
    expect(_key('today-step-resume'), findsOneWidget);
    expect(_key('today-done'), findsNothing);
    expect(_key('today-invite'), findsNothing, reason: 'an existing user');

    // "Choose something else" › Help me with: my project.
    await _tap(tester, _key('today-choose-other'));
    expect(_key('today-choose-sheet'), findsOneWidget);
    expect(_key('today-option-project'), findsOneWidget);
    await _tap(tester, _key('today-pin-project'));
    expect(h.state.settings.todayPin, TodayPin.project);
    expect(h.store.saved!.settings.todayPin, TodayPin.project);
    if (_key('today-choose-sheet').evaluate().isNotEmpty) {
      await tester.tapAt(const Offset(20, 20)); // close the sheet
      await _settle(tester);
    }

    // Today follows the pin: the project and its next milestone, as typed.
    expect(_key('today-step-project'), findsOneWidget);
    expect(_inNextStep(find.text('Four short essays')), findsOneWidget);
    expect(_inNextStep(find.text('Next: First draft')), findsOneWidget);

    // Do it: tick the milestone in the project.
    await _tap(tester, _key('today-next-action'));
    expect(find.byType(ProjectScreen), findsOneWidget);
    await _tap(tester, _key('milestone-check-m2'));
    expect(h.store.saved!.project!.milestones.last.done, isTrue);
    await _back(tester);

    // The easy stop, with a quiet "One more".
    expect(_key('today-done'), findsOneWidget);
    expect(find.text('Done. That can be enough for today.'), findsOneWidget);
    expect(_key('today-step-project'), findsNothing);
    await _tap(tester, _key('today-one-more'));
    expect(_key('today-done'), findsNothing);
    expect(_key('today-next-action'), findsOneWidget);

    // Next launch: the pin is remembered and today's work still counts.
    final saved = h.store.saved!;
    expect(saved.settings.todayPin, TodayPin.project);
    await tester.pumpWidget(const SizedBox());
    await pumpCartha(
      tester,
      data: saved,
      content: _content,
      size: _phone,
    );
    expect(find.byType(TodayTab), findsOneWidget);
    expect(_key('today-done'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Playground: a try is not a task until "Add to my tasks"; '
      'the Collection keeps it; its pick buys a reward, previewed first', (
    tester,
  ) async {
    final h = await pumpCartha(
      tester,
      data: onboardedData(),
      content: _content,
      size: _phone,
    );
    expect(h.state.picksLeft, 0);
    await _openCampaignHub(tester);
    await _tap(tester, _key('campaign-open-try'));
    expect(find.byType(TryScreen), findsOneWidget);
    expect(_key('try-card-try.terrain.01'), findsOneWidget);

    // I tried it, with a note exactly as typed.
    await _type(tester, _key('try-note'), _note);
    await _tap(tester, _key('try-done'));
    expect(find.text('Saved to your Collection.'), findsOneWidget);
    final entry = h.state.data.experimentLog.single;
    expect(entry.experimentId, 'try.terrain.01');
    expect(entry.note, _note);
    expect(entry.day, '2026-11-03');
    expect(h.store.saved!.experimentLog.single.note, _note);
    // Trying is not a task.
    expect(h.state.data.quests, isEmpty);
    expect(h.store.saved!.quests, isEmpty);
    // The moment: +10 XP, the chapter's achievement (by trying) and a pick.
    await tester.pump(CampaignFeedback.settle);
    await tester.pump();
    expect(find.textContaining('+10 XP'), findsOneWidget);
    expect(find.textContaining('A new pick for your avatar'), findsOneWidget);
    expect(h.state.campaign.earnedBy[Achievement.observer], EarnedRoute.trying);
    expect(h.state.picksLeft, 1);
    await _waitOutSnackBars(tester);

    // Only "Add to my tasks" makes a quest; a second tap adds no duplicate.
    await _tap(tester, _key('try-add-task'));
    expect(find.text('Added to your tasks.'), findsOneWidget);
    final quest = h.state.data.quests.single;
    expect(quest.source, QuestSource.experiment);
    expect(h.store.saved!.quests.single.id, quest.id);
    await _waitOutSnackBars(tester);
    await _tap(tester, _key('try-add-task'));
    expect(h.state.data.quests, hasLength(1));
    await _waitOutSnackBars(tester);
    await _back(tester);

    // The Collection: the try with its note, the badge and how it was won.
    await _tap(tester, _key('campaign-link-collection'));
    expect(find.byType(CollectionScreen), findsOneWidget);
    final tried = _key('collection-tried-${entry.id}');
    expect(tried, findsOneWidget);
    expect(
      find.descendant(of: tried, matching: find.text(_note)),
      findsOneWidget,
    );
    final observer = _key('collection-achievement-observer');
    // Changed by design (A1): the experiment that earned it is named.
    final title = _content.experiment('try.terrain.01')!.title;
    expect(
      find.descendant(
        of: observer,
        matching: find.text('Earned by trying: $title'),
      ),
      findsOneWidget,
    );
    final badge = tester.widget<AchievementBadge>(
      find.descendant(of: observer, matching: find.byType(AchievementBadge)),
    );
    expect(badge.earned, isTrue);
    expect(
      tester
          .widget<AchievementBadge>(
            find.descendant(
              of: _key('collection-achievement-challenger'),
              matching: find.byType(AchievementBadge),
            ),
          )
          .earned,
      isFalse,
    );
    await _back(tester);

    // Make it yours › Choose your reward: preview first, then spend.
    await _tap(tester, _key('campaign-open-yours'));
    expect(find.byType(MakeItYoursScreen), findsOneWidget);
    await _tap(tester, _key('campaign-reward-open'));
    expect(find.byType(RewardSheet), findsOneWidget);
    final tiles = tester
        .widgetList<BuilderOptionTile>(find.byType(BuilderOptionTile))
        .toList();
    // The Observer's suggested extra first and preselected.
    expect(tiles.first.key, const ValueKey('reward-option-accessoryScroll'));
    expect(tiles.first.selected, isTrue);
    await _tap(tester, _key('reward-option-sigilStar'));
    expect(
      tester.widget<AvatarView>(_key('reward-preview')).avatar!.sigil,
      Sigil.star,
    );
    expect(h.state.data.avatarUnlocked, isEmpty, reason: 'not spent yet');
    expect(h.state.picksLeft, 1);
    await _tap(tester, _key('reward-confirm'));
    await _settle(tester);
    expect(find.byType(RewardSheet), findsNothing);
    expect(h.state.data.avatarUnlocked, {Unlockable.sigilStar});
    expect(h.store.saved!.avatarUnlocked, {Unlockable.sigilStar});
    expect(h.state.picksLeft, 0);
    await _waitOutSnackBars(tester);
    await _back(tester);

    // The Collection lists the extra chosen.
    await _tap(tester, _key('campaign-link-collection'));
    expect(_key('collection-extra-sigilStar'), findsOneWidget);
    await _back(tester);

    // Missions shows the task, labelled as an experiment.
    await _tap(
      tester,
      find.descendant(
        of: find.byType(PillTabs<CompassSection>),
        matching: find.text('Missions'),
      ),
    );
    expect(find.text(quest.title), findsWidgets);
    expect(find.text('Experiment'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the battle log: the draft survives leaving the screen; a '
      'failed save is honest and keeps the words', (tester) async {
    final h = await pumpCartha(
      tester,
      data: onboardedData().copyWith(
        project: () => MonthProject(
          title: 'Four short essays',
          status: ProjectStatus.active,
          updatedAt: _t,
        ),
      ),
      content: _content,
      size: _phone,
    );
    await _openCampaignHub(tester);
    await _tap(tester, _key('campaign-link-log'));
    expect(find.byType(BattleLogScreen), findsOneWidget);
    await _type(tester, _key('campaign-attempt'), _attempt);
    await _type(tester, _key('campaign-learning'), _learning);

    // Leaving keeps the words as a draft, exactly as typed.
    await _back(tester);
    expect(h.state.attemptDraft!.attempt, _attempt);
    expect(h.state.attemptDraft!.learning, _learning);
    expect(h.store.saved!.attemptDraft!.attempt, _attempt);
    expect(h.store.saved!.attemptDraft!.learning, _learning);
    await _tap(tester, _key('campaign-link-log'));
    expect(_fieldText(tester, 'campaign-attempt'), _attempt);
    expect(_fieldText(tester, 'campaign-learning'), _learning);

    // The phone can't save: never "recorded"; the words stay; Retry on top.
    h.store.failWrites = true;
    await _tap(tester, _key('campaign-record'));
    expect(find.text('Attempt recorded.'), findsNothing);
    expect(
      find.text(
        'Not saved on this phone yet. Your words are still here. '
        'Retry at the top.',
      ),
      findsOneWidget,
    );
    expect(_fieldText(tester, 'campaign-attempt'), _attempt);
    expect(_fieldText(tester, 'campaign-learning'), _learning);
    expect(find.text('Retry'), findsWidgets);
    // On the phone: still the draft, no attempt.
    expect(h.store.saved!.campaignLog, isEmpty);
    expect(h.store.saved!.attemptDraft!.attempt, _attempt);
    await _waitOutSnackBars(tester);

    // Leaving and coming back while Retry still waits: the words are where
    // they were typed, and the attempt is listed once.
    await _back(tester);
    await _tap(tester, _key('campaign-link-log'));
    expect(_fieldText(tester, 'campaign-attempt'), _attempt);
    expect(_fieldText(tester, 'campaign-learning'), _learning);
    expect(h.state.data.campaignLog, hasLength(1));

    // Retry once the phone can save: recorded now, the draft is gone.
    h.store.failWrites = false;
    await _tap(tester, find.text('Retry').first);
    await _settle(tester);
    final saved = h.store.saved!;
    expect(saved.campaignLog.single.attempt, _attempt);
    expect(saved.campaignLog.single.learning, _learning);
    expect(saved.attemptDraft, isNull);
    expect(find.text('Attempt recorded.'), findsOneWidget);
    expect(_fieldText(tester, 'campaign-attempt'), isEmpty);
    await _waitOutSnackBars(tester);

    // Leaving now leaves no draft behind.
    await _back(tester);
    expect(h.store.saved!.attemptDraft, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('backup, restore and "Delete all data" carry the new fields', (
    tester,
  ) async {
    final experiment = ExperimentEntry(
      id: 'x1',
      experimentId: 'try.plan.01',
      day: '2026-11-02',
      note: _note,
      createdAt: _yesterday,
    );
    final data = onboardedData(
      settings: const AppSettings(todayPin: TodayPin.notes),
    ).copyWith(
      attemptDraft: () =>
          AttemptDraft(attempt: _attempt, learning: _learning, updatedAt: _t),
      experimentLog: [experiment],
      tryNoteDrafts: {'try.terrain.01': _note},
      avatarUnlocked: {Unlockable.accessoryCompass},
      quests: [
        Quest(
          id: 'q1',
          title: "Write tomorrow's first step tonight",
          createdAt: _t,
          source: QuestSource.experiment,
        ),
      ],
    );
    final h = await pumpCartha(
      tester,
      data: data,
      content: _content,
      size: _phone,
    );

    // Export.
    await _openTab(tester, 'You');
    await _tap(tester, _key('you-data'));
    expect(find.byType(DataScreen), findsOneWidget);
    await _tap(tester, _key('data-export'));
    final backup = h.files.shared.last;
    // Step 2: the export is the v2 backup (.zip with data.json).
    final exported = decodeBackupBytes(backup.bytes).data;
    expect(exported.settings.todayPin, TodayPin.notes);
    expect(exported.settings.gameInvited, isTrue);
    expect(exported.attemptDraft!.attempt, _attempt);
    expect(exported.attemptDraft!.learning, _learning);
    expect(exported.experimentLog.single.note, _note);
    expect(exported.tryNoteDrafts, {'try.terrain.01': _note});
    expect(exported.avatarUnlocked, {Unlockable.accessoryCompass});
    expect(exported.quests.single.source, QuestSource.experiment);
    await _waitOutSnackBars(tester);

    // Delete all data: everything goes, the welcome comes back.
    await _tap(tester, _key('data-delete'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Continue'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Delete everything'));
    await _settle(tester, frames: 10);
    expect(find.byType(OnboardingFlow), findsOneWidget);
    expect(h.store.raw, isNull);
    expect(h.state.data.attemptDraft, isNull);
    expect(h.state.data.experimentLog, isEmpty);
    expect(h.state.data.tryNoteDrafts, isEmpty);
    expect(h.state.data.avatarUnlocked, isEmpty);
    expect(h.state.data.quests, isEmpty);

    // A fresh start is a new user: Campaign off, question open, no pin.
    await _tap(tester, _key('onboarding-next'));
    await _tap(tester, _key('onboarding-adult'));
    for (var i = 0; i < 3; i++) {
      await _tap(tester, _key('onboarding-next'));
    }
    await _tap(tester, _key('onboarding-finish'));
    await _settle(tester, frames: 8);
    expect(h.state.settings.game, isFalse);
    expect(h.state.settings.gameInvited, isFalse);
    expect(h.state.settings.todayPin, TodayPin.auto);
    // Deleted from You, the new user still lands on Today, with the
    // invitation (not on the You tab left open before).
    expect(h.shell.tab, AppTab.today);
    expect(_in<TodayTab>(_key('today-invite')), findsOneWidget);

    // Restore: every new field comes back, and the question is answered.
    await _openTab(tester, 'You');
    await _tap(tester, _key('you-data'));
    h.files.pickBytes = backup.bytes;
    await _tap(tester, _key('data-import'));
    await _tap(tester, find.widgetWithText(FilledButton, 'Replace'));
    expect(find.text('Backup restored.'), findsOneWidget);
    for (final restored in [h.state.data, h.store.saved!]) {
      expect(restored.settings.todayPin, TodayPin.notes);
      expect(restored.settings.game, isTrue);
      expect(restored.settings.gameInvited, isTrue);
      expect(restored.attemptDraft!.attempt, _attempt);
      expect(restored.attemptDraft!.learning, _learning);
      expect(restored.experimentLog.single.note, _note);
      expect(restored.experimentLog.single.experimentId, 'try.plan.01');
      expect(restored.tryNoteDrafts, {'try.terrain.01': _note});
      expect(restored.avatarUnlocked, {Unlockable.accessoryCompass});
      expect(restored.quests.single.source, QuestSource.experiment);
    }
    // A restore is not a moment, however small (a try, its achievement
    // and its pick came back with it).
    await tester.pump(CampaignFeedback.settle);
    await tester.pump();
    expect(_key('campaign-toast'), findsNothing);
    await _back(tester);
    await _openTab(tester, 'Today');
    expect(_key('today-invite'), findsNothing);
    // Pinned to notes: Today suggests a note.
    expect(_key('today-step-journal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
