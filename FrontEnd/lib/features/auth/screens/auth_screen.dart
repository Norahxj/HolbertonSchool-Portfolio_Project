import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../widgets/auth_tab_switcher.dart';
import '../widgets/social_login_button.dart';

class AuthScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const AuthScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignInSelected = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleMainButton() {
    if (isSignInSelected) {
      // Later: connect to Flask login API
    } else {
      // Later: navigate to detailed registration form
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        isArabic
                            ? Icons.arrow_forward_ios
                            : Icons.arrow_back_ios,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    LanguageToggle(
                      isArabic: isArabic,
                      onTap: widget.onLanguageToggle,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  isArabic ? 'مرحبًا بعودتك!' : 'Welcome back!',
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  isArabic
                      ? 'سجّل الدخول أو أنشئ حسابًا جديدًا'
                      : 'Sign in or create a new account',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AuthTabSwitcher(
                        isSignInSelected: isSignInSelected,
                        isArabic: isArabic,
                        onSignInTap: () {
                          setState(() {
                            isSignInSelected = true;
                          });
                        },
                        onRegisterTap: () {
                          setState(() {
                            isSignInSelected = false;
                          });
                        },
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      AppTextField(
                        label: isArabic ? 'البريد الإلكتروني' : 'Email',
                        hint: isArabic
                            ? 'أدخل بريدك الإلكتروني'
                            : 'Enter your email',
                        icon: Icons.email_outlined,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      AppTextField(
                        label: isArabic ? 'كلمة المرور' : 'Password',
                        hint: isArabic
                            ? 'أدخل كلمة المرور'
                            : 'Enter your password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        controller: passwordController,
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      if (isSignInSelected)
                        Align(
                          alignment: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              // Later: forgot password screen
                            },
                            child: Text(
                              isArabic
                                  ? 'هل نسيت كلمة المرور؟'
                                  : 'Forgot password?',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSpacing.sm),

                      AppButton(
                        text: isSignInSelected
                            ? isArabic
                                ? 'تسجيل الدخول'
                                : 'Sign In'
                            : isArabic
                                ? 'إنشاء حساب'
                                : 'Register',
                        onPressed: _handleMainButton,
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        isArabic ? 'أو' : 'Or',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      SocialLoginButton(
                        text: isArabic
                            ? 'تسجيل الدخول باستخدام Google'
                            : 'Sign in with Google',
                        onTap: () {
                          // Later: Google login
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                Icon(
                  Icons.home_rounded,
                  size: 90,
                  color: AppColors.primary.withOpacity(0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
