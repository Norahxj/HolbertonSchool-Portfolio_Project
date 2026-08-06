import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/child_form_controller.dart';

extension ChildFormFieldErrorLocalization
    on ChildFormFieldErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case ChildFormFieldErrorCode.nameRequired:
        return l10n.childNameRequired;

      case ChildFormFieldErrorCode.nameTooShort:
        return l10n.childNameTooShort;

      case ChildFormFieldErrorCode.nameTooLong:
        return l10n.childNameTooLong;

      case ChildFormFieldErrorCode.nameLettersOnly:
        return l10n.childNameLettersOnly;

      case ChildFormFieldErrorCode.birthDateRequired:
        return l10n.birthDateRequired;

      case ChildFormFieldErrorCode.invalidChildAge:
        return l10n.invalidChildAge;

      case ChildFormFieldErrorCode.invalidPhone:
        return l10n.invalidSaudiPhone;
    }
  }
}

extension ChildFormErrorLocalization on ChildFormErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case ChildFormErrorCode.addChild:
        return l10n.failedToAddChild;

      case ChildFormErrorCode.updateChild:
        return l10n.failedToUpdateChild;

      case ChildFormErrorCode.childNotIdentified:
        return l10n.couldNotIdentifyChildToUpdate;

      case ChildFormErrorCode.phoneAlreadyUsed:
        return l10n.phoneAlreadyUsed;

      case ChildFormErrorCode.parentNotLinkedToFamily:
        return l10n.parentNotLinkedToFamily;

      case ChildFormErrorCode.parentAccessRequiredForAdd:
        return l10n.onlyParentsCanAddChildren;

      case ChildFormErrorCode.parentAccessRequiredForEdit:
        return l10n.onlyParentsCanUpdateChildren;

      case ChildFormErrorCode.parentNotFound:
        return l10n.parentAccountNotFound;

      case ChildFormErrorCode.childNotFound:
        return l10n.childNotFound;

      case ChildFormErrorCode.couldNotCreateChild:
        return l10n.couldNotCreateChild;

      case ChildFormErrorCode.couldNotUpdateChild:
        return l10n.couldNotSaveChildChanges;

      case ChildFormErrorCode.unexpectedAddError:
        return l10n.unexpectedAddChildError;

      case ChildFormErrorCode.unexpectedUpdateError:
        return l10n.unexpectedUpdateChildError;
    }
  }
}