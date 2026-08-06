import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/task_assignment_model.dart';
import '../../../child/screens/child_task_details_screen.dart';
import '../../parent_child_details/controllers/parent_child_details_controller.dart';
import '../../parent_child_details/models/parent_child_tasks_data.dart';
import '../../parent_child_details/utils/parent_child_details_localization.dart';
import '../widgets/child_tasks_view.dart';

class ChildTasksScreen extends StatelessWidget {
  final String childId;
  final String childName;
  final ParentChildDetailsController controller;

  const ChildTasksScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: _ChildTasksCoordinator(
        childId: childId,
        childName: childName,
      ),
    );
  }
}

class _ChildTasksCoordinator extends StatefulWidget {
  final String childId;
  final String childName;

  const _ChildTasksCoordinator({
    required this.childId,
    required this.childName,
  });

  @override
  State<_ChildTasksCoordinator> createState() {
    return _ChildTasksCoordinatorState();
  }
}

class _ChildTasksCoordinatorState extends State<_ChildTasksCoordinator> {
  Future<void> _confirmDeleteTask({
    required String taskId,
    required String taskTitle,
  }) async {
    final l10n = context.l10n;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.deleteTaskTitle,
            textAlign: TextAlign.start,
          ),
          content: Text(
            l10n.deleteTaskConfirmation(taskTitle),
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final controller =
        context.read<ParentChildDetailsController>();

    final result = await controller.deleteTask(taskId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      final message =
          result.backendMessage ??
          result.errorCode?.localized(context) ??
          context.l10n.failedToDeleteTask;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.taskDeletedSuccessfully,
        ),
      ),
    );
  }

  void _openAssignmentDetails(
    TaskAssignmentModel assignment,
  ) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildTaskDetailsScreen(
            assignment: assignment,
            icon: Icons.task_alt_outlined,
            isArabic: isArabic,
            parentView: true,
          );
        },
      ),
    );
  }

  void _openUpcomingTaskDetails(
    UpcomingTaskItem item,
  ) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final assignment = TaskAssignmentModel(
      id: '',
      status: 'PENDING',
      assignedDate: item.nextDate,
      task: AssignmentTask(
        id: item.task.id,
        title: item.task.title,
        description: item.task.description,
        points: item.task.points,
        taskFrequency: item.task.taskFrequency,
        recurrenceDay: item.task.recurrenceDay,
        category: item.task.category,
        isAutoVerified: item.task.isAutoVerified,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildTaskDetailsScreen(
            assignment: assignment,
            icon: Icons.event_available_outlined,
            isArabic: isArabic,
            parentView: true,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<ParentChildDetailsController>();

    return ChildTasksView(
      childId: widget.childId,
      childName: widget.childName,
      controller: controller,
      onAssignmentTap: _openAssignmentDetails,
      onUpcomingTaskTap: _openUpcomingTaskDetails,
      onDeleteTask: ({
        required String taskId,
        required String taskTitle,
      }) {
        return _confirmDeleteTask(
          taskId: taskId,
          taskTitle: taskTitle,
        );
      },
    );
  }
}