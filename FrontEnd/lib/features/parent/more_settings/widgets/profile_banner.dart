import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/user_model.dart';
import 'profile_banner_clippers.dart';

class ProfileBanner extends StatelessWidget {
  final UserModel user;

  const ProfileBanner({super.key, required this.user});

  String _roleLabel(BuildContext context) {
    switch (user.guardianType.trim().toUpperCase()) {
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
            const Positioned.fill(child: _BannerBackground()),
            const _BannerDecorations(),
            const _BannerWaves(),
            Positioned.fill(
              child: _BannerContent(
                fullName: fullName,
                roleLabel: _roleLabel(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerBackground extends StatelessWidget {
  const _BannerBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA875F3), Color(0xFF8A5DE4), Color(0xFF7046CC)],
        ),
      ),
    );
  }
}

class _BannerDecorations extends StatelessWidget {
  const _BannerDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
        const PositionedDirectional(top: 17, start: 16, child: _BannerDots()),
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
      ],
    );
  }
}

class _BannerWaves extends StatelessWidget {
  const _BannerWaves();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 55,
          child: ClipPath(
            clipper: const BackWaveClipper(),
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
            clipper: const FrontWaveClipper(),
            child: Container(
              color: const Color(0xFFD7C1FC).withValues(alpha: 0.72),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerContent extends StatelessWidget {
  final String fullName;
  final String roleLabel;

  const _BannerContent({required this.fullName, required this.roleLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(22, 20, 22, 20),
      child: Row(
        children: [
          const _ProfileAvatar(),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _RoleTag(label: roleLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: const Color(0xFF4D278F).withValues(alpha: 0.22),
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
    );
  }
}

class _RoleTag extends StatelessWidget {
  final String label;

  const _RoleTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _BannerDots extends StatelessWidget {
  const _BannerDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 38,
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: List.generate(15, (_) {
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
