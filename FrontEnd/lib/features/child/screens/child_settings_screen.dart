import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/widgets/child_avatar.dart';
import '../../../core/widgets/screen_background.dart';

class ChildSettingsScreen extends StatelessWidget {
  final int avatarIndex;
  final String childName;
  final VoidCallback onLanguageToggle;
  final Future<void> Function() onLogout;

  const ChildSettingsScreen({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.onLanguageToggle,
    required this.onLogout,
  });

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.logOut),
          content: Text(
            context.l10n.childLogoutConfirmation,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                context.l10n.logOut,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage =
        Localizations.localeOf(context).languageCode == 'ar'
            ? context.l10n.arabic
            : context.l10n.english;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          context.l10n.settings,
          style: AppTextStyles.childTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 22,
          ),
        ),
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ChildAvatar(
                    avatarIndex: avatarIndex,
                    size: 56,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.childAccount,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          childName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.language_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(context.l10n.language),
                    subtitle: Text(
                      '$currentLanguage · ${context.l10n.childSwitchLanguage}',
                    ),
                    trailing: const Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onTap: onLanguageToggle,
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                    ),
                    title: Text(
                      context.l10n.logOut,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}