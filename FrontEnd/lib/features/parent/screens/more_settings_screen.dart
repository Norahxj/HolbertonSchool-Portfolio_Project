import 'package:flutter/material.dart';
import 'package:frontend/models/user_model.dart';

import '../../../app.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../auth/services/auth_api_service.dart';
import 'family_settings_screen.dart';
import 'profile_screen.dart';

// More / Settings screen (Screen 17).
//
// The user request is created inside ParentNav and passed into this
// StatelessWidget. This prevents it from restarting when switching tabs.
class MoreSettingsScreen extends StatelessWidget {
  final Future<UserModel> userFuture;

  const MoreSettingsScreen({
    super.key,
    required this.userFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<UserModel>(
            future: userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Text('Error loading user'),
                );
              }

              final user = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Text(
                      'المزيد',
                      style: AppTextStyles.arabicTitle,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _ProfileBanner(
                      user: user,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    const _SettingsCard(),

                    const SizedBox(height: AppSpacing.xl),

                    const _LogoutButton(),

                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
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

  const _ProfileBanner({
    required this.user,
  });

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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'ولي الأمر',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
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
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

// White card containing the settings rows.
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
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          _SettingsRow(
            icon: Icons.home_outlined,
            label: 'إعدادات العائلة',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FamilySettingsScreen(),
                ),
              );
            },
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          const _LanguageRow(),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          _SettingsRow(
            icon: Icons.notifications_none,
            label: 'الإشعارات',
            showComingSoon: true,
            onTap: () {
              // TODO: Build notification settings later.
            },
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          _SettingsRow(
            icon: Icons.help_outline,
            label: 'المساعدة والدعم',
            showComingSoon: true,
            onTap: () {
              // TODO: Build help and support later.
            },
          ),
        ],
      ),
    );
  }
}

// One tappable setting row.
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
              child: Icon(
                icon,
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

// Small "قريبًا" label.
class _ComingSoonTag extends StatelessWidget {
  const _ComingSoonTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
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

// Language row. It is currently visual only.
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
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
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

// Log out button.
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
          MaterialPageRoute(
            builder: (_) => const AsalahApp(),
          ),
          (route) => false,
        );
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            color: AppColors.error,
            size: 18,
          ),

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