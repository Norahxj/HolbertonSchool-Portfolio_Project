import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../controllers/reward_management_controller.dart';
import '../utils/reward_management_localization.dart';
import '../widgets/reward_management_view.dart';
import 'add_reward_screen.dart';

class RewardManagementScreen extends StatefulWidget {
  final int childrenVersion;

  const RewardManagementScreen({super.key, this.childrenVersion = 0});

  @override
  State<RewardManagementScreen> createState() => _RewardManagementScreenState();
}

class _RewardManagementScreenState extends State<RewardManagementScreen> {
  late final RewardManagementController _controller;

  @override
  void initState() {
    super.initState();

    _controller = RewardManagementController(languageCode: 'ar');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageCode = Localizations.localeOf(context).languageCode;

    if (_controller.languageCode != languageCode) {
      _controller.updateLanguage(languageCode);
    }

    if (_controller.isLoadingChildren && _controller.children.isEmpty) {
      _controller.initialize();
    }
  }

  @override
  void didUpdateWidget(covariant RewardManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.childrenVersion != widget.childrenVersion) {
      _controller.loadChildren();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAddReward({RewardSuggestionModel? suggestion}) async {
    final childId = _controller.selectedChildId;

    if (childId == null) {
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AddRewardScreen(childId: childId, suggestion: suggestion);
        },
      ),
    );

    if (!mounted) {
      return;
    }

    if (saved == true) {
      await _controller.loadCurrentRewards();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.rewardAddedSuccessfully)),
      );
    }
  }

  Future<void> _deleteReward(RewardModel reward) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteRewardTitle, textAlign: TextAlign.start),
          content: Text(
            l10n.deleteRewardConfirmation(reward.rewardName),
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                l10n.delete,
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

    final result = await _controller.deleteReward(reward);

    if (!mounted) {
      return;
    }

    if (result.isSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.rewardDeleted)));

      return;
    }

    final message =
        result.backendMessage ??
        result.errorCode?.localized(context) ??
        context.l10n.failedToDeleteReward;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: RewardManagementView(
        onAddReward: _openAddReward,
        onDeleteReward: _deleteReward,
      ),
    );
  }
}
