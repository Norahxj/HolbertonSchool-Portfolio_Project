import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/daily_feedback_controller.dart';

extension DailyFeedbackErrorLocalization on DailyFeedbackErrorCode {
  String localized(BuildContext context) {
    switch (this) {
      case DailyFeedbackErrorCode.loadFeedback:
        return context.l10n.failedToLoadFeedbackHistory;

      case DailyFeedbackErrorCode.saveFeedback:
        return context.l10n.failedToSaveFeedback;
    }
  }
}
