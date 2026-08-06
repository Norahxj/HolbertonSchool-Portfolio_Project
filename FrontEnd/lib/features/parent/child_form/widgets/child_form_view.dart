import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/child_form_controller.dart';
import 'avatar_option.dart';
import 'birth_date_field.dart';

class ChildFormView extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final VoidCallback onBack;
  final VoidCallback onPickDate;
  final Future<void> Function() onSave;

  const ChildFormView({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.onBack,
    required this.onPickDate,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChildFormController>();

    final isArabic = controller.isArabic;
    final isEditMode = controller.isEditMode;

    String tr(String arabic, String english) {
      return isArabic ? arabic : english;
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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
                    child: AppBackButton(isArabic: isArabic, onTap: onBack),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    isEditMode
                        ? tr('تعديل بيانات الطفل', 'Edit Child Information')
                        : tr('إضافة طفل', 'Add Child'),
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    isEditMode
                        ? tr(
                            'عدّل معلومات الطفل ثم اضغط حفظ',
                            'Update the child information, then save',
                          )
                        : tr(
                            'أضف معلومات طفلك لبدء رحلته',
                            'Add your child’s information to begin their journey',
                          ),
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    tr('اختر صورة رمزية', 'Choose an avatar'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AvatarOption(
                        imagePath: 'assets/avatars/avatar_boy_1v.jpg',
                        backgroundColor: const Color(0xFFD9F0DD),
                        isSelected: controller.selectedAvatarIndex == 0,
                        onTap: () {
                          controller.selectAvatar(0);
                        },
                      ),
                      AvatarOption(
                        imagePath: 'assets/avatars/avatar_boy_2v.jpg',
                        backgroundColor: const Color(0xFFD7E9F7),
                        isSelected: controller.selectedAvatarIndex == 1,
                        onTap: () {
                          controller.selectAvatar(1);
                        },
                      ),
                      AvatarOption(
                        imagePath: 'assets/avatars/avatar_girl_1v.jpg',
                        backgroundColor: AppColors.primaryLight,
                        isSelected: controller.selectedAvatarIndex == 2,
                        onTap: () {
                          controller.selectAvatar(2);
                        },
                      ),
                      AvatarOption(
                        imagePath: 'assets/avatars/avatar_girl_2v.jpg',
                        backgroundColor: const Color(0xFFFBE3EA),
                        isSelected: controller.selectedAvatarIndex == 3,
                        onTap: () {
                          controller.selectAvatar(3);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    label: tr('اسم الطفل', 'Child name'),
                    hint: tr('اسم الطفل', 'Child name'),
                    icon: Icons.person_outline,
                    controller: nameController,
                    errorText: controller.nameError,
                    isArabic: isArabic,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  BirthDateField(
                    label: controller.birthDateLabel,
                    hasValue: controller.selectedBirthDate != null,
                    onTap: onPickDate,
                  ),

                  if (controller.birthDateError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          controller.birthDateError!,
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    tr(
                      'يفتح التقويم لاختيار التاريخ',
                      'Open the calendar to select a date',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: tr(
                      'رقم الجوال (اختياري)',
                      'Phone number (optional)',
                    ),
                    hint: '05XXXXXXXX',
                    icon: Icons.phone_outlined,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    errorText: controller.phoneError,
                    isArabic: isArabic,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  AppButton(
                    text: controller.isSaving
                        ? tr('جارٍ الحفظ...', 'Saving...')
                        : isEditMode
                        ? tr('حفظ التعديلات', 'Save Changes')
                        : tr('حفظ', 'Save'),
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
