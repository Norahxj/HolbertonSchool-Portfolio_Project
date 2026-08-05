import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/profile_controller.dart';
import 'profile_error_state.dart';
import 'profile_field_label.dart';
import 'profile_text_field.dart';

class ProfileView extends StatelessWidget {
  final bool isArabic;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final Future<void> Function() onReload;
  final Future<void> Function() onSave;
  final VoidCallback onBack;

  const ProfileView({
    super.key,
    required this.isArabic,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.onReload,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.pageError != null
                ? ProfileErrorState(
                    message: controller.pageError!,
                    isArabic: isArabic,
                    onRetry: onReload,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppPageHeader(
                          isArabic: isArabic,
                          title: isArabic ? 'الملف الشخصي' : 'Profile',
                          onBack: onBack,
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

                        ProfileFieldLabel(
                          text: isArabic ? 'الاسم الأول' : 'First Name',
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        ProfileTextField(
                          controller: firstNameController,
                          trailingIcon: Icons.person_outline,
                          textDirection: TextDirection.rtl,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        ProfileFieldLabel(
                          text: isArabic ? 'اسم العائلة' : 'Last Name',
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        ProfileTextField(
                          controller: lastNameController,
                          trailingIcon: Icons.person_outline,
                          textDirection: TextDirection.rtl,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        ProfileFieldLabel(
                          text: isArabic ? 'البريد الإلكتروني' : 'Email',
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        ProfileTextField(
                          controller: emailController,
                          trailingIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        ProfileFieldLabel(
                          text: isArabic ? 'رقم الجوال' : 'Phone Number',
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        ProfileTextField(
                          controller: phoneController,
                          trailingIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        ProfileFieldLabel(
                          text: isArabic
                              ? 'صلتي بالأسرة'
                              : 'Family Relationship',
                        ),

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
                                  controller.guardianTypeLabel(
                                    controller.user!.guardianType,
                                  ),
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
                          text: controller.isSaving
                              ? (isArabic ? 'جارٍ الحفظ...' : 'Saving...')
                              : (isArabic ? 'حفظ التغييرات' : 'Save Changes'),
                          onPressed: controller.isSaving ? null : onSave,
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
      ),
    );
  }
}
