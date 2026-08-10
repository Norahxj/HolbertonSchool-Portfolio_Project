import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';

class ProgressWeeklyBarChart
    extends StatelessWidget {
  final List<int> activity;

  const ProgressWeeklyBarChart({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.progressSundayShort,
      context.l10n.progressMondayShort,
      context.l10n.progressTuesdayShort,
      context.l10n.progressWednesdayShort,
      context.l10n.progressThursdayShort,
      context.l10n.progressFridayShort,
      context.l10n.progressSaturdayShort,
    ];

    int maximum = 0;

    for (final value in activity) {
      if (value > maximum) {
        maximum = value;
      }
    }

    return Container(
      padding:
          const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.end,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: List.generate(
          7,
          (index) {
            final count =
                index < activity.length
                    ? activity[index]
                    : 0;

            final height = maximum == 0
                ? 8.0
                : 8.0 +
                    (count / maximum) * 70;

            return _DayBar(
              label: labels[index],
              count: count,
              height: height,
              isMostActive:
                  maximum > 0 &&
                      count == maximum,
            );
          },
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String label;
  final int count;
  final double height;
  final bool isMostActive;

  const _DayBar({
    required this.label,
    required this.count,
    required this.height,
    required this.isMostActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color:
                AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 4),

        Container(
          width: 22,
          height: height,
          decoration: BoxDecoration(
            color: isMostActive
                ? AppColors.primary
                : AppColors.primaryLight,
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),

        const SizedBox(
          height: AppSpacing.sm,
        ),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color:
                AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}