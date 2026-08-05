import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class PointsHistoryErrorState extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function() onRetry;

  const PointsHistoryErrorState({
    super.key,
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
            isArabic
                ? 'تعذّر تحميل سجل النقاط.'
                : 'Could not load points history.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),

          const SizedBox(height: AppSpacing.md),

          ElevatedButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
          ),
        ],
      ),
    );
  }
}
