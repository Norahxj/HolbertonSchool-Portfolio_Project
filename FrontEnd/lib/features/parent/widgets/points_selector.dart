import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';

class PointsSelector extends StatelessWidget {
  final int points;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;


  const PointsSelector({
    super.key,
    required this.points,
    required this.onIncrease,
    required this.onDecrease,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: onDecrease,
            icon: const Icon(Icons.remove),
          ),
          const Spacer(),
          Text(
            '$points نقطة',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.auto_awesome,
            color: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

