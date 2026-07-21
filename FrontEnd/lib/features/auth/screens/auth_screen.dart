import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/services/auth_api_service.dart';
import 'package:frontend/features/auth/widgets/parent_gender_toggle.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../../parent/screens/parent_main_screen.dart';

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
  bool isLoading = false;
  bool _isArabic = true;

  String guardianType = 'mother';

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController familyNameController = TextEditingController();

  final TextEditingController registerEmailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController registerPasswordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Login errors
  String? loginEmailErrorText;
  String? loginPasswordErrorText;

  // Register errors
  String? firstNameErrorText;
  String? familyNameErrorText;
  String? registerEmailErrorText;
  String? phoneErrorText;
  String? registerPasswordErrorText;
  String? confirmPasswordErrorText;

  final AuthApiService _authApiService = AuthApiService();

  @override
  void initState() {
    super.initState();

    // Start with the language received from the previous screen.
    _isArabic = widget.isArabic;
  }

  @override
  void didUpdateWidget(covariant AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keep this screen synchronized if the language
    // is changed by another parent widget.
    if (oldWidget.isArabic != widget.isArabic) {
      _isArabic = widget.isArabic;
    }
  }

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

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
    });

    // Also update the language state in the main app.
    widget.onLanguageToggle();
  }

  void _clearErrors() {
    setState(() {
      firstNameErrorText = null;
      familyNameErrorText = null;
      registerEmailErrorText = null;
      registerPasswordErrorText = null;
      phoneErrorText = null;
      loginEmailErrorText = null;
      loginPasswordErrorText = null;
      confirmPasswordErrorText = null;
    });
  }

  Future<void> _handleMainButton() async {
    _clearErrors();

    if (isSignInSelected) {
      await _login();
    } else {
      await _register();
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _authApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      if (response.response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isArabic ? 'تم تسجيل الدخول بنجاح' : 'Login successful',
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ParentMainScreen(
              isArabic: _isArabic,
              onLanguageToggle: widget.onLanguageToggle,
            ),
          ),
        );
      }
    } on DioException catch (error) {
      if (!mounted) return;

      if (error.response?.statusCode == 400) {
        final errors = error.response?.data['errors'] as Map<String, dynamic>?;

        if (errors != null) {
          setState(() {
            loginEmailErrorText = (errors['email'] as List?)?.join('\n');

            loginPasswordErrorText = (errors['password'] as List?)?.join('\n');
          });

          return;
        }
      }

      if (error.response?.statusCode == 401) {
        final message = error.response?.data['error']?.toString();

        setState(() {
          loginEmailErrorText = message;
          loginPasswordErrorText = message;
        });

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isArabic ? 'حدث خطأ في الخادم' : 'Server error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _register() async {
    if (registerPasswordController.text != confirmPasswordController.text) {
      setState(() {
        confirmPasswordErrorText = _isArabic
            ? 'كلمتا المرور غير متطابقتين'
            : 'Passwords do not match';
      });

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await _authApiService.register(
        firstName: firstNameController.text.trim(),
        lastName: familyNameController.text.trim(),
        phone: phoneController.text.trim(),
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text,
        guardianType: guardianType,
      );

      if (!mounted) return;

      if (response.response.statusCode == 200 ||
          response.response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isArabic
                  ? 'تم إنشاء الحساب بنجاح'
                  : 'Account created successfully',
            ),
          ),
        );

        setState(() {
          isSignInSelected = true;
        });
      }
    } on DioException catch (error) {
      if (!mounted) return;

      if (error.response?.statusCode == 400) {
        final errors = error.response?.data['errors'] as Map<String, dynamic>?;

        if (errors != null) {
          setState(() {
            firstNameErrorText = errors['first_name']?.first?.toString();

            familyNameErrorText = errors['last_name']?.first?.toString();

            registerEmailErrorText = (errors['email'] as List?)?.join('\n');

            phoneErrorText = (errors['phone'] as List?)?.join('\n');

            registerPasswordErrorText = errors['password']?.first?.toString();
          });

          return;
        }
      }

      if (error.response?.statusCode == 409) {
        final message = error.response?.data['error']?.toString();

        setState(() {
          if (message == 'Email already registered') {
            registerEmailErrorText = _isArabic
                ? 'البريد الإلكتروني مسجل مسبقًا'
                : message;
          } else if (message == 'Phone number already used') {
            phoneErrorText = _isArabic ? 'رقم الجوال مستخدم مسبقًا' : message;
          } else if (message == 'Email or phone number already registered') {
            registerEmailErrorText = _isArabic
                ? 'البريد الإلكتروني أو رقم الجوال مسجل مسبقًا'
                : message;

            phoneErrorText = registerEmailErrorText;
          }
        });

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isArabic ? 'حدث خطأ في الخادم' : 'Server error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _handleBack() {
    if (isSignInSelected) {
      Navigator.pop(context);
    } else {
      setState(() {
        isSignInSelected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _isArabic;

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    AppBackButton(onTap: _handleBack),

                    const Spacer(),

                    LanguageToggle(isArabic: isArabic, onTap: _toggleLanguage),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  isSignInSelected
                      ? (isArabic ? 'مرحبًا بعودتك!' : 'Welcome back!')
                      : (isArabic ? 'إنشاء حساب جديد' : 'Create a new account'),
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

                if (isSignInSelected) ...[
                  const SizedBox(height: AppSpacing.xxl),

                  Text(
                    isArabic ? 'ليس لديك حساب؟' : "Don't have an account?",
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          isSignInSelected = false;
                        });
                      },
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
                        isArabic ? 'إنشاء حساب' : 'Create account',
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

  Widget _buildSignInForm(bool isArabic) {
    return Column(
      children: [
        AppTextField(
          label: isArabic ? 'البريد الإلكتروني' : 'Email',
          hint: isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
          icon: Icons.email_outlined,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          errorText: loginEmailErrorText,
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'كلمة المرور' : 'Password',
          hint: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: passwordController,
          errorText: loginPasswordErrorText,
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.md),

        AppButton(
          text: isArabic ? 'تسجيل الدخول' : 'Sign In',
          onPressed: _handleMainButton,
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

  Widget _buildRegisterForm(bool isArabic) {
    return Column(
      children: [
        ParentGenderToggle(
          selectedType: guardianType,
          isArabic: isArabic,
          onTypeSelected: (type) {
            setState(() {
              guardianType = type;
            });
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: isArabic ? 'الاسم الأول' : 'First name',
          hint: isArabic ? 'أدخل الاسم الأول' : 'Enter your first name',
          icon: Icons.person_outline,
          controller: firstNameController,
          errorText: firstNameErrorText,
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'اسم العائلة' : 'Family name',
          hint: isArabic ? 'أدخل اسم العائلة' : 'Enter your family name',
          icon: Icons.person_outline,
          controller: familyNameController,
          errorText: familyNameErrorText,
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'البريد الإلكتروني' : 'Email',
          hint: isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
          icon: Icons.email_outlined,
          controller: registerEmailController,
          keyboardType: TextInputType.emailAddress,
          errorText: registerEmailErrorText,
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'رقم الجوال' : 'Phone number',
          hint: isArabic ? 'أدخل رقم الجوال' : 'Enter your phone number',
          icon: Icons.phone_outlined,
          controller: phoneController,
          keyboardType: TextInputType.phone,
          errorText: phoneErrorText,
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'كلمة المرور' : 'Password',
          hint: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: registerPasswordController,
          errorText: registerPasswordErrorText,
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'تأكيد كلمة المرور' : 'Confirm password',
          hint: isArabic ? 'أعد إدخال كلمة المرور' : 'Re-enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: confirmPasswordController,
          errorText: confirmPasswordErrorText,
          isArabic: isArabic,
        ),

        const SizedBox(height: AppSpacing.lg),

        AppButton(
          text: isArabic ? 'التالي' : 'Next',
          onPressed: _handleMainButton,
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
