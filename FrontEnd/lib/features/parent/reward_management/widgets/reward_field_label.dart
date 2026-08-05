import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class RewardFieldLabel extends StatelessWidget {
  final String text;
  final bool isArabic;

  const RewardFieldLabel({
    super.key,
    required this.text,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
