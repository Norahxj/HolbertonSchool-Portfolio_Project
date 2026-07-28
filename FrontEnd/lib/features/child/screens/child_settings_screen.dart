import 'package:flutter/material.dart';
import '../../../core/widgets/child_avatar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class ChildSettingsScreen extends StatefulWidget {
  final int avatarIndex;
  final String childName;
  final bool isArabic;
  final VoidCallback onLanguageToggle;
  final Future<void> Function() onLogout;

  const ChildSettingsScreen({
    super.key,
    required this.childName,
    required this.avatarIndex,
    required this.isArabic,
    required this.onLanguageToggle,
    required this.onLogout,
  });

  @override
  State<ChildSettingsScreen> createState() =>
      _ChildSettingsScreenState();
}

class _ChildSettingsScreenState
    extends State<ChildSettingsScreen> {
  late bool _isArabic;

  @override
  void initState() {
    super.initState();
    _isArabic = widget.isArabic;
  }

  void _toggleLanguage() {
    widget.onLanguageToggle();

    setState(() {
      _isArabic = !_isArabic;
    });
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection:
              _isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: AlertDialog(
            title: Text(
              _isArabic ? 'تسجيل الخروج' : 'Log out',
            ),
            content: Text(
              _isArabic
                  ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
                  : 'Are you sure you want to log out?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: Text(
                  _isArabic ? 'إلغاء' : 'Cancel',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: Text(
                  _isArabic ? 'تسجيل الخروج' : 'Log out',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout == true) {
      await widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isArabic ? 'الإعدادات' : 'Settings';
    final accountLabel =
        _isArabic ? 'حساب الطفل' : 'Child account';
    final languageLabel = _isArabic ? 'اللغة' : 'Language';
    final currentLanguage =
        _isArabic ? 'العربية' : 'English';
    final changeLanguageLabel =
        _isArabic ? 'التبديل إلى الإنجليزية' : 'Switch to Arabic';
    final logoutLabel =
        _isArabic ? 'تسجيل الخروج' : 'Log out';

    return Directionality(
      textDirection:
          _isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          title: Text(
            title,
            style: AppTextStyles.childTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 22,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  ChildAvatar(
  avatarIndex: widget.avatarIndex,
  size: 56,
),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          accountLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.childName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.language_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(languageLabel),
                    subtitle: Text(
                      '$currentLanguage · $changeLanguageLabel',
                    ),
                    trailing: const Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onTap: _toggleLanguage,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                    ),
                    title: Text(
                      logoutLabel,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: _confirmLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}