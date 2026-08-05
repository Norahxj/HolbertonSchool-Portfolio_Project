import 'package:flutter/material.dart';

import '../../../../app.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/services/auth_api_service.dart';

class LogoutButton extends StatelessWidget {
  final bool isArabic;

  const LogoutButton({super.key, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await AuthApiService().logout();

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AsalahApp()),
          (route) => false,
        );
      },
      child: Row(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout, color: AppColors.error, size: 18),

          const SizedBox(width: AppSpacing.sm),

          Text(
            isArabic ? 'تسجيل الخروج' : 'Log out',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
