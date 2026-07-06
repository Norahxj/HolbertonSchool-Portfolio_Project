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
                  alignment: isArabic
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: LanguageToggle(
                    isArabic: isArabic,
                    onTap: onLanguageToggle,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0,
                      left: 4,
                      child: _SoftPill(width: 74, height: 22),
                    ),
                    Positioned(
                      top: 50,
                      right: 0,
                      child: _SoftPill(width: 58, height: 20),
                    ),
                    Positioned(
                      top: -8,
                      right: 56,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 26,
                        color: AppColors.gold,
                      ),
                    ),
                    Positioned(
                      top: 34,
                      left: 40,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 30,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.gold,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'أصالة',
                          style: AppTextStyles.logoArabic,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Asalah',
                          style: AppTextStyles.logo,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  AppStrings.welcomeTitle(isArabic),
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  isArabic
                     ? 'حيثُ تُبنى القيم وتُكافئ الإنجازات'
                     : 'Where values are built and achievements are rewarded.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                Text(
                  AppStrings.welcomeSubtitle(isArabic),
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

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

class _SoftPill extends StatelessWidget {
  final double width;
  final double height;

  const _SoftPill({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
