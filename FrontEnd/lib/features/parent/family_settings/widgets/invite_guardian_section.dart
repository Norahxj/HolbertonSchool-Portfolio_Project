import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_button.dart';

class InviteGuardianSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const InviteGuardianSection({
    super.key,
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.group_outlined,
                color: AppColors.primaryDark,
                size: 20,
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  context.l10n.inviteAnotherGuardian,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.start,
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: context.l10n.guardianEmailAddress,
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
            text: isSending
                ? context.l10n.sending
                : context.l10n.sendInvitation,
            onPressed: isSending ? null : onSend,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            context.l10n.guardianInvitationExplanation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
