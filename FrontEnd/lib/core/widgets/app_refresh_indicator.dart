import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
      backgroundColor: AppColors.card,
      displacement: 36,
      child: child,
    );
  }
}
