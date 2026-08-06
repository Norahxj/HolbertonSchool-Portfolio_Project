import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import 'task_filter_bar.dart';

class FilteredTasksEmptyState extends StatelessWidget {
  final ChildTaskFilter selectedFilter;

  const FilteredTasksEmptyState({super.key, required this.selectedFilter});

  String _message(BuildContext context) {
    final l10n = context.l10n;

    switch (selectedFilter) {
      case ChildTaskFilter.all:
        return l10n.noTasks;

      case ChildTaskFilter.upcoming:
        return l10n.noUpcomingTasks;

      case ChildTaskFilter.active:
        return l10n.noActiveTasks;

      case ChildTaskFilter.awaitingReview:
        return l10n.noTasksAwaitingReview;

      case ChildTaskFilter.completed:
        return l10n.noCompletedTasks;

      case ChildTaskFilter.rejected:
        return l10n.noRejectedTasks;
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
        _message(context),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

class TasksEmptyState extends StatelessWidget {
  const TasksEmptyState({super.key});

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
            context.l10n.childHasNoTasks,
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
  final Future<void> Function() onRetry;

  const TasksErrorState({super.key, required this.onRetry});

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
            context.l10n.failedToLoadTasks,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () {
              onRetry();
            },
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}
