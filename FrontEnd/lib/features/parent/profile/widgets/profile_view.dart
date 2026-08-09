import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/profile_controller.dart';
import '../utils/profile_localization.dart';
import 'profile_error_state.dart';
import 'profile_form.dart';

class ProfileView extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final Future<void> Function() onReload;
  final Future<void> Function() onSave;
  final VoidCallback onBack;

  const ProfileView({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.onReload,
    required this.onSave,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    final pageError =
        controller.pageBackendMessage ??
        controller.pageErrorCode?.localized(context);

    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: _buildContent(
            context,
            controller,
            pageError,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileController controller,
    String? pageError,
  ) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final user = controller.user;

    if (pageError != null || user == null) {
      return ProfileErrorState(
        message:
            pageError ??
            context.l10n.failedToLoadProfile,
        onRetry: onReload,
      );
    }

    final guardianType = guardianTypeLabel(
      context,
      user.guardianType,
    );

    return SingleChildScrollView(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPageHeader(
            title: context.l10n.profile,
            onBack: onBack,
          ),

          const SizedBox(height: AppSpacing.xl),

          const _ProfileAvatar(),

          const SizedBox(height: AppSpacing.xl),

          ProfileForm(
            firstNameController: firstNameController,
            lastNameController: lastNameController,
            emailController: emailController,
            phoneController: phoneController,
            guardianType: guardianType,
          ),

          const SizedBox(height: AppSpacing.xxl),

          AppButton(
            text: controller.isSaving
                ? context.l10n.saving
                : context.l10n.saveChanges,
            onPressed:
                controller.isSaving ? null : onSave,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.person,
          color: AppColors.primaryDark,
          size: 48,
        ),
      ),
    );
  }
}