import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class LanguageToggle extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const LanguageToggle({
    super.key,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              _LanguageChoice(text: 'ع', isSelected: isArabic),

              const SizedBox(width: 5),

              _LanguageChoice(text: 'EN', isSelected: !isArabic),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _LanguageChoice({required this.text, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : AppColors.primaryDark,
        ),
      ),
    );
  }
}
