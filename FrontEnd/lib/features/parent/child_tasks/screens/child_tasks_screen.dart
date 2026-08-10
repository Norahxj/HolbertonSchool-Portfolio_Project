import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/task_assignment_model.dart';
import '../controllers/child_tasks_controller.dart';
import '../models/child_task_action_result.dart';
import '../models/upcoming_child_task.dart';
import '../utils/child_tasks_localization.dart';
import '../widgets/child_tasks_view.dart';
import 'parent_child_task_details_screen.dart';

class ChildTasksScreen extends StatefulWidget {
  final String childId;
  final String childName;

  const ChildTasksScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildTasksScreen> createState() {
    return _ChildTasksScreenState();
  }
}

class _ChildTasksScreenState extends State<ChildTasksScreen> {
  late final ChildTasksController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ChildTasksController()
      ..loadTasks(widget.childId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteTask({
    required String taskId,
    required String taskTitle,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.deleteTaskTitle,
            textAlign: TextAlign.start,
          ),
          content: Text(
            context.l10n.deleteTaskConfirmation(taskTitle),
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final result = await _controller.deleteTask(taskId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showActionError(result);
      return;
    }

    _showMessage(
      context.l10n.taskDeletedSuccessfully,
    );
  }

  void _openAssignmentDetails(
    TaskAssignmentModel assignment,
  ) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ParentChildTaskDetailsScreen(
            assignment: assignment,
            icon: Icons.task_alt_outlined,
          );
        },
      ),
    );
  }

  void _openUpcomingTaskDetails(
    UpcomingChildTask item,
  ) {
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

    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ParentChildTaskDetailsScreen(
            assignment: assignment,
            icon: Icons.event_available_outlined,
          );
        },
      ),
    );
  }

  void _showActionError(
    ChildTaskActionResult result,
  ) {
    final message =
        result.backendMessage ??
        result.errorCode?.localized(context) ??
        context.l10n.failedToDeleteTask;

    _showMessage(message);
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildTasksView(
        childName: widget.childName,
        onBack: _goBack,
        onAssignmentTap: _openAssignmentDetails,
        onUpcomingTaskTap: _openUpcomingTaskDetails,
        onDeleteTask: _confirmDeleteTask,
      ),
    );
  }
}