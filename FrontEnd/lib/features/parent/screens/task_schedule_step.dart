import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import 'package:frontend/features/parent/widgets/task_error_text.dart';
import 'package:frontend/features/parent/widgets/frequency_card.dart';
import 'package:frontend/features/parent/widgets/selectable_options.dart';

class TaskScheduleStep extends StatelessWidget {
  final int selectedFrequency;
  final String selectedWeeklyDay;
  final int selectedMonthlyDay;

  final List<String> weekDays;
  final List<int> monthlyDays;

  final String? frequencyError;
  final String? recurrenceDayError;

  final ValueChanged<int> onFrequencyChanged;
  final ValueChanged<String> onWeeklyDayChanged;
  final ValueChanged<int> onMonthlyDayChanged;

  const TaskScheduleStep({
    super.key,
    required this.selectedFrequency,
    required this.selectedWeeklyDay,
    required this.selectedMonthlyDay,
    required this.weekDays,
    required this.monthlyDays,
    required this.frequencyError,
    required this.recurrenceDayError,
    required this.onFrequencyChanged,
    required this.onWeeklyDayChanged,
    required this.onMonthlyDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FrequencyCard(
          title: 'يوميًا',
          subtitle: 'تُنفَّذ المهمة كل يوم',
          isSelected: selectedFrequency == 0,
          onTap: () => onFrequencyChanged(0),
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          title: 'مرة في الأسبوع',
          subtitle: 'تُنفَّذ المهمة مرة في الأسبوع',
          isSelected: selectedFrequency == 1,
          onTap: () => onFrequencyChanged(1),
          child: selectedFrequency == 1
              ? _buildWeeklyDays()
              : null,
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          title: 'شهريًا',
          subtitle: 'تُنفَّذ المهمة مرة في الشهر',
          isSelected: selectedFrequency == 2,
          onTap: () => onFrequencyChanged(2),
          child: selectedFrequency == 2
              ? _buildMonthlyDays()
              : null,
        ),

        if (frequencyError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ErrorText(frequencyError!),
        ],

        if (recurrenceDayError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          ErrorText(recurrenceDayError!),
        ],
      ],
    );
  }

  Widget _buildWeeklyDays() {
    return SelectableOptions(
      title: 'اختر يوم الأسبوع',
      options: weekDays,
      selected: selectedWeeklyDay,
      onSelected: onWeeklyDayChanged,
    );
  }

  Widget _buildMonthlyDays() {
    return SelectableOptions(
      title: 'اختر تاريخ التكرار',
      options: monthlyDays.map((day) => '$day').toList(),
      selected: '$selectedMonthlyDay',
      onSelected: (day) {
        onMonthlyDayChanged(int.parse(day));
      },
    );
  }
}