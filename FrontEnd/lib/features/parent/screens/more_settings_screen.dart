import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';
import '../../../services/user_api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import 'family_settings_screen.dart';
import 'profile_screen.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import '../../../app.dart';

// More / Settings screen (Screen 17).
//
// This first pass is static/placeholder only: the parent name and every
// row action are hardcoded. No backend calls happen here yet, and none of
// the rows navigate anywhere yet (see the TODO comments below).
class MoreSettingsScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback? onLanguageToggle;

  const MoreSettingsScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });
  @override
  State<MoreSettingsScreen> createState() => _MoreSettingsScreenState();
}

class _MoreSettingsScreenState extends State<MoreSettingsScreen> {
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = UserApiService().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<UserModel>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Error loading user'));
              }

              final user = snapshot.data!;

              return Column(
                children: [
                  Text('المزيد', style: AppTextStyles.arabicTitle),

                  const SizedBox(height: AppSpacing.lg),

                  _ProfileBanner(user: user),

                  const SizedBox(height: AppSpacing.lg),

                  _SettingsCard(
                    isArabic: widget.isArabic,
                    onLanguageToggle: widget.onLanguageToggle,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  const _LogoutButton(),

                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Purple banner showing the signed-in parent's name and role.
class _ProfileBanner extends StatelessWidget {
  final UserModel user;
  const _ProfileBanner({super.key, required this.user});

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
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
  final bool isArabic;
  final VoidCallback? onLanguageToggle;

  const _SettingsCard({required this.isArabic, required this.onLanguageToggle});

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FamilySettingsScreen()),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          _LanguageRow(isArabic: isArabic, onTap: onLanguageToggle),
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
  final bool isArabic;
  final VoidCallback? onTap;

  const _LanguageRow({required this.isArabic, required this.onTap});

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
                    child: Center(
                      child: Text(
                        isArabic ? 'ع' : 'EN',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isArabic ? 'EN' : 'ع',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    isArabic ? 'اللغة' : 'Language',
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
              child: const Icon(
                Icons.language,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
          ],
        ),
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
      onTap: () async {
        await AuthApiService().logout();

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AsalahApp()),
          (route) => false,
        );
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
// as the active tab. Every item (including the floating home button)
// switches screens with Navigator.pushReplacement, so tapping between
// tabs never stacks pages.

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
