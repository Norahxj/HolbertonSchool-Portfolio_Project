import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class DashboardNoChildrenState extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onAddChild;

  const DashboardNoChildrenState({
    super.key,
    required this.isArabic,
    required this.onAddChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.family_restroom_rounded,
            size: 48,
            color: AppColors.primary,
          ),

          const SizedBox(height: AppSpacing.md),

          Text(
            isArabic ? 'لا يوجد أطفال بعد' : 'No children added yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _AddChildButton(isArabic: isArabic, onTap: onAddChild),
        ],
      ),
    );
  }
}

class DashboardErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const DashboardErrorBanner({
    super.key,
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFF9DEDE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18, color: AppColors.error),
          ),

          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardErrorState extends StatelessWidget {
  final String message;
  final bool isArabic;
  final Future<void> Function() onRetry;

  const DashboardErrorState({
    super.key,
    required this.message,
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: 140),

        const Icon(
          Icons.dashboard_outlined,
          size: 52,
          color: AppColors.primary,
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.error),
        ),

        const SizedBox(height: AppSpacing.md),

        Center(
          child: ElevatedButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
          ),
        ),
      ],
    );
  }
}

class _AddChildButton extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const _AddChildButton({required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          isArabic ? 'إضافة طفل' : 'Add child',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
