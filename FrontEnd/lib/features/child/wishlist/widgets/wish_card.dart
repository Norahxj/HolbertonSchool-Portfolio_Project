import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/wish_model.dart';

class WishCard extends StatelessWidget {
  final WishModel wish;
  final int currentPoints;
  final VoidCallback onDelete;
  final VoidCallback onAchieve;

  const WishCard({
    super.key,
    required this.wish,
    required this.currentPoints,
    required this.onDelete,
    required this.onAchieve,
  });

  String _statusLabel(BuildContext context) {
    switch (wish.status.toUpperCase()) {
      case 'APPROVED':
        return context.l10n.wishlistApprovedStatus;
      case 'REJECTED':
        return context.l10n.wishlistRejectedStatus;
      case 'ACHIEVED':
        return context.l10n.wishlistAchievedStatus;
      default:
        return context.l10n.wishlistPendingStatus;
    }
  }

  Color get _statusColor {
    switch (wish.status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.success;
      case 'REJECTED':
        return Colors.red;
      case 'ACHIEVED':
        return AppColors.gold;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = wish.status.toUpperCase();
    final target = wish.targetPoints;

    final hasProgress =
        status == 'APPROVED' && target != null && target > 0;

    final progressValue = hasProgress
        ? (currentPoints / target).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wish.name,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusLabel(context),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.star,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),

          if (hasProgress) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 8,
                backgroundColor: AppColors.primaryLight,
                valueColor: const AlwaysStoppedAnimation(
                  AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.wishlistTargetPoints(target),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  context.l10n.wishlistCurrentPoints(currentPoints),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          if (status == 'APPROVED') ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed:
                  target != null && currentPoints >= target
                      ? onAchieve
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                target == null
                    ? context.l10n.wishlistTargetNotSpecified
                    : currentPoints >= target
                        ? context.l10n.wishlistAchieveButton
                        : context.l10n.wishlistCollectMorePoints,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],

          if (status == 'PENDING' || status == 'REJECTED') ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
              label: Text(
                context.l10n.delete,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}