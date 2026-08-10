import '../models/child_form_errors.dart';

class ChildFormValidationResult {
  final ChildFormFieldErrorCode? nameError;
  final ChildFormFieldErrorCode? birthDateError;
  final ChildFormFieldErrorCode? phoneError;

  const ChildFormValidationResult({
    this.nameError,
    this.birthDateError,
    this.phoneError,
  });

  bool get isValid {
    return nameError == null && birthDateError == null && phoneError == null;
  }
}

class ChildFormValidator {
  const ChildFormValidator._();

  static final RegExp _namePattern = RegExp(
    r'^[a-zA-Z\u0621-\u063A\u0641-\u064A\s]+$',
  );

  static final RegExp _phonePattern = RegExp(r'^05\d{8}$');

  static ChildFormValidationResult validate({
    required String name,
    required String phone,
    required DateTime? birthDate,
    required DateTime earliestBirthDate,
    required DateTime latestBirthDate,
  }) {
    return ChildFormValidationResult(
      nameError: _validateName(name),
      birthDateError: _validateBirthDate(
        birthDate: birthDate,
        earliestBirthDate: earliestBirthDate,
        latestBirthDate: latestBirthDate,
      ),
      phoneError: _validatePhone(phone),
    );
  }

  static ChildFormFieldErrorCode? _validateName(String name) {
    if (name.isEmpty) {
      return ChildFormFieldErrorCode.nameRequired;
    }

    if (name.length < 2) {
      return ChildFormFieldErrorCode.nameTooShort;
    }

    if (name.length > 100) {
      return ChildFormFieldErrorCode.nameTooLong;
    }

    if (!_namePattern.hasMatch(name)) {
      return ChildFormFieldErrorCode.nameLettersOnly;
    }

    return null;
  }

  static ChildFormFieldErrorCode? _validateBirthDate({
    required DateTime? birthDate,
    required DateTime earliestBirthDate,
    required DateTime latestBirthDate,
  }) {
    if (birthDate == null) {
      return ChildFormFieldErrorCode.birthDateRequired;
    }

    if (birthDate.isBefore(earliestBirthDate) ||
        birthDate.isAfter(latestBirthDate)) {
      return ChildFormFieldErrorCode.invalidChildAge;
    }

    return null;
  }

  static ChildFormFieldErrorCode? _validatePhone(String phone) {
    if (phone.isEmpty) {
      return null;
    }

    if (!_phonePattern.hasMatch(phone)) {
      return ChildFormFieldErrorCode.invalidPhone;
    }

    return null;
  }
}
