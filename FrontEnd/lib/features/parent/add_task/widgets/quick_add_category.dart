import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/task_suggestion_model.dart';

class QuickAddCategory extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<TaskSuggestionModel> suggestions;
  final ValueChanged<TaskSuggestionModel> onSuggestionTap;

  const QuickAddCategory({
    super.key,
    required this.icon,
    required this.label,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppColors.primaryDark,
              size: 18,
            ),

            const SizedBox(width: AppSpacing.sm),

            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.border,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: suggestions.isEmpty
              ? Text(
                  l10n.noSuggestions,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              : Column(
                  children: [
                    for (
                      int index = 0;
                      index < suggestions.length;
                      index++
                    ) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          onSuggestionTap(
                            suggestions[index],
                          );
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

                              const SizedBox(
                                width: AppSpacing.sm,
                              ),

                              Expanded(
                                child: Text(
                                  suggestions[index].title,
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

                      if (index != suggestions.length - 1)
                        const Divider(
                          height: 1,
                          color: AppColors.border,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}