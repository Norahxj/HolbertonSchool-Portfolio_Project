import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../utils/family_settings_localization.dart';
import 'guardian_components.dart';

class GuardiansSection extends StatelessWidget {
  final List<Map<String, dynamic>> guardians;
  final String? currentUserId;

  const GuardiansSection({
    super.key,
    required this.guardians,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FamilyFieldLabel(text: context.l10n.guardians),

        const SizedBox(height: AppSpacing.sm),

        if (guardians.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(context.l10n.noGuardians, textAlign: TextAlign.center),
          )
        else
          ...guardians.map((guardian) {
            final guardianId = guardian['id']?.toString();

            final isCurrentUser = guardianId == currentUserId;

            final firstName = guardian['first_name']?.toString() ?? '';

            final lastName = guardian['last_name']?.toString() ?? '';

            final guardianType = guardian['guardian_type']?.toString() ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GuardianCard(
                name: '$firstName $lastName'.trim(),
                subtitle: guardianType.guardianTypeLabel(context),
                subtitleColor: isCurrentUser
                    ? const Color(0xFFC08A3E)
                    : AppColors.textSecondary,
                avatarColor: AppColors.primaryLight,
                iconColor: AppColors.primary,
                tag: isCurrentUser
                    ? const CurrentUserTag()
                    : const VerifiedTag(),
              ),
            );
          }),
      ],
    );
  }
}
