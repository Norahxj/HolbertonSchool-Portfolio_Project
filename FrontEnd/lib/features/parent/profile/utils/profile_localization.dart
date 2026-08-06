import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../models/profile_error_code.dart';

extension ProfileErrorLocalization on ProfileErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case ProfileErrorCode.loadFailed:
        return l10n.failedToLoadProfile;

      case ProfileErrorCode.saveFailed:
        return l10n.failedToSaveProfile;

      case ProfileErrorCode.unexpectedSaveError:
        return l10n.unexpectedProfileSaveError;

      case ProfileErrorCode.firstNameTooShort:
        return l10n.firstNameTooShort;

      case ProfileErrorCode.lastNameTooShort:
        return l10n.lastNameTooShort;

      case ProfileErrorCode.invalidEmail:
        return l10n.invalidEmailAddress;

      case ProfileErrorCode.phoneRequired:
        return l10n.phoneNumberRequired;

      case ProfileErrorCode.emailAlreadyUsed:
        return l10n.emailAlreadyUsed;

      case ProfileErrorCode.phoneAlreadyUsed:
        return l10n.phoneAlreadyUsed;
    }
  }
}

String guardianTypeLabel(BuildContext context, String guardianType) {
  switch (guardianType.trim().toUpperCase()) {
    case 'MOTHER':
      return context.l10n.mother;

    case 'FATHER':
      return context.l10n.father;

    case 'GUARDIAN':
    default:
      return context.l10n.guardian;
  }
}
