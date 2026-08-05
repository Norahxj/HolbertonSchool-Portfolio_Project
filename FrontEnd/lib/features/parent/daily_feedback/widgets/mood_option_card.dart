import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'daily_feedback_mood.dart';

class MoodOptionCard extends StatelessWidget {
  final String mood;
  final bool isArabic;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodOptionCard({
    super.key,
    required this.mood,
    required this.isArabic,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DailyFeedbackMood.emoji(mood),
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              DailyFeedbackMood.label(mood: mood, isArabic: isArabic),
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
