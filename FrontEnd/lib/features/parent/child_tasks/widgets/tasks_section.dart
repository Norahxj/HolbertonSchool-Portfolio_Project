import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../models/task_assignment_model.dart';
import '../../parent_child_details/controllers/parent_child_details_controller.dart';
import '../../parent_child_details/models/parent_child_tasks_data.dart';
import 'child_task_card.dart';
import 'task_filter_bar.dart';
import 'task_states.dart';
import 'upcoming_task_card.dart';

class TasksSection extends StatelessWidget {
  final ParentChildDetailsController controller;
  final String childId;
  final List<TaskAssignmentModel> tasks;
  final List<UpcomingTaskItem> upcomingTasks;
  final ChildTaskFilter selectedFilter;
  final ValueChanged<TaskAssignmentModel> onAssignmentTap;
  final ValueChanged<UpcomingTaskItem> onUpcomingTaskTap;

  final Future<void> Function({
    required String taskId,
    required String taskTitle,
  })
  onDeleteTask;

  const TasksSection({
    super.key,
    required this.controller,
    required this.childId,
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
      return TasksErrorState(
        onRetry: () {
          controller.loadTasks(childId);
        },
      );
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
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: UpcomingTaskCard(
              item: upcomingTask,
              canDelete: controller.canDeleteTask(upcomingTask.task.id),
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
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ChildTaskCard(
              assignment: assignment,
              canDelete: controller.canDeleteTask(assignment.task.id),
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
