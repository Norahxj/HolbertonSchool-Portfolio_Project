import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/child_avatar.dart';

class ChildHomeHeader extends StatelessWidget {
  final String childName;
  final int avatarIndex;
  final int points;
  final int completedTasks;
  final int totalTasks;
  final bool isArabic;
  final VoidCallback onSettingsPressed;

  const ChildHomeHeader({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.points,
    required this.completedTasks,
    required this.totalTasks,
    required this.isArabic,
    required this.onSettingsPressed,
  });

  /// Avatar indices 0 and 1 are boy avatars.
  /// Avatar indices 2 and 3 are girl avatars.
  bool get isGirlAvatar {
    return avatarIndex == 2 || avatarIndex == 3;
  }

  String get greeting {
    if (!isArabic) {
      return 'Hello, champion! 👋';
    }

    return isGirlAvatar ? 'أهلًا يا بطلة! 👋' : 'أهلًا يا بطل! 👋';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = isArabic
        ? 'يوم جديد وإنجازات جديدة بانتظارك'
        : 'A new day and new achievements await you';

    final pointsLabel = isArabic ? 'نقاط نور' : 'Noor Points';

    final tasksLabel = isArabic ? 'مهام اليوم' : 'Today\'s Tasks';

    final settingsLabel = isArabic ? 'الإعدادات' : 'Settings';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(36),
            bottomRight: Radius.circular(36),
          ),
          image: DecorationImage(
            image: AssetImage('assets/dashboard/child_home_background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF6F42C1).withValues(alpha: 0.30),
                      const Color(0xFF7F55D9).withValues(alpha: 0.52),
                    ],
                  ),
                ),
              ),
            ),

            PositionedDirectional(
              top: -35,
              start: -20,
              child: _DecorativeBubble(
                size: 110,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),

            PositionedDirectional(
              bottom: -30,
              end: -15,
              child: _DecorativeBubble(
                size: 90,
                color: AppColors.gold.withValues(alpha: 0.16),
              ),
            ),

            Positioned(
              top: 145,
              left: 54,
              child: Icon(
                Icons.star_rounded,
                size: 13,
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),

            Positioned(
              top: 8,
              left: isArabic ? 12 : null,
              right: isArabic ? null : 12,
              child: SafeArea(
                bottom: false,
                child: IconButton(
                  tooltip: settingsLabel,
                  onPressed: onSettingsPressed,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                  ),
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  6,
                  AppSpacing.lg,
                  10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 86,
                        height: 86,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.45),
                              blurRadius: 18,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ChildAvatar(
                          avatarIndex: avatarIndex,
                          size: 78,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      greeting,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 1),

                    Text(
                      childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.childTitle.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),

                    const SizedBox(height: 2),

                    /*
                     * The text is placed first in the Row.
                     *
                     * In Arabic, RTL places the text on the right and
                     * the glitter directly after it on the left.
                     *
                     * In English, LTR places the text on the left and
                     * the glitter directly after it on the right.
                     */
                    Directionality(
                      textDirection: isArabic
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          const Icon(
                            Icons.auto_awesome,
                            color: AppColors.gold,
                            size: 15,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _HeaderMetric(
                            icon: Icons.auto_awesome_rounded,
                            iconColor: AppColors.gold,
                            value: '$points',
                            label: pointsLabel,
                            isArabic: isArabic,
                          ),
                        ),

                        const SizedBox(width: AppSpacing.sm),

                        Expanded(
                          child: _HeaderMetric(
                            icon: Icons.task_alt_rounded,
                            iconColor: AppColors.mint,
                            value: '$completedTasks/$totalTasks',
                            label: tasksLabel,
                            isArabic: isArabic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorativeBubble extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeBubble({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isArabic;

  const _HeaderMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 19,
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}