import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class NavigationArrow extends StatelessWidget {
  const NavigationArrow({super.key});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        isRtl
            ? Icons.arrow_back_ios_new_rounded
            : Icons.arrow_forward_ios_rounded,
        size: 18,
        color: AppColors.textSecondary,
      ),
    );
  }
}
