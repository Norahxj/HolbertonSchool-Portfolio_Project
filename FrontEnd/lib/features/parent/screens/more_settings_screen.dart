import 'package:flutter/material.dart';

import '../../../app.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/user_model.dart';
import '../../../services/user_api_service.dart';
import '../../auth/services/auth_api_service.dart';
import 'family_settings_screen.dart';
import 'profile_screen.dart';

class MoreSettingsScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const MoreSettingsScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });

  @override
  State<MoreSettingsScreen> createState() =>
      _MoreSettingsScreenState();
}

class _MoreSettingsScreenState
    extends State<MoreSettingsScreen> {
  late Future<UserModel> _userFuture;

  @override
  void initState() {
    super.initState();

    _userFuture =
        UserApiService().getCurrentUser();
  }

  Future<void> _reloadUser() async {
    final future =
        UserApiService().getCurrentUser();

    setState(() {
      _userFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // FutureBuilder displays the error state.
    }
  }

  Future<void> _openProfileScreen() async {
    final updatedUser =
        await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (_) =>
             ProfileScreen(isArabic: widget.isArabic,),
      ),
    );

    if (!mounted) return;

    if (updatedUser != null) {
      setState(() {
        _userFuture =
            Future.value(updatedUser);
      });
    } else {
      await _reloadUser();
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic
              ? 'هذه الميزة ستكون متاحة قريبًا.'
              : 'This feature is coming soon.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = widget.isArabic;

    return Scaffold(
      body: Directionality(
        textDirection: isArabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: ScreenBackground(
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _reloadUser,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child:
                    FutureBuilder<UserModel>(
                  future: _userFuture,
                  builder: (
                    context,
                    snapshot,
                  ) {
                    if (snapshot
                            .connectionState ==
                        ConnectionState.waiting) {
                      return SizedBox(
                        height:
                            MediaQuery.sizeOf(
                                  context,
                                ).height *
                                0.65,
                        child: const Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData) {
                      return _SettingsErrorState(
                        isArabic: isArabic,
                        onRetry: _reloadUser,
                      );
                    }

                    final user =
                        snapshot.data!;

                    return Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .stretch,
                      children: [
                        Text(
                          isArabic
                              ? 'المزيد'
                              : 'More',
                          textAlign:
                              TextAlign.center,
                          style:
                              AppTextStyles
                                  .arabicTitle,
                        ),

                        const SizedBox(
                          height:
                              AppSpacing.lg,
                        ),

                        _ProfileBanner(
                          user: user,
                          isArabic:
                              isArabic,
                        ),

                        const SizedBox(
                          height:
                              AppSpacing.lg,
                        ),

                        _SettingsCard(
                          isArabic:
                              isArabic,
                          onLanguageToggle:
                              widget
                                  .onLanguageToggle,
                          onProfileTap:
                              _openProfileScreen,
                          onComingSoon:
                              _showComingSoon,
                        ),

                        const SizedBox(
                          height:
                              AppSpacing.xl,
                        ),

                        _LogoutButton(
                          isArabic:
                              isArabic,
                        ),

                        const SizedBox(
                          height:
                              AppSpacing.md,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  final UserModel user;
  final bool isArabic;

  const _ProfileBanner({
    required this.user,
    required this.isArabic,
  });

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
    final fullName =
        '${user.firstName} ${user.lastName}';

    return Container(
      width: double.infinity,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.18,
            ),
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

            // دائرة شفافة كبيرة أعلى الكارد
            Positioned(
              top: -55,
              right: isArabic ? 85 : null,
              left: isArabic ? null : 85,
              child: Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.06,
                  ),
                ),
              ),
            ),

            // دائرة صغيرة شفافة
            Positioned(
              top: 18,
              left: isArabic ? 85 : null,
              right: isArabic ? null : 85,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
            ),

            // نقاط زخرفية بالخلفية
            Positioned(
              top: 17,
              right: isArabic ? 16 : null,
              left: isArabic ? null : 16,
              child: const _BannerDots(),
            ),

            // نجمة زخرفية
            Positioned(
              top: 32,
              right: isArabic ? 105 : null,
              left: isArabic ? null : 105,
              child: Icon(
                Icons.auto_awesome,
                size: 19,
                color: Colors.white.withValues(
                  alpha: 0.55,
                ),
              ),
            ),

            // نجمة أخرى صغيرة
            Positioned(
              top: 82,
              left: isArabic ? 150 : null,
              right: isArabic ? null : 150,
              child: Icon(
                Icons.star_rounded,
                size: 15,
                color: Colors.white.withValues(
                  alpha: 0.32,
                ),
              ),
            ),

            // التموج الخلفي
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 55,
              child: ClipPath(
                clipper: _BackWaveClipper(),
                child: Container(
                  color: const Color(0xFFC5A5FA)
                      .withValues(alpha: 0.55),
                ),
              ),
            ),

            // التموج الأمامي
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 42,
              child: ClipPath(
                clipper: _FrontWaveClipper(),
                child: Container(
                  color: const Color(0xFFD7C1FC)
                      .withValues(alpha: 0.72),
                ),
              ),
            ),

            // الاسم والافتار
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
                    // الافتار
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: 0.65,
                          ),
                          width: 5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4D278F)
                                .withValues(alpha: 0.22),
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
              color: Colors.white.withValues(
                alpha: 0.17,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.24,
                ),
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
        children: List.generate(
          15,
          (index) => Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: 0.28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackWaveClipper extends CustomClipper<Path> {
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
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) {
    return false;
  }
}

class _FrontWaveClipper extends CustomClipper<Path> {
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
  bool shouldReclip(
    covariant CustomClipper<Path> oldClipper,
  ) {
    return false;
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;
  final VoidCallback onProfileTap;
  final VoidCallback onComingSoon;

  const _SettingsCard({
    required this.isArabic,
    required this.onLanguageToggle,
    required this.onProfileTap,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius:
            BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary
                .withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.person_outline,
            label: isArabic
                ? 'الملف الشخصي'
                : 'Personal profile',
            isArabic: isArabic,
            onTap: onProfileTap,
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          _SettingsRow(
            icon: Icons.home_outlined,
            label: isArabic
                ? 'إعدادات العائلة'
                : 'Family settings',
            isArabic: isArabic,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                       FamilySettingsScreen(isArabic: isArabic,),
                ),
              );
            },
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          _LanguageRow(
            isArabic: isArabic,
            onTap: onLanguageToggle,
            
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          _SettingsRow(
            icon:
                Icons.notifications_none,
            label: isArabic
                ? 'الإشعارات'
                : 'Notifications',
            isArabic: isArabic,
            showComingSoon: true,
            onTap: onComingSoon,
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          _SettingsRow(
            icon: Icons.help_outline,
            label: isArabic
                ? 'المساعدة والدعم'
                : 'Help and support',
            isArabic: isArabic,
            showComingSoon: true,
            onTap: onComingSoon,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showComingSoon;
  final bool isArabic;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isArabic,
    this.showComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          textDirection: isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                icon,
                color:
                    AppColors.primaryDark,
                size: 20,
              ),
            ),

            const SizedBox(
              width: AppSpacing.md,
            ),

            Expanded(
              child: Row(
                textDirection: isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: isArabic
                          ? TextAlign.right
                          : TextAlign.left,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  ),

                  if (showComingSoon) ...[
                    const SizedBox(
                      width:
                          AppSpacing.sm,
                    ),

                    _ComingSoonTag(
                      isArabic:
                          isArabic,
                    ),
                  ],
                ],
              ),
            ),

            Icon(
  isArabic
      ? Icons.chevron_right
      : Icons.chevron_left,
  color: AppColors.textSecondary,
  size: 20,
),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonTag extends StatelessWidget {
  final bool isArabic;

  const _ComingSoonTag({
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        isArabic ? 'قريبًا' : 'Soon',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: onTap,
    child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          textDirection: isArabic
              ? TextDirection.rtl
              : TextDirection.ltr,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons.language,
                color:
                    AppColors.primaryDark,
                size: 20,
              ),
            ),
            

            const SizedBox(
              width: AppSpacing.md,
            ),

            Expanded(
              child: Text(
                isArabic
                    ? 'اللغة'
                    : 'Language',
                textAlign: isArabic
                    ? TextAlign.right
                    : TextAlign.left,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      AppColors.textPrimary,
                ),
              ),
            ),
            


            

            _LanguageToggle(
              isArabic: isArabic,
              onTap: onTap,
            ),
          ],
        ),
      ),
       ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool isArabic;
   final VoidCallback onTap;

  const _LanguageToggle({
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.ltr,
        children: [
          _LanguageChoice(
            text: 'ع',
            isSelected: isArabic,
          ),
          const SizedBox(width: 5),
          _LanguageChoice(
            text: 'EN',
            isSelected: !isArabic,
          ),
        ],
      ),
      ),
  ),
    );
    
  }
}

class _LanguageChoice
    extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _LanguageChoice({
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 26,
        minHeight: 26,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSelected
              ? Colors.white
              : AppColors.primaryDark,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isArabic;

  const _LogoutButton({
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await AuthApiService().logout();

        if (!context.mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const AsalahApp(),
          ),
          (route) => false,
        );
      },
      child: Row(
        textDirection: isArabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.logout,
            color: AppColors.error,
            size: 18,
          ),

          const SizedBox(
            width: AppSpacing.sm,
          ),

          Text(
            isArabic
                ? 'تسجيل الخروج'
                : 'Log out',
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

class _SettingsErrorState
    extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function() onRetry;

  const _SettingsErrorState({
    required this.isArabic,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:
          MediaQuery.sizeOf(context)
                  .height *
              0.65,
      child: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Text(
              isArabic
                  ? 'تعذّر تحميل بيانات المستخدم.'
                  : 'Could not load user information.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.error,
              ),
            ),

            const SizedBox(
              height: AppSpacing.sm,
            ),

            ElevatedButton(
              onPressed: onRetry,
              child: Text(
                isArabic
                    ? 'إعادة المحاولة'
                    : 'Try again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}