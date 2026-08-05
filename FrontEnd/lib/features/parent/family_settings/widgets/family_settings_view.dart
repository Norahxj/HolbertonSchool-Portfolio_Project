import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/family_settings_controller.dart';
import 'family_name_section.dart';
import 'guardians_section.dart';
import 'incoming_invitations_section.dart';
import 'invite_guardian_section.dart';
import 'pending_invitations_section.dart';

class FamilySettingsView extends StatelessWidget {
  final bool isArabic;
  final TextEditingController familyNameController;
  final TextEditingController inviteEmailController;
  final Future<void> Function() onReload;
  final Future<void> Function() onSaveFamilyName;
  final Future<void> Function() onSendInvitation;
  final Future<void> Function(String invitationId) onAcceptInvitation;
  final Future<void> Function(String invitationId) onRejectInvitation;
  final VoidCallback onBack;

  const FamilySettingsView({
    super.key,
    required this.isArabic,
    required this.familyNameController,
    required this.inviteEmailController,
    required this.onReload,
    required this.onSaveFamilyName,
    required this.onSendInvitation,
    required this.onAcceptInvitation,
    required this.onRejectInvitation,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<FamilySettingsController>();

    if (controller.isLoading) {
      return const Scaffold(
        body: ScreenBackground(
          child: SafeArea(child: Center(child: CircularProgressIndicator())),
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
                      onPressed: onReload,
                      child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
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
            onRefresh: onReload,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppPageHeader(
                    isArabic: isArabic,
                    title: isArabic ? 'إعدادات العائلة' : 'Family Settings',
                    onBack: onBack,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  FamilyNameSection(
                    isArabic: isArabic,
                    controller: familyNameController,
                    isSaving: controller.isSavingFamilyName,
                    onSave: onSaveFamilyName,
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
                    onAccept: onAcceptInvitation,
                    onReject: onRejectInvitation,
                    isArabic: isArabic,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  InviteGuardianSection(
                    isArabic: isArabic,
                    controller: inviteEmailController,
                    isSending: controller.isSendingInvitation,
                    onSend: onSendInvitation,
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
