import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/family_settings_controller.dart';

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
    }
  }
}

extension FamilyGuardianLocalization on String {
  String guardianTypeLabel(BuildContext context) {
    switch (toLowerCase()) {
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
  final trimmedName = name.trim();

  if (trimmedName.isEmpty) {
    return trimmedName;
  }

  var cleanName = trimmedName.replaceFirst(
    RegExp(r'\s+family$', caseSensitive: false),
    '',
  );

  cleanName = cleanName.replaceFirst(
    RegExp(r'^عائلة\s+', caseSensitive: false),
    '',
  );

  cleanName = cleanName.replaceFirst(
    RegExp(r"['’]s$", caseSensitive: false),
    '',
  );

  return context.l10n.familyNameDisplay(cleanName.trim());
}
