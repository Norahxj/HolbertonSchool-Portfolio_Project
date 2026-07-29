import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../widgets/role_card.dart';
import '../../auth/screens/auth_screen.dart';
import '../../child/screens/child_pin_login_screen.dart';

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
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

                const SizedBox(height: AppSpacing.md),

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

                const SizedBox(height: AppSpacing.md),

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

                const SizedBox(height: AppSpacing.md),

                Text(
                  AppStrings.welcomeSubtitle(isArabic),
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.lg),

                Column(
                  children: [
                    RoleCard(
                      imagePath: 'assets/role_selection/parent1.png',
                      title: isArabic ? 'ولي أمر' : 'Parent',
                      description: isArabic
                          ? 'إدارة أطفالك ومتابعة المهام والمكافآت'
                          : 'Manage your children, tasks, and rewards',
                      isArabic: isArabic,
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

                    const SizedBox(height: AppSpacing.md),

                    RoleCard(
                      imagePath: 'assets/role_selection/child.png',
                      title: isArabic ? 'طفل' : 'Child',
                      description: isArabic
                          ? 'أنجز المهام واجمع النقاط واحصل على المكافآت'
                          : 'Complete tasks, earn points, and unlock rewards',
                      isArabic: isArabic,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChildPinLoginScreen(
                              isArabic: isArabic,
                              onLanguageToggle: onLanguageToggle,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
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

  const _SoftPill({
    required this.width,
    required this.height,
  });

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