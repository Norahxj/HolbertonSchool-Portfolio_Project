import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../family_settings/screens/family_settings_screen.dart';
import 'language_setting_row.dart';

class SettingsCard extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onComingSoon;

  const SettingsCard({
    super.key,
    required this.onProfileTap,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
            label: l10n.personalProfile,
            onTap: onProfileTap,
          ),

          const Divider(height: 1, color: AppColors.border),

          SettingsRow(
            icon: Icons.home_outlined,
            label: l10n.familySettings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) {
                    return  const FamilySettingsScreen();
                  },
                ),
              );
            },
          ),

          const Divider(height: 1, color: AppColors.border),

          const LanguageRow(),

          const Divider(height: 1, color: AppColors.border),

          SettingsRow(
            icon: Icons.notifications_none,
            label: l10n.notifications,
            showComingSoon: true,
            onTap: onComingSoon,
          ),

          const Divider(height: 1, color: AppColors.border),

          SettingsRow(
            icon: Icons.help_outline,
            label: l10n.helpAndSupport,
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

  const SettingsRow({
    super.key,
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
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  if (showComingSoon) ...[
                    const SizedBox(width: AppSpacing.sm),
                    const ComingSoonTag(),
                  ],
                ],
              ),
            ),

            const SettingsNavigationArrow(),
          ],
        ),
      ),
    );
  }
}
class SettingsNavigationArrow extends StatelessWidget {
  const SettingsNavigationArrow({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return Icon(
      isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
      color: AppColors.textSecondary,
      size: 22,
    );
  }
}

class ComingSoonTag extends StatelessWidget {
  const ComingSoonTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        context.l10n.soon,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
