import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';

// Personal Profile screen (Screen 18).
//
// This first pass is static/placeholder only: the name, email, and phone
// controllers start pre-filled with placeholder text, and Save just pops
// back for now. No backend calls happen here yet. The password row from
// the mockup is left out for now to keep this screen simple.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController(
    text: 'نورة الجهني',
  );
  final TextEditingController emailController = TextEditingController(
    text: 'noura@email.com',
  );
  final TextEditingController phoneController = TextEditingController(
    text: '5X XXX XXXX',
  );

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'الملف الشخصي',
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),
                    _RoundBackButton(onTap: () => Navigator.pop(context)),
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

                const _FieldLabel('الاسم الكامل'),
                const SizedBox(height: AppSpacing.sm),
                _ProfileTextField(
                  controller: nameController,
                  trailingIcon: Icons.person_outline,
                ),

                const SizedBox(height: AppSpacing.lg),

                const _FieldLabel('البريد الإلكتروني'),
                const SizedBox(height: AppSpacing.sm),
                _ProfileTextField(
                  controller: emailController,
                  trailingIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: AppSpacing.lg),

                const _FieldLabel('رقم الجوال'),
                const SizedBox(height: AppSpacing.sm),
                _ProfileTextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: AppSpacing.lg),

                const _FieldLabel('صلتي بالأسرة'),
                const SizedBox(height: AppSpacing.sm),
                GestureDetector(
                  onTap: () {
                    // TODO: Show a real dropdown to change the family
                    // relation once that is needed.
                  },
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        Expanded(
                          child: Text(
                            'أم',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.escalator_warning,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  text: 'حفظ التغييرات',
                  onPressed: () {
                    // TODO: Save the updated profile once backend
                    // integration is ready.
                    Navigator.pop(context);
                  },
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

// Round back button in the top-right corner, same style as other screens.
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

// A bold label shown above a field, right-aligned to match the Arabic
// layout used across the app.
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// One editable-looking profile field: a small pencil icon on the leading
// edge, the value in the middle, and an optional icon on the trailing
// edge (e.g. a person or email icon).
class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? trailingIcon;
  final TextInputType keyboardType;

  const _ProfileTextField({
    required this.controller,
    this.trailingIcon,
    this.keyboardType = TextInputType.text,
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
              textDirection: TextDirection.rtl,
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
