import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

enum AppNavigationArrowStyle {
  chevron,
  ios,
}

class AppNavigationArrow extends StatelessWidget {
  final double size;
  final Color color;
  final AppNavigationArrowStyle style;
  final bool followTextDirection;

  const AppNavigationArrow({
    super.key,
    this.size = 22,
    this.color = AppColors.textSecondary,
    this.style = AppNavigationArrowStyle.chevron,
    this.followTextDirection = true,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl =
        Directionality.of(context) == TextDirection.rtl;

    final icon = switch (style) {
      AppNavigationArrowStyle.chevron =>
        Icons.chevron_right_rounded,
      AppNavigationArrowStyle.ios =>
        followTextDirection && isRtl
            ? Icons.arrow_back_ios_new_rounded
            : Icons.arrow_forward_ios_rounded,
    };

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}