import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/reward_model.dart';
import '../../../models/reward_suggestion_model.dart';
import '../widgets/child_card.dart';
import 'add_reward_screen.dart';
import '../reward_management/widgets/reward_states.dart';
import '../reward_management/widgets/current_reward_card.dart';
import '../reward_management/widgets/reward_suggestions_section.dart';
import '../reward_management/widgets/add_reward_button.dart';
import 'package:provider/provider.dart';
import '../reward_management/controllers/reward_management_controller.dart';

class RewardManagementScreen extends StatefulWidget {
  final bool isArabic;
  final int childrenVersion;

  const RewardManagementScreen({
    super.key,
    required this.isArabic,
    this.childrenVersion = 0,
  });

  @override
  State<RewardManagementScreen> createState() => _RewardManagementScreenState();
}
class _RewardManagementScreenState extends State<RewardManagementScreen> {
  bool get isArabic => widget.isArabic;
  late final RewardManagementController _controller;

  @override
  void initState() {
    super.initState();

    _controller = RewardManagementController(isArabic: widget.isArabic)
      ..initialize();
  }

  @override
  void didUpdateWidget(covariant RewardManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childrenVersion != widget.childrenVersion) {
      _controller.loadChildren();
    }

    if (oldWidget.isArabic != widget.isArabic) {
      _controller.updateLanguage(widget.isArabic);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAddReward({RewardSuggestionModel? suggestion}) async {
    final childId = _controller.selectedChildId;

    if (childId == null) return;

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRewardScreen(
          childId: childId,
          isArabic: isArabic,
          suggestion: suggestion,
        ),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      await _controller.loadCurrentRewards();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic
                ? 'تمت إضافة المكافأة بنجاح 🎉'
                : 'Reward added successfully 🎉',
          ),
        ),
      );
    }
  }

  Future<void> _deleteReward(RewardModel reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isArabic ? 'حذف المكافأة' : 'Delete Reward',
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
          content: Text(
            isArabic
                ? 'هل تريد حذف مكافأة "${reward.rewardName}"؟'
                : 'Do you want to delete the reward "${reward.rewardName}"?',
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                isArabic ? 'حذف' : 'Delete',
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final errorMessage = await _controller.deleteReward(reward);

    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم حذف المكافأة' : 'Reward deleted'),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Builder(
        builder: (context) {
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
                                  isSelected:
                                      controller.selectedChildId == child.id,
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
                                  isDeleting: controller.isDeletingReward(
                                    reward.id,
                                  ),
                                  onDelete: isClaimed
                                      ? null
                                      : () {
                                          _deleteReward(reward);
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
                              _openAddReward(suggestion: suggestion);
                            },
                          ),

                        const SizedBox(height: AppSpacing.xl),

                        AddRewardButton(
                          isArabic: isArabic,
                          enabled: controller.selectedChildId != null,
                          onTap: () {
                            _openAddReward();
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
        },
      ),
    );
  }
}
