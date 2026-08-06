import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/add_task_controller.dart';
import 'child_card.dart';
import 'quick_add_category.dart';
import 'task_type_section.dart';

class ChooseChildStep extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onSuggestionApplied;

  const ChooseChildStep({
    super.key,
    required this.isArabic,
    required this.onSuggestionApplied,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

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
              textAlign: TextAlign.center,
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

        TaskTypeSection(isArabic: isArabic),

        const SizedBox(height: AppSpacing.xl),

        _TaskInformationBox(
          text: controller.text(
            'المهام تساعد الأطفال على بناء العادات والقيم وكسب نقاط نور.',
            'Tasks help children build habits and values while earning Noor points.',
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
                  textAlign: TextAlign.center,
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
              icon: TaskTypeSection.taskTypeIcon(controller.selectedTaskType!),
              label: TaskTypeSection.taskTypeLabel(
                controller,
                controller.selectedTaskType!,
              ),
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
}

class _TaskInformationBox extends StatelessWidget {
  final String text;

  const _TaskInformationBox({required this.text});

  @override
  Widget build(BuildContext context) {
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
              text,
              textAlign: TextAlign.start,
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
