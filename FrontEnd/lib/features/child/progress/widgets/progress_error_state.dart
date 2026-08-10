import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';

class ProgressErrorState
    extends StatelessWidget {
  final Future<void> Function() onRetry;

  const ProgressErrorState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const Icon(
                Icons.insights_rounded,
                size: 54,
                color: AppColors.primary,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              Text(
                context
                    .l10n
                    .progressLoadFailed,
                textAlign:
                    TextAlign.center,
                style:
                    AppTextStyles
                        .sectionTitle,
              ),

              const SizedBox(
                height: AppSpacing.md,
              ),

              ElevatedButton(
                onPressed: onRetry,
                child: Text(
                  context.l10n.retry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}