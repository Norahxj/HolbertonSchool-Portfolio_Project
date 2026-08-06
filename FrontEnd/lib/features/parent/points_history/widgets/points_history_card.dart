import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/points_history_model.dart';

class PointsHistoryCard extends StatelessWidget {
  final PointsHistoryModel item;

  const PointsHistoryCard({super.key, required this.item});

  bool get isAdded => item.points >= 0;

  String _title(BuildContext context) {
    final l10n = context.l10n;

    if (item.taskAssignment != null) {
      final taskTitle = item.taskAssignment!.task.title;

      return l10n.taskCompletedPointsHistory(taskTitle);
    }

    if (item.wishlist != null) {
      final wishName = item.wishlist!.name;

      return l10n.wishAchievedPointsHistory(wishName);
    }

    return l10n.pointsUpdate;
  }

  String get formattedDate {
    final date = item.createdAt.toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isAdded ? AppColors.primaryLight : AppColors.goldLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isAdded ? Icons.add_circle_outline : Icons.card_giftcard,
              color: isAdded ? AppColors.primary : AppColors.gold,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(context),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  formattedDate,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Text(
            '${isAdded ? '+' : ''}${item.points}',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isAdded ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
