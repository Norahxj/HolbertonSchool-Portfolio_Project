import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/profile_controller.dart';
import '../utils/profile_localization.dart';
import 'profile_error_state.dart';
import 'profile_field_label.dart';
import 'profile_text_field.dart';

class ProfileView extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final Future<void> Function() onReload;
  final Future<void> Function() onSave;
  final VoidCallback onBack;

  const ProfileView({
    super.key,
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

    final pageError =
        controller.pageBackendMessage ??
        controller.pageErrorCode?.localized(context);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : pageError != null
              ? ProfileErrorState(
                  message: pageError,
                  onRetry: onReload,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      AppPageHeader(
                        title: context.l10n.profile,
                        onBack: onBack,
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration:
                              const BoxDecoration(
                            color:
                                AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person,
                            color:
                                AppColors.primaryDark,
                            size: 48,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: AppSpacing.xl,
                      ),

                      ProfileFieldLabel(
                        text: context.l10n.firstName,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      ProfileTextField(
                        controller:
                            firstNameController,
                        trailingIcon:
                            Icons.person_outline,
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      ProfileFieldLabel(
                        text: context.l10n.lastName,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      ProfileTextField(
                        controller:
                            lastNameController,
                        trailingIcon:
                            Icons.person_outline,
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      ProfileFieldLabel(
                        text: context.l10n.email,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      ProfileTextField(
                        controller: emailController,
                        trailingIcon:
                            Icons.email_outlined,
                        keyboardType:
                            TextInputType.emailAddress,
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      ProfileFieldLabel(
                        text: context.l10n.phoneNumber,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      ProfileTextField(
                        controller: phoneController,
                        trailingIcon:
                            Icons.phone_outlined,
                        keyboardType:
                            TextInputType.phone,
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),

                      ProfileFieldLabel(
                        text:
                            context.l10n.familyRelationship,
                      ),

                      const SizedBox(
                        height: AppSpacing.sm,
                      ),

                      Container(
                        height: 56,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.inputBackground,
                          borderRadius:
                              BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                guardianTypeLabel(
                                  context,
                                  controller
                                      .user!
                                      .guardianType,
                                ),
                                textAlign:
                                    TextAlign.start,
                                style:
                                    const TextStyle(
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: AppSpacing.sm,
                            ),

                            const Icon(
                              Icons
                                  .escalator_warning,
                              size: 18,
                              color: AppColors
                                  .textSecondary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: AppSpacing.xxl,
                      ),

                      AppButton(
                        text: controller.isSaving
                            ? context.l10n.saving
                            : context
                                .l10n
                                .saveChanges,
                        onPressed:
                            controller.isSaving
                            ? null
                            : onSave,
                        gradient:
                            const LinearGradient(
                          begin: Alignment.topLeft,
                          end:
                              Alignment.bottomRight,
                          colors: AppColors
                              .primaryGradient,
                        ),
                      ),

                      const SizedBox(
                        height: AppSpacing.lg,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}