import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PointsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const PointsButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: icon == Icons.add ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: icon == Icons.add ? Colors.white : AppColors.primaryDark,
        ),
      ),
    );
  }
}
