import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'app_back_button.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final Color titleColor;
  final Color buttonBackgroundColor;
  final Color buttonIconColor;
  final bool? isArabic;

  const AppPageHeader({
    super.key,
    required this.title,
    this.onBack,
    this.titleColor = AppColors.textPrimary,
    this.buttonBackgroundColor = AppColors.primaryLight,
    this.buttonIconColor = AppColors.primaryDark,
    this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final arabic =
        isArabic ??
        Directionality.of(context) == TextDirection.rtl;

    final backButton = AppBackButton(
      onTap: onBack,
      backgroundColor: buttonBackgroundColor,
      iconColor: buttonIconColor,
      isArabic: arabic,
    );

    return Row(
      children: [
        if (!arabic)
          backButton
        else
          const SizedBox(width: 44),

        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.arabicTitle.copyWith(
              color: titleColor,
            ),
          ),
        ),

        if (arabic)
          backButton
        else
          const SizedBox(width: 44),
      ],
    );
  }
}