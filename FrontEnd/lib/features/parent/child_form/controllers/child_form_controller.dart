import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/child_model.dart';
import '../../services/child_api_service.dart';

enum ChildFormMode {
  add,
  edit,
}

enum ChildFormFieldErrorCode {
  nameRequired,
  nameTooShort,
  nameTooLong,
  nameLettersOnly,
  birthDateRequired,
  invalidChildAge,
  invalidPhone,
}

enum ChildFormErrorCode {
  addChild,
  updateChild,
  childNotIdentified,
  phoneAlreadyUsed,
  parentNotLinkedToFamily,
  parentAccessRequiredForAdd,
  parentAccessRequiredForEdit,
  parentNotFound,
  childNotFound,
  couldNotCreateChild,
  couldNotUpdateChild,
  unexpectedAddError,
  unexpectedUpdateError,
}

class ChildFormSaveResult {
  final bool isSuccess;
  final ChildModel? child;
  final ChildFormErrorCode? errorCode;
  final String? backendMessage;

  const ChildFormSaveResult({
    this.isSuccess = false,
    this.child,
    this.errorCode,
    this.backendMessage,
  });
}

class ChildFormController extends ChangeNotifier {
  final ChildApiService _childApiService;

  ChildFormController.add({
    ChildApiService? childApiService,
  }) : mode = ChildFormMode.add,
       child = null,
       _childApiService = childApiService ?? ChildApiService(),
       _selectedAvatarIndex = 0,
       _selectedBirthDate = null;

  ChildFormController.edit({
    required ChildModel child,
    ChildApiService? childApiService,
  }) : mode = ChildFormMode.edit,
       child = child,
       _childApiService = childApiService ?? ChildApiService(),
       _selectedAvatarIndex = child.avatarIndex,
       _selectedBirthDate = DateTime.tryParse(child.birthDate);

  final ChildFormMode mode;
  final ChildModel? child;

  bool get isAddMode => mode == ChildFormMode.add;

  bool get isEditMode => mode == ChildFormMode.edit;

  int _selectedAvatarIndex;

  int get selectedAvatarIndex => _selectedAvatarIndex;

  DateTime? _selectedBirthDate;

  DateTime? get selectedBirthDate => _selectedBirthDate;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  ChildFormFieldErrorCode? _nameErrorCode;

  ChildFormFieldErrorCode? get nameErrorCode => _nameErrorCode;

  ChildFormFieldErrorCode? _birthDateErrorCode;

  ChildFormFieldErrorCode? get birthDateErrorCode => _birthDateErrorCode;

  ChildFormFieldErrorCode? _phoneErrorCode;

  ChildFormFieldErrorCode? get phoneErrorCode => _phoneErrorCode;

  void selectAvatar(int avatarIndex) {
    if (_selectedAvatarIndex == avatarIndex) {
      return;
    }

    _selectedAvatarIndex = avatarIndex;
    notifyListeners();
  }

  void selectBirthDate(DateTime date) {
    if (_selectedBirthDate == date) {
      return;
    }

    _selectedBirthDate = date;
    _birthDateErrorCode = null;

    notifyListeners();
  }

  DateTime get earliestBirthDate {
    final now = DateTime.now();

    return DateTime(
      now.year - 18,
      now.month,
      now.day,
    );
  }

  DateTime get latestBirthDate {
    final now = DateTime.now();

    return DateTime(
      now.year - 6,
      now.month,
      now.day,
    );
  }

  DateTime get initialBirthDate {
    final now = DateTime.now();

    var date =
        _selectedBirthDate ??
        DateTime(
          now.year - 7,
          now.month,
          now.day,
        );

    if (date.isBefore(earliestBirthDate)) {
      date = earliestBirthDate;
    }

    if (date.isAfter(latestBirthDate)) {
      date = latestBirthDate;
    }

    return date;
  }

  String? get formattedBirthDate {
    final date = _selectedBirthDate;

    if (date == null) {
      return null;
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  bool validateFields({
    required String name,
    required String phone,
  }) {
    _clearFieldErrors();

    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();

    if (trimmedName.isEmpty) {
      _nameErrorCode = ChildFormFieldErrorCode.nameRequired;
    } else if (trimmedName.length < 2) {
      _nameErrorCode = ChildFormFieldErrorCode.nameTooShort;
    } else if (trimmedName.length > 100) {
      _nameErrorCode = ChildFormFieldErrorCode.nameTooLong;
    } else if (!RegExp(
      r'^[a-zA-Z\u0621-\u063A\u0641-\u064A\s]+$',
    ).hasMatch(trimmedName)) {
      _nameErrorCode = ChildFormFieldErrorCode.nameLettersOnly;
    }

    if (_selectedBirthDate == null) {
      _birthDateErrorCode =
          ChildFormFieldErrorCode.birthDateRequired;
    } else if (_selectedBirthDate!.isBefore(earliestBirthDate) ||
        _selectedBirthDate!.isAfter(latestBirthDate)) {
      _birthDateErrorCode =
          ChildFormFieldErrorCode.invalidChildAge;
    }

    if (trimmedPhone.isNotEmpty &&
        !RegExp(r'^05\d{8}$').hasMatch(trimmedPhone)) {
      _phoneErrorCode = ChildFormFieldErrorCode.invalidPhone;
    }

    notifyListeners();

    return !_hasFieldErrors;
  }

  Future<ChildFormSaveResult> save({
    required String name,
    required String phone,
  }) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();

    final isValid = validateFields(
      name: trimmedName,
      phone: trimmedPhone,
    );

    if (!isValid || _isSaving) {
      return const ChildFormSaveResult();
    }

    _isSaving = true;
    notifyListeners();

    try {
      if (isAddMode) {
        final createdChild = await _childApiService.addChild(
          name: trimmedName,
          birthDate: _formatBirthDate(_selectedBirthDate!),
          avatarIndex: _selectedAvatarIndex,
          phone: trimmedPhone.isEmpty ? null : trimmedPhone,
        );

        return ChildFormSaveResult(
          isSuccess: true,
          child: createdChild,
        );
      }

      final editingChild = child;

      if (editingChild == null) {
        return const ChildFormSaveResult(
          errorCode: ChildFormErrorCode.childNotIdentified,
        );
      }

      final updatedChild = await _childApiService.updateChild(
        childId: editingChild.id,
        name: trimmedName,
        birthDate: _formatBirthDate(_selectedBirthDate!),
        avatarIndex: _selectedAvatarIndex,
        phone: trimmedPhone.isEmpty ? null : trimmedPhone,
      );

      return ChildFormSaveResult(
        isSuccess: true,
        child: updatedChild,
      );
    } on DioException catch (error) {
      debugPrint(
        'Child form save failed: '
        'mode=$mode, '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      _readBackendValidationErrors(error);

      if (_hasFieldErrors) {
        return const ChildFormSaveResult();
      }

      return ChildFormSaveResult(
        errorCode: _readSaveErrorCode(error),
        backendMessage: _readUnknownBackendMessage(error),
      );
    } catch (error) {
      debugPrint('Unexpected child form save error: $error');

      return ChildFormSaveResult(
        errorCode: isAddMode
            ? ChildFormErrorCode.unexpectedAddError
            : ChildFormErrorCode.unexpectedUpdateError,
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _readBackendValidationErrors(DioException error) {
    final responseData = error.response?.data;

    if (responseData is! Map) {
      return;
    }

    final errors = responseData['errors'];

    if (errors is! Map) {
      return;
    }

    final nameMessage = _firstError(errors['name']);

    switch (nameMessage) {
      case 'Child name must be at least 2 characters long.':
        _nameErrorCode = ChildFormFieldErrorCode.nameTooShort;

      case 'Child name must not exceed 100 characters.':
        _nameErrorCode = ChildFormFieldErrorCode.nameTooLong;

      case 'Child name must contain letters only.':
        _nameErrorCode = ChildFormFieldErrorCode.nameLettersOnly;

      default:
        if (nameMessage != null) {
          _nameErrorCode = ChildFormFieldErrorCode.nameLettersOnly;
        }
    }

    final birthDateMessage = _firstError(errors['birth_date']);

    switch (birthDateMessage) {
      case 'Child age must be between 6 and 18.':
      case 'Birth date cannot be in the future.':
        _birthDateErrorCode =
            ChildFormFieldErrorCode.invalidChildAge;

      default:
        if (birthDateMessage != null) {
          _birthDateErrorCode =
              ChildFormFieldErrorCode.birthDateRequired;
        }
    }

    if (_firstError(errors['phone']) != null) {
      _phoneErrorCode = ChildFormFieldErrorCode.invalidPhone;
    }

    notifyListeners();
  }

  ChildFormErrorCode _readSaveErrorCode(DioException error) {
    final backendMessage = _readBackendMessage(error);

    switch (backendMessage) {
      case 'Phone number already used':
        return ChildFormErrorCode.phoneAlreadyUsed;

      case 'Parent is not assigned to a family':
        return ChildFormErrorCode.parentNotLinkedToFamily;

      case 'Parent access required':
        return isAddMode
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
        return isAddMode
            ? ChildFormErrorCode.addChild
            : ChildFormErrorCode.updateChild;
    }
  }

  String? _readUnknownBackendMessage(DioException error) {
    final backendMessage = _readBackendMessage(error);

    const knownMessages = {
      'Phone number already used',
      'Parent is not assigned to a family',
      'Parent access required',
      'Parent not found',
      'Child not found',
      'Could not create child',
      'Failed to update child',
    };

    if (backendMessage == null ||
        knownMessages.contains(backendMessage)) {
      return null;
    }

    return backendMessage;
  }

  String? _readBackendMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is! Map) {
      return null;
    }

    return responseData['error']?.toString() ??
        responseData['message']?.toString();
  }

  String _formatBirthDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String? _firstError(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }

  bool get _hasFieldErrors {
    return _nameErrorCode != null ||
        _birthDateErrorCode != null ||
        _phoneErrorCode != null;
  }

  void _clearFieldErrors() {
    _nameErrorCode = null;
    _birthDateErrorCode = null;
    _phoneErrorCode = null;
  }
}