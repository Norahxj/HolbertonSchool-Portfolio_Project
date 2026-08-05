import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class PointsHistoryEmptyState extends StatelessWidget {
  final bool isArabic;

  const PointsHistoryEmptyState({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 58, color: AppColors.textSecondary),

          const SizedBox(height: AppSpacing.md),

          Text(
            isArabic ? 'لا يوجد سجل نقاط حتى الآن' : 'No points history yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            isArabic
                ? 'ستظهر هنا النقاط المكتسبة والمخصومة.'
                : 'Earned and deducted points will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
