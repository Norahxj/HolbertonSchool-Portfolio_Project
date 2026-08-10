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
  String get weekly => 'أسبوعية';

  @override
  String get monthly => 'شهرية';

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

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get logoutFailed => 'تعذّر تسجيل الخروج. حاول مرة أخرى.';

  @override
  String get failedToLoadDashboard => 'تعذّر تحميل لوحة التحكم.';

  @override
  String get failedToRefreshDashboard => 'تعذّر تحديث لوحة التحكم.';

  @override
  String get failedToDeleteChild => 'تعذّر حذف الطفل. حاول مرة أخرى.';

  @override
  String get childNotFoundForFamily =>
      'لم يتم العثور على الطفل، أو أنه لم يعد مرتبطًا بهذه الأسرة.';

  @override
  String get parentAccountNotFound => 'تعذّر العثور على حساب ولي الأمر.';

  @override
  String get parentAccessRequired => 'هذا الإجراء متاح لحساب ولي الأمر فقط.';

  @override
  String get failedToDeleteChildRelatedData =>
      'تعذّر حذف الطفل والبيانات المرتبطة به.';

  @override
  String get yourChildren => 'أطفالك';

  @override
  String get addChild => 'إضافة طفل';

  @override
  String get reviewTasks => 'مراجعة المهام';

  @override
  String childAgeYears(int age) {
    return '$age سنوات';
  }

  @override
  String pointsCount(int count) {
    return '$count نقطة';
  }

  @override
  String get noChildrenAddedYet => 'لا يوجد أطفال بعد';

  @override
  String get welcome => 'مرحبًا';

  @override
  String get buildingWonderfulGeneration => 'أنتِ تبنين جيلاً رائعًا';

  @override
  String get failedToLoadChildTasks => 'تعذّر تحميل مهام الطفل.';

  @override
  String get failedToRefreshChildTasks => 'تعذّر تحديث مهام الطفل.';

  @override
  String get couldNotIdentifyChild => 'تعذّر تحديد الطفل.';

  @override
  String get onlyCreatorCanDeleteTask => 'يمكنك حذف المهام التي أنشأتها فقط.';

  @override
  String get failedToDeleteTask => 'تعذّر حذف المهمة.';

  @override
  String deleteChildConfirmationTitle(String childName) {
    return 'حذف $childName؟';
  }

  @override
  String get deleteChildConfirmationDescription =>
      'سيتم حذف حساب الطفل وجميع البيانات المرتبطة به نهائيًا. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get childDeletedSuccessfully => 'تم حذف الطفل بنجاح';

  @override
  String get childDetails => 'بيانات الطفل';

  @override
  String get weeklyProgress => 'تقدم الأسبوع';

  @override
  String get noorPointsHistory => 'سجل نقاط نور';

  @override
  String get viewPointsHistory => 'عرض سجل النقاط';

  @override
  String rateChildDayAndViewHistory(String childName) {
    return 'قيّمي يوم $childName وراجعي السجل';
  }

  @override
  String viewChildTasks(String childName) {
    return 'عرض مهام $childName';
  }

  @override
  String get editChildInformation => 'تعديل بيانات الطفل';

  @override
  String get deleting => 'جارٍ الحذف...';

  @override
  String get deleteChild => 'حذف الطفل';

  @override
  String get childAccessCode => 'رمز دخول الطفل';

  @override
  String get childAccessCodeCopied => 'تم نسخ رمز دخول الطفل';

  @override
  String get copyCode => 'نسخ الرمز';

  @override
  String get tasks => 'المهام';

  @override
  String get deleteTaskTitle => 'حذف المهمة؟';

  @override
  String deleteTaskConfirmation(String taskTitle) {
    return 'سيتم حذف مهمة \"$taskTitle\" نهائيًا، ولا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get taskDeletedSuccessfully => 'تم حذف المهمة بنجاح';

  @override
  String childTasksTitle(String childName) {
    return 'مهام $childName';
  }

  @override
  String get all => 'الكل';

  @override
  String get upcoming => 'قادمة';

  @override
  String get active => 'نشطة';

  @override
  String get awaitingReview => 'بانتظار المراجعة';

  @override
  String get completed => 'مكتملة';

  @override
  String get rejected => 'مرفوضة';

  @override
  String get noTasks => 'لا توجد مهام';

  @override
  String get noUpcomingTasks => 'لا توجد مهام قادمة';

  @override
  String get noActiveTasks => 'لا توجد مهام نشطة';

  @override
  String get noTasksAwaitingReview => 'لا توجد مهام بانتظار المراجعة';

  @override
  String get noCompletedTasks => 'لا توجد مهام مكتملة';

  @override
  String get noRejectedTasks => 'لا توجد مهام مرفوضة';

  @override
  String get childHasNoTasks => 'لا توجد مهام لهذا الطفل حتى الآن';

  @override
  String get failedToLoadTasks => 'تعذّر تحميل المهام';

  @override
  String nextTaskDate(String date) {
    return 'الموعد القادم: $date';
  }

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get failedToLoadFamilySettings => 'تعذّر تحميل إعدادات العائلة.';

  @override
  String get familyNameTooShort => 'اسم العائلة يجب أن يكون حرفين على الأقل.';

  @override
  String get invalidGuardianEmail => 'اكتبي بريدًا إلكترونيًا صحيحًا.';

  @override
  String get failedToUpdateFamilyName => 'تعذّر تحديث اسم العائلة.';

  @override
  String get failedToSendInvitation => 'تعذّر إرسال الدعوة.';

  @override
  String get failedToAcceptInvitation => 'تعذّر قبول الدعوة.';

  @override
  String get failedToRejectInvitation => 'تعذّر رفض الدعوة.';

  @override
  String get familySettingsGenericError => 'حدث خطأ غير متوقع.';

  @override
  String get familyName => 'اسم العائلة';

  @override
  String get saveFamilyName => 'حفظ الاسم';

  @override
  String get guardians => 'أولياء الأمور';

  @override
  String get noGuardians => 'لا يوجد أولياء أمور';

  @override
  String get father => 'أب';

  @override
  String get mother => 'أم';

  @override
  String get guardian => 'ولي أمر';

  @override
  String get you => 'أنت';

  @override
  String get incomingInvitations => 'الدعوات الواردة';

  @override
  String get noIncomingInvitations => 'لا توجد دعوات واردة حاليًا';

  @override
  String get incomingInvitationsDescription =>
      'ستظهر هنا دعوات الانضمام إلى العائلات';

  @override
  String get family => 'العائلة';

  @override
  String invitationToJoinFamily(String familyName) {
    return 'دعوة للانضمام إلى $familyName';
  }

  @override
  String invitationSentBy(String name) {
    return 'مرسلة من $name';
  }

  @override
  String get accept => 'قبول';

  @override
  String get inviteAnotherGuardian => 'دعوة ولي أمر آخر';

  @override
  String get guardianEmailAddress => 'البريد الإلكتروني لولي الأمر';

  @override
  String get sending => 'جارٍ الإرسال...';

  @override
  String get sendInvitation => 'إرسال دعوة';

  @override
  String get guardianInvitationExplanation =>
      'يجب أن يكون لدى ولي الأمر حساب مسجل مسبقًا، وستظهر الدعوة داخل حسابه.';

  @override
  String get pendingSentInvitations => 'الدعوات المرسلة المعلّقة';

  @override
  String get noPendingSentInvitations => 'لا توجد دعوات مرسلة معلّقة حاليًا';

  @override
  String get pendingInvitationsDescription =>
      'ستظهر هنا الدعوات التي أرسلتها ولم تُقبل بعد';

  @override
  String get waitingForInvitationAcceptance => 'بانتظار قبول الدعوة';

  @override
  String get invitationAcceptedSuccessfully =>
      'تم قبول الدعوة والانضمام إلى العائلة';

  @override
  String get invitationRejectedSuccessfully => 'تم رفض الدعوة';

  @override
  String get familyNameUpdatedSuccessfully => 'تم تحديث اسم العائلة';

  @override
  String get invitationSentSuccessfully => 'تم إرسال الدعوة بنجاح';

  @override
  String familyNameDisplay(String name) {
    return 'عائلة $name';
  }

  @override
  String get unableToLoadReviewTasks => 'تعذّر تحميل المهام للمراجعة.';

  @override
  String get unableToApproveTask => 'تعذّر قبول المهمة.';

  @override
  String get onlyTaskCreatorCanApprove =>
      'يمكن قبول المهمة فقط بواسطة ولي الأمر الذي أضافها.';

  @override
  String get unableToSendTaskForRetry => 'تعذّر إرسال المهمة لإعادة المحاولة.';

  @override
  String get onlyTaskCreatorCanRequestRetry =>
      'يمكن إرسال المهمة لإعادة المحاولة فقط بواسطة ولي الأمر الذي أضافها.';

  @override
  String get completedRecently => 'أُنجزت مؤخرًا';

  @override
  String completedAt(String time) {
    return 'أُنجزت في $time';
  }

  @override
  String get taskReview => 'مراجعة المهام';

  @override
  String get reviewCompletedTasks => 'راجع ما أنجزه أطفالك';

  @override
  String get pendingReview => 'بانتظار المراجعة';

  @override
  String tasksCount(int count) {
    return '$count مهام';
  }

  @override
  String get acceptTask => 'قبول';

  @override
  String get tryAgain => 'إعادة المحاولة';

  @override
  String get noTasksPendingReview => 'لا توجد مهام بانتظار المراجعة';

  @override
  String taskAcceptedSuccessfully(String taskTitle) {
    return 'تم قبول مهمة \"$taskTitle\"';
  }

  @override
  String taskSentForRetrySuccessfully(String taskTitle) {
    return 'تم إرسال المهمة لإعادة المحاولة: \"$taskTitle\"';
  }

  @override
  String get taskReviewGenericError => 'حدث خطأ غير متوقع أثناء مراجعة المهمة.';

  @override
  String get addChildSubtitle => 'أضف معلومات طفلك لبدء رحلته';

  @override
  String get editChildSubtitle => 'عدّل معلومات الطفل ثم اضغط حفظ';

  @override
  String get chooseAvatar => 'اختر صورة رمزية';

  @override
  String get childName => 'اسم الطفل';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get selectDateOfBirth => 'اختر تاريخ الميلاد';

  @override
  String get select => 'اختيار';

  @override
  String get openCalendarToSelectDate => 'يفتح التقويم لاختيار التاريخ';

  @override
  String get phoneNumberOptional => 'رقم الجوال (اختياري)';

  @override
  String get saveChanges => 'حفظ التعديلات';

  @override
  String get childAddedSuccessfully => 'تمت إضافة الطفل بنجاح';

  @override
  String get childUpdatedSuccessfully => 'تم تعديل بيانات الطفل بنجاح';

  @override
  String get childNameRequired => 'اسم الطفل مطلوب';

  @override
  String get childNameTooShort => 'يجب أن يتكون اسم الطفل من حرفين على الأقل';

  @override
  String get childNameTooLong => 'يجب ألا يتجاوز اسم الطفل 100 حرف';

  @override
  String get childNameLettersOnly =>
      'يجب أن يحتوي الاسم على حروف عربية أو إنجليزية فقط';

  @override
  String get birthDateRequired => 'تاريخ الميلاد مطلوب';

  @override
  String get invalidChildAge => 'يجب أن يكون عمر الطفل بين 6 و18 سنة';

  @override
  String get invalidSaudiPhone => 'أدخل رقم جوال سعودي صحيح يبدأ بـ 05';

  @override
  String get failedToAddChild => 'تعذّر إضافة الطفل. حاول مرة أخرى.';

  @override
  String get failedToUpdateChild => 'تعذّر تعديل بيانات الطفل. حاول مرة أخرى.';

  @override
  String get phoneAlreadyUsed => 'رقم الجوال مستخدم بالفعل.';

  @override
  String get parentNotLinkedToFamily => 'حساب ولي الأمر غير مرتبط بأسرة.';

  @override
  String get onlyParentsCanAddChildren => 'إضافة الأطفال متاحة لولي الأمر فقط.';

  @override
  String get onlyParentsCanUpdateChildren =>
      'تعديل بيانات الطفل متاح لولي الأمر فقط.';

  @override
  String get childNotFound => 'لم يتم العثور على الطفل.';

  @override
  String get couldNotCreateChild => 'تعذّر إنشاء حساب الطفل.';

  @override
  String get couldNotSaveChildChanges => 'تعذّر حفظ التعديلات.';

  @override
  String get couldNotIdentifyChildToUpdate =>
      'تعذّر تحديد الطفل المطلوب تعديله.';

  @override
  String get unexpectedAddChildError => 'حدث خطأ غير متوقع أثناء إضافة الطفل.';

  @override
  String get unexpectedUpdateChildError =>
      'حدث خطأ غير متوقع أثناء تعديل الطفل.';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get phoneNumber => 'رقم الجوال';

  @override
  String get familyRelationship => 'صلتي بالأسرة';

  @override
  String get profileUpdatedSuccessfully => 'تم حفظ التغييرات بنجاح ✓';

  @override
  String get failedToLoadProfile => 'تعذّر تحميل بيانات الملف الشخصي.';

  @override
  String get failedToSaveProfile => 'تعذّر حفظ التغييرات.';

  @override
  String get unexpectedProfileSaveError => 'حدث خطأ أثناء حفظ التغييرات.';

  @override
  String get firstNameTooShort =>
      'يجب أن يتكون الاسم الأول من حرفين على الأقل.';

  @override
  String get lastNameTooShort => 'يجب أن يتكون اسم العائلة من حرفين على الأقل.';

  @override
  String get invalidEmailAddress => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get phoneNumberRequired => 'يرجى إدخال رقم الجوال.';

  @override
  String get emailAlreadyUsed => 'البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get failedToLoadUserInformation => 'تعذّر تحميل بيانات المستخدم.';

  @override
  String get invitedUserNotFound =>
      'لا يوجد حساب ولي أمر بهذا البريد الإلكتروني.';

  @override
  String get cannotInviteYourself => 'لا يمكنك دعوة حسابك نفسه.';

  @override
  String get userAlreadyInFamily => 'ولي الأمر موجود بالفعل في العائلة.';

  @override
  String get guardianTypeAlreadyExists =>
      'يوجد بالفعل ولي أمر من النوع نفسه في العائلة.';

  @override
  String get invitationAlreadyPending => 'توجد دعوة معلّقة لهذا البريد بالفعل.';

  @override
  String get familyInformationNotFound => 'تعذّر العثور على بيانات العائلة.';

  @override
  String get invalidEnteredData => 'تأكدي من صحة البيانات المدخلة.';

  @override
  String get parentNavigationTasks => 'المهام';

  @override
  String get parentNavigationWishes => 'الأمنيات';

  @override
  String get parentNavigationHome => 'الرئيسية';

  @override
  String get parentNavigationRewards => 'المكافآت';

  @override
  String get parentNavigationMore => 'المزيد';

  @override
  String get childNavigationHome => 'الرئيسية';

  @override
  String get childNavigationWishes => 'أمنياتي';

  @override
  String get childNavigationRewards => 'المكافآت';

  @override
  String get childNavigationProgress => 'تقدّمي';

  @override
  String get switchLanguage => 'العربية';

  @override
  String get childTaskAutoApprovedSuccess =>
      'أحسنت! اكتملت المهمة وأُضيفت نقاطك.';

  @override
  String get childTaskSentForReviewSuccess =>
      'أحسنت! أُرسلت المهمة إلى ولي أمرك للمراجعة.';

  @override
  String get childTaskCompleteFailed => 'تعذّر إكمال المهمة. حاول مرة أخرى.';

  @override
  String get childTaskUnexpectedError => 'حدث خطأ أثناء إكمال المهمة.';

  @override
  String get childTaskCompletedApproved => 'مكتملة ومعتمدة';

  @override
  String get childTaskWaitingGuardianReview => 'بانتظار مراجعة ولي الأمر';

  @override
  String get childTaskReadyToComplete => 'جاهزة للإنجاز';

  @override
  String get childTaskApproved => 'تم اعتماد المهمة';

  @override
  String get childTaskCompleteButton => 'أنجزت المهمة';

  @override
  String get childTaskAutoVerificationMessage =>
      'ستُعتمد هذه المهمة تلقائيًا عند إتمامها، وتُضاف النقاط مباشرة إلى رصيدك.';

  @override
  String get childTaskGuardianVerificationMessage =>
      'عند إتمامك المهمة سيراجعها ولي أمرك، وبعد الاعتماد تُضاف النقاط إلى رصيدك.';

  @override
  String get childTaskNoDescription => 'لا يوجد وصف لهذه المهمة.';

  @override
  String noorPointsCount(int points) {
    return '$points نقاط نور';
  }

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get once => 'مرة واحدة';

  @override
  String get childNoTasksToday => 'لا توجد مهام اليوم';

  @override
  String get childNoTasksMessage =>
      'استمتع بوقتك، وعد لاحقًا لرؤية مهام جديدة.';

  @override
  String get childEncouragementMessage =>
      'كل مهمة تنجزها تقرّبك من هدف جديد ومكافأة أجمل!';

  @override
  String get childTodayEncouragement => 'تشجيع اليوم';

  @override
  String get childFromFamily => 'من العائلة';

  @override
  String get childTodayGoal => 'هدف اليوم';

  @override
  String get childNoTasksGoalMessage => 'لا توجد مهام اليوم، استمتع بيومك!';

  @override
  String get childAllTasksCompletedMessage => 'رائع! أنجزت جميع مهام اليوم 🎉';

  @override
  String get childOneTaskRemainingMessage =>
      'بقيت لك مهمة واحدة لإكمال هدف اليوم!';

  @override
  String childTasksRemainingMessage(int count) {
    return 'بقيت لك $count مهام لإكمال هدف اليوم';
  }

  @override
  String get todayTasks => 'مهام اليوم';

  @override
  String get approved => 'تم الاعتماد';

  @override
  String get ready => 'جاهزة للإنجاز';

  @override
  String get childGreetingGirl => 'أهلًا يا بطلة! 👋';

  @override
  String get childGreetingBoy => 'أهلًا يا بطل! 👋';

  @override
  String get childHomeSubtitle => 'يوم جديد وإنجازات جديدة بانتظارك';

  @override
  String get settings => 'الإعدادات';

  @override
  String get childHomeChildNotFound => 'لم نتمكن من العثور على بيانات الطفل.';

  @override
  String get childHomeLoadFailed => 'تعذّر تحميل الصفحة.';

  @override
  String get childAccount => 'حساب الطفل';

  @override
  String get childSwitchLanguage => 'التبديل إلى الإنجليزية';

  @override
  String get childLogoutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get childRewardsLoadFailed => 'تعذّر تحميل المكافآت';

  @override
  String get childRewardsSubtitle => 'مكافأة أسبوعية ترتبط بتقدّمك';

  @override
  String get childRewardsEmpty =>
      'لا توجد مكافآت بعد.\nتحدّث مع والديك لإضافة مكافأة!';

  @override
  String get childRewardClaimedSuccess => 'تم استلام المكافأة! 🎉';

  @override
  String get childRewardClaimFailed => 'تعذّر استلام المكافأة';

  @override
  String get childRewardClaim => 'استلام';

  @override
  String get childRewardClaimedBadge => '🎉 تم';

  @override
  String get childRewardAvailableNow => 'متاحة الآن! اضغط للاستلام ✓';

  @override
  String get childRewardClaimedStatus => 'تم الاستلام 🎉';

  @override
  String childRewardUnlocksOn(String day) {
    return 'تُفتح يوم $day';
  }

  @override
  String get wishlistApprovedStatus => 'مقبولة ✓';

  @override
  String get wishlistRejectedStatus => 'مرفوضة ✗';

  @override
  String get wishlistAchievedStatus => 'تحققت! 🌟';

  @override
  String get wishlistPendingStatus => 'في الانتظار...';

  @override
  String wishlistTargetPoints(int points) {
    return 'الهدف: $points نقطة';
  }

  @override
  String wishlistCurrentPoints(int points) {
    return 'لديك: $points نقطة';
  }

  @override
  String get wishlistTargetNotSpecified => 'لم يتم تحديد النقاط المطلوبة';

  @override
  String get wishlistAchieveButton => 'لقد حققت أمنيتي! 🌟';

  @override
  String get wishlistCollectMorePoints => 'اجمع المزيد من النقاط';

  @override
  String get childWishlistLoadFailed => 'تعذّر تحميل الأمنيات.';

  @override
  String get childWishlistTitle => 'أمنياتي';

  @override
  String get childWishlistSubtitle => 'اختر أمنية واجمع نقاط نور لتحقيقها';

  @override
  String childWishlistPoints(int points) {
    return 'رصيدك الحالي: $points نقطة';
  }

  @override
  String get childAddWish => 'إضافة أمنية';

  @override
  String get childWishlistEmpty => 'لا توجد أمنيات بعد';

  @override
  String get childWishlistEmptySubtitle =>
      'أضف أمنيتك الأولى وابدأ بجمع النقاط لتحقيقها';

  @override
  String get deleteWishTitle => 'حذف الأمنية';

  @override
  String deleteWishConfirmation(String wishName) {
    return 'هل تريد حذف أمنية \"$wishName\"؟';
  }

  @override
  String get deleteWishFailed => 'تعذّر حذف الأمنية.';

  @override
  String get deleteWishSuccess => 'تم حذف الأمنية.';

  @override
  String get achieveWishFailed => 'تعذّر تحقيق الأمنية.';

  @override
  String get achieveWishSuccess => 'تم تحقيق الأمنية! 🌟';

  @override
  String get createWishFailed => 'تعذّر إضافة الأمنية.';

  @override
  String get wishlistLimitReached => 'وصلت للحد الأقصى من الأمنيات المعلقة.';

  @override
  String get wishNameTooShort => 'اسم الأمنية قصير جدًا.';

  @override
  String get wishNameTooLong => 'اسم الأمنية طويل جدًا.';

  @override
  String get addWishTitle => 'إضافة أمنية';

  @override
  String get chooseWishesCarefully => 'اختر أمنياتك بعناية';

  @override
  String pendingWishesCount(int count, int maximum) {
    return 'لديك $count من أصل $maximum أمنيات بانتظار المراجعة';
  }

  @override
  String get wishNameLabel => 'اسم الأمنية';

  @override
  String get wishNameHint => 'مثال: دراجة هوائية';

  @override
  String get wishlistLimitExplanation =>
      'يمكنك إضافة حتى 5 أمنيات بانتظار مراجعة ولي أمرك. بعد قبول الأمنية سيحدد ولي أمرك عدد النقاط المطلوبة لتحقيقها.';

  @override
  String get maximumWishLimitReached => 'وصلتِ إلى الحد الأقصى';

  @override
  String get saveWish => 'حفظ الأمنية';
}
