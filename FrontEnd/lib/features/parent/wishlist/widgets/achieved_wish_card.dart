import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import 'wish_header.dart';
import 'wish_points_panel.dart';
import 'wish_status_tag.dart';

class AchievedWishCard extends StatelessWidget {
  final String childName;
  final int avatarIndex;
  final String wishTitle;
  final int points;

  const AchievedWishCard({
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
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD8C6FF)),
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
                label: l10n.wishAchieved,
                backgroundColor: AppColors.primaryDark,
                textColor: Colors.white,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.wishAchievedSuccessfully,
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
          WishPointsPanel(
            label: l10n.completedNoorPointsGoal,
            points: points,
            leadingIcon: Icons.emoji_events_rounded,
          ),
        ],
      ),
    );
  }
}
