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
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      children: [
        FrequencyCard(
          title: isArabic ? 'يوميًا' : 'Daily',
          subtitle: isArabic
              ? 'تُنفَّذ المهمة كل يوم'
              : 'The task is completed every day',
          isSelected: selectedFrequency == 0,
          onTap: () => onFrequencyChanged(0),
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          title: isArabic ? 'مرة في الأسبوع' : 'Once a week',
          subtitle: isArabic
              ? 'تُنفَّذ المهمة مرة في الأسبوع'
              : 'The task is completed once a week',
          isSelected: selectedFrequency == 1,
          onTap: () => onFrequencyChanged(1),
          child: selectedFrequency == 1 ? _buildWeeklyDays(isArabic) : null,
        ),

        const SizedBox(height: AppSpacing.md),

        FrequencyCard(
          title: isArabic ? 'شهريًا' : 'Monthly',
          subtitle: isArabic
              ? 'تُنفَّذ المهمة مرة في الشهر'
              : 'The task is completed once a month',
          isSelected: selectedFrequency == 2,
          onTap: () => onFrequencyChanged(2),
          child: selectedFrequency == 2 ? _buildMonthlyDays(isArabic) : null,
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

  Widget _buildWeeklyDays(bool isArabic) {
    final displayedWeekDays = weekDays
        .map((day) => _translateWeekDay(day, isArabic))
        .toList();

    final selectedDayIndex = weekDays.indexOf(selectedWeeklyDay);

    final displayedSelectedDay = selectedDayIndex >= 0
        ? displayedWeekDays[selectedDayIndex]
        : selectedWeeklyDay;

    return SelectableOptions(
      title: isArabic ? 'اختر يوم الأسبوع' : 'Select a day of the week',
      options: displayedWeekDays,
      selected: displayedSelectedDay,
      onSelected: (selectedDay) {
        final selectedIndex = displayedWeekDays.indexOf(selectedDay);

        if (selectedIndex >= 0) {
          onWeeklyDayChanged(weekDays[selectedIndex]);
        }
      },
    );
  }

  Widget _buildMonthlyDays(bool isArabic) {
    return SelectableOptions(
      title: isArabic ? 'اختر تاريخ التكرار' : 'Select the recurrence date',
      options: monthlyDays.map((day) => '$day').toList(),
      selected: '$selectedMonthlyDay',
      onSelected: (day) {
        onMonthlyDayChanged(int.parse(day));
      },
    );
  }

  String _translateWeekDay(String day, bool isArabic) {
    const arabicDays = {
      'Saturday': 'السبت',
      'Sunday': 'الأحد',
      'Monday': 'الاثنين',
      'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء',
      'Thursday': 'الخميس',
      'Friday': 'الجمعة',
    };

    const englishDays = {
      'السبت': 'Saturday',
      'الأحد': 'Sunday',
      'الاثنين': 'Monday',
      'الثلاثاء': 'Tuesday',
      'الأربعاء': 'Wednesday',
      'الخميس': 'Thursday',
      'الجمعة': 'Friday',
    };

    if (isArabic) {
      return arabicDays[day] ?? day;
    }

    return englishDays[day] ?? day;
  }
}
