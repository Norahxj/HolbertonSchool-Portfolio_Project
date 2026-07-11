import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import 'profile_screen.dart';

// More / Settings screen (Screen 17).
//
// This first pass is static/placeholder only: the parent name and every
// row action are hardcoded. No backend calls happen here yet, and none of
// the rows navigate anywhere yet (see the TODO comments below).
class MoreSettingsScreen extends StatelessWidget {
  const MoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Text('المزيد', style: AppTextStyles.arabicTitle),

                const SizedBox(height: AppSpacing.lg),

                const _ProfileBanner(),

                const SizedBox(height: AppSpacing.lg),

                const _SettingsCard(),

                const SizedBox(height: AppSpacing.xl),

                const _LogoutButton(),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// Purple banner showing the signed-in parent's name and role.
class _ProfileBanner extends StatelessWidget {
  const _ProfileBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'نورة الجهني',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ولي الأمر',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// White rounded card holding every settings row.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.person_outline,
            label: 'الملف الشخصي',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          _SettingsRow(
            icon: Icons.home_outlined,
            label: 'إعدادات العائلة',
            onTap: () {
              // TODO: Navigate to the family settings screen (Screen 19).
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          const _LanguageRow(),
          const Divider(height: 1, color: AppColors.border),
          _SettingsRow(
            icon: Icons.notifications_none,
            label: 'الإشعارات',
            showComingSoon: true,
            onTap: () {
              // TODO: Notifications settings are not built yet.
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          _SettingsRow(
            icon: Icons.help_outline,
            label: 'المساعدة والدعم',
            showComingSoon: true,
            onTap: () {
              // TODO: Help & support screen is not built yet.
            },
          ),
        ],
      ),
    );
  }
}

// One tappable row inside the settings card, e.g. "Personal profile".
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showComingSoon;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.chevron_left,
              color: AppColors.textSecondary,
              size: 20,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showComingSoon) ...[
                    const _ComingSoonTag(),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// Small "قريبًا" (Coming soon) tag shown next to a couple of rows.
class _ComingSoonTag extends StatelessWidget {
  const _ComingSoonTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'قريبًا',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

// The "Language" row. This is a visual toggle only for now — it does not
// switch the app language yet. Real language switching already exists in
// the language_toggle widget used on other screens.
class _LanguageRow extends StatelessWidget {
  const _LanguageRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'ع',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'EN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'اللغة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.language,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// Plain red "Log out" text link below the settings card.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Wire this up to the real logout flow once auth session
        // handling (e.g. clearing a saved token) is in place.
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, color: AppColors.error, size: 18),
          SizedBox(width: AppSpacing.sm),
          Text(
            'تسجيل الخروج',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom navigation bar shown on this screen, with "المزيد" highlighted
// as the active tab. Tapping the floating home button takes the parent
// back to the dashboard using Navigator.pop, since this screen was opened
// from there with Navigator.push.
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 88,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 66,
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
                    _NavItem(
                      icon: Icons.more_horiz,
                      label: 'المزيد',
                      isActive: true,
                    ),
                    _NavItem(icon: Icons.favorite_border, label: 'الأمنيات'),
                    SizedBox(width: 56),
                    _NavItem(
                      icon: Icons.card_giftcard_outlined,
                      label: 'المكافآت',
                    ),
                    _NavItem(
                      icon: Icons.list_alt,
                      label: 'المهام',
                      badgeCount: 2,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // This screen was opened from the Parent Dashboard with
                    // Navigator.push, so popping it returns to that screen.
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'الرئيسية',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// One icon + label pair inside the bottom navigation bar. Set isActive to
// true to draw it in the highlighted color (used for "المزيد" here).
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int? badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = isActive ? AppColors.primary : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: itemColor, size: 22),
            if (badgeCount != null)
              Positioned(
                top: -4,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: itemColor,
          ),
        ),
      ],
    );
  }
}
