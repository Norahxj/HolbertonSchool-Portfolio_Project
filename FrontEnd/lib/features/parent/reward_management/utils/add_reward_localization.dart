import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../models/add_reward_result.dart';

extension AddRewardErrorLocalization on AddRewardErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case AddRewardErrorCode.rewardNameRequired:
        return l10n.rewardNameRequired;

      case AddRewardErrorCode.saveReward:
        return l10n.couldNotSaveReward;

      case AddRewardErrorCode.genericSaveReward:
        return l10n.saveRewardGenericError;
    }
  }
}
