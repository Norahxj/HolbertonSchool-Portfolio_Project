import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class ProfileErrorState extends StatelessWidget {
  final String message;
  final bool isArabic;
  final Future<void> Function() onRetry;

  const ProfileErrorState({
    super.key,
    required this.message,
    required this.isArabic,
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),

            const SizedBox(height: AppSpacing.sm),

            ElevatedButton(
              onPressed: onRetry,
              child: Text(isArabic ? 'إعادة المحاولة' : 'Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
