import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';

class DailyGoalCard extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const DailyGoalCard({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalTasks == 0
        ? 0.0
        : (completedTasks / totalTasks).clamp(0.0, 1.0).toDouble();

    final remainingTasks = (totalTasks - completedTasks)
        .clamp(0, totalTasks)
        .toInt();

    String message;

    if (totalTasks == 0) {
      message = context.l10n.childNoTasksGoalMessage;
    } else if (remainingTasks == 0) {
      message = context.l10n.childAllTasksCompletedMessage;
    } else if (remainingTasks == 1) {
      message = context.l10n.childOneTaskRemainingMessage;
    } else {
      message = context.l10n.childTasksRemainingMessage(
        remainingTasks,
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.goldLight,
            Color(0xFFFFF9E7),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: AppColors.orange,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  Text(
                    context.l10n.childTodayGoal,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                '$completedTasks/$totalTasks',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: AppTextStyles.caption,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation(
                AppColors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}