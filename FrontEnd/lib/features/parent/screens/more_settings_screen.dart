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
  final VoidCallback? onLanguageToggle;

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
            const ProfileScreen(),
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
    switch (
        user.guardianType.toUpperCase()) {
      case 'MOTHER':
        return isArabic
            ? 'أم'
            : 'Mother';

      case 'FATHER':
        return isArabic
            ? 'أب'
            : 'Father';

      default:
        return isArabic
            ? 'ولي الأمر'
            : 'Guardian';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors:
              AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Row(
        textDirection: isArabic
            ? TextDirection.rtl
            : TextDirection.ltr,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.25,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(
            width: AppSpacing.md,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} '
                  '${user.lastName}',
                  textAlign: isArabic
                      ? TextAlign.right
                      : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  _roleLabel,
                  textAlign: isArabic
                      ? TextAlign.right
                      : TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final bool isArabic;
  final VoidCallback? onLanguageToggle;
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
                      const FamilySettingsScreen(),
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
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              color:
                  AppColors.textSecondary,
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
  final VoidCallback? onTap;

  const _LanguageRow({
    required this.isArabic,
    required this.onTap,
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

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 7,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color:
                    AppColors.primaryLight,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: const Row(
                textDirection:
                    TextDirection.ltr,
                children: [],
              ),
            ),

            _LanguageToggle(
              isArabic: isArabic,
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final bool isArabic;

  const _LanguageToggle({
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
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