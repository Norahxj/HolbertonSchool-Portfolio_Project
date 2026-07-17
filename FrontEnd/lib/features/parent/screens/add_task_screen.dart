import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';
import 'package:frontend/models/child_model.dart';
import 'package:frontend/services/task_api_service.dart';
import 'package:frontend/services/child_api_service.dart';
import 'parent_main_screen.dart';
import 'package:frontend/models/task_suggestion_model.dart';
// Add Task wizard (Screens 9-12).
//
// This first pass is static/placeholder only: every step just updates
// simple local state, and there are no backend calls yet. The 4 mockup
// screens are combined into one file, switching on currentStep.
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskApiService _taskApiService = TaskApiService();
  final ChildApiService _childApiService = ChildApiService();

  List<ChildModel> children = [];
  List<String> selectedChildIds = [];
  bool isLoadingChildren = true;
  bool isSubmitting = false;
  bool isSaving = false;
  List<TaskSuggestionModel> taskSuggestions = [];
bool isLoadingSuggestions = false;
String? suggestionsError;

  int currentStep = 0;

  String? titleError;
  String? descriptionError;
  String? pointsError;
  String? categoryError;
  String? frequencyError;
  String? recurrenceDayError;
  String? childError;
  String? mapBackendError(String? message) {
    switch (message) {
      case "Shorter than minimum length 1.":
        return "الرجاء اختيار طفل واحد على الأقل";

      case "Must be greater than or equal to 1 and less than or equal to 100.":
        return "عدد النقاط يجب أن يكون بين 1 و100";

      case "Length must be between 2 and 100.":
        return "اسم المهمة يجب أن يكون بين حرفين و100 حرف";

      case "Length must be between 2 and 500.":
        return "الوصف يجب أن يكون بين حرفين و500 حرف";

      default:
        return message;
    }
  }
  String? getError(dynamic error) {
  if (error == null) return null;

  if (error is List && error.isNotEmpty) {
    return error.first.toString();
  }

  return error.toString();
}

  // Step 1: which task type/category is picked. Null means none yet.
  int? selectedTaskType;

  // Step 2: task name, description, points, and the trust toggle.
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  int taskPoints = 10;
  bool trustChild = true;

  int selectedFrequency = 1;

  // Which day of the week is picked when "مرة في الأسبوع" is selected.
  String selectedWeeklyDay = 'الأحد';

  // Which day of the month is picked when "شهريًا" is selected.
  int selectedMonthlyDay = 1;

  // The choices shown for the weekly day and monthly date pickers.
  final List<String> weekDays = const [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];
  final List<int> monthlyDays =List<int>.generate(31, (index) => index + 1);
  String get taskFrequency {
    switch (selectedFrequency) {
      case 0:
        return "DAILY";
      case 1:
        return "WEEKLY";
      case 2:
        return "MONTHLY";
      default:
        return "ONCE";
    }
  }

  int? get recurrenceDay {
    if (selectedFrequency == 1) {
  switch (selectedWeeklyDay) {
    case 'الإثنين':
      return 0;
    case 'الثلاثاء':
      return 1;
    case 'الأربعاء':
      return 2;
    case 'الخميس':
      return 3;
    case 'الجمعة':
      return 4;
    case 'السبت':
      return 5;
    case 'الأحد':
      return 6;
  }
}

    if (selectedFrequency == 2) {
      return selectedMonthlyDay;
    }

    return null;
  }

  String get category {
    switch (selectedTaskType) {
      case 0:
        return "SOCIAL";
      case 1:
        return "MORAL";
      case 2:
        return "RELIGIOUS";
      case 3:
        return "FINANCIAL";
      default:
        return "MORAL";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final data = await _childApiService.getChildren();

      setState(() {
        children = data;
        isLoadingChildren = false;
      });
    } on DioException {
      setState(() {
        isLoadingChildren = false;
      });
    }
  }
Future<void> _loadTaskSuggestions() async {
  if (selectedChildIds.isEmpty || selectedTaskType == null) {
    return;
  }

  setState(() {
    isLoadingSuggestions = true;
    suggestionsError = null;
    taskSuggestions = [];
  });

  try {
    final suggestions = await _taskApiService.getTaskSuggestions({
      'child_ids': selectedChildIds,
      'category': category,
      'lang': 'ar',
    });

    if (!mounted) return;

    setState(() {
      taskSuggestions = suggestions;
    });
  } on DioException catch (e) {
    if (!mounted) return;

    setState(() {
      suggestionsError =
          e.response?.data?['error']?.toString() ??
          'تعذر تحميل المهام المقترحة';
    });
  } finally {
    if (mounted) {
      setState(() {
        isLoadingSuggestions = false;
      });
    }
  }
}

void _applyTaskSuggestion(TaskSuggestionModel suggestion) {
  taskNameController.text = suggestion.title;
  taskDescriptionController.text = suggestion.description;
  taskPoints = suggestion.points;
  trustChild = suggestion.isAutoVerified;

  switch (suggestion.taskFrequency) {
    case 'DAILY':
      selectedFrequency = 0;
      break;

    case 'WEEKLY':
      selectedFrequency = 1;

      switch (suggestion.recurrenceDay) {
        case 0:
          selectedWeeklyDay = 'الإثنين';
          break;
        case 1:
          selectedWeeklyDay = 'الثلاثاء';
          break;
        case 2:
          selectedWeeklyDay = 'الأربعاء';
          break;
        case 3:
          selectedWeeklyDay = 'الخميس';
          break;
        case 4:
          selectedWeeklyDay = 'الجمعة';
          break;
        case 5:
          selectedWeeklyDay = 'السبت';
          break;
        case 6:
          selectedWeeklyDay = 'الأحد';
          break;
      }
      break;

    case 'MONTHLY':
      selectedFrequency = 2;

      final day = suggestion.recurrenceDay;
      if (day != null && day >= 1 && day <= 31) {
        selectedMonthlyDay = day;
      }
      break;
  }
}
Future<void> _showMonthlyDayPicker() async {
  final selectedDay = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر يوم الشهر',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 31,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final isSelected = day == selectedMonthlyDay;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context, day);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  if (selectedDay != null) {
    setState(() {
      selectedMonthlyDay = selectedDay;
    });
  }
}
  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
  setState(() {
    childError = null;
    categoryError = null;
    titleError = null;
    descriptionError = null;
    pointsError = null;
    frequencyError = null;
    recurrenceDayError = null;
  });

  // الصفحة الأولى
  
    
   // الصفحة الأولى: اختيار الطفل ونوع المهمة
if (currentStep == 0) {
  bool hasError = false;

  if (selectedChildIds.isEmpty) {
    childError = "الرجاء اختيار طفل واحد على الأقل";
    hasError = true;
  }

  if (selectedTaskType == null) {
    categoryError = "الرجاء اختيار نوع المهمة";
    hasError = true;
  }

  if (hasError) {
    setState(() {});
    return;
  }
}

// الصفحة الثانية: تفاصيل المهمة
if (currentStep == 1) {
  bool hasError = false;

  if (taskNameController.text.trim().isEmpty) {
    titleError = "اسم المهمة مطلوب";
    hasError = true;
  }

  if (taskDescriptionController.text.trim().isEmpty) {
    descriptionError = "الوصف مطلوب";
    hasError = true;
  }

  if (taskPoints < 1 || taskPoints > 100) {
    pointsError = "عدد النقاط يجب أن يكون بين 1 و100";
    hasError = true;
  }

  if (hasError) {
    setState(() {});
    return;
  }
}

  setState(() {
    currentStep++;
  });
}

  void _goToPreviousStep() {
    if (currentStep == 0) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      currentStep --;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          _stepTitle,
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),
                    
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  _stepSubtitle,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                if (currentStep == 0) _buildChooseChildStep(),
                if (currentStep == 1) _buildTaskDetailsStep(),

                const SizedBox(height: AppSpacing.xl),

                _buildBottomButtons(),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // The title text shown at the top for the current step.
  String get _stepTitle {
  if (currentStep == 0) return 'إضافة مهمة';
  return 'تفاصيل المهمة';
}

  // The subtitle text shown below the title for the current step.
  String get _stepSubtitle {
  if (currentStep == 0) {
    return 'لمن هذه المهمة؟ (يمكن اختيار أكثر من طفل)';
  }

  return 'أضيفي تفاصيل المهمة وحددي تكرارها';
}

  // ---- Step 0: choose child ----

  Widget _buildChooseChildStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isLoadingChildren)
          const Center(child: CircularProgressIndicator())
        else if (children.isEmpty)
          const Center(
            child: Text(
              'لا يوجد أطفال بعد. الرجاء إضافة طفل أولاً.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: children.map((child) {
              final isSelected = selectedChildIds.contains(child.id);

              return _ChildChip(
                name: child.name,
                avatarColor: AppColors.primaryLight,
                iconColor: AppColors.primary,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedChildIds.remove(child.id);
                    } else {
                      selectedChildIds.add(child.id);
                    }
                  });
                },
              );
            }).toList(),
          ),

        if (childError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              childError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),
        const Align(
  alignment: Alignment.centerRight,
  child: Text(
    'نوع المهمة',
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  ),
),

const SizedBox(height: AppSpacing.xs),

Text(
  selectedChildIds.isEmpty
      ? 'اختر طفلًا أولًا لتفعيل أنواع المهام'
      : 'اختر نوع المهمة',
  textAlign: TextAlign.right,
  style: TextStyle(
    fontSize: 12,
    color: selectedChildIds.isEmpty
        ? Colors.grey.shade500
        : AppColors.textSecondary,
  ),
),

const SizedBox(height: AppSpacing.md),

_buildTaskTypeStep(),

const SizedBox(height: AppSpacing.lg),

const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'المهام تساعد الأطفال على بناء العادات والقيم وكسب نقاط نور.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        if (selectedTaskType != null) ...[
  const Align(
    alignment: Alignment.centerRight,
    child: Text(
      'إضافة سريعة',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ),
  ),

  const SizedBox(height: AppSpacing.sm),

  if (isLoadingSuggestions)
    const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: CircularProgressIndicator(),
      ),
    )
  else if (suggestionsError != null)
    Column(
      children: [
        Text(
          suggestionsError!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
        TextButton(
          onPressed: _loadTaskSuggestions,
          child: const Text('إعادة المحاولة'),
        ),
      ],
    )
  else
    _QuickAddCategory(
  icon: selectedTaskType == 0
      ? Icons.mosque_outlined
      : selectedTaskType == 1
          ? Icons.shopping_bag_outlined
          : selectedTaskType == 2
              ? Icons.menu_book_outlined
              : Icons.credit_card,
  label: selectedTaskType == 0
      ? 'المهام الثقافية'
      : selectedTaskType == 1
          ? 'المهام اليومية'
          : selectedTaskType == 2
              ? 'المهام الدينية'
              : 'المهام المالية',
  suggestions: taskSuggestions,
  onSuggestionTap: (suggestion) {
  setState(() {
    _applyTaskSuggestion(suggestion);
    currentStep = 1;
  });
},
),
],

      ],
    );
  }
  // ---- Step 1: task type ----

  Widget _buildTaskTypeStep() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _TaskTypeCard(
                icon: Icons.mosque_outlined,
                label: 'المهام الثقافية',
                isSelected: selectedTaskType == 0,
                isEnabled: selectedChildIds.isNotEmpty,
                onTap: () {
  setState(() {
    selectedTaskType = 0;
    categoryError = null;
  });

  _loadTaskSuggestions();
},
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _TaskTypeCard(
                icon: Icons.shopping_bag_outlined,
                label: 'المهام اليومية',
                isSelected: selectedTaskType == 1,
                isEnabled: selectedChildIds.isNotEmpty,
                onTap: () {
  setState(() {
    selectedTaskType = 1;
    categoryError = null;
  });

  _loadTaskSuggestions();
},
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: _TaskTypeCard(
                icon: Icons.menu_book_outlined,
                label: 'المهام الدينية',
                isSelected: selectedTaskType == 2,
                isEnabled: selectedChildIds.isNotEmpty,
                onTap: () {
  setState(() {
    selectedTaskType = 2;
    categoryError = null;
  });

  _loadTaskSuggestions();
},
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _TaskTypeCard(
                icon: Icons.credit_card,
                label: 'المهام المالية',
                isSelected: selectedTaskType == 3,
                isEnabled: selectedChildIds.isNotEmpty,
                onTap: () {
  setState(() {
    selectedTaskType = 3;
    categoryError = null;
  });

  _loadTaskSuggestions();
},
              ),
            ),
          ],
        ),
        if (categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                categoryError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
  Widget _buildTaskSuggestionsSection() {
  if (selectedTaskType == null) {
    return const SizedBox.shrink();
  }

  if (isLoadingSuggestions) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  if (suggestionsError != null) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        children: [
          Text(
            suggestionsError!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _loadTaskSuggestions,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  if (taskSuggestions.isEmpty) {
    return const SizedBox.shrink();
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Align(
        alignment: Alignment.centerRight,
        child: Text(
          'مهام مقترحة',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),

      const SizedBox(height: AppSpacing.xs),

      const Text(
        'اضغط على المهمة التي تناسبك',
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),

      const SizedBox(height: AppSpacing.md),

      ...taskSuggestions.map(
        (suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _applyTaskSuggestion(suggestion);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          suggestion.title,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          suggestion.description,
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${suggestion.points} نقطة',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: AppColors.gold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  // ---- Step 2: task details ----

  Widget _buildTaskDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'اسم المهمة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _TaskTextField(
          controller: taskNameController,
          hint: 'مثال: ترتيب سريرك',
          errorText: titleError,
        ),

        const SizedBox(height: AppSpacing.lg),

        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'الوصف',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _TaskTextField(
          controller: taskDescriptionController,
          hint: 'صف المهمة باختصار...',
          maxLines: 2,
          errorText: descriptionError,
        ),

        const SizedBox(height: AppSpacing.lg),

        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'نقاط نور',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _PointsButton(
                icon: Icons.add,
                onTap: () {
                  setState(() {
                    taskPoints = taskPoints + 5;
                  });
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _PointsButton(
                icon: Icons.remove,
                onTap: () {
                  // Do not let points go below zero.
                  if (taskPoints > 0) {
                    setState(() {
                      taskPoints = taskPoints - 5;
                    });
                  }
                },
              ),
              const Spacer(),
              Text(
                '$taskPoints نقطة',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
            ],
          ),
        ),
        if (pointsError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              pointsError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'نقاط نور تحفّز الأطفال وتشجعهم على الاستمرار.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        

const SizedBox(height: AppSpacing.xl),

const Align(
  alignment: Alignment.centerRight,
  child: Text(
    'تكرار المهمة',
    style: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  ),
),

const SizedBox(height: AppSpacing.md),

_buildTaskScheduleStep(),

const SizedBox(height: AppSpacing.xl),

Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.card,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.border),
  ),
  child: Row(
    children: [
      GestureDetector(
        onTap: () {
          setState(() {
            trustChild = !trustChild;
          });
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: trustChild ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
          child: trustChild
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : null,
        ),
      ),

      const SizedBox(width: AppSpacing.sm),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          textDirection: TextDirection.ltr,
          children: const [
            Text(
              'هل تثق بجدية طفلك في هذه المهمة؟',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'إذا وثقت، ستُعتمد المهمة تلقائيًا بدون الحاجة لمراجعتك',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
     ],
    );
  }

  // ---- Step 3: task schedule ----

  Widget _buildTaskScheduleStep() {
    return Column(
      children: [
        _FrequencyCard(
          title: 'يوميًا',
          subtitle: 'تُنفَّذ المهمة كل يوم',
          isSelected: selectedFrequency == 0,
          onTap: () {
            setState(() {
              selectedFrequency = 0;
            });
          },
        ),

        const SizedBox(height: AppSpacing.md),

        _FrequencyCard(
          title: 'مرة في الأسبوع',
          subtitle: 'تُنفَّذ المهمة مرة في الأسبوع',
          isSelected: selectedFrequency == 1,
          onTap: () {
            setState(() {
              selectedFrequency = 1;
            });
          },
          extraContent: selectedFrequency == 1
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اختر يوم الأسبوع',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final day in weekDays)
                          _SelectableChip(
                            label: day,
                            isSelected: selectedWeeklyDay == day,
                            onTap: () {
                              setState(() {
                                selectedWeeklyDay = day;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                )
              : null,
        ),

        const SizedBox(height: AppSpacing.md),

        _FrequencyCard(
          title: 'شهريًا',
          subtitle: 'تُنفَّذ المهمة مرة في الشهر',
          isSelected: selectedFrequency == 2,
          onTap: () {
            setState(() {
              selectedFrequency = 2;
            });
          },
          extraContent: selectedFrequency == 2
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اختر تاريخ التكرار',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    
  Center(
  child: InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: _showMonthlyDayPicker,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 18,
            color: AppColors.primaryDark,
          ),

          const SizedBox(width: AppSpacing.sm),

          Text(
            '$selectedMonthlyDay',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ],
      ),
    ),
  ),
),
                  ],
                )
              : null,
        ),
        if (frequencyError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              frequencyError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],

        if (recurrenceDayError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              recurrenceDayError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  // ---- Bottom buttons (change depending on the current step) ----

  Widget _buildBottomButtons() {
    // Step 0 only has a single full-width "Next" button.
    if (currentStep == 0) {
      return AppButton(
        text: 'التالي',
        onPressed: _goToNextStep,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
      );
    }

    // The last step shows "Save" instead of "Next".
    final isLastStep = currentStep == 1;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppButton(
            text: isLastStep ? 'حفظ المهمة' : 'التالي',
            onPressed: isSaving
                ? null
                : () async {
                    if (isLastStep) {
                      setState(() {
                        isSaving = true;

                        titleError = null;
                        descriptionError = null;
                        pointsError = null;
                        categoryError = null;
                        frequencyError = null;
                        recurrenceDayError = null;
                        childError = null;
                      });

                      try {
                        print("Before API");
                        print("recurrenceDay = $recurrenceDay");
                        print("type = ${recurrenceDay.runtimeType}");


                        await _taskApiService.createTask({
                          "child_ids": selectedChildIds,
                          "title": taskNameController.text.trim(),
                          "description": taskDescriptionController.text.trim(),
                          "points": taskPoints,
                          "task_frequency": taskFrequency,
                          "recurrence_day": recurrenceDay,
                          "category": category,
                          "is_auto_verified": trustChild,
                        });

                        if (!mounted) return;
                        Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (_) => const ParentMainScreen(
      initialIndex: 2,
    ),
  ),
);
                      } on DioException catch (e) {
                        final errors = e.response?.data["errors"];

                        setState(() {
                          titleError = mapBackendError(errors?["title"]?.first);
                          descriptionError = mapBackendError(
                            errors?["description"]?.first,
                          );
                          pointsError = mapBackendError(
                            errors?["points"]?.first,
                          );
                          childError = mapBackendError(
                            errors?["child_ids"]?.first,
                          );
                          categoryError = mapBackendError(
                            errors?["category"]?.first,
                          );
                          frequencyError = mapBackendError(
                            errors?["task_frequency"]?.first,
                          );
                          recurrenceDayError =
                          mapBackendError(getError(errors?["recurrence_day"])
                          );

                          if (childError != null || categoryError != null) {
  currentStep = 0;
} else if (titleError != null ||
    descriptionError != null ||
    pointsError != null ||
    frequencyError != null ||
    recurrenceDayError != null) {
  currentStep = 1;
}
                        });
                      } finally {
                        if (mounted) {
                          setState(() {
                            isSaving = false;
                          });
                        }
                      }
                    } else {
                      _goToNextStep();
                    }
                  },
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _goToPreviousStep,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'رجوع',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Round back button in the top-right corner. Always exits the whole
// wizard, no matter which step is showing (same as every mockup screen).
class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

// One child avatar + name used on Step 0, with a checkmark badge when
// selected. Tapping toggles that child in or out of the task.

class _ChildChip extends StatelessWidget {
  final String name;
  final Color avatarColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildChip({
    required this.name,
    required this.avatarColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              )
            else
              const SizedBox(width: 20),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Text(
                name,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: avatarColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: iconColor,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// One "quick add" category placeholder shown on Step 0. Static only, same
// simplification already used on the Reward Management screen: a plain
// light border instead of a dashed one.
class _QuickAddCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<TaskSuggestionModel> suggestions;
  final ValueChanged<TaskSuggestionModel> onSuggestionTap;

  const _QuickAddCategory({
    required this.icon,
    required this.label,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              icon,
              color: AppColors.primaryDark,
              size: 18,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: suggestions.isEmpty
              ? const Text(
                  'لا توجد مهام مقترحة حاليًا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < suggestions.length; i++) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          onSuggestionTap(suggestions[i]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                size: 18,
                                color: AppColors.primary,
                              ),

                              const SizedBox(width: AppSpacing.sm),

                              Expanded(
                                child: Text(
                                  suggestions[i].title,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (i != suggestions.length - 1)
                        const Divider(
                          height: 1,
                          color: AppColors.border,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
// One selectable task-type card shown on Step 1, arranged in a 2x2 grid.
class _TaskTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const _TaskTypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.card
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: !isEnabled
                ? Colors.grey.shade300
                : isSelected
                    ? AppColors.primary
                    : AppColors.border,
            width: isSelected && isEnabled ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.primaryLight
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isEnabled
                    ? AppColors.primaryDark
                    : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEnabled
                    ? AppColors.textPrimary
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _TaskTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? errorText;

  const _TaskTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorText: errorText,
      ),
    );
  }
}

// The small round + / - buttons next to the points value on Step 2.
class _PointsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PointsButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: icon == Icons.add ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: icon == Icons.add ? Colors.white : AppColors.primaryDark,
        ),
      ),
    );
  }
}

// A small rounded chip used to pick one weekly day or one monthly date.
// Turns purple when selected, light lavender otherwise.
class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

// One selectable frequency card shown on Step 3 (daily/weekly/monthly).
// extraContent is an optional row shown below the title when this card
// is selected, e.g. the weekly day picker or the monthly date picker.
class _FrequencyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? extraContent;

  const _FrequencyCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                ),
              ],
            ),
            if (extraContent != null) ...[
              const SizedBox(height: AppSpacing.sm),
              extraContent!,
            ],
          ],
        ),
      ),
    );
  }
}
