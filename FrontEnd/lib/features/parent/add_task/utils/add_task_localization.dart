import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../models/add_task_errors.dart';
import '../models/add_task_week_day.dart';

extension AddTaskErrorLocalization on AddTaskErrorCode {
  String localized(BuildContext context) {
    switch (this) {
      case AddTaskErrorCode.selectAtLeastOneChild:
        return context.l10n.selectAtLeastOneChild;

      case AddTaskErrorCode.selectTaskType:
        return context.l10n.selectTaskTypeError;

      case AddTaskErrorCode.taskNameRequired:
        return context.l10n.taskNameRequired;

      case AddTaskErrorCode.descriptionRequired:
        return context.l10n.descriptionRequired;

      case AddTaskErrorCode.pointsRange:
        return context.l10n.pointsRangeError;

      case AddTaskErrorCode.taskNameLength:
        return context.l10n.taskNameLengthError;

      case AddTaskErrorCode.descriptionLength:
        return context.l10n.descriptionLengthError;
    }
  }
}

extension AddTaskSaveErrorLocalization on AddTaskSaveErrorCode {
  String localized(BuildContext context) {
    switch (this) {
      case AddTaskSaveErrorCode.generic:
        return context.l10n.saveTaskGenericError;
    }
  }
}

extension AddTaskWeekDayLocalization on AddTaskWeekDay {
  String localized(BuildContext context) {
    switch (this) {
      case AddTaskWeekDay.sunday:
        return context.l10n.sunday;

      case AddTaskWeekDay.monday:
        return context.l10n.monday;

      case AddTaskWeekDay.tuesday:
        return context.l10n.tuesday;

      case AddTaskWeekDay.wednesday:
        return context.l10n.wednesday;

      case AddTaskWeekDay.thursday:
        return context.l10n.thursday;

      case AddTaskWeekDay.friday:
        return context.l10n.friday;

      case AddTaskWeekDay.saturday:
        return context.l10n.saturday;
    }
  }
}
