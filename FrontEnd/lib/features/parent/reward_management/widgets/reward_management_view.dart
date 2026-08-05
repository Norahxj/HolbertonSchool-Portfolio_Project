import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../../widgets/child_card.dart';
import '../controllers/reward_management_controller.dart';
import 'add_reward_button.dart';
import 'current_reward_card.dart';
import 'reward_states.dart';
import 'reward_suggestions_section.dart';

class RewardManagementView extends StatelessWidget {
  final bool isArabic;

  final Future<void> Function({RewardSuggestionModel? suggestion}) onAddReward;

  final Future<void> Function(RewardModel reward) onDeleteReward;

  const RewardManagementView({
    super.key,
    required this.isArabic,
    required this.onAddReward,
    required this.onDeleteReward,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RewardManagementController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: controller.loadChildren,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isArabic ? 'إدارة المكافآت' : 'Reward Management',
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    isArabic
                        ? 'مكافآت أسبوعية تُمنح حسب أداء الطفل'
                        : 'Weekly rewards based on the child’s performance',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (controller.isLoadingChildren)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.childrenError != null)
                    RewardErrorMessage(
                      message: controller.childrenError!,
                      onRetry: controller.loadChildren,
                    )
                  else if (controller.children.isEmpty)
                    RewardEmptyMessage(
                      message: isArabic
                          ? 'لا يوجد أطفال بعد. أضف طفلًا أولًا.'
                          : 'No children yet. Add a child first.',
                    )
                  else
                    Directionality(
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: controller.children.map((child) {
                          return ChildCard(
                            name: child.name,
                            avatarIndex: child.avatarIndex,
                            isSelected: controller.selectedChildId == child.id,
                            onTap: () {
                              controller.selectChild(child.id);
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  if (controller.selectedChildId != null) ...[
                    Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        isArabic
                            ? 'مكافآت الطفل الحالية'
                            : 'Current Child Rewards',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    if (controller.isLoadingRewards)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (controller.rewardsError != null)
                      RewardErrorMessage(
                        message: controller.rewardsError!,
                        onRetry: controller.loadCurrentRewards,
                      )
                    else if (controller.currentRewards.isEmpty)
                      RewardEmptyMessage(
                        message: isArabic
                            ? 'لا توجد مكافآت لهذا الطفل حتى الآن'
                            : 'This child has no rewards yet',
                      )
                    else
                      Column(
                        children: controller.currentRewards.map((reward) {
                          final isClaimed =
                              reward.status.toUpperCase() == 'CLAIMED';

                          return CurrentRewardCard(
                            reward: reward,
                            isArabic: isArabic,
                            isDeleting: controller.isDeletingReward(reward.id),
                            onDelete: isClaimed
                                ? null
                                : () {
                                    onDeleteReward(reward);
                                  },
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: AppSpacing.lg),
                  ],

                  Align(
                    alignment: isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      isArabic ? 'إضافة سريعة' : 'Quick Add',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  if (controller.selectedChildId == null)
                    RewardEmptyMessage(
                      message: isArabic
                          ? 'اختر طفلًا أولًا لعرض المكافآت المقترحة'
                          : 'Select a child first to view suggested rewards',
                    )
                  else if (controller.isLoadingSuggestions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (controller.suggestionsError != null)
                    RewardErrorMessage(
                      message: controller.suggestionsError!,
                      onRetry: controller.loadRewardSuggestions,
                    )
                  else
                    RewardSuggestionsSection(
                      suggestions: controller.rewardSuggestions,
                      isArabic: isArabic,
                      onSuggestionTap: (suggestion) {
                        onAddReward(suggestion: suggestion);
                      },
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  AddRewardButton(
                    isArabic: isArabic,
                    enabled: controller.selectedChildId != null,
                    onTap: () {
                      onAddReward();
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
