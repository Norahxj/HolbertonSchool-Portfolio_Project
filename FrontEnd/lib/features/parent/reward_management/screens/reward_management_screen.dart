import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/reward_model.dart';
import '../../../../models/reward_suggestion_model.dart';
import '../controllers/reward_management_controller.dart';
import '../models/reward_management_result.dart';
import '../utils/reward_management_localization.dart';
import '../widgets/reward_management_view.dart';
import 'add_reward_screen.dart';

class RewardManagementScreen extends StatefulWidget {
  final int childrenVersion;

  const RewardManagementScreen({super.key, this.childrenVersion = 0});

  @override
  State<RewardManagementScreen> createState() {
    return _RewardManagementScreenState();
  }
}

class _RewardManagementScreenState extends State<RewardManagementScreen> {
  late final RewardManagementController _controller;

  String? _languageCode;

  @override
  void initState() {
    super.initState();

    _controller = RewardManagementController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentLanguageCode = Localizations.localeOf(context).languageCode;

    if (_languageCode == null) {
      _languageCode = currentLanguageCode;

      _controller.initialize(languageCode: currentLanguageCode);

      return;
    }

    if (_languageCode != currentLanguageCode) {
      _languageCode = currentLanguageCode;

      _controller.loadRewardSuggestions(languageCode: currentLanguageCode);
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

  Future<void> _refresh() {
    return _controller.refresh(languageCode: _languageCode ?? 'ar');
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

    if (!mounted || saved != true) {
      return;
    }

    await _controller.loadCurrentRewards();

    if (!mounted) {
      return;
    }

    _showMessage(context.l10n.rewardAddedSuccessfully);
  }

  Future<void> _deleteReward(RewardModel reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.deleteRewardTitle,
            textAlign: TextAlign.start,
          ),
          content: Text(
            context.l10n.deleteRewardConfirmation(reward.rewardName),
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(context.l10n.delete),
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

    if (!result.isSuccess) {
      _showDeleteError(result);
      return;
    }

    _showMessage(context.l10n.rewardDeleted);
  }

  void _showDeleteError(RewardDeleteResult result) {
    final message =
        result.backendMessage ??
        result.errorCode?.localized(context) ??
        context.l10n.failedToDeleteReward;

    _showMessage(message);
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: RewardManagementView(
        onRefresh: _refresh,
        onAddReward: _openAddReward,
        onDeleteReward: _deleteReward,
      ),
    );
  }
}
