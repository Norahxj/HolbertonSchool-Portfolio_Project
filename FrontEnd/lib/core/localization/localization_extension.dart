import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

extension LocalizationContext on BuildContext {
  AppLocalizations get l10n {
    return AppLocalizations.of(this);
  }
}
