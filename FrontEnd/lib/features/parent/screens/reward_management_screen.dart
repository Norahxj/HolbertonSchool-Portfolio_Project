import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/reward_model.dart';
import '../../../models/reward_suggestion_model.dart';
import 'add_reward_screen.dart';
import 'package:provider/provider.dart';
import '../reward_management/controllers/reward_management_controller.dart';
import '../reward_management/widgets/reward_management_view.dart';

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
      child: RewardManagementView(
        isArabic: isArabic,
        onAddReward: _openAddReward,
        onDeleteReward: _deleteReward,
      ),
    );
  }
}
