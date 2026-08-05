import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;
  final bool? isArabic;

  const AppBackButton({
    super.key,
    this.onTap,
    this.backgroundColor = AppColors.primaryLight,
    this.iconColor = AppColors.primaryDark,
    this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final arabic = isArabic ?? Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap ?? () => Navigator.maybePop(context),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            arabic ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            textDirection: TextDirection.ltr,
            size: 18,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
