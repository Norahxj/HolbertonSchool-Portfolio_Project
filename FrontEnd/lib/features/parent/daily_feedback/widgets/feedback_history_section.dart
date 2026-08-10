import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/daily_feedback_model.dart';
import 'daily_feedback_mood.dart';

class FeedbackHistorySection extends StatelessWidget {
  final List<DailyFeedbackModel> feedbackHistory;

  const FeedbackHistorySection({
    super.key,
    required this.feedbackHistory,
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
          context.l10n.feedbackHistory,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DailyFeedbackMood.label(
                            context: context,
                            mood: feedback.mood,
                          ),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          DailyFeedbackMood.formatDate(
                            feedback.feedbackDate,
                          ),
                          textAlign: TextAlign.start,
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