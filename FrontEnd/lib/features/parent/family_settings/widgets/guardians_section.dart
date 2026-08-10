import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../models/family_guardian.dart';
import '../utils/family_settings_localization.dart';
import 'guardian_components.dart';

class GuardiansSection extends StatelessWidget {
  final List<FamilyGuardian> guardians;
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
          for (final guardian in guardians)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
              child: GuardianCard(
                name: guardian.fullName,
                subtitle: guardian.guardianType.guardianTypeLabel(context),
                subtitleColor: guardian.id == currentUserId
                    ? const Color(0xFFC08A3E)
                    : AppColors.textSecondary,
                avatarColor: AppColors.primaryLight,
                iconColor: AppColors.primary,
                tag: guardian.id == currentUserId
                    ? const CurrentUserTag()
                    : const VerifiedTag(),
              ),
            ),
      ],
    );
  }
}
