// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Cartharise';

  @override
  String get appTagline => 'Maîtrisez-vous. Avancez avec un but.';

  @override
  String get appPromise =>
      'Comprenez-vous. Choisissez votre chemin. Avancez avec un but.';

  @override
  String get tabToday => 'Aujourd’hui';

  @override
  String get tabReset => 'Recentrage';

  @override
  String get tabCompass => 'Boussole';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabYou => 'Vous';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get skip => 'Passer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get done => 'Terminé';

  @override
  String get retry => 'Réessayer';

  @override
  String get close => 'Fermer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get keepGoing => 'Continuer';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get moreInfo => 'En savoir plus';

  @override
  String get saveStatusSaving => 'Enregistrement…';

  @override
  String get saveStatusSaved => 'Enregistré sur ce téléphone';

  @override
  String get saveStatusFailed => 'Dernière modification non enregistrée.';

  @override
  String get saveFailedHelp =>
      'Vos mots sont toujours là. Réessayez, ou exportez une copie.';

  @override
  String get saveExportCopy => 'Exporter une copie';

  @override
  String get bootLoading => 'Préparation de votre espace…';

  @override
  String get bootLoadErrorTitle => 'Vos données n’ont pas pu être ouvertes';

  @override
  String get bootLoadErrorBody =>
      'Cartharise n’a pas pu lire son fichier. Rien n’a été supprimé.';

  @override
  String get bootLoadErrorHint =>
      'Réessayez. Si le problème persiste, libérez de l’espace.';

  @override
  String get bootStartFresh =>
      'Repartir de zéro et garder le fichier illisible';

  @override
  String get bootStartFreshConfirmTitle => 'Repartir de zéro ?';

  @override
  String get bootStartFreshConfirmBody =>
      'Le fichier illisible est mis de côté, pas supprimé. Cartharise repart à vide.';

  @override
  String get storageTransparency =>
      'Uniquement sur ce téléphone. Rien n’est synchronisé, copié dans les sauvegardes du téléphone ou du cloud, ni chiffré par Cartharise. Supprimer l’app ou vos données efface tout.';

  @override
  String get storageErrorTitle => 'Problème de stockage';

  @override
  String get storageErrorBody =>
      'Impossible d’enregistrer sur ce téléphone pour l’instant. Vos mots restent à l’écran jusqu’à ce que vous quittiez.';

  @override
  String linkOpenFailed(String url) {
    return 'Le lien n’a pas pu s’ouvrir. Vous pouvez y aller vous-même : $url';
  }

  @override
  String get shareFailed => 'Le partage n’a pas pu s’ouvrir sur ce téléphone.';

  @override
  String get reminderChannelName => 'Rappels des pauses';

  @override
  String get reminderChannelDescription =>
      'Pauses facultatives dans la journée, issues de votre recentrage Cartharise.';

  @override
  String get loaderLabel => 'Chargement';

  @override
  String get emblemLabel => 'Emblème de Cartharise';

  @override
  String progressLabel(int value) {
    return '$value pour cent';
  }

  @override
  String get selectedLabel => 'Sélectionné';

  @override
  String get awakeningTitle => 'L’Éveil';

  @override
  String get awakeningSubtitle =>
      'Sept idées derrière le recentrage. Facultatif, dans l’ordre de votre choix.';

  @override
  String get awakeningStripTitle => 'Découvrir les idées d’abord (facultatif)';

  @override
  String get awakeningSeeAll => 'Voir toutes les leçons';

  @override
  String awakeningReadCount(int read, int total) {
    return 'Lues : $read sur $total';
  }

  @override
  String awakeningLessonNumber(int n) {
    return 'Leçon $n';
  }

  @override
  String awakeningLessonOf(int n, int total) {
    return 'Leçon $n sur $total';
  }

  @override
  String get awakeningRead => 'Lue';

  @override
  String get awakeningNotRead => 'Pas encore lue';

  @override
  String get awakeningExample => 'Exemple';

  @override
  String get awakeningNuance => 'Un regard, pas un verdict';

  @override
  String get awakeningCheckTitle => 'Vérifier votre compréhension';

  @override
  String get awakeningCheckHint =>
      'Choisissez la réponse qui convient le mieux. Rien n’est noté ni enregistré.';

  @override
  String get awakeningCheckRight => 'C’est bien ça.';

  @override
  String get awakeningCheckNotQuite =>
      'Pas tout à fait, et ce n’est pas grave.';

  @override
  String get awakeningTryIt => 'Essayer';

  @override
  String get awakeningTryItBody =>
      'Mettez cette idée en pratique avec une question du recentrage.';

  @override
  String awakeningTryItPrompt(String title) {
    return 'Essayer : $title';
  }

  @override
  String get awakeningPrevious => 'Leçon précédente';

  @override
  String get awakeningNext => 'Leçon suivante';

  @override
  String get awakeningDone => 'Retour aux leçons';

  @override
  String awakeningSourceNote(String title, String author) {
    return 'Avec les mots de Cartharise, d’après « $title » de $author. App indépendante.';
  }

  @override
  String get awakeningSourceLink => 'À propos de la source';

  @override
  String get awakeningMissing => 'Cette leçon n’est pas disponible.';

  @override
  String get campaignSection => 'Campagne';

  @override
  String get campaignSubtitle => 'Votre direction, jouée comme un jeu.';

  @override
  String get campaignStatusEyebrow => 'Votre campagne';

  @override
  String campaignLevel(int level, int xp) {
    return 'Niveau $level · $xp XP';
  }

  @override
  String get campaignXpNote =>
      'Les XP comptent ce que vous faites, jamais votre valeur. Le repos ne coûte rien.';

  @override
  String get campaignXpHow => 'Comment gagner des XP';

  @override
  String campaignXpRuleReflection(int xp) {
    return '+$xp XP par question du recentrage à laquelle vous répondez (une fois par question)';
  }

  @override
  String campaignXpRuleQuest(int xp, int max) {
    return '+$xp XP par quête accomplie, jusqu’à $max par jour';
  }

  @override
  String campaignXpRulePath(int xp) {
    return '+$xp XP par jour du parcours de 30 jours que vous écrivez';
  }

  @override
  String campaignXpRuleAttempt(int xp) {
    return '+$xp XP par jour où vous notez un essai pour votre projet du mois';
  }

  @override
  String campaignXpRuleReview(int xp) {
    return '+$xp XP par bilan de la semaine';
  }

  @override
  String campaignXpRulesNote(int step) {
    return 'Les XP ignorent ce que vous écrivez et ce que vous ressentez. Passer ou vous reposer ne coûte jamais d’XP. Chaque tranche de $step XP donne un nouveau niveau.';
  }

  @override
  String get campaignActOne => 'Acte I · L’éveil d’une journée';

  @override
  String campaignChaptersExplored(int count, int total) {
    return 'Chapitres explorés : $count sur $total';
  }

  @override
  String campaignChapterNumber(int number) {
    return 'Chapitre $number';
  }

  @override
  String get campaignChapterTerrain => 'Voir le terrain';

  @override
  String get campaignChapterTerrainArea => 'Réalité actuelle';

  @override
  String get campaignChapterPattern => 'Trouver le schéma';

  @override
  String get campaignChapterPatternArea => 'Anti-vision et identité';

  @override
  String get campaignChapterBanner => 'Lever votre bannière';

  @override
  String get campaignChapterBannerArea => 'Vision d’avenir';

  @override
  String get campaignChapterAutopilot => 'Sortir du pilote automatique';

  @override
  String get campaignChapterAutopilotArea => 'Pauses de la journée';

  @override
  String get campaignChapterPlan => 'Planifier la campagne';

  @override
  String get campaignChapterPlanArea => 'Synthèse du soir';

  @override
  String campaignChapterReflections(String area, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réflexions',
      one: '$count réflexion',
    );
    return '$area · $_temp0';
  }

  @override
  String campaignChapterDone(int done, int total) {
    return 'Écrites : $done sur $total';
  }

  @override
  String get campaignChapterExplored => 'Exploré';

  @override
  String get campaignChapterExplore => 'Explorer';

  @override
  String campaignChapterExploreLabel(int number, String name) {
    return 'Explorer le chapitre $number, $name';
  }

  @override
  String get campaignMapTitle => 'La carte du stratège';

  @override
  String get campaignMapAntiVision => 'L’enjeu · Anti-vision';

  @override
  String get campaignMapVision => 'Condition de victoire · Vision';

  @override
  String get campaignMapYear => 'Campagne principale · Mission d’un an';

  @override
  String get campaignMapMonth => 'Boss du mois · Projet du mois';

  @override
  String get campaignMapLevers => 'Quêtes quotidiennes · Leviers quotidiens';

  @override
  String get campaignMapBoundaries => 'Règles d’engagement · Limites';

  @override
  String get campaignMapBoundariesNote =>
      'Le jeu ne récompense jamais le fait d’y renoncer.';

  @override
  String get campaignMapEmpty => 'Pas encore écrit.';

  @override
  String get campaignMapEdit => 'Bâtir votre stratégie';

  @override
  String get campaignMapQuests => 'Ouvrir les quêtes quotidiennes';

  @override
  String get campaignBossTitle => 'Le boss du mois';

  @override
  String get campaignBossBody =>
      'Le boss est un projet, jamais une personne. Notez ce que vous tentez.';

  @override
  String get campaignBossNoProject =>
      'Choisissez un projet du mois dans votre Boussole pour le voir ici.';

  @override
  String get campaignAttemptLabel => 'Qu’avez-vous vraiment tenté ?';

  @override
  String get campaignAttemptHint =>
      'Un moment de concentration, un message difficile, un premier jet…';

  @override
  String get campaignAttemptRequired =>
      'Écrivez quelques mots sur ce que vous avez tenté.';

  @override
  String get campaignLearningLabel => 'Qu’avez-vous appris ? (facultatif)';

  @override
  String get campaignLearningHint => 'Ce qui a marché, ce que vous changeriez.';

  @override
  String get campaignRecord => 'Noter cet essai';

  @override
  String get campaignRecorded => 'Essai noté.';

  @override
  String campaignLogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Carnet de bataille · $count essais',
      one: 'Carnet de bataille · $count essai',
      zero: 'Carnet de bataille',
    );
    return '$_temp0';
  }

  @override
  String get campaignLogEmpty =>
      'Pas encore d’essai. Le premier peut être minuscule.';

  @override
  String campaignLogLearned(String learning) {
    return 'Appris : $learning';
  }

  @override
  String campaignLogEditLabel(String date) {
    return 'Modifier l’essai du $date';
  }

  @override
  String get campaignAttemptEditTitle => 'Modifier l’essai';

  @override
  String get campaignAttemptSave => 'Enregistrer l’essai';

  @override
  String get campaignAttemptDelete => 'Supprimer l’essai';

  @override
  String get campaignAttemptDeleteTitle => 'Supprimer cet essai ?';

  @override
  String get campaignAttemptDeleteBody => 'Il sera retiré. C’est définitif.';

  @override
  String get campaignAttemptDeleted => 'Essai supprimé';

  @override
  String get campaignAchievementsTitle => 'Hauts faits inspirés de l’article';

  @override
  String get campaignAchievementsSubtitle =>
      'Obtenus en réfléchissant, en essayant ou en agissant. Jamais selon ce que vous écrivez.';

  @override
  String campaignAchievementsCount(int earned, int total) {
    return 'Obtenus : $earned sur $total';
  }

  @override
  String get campaignNotYet => 'Pas encore';

  @override
  String get campaignAchievementObserver => 'L’Observateur';

  @override
  String get campaignAchievementObserverBody =>
      'Répondez à toutes les questions sur la réalité actuelle en un recentrage, ou essayez une de ses expériences';

  @override
  String get campaignAchievementPathfinder => 'L’Éclaireur';

  @override
  String get campaignAchievementPathfinderBody =>
      'Répondez à toutes les questions d’anti-vision et d’identité en un recentrage, ou essayez une de ses expériences';

  @override
  String get campaignAchievementVisionary => 'Le Visionnaire';

  @override
  String get campaignAchievementVisionaryBody =>
      'Répondez à toutes les questions de vision d’avenir en un recentrage, ou essayez une de ses expériences';

  @override
  String get campaignAchievementWatchful => 'Le Vigilant';

  @override
  String get campaignAchievementWatchfulBody =>
      'Répondez à toutes les pauses de la journée en un recentrage, ou essayez une de ses expériences';

  @override
  String get campaignAchievementStrategist => 'Le Stratège';

  @override
  String get campaignAchievementStrategistBody =>
      'Répondez à toutes les questions du plan du soir en un recentrage, ou essayez une de ses expériences';

  @override
  String get campaignAchievementPractitioner => 'Le Praticien';

  @override
  String get campaignAchievementPractitionerBody =>
      'Accomplir une quête dans la vraie vie';

  @override
  String get campaignAchievementChallenger => 'Le Challenger';

  @override
  String get campaignAchievementChallengerBody =>
      'Noter un premier essai pour votre projet du mois';

  @override
  String get campaignActTwo => 'Acte II · Trente jours pour devenir';

  @override
  String get campaignActTwoBody =>
      'Une direction, pas une échéance. Continuez les petits pas.';

  @override
  String get campaignStatQuests => 'Quêtes accomplies';

  @override
  String get campaignStatPath => 'Notes du parcours écrites';

  @override
  String get campaignStatAttempts => 'Essais notés';

  @override
  String get campaignContinuePath => 'Continuer le parcours de 30 jours';

  @override
  String get campaignReadArticle => 'Lire l’article';

  @override
  String get campaignNote =>
      'XP, niveaux et hauts faits sont des ajouts de Cartharise, pas de l’article. Désactivez-les dans Vous.';

  @override
  String get campaignTodayOpen => 'Ouvrir la Campagne';

  @override
  String get campaignSettingTitle => 'La Campagne';

  @override
  String get campaignSettingHint =>
      'XP, niveaux et hauts faits. Votre carnet de bataille reste si vous la désactivez.';

  @override
  String campaignWaypoint(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'carthage': 'Carthage',
      'newCarthage': 'Carthagène',
      'ebro': 'Èbre',
      'pyrenees': 'Pyrénées',
      'rhone': 'Rhône',
      'alps': 'Alpes',
      'italy': 'Italie',
      'other': 'Route',
    });
    return '$_temp0';
  }

  @override
  String campaignRouteHere(String place) {
    return 'Étape actuelle : $place';
  }

  @override
  String campaignRouteNext(int xp, String place) {
    return 'Prochaine étape : $place, dans $xp XP';
  }

  @override
  String get campaignRouteEnd => 'Vous voici en Italie. La campagne continue.';

  @override
  String campaignRouteLabel(String place, int stop, int total) {
    return 'Route d’Hannibal : $place, étape $stop sur $total.';
  }

  @override
  String get campaignBossStrength => 'Force du boss';

  @override
  String campaignBossMilestones(int done, int total) {
    return 'Jalons atteints : $done sur $total';
  }

  @override
  String get campaignBossBeaten =>
      'Tous les jalons sont atteints. Boss vaincu.';

  @override
  String get campaignBossNoMilestones =>
      'Ajoutez des jalons à votre projet pour affaiblir le boss.';

  @override
  String get campaignBossOpenProject => 'Ouvrir le projet';

  @override
  String campaignNextAchievement(String name, String how) {
    return 'Ensuite : $name · $how';
  }

  @override
  String campaignToastXp(int xp) {
    return '+$xp XP';
  }

  @override
  String campaignToastAchievement(String name) {
    return 'Haut fait obtenu : $name';
  }

  @override
  String get campaignStrategistEmpty =>
      'Créez un avatar pour parcourir la route avec vous.';

  @override
  String campaignExtrasCount(int count, int total) {
    return 'Extras débloqués : $count sur $total';
  }

  @override
  String get campaignExtrasAll => 'Tous les extras sont débloqués.';

  @override
  String campaignQuestXp(int xp) {
    return '+$xp XP';
  }

  @override
  String campaignQuestXpLabel(int xp) {
    return 'Rapporte $xp XP une fois faite';
  }

  @override
  String campaignXpRuleExperiment(int xp) {
    return '+$xp XP par nouvelle expérience essayée (une fois chacune)';
  }

  @override
  String get campaignNoticeTitle => 'Remarquer';

  @override
  String get campaignNoticeLine => 'Une question ou une idée à revoir.';

  @override
  String get campaignTryTitle => 'Essayer';

  @override
  String get campaignTryLine => 'Une mini-expérience pour la vraie vie.';

  @override
  String get campaignYoursTitle => 'À votre image';

  @override
  String get campaignYoursLine => 'Votre avatar et votre devise.';

  @override
  String campaignYoursPicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count récompenses à choisir',
      one: '$count récompense à choisir',
    );
    return '$_temp0';
  }

  @override
  String get campaignLinkRoute => 'Route';

  @override
  String get campaignLinkChapters => 'Chapitres';

  @override
  String get campaignLinkBattleLog => 'Carnet de bataille';

  @override
  String get campaignLinkBattleLogDraft => 'Carnet · brouillon gardé';

  @override
  String get campaignLinkCollection => 'Collection';

  @override
  String get campaignRouteTitle => 'La route';

  @override
  String get campaignRouteSubtitle =>
      'Une étape par niveau. Le repos ne vous fait jamais reculer.';

  @override
  String get campaignRouteStops => 'Étapes';

  @override
  String get campaignRouteStopHere => 'Vous êtes ici';

  @override
  String get campaignRouteStopReached => 'Atteinte';

  @override
  String campaignRouteStopAhead(int xp) {
    return 'Encore $xp XP';
  }

  @override
  String get campaignChaptersTitle => 'Chapitres';

  @override
  String campaignChapterTried(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expériences essayées',
      one: '$count expérience essayée',
    );
    return '$_temp0';
  }

  @override
  String get campaignChapterTry => 'En essayer une';

  @override
  String campaignChapterTryLabel(int number, String name) {
    return 'Essayer une expérience du chapitre $number, $name';
  }

  @override
  String get campaignBattleLogTitle => 'Carnet de bataille';

  @override
  String get campaignAttemptDraftNote =>
      'Gardé sur ce téléphone au fil de l’écriture.';

  @override
  String get campaignAttemptNotSaved =>
      'Pas encore enregistré sur ce téléphone. Vos mots sont toujours là. Réessayez en haut.';

  @override
  String get campaignNotSavedYet =>
      'Pas encore enregistré sur ce téléphone. Réessayez en haut.';

  @override
  String get campaignCollectionTitle => 'Collection';

  @override
  String get campaignCollectionSubtitle =>
      'Ce que vous avez essayé, obtenu et choisi.';

  @override
  String campaignCollectionTried(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count expériences essayées',
      one: '$count expérience essayée',
      zero: 'Expériences essayées',
    );
    return '$_temp0';
  }

  @override
  String get campaignCollectionTriedEmpty =>
      'Rien d’essayé pour l’instant. Voyez Essayer.';

  @override
  String get campaignTryOpen => 'Ouvrir Essayer';

  @override
  String get campaignExperimentUnknown => 'Une expérience';

  @override
  String campaignTriedOn(String date) {
    return 'Essayée le $date';
  }

  @override
  String campaignTriedEditLabel(String date) {
    return 'Modifier la note du $date';
  }

  @override
  String get campaignTriedSave => 'Enregistrer la note';

  @override
  String get campaignTriedRemove => 'Retirer cet essai';

  @override
  String get campaignTriedRemoveTitle => 'Retirer cet essai ?';

  @override
  String get campaignTriedRemoveBody =>
      'Il quitte votre Collection, avec sa note.';

  @override
  String get campaignTriedRemoved => 'Essai retiré';

  @override
  String get campaignTriedUnsavedTitle => 'Enregistrer la modification ?';

  @override
  String get campaignTriedUnsavedBody =>
      'La note a été modifiée mais pas enregistrée.';

  @override
  String get campaignTriedDiscard => 'Abandonner';

  @override
  String get campaignEarnedByReflecting => 'Obtenu en réfléchissant';

  @override
  String get campaignEarnedByTrying => 'Obtenu en essayant';

  @override
  String campaignEarnedByTryingWhat(String experiment) {
    return 'Obtenu en essayant : $experiment';
  }

  @override
  String get campaignEarnedByDoing => 'Obtenu en agissant';

  @override
  String get campaignCollectionExtras => 'Extras choisis';

  @override
  String get campaignCollectionExtrasEmpty =>
      'Aucun extra choisi pour l’instant.';

  @override
  String get campaignTryScreenSubtitle =>
      'De petites expériences. Rien ne rejoint vos tâches sans vous.';

  @override
  String campaignTryMinutes(int minutes) {
    return 'Environ $minutes min';
  }

  @override
  String campaignTryXpLabel(int xp) {
    return 'Rapporte $xp XP la première fois';
  }

  @override
  String campaignTryStepLabel(int number, String step) {
    return 'Étape $number : $step';
  }

  @override
  String get campaignTryNoteLabel => 'Une note (facultatif)';

  @override
  String get campaignTryNoteHint =>
      'Comment ça s’est passé ? Une ligne suffit.';

  @override
  String get campaignTryDone => 'Je l’ai essayée';

  @override
  String get campaignTryRecorded => 'Ajoutée à votre Collection.';

  @override
  String get campaignTryAddTask => 'Ajouter à mes tâches';

  @override
  String get campaignTryAdded => 'Ajoutée à vos tâches.';

  @override
  String get campaignTryAlreadyTask => 'Déjà dans vos tâches.';

  @override
  String get campaignTryOpenTasks => 'Ouvrir les tâches';

  @override
  String get campaignTryPrevious => 'Précédente';

  @override
  String campaignTryPosition(int index, int total) {
    return '$index sur $total';
  }

  @override
  String get campaignTryEmpty => 'Pas encore d’expérience ici.';

  @override
  String get campaignNoticeScreenSubtitle =>
      'Choisissez-en une. Chacune ouvre une question ou une leçon.';

  @override
  String get campaignNoticeKindPrompt => 'Réflexion';

  @override
  String get campaignNoticeKindLesson => 'Leçon';

  @override
  String campaignNoticeOpens(String title) {
    return 'Ouvre : $title';
  }

  @override
  String get campaignNoticeWritten => 'Écrite';

  @override
  String get campaignNoticeRead => 'Lue';

  @override
  String get campaignNoticeEmpty => 'Rien à remarquer ici pour l’instant.';

  @override
  String get campaignYoursScreenSubtitle =>
      'Votre allure et votre devise. Les extras sont décoratifs et restent à vous.';

  @override
  String get campaignRewardCardTitle => 'Récompenses à choisir';

  @override
  String get campaignRewardTitle => 'Choisir votre récompense';

  @override
  String campaignRewardPicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count choix à faire. Ce que vous choisissez reste à vous.',
      one: '$count choix à faire. Ce que vous choisissez reste à vous.',
    );
    return '$_temp0';
  }

  @override
  String campaignRewardSuggestedLine(String item) {
    return 'Suggestion : $item';
  }

  @override
  String campaignRewardSuggested(String kind) {
    return 'Suggestion · $kind';
  }

  @override
  String campaignRewardChoose(String item) {
    return 'Choisir : $item';
  }

  @override
  String campaignRewardChosen(String item) {
    return '$item : à vous pour de bon.';
  }

  @override
  String get campaignRewardWear => 'Le porter';

  @override
  String campaignRewardPreviewLabel(String item) {
    return 'Votre avatar avec : $item';
  }

  @override
  String get campaignRewardNone => 'Aucun choix à faire pour l’instant.';

  @override
  String get campaignRewardGameOff =>
      'Campagne désactivée : tous les extras sont déjà ouverts.';

  @override
  String get campaignPlaygroundSection => 'Terrain de jeu';

  @override
  String get campaignPlaygroundSubtitle =>
      'De petites choses à remarquer et à essayer.';

  @override
  String get campaignPlaygroundGameOff =>
      'Ni XP ni niveaux tant que la Campagne est désactivée. Activez-la dans Vous.';

  @override
  String get campaignInviteTitle => 'Jouer à la Campagne ?';

  @override
  String get campaignInviteBody => 'XP et niveaux pour ce que vous faites.';

  @override
  String get campaignInvitePlay => 'Jouer';

  @override
  String get campaignInvitePlaying =>
      'La Campagne est activée. Elle se trouve dans Boussole.';

  @override
  String get campaignInviteLater => 'Vous pourrez l’activer dans Vous.';

  @override
  String campaignToastPick(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux choix pour votre avatar',
      one: 'Un nouveau choix pour votre avatar',
    );
    return '$_temp0';
  }

  @override
  String get campaignQuestFromTry => 'Expérience';

  @override
  String get compassTitle => 'Boussole';

  @override
  String get compassSubtitle => 'Votre direction, avec vos mots.';

  @override
  String get compassMissionsSubtitle => 'Votre direction, en action.';

  @override
  String get compassSectionCompass => 'Boussole';

  @override
  String get compassSectionMissions => 'Missions';

  @override
  String get compassHeroEyebrow => 'Ma direction';

  @override
  String get compassHeroEmpty =>
      'Six réponses courtes pour orienter vos journées. Écrivez-les, ou partez de vos réponses du soir.';

  @override
  String compassLastUpdated(String date) {
    return 'Mise à jour le $date';
  }

  @override
  String get compassImportOfferTitleEmpty =>
      'Partir de votre réflexion du soir';

  @override
  String get compassImportOfferTitle =>
      'Vos réponses du soir peuvent remplir les champs vides';

  @override
  String get compassImportOfferBody =>
      'Reprenez vos mots du soir dans les champs vides. Rien ne change sans votre accord.';

  @override
  String get compassImportAction => 'Utiliser mes réflexions du soir';

  @override
  String get compassEmptyTitle => 'Votre Boussole est vide';

  @override
  String get compassEmptyBody =>
      'Écrivez chaque partie ci-dessous, ou répondez d’abord aux questions du soir.';

  @override
  String get compassEmptyAction => 'Aller à la réflexion du soir';

  @override
  String get compassFieldAntiVision => 'Anti-vision';

  @override
  String get compassFieldAntiVisionHelp =>
      'Ce que je refuse que ma vie devienne.';

  @override
  String get compassFieldAntiVisionHint =>
      'La vie que je ne veux pas, en une ou deux phrases';

  @override
  String get compassFieldVision => 'Vision';

  @override
  String get compassFieldVisionHelp => 'Ce vers quoi je construis.';

  @override
  String get compassFieldVisionHint => 'La vie que je veux faire grandir';

  @override
  String get compassFieldYearGoal => 'Mission d’un an';

  @override
  String get compassFieldYearGoalHelp =>
      'Le résultat qui compterait le plus dans un an.';

  @override
  String get compassFieldYearGoalHint => 'D’ici un an, je…';

  @override
  String get compassFieldMonthProject => 'Projet du mois';

  @override
  String get compassFieldMonthProjectHelp =>
      'Un projet pour les quatre semaines à venir.';

  @override
  String get compassFieldMonthProjectHint =>
      'Ce mois-ci, je vais créer ou terminer…';

  @override
  String get compassFieldDailyLevers => 'Leviers quotidiens';

  @override
  String get compassFieldDailyLeversHelp => '2 ou 3 actions, une par ligne.';

  @override
  String get compassFieldDailyLeversHint => 'Marcher 20 minutes\nLire 10 pages';

  @override
  String get compassFieldConstraints => 'Limites';

  @override
  String get compassFieldConstraintsHelp => 'Ce que je ne sacrifierai pas.';

  @override
  String get compassFieldConstraintsHint =>
      'Le sommeil, les dîners en famille, un jour de repos…';

  @override
  String get compassConstraintsOwnWords =>
      'Personne d’autre que vous ne l’écrit.';

  @override
  String get compassConstraintsChip => 'Écrit uniquement par vous';

  @override
  String get compassLeversToQuests => 'En faire des quêtes';

  @override
  String get compassOpenProject => 'Ouvrir le projet du mois';

  @override
  String get compassVersionsTitle => 'Versions';

  @override
  String get compassVersionsBody =>
      'Gardez une copie avant les grands changements.';

  @override
  String get compassSaveVersion => 'Garder une version';

  @override
  String get compassVersionSaved => 'Version gardée';

  @override
  String compassViewVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Versions ($count)',
      zero: 'Versions',
    );
    return '$_temp0';
  }

  @override
  String get compassVersionsSubtitle =>
      'Copies de votre Boussole, la plus récente en premier.';

  @override
  String get compassVersionsEmptyTitle => 'Pas encore de version';

  @override
  String get compassVersionsEmptyBody =>
      'Gardez une version quand vous voulez une copie à relire plus tard.';

  @override
  String get compassVersionReasonManual => 'Gardée par vous';

  @override
  String get compassVersionReasonBeforeImport => 'Avant un import';

  @override
  String get compassVersionReasonBeforeRestore => 'Avant une restauration';

  @override
  String get compassVersionTitle => 'Version';

  @override
  String get compassVersionEmptyField => 'Vide dans cette version';

  @override
  String get compassVersionSameAsNow => 'Comme aujourd’hui';

  @override
  String get compassVersionDiffers => 'Différent d’aujourd’hui';

  @override
  String get compassVersionReadOnly =>
      'Lecture seule. Restaurer garde d’abord votre Boussole actuelle.';

  @override
  String get compassRestoreAction => 'Restaurer cette version';

  @override
  String get compassRestoreConfirmTitle => 'Restaurer cette version ?';

  @override
  String get compassRestoreConfirmBody =>
      'Elle remplace votre Boussole. L’actuelle est gardée d’abord.';

  @override
  String get compassRestoreConfirm => 'Restaurer';

  @override
  String get compassRestored =>
      'Version restaurée. La précédente a été gardée.';

  @override
  String get compassImportTitle => 'Utiliser mes réflexions du soir';

  @override
  String get compassImportBody =>
      'Vos réponses du soir, telles qu’écrites. Choisissez les champs vides à remplir.';

  @override
  String compassImportFrom(String prompt) {
    return 'D’après : $prompt';
  }

  @override
  String get compassImportKeeps => 'Garde votre texte actuel';

  @override
  String get compassImportNoAnswer => 'Pas encore de réponse du soir';

  @override
  String get compassImportConstraintsNote =>
      'Les limites ne sont écrites que par vous.';

  @override
  String get compassImportSnapshotNote =>
      'Votre Boussole actuelle est d’abord gardée comme version.';

  @override
  String compassImportConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Remplir $count champs',
      one: 'Remplir $count champ',
      zero: 'Choisissez un champ',
    );
    return '$_temp0';
  }

  @override
  String get compassImportNothing =>
      'Rien à reprendre pour l’instant. Répondez d’abord aux questions du soir.';

  @override
  String compassImportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count champs de la Boussole remplis avec vos réponses du soir.',
      one: '$count champ de la Boussole rempli avec vos réponses du soir.',
    );
    return '$_temp0';
  }

  @override
  String get journalTitle => 'Journal';

  @override
  String get journalSubtitle => 'Penser, réfléchir et grandir, à votre rythme.';

  @override
  String get journalSectionNotes => 'Notes';

  @override
  String get journalSectionReviews => 'Bilans';

  @override
  String get journalSectionLookBack => 'Regards';

  @override
  String journalDateTime(String date, String time) {
    return '$date à $time';
  }

  @override
  String get journalNotesIntro => 'Écriture libre. Reste sur ce téléphone.';

  @override
  String get journalNewNote => 'Nouvelle note';

  @override
  String get journalNotesEmptyTitle => 'Pas encore de note';

  @override
  String get journalNotesEmptyBody =>
      'Une idée, un souci, quelque chose que vous avez remarqué.';

  @override
  String get journalUntitled => 'Note sans titre';

  @override
  String get journalEditedBadge => 'Modifiée';

  @override
  String get journalEntryNewTitle => 'Nouvelle note';

  @override
  String get journalEntryTitle => 'Note';

  @override
  String get journalEntryTitleField => 'Titre (facultatif)';

  @override
  String get journalEntryBodyField => 'Votre note';

  @override
  String get journalEntryBodyHint =>
      'Écrivez librement. Tout s’enregistre seul.';

  @override
  String journalEntryWritten(String when) {
    return 'Écrite le $when';
  }

  @override
  String journalEntryEdited(String when) {
    return 'Dernière modification : $when';
  }

  @override
  String get journalEntryPrivacy =>
      'Uniquement sur ce téléphone. Jamais dans les notifications.';

  @override
  String get journalEntryDelete => 'Supprimer la note';

  @override
  String get journalEntryDeleteTitle => 'Supprimer cette note ?';

  @override
  String get journalEntryDeleteBody =>
      'La note est retirée de ce téléphone. C’est définitif.';

  @override
  String get journalEntryDeleted => 'Note supprimée';

  @override
  String get journalEntryMissingTitle => 'Cette note n’est plus là';

  @override
  String get journalEntryMissingBody =>
      'Elle a peut-être été supprimée. Vos autres notes n’ont pas changé.';

  @override
  String get journalReviewsIntro =>
      'Une fois par semaine : ce qui a marché, ce qui a gêné, quoi essayer ensuite.';

  @override
  String get journalReviewThisWeek => 'Faire le bilan de la semaine';

  @override
  String get journalOpenThisWeek => 'Ouvrir le bilan de la semaine';

  @override
  String get journalReviewsEmptyTitle => 'Pas encore de bilan';

  @override
  String get journalReviewsEmptyBody => 'Quelques minutes, à votre façon.';

  @override
  String journalWeekOf(String date) {
    return 'Semaine du $date';
  }

  @override
  String get journalReviewTitle => 'Bilan de la semaine';

  @override
  String get journalReviewEditIntro =>
      'Écrivez autant que vous voulez. Tout s’enregistre seul.';

  @override
  String get journalReviewChangeWeek => 'Changer de semaine';

  @override
  String get journalReviewWins => 'Réussites';

  @override
  String get journalReviewWinsHint =>
      'Qu’est-ce qui a marché cette semaine, même un peu ?';

  @override
  String get journalReviewFriction => 'Frictions';

  @override
  String get journalReviewFrictionHint =>
      'Qu’est-ce qui a gêné ? Remarquez-le, simplement. Sans reproche.';

  @override
  String get journalReviewNext => 'Prochaine expérience';

  @override
  String get journalReviewNextHint =>
      'Une petite chose à essayer la semaine prochaine.';

  @override
  String get journalReviewSave => 'Enregistrer le bilan';

  @override
  String get journalReviewSaved => 'Bilan enregistré';

  @override
  String get journalReviewEdit => 'Modifier le bilan';

  @override
  String get journalReviewDelete => 'Supprimer le bilan';

  @override
  String get journalReviewDeleteTitle => 'Supprimer ce bilan ?';

  @override
  String journalReviewDeleteBody(String date) {
    return 'Le bilan de la semaine du $date sera retiré. C’est définitif.';
  }

  @override
  String get journalReviewDeleted => 'Bilan supprimé';

  @override
  String get journalReviewNothingWritten => 'Rien d’écrit';

  @override
  String journalReviewWritten(String when) {
    return 'Enregistré le $when';
  }

  @override
  String get journalReviewMissingTitle => 'Ce bilan n’est plus là';

  @override
  String get journalReviewMissingBody =>
      'Il a peut-être été supprimé. Vos autres bilans n’ont pas changé.';

  @override
  String get journalLookBackIntro => 'Voyez comment vos mots ont évolué.';

  @override
  String get journalCompareTitle => 'Comparer votre Boussole';

  @override
  String get journalCompareBody =>
      'Choisissez deux moments à mettre côte à côte.';

  @override
  String get journalCompareFirst => 'Premier';

  @override
  String get journalCompareSecond => 'Second';

  @override
  String get journalCompareNow => 'Votre Boussole aujourd’hui';

  @override
  String journalComparePick(String which) {
    return 'Choisir ce qui s’affiche en « $which »';
  }

  @override
  String journalComparePickerLabel(String which, String current) {
    return '$which : $current. Touchez pour changer.';
  }

  @override
  String get journalCompareEmptyTitle => 'Pas encore de version gardée';

  @override
  String get journalCompareEmptyBody =>
      'Gardez une version de la Boussole pour la comparer ici plus tard.';

  @override
  String get journalOpenCompass => 'Ouvrir la Boussole';

  @override
  String get journalCompareSame => 'Identique des deux côtés';

  @override
  String get journalCompareEmptyField => 'Vide';

  @override
  String get journalVersionManual => 'gardée par vous';

  @override
  String get journalVersionBeforeImport => 'avant un import';

  @override
  String get journalVersionBeforeRestore => 'avant une restauration';

  @override
  String journalVersionLabel(String date, String reason) {
    return '$date · $reason';
  }

  @override
  String get journalPastResetsTitle => 'Recentrages précédents';

  @override
  String get journalPastResetsBody =>
      'Commencer un nouveau recentrage garde le précédent ici, à relire.';

  @override
  String get journalPastResetsEmpty =>
      'Pas encore de recentrage précédent. En commencer un nouveau garde l’ancien ici.';

  @override
  String journalResetStarted(String date) {
    return 'Commencé le $date';
  }

  @override
  String journalResetCompleted(String date) {
    return 'Terminé le $date';
  }

  @override
  String journalResetAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses écrites',
      one: '$count réponse écrite',
      zero: 'Aucune réponse écrite',
    );
    return '$_temp0';
  }

  @override
  String get journalPastResetTitle => 'Recentrage précédent';

  @override
  String get journalPastResetReadOnly =>
      'Lecture seule. Vos mots sont gardés exactement comme vous les avez écrits.';

  @override
  String get journalPastResetCompare => 'Montrer aussi mes réponses actuelles';

  @override
  String get journalPastResetThen => 'Alors';

  @override
  String get journalPastResetNow => 'Aujourd’hui';

  @override
  String get journalPastResetNoCurrent =>
      'Pas de réponse dans votre recentrage actuel';

  @override
  String get journalPastResetSkipped => 'Passée';

  @override
  String get journalPastResetNone => 'Ce recentrage n’a pas de réponse écrite.';

  @override
  String get journalPastResetOther => 'Autres réponses';

  @override
  String get journalPastResetMissingTitle => 'Ce recentrage n’est plus là';

  @override
  String get journalPastResetUnfinished => 'Pas terminé';

  @override
  String journalPastResetLeftOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions sont restées ouvertes.',
      one: '$count question est restée ouverte.',
    );
    return '$_temp0';
  }

  @override
  String get journalPhaseMorning => 'Matin';

  @override
  String get journalPhaseDaytime => 'Journée';

  @override
  String get journalPhaseBonus => 'Bonus';

  @override
  String get journalPhaseEvening => 'Soir';

  @override
  String get listenAction => 'Écouter';

  @override
  String get listenStop => 'Arrêter la lecture';

  @override
  String get listenMyNote => 'Écouter ma note';

  @override
  String get listenMyAnswer => 'Écouter ma réponse';

  @override
  String get listenStarted => 'Lecture à voix haute.';

  @override
  String get listenStopped => 'Lecture arrêtée.';

  @override
  String get listenHearHint =>
      'Pas de son ? Vérifiez le volume et le mode silencieux.';

  @override
  String get listenNoVoice =>
      'Aucune voix pour cette langue sur ce téléphone. Vous pouvez en ajouter une dans ses réglages de synthèse vocale.';

  @override
  String get listenUnavailable =>
      'L\'écoute n\'est pas disponible sur ce téléphone.';

  @override
  String get listenSilent =>
      'Votre téléphone est en mode silencieux. Activez le son ou utilisez des écouteurs.';

  @override
  String get listenFailed =>
      'Impossible de lire ce texte à voix haute. Réessayez.';

  @override
  String get mediaAddPhoto => 'Ajouter une photo';

  @override
  String get mediaRecord => 'Enregistrer';

  @override
  String get mediaRecordLabel => 'Enregistrer une note vocale';

  @override
  String get mediaPhotoSourceTitle => 'Ajouter une photo';

  @override
  String get mediaTakePhoto => 'Prendre une photo';

  @override
  String get mediaChoosePhoto => 'Choisir dans vos photos';

  @override
  String get mediaPhotoAdded => 'Photo ajoutée.';

  @override
  String get mediaNotSavedYet =>
      'Ajouté, mais pas encore enregistré sur ce téléphone.';

  @override
  String mediaPhotoLabel(String date) {
    return 'Photo ajoutée le $date';
  }

  @override
  String get mediaPhotoOpenHint => 'S’ouvre en plein écran';

  @override
  String get mediaPhotoMissing => 'Absente';

  @override
  String get mediaPhotoMissingLabel =>
      'Cette photo n’est plus sur ce téléphone.';

  @override
  String get mediaPhotoTitle => 'Photo';

  @override
  String mediaPhotoAddedOn(String date) {
    return 'Ajoutée le $date';
  }

  @override
  String get mediaPhotoRemove => 'Retirer la photo';

  @override
  String get mediaPhotoRemoveTitle => 'Retirer cette photo ?';

  @override
  String get mediaPhotoRemoveBody =>
      'Elle est supprimée de ce téléphone. C’est définitif.';

  @override
  String get mediaRemove => 'Retirer';

  @override
  String get mediaPhotoRemoved => 'Photo retirée.';

  @override
  String get mediaRemovedNotSaved =>
      'Retiré ici, mais pas encore enregistré sur ce téléphone.';

  @override
  String get mediaCameraDenied =>
      'L’accès à l’appareil photo est coupé. Choisissez dans vos photos, ou autorisez-le dans les Réglages.';

  @override
  String get mediaPhotosDenied =>
      'L’accès aux photos est coupé. Autorisez-le dans les Réglages, ou écrivez plutôt.';

  @override
  String get mediaCameraUnavailable =>
      'Pas d’appareil photo ici. Choisissez plutôt dans vos photos.';

  @override
  String get mediaPhotosUnavailable =>
      'Les photos ne peuvent pas s’ouvrir ici. Vous pouvez écrire à la place.';

  @override
  String get mediaPickFailed => 'Les photos n’ont pas pu s’ouvrir. Réessayez.';

  @override
  String get mediaPhotoUnreadable =>
      'Cette photo n’a pas pu être lue. Rien n’a été ajouté.';

  @override
  String get mediaPhotoTooLarge =>
      'Cette photo dépasse 50 Mo. Choisissez-en une plus petite.';

  @override
  String get mediaWriteFailed =>
      'Impossible de l’enregistrer sur ce téléphone. Le stockage est peut-être plein. Rien n’a été ajouté.';

  @override
  String get mediaEntryGone =>
      'Cet élément n’est plus là. Rien n’a été ajouté.';

  @override
  String get mediaRecoveredPhoto =>
      'Une photo prise n’a pas encore été ajoutée.';

  @override
  String get mediaRecoveredRecording =>
      'Un enregistrement a été coupé à la fermeture de l’app. Il est peut-être incomplet.';

  @override
  String get mediaRecoveredKeep => 'Garder dans une nouvelle note';

  @override
  String get mediaRecoveredDiscard => 'Abandonner';

  @override
  String get mediaRecoveredDiscardTitle => 'L’abandonner ?';

  @override
  String get mediaRecoveredDiscardBody => 'Il est supprimé de ce téléphone.';

  @override
  String get mediaRecoveredKept =>
      'Gardé dans une nouvelle note de votre Journal.';

  @override
  String get mediaDismiss => 'Fermer';

  @override
  String get mediaRecorderTitle => 'Note vocale';

  @override
  String get mediaRecorderStarting => 'Préparation du micro…';

  @override
  String get mediaRecorderRecording => 'Enregistrement';

  @override
  String get mediaRecorderStop => 'Arrêter et garder';

  @override
  String get mediaRecorderDiscard => 'Abandonner';

  @override
  String get mediaRecorderDiscardTitle => 'Abandonner cet enregistrement ?';

  @override
  String get mediaRecorderDiscardBody =>
      'Ce que vous avez enregistré est supprimé.';

  @override
  String get mediaRecorderSaving => 'Enregistrement…';

  @override
  String get mediaRecorderStarted =>
      'Enregistrement. Touchez Arrêter et garder à la fin.';

  @override
  String get mediaRecorderSaved => 'Note vocale enregistrée.';

  @override
  String mediaRecorderInterrupted(String time) {
    return 'Interrompu. Ce qui a été enregistré avant ($time) est gardé.';
  }

  @override
  String get mediaRecorderAgain => 'Enregistrer à nouveau';

  @override
  String get mediaMicDenied =>
      'L’accès au micro est coupé. Autorisez-le dans les Réglages, ou écrivez plutôt.';

  @override
  String get mediaMicUnavailable =>
      'L’enregistrement n’est pas disponible sur ce téléphone. Vous pouvez écrire à la place.';

  @override
  String get mediaRecordFailed =>
      'L’enregistrement n’a pas pu démarrer. Réessayez, ou écrivez plutôt.';

  @override
  String get mediaNothingRecorded =>
      'Rien n’a été enregistré. Réessayez, ou écrivez plutôt.';

  @override
  String get mediaRecordStorageFailed =>
      'L’enregistrement n’a pas pu être gardé. Le stockage est peut-être plein.';

  @override
  String get mediaWriteInstead => 'Écrire plutôt';

  @override
  String get mediaVoiceNote => 'Note vocale';

  @override
  String get mediaPartial => 'Partielle';

  @override
  String get mediaPlay => 'Écouter la note vocale';

  @override
  String get mediaPause => 'Mettre en pause la note vocale';

  @override
  String mediaPositionOf(String position, String length) {
    return '$position sur $length';
  }

  @override
  String get mediaVoiceMissing =>
      'Cet enregistrement n’est plus sur ce téléphone.';

  @override
  String get mediaPlayFailed => 'Cet enregistrement ne peut pas être lu.';

  @override
  String get mediaVoiceRemove => 'Retirer la note vocale';

  @override
  String get mediaVoiceRemoveTitle => 'Retirer cette note vocale ?';

  @override
  String get mediaVoiceRemoveBody =>
      'L’enregistrement est supprimé de ce téléphone. C’est définitif.';

  @override
  String get mediaVoiceRemoved => 'Note vocale retirée.';

  @override
  String get mediaTranscriptAdd => 'Écrire ce que vous avez dit';

  @override
  String get mediaTranscriptEdit => 'Modifier vos mots';

  @override
  String get mediaTranscriptTitle => 'Vos mots pour cet enregistrement';

  @override
  String get mediaTranscriptLabel => 'Ce que vous avez dit (facultatif)';

  @override
  String get mediaTranscriptSaved =>
      'Vos mots sont gardés avec l’enregistrement.';

  @override
  String mediaMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '$count minute',
    );
    return '$_temp0';
  }

  @override
  String mediaSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondes',
      one: '$count seconde',
    );
    return '$_temp0';
  }

  @override
  String get mediaPinnedTitle => 'Souvenir épinglé';

  @override
  String mediaPinnedFromNote(String date) {
    return 'D’une note · $date';
  }

  @override
  String mediaPinnedFromTry(String date) {
    return 'D’une expérience · $date';
  }

  @override
  String mediaPinnedFromAttempt(String date) {
    return 'D’un essai · $date';
  }

  @override
  String get mediaPinnedOpen => 'Ouvrir l’original';

  @override
  String get mediaPinnedPhoto => 'Photo épinglée';

  @override
  String get mediaPinPhoto => 'Épingler en souvenir';

  @override
  String get mediaUnpin => 'Désépingler';

  @override
  String get mediaPinned => 'Épinglé en haut de votre Journal.';

  @override
  String get mediaPinnedNotSaved =>
      'Épinglé, mais pas encore enregistré sur ce téléphone.';

  @override
  String get mediaUnpinned => 'Désépinglé. Rien d’autre n’a changé.';

  @override
  String get mediaUnpinnedNotSaved =>
      'Désépinglé, mais pas encore enregistré sur ce téléphone.';

  @override
  String get mediaPinWords => 'Épingler';

  @override
  String get mediaPinWordsTooltip => 'Épingler les mots sélectionnés';

  @override
  String get mediaPinSelectFirst =>
      'Sélectionnez des mots, puis touchez Épingler.';

  @override
  String get mediaPinNotFound =>
      'Ces mots n’ont pas pu être épinglés. Sélectionnez-les à nouveau.';

  @override
  String mediaCountPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '$count photo',
    );
    return '$_temp0';
  }

  @override
  String mediaCountVoice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes vocales',
      one: '$count note vocale',
    );
    return '$_temp0';
  }

  @override
  String mediaAnd(String first, String second) {
    return '$first et $second';
  }

  @override
  String get mediaNoteVoiceOnly => 'Note vocale';

  @override
  String get mediaNotePhotoOnly => 'Note photo';

  @override
  String get mediaNoteDeleteBody =>
      'La note, ses photos et ses enregistrements sont retirés de ce téléphone. C’est définitif.';

  @override
  String get mediaTodayRecordSaved =>
      'Note vocale enregistrée dans votre Journal.';

  @override
  String get mediaTodayRecordNotSaved =>
      'Note vocale prise, mais pas encore enregistrée. Réessayez en haut.';

  @override
  String get mediaTodayOpen => 'Ouvrir';

  @override
  String get mediaDataNoFiles =>
      'Comprend vos mots et réglages. Pas encore de photos ni d’enregistrements.';

  @override
  String mediaDataWithFiles(String files, String size) {
    return 'Comprend vos mots et réglages, plus $files ($size).';
  }

  @override
  String get mediaDataTooLarge =>
      'Photos et enregistrements dépassent 256 Mo, trop pour être restaurés. L’export ne garde que vos mots ; retirez-en pour une sauvegarde complète.';

  @override
  String get mediaBackupTooLargeTitle => 'Trop volumineux à restaurer';

  @override
  String get mediaBackupTooLargeBody =>
      'Vos photos et enregistrements dépassent 256 Mo, plus qu’une sauvegarde ne peut restaurer. Exporter seulement vos mots et réglages ?';

  @override
  String get mediaBackupWordsOnly => 'Exporter les mots seulement';

  @override
  String get mediaBackupWordsShared =>
      'Mots et réglages partagés. Les photos et enregistrements n’y sont pas.';

  @override
  String get mediaDataImportFormats =>
      'Accepte une sauvegarde .zip, ou une plus ancienne en .json.';

  @override
  String mediaSizeKb(String size) {
    return '$size Ko';
  }

  @override
  String mediaSizeMb(String size) {
    return '$size Mo';
  }

  @override
  String mediaSizeGb(String size) {
    return '$size Go';
  }

  @override
  String get missionsIntro =>
      'De petits pas vers votre Boussole. Le repos compte aussi.';

  @override
  String get missionsToday => 'Aujourd’hui';

  @override
  String get missionsTodayEmpty =>
      'Rien de prévu. Ajoutez une quête, ou reposez-vous.';

  @override
  String get missionsLater => 'Sans date et à venir';

  @override
  String get missionsLaterEmpty =>
      'Les quêtes sans date, ou prévues plus tard, apparaissent ici.';

  @override
  String missionsDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faites ($count)',
      zero: 'Faites',
    );
    return '$_temp0';
  }

  @override
  String get missionsAddQuest => 'Ajouter une quête';

  @override
  String missionsQuestMarkDone(String title) {
    return 'Marquer « $title » comme faite';
  }

  @override
  String missionsQuestOptions(String title) {
    return 'Options pour « $title »';
  }

  @override
  String get missionsQuestDaily => 'Chaque jour';

  @override
  String missionsQuestDue(String date) {
    return 'Prévue le $date';
  }

  @override
  String get missionsQuestDoneToday => 'Faite aujourd’hui';

  @override
  String missionsQuestDoneOn(String date) {
    return 'Faite le $date';
  }

  @override
  String missionsQuestMovedToDone(String title) {
    return '« $title » passée dans Faites';
  }

  @override
  String get missionsUndo => 'Annuler';

  @override
  String get missionsQuestDeleted => 'Quête supprimée';

  @override
  String get missionsQuestEdit => 'Modifier';

  @override
  String get missionsQuestDelete => 'Supprimer';

  @override
  String get missionsViewLabel => 'Afficher les quêtes en';

  @override
  String get missionsViewList => 'Liste';

  @override
  String get missionsViewBoard => 'Tableau';

  @override
  String get missionsBoardHint =>
      'Maintenez une carte pour la déplacer, ou utilisez son bouton.';

  @override
  String get missionsBoardTodayFilter => 'Aujourd’hui';

  @override
  String get missionsBoardTodayFilterTooltip =>
      'Seulement les quêtes quotidiennes et celles prévues aujourd’hui';

  @override
  String get missionsLaneLater => 'Plus tard';

  @override
  String get missionsLaneReady => 'Prêtes';

  @override
  String get missionsLaneDoing => 'En cours';

  @override
  String get missionsLaneDone => 'Faites';

  @override
  String missionsLaneSummary(String lane, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quêtes',
      one: '$count quête',
      zero: 'aucune quête',
    );
    return '$lane, $_temp0';
  }

  @override
  String get missionsLaneLaterEmpty =>
      'Rangez ici les idées pour une autre fois.';

  @override
  String get missionsLaneReadyEmpty => 'Les quêtes prêtes à commencer.';

  @override
  String get missionsLaneDoingEmpty =>
      'Placez ici une quête quand vous la commencez.';

  @override
  String get missionsLaneDoneEmpty => 'Les quêtes terminées arrivent ici.';

  @override
  String get missionsLaneTodayEmpty => 'Rien ici pour aujourd’hui.';

  @override
  String get missionsLaneDoneFolded =>
      'Repliée. Déposez une carte ici pour la terminer.';

  @override
  String get missionsBoardDoingNote => 'Moins en cours, c’est plus léger.';

  @override
  String missionsBoardAddTo(String lane) {
    return 'Ajouter à $lane';
  }

  @override
  String missionsBoardMoveTooltip(String title) {
    return 'Déplacer « $title » vers…';
  }

  @override
  String missionsBoardMoveToLane(String lane) {
    return 'Déplacer vers $lane';
  }

  @override
  String missionsBoardMoved(String title, String lane) {
    return '« $title » déplacée vers $lane';
  }

  @override
  String missionsBoardDoneForToday(String title) {
    return '« $title » faite pour aujourd’hui';
  }

  @override
  String get missionsBoardDropHere => 'Déposer ici pour déplacer';

  @override
  String get missionsBoardHiddenByFilter =>
      'Ajoutée. Le filtre Aujourd’hui la masque.';

  @override
  String get missionsBoardShowAll => 'Tout afficher';

  @override
  String get missionsNewQuestTitle => 'Nouvelle quête';

  @override
  String get missionsEditQuestTitle => 'Modifier la quête';

  @override
  String get missionsQuestTitleLabel => 'Que ferez-vous ?';

  @override
  String get missionsQuestTitleHint => 'Marcher 20 minutes';

  @override
  String get missionsQuestTitleRequired => 'Donnez quelques mots à la quête.';

  @override
  String get missionsQuestRepeat => 'Répéter chaque jour';

  @override
  String get missionsQuestRepeatHelp => 'Chaque jour dans Aujourd’hui.';

  @override
  String get missionsQuestDueLabel => 'Date (facultatif)';

  @override
  String get missionsQuestNoDate => 'Sans date';

  @override
  String get missionsQuestChooseDate => 'Choisir une date';

  @override
  String get missionsQuestClearDate => 'Retirer la date';

  @override
  String get missionsQuestSave => 'Enregistrer la quête';

  @override
  String get missionsQuestDeleteAction => 'Supprimer la quête';

  @override
  String get missionsLeversTitle => 'Faire de vos leviers des quêtes';

  @override
  String get missionsLeversBody =>
      'Tirés de votre Boussole. Modifiez, puis ajoutez ceux que vous voulez.';

  @override
  String missionsLeversInclude(String title) {
    return 'Inclure « $title »';
  }

  @override
  String missionsLeversDraftLabel(int index) {
    return 'Quête $index';
  }

  @override
  String missionsLeversAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count quêtes quotidiennes',
      one: 'Ajouter $count quête quotidienne',
      zero: 'Choisissez-en au moins une',
    );
    return '$_temp0';
  }

  @override
  String missionsLeversAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quêtes quotidiennes ajoutées.',
      one: '$count quête quotidienne ajoutée.',
      zero: 'Rien de nouveau à ajouter. Ces quêtes existent déjà.',
    );
    return '$_temp0';
  }

  @override
  String get missionsLeversNotNow => 'Pas maintenant';

  @override
  String get missionsProjectTitle => 'Projet du mois';

  @override
  String get missionsProjectEmpty =>
      'Prévoyez un projet pour les quatre semaines à venir.';

  @override
  String missionsProjectFromCompass(String title) {
    return 'D’après votre Boussole : $title';
  }

  @override
  String get missionsProjectUntitled => 'Projet sans titre';

  @override
  String missionsProjectMilestones(int done, int total) {
    return 'Jalons franchis : $done sur $total';
  }

  @override
  String get missionsStatusPlanned => 'Prévu';

  @override
  String get missionsStatusActive => 'En cours';

  @override
  String get missionsStatusPaused => 'En pause';

  @override
  String get missionsStatusDone => 'Terminé';

  @override
  String get missionsProjectScreenSubtitle =>
      'Un projet, quelques jalons, et un regard en arrière.';

  @override
  String get missionsProjectTitleLabel => 'Projet';

  @override
  String get missionsProjectTitleHint =>
      'Que voulez-vous créer ou terminer ce mois-ci ?';

  @override
  String get missionsProjectLinked => 'Relié à votre Boussole';

  @override
  String missionsProjectOfferUpdate(String title) {
    return 'Votre Boussole indique : $title. La mettre à jour ?';
  }

  @override
  String get missionsProjectOfferAdd =>
      'En faire le projet du mois de votre Boussole ?';

  @override
  String get missionsProjectUpdateCompass => 'Mettre à jour la Boussole';

  @override
  String get missionsProjectAddCompass => 'Ajouter à la Boussole';

  @override
  String get missionsProjectKeep => 'Laisser tel quel';

  @override
  String get missionsProjectCompassUpdated => 'Boussole mise à jour';

  @override
  String get missionsProjectStatus => 'État';

  @override
  String get missionsMilestones => 'Jalons';

  @override
  String get missionsMilestonesEmpty =>
      'Découpez le projet en quelques étapes visibles.';

  @override
  String get missionsMilestoneAdd => 'Ajouter un jalon';

  @override
  String get missionsMilestoneNew => 'Nouveau jalon';

  @override
  String get missionsMilestoneRename => 'Renommer le jalon';

  @override
  String missionsMilestoneMarkDone(String title) {
    return 'Marquer le jalon « $title » comme franchi';
  }

  @override
  String missionsMilestoneRenameLabel(String title) {
    return 'Renommer « $title »';
  }

  @override
  String missionsMilestoneDeleteLabel(String title) {
    return 'Supprimer « $title »';
  }

  @override
  String get missionsMilestoneDeleted => 'Jalon supprimé';

  @override
  String get missionsRetro => 'Regard en arrière';

  @override
  String get missionsRetroHelp =>
      'Ce qui a marché, ce que vous avez appris, ce que vous changeriez.';

  @override
  String get missionsRetroHint => 'Vos notes';

  @override
  String get missionsProjectClear => 'Supprimer ce projet';

  @override
  String get missionsProjectClearTitle => 'Supprimer ce projet ?';

  @override
  String get missionsProjectClearBody =>
      'Son titre, ses jalons et ses notes disparaissent. Votre Boussole, vos tâches et vos essais restent.';

  @override
  String get missionsProjectClearConfirm => 'Supprimer';

  @override
  String get missionsPathTitle => 'Parcours de 30 jours';

  @override
  String get missionsPathIntro =>
      'Chaque jour est ouvert : allez à votre rythme.';

  @override
  String missionsPathWrittenCount(int count) {
    return 'Jours écrits : $count sur 30';
  }

  @override
  String get missionsStageObserve => 'Observer';

  @override
  String get missionsStageExperiment => 'Expérimenter';

  @override
  String get missionsStageBuild => 'Construire';

  @override
  String get missionsStageAdjust => 'Ajuster';

  @override
  String get missionsStageObserveHelp =>
      'Remarquez ce qui se passe, sans juger.';

  @override
  String get missionsStageExperimentHelp =>
      'Essayez de petits changements et voyez ce qui aide.';

  @override
  String get missionsStageBuildHelp =>
      'Gardez ce qui aide et rendez-le plus facile.';

  @override
  String get missionsStageAdjustHelp =>
      'Regardez en arrière et ajustez votre direction.';

  @override
  String missionsStageDays(int from, int to) {
    return 'Jours $from à $to';
  }

  @override
  String missionsDayLabel(int day) {
    return 'Jour $day';
  }

  @override
  String get missionsDayWritten => 'Écrit';

  @override
  String missionsDayStage(int day, String stage) {
    return 'Jour $day · $stage';
  }

  @override
  String missionsDayAnswerLabel(int day) {
    return 'Votre note du jour $day';
  }

  @override
  String get missionsDayAnswerHint =>
      'Écrivez autant ou aussi peu que vous voulez.';

  @override
  String missionsDayPrevious(int day) {
    return 'Jour $day';
  }

  @override
  String missionsDayNext(int day) {
    return 'Jour $day';
  }

  @override
  String missionsDayPreviousLabel(int day) {
    return 'Précédent : jour $day';
  }

  @override
  String missionsDayNextLabel(int day) {
    return 'Suivant : jour $day';
  }

  @override
  String get missionsDayMissing => 'Ce jour n’est pas disponible.';

  @override
  String get onboardingBrandIntro =>
      'Une journée de réflexion honnête. Puis de petits pas.';

  @override
  String get onboardingBegin => 'Commencer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'C’est parti';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboardingLimitsTitle => 'Avant de commencer';

  @override
  String get onboardingLimitsIntro => 'Quelques mots honnêtes.';

  @override
  String get onboardingLimitsClarityTitle => 'Une journée peut éclairer';

  @override
  String get onboardingLimitsClarityBody =>
      'Voyez où vous en êtes et ce que vous voulez.';

  @override
  String get onboardingLimitsNoGuaranteeTitle =>
      'Pas de miracle du jour au lendemain';

  @override
  String get onboardingLimitsNoGuaranteeBody =>
      'Le changement vient de petits pas, semaine après semaine.';

  @override
  String get onboardingLimitsNotTherapyTitle => 'Pas une thérapie';

  @override
  String get onboardingLimitsNotTherapyBody =>
      'Aucun diagnostic. Pour de l’aide : Vous › Aide.';

  @override
  String get onboardingLimitsControlTitle => 'Vous gardez la main';

  @override
  String get onboardingLimitsControlBody =>
      'Passez, adoucissez ou suspendez chaque question.';

  @override
  String get onboardingAdultConfirm => 'J’ai 18 ans ou plus';

  @override
  String get onboardingAdultConfirmHelp => 'Conçu pour les adultes.';

  @override
  String get onboardingAdultRequired =>
      'Confirmez avoir 18 ans ou plus pour continuer.';

  @override
  String get onboardingCreditTitle => 'Inspiré par';

  @override
  String onboardingCreditByline(String author, String date) {
    return 'par $author · $date';
  }

  @override
  String get onboardingCreditArticle => 'Lire l’article original';

  @override
  String get onboardingCreditNewsletter =>
      'Le lire dans la newsletter de l’auteur';

  @override
  String get onboardingCreditNoNeed => 'Inutile de le lire avant.';

  @override
  String get onboardingPaceTitle => 'Choisissez votre rythme';

  @override
  String get onboardingPaceIntro => 'Modifiable à tout moment dans Vous.';

  @override
  String get onboardingPaceOneDayTitle => 'Une journée';

  @override
  String get onboardingPaceOneDayBody => 'Matin, journée et soir en un jour.';

  @override
  String get onboardingPaceFlexibleTitle => 'Libre';

  @override
  String get onboardingPaceFlexibleBody =>
      'Étalez-le. Reprenez quand vous voulez.';

  @override
  String get onboardingPaceNoLock => 'Rien ne se verrouille ni n’expire.';

  @override
  String get onboardingNameTitle => 'Comment vous appeler ?';

  @override
  String get onboardingNameIntro => 'Facultatif. Reste sur ce téléphone.';

  @override
  String get onboardingNameLabel => 'Prénom (facultatif)';

  @override
  String get onboardingNameHelp =>
      'Sans prénom, nous dirons « âme voyageuse ».';

  @override
  String get onboardingPrivacyTitle => 'Vos mots restent à vous';

  @override
  String get onboardingPrivacyStorageHeading => 'Où vivent vos écrits';

  @override
  String get onboardingPrivacyNoAccount =>
      'Ni compte, ni publicité, ni statistiques.';

  @override
  String get onboardingPrivacyControl =>
      'Exportez ou supprimez tout dans Vous › Vos données.';

  @override
  String get personaFeatureTitle => 'Votre stratège';

  @override
  String get personaAvatarLabel => 'Votre avatar';

  @override
  String get personaNoAvatar => 'Pas encore d’avatar';

  @override
  String get personaCreate => 'Créer votre avatar';

  @override
  String get personaEdit => 'Modifier votre avatar';

  @override
  String get personaSilhouette => 'Silhouette';

  @override
  String get personaLocked => 'Verrouillé';

  @override
  String get personaUnlockWithPick => 'À choisir avec une récompense';

  @override
  String personaNextPickStop(String place) {
    return 'Prochain choix à l’étape : $place';
  }

  @override
  String personaNextPickAchievement(String achievement) {
    return 'Prochain choix : obtenir $achievement';
  }

  @override
  String get personaCategorySkin => 'Peau';

  @override
  String get personaCategoryFace => 'Visage';

  @override
  String get personaCategoryHair => 'Cheveux';

  @override
  String get personaCategoryHairColor => 'Couleur des cheveux';

  @override
  String get personaCategoryFacialHair => 'Pilosité faciale';

  @override
  String get personaCategoryEyewear => 'Lunettes';

  @override
  String get personaCategoryMark => 'Signes';

  @override
  String get personaCategoryExpression => 'Expression';

  @override
  String get personaCategoryHeadwear => 'Couvre-chef';

  @override
  String get personaCategoryGarment => 'Vêtement';

  @override
  String get personaCategoryGarmentColor => 'Couleur';

  @override
  String get personaCategoryAccessory => 'À porter';

  @override
  String get personaCategorySigil => 'Bannière';

  @override
  String personaSkinTone(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'sand': 'Sable',
      'honey': 'Miel',
      'clay': 'Argile',
      'copper': 'Cuivre',
      'chestnut': 'Châtaigne',
      'walnut': 'Noyer',
      'umber': 'Terre d’ombre',
      'ebony': 'Ébène',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaFace(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'oval': 'Ovale',
      'round': 'Rond',
      'square': 'Carré',
      'long': 'Allongé',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHair(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'bald': 'Rasé',
      'buzz': 'Très court',
      'short': 'Court',
      'wavy': 'Ondulé',
      'curly': 'Bouclé',
      'coily': 'Frisé serré',
      'afro': 'Afro',
      'locs': 'Locks',
      'braids': 'Tresses',
      'bun': 'Chignon',
      'long': 'Long',
      'ponytail': 'Queue-de-cheval',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHairColor(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'black': 'Noir',
      'darkBrown': 'Brun foncé',
      'brown': 'Brun',
      'auburn': 'Auburn',
      'copper': 'Cuivré',
      'blonde': 'Blond',
      'grey': 'Gris',
      'white': 'Blanc',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaFacialHair(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'Aucune',
      'stubble': 'Barbe de trois jours',
      'moustache': 'Moustache',
      'beard': 'Barbe',
      'fullBeard': 'Barbe fournie',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaEyewear(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'Aucune',
      'round': 'Lunettes rondes',
      'square': 'Lunettes carrées',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaMark(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'Aucun',
      'freckles': 'Taches de rousseur',
      'beautyMark': 'Grain de beauté',
      'vitiligo': 'Vitiligo',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaExpression(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'calm': 'Calme',
      'smile': 'Sourire',
      'focused': 'Concentration',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHeadwear(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'Aucun',
      'headscarf': 'Foulard',
      'turban': 'Turban',
      'hood': 'Capuche',
      'circlet': 'Diadème',
      'laurel': 'Couronne de laurier',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaGarment(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'tunic': 'Tunique',
      'cloak': 'Cape',
      'robe': 'Robe longue',
      'wrap': 'Drapé',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaGarmentColor(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'forest': 'Forêt',
      'olive': 'Olive',
      'sand': 'Sable',
      'ivory': 'Ivoire',
      'sage': 'Sauge',
      'indigo': 'Indigo',
      'crimson': 'Cramoisi',
      'bronze': 'Bronze',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaAccessory(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'Aucun',
      'satchel': 'Besace',
      'scroll': 'Parchemin',
      'compass': 'Boussole',
      'amulet': 'Amulette de Tanit',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaSigil(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'Aucune',
      'elephant': 'Éléphant',
      'sun': 'Soleil levant',
      'path': 'Chemin',
      'compass': 'Boussole',
      'star': 'Étoile polaire',
      'laurel': 'Laurier',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String get personaBuilderSurprise => 'Surprenez-moi';

  @override
  String get personaBuilderSurprised => 'Nouvelle allure. Non enregistrée.';

  @override
  String get personaBuilderUndo => 'Annuler';

  @override
  String get personaBuilderParts => 'Parties de l’avatar';

  @override
  String personaBuilderPartLabel(String category, String value) {
    return '$category : $value';
  }

  @override
  String personaBuilderPreviewLabel(String parts) {
    return 'Aperçu de l’avatar. $parts';
  }

  @override
  String get personaBuilderLockedNote =>
      'Les extras verrouillés s’ouvrent avec des récompenses.';

  @override
  String get personaBuilderKept => 'À vous pour de bon';

  @override
  String get personaBuilderHiddenSilhouette =>
      'Choisissez une couleur de peau pour voir le visage et les couleurs.';

  @override
  String get personaBuilderHiddenHeadwear =>
      'Les cheveux sont cachés sous votre couvre-chef.';

  @override
  String get personaBuilderMottoLabel => 'Devise (facultatif)';

  @override
  String get personaBuilderMottoHint => 'Quelques mots à vous';

  @override
  String personaBuilderMottoCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get personaBuilderMottoTooLong =>
      'Un peu trop longue. Raccourcissez-la pour enregistrer.';

  @override
  String personaBuilderMottoQuoted(String motto) {
    return '« $motto »';
  }

  @override
  String get personaBuilderSaved => 'Avatar enregistré.';

  @override
  String get personaBuilderNotSaved =>
      'Pas encore enregistré sur ce téléphone. Réessayez en haut, ou exportez une copie.';

  @override
  String get personaBuilderRemove => 'Retirer l’avatar';

  @override
  String get personaBuilderRemoveTitle => 'Retirer votre avatar ?';

  @override
  String get personaBuilderRemoveBody =>
      'Votre profil affiche à nouveau l’emblème. Créez-en un autre quand vous voulez.';

  @override
  String get personaBuilderRemoveAction => 'Retirer';

  @override
  String get personaBuilderRemoved => 'Avatar retiré.';

  @override
  String get personaBuilderRemovedNotSaved =>
      'Retiré ici, mais pas encore enregistré sur ce téléphone. Réessayez en haut.';

  @override
  String get personaBuilderLeaveTitle => 'Partir sans enregistrer ?';

  @override
  String get personaBuilderLeaveBody =>
      'Les changements de l’avatar ne seront pas gardés.';

  @override
  String get personaBuilderLeaveAction => 'Partir';

  @override
  String get personaBuilderKeepEditing => 'Continuer à modifier';

  @override
  String get personaBuilderProfileHint =>
      'Le prénom et l’avatar sont facultatifs et restent sur ce téléphone.';

  @override
  String get projectsPictureTitle => 'Image';

  @override
  String get projectsPictureEmpty =>
      'Une scène peinte ou une photo. Elle s’affiche sur les tâches du projet.';

  @override
  String get projectsPictureChoose => 'Choisir une image';

  @override
  String get projectsPictureChange => 'Changer d’image';

  @override
  String get projectsPictureRemove => 'Retirer l’image';

  @override
  String get projectsPictureRemoved => 'Image retirée';

  @override
  String get projectsPhotoRemoveTitle => 'Retirer la photo ?';

  @override
  String get projectsPhotoRemoveBody =>
      'Elle est supprimée de l’app. Les photos de votre galerie ne sont pas touchées.';

  @override
  String get projectsPhotoRemoveConfirm => 'Retirer la photo';

  @override
  String get projectsClearBodyPhoto =>
      'Son titre, ses jalons, ses notes et sa photo disparaissent. Votre Boussole, vos tâches et vos essais restent.';

  @override
  String get projectsDeleteFinishInstead => 'Plutôt terminer et garder';

  @override
  String get projectsDeletedCurrent => 'Projet supprimé';

  @override
  String projectsPictureLabel(String name) {
    return 'Image du projet : $name';
  }

  @override
  String get projectsPhotoName => 'votre photo';

  @override
  String get projectsPhotoMissing => 'Photo introuvable sur ce téléphone';

  @override
  String get projectsArtSheetTitle => 'Image du projet';

  @override
  String get projectsArtScenes => 'Scènes peintes';

  @override
  String get projectsArtPhoto => 'Votre photo';

  @override
  String get projectsArtPhotoNote => 'Les photos restent sur ce téléphone.';

  @override
  String get projectsArtChoosePhoto => 'Choisir une photo';

  @override
  String get projectsArtTakePhoto => 'Prendre une photo';

  @override
  String get projectsArtAdding => 'Ajout de la photo…';

  @override
  String get projectsArtSelected => 'Sélectionnée';

  @override
  String get projectsArtReplacesPhoto =>
      'Choisir une autre image supprime votre photo de l’app.';

  @override
  String get projectsArtSunrise => 'Lever du soleil';

  @override
  String get projectsArtPath => 'Route sinueuse';

  @override
  String get projectsArtCompass => 'Colline à la boussole';

  @override
  String get projectsArtSteps => 'Marches de pierre';

  @override
  String get projectsArtDawnRuins => 'Ruines à l’aube';

  @override
  String get projectsArtRoots => 'Racines profondes';

  @override
  String get projectsArtCitadel => 'Village perché';

  @override
  String get projectsArtSailing => 'En mer';

  @override
  String get projectsArtRoute => 'Route du sommet';

  @override
  String get projectsPhotoDeniedCamera =>
      'L’accès à l’appareil photo est coupé. Autorisez-le dans les Réglages, ou choisissez une photo ou une scène peinte.';

  @override
  String get projectsPhotoDeniedLibrary =>
      'L’accès aux photos est coupé. Autorisez-le dans les Réglages, ou choisissez une scène peinte.';

  @override
  String get projectsPhotoNoCamera =>
      'Pas d’appareil photo ici. Choisissez une photo ou une scène peinte.';

  @override
  String get projectsPhotoNoLibrary =>
      'Les photos ne sont pas disponibles ici. Choisissez une scène peinte.';

  @override
  String get projectsPhotoFailed =>
      'La photo n’a pas pu être récupérée. Réessayez, ou choisissez une scène peinte.';

  @override
  String get projectsPhotoTooLarge =>
      'Cette photo est trop lourde pour être gardée. Essayez-en une autre.';

  @override
  String get projectsPhotoNotKept =>
      'La photo n’a pas pu être gardée sur ce téléphone. Vérifiez l’espace libre et réessayez.';

  @override
  String get projectsNotSaved =>
      'Pas encore enregistré. Utilisez Réessayer sur cette page.';

  @override
  String get projectsFinish => 'Terminer ce projet';

  @override
  String get projectsFinishSheetBody =>
      'Il rejoint votre historique avec ses jalons, ses tâches et ses essais.';

  @override
  String get projectsFinishConfirm => 'Terminer et garder';

  @override
  String get projectsFinishedSnack => 'Gardé dans l’historique de vos projets.';

  @override
  String get projectsFinishedTitle => 'Terminé et gardé';

  @override
  String projectsFinishedBody(String title) {
    return '« $title » est dans l’historique de vos projets.';
  }

  @override
  String get projectsPlanNext => 'Prévoir le suivant';

  @override
  String get projectsViewHistory => 'Voir l’historique';

  @override
  String projectsHistoryLink(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Historique des projets · $count',
      one: 'Historique des projets · $count',
    );
    return '$_temp0';
  }

  @override
  String get projectsCardNext => 'Prévoyez votre prochain projet.';

  @override
  String get projectsHistoryTitle => 'Projets passés';

  @override
  String get projectsHistorySubtitle =>
      'Ce que vous avez construit, mois après mois.';

  @override
  String get projectsHistoryEmptyTitle => 'Rien ici pour l’instant';

  @override
  String get projectsHistoryEmptyBody =>
      'Terminez un projet du mois pour le garder ici.';

  @override
  String projectsMonths(String start, String end) {
    return '$start – $end';
  }

  @override
  String projectsTasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '$count tâche',
      zero: 'Aucune tâche',
    );
    return '$_temp0';
  }

  @override
  String projectsAttemptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count essais',
      one: '$count essai',
      zero: 'Aucun essai',
    );
    return '$_temp0';
  }

  @override
  String get projectsNoMilestones => 'Aucun jalon';

  @override
  String get projectsRetroEmpty => 'Aucune note écrite.';

  @override
  String get projectsPastTitle => 'Projet passé';

  @override
  String projectsFinishedOn(String date) {
    return 'Terminé le $date';
  }

  @override
  String get projectsMilestoneDone => 'Franchi';

  @override
  String get projectsMilestoneOpen => 'À faire';

  @override
  String get projectsTasks => 'Tâches';

  @override
  String get projectsTasksEmpty => 'Aucune tâche reliée.';

  @override
  String get projectsAttempts => 'Essais';

  @override
  String get projectsAttemptsEmpty => 'Aucun essai relié.';

  @override
  String get projectsTaskDone => 'Faite';

  @override
  String get projectsDelete => 'Retirer de l’historique';

  @override
  String get projectsDeleteTitle => 'Retirer ce projet ?';

  @override
  String get projectsDeleteBody =>
      'Son titre, ses jalons, ses notes et son image disparaissent. Ses tâches et ses essais restent.';

  @override
  String get projectsDeleteConfirm => 'Retirer';

  @override
  String get projectsDeleted => 'Projet retiré';

  @override
  String projectsTagLabel(String title) {
    return 'Projet : $title';
  }

  @override
  String get projectsQuestLink => 'Fait partie du projet du mois';

  @override
  String get projectsQuestLinkPast => 'Fait partie d’un projet terminé';

  @override
  String projectsKeepsakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Projets terminés',
      one: 'Projet terminé',
    );
    return '$_temp0';
  }

  @override
  String projectsKeepsakesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count projets gardés',
      one: '$count projet gardé',
    );
    return '$_temp0';
  }

  @override
  String get resetTitle => 'Le Recentrage';

  @override
  String get resetSubtitle =>
      'Une journée pour voir où vous en êtes et choisir où aller.';

  @override
  String get resetPaceOneDayTitle => 'Votre rythme : une journée';

  @override
  String get resetPaceOneDayBody =>
      'Matin, journée, soir. Rien ne se verrouille si cela prend plus longtemps.';

  @override
  String get resetPaceFlexibleTitle => 'Votre rythme : libre';

  @override
  String get resetPaceFlexibleBody =>
      'Tout ordre, tout rythme. Rien ne se verrouille ni n’expire.';

  @override
  String get resetPaceChange => 'Changer de rythme';

  @override
  String get resetProgressTitle => 'Votre recentrage';

  @override
  String resetProgressCount(int answered, int total) {
    return 'Réponses : $answered sur $total questions principales';
  }

  @override
  String resetProgressNext(String title) {
    return 'Ensuite : $title';
  }

  @override
  String get resetBegin => 'Commencer';

  @override
  String get resetContinue => 'Continuer';

  @override
  String get resetAllDoneBody =>
      'Chaque question principale a une réponse ou a été passée. Vous pouvez encore les modifier.';

  @override
  String get resetSeeCreated => 'Voir ce que vous avez créé';

  @override
  String resetCompletedOn(String date) {
    return 'Terminé le $date. Les réponses restent modifiables.';
  }

  @override
  String get resetPhasesTitle => 'Votre journée';

  @override
  String get resetPhaseMorning => 'Matin';

  @override
  String get resetPhaseDaytime => 'Journée';

  @override
  String get resetPhaseBonus => 'Facultatif';

  @override
  String get resetPhaseEvening => 'Soir';

  @override
  String get resetSubflowMirror => 'Le Miroir';

  @override
  String get resetSubflowVision => 'La Vision';

  @override
  String get resetSubflowInterrupt => 'L’Interruption';

  @override
  String get resetSubflowBreakthrough => 'La Percée';

  @override
  String get resetMirrorBody => 'Réalité actuelle, futurs possibles, identité';

  @override
  String get resetVisionBody =>
      'Une bonne journée ordinaire, qui devenir, un pas';

  @override
  String get resetInterruptBody =>
      'Six courtes pauses à différents moments de la journée';

  @override
  String get resetBreakthroughBody => 'Prises de conscience, direction et plan';

  @override
  String get resetGroupCurrentReality => 'Réalité actuelle';

  @override
  String get resetGroupAntiVision => 'Un avenir dont vous ne voulez pas';

  @override
  String get resetGroupIdentity => 'Identité';

  @override
  String get resetGroupVision => 'Vision';

  @override
  String get resetGroupInterrupt => 'Pause';

  @override
  String get resetGroupContemplation => 'Contemplation';

  @override
  String get resetGroupInsight => 'Prises de conscience';

  @override
  String get resetGroupDirection => 'Direction';

  @override
  String get resetGroupPlan => 'Plan';

  @override
  String resetCountAnswered(int answered, int total) {
    return 'Réponses : $answered sur $total';
  }

  @override
  String resetCountAnsweredSkipped(int answered, int total, int skipped) {
    return 'Réponses : $answered sur $total, $skipped passées';
  }

  @override
  String get resetCountNotStarted => 'Pas encore commencé';

  @override
  String resetRingLabel(int answered, int total) {
    return '$answered/$total';
  }

  @override
  String resetOpenPhase(String phase) {
    return 'Ouvrir les questions : $phase';
  }

  @override
  String get resetStateAnswered => 'Réponse écrite';

  @override
  String get resetStateSkipped => 'Passée';

  @override
  String get resetStateOpen => 'Pas encore de réponse';

  @override
  String get resetStateCurrent => 'Vous êtes ici';

  @override
  String resetCheckinTime(String time) {
    return 'Pause · $time';
  }

  @override
  String get resetOptionalTitle => 'Contemplations facultatives';

  @override
  String get resetOptionalBody => 'Trois questions en plus. Facultatif.';

  @override
  String get resetOptionalChip => 'Facultatif';

  @override
  String get resetPastTitle => 'Recentrages passés';

  @override
  String resetPastStarted(String date) {
    return 'Commencé le $date';
  }

  @override
  String resetPastFinished(String date) {
    return 'Terminé le $date';
  }

  @override
  String get resetPastUnfinished => 'Pas terminé';

  @override
  String resetPastAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '$count réponse',
      zero: 'Aucune réponse',
    );
    return '$_temp0';
  }

  @override
  String get resetNewTitle => 'Commencer un nouveau recentrage';

  @override
  String get resetNewBody =>
      'Repartez à neuf. Celui-ci reste dans Recentrages passés.';

  @override
  String get resetNewConfirmTitle => 'Commencer un nouveau recentrage ?';

  @override
  String get resetNewConfirmBody =>
      'Vos réponses passent dans Recentrages passés. Boussole, quêtes et journal restent.';

  @override
  String get resetNewConfirmAction => 'Nouveau recentrage';

  @override
  String get resetNewStarted =>
      'Nouveau recentrage commencé. Le précédent est dans Recentrages passés.';

  @override
  String resetQuestionOf(int n, int total) {
    return 'Question $n sur $total';
  }

  @override
  String get resetPauseTooltip => 'Faire une pause et revenir au Recentrage';

  @override
  String get resetJumpTooltip => 'Aller à une question';

  @override
  String get resetJump => 'Aller à';

  @override
  String resetJumpTitle(String phase) {
    return 'Questions : $phase';
  }

  @override
  String get resetSofter => 'Version plus douce';

  @override
  String get resetSofterHint => 'La même question, posée plus doucement.';

  @override
  String get resetHelpLink => 'Qu’est-ce que cela veut dire ?';

  @override
  String get resetExampleTitle => 'Exemple, pas une bonne réponse';

  @override
  String get resetAnswerLabel => 'Votre réponse';

  @override
  String get resetAnswerHint => 'Écrivez autant ou aussi peu que vous voulez.';

  @override
  String get resetSkippedNote =>
      'Passée. Revenez quand vous voulez, ou laissez-la.';

  @override
  String get resetSaveContinue => 'Enregistrer et continuer';

  @override
  String get resetSaveFinish => 'Enregistrer et terminer';

  @override
  String get resetSkip => 'Passer pour l’instant';

  @override
  String get resetPause => 'Pause';

  @override
  String get resetHeavyLink => 'C’est lourd ?';

  @override
  String get resetHeavyTitle => 'Cela peut faire beaucoup';

  @override
  String get resetHeavyBody =>
      'Allez aussi loin que vous voulez : adoucissez, passez ou arrêtez. Vos mots sont enregistrés.';

  @override
  String get resetHeavySofter => 'Passer à la version plus douce';

  @override
  String get resetHeavySkip => 'Passer cette question';

  @override
  String get resetHeavyPause => 'Faire une pause';

  @override
  String get resetHeavySupport => 'Aide et sécurité';

  @override
  String get resetHeavyCrisis =>
      'Cartharise n’est pas une thérapie. Si vous ne vous sentez pas en sécurité, contactez maintenant les urgences ou une ligne d’écoute.';

  @override
  String get resetPromptMissing => 'Cette question n’est pas disponible.';

  @override
  String get resetCompleteTitle => 'Recentrage terminé';

  @override
  String get resetCompleteLead =>
      'Une journée peut éclairer ; le reste, c’est de la pratique.';

  @override
  String get resetCompleteCreatedTitle => 'Ce que vous avez créé';

  @override
  String resetCompleteAnswers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses écrites',
      one: '$count réponse écrite',
      zero: 'Aucune réponse écrite',
    );
    return '$_temp0';
  }

  @override
  String resetCompleteSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions passées',
      one: '$count question passée',
    );
    return '$_temp0';
  }

  @override
  String resetCompletePhaseLine(String phase, int answered, int total) {
    return '$phase · réponses : $answered sur $total';
  }

  @override
  String get resetCompleteVisionTitle => 'Votre vision, avec vos mots';

  @override
  String resetCompleteOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions principales restent ouvertes.',
      one: '$count question principale reste ouverte.',
    );
    return '$_temp0';
  }

  @override
  String get resetCompleteCompassBody =>
      'Vos réponses du soir peuvent lancer votre Boussole de vie. Vous choisissez ; rien n’est écrasé.';

  @override
  String get resetCompleteBuildCompass => 'Construire votre Boussole';

  @override
  String get resetCompleteLater => 'Plus tard';

  @override
  String sceneryRouteScene(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'carthage': 'Carthage : des navires dans le port circulaire à l’aube',
      'newCarthage':
          'Carthagène : des maisons blanches au-dessus d’une baie calme',
      'ebro': 'L’Èbre : un large fleuve qui serpente dans la plaine',
      'pyrenees': 'Les Pyrénées : un col élevé entre des sommets enneigés',
      'rhone': 'Le Rhône : un éléphant traverse le fleuve sur un radeau',
      'alps': 'Les Alpes : un sentier monte vers la neige au clair de lune',
      'italy': 'L’Italie : des cyprès et des champs au soleil du matin',
      'other': 'Un paysage sur la route',
    });
    return '$_temp0';
  }

  @override
  String get sceneryKeepsakesTitle => 'Souvenirs';

  @override
  String get sceneryKeepsakesLine =>
      'Essayez une expérience d’un chapitre pour garder son souvenir.';

  @override
  String sceneryKeepsakeName(String chapter) {
    String _temp0 = intl.Intl.selectLogic(chapter, {
      'terrain': 'Longue-vue',
      'pattern': 'Carreau de mosaïque',
      'banner': 'Bannière',
      'autopilot': 'Sablier',
      'plan': 'Rouleau',
      'other': 'Souvenir',
    });
    return '$_temp0';
  }

  @override
  String sceneryKeepsakeKept(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gardé · $count expériences',
      one: 'Gardé · 1 expérience',
    );
    return '$_temp0';
  }

  @override
  String get sceneryKeepsakeNotYet => 'Pas encore';

  @override
  String sceneryKeepsakeLabel(String name, String chapter, String status) {
    return '$name, $chapter : $status';
  }

  @override
  String todayGreetingMorning(String name) {
    return 'Bonjour, $name.';
  }

  @override
  String todayGreetingAfternoon(String name) {
    return 'Bon après-midi, $name.';
  }

  @override
  String todayGreetingEvening(String name) {
    return 'Bonsoir, $name.';
  }

  @override
  String get todayDefaultName => 'âme voyageuse';

  @override
  String get todaySubtitle => 'La clarté aujourd’hui. Le progrès demain.';

  @override
  String get todayNextEyebrow => 'Votre prochaine étape';

  @override
  String get todayNextStartTitle => 'Commencer la réflexion du matin';

  @override
  String todayNextStartBody(int count) {
    return '$count courtes questions. Passez ou faites une pause à tout moment.';
  }

  @override
  String get todayNextStartHint =>
      'Matin, journée, soir : un jour, à votre rythme.';

  @override
  String get todayNextStartAction => 'Commencer';

  @override
  String todayNextLessonsAction(int count) {
    return 'Découvrir les $count idées (facultatif)';
  }

  @override
  String todayNextResumeTitle(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'morning': 'Reprendre la réflexion du matin',
      'daytime': 'Reprendre les pauses de la journée',
      'evening': 'Reprendre la réflexion du soir',
      'other': 'Reprendre votre recentrage',
    });
    return '$_temp0';
  }

  @override
  String todayNextResumeBody(String title) {
    return 'Ensuite : $title';
  }

  @override
  String todayNextResumePosition(String phase, int ordinal, int total) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'morning': 'Matin',
      'daytime': 'Journée',
      'evening': 'Soir',
      'other': 'Recentrage',
    });
    return '$_temp0 · question $ordinal sur $total';
  }

  @override
  String get todayNextResumeAction => 'Reprendre';

  @override
  String get todayNextQuestBody => 'Une des quêtes du jour.';

  @override
  String get todayNextQuestAction => 'Marquer comme faite';

  @override
  String get todayNextQuestOption => 'Faire une quête du jour';

  @override
  String get todayNextCompassTitle => 'Construire votre Boussole';

  @override
  String get todayNextCompassImportBody =>
      'Vos réponses du soir peuvent remplir votre Boussole. Vous choisissez.';

  @override
  String get todayNextCompassManualBody =>
      'Écrivez votre vision, un projet du mois et vos leviers quotidiens.';

  @override
  String get todayNextCompassImportAction => 'Revoir vos réponses';

  @override
  String get todayNextLeversTitle => 'Faire de vos leviers des quêtes';

  @override
  String get todayNextLeversBody =>
      'Vos leviers quotidiens, en petites quêtes.';

  @override
  String get todayNextLeversAction => 'Choisir des quêtes';

  @override
  String get todayNextProjectTitle => 'Avancer sur votre projet';

  @override
  String todayNextProjectNext(String milestone) {
    return 'Ensuite : $milestone';
  }

  @override
  String get todayNextProjectAction => 'Ouvrir le projet';

  @override
  String get todayNextReviewTitle => 'Regarder votre semaine';

  @override
  String get todayNextReviewBody => 'Ce qui a marché, ce qui a gêné, la suite.';

  @override
  String get todayNextReviewAction => 'Faire un bilan de la semaine';

  @override
  String get todayNextJournalTitle => 'Écrire une note';

  @override
  String get todayNextJournalBody => 'Quelques lignes sur aujourd’hui.';

  @override
  String get todayNextJournalAction => 'Nouvelle note';

  @override
  String get todayOpenCompass => 'Ouvrir la Boussole';

  @override
  String get todayChooseOther => 'Choisir autre chose';

  @override
  String get todayChooseSteps => 'Autres étapes';

  @override
  String get todayPinTitle => 'Aidez-moi avec';

  @override
  String get todayPinProject => 'Mon projet';

  @override
  String get todayPinReflection => 'La réflexion';

  @override
  String get todayPinNotes => 'Les notes';

  @override
  String get todayPinAuto => 'Choisir pour moi';

  @override
  String get todayPinNoProject =>
      'Pas encore de projet. Aujourd’hui choisit pour l’instant.';

  @override
  String get todayDoneTitle =>
      'C’est fait. Cela peut suffire pour aujourd’hui.';

  @override
  String get todayDoneMore => 'Encore une';

  @override
  String get todayDoneMoreLabel => 'Montrer une autre étape';

  @override
  String get todayWriteHint => 'Écrivez quelques lignes…';

  @override
  String get todayWriteLabel => 'Écrire une nouvelle note';

  @override
  String get todayFocusTitle => 'Au programme';

  @override
  String get todayFocusEmptyTitle => 'Aucune quête aujourd’hui';

  @override
  String get todayFocusEmptyBody =>
      'Ajoutez une petite quête quand vous le souhaitez.';

  @override
  String get todayHintQuests =>
      'Les quêtes sont de petits pas que vous choisissez. Ajustez-les chaque semaine.';

  @override
  String get todayFocusAdd => 'Ajouter une quête';

  @override
  String todayFocusSeeAll(int count) {
    return 'Voir les $count quêtes';
  }

  @override
  String todayFocusLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres, sans date ou pour plus tard',
      one: '$count autre, sans date ou pour plus tard',
    );
    return '$_temp0';
  }

  @override
  String todayQuestMarkDone(String title) {
    return 'Marquer « $title » comme faite';
  }

  @override
  String get todayQuestDaily => 'Chaque jour';

  @override
  String todayJourneyWritten(int answered, int total) {
    return 'Réflexions écrites : $answered sur $total';
  }

  @override
  String get todayJourneyOpenReset => 'Ouvrir le recentrage';

  @override
  String todayPathDay(int day) {
    return 'Jour $day sur 30';
  }

  @override
  String todayPathOpen(int day) {
    return 'Ouvrir le jour $day';
  }

  @override
  String get todayDirectionTitle => 'Votre direction';

  @override
  String get todayDirectionSummary => 'Votre vision et le projet du mois.';

  @override
  String todayDirectionLabel(String title, String summary) {
    return '$title. $summary';
  }

  @override
  String get todayDirectionEmpty => 'Votre Boussole est vide.';

  @override
  String get todayHintCompass =>
      'Vos réponses peuvent devenir une Boussole de vie.';

  @override
  String get todayDirectionVision => 'Vision';

  @override
  String get todayDirectionMonth => 'Ce mois-ci';

  @override
  String get todayDirectionNoVision => 'Pas encore de vision écrite.';

  @override
  String get todayDirectionNoMonth => 'Pas encore de projet du mois.';

  @override
  String get todayTileReset => 'Réflexion';

  @override
  String todayTileResetValue(int answered, int total) {
    return '$answered/$total';
  }

  @override
  String get todayTileResetStart => 'Commencer';

  @override
  String get todayTileResetDone => 'Terminé';

  @override
  String get todayTileResetDetail => 'réponses';

  @override
  String get todayTileCampaign => 'Jeu';

  @override
  String todayTileCampaignValue(int level) {
    return 'Niveau $level';
  }

  @override
  String get todayTilePath => 'Parcours 30 jours';

  @override
  String todayTilePathValue(int day) {
    return 'Jour $day';
  }

  @override
  String todayPathStageName(String stage) {
    String _temp0 = intl.Intl.selectLogic(stage, {
      'observe': 'Observer',
      'experiment': 'Expérimenter',
      'build': 'Construire',
      'adjust': 'Ajuster',
      'other': 'Parcours',
    });
    return '$_temp0';
  }

  @override
  String todayTileLabel(String title, String value, String detail) {
    return '$title : $value. $detail';
  }

  @override
  String get voiceDictate => 'Dictate';

  @override
  String voiceDictateInto(String field) {
    return 'Dictate: $field';
  }

  @override
  String get voiceDictateHint =>
      'Speak, then check the text before it goes in.';

  @override
  String get voiceSheetTitle => 'Dictate';

  @override
  String get voiceStarting => 'Getting dictation ready…';

  @override
  String get voiceListening => 'Listening';

  @override
  String get voiceListeningStarted => 'Listening. Tap Stop when you\'re done.';

  @override
  String get voiceOnPhone => 'Recognised on this phone. Nothing is sent.';

  @override
  String get voiceHeardLabel => 'Heard so far';

  @override
  String get voiceSpeakNow => 'Speak. Your words appear here.';

  @override
  String get voiceStop => 'Stop';

  @override
  String get voiceCancel => 'Cancel';

  @override
  String get voiceFinishing => 'Finishing…';

  @override
  String get voiceReviewLabel => 'Dictated text';

  @override
  String get voiceReviewHint =>
      'Edit it if you like. It goes in only when you tap Insert.';

  @override
  String get voiceReviewReady => 'Done listening. Check the text, then Insert.';

  @override
  String get voiceStoppedEarly =>
      'Dictation stopped early. Here\'s what was heard.';

  @override
  String get voiceInsert => 'Insert';

  @override
  String get voiceDiscard => 'Discard';

  @override
  String get voiceDiscardTitle => 'Discard this text?';

  @override
  String get voiceDiscardBody => 'It won\'t be added.';

  @override
  String get voiceKeep => 'Keep';

  @override
  String get voiceInserted => 'Text inserted.';

  @override
  String get voiceUnsupported =>
      'Dictation in this language isn\'t available on this phone.';

  @override
  String get voiceNeedsModel =>
      'To dictate, add this language for offline speech in your phone\'s settings.';

  @override
  String get voiceNoPermission =>
      'Microphone or speech access is off. Allow it in Settings to dictate.';

  @override
  String get voiceTooOld =>
      'Dictation needs a newer system version on this phone.';

  @override
  String get voiceNothingHeard =>
      'Nothing was heard. Try again, or type instead.';

  @override
  String get voiceInterrupted =>
      'Dictation stopped: a call or another app took the microphone.';

  @override
  String get voiceBusy => 'Dictation is busy. Try again in a moment.';

  @override
  String get voiceFailed => 'Dictation stopped. Try again, or type instead.';

  @override
  String get voiceRecordInstead => 'Record instead';

  @override
  String get voiceTypeInstead => 'Type instead';

  @override
  String get youTitle => 'Vous';

  @override
  String get youSubtitle => 'Votre espace, vos choix.';

  @override
  String get youProfileEyebrow => 'Profil';

  @override
  String get youNoName => 'Aucun prénom';

  @override
  String get youProfileBody =>
      'Facultatif, reste sur ce téléphone. Touchez pour changer.';

  @override
  String get youEditName => 'Modifier le prénom';

  @override
  String get youNameDialogTitle => 'Votre prénom';

  @override
  String get youNameHint => 'Facultatif';

  @override
  String get youPaceTitle => 'Rythme';

  @override
  String get youPaceOneDay => 'Une journée';

  @override
  String get youPaceFlexible => 'Libre';

  @override
  String get youPaceHint => 'Sans verrou. Modifiable à tout moment.';

  @override
  String get youSectionCredit => 'Source';

  @override
  String get youSectionSettings => 'Réglages';

  @override
  String get youSectionCare => 'Prendre soin';

  @override
  String get youSectionAbout => 'À propos';

  @override
  String get youInspiration => 'Inspiration';

  @override
  String get youInspirationHint => 'L’article derrière Cartharise';

  @override
  String get youReminders => 'Rappels';

  @override
  String get youRemindersOn => 'Activés';

  @override
  String get youRemindersOff => 'Désactivés';

  @override
  String get youAppearance => 'Apparence';

  @override
  String youAppearanceSummary(String theme, String mode) {
    return '$theme · $mode';
  }

  @override
  String get youData => 'Vos données';

  @override
  String get youDataHint => 'Exporter, restaurer ou supprimer';

  @override
  String get youSupport => 'Aide et sécurité';

  @override
  String get youSupportHint => 'Pas une thérapie. De l’aide si c’est lourd.';

  @override
  String youVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get youAboutBody => 'Indépendante. Tout reste sur ce téléphone.';

  @override
  String get youLicences => 'Licences open source';

  @override
  String get youLicencesHint =>
      'Dont les polices Inter et Cinzel (SIL Open Font License)';

  @override
  String youLegalese(String title, String author) {
    return 'App indépendante inspirée de « $title » de $author. Ni affiliée à l’auteur, ni approuvée par lui.';
  }

  @override
  String get youReplayWelcome => 'Revoir l’accueil';

  @override
  String get youReplayWelcomeHint =>
      'Revoir l’introduction. Rien de ce que vous avez écrit ne change.';

  @override
  String get youReplayConfirmTitle => 'Revoir l’accueil ?';

  @override
  String get youReplayConfirmBody =>
      'Revoir l’introduction. Vos écrits et vos réglages restent.';

  @override
  String get youReplayConfirmAction => 'Montrer l’accueil';

  @override
  String get youInspirationTitle => 'Inspiration';

  @override
  String get youInspirationSubtitle => 'L’œuvre qui a inspiré Cartharise';

  @override
  String get youInspirationEyebrow => 'Inspiré par';

  @override
  String youInspirationByline(String author) {
    return 'par $author';
  }

  @override
  String youInspirationPublished(String date) {
    return 'Publié le $date';
  }

  @override
  String get youInspirationReadArticle => 'Lire l’article sur X';

  @override
  String get youInspirationReadNewsletter => 'Lire la version newsletter';

  @override
  String youInspirationLinkHint(String host) {
    return 'S’ouvre dans votre navigateur : $host';
  }

  @override
  String get youInspirationIndependentTitle => 'Une app indépendante';

  @override
  String get youInspirationParaphraseTitle => 'Avec les mots de Cartharise';

  @override
  String get youInspirationSplitTitle =>
      'De la source, ou ajouté par Cartharise ?';

  @override
  String get youInspirationFromSource => 'Tiré de l’article, reformulé';

  @override
  String get youInspirationSource1 =>
      'Les sept idées centrales des leçons de l’Éveil';

  @override
  String get youInspirationSource2 =>
      'Les questions du matin, de la journée et du soir';

  @override
  String get youInspirationSource3 => 'Les six parties de la Boussole de vie';

  @override
  String get youInspirationSource4 =>
      'Les six horaires des pauses de la journée';

  @override
  String get youInspirationAdded => 'Ajouté par Cartharise';

  @override
  String get youInspirationAdded1 =>
      'Les exemples, les aides et les versions plus douces';

  @override
  String get youInspirationAdded2 =>
      'Les quêtes, la vue Aujourd’hui et le parcours de trente jours';

  @override
  String get youInspirationAdded3 =>
      'Notes du journal, bilans de la semaine et regards en arrière';

  @override
  String get youInspirationAdded4 =>
      'Rappels, export vers le calendrier et sauvegardes';

  @override
  String get youInspirationReadOriginal =>
      'Pour tout le raisonnement de l’auteur, lisez l’original.';

  @override
  String get youRemindersTitle => 'Rappels';

  @override
  String get youRemindersSubtitle => 'Six pauses facultatives dans la journée.';

  @override
  String get youRemindersSwitch => 'Notifications des pauses';

  @override
  String get youRemindersSwitchOn => 'Activées, aux heures ci-dessous.';

  @override
  String get youRemindersSwitchOff =>
      'Désactivées. Rien n’est envoyé tant que vous ne les activez pas.';

  @override
  String get youRemindersPrivacy =>
      'Les notifications montrent seulement le titre de la pause, jamais vos mots.';

  @override
  String get youRemindersDeniedTitle =>
      'Les notifications ne sont pas autorisées';

  @override
  String get youRemindersDeniedBody =>
      'Les notifications sont bloquées pour Cartharise. Autorisez-les dans les réglages du téléphone, ou ajoutez les pauses à votre calendrier.';

  @override
  String get youRemindersUnavailableTitle =>
      'Les notifications ne sont pas disponibles';

  @override
  String get youRemindersUnavailableBody =>
      'Ce téléphone ne peut pas afficher de notifications. Ajoutez plutôt les pauses à votre calendrier.';

  @override
  String get youRemindersScheduleFailed =>
      'Les notifications n’ont pas pu être programmées. Réessayez, ou utilisez votre calendrier.';

  @override
  String get youRemindersCalendarInstead => 'Les ajouter plutôt au calendrier';

  @override
  String get youRemindersTimesTitle => 'Horaires des pauses';

  @override
  String get youRemindersTimesBody =>
      'Heure locale. Adaptez chacune à votre journée.';

  @override
  String youRemindersSourceDefault(String time) {
    return 'Par défaut dans la source : $time';
  }

  @override
  String youRemindersUseDefault(String time) {
    return 'Utiliser $time';
  }

  @override
  String youRemindersChangeTime(String title, String time) {
    return 'Changer l’heure de $title, actuellement $time';
  }

  @override
  String youRemindersRowLabel(String title, String time) {
    return 'Pause $title, $time';
  }

  @override
  String get youRemindersQuietTitle => 'Heures calmes';

  @override
  String get youRemindersQuietBody =>
      'Aucune notification de pause entre ces heures.';

  @override
  String get youRemindersQuietFrom => 'De';

  @override
  String get youRemindersQuietUntil => 'À';

  @override
  String get youRemindersQuietNotSet => 'Non défini';

  @override
  String get youRemindersQuietClear => 'Effacer les heures calmes';

  @override
  String get youRemindersQuietIncomplete =>
      'Indiquez les deux heures pour activer les heures calmes.';

  @override
  String get youRemindersCalendarTitle => 'Ajouter à votre calendrier';

  @override
  String get youRemindersCalendarBody =>
      'Un fichier calendrier avec vos pauses sur 30 jours. Titres seulement.';

  @override
  String get youRemindersCalendarButton => 'Ajouter au calendrier (.ics)';

  @override
  String get youRemindersCalendarNone =>
      'Activez au moins une pause pour créer le fichier.';

  @override
  String get youCalendarName => 'Pauses Cartharise';

  @override
  String youCalendarEventTitle(String title) {
    return 'Pause Cartharise : $title';
  }

  @override
  String get youCalendarEventDescription =>
      'Une courte pause dans la journée, issue de votre recentrage Cartharise. Ouvrez l’app quand cela vous convient ; chaque pause est facultative.';

  @override
  String get youRemindersCalendarShared =>
      'Fichier calendrier partagé. Ouvrez-le dans votre app de calendrier.';

  @override
  String get youShareDismissed => 'Rien n’a été partagé.';

  @override
  String get youAppearanceTitle => 'Apparence';

  @override
  String get youAppearanceSubtitle =>
      'Langue, couleurs, clair ou sombre, et animations.';

  @override
  String get youLanguageTitle => 'Langue';

  @override
  String get youLanguageSystem => 'Comme le téléphone';

  @override
  String youLanguageSystemNow(String language) {
    return 'Actuellement : $language';
  }

  @override
  String get youLanguageNote =>
      'Les leçons et les questions changent aussi. Vos mots restent tels que vous les avez écrits.';

  @override
  String get youThemeTitle => 'Thème';

  @override
  String get youThemeForest => 'Forêt';

  @override
  String get youThemeOlive => 'Olivier';

  @override
  String get youThemeOasis => 'Oasis';

  @override
  String get youThemeTyrian => 'Rose de Tyr';

  @override
  String get youThemeAlpine => 'Alpes';

  @override
  String get youThemeObsidian => 'Obsidienne';

  @override
  String get youThemeAboutForest =>
      'Forêt profonde et bronze : l’original de Cartharise.';

  @override
  String get youThemeAboutOlive => 'Les oliveraies de la campagne punique.';

  @override
  String get youThemeAboutOasis =>
      'Le vert des palmiers et l’or des dattes des oasis du désert.';

  @override
  String get youThemeAboutTyrian =>
      'La teinture rose de Tyr, la cité mère de Carthage.';

  @override
  String get youThemeAboutAlpine =>
      'Granit et neige, là où Hannibal a franchi les Alpes.';

  @override
  String get youThemeAboutObsidian =>
      'Verre volcanique noir et or. Vrai noir en mode sombre.';

  @override
  String get youModeTitle => 'Clair ou sombre';

  @override
  String get youModeSystem => 'Système';

  @override
  String get youModeLight => 'Clair';

  @override
  String get youModeDark => 'Sombre';

  @override
  String get youMotion => 'Animations de l’interface';

  @override
  String get youMotionHint =>
      'Transitions d’écran et emblème animé. Coupées quand votre téléphone réduit les animations.';

  @override
  String get youDataTitle => 'Vos données';

  @override
  String get youDataSubtitle =>
      'Tout ce que vous écrivez reste sur ce téléphone.';

  @override
  String get youDataWhereTitle => 'Où vivent vos données';

  @override
  String get youDataExportTitle => 'Exporter une sauvegarde';

  @override
  String get youDataExportBody =>
      'Enregistre tout, photos et enregistrements compris, dans un seul fichier .zip. Il n’est pas chiffré : gardez-le en lieu sûr.';

  @override
  String get youDataExportButton => 'Exporter la sauvegarde';

  @override
  String get youDataExported => 'Sauvegarde partagée.';

  @override
  String get youDataExportedPartial =>
      'Sauvegarde partagée, mais certaines photos ou certains enregistrements n’ont pas pu être lus et n’y sont pas.';

  @override
  String get youDataImportTitle => 'Restaurer une sauvegarde';

  @override
  String get youDataImportBody =>
      'Remplace tout par une sauvegarde. Vous confirmerez d’abord.';

  @override
  String get youDataImportButton => 'Choisir un fichier de sauvegarde';

  @override
  String get youDataImportConfirmTitle => 'Restaurer cette sauvegarde ?';

  @override
  String youDataImportConfirmBody(String date) {
    return 'Remplacer tout ce qui est sur ce téléphone par cette sauvegarde ($date) ?';
  }

  @override
  String get youDataImportConfirmAction => 'Remplacer';

  @override
  String get youDataImportUnknownDate => 'date inconnue';

  @override
  String youDataImportMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count photos ou enregistrements cités sont absents. Leurs éléments sont gardés.',
      one: 'Une photo ou un enregistrement cité est absent. Son élément est gardé.',
    );
    return '$_temp0';
  }

  @override
  String get youDataImportFilesFailed =>
      'Ses photos et enregistrements n’ont pas pu être gardés sur ce téléphone.';

  @override
  String get youDataImported => 'Sauvegarde restaurée.';

  @override
  String get youDataImportedNotSaved =>
      'Sauvegarde ouverte mais pas encore enregistrée. Réessayez en haut, ou exportez une copie.';

  @override
  String get youDataImportFailedTitle => 'Ce fichier n’a pas pu être utilisé';

  @override
  String get youDataImportUnchanged =>
      'Vos données actuelles n’ont pas changé.';

  @override
  String get youDataImportNotJson =>
      'Ce n’est pas un fichier de sauvegarde lisible.';

  @override
  String get youDataImportNotBackup =>
      'Ce n’est pas une sauvegarde Cartharise.';

  @override
  String get youDataImportUnsupported =>
      'Ce format de sauvegarde n’est pas pris en charge par cette version.';

  @override
  String get youDataImportDamaged => 'La sauvegarde est incomplète ou abîmée.';

  @override
  String get youDataImportTooLarge =>
      'Le fichier est trop lourd pour être une sauvegarde Cartharise.';

  @override
  String get youDataImportNotText => 'Ce n’est pas un fichier texte.';

  @override
  String get youDataImportOpenFailed => 'Le fichier n’a pas pu s’ouvrir.';

  @override
  String get youDataDeleteTitle => 'Supprimer toutes les données';

  @override
  String get youDataDeleteBody =>
      'Efface tout sur ce téléphone et annule les rappels. Exportez d’abord pour garder une copie.';

  @override
  String get youDataDeleteButton => 'Supprimer toutes les données';

  @override
  String get youDataDeleteConfirm1Title => 'Supprimer toutes les données ?';

  @override
  String get youDataDeleteConfirm1Body =>
      'Réponses, Boussole, quêtes, notes, photos, enregistrements, bilans et réglages seront effacés.';

  @override
  String get youDataDeleteConfirm1Action => 'Continuer';

  @override
  String get youDataDeleteConfirm2Title => 'C’est définitif';

  @override
  String get youDataDeleteConfirm2Body =>
      'Il n’existe pas d’autre copie. Seule une sauvegarde exportée peut tout ramener.';

  @override
  String get youDataDeleteConfirm2Action => 'Tout supprimer';

  @override
  String get youDataDeleteFailed =>
      'La suppression n’a pas abouti. Vos écrits sont toujours là ; réessayez.';

  @override
  String get youDataDeleteCopiesLeft =>
      'Supprimé, mais une copie d’export temporaire n’a pas pu être retirée. Désinstaller l’app l’efface.';

  @override
  String get youDataDeleteFilesLeft =>
      'Supprimé, mais certaines photos ou certains enregistrements n’ont pas encore pu être retirés. Rouvrir l’app les retire.';

  @override
  String get youSupportTitle => 'Aide et sécurité';

  @override
  String get youSupportSubtitle =>
      'Réfléchir peut remuer des choses. C’est normal.';

  @override
  String get youSupportNotTherapyTitle => 'Pas une thérapie';

  @override
  String get youSupportNotTherapyBody =>
      'Un outil de réflexion personnelle. Ni thérapie, ni accompagnement psychologique, ni avis médical, ni diagnostic.';

  @override
  String get youSupportHeavyTitle => 'Si une question pèse';

  @override
  String get youSupportHeavy1 => 'Passez-la. Chaque question est facultative.';

  @override
  String get youSupportHeavy2 =>
      'Choisissez la version plus douce quand elle existe.';

  @override
  String get youSupportHeavy3 =>
      'Faites une pause et revenez un autre jour. Vos mots sont gardés.';

  @override
  String get youSupportHeavy4 => 'Parlez-en à une personne de confiance.';

  @override
  String get youSupportCrisisTitle => 'En cas de crise';

  @override
  String get youSupportCrisisBody =>
      'En danger, ou envie de vous faire du mal ? Contactez tout de suite les urgences, ou une ligne d’écoute de votre pays.';

  @override
  String get youSupportFindHelpline => 'Trouver une ligne d’écoute';

  @override
  String get youSupportHelplineHint =>
      'Ouvre findahelpline.com, des lignes d’écoute par pays.';

  @override
  String get youSupportOngoingTitle => 'Un soutien dans la durée';

  @override
  String get youSupportOngoingBody =>
      'Si les sentiments difficiles durent, un médecin ou un psychologue peut aider.';
}
