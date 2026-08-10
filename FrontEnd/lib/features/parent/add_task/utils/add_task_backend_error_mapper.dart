import 'package:dio/dio.dart';

import '../models/add_task_errors.dart';

class AddTaskBackendErrors {
  final AddTaskErrorCode? childError;
  final AddTaskErrorCode? categoryError;
  final AddTaskErrorCode? titleError;
  final AddTaskErrorCode? descriptionError;
  final AddTaskErrorCode? pointsError;
  final String? frequencyError;
  final String? recurrenceDayError;

  const AddTaskBackendErrors({
    this.childError,
    this.categoryError,
    this.titleError,
    this.descriptionError,
    this.pointsError,
    this.frequencyError,
    this.recurrenceDayError,
  });

  bool get hasStepOneError {
    return childError != null || categoryError != null;
  }
}

class AddTaskBackendErrorMapper {
  const AddTaskBackendErrorMapper._();

  static AddTaskBackendErrors readFieldErrors(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return const AddTaskBackendErrors();
    }

    final errors = data['errors'];

    if (errors is! Map) {
      return const AddTaskBackendErrors();
    }

    return AddTaskBackendErrors(
      titleError: _mapFieldError(_firstError(errors['title'])),
      descriptionError: _mapFieldError(_firstError(errors['description'])),
      pointsError: _mapFieldError(_firstError(errors['points'])),
      childError: _mapFieldError(_firstError(errors['child_ids'])),
      categoryError: _mapCategoryError(_firstError(errors['category'])),
      frequencyError: _firstError(errors['task_frequency']),
      recurrenceDayError: _firstError(errors['recurrence_day']),
    );
  }

  static String? readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return null;
    }

    final errorMessage = data['error']?.toString().trim();

    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    final message = data['message']?.toString().trim();

    if (message == null || message.isEmpty) {
      return null;
    }

    return message;
  }

  static AddTaskErrorCode? _mapFieldError(String? message) {
    switch (message) {
      case 'Shorter than minimum length 1.':
        return AddTaskErrorCode.selectAtLeastOneChild;

      case 'Must be greater than or equal to 1 and less than or equal to 100.':
        return AddTaskErrorCode.pointsRange;

      case 'Length must be between 2 and 100.':
        return AddTaskErrorCode.taskNameLength;

      case 'Length must be between 2 and 500.':
        return AddTaskErrorCode.descriptionLength;

      default:
        return null;
    }
  }

  static AddTaskErrorCode? _mapCategoryError(String? message) {
    if (message == null) {
      return null;
    }

    return AddTaskErrorCode.selectTaskType;
  }

  static String? _firstError(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }
}
