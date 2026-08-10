import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/child_rewards_controller.dart';
import 'child_reward_card.dart';

class ChildRewardsView extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetry;
  final Future<void> Function(String rewardId) onClaim;

  const ChildRewardsView({
    super.key,
    required this.onRefresh,
    required this.onRetry,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<ChildRewardsController>();

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (controller.hasError) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.childRewardsLoadFailed,
                    style: const TextStyle(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: Text(
                      context.l10n.retry,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final rewards = controller.rewards;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.childNavigationRewards,
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    context.l10n.childRewardsSubtitle,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (rewards.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(
                        AppSpacing.xl,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.l10n.childRewardsEmpty,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: rewards.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(
                            height: AppSpacing.md,
                          ),
                      itemBuilder: (context, index) {
                        final reward = rewards[index];

                        return ChildRewardCard(
                          reward: reward,
                          onClaim:
                              reward.status.toLowerCase() ==
                                      'unlocked'
                                  ? () => onClaim(reward.id)
                                  : null,
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}