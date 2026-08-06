import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../models/child_task_action_result.dart';

extension ChildTasksErrorLocalization on ChildTasksErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case ChildTasksErrorCode.loadFailed:
        return l10n.failedToLoadChildTasks;

      case ChildTasksErrorCode.refreshFailed:
        return l10n.failedToRefreshChildTasks;

      case ChildTasksErrorCode.childNotIdentified:
        return l10n.couldNotIdentifyChild;

      case ChildTasksErrorCode.deleteNotAllowed:
        return l10n.onlyCreatorCanDeleteTask;

      case ChildTasksErrorCode.deleteFailed:
        return l10n.failedToDeleteTask;
    }
  }
}
