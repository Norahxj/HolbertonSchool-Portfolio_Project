import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/user_model.dart';

class ProfileBanner extends StatelessWidget {
  final UserModel user;

  const ProfileBanner({super.key, required this.user});

  String _roleLabel(BuildContext context) {
    switch (user.guardianType.toUpperCase()) {
      case 'MOTHER':
        return context.l10n.mother;

      case 'FATHER':
        return context.l10n.father;

      default:
        return context.l10n.guardian;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();

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

            PositionedDirectional(
              top: -55,
              start: 85,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),

            PositionedDirectional(
              top: 18,
              end: 85,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            ),

            const PositionedDirectional(
              top: 17,
              start: 16,
              child: BannerDots(),
            ),

            PositionedDirectional(
              top: 32,
              start: 105,
              child: Icon(
                Icons.auto_awesome,
                size: 19,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),

            PositionedDirectional(
              top: 82,
              end: 150,
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
                        alignment: AlignmentDirectional.centerStart,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                fullName,
                                textAlign: TextAlign.start,
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
                              alignment: AlignmentDirectional.centerStart,
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
                                  _roleLabel(context),
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
        children: List.generate(15, (index) {
          return Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.28),
            ),
          );
        }),
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
