import 'package:flutter/material.dart';
import '../../../../core/widgets/child_avatar.dart';
import '../models/review_task.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class PendingHeader extends StatelessWidget {
  final int count;
  final bool isArabic;

  const PendingHeader({super.key, required this.count, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isArabic ? 'بانتظار المراجعة' : 'Pending review',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isArabic ? '$count مهام' : '$count tasks',
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class ReviewTaskCard extends StatelessWidget {
  final ReviewTask item;
  final bool isArabic;
  final String timeText;

  final bool isUpdating;
  final bool isApproving;
  final bool isRetrying;

  final VoidCallback onApprove;
  final VoidCallback onRetry;

  const ReviewTaskCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.timeText,
    required this.isUpdating,
    required this.isApproving,
    required this.isRetrying,
    required this.onApprove,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ChildAvatar(avatarIndex: item.child.avatarIndex, size: 42),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.child.name,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item.assignment.task.title,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      timeText,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 14,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      '${item.assignment.task.points}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUpdating ? null : onApprove,
                  icon: isApproving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(isArabic ? 'مقبولة' : 'Accepted'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryLight,
                    disabledForegroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isUpdating ? null : onRetry,
                  icon: isRetrying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  label: Text(
                    isArabic ? 'إعادة المحاولة' : 'Try Again',
                    textAlign: TextAlign.center,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyCard extends StatelessWidget {
  final bool isArabic;

  const EmptyCard({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: AppColors.primary,
            size: 42,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            isArabic
                ? 'لا توجد مهام بانتظار المراجعة'
                : 'No tasks are pending review',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class TaskReviewErrorCard extends StatelessWidget {
  final String message;
  final bool isArabic;
  final Future<void> Function() onRetry;

  const TaskReviewErrorCard({
    super.key,
    required this.message,
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),

          const SizedBox(height: AppSpacing.sm),

          TextButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
          ),
        ],
      ),
    );
  }
}
