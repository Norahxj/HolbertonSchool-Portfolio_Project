import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/child_avatar.dart';

class WishHeader extends StatelessWidget {
  final String childName;
  final String wishTitle;
  final int avatarIndex;

  const WishHeader({
    super.key,
    required this.childName,
    required this.wishTitle,
    required this.avatarIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChildAvatar(avatarIndex: avatarIndex, size: 40),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                childName,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                wishTitle,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
