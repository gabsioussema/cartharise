// French content for Cartharise — a DRAFT until a native speaker reviews it
// (docs/translations.md). Translate by permanent id; structure (order,
// phases, links, Compass mapping, correct answers) always comes from the
// English library, so only words go here. An item missing or incomplete
// here is shown in English (never half translated): `coverageFor` in
// content.dart and `make l10n`'s report say what is left.
//
// Same rules as English: paraphrase, never reproduce the source; short,
// calm, action first; no guilt, streak, score or diagnosis wording.
//
// French choices (keep them consistent, see docs/translations.md):
// * vouvoiement throughout, calm and respectful; avoid wording that genders
//   the reader ("quand vous le souhaitez", not "quand vous serez prêt");
// * typographic apostrophe (’) and « » quotes, with a no-break space
//   (U+00A0) before : ; ! ? and inside « » (test/french_test.dart checks);
// * the article's title, author and links stay as published.
import '../domain/content.dart';
import '../domain/content_translation.dart';
import 'en.dart';

/// The French translation, keyed by permanent id.
const ContentTranslation frenchTranslation = ContentTranslation(
  languageCode: 'fr',
  version: 2,
  lessons: _lessons,
  prompts: _prompts,
  thirtyDays: _thirtyDays,
  experiments: _experiments,
  notices: _notices,
  credit: _credit,
);

/// The French library: English structure, French words where translated.
final ContentLibrary frenchContent = translateContent(
  englishContent,
  frenchTranslation,
);

// ---------------------------------------------------------------------------
// Credit
// ---------------------------------------------------------------------------

const CreditText _credit = CreditText(
  publishedOn: "23 décembre 2025",
  independenceNotice:
      "Cartharise est une app indépendante. Elle n’est ni affiliée à Dan Koe, "
      "ni soutenue ou approuvée par lui.",
  paraphraseNotice:
      "Les leçons et les questions sont reformulées avec les mots de "
      "Cartharise ; l’article lui-même n’est pas reproduit ici. Lisez "
      "l’original pour tout le raisonnement de l’auteur. Le parcours de "
      "trente jours, les quêtes, le journal et les bilans de la semaine sont "
      "des ajouts de Cartharise, absents de l’article.",
);

// ---------------------------------------------------------------------------
// L’Éveil : les sept idées centrales
// ---------------------------------------------------------------------------

const Map<String, LessonText> _lessons = {
  'lesson.01': LessonText(
    title: "D’abord, qui vous êtes",
    summary:
        "Un changement durable naît souvent de la façon dont vous vous voyez, "
        "pas seulement de ce que vous essayez de faire.",
    explanation:
        "La plupart des plans commencent par des actions : faire plus de "
        "sport, écrire chaque jour, dépenser moins. L’article avance que ces "
        "actions reposent sur quelque chose de plus profond : la façon dont "
        "vous vous voyez.\n\n"
        "Quand une habitude correspond à l’image que vous avez de vous, elle "
        "paraît naturelle plutôt que forcée. Quand elle la contredit, la "
        "motivation s’éteint souvent au bout de quelques semaines et "
        "l’ancienne routine revient.\n\n"
        "L’idée est donc de partir du genre de vie, et du genre de personne, "
        "qui produirait ce résultat naturellement. Les actions ont alors "
        "quelque chose sur quoi pousser.",
    example:
        "Deux amis décident de mieux manger. L’un le vit comme un régime "
        "court à tenir. L’autre commence à se voir comme quelqu’un qui aime "
        "cuisiner des produits frais. Le second changement paraît souvent "
        "plus léger, parce qu’il correspond à la personne qu’il devient.",
    nuance:
        "C’est un regard issu du développement personnel, pas une loi de la "
        "psychologie. La santé, l’argent, le temps et le soutien comptent "
        "aussi dans ce qui est possible. Se voir autrement peut aider, mais "
        "ce n’est jamais toute l’histoire, ni une raison de se blâmer.",
    check: CheckText(
      question:
          "Selon cette leçon, pourquoi certains changements "
          "s’essoufflent-ils vite ?",
      options: [
        "Ils contredisent la façon dont la personne se voit",
        "La personne n’a tout simplement pas fait assez d’efforts",
        "Les habitudes ne peuvent jamais vraiment changer",
      ],
      explanation:
          "L’idée est qu’un changement dure plus longtemps quand il "
          "correspond à l’image que vous avez de vous. Ce n’est ni une "
          "question d’effort ni de valeur, et les habitudes peuvent changer.",
    ),
  ),
  'lesson.02': LessonText(
    title: "Vos actions ont des raisons",
    summary:
        "Les habitudes servent généralement à quelque chose, même quand ce "
        "but nous échappe.",
    explanation:
        "Pour l’article, tout ce que nous faisons vise quelque chose, même "
        "sans que nous en ayons conscience. Repousser une tâche peut être une "
        "façon d’éviter d’être jugé. Rester dans un cadre familier peut être "
        "une façon de se sentir en sécurité.\n\n"
        "Les raisons que nous nous donnons sont souvent plus nettes que les "
        "vraies. C’est très humain, et cela ne fait de personne une mauvaise "
        "personne.\n\n"
        "Un objectif fonctionne aussi un peu comme une paire de lunettes : il "
        "oriente ce que vous remarquez. Visez quelque chose de nouveau et vous "
        "commencez à voir de nouvelles occasions. C’est pourquoi un vrai "
        "changement commence par un nouveau point de vue, pas seulement par "
        "une nouvelle liste de tâches.",
    example:
        "Quelqu’un veut partager ses dessins en ligne mais ne publie jamais "
        "rien. En y regardant de plus près, ne pas publier le protège de "
        "l’avis d’inconnus. Une fois cela vu, un premier pas plus petit "
        "devient possible, comme montrer un dessin à un ami.",
    nuance:
        "C’est une façon de regarder les comportements, pas de lire dans les "
        "pensées. Cartharise ne devine jamais vos motivations cachées ; c’est "
        "à vous de vérifier si une explication vous correspond. Parfois, "
        "une habitude est simplement du repos, et c’est très bien.",
    check: CheckText(
      question:
          "Que suggère cette leçon à propos d’une habitude que vous "
          "aimeriez changer ?",
      options: [
        "Elle vous apporte sans doute quelque chose, comme du confort ou de "
            "la sécurité",
        "Elle prouve que vos objectifs ne comptent pas pour vous",
        "Elle n’a aucune cause",
      ],
      explanation:
          "La plupart des habitudes répondent à un besoin. Remarquer ce "
          "besoin, sans le juger, vous laisse plus de liberté pour choisir.",
    ),
  ),
  'lesson.03': LessonText(
    title: "Pourquoi changer peut sembler risqué",
    summary:
        "Nous protégeons l’image que nous avons de nous, alors le changement "
        "peut ressembler à une menace, même quand nous le voulons.",
    explanation:
        "L’article décrit une boucle. Nous choisissons des objectifs, "
        "remarquons ce qui s’y rapporte, agissons, recevons un retour et "
        "recommençons. Avec le temps, ce que nous répétons devient une "
        "partie de ce que nous croyons être.\n\n"
        "Une fois cette image en place, nous avons tendance à la protéger. "
        "Remettre en cause « le genre de personne que je suis » peut "
        "déclencher le même stress qu’une menace physique, même quand le "
        "changement nous ferait du bien.\n\n"
        "Une grande partie de cette boucle se forme tôt, façonnée par la "
        "famille et la culture. La remarquer est un premier pas pour choisir "
        "ce que l’on garde.",
    example:
        "Quelqu’un a toujours dit : « Les chiffres, ce n’est pas pour moi. » "
        "Quand son travail propose une courte formation au budget, une gêne "
        "monte avant même le début. C’est l’étiquette, pas la formation, qui "
        "semble en danger.",
    nuance:
        "C’est un modèle simplifié, tiré de plusieurs idées du développement "
        "personnel et de la psychologie, pas un fait établi. Toute hésitation "
        "n’est pas de l’autoprotection ; parfois, la prudence est sage. "
        "Utilisez-le comme une question à explorer, jamais comme une "
        "étiquette sur vous.",
    check: CheckText(
      question:
          "Selon cette leçon, pourquoi un changement utile peut-il "
          "quand même mettre mal à l’aise ?",
      options: [
        "Il peut bousculer la façon dont vous vous voyez",
        "Le malaise montre que ce changement n’est pas fait pour vous",
        "Seules certaines personnes ressentent une gêne face au changement",
      ],
      explanation:
          "Un changement peut toucher l’idée que vous vous faites de vous, "
          "ce qui peut gêner. Le malaise seul ne dit pas si un changement est "
          "juste ou non.",
    ),
  ),
  'lesson.04': LessonText(
    title: "Le regard peut s’élargir",
    summary:
        "Certains penseurs décrivent des façons de voir le monde qui peuvent "
        "s’élargir au fil d’une vie.",
    explanation:
        "L’article s’appuie sur des modèles du développement adulte. En gros, "
        "ils décrivent un passage : suivre les règles de son groupe, puis "
        "former ses propres valeurs, puis remarquer que ces valeurs ont été "
        "façonnées par son milieu et peuvent être tenues plus légèrement.\n\n"
        "Le point clé : ce qui paraît possible dépend en partie de la façon "
        "dont vous voyez les choses. Une question qui ouvre une porte pour "
        "l’un peut sembler étrange à l’autre, et c’est normal.\n\n"
        "À retenir en pratique : repérez les croyances adoptées sans les "
        "avoir choisies, et demandez-vous lesquelles vous voulez encore "
        "garder.",
    example:
        "Quelqu’un a grandi avec l’idée qu’un emploi de bureau stable est la "
        "seule voie raisonnable. Plus tard, cette personne remarque que "
        "c’était l’avis de sa famille et se demande ce qui compte pour elle. "
        "Elle garde peut-être son emploi, mais c’est désormais un choix.",
    nuance:
        "Ce sont des cadres de pensée, et les chercheurs en débattent. "
        "Cartharise ne vous place à aucun stade, ne mesure pas votre "
        "évolution et ne laisse jamais entendre que quelqu’un serait en "
        "avance sur un autre. Prenez seulement ce qui vous est utile.",
    check: CheckText(
      question:
          "Comment Cartharise utilise-t-il les idées sur les stades "
          "de développement ?",
      options: [
        "Comme un regard pour repérer des croyances adoptées sans les choisir",
        "Pour vous dire à quel stade vous êtes",
        "Pour classer les gens du plus bas au plus haut",
      ],
      explanation:
          "C’est proposé uniquement comme un regard pour réfléchir. L’app ne "
          "vous place jamais à un stade et ne vous compare à personne.",
    ),
  ),
  'lesson.05': LessonText(
    title: "Viser, vérifier, ajuster",
    summary:
        "On avance en visant, en agissant, en remarquant ce qui s’est passé "
        "et en ajustant, encore et encore.",
    explanation:
        "L’article décrit l’intelligence comme la capacité à avancer vers ce "
        "que l’on veut. Il emprunte une idée à la pensée systémique : choisir "
        "une cible, agir, vérifier où l’on en est, comparer et corriger le "
        "cap. Un thermostat fonctionne ainsi, tout comme un marin qui tient "
        "la barre.\n\n"
        "Vu ainsi, un revers est une information, pas un verdict. La question "
        "utile devient : « Qu’ai-je appris, et que vais-je essayer "
        "ensuite ? »\n\n"
        "L’article note aussi que beaucoup suivent un chemin tracé par "
        "défaut. Tenir la barre, c’est choisir sa propre cible, même petite, "
        "et la mettre à l’épreuve.",
    example:
        "Quelqu’un veut plus d’énergie. Cette personne essaie de se coucher "
        "plus tôt pendant une semaine, remarque qu’elle se réveille toujours "
        "fatiguée, puis essaie plutôt d’arrêter le café après le déjeuner. "
        "Chaque essai lui apprend quelque chose.",
    nuance:
        "Une boucle de rétroaction est une métaphore utile, pas une théorie "
        "complète de l’être humain. La chance, le soutien et la santé "
        "comptent aussi, et chaque objectif n’a pas le même rythme. Changer "
        "d’objectif fait partie du chemin, ce n’est pas abandonner.",
    check: CheckText(
      question:
          "Dans une boucle de rétroaction, quelle réponse est utile "
          "quand quelque chose ne marche pas ?",
      options: [
        "Remarquer ce qui s’est passé et ajuster le prochain essai",
        "Arrêter, puisque cela prouve que l’objectif était mauvais",
        "Continuer exactement de la même façon",
      ],
      explanation:
          "Chaque essai vous donne une information. Les petits ajustements "
          "sont ce qui fait avancer la boucle.",
    ),
  ),
  'lesson.06': LessonText(
    title: "Une journée hors du pilote automatique",
    summary:
        "Le recentrage, c’est une journée de questions : un regard intérieur "
        "le matin, de courtes pauses dans la journée et un bilan le soir.",
    explanation:
        "L’article suggère que le changement passe souvent par trois "
        "phases : le sentiment grandissant que quelque chose ne va pas, une "
        "période où l’on ne sait pas ce qui vient, puis une direction plus "
        "claire.\n\n"
        "Le recentrage est conçu pour traverser ces phases exprès. Le matin, "
        "vous regardez honnêtement votre présent et deux futurs possibles. "
        "Dans la journée, de courtes pauses interrompent le pilote "
        "automatique. Le soir, vous rassemblez ce que vous avez remarqué en "
        "une direction.\n\n"
        "L’article recommande d’écrire à la main et de penser par vous-même "
        "plutôt que de laisser un outil répondre à votre place. Dans "
        "Cartharise, vous pouvez y consacrer une journée ou aller à votre "
        "rythme ; rien n’est verrouillé par le temps.",
    example:
        "Quelqu’un réserve un samedi tranquille. Les questions du matin "
        "accompagnent le petit-déjeuner, une pause se glisse entre deux "
        "courses, et les réponses du soir s’écrivent avant de dormir. Une "
        "autre personne étale les mêmes questions sur une semaine.",
    nuance:
        "Une journée peut apporter de la clarté ; elle ne peut pas promettre "
        "une vie transformée. Les questions peuvent remuer des émotions "
        "fortes : passez, adoucissez ou faites une pause dès que vous en avez "
        "besoin. Cartharise n’est pas une thérapie. Si c’est difficile, "
        "tournez-vous vers un professionnel ou une personne de confiance.",
    check: CheckText(
      question: "À quoi sert la partie du soir du recentrage ?",
      options: [
        "Rassembler ce que la journée a appris en une direction",
        "Noter la réussite de la journée",
        "Commencer une nouvelle liste de plaintes",
      ],
      explanation:
          "Le soir transforme ce que vous avez remarqué en quelques phrases "
          "de direction et en petits pas. Rien n’est noté.",
    ),
  ),
  'lesson.07': LessonText(
    title: "Votre direction comme un jeu",
    summary:
        "Six parties transforment vos réponses en un plan qui fonctionne un "
        "peu comme un jeu, avec un enjeu, un but, des missions, des quêtes et "
        "des règles.",
    explanation:
        "Les jeux retiennent notre attention parce qu’ils offrent des buts "
        "clairs, des retours rapides et des défis à notre mesure. L’article "
        "reprend cette idée pour organiser un plan de vie en six parties.\n\n"
        "L’anti-vision montre l’enjeu. La vision décrit la victoire, pour "
        "l’instant. L’objectif d’un an est la mission principale. Le projet "
        "du mois est le grand défi où vous développez des compétences. Les "
        "leviers quotidiens sont de petites quêtes qui font avancer le "
        "projet. Les limites sont les règles que vous respectez, comme "
        "protéger votre sommeil ou le temps en famille.\n\n"
        "Ces objectifs servent à faire le point plutôt qu’à marquer une "
        "ligne d’arrivée. Vous pouvez les changer à mesure que vous "
        "apprenez.",
    example:
        "L’objectif d’un an de quelqu’un : courir 10 km. Le projet du mois : "
        "un programme de course pour débuter. Le levier du jour : 20 minutes "
        "de course. Une limite : l’entraînement ne remplace jamais le dîner "
        "en famille.",
    nuance:
        "L’idée du jeu est une métaphore pour alléger la planification. Le "
        "plan ne vous note pas, et vos progrès ici ne mesurent jamais votre "
        "valeur. Votre Boussole se modifie librement, et les limites ne sont "
        "jamais écrites que par vous.",
    check: CheckText(
      question: "Dans le plan en six parties, que sont les limites ?",
      options: [
        "Des bornes que vous choisissez pour que le plan ne coûte jamais "
            "l’essentiel",
        "Des tâches à accomplir absolument chaque jour",
        "Une note qui montre si vous faites bien",
      ],
      explanation:
          "Les limites sont des bornes que vous posez vous-même, comme "
          "protéger le sommeil ou vos relations. Cartharise ne les remplit "
          "jamais à votre place.",
    ),
  ),
};

// ---------------------------------------------------------------------------
// Questions du recentrage : 14 matin · 6 journée · 3 bonus · 7 soir
// ---------------------------------------------------------------------------

const Map<String, PromptText> _prompts = {
  // ── Matin 01–04 · réalité actuelle (Le Miroir) ──────────────────────────
  'morning.01': PromptText(
    title: "L’insatisfaction tranquille",
    question:
        "Quel inconfort sourd et constant avez-vous pris l’habitude de vivre "
        "au quotidien ?",
    softerQuestion:
        "Y a-t-il une petite chose dans vos journées qui vous gêne depuis un "
        "moment ?",
    context:
        "On commence par le présent. Pas les grandes crises, juste le malaise "
        "de fond que vous avez appris à supporter.",
    help:
        "Pensez à quelque chose qui n’est pas terrible, seulement un peu de "
        "travers, et qui dure depuis des mois. Parce que c’est supportable, "
        "on cesse facilement de le remarquer. Le nommer est un premier pas "
        "pour voir clairement votre situation. Quelques mots suffisent.",
    example:
        "Quelqu’un pourrait écrire : « La plupart des soirs, je suis agité "
        "et je fais défiler mon téléphone jusque tard, alors que je suis "
        "épuisé. »",
  ),
  'morning.02': PromptText(
    title: "Les plaintes qui reviennent",
    question:
        "De quoi vous plaignez-vous sans rien changer ? Essayez de noter les "
        "deux ou trois plaintes que vous avez le plus répétées cette année.",
    softerQuestion:
        "Quels sujets reviennent sans cesse quand vous parlez de votre vie ?",
    context:
        "Les plaintes qui reviennent sont des indices précieux. Elles "
        "désignent ce qui compte pour vous mais n’a pas encore bougé.",
    help:
        "Pensez à ce que vous dites à vos amis, à votre famille ou à "
        "vous-même. Vous ne jugez ni la plainte ni vous-même, vous la notez "
        "seulement. Laissez de côté ce que vous avez déjà changé.",
    example:
        "Quelqu’un pourrait écrire : « Mon trajet est trop long. Je n’ai "
        "jamais le temps de peindre. Les réunions d’équipe tournent en "
        "rond. »",
  ),
  'morning.03': PromptText(
    title: "Ce que disent vos actions",
    question:
        "Regardez chaque plainte. Si quelqu’un voyait seulement ce que vous "
        "faites, sans entendre ce que vous dites, que devinerait-il de ce "
        "que vous voulez ?",
    softerQuestion:
        "Pour une de ces plaintes, que protègent peut-être en silence vos "
        "choix de tous les jours ?",
    context:
        "Nos comportements suivent souvent des buts jamais dits à voix "
        "haute. Cette question regarde l’écart entre ce que vous voulez "
        "faire et ce que vous faites.",
    help:
        "Il ne s’agit pas de vous prendre en faute. La plupart des habitudes "
        "vous apportent quelque chose : confort, repos, sécurité ou "
        "approbation. Écrivez ce qu’un observateur extérieur pourrait "
        "deviner, puis voyez si cela vous correspond. Vous avez le droit "
        "de ne pas être d’accord.",
    example:
        "Quelqu’un pourrait écrire : « Je dis vouloir me remettre en forme, "
        "mais un observateur me verrait choisir le canapé après le travail. "
        "J’ai peut-être plus besoin de récupérer que de m’entraîner en ce "
        "moment. »",
  ),
  'morning.04': PromptText(
    title: "La vérité difficile à dire",
    question:
        "Qu’y a-t-il de vrai dans votre vie en ce moment que vous auriez du "
        "mal à confier à une personne que vous admirez ?",
    softerQuestion:
        "Quelle chose honnête sur votre vie dites-vous rarement à voix "
        "haute ?",
    context:
        "Certains faits sont plus faciles à laisser dans le flou. En écrire "
        "un, en privé, peut lui enlever un peu de son poids.",
    help:
        "Votre réponse reste sur ce téléphone. Vous n’avez à la montrer à "
        "personne ni à agir aujourd’hui. Si c’est trop, passez à la version "
        "plus douce, ou passez la question et revenez-y plus tard.",
    example:
        "Quelqu’un pourrait écrire : « Cela fait trois ans que je dis “le "
        "mois prochain” à propos de lancer ma propre activité. »",
  ),

  // ── Matin 05–08 · anti-vision (Le Miroir) ───────────────────────────────
  'morning.05': PromptText(
    title: "Cinq ans, sans changement",
    question:
        "Imaginez que vos habitudes restent exactement les mêmes pendant "
        "cinq ans. Décrivez un jour de semaine ordinaire : où vous vous "
        "réveillez, comment va votre corps, qui vous entoure, comment se "
        "termine la soirée.",
    softerQuestion:
        "Imaginez une journée normale dans cinq ans si tout continue comme "
        "aujourd’hui. Que remarquez-vous ?",
    context:
        "C’est un futur possible, pas une prédiction. Voir où le chemin "
        "d’aujourd’hui pourrait mener peut éclairer le choix qui se présente "
        "à vous.",
    help:
        "Ajoutez de petits détails, comme une scène de film : le matin, les "
        "heures de travail, le soir. Ce tableau fait partie d’une "
        "anti-vision, un futur que vous préféreriez éviter. C’est un outil "
        "de clarté, pas une prévision. Arrêtez-vous dès que vous en avez "
        "besoin.",
    example:
        "Quelqu’un pourrait écrire : « Je me réveille fatigué dans le même "
        "appartement, je lis mes messages de travail au lit et je passe la "
        "soirée sur mon téléphone avec l’impression d’avoir voulu faire "
        "plus. »",
  ),
  'morning.06': PromptText(
    title: "Dix ans, sans changement",
    question:
        "Prolongez ce tableau sur dix ans. Quelles occasions auraient pu "
        "passer, et comment d’autres pourraient-ils décrire votre vie ?",
    softerQuestion:
        "Si les choses restaient à peu près les mêmes pendant dix ans, "
        "qu’aimeriez-vous avoir essayé ?",
    context:
        "Un regard plus long montre ce qui s’accumule lentement. Là encore, "
        "c’est une possibilité à regarder, pas quelque chose qui va arriver.",
    help:
        "Pensez aux occasions, aux relations, à la santé et au travail. "
        "Restez honnête, avec bienveillance envers vous-même. Vous décrivez un "
        "chemin, pas votre valeur en tant que personne.",
    example:
        "Quelqu’un pourrait écrire : « Je parlerais peut-être encore "
        "d’apprendre le piano, et ma famille se souviendrait de moi comme de "
        "quelqu’un de toujours occupé. »",
  ),
  'morning.07': PromptText(
    title: "Le regard d’une vie plus tard",
    question:
        "Imaginez-vous à un âge avancé, en train de regarder une vie où vous "
        "avez toujours choisi la sécurité. Qu’est-ce que cela a coûté, et "
        "qu’est-ce qui est resté sans être tenté ?",
    softerQuestion:
        "Plus tard dans votre vie, qu’est-ce qui vous attristerait d’avoir "
        "laissé passer ?",
    context:
        "Regarder depuis le bout de la vie aide à séparer ce qui compte de "
        "ce qui semble seulement urgent. C’est une expérience de pensée, pas "
        "un verdict.",
    help:
        "Certaines personnes trouvent cette question lourde. Gardez une "
        "réponse courte si vous voulez, prenez la version plus douce, ou "
        "passez-la. Le but est de remarquer ce qui compte pour vous, pas de "
        "vous sentir mal.",
    example:
        "Quelqu’un pourrait écrire : « Je n’ai jamais montré mes textes, "
        "jamais vécu à l’étranger, et pas assez pris le temps avec ma "
        "sœur. »",
  ),
  'morning.08': PromptText(
    title: "Les chemins autour de vous",
    question:
        "Connaissez-vous quelqu’un qui semble avoir quelques années d’avance "
        "sur une route comme celle que vous venez d’imaginer ? Que "
        "ressentez-vous en imaginant votre vie prendre le même chemin ?",
    softerQuestion:
        "Sans juger personne, quel parcours vous montre une direction que "
        "vous préféreriez ne pas prendre ? Qu’est-ce que cela vous apprend ?",
    context:
        "La vie des autres peut rendre une direction plus concrète. Il "
        "s’agit de vos propres choix, pas de juger qui que ce soit.",
    help:
        "Inutile de nommer qui que ce soit. Chaque vie a des raisons "
        "invisibles de l’extérieur. Concentrez-vous sur ce que cela éveille "
        "en vous et sur ce que cela dit de ce que vous voulez.",
    example:
        "Quelqu’un pourrait écrire : « Un collègue plus âgé dit souvent "
        "qu’il aurait aimé changer de métier il y a des années. M’imaginer "
        "dire cela me donne envie d’explorer maintenant. »",
  ),

  // ── Matin 09–11 · identité (Le Miroir) ──────────────────────────────────
  'morning.09': PromptText(
    title: "Un rôle devenu trop étroit",
    question:
        "Quelle façon de vous voir auriez-vous besoin d’assouplir pour "
        "changer ? Essayez de compléter : « Je suis le genre de personne "
        "qui… » Que pourrait vous coûter, auprès des autres, le fait de la "
        "lâcher ?",
    softerQuestion:
        "Y a-t-il une étiquette que vous vous donnez souvent et qui vous "
        "maintient peut-être sur place ?",
    context:
        "Nous portons tous des étiquettes sur qui nous sommes. Certaines "
        "nous aident ; d’autres nous retiennent sans bruit.",
    help:
        "Voyez votre réponse comme une hypothèse à tester, pas comme un fait "
        "sur vous. Un rôle peut être « la personne fiable », « pas du genre "
        "créatif » ou « celle qui ne fait jamais d’histoires ». Remarquez "
        "aussi ce que ce rôle vous apporte.",
    example:
        "Quelqu’un pourrait écrire : « Je suis le genre de personne qui ne "
        "demande jamais d’aide. Si je changeais, j’aurais peur que les "
        "autres me trouvent moins capable. »",
  ),
  'morning.10': PromptText(
    title: "La raison difficile à avouer",
    question:
        "Quelle raison de ne pas changer est la plus gênante à admettre, "
        "même à vous-même ?",
    softerQuestion:
        "Quelle inquiétude explique peut-être en partie pourquoi changer a "
        "semblé difficile ?",
    context:
        "Les raisons que nous donnons aux autres sont souvent nettes. Les "
        "vraies sont plus humaines, comme la peur d’avoir l’air ridicule.",
    help:
        "C’est une hypothèse, pas un jugement sur votre caractère. Les "
        "réponses fréquentes parlent de la peur d’être jugé, de s’investir "
        "sans y arriver, ou de décevoir quelqu’un. Accueillez avec douceur ce "
        "qui remonte.",
    example:
        "Quelqu’un pourrait écrire : « Si j’essaie vraiment et que ça ne "
        "marche pas, je ne pourrai plus me dire que c’était seulement un "
        "manque de temps. »",
  ),
  'morning.11': PromptText(
    title: "Ce que protègent vos habitudes",
    question:
        "Si une partie de votre routine sert à vous protéger, que "
        "protège-t-elle ? Et quel prix payez-vous pour cette sécurité ?",
    softerQuestion:
        "De quoi vos habitudes essaient-elles peut-être de vous protéger, "
        "ou de vous garder à l’abri ?",
    context:
        "Beaucoup d’habitudes ont commencé comme des façons sensées de faire "
        "face. Voir ce qu’elles protègent rend le changement moins proche "
        "d’un combat.",
    help:
        "On protège souvent sa fierté, un sentiment d’appartenance, son "
        "énergie ou le confort du connu. Ce que vous écrivez est une "
        "explication possible à tester, pas une conclusion sur vous.",
    example:
        "Quelqu’un pourrait écrire : « Rester très occupé m’empêche "
        "peut-être de voir que je me sens seul. Cela me coûte du repos et de "
        "vraies conversations. »",
  ),

  // ── Matin 12–14 · vision (La Vision) ────────────────────────────────────
  'morning.12': PromptText(
    title: "Une bonne journée, dans trois ans",
    question:
        "Mettez un instant de côté les limites pratiques. Si vous viviez la "
        "vie que vous voulez vraiment dans trois ans, à quoi ressemblerait "
        "un jour de semaine ordinaire ?",
    softerQuestion:
        "À quoi ressemblerait pour vous une bonne journée ordinaire, dans "
        "quelques années ?",
    context:
        "Tournons-nous maintenant vers ce que vous voulez. Les journées "
        "ordinaires comptent, car c’est là que se passe l’essentiel de la "
        "vie.",
    help:
        "Gardez le même niveau de détail que pour le tableau à cinq ans : le "
        "matin, le travail, les gens, le corps, le soir. Décrivez ce que "
        "vous voulez, pas ce que vous pensez devoir vouloir. Vous pourrez le "
        "changer à tout moment.",
    example:
        "Quelqu’un pourrait écrire : « Je me réveille sans réveil, j’écris "
        "pendant une heure, je travaille sur des projets choisis et je "
        "cuisine avec des amis deux fois par semaine. »",
  ),
  'morning.13': PromptText(
    title: "La personne que vous devenez",
    question:
        "Pour que cette journée paraisse naturelle plutôt que forcée, que "
        "faudrait-il croire sur vous-même ? Écrivez-le comme une phrase "
        "ouverte : « Je deviens quelqu’un qui… »",
    softerQuestion:
        "Quelle croyance sur vous-même rendrait cette journée plus facile à "
        "vivre ?",
    context:
        "Le changement dure quand il correspond à la façon dont vous vous "
        "voyez. Cette phrase est une direction à essayer, pas l’affirmation "
        "que c’est déjà vrai.",
    help:
        "Gardez-la ouverte et bienveillante, par exemple « Je deviens "
        "quelqu’un qui prend soin de son énergie ». Ce sont vos mots, et "
        "vous pourrez les modifier plus tard. Cartharise ne les traite "
        "jamais comme un fait sur vous.",
    example:
        "Quelqu’un pourrait écrire : « Je deviens quelqu’un qui crée des "
        "choses et les partage, même quand elles ne sont pas parfaites. »",
  ),
  'morning.14': PromptText(
    title: "Un pas cette semaine",
    question:
        "Choisissez une petite action pour les sept jours à venir, à "
        "l’image de la personne que vous avez décrite. Laquelle ?",
    softerQuestion:
        "Quel pas facile cette semaine irait vers la journée que vous avez "
        "imaginée ?",
    context:
        "Un petit pas concret transforme une vision en quelque chose que "
        "vous pouvez tester dans la vie de tous les jours.",
    help:
        "Rendez-le précis et faisable même un jour de fatigue : un moment, "
        "un lieu, un premier geste. Petit, c’est très bien. Les grands plans "
        "peuvent attendre.",
    example:
        "Quelqu’un pourrait écrire : « Samedi matin, dessiner 20 minutes à "
        "la table de la cuisine avant de regarder mon téléphone. »",
  ),

  // ── Journée 01–06 · interruption (L’Interruption) ───────────────────────
  'daytime.01': PromptText(
    title: "Ce que vous évitez",
    question:
        "Faites une courte pause. Ce que vous faites en ce moment est-il une "
        "façon de repousser autre chose ? Si oui, quoi ?",
    softerQuestion:
        "Y a-t-il quelque chose que vous laissez pour plus tard aujourd’hui ?",
    context:
        "Les pauses de la journée cassent le pilote automatique. Elles sont "
        "rapides : une phrase ou deux suffisent largement.",
    help:
        "Éviter est normal et a souvent du sens. Le but est de le remarquer, "
        "pas de tout lâcher pour s’en occuper. « Rien pour l’instant » est "
        "aussi une bonne réponse.",
    example:
        "Quelqu’un pourrait écrire : « Je trie mes e-mails au lieu de "
        "commencer le rapport difficile. »",
  ),
  'daytime.02': PromptText(
    title: "Les priorités en actes",
    question:
        "Repensez aux deux dernières heures. À en juger par vos seuls actes, "
        "qu’est-ce qui compte le plus pour vous aux yeux d’un observateur ?",
    softerQuestion:
        "Qu’ont montré les deux dernières heures de ce dont vous aviez "
        "besoin ?",
    context:
        "Nos actes montrent nos vraies priorités du moment. C’est une "
        "information, pas une note.",
    help:
        "Décrivez ce que vous avez fait, puis devinez la priorité derrière : "
        "repos, lien, argent, approbation, éviter le stress. Toute réponse "
        "est utile.",
    example:
        "Quelqu’un pourrait écrire : « Surtout des messages et de petites "
        "tâches. On devinerait que je veux être disponible pour tout le "
        "monde. »",
  ),
  'daytime.03': PromptText(
    title: "Quelle direction ?",
    question:
        "Les choix d’aujourd’hui vous mènent-ils vers le futur que vous "
        "voulez éviter, ou vers celui que vous espérez ?",
    softerQuestion:
        "Quelle chose, aujourd’hui, est allée vers la vie que vous voulez ?",
    context:
        "Cette question relie vos images du matin au milieu d’une journée "
        "ordinaire.",
    help:
        "Pas besoin d’une grande réponse. C’est souvent un mélange. Si vous "
        "le pouvez, nommez un choix dans chaque direction.",
    example:
        "Quelqu’un pourrait écrire : « Un mélange. Travailler pendant le "
        "déjeuner, c’était l’ancien chemin ; la petite marche d’après, le "
        "nouveau. »",
  ),
  'daytime.04': PromptText(
    title: "Mis de côté, mais important",
    question:
        "Qu’est-ce qui compte pour vous, mais que vous traitez comme si ce "
        "n’était pas le cas ?",
    softerQuestion:
        "Y a-t-il une chose qui vous tient à cœur et qui a eu peu de place "
        "ces derniers temps ?",
    context:
        "Ce qui est important sans faire de bruit, comme la santé, les "
        "proches ou la création, se laisse facilement repousser.",
    help:
        "Avec curiosité, sans sévérité. Mettre quelque chose de côté est souvent "
        "signe de fatigue ou d’un emploi du temps chargé, pas d’un manque "
        "d’intérêt.",
    example:
        "Quelqu’un pourrait écrire : « Appeler mon père. Je répète que je "
        "suis trop occupé, mais il me manque. »",
  ),
  'daytime.05': PromptText(
    title: "Image ou envie ?",
    question:
        "Qu’avez-vous fait aujourd’hui surtout pour entretenir une image de "
        "vous, plutôt que par envie ?",
    softerQuestion:
        "Y a-t-il eu un moment aujourd’hui où vous avez fait quelque chose "
        "juste parce que vous le faites toujours ?",
    context:
        "Certains actes viennent de ce que nous voulons ; d’autres de "
        "l’habitude ou de la façon dont nous aimons être vus. Les deux sont "
        "humains.",
    help:
        "Cherchez de petits moments : accepter quelque chose, vous taire, "
        "dire oui par habitude. Notez-les sans vous le reprocher.",
    example:
        "Quelqu’un pourrait écrire : « Je suis resté tard pour avoir l’air "
        "impliqué, pas parce que le travail le demandait. »",
  ),
  'daytime.06': PromptText(
    title: "L’élan ou le creux",
    question:
        "Quel moment d’aujourd’hui vous a semblé le plus éveillé, le plus "
        "vivant ? Et lequel le plus terne ou épuisant ?",
    context:
        "Votre énergie est un signal discret sur ce qui vous convient et ce "
        "qui ne vous convient pas.",
    help:
        "Nommez deux moments, un haut et un bas. Remarquez avec qui vous "
        "étiez et ce que vous faisiez. Des tendances apparaissent sur "
        "plusieurs jours.",
    example:
        "Quelqu’un pourrait écrire : « Le plus vivant : résoudre un problème "
        "avec une collègue. Le plus éteint : l’heure à faire défiler mon "
        "téléphone après le dîner. »",
  ),

  // ── Bonus 01–03 · contemplation (facultatif) ────────────────────────────
  'bonus.01': PromptText(
    title: "Le regard des autres",
    question:
        "Repensez à l’étiquette dont vous avez parlé ce matin. Que "
        "changerait-il si vous n’aviez plus besoin que les autres vous "
        "voient ainsi ?",
    softerQuestion:
        "Quelle opinion sur vous compte le plus en ce moment, et pourquoi ?",
    context:
        "Facultatif, pour une marche, un trajet ou un moment calme. Cela ne "
        "compte pas pour terminer votre recentrage.",
    help:
        "Cette question prolonge celle du matin sur un rôle devenu trop "
        "étroit (« Je suis le genre de personne qui… »). Imaginez la liberté "
        "et l’inconfort de lâcher cette étiquette. Si vous avez passé cette "
        "question, pensez à n’importe quelle étiquette que vous portez.",
    example:
        "Quelqu’un pourrait écrire : « Si je n’avais plus besoin d’être vu "
        "comme la personne calme, je pourrais dire quand je suis débordé. »",
  ),
  'bonus.02': PromptText(
    title: "La sécurité ou l’élan",
    question:
        "Dans quels domaines de votre vie choisissez-vous peut-être le "
        "confort et la sécurité plutôt que ce qui vous fait vous sentir en "
        "vie ?",
    softerQuestion:
        "Y a-t-il un domaine de votre vie où jouer la sécurité ne vous "
        "semble plus tout à fait juste ?",
    context:
        "Facultatif. La sécurité a une vraie valeur ; cette question demande "
        "seulement si l’échange vous convient encore.",
    help:
        "Regardez le travail, les relations, la santé et la créativité. "
        "Parfois, le choix prudent est le bon. Vous remarquez seulement, "
        "vous ne décidez pas.",
    example:
        "Quelqu’un pourrait écrire : « Je cuisine toujours les cinq mêmes "
        "recettes. C’est un détail, mais cela montre comme je m’en tiens à "
        "ce que je connais. »",
  ),
  'bonus.03': PromptText(
    title: "Une version minuscule demain",
    question:
        "Demain, quelle est la plus petite façon d’agir comme la personne "
        "que vous espérez devenir ?",
    context:
        "Facultatif. Une version minuscule est plus facile à commencer qu’un "
        "grand plan.",
    help: "Pensez en minutes, pas en mois : un message, une page, une marche.",
    example:
        "Quelqu’un pourrait écrire : « Écrire trois phrases de mon histoire "
        "avant le travail. »",
  ),

  // ── Soir 01–02 · prises de conscience (La Percée) ───────────────────────
  'evening.01': PromptText(
    title: "Ce qui m’a bloqué",
    question:
        "Après tout ce que vous avez remarqué aujourd’hui, quelle est votre "
        "meilleure explication actuelle de ce qui vous a bloqué ?",
    softerQuestion: "Qu’avez-vous appris aujourd’hui sur ce qui vous retient ?",
    context:
        "Le soir sert à rassembler la journée. Une hypothèse de travail "
        "suffit ; pas besoin de certitude.",
    help:
        "Relisez vos réponses du matin et de la journée si vous voulez. "
        "Écrivez votre hypothèse en quelques phrases. Elle pourra changer à "
        "mesure que vous en apprenez plus.",
    example:
        "Quelqu’un pourrait écrire : « J’attends toujours de me sentir prêt, "
        "et je remplis mon temps pour ne jamais avoir à vérifier. »",
  ),
  'evening.02': PromptText(
    title: "Le schéma intérieur",
    question:
        "En laissant de côté les circonstances et les autres, quel schéma "
        "ou quelle croyance intérieure semble mener la danse ?",
    softerQuestion:
        "Quelle pensée ou quelle habitude d’esprit revient encore et "
        "encore ?",
    context:
        "Les choses extérieures comptent aussi. Cette question regarde "
        "seulement la part sur laquelle vous pouvez agir de l’intérieur.",
    help:
        "Nommez-le simplement, par exemple « je dois être sûr avant de "
        "commencer » ou « le repos se mérite ». Voyez-le comme une hypothèse "
        "à tester, pas un jugement sur qui vous êtes.",
    example:
        "Quelqu’un pourrait écrire : « Croire que mes idées ne sont pas "
        "encore assez bonnes pour être montrées. »",
  ),

  // ── Soir 03–04 · direction (La Percée → Boussole) ───────────────────────
  'evening.03': PromptText(
    title: "L’anti-vision en une ligne",
    question: "En une phrase, que ne voulez-vous pas que votre vie devienne ?",
    softerQuestion:
        "En une phrase, de quelle direction aimeriez-vous vous éloigner ?",
    context:
        "Cette phrase rassemble vos images du matin en un court rappel vers "
        "lequel revenir.",
    help:
        "Rendez-la personnelle et assez claire pour qu’elle ait du sens à la "
        "relecture. Elle décrit un futur possible à éviter, pas une "
        "prédiction. Vous pourrez ensuite l’ajouter à votre Boussole de vie "
        "comme anti-vision.",
    example:
        "Quelqu’un pourrait écrire : « Des années occupées et fatiguées, à "
        "toujours vouloir commencer ce qui compte pour moi. »",
  ),
  'evening.04': PromptText(
    title: "La vision en une ligne",
    question:
        "En une phrase, quelle vie commencez-vous à construire ? Elle peut "
        "changer plus tard.",
    context:
        "Une première version simple de votre vision suffit. Elle devient "
        "plus claire avec l’expérience.",
    help:
        "Voyez-la comme un premier jet. Concentrez-vous sur la façon dont "
        "vous voulez vivre, pas sur ce que vous voulez posséder. Vous "
        "pourrez ensuite l’ajouter à votre Boussole de vie comme vision.",
    example:
        "Quelqu’un pourrait écrire : « Une vie calme et en bonne santé, où "
        "je fais de la musique et où j’ai du temps pour les gens que "
        "j’aime. »",
  ),

  // ── Soir 05–07 · plan (La Percée → Boussole) ────────────────────────────
  'evening.05': PromptText(
    title: "Dans un an",
    question:
        "Dans un an, quel changement concret vous montrerait que l’ancien "
        "schéma s’est desserré ?",
    context:
        "Ici, les objectifs fonctionnent comme des lentilles : une façon "
        "d’orienter les choix du jour, pas une ligne d’arrivée pour vous "
        "juger.",
    help:
        "Choisissez quelque chose d’observable : une habitude tenue, un "
        "projet partagé, une conversation qui a eu lieu. Restez réaliste, "
        "avec égard pour votre santé, votre argent et vos relations. "
        "Cela peut devenir la mission d’un an de votre Boussole.",
    example:
        "Quelqu’un pourrait écrire : « J’ai terminé et partagé une petite "
        "collection de mes photos. »",
  ),
  'evening.06': PromptText(
    title: "Dans un mois",
    question:
        "Que pourriez-vous construire, apprendre ou mettre en place le mois "
        "prochain pour garder ce changement d’un an à portée de main ?",
    context:
        "Un mois est assez long pour créer quelque chose de réel et assez "
        "court pour rester concentré.",
    help:
        "Pensez à un projet avec une fin claire : une compétence à "
        "pratiquer, un brouillon à terminer, une routine à essayer. Cela "
        "peut devenir le projet du mois de votre Boussole.",
    example:
        "Quelqu’un pourrait écrire : « Suivre un cours de retouche photo "
        "pour débuter et choisir mes 20 meilleures photos. »",
  ),
  'evening.07': PromptText(
    title: "Les actions de demain",
    question:
        "Listez deux ou trois petites actions à prévoir demain, dans la "
        "direction que vous avez choisie. Mettez-en une par ligne.",
    context:
        "Les petites actions quotidiennes font avancer le projet du mois. "
        "Cartharise peut transformer ces lignes en brouillons de quêtes, "
        "à valider par vous.",
    help:
        "Gardez chaque action courte, concrète et faisable en moins d’une "
        "heure. Une action par ligne permet de les transformer facilement "
        "en quêtes plus tard. Vous pouvez les modifier à tout moment.",
    example:
        "Quelqu’un pourrait écrire :\n"
        "Retoucher cinq photos pendant 30 minutes\n"
        "Demander l’avis de Sam\n"
        "Marcher après le déjeuner",
  ),
};

// ---------------------------------------------------------------------------
// Parcours de trente jours (ajout de Cartharise, absent de l’article)
// Observer 1–7 · Expérimenter 8–15 · Construire 16–23 · Ajuster 24–30
// ---------------------------------------------------------------------------

const Map<int, PathDayText> _thirtyDays = {
  // Observer
  1: PathDayText(
    title: "Votre première heure",
    prompt:
        "Comment s’est passée la première heure de la journée ? Décrivez-la "
        "comme si vous l’observiez, sans la juger.",
    hint:
        "D’abord les faits : ce que vous avez fait, puis ce que vous avez "
        "ressenti.",
  ),
  2: PathDayText(
    title: "L’énergie qui monte, qui descend",
    prompt:
        "Nommez un moment qui vous a donné de l’énergie aujourd’hui, et un "
        "qui vous en a pris.",
    hint: "Votre pause de 21 h du recentrage peut aider à comparer.",
  ),
  3: PathDayText(
    title: "Où est passé le temps",
    prompt:
        "En gros, où est passé votre temps libre aujourd’hui ? Dans quelle "
        "mesure cela rejoint-il la vision de votre Boussole ?",
    hint: "Une estimation suffit. Ce n’est pas une feuille de temps.",
  ),
  4: PathDayText(
    title: "Une plainte, revue",
    prompt:
        "Choisissez une plainte de votre recentrage. Est-elle revenue "
        "aujourd’hui ? Que s’est-il passé juste avant ?",
    hint: "Repérer le déclencheur est souvent plus utile que la plainte.",
  ),
  5: PathDayText(
    title: "Les autres et l’énergie",
    prompt:
        "Avec qui avez-vous passé du temps aujourd’hui, et comment "
        "vous sentiez-vous après ?",
    hint:
        "Pas besoin d’écrire de noms. Des initiales ou des rôles "
        "suffisent.",
  ),
  6: PathDayText(
    title: "Les petits reports",
    prompt:
        "Qu’avez-vous repoussé aujourd’hui ? Quel sentiment est venu juste "
        "avant ?",
    hint: "L’ennui, l’inquiétude et la fatigue sont des réponses courantes.",
  ),
  7: PathDayText(
    title: "Une semaine à remarquer",
    prompt:
        "En repensant aux sept derniers jours, quelle tendance ressort le "
        "plus ?",
    hint: "Une seule suffit. Gardez-la pour l’étape suivante.",
  ),
  // Expérimenter
  8: PathDayText(
    title: "Un petit changement",
    prompt:
        "Choisissez un petit changement à essayer ces prochains jours, lié "
        "à vos leviers quotidiens. Lequel, et quand le ferez-vous ?",
    hint: "Assez petit pour être fait un jour de fatigue.",
  ),
  9: PathDayText(
    title: "Premier essai",
    prompt:
        "Avez-vous essayé votre changement, ou presque ? Que s’est-il passé, "
        "et qu’est-ce qui a gêné ?",
    hint: "Les deux réponses vous apprennent quelque chose.",
  ),
  10: PathDayText(
    title: "Rendre plus facile",
    prompt:
        "Comment rendre votre action plus facile à commencer ? Pensez à "
        "moins d’étapes, à un meilleur moment, ou à tout préparer à "
        "l’avance.",
    hint: "Baissez l’effort avant de monter l’ambition.",
  ),
  11: PathDayText(
    title: "Autrement",
    prompt:
        "Prenez une habitude automatique et faites-la autrement une fois "
        "aujourd’hui. Qu’avez-vous remarqué ?",
    hint:
        "Un autre trajet, un autre ordre, une autre réponse. En toute "
        "légèreté.",
  ),
  12: PathDayText(
    title: "Demander un avis",
    prompt:
        "Qui pourrait vous donner un retour utile ou de l’aide pour votre "
        "projet du mois ? Que lui demanderiez-vous ?",
    hint: "Demander est facultatif. Écrire la question aide déjà.",
  ),
  13: PathDayText(
    title: "Tester une croyance",
    prompt:
        "Repensez au schéma intérieur nommé le soir. Quelle petite action "
        "aujourd’hui pourrait vérifier s’il est vraiment vrai ?",
    hint: "Prenez le résultat comme une information, quel qu’il soit.",
  ),
  14: PathDayText(
    title: "Se reposer exprès",
    prompt:
        "Quel repos avez-vous pris aujourd’hui ? Vous a-t-il ressourcé, ou "
        "juste fait passer le temps ?",
    hint:
        "Le repos fait partie du plan, ce n’est pas une pause hors du "
        "plan.",
  ),
  15: PathDayText(
    title: "Ce qui a un peu marché",
    prompt:
        "Parmi vos essais de la semaine, qu’est-ce qui a marché, même un "
        "peu ? Que gardez-vous, et que laissez-vous ?",
    hint: "Les petites victoires comptent. Décider d’arrêter aussi.",
  ),
  // Construire
  16: PathDayText(
    title: "Choisir ce qu’on garde",
    prompt:
        "Quelles une ou deux actions de vos expériences voulez-vous garder "
        "pour l’instant ? Ajoutez-les en quêtes si vous voulez.",
    hint: "Gardez une liste courte pour qu’elle reste faisable.",
  ),
  17: PathDayText(
    title: "Façonner une quête",
    prompt:
        "Réécrivez une de vos quêtes pour la rendre plus claire et plus "
        "petite. Quelle est la nouvelle version ?",
    hint: "Une bonne quête commence par un verbe et tient en une séance.",
  ),
  18: PathDayText(
    title: "Point sur le projet",
    prompt:
        "Où en est votre projet du mois ? Quelle est la prochaine étape "
        "qu’on pourrait voir ?",
    hint:
        "Une étape visible se commence plus facilement qu’une étape "
        "floue.",
  ),
  19: PathDayText(
    title: "Protéger une limite",
    prompt:
        "Quelle limite de votre Boussole a été mise à l’épreuve cette "
        "semaine ? Comment l’avez-vous protégée, ou comment le faire la "
        "prochaine fois ?",
    hint: "Si vous n’avez pas encore écrit de limites, c’est le bon jour.",
  ),
  20: PathDayText(
    title: "Arranger votre espace",
    prompt:
        "Que pourriez-vous changer dans votre chambre, sur votre bureau ou "
        "dans votre téléphone pour faciliter vos leviers quotidiens ?",
    hint: "Ce qui aide en vue, les distractions hors de portée.",
  ),
  21: PathDayText(
    title: "Prévoir un jour sans énergie",
    prompt:
        "Imaginez une journée avec très peu d’énergie. Quelle est la plus "
        "petite version de votre quête que vous pourriez encore faire ?",
    hint: "Une version de deux minutes garde le fil.",
  ),
  22: PathDayText(
    title: "Montrer un morceau",
    prompt:
        "Y a-t-il une partie de votre projet que vous pourriez montrer, même "
        "inachevée ? Que ressentez-vous à cette idée ?",
    hint:
        "Montrer est facultatif. Remarquer ce que vous ressentez est "
        "l’exercice.",
  ),
  23: PathDayText(
    title: "Des signes de changement",
    prompt:
        "Qu’avez-vous fait ces dernières semaines que votre ancienne routine "
        "n’aurait pas fait ?",
    hint: "Les tout petits exemples comptent.",
  ),
  // Ajuster
  24: PathDayText(
    title: "Relire votre Boussole",
    prompt:
        "Lisez votre Boussole de haut en bas. Qu’est-ce qui sonne encore "
        "juste ? Qu’est-ce qui sonne faux maintenant ?",
    hint:
        "Gardez une version de la Boussole avant de changer quoi que ce "
        "soit.",
  ),
  25: PathDayText(
    title: "Rafraîchir votre vision",
    prompt:
        "Votre image d’une bonne journée ordinaire a-t-elle changé ? Écrivez "
        "une ligne à ajouter et une à retirer.",
    hint: "Une vision est faite pour grandir avec vous.",
  ),
  26: PathDayText(
    title: "Point sur l’objectif d’un an",
    prompt:
        "Votre mission d’un an correspond-elle encore à ce que vous avez "
        "appris ? Gardez-la, ajustez-la ou remplacez-la.",
    hint: "Changer d’objectif fait normalement partie du pilotage.",
  ),
  27: PathDayText(
    title: "Le prochain projet",
    prompt:
        "Quel pourrait être le projet du mois prochain, dans la continuité "
        "de celui-ci ?",
    hint: "Il peut prolonger ce projet, ou en commencer un nouveau.",
  ),
  28: PathDayText(
    title: "Laisser partir quelque chose",
    prompt:
        "Quel plan, quelle habitude ou quelle attente pourriez-vous déposer "
        "maintenant ?",
    hint: "Laisser partir fait de la place pour ce qui compte davantage.",
  ),
  29: PathDayText(
    title: "Un regard bienveillant",
    prompt:
        "Quel essai de ce mois-ci vous réjouit, quel que soit le "
        "résultat ?",
    hint: "L’effort et la curiosité comptent, pas seulement les résultats.",
  ),
  30: PathDayText(
    title: "Le prochain chapitre",
    prompt:
        "Écrivez-vous une courte note pour les trente prochains jours : ce "
        "qu’il faut garder, changer et essayer.",
    hint:
        "Vous pouvez commencer un nouveau recentrage ou garder une "
        "version de la Boussole à tout moment.",
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
// Le Terrain de jeu : expériences « Essayer » et cartes « Remarquer »
// ─────────────────────────────────────────────────────────────────────────────

const Map<String, ExperimentText> _experiments = {
  // Voir le terrain : vos journées telles qu’elles sont.
  'try.terrain.01': ExperimentText(
    title: "Traverser une pièce comme un invité",
    steps: [
      "Traversez lentement une pièce que vous utilisez chaque jour.",
      "Remarquez une chose que vous ne voyiez plus.",
    ],
  ),
  'try.terrain.02': ExperimentText(
    title: "Compter une petite habitude aujourd’hui",
    steps: [
      "Choisissez une petite habitude, comme prendre votre téléphone.",
      "Faites un trait à chaque fois.",
      "Regardez le total ce soir. Regardez, simplement.",
    ],
  ),
  'try.terrain.03': ExperimentText(
    title: "Noter une heure ordinaire",
    steps: [
      "Choisissez une heure ordinaire aujourd’hui.",
      "Toutes les 15 minutes, notez en quelques mots ce que vous faites.",
    ],
  ),

  // Trouver le schéma : ce qui se répète.
  'try.pattern.01': ExperimentText(
    title: "Faire une routine autrement",
    steps: [
      "Choisissez une petite routine : votre trajet, l’ordre de vos tâches.",
      "Faites-la autrement une fois aujourd’hui.",
      "Remarquez ce qui vous a semblé étrange.",
    ],
  ),
  'try.pattern.02': ExperimentText(
    title: "Attraper un « Je suis le genre de personne qui… »",
    steps: [
      "Guettez cette phrase dans votre tête aujourd’hui.",
      "Écrivez-la telle qu’elle est venue.",
      "Demandez-vous : est-ce encore vrai ?",
    ],
  ),
  'try.pattern.03': ExperimentText(
    title: "Marquer une pause avant une vieille excuse",
    steps: [
      "Quand une vieille raison de repousser revient, respirez lentement "
          "trois fois.",
      "Puis choisissez exprès, dans un sens ou dans l’autre.",
    ],
  ),

  // Lever votre bannière : un aperçu de la vie que vous voulez.
  'try.banner.01': ExperimentText(
    title: "Dix minutes comme votre futur vous",
    steps: [
      "Imaginez une bonne journée ordinaire dans quelques années.",
      "Choisissez une petite chose que vous faites ce jour-là.",
      "Faites-la dix minutes aujourd’hui.",
    ],
  ),
  'try.banner.02': ExperimentText(
    title: "Arranger un petit espace à votre goût",
    steps: [
      "Choisissez un bureau, une étagère ou un coin.",
      "Rangez-le ou arrangez-le pour qu’il ressemble aux journées que vous "
          "voulez.",
    ],
  ),
  'try.banner.03': ExperimentText(
    title: "Donner dix minutes à une curiosité",
    steps: [
      "Choisissez un sujet que vous aimeriez mieux connaître.",
      "Lisez, regardez ou essayez pendant dix minutes.",
    ],
  ),

  // Sortir du pilote automatique : de petites interruptions dans la journée.
  'try.autopilot.01': ExperimentText(
    title: "Prévoir une pause en douceur",
    steps: [
      "Réglez une alarme discrète pour plus tard aujourd’hui.",
      "Quand elle sonne, demandez-vous : que suis-je en train de faire, et "
          "pourquoi ?",
    ],
  ),
  'try.autopilot.02': ExperimentText(
    title: "Laisser votre téléphone dans une autre pièce",
    steps: [
      "Le temps d’un repas ou d’une petite tâche, gardez votre téléphone "
          "hors de portée.",
      "Remarquez quand vous avez envie de le prendre.",
    ],
  ),
  'try.autopilot.03': ExperimentText(
    title: "Faire lentement une tâche ordinaire",
    steps: [
      "Faites le thé, la vaisselle ou une marche deux fois plus lentement "
          "que d’habitude.",
      "Prêtez attention à chaque geste.",
    ],
  ),

  // Planifier la campagne : un petit pas, rendu facile.
  'try.plan.01': ExperimentText(
    title: "Écrire ce soir le premier pas de demain",
    steps: [
      "Avant de dormir, notez la première petite action de demain.",
      "Laissez-la là où vous la verrez le matin.",
    ],
  ),
  'try.plan.02': ExperimentText(
    title: "Réduire une tâche jusqu’à ce qu’elle soit facile",
    steps: [
      "Choisissez une tâche que vous repoussez sans cesse.",
      "Réduisez-la jusqu’à ce qu’elle prenne cinq minutes.",
      "Faites ce petit morceau.",
    ],
  ),
  'try.plan.03': ExperimentText(
    title: "Rayer une chose qui ne compte plus",
    steps: [
      "Relisez votre liste de tâches ou vos projets.",
      "Retirez un élément que vous n’avez plus besoin de faire.",
    ],
  ),
};

const Map<String, NoticeText> _notices = {
  'notice.01': NoticeText(title: "Ce que vous avez appris à supporter"),
  'notice.02': NoticeText(title: "Les plaintes que vous répétez"),
  'notice.03': NoticeText(title: "Pourquoi vos habitudes ont du sens"),
  'notice.04': NoticeText(title: "Ce que vous repoussez en ce moment"),
  'notice.05': NoticeText(title: "Les moments en pilote automatique"),
  'notice.06': NoticeText(title: "Une bonne journée, dans quelques années"),
  'notice.07': NoticeText(title: "Viser, agir, remarquer, ajuster"),
};
