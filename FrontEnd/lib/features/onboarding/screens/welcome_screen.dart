import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../widgets/role_card.dart';
import '../../auth/screens/auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const WelcomeScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Align(
                  alignment:
                      isArabic ? Alignment.centerLeft : Alignment.centerRight,
                  child: LanguageToggle(
                    isArabic: isArabic,
                    onTap: onLanguageToggle,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                const Text(
                  'Asalah',
                  style: AppTextStyles.logo,
                  textAlign: TextAlign.center,
                ),

                const Text(
                  'أصالة',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  AppStrings.welcomeTitle(isArabic),
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  AppStrings.welcomeSubtitle(isArabic),
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                Row(
                  children: [
                    RoleCard(
                      arabicTitle: 'ولي الأمر',
                      englishTitle: 'Parent',
                      icon: Icons.family_restroom,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuthScreen(
                              isArabic: isArabic,
                              onLanguageToggle: onLanguageToggle,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.md),
                    RoleCard(
                      arabicTitle: 'طفل',
                      englishTitle: 'Child',
                      icon: Icons.child_care,
                      onTap: () {
                        // Later: navigate to child auth screen
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
