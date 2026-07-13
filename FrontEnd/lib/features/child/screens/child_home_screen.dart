import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// Child Home Dashboard screen (Screen 21).
//
// This first pass is static/placeholder only: the child's name, points
// balance, and today's tasks are all hardcoded. No backend calls happen
// here yet.
class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          '3/5',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      Text('مهام اليوم', style: AppTextStyles.arabicTitle),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  const _TaskCard(
                    title: 'الصلاة في وقتها',
                    points: 10,
                    statusText: 'معتمدة تلقائيًا',
                    statusColor: AppColors.success,
                    borderColor: Color(0xFFBFE3C6),
                    circleColor: AppColors.success,
                    circleIcon: Icons.check,
                    taskIcon: Icons.mosque,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  const _TaskCard(
                    title: 'ترتيب السرير',
                    points: 5,
                    statusText: 'بانتظار المراجعة',
                    statusColor: Color(0xFFC08A3E),
                    borderColor: Color(0xFFF0DFA8),
                    circleColor: AppColors.gold,
                    circleIcon: Icons.access_time,
                    taskIcon: Icons.king_bed_outlined,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  const _TaskCard(
                    title: 'توفير مصروفي',
                    points: 10,
                    statusText: 'مرفوضة',
                    statusColor: AppColors.error,
                    borderColor: Color(0xFFF0B8B8),
                    circleColor: AppColors.error,
                    circleIcon: Icons.close,
                    taskIcon: Icons.credit_card,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// Purple gradient header: greeting, avatar, and the Noor points card.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'أهلاً،',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '✦ سارة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFBE3EA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.girl,
                      color: Color(0xFFD1637F),
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'رصيدك من نقاط نور',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '240 نقطة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// One task card for the "مهام اليوم" list. Same shape is reused for
// completed, pending, and rejected tasks, just with different colors,
// icons, and status text passed in.
class _TaskCard extends StatelessWidget {
  final String title;
  final int points;
  final String statusText;
  final Color statusColor;
  final Color borderColor;
  final Color circleColor;
  final IconData circleIcon;
  final IconData taskIcon;

  const _TaskCard({
    required this.title,
    required this.points,
    required this.statusText,
    required this.statusColor,
    required this.borderColor,
    required this.circleColor,
    required this.circleIcon,
    required this.taskIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(circleIcon, color: Colors.white, size: 18),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$points نقاط ✦ $statusText',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(taskIcon, color: AppColors.primaryDark, size: 20),
          ),
        ],
      ),
    );
  }
}

// Bottom navigation bar for the child screens. Simpler than the parent
// one: just 4 plain items in a row, no floating center button.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(icon: Icons.bar_chart_rounded, label: 'تقدّمي'),
            _NavItem(icon: Icons.card_giftcard_outlined, label: 'المكافآت'),
            _NavItem(icon: Icons.favorite_border, label: 'أمنياتي'),
            _NavItem(
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              isActive: true,
            ),
          ],
        ),
      ),
    );
  }
}

// One icon + label pair inside the bottom navigation bar.
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
