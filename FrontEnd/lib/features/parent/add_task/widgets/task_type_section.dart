import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/add_task_controller.dart';
import 'task_type_card.dart';

class TaskTypeSection extends StatelessWidget {
  final bool isArabic;

  const TaskTypeSection({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

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
      icon: taskTypeIcon(taskType),
      label: taskTypeLabel(controller, taskType),
      isSelected: controller.selectedTaskType == taskType,
      isEnabled: controller.selectedChildIds.isNotEmpty,
      onTap: () {
        controller.selectTaskType(taskType);
      },
    );
  }

  static IconData taskTypeIcon(int taskType) {
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

  static String taskTypeLabel(AddTaskController controller, int taskType) {
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
}
