import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/add_task_controller.dart';
import '../utils/add_task_localization.dart';
import 'task_type_card.dart';

class TaskTypeSection extends StatelessWidget {
  const TaskTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTaskTypeCard(
                context: context,
                controller: controller,
                taskType: 0,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: _buildTaskTypeCard(
                context: context,
                controller: controller,
                taskType: 1,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: _buildTaskTypeCard(
                context: context,
                controller: controller,
                taskType: 2,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: _buildTaskTypeCard(
                context: context,
                controller: controller,
                taskType: 3,
              ),
            ),
          ],
        ),

        if (controller.categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                controller.categoryError!.localized(context),
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTaskTypeCard({
    required BuildContext context,
    required AddTaskController controller,
    required int taskType,
  }) {
    return TaskTypeCard(
      icon: taskTypeIcon(taskType),
      label: taskTypeLabel(context, taskType),
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

  static String taskTypeLabel(BuildContext context, int taskType) {
    final l10n = context.l10n;

    switch (taskType) {
      case 0:
        return l10n.culturalTasks;

      case 1:
        return l10n.dailyTasks;

      case 2:
        return l10n.religiousTasks;

      default:
        return l10n.financialTasks;
    }
  }
}
