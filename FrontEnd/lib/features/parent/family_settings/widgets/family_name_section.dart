import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'guardian_components.dart';

class FamilyNameSection extends StatelessWidget {
  final bool isArabic;
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;

  const FamilyNameSection({
    super.key,
    required this.isArabic,
    required this.controller,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FamilyFieldLabel(text: isArabic ? 'اسم العائلة' : 'Family Name'),

        const SizedBox(height: AppSpacing.sm),

        Container(
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
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              const Icon(
                Icons.home_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              isSaving
                  ? (isArabic ? 'جارٍ الحفظ...' : 'Saving...')
                  : (isArabic ? 'حفظ الاسم' : 'Save Name'),
            ),
          ),
        ),
      ],
    );
  }
}
