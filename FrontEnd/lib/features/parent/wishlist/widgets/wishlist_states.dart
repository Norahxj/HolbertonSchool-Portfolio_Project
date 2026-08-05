import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class WishlistErrorState extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onRetry;

  const WishlistErrorState({
    super.key,
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            isArabic
                ? 'حدث خطأ أثناء تحميل الأمنيات. حاول مرة أخرى.'
                : 'An error occurred while loading wishes. Please try again.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try Again'),
          ),
        ],
      ),
    );
  }
}

class WishlistEmptyState extends StatelessWidget {
  final bool isArabic;

  const WishlistEmptyState({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          isArabic ? 'لا توجد أمنيات بعد.' : 'No wishes yet.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
