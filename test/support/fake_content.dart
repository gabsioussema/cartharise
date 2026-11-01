import 'package:cartharise/domain/content.dart';

/// A complete, dummy-text [ContentLibrary] with the real structure
/// (PLAN.md §7): 14 morning, 6 daytime (source default times), 3 optional
/// bonus, 7 evening (evening.03–07 map to Compass fields), 7 lessons with
/// checks, and 30 path days in four stages. Tests never depend on the real
/// English wording.
final ContentLibrary fakeContent = ContentLibrary(
  languageCode: 'en',
  version: 1,
  lessons: [
    for (var i = 1; i <= 7; i++)
      Lesson(
        id: 'lesson.${_two(i)}',
        ordinal: i,
        title: 'Lesson $i title',
        summary: 'Summary of lesson $i.',
        explanation: 'Explanation of lesson $i.\n\nA second paragraph.',
        example: 'Example for lesson $i.',
        nuance: 'Nuance for lesson $i.',
        relatedPromptIds: ['morning.${_two(i)}'],
        check: KnowledgeCheck(
          question: 'Check question $i?',
          options: const ['Option A', 'Option B', 'Option C'],
          correctIndex: i % 3,
          explanation: 'Why option ${'ABC'[i % 3]} fits.',
        ),
      ),
  ],
  prompts: [
    for (var i = 1; i <= 14; i++)
      _prompt('morning', PromptPhase.morning, i, switch (i) {
        <= 4 => PromptGroup.currentReality,
        <= 8 => PromptGroup.antiVision,
        <= 11 => PromptGroup.identity,
        _ => PromptGroup.vision,
      }, softer: i >= 5 && i <= 11),
    for (var i = 1; i <= 6; i++)
      _prompt(
        'daytime',
        PromptPhase.daytime,
        i,
        PromptGroup.interrupt,
        time: kFakeDaytimeTimes[i - 1],
      ),
    for (var i = 1; i <= 3; i++)
      _prompt(
        'bonus',
        PromptPhase.bonus,
        i,
        PromptGroup.contemplation,
        core: false,
      ),
    for (var i = 1; i <= 7; i++)
      _prompt(
        'evening',
        PromptPhase.evening,
        i,
        switch (i) {
          <= 2 => PromptGroup.insight,
          <= 4 => PromptGroup.direction,
          _ => PromptGroup.plan,
        },
        mapsTo: switch (i) {
          3 => CompassField.antiVision,
          4 => CompassField.vision,
          5 => CompassField.yearGoal,
          6 => CompassField.monthProject,
          7 => CompassField.dailyLevers,
          _ => null,
        },
      ),
  ],
  thirtyDays: [
    for (var d = 1; d <= 30; d++)
      PathDay(
        day: d,
        stage: switch (d) {
          <= 7 => PathStage.observe,
          <= 15 => PathStage.experiment,
          <= 23 => PathStage.build,
          _ => PathStage.adjust,
        },
        title: 'Day $d title',
        prompt: 'Day $d prompt?',
        hint: d.isEven ? 'Hint for day $d.' : null,
      ),
  ],
  credit: const SourceCredit(
    title: 'How to fix your entire life in 1 day',
    author: 'Dan Koe',
    articleUrl: 'https://x.com/thedankoe/status/2010751592346030461',
    newsletterUrl:
        'https://letters.thedankoe.com/p/how-to-fix-your-entire-life-in-1',
    publishedOn: '23 December 2025',
    independenceNotice:
        'Independent; not affiliated with or endorsed by the author.',
    paraphraseNotice: 'Prompts are paraphrased, not reproduced.',
  ),
);

const kFakeDaytimeTimes = [
  '11:00',
  '13:30',
  '15:15',
  '17:00',
  '19:30',
  '21:00',
];

String _two(int i) => i.toString().padLeft(2, '0');

Prompt _prompt(
  String prefix,
  PromptPhase phase,
  int i,
  PromptGroup group, {
  bool softer = false,
  bool core = true,
  String? time,
  CompassField? mapsTo,
}) => Prompt(
  id: '$prefix.${_two(i)}',
  phase: phase,
  ordinal: i,
  group: group,
  title: '${prefix[0].toUpperCase()}${prefix.substring(1)} $i title',
  question: 'Question $prefix $i?',
  context: 'Context for $prefix $i.',
  help: 'Help for $prefix $i.',
  example: 'Example for $prefix $i.',
  sourceReference:
      '${prefix[0].toUpperCase()}${prefix.substring(1)} ${_two(i)}',
  softerQuestion: softer ? 'Softer question $prefix $i?' : null,
  defaultTime: time,
  mapsTo: mapsTo,
  core: core,
);
