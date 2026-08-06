import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/child_form_controller.dart';
import '../utils/child_form_localization.dart';
import 'avatar_option.dart';
import 'birth_date_field.dart';

class ChildFormView extends StatelessWidget {
  final bool isEditMode;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback onBack;
  final VoidCallback onPickDate;
  final Future<void> Function() onSave;

  const ChildFormView({
    super.key,
    required this.isEditMode,
    required this.nameController,
    required this.phoneController,
    required this.onBack,
    required this.onPickDate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChildFormController>();

    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    final nameError =
        controller.nameErrorCode?.localized(context);

    final birthDateError =
        controller.birthDateErrorCode?.localized(context);

    final phoneError =
        controller.phoneErrorCode?.localized(context);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Align(
                  alignment: isArabic
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: AppBackButton(
                    isArabic: isArabic,
                    onTap: onBack,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  isEditMode
                      ? context.l10n.editChildInformation
                      : context.l10n.addChild,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arabicTitle,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  isEditMode
                      ? context.l10n.editChildSubtitle
                      : context.l10n.addChildSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  context.l10n.chooseAvatar,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AvatarOption(
                      imagePath:
                          'assets/avatars/avatar_boy_1v.jpg',
                      backgroundColor:
                          const Color(0xFFD9F0DD),
                      isSelected:
                          controller.selectedAvatarIndex == 0,
                      onTap: () {
                        controller.selectAvatar(0);
                      },
                    ),

                    AvatarOption(
                      imagePath:
                          'assets/avatars/avatar_boy_2v.jpg',
                      backgroundColor:
                          const Color(0xFFD7E9F7),
                      isSelected:
                          controller.selectedAvatarIndex == 1,
                      onTap: () {
                        controller.selectAvatar(1);
                      },
                    ),

                    AvatarOption(
                      imagePath:
                          'assets/avatars/avatar_girl_1v.jpg',
                      backgroundColor: AppColors.primaryLight,
                      isSelected:
                          controller.selectedAvatarIndex == 2,
                      onTap: () {
                        controller.selectAvatar(2);
                      },
                    ),

                    AvatarOption(
                      imagePath:
                          'assets/avatars/avatar_girl_2v.jpg',
                      backgroundColor:
                          const Color(0xFFFBE3EA),
                      isSelected:
                          controller.selectedAvatarIndex == 3,
                      onTap: () {
                        controller.selectAvatar(3);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppTextField(
                  label: context.l10n.childName,
                  hint: context.l10n.childName,
                  icon: Icons.person_outline,
                  controller: nameController,
                  errorText: nameError,
                ),

                const SizedBox(height: AppSpacing.md),

                BirthDateField(
                  label:
                      controller.formattedBirthDate ??
                      context.l10n.dateOfBirth,
                  hasValue:
                      controller.selectedBirthDate != null,
                  onTap: onPickDate,
                ),

                if (birthDateError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Align(
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        birthDateError,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  context.l10n.openCalendarToSelectDate,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: context.l10n.phoneNumberOptional,
                  hint: '05XXXXXXXX',
                  icon: Icons.phone_outlined,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  errorText: phoneError,
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  text: controller.isSaving
                      ? context.l10n.saving
                      : isEditMode
                      ? context.l10n.saveChanges
                      : context.l10n.save,
                  onPressed:
                      controller.isSaving ? null : onSave,
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