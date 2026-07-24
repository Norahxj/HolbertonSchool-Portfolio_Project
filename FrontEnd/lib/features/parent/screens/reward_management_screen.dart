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
import 'add_reward_screen.dart';

class RewardManagementScreen extends StatefulWidget {
  const RewardManagementScreen({super.key});

  @override
  State<RewardManagementScreen> createState() => _RewardManagementScreenState();
}

class _RewardManagementScreenState extends State<RewardManagementScreen> {
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

    _loadChildren();
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
        childrenError = _readBackendMessage(error) ?? 'تعذّر تحميل الأطفال';

        isLoadingChildren = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        childrenError = 'تعذّر تحميل الأطفال';

        isLoadingChildren = false;
      });
    }
  }

  Future<void> _loadSelectedChildData() async {
  final requests = <Future<void>>[
    _loadCurrentRewards(),
  ];

  if (rewardSuggestions.isEmpty) {
    requests.add(_loadRewardSuggestions());
  }

  await Future.wait(requests);
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
        rewardsError = _readBackendMessage(error) ?? 'تعذّر تحميل مكافآت الطفل';
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
    final childId = selectedChildId;

    if (childId == null) return;

    setState(() {
      isLoadingSuggestions = true;
      suggestionsError = null;
    });

    try {
      final suggestions = await _rewardApiService.getRewardSuggestions(
        lang: 'ar',
        count: 5,
      );

      if (!mounted || selectedChildId != childId) {
        return;
      }

      setState(() {
        rewardSuggestions = suggestions;
      });
    } on DioException catch (error) {
      if (!mounted || selectedChildId != childId) {
        return;
      }

      setState(() {
        suggestionsError =
            _readBackendMessage(error) ?? 'تعذّر تحميل المكافآت المقترحة';
      });
    } finally {
      if (mounted && selectedChildId == childId) {
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
        builder: (_) =>
            AddRewardScreen(childId: childId, suggestion: suggestion),
      ),
    );

    if (!mounted) return;

    if (saved == true) {
      await _loadCurrentRewards();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة المكافأة بنجاح 🎉')),
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
          title: const Text('حذف المكافأة', textAlign: TextAlign.right),
          content: Text(
            'هل تريد حذف مكافأة '
            '"${reward.rewardName}"؟',
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'حذف',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      deletingRewardIds.add(reward.id);
    });

    try {
      await _rewardApiService.deleteReward(reward.id);

      if (!mounted) return;

      setState(() {
        currentRewards.removeWhere((item) => item.id == reward.id);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف المكافأة')));
    } on DioException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_readBackendMessage(error) ?? 'تعذّر حذف المكافأة'),
        ),
      );
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
                    'إدارة المكافآت',
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'مكافآت أسبوعية تُمنح حسب أداء الطفل',
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
                    const _EmptyMessage(
                      message: 'لا يوجد أطفال بعد. أضف طفلًا أولًا.',
                    )
                  else
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: children.map((child) {
                        return _ChildChip(
                          child: child,
                          isSelected: selectedChildId == child.id,
                          onTap: () {
                            _selectChild(child.id);
                          },
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: AppSpacing.lg),

                  if (selectedChildId != null) ...[
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'مكافآت الطفل الحالية',
                        style: TextStyle(
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
                      const _EmptyMessage(
                        message: 'لا توجد مكافآت لهذا الطفل حتى الآن',
                      )
                    else
                      Column(
                        children: currentRewards.map((reward) {
                          final isClaimed =
                              reward.status.toUpperCase() == 'CLAIMED';

                          return _CurrentRewardCard(
                            reward: reward,
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

                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'إضافة سريعة',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  if (selectedChildId == null)
                    const _EmptyMessage(
                      message: 'اختر طفلًا أولًا لعرض المكافآت المقترحة',
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
                      onSuggestionTap: (suggestion) {
                        _openAddReward(suggestion: suggestion);
                      },
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  _AddRewardButton(
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

class _ChildChip extends StatelessWidget {
  final ChildModel child;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildChip({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color backgroundColor;
    Color iconColor;

    if (child.avatarIndex == 0) {
      icon = Icons.boy;
      backgroundColor = const Color(0xFFD9F0DD);
      iconColor = const Color(0xFF3E8E5A);
    } else if (child.avatarIndex == 1) {
      icon = Icons.boy;
      backgroundColor = const Color(0xFFD7E9F7);
      iconColor = const Color(0xFF2B6CA3);
    } else if (child.avatarIndex == 2) {
      icon = Icons.girl;
      backgroundColor = AppColors.primaryLight;
      iconColor = AppColors.primary;
    } else {
      icon = Icons.girl;
      backgroundColor = const Color(0xFFFBE3EA);
      iconColor = const Color(0xFFD1637F);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),

                if (isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              child.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentRewardCard extends StatelessWidget {
  final RewardModel reward;
  final bool isDeleting;
  final VoidCallback? onDelete;

  const _CurrentRewardCard({
    required this.reward,
    required this.isDeleting,
    required this.onDelete,
  });

  String get statusLabel {
    switch (reward.status.toUpperCase()) {
      case 'UNLOCKED':
        return 'متاحة';

      case 'CLAIMED':
        return 'تم استلامها';

      default:
        return 'مقفلة';
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
        textDirection: TextDirection.ltr,
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  reward.rewardName,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
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
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
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
                  mainAxisAlignment: MainAxisAlignment.end,
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
                  'تفتح يوم '
                  '${reward.unlockDayLabel}',
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
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

  final ValueChanged<RewardSuggestionModel> onSuggestionTap;

  const _QuickAddCategory({
    required this.suggestions,
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
          ? const Text(
              'لا توجد مكافآت مقترحة حاليًا',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            size: 19,
                            color: AppColors.primary,
                          ),

                          const SizedBox(width: AppSpacing.sm),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  suggestions[index].rewardName,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
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
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
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
  final VoidCallback onTap;

  const _AddRewardButton({required this.enabled, required this.onTap});

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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Colors.white, size: 20),

              SizedBox(width: AppSpacing.sm),

              Text(
                'إضافة مكافأة',
                style: TextStyle(
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
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error, fontSize: 13),
        ),

        TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
      ],
    );
  }
}
