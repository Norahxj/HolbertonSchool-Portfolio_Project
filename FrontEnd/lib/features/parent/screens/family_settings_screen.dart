import 'package:flutter/material.dart';
import '../../../core/widgets/app_page_header.dart';
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

  bool get isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

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
  List<Map<String, dynamic>> incomingInvitations = [];

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
      final results = await Future.wait([
        familyApiService.getFamilyDetails(),
        familyApiService.getIncomingInvitations(),
      ]);

      final familyData = results[0] as Map<String, dynamic>;

      final loadedIncomingInvitations =
          results[1] as List<Map<String, dynamic>>;

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
        incomingInvitations = loadedIncomingInvitations;

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

  Future<void> _acceptInvitation(String invitationId) async {
    try {
      await familyApiService.acceptInvitation(invitationId);

      if (!mounted) return;

      _showMessage(
        isArabic
            ? 'تم قبول الدعوة والانضمام إلى العائلة'
            : 'Invitation accepted and joined the family',
      );

      await _loadFamilyData();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        familyApiService.readErrorMessage(error),
        isError: true,
      );
    }
  }

  Future<void> _rejectInvitation(String invitationId) async {
    try {
      await familyApiService.rejectInvitation(invitationId);

      if (!mounted) return;

      _showMessage(
        isArabic ? 'تم رفض الدعوة' : 'Invitation rejected',
      );

      await _loadFamilyData();
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        familyApiService.readErrorMessage(error),
        isError: true,
      );
    }
  }

  Future<void> _saveFamilyName() async {
    final name = familyNameController.text.trim();

    if (name.length < 2) {
      _showMessage(
        isArabic
            ? 'اسم العائلة يجب أن يكون حرفين على الأقل'
            : 'Family name must be at least two characters',
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

      _showMessage(
        isArabic ? 'تم تحديث اسم العائلة' : 'Family name updated',
      );

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
        isArabic
            ? 'اكتبي بريدًا إلكترونيًا صحيحًا'
            : 'Enter a valid email address',
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

      _showMessage(
        isArabic
            ? 'تم إرسال الدعوة بنجاح'
            : 'Invitation sent successfully',
      );

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
        return isArabic ? 'أب' : 'Father';
      case 'mother':
        return isArabic ? 'أم' : 'Mother';
      case 'guardian':
        return isArabic ? 'ولي أمر' : 'Guardian';
      default:
        return isArabic ? 'ولي أمر' : 'Guardian';
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
                      child: Text(
                        isArabic ? 'إعادة المحاولة' : 'Try again',
                      ),
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
                  AppPageHeader(
                    isArabic: isArabic,
  title: isArabic
      ? 'إعدادات العائلة'
      : 'Family Settings',
  onBack: () {
    Navigator.pop(context);
  },
),
                  const SizedBox(height: AppSpacing.xl),
                  _FieldLabel(
                    isArabic ? 'اسم العائلة' : 'Family Name',
                  ),
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
                            textAlign: isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            textDirection: isArabic
                                ? TextDirection.rtl
                                : TextDirection.ltr,
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
                            ? (isArabic
                                ? 'جارٍ الحفظ...'
                                : 'Saving...')
                            : (isArabic
                                ? 'حفظ الاسم'
                                : 'Save Name'),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _FieldLabel(
                    isArabic
                        ? 'أولياء الأمور'
                        : 'Guardians',
                  ),
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
                      child: Text(
                        isArabic
                            ? 'لا يوجد أولياء أمور'
                            : 'No guardians',
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
                              ? '${isArabic ? 'أنت' : 'You'} · ${_guardianTypeLabel(guardianType)}'
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
                              ? _CurrentUserTag(
                                  isArabic: isArabic,
                                )
                              : const _VerifiedTag(),
                        ),
                      );
                    }),
                  const SizedBox(height: AppSpacing.xl),
                  _PendingInvitationsSection(
                    invitations: sentInvitations,
                    isArabic: isArabic,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  _IncomingInvitationsSection(
                    invitations: incomingInvitations,
                    onAccept: _acceptInvitation,
                    onReject: _rejectInvitation,
                    isArabic: isArabic,
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
                        Row(
                          children: [
                            const Icon(
                              Icons.group_outlined,
                              color:
                                  AppColors.primaryDark,
                              size: 20,
                            ),
                            const SizedBox(
                              width: AppSpacing.sm,
                            ),
                            Expanded(
                              child: Text(
                                isArabic
                                    ? 'دعوة ولي أمر آخر'
                                    : 'Invite Another Guardian',
                                textAlign:
                                    TextAlign.right,
                                style: const TextStyle(
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
                                  textAlign: isArabic
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  textDirection:
                                      isArabic
                                          ? TextDirection.rtl
                                          : TextDirection.ltr,
                                  decoration:
                                      InputDecoration(
                                    hintText: isArabic
                                        ? 'البريد الإلكتروني لولي الأمر'
                                        : 'Guardian email address',
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
                              ? (isArabic
                                  ? 'جارٍ الإرسال...'
                                  : 'Sending...')
                              : (isArabic
                                  ? 'إرسال دعوة'
                                  : 'Send Invitation'),
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
                        Text(
                          isArabic
                              ? 'يجب أن يكون لدى ولي الأمر حساب مسجل مسبقًا، وستظهر الدعوة داخل حسابه'
                              : 'The guardian must already have a registered account, and the invitation will appear in their account',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
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
  final bool isArabic;

  const _CurrentUserTag({
    required this.isArabic,
  });

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
      child: Text(
        isArabic ? 'أنت' : 'You',
        style: const TextStyle(
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
  final bool isArabic;

  const _PendingInvitationsSection({
    required this.invitations,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(
          isArabic
              ? 'الدعوات المرسلة المعلّقة'
              : 'Pending Sent Invitations',
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
            child: Column(
              children: [
                Text(
                  isArabic
                      ? 'لا توجد دعوات مرسلة معلّقة حاليًا'
                      : 'There are no pending sent invitations',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'ستظهر هنا الدعوات التي أرسلتها ولم تُقبل بعد'
                      : 'Invitations you sent that have not yet been accepted will appear here',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                        Text(
                          isArabic
                              ? 'بانتظار قبول الدعوة'
                              : 'Waiting for invitation acceptance',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
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

class _IncomingInvitationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> invitations;
  final bool isArabic;
  final Future<void> Function(String invitationId) onAccept;
  final Future<void> Function(String invitationId) onReject;

  const _IncomingInvitationsSection({
    required this.invitations,
    required this.onAccept,
    required this.onReject,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(
          isArabic
              ? 'الدعوات الواردة'
              : 'Incoming Invitations',
        ),

        const SizedBox(height: AppSpacing.sm),

        if (invitations.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Text(
                  isArabic
                      ? 'لا توجد دعوات واردة حاليًا'
                      : 'There are no incoming invitations',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'ستظهر هنا دعوات الانضمام إلى العائلات'
                      : 'Family invitations will appear here',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...invitations.map((invitation) {
            final invitationId =
                invitation['id']?.toString() ?? '';

            final familyName =
                invitation['family_name']?.toString() ??
                    (isArabic ? 'العائلة' : 'the family');

            final invitedByName =
                invitation['invited_by_name']?.toString();
            final invitedByEmail =
                invitation['invited_by_email']?.toString();

            return Container(
              margin: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.family_restroom,
                        color: AppColors.primary,
                        size: 26,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text(
                              isArabic
                                  ? 'دعوة للانضمام إلى $familyName'
                                  : 'Invitation to join $familyName',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (invitedByName != null &&
                                invitedByName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                isArabic
                                    ? 'مرسلة من $invitedByName'
                                    : 'Sent by $invitedByName',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],

                            if (invitedByEmail != null &&
                                invitedByEmail.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                invitedByEmail,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: invitationId.isEmpty
                              ? null
                              : () => onReject(invitationId),
                          child: Text(
                            isArabic ? 'رفض' : 'Reject',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: invitationId.isEmpty
                              ? null
                              : () => onAccept(invitationId),
                          child: Text(
                            isArabic ? 'قبول' : 'Accept',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}