import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/parent_dashboard_controller.dart';

extension ParentDashboardErrorLocalization on ParentDashboardErrorCode {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    switch (this) {
      case ParentDashboardErrorCode.loadDashboard:
        return l10n.failedToLoadDashboard;

      case ParentDashboardErrorCode.refreshDashboard:
        return l10n.failedToRefreshDashboard;
    }
  }
}
