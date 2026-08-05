import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class SettingsErrorState extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function() onRetry;

  const SettingsErrorState({
    super.key,
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.65,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'تعذّر تحميل بيانات المستخدم.'
                  : 'Could not load user information.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),

            const SizedBox(height: AppSpacing.sm),

            ElevatedButton(
              onPressed: onRetry,
              child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
