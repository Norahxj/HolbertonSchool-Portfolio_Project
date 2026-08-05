import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/user_model.dart';

class ProfileBanner extends StatelessWidget {
  final UserModel user;
  final bool isArabic;

  const ProfileBanner({super.key, required this.user, required this.isArabic});

  String get _roleLabel {
    switch (user.guardianType.toUpperCase()) {
      case 'MOTHER':
        return isArabic ? 'أم' : 'Mother';

      case 'FATHER':
        return isArabic ? 'أب' : 'Father';

      default:
        return isArabic ? 'ولي الأمر' : 'Guardian';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.firstName} ${user.lastName}';

    return Container(
      width: double.infinity,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // الخلفية البنفسجية
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFA875F3),
                      Color(0xFF8A5DE4),
                      Color(0xFF7046CC),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              top: -55,
              right: isArabic ? 85 : null,
              left: isArabic ? null : 85,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),

            Positioned(
              top: 18,
              left: isArabic ? 85 : null,
              right: isArabic ? null : 85,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),

            Positioned(
              top: 17,
              right: isArabic ? 16 : null,
              left: isArabic ? null : 16,
              child: const BannerDots(),
            ),

            Positioned(
              top: 32,
              right: isArabic ? 105 : null,
              left: isArabic ? null : 105,
              child: Icon(
                Icons.auto_awesome,
                size: 19,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),

            Positioned(
              top: 82,
              left: isArabic ? 150 : null,
              right: isArabic ? null : 150,
              child: Icon(
                Icons.star_rounded,
                size: 15,
                color: Colors.white.withValues(alpha: 0.32),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 55,
              child: ClipPath(
                clipper: BackWaveClipper(),
                child: Container(
                  color: const Color(0xFFC5A5FA).withValues(alpha: 0.55),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 42,
              child: ClipPath(
                clipper: FrontWaveClipper(),
                child: Container(
                  color: const Color(0xFFD7C1FC).withValues(alpha: 0.72),
                ),
              ),
            ),

            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Row(
                  textDirection: isArabic
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4D278F,
                            ).withValues(alpha: 0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF8051D8),
                        size: 36,
                      ),
                    ),

                    const SizedBox(width: 18),

                    Expanded(
                      child: Align(
                        alignment: isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: isArabic
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                fullName,
                                textDirection: isArabic
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                textAlign: isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Align(
                              alignment: isArabic
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.17),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.24),
                                  ),
                                ),
                                child: Text(
                                  _roleLabel,
                                  textDirection: isArabic
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
  }
}

class BannerDots extends StatelessWidget {
  const BannerDots({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 38,
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: List.generate(
          15,
          (index) => Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.28),
            ),
          ),
        ),
      ),
    );
  }
}

class BackWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.48);

    path.cubicTo(
      size.width * 0.20,
      size.height * 0.05,
      size.width * 0.40,
      size.height * 0.95,
      size.width * 0.62,
      size.height * 0.48,
    );

    path.cubicTo(
      size.width * 0.78,
      size.height * 0.12,
      size.width * 0.90,
      size.height * 0.20,
      size.width,
      size.height * 0.58,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class FrontWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height * 0.55);

    path.cubicTo(
      size.width * 0.18,
      size.height * 0.22,
      size.width * 0.34,
      size.height * 0.95,
      size.width * 0.54,
      size.height * 0.65,
    );

    path.cubicTo(
      size.width * 0.74,
      size.height * 0.35,
      size.width * 0.86,
      size.height * 0.30,
      size.width,
      size.height * 0.68,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
