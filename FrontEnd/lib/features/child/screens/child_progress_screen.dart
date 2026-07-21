import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// Child Progress screen (Screen 26).
//
// The weekly percentage, statistics, trophies, and chart are currently
// static placeholders. Backend data can be connected later.
class ChildProgressScreen extends StatelessWidget {
  const ChildProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تقدّمي',
                style: AppTextStyles.arabicTitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.lg),

              const _ProgressSummaryCard(
                percent: 72,
                message: 'أحسنت! أنجزت 18 مهمة هذا الأسبوع',
              ),

              const SizedBox(height: AppSpacing.lg),

              const Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.water_drop,
                      iconColor: Color(0xFFDE9A3E),
                      value: '6',
                      label: 'أيام متتالية',
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                      value: '54',
                      label: 'مهمة مكتملة',
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.auto_awesome,
                      iconColor: AppColors.gold,
                      value: '240',
                      label: 'إجمالي النقاط',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Child trophies section.
              _TrophiesSection(),

              const SizedBox(height: AppSpacing.xl),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'نشاط الأسبوع',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              const _WeeklyBarChart(),

              // Extra space at the bottom so the chart does not touch
              // the shared navigation bar.
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// Purple card that displays the weekly progress.
class _ProgressSummaryCard extends StatelessWidget {
  final int percent;
  final String message;

  const _ProgressSummaryCard({
    required this.percent,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: percent / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.gold,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'هذا الأسبوع',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
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

// One statistics card.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// The four trophy categories.
enum _TrophyKind {
  daily,
  cultural,
  financial,
  religious,
}

// Displays the trophy title, trophy cards, and explanation.
class _TrophiesSection extends StatelessWidget {
  const _TrophiesSection();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              'أوسمتي',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const Row(
            children: [
              Expanded(
                child: _TrophyBadge(
                  kind: _TrophyKind.daily,
                  unlocked: true,
                  completedTasks: 5,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TrophyBadge(
                  kind: _TrophyKind.cultural,
                  unlocked: false,
                  completedTasks: 3,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TrophyBadge(
                  kind: _TrophyKind.financial,
                  unlocked: false,
                  completedTasks: 2,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TrophyBadge(
                  kind: _TrophyKind.religious,
                  unlocked: true,
                  completedTasks: 5,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          const Text(
            'يفتح كل وسام بعد إنجاز 5 مهام من فئته',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// One child-friendly trophy card.
class _TrophyBadge extends StatelessWidget {
  final _TrophyKind kind;
  final bool unlocked;
  final int completedTasks;

  const _TrophyBadge({
    required this.kind,
    required this.unlocked,
    required this.completedTasks,
  });

  // Arabic category name.
  String get title {
    switch (kind) {
      case _TrophyKind.daily:
        return 'المهام\nاليومية';

      case _TrophyKind.cultural:
        return 'المهام\nالثقافية';

      case _TrophyKind.financial:
        return 'المهام\nالمالية';

      case _TrophyKind.religious:
        return 'المهام\nالدينية';
    }
  }

  // Small icon that represents the category.
  IconData get categoryIcon {
    switch (kind) {
      case _TrophyKind.daily:
        return Icons.wb_sunny_rounded;

      case _TrophyKind.cultural:
        return Icons.menu_book_rounded;

      case _TrophyKind.financial:
        return Icons.savings_rounded;

      case _TrophyKind.religious:
        return Icons.nightlight_round;
    }
  }

  // Main color for the trophy.
  Color get accentColor {
    if (!unlocked) {
      return const Color(0xFFB8ACD8);
    }

    switch (kind) {
      case _TrophyKind.daily:
        return const Color(0xFFE2B640);

      case _TrophyKind.cultural:
        return const Color(0xFF8C6CDD);

      case _TrophyKind.financial:
        return const Color(0xFF65B98B);

      case _TrophyKind.religious:
        return const Color(0xFFE29B4A);
    }
  }

  Color get cardBackground {
    if (unlocked) {
      return const Color(0xFFFFFCF3);
    }

    return const Color(0xFFF8F5FC);
  }

  Color get cardBorder {
    if (unlocked) {
      return accentColor;
    }

    return const Color(0xFFE7E0F2);
  }

  @override
  Widget build(BuildContext context) {
    const lockedTextColor = Color(0xFF9E95B9);

    return Container(
      height: 165,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: cardBorder,
          width: unlocked ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(
              unlocked ? 0.16 : 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
                    color: accentColor.withOpacity(
                      unlocked ? 0.17 : 0.12,
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
                          : const Color(0xFFF0ECF7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withOpacity(0.35),
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
                      backgroundColor: Color(0xFFE9E3F4),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 11,
                        color: lockedTextColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            title,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(
                unlocked ? 0.13 : 0.09,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              unlocked
                  ? 'مكتمل ٥/٥'
                  : '${_convertToArabicNumbers(completedTasks)}/٥',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: unlocked ? accentColor : lockedTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Converts English numbers to Arabic numbers.
//
// Example:
// 3 becomes ٣
// 12 becomes ١٢
String _convertToArabicNumbers(int number) {
  const englishNumbers = '0123456789';
  const arabicNumbers = '٠١٢٣٤٥٦٧٨٩';

  return number.toString().split('').map((character) {
    final index = englishNumbers.indexOf(character);

    if (index == -1) {
      return character;
    }

    return arabicNumbers[index];
  }).join();
}

// A simple seven-day bar chart.
class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _DayBar(
            label: 'أحد',
            height: 45,
            color: AppColors.primaryLight,
          ),
          _DayBar(
            label: 'إثنين',
            height: 55,
            color: AppColors.primaryLight,
          ),
          _DayBar(
            label: 'ثلاثاء',
            height: 30,
            color: AppColors.primaryLight,
          ),
          _DayBar(
            label: 'أربعاء',
            height: 75,
            color: AppColors.primary,
          ),
          _DayBar(
            label: 'خميس',
            height: 25,
            color: AppColors.primaryLight,
          ),
          _DayBar(
            label: 'جمعة',
            height: 85,
            color: AppColors.primaryDark,
          ),
          _DayBar(
            label: 'سبت',
            height: 35,
            color: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}

// One bar in the weekly chart.
class _DayBar extends StatelessWidget {
  final String label;
  final double height;
  final Color color;

  const _DayBar({
    required this.label,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}