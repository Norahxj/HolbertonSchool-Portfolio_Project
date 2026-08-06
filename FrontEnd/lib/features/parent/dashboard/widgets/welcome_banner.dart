import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';

class WelcomeBanner extends StatelessWidget {
  final String parentName;

  const WelcomeBanner({super.key, required this.parentName});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

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
                  flipX: isRtl,
                  child: Image.asset(
                    'assets/dashboard/family_home.png',
                    fit: BoxFit.cover,
                    alignment: isRtl
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isRtl
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
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

                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  start: 24,
                  width: bannerWidth * 0.44,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.welcome,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark.withValues(alpha: 0.75),
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        parentName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 21,
                          height: 1.15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),

                      const SizedBox(height: 9),

                      Text(
                        context.l10n.buildingWonderfulGeneration,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
