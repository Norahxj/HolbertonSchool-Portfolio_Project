import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';

class LogoutButton extends StatelessWidget {
  final bool isLoading;
  final Future<void> Function() onLogout;

  const LogoutButton({
    super.key,
    required this.isLoading,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () {
                onLogout();
              },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isLoading ? 0.65 : 1,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                else
                  const Icon(Icons.logout, color: AppColors.error, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  context.l10n.logOut,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
