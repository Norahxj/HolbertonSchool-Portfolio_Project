import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AuthTabSwitcher extends StatelessWidget {
  final bool isSignInSelected;
  final VoidCallback onSignInTap;
  final VoidCallback onRegisterTap;
  final bool isArabic;

  const AuthTabSwitcher({
    super.key,
    required this.isSignInSelected,
    required this.onSignInTap,
    required this.onRegisterTap,
    required this.isArabic,
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
          _TabButton(
            title: isArabic ? 'تسجيل الدخول' : 'Sign In',
            isSelected: isSignInSelected,
            onTap: onSignInTap,
          ),
          _TabButton(
            title: isArabic ? 'إنشاء حساب' : 'Register',
            isSelected: !isSignInSelected,
            onTap: onRegisterTap,
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
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
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
