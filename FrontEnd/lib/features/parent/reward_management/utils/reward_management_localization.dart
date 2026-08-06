import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/reward_management_controller.dart';

extension RewardManagementErrorLocalization on RewardManagementErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case RewardManagementErrorCode.loadChildren:
        return l10n.failedToLoadChildren;

      case RewardManagementErrorCode.loadRewards:
        return l10n.failedToLoadChildRewards;

      case RewardManagementErrorCode.loadSuggestions:
        return l10n.failedToLoadRewardSuggestions;

      case RewardManagementErrorCode.deleteNotAllowed:
        return l10n.deleteRewardNotAllowed;

      case RewardManagementErrorCode.deleteClaimedReward:
        return l10n.deleteClaimedRewardNotAllowed;

      case RewardManagementErrorCode.deleteReward:
        return l10n.failedToDeleteReward;
    }
  }
}
