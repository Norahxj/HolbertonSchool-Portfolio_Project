import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';

class ProgressSummaryCard
    extends StatelessWidget {
  final int percent;
  final String message;

  const ProgressSummaryCard({
    super.key,
    required this.percent,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final safePercent =
        percent.clamp(0, 100);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage(
            'assets/dashboard/child_progress_background.png',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.all(
              AppSpacing.xl,
            ),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child:
                        CircularProgressIndicator(
                      value:
                          safePercent / 100,
                      strokeWidth: 8,
                      backgroundColor:
                          Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation(
                        AppColors.gold,
                      ),
                    ),
                  ),

                  Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        '$safePercent%',
                        style:
                            const TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        context
                            .l10n
                            .progressThisWeek,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color:
                              Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: Colors.black
                  .withValues(alpha: 0.25),
              borderRadius:
                  const BorderRadius.only(
                bottomLeft:
                    Radius.circular(24),
                bottomRight:
                    Radius.circular(24),
              ),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}