import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../models/daily_feedback_model.dart';
import 'mood_option_card.dart';

class TodayFeedbackCard extends StatelessWidget {
  final String childName;
  final bool isArabic;
  final DailyFeedbackModel? todayFeedback;
  final String? selectedMood;
  final bool isSubmitting;
  final ValueChanged<String> onMoodSelected;
  final Future<void> Function() onSubmit;

  const TodayFeedbackCard({
    super.key,
    required this.childName,
    required this.isArabic,
    required this.todayFeedback,
    required this.selectedMood,
    required this.isSubmitting,
    required this.onMoodSelected,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            todayFeedback != null
                ? (isArabic
                      ? 'تقييم اليوم (يمكنك التعديل)'
                      : 'Today\'s Feedback (You Can Edit It)')
                : (isArabic
                      ? 'كيف كان يوم $childName؟'
                      : 'How was $childName\'s day?'),
            style: AppTextStyles.arabicTitle,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: kMoodValues.map((mood) {
              return MoodOptionCard(
                mood: mood,
                isArabic: isArabic,
                isSelected: selectedMood == mood,
                onTap: () {
                  onMoodSelected(mood);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),

          ElevatedButton(
            onPressed: selectedMood != null && !isSubmitting ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    todayFeedback != null
                        ? (isArabic ? 'تحديث التقييم' : 'Update Feedback')
                        : (isArabic ? 'حفظ التقييم' : 'Save Feedback'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
