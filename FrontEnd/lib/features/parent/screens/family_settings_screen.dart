import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';

// Family Settings screen (Screen 19).
//
// This first pass is static/placeholder only: the family name and
// guardians below are hardcoded, and the invite button doesn't send
// anything real yet (see the TODO comment). No backend calls happen here.
class FamilySettingsScreen extends StatefulWidget {
  const FamilySettingsScreen({super.key});

  @override
  State<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {
  final TextEditingController familyNameController = TextEditingController(
    text:
        'منزل user', // Placeholder family name; will be replaced with real data later.
  );
  final TextEditingController inviteEmailController = TextEditingController();

  @override
  void dispose() {
    familyNameController.dispose();
    inviteEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'إعدادات العائلة',
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),
                    _RoundBackButton(onTap: () => Navigator.pop(context)),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                const _FieldLabel('اسم العائلة'),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: familyNameController,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(
                        Icons.home_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                const _FieldLabel('أولياء الأمور'),

                const SizedBox(height: AppSpacing.sm),

                const _GuardianCard(
                  name: 'نورة الجهني',
                  subtitle: 'أنت . ام',
                  subtitleColor: Color(0xFFC08A3E),
                  avatarColor: AppColors.primaryLight,
                  iconColor: AppColors.primary,
                  tag: _OwnerTag(),
                ),

                const SizedBox(height: AppSpacing.sm),

                const _GuardianCard(
                  name: 'مشعل الجهني',
                  subtitle: 'اب',
                  subtitleColor: AppColors.textSecondary,
                  avatarColor: Color(0xFFDCEBFB),
                  iconColor: Color(0xFF4A90D9),
                  tag: _VerifiedTag(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // TODO: Replace this empty state with real pending
                // invitation cards (and the accept/reject popup) once
                // backend integration is ready.
                const _PendingInvitationsSection(),

                const SizedBox(height: AppSpacing.xl),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'دعوة ولي أمر آخر',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: inviteEmailController,
                                keyboardType: TextInputType.emailAddress,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                decoration: const InputDecoration(
                                  hintText: 'البريد الإلكتروني لولي الأمر',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(
                              Icons.mail_outline,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      AppButton(
                        text: 'إرسال دعوة',
                        onPressed: () {
                          // TODO: Send the real invitation email once
                          // backend integration is ready.
                        },
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.primaryGradient,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      const Text(
                        'سيصل رابط الدعوة عبر البريد الإلكتروني',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Round back button in the top-right corner, same style as other screens.
class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

// A bold label shown above a field or section, right-aligned to match
// the Arabic layout used across the app.
class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// One row in the "أولياء الأمور" (Guardians) list: a status tag on the
// left, the name and subtitle in the middle, and an avatar on the right.
class _GuardianCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final Color subtitleColor;
  final Color avatarColor;
  final Color iconColor;
  final Widget tag;

  const _GuardianCard({
    required this.name,
    required this.subtitle,
    required this.subtitleColor,
    required this.avatarColor,
    required this.iconColor,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          tag,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: iconColor, size: 20),
          ),
        ],
      ),
    );
  }
}

// The "مالكة" (Owner) pill shown next to the parent who owns the family.
class _OwnerTag extends StatelessWidget {
  const _OwnerTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF0E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'مالكة',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
        ),
      ),
    );
  }
}

// The small green checkmark shown next to a guardian who already
// accepted their invite.
class _VerifiedTag extends StatelessWidget {
  const _VerifiedTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 16),
    );
  }
}

// The "الدعوات المعلّقة" (Pending Invitations) section. This is just an
// empty state for now — no real invitations exist yet, so there is
// nothing tappable here. Once backend integration is ready, this will
// be replaced with real invitation cards and an accept/reject popup.
class _PendingInvitationsSection extends StatelessWidget {
  const _PendingInvitationsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('الدعوات المعلّقة'),

        const SizedBox(height: AppSpacing.sm),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Text(
                'لا توجد دعوات معلّقة حاليًا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'ستظهر هنا الدعوات عند وصولها',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
