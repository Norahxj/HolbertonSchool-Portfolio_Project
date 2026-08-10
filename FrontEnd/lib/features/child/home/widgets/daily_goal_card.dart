import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class DailyGoalCard extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final bool isArabic;

  const DailyGoalCard({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.isArabic,
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
      message = isArabic
          ? 'لا توجد مهام اليوم، استمتع بيومك!'
          : 'There are no tasks today. Enjoy your day!';
    } else if (remainingTasks == 0) {
      message = isArabic
          ? 'رائع! أنجزت جميع مهام اليوم 🎉'
          : 'Great! You completed all of today\'s tasks 🎉';
    } else if (remainingTasks == 1) {
      message = isArabic
          ? 'بقيت لك مهمة واحدة لإكمال هدف اليوم!'
          : 'You have one task left to complete today\'s goal!';
    } else {
      message = isArabic
          ? 'بقيت لك $remainingTasks مهام لإكمال هدف اليوم'
          : 'You have $remainingTasks tasks left to complete today\'s goal';
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
            textDirection: isArabic
                ? TextDirection.rtl
                : TextDirection.ltr,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                textDirection: isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
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
                    isArabic
                        ? 'هدف اليوم'
                        : 'Today\'s Goal',
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
            alignment: isArabic
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Text(
              message,
              textAlign: isArabic
                  ? TextAlign.right
                  : TextAlign.left,
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