import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/child_rewards_controller.dart';
import '../widgets/child_rewards_view.dart';

class ChildRewardsScreen extends StatefulWidget {
  const ChildRewardsScreen({
    super.key,
  });

  @override
  State<ChildRewardsScreen> createState() {
    return _ChildRewardsScreenState();
  }
}

class _ChildRewardsScreenState extends State<ChildRewardsScreen> {
  late final ChildRewardsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ChildRewardsController()
      ..loadRewards();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _claimReward(String rewardId) async {
    final result = await _controller.claimReward(rewardId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showMessage(
        context.l10n.childRewardClaimFailed,
        AppColors.error,
      );
      return;
    }

    _showMessage(
      context.l10n.childRewardClaimedSuccess,
      AppColors.success,
    );
  }

  void _showMessage(
    String message,
    Color backgroundColor,
  ) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildRewardsView(
        onRefresh: _controller.loadRewards,
        onRetry: _controller.loadRewards,
        onClaim: _claimReward,
      ),
    );
  }
}