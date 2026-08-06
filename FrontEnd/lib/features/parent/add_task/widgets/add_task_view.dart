import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/screen_background.dart';
import 'child_card.dart';
import '../controllers/add_task_controller.dart';
import 'frequency_card.dart';
import 'points_button.dart';
import 'quick_add_category.dart';
import 'selectable_chip.dart';
import 'task_text_field.dart';
import 'task_type_card.dart';

class AddTaskView extends StatelessWidget {
  final bool isArabic;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Future<void> Function() onSave;
  final Future<void> Function() onMonthlyDayPicker;
  final VoidCallback onSuggestionApplied;

  const AddTaskView({
    super.key,
    required this.isArabic,
    required this.scrollController,
    required this.onRefresh,
    required this.onNext,
    required this.onBack,
    required this.onSave,
    required this.onMonthlyDayPicker,
    required this.onSuggestionApplied,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        controller.stepTitle,
                        style: AppTextStyles.arabicTitle,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      controller.stepSubtitle,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    if (controller.currentStep == 0)
                      _buildChooseChildStep(context, controller),

                    if (controller.currentStep == 1)
                      _buildTaskDetailsStep(context, controller),

                    const SizedBox(height: AppSpacing.xl),

                    _buildBottomButtons(controller),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChooseChildStep(
    BuildContext context,
    AddTaskController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (controller.isLoadingChildren)
          const Center(child: CircularProgressIndicator())
        else if (controller.children.isEmpty)
          Center(
            child: Text(
              controller.text(
                'لا يوجد أطفال بعد. الرجاء إضافة طفل أولاً.',
                'No children yet. Please add a child first.',
              ),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: controller.children.map((child) {
              final isSelected = controller.selectedChildIds.contains(child.id);

              return ChildCard(
                name: child.name,
                avatarIndex: child.avatarIndex,
                isSelected: isSelected,
                onTap: () {
                  controller.toggleChild(child.id);
                },
              );
            }).toList(),
          ),

        if (controller.childError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              controller.childError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            controller.text('نوع المهمة', 'Task Type'),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          controller.selectedChildIds.isEmpty
              ? controller.text(
                  'اختر طفلًا أولًا لتفعيل أنواع المهام',
                  'Select a child first to enable task types',
                )
              : controller.text('اختر نوع المهمة', 'Choose a task type'),
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 12,
            color: controller.selectedChildIds.isEmpty
                ? Colors.grey.shade500
                : AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        _buildTaskTypeStep(controller),

        const SizedBox(height: AppSpacing.xl),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.text(
                    'المهام تساعد الأطفال على بناء العادات والقيم وكسب نقاط نور.',
                    'Tasks help children build habits and values while earning Noor points.',
                  ),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 18,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        if (controller.selectedTaskType != null) ...[
          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              controller.text('إضافة سريعة', 'Quick Add'),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          if (controller.isLoadingSuggestions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: CircularProgressIndicator(),
              ),
            )
          else if (controller.suggestionsError != null)
            Column(
              children: [
                Text(
                  controller.suggestionsError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),

                TextButton(
                  onPressed: controller.loadTaskSuggestions,
                  child: Text(controller.text('إعادة المحاولة', 'Try Again')),
                ),
              ],
            )
          else
            QuickAddCategory(
              icon: _taskTypeIcon(controller.selectedTaskType!),
              label: _taskTypeLabel(controller, controller.selectedTaskType!),
              suggestions: controller.taskSuggestions,
              isArabic: isArabic,
              onSuggestionTap: (suggestion) {
                controller.applyTaskSuggestion(suggestion);
                onSuggestionApplied();
              },
            ),
        ],
      ],
    );
  }

  Widget _buildTaskTypeStep(AddTaskController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTaskTypeCard(controller: controller, taskType: 0),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: _buildTaskTypeCard(controller: controller, taskType: 1),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: _buildTaskTypeCard(controller: controller, taskType: 2),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: _buildTaskTypeCard(controller: controller, taskType: 3),
            ),
          ],
        ),

        if (controller.categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: isArabic
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                controller.categoryError!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTaskTypeCard({
    required AddTaskController controller,
    required int taskType,
  }) {
    return TaskTypeCard(
      icon: _taskTypeIcon(taskType),
      label: _taskTypeLabel(controller, taskType),
      isSelected: controller.selectedTaskType == taskType,
      isEnabled: controller.selectedChildIds.isNotEmpty,
      onTap: () {
        controller.selectTaskType(taskType);
      },
    );
  }

  IconData _taskTypeIcon(int taskType) {
    switch (taskType) {
      case 0:
        return Icons.mosque_outlined;
      case 1:
        return Icons.shopping_bag_outlined;
      case 2:
        return Icons.menu_book_outlined;
      default:
        return Icons.credit_card;
    }
  }

  String _taskTypeLabel(AddTaskController controller, int taskType) {
    switch (taskType) {
      case 0:
        return controller.text('المهام الثقافية', 'Cultural Tasks');

      case 1:
        return controller.text('المهام اليومية', 'Daily Tasks');

      case 2:
        return controller.text('المهام الدينية', 'Religious Tasks');

      default:
        return controller.text('المهام المالية', 'Financial Tasks');
    }
  }

  Widget _buildTaskDetailsStep(
    BuildContext context,
    AddTaskController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _fieldLabel(controller.text('اسم المهمة', 'Task Name')),

        const SizedBox(height: AppSpacing.sm),

        TaskTextField(
          controller: controller.taskNameController,
          hint: controller.text('مثال: ترتيب سريرك', 'Example: Make your bed'),
          isArabic: isArabic,
          errorText: controller.titleError,
        ),

        const SizedBox(height: AppSpacing.lg),

        _fieldLabel(controller.text('الوصف', 'Description')),

        const SizedBox(height: AppSpacing.sm),

        TaskTextField(
          controller: controller.taskDescriptionController,
          hint: controller.text(
            'صف المهمة باختصار...',
            'Briefly describe the task...',
          ),
          isArabic: isArabic,
          maxLines: 2,
          errorText: controller.descriptionError,
        ),

        const SizedBox(height: AppSpacing.lg),

        _fieldLabel(controller.text('نقاط نور', 'Noor Points')),

        const SizedBox(height: AppSpacing.sm),

        _buildPointsSelector(controller),

        if (controller.pointsError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              controller.pointsError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        _buildPointsInformation(controller),

        const SizedBox(height: AppSpacing.xl),

        _fieldLabel(controller.text('تكرار المهمة', 'Task Frequency')),

        const SizedBox(height: AppSpacing.md),

        _buildTaskScheduleStep(controller),

        const SizedBox(height: AppSpacing.xl),

        _buildTrustChildCard(controller),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPointsSelector(AddTaskController controller) {
    return Container(
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
          PointsButton(icon: Icons.add, onTap: controller.increasePoints),

          const SizedBox(width: AppSpacing.sm),

          PointsButton(icon: Icons.remove, onTap: controller.decreasePoints),

          const Spacer(),

          Text(
            isArabic
                ? '${controller.taskPoints} نقطة'
                : '${controller.taskPoints} points',
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
    );
  }

  Widget _buildPointsInformation(AddTaskController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              controller.text(
                'نقاط نور تحفّز الأطفال وتشجعهم على الاستمرار.',
                'Noor points motivate children and encourage them to keep going.',
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
        ],
      ),
    );
  }

  Widget _buildTrustChildCard(AddTaskController controller) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.toggleTrustChild,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: controller.trustChild ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: controller.trustChild
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  controller.text(
                    'هل تثق بجدية طفلك في هذه المهمة؟',
                    'Do you trust your child to complete this task seriously?',
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  controller.text(
                    'إذا وثقت، ستُعتمد المهمة تلقائيًا بدون الحاجة لمراجعتك',
                    'If you do, the task will be approved automatically without your review.',
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskScheduleStep(AddTaskController controller) {
    return Column(
      children: [
        FrequencyCard(
          isArabic: isArabic,
          title: controller.text('يوميًا', 'Daily'),
          subtitle: controller.text(
            'تُنفَّذ المهمة كل يوم',
            'The task is completed every day',
          ),
          isSelected: controller.selectedFrequency == 0,
          onTap: () {
            controller.selectFrequency(0);
          },
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          isArabic: isArabic,
          title: controller.text('مرة في الأسبوع', 'Once a Week'),
          subtitle: controller.text(
            'تُنفَّذ المهمة مرة في الأسبوع',
            'The task is completed once a week',
          ),
          isSelected: controller.selectedFrequency == 1,
          onTap: () {
            controller.selectFrequency(1);
          },
          extraContent: controller.selectedFrequency == 1
              ? _buildWeeklyPicker(controller)
              : null,
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          isArabic: isArabic,
          title: controller.text('شهريًا', 'Monthly'),
          subtitle: controller.text(
            'تُنفَّذ المهمة مرة في الشهر',
            'The task is completed once a month',
          ),
          isSelected: controller.selectedFrequency == 2,
          onTap: () {
            controller.selectFrequency(2);
          },
          extraContent: controller.selectedFrequency == 2
              ? _buildMonthlyPicker(controller)
              : null,
        ),

        if (controller.frequencyError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              controller.frequencyError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],

        if (controller.recurrenceDayError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              controller.recurrenceDayError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeeklyPicker(AddTaskController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            controller.text('اختر يوم الأسبوع', 'Choose a day of the week'),
            style: const TextStyle(
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
            for (final day in controller.weekDays)
              SelectableChip(
                label: controller.weekDayLabel(day),
                isSelected: controller.selectedWeeklyDay == day,
                onTap: () {
                  controller.selectWeeklyDay(day);
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthlyPicker(AddTaskController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            controller.text('اختر تاريخ التكرار', 'Choose the repeat date'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onMonthlyDayPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
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
                    '${controller.selectedMonthlyDay}',
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
    );
  }

  Widget _buildBottomButtons(AddTaskController controller) {
    if (controller.currentStep == 0) {
      return AppButton(
        text: controller.text('التالي', 'Next'),
        onPressed: onNext,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppButton(
            text: controller.isSaving
                ? controller.text('جارٍ الحفظ...', 'Saving...')
                : controller.text('حفظ المهمة', 'Save Task'),
            onPressed: controller.isSaving ? null : onSave,
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
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                controller.text('رجوع', 'Back'),
                style: const TextStyle(
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
