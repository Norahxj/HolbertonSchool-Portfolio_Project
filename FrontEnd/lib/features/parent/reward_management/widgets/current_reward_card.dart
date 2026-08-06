import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/reward_model.dart';

class CurrentRewardCard extends StatelessWidget {
  final RewardModel reward;
  final bool isDeleting;
  final VoidCallback? onDelete;

  const CurrentRewardCard({
    super.key,
    required this.reward,
    required this.isDeleting,
    required this.onDelete,
  });

  String _statusLabel(BuildContext context) {
    final l10n = context.l10n;

    switch (reward.status.trim().toUpperCase()) {
      case 'UNLOCKED':
        return l10n.rewardStatusUnlocked;

      case 'CLAIMED':
        return l10n.rewardStatusClaimed;

      default:
        return l10n.rewardStatusLocked;
    }
  }

  IconData get _statusIcon {
    switch (reward.status.trim().toUpperCase()) {
      case 'UNLOCKED':
        return Icons.lock_open_outlined;

      case 'CLAIMED':
        return Icons.check_circle_outline;

      default:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.card_giftcard_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.rewardName,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (reward.description?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    reward.description!,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon, size: 17, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      _statusLabel(context),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  context.l10n.rewardUnlockDay(reward.unlockDayLabel),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: isDeleting ? null : onDelete,
              tooltip: context.l10n.delete,
              icon: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : const Icon(Icons.delete_outline, color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}
