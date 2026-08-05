import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';

class InviteGuardianSection extends StatelessWidget {
  final bool isArabic;
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const InviteGuardianSection({
    super.key,
    required this.isArabic,
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
                  isArabic
                      ? 'دعوة ولي أمر آخر'
                      : 'Invite Another Guardian',
                  textAlign: TextAlign.right,
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
                    controller: controller,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: isArabic
                        ? TextAlign.right
                        : TextAlign.left,
                    textDirection: isArabic
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    decoration: InputDecoration(
                      hintText: isArabic
                          ? 'البريد الإلكتروني لولي الأمر'
                          : 'Guardian email address',
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
                ? (isArabic ? 'جارٍ الإرسال...' : 'Sending...')
                : (isArabic ? 'إرسال دعوة' : 'Send Invitation'),
            onPressed: isSending ? () {} : onSend,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            isArabic
                ? 'يجب أن يكون لدى ولي الأمر حساب مسجل مسبقًا، وستظهر الدعوة داخل حسابه'
                : 'The guardian must already have a registered account, and the invitation will appear in their account',
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