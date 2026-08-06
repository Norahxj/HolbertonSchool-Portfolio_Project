import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import 'profile_field_label.dart';
import 'profile_read_only_field.dart';
import 'profile_text_field.dart';

class ProfileForm extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String guardianType;

  const ProfileForm({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.guardianType,
  });

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileFieldLabel(text: context.l10n.firstName),
          const SizedBox(height: AppSpacing.sm),
          ProfileTextField(
            controller: firstNameController,
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.givenName],
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileFieldLabel(text: context.l10n.lastName),
          const SizedBox(height: AppSpacing.sm),
          ProfileTextField(
            controller: lastNameController,
            icon: Icons.person_outline,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.familyName],
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileFieldLabel(text: context.l10n.email),
          const SizedBox(height: AppSpacing.sm),
          ProfileTextField(
            controller: emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileFieldLabel(text: context.l10n.phoneNumber),
          const SizedBox(height: AppSpacing.sm),
          ProfileTextField(
            controller: phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            autofillHints: const [AutofillHints.telephoneNumber],
          ),
          const SizedBox(height: AppSpacing.lg),
          ProfileFieldLabel(text: context.l10n.familyRelationship),
          const SizedBox(height: AppSpacing.sm),
          ProfileReadOnlyField(
            value: guardianType,
            icon: Icons.escalator_warning,
          ),
        ],
      ),
    );
  }
}
