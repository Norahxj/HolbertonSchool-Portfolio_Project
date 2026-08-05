import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class LeftNavigationArrow extends StatelessWidget {
  const LeftNavigationArrow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 18,
        color: AppColors.textSecondary,
      ),
    );
  }
}
