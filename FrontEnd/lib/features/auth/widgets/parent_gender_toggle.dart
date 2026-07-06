import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ParentGenderToggle extends StatelessWidget {
  final String selectedType;
  final bool isArabic;
  final ValueChanged<String> onTypeSelected;

  const ParentGenderToggle({
    super.key,
    required this.selectedType,
    required this.isArabic,
    required this.onTypeSelected,
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
            isSelected: selectedType == 'father',
            onTap: () => onTypeSelected('father'),
          ),
          _GenderOption(
            label: isArabic ? 'أم' : 'Mother',
            icon: Icons.woman,
            isSelected: selectedType == 'mother',
            onTap: () => onTypeSelected('mother'),
          ),
          _GenderOption(
            label: isArabic ? 'وصيّ' : 'Guardian',
            icon: Icons.supervisor_account,
            isSelected: selectedType == 'guardian',
            onTap: () => onTypeSelected('guardian'),
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
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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
