import '../models/family_settings_errors.dart';

class FamilySettingsValidator {
  const FamilySettingsValidator._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static FamilySettingsErrorCode? validateFamilyName(String name) {
    if (name.trim().length < 2) {
      return FamilySettingsErrorCode.familyNameTooShort;
    }

    return null;
  }

  static FamilySettingsErrorCode? validateInvitationEmail(String email) {
    if (!_emailPattern.hasMatch(email.trim())) {
      return FamilySettingsErrorCode.invalidInvitationEmail;
    }

    return null;
  }
}
