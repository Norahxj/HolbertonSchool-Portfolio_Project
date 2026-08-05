import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class DailyFeedbackErrorState extends StatelessWidget {
  final String message;
  final bool isArabic;
  final Future<void> Function() onRetry;

  const DailyFeedbackErrorState({
    super.key,
    required this.message,
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),

          const SizedBox(height: AppSpacing.md),

          ElevatedButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try Again'),
          ),
        ],
      ),
    );
  }
}
