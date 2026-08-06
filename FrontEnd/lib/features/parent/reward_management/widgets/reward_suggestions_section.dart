import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/reward_suggestion_model.dart';

class RewardSuggestionsSection extends StatelessWidget {
  final List<RewardSuggestionModel> suggestions;

  final ValueChanged<RewardSuggestionModel> onSuggestionTap;

  const RewardSuggestionsSection({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: suggestions.isEmpty
          ? Text(
              context.l10n.noSuggestedRewards,
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
