import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../../auth/screens/auth_screen.dart';
import '../../child/pin_login/screens/child_pin_login_screen.dart';
import '../widgets/role_card.dart';

class WelcomeScreen extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;
  final Future<void> Function() onParentAuthenticated;

  const WelcomeScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
    required this.onParentAuthenticated,
  });

  void _openParentAuthentication(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AuthScreen(
            isArabic: isArabic,
            onLanguageToggle: onLanguageToggle,
            onAuthenticated: onParentAuthenticated,
          );
        },
      ),
    );
  }

  void _openChildLogin(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildPinLoginScreen(
            onLanguageToggle: onLanguageToggle,
          );
        },
      ),
    );
  }

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
                  alignment: AlignmentDirectional.centerEnd,
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
                    const PositionedDirectional(
                      top: 0,
                      start: 4,
                      child: _SoftPill(width: 74, height: 22),
                    ),
                    const PositionedDirectional(
                      top: 50,
                      end: 0,
                      child: _SoftPill(width: 58, height: 20),
                    ),
                    const PositionedDirectional(
                      top: -8,
                      end: 56,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 26,
                        color: AppColors.gold,
                      ),
                    ),
                    const PositionedDirectional(
                      top: 34,
                      start: 40,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const PositionedDirectional(
                      bottom: 6,
                      end: 30,
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
                const SizedBox(height: 60),
                RoleCard(
                  imagePath: 'assets/role_selection/parent1.png',
                  title: isArabic ? 'ولي أمر' : 'Parent',
                  description: isArabic
                      ? 'إدارة أطفالك ومتابعة المهام والمكافآت'
                      : 'Manage your children, tasks, and rewards',
                  isArabic: isArabic,
                  onTap: () {
                    _openParentAuthentication(context);
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
                    _openChildLogin(context);
                  },
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

  const _SoftPill({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
