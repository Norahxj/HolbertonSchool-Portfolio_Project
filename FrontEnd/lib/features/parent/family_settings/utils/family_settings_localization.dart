import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../models/family_settings_errors.dart';
import 'family_name_formatter.dart';

extension FamilySettingsErrorLocalization on FamilySettingsErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case FamilySettingsErrorCode.loadFamilyData:
        return l10n.failedToLoadFamilySettings;

      case FamilySettingsErrorCode.familyNameTooShort:
        return l10n.familyNameTooShort;

      case FamilySettingsErrorCode.invalidInvitationEmail:
        return l10n.invalidGuardianEmail;

      case FamilySettingsErrorCode.updateFamilyName:
        return l10n.failedToUpdateFamilyName;

      case FamilySettingsErrorCode.sendInvitation:
        return l10n.failedToSendInvitation;

      case FamilySettingsErrorCode.acceptInvitation:
        return l10n.failedToAcceptInvitation;

      case FamilySettingsErrorCode.rejectInvitation:
        return l10n.failedToRejectInvitation;

      case FamilySettingsErrorCode.invitedUserNotFound:
        return l10n.invitedUserNotFound;

      case FamilySettingsErrorCode.cannotInviteYourself:
        return l10n.cannotInviteYourself;

      case FamilySettingsErrorCode.userAlreadyInFamily:
        return l10n.userAlreadyInFamily;

      case FamilySettingsErrorCode.guardianTypeAlreadyExists:
        return l10n.guardianTypeAlreadyExists;

      case FamilySettingsErrorCode.invitationAlreadyPending:
        return l10n.invitationAlreadyPending;

      case FamilySettingsErrorCode.familyNotFound:
        return l10n.familyInformationNotFound;

      case FamilySettingsErrorCode.invalidEnteredData:
        return l10n.invalidEnteredData;
    }
  }
}

extension FamilyGuardianLocalization on String {
  String guardianTypeLabel(BuildContext context) {
    switch (trim().toLowerCase()) {
      case 'father':
        return context.l10n.father;

      case 'mother':
        return context.l10n.mother;

      case 'guardian':
      default:
        return context.l10n.guardian;
    }
  }
}

String displayLocalizedFamilyName(BuildContext context, String name) {
  final cleanName = FamilyNameFormatter.removeFamilyDecoration(name);

  if (cleanName.isEmpty) {
    return '';
  }

  return context.l10n.familyNameDisplay(cleanName);
}
