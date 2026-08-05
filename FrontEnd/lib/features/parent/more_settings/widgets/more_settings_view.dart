import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/more_settings_controller.dart';
import 'logout_button.dart';
import 'profile_banner.dart';
import 'settings_card.dart';
import 'settings_error_state.dart';

class MoreSettingsView extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function() onReload;
  final VoidCallback onLanguageToggle;
  final VoidCallback onProfileTap;
  final VoidCallback onComingSoon;

  const MoreSettingsView({
    super.key,
    required this.isArabic,
    required this.onReload,
    required this.onLanguageToggle,
    required this.onProfileTap,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MoreSettingsController>();

    return Scaffold(
      body: Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: ScreenBackground(
          child: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: onReload,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: _buildContent(context, controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MoreSettingsController controller,
  ) {
    if (controller.isLoading) {
      return SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.errorMessage != null || controller.user == null) {
      return SettingsErrorState(isArabic: isArabic, onRetry: onReload);
    }

    final user = controller.user!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isArabic ? 'المزيد' : 'More',
          textAlign: TextAlign.center,
          style: AppTextStyles.arabicTitle,
        ),

        const SizedBox(height: AppSpacing.lg),

        ProfileBanner(user: user, isArabic: isArabic),

        const SizedBox(height: AppSpacing.lg),

        SettingsCard(
          isArabic: isArabic,
          onLanguageToggle: onLanguageToggle,
          onProfileTap: onProfileTap,
          onComingSoon: onComingSoon,
        ),

        const SizedBox(height: AppSpacing.xl),

        LogoutButton(isArabic: isArabic),

        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
