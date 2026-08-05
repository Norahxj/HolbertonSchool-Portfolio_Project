import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../parent_child_details/controllers/parent_child_details_controller.dart';
import '../widgets/child_tasks_view.dart';

class ChildTasksScreen extends StatelessWidget {
  final String childId;
  final String childName;
  final bool isArabic;
  final ParentChildDetailsController controller;

  const ChildTasksScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.isArabic,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: controller,
      child: _ChildTasksCoordinator(
        childId: childId,
        childName: childName,
        isArabic: isArabic,
      ),
    );
  }
}

class _ChildTasksCoordinator extends StatefulWidget {
  final String childId;
  final String childName;
  final bool isArabic;

  const _ChildTasksCoordinator({
    required this.childId,
    required this.childName,
    required this.isArabic,
  });

  @override
  State<_ChildTasksCoordinator> createState() => _ChildTasksCoordinatorState();
}

class _ChildTasksCoordinatorState extends State<_ChildTasksCoordinator> {
  Future<void> _confirmDeleteTask({
    required String taskId,
    required String taskTitle,
  }) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(widget.isArabic ? 'حذف المهمة؟' : 'Delete task?'),
          content: Text(
            widget.isArabic
                ? 'سيتم حذف مهمة "$taskTitle" نهائيًا، ولا يمكن التراجع عن هذا الإجراء.'
                : 'The task "$taskTitle" will be permanently deleted. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(widget.isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(widget.isArabic ? 'حذف' : 'Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final controller = context.read<ParentChildDetailsController>();

    final errorMessage = await controller.deleteTask(taskId);

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      final message = errorMessage == 'You can only delete tasks you created.'
          ? widget.isArabic
                ? 'لا يمكنك حذف هذه المهمة لأنها أُنشئت بواسطة ولي أمر آخر.'
                : 'You cannot delete this task because it was created by another parent.'
          : widget.isArabic
          ? 'تعذر حذف المهمة. حاولي مرة أخرى.'
          : errorMessage;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic ? 'تم حذف المهمة بنجاح' : 'Task deleted successfully',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ParentChildDetailsController>();

    return ChildTasksView(
      childId: widget.childId,
      childName: widget.childName,
      isArabic: widget.isArabic,
      controller: controller,
      onDeleteTask: ({required String taskId, required String taskTitle}) {
        return _confirmDeleteTask(taskId: taskId, taskTitle: taskTitle);
      },
    );
  }
}
