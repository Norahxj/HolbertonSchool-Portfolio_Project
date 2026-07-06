import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class PhoneInputField extends StatelessWidget {
  final String hint;
  final String countryCode;
  final TextEditingController? controller;

  const PhoneInputField({
    super.key,
    required this.hint,
    this.countryCode = '+966',
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 24,
            width: 1,
            color: AppColors.border,
          ),
          const SizedBox(width: 8),
          Text(
            countryCode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
