import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class WelcomeBanner extends StatelessWidget {
  final String parentName;
  final bool isArabic;

  const WelcomeBanner({
    super.key,
    required this.parentName,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bannerWidth = constraints.maxWidth;

        return Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Transform.flip(
                  flipX: isArabic,
                  child: Image.asset(
                    'assets/dashboard/family_home.png',
                    fit: BoxFit.cover,
                    alignment: isArabic
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      end: isArabic
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      colors: [
                        const Color(0xFFF7F2FB).withValues(alpha: 0.78),
                        const Color(0xFFF1E8F8).withValues(alpha: 0.55),
                        const Color(0xFFE7DAF5).withValues(alpha: 0.18),
                        const Color(0xFFF2ECF8).withValues(alpha: 0.18),
                      ],
                      stops: const [0.0, 0.30, 0.52, 0.75],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: isArabic ? 24 : null,
                  left: isArabic ? null : 24,
                  width: bannerWidth * 0.44,
                  child: Directionality(
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isArabic ? 'مرحبًا' : 'Welcome',
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark.withValues(
                              alpha: 0.75,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          parentName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 21,
                            height: 1.15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          isArabic
                              ? 'أنتِ تبنين جيلاً رائعًا'
                              : 'You are building a wonderful generation',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
