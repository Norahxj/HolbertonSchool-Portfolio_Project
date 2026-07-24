import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/user_model.dart';
import '../../../services/user_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserApiService _userApiService = UserApiService();

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  UserModel? _user;

  bool _isLoading = true;
  bool _isSaving = false;

  String? _pageError;

  @override
  void initState() {
    super.initState();

    _loadUser();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _pageError = null;
    });

    try {
      final user = await _userApiService.getCurrentUser();

      if (!mounted) return;

      firstNameController.text = user.firstName;

      lastNameController.text = user.lastName;

      emailController.text = user.email;

      phoneController.text = user.phone;

      setState(() {
        _user = user;
        _isLoading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;

      setState(() {
        _pageError =
            _readBackendMessage(error) ?? 'تعذّر تحميل بيانات الملف الشخصي.';

        _isLoading = false;
      });

      debugPrint(
        'Loading profile failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _pageError = 'تعذّر تحميل بيانات الملف الشخصي.';

        _isLoading = false;
      });

      debugPrint('Loading profile failed: $error');
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    final firstName = firstNameController.text.trim();

    final lastName = lastNameController.text.trim();

    final email = emailController.text.trim().toLowerCase();

    final phone = phoneController.text.trim();

    if (firstName.length < 2) {
      _showMessage('يجب أن يتكون الاسم الأول من حرفين على الأقل.');
      return;
    }

    if (lastName.length < 2) {
      _showMessage('يجب أن يتكون اسم العائلة من حرفين على الأقل.');
      return;
    }

    if (!email.contains('@')) {
      _showMessage('يرجى إدخال بريد إلكتروني صحيح.');
      return;
    }

    if (phone.isEmpty) {
      _showMessage('يرجى إدخال رقم الجوال.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedUser = await _userApiService.updateCurrentUser(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ التغييرات بنجاح ✓')));

      // Return the updated user to MoreSettingsScreen.
      Navigator.pop(context, updatedUser);
    } on DioException catch (error) {
      if (!mounted) return;

      _showMessage(_readBackendMessage(error) ?? 'تعذّر حفظ التغييرات.');

      debugPrint(
        'Updating profile failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      if (!mounted) return;

      _showMessage('حدث خطأ أثناء حفظ التغييرات.');

      debugPrint('Updating profile failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return null;
    }

    final errorMessage = data['error']?.toString();

    if (errorMessage == 'Email already registered') {
      return 'البريد الإلكتروني مستخدم بالفعل.';
    }

    if (errorMessage == 'Phone number already used') {
      return 'رقم الجوال مستخدم بالفعل.';
    }

    if (errorMessage != null) {
      return errorMessage;
    }

    final errors = data['errors'];

    if (errors is Map && errors.isNotEmpty) {
      final firstError = errors.values.first;

      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }

      return firstError.toString();
    }

    return data['message']?.toString();
  }

  String _guardianTypeLabel(String guardianType) {
    switch (guardianType.toUpperCase()) {
      case 'MOTHER':
        return 'أم';

      case 'FATHER':
        return 'أب';

      default:
        return 'ولي أمر';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _pageError != null
              ? _ProfileErrorState(message: _pageError!, onRetry: _loadUser)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 44),

                          Expanded(
                            child: Center(
                              child: Text(
                                'الملف الشخصي',
                                style: AppTextStyles.arabicTitle,
                              ),
                            ),
                          ),

                          _RoundBackButton(
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.primaryDark,
                            size: 48,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      const _FieldLabel('الاسم الأول'),

                      const SizedBox(height: AppSpacing.sm),

                      _ProfileTextField(
                        controller: firstNameController,
                        trailingIcon: Icons.person_outline,
                        textDirection: TextDirection.rtl,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      const _FieldLabel('اسم العائلة'),

                      const SizedBox(height: AppSpacing.sm),

                      _ProfileTextField(
                        controller: lastNameController,
                        trailingIcon: Icons.person_outline,
                        textDirection: TextDirection.rtl,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      const _FieldLabel('البريد الإلكتروني'),

                      const SizedBox(height: AppSpacing.sm),

                      _ProfileTextField(
                        controller: emailController,
                        trailingIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      const _FieldLabel('رقم الجوال'),

                      const SizedBox(height: AppSpacing.sm),

                      _ProfileTextField(
                        controller: phoneController,
                        trailingIcon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      const _FieldLabel('صلتي بالأسرة'),

                      const SizedBox(height: AppSpacing.sm),

                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _guardianTypeLabel(_user!.guardianType),
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(width: AppSpacing.sm),

                            const Icon(
                              Icons.escalator_warning,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      AppButton(
                        text: _isSaving ? 'جارٍ الحفظ...' : 'حفظ التغييرات',
                        onPressed: _isSaving ? null : _saveChanges,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.primaryGradient,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? trailingIcon;
  final TextInputType keyboardType;
  final TextDirection textDirection;

  const _ProfileTextField({
    required this.controller,
    this.trailingIcon,
    this.keyboardType = TextInputType.text,
    required this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.edit_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              textDirection: textDirection,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          if (trailingIcon != null) ...[
            const SizedBox(width: AppSpacing.sm),

            Icon(trailingIcon, size: 18, color: AppColors.textSecondary),
          ],
        ],
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ProfileErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),

            const SizedBox(height: AppSpacing.sm),

            ElevatedButton(
              onPressed: onRetry,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
