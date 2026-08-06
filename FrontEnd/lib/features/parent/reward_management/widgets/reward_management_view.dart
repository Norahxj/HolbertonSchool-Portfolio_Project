import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../controllers/reward_management_controller.dart';
import '../utils/reward_management_localization.dart';
import 'add_reward_button.dart';
import 'current_reward_card.dart';
import 'reward_child_selector_card.dart';
import 'reward_states.dart';
import 'reward_suggestions_section.dart';

class RewardManagementView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  final Future<void> Function({RewardSuggestionModel? suggestion}) onAddReward;

  final Future<void> Function(RewardModel reward) onDeleteReward;

  const RewardManagementView({
    super.key,
    required this.onRefresh,
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
            onRefresh: onRefresh,
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
                  _ChildrenSelectorSection(controller: controller),
                  const SizedBox(height: AppSpacing.lg),
                  if (controller.selectedChildId != null) ...[
                    _CurrentRewardsSection(
                      controller: controller,
                      onDeleteReward: onDeleteReward,
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
                  _SuggestionsSection(
                    controller: controller,
                    onAddReward: onAddReward,
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

class _ChildrenSelectorSection extends StatelessWidget {
  final RewardManagementController controller;

  const _ChildrenSelectorSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingChildren) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.childrenError != null) {
      return RewardErrorMessage(
        message:
            controller.childrenBackendMessage ??
            controller.childrenError!.localized(context),
        onRetry: controller.loadChildren,
      );
    }

    if (controller.children.isEmpty) {
      return RewardEmptyMessage(message: context.l10n.noChildrenAddFirst);
    }

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final child in controller.children)
          RewardChildSelectorCard(
            name: child.name,
            avatarIndex: child.avatarIndex,
            isSelected: controller.selectedChildId == child.id,
            onTap: () {
              controller.selectChild(child.id);
            },
          ),
      ],
    );
  }
}

class _CurrentRewardsSection extends StatelessWidget {
  final RewardManagementController controller;
  final Future<void> Function(RewardModel reward) onDeleteReward;

  const _CurrentRewardsSection({
    required this.controller,
    required this.onDeleteReward,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            context.l10n.currentChildRewards,
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
          RewardEmptyMessage(message: context.l10n.noRewardsForChild)
        else
          for (final reward in controller.currentRewards)
            CurrentRewardCard(
              reward: reward,
              isDeleting: controller.isDeletingReward(reward.id),
              onDelete: reward.status.toUpperCase() == 'CLAIMED'
                  ? null
                  : () {
                      onDeleteReward(reward);
                    },
            ),
      ],
    );
  }
}

class _SuggestionsSection extends StatelessWidget {
  final RewardManagementController controller;

  final Future<void> Function({RewardSuggestionModel? suggestion}) onAddReward;

  const _SuggestionsSection({
    required this.controller,
    required this.onAddReward,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.selectedChildId == null) {
      return RewardEmptyMessage(
        message: context.l10n.selectChildForSuggestions,
      );
    }

    if (controller.isLoadingSuggestions) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.suggestionsError != null) {
      final languageCode = Localizations.localeOf(context).languageCode;

      return RewardErrorMessage(
        message:
            controller.suggestionsBackendMessage ??
            controller.suggestionsError!.localized(context),
        onRetry: () {
          return controller.loadRewardSuggestions(languageCode: languageCode);
        },
      );
    }

    return RewardSuggestionsSection(
      suggestions: controller.rewardSuggestions,
      onSuggestionTap: (suggestion) {
        onAddReward(suggestion: suggestion);
      },
    );
  }
}
