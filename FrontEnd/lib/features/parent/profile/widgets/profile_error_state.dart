import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';

class ProfileErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const ProfileErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () {
                onRetry();
              },
              child: Text(context.l10n.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
