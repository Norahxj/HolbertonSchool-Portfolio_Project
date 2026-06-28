import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class LanguageToggle extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const LanguageToggle({
    super.key,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(
        Icons.language,
        size: 18,
        color: AppColors.textPrimary,
      ),
      label: Text(
        AppStrings.changeLanguage(isArabic),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
