// English content for Cartharise (launch language).
//
// Every user-facing sentence here is independently written: the source article
// is credited and linked, never reproduced (PLAN.md §7, F-039). Prompt ids are
// permanent — saved answers are keyed by them. Reword freely, but never reuse an
// id for a different question; bump [ContentLibrary.version] on any change.
//
// Traceability (source segment → ids → placement): docs/content-traceability.md.
import '../domain/content.dart';

// Source segments, mirroring the requirements' §05 coverage rows.
const String _srcReality = 'Morning 01–04 · current reality';
const String _srcAntiVision = 'Morning 05–08 · anti-vision';
const String _srcIdentity = 'Morning 09–11 · identity';
const String _srcVision = 'Morning 12–14 · vision';
const String _srcInterrupt = 'Daytime 01–06 · interrupt';
const String _srcBonus = 'Bonus 01–03 · contemplation';
const String _srcInsight = 'Evening 01–02 · insight';
const String _srcDirection = 'Evening 03–04 · direction';
const String _srcPlan = 'Evening 05–07 · plan';

const ContentLibrary englishContent = ContentLibrary(
  languageCode: 'en',
  version: 1,
  lessons: _lessons,
  prompts: _prompts,
  thirtyDays: _thirtyDays,
  credit: _credit,
  experiments: _experiments,
  notices: _notices,
);

// ---------------------------------------------------------------------------
// Credit (F-002, F-038)
// ---------------------------------------------------------------------------

const SourceCredit _credit = SourceCredit(
  title: 'How to fix your entire life in 1 day',
  author: 'Dan Koe',
  articleUrl: 'https://x.com/thedankoe/status/2010751592346030461',
  newsletterUrl:
      'https://letters.thedankoe.com/p/how-to-fix-your-entire-life-in-1',
  publishedOn: '23 December 2025',
  independenceNotice:
      "Cartharise is an independent app. It is not affiliated with, sponsored "
      "by or endorsed by Dan Koe.",
  paraphraseNotice:
      "The lessons and questions are paraphrased in Cartharise's own words; "
      "the article itself is not reproduced here. Read the original for the "
      "author's full reasoning. The thirty-day path, quests, journal and "
      "weekly reviews are Cartharise additions, not part of the article.",
);

// ---------------------------------------------------------------------------
// Awakening: the seven central ideas (F-005, F-006)
// ---------------------------------------------------------------------------

const List<Lesson> _lessons = [
  Lesson(
    id: 'lesson.01',
    ordinal: 1,
    title: 'Who you are comes first',
    summary:
        "Lasting change tends to grow from how you see yourself, not only "
        "from what you try to do.",
    explanation:
        "Most plans start with actions: exercise more, write every day, "
        "spend less. The article argues that actions rest on something "
        "deeper, which is the way you see yourself.\n\n"
        "When a habit fits your picture of who you are, it feels normal "
        "instead of forced. When it clashes with that picture, motivation "
        "often fades after a few weeks and the old routine comes back.\n\n"
        "So the suggestion is to begin with the kind of life, and the kind "
        "of person, that would produce the result naturally. Actions then "
        "have something to grow from.",
    example:
        "Two friends decide to eat better. One treats it as a short diet "
        "to get through. The other starts to think of themselves as someone "
        "who enjoys cooking fresh food. The second change often feels "
        "lighter, because it fits who they are becoming.",
    nuance:
        "This is a lens from self-development writing, not a law of "
        "psychology. Health, money, time and support also shape what is "
        "possible. Seeing yourself differently can help, but it is never "
        "the whole story, and it is never a reason for blame.",
    relatedPromptIds: ['morning.09', 'morning.13', 'morning.14'],
    check: KnowledgeCheck(
      question: "According to this lesson, why do some changes fade quickly?",
      options: [
        "They clash with how the person sees themselves",
        "The person simply did not try hard enough",
        "Habits can never really change",
      ],
      correctIndex: 0,
      explanation:
          "The idea is that change lasts longer when it fits your sense of "
          "self. It is not about effort or worth, and habits can change.",
    ),
  ),
  Lesson(
    id: 'lesson.02',
    ordinal: 2,
    title: 'Your actions have reasons',
    summary:
        "Habits usually serve a purpose, even when that purpose is hidden "
        "from us.",
    explanation:
        "The article's view is that everything we do is aimed at something, "
        "even when we are not aware of it. Putting off a task can be a way "
        "to avoid being judged. Staying somewhere familiar can be a way to "
        "feel safe.\n\n"
        "The reasons we tell ourselves are often tidier than the real ones. "
        "That is very human, and it does not make anyone a bad person.\n\n"
        "A goal also works a bit like a pair of glasses: it shapes what you "
        "notice. Aim at something new and you start to see new chances, "
        "which is why real change begins with a new point of view, not just "
        "a new to-do list.",
    example:
        "Someone wants to share their art online but never posts. Looking "
        "closer, not posting keeps them safe from strangers' opinions. Once "
        "they see that, a smaller first step feels possible, like showing "
        "one drawing to a friend.",
    nuance:
        "This is a way of looking at behaviour, not a way of reading minds. "
        "Cartharise never guesses your hidden motives; only you can test "
        "whether an explanation fits. Sometimes a habit is simply rest, and "
        "that is fine.",
    relatedPromptIds: ['morning.03', 'morning.11', 'daytime.02'],
    check: KnowledgeCheck(
      question:
          "What does this lesson suggest about a habit you would like to "
          "change?",
      options: [
        "It probably gives you something, such as comfort or safety",
        "It proves you do not care about your goals",
        "It has no cause at all",
      ],
      correctIndex: 0,
      explanation:
          "Most habits meet some need. Noticing that need, without judging "
          "it, gives you more room to choose.",
    ),
  ),
  Lesson(
    id: 'lesson.03',
    ordinal: 3,
    title: 'Why change can feel risky',
    summary:
        "We tend to guard our sense of self, so change can feel like a "
        "threat even when we want it.",
    explanation:
        "The article describes a loop. We choose goals, notice what fits "
        "them, act, get feedback and repeat. Over time, what we repeat "
        "becomes part of who we think we are.\n\n"
        "Once a self-image is in place, we tend to guard it. A challenge to "
        "“the kind of person I am” can set off the same stress as a "
        "physical threat, even when the change would help us.\n\n"
        "Much of this loop starts early, shaped by family and culture. "
        "Noticing it is a first step toward choosing which parts to keep.",
    example:
        "Someone has always said “I'm not a numbers person.” When their job "
        "offers a short budgeting course, they feel uneasy before it even "
        "starts. The label, not the course, is what feels at risk.",
    nuance:
        "This is a simplified model drawn from several ideas in "
        "self-development and psychology, not a settled fact. Not every "
        "hesitation is self-protection; sometimes caution is wise. Use it "
        "as a question to explore, never as a label for yourself.",
    relatedPromptIds: ['morning.09', 'morning.11', 'daytime.05', 'bonus.01'],
    check: KnowledgeCheck(
      question:
          "Why might a helpful change still feel uncomfortable, according to "
          "this lesson?",
      options: [
        "It can challenge how you see yourself",
        "Discomfort shows the change is wrong for you",
        "Only some people ever feel uneasy about change",
      ],
      correctIndex: 0,
      explanation:
          "A change can touch your sense of who you are, which may feel "
          "uneasy. Discomfort alone does not tell you whether a change is "
          "right or wrong.",
    ),
  ),
  Lesson(
    id: 'lesson.04',
    ordinal: 4,
    title: 'Ways of seeing can widen',
    summary:
        "Some thinkers describe ways of seeing the world that can grow "
        "broader over a lifetime.",
    explanation:
        "The article draws on models of adult development. In broad terms, "
        "they describe a movement from following the rules of your group, "
        "to forming your own values, to noticing that those values were "
        "shaped by where you grew up and can be held more lightly.\n\n"
        "The point is that what feels possible depends partly on how you "
        "see things. A question that opens a door for one person may feel "
        "strange to another, and that is okay.\n\n"
        "The practical takeaway is simple: notice beliefs you took on "
        "without choosing them, and ask which ones you still want to keep.",
    example:
        "Someone grew up believing a steady office job is the only sensible "
        "path. Later they notice this was their family's view and ask what "
        "they value themselves. They may keep the job, but now it is a "
        "choice.",
    nuance:
        "These are frameworks, and researchers disagree about them. "
        "Cartharise does not place you in any stage, measure your growth, "
        "or suggest that one person is ahead of another. Take only what is "
        "useful to you.",
    relatedPromptIds: ['morning.09', 'evening.02', 'bonus.01'],
    check: KnowledgeCheck(
      question: "How does Cartharise use ideas about stages of development?",
      options: [
        "As one lens for noticing beliefs you took on without choosing",
        "To tell you which stage you are in",
        "To rank people from lower to higher",
      ],
      correctIndex: 0,
      explanation:
          "It is offered only as a lens for reflection. The app never puts "
          "you in a stage or compares you with anyone.",
    ),
  ),
  Lesson(
    id: 'lesson.05',
    ordinal: 5,
    title: 'Aim, check, adjust',
    summary:
        "Progress comes from aiming, acting, noticing what happened and "
        "adjusting, again and again.",
    explanation:
        "The article describes intelligence as the ability to move toward "
        "what you want. It borrows an idea from systems thinking: pick a "
        "target, act, check where you are, compare, and correct course. A "
        "thermostat works like this, and so does a sailor steering a boat.\n\n"
        "Seen this way, a setback is information, not a verdict. The useful "
        "question becomes “What did I learn, and what will I try next?”\n\n"
        "The article also notes that many people follow a path handed to "
        "them by default. Steering means choosing your own target, even a "
        "small one, and testing it.",
    example:
        "Someone wants more energy. They try going to bed earlier for a "
        "week, notice they still wake up tired, then try cutting coffee "
        "after lunch instead. Each try teaches them something.",
    nuance:
        "A feedback loop is a helpful metaphor, not a full theory of "
        "people. Luck, support and health matter too, and not every goal "
        "fits every timeline. Changing a goal is part of the process, not "
        "giving up.",
    relatedPromptIds: ['daytime.03', 'evening.05', 'evening.07'],
    check: KnowledgeCheck(
      question:
          "In a feedback loop, what is a useful response when something "
          "does not work?",
      options: [
        "Notice what happened and adjust the next try",
        "Stop, because it proves the goal was wrong",
        "Keep doing exactly the same thing",
      ],
      correctIndex: 0,
      explanation:
          "Every attempt gives you information. Small adjustments are how "
          "the loop moves forward.",
    ),
  ),
  Lesson(
    id: 'lesson.06',
    ordinal: 6,
    title: 'A day off autopilot',
    summary:
        "The reset is one day of questions: a morning look inward, short "
        "pauses during the day and an evening pull-together.",
    explanation:
        "The article suggests that change often moves through three "
        "phases: a growing sense that something does not fit, a stretch of "
        "not knowing what comes next, and then a clearer direction.\n\n"
        "The reset is built to move through those phases on purpose. In "
        "the morning you look honestly at your present and at two possible "
        "futures. During the day, short check-ins interrupt autopilot. In "
        "the evening, you gather what you noticed into a direction.\n\n"
        "The article recommends writing by hand and thinking for yourself "
        "rather than letting a tool answer for you. In Cartharise you can "
        "take one day or go at your own pace; nothing is locked by time.",
    example:
        "Someone sets aside a quiet Saturday. They answer the morning "
        "questions over breakfast, glance at a check-in while running "
        "errands, and write the evening answers before bed. Another person "
        "spreads the same questions across a week.",
    nuance:
        "One day can bring clarity; it cannot promise a changed life. The "
        "questions can stir up strong feelings, so skip, soften or pause "
        "whenever you need to. Cartharise is not therapy. If you are "
        "struggling, please reach out to a professional or someone you "
        "trust.",
    relatedPromptIds: ['morning.01', 'daytime.01', 'evening.01'],
    check: KnowledgeCheck(
      question: "What is the evening part of the reset for?",
      options: [
        "Gathering the day's insights into a direction",
        "Grading how well the day went",
        "Starting a fresh list of complaints",
      ],
      correctIndex: 0,
      explanation:
          "The evening turns what you noticed into a few sentences of "
          "direction and small next steps. Nothing is graded.",
    ),
  ),
  Lesson(
    id: 'lesson.07',
    ordinal: 7,
    title: 'Your direction as a game',
    summary:
        "Six parts turn your answers into a plan that works a little like "
        "a game, with stakes, a goal, missions, quests and rules.",
    explanation:
        "Games hold our attention because they offer clear goals, quick "
        "feedback and challenges that match our skills. The article "
        "borrows this to organise a life plan into six parts.\n\n"
        "The anti-vision shows what is at stake. The vision describes "
        "winning, for now. The one-year goal is the main mission. The "
        "one-month project is the big challenge where you build skills. "
        "Daily levers are small quests that move the project forward. "
        "Constraints are the rules you keep, like protecting sleep or "
        "family time.\n\n"
        "These goals work as lenses for focus rather than finish lines. "
        "You can change them as you learn.",
    example:
        "Someone's one-year goal is to run a 10 km race. This month's "
        "project is a beginner running plan. Today's lever is a 20-minute "
        "run. One constraint: training never replaces dinner with family.",
    nuance:
        "The game idea is a metaphor to make planning feel lighter. "
        "Cartharise keeps no points, levels or scores, and progress here is "
        "never a measure of your worth. Your Compass is yours to edit, and "
        "constraints are only ever written by you.",
    relatedPromptIds: [
      'evening.03',
      'evening.04',
      'evening.05',
      'evening.06',
      'evening.07',
    ],
    check: KnowledgeCheck(
      question: "In the six-part plan, what are constraints?",
      options: [
        "Limits you choose so the plan never costs what matters most",
        "Tasks you have to complete every single day",
        "A score that shows how well you are doing",
      ],
      correctIndex: 0,
      explanation:
          "Constraints are boundaries you set yourself, such as protecting "
          "sleep or relationships. Cartharise never fills them in for you.",
    ),
  ),
];

// ---------------------------------------------------------------------------
// Reset prompts: 14 morning · 6 daytime · 3 bonus · 7 evening
// ---------------------------------------------------------------------------

const List<Prompt> _prompts = [
  // ── Morning 01–04 · current reality (The Mirror) ──────────────────────────
  Prompt(
    id: 'morning.01',
    phase: PromptPhase.morning,
    ordinal: 1,
    group: PromptGroup.currentReality,
    title: 'Quiet dissatisfaction',
    question:
        "What low, steady discomfort in your life have you got used to "
        "living with?",
    softerQuestion:
        "Is there something small in your days that has bothered you for a "
        "while?",
    context:
        "We start with the present. Not big crises, just the background "
        "unease you have learned to put up with.",
    help:
        "Think of something that is not terrible, only a little wrong, and "
        "has been that way for months. Because it is bearable, it is easy "
        "to stop noticing it. Naming it is a first step toward seeing your "
        "situation clearly. A few words are enough.",
    example:
        "Someone might write: “Most evenings I feel restless and scroll "
        "until late, even though I'm tired.”",
    sourceReference: _srcReality,
  ),
  Prompt(
    id: 'morning.02',
    phase: PromptPhase.morning,
    ordinal: 2,
    group: PromptGroup.currentReality,
    title: 'Complaints on repeat',
    question:
        "What do you keep complaining about without doing anything "
        "different? Try to list the two or three you have said most this "
        "year.",
    softerQuestion:
        "Which topics come up again and again when you talk about your "
        "life?",
    context:
        "Complaints that keep coming back are useful clues. They point to "
        "things that matter to you but have not moved yet.",
    help:
        "Think about what you tell friends, family or yourself. You are "
        "not judging the complaint or yourself, only collecting it. Leave "
        "out anything you have already changed.",
    example:
        "Someone might write: “My commute is too long. I never have time to "
        "paint. Team meetings go in circles.”",
    sourceReference: _srcReality,
  ),
  Prompt(
    id: 'morning.03',
    phase: PromptPhase.morning,
    ordinal: 3,
    group: PromptGroup.currentReality,
    title: 'What your actions say',
    question:
        "Look at each complaint. If someone could only see what you do, "
        "and not hear what you say, what would they guess you want?",
    softerQuestion:
        "For one complaint, what might your everyday choices be quietly "
        "looking after?",
    context:
        "Behaviour often follows goals we never say out loud. This "
        "question looks at the gap between what you intend and what you "
        "do.",
    help:
        "This is not about catching yourself out. Most habits give you "
        "something, such as comfort, rest, safety or approval. Write what an "
        "outside viewer might guess, then decide whether it fits. You are "
        "free to disagree with the guess.",
    example:
        "Someone might write: “I say I want to get fit, but an observer "
        "would see me choose quiet time on the sofa after work. Maybe I need "
        "recovery more than training right now.”",
    sourceReference: _srcReality,
  ),
  Prompt(
    id: 'morning.04',
    phase: PromptPhase.morning,
    ordinal: 4,
    group: PromptGroup.currentReality,
    title: 'The hard-to-say truth',
    question:
        "What is true about your life right now that you would struggle to "
        "tell a person you look up to?",
    softerQuestion:
        "What is one honest thing about your life that you rarely say out "
        "loud?",
    context:
        "Some facts are easier to keep vague. Writing one down, privately, "
        "can take away some of its weight.",
    help:
        "Your answer stays on this phone. You do not need to show it to "
        "anyone or act on it today. If this feels like too much, switch to "
        "the gentler wording or skip it and come back later.",
    example:
        "Someone might write: “I have been saying ‘next month’ about "
        "starting my own business for three years.”",
    sourceReference: _srcReality,
  ),

  // ── Morning 05–08 · anti-vision (The Mirror) ─────────────────────────────
  Prompt(
    id: 'morning.05',
    phase: PromptPhase.morning,
    ordinal: 5,
    group: PromptGroup.antiVision,
    title: 'Five years, unchanged',
    question:
        "Imagine your habits stay exactly as they are for five years. "
        "Describe an ordinary weekday then: where you wake up, how your body "
        "feels, who is around you, how the evening ends.",
    softerQuestion:
        "Picture a normal day five years from now if things simply carry "
        "on as they are. What do you notice?",
    context:
        "This is a possible future, not a prediction. Seeing where today's "
        "path could lead can make the choice in front of you clearer.",
    help:
        "Add small details, like a scene in a film: morning, working hours, "
        "evening. This picture is part of an anti-vision, a future you "
        "would rather avoid. It is a tool for clarity, not a forecast. Stop "
        "whenever you need to.",
    example:
        "Someone might write: “I wake up tired in the same flat, read work "
        "messages in bed, and spend the evening on my phone feeling I meant "
        "to do more.”",
    sourceReference: _srcAntiVision,
  ),
  Prompt(
    id: 'morning.06',
    phase: PromptPhase.morning,
    ordinal: 6,
    group: PromptGroup.antiVision,
    title: 'Ten years, unchanged',
    question:
        "Stretch the same picture to ten years. Which chances might have "
        "slipped by, and how might others describe your life?",
    softerQuestion:
        "If things stayed much the same for ten years, what might you wish "
        "you had tried?",
    context:
        "A longer view shows what slowly adds up. Again, this is a "
        "possibility to look at, not something that will happen.",
    help:
        "Think about opportunities, relationships, health and work. Be "
        "honest but kind to yourself. You are describing a path, not your "
        "worth as a person.",
    example:
        "Someone might write: “I might still be talking about learning the "
        "piano, and my family might remember me as always busy.”",
    sourceReference: _srcAntiVision,
  ),
  Prompt(
    id: 'morning.07',
    phase: PromptPhase.morning,
    ordinal: 7,
    group: PromptGroup.antiVision,
    title: 'Looking back from later life',
    question:
        "Imagine yourself much older, looking back on a life where you "
        "always chose the safe option. What did that cost, and what was "
        "left untried?",
    softerQuestion:
        "When you are older, what would you be sad to have missed out on?",
    context:
        "Looking from the far end of life can separate what matters from "
        "what only feels urgent. It is a thought experiment, not a verdict.",
    help:
        "Some people find this question heavy. Keep your answer short if "
        "you like, use the gentler wording, or skip it. The aim is to "
        "notice what matters to you, not to feel bad.",
    example:
        "Someone might write: “I never showed anyone my writing, never "
        "lived abroad, and didn't spend enough slow time with my sister.”",
    sourceReference: _srcAntiVision,
  ),
  Prompt(
    id: 'morning.08',
    phase: PromptPhase.morning,
    ordinal: 8,
    group: PromptGroup.antiVision,
    title: 'Paths around you',
    question:
        "Is there someone you know who seems a few years further along a "
        "road like the one you just pictured? What comes up when you "
        "imagine your life going the same way?",
    softerQuestion:
        "Without judging anyone, whose path shows you a direction you would "
        "rather not take? What does that teach you?",
    context:
        "Other people's lives can make a direction feel real. This is about "
        "your own choices, not about judging anyone else.",
    help:
        "You do not have to name anyone. Every life has reasons you cannot "
        "see from outside. Focus on the feeling it brings up in you and "
        "what that says about what you want.",
    example:
        "Someone might write: “An older colleague often says he wishes he "
        "had changed careers years ago. Imagining saying that myself makes "
        "me want to explore now.”",
    sourceReference: _srcAntiVision,
  ),

  // ── Morning 09–11 · identity (The Mirror) ────────────────────────────────
  Prompt(
    id: 'morning.09',
    phase: PromptPhase.morning,
    ordinal: 9,
    group: PromptGroup.identity,
    title: 'A role you might outgrow',
    question:
        "Which way of seeing yourself might you need to loosen in order to "
        "change? Try finishing: “I'm the kind of person who…” What could "
        "letting it go cost you with other people?",
    softerQuestion:
        "Is there a label you often use for yourself that might be keeping "
        "you in place?",
    context:
        "We all carry labels about who we are. Some help us; some quietly "
        "keep us where we are.",
    help:
        "Treat your answer as a guess to test, a hypothesis, not a fact "
        "about you. A role might be “the reliable one”, “not a creative "
        "person” or “the one who never makes a fuss”. Notice what keeping "
        "it gives you, too.",
    example:
        "Someone might write: “I'm the kind of person who never asks for "
        "help. If I changed that, I'd worry people might see me as less "
        "capable.”",
    sourceReference: _srcIdentity,
  ),
  Prompt(
    id: 'morning.10',
    phase: PromptPhase.morning,
    ordinal: 10,
    group: PromptGroup.identity,
    title: 'The reason that is hard to say',
    question:
        "What reason for not changing feels most awkward to admit, even to "
        "yourself?",
    softerQuestion: "What worry might be part of why change has felt hard?",
    context:
        "The reasons we give others are often neat. The real ones tend to "
        "be more human, like the fear of looking foolish.",
    help:
        "This is a hypothesis, not a judgement of your character. Common "
        "answers involve fear of being judged, of trying hard and still "
        "not getting there, or of letting someone down. Be gentle with "
        "whatever comes up.",
    example:
        "Someone might write: “Maybe if I really try and it doesn't work "
        "out, I can't tell myself it was only a lack of time.”",
    sourceReference: _srcIdentity,
  ),
  Prompt(
    id: 'morning.11',
    phase: PromptPhase.morning,
    ordinal: 11,
    group: PromptGroup.identity,
    title: 'What your habits guard',
    question:
        "If part of your current routine is there to keep you safe, what is "
        "it keeping safe? And what price do you pay for that safety?",
    softerQuestion:
        "What might your habits be trying to keep you comfortable or safe "
        "from?",
    context:
        "Many habits began as sensible ways to cope. Seeing what they guard "
        "can make change feel less like a fight.",
    help:
        "People often protect their pride, a sense of belonging, their "
        "energy or the comfort of the familiar. Whatever you write is a "
        "possible explanation for you to test, not a conclusion about you.",
    example:
        "Someone might write: “Staying very busy might stop me noticing "
        "that I feel lonely. It costs me rest and real conversations.”",
    sourceReference: _srcIdentity,
  ),

  // ── Morning 12–14 · vision (The Vision) ──────────────────────────────────
  Prompt(
    id: 'morning.12',
    phase: PromptPhase.morning,
    ordinal: 12,
    group: PromptGroup.vision,
    title: 'A good day, three years on',
    question:
        "Set practical limits aside for a moment. If you could be living "
        "the life you truly want three years from now, what would a normal "
        "weekday look like?",
    softerQuestion:
        "What would a good, ordinary day look like for you a few years from "
        "now?",
    context:
        "Now we turn toward what you want. Ordinary days matter, because "
        "that is where most of life happens.",
    help:
        "Use the same level of detail as your five-year picture: morning, "
        "work, people, body, evening. Describe what you want, not what you "
        "think you should want. You can change it at any time.",
    example:
        "Someone might write: “I wake up without an alarm, write for an "
        "hour, work on projects I chose, and cook with friends twice a "
        "week.”",
    sourceReference: _srcVision,
  ),
  Prompt(
    id: 'morning.13',
    phase: PromptPhase.morning,
    ordinal: 13,
    group: PromptGroup.vision,
    title: 'Who you are becoming',
    question:
        "For that day to feel normal instead of forced, what would you need "
        "to believe about yourself? Write it as an open statement: “I am "
        "becoming someone who…”",
    softerQuestion:
        "What is one belief about yourself that would make that day easier "
        "to live?",
    context:
        "Change tends to last when it fits how you see yourself. This "
        "statement is a direction to try on, not a claim that it is already "
        "true.",
    help:
        "Keep it open and kind, for example “I am becoming someone who "
        "looks after my energy”. These are your own words and you can edit "
        "them later. Cartharise never treats them as a fact about you.",
    example:
        "Someone might write: “I am becoming someone who makes things and "
        "shares them, even when they are not perfect.”",
    sourceReference: _srcVision,
  ),
  Prompt(
    id: 'morning.14',
    phase: PromptPhase.morning,
    ordinal: 14,
    group: PromptGroup.vision,
    title: 'One step this week',
    question:
        "Choose one small action for the coming seven days that fits the "
        "person you described. What is it?",
    softerQuestion:
        "What is one easy step this week that points toward the day you "
        "imagined?",
    context:
        "A small, real step turns a vision into something you can test in "
        "daily life.",
    help:
        "Make it specific and doable even on a tired day: a time, a place, "
        "a first move. Small is fine. Bigger plans can wait.",
    example:
        "Someone might write: “On Saturday morning, sketch for 20 minutes at "
        "the kitchen table before I check my phone.”",
    sourceReference: _srcVision,
  ),

  // ── Daytime 01–06 · interrupt (The Interrupt) ────────────────────────────
  Prompt(
    id: 'daytime.01',
    phase: PromptPhase.daytime,
    ordinal: 1,
    group: PromptGroup.interrupt,
    defaultTime: '11:00',
    title: 'Avoidance check',
    question:
        "Pause for a moment. Is what you are doing right now a way of "
        "putting something else off? If so, what?",
    softerQuestion: "Is there something you have been leaving for later today?",
    context:
        "Daytime check-ins break autopilot. They are quick: a sentence or "
        "two is plenty.",
    help:
        "Avoidance is normal and often makes sense. The aim is to notice "
        "it, not to drop everything and deal with it. “Nothing right now” "
        "is a fine answer too.",
    example:
        "Someone might write: “Sorting my inbox instead of starting the "
        "difficult report.”",
    sourceReference: _srcInterrupt,
  ),
  Prompt(
    id: 'daytime.02',
    phase: PromptPhase.daytime,
    ordinal: 2,
    group: PromptGroup.interrupt,
    defaultTime: '13:30',
    title: 'Priorities in action',
    question:
        "Think back over the last couple of hours. Judging only by your "
        "actions, what would an observer say you care about most?",
    softerQuestion:
        "What did the last couple of hours show about what you needed?",
    context:
        "Actions show our real priorities in the moment. This is "
        "information, not a grade.",
    help:
        "Describe what you did, then guess the priority behind it: rest, "
        "connection, money, approval, avoiding stress. Every answer is "
        "useful.",
    example:
        "Someone might write: “Mostly messages and small jobs. They'd guess "
        "I want to be available to everyone.”",
    sourceReference: _srcInterrupt,
  ),
  Prompt(
    id: 'daytime.03',
    phase: PromptPhase.daytime,
    ordinal: 3,
    group: PromptGroup.interrupt,
    defaultTime: '15:15',
    title: 'Which direction?',
    question:
        "Are today's choices leading you toward the future you want to "
        "avoid, or toward the one you hope for?",
    softerQuestion:
        "What is one thing today that pointed toward the life you want?",
    context:
        "This links your morning pictures to the middle of an ordinary day.",
    help:
        "No big answer is needed. Often it is a mix. If you can, name one "
        "choice that pointed each way.",
    example:
        "Someone might write: “A mix. Working through lunch was the old "
        "path; the short walk afterwards was the new one.”",
    sourceReference: _srcInterrupt,
  ),
  Prompt(
    id: 'daytime.04',
    phase: PromptPhase.daytime,
    ordinal: 4,
    group: PromptGroup.interrupt,
    defaultTime: '17:00',
    title: 'Set aside, but important',
    question:
        "What matters to you that you have been treating as if it does "
        "not?",
    softerQuestion:
        "Is there something you care about that has not had much room "
        "lately?",
    context:
        "Important things that do not shout, such as health, people or "
        "creative work, are easy to push aside.",
    help:
        "Be curious, not harsh. Setting something aside is often a sign of "
        "being busy or tired, not of not caring.",
    example:
        "Someone might write: “Calling my dad. I keep saying I'm too busy, "
        "but I miss him.”",
    sourceReference: _srcInterrupt,
  ),
  Prompt(
    id: 'daytime.05',
    phase: PromptPhase.daytime,
    ordinal: 5,
    group: PromptGroup.interrupt,
    defaultTime: '19:30',
    title: 'Image or wish?',
    question:
        "What did you do today mainly to keep up an image of yourself, "
        "rather than because you wanted to?",
    softerQuestion:
        "Was there a moment today when you did something just because it is "
        "what you always do?",
    context:
        "Some actions come from what we want; others come from habit or "
        "from how we like to be seen. Both are human.",
    help:
        "Look for small moments: agreeing to something, staying quiet, "
        "saying yes out of habit. Note them without blaming yourself.",
    example:
        "Someone might write: “I stayed late so I'd look committed, not "
        "because the work needed it.”",
    sourceReference: _srcInterrupt,
  ),
  Prompt(
    id: 'daytime.06',
    phase: PromptPhase.daytime,
    ordinal: 6,
    group: PromptGroup.interrupt,
    defaultTime: '21:00',
    title: 'Alive or flat',
    question:
        "When today did you feel most awake and alive? When did you feel "
        "flat or drained?",
    context:
        "Your energy is a quiet signal about what suits you and what does "
        "not.",
    help:
        "Name two moments, one high and one low. Notice who you were with "
        "and what you were doing. Patterns show up over several days.",
    example:
        "Someone might write: “Most alive: solving a problem with a "
        "colleague. Most flat: the hour of scrolling after dinner.”",
    sourceReference: _srcInterrupt,
  ),

  // ── Bonus 01–03 · contemplation (optional, not core) ─────────────────────
  Prompt(
    id: 'bonus.01',
    phase: PromptPhase.bonus,
    ordinal: 1,
    group: PromptGroup.contemplation,
    core: false,
    title: 'Other people’s view',
    question:
        "Think of the label you wrote about this morning. What would shift "
        "if you no longer needed others to see you that way?",
    softerQuestion:
        "Whose opinion of you feels most important right now, and why?",
    context:
        "Optional, for a walk, a commute or a quiet moment. It does not "
        "count toward finishing your reset.",
    help:
        "This builds on the morning question about a role you might "
        "outgrow (“I'm the kind of person who…”). Imagine both the freedom "
        "and the discomfort of letting the label go. If you skipped that "
        "question, think of any label you carry.",
    example:
        "Someone might write: “If I didn't need to be seen as the calm one, "
        "I might say when I'm overwhelmed.”",
    sourceReference: _srcBonus,
  ),
  Prompt(
    id: 'bonus.02',
    phase: PromptPhase.bonus,
    ordinal: 2,
    group: PromptGroup.contemplation,
    core: false,
    title: 'Safe or alive',
    question:
        "Where in your life might you be choosing comfort and safety over "
        "feeling alive?",
    softerQuestion:
        "Is there a part of your life where playing it safe no longer "
        "feels quite right?",
    context:
        "Optional. Safety has real value; this question only asks whether "
        "the trade still feels right to you.",
    help:
        "Look at work, relationships, health and creativity. Sometimes the "
        "safe choice is the right one. You are only noticing, not deciding.",
    example:
        "Someone might write: “I only cook the same five recipes. It's "
        "small, but it shows how I stick to what I know.”",
    sourceReference: _srcBonus,
  ),
  Prompt(
    id: 'bonus.03',
    phase: PromptPhase.bonus,
    ordinal: 3,
    group: PromptGroup.contemplation,
    core: false,
    title: 'A tiny version tomorrow',
    question:
        "Tomorrow, what is the tiniest way you could act like the person "
        "you hope to become?",
    context: "Optional. A tiny version is easier to start than a big plan.",
    help: "Think in minutes, not months: one message, one page, one walk.",
    example:
        "Someone might write: “Write three sentences of my story before "
        "work.”",
    sourceReference: _srcBonus,
  ),

  // ── Evening 01–02 · insight (The Breakthrough) ───────────────────────────
  Prompt(
    id: 'evening.01',
    phase: PromptPhase.evening,
    ordinal: 1,
    group: PromptGroup.insight,
    title: 'Why I have felt stuck',
    question:
        "After everything you noticed today, what is your best current "
        "explanation for why you have felt stuck?",
    softerQuestion:
        "What is one thing you learned today about what has been holding "
        "you back?",
    context:
        "The evening is for pulling the day together. A working theory is "
        "enough; you do not need certainty.",
    help:
        "Read back over your morning and daytime answers if you like. "
        "Write your theory in a few sentences. It can change as you learn "
        "more.",
    example:
        "Someone might write: “I keep waiting to feel ready, and I fill my "
        "time so I never have to find out.”",
    sourceReference: _srcInsight,
  ),
  Prompt(
    id: 'evening.02',
    phase: PromptPhase.evening,
    ordinal: 2,
    group: PromptGroup.insight,
    title: 'The inner pattern',
    question:
        "Leaving aside circumstances and other people, what inner pattern "
        "or belief seems to be steering things?",
    softerQuestion:
        "What thought or habit of mind seems to come up again and again?",
    context:
        "Outside things matter too. This question looks only at the part "
        "you can work with from the inside.",
    help:
        "Name it simply, for example “I have to be sure before I start” or "
        "“rest has to be earned”. Treat it as a hypothesis to test, not a "
        "judgement about who you are.",
    example:
        "Someone might write: “Believing my ideas are not good enough to "
        "show anyone yet.”",
    sourceReference: _srcInsight,
  ),

  // ── Evening 03–04 · direction (The Breakthrough → Compass) ───────────────
  Prompt(
    id: 'evening.03',
    phase: PromptPhase.evening,
    ordinal: 3,
    group: PromptGroup.direction,
    mapsTo: CompassField.antiVision,
    title: 'Anti-vision in one line',
    question: "In one sentence, what do you not want your life to become?",
    softerQuestion:
        "In one sentence, what direction would you like to move away from?",
    context:
        "This sentence gathers your morning pictures into a short reminder "
        "you can come back to.",
    help:
        "Make it personal and clear enough to mean something when you read "
        "it again. It describes a possible future to steer away from, not a "
        "prediction. You can later add it to your Life Compass as your "
        "anti-vision.",
    example:
        "Someone might write: “Years spent busy and tired, always meaning "
        "to start the things I care about.”",
    sourceReference: _srcDirection,
  ),
  Prompt(
    id: 'evening.04',
    phase: PromptPhase.evening,
    ordinal: 4,
    group: PromptGroup.direction,
    mapsTo: CompassField.vision,
    title: 'Vision in one line',
    question:
        "In one sentence, what life are you starting to build? It is fine "
        "if it changes later.",
    context:
        "A first, simple version of your vision is enough. It grows clearer "
        "with experience.",
    help:
        "Think of it as a first draft. Focus on how you want to live, not "
        "on things to own. You can later add it to your Life Compass as "
        "your vision.",
    example:
        "Someone might write: “A calm, healthy life where I make music and "
        "have time for the people I love.”",
    sourceReference: _srcDirection,
  ),

  // ── Evening 05–07 · plan (The Breakthrough → Compass) ────────────────────
  Prompt(
    id: 'evening.05',
    phase: PromptPhase.evening,
    ordinal: 5,
    group: PromptGroup.plan,
    mapsTo: CompassField.yearGoal,
    title: 'One year from now',
    question:
        "A year from now, what one concrete change would show you that the "
        "old pattern has loosened?",
    context:
        "Goals here work like lenses: a way to focus today's choices, not "
        "a finish line to judge yourself by.",
    help:
        "Choose something you could actually observe, like a habit kept, a "
        "project shared or a conversation had. Keep it realistic and kind "
        "to your health, money and relationships. It can become the "
        "one-year goal in your Compass.",
    example:
        "Someone might write: “I have finished and shared a small "
        "collection of my photos.”",
    sourceReference: _srcPlan,
  ),
  Prompt(
    id: 'evening.06',
    phase: PromptPhase.evening,
    ordinal: 6,
    group: PromptGroup.plan,
    mapsTo: CompassField.monthProject,
    title: 'One month from now',
    question:
        "What could you build, learn or set up in the next month that keeps "
        "your one-year change within reach?",
    context:
        "A month is long enough to make something real and short enough to "
        "stay focused.",
    help:
        "Think of one project with a clear end: a skill to practise, a "
        "draft to finish, a routine to try. It can become the month project "
        "in your Compass.",
    example:
        "Someone might write: “Take a beginner photo-editing course and "
        "choose my best 20 photos.”",
    sourceReference: _srcPlan,
  ),
  Prompt(
    id: 'evening.07',
    phase: PromptPhase.evening,
    ordinal: 7,
    group: PromptGroup.plan,
    mapsTo: CompassField.dailyLevers,
    title: "Tomorrow's actions",
    question:
        "List two or three small actions you could schedule for tomorrow "
        "that fit the direction you chose. Put each one on its own line.",
    context:
        "Small daily actions move the month project forward. Cartharise can "
        "turn these lines into draft quests for you to approve.",
    help:
        "Keep each action short, concrete and doable in under an hour. One "
        "action per line makes it easy to turn them into quests later. You "
        "can edit them at any time.",
    example:
        "Someone might write:\n"
        "Edit five photos for 30 minutes\n"
        "Ask Sam for feedback\n"
        "Walk after lunch",
    sourceReference: _srcPlan,
  ),
];

// ---------------------------------------------------------------------------
// Thirty-day path (F-057) — a Cartharise addition, not part of the article.
// Observe 1–7 · Experiment 8–15 · Build 16–23 · Adjust 24–30.
// ---------------------------------------------------------------------------

const List<PathDay> _thirtyDays = [
  // Observe
  PathDay(
    day: 1,
    stage: PathStage.observe,
    title: 'Your first hour',
    prompt:
        "How did the first hour of today go? Describe it as if you were "
        "watching, without judging it.",
    hint: "Facts first: what you did, then how you felt.",
  ),
  PathDay(
    day: 2,
    stage: PathStage.observe,
    title: 'Energy up, energy down',
    prompt:
        "Name one moment today that gave you energy and one that took it "
        "away.",
    hint: "Your 21:00 check-in from the reset may help you compare.",
  ),
  PathDay(
    day: 3,
    stage: PathStage.observe,
    title: 'Where the time went',
    prompt:
        "Roughly, where did your free time go today? How well does that "
        "match the vision in your Compass?",
    hint: "Rough guesses are fine. This is not a time sheet.",
  ),
  PathDay(
    day: 4,
    stage: PathStage.observe,
    title: 'A complaint, revisited',
    prompt:
        "Pick one complaint from your reset. Did it show up today? What "
        "happened just before it did?",
    hint: "Noticing the trigger is often more useful than the complaint.",
  ),
  PathDay(
    day: 5,
    stage: PathStage.observe,
    title: 'People and energy',
    prompt:
        "Who did you spend time with today, and how did you feel "
        "afterwards?",
    hint: "No need to write names. Initials or roles are enough.",
  ),
  PathDay(
    day: 6,
    stage: PathStage.observe,
    title: 'Small delays',
    prompt:
        "What did you put off today? What feeling came just before you put "
        "it off?",
    hint: "Boredom, worry and tiredness are all common answers.",
  ),
  PathDay(
    day: 7,
    stage: PathStage.observe,
    title: 'A week of noticing',
    prompt:
        "Looking back over the last seven days, which pattern stands out "
        "most?",
    hint: "One pattern is enough. Keep it for the next stage.",
  ),
  // Experiment
  PathDay(
    day: 8,
    stage: PathStage.experiment,
    title: 'One small change',
    prompt:
        "Choose one small change to try for the next few days, linked to "
        "your daily levers. What is it, and when will you do it?",
    hint: "Make it small enough to do on a tired day.",
  ),
  PathDay(
    day: 9,
    stage: PathStage.experiment,
    title: 'First try',
    prompt:
        "Did you try your change, or almost try it? What happened, and what "
        "got in the way?",
    hint: "Both answers teach you something.",
  ),
  PathDay(
    day: 10,
    stage: PathStage.experiment,
    title: 'Make it easier',
    prompt:
        "How could you make your chosen action easier to start? Think fewer "
        "steps, a better time, or things ready in advance.",
    hint: "Lower the effort before you raise the ambition.",
  ),
  PathDay(
    day: 11,
    stage: PathStage.experiment,
    title: 'Something different',
    prompt:
        "Pick one automatic habit and do it differently once today. What "
        "did you notice?",
    hint: "A new route, a new order, a new reply. Keep it light.",
  ),
  PathDay(
    day: 12,
    stage: PathStage.experiment,
    title: 'Ask for input',
    prompt:
        "Who could give you useful feedback or help with your month "
        "project? What would you ask them?",
    hint: "Asking is optional. Writing the question down already helps.",
  ),
  PathDay(
    day: 13,
    stage: PathStage.experiment,
    title: 'Test a belief',
    prompt:
        "Think of the inner pattern you named in the evening. What small "
        "action today could test whether it is really true?",
    hint: "Treat the result as information, whatever it is.",
  ),
  PathDay(
    day: 14,
    stage: PathStage.experiment,
    title: 'Rest on purpose',
    prompt:
        "How did you rest today? Did it leave you refreshed or just pass "
        "the time?",
    hint: "Rest is part of the plan, not a break from it.",
  ),
  PathDay(
    day: 15,
    stage: PathStage.experiment,
    title: 'What worked a little',
    prompt:
        "Of the things you tried this week, what worked even a little? What "
        "will you keep, and what will you drop?",
    hint: "Small wins count. So does deciding to stop something.",
  ),
  // Build
  PathDay(
    day: 16,
    stage: PathStage.build,
    title: 'Choose your keepers',
    prompt:
        "Which one or two actions from your experiments do you want to keep "
        "for now? Add them as quests if you like.",
    hint: "Keep the list short so it stays doable.",
  ),
  PathDay(
    day: 17,
    stage: PathStage.build,
    title: 'Shape a quest',
    prompt:
        "Rewrite one of your quests so it is clearer and smaller. What is "
        "the new version?",
    hint: "A good quest starts with a verb and fits in one sitting.",
  ),
  PathDay(
    day: 18,
    stage: PathStage.build,
    title: 'Project check-in',
    prompt:
        "Where is your month project right now? What is the next step "
        "someone could see?",
    hint: "Visible steps are easier to start than vague ones.",
  ),
  PathDay(
    day: 19,
    stage: PathStage.build,
    title: 'Protect a boundary',
    prompt:
        "Which constraint in your Compass was tested this week? How did you "
        "protect it, or how could you next time?",
    hint: "If you have not written constraints yet, today is a good day.",
  ),
  PathDay(
    day: 20,
    stage: PathStage.build,
    title: 'Shape your space',
    prompt:
        "What could you change in your room, desk or phone to make your "
        "daily levers easier?",
    hint: "Put helpful things in sight and distractions out of reach.",
  ),
  PathDay(
    day: 21,
    stage: PathStage.build,
    title: 'Plan for a low day',
    prompt:
        "Picture a day with very little energy. What is the smallest "
        "version of your quest you could still do?",
    hint: "A two-minute version still keeps the thread.",
  ),
  PathDay(
    day: 22,
    stage: PathStage.build,
    title: 'Show a piece',
    prompt:
        "Is there one part of your project you could show someone, even "
        "unfinished? How does that idea feel?",
    hint: "Showing is optional. Noticing the feeling is the exercise.",
  ),
  PathDay(
    day: 23,
    stage: PathStage.build,
    title: 'Signs of change',
    prompt:
        "What have you done in these weeks that your old routine would not "
        "have done?",
    hint: "Tiny examples count.",
  ),
  // Adjust
  PathDay(
    day: 24,
    stage: PathStage.adjust,
    title: 'Reread your Compass',
    prompt:
        "Read your Compass from top to bottom. What still feels true? What "
        "feels off now?",
    hint: "Save a Compass version before you change anything.",
  ),
  PathDay(
    day: 25,
    stage: PathStage.adjust,
    title: 'Refresh your vision',
    prompt:
        "Has your picture of a good ordinary day changed? Write one line "
        "you would add and one you would remove.",
    hint: "Visions are meant to grow with you.",
  ),
  PathDay(
    day: 26,
    stage: PathStage.adjust,
    title: 'Year goal check',
    prompt:
        "Does your one-year goal still fit what you have learned? Keep it, "
        "adjust it, or replace it.",
    hint: "Changing a goal is a normal part of steering.",
  ),
  PathDay(
    day: 27,
    stage: PathStage.adjust,
    title: 'The next project',
    prompt: "What could next month's project be, building on this one?",
    hint: "It can continue this project, or start a new one.",
  ),
  PathDay(
    day: 28,
    stage: PathStage.adjust,
    title: 'Let something go',
    prompt: "Which plan, habit or expectation are you ready to set down?",
    hint: "Letting go makes room for what matters more.",
  ),
  PathDay(
    day: 29,
    stage: PathStage.adjust,
    title: 'A kind look back',
    prompt: "What are you glad you tried this month, whatever the result?",
    hint: "Effort and curiosity count, not only outcomes.",
  ),
  PathDay(
    day: 30,
    stage: PathStage.adjust,
    title: 'The next chapter',
    prompt:
        "Write a short note to yourself for the next thirty days: what to "
        "keep, what to change and what to try.",
    hint: "You can start a new reset or save a Compass version at any time.",
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// The Playground: "Try" experiments and "Notice" cards
// ─────────────────────────────────────────────────────────────────────────────
// Experiment ids are `try.<chapter>.<nn>`, notice ids `notice.<nn>`: permanent
// (the experiment log is keyed by them). Tiny, real-world, safe, never about
// sharing personal details; one to three short steps, action first.

const List<Experiment> _experiments = [
  Experiment(
    id: 'try.terrain.01',
    chapter: CampaignChapter.terrain,
    title: 'Walk one room as a guest would',
    steps: [
      'Walk slowly through one room you use every day.',
      'Notice one thing you have stopped seeing.',
    ],
    minutes: 5,
  ),
];

const List<Notice> _notices = [
  Notice(
    id: 'notice.01',
    glyph: CarthaGlyph.notice,
    title: 'What you have learned to put up with',
    promptId: 'morning.01',
  ),
];
