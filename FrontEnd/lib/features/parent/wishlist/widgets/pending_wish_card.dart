import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import 'wish_components.dart';

class PendingWishCard extends StatefulWidget {
  final String childName;
  final int avatarIndex;
  final String wishTitle;
  final int startingPoints;
  final ValueChanged<int> onApprove;
  final VoidCallback onReject;

  const PendingWishCard({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.wishTitle,
    required this.startingPoints,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<PendingWishCard> createState() {
    return _PendingWishCardState();
  }
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
            childName: widget.childName,
            wishTitle: widget.wishTitle,
            avatarIndex: widget.avatarIndex,
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              StatusTag(
                label: l10n.pendingApproval,
                backgroundColor: AppColors.primaryLight,
                textColor: AppColors.primaryDark,
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  l10n.pendingWishSubtitle,
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
                  textDirection: TextDirection.ltr,
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
                  l10n.pointsGoal,
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
            l10n.convertWishExplanation,
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
                        SnackBar(content: Text(l10n.pointsMustBePositive)),
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
                            l10n.convertToGoal,
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
                          l10n.reject,
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
