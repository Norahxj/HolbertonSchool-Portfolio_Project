import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  final TextDirection? textDirection;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textDirection,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.md),
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
              textDirection: textDirection,
              textAlign: TextAlign.start,
              textCapitalization: textCapitalization,
              autofillHints: autofillHints,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(icon, size: 18, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
