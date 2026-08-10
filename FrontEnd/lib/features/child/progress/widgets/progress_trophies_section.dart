import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../models/progress_trophy_kind.dart';

class ProgressTrophiesSection
    extends StatelessWidget {
  final Map<ProgressTrophyKind, int>
      completedByCategory;

  const ProgressTrophiesSection({
    super.key,
    required this.completedByCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment:
              AlignmentDirectional.centerStart,
          child: Text(
            context.l10n.progressMyBadges,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        Row(
          children: [
            Expanded(
              child: _TrophyBadge(
                kind:
                    ProgressTrophyKind.daily,
                completedTasks:
                    completedByCategory[
                            ProgressTrophyKind
                                .daily] ??
                        0,
              ),
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Expanded(
              child: _TrophyBadge(
                kind:
                    ProgressTrophyKind
                        .cultural,
                completedTasks:
                    completedByCategory[
                            ProgressTrophyKind
                                .cultural] ??
                        0,
              ),
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Expanded(
              child: _TrophyBadge(
                kind:
                    ProgressTrophyKind
                        .financial,
                completedTasks:
                    completedByCategory[
                            ProgressTrophyKind
                                .financial] ??
                        0,
              ),
            ),

            const SizedBox(
              width: AppSpacing.sm,
            ),

            Expanded(
              child: _TrophyBadge(
                kind:
                    ProgressTrophyKind
                        .religious,
                completedTasks:
                    completedByCategory[
                            ProgressTrophyKind
                                .religious] ??
                        0,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: AppSpacing.md,
        ),

        Text(
          context.l10n
              .progressBadgeUnlockExplanation,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TrophyBadge extends StatelessWidget {
  final ProgressTrophyKind kind;
  final int completedTasks;

  const _TrophyBadge({
    required this.kind,
    required this.completedTasks,
  });

  bool get unlocked {
    return completedTasks >= 5;
  }

  int get displayedTasks {
    return completedTasks > 5
        ? 5
        : completedTasks;
  }

  String _title(BuildContext context) {
    switch (kind) {
      case ProgressTrophyKind.daily:
        return context
            .l10n
            .progressDailyTasksBadge;

      case ProgressTrophyKind.cultural:
        return context
            .l10n
            .progressCulturalTasksBadge;

      case ProgressTrophyKind.financial:
        return context
            .l10n
            .progressFinancialTasksBadge;

      case ProgressTrophyKind.religious:
        return context
            .l10n
            .progressReligiousTasksBadge;
    }
  }

  IconData get categoryIcon {
    switch (kind) {
      case ProgressTrophyKind.daily:
        return Icons.wb_sunny_rounded;

      case ProgressTrophyKind.cultural:
        return Icons.menu_book_rounded;

      case ProgressTrophyKind.financial:
        return Icons.savings_rounded;

      case ProgressTrophyKind.religious:
        return Icons.nightlight_round;
    }
  }

  Color get accentColor {
    if (!unlocked) {
      return const Color(0xFFB8ACD8);
    }

    switch (kind) {
      case ProgressTrophyKind.daily:
        return const Color(0xFFE2B640);

      case ProgressTrophyKind.cultural:
        return const Color(0xFF8C6CDD);

      case ProgressTrophyKind.financial:
        return const Color(0xFF65B98B);

      case ProgressTrophyKind.religious:
        return const Color(0xFFE29B4A);
    }
  }

  Color get cardBackground {
    return unlocked
        ? const Color(0xFFFFFCF3)
        : const Color(0xFFF8F5FC);
  }

  Color get cardBorder {
    return unlocked
        ? accentColor
        : const Color(0xFFE7E0F2);
  }

  @override
  Widget build(BuildContext context) {
    const lockedTextColor =
        Color(0xFF9E95B9);

    return Container(
      height: 165,
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius:
            BorderRadius.circular(26),
        border: Border.all(
          color: cardBorder,
          width: unlocked ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(
              alpha: unlocked ? 0.16 : 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color:
                        accentColor.withValues(
                      alpha:
                          unlocked
                              ? 0.17
                              : 0.12,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),

                Icon(
                  Icons.emoji_events_rounded,
                  size: 36,
                  color: accentColor,
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: unlocked
                          ? Colors.white
                          : const Color(
                              0xFFF0ECF7,
                            ),
                      shape:
                          BoxShape.circle,
                      border: Border.all(
                        color: accentColor
                            .withValues(
                          alpha: 0.35,
                        ),
                      ),
                    ),
                    child: Icon(
                      categoryIcon,
                      size: 14,
                      color: accentColor,
                    ),
                  ),
                ),

                if (!unlocked)
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor:
                          Color(0xFFE9E3F4),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 11,
                        color:
                            lockedTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _title(context),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.3,
              fontWeight: FontWeight.bold,
              color: unlocked
                  ? AppColors.textPrimary
                  : lockedTextColor,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color:
                  accentColor.withValues(
                alpha:
                    unlocked ? 0.13 : 0.09,
              ),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              unlocked
                  ? context.l10n
                      .progressBadgeCompleted
                  : context.l10n
                      .progressBadgeCount(
                      displayedTasks,
                    ),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: unlocked
                    ? accentColor
                    : lockedTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}