import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../models/daily_feedback_model.dart';

class DailyFeedbackCard extends StatelessWidget {
  final DailyFeedbackModel feedback;
  final bool isArabic;

  const DailyFeedbackCard({
    super.key,
    required this.feedback,
    required this.isArabic,
  });

  String get _emoji {
    switch (feedback.mood) {
      case 'HAPPY':
        return '😊';
      case 'PROUD':
        return '🌟';
      case 'GREAT':
        return '🎉';
      case 'LOVE':
        return '❤️';
      case 'STRONG':
        return '💪';
      case 'STAR':
        return '⭐';
      default:
        return '🌟';
    }
  }

  String get _label {
    if (isArabic) {
      switch (feedback.mood) {
        case 'HAPPY':
          return 'سعيد';
        case 'PROUD':
          return 'فخور بك';
        case 'GREAT':
          return 'رائع';
        case 'LOVE':
          return 'محبوب';
        case 'STRONG':
          return 'قوي';
        case 'STAR':
          return 'نجم';
        default:
          return feedback.mood;
      }
    }

    switch (feedback.mood) {
      case 'HAPPY':
        return 'Happy';
      case 'PROUD':
        return 'Proud of you';
      case 'GREAT':
        return 'Great';
      case 'LOVE':
        return 'Loved';
      case 'STRONG':
        return 'Strong';
      case 'STAR':
        return 'Star';
      default:
        return feedback.mood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _emoji,
              style: const TextStyle(fontSize: 28),
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
                  isArabic
                      ? 'تشجيع اليوم'
                      : 'Today\'s Encouragement',
                  textAlign: isArabic
                      ? TextAlign.right
                      : TextAlign.left,
                  style: AppTextStyles.caption,
                ),

                const SizedBox(height: 4),

                Text(
                  _label,
                  textAlign: isArabic
                      ? TextAlign.right
                      : TextAlign.left,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  isArabic
                      ? 'من العائلة'
                      : 'From your family',
                  textAlign: isArabic
                      ? TextAlign.right
                      : TextAlign.left,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}