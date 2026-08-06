import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../../add_task/widgets/child_card.dart';
import '../controllers/reward_management_controller.dart';
import '../utils/reward_management_localization.dart';
import 'add_reward_button.dart';
import 'current_reward_card.dart';
import 'reward_states.dart';
import 'reward_suggestions_section.dart';

class RewardManagementView extends StatelessWidget {
  final Future<void> Function({RewardSuggestionModel? suggestion}) onAddReward;

  final Future<void> Function(RewardModel reward) onDeleteReward;

  const RewardManagementView({
    super.key,
    required this.onAddReward,
    required this.onDeleteReward,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RewardManagementController>();

    final l10n = context.l10n;

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
                    l10n.rewardManagement,
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    l10n.rewardManagementSubtitle,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (controller.isLoadingChildren)
                    const Center(child: CircularProgressIndicator())
                  else if (controller.childrenError != null)
                    RewardErrorMessage(
                      message:
                          controller.childrenBackendMessage ??
                          controller.childrenError!.localized(context),
                      onRetry: controller.loadChildren,
                    )
                  else if (controller.children.isEmpty)
                    RewardEmptyMessage(message: l10n.noChildrenAddFirst)
                  else
                    Wrap(
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

                  const SizedBox(height: AppSpacing.lg),

                  if (controller.selectedChildId != null) ...[
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        l10n.currentChildRewards,
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
                        message:
                            controller.rewardsBackendMessage ??
                            controller.rewardsError!.localized(context),
                        onRetry: controller.loadCurrentRewards,
                      )
                    else if (controller.currentRewards.isEmpty)
                      RewardEmptyMessage(message: l10n.noRewardsForChild)
                    else
                      Column(
                        children: controller.currentRewards.map((reward) {
                          final isClaimed =
                              reward.status.toUpperCase() == 'CLAIMED';

                          return CurrentRewardCard(
                            reward: reward,
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
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.quickAdd,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  if (controller.selectedChildId == null)
                    RewardEmptyMessage(message: l10n.selectChildForSuggestions)
                  else if (controller.isLoadingSuggestions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (controller.suggestionsError != null)
                    RewardErrorMessage(
                      message:
                          controller.suggestionsBackendMessage ??
                          controller.suggestionsError!.localized(context),
                      onRetry: controller.loadRewardSuggestions,
                    )
                  else
                    RewardSuggestionsSection(
                      suggestions: controller.rewardSuggestions,
                      onSuggestionTap: (suggestion) {
                        onAddReward(suggestion: suggestion);
                      },
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  AddRewardButton(
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
