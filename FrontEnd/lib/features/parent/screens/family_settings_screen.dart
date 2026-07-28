import 'package:flutter/material.dart';

import '../services/family_api_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';

class FamilySettingsScreen extends StatefulWidget {
  const FamilySettingsScreen({super.key});

  @override
  State<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {
  final FamilyApiService familyApiService = FamilyApiService();

  final TextEditingController familyNameController =
      TextEditingController();
  final TextEditingController inviteEmailController =
      TextEditingController();

  bool isLoading = true;
  bool isSavingFamilyName = false;
  bool isSendingInvitation = false;

  String? pageError;
  String? currentUserId;

  List<Map<String, dynamic>> guardians = [];
  List<Map<String, dynamic>> sentInvitations = [];

  @override
  void initState() {
    super.initState();
    _loadFamilyData();
  }

  @override
  void dispose() {
    familyNameController.dispose();
    inviteEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        pageError = null;
      });
    }

    try {
      final familyData = await familyApiService.getFamilyDetails();

      final loadedGuardians = (familyData['guardians'] as List? ?? [])
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();

      final loadedSentInvitations =
          (familyData['pending_invitations'] as List? ?? [])
              .map(
                (item) => Map<String, dynamic>.from(item as Map),
              )
              .toList();

      if (!mounted) return;

      setState(() {
        familyNameController.text =
            familyData['name']?.toString() ?? '';

        currentUserId =
            familyData['current_user_id']?.toString();

        guardians = loadedGuardians;
        sentInvitations = loadedSentInvitations;

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        pageError = familyApiService.readErrorMessage(error);
        isLoading = false;
      });
    }
  }

  Future<void> _saveFamilyName() async {
    final name = familyNameController.text.trim();

    if (name.length < 2) {
      _showMessage(
        'اسم العائلة يجب أن يكون حرفين على الأقل',
        isError: true,
      );
      return;
    }

    setState(() {
      isSavingFamilyName = true;
    });

    try {
      await familyApiService.updateFamilyName(name);

      if (!mounted) return;

      _showMessage('تم تحديث اسم العائلة');

      await _loadFamilyData();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        familyApiService.readErrorMessage(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingFamilyName = false;
        });
      }
    }
  }

  Future<void> _sendInvitation() async {
    final email =
        inviteEmailController.text.trim().toLowerCase();

    if (email.isEmpty || !email.contains('@')) {
      _showMessage(
        'اكتبي بريدًا إلكترونيًا صحيحًا',
        isError: true,
      );
      return;
    }

    setState(() {
      isSendingInvitation = true;
    });

    try {
      await familyApiService.inviteParent(email);

      inviteEmailController.clear();

      if (!mounted) return;

      _showMessage('تم إرسال الدعوة بنجاح');

      await _loadFamilyData();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        familyApiService.readErrorMessage(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSendingInvitation = false;
        });
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : AppColors.success,
      ),
    );
  }

  String _guardianTypeLabel(String type) {
    switch (type) {
      case 'father':
        return 'أب';
      case 'mother':
        return 'أم';
      case 'guardian':
        return 'ولي أمر';
      default:
        return 'ولي أمر';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    if (pageError != null) {
      return Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 42,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      pageError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: _loadFamilyData,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadFamilyData,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            'إعدادات العائلة',
                            style:
                                AppTextStyles.arabicTitle,
                          ),
                        ),
                      ),
                      _RoundBackButton(
                        onTap: () =>
                            Navigator.pop(context),
                      ),
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
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color:
                              AppColors.textSecondary,
                        ),
                        const SizedBox(
                          width: AppSpacing.sm,
                        ),
                        Expanded(
                          child: TextField(
                            controller:
                                familyNameController,
                            textAlign: TextAlign.right,
                            textDirection:
                                TextDirection.rtl,
                            style: const TextStyle(
                              color:
                                  AppColors.textPrimary,
                            ),
                            decoration:
                                const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppSpacing.sm,
                        ),
                        const Icon(
                          Icons.home_outlined,
                          size: 18,
                          color:
                              AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: isSavingFamilyName
                          ? null
                          : _saveFamilyName,
                      icon: isSavingFamilyName
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.save_outlined,
                            ),
                      label: Text(
                        isSavingFamilyName
                            ? 'جارٍ الحفظ...'
                            : 'حفظ الاسم',
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _FieldLabel('أولياء الأمور'),
                  const SizedBox(height: AppSpacing.sm),
                  if (guardians.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(
                        AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.border,
                        ),
                      ),
                      child: const Text(
                        'لا يوجد أولياء أمور',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...guardians.map((guardian) {
                      final guardianId =
                          guardian['id']?.toString();

                      final isCurrentUser =
                          guardianId == currentUserId;

                      final firstName =
                          guardian['first_name']
                                  ?.toString() ??
                              '';

                      final lastName =
                          guardian['last_name']
                                  ?.toString() ??
                              '';

                      final guardianType =
                          guardian['guardian_type']
                                  ?.toString() ??
                              '';

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: _GuardianCard(
                          name:
                              '$firstName $lastName'
                                  .trim(),
                          subtitle: isCurrentUser
                              ? 'أنت · ${_guardianTypeLabel(guardianType)}'
                              : _guardianTypeLabel(
                                  guardianType,
                                ),
                          subtitleColor:
                              isCurrentUser
                                  ? const Color(
                                      0xFFC08A3E,
                                    )
                                  : AppColors
                                      .textSecondary,
                          avatarColor:
                              AppColors.primaryLight,
                          iconColor:
                              AppColors.primary,
                          tag: isCurrentUser
                              ? const _CurrentUserTag()
                              : const _VerifiedTag(),
                        ),
                      );
                    }),
                  const SizedBox(height: AppSpacing.xl),
                  _PendingInvitationsSection(
                    invitations: sentInvitations,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(
                      AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.group_outlined,
                              color:
                                  AppColors.primaryDark,
                              size: 20,
                            ),
                            SizedBox(
                              width: AppSpacing.sm,
                            ),
                            Expanded(
                              child: Text(
                                'دعوة ولي أمر آخر',
                                textAlign:
                                    TextAlign.right,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: AppColors
                                      .textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: AppSpacing.md,
                        ),
                        Container(
                          height: 56,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal:
                                AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors
                                .inputBackground,
                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller:
                                      inviteEmailController,
                                  keyboardType:
                                      TextInputType
                                          .emailAddress,
                                  textAlign:
                                      TextAlign.right,
                                  textDirection:
                                      TextDirection.rtl,
                                  decoration:
                                      const InputDecoration(
                                    hintText:
                                        'البريد الإلكتروني لولي الأمر',
                                    border:
                                        InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: AppSpacing.sm,
                              ),
                              const Icon(
                                Icons.mail_outline,
                                size: 18,
                                color: AppColors
                                    .textSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.md,
                        ),
                        AppButton(
                          text: isSendingInvitation
                              ? 'جارٍ الإرسال...'
                              : 'إرسال دعوة',
                          onPressed:
                              isSendingInvitation
                                  ? () {}
                                  : _sendInvitation,
                          gradient:
                              const LinearGradient(
                            begin:
                                Alignment.topLeft,
                            end:
                                Alignment.bottomRight,
                            colors: AppColors
                                .primaryGradient,
                          ),
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                        const Text(
                          'يجب أن يكون لدى ولي الأمر حساب مسجل مسبقًا، وستظهر الدعوة داخل حسابه',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors
                                .textSecondary,
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
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({
    required this.onTap,
  });

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
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          tag,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color:
                          AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
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
            child: Icon(
              Icons.person,
              color: iconColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentUserTag extends StatelessWidget {
  const _CurrentUserTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF0E1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'أنت',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
        ),
      ),
    );
  }
}

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
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

class _PendingInvitationsSection
    extends StatelessWidget {
  final List<Map<String, dynamic>> invitations;

  const _PendingInvitationsSection({
    required this.invitations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel(
          'الدعوات المرسلة المعلّقة',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (invitations.isEmpty)
          Container(
            padding:
                const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius:
                  BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: const Column(
              children: [
                Text(
                  'لا توجد دعوات مرسلة معلّقة حاليًا',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ستظهر هنا الدعوات التي أرسلتها ولم تُقبل بعد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...invitations.map(
            (invitation) => Container(
              margin: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    color:
                        AppColors.textSecondary,
                  ),
                  const SizedBox(
                    width: AppSpacing.sm,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Text(
                          invitation[
                                      'invited_email']
                                  ?.toString() ??
                              '',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color:
                                AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'بانتظار قبول الدعوة',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors
                                .textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
