import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';

class EmptyTasksCard extends StatelessWidget {
  const EmptyTasksCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.skyLight,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.sky.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: AppColors.sky,
              size: 36,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.l10n.childNoTasksToday,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.childNoTasksMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ],
      ),
    );
  }
}