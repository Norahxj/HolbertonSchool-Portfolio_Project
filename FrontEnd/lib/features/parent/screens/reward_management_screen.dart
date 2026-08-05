import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/child_model.dart';
import '../../../models/reward_model.dart';
import '../../../models/reward_suggestion_model.dart';
import '../../../services/reward_api_service.dart';
import '../services/child_api_service.dart';
import '../widgets/child_card.dart';
import 'add_reward_screen.dart';

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
  final ChildApiService _childApiService = ChildApiService();

  final RewardApiService _rewardApiService = RewardApiService();

  List<ChildModel> children = [];
  List<RewardModel> currentRewards = [];

  List<RewardSuggestionModel> rewardSuggestions = [];

  String? selectedChildId;

  bool isLoadingChildren = true;
  bool isLoadingRewards = false;
  bool isLoadingSuggestions = false;

  String? childrenError;
  String? rewardsError;
  String? suggestionsError;

  final Set<String> deletingRewardIds = {};

  @override
  void initState() {
    super.initState();

    Future.wait([_loadChildren(), _loadRewardSuggestions()]);
  }

  @override
  void didUpdateWidget(covariant RewardManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childrenVersion != widget.childrenVersion) {
      _loadChildren();
    }

    if (oldWidget.isArabic != widget.isArabic) {
      rewardSuggestions = [];

      if (selectedChildId != null) {
        _loadRewardSuggestions();
      }
    }
  }

  Future<void> _loadChildren() async {
    setState(() {
      isLoadingChildren = true;
      childrenError = null;
    });

    try {
      final data = await _childApiService.getChildren();

      if (!mounted) return;

      setState(() {
        children = data;
        isLoadingChildren = false;

        if (data.isNotEmpty && selectedChildId == null) {
          selectedChildId = data.first.id;
        }
      });

      if (selectedChildId != null) {
        await _loadSelectedChildData();
      }
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        childrenError =
            _readBackendMessage(error) ??
            (isArabic ? 'تعذّر تحميل الأطفال' : 'Failed to load children');

        isLoadingChildren = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        childrenError = isArabic
            ? 'تعذّر تحميل الأطفال'
            : 'Failed to load children';

        isLoadingChildren = false;
      });
    }
  }

  Future<void> _loadSelectedChildData() async {
    await _loadCurrentRewards();
  }

  Future<void> _selectChild(String childId) async {
    if (selectedChildId == childId) {
      return;
    }

    setState(() {
      selectedChildId = childId;
      currentRewards = [];
    });

    await _loadSelectedChildData();
  }

  Future<void> _loadCurrentRewards() async {
    final childId = selectedChildId;

    if (childId == null) return;

    setState(() {
      isLoadingRewards = true;
      rewardsError = null;
    });

    try {
      final rewards = await _rewardApiService.getRewardsForChild(childId);

      if (!mounted || selectedChildId != childId) {
        return;
      }

      setState(() {
        currentRewards = rewards;
      });
    } on DioException catch (error) {
      if (!mounted || selectedChildId != childId) {
        return;
      }

      setState(() {
        rewardsError =
            _readBackendMessage(error) ??
            (isArabic
                ? 'تعذّر تحميل مكافآت الطفل'
                : 'Failed to load child rewards');
      });
    } finally {
      if (mounted && selectedChildId == childId) {
        setState(() {
          isLoadingRewards = false;
        });
      }
    }
  }

  Future<void> _loadRewardSuggestions() async {
    setState(() {
      isLoadingSuggestions = true;
      suggestionsError = null;
    });

    try {
      final suggestions = await _rewardApiService.getRewardSuggestions(
        lang: isArabic ? 'ar' : 'en',
        count: 5,
      );

      if (!mounted) return;

      setState(() {
        rewardSuggestions = suggestions;
      });
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        suggestionsError =
            _readBackendMessage(error) ??
            (isArabic
                ? 'تعذّر تحميل المكافآت المقترحة'
                : 'Failed to load suggested rewards');
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingSuggestions = false;
        });
      }
    }
  }

  Future<void> _openAddReward({RewardSuggestionModel? suggestion}) async {
    final childId = selectedChildId;

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
      await _loadCurrentRewards();

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
    if (deletingRewardIds.contains(reward.id)) {
      return;
    }

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

    final rewardIndex = currentRewards.indexWhere(
      (item) => item.id == reward.id,
    );

    setState(() {
      deletingRewardIds.add(reward.id);
      currentRewards.removeWhere((item) => item.id == reward.id);
    });

    try {
      await _rewardApiService.deleteReward(reward.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم حذف المكافأة' : 'Reward deleted'),
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        final safeIndex = rewardIndex.clamp(0, currentRewards.length).toInt();

        currentRewards.insert(safeIndex, reward);
      });

      final statusCode = error.response?.statusCode;
      final backendMessage = _readBackendMessage(error);

      String message;

      if (statusCode == 404) {
        message = isArabic
            ? 'لا يمكنك حذف هذه المكافأة؛ يمكن حذفها فقط بواسطة ولي الأمر الذي أضافها.'
            : 'You cannot delete this reward. Only the parent who added it can delete it.';
      } else if (backendMessage?.toLowerCase().contains('claimed') == true) {
        message = isArabic
            ? 'لا يمكن حذف المكافأة بعد استلامها.'
            : 'A claimed reward cannot be deleted.';
      } else {
        message = isArabic
            ? 'تعذّر حذف المكافأة. حاول مرة أخرى.'
            : 'Failed to delete the reward. Please try again.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          deletingRewardIds.remove(reward.id);
        });
      }
    }
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _loadChildren,
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

                  if (isLoadingChildren)
                    const Center(child: CircularProgressIndicator())
                  else if (childrenError != null)
                    _ErrorMessage(
                      message: childrenError!,
                      onRetry: _loadChildren,
                    )
                  else if (children.isEmpty)
                    _EmptyMessage(
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
                        children: children.map((child) {
                          return ChildCard(
                            name: child.name,
                            avatarIndex: child.avatarIndex,
                            isSelected: selectedChildId == child.id,
                            onTap: () {
                              _selectChild(child.id);
                            },
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  if (selectedChildId != null) ...[
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

                    if (isLoadingRewards)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (rewardsError != null)
                      _ErrorMessage(
                        message: rewardsError!,
                        onRetry: _loadCurrentRewards,
                      )
                    else if (currentRewards.isEmpty)
                      _EmptyMessage(
                        message: isArabic
                            ? 'لا توجد مكافآت لهذا الطفل حتى الآن'
                            : 'This child has no rewards yet',
                      )
                    else
                      Column(
                        children: currentRewards.map((reward) {
                          final isClaimed =
                              reward.status.toUpperCase() == 'CLAIMED';

                          return _CurrentRewardCard(
                            reward: reward,
                            isArabic: isArabic,
                            isDeleting: deletingRewardIds.contains(reward.id),
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

                  if (selectedChildId == null)
                    _EmptyMessage(
                      message: isArabic
                          ? 'اختر طفلًا أولًا لعرض المكافآت المقترحة'
                          : 'Select a child first to view suggested rewards',
                    )
                  else if (isLoadingSuggestions)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (suggestionsError != null)
                    _ErrorMessage(
                      message: suggestionsError!,
                      onRetry: _loadRewardSuggestions,
                    )
                  else
                    _QuickAddCategory(
                      suggestions: rewardSuggestions,
                      isArabic: isArabic,
                      onSuggestionTap: (suggestion) {
                        _openAddReward(suggestion: suggestion);
                      },
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  _AddRewardButton(
                    isArabic: isArabic,
                    enabled: selectedChildId != null,
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
  }
}

class _CurrentRewardCard extends StatelessWidget {
  final RewardModel reward;
  final bool isArabic;
  final bool isDeleting;
  final VoidCallback? onDelete;

  const _CurrentRewardCard({
    required this.reward,
    required this.isArabic,
    required this.isDeleting,
    required this.onDelete,
  });

  String get statusLabel {
    switch (reward.status.toUpperCase()) {
      case 'UNLOCKED':
        return isArabic ? 'متاحة' : 'Unlocked';

      case 'CLAIMED':
        return isArabic ? 'تم استلامها' : 'Claimed';

      default:
        return isArabic ? 'مقفلة' : 'Locked';
    }
  }

  IconData get statusIcon {
    switch (reward.status.toUpperCase()) {
      case 'UNLOCKED':
        return Icons.lock_open_outlined;

      case 'CLAIMED':
        return Icons.check_circle_outline;

      default:
        return Icons.lock_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,
        children: [
          if (onDelete != null)
            IconButton(
              onPressed: isDeleting ? null : onDelete,
              icon: isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline, color: AppColors.error),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  reward.rewardName,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                if (reward.description != null &&
                    reward.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),

                  Text(
                    reward.description!,
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Row(
                  mainAxisAlignment: isArabic
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 4),

                    Icon(statusIcon, size: 17, color: AppColors.primary),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  isArabic
                      ? 'تفتح يوم ${reward.unlockDayLabel}'
                      : 'Unlocks on ${reward.unlockDayLabel}',
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.card_giftcard_outlined,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddCategory extends StatelessWidget {
  final List<RewardSuggestionModel> suggestions;
  final bool isArabic;

  final ValueChanged<RewardSuggestionModel> onSuggestionTap;

  const _QuickAddCategory({
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

class _AddRewardButton extends StatelessWidget {
  final bool enabled;
  final bool isArabic;
  final VoidCallback onTap;

  const _AddRewardButton({
    required this.enabled,
    required this.onTap,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: Colors.white, size: 20),

              const SizedBox(width: AppSpacing.sm),

              Text(
                isArabic ? 'إضافة مكافأة' : 'Add Reward',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error, fontSize: 13),
        ),

        TextButton(
          onPressed: onRetry,
          child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
        ),
      ],
    );
  }
}
