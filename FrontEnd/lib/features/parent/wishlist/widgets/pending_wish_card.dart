import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'wish_components.dart';

class PendingWishCard extends StatefulWidget {
  final String childName;
  final bool isArabic;
  final int avatarIndex;
  final String wishTitle;
  final String subtitle;
  final int startingPoints;
  final ValueChanged<int> onApprove;
  final VoidCallback onReject;

  const PendingWishCard({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.wishTitle,
    required this.subtitle,
    required this.startingPoints,
    required this.onApprove,
    required this.onReject,
    required this.isArabic,
  });

  @override
  State<PendingWishCard> createState() => _PendingWishCardState();
}

class _PendingWishCardState extends State<PendingWishCard> {
  late int requiredPoints;

  @override
  void initState() {
    super.initState();
    requiredPoints = widget.startingPoints;
  }

  @override
  Widget build(BuildContext context) {
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
            childName: widget.childName,
            wishTitle: widget.wishTitle,
            avatarIndex: widget.avatarIndex,
            isArabic: widget.isArabic,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              StatusTag(
                label: widget.isArabic
                    ? 'بانتظار الموافقة'
                    : 'Pending Approval',
                backgroundColor: AppColors.primaryLight,
                textColor: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.subtitle,
                  textAlign: widget.isArabic ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                StepperButton(
                  icon: Icons.add,
                  isFilled: true,
                  onTap: () {
                    setState(() {
                      requiredPoints += 10;
                    });
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$requiredPoints',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.auto_awesome, color: AppColors.gold, size: 16),
                const SizedBox(width: AppSpacing.sm),
                StepperButton(
                  icon: Icons.remove,
                  isFilled: false,
                  onTap: () {
                    if (requiredPoints > 10) {
                      setState(() {
                        requiredPoints -= 10;
                      });
                    }
                  },
                ),
                const Spacer(),
                Text(
                  widget.isArabic ? 'هدف النقاط' : 'Points Goal',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            widget.isArabic
                ? 'بعد تحويل الأمنية إلى هدف، يبدأ الطفل بجمع هذا العدد من نقاط نور لتحقيقها.'
                : 'After converting the wish into a goal, the child starts collecting these Noor points to achieve it.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    if (requiredPoints <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.isArabic
                                ? 'يجب أن تكون النقاط أكبر من صفر'
                                : 'Points must be greater than zero',
                          ),
                        ),
                      );
                      return;
                    }

                    widget.onApprove(requiredPoints);
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.isArabic
                                ? 'تحويل إلى هدف'
                                : 'Convert to Goal',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.check, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onReject,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.isArabic ? 'رفض' : 'Reject',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.close,
                          color: AppColors.textPrimary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
