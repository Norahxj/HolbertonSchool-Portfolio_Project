import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/reward_model.dart';

class ChildRewardCard extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback? onClaim;

  const ChildRewardCard({
    super.key,
    required this.reward,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final status = reward.status.toLowerCase();

    final isUnlocked = status == 'unlocked';
    final isClaimed = status == 'claimed';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.primaryGradient,
              )
            : null,
        color: isUnlocked ? null : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.card_giftcard_outlined,
              color: isUnlocked
                  ? Colors.white
                  : AppColors.primaryDark,
              size: 22,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  reward.rewardName,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),

                if (reward.description != null &&
                    reward.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),

                  Text(
                    reward.description!,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUnlocked
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 4),

                Text(
                  _statusLabel(context),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked
                        ? Colors.white70
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          if (isUnlocked)
            ElevatedButton(
              onPressed: onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: Text(
                context.l10n.childRewardClaim,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),

          if (isClaimed)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                context.l10n.childRewardClaimedBadge,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.gold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context) {
    switch (reward.status.toLowerCase()) {
      case 'unlocked':
        return context.l10n.childRewardAvailableNow;

      case 'claimed':
        return context.l10n.childRewardClaimedStatus;

      default:
        return context.l10n.childRewardUnlocksOn(
          _unlockDayLabel(context),
        );
    }
  }

  String _unlockDayLabel(BuildContext context) {
    switch (reward.unlockDay) {
      case 0:
        return context.l10n.sunday;
      case 1:
        return context.l10n.monday;
      case 2:
        return context.l10n.tuesday;
      case 3:
        return context.l10n.wednesday;
      case 4:
        return context.l10n.thursday;
      case 5:
        return context.l10n.friday;
      case 6:
        return context.l10n.saturday;
      default:
        return context.l10n.notSpecified;
    }
  }
}