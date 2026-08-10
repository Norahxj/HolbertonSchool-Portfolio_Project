import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class WishStepperButton extends StatelessWidget {
  final IconData icon;
  final bool isFilled;
  final VoidCallback? onTap;

  const WishStepperButton({
    super.key,
    required this.icon,
    required this.isFilled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isFilled ? Colors.white : AppColors.primaryDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: onTap == null ? 0.45 : 1,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isFilled ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: foregroundColor),
          ),
        ),
      ),
    );
  }
}
