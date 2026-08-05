import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';

class ChildrenSectionHeader extends StatelessWidget {
  final String title;
  final bool isArabic;
  final int pendingReviewCount;
  final VoidCallback onAddChild;
  final VoidCallback onReviewTasks;

  const ChildrenSectionHeader({
    super.key,
    required this.title,
    required this.isArabic,
    required this.pendingReviewCount,
    required this.onAddChild,
    required this.onReviewTasks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.arabicTitle),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HeaderActionButton(
              tooltip: isArabic ? 'إضافة طفل' : 'Add child',
              icon: Icons.add_rounded,
              onTap: onAddChild,
            ),
            const SizedBox(width: AppSpacing.sm),
            _ReviewTasksHeaderButton(
              isArabic: isArabic,
              count: pendingReviewCount,
              onTap: onReviewTasks,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.primaryLight,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _ReviewTasksHeaderButton extends StatelessWidget {
  final bool isArabic;
  final int count;
  final VoidCallback onTap;

  const _ReviewTasksHeaderButton({
    required this.isArabic,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: isArabic ? 'مراجعة المهام' : 'Review tasks',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: AppColors.primaryLight,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.fact_check_outlined,
                  size: 23,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              top: -2,
              right: isArabic ? null : -2,
              left: isArabic ? -2 : null,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
