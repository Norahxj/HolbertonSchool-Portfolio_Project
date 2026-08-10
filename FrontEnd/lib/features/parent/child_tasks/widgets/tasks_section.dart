import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../models/task_assignment_model.dart';
import '../controllers/child_tasks_controller.dart';
import '../models/upcoming_child_task.dart';
import 'child_task_card.dart';
import 'task_filter_bar.dart';
import 'task_states.dart';
import 'upcoming_task_card.dart';

class TasksSection extends StatelessWidget {
  final ChildTasksController controller;
  final List<TaskAssignmentModel> tasks;
  final List<UpcomingChildTask> upcomingTasks;
  final ChildTaskFilter selectedFilter;
  final ValueChanged<TaskAssignmentModel> onAssignmentTap;
  final ValueChanged<UpcomingChildTask> onUpcomingTaskTap;

  final Future<void> Function({
    required String taskId,
    required String taskTitle,
  })
  onDeleteTask;

  const TasksSection({
    super.key,
    required this.controller,
    required this.tasks,
    required this.upcomingTasks,
    required this.selectedFilter,
    required this.onAssignmentTap,
    required this.onUpcomingTaskTap,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading && controller.hasNoTaskData) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final hasError =
        controller.errorCode != null || controller.backendMessage != null;

    if (hasError && controller.hasNoTaskData) {
      return TasksErrorState(onRetry: controller.refresh);
    }

    if (controller.hasNoTaskData) {
      return const TasksEmptyState();
    }

    if (tasks.isEmpty && upcomingTasks.isEmpty) {
      return FilteredTasksEmptyState(selectedFilter: selectedFilter);
    }

    return Column(
      children: [
        for (final upcomingTask in upcomingTasks)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: UpcomingTaskCard(
              item: upcomingTask,
              canDelete: controller.canDeleteTask(upcomingTask.task.id),
              isDeleting: controller.isDeletingTask(upcomingTask.task.id),
              onTap: () {
                onUpcomingTaskTap(upcomingTask);
              },
              onDelete: () {
                return onDeleteTask(
                  taskId: upcomingTask.task.id,
                  taskTitle: upcomingTask.task.title,
                );
              },
            ),
          ),
        for (final assignment in tasks)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            child: ChildTaskCard(
              assignment: assignment,
              canDelete: controller.canDeleteTask(assignment.task.id),
              isDeleting: controller.isDeletingTask(assignment.task.id),
              onTap: () {
                onAssignmentTap(assignment);
              },
              onDelete: () {
                return onDeleteTask(
                  taskId: assignment.task.id,
                  taskTitle: assignment.task.title,
                );
              },
            ),
          ),
      ],
    );
  }
}
