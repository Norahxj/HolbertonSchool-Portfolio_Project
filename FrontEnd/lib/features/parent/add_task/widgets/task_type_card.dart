import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';

import '../../../../core/constants/app_colors.dart';

class TaskTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  const TaskTypeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.card : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: !isEnabled
                ? Colors.grey.shade300
                : isSelected
                ? AppColors.primary
                : AppColors.border,
            width: isSelected && isEnabled ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.primaryLight
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isEnabled ? AppColors.primaryDark : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEnabled ? AppColors.textPrimary : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
