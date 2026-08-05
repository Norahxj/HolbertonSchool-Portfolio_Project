import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../models/reward_suggestion_model.dart';

class RewardSuggestionsSection  extends StatelessWidget {
  final List<RewardSuggestionModel> suggestions;
  final bool isArabic;

  final ValueChanged<RewardSuggestionModel> onSuggestionTap;

  const RewardSuggestionsSection ({
    super.key,
    required this.suggestions,
    required this.isArabic,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: suggestions.isEmpty
          ? Text(
              isArabic
                  ? 'لا توجد مكافآت مقترحة حاليًا'
                  : 'No suggested rewards available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              children: [
                for (int index = 0; index < suggestions.length; index++) ...[
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      onSuggestionTap(suggestions[index]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        textDirection: isArabic
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 19,
                            color: AppColors.primary,
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestions[index].rewardName,
                                  textAlign: TextAlign.start,
                                  textDirection: isArabic
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),

                                if (suggestions[index]
                                    .description
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 3),

                                  Text(
                                    suggestions[index].description,
                                    textAlign: TextAlign.start,
                                    textDirection: isArabic
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (index != suggestions.length - 1)
                    const Divider(height: 1, color: AppColors.border),
                ],
              ],
            ),
    );
  }
}
