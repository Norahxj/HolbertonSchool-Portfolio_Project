import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'guardian_components.dart';

class FamilyNameSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;

  const FamilyNameSection({
    super.key,
    required this.controller,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FamilyFieldLabel(
          text: context.l10n.familyName,
        ),

        const SizedBox(height: AppSpacing.sm),

        AppTextField(
          label: '',
          hint: context.l10n.familyName,
          icon: Icons.home_outlined,
          controller: controller,
        ),

        const SizedBox(height: AppSpacing.sm),

        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            onPressed: isSaving ? null : onSave,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.save_outlined,
                  ),
            label: Text(
              isSaving
                  ? context.l10n.saving
                  : context.l10n.saveFamilyName,
            ),
          ),
        ),
      ],
    );
  }
}