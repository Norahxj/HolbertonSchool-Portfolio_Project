import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../models/parent_child_details_action_result.dart';

extension ParentChildDetailsErrorLocalization on ParentChildDetailsErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case ParentChildDetailsErrorCode.loadTasks:
        return l10n.failedToLoadChildTasks;

      case ParentChildDetailsErrorCode.refreshTasks:
        return l10n.failedToRefreshChildTasks;

      case ParentChildDetailsErrorCode.childNotIdentified:
        return l10n.couldNotIdentifyChild;

      case ParentChildDetailsErrorCode.taskDeleteNotAllowed:
        return l10n.onlyCreatorCanDeleteTask;

      case ParentChildDetailsErrorCode.deleteTask:
        return l10n.failedToDeleteTask;

      case ParentChildDetailsErrorCode.deleteChild:
        return l10n.failedToDeleteChild;

      case ParentChildDetailsErrorCode.childNotFound:
        return l10n.childNotFoundForFamily;

      case ParentChildDetailsErrorCode.parentNotFound:
        return l10n.parentAccountNotFound;

      case ParentChildDetailsErrorCode.parentAccessRequired:
        return l10n.parentAccessRequired;

      case ParentChildDetailsErrorCode.deleteChildRelatedData:
        return l10n.failedToDeleteChildRelatedData;
    }
  }
}
