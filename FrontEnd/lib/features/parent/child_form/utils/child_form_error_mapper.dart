import 'package:dio/dio.dart';

import '../models/child_form_errors.dart';
import '../models/child_form_mode.dart';

class ChildFormBackendValidationErrors {
  final ChildFormFieldErrorCode? nameError;
  final ChildFormFieldErrorCode? birthDateError;
  final ChildFormFieldErrorCode? phoneError;

  const ChildFormBackendValidationErrors({
    this.nameError,
    this.birthDateError,
    this.phoneError,
  });

  bool get hasErrors {
    return nameError != null || birthDateError != null || phoneError != null;
  }
}

class ChildFormErrorMapper {
  const ChildFormErrorMapper._();

  static const Set<String> _knownMessages = {
    'Phone number already used',
    'Parent is not assigned to a family',
    'Parent access required',
    'Parent not found',
    'Child not found',
    'Could not create child',
    'Failed to update child',
  };

  static ChildFormBackendValidationErrors readValidationErrors(
    DioException error,
  ) {
    final responseData = error.response?.data;

    if (responseData is! Map) {
      return const ChildFormBackendValidationErrors();
    }

    final errors = responseData['errors'];

    if (errors is! Map) {
      return const ChildFormBackendValidationErrors();
    }

    return ChildFormBackendValidationErrors(
      nameError: _mapNameError(_firstError(errors['name'])),
      birthDateError: _mapBirthDateError(_firstError(errors['birth_date'])),
      phoneError: _mapPhoneError(_firstError(errors['phone'])),
    );
  }

  static ChildFormErrorCode mapSaveError({
    required DioException error,
    required ChildFormMode mode,
  }) {
    final backendMessage = readBackendMessage(error);

    switch (backendMessage) {
      case 'Phone number already used':
        return ChildFormErrorCode.phoneAlreadyUsed;

      case 'Parent is not assigned to a family':
        return ChildFormErrorCode.parentNotLinkedToFamily;

      case 'Parent access required':
        return mode == ChildFormMode.add
            ? ChildFormErrorCode.parentAccessRequiredForAdd
            : ChildFormErrorCode.parentAccessRequiredForEdit;

      case 'Parent not found':
        return ChildFormErrorCode.parentNotFound;

      case 'Child not found':
        return ChildFormErrorCode.childNotFound;

      case 'Could not create child':
        return ChildFormErrorCode.couldNotCreateChild;

      case 'Failed to update child':
        return ChildFormErrorCode.couldNotUpdateChild;

      default:
        return mode == ChildFormMode.add
            ? ChildFormErrorCode.addChild
            : ChildFormErrorCode.updateChild;
    }
  }

  static String? readUnknownBackendMessage(DioException error) {
    final backendMessage = readBackendMessage(error);

    if (backendMessage == null) {
      return null;
    }

    final cleanMessage = backendMessage.trim();

    if (cleanMessage.isEmpty || _knownMessages.contains(cleanMessage)) {
      return null;
    }

    return cleanMessage;
  }

  static String? readBackendMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is! Map) {
      return null;
    }

    final errorMessage = responseData['error']?.toString().trim();

    if (errorMessage != null && errorMessage.isNotEmpty) {
      return errorMessage;
    }

    final message = responseData['message']?.toString().trim();

    if (message == null || message.isEmpty) {
      return null;
    }

    return message;
  }

  static ChildFormFieldErrorCode? _mapNameError(String? message) {
    switch (message) {
      case 'Child name must be at least 2 characters long.':
        return ChildFormFieldErrorCode.nameTooShort;

      case 'Child name must not exceed 100 characters.':
        return ChildFormFieldErrorCode.nameTooLong;

      case 'Child name must contain letters only.':
        return ChildFormFieldErrorCode.nameLettersOnly;

      case null:
        return null;

      default:
        return ChildFormFieldErrorCode.nameLettersOnly;
    }
  }

  static ChildFormFieldErrorCode? _mapBirthDateError(String? message) {
    switch (message) {
      case 'Child age must be between 6 and 18.':
      case 'Birth date cannot be in the future.':
        return ChildFormFieldErrorCode.invalidChildAge;

      case null:
        return null;

      default:
        return ChildFormFieldErrorCode.birthDateRequired;
    }
  }

  static ChildFormFieldErrorCode? _mapPhoneError(String? message) {
    if (message == null) {
      return null;
    }

    return ChildFormFieldErrorCode.invalidPhone;
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
