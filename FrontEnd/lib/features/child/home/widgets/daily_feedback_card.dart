import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/daily_feedback_model.dart';

class DailyFeedbackCard extends StatelessWidget {
  final DailyFeedbackModel feedback;

  const DailyFeedbackCard({
    super.key,
    required this.feedback,
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

  String _label(BuildContext context) {
    switch (feedback.mood) {
      case 'HAPPY':
        return context.l10n.moodHappy;
      case 'PROUD':
        return context.l10n.moodProud;
      case 'GREAT':
        return context.l10n.moodGreat;
      case 'LOVE':
        return context.l10n.moodLoved;
      case 'STRONG':
        return context.l10n.moodStrong;
      case 'STAR':
        return context.l10n.moodStar;
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.childTodayEncouragement,
                  textAlign: TextAlign.start,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  _label(context),
                  textAlign: TextAlign.start,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.childFromFamily,
                  textAlign: TextAlign.start,
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