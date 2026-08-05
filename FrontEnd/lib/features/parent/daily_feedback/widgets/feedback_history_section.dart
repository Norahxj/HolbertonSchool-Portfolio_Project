import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../models/daily_feedback_model.dart';
import 'daily_feedback_mood.dart';

class FeedbackHistorySection extends StatelessWidget {
  final List<DailyFeedbackModel> feedbackHistory;
  final bool isArabic;

  const FeedbackHistorySection({
    super.key,
    required this.feedbackHistory,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    if (feedbackHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isArabic ? 'سجل التقييمات' : 'Feedback History',
          style: AppTextStyles.arabicTitle,
        ),

        const SizedBox(height: AppSpacing.md),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: feedbackHistory.length,
          separatorBuilder: (_, _) {
            return const SizedBox(height: AppSpacing.sm);
          },
          itemBuilder: (context, index) {
            final feedback = feedbackHistory[index];

            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    DailyFeedbackMood.emoji(feedback.mood),
                    style: const TextStyle(fontSize: 28),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: isArabic
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          DailyFeedbackMood.label(
                            mood: feedback.mood,
                            isArabic: isArabic,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        Text(
                          DailyFeedbackMood.formatDate(feedback.feedbackDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
