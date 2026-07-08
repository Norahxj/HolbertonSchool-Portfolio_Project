import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/language_toggle.dart';
import '../../../core/widgets/screen_background.dart';
import '../widgets/parent_gender_toggle.dart';
import '../widgets/phone_input_field.dart';
import '../../../services/auth_api_service.dart';
import '../../parent/screens/parent_dashboard_screen.dart';
import 'package:dio/dio.dart';

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
  
  String? emailErrorText;
  String? passwordErrorText;
  String? firstNameErrorText;
  String? familyNameErrorText;
  String? registerEmailErrorText;
  String? phoneErrorText;
  
  
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

  Future<void> _handleMainButton() async {
    try {
      if (isSignInSelected) {
        final response = await _authApiService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Success")),
          );
          print("GOING TO DASHBOARD");
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ParentDashboardScreen(),
            ),
          );
        }
      } else {
        if (registerPasswordController.text != confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Passwords do not match"),
            ),
          );
          return;
        }

        final response = await _authApiService.register(
          firstName: firstNameController.text.trim(),
          lastName: familyNameController.text.trim(),
          phone: phoneController.text.trim(),
          email: registerEmailController.text.trim(),
          password: registerPasswordController.text,
          guardianType: guardianType,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Register Success"),
            ),
          );

          setState(() {
            isSignInSelected = true;
          });
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data["errors"] as Map<String, dynamic>?;


        if (errors != null) {
          setState(() {
            emailErrorText = errors['email']?.join(', ');
            passwordErrorText = errors['password']?.join(', ');
            firstNameErrorText = errors['first_name']?.join(', ');
            familyNameErrorText = errors['last_name']?.join(', ');
            registerEmailErrorText = errors['email']?.join(', ');
            phoneErrorText = errors['phone']?.join(', ');
          });
          return;
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server Error")),
      );
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
          errorText: emailErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'كلمة المرور' : 'Password',
          hint: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: passwordController,
          errorText: passwordErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppButton(
          text: isArabic ? 'تسجيل الدخول' : 'Sign In',
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

  Widget _buildRegisterForm(bool isArabic) {
    return Column(
      children: [
        ParentGenderToggle(
          selectedType: guardianType,
          isArabic: isArabic,
          onTypeSelected: (type) => setState(() => guardianType = type),
        ),

        const SizedBox(height: AppSpacing.lg),

        AppTextField(
          label: isArabic ? 'الاسم الأول' : 'First name',
          hint: isArabic ? 'الاسم الأول' : 'Enter your first name',
          icon: Icons.person_outline,
          controller: firstNameController,
          errorText: firstNameErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'اسم العائلة' : 'Family name',
          hint: isArabic ? 'اسم العائلة' : 'Enter your family name',
          icon: Icons.person_outline,
          controller: familyNameController,
          errorText: familyNameErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'البريد الإلكتروني' : 'Email',
          hint: isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
          icon: Icons.email_outlined,
          controller: registerEmailController,
          keyboardType: TextInputType.emailAddress,
          errorText: registerEmailErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        PhoneInputField(
          hint: isArabic ? 'رقم الجوال' : 'Phone number',
          controller: phoneController,
          errorText: phoneErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'كلمة المرور' : 'Password',
          hint: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: registerPasswordController,
          errorText: passwordErrorText,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          label: isArabic ? 'تأكيد كلمة المرور' : 'Confirm password',
          hint: isArabic ? 'أعد إدخال كلمة المرور' : 'Re-enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: confirmPasswordController,
          errorText: passwordErrorText,
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

  const _RoundIconButton({required this.icon, required this.onTap});

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
