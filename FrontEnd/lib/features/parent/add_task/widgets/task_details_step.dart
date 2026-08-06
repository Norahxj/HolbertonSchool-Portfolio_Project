import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/add_task_controller.dart';
import 'points_button.dart';
import 'task_schedule_section.dart';
import 'task_text_field.dart';

class TaskDetailsStep extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function() onMonthlyDayPicker;

  const TaskDetailsStep({
    super.key,
    required this.isArabic,
    required this.onMonthlyDayPicker,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(
          text: controller.text('اسم المهمة', 'Task Name'),
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.sm),

        TaskTextField(
          controller: controller.taskNameController,
          hint: controller.text('مثال: ترتيب سريرك', 'Example: Make your bed'),
          isArabic: isArabic,
          errorText: controller.titleError,
        ),

        const SizedBox(height: AppSpacing.lg),

        _FieldLabel(
          text: controller.text('الوصف', 'Description'),
          isArabic: isArabic,
        ),

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

        _FieldLabel(
          text: controller.text('نقاط نور', 'Noor Points'),
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.sm),

        _PointsSelector(isArabic: isArabic),

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

        _PointsInformationBox(isArabic: isArabic),

        const SizedBox(height: AppSpacing.xl),

        _FieldLabel(
          text: controller.text('تكرار المهمة', 'Task Frequency'),
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.md),

        TaskScheduleSection(
          isArabic: isArabic,
          onMonthlyDayPicker: onMonthlyDayPicker,
        ),

        const SizedBox(height: AppSpacing.xl),

        _TrustChildCard(isArabic: isArabic),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isArabic;

  const _FieldLabel({required this.text, required this.isArabic});

  @override
  Widget build(BuildContext context) {
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
}

class _PointsSelector extends StatelessWidget {
  final bool isArabic;

  const _PointsSelector({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

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
}

class _PointsInformationBox extends StatelessWidget {
  final bool isArabic;

  const _PointsInformationBox({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<AddTaskController>();

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
}

class _TrustChildCard extends StatelessWidget {
  final bool isArabic;

  const _TrustChildCard({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

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
}
