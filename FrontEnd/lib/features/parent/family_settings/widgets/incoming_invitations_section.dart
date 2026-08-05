import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'guardian_components.dart';

class IncomingInvitationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> invitations;
  final bool isArabic;
  final Future<void> Function(String invitationId) onAccept;
  final Future<void> Function(String invitationId) onReject;

  const IncomingInvitationsSection({
    super.key,
    required this.invitations,
    required this.onAccept,
    required this.onReject,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FamilyFieldLabel(
          text: isArabic ? 'الدعوات الواردة' : 'Incoming Invitations',
        ),

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
                  isArabic
                      ? 'لا توجد دعوات واردة حاليًا'
                      : 'There are no incoming invitations',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isArabic
                      ? 'ستظهر هنا دعوات الانضمام إلى العائلات'
                      : 'Family invitations will appear here',
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
                invitation['family_name']?.toString() ??
                (isArabic ? 'العائلة' : 'the family');

            final invitedByName = invitation['invited_by_name']?.toString();
            final invitedByEmail = invitation['invited_by_email']?.toString();

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
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isArabic
                                  ? 'دعوة للانضمام إلى $familyName'
                                  : 'Invitation to join $familyName',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (invitedByName != null &&
                                invitedByName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                isArabic
                                    ? 'مرسلة من $invitedByName'
                                    : 'Sent by $invitedByName',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],

                            if (invitedByEmail != null &&
                                invitedByEmail.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                invitedByEmail,
                                textAlign: TextAlign.right,
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
                          onPressed: invitationId.isEmpty
                              ? null
                              : () => onReject(invitationId),
                          child: Text(isArabic ? 'رفض' : 'Reject'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: invitationId.isEmpty
                              ? null
                              : () => onAccept(invitationId),
                          child: Text(isArabic ? 'قبول' : 'Accept'),
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
