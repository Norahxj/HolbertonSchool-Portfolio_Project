import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../models/points_history_model.dart';

class PointsHistoryCard extends StatelessWidget {
  final PointsHistoryModel item;
  final bool isArabic;

  const PointsHistoryCard({
    super.key,
    required this.item,
    required this.isArabic,
  });

  bool get isAdded => item.points >= 0;

  String get title {
    if (item.taskAssignment != null) {
      final taskTitle = item.taskAssignment!.task.title;

      return isArabic ? 'إكمال مهمة: $taskTitle' : 'Task completed: $taskTitle';
    }

    if (item.wishlist != null) {
      final wishName = item.wishlist!.name;

      return isArabic ? 'تحقيق أمنية: $wishName' : 'Wish achieved: $wishName';
    }

    return isArabic ? 'تحديث في النقاط' : 'Points update';
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
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
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
