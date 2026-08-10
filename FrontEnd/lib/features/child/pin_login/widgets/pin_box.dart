import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class PinBox extends StatelessWidget {
  final String digit;

  const PinBox({
    super.key,
    required this.digit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}