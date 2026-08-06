import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../controllers/add_task_controller.dart';
import 'frequency_card.dart';
import 'selectable_chip.dart';

class TaskScheduleSection extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function() onMonthlyDayPicker;

  const TaskScheduleSection({
    super.key,
    required this.isArabic,
    required this.onMonthlyDayPicker,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

    return Column(
      children: [
        FrequencyCard(
          isArabic: isArabic,
          title: controller.text('يوميًا', 'Daily'),
          subtitle: controller.text(
            'تُنفَّذ المهمة كل يوم',
            'The task is completed every day',
          ),
          isSelected: controller.selectedFrequency == 0,
          onTap: () {
            controller.selectFrequency(0);
          },
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          isArabic: isArabic,
          title: controller.text('مرة في الأسبوع', 'Once a Week'),
          subtitle: controller.text(
            'تُنفَّذ المهمة مرة في الأسبوع',
            'The task is completed once a week',
          ),
          isSelected: controller.selectedFrequency == 1,
          onTap: () {
            controller.selectFrequency(1);
          },
          extraContent: controller.selectedFrequency == 1
              ? _WeeklyDayPicker(isArabic: isArabic)
              : null,
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          isArabic: isArabic,
          title: controller.text('شهريًا', 'Monthly'),
          subtitle: controller.text(
            'تُنفَّذ المهمة مرة في الشهر',
            'The task is completed once a month',
          ),
          isSelected: controller.selectedFrequency == 2,
          onTap: () {
            controller.selectFrequency(2);
          },
          extraContent: controller.selectedFrequency == 2
              ? _MonthlyDayPicker(isArabic: isArabic, onTap: onMonthlyDayPicker)
              : null,
        ),

        if (controller.frequencyError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              controller.frequencyError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],

        if (controller.recurrenceDayError != null) ...[
          const SizedBox(height: AppSpacing.sm),

          Align(
            alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              controller.recurrenceDayError!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeeklyDayPicker extends StatelessWidget {
  final bool isArabic;

  const _WeeklyDayPicker({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            controller.text('اختر يوم الأسبوع', 'Choose a day of the week'),
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
                label: controller.weekDayLabel(day),
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
  final bool isArabic;
  final Future<void> Function() onTap;

  const _MonthlyDayPicker({required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddTaskController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            controller.text('اختر تاريخ التكرار', 'Choose the repeat date'),
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
                border: Border.all(color: AppColors.border),
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
