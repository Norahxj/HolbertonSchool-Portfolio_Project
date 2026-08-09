import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization_extension.dart';
import '../models/task_review_error_code.dart';

extension TaskReviewErrorLocalization on TaskReviewErrorCode {
  String localized(BuildContext context) {
    switch (this) {
      case TaskReviewErrorCode.loadTasks:
        return context.l10n.unableToLoadReviewTasks;

      case TaskReviewErrorCode.approveTask:
        return context.l10n.unableToApproveTask;

      case TaskReviewErrorCode.approveNotAllowed:
        return context.l10n.onlyTaskCreatorCanApprove;

      case TaskReviewErrorCode.retryTask:
        return context.l10n.unableToSendTaskForRetry;

      case TaskReviewErrorCode.retryNotAllowed:
        return context.l10n.onlyTaskCreatorCanRequestRetry;
    }
  }
}

String formatTaskCompletedTime(
  BuildContext context,
  DateTime? completedAt,
) {
  if (completedAt == null) {
    return context.l10n.completedRecently;
  }

  final locale =
      Localizations.localeOf(context).toLanguageTag();

  final formattedTime = DateFormat.jm(
    locale,
  ).format(completedAt.toLocal());

  return context.l10n.completedAt(formattedTime);
}