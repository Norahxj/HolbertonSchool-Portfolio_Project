import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';

class SettingsErrorState extends StatelessWidget {
  final String? message;
  final Future<void> Function() onRetry;

  const SettingsErrorState({super.key, required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.65,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? context.l10n.failedToLoadUserInformation,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),

            const SizedBox(height: AppSpacing.sm),

            ElevatedButton(
              onPressed: onRetry,
              child: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
