import '../models/add_task_errors.dart';

class AddTaskValidationResult {
  final AddTaskErrorCode? childError;
  final AddTaskErrorCode? categoryError;
  final AddTaskErrorCode? titleError;
  final AddTaskErrorCode? descriptionError;
  final AddTaskErrorCode? pointsError;

  const AddTaskValidationResult({
    this.childError,
    this.categoryError,
    this.titleError,
    this.descriptionError,
    this.pointsError,
  });

  bool get isValid {
    return childError == null &&
        categoryError == null &&
        titleError == null &&
        descriptionError == null &&
        pointsError == null;
  }

  bool get hasStepOneError {
    return childError != null || categoryError != null;
  }
}

class AddTaskValidator {
  const AddTaskValidator._();

  static AddTaskValidationResult validateStepOne({
    required List<String> childIds,
    required int? taskType,
  }) {
    return AddTaskValidationResult(
      childError: childIds.isEmpty
          ? AddTaskErrorCode.selectAtLeastOneChild
          : null,
      categoryError: taskType == null ? AddTaskErrorCode.selectTaskType : null,
    );
  }

  static AddTaskValidationResult validateDetails({
    required String title,
    required String description,
    required int points,
  }) {
    AddTaskErrorCode? titleError;
    AddTaskErrorCode? descriptionError;
    AddTaskErrorCode? pointsError;

    if (title.isEmpty) {
      titleError = AddTaskErrorCode.taskNameRequired;
    } else if (title.length < 2 || title.length > 100) {
      titleError = AddTaskErrorCode.taskNameLength;
    }

    if (description.isEmpty) {
      descriptionError = AddTaskErrorCode.descriptionRequired;
    } else if (description.length < 2 || description.length > 500) {
      descriptionError = AddTaskErrorCode.descriptionLength;
    }

    if (points < 1 || points > 100) {
      pointsError = AddTaskErrorCode.pointsRange;
    }

    return AddTaskValidationResult(
      titleError: titleError,
      descriptionError: descriptionError,
      pointsError: pointsError,
    );
  }

  static AddTaskValidationResult validateAll({
    required List<String> childIds,
    required int? taskType,
    required String title,
    required String description,
    required int points,
  }) {
    final stepOne = validateStepOne(childIds: childIds, taskType: taskType);

    final details = validateDetails(
      title: title,
      description: description,
      points: points,
    );

    return AddTaskValidationResult(
      childError: stepOne.childError,
      categoryError: stepOne.categoryError,
      titleError: details.titleError,
      descriptionError: details.descriptionError,
      pointsError: details.pointsError,
    );
  }
}
