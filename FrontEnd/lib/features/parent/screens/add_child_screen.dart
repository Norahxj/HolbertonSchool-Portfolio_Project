import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/screen_background.dart';

// Add Child screen (Screen 5).
//
// This first pass is static/placeholder only: avatar and date selection
// are kept as simple local state, and Save just pops back for now.
class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  int selectedAvatarIndex = 0;
  DateTime? selectedDate;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 7, now.month, now.day),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  String get _dateLabel {
    if (selectedDate == null) return 'تاريخ الميلاد';
    final d = selectedDate!;
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: _RoundIconButton(
                    icon: Icons.arrow_forward_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  'إضافة طفل',
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'أضف معلومات طفلك لبدء رحلته',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                const Text(
                  'اختر صورة رمزية',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AvatarOption(
                      icon: Icons.boy,
                      backgroundColor: const Color(0xFFD9F0DD),
                      iconColor: const Color(0xFF3E8E5A),
                      isSelected: selectedAvatarIndex == 0,
                      onTap: () => setState(() => selectedAvatarIndex = 0),
                    ),
                    _AvatarOption(
                      icon: Icons.boy,
                      backgroundColor: const Color(0xFFD7E9F7),
                      iconColor: const Color(0xFF2B6CA3),
                      isSelected: selectedAvatarIndex == 1,
                      onTap: () => setState(() => selectedAvatarIndex = 1),
                    ),
                    _AvatarOption(
                      icon: Icons.girl,
                      backgroundColor: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      isSelected: selectedAvatarIndex == 2,
                      onTap: () => setState(() => selectedAvatarIndex = 2),
                    ),
                    _AvatarOption(
                      icon: Icons.girl,
                      backgroundColor: const Color(0xFFFBE3EA),
                      iconColor: const Color(0xFFD1637F),
                      isSelected: selectedAvatarIndex == 3,
                      onTap: () => setState(() => selectedAvatarIndex = 3),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                AppTextField(
                  label: 'اسم الطفل',
                  hint: 'اسم الطفل',
                  icon: Icons.person_outline,
                  controller: nameController,
                ),

                const SizedBox(height: AppSpacing.md),

                _BirthDateField(
                  label: _dateLabel,
                  hasValue: selectedDate != null,
                  onTap: _pickDate,
                ),

                const SizedBox(height: AppSpacing.xs),

                const Text(
                  'يفتح التقويم لاختيار التاريخ',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'رقم الجوال',
                  hint: 'رقم الجوال (اختياري)',
                  icon: Icons.phone_outlined,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  text: 'حفظ',
                  onPressed: () {
                    // TODO: Save the new child once backend integration is ready.
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

class _AvatarOption extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 3)
              : null,
        ),
        child: Icon(icon, color: iconColor, size: 30),
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  final String label;
  final bool hasValue;
  final VoidCallback onTap;

  const _BirthDateField({
    required this.label,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textSecondary,
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
