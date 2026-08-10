import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class AppErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  final String retryLabel;
  final bool showIcon;
  final double? height;

  const AppErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    required this.retryLabel,
    this.showIcon = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            ElevatedButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );

    if (height == null) {
      return content;
    }

    return SizedBox(
      height: height,
      child: content,
    );
  }
}