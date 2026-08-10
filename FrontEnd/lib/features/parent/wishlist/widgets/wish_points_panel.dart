import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class WishPointsPanel extends StatelessWidget {
  final String label;
  final int points;
  final IconData? leadingIcon;

  const WishPointsPanel({
    super.key,
    required this.label,
    required this.points,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEADFFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(leadingIcon, color: AppColors.primaryDark, size: 21),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (points > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
            const SizedBox(width: 4),
            Text(
              '$points',
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
