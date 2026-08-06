import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import 'guardian_components.dart';

class IncomingInvitationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> invitations;
  final bool Function(String invitationId) isProcessingInvitation;
  final Future<void> Function(String invitationId) onAccept;
  final Future<void> Function(String invitationId) onReject;

  const IncomingInvitationsSection({
    super.key,
    required this.invitations,
    required this.isProcessingInvitation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FamilyFieldLabel(text: context.l10n.incomingInvitations),

        const SizedBox(height: AppSpacing.sm),

        if (invitations.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  context.l10n.noIncomingInvitations,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  context.l10n.incomingInvitationsDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...invitations.map((invitation) {
            final invitationId = invitation['id']?.toString() ?? '';

            final familyName =
                invitation['family_name']?.toString() ?? context.l10n.family;

            final invitedByName = invitation['invited_by_name']?.toString();

            final invitedByEmail = invitation['invited_by_email']?.toString();

            final isProcessing = isProcessingInvitation(invitationId);

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.family_restroom,
                        color: AppColors.primary,
                        size: 26,
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.invitationToJoinFamily(familyName),
                              textAlign: TextAlign.start,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),

                            if (invitedByName != null &&
                                invitedByName.trim().isNotEmpty) ...[
                              const SizedBox(height: 4),

                              Text(
                                context.l10n.invitationSentBy(invitedByName),
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],

                            if (invitedByEmail != null &&
                                invitedByEmail.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),

                              Text(
                                invitedByEmail,
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: invitationId.isEmpty || isProcessing
                              ? null
                              : () {
                                  onReject(invitationId);
                                },
                          child: Text(context.l10n.reject),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: invitationId.isEmpty || isProcessing
                              ? null
                              : () {
                                  onAccept(invitationId);
                                },
                          child: isProcessing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(context.l10n.accept),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
