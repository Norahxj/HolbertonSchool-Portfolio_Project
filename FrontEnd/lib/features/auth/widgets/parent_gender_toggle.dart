import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ParentGenderToggle extends StatelessWidget {
  final bool isMotherSelected;
  final bool isArabic;
  final VoidCallback onFatherTap;
  final VoidCallback onMotherTap;

  const ParentGenderToggle({
    super.key,
    required this.isMotherSelected,
    required this.isArabic,
    required this.onFatherTap,
    required this.onMotherTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _GenderOption(
            label: isArabic ? 'أب' : 'Father',
            icon: Icons.man,
            isSelected: !isMotherSelected,
            onTap: onFatherTap,
          ),
          _GenderOption(
            label: isArabic ? 'أم' : 'Mother',
            icon: Icons.woman,
            isSelected: isMotherSelected,
            onTap: onMotherTap,
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
