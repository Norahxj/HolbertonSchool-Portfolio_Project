import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../widgets/auth_tab_switcher.dart';
import '../widgets/parent_gender_toggle.dart';
import '../widgets/phone_input_field.dart';
import '../widgets/social_login_button.dart';
import '../../../services/auth_api_service.dart';

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
  bool isMotherSelected = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController registerEmailController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthApiService _authApiService = AuthApiService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    familyNameController.dispose();
    registerEmailController.dispose();
    phoneController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleMainButton() async {
  if (isSignInSelected) {
    try {
      final response = await _authApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login Success"),
          ),
        );

        print(response.data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data.toString()),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  } else {
    try {
      final response = await _authApiService.register(
        firstName: firstNameController.text,
        lastName: familyNameController.text,
        phone: phoneController.text,
        email: registerEmailController.text,
        password: registerPasswordController.text,
        guardianType: isMotherSelected ? "mother" : "father",
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Register Success"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data.toString()),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}

  void _handleBack() {
    if (isSignInSelected) {
      Navigator.pop(context);
    } else {
      setState(() => isSignInSelected = true);
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
                    _RoundIconButton(
                      icon: isArabic ? Icons.arrow_forward : Icons.arrow_back,
                      onTap: _handleBack,
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
                  isSignInSelected
                      ? (isArabic ? 'مرحبًا بعودتك!' : 'Welcome back!')
                      : (isArabic
                          ? 'إنشاء حساب جديد'
                          : 'Create a new account'),
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  isSignInSelected
                      ? (isArabic
                          ? 'سجّل الدخول أو أنشئ حسابًا جديدًا'
                          : 'Sign in or create a new account')
                      : (isArabic
                          ? 'يرجى تعبئة البيانات لإنشاء حسابك'
                          : 'Please fill in your details to create your account'),
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
                  child: isSignInSelected
                      ? _buildSignInForm(isArabic)
                      : _buildRegisterForm(isArabic),
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

  Widget _buildSignInForm(bool isArabic) {
    return Column(
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
          hint: isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
          icon: Icons.email_outlined,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'كلمة المرور' : 'Password',
          hint: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: passwordController,
        ),

        const SizedBox(height: AppSpacing.sm),

        Align(
          alignment:
              isArabic ? Alignment.centerRight : Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              // Later: forgot password screen
            },
            child: Text(
              isArabic ? 'هل نسيت كلمة المرور؟' : 'Forgot password?',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        AppButton(
          text: isArabic ? 'تسجيل الدخول' : 'Sign In',
          onPressed: _handleMainButton,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
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
    );
  }

  Widget _buildRegisterForm(bool isArabic) {
    return Column(
      children: [
        ParentGenderToggle(
          isMotherSelected: isMotherSelected,
          isArabic: isArabic,
          onFatherTap: () => setState(() => isMotherSelected = false),
          onMotherTap: () => setState(() => isMotherSelected = true),
        ),

        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: isArabic ? 'الاسم الأول' : 'First name',
          hint: isArabic ? 'الاسم الأول' : 'Enter your first name',
          icon: Icons.person_outline,
          controller: firstNameController,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'اسم العائلة' : 'Family name',
          hint: isArabic ? 'اسم العائلة' : 'Enter your family name',
          icon: Icons.person_outline,
          controller: familyNameController,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'البريد الإلكتروني' : 'Email',
          hint: isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
          icon: Icons.email_outlined,
          controller: registerEmailController,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: AppSpacing.md),

        PhoneInputField(
          hint: isArabic ? 'رقم الجوال' : 'Phone number',
          controller: phoneController,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'كلمة المرور' : 'Password',
          hint: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: registerPasswordController,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'تأكيد كلمة المرور' : 'Confirm password',
          hint: isArabic ? 'أعد إدخال كلمة المرور' : 'Re-enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: confirmPasswordController,
        ),

        const SizedBox(height: AppSpacing.lg),

        AppButton(
          text: isArabic ? 'التالي' : 'Next',
          onPressed: _handleMainButton,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}

