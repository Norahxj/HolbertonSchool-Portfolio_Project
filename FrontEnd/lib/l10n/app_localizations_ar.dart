// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'أصالة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get saving => 'جارٍ الحفظ...';

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get taskDetails => 'تفاصيل المهمة';

  @override
  String get saveTask => 'حفظ المهمة';

  @override
  String get taskName => 'اسم المهمة';

  @override
  String get taskDescription => 'الوصف';

  @override
  String get taskFrequency => 'تكرار المهمة';

  @override
  String get taskType => 'نوع المهمة';

  @override
  String get noorPoints => 'نقاط نور';

  @override
  String get daily => 'يوميًا';

  @override
  String get weekly => 'مرة في الأسبوع';

  @override
  String get monthly => 'شهريًا';

  @override
  String get chooseChildSubtitle => 'لمن هذه المهمة؟ (يمكن اختيار أكثر من طفل)';

  @override
  String get taskDetailsSubtitle => 'أضيفي تفاصيل المهمة وحددي تكرارها';

  @override
  String get selectChildFirst => 'اختر طفلًا أولًا لتفعيل أنواع المهام';

  @override
  String get chooseTaskType => 'اختر نوع المهمة';

  @override
  String get noChildrenYet => 'لا يوجد أطفال بعد. الرجاء إضافة طفل أولًا.';

  @override
  String get culturalTasks => 'المهام الثقافية';

  @override
  String get dailyTasks => 'المهام اليومية';

  @override
  String get religiousTasks => 'المهام الدينية';

  @override
  String get financialTasks => 'المهام المالية';

  @override
  String get quickAdd => 'إضافة سريعة';

  @override
  String get unableToLoadSuggestions => 'تعذّر تحميل المهام المقترحة';

  @override
  String get noSuggestions => 'لا توجد مهام مقترحة حاليًا';

  @override
  String get taskNameExample => 'مثال: ترتيب سريرك';

  @override
  String get taskDescriptionHint => 'صف المهمة باختصار...';

  @override
  String get chooseWeekDay => 'اختر يوم الأسبوع';

  @override
  String get chooseMonthDay => 'اختر يوم الشهر';

  @override
  String get chooseRepeatDate => 'اختر تاريخ التكرار';

  @override
  String get sunday => 'الأحد';

  @override
  String get monday => 'الإثنين';

  @override
  String get tuesday => 'الثلاثاء';

  @override
  String get wednesday => 'الأربعاء';

  @override
  String get thursday => 'الخميس';

  @override
  String get friday => 'الجمعة';

  @override
  String get saturday => 'السبت';

  @override
  String pointsValue(int points) {
    return '$points نقطة';
  }

  @override
  String get taskNameRequired => 'اسم المهمة مطلوب';

  @override
  String get descriptionRequired => 'الوصف مطلوب';

  @override
  String get selectAtLeastOneChild => 'الرجاء اختيار طفل واحد على الأقل';

  @override
  String get selectTaskTypeError => 'الرجاء اختيار نوع المهمة';

  @override
  String get pointsRangeError => 'عدد النقاط يجب أن يكون بين 1 و100';

  @override
  String get taskNameLengthError => 'اسم المهمة يجب أن يكون بين حرفين و100 حرف';

  @override
  String get descriptionLengthError => 'الوصف يجب أن يكون بين حرفين و500 حرف';

  @override
  String get saveTaskGenericError => 'حدث خطأ أثناء حفظ المهمة';

  @override
  String get tasksInformation =>
      'المهام تساعد الأطفال على بناء العادات والقيم وكسب نقاط نور.';

  @override
  String get pointsInformation =>
      'نقاط نور تحفّز الأطفال وتشجعهم على الاستمرار.';

  @override
  String get trustChildQuestion => 'هل تثق بجدية طفلك في هذه المهمة؟';

  @override
  String get trustChildDescription =>
      'إذا وثقت، ستُعتمد المهمة تلقائيًا بدون الحاجة لمراجعتك';

  @override
  String get dailyFrequencyDescription => 'تُنفَّذ المهمة كل يوم';

  @override
  String get weeklyFrequencyDescription => 'تُنفَّذ المهمة مرة في الأسبوع';

  @override
  String get monthlyFrequencyDescription => 'تُنفَّذ المهمة مرة في الشهر';

  @override
  String get failedToLoadChildren => 'تعذّر تحميل الأطفال';

  @override
  String get failedToLoadChildRewards => 'تعذّر تحميل مكافآت الطفل';

  @override
  String get failedToLoadRewardSuggestions => 'تعذّر تحميل المكافآت المقترحة';

  @override
  String get deleteRewardNotAllowed =>
      'لا يمكنك حذف هذه المكافأة؛ يمكن حذفها فقط بواسطة ولي الأمر الذي أضافها.';

  @override
  String get deleteClaimedRewardNotAllowed =>
      'لا يمكن حذف المكافأة بعد استلامها.';

  @override
  String get failedToDeleteReward => 'تعذّر حذف المكافأة. حاول مرة أخرى.';

  @override
  String get rewardAddedSuccessfully => 'تمت إضافة المكافأة بنجاح 🎉';

  @override
  String get deleteRewardTitle => 'حذف المكافأة';

  @override
  String deleteRewardConfirmation(String rewardName) {
    return 'هل تريد حذف مكافأة \"$rewardName\"؟';
  }

  @override
  String get delete => 'حذف';

  @override
  String get rewardDeleted => 'تم حذف المكافأة';

  @override
  String get rewardManagement => 'إدارة المكافآت';

  @override
  String get rewardManagementSubtitle => 'مكافآت أسبوعية تُمنح حسب أداء الطفل';

  @override
  String get noChildrenAddFirst => 'لا يوجد أطفال بعد. أضف طفلًا أولًا.';

  @override
  String get currentChildRewards => 'مكافآت الطفل الحالية';

  @override
  String get noRewardsForChild => 'لا توجد مكافآت لهذا الطفل حتى الآن';

  @override
  String get selectChildForSuggestions =>
      'اختر طفلًا أولًا لعرض المكافآت المقترحة';

  @override
  String get rewardStatusUnlocked => 'متاحة';

  @override
  String get rewardStatusClaimed => 'تم استلامها';

  @override
  String get rewardStatusLocked => 'مقفلة';

  @override
  String rewardUnlockDay(String day) {
    return 'يوم إتاحة المكافأة';
  }

  @override
  String get noSuggestedRewards => 'لا توجد مكافآت مقترحة حاليًا';

  @override
  String get addReward => 'إضافة مكافأة';

  @override
  String get rewardNameRequired => 'اكتب اسم المكافأة أولًا';

  @override
  String get couldNotSaveReward => 'تعذّر حفظ المكافأة';

  @override
  String get saveRewardGenericError => 'حدث خطأ أثناء حفظ المكافأة';

  @override
  String get newReward => 'مكافأة جديدة';

  @override
  String get rewardName => 'اسم المكافأة';

  @override
  String get rewardNameExample => 'مثال: رحلة إلى الحديقة';

  @override
  String get rewardDescription => 'وصف المكافأة';

  @override
  String get rewardDescriptionExample =>
      'مثال: زيارة الحديقة مع العائلة في نهاية الأسبوع';

  @override
  String rewardAvailableEveryWeek(String day) {
    return 'ستصبح المكافأة متاحة للطفل يوم $day من كل أسبوع.';
  }

  @override
  String get saveReward => 'حفظ المكافأة';

  @override
  String get rewardUnlockDayLabel => 'يوم إتاحة المكافأة';

  @override
  String get failedToLoadFeedbackHistory => 'تعذّر تحميل سجل التقييم';

  @override
  String get failedToSaveFeedback => 'تعذّر حفظ التقييم. حاول مرة أخرى.';

  @override
  String get feedbackSavedSuccessfully => 'تم حفظ التقييم بنجاح ✓';

  @override
  String get dailyFeedback => 'التقييم اليومي';

  @override
  String get feedbackHistory => 'سجل التقييمات';

  @override
  String get todayFeedbackEditable => 'تقييم اليوم (يمكنك التعديل)';

  @override
  String howWasChildDay(String childName) {
    return 'كيف كان يوم $childName؟';
  }

  @override
  String get updateFeedback => 'تحديث التقييم';

  @override
  String get saveFeedback => 'حفظ التقييم';

  @override
  String get moodHappy => 'سعيد';

  @override
  String get moodProud => 'فخور';

  @override
  String get moodGreat => 'رائع';

  @override
  String get moodLoved => 'محبوب';

  @override
  String get moodStrong => 'قوي';

  @override
  String get moodStar => 'نجم';

  @override
  String childPointsHistory(String childName) {
    return 'سجل نقاط $childName';
  }

  @override
  String taskCompletedPointsHistory(String taskTitle) {
    return 'إكمال مهمة: $taskTitle';
  }

  @override
  String wishAchievedPointsHistory(String wishName) {
    return 'تحقيق أمنية: $wishName';
  }

  @override
  String get pointsUpdate => 'تحديث في النقاط';

  @override
  String get noPointsHistoryYet => 'لا يوجد سجل نقاط حتى الآن';

  @override
  String get pointsHistoryDescription => 'ستظهر هنا النقاط المكتسبة والمخصومة.';

  @override
  String get failedToLoadPointsHistory => 'تعذّر تحميل سجل النقاط.';

  @override
  String get childrenWishes => 'أمنيات الأطفال';

  @override
  String get childrenWishesSubtitle =>
      'راجع أمنية طفلك وحدد عدد نقاط نور التي يحتاج لجمعها حتى يتمكن من تحقيقها';

  @override
  String get failedToRefreshWishes => 'تعذّر تحديث الأمنيات';

  @override
  String get failedToApproveWish => 'تعذّرت الموافقة على الأمنية';

  @override
  String get failedToRejectWish => 'تعذّر رفض الأمنية';

  @override
  String get wishApprovalExplanation =>
      'بعد اعتماد الأمنية، يبدأ الطفل بجمع نقاط نور حتى يصل إلى الهدف المحدد.';

  @override
  String get pendingApproval => 'بانتظار الموافقة';

  @override
  String get pendingWishSubtitle =>
      'طلب هذه الأمنية وينتظر منك تحديد هدف النقاط';

  @override
  String get pointsGoal => 'هدف النقاط';

  @override
  String get convertWishExplanation =>
      'بعد تحويل الأمنية إلى هدف، يبدأ الطفل بجمع هذا العدد من نقاط نور لتحقيقها.';

  @override
  String get pointsMustBePositive => 'يجب أن تكون النقاط أكبر من صفر';

  @override
  String get convertToGoal => 'تحويل إلى هدف';

  @override
  String get reject => 'رفض';

  @override
  String get goalCreated => 'هدف معتمد';

  @override
  String get wishApprovedSubtitle => 'تمت الموافقة على هذه الأمنية';

  @override
  String get selectedPointsGoal => 'هدف النقاط المحدد';

  @override
  String get wishAchieved => 'تم تحقيقها';

  @override
  String get wishAchievedSuccessfully => 'تم تحقيق هذه الأمنية بنجاح 🎉';

  @override
  String get completedNoorPointsGoal => 'أكمل الطفل هدف نقاط نور';

  @override
  String get failedToLoadWishes =>
      'حدث خطأ أثناء تحميل الأمنيات. حاول مرة أخرى.';

  @override
  String get noWishesYet => 'لا توجد أمنيات بعد.';

  @override
  String get more => 'المزيد';

  @override
  String get comingSoonMessage => 'هذه الميزة ستكون متاحة قريبًا.';

  @override
  String get personalProfile => 'الملف الشخصي';

  @override
  String get familySettings => 'إعدادات العائلة';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get soon => 'قريبًا';
}
