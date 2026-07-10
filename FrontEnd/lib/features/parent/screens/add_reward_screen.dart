import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';

// Add New Reward screen (Screen 16).
//
// This first pass is static/placeholder only: the text fields, icon
// choice, and weekly-renew switch are simple local state. Save just pops
// back for now. No backend calls happen here yet.
class AddRewardScreen extends StatefulWidget {
  const AddRewardScreen({super.key});

  @override
  State<AddRewardScreen> createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Which icon in the "الأيقونة" row is currently selected.
  int selectedIconIndex = 3;

  // Whether the "تتجدد أسبوعيًا" (renews weekly) switch is on.
  bool renewsWeekly = true;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
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
                          'مكافأة جديدة',
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),
                    _RoundBackButton(onTap: () => Navigator.pop(context)),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                const _FieldLabel('اسم المكافأة'),
                const SizedBox(height: AppSpacing.sm),
                _RewardTextField(
                  controller: nameController,
                  hint: 'مثال: رحلة إلى الحديقة',
                ),

                const SizedBox(height: AppSpacing.lg),

                const _FieldLabel('وصف المكافأة'),
                const SizedBox(height: AppSpacing.sm),
                _RewardTextField(
                  controller: descriptionController,
                  hint: 'مثال: زيارة نهاية الأسبوع للحديقة العامة مع العائلة',
                  maxLines: 3,
                ),

                const SizedBox(height: AppSpacing.lg),

                const _FieldLabel('الأيقونة'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _IconOption(
                      icon: Icons.favorite_border,
                      backgroundColor: const Color(0xFFFBE3EA),
                      iconColor: const Color(0xFFD1637F),
                      isSelected: selectedIconIndex == 0,
                      onTap: () {
                        setState(() {
                          selectedIconIndex = 0;
                        });
                      },
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _IconOption(
                      icon: Icons.access_time,
                      backgroundColor: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      isSelected: selectedIconIndex == 1,
                      onTap: () {
                        setState(() {
                          selectedIconIndex = 1;
                        });
                      },
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _IconOption(
                      icon: Icons.bookmark_border,
                      backgroundColor: const Color(0xFFDFF3E4),
                      iconColor: const Color(0xFF4CAF50),
                      isSelected: selectedIconIndex == 2,
                      onTap: () {
                        setState(() {
                          selectedIconIndex = 2;
                        });
                      },
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _IconOption(
                      icon: Icons.shopping_bag_outlined,
                      backgroundColor: const Color(0xFFFCE7D2),
                      iconColor: const Color(0xFFDE9A3E),
                      isSelected: selectedIconIndex == 3,
                      onTap: () {
                        setState(() {
                          selectedIconIndex = 3;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                _WeeklyRenewToggle(
                  value: renewsWeekly,
                  onChanged: (value) {
                    setState(() {
                      renewsWeekly = value;
                    });
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  text: 'حفظ المكافأة',
                  onPressed: () {
                    // TODO: Save the new reward once backend integration is
                    // ready.
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

// Round back button in the top-right corner, same style as the one used
// on the Add Child screen.
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

// A simple rounded text field used for the reward name and description.
class _RewardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _RewardTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

// One icon choice inside the "الأيقونة" row. Tapping it selects that icon
// as the reward's category, shown with a colored border.
class _IconOption extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconOption({
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: iconColor, width: 2) : null,
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}

// The "تتجدد أسبوعيًا" (renews weekly) row with its on/off switch.
class _WeeklyRenewToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _WeeklyRenewToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'تتجدد أسبوعيًا',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'تعود المكافأة كل يوم اثنين',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
