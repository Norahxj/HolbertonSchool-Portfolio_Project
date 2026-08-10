import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class EncouragementCard extends StatelessWidget {
  final bool isArabic;

  const EncouragementCard({
    super.key,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.mintLight,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.mint,
            size: 30,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              isArabic
                  ? 'كل مهمة تنجزها تقرّبك من هدف جديد ومكافأة أجمل!'
                  : 'Every task you complete brings you closer to a new goal and a better reward!',
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}