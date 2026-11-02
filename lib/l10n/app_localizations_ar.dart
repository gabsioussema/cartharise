// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Cartharise';

  @override
  String get appTagline => 'إتقانٌ للذات. نهوضٌ بغاية.';

  @override
  String get appPromise => 'فهمٌ للذات. اختيارٌ للطريق. نهوضٌ بغاية.';

  @override
  String get tabToday => 'اليوم';

  @override
  String get tabReset => 'إعادة ضبط';

  @override
  String get tabCompass => 'البوصلة';

  @override
  String get tabJournal => 'اليوميات';

  @override
  String get tabYou => 'أنت';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get skip => 'تخطٍّ';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تمّ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get close => 'إغلاق';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get keepGoing => 'متابعة';

  @override
  String get tryAgain => 'المحاولة مجددًا';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get moreInfo => 'مزيد من المعلومات';

  @override
  String get saveStatusSaving => 'جارٍ الحفظ…';

  @override
  String get saveStatusSaved => 'محفوظ على هذا الجهاز';

  @override
  String get saveStatusFailed => 'تعذّر حفظ آخر تغيير.';

  @override
  String get saveFailedHelp =>
      'كلماتك ما زالت هنا. يمكنك إعادة المحاولة أو تصدير نسخة.';

  @override
  String get saveExportCopy => 'تصدير نسخة';

  @override
  String get bootLoading => 'نجهّز مساحتك…';

  @override
  String get bootLoadErrorTitle => 'تعذّر فتح بياناتك المحفوظة';

  @override
  String get bootLoadErrorBody =>
      'لم يتمكّن Cartharise من قراءة ملفه. لم يُحذف شيء.';

  @override
  String get bootLoadErrorHint =>
      'يمكنك المحاولة مجددًا. وإن تكرّر ذلك، فقد يفيد تحرير بعض المساحة.';

  @override
  String get bootStartFresh => 'بداية جديدة مع الاحتفاظ بالملف غير المقروء';

  @override
  String get bootStartFreshConfirmTitle => 'بداية جديدة؟';

  @override
  String get bootStartFreshConfirmBody =>
      'يُنحّى الملف غير المقروء جانبًا ولا يُحذف. ويبدأ Cartharise فارغًا.';

  @override
  String get storageTransparency =>
      'على هذا الهاتف فقط. بلا مزامنة، وخارج النسخ الاحتياطي للهاتف والسحابة، وبلا تشفير من Cartharise. حذف التطبيق أو بياناتك يمحوها.';

  @override
  String get storageErrorTitle => 'مشكلة في التخزين';

  @override
  String get storageErrorBody =>
      'يتعذّر الحفظ على هذا الهاتف الآن. تبقى كلماتك على الشاشة ما دامت مفتوحة.';

  @override
  String linkOpenFailed(String url) {
    return 'تعذّر فتح الرابط. يمكنك زيارته بنفسك: $url';
  }

  @override
  String get shareFailed => 'تعذّر فتح قائمة المشاركة على هذا الهاتف.';

  @override
  String get reminderChannelName => 'تذكيرات الوقفات';

  @override
  String get reminderChannelDescription =>
      'وقفات نهارية اختيارية من إعادة الضبط في Cartharise.';

  @override
  String get loaderLabel => 'جارٍ التحميل';

  @override
  String get emblemLabel => 'شعار Cartharise';

  @override
  String progressLabel(int value) {
    return '$value بالمئة';
  }

  @override
  String get selectedLabel => 'محدَّد';

  @override
  String get awakeningTitle => 'اليقظة';

  @override
  String get awakeningSubtitle =>
      'سبع أفكار وراء إعادة الضبط. اختيارية، وبأي ترتيب.';

  @override
  String get awakeningStripTitle => 'الأفكار أولًا (اختياري)';

  @override
  String get awakeningSeeAll => 'كل الدروس';

  @override
  String awakeningReadCount(int read, int total) {
    return 'المقروء: $read من $total';
  }

  @override
  String awakeningLessonNumber(int n) {
    return 'الدرس $n';
  }

  @override
  String awakeningLessonOf(int n, int total) {
    return 'الدرس $n من $total';
  }

  @override
  String get awakeningRead => 'مقروء';

  @override
  String get awakeningNotRead => 'لم يُقرأ بعد';

  @override
  String get awakeningExample => 'مثال';

  @override
  String get awakeningNuance => 'عدسة للنظر، لا حُكم';

  @override
  String get awakeningCheckTitle => 'وقفة للفهم';

  @override
  String get awakeningCheckHint =>
      'يكفي اختيار الإجابة الأنسب. لا شيء يُقيَّم أو يُحفظ.';

  @override
  String get awakeningCheckRight => 'تمامًا.';

  @override
  String get awakeningCheckNotQuite => 'ليس تمامًا، ولا بأس.';

  @override
  String get awakeningTryIt => 'تجربة الفكرة';

  @override
  String get awakeningTryItBody =>
      'سؤال من إعادة الضبط يضع هذه الفكرة موضع التطبيق.';

  @override
  String awakeningTryItPrompt(String title) {
    return 'للتجربة: $title';
  }

  @override
  String get awakeningPrevious => 'الدرس السابق';

  @override
  String get awakeningNext => 'الدرس التالي';

  @override
  String get awakeningDone => 'العودة إلى الدروس';

  @override
  String awakeningSourceNote(String title, String author) {
    return 'بكلمات Cartharise، عن مقال «$title» للكاتب $author. تطبيق مستقل.';
  }

  @override
  String get awakeningSourceLink => 'عن المصدر';

  @override
  String get awakeningMissing => 'هذا الدرس غير متاح.';

  @override
  String get campaignSection => 'الحملة';

  @override
  String get campaignSubtitle => 'وجهتك، على هيئة لعبة.';

  @override
  String get campaignStatusEyebrow => 'حملتك';

  @override
  String campaignLevel(int level, int xp) {
    return 'المستوى $level · $xp XP';
  }

  @override
  String get campaignXpNote =>
      'الخبرة (XP) تعكس الأفعال، لا قيمتك أبدًا. والراحة لا تكلّف شيئًا.';

  @override
  String get campaignXpHow => 'كيف تُكتسب الخبرة (XP)';

  @override
  String campaignXpRuleReflection(int xp) {
    return '‎+$xp XP لكل سؤال يُجاب عنه في إعادة الضبط (مرة واحدة لكل سؤال)';
  }

  @override
  String campaignXpRuleQuest(int xp, int max) {
    return '‎+$xp XP لكل مهمّة تُنجَز، حتى $max في اليوم';
  }

  @override
  String campaignXpRulePath(int xp) {
    return '‎+$xp XP لكل يوم يُكتب من مسار 30 يومًا';
  }

  @override
  String campaignXpRuleAttempt(int xp) {
    return '‎+$xp XP لكل يوم تُسجَّل فيه محاولة في مشروعك الشهري';
  }

  @override
  String campaignXpRuleReview(int xp) {
    return '‎+$xp XP لكل مراجعة أسبوعية';
  }

  @override
  String campaignXpRulesNote(int step) {
    return 'الخبرة لا تنظر إلى المكتوب ولا إلى المشاعر. التخطّي والراحة لا يكلّفان شيئًا أبدًا. كل $step XP مستوى جديد.';
  }

  @override
  String get campaignActOne => 'الجزء الأول · يقظة اليوم الواحد';

  @override
  String campaignChaptersExplored(int count, int total) {
    return 'الفصول المستكشفة: $count من $total';
  }

  @override
  String campaignChapterNumber(int number) {
    return 'الفصل $number';
  }

  @override
  String get campaignChapterTerrain => 'استطلاع الأرض';

  @override
  String get campaignChapterTerrainArea => 'الواقع الحالي';

  @override
  String get campaignChapterPattern => 'اكتشاف النمط';

  @override
  String get campaignChapterPatternArea => 'الرؤية المضادّة والهوية';

  @override
  String get campaignChapterBanner => 'رفع الراية';

  @override
  String get campaignChapterBannerArea => 'رؤية المستقبل';

  @override
  String get campaignChapterAutopilot => 'كسر الطيار الآلي';

  @override
  String get campaignChapterAutopilotArea => 'وقفات النهار';

  @override
  String get campaignChapterPlan => 'التخطيط للحملة';

  @override
  String get campaignChapterPlanArea => 'خلاصة المساء';

  @override
  String campaignChapterReflections(String area, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تأمّل',
      many: '$count تأمّلًا',
      few: '$count تأمّلات',
      two: 'تأمّلان',
      one: 'تأمّل واحد',
      zero: 'لا تأمّلات',
    );
    return '$area · $_temp0';
  }

  @override
  String campaignChapterDone(int done, int total) {
    return 'المكتوب: $done من $total';
  }

  @override
  String get campaignChapterExplored => 'مُستكشَف';

  @override
  String get campaignChapterExplore => 'استكشاف';

  @override
  String campaignChapterExploreLabel(int number, String name) {
    return 'استكشاف الفصل $number، $name';
  }

  @override
  String get campaignMapTitle => 'خريطة الاستراتيجية';

  @override
  String get campaignMapAntiVision => 'ما على المحكّ · الرؤية المضادّة';

  @override
  String get campaignMapVision => 'شرط الفوز · الرؤية';

  @override
  String get campaignMapYear => 'الحملة الكبرى · مهمّة السنة';

  @override
  String get campaignMapMonth => 'زعيم الشهر · مشروع الشهر';

  @override
  String get campaignMapLevers => 'المهامّ اليومية · الروافع اليومية';

  @override
  String get campaignMapBoundaries => 'قواعد الاشتباك · الحدود';

  @override
  String get campaignMapBoundariesNote => 'اللعبة لا تكافئ التخلّي عنها أبدًا.';

  @override
  String get campaignMapEmpty => 'لم يُكتب بعد.';

  @override
  String get campaignMapEdit => 'بناء استراتيجيتك';

  @override
  String get campaignMapQuests => 'فتح المهامّ اليومية';

  @override
  String get campaignBossTitle => 'مواجهة زعيم الشهر';

  @override
  String get campaignBossBody =>
      'الزعيم مشروع، لا شخص أبدًا. والمحاولات تُسجَّل هنا.';

  @override
  String get campaignBossNoProject =>
      'لرؤيته هنا، يلزم تحديد مشروع للشهر في بوصلتك.';

  @override
  String get campaignAttemptLabel => 'ما الذي جرّبته فعلًا؟';

  @override
  String get campaignAttemptHint => 'فترة تركيز، رسالة صعبة، مسودّة أولى…';

  @override
  String get campaignAttemptRequired => 'بضع كلمات عمّا جرّبته.';

  @override
  String get campaignLearningLabel => 'ماذا تعلّمت؟ (اختياري)';

  @override
  String get campaignLearningHint => 'ما نجح، وما يستحق التغيير.';

  @override
  String get campaignRecord => 'تسجيل هذه المحاولة';

  @override
  String get campaignRecorded => 'سُجّلت المحاولة.';

  @override
  String campaignLogTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سجلّ المعارك · $count محاولة',
      many: 'سجلّ المعارك · $count محاولة',
      few: 'سجلّ المعارك · $count محاولات',
      two: 'سجلّ المعارك · محاولتان',
      one: 'سجلّ المعارك · محاولة واحدة',
      zero: 'سجلّ المعارك',
    );
    return '$_temp0';
  }

  @override
  String get campaignLogEmpty =>
      'لا محاولات بعد. والأولى يمكن أن تكون صغيرة جدًا.';

  @override
  String campaignLogLearned(String learning) {
    return 'ما تعلّمته: $learning';
  }

  @override
  String campaignLogEditLabel(String date) {
    return 'تعديل محاولة $date';
  }

  @override
  String get campaignAttemptEditTitle => 'تعديل المحاولة';

  @override
  String get campaignAttemptSave => 'حفظ المحاولة';

  @override
  String get campaignAttemptDelete => 'حذف المحاولة';

  @override
  String get campaignAttemptDeleteTitle => 'حذف هذه المحاولة؟';

  @override
  String get campaignAttemptDeleteBody => 'ستُزال. ولا يمكن التراجع عن ذلك.';

  @override
  String get campaignAttemptDeleted => 'حُذفت المحاولة';

  @override
  String get campaignAchievementsTitle => 'إنجازات من المقال';

  @override
  String get campaignAchievementsSubtitle =>
      'تُكتسب بالتأمّل أو التجربة أو الفعل. ولا تُكتسب بالمكتوب أبدًا.';

  @override
  String campaignAchievementsCount(int earned, int total) {
    return 'المُكتسَب: $earned من $total';
  }

  @override
  String get campaignNotYet => 'ليس بعد';

  @override
  String get campaignAchievementObserver => 'وسام الملاحظة';

  @override
  String get campaignAchievementObserverBody =>
      'الإجابة عن كل أسئلة الواقع الحالي في إعادة ضبط واحدة، أو تجربة إحدى تجاربه';

  @override
  String get campaignAchievementPathfinder => 'وسام اكتشاف الطريق';

  @override
  String get campaignAchievementPathfinderBody =>
      'الإجابة عن كل أسئلة الرؤية المضادّة والهوية في إعادة ضبط واحدة، أو تجربة إحدى تجاربه';

  @override
  String get campaignAchievementVisionary => 'وسام الرؤية';

  @override
  String get campaignAchievementVisionaryBody =>
      'الإجابة عن كل أسئلة رؤية المستقبل في إعادة ضبط واحدة، أو تجربة إحدى تجاربه';

  @override
  String get campaignAchievementWatchful => 'وسام اليقظة';

  @override
  String get campaignAchievementWatchfulBody =>
      'الإجابة عن كل وقفات النهار في إعادة ضبط واحدة، أو تجربة إحدى تجاربه';

  @override
  String get campaignAchievementStrategist => 'وسام الاستراتيجية';

  @override
  String get campaignAchievementStrategistBody =>
      'الإجابة عن كل أسئلة التخطيط المسائي في إعادة ضبط واحدة، أو تجربة إحدى تجاربه';

  @override
  String get campaignAchievementPractitioner => 'وسام الممارسة';

  @override
  String get campaignAchievementPractitionerBody =>
      'إنجاز مهمّة في الحياة الواقعية';

  @override
  String get campaignAchievementChallenger => 'وسام التحدّي';

  @override
  String get campaignAchievementChallengerBody =>
      'تسجيل أول محاولة في مشروعك الشهري';

  @override
  String get campaignActTwo => 'الجزء الثاني · التحوّل في 30 يومًا';

  @override
  String get campaignActTwoBody =>
      'وجهة، لا موعد نهائي. ولتستمرّ الخطوات الصغيرة.';

  @override
  String get campaignStatQuests => 'المهامّ المُنجَزة';

  @override
  String get campaignStatPath => 'ملاحظات مسار 30 يومًا';

  @override
  String get campaignStatAttempts => 'المحاولات المسجّلة';

  @override
  String get campaignContinuePath => 'متابعة مسار 30 يومًا';

  @override
  String get campaignReadArticle => 'قراءة المقال';

  @override
  String get campaignNote =>
      'الخبرة (XP) والمستويات والإنجازات من إضافات Cartharise، وليست من المقال. يمكن إيقافها من «أنت».';

  @override
  String get campaignTodayOpen => 'فتح الحملة';

  @override
  String get campaignSettingTitle => 'الحملة';

  @override
  String get campaignSettingHint =>
      'الخبرة (XP) والمستويات والإنجازات. ويبقى سجلّ المعارك محفوظًا إن أوقفتها.';

  @override
  String campaignWaypoint(String place) {
    String _temp0 = intl.Intl.selectLogic(place, {
      'carthage': 'قرطاج',
      'newCarthage': 'قرطاج الجديدة',
      'ebro': 'نهر إيبرو',
      'pyrenees': 'جبال البرانس',
      'rhone': 'نهر الرون',
      'alps': 'جبال الألب',
      'italy': 'إيطاليا',
      'other': 'الطريق',
    });
    return '$_temp0';
  }

  @override
  String campaignRouteHere(String place) {
    return 'أنت عند $place';
  }

  @override
  String campaignRouteNext(int xp, String place) {
    return '$xp XP حتى $place';
  }

  @override
  String get campaignRouteEnd => 'عبرت إلى إيطاليا. والحملة مستمرة.';

  @override
  String campaignRouteLabel(String place, int stop, int total) {
    return 'طريق حنّبعل: $place، المحطة $stop من $total.';
  }

  @override
  String get campaignBossStrength => 'قوة الزعيم';

  @override
  String campaignBossMilestones(int done, int total) {
    return 'المحطات المبلوغة: $done من $total';
  }

  @override
  String get campaignBossBeaten => 'بُلغت كل المحطات. هُزم الزعيم.';

  @override
  String get campaignBossNoMilestones => 'إضافة محطات إلى مشروعك تُضعف الزعيم.';

  @override
  String get campaignBossOpenProject => 'فتح المشروع';

  @override
  String campaignNextAchievement(String name, String how) {
    return 'التالي: $name · $how';
  }

  @override
  String campaignToastXp(int xp) {
    return '‎+$xp XP';
  }

  @override
  String campaignToastAchievement(String name) {
    return 'إنجاز جديد: $name';
  }

  @override
  String get campaignStrategistEmpty =>
      'يمكن إنشاء صورة رمزية لترافقك على الطريق.';

  @override
  String campaignExtrasCount(int count, int total) {
    return 'الإضافات المفتوحة: $count من $total';
  }

  @override
  String get campaignExtrasAll => 'كل الإضافات مفتوحة.';

  @override
  String campaignQuestXp(int xp) {
    return '‎+$xp XP';
  }

  @override
  String campaignQuestXpLabel(int xp) {
    return 'تمنح $xp XP عند إنجازها';
  }

  @override
  String campaignXpRuleExperiment(int xp) {
    return '‎+$xp XP لكل تجربة جديدة تُجرَّب (مرة واحدة لكل منها)';
  }

  @override
  String get campaignNoticeTitle => 'انتباه';

  @override
  String get campaignNoticeLine => 'سؤال أو فكرة تستحق نظرة أخرى.';

  @override
  String get campaignTryTitle => 'تجربة';

  @override
  String get campaignTryLine => 'تجربة صغيرة للحياة الواقعية.';

  @override
  String get campaignYoursTitle => 'على طريقتك';

  @override
  String get campaignYoursLine => 'صورتك الرمزية وعبارتك.';

  @override
  String campaignYoursPicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مكافأة للاختيار',
      many: '$count مكافأة للاختيار',
      few: '$count مكافآت للاختيار',
      two: 'مكافأتان للاختيار',
      one: 'مكافأة واحدة للاختيار',
      zero: 'لا مكافآت للاختيار',
    );
    return '$_temp0';
  }

  @override
  String get campaignLinkRoute => 'الطريق';

  @override
  String get campaignLinkChapters => 'الفصول';

  @override
  String get campaignLinkBattleLog => 'سجلّ المعارك';

  @override
  String get campaignLinkBattleLogDraft => 'سجلّ المعارك · المسودّة محفوظة';

  @override
  String get campaignLinkCollection => 'التذكارات';

  @override
  String get campaignRouteTitle => 'الطريق';

  @override
  String get campaignRouteSubtitle =>
      'محطة لكل مستوى. والراحة لا تعيدك إلى الوراء أبدًا.';

  @override
  String get campaignRouteStops => 'المحطات';

  @override
  String get campaignRouteStopHere => 'أنت هنا';

  @override
  String get campaignRouteStopReached => 'بُلغت';

  @override
  String campaignRouteStopAhead(int xp) {
    return 'باقٍ $xp XP';
  }

  @override
  String get campaignChaptersTitle => 'الفصول';

  @override
  String campaignChapterTried(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'جُرّبت $count تجربة',
      many: 'جُرّبت $count تجربة',
      few: 'جُرّبت $count تجارب',
      two: 'جُرّبت تجربتان',
      one: 'جُرّبت تجربة واحدة',
      zero: 'لم تُجرَّب أي تجربة',
    );
    return '$_temp0';
  }

  @override
  String get campaignChapterTry => 'تجربة واحدة';

  @override
  String campaignChapterTryLabel(int number, String name) {
    return 'تجربة من الفصل $number، $name';
  }

  @override
  String get campaignBattleLogTitle => 'سجلّ المعارك';

  @override
  String get campaignAttemptDraftNote => 'يُحفظ على هذا الهاتف أثناء الكتابة.';

  @override
  String get campaignAttemptNotSaved =>
      'لم يُحفظ على هذا الهاتف بعد. كلماتك ما زالت هنا. «إعادة المحاولة» في الأعلى.';

  @override
  String get campaignNotSavedYet =>
      'لم يُحفظ على هذا الهاتف بعد. «إعادة المحاولة» في الأعلى.';

  @override
  String get campaignCollectionTitle => 'التذكارات';

  @override
  String get campaignCollectionSubtitle =>
      'ما جرّبته، وما اكتسبته، وما اخترته.';

  @override
  String campaignCollectionTried(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تجربة مُجرَّبة',
      many: '$count تجربة مُجرَّبة',
      few: '$count تجارب مُجرَّبة',
      two: 'تجربتان مُجرَّبتان',
      one: 'تجربة واحدة مُجرَّبة',
      zero: 'التجارب المُجرَّبة',
    );
    return '$_temp0';
  }

  @override
  String get campaignCollectionTriedEmpty =>
      'لم يُجرَّب شيء بعد. في «تجربة» تجارب صغيرة.';

  @override
  String get campaignTryOpen => 'فتح «تجربة»';

  @override
  String get campaignExperimentUnknown => 'تجربة';

  @override
  String campaignTriedOn(String date) {
    return 'جُرّبت في $date';
  }

  @override
  String campaignTriedEditLabel(String date) {
    return 'تعديل ملاحظة $date';
  }

  @override
  String get campaignTriedSave => 'حفظ الملاحظة';

  @override
  String get campaignTriedRemove => 'إزالة هذه التجربة';

  @override
  String get campaignTriedRemoveTitle => 'إزالة هذه التجربة؟';

  @override
  String get campaignTriedRemoveBody => 'تخرج من تذكاراتك، مع ملاحظتها.';

  @override
  String get campaignTriedRemoved => 'أُزيلت التجربة';

  @override
  String get campaignTriedUnsavedTitle => 'حفظ التغيير؟';

  @override
  String get campaignTriedUnsavedBody => 'تغيّرت الملاحظة ولم تُحفظ.';

  @override
  String get campaignTriedDiscard => 'تجاهل التغيير';

  @override
  String get campaignEarnedByReflecting => 'اكتُسب بالتأمّل';

  @override
  String get campaignEarnedByTrying => 'اكتُسب بالتجربة';

  @override
  String campaignEarnedByTryingWhat(String experiment) {
    return 'اكتُسب بالتجربة: $experiment';
  }

  @override
  String get campaignEarnedByDoing => 'اكتُسب بالفعل';

  @override
  String get campaignCollectionExtras => 'الإضافات المختارة';

  @override
  String get campaignCollectionExtrasEmpty => 'لم تُختر إضافات بعد.';

  @override
  String get campaignTryScreenSubtitle =>
      'تجارب صغيرة. لا ينضمّ شيء إلى مهامّك إلا بإضافتك له.';

  @override
  String campaignTryMinutes(int minutes) {
    return 'المدّة التقريبية: $minutes د';
  }

  @override
  String campaignTryXpLabel(int xp) {
    return 'تمنح $xp XP في المرة الأولى';
  }

  @override
  String campaignTryStepLabel(int number, String step) {
    return 'الخطوة $number: $step';
  }

  @override
  String get campaignTryNoteLabel => 'ملاحظة (اختيارية)';

  @override
  String get campaignTryNoteHint => 'كيف جرى الأمر؟ سطر واحد يكفي.';

  @override
  String get campaignTryDone => 'جرّبتها';

  @override
  String get campaignTryRecorded => 'حُفظت في تذكاراتك.';

  @override
  String get campaignTryAddTask => 'إضافة إلى مهامّي';

  @override
  String get campaignTryAdded => 'أُضيفت إلى مهامّك.';

  @override
  String get campaignTryAlreadyTask => 'موجودة في مهامّك بالفعل.';

  @override
  String get campaignTryOpenTasks => 'فتح المهامّ';

  @override
  String get campaignTryPrevious => 'السابقة';

  @override
  String campaignTryPosition(int index, int total) {
    return '$index من $total';
  }

  @override
  String get campaignTryEmpty => 'لا تجارب هنا بعد.';

  @override
  String get campaignNoticeScreenSubtitle =>
      'واحدة تكفي. كلٌّ منها يفتح سؤالًا أو درسًا.';

  @override
  String get campaignNoticeKindPrompt => 'تأمّل';

  @override
  String get campaignNoticeKindLesson => 'درس';

  @override
  String campaignNoticeOpens(String title) {
    return 'يفتح: $title';
  }

  @override
  String get campaignNoticeWritten => 'مكتوب';

  @override
  String get campaignNoticeRead => 'مقروء';

  @override
  String get campaignNoticeEmpty => 'لا شيء للانتباه إليه هنا بعد.';

  @override
  String get campaignYoursScreenSubtitle =>
      'مظهرك وعبارتك. الإضافات للزينة فقط، وتبقى لك.';

  @override
  String get campaignRewardCardTitle => 'اختيارات المكافأة';

  @override
  String get campaignRewardTitle => 'اختيار مكافأتك';

  @override
  String campaignRewardPicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اختيار متاح. وما يُختار يبقى لك.',
      many: '$count اختيارًا متاحًا. وما يُختار يبقى لك.',
      few: '$count اختيارات متاحة. وما يُختار يبقى لك.',
      two: 'اختياران متاحان. وما يُختار يبقى لك.',
      one: 'اختيار واحد متاح. وما يُختار يبقى لك.',
      zero: 'لا اختيارات متاحة. وما يُختار يبقى لك.',
    );
    return '$_temp0';
  }

  @override
  String campaignRewardSuggestedLine(String item) {
    return 'مقترح: $item';
  }

  @override
  String campaignRewardSuggested(String kind) {
    return 'مقترح · $kind';
  }

  @override
  String campaignRewardChoose(String item) {
    return 'اختيار $item';
  }

  @override
  String campaignRewardChosen(String item) {
    return '$item لك، ويبقى لك.';
  }

  @override
  String get campaignRewardWear => 'ارتداؤه';

  @override
  String campaignRewardPreviewLabel(String item) {
    return 'صورتك الرمزية مع $item';
  }

  @override
  String get campaignRewardNone => 'لا اختيار متاح الآن.';

  @override
  String get campaignRewardGameOff =>
      'مع إيقاف الحملة، كل الإضافات مفتوحة بالفعل.';

  @override
  String get campaignPlaygroundSection => 'ساحة اللعب';

  @override
  String get campaignPlaygroundSubtitle => 'أشياء صغيرة للانتباه والتجربة.';

  @override
  String get campaignPlaygroundGameOff =>
      'لا خبرة (XP) ولا مستويات ما دامت الحملة متوقفة. يمكن تشغيلها من «أنت».';

  @override
  String get campaignInviteTitle => 'اللعب في الحملة؟';

  @override
  String get campaignInviteBody => 'خبرة (XP) ومستويات على أفعالك.';

  @override
  String get campaignInvitePlay => 'لنلعب';

  @override
  String get campaignInvitePlaying => 'الحملة مفعّلة. مكانها في البوصلة.';

  @override
  String get campaignInviteLater => 'يمكن تشغيلها من «أنت».';

  @override
  String campaignToastPick(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اختيار جديد لصورتك الرمزية',
      many: '$count اختيارًا جديدًا لصورتك الرمزية',
      few: '$count اختيارات جديدة لصورتك الرمزية',
      two: 'اختياران جديدان لصورتك الرمزية',
      one: 'اختيار جديد لصورتك الرمزية',
    );
    return '$_temp0';
  }

  @override
  String get campaignQuestFromTry => 'تجربة';

  @override
  String get compassTitle => 'البوصلة';

  @override
  String get compassSubtitle => 'وجهتك، بكلماتك أنت.';

  @override
  String get compassMissionsSubtitle => 'وجهتك، وقد صارت أفعالًا.';

  @override
  String get compassSectionCompass => 'البوصلة';

  @override
  String get compassSectionMissions => 'المهمّات';

  @override
  String get compassHeroEyebrow => 'وجهتي';

  @override
  String get compassHeroEmpty =>
      'ست إجابات قصيرة توجّه أيامك. يمكنك كتابتها، أو البدء من إجابات المساء.';

  @override
  String compassLastUpdated(String date) {
    return 'آخر تحديث: $date';
  }

  @override
  String get compassImportOfferTitleEmpty => 'البدء من تأمّل المساء';

  @override
  String get compassImportOfferTitle =>
      'يمكن لإجابات المساء أن تملأ الحقول الفارغة';

  @override
  String get compassImportOfferBody =>
      'تنتقل كلمات مسائك إلى الحقول الفارغة. لا يتغيّر شيء قبل تأكيدك.';

  @override
  String get compassImportAction => 'استخدام تأمّلات المساء';

  @override
  String get compassEmptyTitle => 'بوصلتك فارغة';

  @override
  String get compassEmptyBody =>
      'يمكنك كتابة كل جزء أدناه، أو الإجابة عن أسئلة المساء أولًا.';

  @override
  String get compassEmptyAction => 'الانتقال إلى تأمّل المساء';

  @override
  String get compassFieldAntiVision => 'الرؤية المضادّة';

  @override
  String get compassFieldAntiVisionHelp => 'ما أرفض أن تصير إليه حياتي.';

  @override
  String get compassFieldAntiVisionHint =>
      'الحياة التي لا أريدها، في جملة أو جملتين';

  @override
  String get compassFieldVision => 'الرؤية';

  @override
  String get compassFieldVisionHelp => 'ما أبنيه وأسير نحوه.';

  @override
  String get compassFieldVisionHint => 'الحياة التي أريد أن أنمو إليها';

  @override
  String get compassFieldYearGoal => 'مهمّة السنة';

  @override
  String get compassFieldYearGoalHelp => 'النتيجة الأهمّ بعد عام من الآن.';

  @override
  String get compassFieldYearGoalHint =>
      'في مثل هذا الوقت من العام القادم، سأكون قد…';

  @override
  String get compassFieldMonthProject => 'مشروع الشهر';

  @override
  String get compassFieldMonthProjectHelp =>
      'مشروع واحد للأسابيع الأربعة القادمة.';

  @override
  String get compassFieldMonthProjectHint => 'هذا الشهر سأبني أو أُنهي…';

  @override
  String get compassFieldDailyLevers => 'الروافع اليومية';

  @override
  String get compassFieldDailyLeversHelp => 'فعلان أو ثلاثة، كلٌّ في سطر.';

  @override
  String get compassFieldDailyLeversHint => 'المشي 20 دقيقة\nقراءة 10 صفحات';

  @override
  String get compassFieldConstraints => 'الحدود';

  @override
  String get compassFieldConstraintsHelp => 'ما لن أضحّي به.';

  @override
  String get compassFieldConstraintsHint => 'النوم، عشاء العائلة، يوم للراحة…';

  @override
  String get compassConstraintsOwnWords => 'أنت وحدك من يكتب هذا.';

  @override
  String get compassConstraintsChip => 'بقلمك وحدك';

  @override
  String get compassLeversToQuests => 'تحويلها إلى مهامّ';

  @override
  String get compassOpenProject => 'فتح مشروع الشهر';

  @override
  String get compassVersionsTitle => 'النُّسخ';

  @override
  String get compassVersionsBody => 'يمكنك حفظ لقطة قبل التغييرات الكبيرة.';

  @override
  String get compassSaveVersion => 'حفظ نسخة';

  @override
  String get compassVersionSaved => 'حُفظت النسخة';

  @override
  String compassViewVersions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'النُّسخ ($count)',
      zero: 'النُّسخ',
    );
    return '$_temp0';
  }

  @override
  String get compassVersionsSubtitle => 'لقطات من بوصلتك، الأحدث أولًا.';

  @override
  String get compassVersionsEmptyTitle => 'لا نُسخ بعد';

  @override
  String get compassVersionsEmptyBody =>
      'يمكنك حفظ نسخة متى أردت لقطة للعودة إليها لاحقًا.';

  @override
  String get compassVersionReasonManual => 'حفظتها بنفسك';

  @override
  String get compassVersionReasonBeforeImport => 'قبل استيراد';

  @override
  String get compassVersionReasonBeforeRestore => 'قبل استعادة';

  @override
  String get compassVersionTitle => 'نسخة';

  @override
  String get compassVersionEmptyField => 'فارغ في هذه النسخة';

  @override
  String get compassVersionSameAsNow => 'مطابق للحالي';

  @override
  String get compassVersionDiffers => 'مختلف عن الحالي';

  @override
  String get compassVersionReadOnly =>
      'للقراءة فقط. الاستعادة تحفظ بوصلتك الحالية أولًا.';

  @override
  String get compassRestoreAction => 'استعادة هذه النسخة';

  @override
  String get compassRestoreConfirmTitle => 'استعادة هذه النسخة؟';

  @override
  String get compassRestoreConfirmBody =>
      'ستحلّ محلّ بوصلتك. تُحفظ البوصلة الحالية أولًا.';

  @override
  String get compassRestoreConfirm => 'استعادة';

  @override
  String get compassRestored => 'استُعيدت النسخة، وحُفظت السابقة.';

  @override
  String get compassImportTitle => 'استخدام تأمّلات المساء';

  @override
  String get compassImportBody =>
      'إجابات مسائك كما كتبتها. يمكنك اختيار الحقول الفارغة التي ستُملأ.';

  @override
  String compassImportFrom(String prompt) {
    return 'من: $prompt';
  }

  @override
  String get compassImportKeeps => 'يُبقي نصّك الحالي';

  @override
  String get compassImportNoAnswer => 'لا إجابة مسائية بعد';

  @override
  String get compassImportConstraintsNote => 'الحدود لا يكتبها أحد سواك.';

  @override
  String get compassImportSnapshotNote => 'تُحفظ بوصلتك الحالية كنسخة أولًا.';

  @override
  String compassImportConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ملء $count حقل',
      many: 'ملء $count حقلًا',
      few: 'ملء $count حقول',
      two: 'ملء حقلين',
      one: 'ملء حقل واحد',
      zero: 'اختيار حقل',
    );
    return '$_temp0';
  }

  @override
  String get compassImportNothing =>
      'لا شيء لنقله بعد. يمكنك الإجابة عن أسئلة المساء أولًا.';

  @override
  String compassImportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مُلئ $count حقل في البوصلة من إجابات المساء.',
      many: 'مُلئ $count حقلًا في البوصلة من إجابات المساء.',
      few: 'مُلئت $count حقول في البوصلة من إجابات المساء.',
      two: 'مُلئ حقلان في البوصلة من إجابات المساء.',
      one: 'مُلئ حقل واحد في البوصلة من إجابات المساء.',
    );
    return '$_temp0';
  }

  @override
  String get journalTitle => 'اليوميات';

  @override
  String get journalSubtitle => 'تفكير وتأمّل ونموّ، على مهلك.';

  @override
  String get journalSectionNotes => 'الملاحظات';

  @override
  String get journalSectionReviews => 'المراجعات';

  @override
  String get journalSectionLookBack => 'نظرة إلى الوراء';

  @override
  String journalDateTime(String date, String time) {
    return '$date، $time';
  }

  @override
  String get journalNotesIntro => 'كتابة حرّة. تبقى على هذا الهاتف.';

  @override
  String get journalNewNote => 'ملاحظة جديدة';

  @override
  String get journalNotesEmptyTitle => 'لا ملاحظات بعد';

  @override
  String get journalNotesEmptyBody => 'فكرة، أو قلق، أو شيء لفت انتباهك.';

  @override
  String get journalUntitled => 'ملاحظة بلا عنوان';

  @override
  String get journalEditedBadge => 'معدَّلة';

  @override
  String get journalEntryNewTitle => 'ملاحظة جديدة';

  @override
  String get journalEntryTitle => 'ملاحظة';

  @override
  String get journalEntryTitleField => 'العنوان (اختياري)';

  @override
  String get journalEntryBodyField => 'ملاحظتك';

  @override
  String get journalEntryBodyHint => 'كتابة حرّة. تُحفظ أثناء الكتابة.';

  @override
  String journalEntryWritten(String when) {
    return 'كُتبت في $when';
  }

  @override
  String journalEntryEdited(String when) {
    return 'آخر تعديل في $when';
  }

  @override
  String get journalEntryPrivacy =>
      'على هذا الهاتف فقط. لا تظهر أبدًا في الإشعارات.';

  @override
  String get journalEntryDelete => 'حذف الملاحظة';

  @override
  String get journalEntryDeleteTitle => 'حذف هذه الملاحظة؟';

  @override
  String get journalEntryDeleteBody =>
      'تُزال الملاحظة من هذا الهاتف. ولا يمكن التراجع عن ذلك.';

  @override
  String get journalEntryDeleted => 'حُذفت الملاحظة';

  @override
  String get journalEntryMissingTitle => 'هذه الملاحظة لم تعد هنا';

  @override
  String get journalEntryMissingBody =>
      'ربما حُذفت. ملاحظاتك الأخرى لم تتغيّر.';

  @override
  String get journalReviewsIntro =>
      'مرة في الأسبوع: ما سار جيدًا، وما اعترضك، وما يستحق التجربة بعد ذلك.';

  @override
  String get journalReviewThisWeek => 'مراجعة هذا الأسبوع';

  @override
  String get journalOpenThisWeek => 'فتح مراجعة هذا الأسبوع';

  @override
  String get journalReviewsEmptyTitle => 'لا مراجعات أسبوعية بعد';

  @override
  String get journalReviewsEmptyBody => 'بضع دقائق. ولا طريقة صحيحة واحدة.';

  @override
  String journalWeekOf(String date) {
    return 'أسبوع $date';
  }

  @override
  String get journalReviewTitle => 'مراجعة أسبوعية';

  @override
  String get journalReviewEditIntro =>
      'بالقدر الذي يناسبك. تُحفظ أثناء الكتابة.';

  @override
  String get journalReviewChangeWeek => 'تغيير الأسبوع';

  @override
  String get journalReviewWins => 'مكاسب';

  @override
  String get journalReviewWinsHint =>
      'ما الذي سار جيدًا هذا الأسبوع، مهما كان صغيرًا؟';

  @override
  String get journalReviewFriction => 'عقبات';

  @override
  String get journalReviewFrictionHint =>
      'ما الذي اعترضك؟ مجرد ملاحظة، بلا لوم.';

  @override
  String get journalReviewNext => 'التجربة التالية';

  @override
  String get journalReviewNextHint => 'شيء صغير للتجربة الأسبوع القادم.';

  @override
  String get journalReviewSave => 'حفظ المراجعة';

  @override
  String get journalReviewSaved => 'حُفظت المراجعة';

  @override
  String get journalReviewEdit => 'تعديل المراجعة';

  @override
  String get journalReviewDelete => 'حذف المراجعة';

  @override
  String get journalReviewDeleteTitle => 'حذف هذه المراجعة؟';

  @override
  String journalReviewDeleteBody(String date) {
    return 'ستُزال مراجعة أسبوع $date. ولا يمكن التراجع عن ذلك.';
  }

  @override
  String get journalReviewDeleted => 'حُذفت المراجعة';

  @override
  String get journalReviewNothingWritten => 'لم يُكتب شيء';

  @override
  String journalReviewWritten(String when) {
    return 'حُفظت في $when';
  }

  @override
  String get journalReviewMissingTitle => 'هذه المراجعة لم تعد هنا';

  @override
  String get journalReviewMissingBody =>
      'ربما حُذفت. مراجعاتك الأخرى لم تتغيّر.';

  @override
  String get journalLookBackIntro => 'لمحة عن تغيّر كلماتك عبر الوقت.';

  @override
  String get journalCompareTitle => 'مقارنة بوصلتك';

  @override
  String get journalCompareBody => 'يمكنك اختيار لحظتين لوضعهما جنبًا إلى جنب.';

  @override
  String get journalCompareFirst => 'الأولى';

  @override
  String get journalCompareSecond => 'الثانية';

  @override
  String get journalCompareNow => 'بوصلتك الآن';

  @override
  String journalComparePick(String which) {
    return 'اختيار ما يظهر بوصفه «$which»';
  }

  @override
  String journalComparePickerLabel(String which, String current) {
    return '$which: $current. للتغيير، يكفي النقر.';
  }

  @override
  String get journalCompareEmptyTitle => 'لا نُسخ محفوظة بعد';

  @override
  String get journalCompareEmptyBody =>
      'بعد حفظ نسخة من البوصلة، تمكن مقارنتها هنا.';

  @override
  String get journalOpenCompass => 'فتح البوصلة';

  @override
  String get journalCompareSame => 'متطابق في الاثنتين';

  @override
  String get journalCompareEmptyField => 'فارغ';

  @override
  String get journalVersionManual => 'حفظتها بنفسك';

  @override
  String get journalVersionBeforeImport => 'قبل استيراد';

  @override
  String get journalVersionBeforeRestore => 'قبل استعادة';

  @override
  String journalVersionLabel(String date, String reason) {
    return '$date · $reason';
  }

  @override
  String get journalPastResetsTitle => 'إعادات ضبط سابقة';

  @override
  String get journalPastResetsBody =>
      'عند بدء إعادة ضبط جديدة، تبقى السابقة هنا للقراءة.';

  @override
  String get journalPastResetsEmpty =>
      'لا إعادات ضبط سابقة بعد. عند بدء واحدة جديدة، تبقى القديمة هنا.';

  @override
  String journalResetStarted(String date) {
    return 'بدأت في $date';
  }

  @override
  String journalResetCompleted(String date) {
    return 'اكتملت في $date';
  }

  @override
  String journalResetAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجابة مكتوبة',
      many: '$count إجابة مكتوبة',
      few: '$count إجابات مكتوبة',
      two: 'إجابتان مكتوبتان',
      one: 'إجابة مكتوبة واحدة',
      zero: 'لا إجابات مكتوبة',
    );
    return '$_temp0';
  }

  @override
  String get journalPastResetTitle => 'إعادة ضبط سابقة';

  @override
  String get journalPastResetReadOnly =>
      'للقراءة فقط. كلماتك محفوظة كما كتبتها تمامًا.';

  @override
  String get journalPastResetCompare => 'عرض إجاباتي الحالية أيضًا';

  @override
  String get journalPastResetThen => 'حينها';

  @override
  String get journalPastResetNow => 'الآن';

  @override
  String get journalPastResetNoCurrent => 'لا إجابة في إعادة الضبط الحالية';

  @override
  String get journalPastResetSkipped => 'متخطّى';

  @override
  String get journalPastResetNone => 'لا إجابات مكتوبة في إعادة الضبط هذه.';

  @override
  String get journalPastResetOther => 'إجابات أخرى';

  @override
  String get journalPastResetMissingTitle => 'إعادة الضبط هذه لم تعد هنا';

  @override
  String get journalPastResetUnfinished => 'لم تكتمل';

  @override
  String journalPastResetLeftOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'بقي $count سؤال مفتوحًا.',
      many: 'بقي $count سؤالًا مفتوحًا.',
      few: 'بقيت $count أسئلة مفتوحة.',
      two: 'بقي سؤالان مفتوحين.',
      one: 'بقي سؤال واحد مفتوحًا.',
      zero: 'لم يبقَ أي سؤال مفتوحًا.',
    );
    return '$_temp0';
  }

  @override
  String get journalPhaseMorning => 'الصباح';

  @override
  String get journalPhaseDaytime => 'النهار';

  @override
  String get journalPhaseBonus => 'إضافي';

  @override
  String get journalPhaseEvening => 'المساء';

  @override
  String get mediaAddPhoto => 'إضافة صورة';

  @override
  String get mediaRecord => 'تسجيل';

  @override
  String get mediaRecordLabel => 'تسجيل ملاحظة صوتية';

  @override
  String get mediaPhotoSourceTitle => 'إضافة صورة';

  @override
  String get mediaTakePhoto => 'التقاط صورة';

  @override
  String get mediaChoosePhoto => 'الاختيار من صورك';

  @override
  String get mediaPhotoAdded => 'أُضيفت الصورة.';

  @override
  String get mediaNotSavedYet => 'أُضيفت، لكنها لم تُحفظ على هذا الهاتف بعد.';

  @override
  String mediaPhotoLabel(String date) {
    return 'صورة، أُضيفت في $date';
  }

  @override
  String get mediaPhotoOpenHint => 'تُفتح بملء الشاشة';

  @override
  String get mediaPhotoMissing => 'مفقودة';

  @override
  String get mediaPhotoMissingLabel => 'هذه الصورة لم تعد على هذا الهاتف.';

  @override
  String get mediaPhotoTitle => 'صورة';

  @override
  String mediaPhotoAddedOn(String date) {
    return 'أُضيفت في $date';
  }

  @override
  String get mediaPhotoRemove => 'إزالة الصورة';

  @override
  String get mediaPhotoRemoveTitle => 'إزالة هذه الصورة؟';

  @override
  String get mediaPhotoRemoveBody =>
      'تُحذف من هذا الهاتف. ولا يمكن التراجع عن ذلك.';

  @override
  String get mediaRemove => 'إزالة';

  @override
  String get mediaPhotoRemoved => 'أُزيلت الصورة.';

  @override
  String get mediaRemovedNotSaved =>
      'أُزيلت، لكن التغيير لم يُحفظ على هذا الهاتف بعد.';

  @override
  String get mediaCameraDenied =>
      'الوصول إلى الكاميرا متوقف. يمكن الاختيار من صورك، أو السماح بالكاميرا من الإعدادات.';

  @override
  String get mediaPhotosDenied =>
      'الوصول إلى الصور متوقف. يمكن السماح به من الإعدادات، أو الكتابة بدلًا من ذلك.';

  @override
  String get mediaCameraUnavailable =>
      'لا كاميرا هنا. يمكن الاختيار من صورك بدلًا من ذلك.';

  @override
  String get mediaPhotosUnavailable =>
      'يتعذّر فتح الصور هنا. يمكنك الكتابة بدلًا من ذلك.';

  @override
  String get mediaPickFailed => 'تعذّر فتح الصور. يمكن المحاولة مجددًا.';

  @override
  String get mediaPhotoUnreadable => 'تعذّرت قراءة هذه الصورة. لم يُضَف شيء.';

  @override
  String get mediaPhotoTooLarge =>
      'حجم هذه الصورة يتجاوز 50 ميغابايت. يمكن اختيار صورة أصغر.';

  @override
  String get mediaWriteFailed =>
      'تعذّر الحفظ على هذا الهاتف. ربما امتلأت مساحة التخزين. لم يُضَف شيء.';

  @override
  String get mediaEntryGone => 'هذا العنصر لم يعد هنا. لم يُضَف شيء.';

  @override
  String get mediaRecoveredPhoto => 'صورة التقطتها لم تُضَف بعد.';

  @override
  String get mediaRecoveredRecording =>
      'انقطع تسجيل عند إغلاق التطبيق. قد يكون ناقصًا.';

  @override
  String get mediaRecoveredKeep => 'الاحتفاظ به في ملاحظة جديدة';

  @override
  String get mediaRecoveredDiscard => 'حذف';

  @override
  String get mediaRecoveredDiscardTitle => 'حذفه؟';

  @override
  String get mediaRecoveredDiscardBody => 'يُحذف من هذا الهاتف.';

  @override
  String get mediaRecoveredKept => 'حُفظ في ملاحظة جديدة في يومياتك.';

  @override
  String get mediaDismiss => 'إخفاء';

  @override
  String get mediaRecorderTitle => 'ملاحظة صوتية';

  @override
  String get mediaRecorderStarting => 'نجهّز الميكروفون…';

  @override
  String get mediaRecorderRecording => 'جارٍ التسجيل';

  @override
  String get mediaRecorderStop => 'إيقاف وحفظ';

  @override
  String get mediaRecorderDiscard => 'حذف';

  @override
  String get mediaRecorderDiscardTitle => 'حذف هذا التسجيل؟';

  @override
  String get mediaRecorderDiscardBody => 'يُحذف ما سجّلته.';

  @override
  String get mediaRecorderSaving => 'جارٍ الحفظ…';

  @override
  String get mediaRecorderStarted =>
      'جارٍ التسجيل. عند الانتهاء: زرّ «إيقاف وحفظ».';

  @override
  String get mediaRecorderSaved => 'حُفظت الملاحظة الصوتية.';

  @override
  String mediaRecorderInterrupted(String time) {
    return 'انقطع التسجيل. حُفظ ما سُجّل قبل ذلك ($time).';
  }

  @override
  String get mediaRecorderAgain => 'تسجيل من جديد';

  @override
  String get mediaMicDenied =>
      'الوصول إلى الميكروفون متوقف. يمكن السماح به من الإعدادات، أو الكتابة بدلًا من ذلك.';

  @override
  String get mediaMicUnavailable =>
      'التسجيل غير متاح على هذا الهاتف. يمكنك الكتابة بدلًا من ذلك.';

  @override
  String get mediaRecordFailed =>
      'تعذّر بدء التسجيل. يمكن المحاولة مجددًا، أو الكتابة بدلًا من ذلك.';

  @override
  String get mediaNothingRecorded =>
      'لم يُسجَّل شيء. يمكن المحاولة مجددًا، أو الكتابة بدلًا من ذلك.';

  @override
  String get mediaRecordStorageFailed =>
      'تعذّر حفظ التسجيل. ربما امتلأت مساحة التخزين.';

  @override
  String get mediaWriteInstead => 'الكتابة بدلًا من ذلك';

  @override
  String get mediaVoiceNote => 'ملاحظة صوتية';

  @override
  String get mediaPartial => 'جزئي';

  @override
  String get mediaPlay => 'تشغيل الملاحظة الصوتية';

  @override
  String get mediaPause => 'إيقاف الملاحظة الصوتية مؤقتًا';

  @override
  String mediaPositionOf(String position, String length) {
    return '$position من $length';
  }

  @override
  String get mediaVoiceMissing => 'هذا التسجيل لم يعد على هذا الهاتف.';

  @override
  String get mediaPlayFailed => 'يتعذّر تشغيل هذا التسجيل.';

  @override
  String get mediaVoiceRemove => 'إزالة الملاحظة الصوتية';

  @override
  String get mediaVoiceRemoveTitle => 'إزالة هذه الملاحظة الصوتية؟';

  @override
  String get mediaVoiceRemoveBody =>
      'يُحذف التسجيل من هذا الهاتف. ولا يمكن التراجع عن ذلك.';

  @override
  String get mediaVoiceRemoved => 'أُزيلت الملاحظة الصوتية.';

  @override
  String get mediaTranscriptAdd => 'كتابة ما قلته';

  @override
  String get mediaTranscriptEdit => 'تعديل كلماتك';

  @override
  String get mediaTranscriptTitle => 'كلماتك لهذا التسجيل';

  @override
  String get mediaTranscriptLabel => 'ما قلته (اختياري)';

  @override
  String get mediaTranscriptSaved => 'كلماتك محفوظة مع التسجيل.';

  @override
  String mediaMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دقيقة',
      many: '$count دقيقة',
      few: '$count دقائق',
      two: 'دقيقتان',
      one: 'دقيقة واحدة',
      zero: '$count دقيقة',
    );
    return '$_temp0';
  }

  @override
  String mediaSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ثانية',
      many: '$count ثانية',
      few: '$count ثوانٍ',
      two: 'ثانيتان',
      one: 'ثانية واحدة',
      zero: '$count ثانية',
    );
    return '$_temp0';
  }

  @override
  String get mediaPinnedTitle => 'ذكرى مثبّتة';

  @override
  String mediaPinnedFromNote(String date) {
    return 'من ملاحظة · $date';
  }

  @override
  String mediaPinnedFromTry(String date) {
    return 'من تجربة · $date';
  }

  @override
  String mediaPinnedFromAttempt(String date) {
    return 'من محاولة · $date';
  }

  @override
  String get mediaPinnedOpen => 'فتح مصدرها';

  @override
  String get mediaPinnedPhoto => 'صورة مثبّتة';

  @override
  String get mediaPinPhoto => 'تثبيت كذكرى';

  @override
  String get mediaUnpin => 'إلغاء التثبيت';

  @override
  String get mediaPinned => 'ثُبّتت أعلى يومياتك.';

  @override
  String get mediaPinnedNotSaved =>
      'ثُبّتت، لكنها لم تُحفظ على هذا الهاتف بعد.';

  @override
  String get mediaUnpinned => 'أُلغي التثبيت، ولم يتغيّر شيء آخر.';

  @override
  String get mediaUnpinnedNotSaved =>
      'أُلغي التثبيت، لكن التغيير لم يُحفظ على هذا الهاتف بعد.';

  @override
  String get mediaPinWords => 'تثبيت';

  @override
  String get mediaPinWordsTooltip => 'تثبيت الكلمات المحدّدة';

  @override
  String get mediaPinSelectFirst => 'يلزم تحديد بعض الكلمات أولًا، ثم «تثبيت».';

  @override
  String get mediaPinNotFound =>
      'تعذّر تثبيت هذه الكلمات. يمكن تحديدها من جديد.';

  @override
  String mediaCountPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صورة',
      many: '$count صورة',
      few: '$count صور',
      two: 'صورتان',
      one: 'صورة واحدة',
      zero: 'لا صور',
    );
    return '$_temp0';
  }

  @override
  String mediaCountVoice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاحظة صوتية',
      many: '$count ملاحظة صوتية',
      few: '$count ملاحظات صوتية',
      two: 'ملاحظتان صوتيتان',
      one: 'ملاحظة صوتية واحدة',
      zero: 'لا ملاحظات صوتية',
    );
    return '$_temp0';
  }

  @override
  String mediaAnd(String first, String second) {
    return '$first و$second';
  }

  @override
  String get mediaNoteVoiceOnly => 'ملاحظة صوتية';

  @override
  String get mediaNotePhotoOnly => 'ملاحظة مصوّرة';

  @override
  String get mediaNoteDeleteBody =>
      'تُزال الملاحظة وصورها وتسجيلاتها من هذا الهاتف. ولا يمكن التراجع عن ذلك.';

  @override
  String get mediaTodayRecordSaved => 'حُفظت الملاحظة الصوتية في يومياتك.';

  @override
  String get mediaTodayRecordNotSaved =>
      'سُجّلت، لكنها لم تُحفظ بعد. «إعادة المحاولة» في الأعلى.';

  @override
  String get mediaTodayOpen => 'فتح';

  @override
  String get mediaDataNoFiles =>
      'تشمل كلماتك وإعداداتك. لا صور ولا تسجيلات بعد.';

  @override
  String mediaDataWithFiles(String files, String size) {
    return 'تشمل كلماتك وإعداداتك، إضافة إلى $files ($size).';
  }

  @override
  String get mediaDataTooLarge =>
      'الصور والتسجيلات تتجاوز 256 ميغابايت، وهذا أكبر من أن يُستعاد. التصدير يحفظ كلماتك فقط؛ وإزالة بعضها تتيح نسخة كاملة.';

  @override
  String get mediaBackupTooLargeTitle => 'أكبر من أن يُستعاد';

  @override
  String get mediaBackupTooLargeBody =>
      'صورك وتسجيلاتك تتجاوز 256 ميغابايت، أي أكثر مما تستطيع نسخة احتياطية استعادته. تصدير كلماتك وإعداداتك فقط؟';

  @override
  String get mediaBackupWordsOnly => 'تصدير الكلمات فقط';

  @override
  String get mediaBackupWordsShared =>
      'شُوركت الكلمات والإعدادات. الصور والتسجيلات ليست فيها.';

  @override
  String get mediaDataImportFormats =>
      'يقبل نسخة احتياطية ‎.zip، أو نسخة ‎.json أقدم.';

  @override
  String mediaSizeKb(String size) {
    return '$size كيلوبايت';
  }

  @override
  String mediaSizeMb(String size) {
    return '$size ميغابايت';
  }

  @override
  String mediaSizeGb(String size) {
    return '$size غيغابايت';
  }

  @override
  String get missionsIntro => 'خطوات صغيرة نحو بوصلتك. وللراحة مكانها أيضًا.';

  @override
  String get missionsToday => 'اليوم';

  @override
  String get missionsTodayEmpty =>
      'لا شيء مخطّط. يمكنك إضافة مهمّة، أو الراحة.';

  @override
  String get missionsLater => 'أي وقت وقادمًا';

  @override
  String get missionsLaterEmpty =>
      'المهامّ بلا تاريخ، أو المخطّط لها لاحقًا، تظهر هنا.';

  @override
  String missionsDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'المُنجَزة ($count)',
      zero: 'المُنجَزة',
    );
    return '$_temp0';
  }

  @override
  String get missionsAddQuest => 'إضافة مهمّة';

  @override
  String missionsQuestMarkDone(String title) {
    return 'تحديد «$title» كمُنجَزة';
  }

  @override
  String missionsQuestOptions(String title) {
    return 'خيارات «$title»';
  }

  @override
  String get missionsQuestDaily => 'كل يوم';

  @override
  String missionsQuestDue(String date) {
    return 'مخطّطة ليوم $date';
  }

  @override
  String get missionsQuestDoneToday => 'أُنجزت اليوم';

  @override
  String missionsQuestDoneOn(String date) {
    return 'أُنجزت في $date';
  }

  @override
  String missionsQuestMovedToDone(String title) {
    return 'نُقلت «$title» إلى المُنجَزة';
  }

  @override
  String get missionsUndo => 'تراجع';

  @override
  String get missionsQuestDeleted => 'حُذفت المهمّة';

  @override
  String get missionsQuestEdit => 'تعديل';

  @override
  String get missionsQuestDelete => 'حذف';

  @override
  String get missionsViewLabel => 'عرض المهامّ بصيغة';

  @override
  String get missionsViewList => 'قائمة';

  @override
  String get missionsViewBoard => 'لوحة';

  @override
  String get missionsBoardHint =>
      'للسحب: ضغطة مطوّلة على البطاقة، أو زرّ النقل.';

  @override
  String get missionsBoardTodayFilter => 'اليوم';

  @override
  String get missionsBoardTodayFilterTooltip =>
      'المهامّ اليومية والمخطّطة لليوم فقط';

  @override
  String get missionsLaneLater => 'لاحقًا';

  @override
  String get missionsLaneReady => 'جاهزة';

  @override
  String get missionsLaneDoing => 'قيد التنفيذ';

  @override
  String get missionsLaneDone => 'مُنجَزة';

  @override
  String missionsLaneSummary(String lane, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمّة',
      many: '$count مهمّة',
      few: '$count مهامّ',
      two: 'مهمّتان',
      one: 'مهمّة واحدة',
      zero: 'لا مهامّ',
    );
    return '$lane، $_temp0';
  }

  @override
  String get missionsLaneLaterEmpty => 'مكان لأفكار تنتظر وقتًا آخر.';

  @override
  String get missionsLaneReadyEmpty => 'مهامّ جاهزة للبدء.';

  @override
  String get missionsLaneDoingEmpty => 'تُنقل المهمّة إلى هنا عند البدء بها.';

  @override
  String get missionsLaneDoneEmpty => 'المهامّ المنتهية تستقرّ هنا.';

  @override
  String get missionsLaneTodayEmpty => 'لا شيء هنا لليوم.';

  @override
  String get missionsLaneDoneFolded => 'مطويّة. إفلات بطاقة هنا يُنهيها.';

  @override
  String get missionsBoardDoingNote => 'القليل قيد التنفيذ قد يكون أخفّ.';

  @override
  String missionsBoardAddTo(String lane) {
    return 'إضافة إلى «$lane»';
  }

  @override
  String missionsBoardMoveTooltip(String title) {
    return 'نقل «$title» إلى…';
  }

  @override
  String missionsBoardMoveToLane(String lane) {
    return 'نقل إلى «$lane»';
  }

  @override
  String missionsBoardMoved(String title, String lane) {
    return 'نُقلت «$title» إلى «$lane»';
  }

  @override
  String missionsBoardDoneForToday(String title) {
    return 'أُنجزت «$title» لهذا اليوم';
  }

  @override
  String get missionsBoardDropHere => 'الإفلات للنقل إلى هنا';

  @override
  String get missionsBoardHiddenByFilter => 'أُضيفت. مرشّح «اليوم» يخفيها.';

  @override
  String get missionsBoardShowAll => 'عرض الكل';

  @override
  String get missionsNewQuestTitle => 'مهمّة جديدة';

  @override
  String get missionsEditQuestTitle => 'تعديل المهمّة';

  @override
  String get missionsQuestTitleLabel => 'ما الخطوة؟';

  @override
  String get missionsQuestTitleHint => 'المشي 20 دقيقة';

  @override
  String get missionsQuestTitleRequired => 'تحتاج المهمّة إلى بضع كلمات.';

  @override
  String get missionsQuestRepeat => 'تكرار كل يوم';

  @override
  String get missionsQuestRepeatHelp => 'تظهر في «اليوم» كل يوم.';

  @override
  String get missionsQuestDueLabel => 'التاريخ (اختياري)';

  @override
  String get missionsQuestNoDate => 'أي وقت';

  @override
  String get missionsQuestChooseDate => 'اختيار تاريخ';

  @override
  String get missionsQuestClearDate => 'إزالة التاريخ';

  @override
  String get missionsQuestSave => 'حفظ المهمّة';

  @override
  String get missionsQuestDeleteAction => 'حذف المهمّة';

  @override
  String get missionsLeversTitle => 'تحويل روافعك اليومية إلى مهامّ';

  @override
  String get missionsLeversBody =>
      'من بوصلتك. يمكنك التعديل، ثم إضافة ما يناسبك.';

  @override
  String missionsLeversInclude(String title) {
    return 'تضمين «$title»';
  }

  @override
  String missionsLeversDraftLabel(int index) {
    return 'المهمّة $index';
  }

  @override
  String missionsLeversAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إضافة $count مهمّة يومية',
      many: 'إضافة $count مهمّة يومية',
      few: 'إضافة $count مهامّ يومية',
      two: 'إضافة مهمّتين يوميتين',
      one: 'إضافة مهمّة يومية واحدة',
      zero: 'اختيار واحدة على الأقل',
    );
    return '$_temp0';
  }

  @override
  String missionsLeversAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'أُضيفت $count مهمّة يومية.',
      many: 'أُضيفت $count مهمّة يومية.',
      few: 'أُضيفت $count مهامّ يومية.',
      two: 'أُضيفت مهمّتان يوميتان.',
      one: 'أُضيفت مهمّة يومية واحدة.',
      zero: 'لا جديد للإضافة. هذه المهامّ موجودة بالفعل.',
    );
    return '$_temp0';
  }

  @override
  String get missionsLeversNotNow => 'ليس الآن';

  @override
  String get missionsProjectTitle => 'مشروع الشهر';

  @override
  String get missionsProjectEmpty =>
      'التخطيط لمشروع واحد للأسابيع الأربعة القادمة.';

  @override
  String missionsProjectFromCompass(String title) {
    return 'من بوصلتك: $title';
  }

  @override
  String get missionsProjectUntitled => 'مشروع بلا عنوان';

  @override
  String missionsProjectMilestones(int done, int total) {
    return 'المحطات المُنجَزة: $done من $total';
  }

  @override
  String get missionsStatusPlanned => 'مخطَّط';

  @override
  String get missionsStatusActive => 'نشِط';

  @override
  String get missionsStatusPaused => 'متوقّف مؤقتًا';

  @override
  String get missionsStatusDone => 'مُنجَز';

  @override
  String get missionsProjectScreenSubtitle =>
      'مشروع واحد، وبضع محطات، ونظرة إلى الوراء.';

  @override
  String get missionsProjectTitleLabel => 'المشروع';

  @override
  String get missionsProjectTitleHint => 'ما الذي سيُبنى أو يُنجَز هذا الشهر؟';

  @override
  String get missionsProjectLinked => 'مرتبط ببوصلتك';

  @override
  String missionsProjectOfferUpdate(String title) {
    return 'بوصلتك تقول: $title. تحديثها لتتطابق؟';
  }

  @override
  String get missionsProjectOfferAdd => 'إضافة هذا كمشروع الشهر في بوصلتك؟';

  @override
  String get missionsProjectUpdateCompass => 'تحديث البوصلة';

  @override
  String get missionsProjectAddCompass => 'إضافة إلى البوصلة';

  @override
  String get missionsProjectKeep => 'إبقاؤه كما هو';

  @override
  String get missionsProjectCompassUpdated => 'حُدّثت البوصلة';

  @override
  String get missionsProjectStatus => 'الحالة';

  @override
  String get missionsMilestones => 'المحطات';

  @override
  String get missionsMilestonesEmpty =>
      'تقسيم المشروع إلى بضع خطوات يمكن لأي أحد رؤيتها.';

  @override
  String get missionsMilestoneAdd => 'إضافة محطة';

  @override
  String get missionsMilestoneNew => 'محطة جديدة';

  @override
  String get missionsMilestoneRename => 'إعادة تسمية المحطة';

  @override
  String missionsMilestoneMarkDone(String title) {
    return 'تحديد المحطة «$title» كمُنجَزة';
  }

  @override
  String missionsMilestoneRenameLabel(String title) {
    return 'إعادة تسمية «$title»';
  }

  @override
  String missionsMilestoneDeleteLabel(String title) {
    return 'حذف «$title»';
  }

  @override
  String get missionsMilestoneDeleted => 'حُذفت المحطة';

  @override
  String get missionsRetro => 'نظرة إلى الوراء';

  @override
  String get missionsRetroHelp => 'ما نجح، وما تعلّمته، وما يستحق التغيير.';

  @override
  String get missionsRetroHint => 'ملاحظاتك';

  @override
  String get missionsProjectClear => 'حذف هذا المشروع';

  @override
  String get missionsProjectClearTitle => 'حذف هذا المشروع؟';

  @override
  String get missionsProjectClearBody =>
      'يذهب عنوانه ومحطاته وملاحظاته نهائيًا. وتبقى بوصلتك ومهامّك ومحاولاتك.';

  @override
  String get missionsProjectClearConfirm => 'حذف';

  @override
  String get missionsPathTitle => 'مسار 30 يومًا';

  @override
  String get missionsPathIntro => 'كل يوم مفتوح، على إيقاعك.';

  @override
  String missionsPathWrittenCount(int count) {
    return 'المكتوب: $count من 30';
  }

  @override
  String get missionsStageObserve => 'الملاحظة';

  @override
  String get missionsStageExperiment => 'التجربة';

  @override
  String get missionsStageBuild => 'البناء';

  @override
  String get missionsStageAdjust => 'التعديل';

  @override
  String get missionsStageObserveHelp => 'ملاحظة ما يحدث، دون الحكم عليه.';

  @override
  String get missionsStageExperimentHelp => 'تغييرات صغيرة لمعرفة ما يفيد.';

  @override
  String get missionsStageBuildHelp => 'الإبقاء على ما يفيد وتسهيله.';

  @override
  String get missionsStageAdjustHelp => 'نظرة إلى الوراء وتعديل الوجهة.';

  @override
  String missionsStageDays(int from, int to) {
    return 'الأيام $from–$to';
  }

  @override
  String missionsDayLabel(int day) {
    return 'اليوم $day';
  }

  @override
  String get missionsDayWritten => 'مكتوب';

  @override
  String missionsDayStage(int day, String stage) {
    return 'اليوم $day · $stage';
  }

  @override
  String missionsDayAnswerLabel(int day) {
    return 'ملاحظتك لليوم $day';
  }

  @override
  String get missionsDayAnswerHint => 'قليلًا أو كثيرًا، كما يناسبك.';

  @override
  String missionsDayPrevious(int day) {
    return 'اليوم $day';
  }

  @override
  String missionsDayNext(int day) {
    return 'اليوم $day';
  }

  @override
  String missionsDayPreviousLabel(int day) {
    return 'السابق: اليوم $day';
  }

  @override
  String missionsDayNextLabel(int day) {
    return 'التالي: اليوم $day';
  }

  @override
  String get missionsDayMissing => 'هذا اليوم غير متاح.';

  @override
  String get onboardingBrandIntro =>
      'يوم واحد صادق من التأمّل. ثم خطوات صغيرة.';

  @override
  String get onboardingBegin => 'لنبدأ';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingStart => 'انطلاق';

  @override
  String onboardingStepCounter(int current, int total) {
    return 'الخطوة $current من $total';
  }

  @override
  String get onboardingLimitsTitle => 'قبل البدء';

  @override
  String get onboardingLimitsIntro => 'بضع كلمات صادقة.';

  @override
  String get onboardingLimitsClarityTitle => 'يوم واحد قد يجلب الوضوح';

  @override
  String get onboardingLimitsClarityBody => 'صورة أوضح لموقعك الآن ولما يهمّك.';

  @override
  String get onboardingLimitsNoGuaranteeTitle =>
      'لن يُصلح حياتك بين ليلة وضحاها';

  @override
  String get onboardingLimitsNoGuaranteeBody =>
      'التغيير يأتي من خطوات صغيرة، أسبوعًا بعد أسبوع.';

  @override
  String get onboardingLimitsNotTherapyTitle => 'ليس علاجًا نفسيًا';

  @override
  String get onboardingLimitsNotTherapyBody =>
      'لا تشخيص هنا. للمساعدة: أنت › الدعم.';

  @override
  String get onboardingLimitsControlTitle => 'القرار بيدك';

  @override
  String get onboardingLimitsControlBody =>
      'يمكنك تخطّي أي سؤال أو تلطيفه أو إيقافه مؤقتًا.';

  @override
  String get onboardingAdultConfirm => 'عمري 18 عامًا أو أكثر';

  @override
  String get onboardingAdultConfirmHelp => 'مصمَّم للبالغين.';

  @override
  String get onboardingAdultRequired =>
      'للمتابعة، يُرجى تأكيد أن عمرك 18 عامًا أو أكثر.';

  @override
  String get onboardingCreditTitle => 'مستوحى من';

  @override
  String onboardingCreditByline(String author, String date) {
    return 'بقلم $author · $date';
  }

  @override
  String get onboardingCreditArticle => 'قراءة المقال الأصلي';

  @override
  String get onboardingCreditNewsletter => 'قراءته في النشرة البريدية للكاتب';

  @override
  String get onboardingCreditNoNeed => 'لا حاجة لقراءته أولًا.';

  @override
  String get onboardingPaceTitle => 'اختيار إيقاعك';

  @override
  String get onboardingPaceIntro => 'يمكن تغييره في أي وقت من «أنت».';

  @override
  String get onboardingPaceOneDayTitle => 'يوم واحد';

  @override
  String get onboardingPaceOneDayBody => 'الصباح والنهار والمساء في يوم واحد.';

  @override
  String get onboardingPaceFlexibleTitle => 'مرن';

  @override
  String get onboardingPaceFlexibleBody => 'على مهلك. والعودة ممكنة في أي وقت.';

  @override
  String get onboardingPaceNoLock => 'لا شيء يُقفَل أو تنتهي مدّته.';

  @override
  String get onboardingNameTitle => 'بماذا نناديك؟';

  @override
  String get onboardingNameIntro => 'اختياري. يبقى على هذا الهاتف.';

  @override
  String get onboardingNameLabel => 'الاسم (اختياري)';

  @override
  String get onboardingNameHelp => 'إن تركته فارغًا، فسنناديك «رحّالة».';

  @override
  String get onboardingPrivacyTitle => 'كلماتك تبقى لك';

  @override
  String get onboardingPrivacyStorageHeading => 'أين تُحفظ كتاباتك';

  @override
  String get onboardingPrivacyNoAccount => 'لا حساب ولا إعلانات ولا تحليلات.';

  @override
  String get onboardingPrivacyControl =>
      'التصدير أو الحذف متاح دائمًا في أنت › بياناتك.';

  @override
  String get personaFeatureTitle => 'استراتيجيّك';

  @override
  String get personaAvatarLabel => 'صورتك الرمزية';

  @override
  String get personaNoAvatar => 'لا صورة رمزية بعد';

  @override
  String get personaCreate => 'إنشاء صورتك الرمزية';

  @override
  String get personaEdit => 'تعديل صورتك الرمزية';

  @override
  String get personaSilhouette => 'ظِلّ';

  @override
  String get personaLocked => 'مقفلة';

  @override
  String get personaUnlockWithPick => 'متاحة باختيار مكافأة';

  @override
  String personaNextPickStop(String place) {
    return 'الاختيار التالي عند $place';
  }

  @override
  String personaNextPickAchievement(String achievement) {
    return 'الاختيار التالي: إنجاز «$achievement»';
  }

  @override
  String get personaCategorySkin => 'البشرة';

  @override
  String get personaCategoryFace => 'الوجه';

  @override
  String get personaCategoryHair => 'الشعر';

  @override
  String get personaCategoryHairColor => 'لون الشعر';

  @override
  String get personaCategoryFacialHair => 'شعر الوجه';

  @override
  String get personaCategoryEyewear => 'النظارات';

  @override
  String get personaCategoryMark => 'علامات';

  @override
  String get personaCategoryExpression => 'التعبير';

  @override
  String get personaCategoryHeadwear => 'غطاء الرأس';

  @override
  String get personaCategoryGarment => 'الملابس';

  @override
  String get personaCategoryGarmentColor => 'اللون';

  @override
  String get personaCategoryAccessory => 'المتاع';

  @override
  String get personaCategorySigil => 'الراية';

  @override
  String personaSkinTone(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'sand': 'رملي',
      'honey': 'عسلي',
      'clay': 'طيني',
      'copper': 'نحاسي',
      'chestnut': 'كستنائي',
      'walnut': 'جوزي',
      'umber': 'بنّي داكن',
      'ebony': 'أبنوسي',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaFace(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'oval': 'بيضاوي',
      'round': 'مستدير',
      'square': 'مربّع',
      'long': 'طويل',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHair(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'bald': 'بلا شعر',
      'buzz': 'قصير جدًا',
      'short': 'قصير',
      'wavy': 'مموّج',
      'curly': 'مجعّد',
      'coily': 'ملفوف',
      'afro': 'أفرو',
      'locs': 'خصل مجدولة',
      'braids': 'ضفائر',
      'bun': 'كعكة',
      'long': 'طويل',
      'ponytail': 'ذيل حصان',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHairColor(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'black': 'أسود',
      'darkBrown': 'بنّي داكن',
      'brown': 'بنّي',
      'auburn': 'كستنائي محمرّ',
      'copper': 'نحاسي',
      'blonde': 'أشقر',
      'grey': 'رمادي',
      'white': 'أبيض',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaFacialHair(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'بلا',
      'stubble': 'لحية خفيفة',
      'moustache': 'شارب',
      'beard': 'لحية',
      'fullBeard': 'لحية كثّة',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaEyewear(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'بلا',
      'round': 'نظارات مستديرة',
      'square': 'نظارات مربّعة',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaMark(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'بلا',
      'freckles': 'نمش',
      'beautyMark': 'شامة',
      'vitiligo': 'بهاق',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaExpression(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'calm': 'هدوء',
      'smile': 'ابتسامة',
      'focused': 'تركيز',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaHeadwear(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'بلا',
      'headscarf': 'وشاح الرأس',
      'turban': 'عمامة',
      'hood': 'قلنسوة',
      'circlet': 'إكليل رفيع',
      'laurel': 'إكليل غار',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaGarment(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'tunic': 'سترة طويلة',
      'cloak': 'عباءة',
      'robe': 'رداء',
      'wrap': 'ملحفة',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaGarmentColor(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'forest': 'أخضر الغابة',
      'olive': 'زيتوني',
      'sand': 'رملي',
      'ivory': 'عاجي',
      'sage': 'أخضر مريمي',
      'indigo': 'نيلي',
      'crimson': 'قرمزي',
      'bronze': 'برونزي',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaAccessory(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'بلا',
      'satchel': 'حقيبة كتف',
      'scroll': 'لفافة',
      'compass': 'بوصلة',
      'amulet': 'تميمة تانيت',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String personaSigil(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'none': 'بلا',
      'elephant': 'فيل',
      'sun': 'شمس مشرقة',
      'path': 'درب',
      'compass': 'بوصلة',
      'star': 'نجم الشمال',
      'laurel': 'غار',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String get personaBuilderSurprise => 'فاجئني';

  @override
  String get personaBuilderSurprised => 'مظهر جديد. لم يُحفظ بعد.';

  @override
  String get personaBuilderUndo => 'تراجع';

  @override
  String get personaBuilderParts => 'أجزاء الصورة الرمزية';

  @override
  String personaBuilderPartLabel(String category, String value) {
    return '$category: $value';
  }

  @override
  String personaBuilderPreviewLabel(String parts) {
    return 'معاينة الصورة الرمزية. $parts';
  }

  @override
  String get personaBuilderLockedNote =>
      'الإضافات المقفلة تُفتح باختيارات المكافأة.';

  @override
  String get personaBuilderKept => 'باقية لك';

  @override
  String get personaBuilderHiddenSilhouette =>
      'اختيار لون البشرة يُظهر الوجه والألوان.';

  @override
  String get personaBuilderHiddenHeadwear => 'الشعر مخفيّ تحت غطاء الرأس.';

  @override
  String get personaBuilderMottoLabel => 'عبارتك (اختيارية)';

  @override
  String get personaBuilderMottoHint => 'بضع كلمات من عندك';

  @override
  String personaBuilderMottoCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get personaBuilderMottoTooLong =>
      'أطول قليلًا من اللازم. يلزم تقصيرها للحفظ.';

  @override
  String personaBuilderMottoQuoted(String motto) {
    return '«$motto»';
  }

  @override
  String get personaBuilderSaved => 'حُفظت الصورة الرمزية.';

  @override
  String get personaBuilderNotSaved =>
      'لم تُحفظ على هذا الهاتف بعد. «إعادة المحاولة» في الأعلى، أو تصدير نسخة.';

  @override
  String get personaBuilderRemove => 'إزالة الصورة الرمزية';

  @override
  String get personaBuilderRemoveTitle => 'إزالة صورتك الرمزية؟';

  @override
  String get personaBuilderRemoveBody =>
      'يعود ملفك إلى إظهار الشعار. ويمكن إنشاء صورة جديدة في أي وقت.';

  @override
  String get personaBuilderRemoveAction => 'إزالة';

  @override
  String get personaBuilderRemoved => 'أُزيلت الصورة الرمزية.';

  @override
  String get personaBuilderRemovedNotSaved =>
      'أُزيلت هنا، لكن التغيير لم يُحفظ على هذا الهاتف بعد. «إعادة المحاولة» في الأعلى.';

  @override
  String get personaBuilderLeaveTitle => 'المغادرة دون حفظ؟';

  @override
  String get personaBuilderLeaveBody => 'لن تُحفظ تغييرات صورتك الرمزية.';

  @override
  String get personaBuilderLeaveAction => 'مغادرة';

  @override
  String get personaBuilderKeepEditing => 'متابعة التعديل';

  @override
  String get personaBuilderProfileHint =>
      'الاسم والصورة الرمزية اختياريان ويبقيان على هذا الهاتف.';

  @override
  String get projectsPictureTitle => 'الصورة';

  @override
  String get projectsPictureEmpty =>
      'مشهد مرسوم أو صورة فوتوغرافية. تظهر على مهامّ هذا المشروع.';

  @override
  String get projectsPictureChoose => 'اختيار صورة';

  @override
  String get projectsPictureChange => 'تغيير الصورة';

  @override
  String get projectsPictureRemove => 'إزالة الصورة';

  @override
  String get projectsPictureRemoved => 'أُزيلت الصورة';

  @override
  String get projectsPhotoRemoveTitle => 'إزالة الصورة؟';

  @override
  String get projectsPhotoRemoveBody =>
      'تُحذف من التطبيق. ولا تُمسّ الصور في معرض هاتفك.';

  @override
  String get projectsPhotoRemoveConfirm => 'إزالة الصورة';

  @override
  String get projectsClearBodyPhoto =>
      'يذهب عنوانه ومحطاته وملاحظاته وصورته نهائيًا. وتبقى بوصلتك ومهامّك ومحاولاتك.';

  @override
  String get projectsDeleteFinishInstead => 'إنهاؤه والاحتفاظ به بدلًا من ذلك';

  @override
  String get projectsDeletedCurrent => 'حُذف المشروع';

  @override
  String projectsPictureLabel(String name) {
    return 'صورة المشروع: $name';
  }

  @override
  String get projectsPhotoName => 'صورتك';

  @override
  String get projectsPhotoMissing => 'لم يُعثر على الصورة في هذا الهاتف';

  @override
  String get projectsArtSheetTitle => 'صورة المشروع';

  @override
  String get projectsArtScenes => 'مشاهد مرسومة';

  @override
  String get projectsArtPhoto => 'صورتك';

  @override
  String get projectsArtPhotoNote => 'تبقى الصور على هذا الهاتف.';

  @override
  String get projectsArtChoosePhoto => 'اختيار صورة';

  @override
  String get projectsArtTakePhoto => 'التقاط صورة';

  @override
  String get projectsArtAdding => 'جارٍ إضافة الصورة…';

  @override
  String get projectsArtSelected => 'محدَّدة';

  @override
  String get projectsArtReplacesPhoto =>
      'اختيار صورة أخرى يحذف صورتك من التطبيق.';

  @override
  String get projectsArtSunrise => 'شروق';

  @override
  String get projectsArtPath => 'طريق متعرّج';

  @override
  String get projectsArtCompass => 'تلّ البوصلة';

  @override
  String get projectsArtSteps => 'درجات حجرية';

  @override
  String get projectsArtDawnRuins => 'أطلال عند الفجر';

  @override
  String get projectsArtRoots => 'جذور عميقة';

  @override
  String get projectsArtCitadel => 'بلدة على تلّ';

  @override
  String get projectsArtSailing => 'إبحار';

  @override
  String get projectsArtRoute => 'طريق القمّة';

  @override
  String get projectsPhotoDeniedCamera =>
      'الوصول إلى الكاميرا متوقف. يمكن السماح به من الإعدادات، أو اختيار صورة أو مشهد مرسوم.';

  @override
  String get projectsPhotoDeniedLibrary =>
      'الوصول إلى الصور متوقف. يمكن السماح به من الإعدادات، أو اختيار مشهد مرسوم.';

  @override
  String get projectsPhotoNoCamera =>
      'لا كاميرا هنا. يمكن اختيار صورة أو مشهد مرسوم.';

  @override
  String get projectsPhotoNoLibrary =>
      'الصور غير متاحة هنا. يمكن اختيار مشهد مرسوم.';

  @override
  String get projectsPhotoFailed =>
      'تعذّر الحصول على الصورة. يمكن المحاولة مجددًا، أو اختيار مشهد مرسوم.';

  @override
  String get projectsPhotoTooLarge =>
      'هذه الصورة أكبر من أن تُحفظ. يمكن تجربة صورة أخرى.';

  @override
  String get projectsPhotoNotKept =>
      'تعذّر حفظ الصورة على هذا الهاتف. يُرجى التحقق من المساحة الفارغة والمحاولة مجددًا.';

  @override
  String get projectsNotSaved =>
      'لم يُحفظ بعد. زرّ «إعادة المحاولة» في هذه الصفحة.';

  @override
  String get projectsFinish => 'إنهاء هذا المشروع';

  @override
  String get projectsFinishSheetBody =>
      'ينتقل إلى سجلّك مع محطاته ومهامّه ومحاولاته.';

  @override
  String get projectsFinishConfirm => 'إنهاء واحتفاظ';

  @override
  String get projectsFinishedSnack => 'محفوظ في سجلّ مشاريعك.';

  @override
  String get projectsFinishedTitle => 'انتهى وحُفظ';

  @override
  String projectsFinishedBody(String title) {
    return '«$title» في سجلّ مشاريعك.';
  }

  @override
  String get projectsPlanNext => 'التخطيط للمشروع التالي';

  @override
  String get projectsViewHistory => 'عرض السجلّ';

  @override
  String projectsHistoryLink(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سجلّ المشاريع · $count',
    );
    return '$_temp0';
  }

  @override
  String get projectsCardNext => 'التخطيط لمشروعك التالي.';

  @override
  String get projectsHistoryTitle => 'مشاريع سابقة';

  @override
  String get projectsHistorySubtitle => 'ما بنيته، شهرًا بعد شهر.';

  @override
  String get projectsHistoryEmptyTitle => 'لا شيء هنا بعد';

  @override
  String get projectsHistoryEmptyBody => 'إنهاء مشروع الشهر يحفظه هنا.';

  @override
  String projectsMonths(String start, String end) {
    return '$start – $end';
  }

  @override
  String projectsTasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمّة',
      many: '$count مهمّة',
      few: '$count مهامّ',
      two: 'مهمّتان',
      one: 'مهمّة واحدة',
      zero: 'لا مهامّ',
    );
    return '$_temp0';
  }

  @override
  String projectsAttemptsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محاولة',
      many: '$count محاولة',
      few: '$count محاولات',
      two: 'محاولتان',
      one: 'محاولة واحدة',
      zero: 'لا محاولات',
    );
    return '$_temp0';
  }

  @override
  String get projectsNoMilestones => 'لا محطات';

  @override
  String get projectsRetroEmpty => 'لم تُكتب ملاحظات.';

  @override
  String get projectsPastTitle => 'مشروع سابق';

  @override
  String projectsFinishedOn(String date) {
    return 'انتهى في $date';
  }

  @override
  String get projectsMilestoneDone => 'مُنجَزة';

  @override
  String get projectsMilestoneOpen => 'مفتوحة';

  @override
  String get projectsTasks => 'المهامّ';

  @override
  String get projectsTasksEmpty => 'لا مهامّ مرتبطة به.';

  @override
  String get projectsAttempts => 'المحاولات';

  @override
  String get projectsAttemptsEmpty => 'لا محاولات مرتبطة به.';

  @override
  String get projectsTaskDone => 'مُنجَزة';

  @override
  String get projectsDelete => 'إزالة من السجلّ';

  @override
  String get projectsDeleteTitle => 'إزالة هذا المشروع؟';

  @override
  String get projectsDeleteBody =>
      'يذهب عنوانه ومحطاته وملاحظاته وصورته. وتبقى مهامّه ومحاولاته.';

  @override
  String get projectsDeleteConfirm => 'إزالة';

  @override
  String get projectsDeleted => 'أُزيل المشروع';

  @override
  String projectsTagLabel(String title) {
    return 'المشروع: $title';
  }

  @override
  String get projectsQuestLink => 'جزء من مشروع الشهر';

  @override
  String get projectsQuestLinkPast => 'جزء من مشروع منتهٍ';

  @override
  String projectsKeepsakes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مشاريع منتهية',
      two: 'مشروعان منتهيان',
      one: 'مشروع منتهٍ',
    );
    return '$_temp0';
  }

  @override
  String projectsKeepsakesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مشروع محفوظ',
      many: '$count مشروعًا محفوظًا',
      few: '$count مشاريع محفوظة',
      two: 'مشروعان محفوظان',
      one: 'مشروع واحد محفوظ',
      zero: 'لا مشاريع محفوظة',
    );
    return '$_temp0';
  }

  @override
  String get resetTitle => 'إعادة الضبط';

  @override
  String get resetSubtitle => 'يوم واحد لمعرفة أين أنت، واختيار وجهتك.';

  @override
  String get resetPaceOneDayTitle => 'إيقاعك: يوم واحد';

  @override
  String get resetPaceOneDayBody =>
      'الصباح، فالنهار، فالمساء. لا شيء يُقفَل إن استغرق الأمر أطول.';

  @override
  String get resetPaceFlexibleTitle => 'إيقاعك: مرن';

  @override
  String get resetPaceFlexibleBody =>
      'بأي ترتيب وأي إيقاع. لا شيء يُقفَل أو تنتهي مدّته.';

  @override
  String get resetPaceChange => 'تغيير الإيقاع';

  @override
  String get resetProgressTitle => 'رحلتك في إعادة الضبط';

  @override
  String resetProgressCount(int answered, int total) {
    return 'الأسئلة الأساسية المُجاب عنها: $answered من $total';
  }

  @override
  String resetProgressNext(String title) {
    return 'التالي: $title';
  }

  @override
  String get resetBegin => 'لنبدأ';

  @override
  String get resetContinue => 'متابعة';

  @override
  String get resetAllDoneBody =>
      'كل الأسئلة الأساسية أُجيب عنها أو تُخطّيت. وما زال تعديلها ممكنًا.';

  @override
  String get resetSeeCreated => 'عرض ما صنعته';

  @override
  String resetCompletedOn(String date) {
    return 'اكتملت في $date. وتبقى الإجابات قابلة للتعديل.';
  }

  @override
  String get resetPhasesTitle => 'يومك';

  @override
  String get resetPhaseMorning => 'الصباح';

  @override
  String get resetPhaseDaytime => 'النهار';

  @override
  String get resetPhaseBonus => 'اختياري';

  @override
  String get resetPhaseEvening => 'المساء';

  @override
  String get resetSubflowMirror => 'المرآة';

  @override
  String get resetSubflowVision => 'الرؤية';

  @override
  String get resetSubflowInterrupt => 'الوقفة';

  @override
  String get resetSubflowBreakthrough => 'الانطلاقة';

  @override
  String get resetMirrorBody => 'الواقع الحالي، والمستقبلات الممكنة، والهوية';

  @override
  String get resetVisionBody => 'يوم عادي جميل، والذات المنشودة، وخطوة واحدة';

  @override
  String get resetInterruptBody => 'ست وقفات قصيرة في لحظات من يومك';

  @override
  String get resetBreakthroughBody => 'خلاصات، ووجهة، وخطة';

  @override
  String get resetGroupCurrentReality => 'الواقع الحالي';

  @override
  String get resetGroupAntiVision => 'مستقبل غير مرغوب فيه';

  @override
  String get resetGroupIdentity => 'الهوية';

  @override
  String get resetGroupVision => 'الرؤية';

  @override
  String get resetGroupInterrupt => 'وقفة';

  @override
  String get resetGroupContemplation => 'تأمّل أعمق';

  @override
  String get resetGroupInsight => 'الخلاصات';

  @override
  String get resetGroupDirection => 'الوجهة';

  @override
  String get resetGroupPlan => 'الخطة';

  @override
  String resetCountAnswered(int answered, int total) {
    return 'المُجاب: $answered من $total';
  }

  @override
  String resetCountAnsweredSkipped(int answered, int total, int skipped) {
    return 'المُجاب: $answered من $total، والمتخطّى: $skipped';
  }

  @override
  String get resetCountNotStarted => 'لم يبدأ بعد';

  @override
  String resetRingLabel(int answered, int total) {
    return '$answered/$total';
  }

  @override
  String resetOpenPhase(String phase) {
    return 'فتح أسئلة $phase';
  }

  @override
  String get resetStateAnswered => 'مُجاب';

  @override
  String get resetStateSkipped => 'متخطّى';

  @override
  String get resetStateOpen => 'لم يُجَب بعد';

  @override
  String get resetStateCurrent => 'أنت هنا';

  @override
  String resetCheckinTime(String time) {
    return 'وقفة · $time';
  }

  @override
  String get resetOptionalTitle => 'تأمّلات اختيارية';

  @override
  String get resetOptionalBody => 'ثلاثة أسئلة إضافية. اختيارية.';

  @override
  String get resetOptionalChip => 'اختياري';

  @override
  String get resetPastTitle => 'إعادات ضبط سابقة';

  @override
  String resetPastStarted(String date) {
    return 'بدأت في $date';
  }

  @override
  String resetPastFinished(String date) {
    return 'اكتملت في $date';
  }

  @override
  String get resetPastUnfinished => 'لم تكتمل';

  @override
  String resetPastAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إجابة',
      many: '$count إجابة',
      few: '$count إجابات',
      two: 'إجابتان',
      one: 'إجابة واحدة',
      zero: 'لا إجابات',
    );
    return '$_temp0';
  }

  @override
  String get resetNewTitle => 'بدء إعادة ضبط جديدة';

  @override
  String get resetNewBody => 'بداية جديدة. وتبقى هذه في «إعادات ضبط سابقة».';

  @override
  String get resetNewConfirmTitle => 'بدء إعادة ضبط جديدة؟';

  @override
  String get resetNewConfirmBody =>
      'تنتقل إجاباتك إلى «إعادات ضبط سابقة». وتبقى البوصلة والمهامّ واليوميات.';

  @override
  String get resetNewConfirmAction => 'بدء إعادة ضبط جديدة';

  @override
  String get resetNewStarted =>
      'بدأت إعادة ضبط جديدة. والسابقة في «إعادات ضبط سابقة».';

  @override
  String resetQuestionOf(int n, int total) {
    return 'السؤال $n من $total';
  }

  @override
  String get resetPauseTooltip => 'إيقاف مؤقت والعودة إلى إعادة الضبط';

  @override
  String get resetJumpTooltip => 'الانتقال إلى سؤال';

  @override
  String get resetJump => 'انتقال';

  @override
  String resetJumpTitle(String phase) {
    return 'أسئلة $phase';
  }

  @override
  String get resetSofter => 'صياغة ألطف';

  @override
  String get resetSofterHint => 'السؤال نفسه، بلطف أكبر.';

  @override
  String get resetHelpLink => 'ما معنى هذا؟';

  @override
  String get resetExampleTitle => 'مثال، لا إجابة صحيحة';

  @override
  String get resetAnswerLabel => 'إجابتك';

  @override
  String get resetAnswerHint => 'قليلًا أو كثيرًا، كما يناسبك.';

  @override
  String get resetSkippedNote => 'تُخطّي. يمكنك العودة إليه متى شئت، أو تركه.';

  @override
  String get resetSaveContinue => 'حفظ ومتابعة';

  @override
  String get resetSaveFinish => 'حفظ وإنهاء';

  @override
  String get resetSkip => 'التخطّي الآن';

  @override
  String get resetPause => 'إيقاف مؤقت';

  @override
  String get resetHeavyLink => 'هل الأمر ثقيل؟';

  @override
  String get resetHeavyTitle => 'قد يكون هذا كثيرًا';

  @override
  String get resetHeavyBody =>
      'العمق الذي يناسبك يكفي: يمكنك التلطيف أو التخطّي أو التوقف. كلماتك محفوظة.';

  @override
  String get resetHeavySofter => 'التحوّل إلى صياغة ألطف';

  @override
  String get resetHeavySkip => 'تخطّي هذا السؤال';

  @override
  String get resetHeavyPause => 'أخذ استراحة';

  @override
  String get resetHeavySupport => 'الدعم والأمان';

  @override
  String get resetHeavyCrisis =>
      'Cartharise ليس علاجًا. إن شعرت بأنك لست في أمان، يُرجى التواصل الآن مع خدمات الطوارئ أو خط مساندة للأزمات.';

  @override
  String get resetPromptMissing => 'هذا السؤال غير متاح.';

  @override
  String get resetCompleteTitle => 'اكتملت إعادة الضبط';

  @override
  String get resetCompleteLead => 'يوم واحد قد يجلب الوضوح؛ والباقي ممارسة.';

  @override
  String get resetCompleteCreatedTitle => 'ما صنعته';

  @override
  String resetCompleteAnswers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'كُتبت $count إجابة',
      many: 'كُتبت $count إجابة',
      few: 'كُتبت $count إجابات',
      two: 'كُتبت إجابتان',
      one: 'كُتبت إجابة واحدة',
      zero: 'لم تُكتب إجابات',
    );
    return '$_temp0';
  }

  @override
  String resetCompleteSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تُخطّي $count سؤال',
      many: 'تُخطّي $count سؤالًا',
      few: 'تُخطّيت $count أسئلة',
      two: 'تُخطّي سؤالان',
      one: 'تُخطّي سؤال واحد',
      zero: 'لم يُتخطَّ أي سؤال',
    );
    return '$_temp0';
  }

  @override
  String resetCompletePhaseLine(String phase, int answered, int total) {
    return '$phase: المُجاب $answered من $total';
  }

  @override
  String get resetCompleteVisionTitle => 'رؤيتك، بكلماتك';

  @override
  String resetCompleteOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ما زال $count سؤال أساسي مفتوحًا.',
      many: 'ما زال $count سؤالًا أساسيًا مفتوحًا.',
      few: 'ما زالت $count أسئلة أساسية مفتوحة.',
      two: 'ما زال سؤالان أساسيان مفتوحين.',
      one: 'ما زال سؤال أساسي واحد مفتوحًا.',
      zero: 'لا أسئلة أساسية مفتوحة.',
    );
    return '$_temp0';
  }

  @override
  String get resetCompleteCompassBody =>
      'يمكن لإجابات المساء أن تبدأ بها بوصلة حياتك. القرار لك، ولا يُستبدل شيء.';

  @override
  String get resetCompleteBuildCompass => 'بناء بوصلتك';

  @override
  String get resetCompleteLater => 'لاحقًا';

  @override
  String todayGreetingMorning(String name) {
    return 'صباح الخير يا $name.';
  }

  @override
  String todayGreetingAfternoon(String name) {
    return 'طاب نهارك يا $name.';
  }

  @override
  String todayGreetingEvening(String name) {
    return 'مساء الخير يا $name.';
  }

  @override
  String get todayDefaultName => 'رحّالة';

  @override
  String get todaySubtitle => 'وضوح اليوم، وتقدّم الغد.';

  @override
  String get todayNextEyebrow => 'خطوتك التالية';

  @override
  String get todayNextStartTitle => 'تأمّل الصباح بانتظارك';

  @override
  String todayNextStartBody(int count) {
    return '$count من الأسئلة القصيرة. يمكن تخطّي أيّ منها والتوقف متى شئت.';
  }

  @override
  String get todayNextStartHint =>
      'الصباح، ثم النهار، ثم المساء: يوم واحد، على مهلك.';

  @override
  String get todayNextStartAction => 'لنبدأ';

  @override
  String todayNextLessonsAction(int count) {
    return 'قراءة الأفكار ($count) أولًا، اختياري';
  }

  @override
  String todayNextResumeTitle(String phase) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'morning': 'متابعة تأمّل الصباح',
      'daytime': 'متابعة وقفات النهار',
      'evening': 'متابعة تأمّل المساء',
      'other': 'متابعة إعادة الضبط',
    });
    return '$_temp0';
  }

  @override
  String todayNextResumeBody(String title) {
    return 'التالي: $title';
  }

  @override
  String todayNextResumePosition(String phase, int ordinal, int total) {
    String _temp0 = intl.Intl.selectLogic(phase, {
      'morning': 'الصباح',
      'daytime': 'النهار',
      'evening': 'المساء',
      'other': 'إعادة الضبط',
    });
    return '$_temp0 · السؤال $ordinal من $total';
  }

  @override
  String get todayNextResumeAction => 'متابعة';

  @override
  String get todayNextQuestBody => 'إحدى مهامّ اليوم.';

  @override
  String get todayNextQuestAction => 'تمّت';

  @override
  String get todayNextQuestOption => 'إنجاز إحدى مهامّ اليوم';

  @override
  String get todayNextCompassTitle => 'بناء بوصلتك';

  @override
  String get todayNextCompassImportBody =>
      'يمكن لإجابات المساء أن تملأ بوصلتك. والقرار لك.';

  @override
  String get todayNextCompassManualBody =>
      'رؤيتك، ومشروع للشهر، وروافع يومية، بكلماتك.';

  @override
  String get todayNextCompassImportAction => 'مراجعة إجاباتك';

  @override
  String get todayNextLeversTitle => 'من الروافع إلى المهامّ';

  @override
  String get todayNextLeversBody => 'روافعك اليومية يمكن أن تصبح مهامّ صغيرة.';

  @override
  String get todayNextLeversAction => 'اختيار المهامّ';

  @override
  String get todayNextProjectTitle => 'العمل على مشروعك';

  @override
  String todayNextProjectNext(String milestone) {
    return 'التالي: $milestone';
  }

  @override
  String get todayNextProjectAction => 'فتح المشروع';

  @override
  String get todayNextReviewTitle => 'نظرة إلى أسبوعك';

  @override
  String get todayNextReviewBody =>
      'ما الذي سار جيدًا، وما الذي اعترضك، وما التالي.';

  @override
  String get todayNextReviewAction => 'بدء مراجعة أسبوعية';

  @override
  String get todayNextJournalTitle => 'كتابة ملاحظة';

  @override
  String get todayNextJournalBody => 'بضعة أسطر عن اليوم.';

  @override
  String get todayNextJournalAction => 'ملاحظة جديدة';

  @override
  String get todayOpenCompass => 'فتح البوصلة';

  @override
  String get todayChooseOther => 'اختيار شيء آخر';

  @override
  String get todayChooseSteps => 'خطوات أخرى';

  @override
  String get todayPinTitle => 'ساعدني في';

  @override
  String get todayPinProject => 'مشروعي';

  @override
  String get todayPinReflection => 'التأمّل';

  @override
  String get todayPinNotes => 'الملاحظات';

  @override
  String get todayPinAuto => 'قرّر عنّي';

  @override
  String get todayPinNoProject => 'لا مشروع بعد. «اليوم» يختار عنك الآن.';

  @override
  String get todayDoneTitle => 'تمّ. وقد يكفي هذا لليوم.';

  @override
  String get todayDoneMore => 'خطوة أخرى';

  @override
  String get todayDoneMoreLabel => 'عرض خطوة أخرى';

  @override
  String get todayWriteHint => 'بضعة أسطر هنا…';

  @override
  String get todayWriteLabel => 'كتابة ملاحظة جديدة';

  @override
  String get todayFocusTitle => 'تركيز اليوم';

  @override
  String get todayFocusEmptyTitle => 'لا مهامّ لليوم';

  @override
  String get todayFocusEmptyBody => 'يمكنك إضافة مهمّة صغيرة متى ناسبك ذلك.';

  @override
  String get todayHintQuests =>
      'المهامّ خطوات صغيرة من اختيارك. ويمكن تعديلها كل أسبوع.';

  @override
  String get todayFocusAdd => 'إضافة مهمّة';

  @override
  String todayFocusSeeAll(int count) {
    return 'عرض كل المهامّ ($count)';
  }

  @override
  String todayFocusLater(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمّة أخرى لأي وقت أو لاحقًا',
      many: '$count مهمّة أخرى لأي وقت أو لاحقًا',
      few: '$count مهامّ أخرى لأي وقت أو لاحقًا',
      two: 'مهمّتان أخريان لأي وقت أو لاحقًا',
      one: 'مهمّة أخرى لأي وقت أو لاحقًا',
      zero: 'لا مهامّ لوقت لاحق',
    );
    return '$_temp0';
  }

  @override
  String todayQuestMarkDone(String title) {
    return 'تحديد «$title» كمُنجَزة';
  }

  @override
  String get todayQuestDaily => 'كل يوم';

  @override
  String todayJourneyWritten(int answered, int total) {
    return 'التأمّلات المكتوبة: $answered من $total';
  }

  @override
  String get todayJourneyOpenReset => 'فتح إعادة الضبط';

  @override
  String todayPathDay(int day) {
    return 'اليوم $day من 30';
  }

  @override
  String todayPathOpen(int day) {
    return 'فتح اليوم $day';
  }

  @override
  String get todayDirectionTitle => 'وجهتك';

  @override
  String get todayDirectionSummary => 'رؤيتك ومشروع هذا الشهر.';

  @override
  String todayDirectionLabel(String title, String summary) {
    return '$title. $summary';
  }

  @override
  String get todayDirectionEmpty => 'بوصلتك فارغة.';

  @override
  String get todayHintCompass => 'يمكن لإجاباتك أن تصبح بوصلة لحياتك.';

  @override
  String get todayDirectionVision => 'الرؤية';

  @override
  String get todayDirectionMonth => 'هذا الشهر';

  @override
  String get todayDirectionNoVision => 'لم تُكتب رؤية بعد.';

  @override
  String get todayDirectionNoMonth => 'لا مشروع للشهر بعد.';

  @override
  String get todayTileReset => 'إعادة الضبط';

  @override
  String todayTileResetValue(int answered, int total) {
    return '$answered/$total';
  }

  @override
  String get todayTileResetStart => 'البداية';

  @override
  String get todayTileResetDone => 'تمّ';

  @override
  String get todayTileResetDetail => 'تأمّلات';

  @override
  String get todayTileCampaign => 'الحملة';

  @override
  String todayTileCampaignValue(int level) {
    return 'مستوى $level';
  }

  @override
  String get todayTilePath => 'مسار 30 يومًا';

  @override
  String todayTilePathValue(int day) {
    return 'اليوم $day';
  }

  @override
  String todayPathStageName(String stage) {
    String _temp0 = intl.Intl.selectLogic(stage, {
      'observe': 'الملاحظة',
      'experiment': 'التجربة',
      'build': 'البناء',
      'adjust': 'التعديل',
      'other': 'المسار',
    });
    return '$_temp0';
  }

  @override
  String todayTileLabel(String title, String value, String detail) {
    return '$title: $value. $detail';
  }

  @override
  String get youTitle => 'أنت';

  @override
  String get youSubtitle => 'مساحتك، واختياراتك.';

  @override
  String get youProfileEyebrow => 'الملف الشخصي';

  @override
  String get youNoName => 'لم يُحدَّد اسم';

  @override
  String get youProfileBody =>
      'اختياري، ويبقى على هذا الهاتف. للتغيير، يكفي النقر.';

  @override
  String get youEditName => 'تعديل الاسم';

  @override
  String get youNameDialogTitle => 'اسمك';

  @override
  String get youNameHint => 'اختياري';

  @override
  String get youPaceTitle => 'الإيقاع';

  @override
  String get youPaceOneDay => 'يوم واحد';

  @override
  String get youPaceFlexible => 'مرن';

  @override
  String get youPaceHint => 'لا شيء يُقفَل. والتغيير ممكن في أي وقت.';

  @override
  String get youSectionCredit => 'المصدر';

  @override
  String get youSectionSettings => 'الإعدادات';

  @override
  String get youSectionCare => 'العناية';

  @override
  String get youSectionAbout => 'حول التطبيق';

  @override
  String get youInspiration => 'الإلهام';

  @override
  String get youInspirationHint => 'المقال الذي وراء Cartharise';

  @override
  String get youReminders => 'التذكيرات';

  @override
  String get youRemindersOn => 'مفعّلة';

  @override
  String get youRemindersOff => 'متوقفة';

  @override
  String get youAppearance => 'المظهر';

  @override
  String youAppearanceSummary(String theme, String mode) {
    return '$theme · $mode';
  }

  @override
  String get youData => 'بياناتك';

  @override
  String get youDataHint => 'تصدير أو استعادة أو حذف';

  @override
  String get youSupport => 'الدعم والأمان';

  @override
  String get youSupportHint => 'ليس علاجًا. مساعدة إن ثقلت الأمور.';

  @override
  String youVersion(String version, String build) {
    return 'الإصدار $version (البناء $build)';
  }

  @override
  String get youAboutBody => 'مستقل. كل شيء يبقى على هذا الهاتف.';

  @override
  String get youLicences => 'تراخيص المصادر المفتوحة';

  @override
  String get youLicencesHint =>
      'بما فيها خطوط Inter وCinzel وNoto Sans Arabic (رخصة SIL للخطوط المفتوحة)';

  @override
  String youLegalese(String title, String author) {
    return 'تطبيق مستقل مستوحى من «$title» للكاتب $author. غير تابع للكاتب ولا معتمد منه.';
  }

  @override
  String get youReplayWelcome => 'إعادة عرض الترحيب';

  @override
  String get youReplayWelcomeHint =>
      'عرض المقدّمة مجددًا. لا يتغيّر شيء مما كتبته.';

  @override
  String get youReplayConfirmTitle => 'إعادة عرض الترحيب؟';

  @override
  String get youReplayConfirmBody =>
      'عرض المقدّمة مجددًا. تبقى كتاباتك وإعداداتك.';

  @override
  String get youReplayConfirmAction => 'عرض الترحيب';

  @override
  String get youInspirationTitle => 'الإلهام';

  @override
  String get youInspirationSubtitle => 'العمل الذي ألهم Cartharise';

  @override
  String get youInspirationEyebrow => 'مستوحى من';

  @override
  String youInspirationByline(String author) {
    return 'بقلم $author';
  }

  @override
  String youInspirationPublished(String date) {
    return 'نُشر في $date';
  }

  @override
  String get youInspirationReadArticle => 'قراءة المقال على X';

  @override
  String get youInspirationReadNewsletter => 'قراءة نسخة النشرة البريدية';

  @override
  String youInspirationLinkHint(String host) {
    return 'يُفتح في متصفحك: $host';
  }

  @override
  String get youInspirationIndependentTitle => 'تطبيق مستقل';

  @override
  String get youInspirationParaphraseTitle => 'بكلمات Cartharise الخاصة';

  @override
  String get youInspirationSplitTitle => 'من المصدر، أم من إضافات Cartharise؟';

  @override
  String get youInspirationFromSource => 'من المقال، بإعادة صياغة';

  @override
  String get youInspirationSource1 => 'الأفكار السبع المركزية وراء دروس اليقظة';

  @override
  String get youInspirationSource2 =>
      'أسئلة إعادة الضبط في الصباح والنهار والمساء';

  @override
  String get youInspirationSource3 => 'الأجزاء الستة لبوصلة الحياة';

  @override
  String get youInspirationSource4 => 'أوقات الوقفات النهارية الستة';

  @override
  String get youInspirationAdded => 'من إضافات Cartharise';

  @override
  String get youInspirationAdded1 => 'الأمثلة ونصوص المساعدة والصياغات الألطف';

  @override
  String get youInspirationAdded2 =>
      'المهامّ، وشاشة «اليوم»، ومسار الثلاثين يومًا';

  @override
  String get youInspirationAdded3 =>
      'ملاحظات اليوميات، والمراجعات الأسبوعية، و«نظرة إلى الوراء»';

  @override
  String get youInspirationAdded4 =>
      'التذكيرات، وتصدير التقويم، والنسخ الاحتياطية';

  @override
  String get youInspirationReadOriginal =>
      'لمعرفة تفكير الكاتب كاملًا، يُستحسن قراءة الأصل.';

  @override
  String get youRemindersTitle => 'التذكيرات';

  @override
  String get youRemindersSubtitle => 'ست وقفات اختيارية خلال النهار.';

  @override
  String get youRemindersSwitch => 'إشعارات الوقفات';

  @override
  String get youRemindersSwitchOn => 'مفعّلة، في الأوقات أدناه.';

  @override
  String get youRemindersSwitchOff => 'متوقفة. لا يُرسَل شيء قبل تفعيلها.';

  @override
  String get youRemindersPrivacy =>
      'تُظهر الإشعارات عنوان الوقفة فقط، ولا تُظهر كلماتك أبدًا.';

  @override
  String get youRemindersDeniedTitle => 'الإشعارات غير مسموح بها';

  @override
  String get youRemindersDeniedBody =>
      'الإشعارات محظورة لتطبيق Cartharise. يمكن السماح بها من إعدادات الهاتف، أو إضافة الوقفات إلى تقويمك.';

  @override
  String get youRemindersUnavailableTitle => 'الإشعارات غير متاحة';

  @override
  String get youRemindersUnavailableBody =>
      'لا يستطيع هذا الهاتف عرض الإشعارات. يمكن إضافة الوقفات إلى تقويمك بدلًا من ذلك.';

  @override
  String get youRemindersScheduleFailed =>
      'تعذّرت جدولة الإشعارات. يمكن المحاولة مجددًا، أو استخدام تقويمك.';

  @override
  String get youRemindersCalendarInstead => 'الإضافة إلى تقويمك بدلًا من ذلك';

  @override
  String get youRemindersTimesTitle => 'أوقات الوقفات';

  @override
  String get youRemindersTimesBody =>
      'بالتوقيت المحلي. يمكن تغيير أيّ منها ليناسب يومك.';

  @override
  String youRemindersSourceDefault(String time) {
    return 'الافتراضي في المصدر $time';
  }

  @override
  String youRemindersUseDefault(String time) {
    return 'استخدام $time';
  }

  @override
  String youRemindersChangeTime(String title, String time) {
    return 'تغيير وقت «$title»، الآن $time';
  }

  @override
  String youRemindersRowLabel(String title, String time) {
    return 'وقفة «$title»، $time';
  }

  @override
  String get youRemindersQuietTitle => 'ساعات الهدوء';

  @override
  String get youRemindersQuietBody => 'لا إشعارات وقفات بين هذين الوقتين.';

  @override
  String get youRemindersQuietFrom => 'من';

  @override
  String get youRemindersQuietUntil => 'حتى';

  @override
  String get youRemindersQuietNotSet => 'غير محدَّد';

  @override
  String get youRemindersQuietClear => 'مسح ساعات الهدوء';

  @override
  String get youRemindersQuietIncomplete =>
      'لتطبيق ساعات الهدوء، يلزم تحديد الوقتين.';

  @override
  String get youRemindersCalendarTitle => 'الإضافة إلى تقويمك';

  @override
  String get youRemindersCalendarBody =>
      'ملف تقويم بوقفاتك لمدة 30 يومًا. العناوين فقط.';

  @override
  String get youRemindersCalendarButton => 'إضافة إلى التقويم (‎.ics)';

  @override
  String get youRemindersCalendarNone =>
      'لإنشاء الملف، يلزم تفعيل وقفة واحدة على الأقل.';

  @override
  String get youCalendarName => 'وقفات Cartharise';

  @override
  String youCalendarEventTitle(String title) {
    return 'وقفة Cartharise: $title';
  }

  @override
  String get youCalendarEventDescription =>
      'استراحة نهارية قصيرة من إعادة الضبط في Cartharise. يمكن فتح التطبيق متى ناسبك؛ وكل وقفة اختيارية.';

  @override
  String get youRemindersCalendarShared =>
      'شُورك ملف التقويم. يمكن فتحه في تطبيق التقويم.';

  @override
  String get youShareDismissed => 'لم تتمّ مشاركة شيء.';

  @override
  String get youAppearanceTitle => 'المظهر';

  @override
  String get youAppearanceSubtitle => 'الألوان، والفاتح أو الداكن، والحركة.';

  @override
  String get youThemeTitle => 'السمة';

  @override
  String get youThemeForest => 'الغابة';

  @override
  String get youThemeOlive => 'الزيتون';

  @override
  String get youThemeOasis => 'الواحة';

  @override
  String get youThemeTyrian => 'وردة صور';

  @override
  String get youThemeAlpine => 'الألب';

  @override
  String get youThemeObsidian => 'السَّبَج';

  @override
  String get youThemeAboutForest => 'غابة عميقة وبرونز: أصل Cartharise.';

  @override
  String get youThemeAboutOlive => 'بساتين الزيتون في الريف البونيقي.';

  @override
  String get youThemeAboutOasis => 'خضرة النخيل وذهب التمر في واحات الصحراء.';

  @override
  String get youThemeAboutTyrian => 'صبغة الورد من صور، المدينة الأم لقرطاج.';

  @override
  String get youThemeAboutAlpine => 'غرانيت وثلج، حيث عبر حنّبعل جبال الألب.';

  @override
  String get youThemeAboutObsidian =>
      'زجاج بركاني أسود وذهب. أسود حقيقي في الوضع الداكن.';

  @override
  String get youModeTitle => 'فاتح أو داكن';

  @override
  String get youModeSystem => 'النظام';

  @override
  String get youModeLight => 'فاتح';

  @override
  String get youModeDark => 'داكن';

  @override
  String get youMotion => 'حركة الواجهة';

  @override
  String get youMotionHint =>
      'انتقالات الشاشات والشعار المتحرك. تتوقف عندما يقلّل هاتفك الحركة.';

  @override
  String get youDataTitle => 'بياناتك';

  @override
  String get youDataSubtitle => 'كل ما يُكتب هنا يبقى على هذا الهاتف.';

  @override
  String get youDataWhereTitle => 'أين تُحفظ بياناتك';

  @override
  String get youDataExportTitle => 'تصدير نسخة احتياطية';

  @override
  String get youDataExportBody =>
      'يحفظ كل شيء، بما في ذلك الصور والتسجيلات، في ملف ‎.zip واحد. الملف غير مشفّر، لذا يُستحسن إبقاؤه خاصًا.';

  @override
  String get youDataExportButton => 'تصدير نسخة احتياطية';

  @override
  String get youDataExported => 'شُوركت النسخة الاحتياطية.';

  @override
  String get youDataExportedPartial =>
      'شُوركت النسخة الاحتياطية، لكن تعذّرت قراءة بعض الصور أو التسجيلات فلم تُضمَّن.';

  @override
  String get youDataImportTitle => 'استعادة نسخة احتياطية';

  @override
  String get youDataImportBody =>
      'تستبدل كل شيء بنسخة احتياطية، بعد تأكيدك أولًا.';

  @override
  String get youDataImportButton => 'اختيار ملف نسخة احتياطية';

  @override
  String get youDataImportConfirmTitle => 'استعادة هذه النسخة؟';

  @override
  String youDataImportConfirmBody(String date) {
    return 'استبدال كل ما على هذا الهاتف بالنسخة الاحتياطية (التاريخ: $date)؟';
  }

  @override
  String get youDataImportConfirmAction => 'استبدال';

  @override
  String get youDataImportUnknownDate => 'غير معروف';

  @override
  String youDataImportMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'عدد الملفات المفقودة (صور أو تسجيلات): $count. وتبقى مُدخلاتها محفوظة.',
      one: 'ملف واحد مذكور فيها مفقود (صورة أو تسجيل). ويبقى مُدخله محفوظًا.',
    );
    return '$_temp0';
  }

  @override
  String get youDataImportFilesFailed =>
      'تعذّر حفظ صورها وتسجيلاتها على هذا الهاتف.';

  @override
  String get youDataImported => 'استُعيدت النسخة الاحتياطية.';

  @override
  String get youDataImportedNotSaved =>
      'فُتحت النسخة الاحتياطية لكنها لم تُحفظ بعد. «إعادة المحاولة» في الأعلى، أو تصدير نسخة.';

  @override
  String get youDataImportFailedTitle => 'تعذّر استخدام هذا الملف';

  @override
  String get youDataImportUnchanged => 'لم تتغيّر بياناتك الحالية.';

  @override
  String get youDataImportNotJson => 'ليس ملف نسخة احتياطية قابلًا للقراءة.';

  @override
  String get youDataImportNotBackup => 'ليس نسخة احتياطية من Cartharise.';

  @override
  String get youDataImportUnsupported =>
      'صيغة هذه النسخة غير مدعومة في هذا الإصدار.';

  @override
  String get youDataImportDamaged => 'النسخة الاحتياطية ناقصة أو تالفة.';

  @override
  String get youDataImportTooLarge =>
      'الملف أكبر من أن يكون نسخة احتياطية من Cartharise.';

  @override
  String get youDataImportNotText => 'ليس ملفًا نصيًا.';

  @override
  String get youDataImportOpenFailed => 'تعذّر فتح الملف.';

  @override
  String get youDataDeleteTitle => 'حذف كل البيانات';

  @override
  String get youDataDeleteBody =>
      'يمحو كل شيء على هذا الهاتف ويلغي التذكيرات. التصدير أولًا يحفظ نسخة.';

  @override
  String get youDataDeleteButton => 'حذف كل البيانات';

  @override
  String get youDataDeleteConfirm1Title => 'حذف كل البيانات؟';

  @override
  String get youDataDeleteConfirm1Body =>
      'ستُمحى الإجابات والبوصلة والمهامّ والملاحظات والصور والتسجيلات والمراجعات والإعدادات.';

  @override
  String get youDataDeleteConfirm1Action => 'متابعة';

  @override
  String get youDataDeleteConfirm2Title => 'لا يمكن التراجع عن هذا';

  @override
  String get youDataDeleteConfirm2Body =>
      'لا توجد نسخة أخرى. وحدها نسخة احتياطية مُصدَّرة تستطيع إعادتها.';

  @override
  String get youDataDeleteConfirm2Action => 'حذف كل شيء';

  @override
  String get youDataDeleteFailed =>
      'تعذّر الحذف. كتاباتك ما زالت هنا؛ يمكن المحاولة مجددًا.';

  @override
  String get youDataDeleteCopiesLeft =>
      'حُذفت البيانات، لكن تعذّرت إزالة نسخة تصدير مؤقتة. إزالة التطبيق تمحوها.';

  @override
  String get youDataDeleteFilesLeft =>
      'حُذفت البيانات، لكن تعذّرت إزالة بعض الصور أو التسجيلات بعد. فتح التطبيق مجددًا يزيلها.';

  @override
  String get youSupportTitle => 'الدعم والأمان';

  @override
  String get youSupportSubtitle => 'قد يحرّك التأمّل مشاعر كثيرة. وهذا طبيعي.';

  @override
  String get youSupportNotTherapyTitle => 'ليس علاجًا';

  @override
  String get youSupportNotTherapyBody =>
      'أداة للتأمّل الذاتي. ليست علاجًا نفسيًا ولا إرشادًا ولا نصيحة طبية ولا تشخيصًا.';

  @override
  String get youSupportHeavyTitle => 'إن بدا سؤال ثقيلًا';

  @override
  String get youSupportHeavy1 => 'يمكن تخطّيه. كل سؤال اختياري.';

  @override
  String get youSupportHeavy2 => 'يمكن التحوّل إلى الصياغة الألطف حين تتوفّر.';

  @override
  String get youSupportHeavy3 =>
      'يمكن التوقف والعودة في يوم آخر. كلماتك محفوظة.';

  @override
  String get youSupportHeavy4 => 'الحديث مع شخص موضع ثقتك قد يساعد.';

  @override
  String get youSupportCrisisTitle => 'في حالة الأزمة';

  @override
  String get youSupportCrisisBody =>
      'في خطر، أو تراودك أفكار بإيذاء نفسك؟ يُرجى التواصل الآن مع خدمات الطوارئ، أو مع خط مساندة للأزمات في بلدك.';

  @override
  String get youSupportFindHelpline => 'العثور على خط مساندة';

  @override
  String get youSupportHelplineHint =>
      'يفتح findahelpline.com، خطوط المساندة حسب البلد.';

  @override
  String get youSupportOngoingTitle => 'دعم مستمر';

  @override
  String get youSupportOngoingBody =>
      'إن استمرت المشاعر الصعبة، فقد يساعد طبيب أو مرشد نفسي.';
}
