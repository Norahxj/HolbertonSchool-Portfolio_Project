import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../models/task_suggestion_model.dart';

class QuickAddCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<TaskSuggestionModel> suggestions;
  final ValueChanged<TaskSuggestionModel> onSuggestionTap;
  final bool isArabic;

  const QuickAddCategory({
    super.key,
    required this.icon,
    required this.label,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: isArabic
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, color: AppColors.primaryDark, size: 18),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: suggestions.isEmpty
              ? Text(
                  isArabic
                      ? 'لا توجد مهام مقترحة حاليًا'
                      : 'No suggested tasks available right now',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              : Column(
                  children: [
                    for (int i = 0; i < suggestions.length; i++) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          onSuggestionTap(suggestions[i]);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.add_circle_outline,
                                size: 18,
                                color: AppColors.primary,
                              ),

                              const SizedBox(width: AppSpacing.sm),

                              Expanded(
                                child: Text(
                                  suggestions[i].title,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (i != suggestions.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
