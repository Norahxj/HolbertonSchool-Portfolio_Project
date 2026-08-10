import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/add_wishlist_controller.dart';

class AddWishlistView extends StatelessWidget {
  final TextEditingController nameController;
  final VoidCallback onBack;
  final Future<void> Function() onSubmit;

  const AddWishlistView({
    super.key,
    required this.nameController,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddWishlistController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppPageHeader(
                  title: context.l10n.addWishTitle,
                  onBack: onBack,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  context.l10n.chooseWishesCarefully,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.md),

                if (controller.isLoading)
                  const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: controller.hasReachedLimit
                            ? const Color(0xFFF9DEDE)
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        context.l10n.pendingWishesCount(
                          controller.pendingWishesCount,
                          AddWishlistController.maximumPendingWishes,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: controller.hasReachedLimit
                              ? AppColors.error
                              : AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),

                if (controller.errorCode != null) ...[
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    context.l10n.childWishlistLoadFailed,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),

                  TextButton(
                    onPressed: controller.loadCurrentWishes,
                    child: Text(
                      context.l10n.retry,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                _FieldLabel(
                  text: context.l10n.wishNameLabel,
                ),

                const SizedBox(height: AppSpacing.sm),

                _WishTextField(
                  controller: nameController,
                  hint: context.l10n.wishNameHint,
                  enabled: !controller.hasReachedLimit,
                ),

                const SizedBox(height: AppSpacing.lg),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                        size: 18,
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: Text(
                          context.l10n.wishlistLimitExplanation,
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        controller.isSaving ||
                            controller.isLoading ||
                            controller.hasReachedLimit
                        ? null
                        : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                          AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      disabledForegroundColor:
                          AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: controller.isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            controller.hasReachedLimit
                                ? context.l10n.maximumWishLimitReached
                                : context.l10n.saveWish,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _WishTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;

  const _WishTextField({
    required this.controller,
    required this.hint,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textAlign: TextAlign.start,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}