import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/task_assignment_model.dart';

class ParentChildTaskDetailsScreen extends StatelessWidget {
  final TaskAssignmentModel assignment;
  final IconData icon;

  const ParentChildTaskDetailsScreen({
    super.key,
    required this.assignment,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final task = assignment.task;
    final statusStyle = _statusStyle(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: AppBackButton(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primaryDark,
                      size: 56,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  task.title,
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 18,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      context.l10n.noorPointsCount(task.points),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC08A3E),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: statusStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusStyle.icon,
                          color: statusStyle.foregroundColor,
                          size: 16,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          statusStyle.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusStyle.foregroundColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: 0.06,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.taskDescription,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      Text(
                        task.description.trim().isEmpty
                            ? context.l10n.childTaskNoDescription
                            : task.description,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),

                          const SizedBox(width: 6),

                          Text(
                            _frequencyText(
                              context,
                              task.taskFrequency,
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _frequencyText(
    BuildContext context,
    String frequency,
  ) {
    switch (frequency.toUpperCase()) {
      case 'DAILY':
        return context.l10n.daily;

      case 'WEEKLY':
        return context.l10n.weekly;

      case 'MONTHLY':
        return context.l10n.monthly;

      case 'ONCE':
        return context.l10n.once;

      default:
        if (frequency.trim().isEmpty) {
          return context.l10n.notSpecified;
        }

        return frequency;
    }
  }

  _ParentTaskStatusStyle _statusStyle(
    BuildContext context,
  ) {
    final status = assignment.normalizedStatus;

    if (status == 'APPROVED') {
      return _ParentTaskStatusStyle(
        label: context.l10n.childTaskCompletedApproved,
        foregroundColor: AppColors.success,
        backgroundColor: const Color(0xFFE8F5EA),
        icon: Icons.check_circle_rounded,
      );
    }

    if (status == 'PENDING_REVIEW' || status == 'COMPLETED') {
      return _ParentTaskStatusStyle(
        label: context.l10n.childTaskWaitingGuardianReview,
        foregroundColor: const Color(0xFFC08A3E),
        backgroundColor: const Color(0xFFFFF4D6),
        icon: Icons.hourglass_top_rounded,
      );
    }

    if (status == 'REJECTED') {
      return _ParentTaskStatusStyle(
        label: context.l10n.rejected,
        foregroundColor: AppColors.error,
        backgroundColor: const Color(0xFFF9DEDE),
        icon: Icons.cancel_rounded,
      );
    }

    return _ParentTaskStatusStyle(
      label: context.l10n.childTaskReadyToComplete,
      foregroundColor: AppColors.primary,
      backgroundColor: AppColors.primaryLight,
      icon: Icons.task_alt_rounded,
    );
  }
}

class _ParentTaskStatusStyle {
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData icon;

  const _ParentTaskStatusStyle({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.icon,
  });
}