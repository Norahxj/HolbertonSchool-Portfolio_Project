import 'package:flutter/material.dart';
import '../../../../models/task_assignment_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../models/parent_child_tasks_data.dart';
import '../../../child/screens/child_task_details_screen.dart';

class UpcomingTaskCard extends StatelessWidget {
  final UpcomingTaskItem item;
  final bool isArabic;
  final bool canDelete;
  final Future<void> Function() onDelete;

  const UpcomingTaskCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.canDelete,
    required this.onDelete,
  });
  String get _frequencyLabel {
    final frequency = item.task.taskFrequency.toUpperCase();

    if (frequency == 'WEEKLY') {
      return isArabic ? 'أسبوعية' : 'Weekly';
    }

    return isArabic ? 'شهرية' : 'Monthly';
  }

  String get _formattedDate {
    final date = item.nextDate;

    final arabicWeekdays = [
      '',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final englishWeekdays = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final arabicMonths = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    final englishMonths = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final weekday = isArabic
        ? arabicWeekdays[date.weekday]
        : englishWeekdays[date.weekday];

    final month = isArabic
        ? arabicMonths[date.month]
        : englishMonths[date.month];

    final separator = isArabic ? '،' : ',';

    return '$weekday$separator ${date.day} $month ${date.year}';
  }

  TaskAssignmentModel get _displayAssignment {
    return TaskAssignmentModel(
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
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChildTaskDetailsScreen(
                assignment: _displayAssignment,
                icon: Icons.event_available_outlined,
                isArabic: isArabic,
                parentView: true,
              ),
            ),
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.32),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  color: AppColors.primaryDark,
                  size: 21,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.task.title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isArabic ? 'قادمة' : 'Upcoming',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),

                        Text(
                          _frequencyLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      isArabic
                          ? 'الموعد القادم: $_formattedDate'
                          : 'Next date: $_formattedDate',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),
              if (canDelete) ...[
                IconButton(
                  onPressed: onDelete,
                  tooltip: isArabic ? 'حذف المهمة' : 'Delete task',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                    size: 21,
                  ),
                ),

                const SizedBox(width: 2),
              ],

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.task.points}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
