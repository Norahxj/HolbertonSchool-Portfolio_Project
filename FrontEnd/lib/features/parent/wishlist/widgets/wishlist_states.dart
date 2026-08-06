import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';

class WishlistErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const WishlistErrorState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            context.l10n.failedToLoadWishes,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.error,
            ),
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
    );
  }
}

class WishlistEmptyState extends StatelessWidget {
  const WishlistEmptyState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          context.l10n.noWishesYet,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color:
                AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}