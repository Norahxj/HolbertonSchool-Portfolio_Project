import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';

class ChildAccessCodeCard extends StatelessWidget {
  final String accessCode;
  final VoidCallback? onCopy;

  const ChildAccessCodeCard({
    super.key,
    required this.accessCode,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccessCode = accessCode.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.password_rounded,
              color: AppColors.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.childAccessCode,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  hasAccessCode ? accessCode : '—',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.copyCode,
            onPressed: hasAccessCode ? onCopy : null,
            icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
