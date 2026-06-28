import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class RoleCard extends StatelessWidget {
  final String arabicTitle;
  final String englishTitle;
  final IconData icon;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.arabicTitle,
    required this.englishTitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 210,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryLight,
                AppColors.primary,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryDark.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Icon(
                  icon,
                  size: 44,
                  color: AppColors.primaryDark,
                ),
              ),
              Column(
                children: [
                  Text(
                    arabicTitle,
                    style: AppTextStyles.cardTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    englishTitle,
                    style: AppTextStyles.cardSubtitle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
