import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'wish_components.dart';

class AchievedWishCard extends StatelessWidget {
  final String childName;
  final int avatarIndex;
  final String wishTitle;
  final int points;
  final bool isArabic;

  const AchievedWishCard({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.wishTitle,
    required this.points,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8C6FF)),
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
                label: isArabic ? 'تم تحقيقها' : 'Achieved',
                backgroundColor: AppColors.primaryDark,
                textColor: Colors.white,
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  isArabic
                      ? 'تم تحقيق هذه الأمنية بنجاح 🎉'
                      : 'This wish was achieved successfully 🎉',
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
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEADFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.primaryDark,
                    size: 21,
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                Expanded(
                  child: Text(
                    isArabic
                        ? 'أكمل الطفل هدف نقاط نور'
                        : 'The child completed the Noor Points goal',
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                if (points > 0) ...[
                  const SizedBox(width: AppSpacing.sm),

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
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
