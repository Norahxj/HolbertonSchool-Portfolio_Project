import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../models/more_settings_error_code.dart';

extension MoreSettingsErrorLocalization on MoreSettingsErrorCode {
  String localized(BuildContext context) {
    switch (this) {
      case MoreSettingsErrorCode.loadUserFailed:
        return context.l10n.failedToLoadUserInformation;
    }
  }
}
