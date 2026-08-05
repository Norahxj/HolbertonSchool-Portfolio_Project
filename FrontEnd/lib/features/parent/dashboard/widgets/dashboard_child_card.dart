import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/child_avatar.dart';
import '../../models/parent_dashboard_data.dart';

class DashboardChildCard extends StatelessWidget {
  final ParentDashboardChildItem item;
  final bool isArabic;
  final VoidCallback onTap;

  const DashboardChildCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dashboard = item.dashboard;
    final progress = dashboard.progressPercentage.clamp(0, 100).round();

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          constraints: const BoxConstraints(minHeight: 108),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              ChildAvatar(avatarIndex: item.child.avatarIndex, size: 64),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dashboard.childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      isArabic
                          ? '${dashboard.childAge} سنوات'
                          : '${dashboard.childAge} years old',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _ChildPointsBadge(points: item.points, isArabic: isArabic),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              _ProgressRing(percent: progress),

              const SizedBox(width: 8),

              _ChildCardNavigationArrow(isArabic: isArabic),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildPointsBadge extends StatelessWidget {
  final int? points;
  final bool isArabic;

  const _ChildPointsBadge({required this.points, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final pointsText = points?.toString() ?? '0';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.gold,
            size: 14,
          ),

          const SizedBox(width: 5),

          Text(
            isArabic ? '$pointsText نقطة' : '$pointsText points',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final int percent;

  const _ProgressRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: safePercent / 100,
              strokeWidth: 5,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          Text(
            '$safePercent%',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCardNavigationArrow extends StatelessWidget {
  final bool isArabic;

  const _ChildCardNavigationArrow({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Icon(
        isArabic
            ? Icons.arrow_back_ios_new_rounded
            : Icons.arrow_forward_ios_rounded,
        size: 18,
        color: AppColors.textSecondary,
      ),
    );
  }
}
