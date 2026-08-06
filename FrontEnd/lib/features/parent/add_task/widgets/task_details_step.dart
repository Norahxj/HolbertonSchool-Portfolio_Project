import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/add_task_controller.dart';
import '../utils/add_task_localization.dart';
import 'points_button.dart';
import 'task_schedule_section.dart';
import 'task_text_field.dart';

class TaskDetailsStep extends StatelessWidget {
  final Future<void> Function() onMonthlyDayPicker;

  const TaskDetailsStep({
    super.key,
    required this.onMonthlyDayPicker,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(
          text: l10n.taskName,
        ),

        const SizedBox(height: AppSpacing.sm),

        TaskTextField(
          controller: controller.taskNameController,
          hint: l10n.taskNameExample,
          errorText: controller.titleError?.localized(context),
        ),

        const SizedBox(height: AppSpacing.lg),

        _FieldLabel(
          text: l10n.taskDescription,
        ),

        const SizedBox(height: AppSpacing.sm),

        TaskTextField(
          controller: controller.taskDescriptionController,
          hint: l10n.taskDescriptionHint,
          maxLines: 2,
          errorText: controller.descriptionError?.localized(context),
        ),

        const SizedBox(height: AppSpacing.lg),

        _FieldLabel(
          text: l10n.noorPoints,
        ),

        const SizedBox(height: AppSpacing.sm),

        const _PointsSelector(),

        if (controller.pointsError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              controller.pointsError!.localized(context),
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        const _PointsInformationBox(),

        const SizedBox(height: AppSpacing.xl),

        _FieldLabel(
          text: l10n.taskFrequency,
        ),

        const SizedBox(height: AppSpacing.md),

        TaskScheduleSection(
          onMonthlyDayPicker: onMonthlyDayPicker,
        ),

        const SizedBox(height: AppSpacing.xl),

        const _TrustChildCard(),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PointsSelector extends StatelessWidget {
  const _PointsSelector();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          PointsButton(
            icon: Icons.add,
            onTap: controller.increasePoints,
          ),

          const SizedBox(width: AppSpacing.sm),

          PointsButton(
            icon: Icons.remove,
            onTap: controller.decreasePoints,
          ),

          const Spacer(),

          Text(
            l10n.pointsValue(
              controller.taskPoints,
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: AppSpacing.xs),

          const Icon(
            Icons.auto_awesome,
            color: AppColors.gold,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _PointsInformationBox extends StatelessWidget {
  const _PointsInformationBox();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
              l10n.pointsInformation,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          const Icon(
            Icons.auto_awesome,
            color: AppColors.primary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _TrustChildCard extends StatelessWidget {
  const _TrustChildCard();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.toggleTrustChild,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: controller.trustChild
                    ? AppColors.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: controller.trustChild
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.trustChildQuestion,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  l10n.trustChildDescription,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}