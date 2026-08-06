import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import 'wish_header.dart';
import 'wish_points_panel.dart';
import 'wish_status_tag.dart';

class ApprovedWishCard extends StatelessWidget {
  final String childName;
  final int avatarIndex;
  final String wishTitle;
  final int points;

  const ApprovedWishCard({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.wishTitle,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WishHeader(
            childName: childName,
            wishTitle: wishTitle,
            avatarIndex: avatarIndex,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              WishStatusTag(
                label: l10n.goalCreated,
                backgroundColor: AppColors.primaryLight,
                textColor: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.wishApprovedSubtitle,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          WishPointsPanel(label: l10n.selectedPointsGoal, points: points),
        ],
      ),
    );
  }
}
