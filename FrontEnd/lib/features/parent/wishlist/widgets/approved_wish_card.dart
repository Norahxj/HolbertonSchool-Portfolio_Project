import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'wish_components.dart';

class ApprovedWishCard extends StatelessWidget {
  final String childName;
  final int avatarIndex;
  final String wishTitle;
  final String subtitle;
  final int points;
  final bool isArabic;

  const ApprovedWishCard({
    super.key,
    required this.childName,
    required this.isArabic,
    required this.avatarIndex,
    required this.wishTitle,
    required this.subtitle,
    required this.points,
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
          WishHeader(
            childName: childName,
            wishTitle: wishTitle,
            avatarIndex: avatarIndex,
            isArabic: isArabic,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              StatusTag(
                label: isArabic ? 'هدف معتمد' : 'Goal Created',
                backgroundColor: AppColors.primaryLight,
                textColor: AppColors.primaryDark,
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  subtitle,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Expanded(
                  child: Text(
                    isArabic ? 'هدف النقاط المحدد' : 'Selected Points Goal',
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 16,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      '$points',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
