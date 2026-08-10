import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../controllers/auth_controller.dart';
import 'parent_gender_toggle.dart';

class AuthView extends StatelessWidget {
  final bool isSignInSelected;
  final String guardianType;

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController firstNameController;
  final TextEditingController familyNameController;
  final TextEditingController registerEmailController;
  final TextEditingController phoneController;
  final TextEditingController registerPasswordController;
  final TextEditingController confirmPasswordController;

  final String? loginEmailErrorText;
  final String? loginPasswordErrorText;
  final String? firstNameErrorText;
  final String? familyNameErrorText;
  final String? registerEmailErrorText;
  final String? phoneErrorText;
  final String? registerPasswordErrorText;
  final String? confirmPasswordErrorText;

  final VoidCallback onBack;
  final VoidCallback onLanguageToggle;
  final VoidCallback onCreateAccount;
  final ValueChanged<String> onGuardianTypeChanged;
  final Future<void> Function() onSubmit;

  const AuthView({
    super.key,
    required this.isSignInSelected,
    required this.guardianType,
    required this.emailController,
    required this.passwordController,
    required this.firstNameController,
    required this.familyNameController,
    required this.registerEmailController,
    required this.phoneController,
    required this.registerPasswordController,
    required this.confirmPasswordController,
    required this.loginEmailErrorText,
    required this.loginPasswordErrorText,
    required this.firstNameErrorText,
    required this.familyNameErrorText,
    required this.registerEmailErrorText,
    required this.phoneErrorText,
    required this.registerPasswordErrorText,
    required this.confirmPasswordErrorText,
    required this.onBack,
    required this.onLanguageToggle,
    required this.onCreateAccount,
    required this.onGuardianTypeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    AppBackButton(
                      onTap: onBack,
                    ),

                    const Spacer(),

                    LanguageToggle(
                      onTap: onLanguageToggle,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  isSignInSelected
                      ? context.l10n.authWelcomeBack
                      : context.l10n.authCreateAccountTitle,
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  isSignInSelected
                      ? context.l10n.authSignInSubtitle
                      : context.l10n.authRegisterSubtitle,
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
                        color: AppColors.primary.withValues(
                          alpha: 0.10,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: isSignInSelected
                      ? _SignInForm(
                          emailController: emailController,
                          passwordController: passwordController,
                          emailErrorText: loginEmailErrorText,
                          passwordErrorText: loginPasswordErrorText,
                          isLoading: controller.isSubmitting,
                          onSubmit: onSubmit,
                        )
                      : _RegisterForm(
                          guardianType: guardianType,
                          firstNameController: firstNameController,
                          familyNameController: familyNameController,
                          registerEmailController:
                              registerEmailController,
                          phoneController: phoneController,
                          registerPasswordController:
                              registerPasswordController,
                          confirmPasswordController:
                              confirmPasswordController,
                          firstNameErrorText: firstNameErrorText,
                          familyNameErrorText: familyNameErrorText,
                          registerEmailErrorText:
                              registerEmailErrorText,
                          phoneErrorText: phoneErrorText,
                          registerPasswordErrorText:
                              registerPasswordErrorText,
                          confirmPasswordErrorText:
                              confirmPasswordErrorText,
                          isLoading: controller.isSubmitting,
                          onGuardianTypeChanged:
                              onGuardianTypeChanged,
                          onSubmit: onSubmit,
                        ),
                ),

                if (isSignInSelected) ...[
                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    context.l10n.authNoAccount,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: onCreateAccount,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        context.l10n.authCreateAccountButton,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final String? emailErrorText;
  final String? passwordErrorText;

  final bool isLoading;
  final Future<void> Function() onSubmit;

  const _SignInForm({
    required this.emailController,
    required this.passwordController,
    required this.emailErrorText,
    required this.passwordErrorText,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppTextField(
          label: context.l10n.email,
          hint: context.l10n.authEnterEmail,
          icon: Icons.email_outlined,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: emailErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: context.l10n.password,
          hint: context.l10n.authEnterPassword,
          icon: Icons.lock_outline,
          isPassword: true,
          controller: passwordController,
          errorText: passwordErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppButton(
          text: context.l10n.authSignInButton,
          onPressed: onSubmit,
          isLoading: isLoading,
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

class _RegisterForm extends StatelessWidget {
  final String guardianType;

  final TextEditingController firstNameController;
  final TextEditingController familyNameController;
  final TextEditingController registerEmailController;
  final TextEditingController phoneController;
  final TextEditingController registerPasswordController;
  final TextEditingController confirmPasswordController;

  final String? firstNameErrorText;
  final String? familyNameErrorText;
  final String? registerEmailErrorText;
  final String? phoneErrorText;
  final String? registerPasswordErrorText;
  final String? confirmPasswordErrorText;

  final bool isLoading;

  final ValueChanged<String> onGuardianTypeChanged;
  final Future<void> Function() onSubmit;

  const _RegisterForm({
    required this.guardianType,
    required this.firstNameController,
    required this.familyNameController,
    required this.registerEmailController,
    required this.phoneController,
    required this.registerPasswordController,
    required this.confirmPasswordController,
    required this.firstNameErrorText,
    required this.familyNameErrorText,
    required this.registerEmailErrorText,
    required this.phoneErrorText,
    required this.registerPasswordErrorText,
    required this.confirmPasswordErrorText,
    required this.isLoading,
    required this.onGuardianTypeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ParentGenderToggle(
          selectedType: guardianType,
          onTypeSelected: onGuardianTypeChanged,
        ),

        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: context.l10n.firstName,
          hint: context.l10n.authEnterFirstName,
          icon: Icons.person_outline,
          controller: firstNameController,
          errorText: firstNameErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: context.l10n.familyName,
          hint: context.l10n.authEnterFamilyName,
          icon: Icons.person_outline,
          controller: familyNameController,
          errorText: familyNameErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: context.l10n.email,
          hint: context.l10n.authEnterEmail,
          icon: Icons.email_outlined,
          controller: registerEmailController,
          keyboardType: TextInputType.emailAddress,
          errorText: registerEmailErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: context.l10n.phoneNumber,
          hint: context.l10n.authEnterPhone,
          icon: Icons.phone_outlined,
          controller: phoneController,
          keyboardType: TextInputType.phone,
          errorText: phoneErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: context.l10n.password,
          hint: context.l10n.authEnterPassword,
          icon: Icons.lock_outline,
          isPassword: true,
          controller: registerPasswordController,
          errorText: registerPasswordErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: context.l10n.confirmPassword,
          hint: context.l10n.authConfirmPasswordHint,
          icon: Icons.lock_outline,
          isPassword: true,
          controller: confirmPasswordController,
          errorText: confirmPasswordErrorText,
        ),

        const SizedBox(height: AppSpacing.lg),

        AppButton(
          text: context.l10n.next,
          onPressed: onSubmit,
          isLoading: isLoading,
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