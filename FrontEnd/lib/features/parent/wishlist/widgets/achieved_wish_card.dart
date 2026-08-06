import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import 'wish_components.dart';

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
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFFF7F2FF,
        ),
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: const Color(
            0xFFD8C6FF,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          WishHeader(
            childName: childName,
            wishTitle: wishTitle,
            avatarIndex: avatarIndex,
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          Row(
            children: [
              StatusTag(
                label: l10n.wishAchieved,
                backgroundColor:
                    AppColors.primaryDark,
                textColor: Colors.white,
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              Expanded(
                child: Text(
                  l10n.wishAchievedSuccessfully,
                  textAlign:
                      TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors
                        .textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                      BoxDecoration(
                    color: const Color(
                      0xFFEADFFF,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .emoji_events_rounded,
                    color: AppColors
                        .primaryDark,
                    size: 21,
                  ),
                ),

                const SizedBox(
                  width: AppSpacing.sm,
                ),

                Expanded(
                  child: Text(
                    l10n.completedNoorPointsGoal,
                    textAlign:
                        TextAlign.start,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ),

                if (points > 0) ...[
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.gold,
                    size: 16,
                  ),

                  const SizedBox(
                    width: 4,
                  ),

                  Text(
                    '$points',
                    textDirection:
                        TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                      color: AppColors
                          .primaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}