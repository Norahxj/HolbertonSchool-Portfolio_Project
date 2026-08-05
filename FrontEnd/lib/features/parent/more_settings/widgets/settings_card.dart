import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../screens/family_settings_screen.dart';
import 'language_setting_row.dart';

class SettingsCard extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;
  final VoidCallback onProfileTap;
  final VoidCallback onComingSoon;

  const SettingsCard({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
    required this.onProfileTap,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          SettingsRow(
            icon: Icons.person_outline,
            label: isArabic ? 'الملف الشخصي' : 'Personal profile',
            isArabic: isArabic,
            onTap: onProfileTap,
          ),

          const Divider(height: 1, color: AppColors.border),

          SettingsRow(
            icon: Icons.home_outlined,
            label: isArabic ? 'إعدادات العائلة' : 'Family settings',
            isArabic: isArabic,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FamilySettingsScreen(isArabic: isArabic),
                ),
              );
            },
          ),

          const Divider(height: 1, color: AppColors.border),

          LanguageRow(isArabic: isArabic, onTap: onLanguageToggle),

          const Divider(height: 1, color: AppColors.border),

          SettingsRow(
            icon: Icons.notifications_none,
            label: isArabic ? 'الإشعارات' : 'Notifications',
            isArabic: isArabic,
            showComingSoon: true,
            onTap: onComingSoon,
          ),

          const Divider(height: 1, color: AppColors.border),

          SettingsRow(
            icon: Icons.help_outline,
            label: isArabic ? 'المساعدة والدعم' : 'Help and support',
            isArabic: isArabic,
            showComingSoon: true,
            onTap: onComingSoon,
          ),
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showComingSoon;
  final bool isArabic;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isArabic,
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
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),

            const SizedBox(width: AppSpacing.md),

            Expanded(
              child: Row(
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  if (showComingSoon) ...[
                    const SizedBox(width: AppSpacing.sm),

                    ComingSoonTag(isArabic: isArabic),
                  ],
                ],
              ),
            ),

            SettingsNavigationArrow(isArabic: isArabic),
          ],
        ),
      ),
    );
  }
}

class SettingsNavigationArrow extends StatelessWidget {
  final bool isArabic;

  const SettingsNavigationArrow({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // Keep the icon direction fixed instead of letting RTL mirror it.
      textDirection: TextDirection.ltr,
      child: Icon(
        isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
        size: 22,
      ),
    );
  }
}

class ComingSoonTag extends StatelessWidget {
  final bool isArabic;

  const ComingSoonTag({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isArabic ? 'قريبًا' : 'Soon',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
