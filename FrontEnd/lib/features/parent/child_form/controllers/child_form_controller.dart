import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/child_model.dart';
import '../models/child_form_errors.dart';
import '../models/child_form_mode.dart';
import '../models/child_form_save_result.dart';
import '../repositories/child_form_repository.dart';
import '../utils/child_form_error_mapper.dart';
import '../utils/child_form_validator.dart';

class ChildFormController extends ChangeNotifier {
  final ChildFormRepository _repository;

  ChildFormController.add({ChildFormRepository? repository})
    : mode = ChildFormMode.add,
      child = null,
      _repository = repository ?? ChildFormRepository(),
      _selectedAvatarIndex = 0,
      _selectedBirthDate = null;

  ChildFormController.edit({
    required ChildModel child,
    ChildFormRepository? repository,
  }) : mode = ChildFormMode.edit,
       child = child,
       _repository = repository ?? ChildFormRepository(),
       _selectedAvatarIndex = child.avatarIndex,
       _selectedBirthDate = DateTime.tryParse(child.birthDate);

  final ChildFormMode mode;
  final ChildModel? child;

  int _selectedAvatarIndex;
  DateTime? _selectedBirthDate;

  bool _isSaving = false;
  bool _isDisposed = false;

  ChildFormFieldErrorCode? _nameErrorCode;
  ChildFormFieldErrorCode? _birthDateErrorCode;
  ChildFormFieldErrorCode? _phoneErrorCode;

  bool get isAddMode => mode == ChildFormMode.add;

  bool get isEditMode => mode == ChildFormMode.edit;

  int get selectedAvatarIndex => _selectedAvatarIndex;

  DateTime? get selectedBirthDate => _selectedBirthDate;

  bool get isSaving => _isSaving;

  ChildFormFieldErrorCode? get nameErrorCode => _nameErrorCode;

  ChildFormFieldErrorCode? get birthDateErrorCode => _birthDateErrorCode;

  ChildFormFieldErrorCode? get phoneErrorCode => _phoneErrorCode;

  DateTime get earliestBirthDate {
    final today = _today();

    return DateTime(today.year - 18, today.month, today.day);
  }

  DateTime get latestBirthDate {
    final today = _today();

    return DateTime(today.year - 6, today.month, today.day);
  }

  DateTime get initialBirthDate {
    final today = _today();

    var date =
        _selectedBirthDate ?? DateTime(today.year - 7, today.month, today.day);

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

  void selectAvatar(int avatarIndex) {
    if (avatarIndex < 0 ||
        avatarIndex > 3 ||
        _selectedAvatarIndex == avatarIndex) {
      return;
    }

    _selectedAvatarIndex = avatarIndex;
    _notify();
  }

  void selectBirthDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    if (_selectedBirthDate == normalizedDate) {
      return;
    }

    _selectedBirthDate = normalizedDate;
    _birthDateErrorCode = null;

    _notify();
  }

  Future<ChildFormSaveResult> save({
    required String name,
    required String phone,
  }) async {
    if (_isSaving) {
      return const ChildFormSaveResult.validationFailure();
    }

    final cleanName = name.trim();
    final cleanPhone = phone.trim();

    final isValid = _validateFields(name: cleanName, phone: cleanPhone);

    if (!isValid) {
      return const ChildFormSaveResult.validationFailure();
    }

    _isSaving = true;
    _notify();

    try {
      final savedChild = isAddMode
          ? await _addChild(name: cleanName, phone: cleanPhone)
          : await _updateChild(name: cleanName, phone: cleanPhone);

      return ChildFormSaveResult.success(savedChild);
    } on DioException catch (error) {
      debugPrint(
        'Child form save failed: '
        'mode=$mode, '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );

      final validationErrors = ChildFormErrorMapper.readValidationErrors(error);

      if (validationErrors.hasErrors) {
        _applyBackendValidationErrors(validationErrors);

        return const ChildFormSaveResult.validationFailure();
      }

      return ChildFormSaveResult.failure(
        errorCode: ChildFormErrorMapper.mapSaveError(error: error, mode: mode),
        backendMessage: ChildFormErrorMapper.readUnknownBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Unexpected child form save error: '
        '$error\n$stackTrace',
      );

      return ChildFormSaveResult.failure(
        errorCode: isAddMode
            ? ChildFormErrorCode.unexpectedAddError
            : ChildFormErrorCode.unexpectedUpdateError,
      );
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  Future<ChildModel> _addChild({required String name, required String phone}) {
    return _repository.addChild(
      name: name,
      birthDate: _formatBirthDate(_selectedBirthDate!),
      avatarIndex: _selectedAvatarIndex,
      phone: phone.isEmpty ? null : phone,
    );
  }

  Future<ChildModel> _updateChild({
    required String name,
    required String phone,
  }) {
    final editingChild = child;

    if (editingChild == null) {
      throw StateError('Child is required in edit mode.');
    }

    return _repository.updateChild(
      childId: editingChild.id,
      name: name,
      birthDate: _formatBirthDate(_selectedBirthDate!),
      avatarIndex: _selectedAvatarIndex,
      phone: phone.isEmpty ? null : phone,
    );
  }

  bool _validateFields({required String name, required String phone}) {
    final validation = ChildFormValidator.validate(
      name: name,
      phone: phone,
      birthDate: _selectedBirthDate,
      earliestBirthDate: earliestBirthDate,
      latestBirthDate: latestBirthDate,
    );

    _nameErrorCode = validation.nameError;
    _birthDateErrorCode = validation.birthDateError;
    _phoneErrorCode = validation.phoneError;

    _notify();

    return validation.isValid;
  }

  void _applyBackendValidationErrors(ChildFormBackendValidationErrors errors) {
    _nameErrorCode = errors.nameError;
    _birthDateErrorCode = errors.birthDateError;
    _phoneErrorCode = errors.phoneError;

    _notify();
  }

  DateTime _today() {
    final now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  String _formatBirthDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
