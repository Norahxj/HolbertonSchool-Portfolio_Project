import 'package:flutter/material.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/screen_background.dart';
import '../family_settings/widgets/pending_invitations_section.dart';
import '../family_settings/widgets/incoming_invitations_section.dart';
import '../family_settings/widgets/invite_guardian_section.dart';
import 'package:provider/provider.dart';
import '../family_settings/controllers/family_settings_controller.dart';
import '../family_settings/widgets/family_name_section.dart';
import '../family_settings/widgets/guardians_section.dart';

class FamilySettingsScreen extends StatefulWidget {
  final bool isArabic;

  const FamilySettingsScreen({super.key, required this.isArabic});

  @override
  State<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {
  late final FamilySettingsController _controller;

  bool get isArabic => widget.isArabic;

  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController inviteEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = FamilySettingsController(isArabic: isArabic);

    _loadFamilyData();
  }

  @override
  void dispose() {
    _controller.dispose();
    familyNameController.dispose();
    inviteEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadFamilyData() async {
    await _controller.loadFamilyData();

    if (!mounted) {
      return;
    }

    familyNameController.text = _controller.displayFamilyName(
      _controller.originalFamilyName,
    );
  }

  Future<void> _acceptInvitation(String invitationId) async {
    final errorMessage = await _controller.acceptInvitation(invitationId);

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }

    _showMessage(
      isArabic
          ? 'تم قبول الدعوة والانضمام إلى العائلة'
          : 'Invitation accepted and joined the family',
    );
  }

  Future<void> _rejectInvitation(String invitationId) async {
    final errorMessage = await _controller.rejectInvitation(invitationId);

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }

    _showMessage(isArabic ? 'تم رفض الدعوة' : 'Invitation rejected');
  }

  Future<void> _saveFamilyName() async {
    final errorMessage = await _controller.saveFamilyName(
      familyNameController.text,
    );

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }

    familyNameController.text = _controller.displayFamilyName(
      _controller.originalFamilyName,
    );

    _showMessage(isArabic ? 'تم تحديث اسم العائلة' : 'Family name updated');
  }

  Future<void> _sendInvitation() async {
    final errorMessage = await _controller.sendInvitation(
      inviteEmailController.text,
    );

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }

    inviteEmailController.clear();

    _showMessage(
      isArabic ? 'تم إرسال الدعوة بنجاح' : 'Invitation sent successfully',
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Builder(
        builder: (context) {
          final controller = context.watch<FamilySettingsController>();

          if (controller.isLoading) {
            return const Scaffold(
              body: ScreenBackground(
                child: SafeArea(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }

          if (controller.pageError != null) {
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
                            controller.pageError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ElevatedButton(
                            onPressed: controller.loadFamilyData,
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
                  onRefresh: controller.loadFamilyData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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

                        FamilyNameSection(
                          isArabic: isArabic,
                          controller: familyNameController,
                          isSaving: controller.isSavingFamilyName,
                          onSave: _saveFamilyName,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        GuardiansSection(
                          isArabic: isArabic,
                          guardians: controller.guardians,
                          currentUserId: controller.currentUserId,
                          guardianTypeLabel: controller.guardianTypeLabel,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        PendingInvitationsSection(
                          invitations: controller.sentInvitations,
                          isArabic: isArabic,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        IncomingInvitationsSection(
                          invitations: controller.incomingInvitations,
                          onAccept: _acceptInvitation,
                          onReject: _rejectInvitation,
                          isArabic: isArabic,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        InviteGuardianSection(
                          isArabic: isArabic,
                          controller: inviteEmailController,
                          isSending: controller.isSendingInvitation,
                          onSend: _sendInvitation,
                        ),

                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
