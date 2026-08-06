import '../models/profile_error_code.dart';

class ProfileValidator {
  const ProfileValidator._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static ProfileErrorCode? validate({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    if (firstName.length < 2) {
      return ProfileErrorCode.firstNameTooShort;
    }

    if (lastName.length < 2) {
      return ProfileErrorCode.lastNameTooShort;
    }

    if (!_emailPattern.hasMatch(email)) {
      return ProfileErrorCode.invalidEmail;
    }

    if (phone.isEmpty) {
      return ProfileErrorCode.phoneRequired;
    }

    return null;
  }
}
