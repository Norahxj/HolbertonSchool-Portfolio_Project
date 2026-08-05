import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'task_filter_bar.dart';

class FilteredTasksEmptyState extends StatelessWidget {
  final bool isArabic;
  final ChildTaskFilter selectedFilter;

  const FilteredTasksEmptyState({
    super.key,
    required this.isArabic,
    required this.selectedFilter,
  });

  String get _message {
    switch (selectedFilter) {
      case ChildTaskFilter.all:
        return isArabic ? 'لا توجد مهام' : 'No tasks';

      case ChildTaskFilter.upcoming:
        return isArabic ? 'لا توجد مهام قادمة' : 'No upcoming tasks';

      case ChildTaskFilter.active:
        return isArabic ? 'لا توجد مهام نشطة' : 'No active tasks';

      case ChildTaskFilter.awaitingReview:
        return isArabic
            ? 'لا توجد مهام بانتظار المراجعة'
            : 'No tasks awaiting review';

      case ChildTaskFilter.completed:
        return isArabic ? 'لا توجد مهام مكتملة' : 'No completed tasks';

      case ChildTaskFilter.rejected:
        return isArabic ? 'لا توجد مهام مرفوضة' : 'No rejected tasks';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        _message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

class TasksEmptyState extends StatelessWidget {
  final bool isArabic;

  const TasksEmptyState({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isArabic
                ? 'لا توجد مهام لهذا الطفل حتى الآن'
                : 'This child has no tasks yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class TasksErrorState extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onRetry;

  const TasksErrorState({
    super.key,
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 38, color: AppColors.error),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isArabic ? 'تعذّر تحميل المهام' : 'Failed to load tasks',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
          ),
        ],
      ),
    );
  }
}
