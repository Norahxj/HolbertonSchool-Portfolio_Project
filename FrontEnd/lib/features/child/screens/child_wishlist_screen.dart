import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import 'add_wishlist_screen.dart';

// Child Wishlist screen (Screen 23).
//
// This first pass is static/placeholder only: the points balance and
// wishes below are all hardcoded. No backend calls happen here yet.
class ChildWishlistScreen extends StatelessWidget {
  const ChildWishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '240',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.auto_awesome,
                                color: AppColors.gold,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'قائمة أمنياتي',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.arabicTitle,
                          ),
                        ),
                        // Empty box the same width as the badge, so the
                        // title above stays centered on the screen.
                        const SizedBox(width: 56),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      'اجمع نقاط نور لتحقيق أمنياتك',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const _WishCard(
                      title: 'دراجة هوائية',
                      subtitle: 'باقٍ 60 نقطة فقط',
                      subtitleColor: AppColors.success,
                      progress: 0.76,
                      percentLabel: '76%',
                      pointsLabel: '✦ 250 / 190',
                      iconBackgroundColor: Color(0xFFFCE7D2),
                      iconColor: Color(0xFFDE9A3E),
                      icon: Icons.star,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    const _WishCard(
                      title: 'مجموعة قصص',
                      subtitle: 'استمر في جمع النقاط',
                      subtitleColor: AppColors.textSecondary,
                      progress: 0.40,
                      percentLabel: '40%',
                      pointsLabel: '✦ 120 / 48',
                      iconBackgroundColor: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      icon: Icons.card_giftcard,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddWishlistScreen(),
                          ),
                        );
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'إضافة أمنية',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Icon(Icons.add, color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// One wish card: title + status subtitle + icon on top, then a progress
// bar, then a percent/points row below it.
class _WishCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final double progress;
  final String percentLabel;
  final String pointsLabel;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;

  const _WishCard({
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.progress,
    required this.percentLabel,
    required this.pointsLabel,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.primaryLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                percentLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                pointsLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Bottom navigation bar for the child screens, with "أمنياتي" highlighted
// as the active tab.
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
            _NavItem(
              icon: Icons.favorite_border,
              label: 'أمنياتي',
              isActive: true,
            ),
            _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
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
