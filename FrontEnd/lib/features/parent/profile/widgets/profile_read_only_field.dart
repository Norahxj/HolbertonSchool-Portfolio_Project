import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class ProfileReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;

  const ProfileReadOnlyField({
    super.key,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(icon, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
