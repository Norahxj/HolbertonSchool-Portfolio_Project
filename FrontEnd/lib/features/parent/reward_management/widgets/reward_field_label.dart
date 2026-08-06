import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RewardFieldLabel extends StatelessWidget {
  final String text;

  const RewardFieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
