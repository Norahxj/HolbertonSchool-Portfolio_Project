import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/add_task_controller.dart';
import '../utils/add_task_localization.dart';
import 'frequency_card.dart';
import 'selectable_chip.dart';

class TaskScheduleSection extends StatelessWidget {
  final Future<void> Function() onMonthlyDayPicker;

  const TaskScheduleSection({
    super.key,
    required this.onMonthlyDayPicker,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();
    final l10n = context.l10n;

    return Column(
      children: [
        FrequencyCard(
          title: l10n.daily,
          subtitle: l10n.dailyFrequencyDescription,
          isSelected: controller.selectedFrequency == 0,
          onTap: () {
            controller.selectFrequency(0);
          },
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          title: l10n.weekly,
          subtitle: l10n.weeklyFrequencyDescription,
          isSelected: controller.selectedFrequency == 1,
          onTap: () {
            controller.selectFrequency(1);
          },
          extraContent: controller.selectedFrequency == 1
              ? const _WeeklyDayPicker()
              : null,
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          title: l10n.monthly,
          subtitle: l10n.monthlyFrequencyDescription,
          isSelected: controller.selectedFrequency == 2,
          onTap: () {
            controller.selectFrequency(2);
          },
          extraContent: controller.selectedFrequency == 2
              ? _MonthlyDayPicker(
                  onTap: onMonthlyDayPicker,
                )
              : null,
        ),

        if (controller.frequencyBackendError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              controller.frequencyBackendError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],

        if (controller.recurrenceDayBackendError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              controller.recurrenceDayBackendError!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeeklyDayPicker extends StatelessWidget {
  const _WeeklyDayPicker();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.chooseWeekDay,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final day in controller.weekDays)
              SelectableChip(
                label: day.localized(context),
                isSelected: controller.selectedWeeklyDay == day,
                onTap: () {
                  controller.selectWeeklyDay(day);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _MonthlyDayPicker extends StatelessWidget {
  final Future<void> Function() onTap;

  const _MonthlyDayPicker({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            l10n.chooseRepeatDate,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: AppColors.primaryDark,
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Text(
                    '${controller.selectedMonthlyDay}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}