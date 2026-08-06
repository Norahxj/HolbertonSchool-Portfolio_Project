import 'family_guardian.dart';
import 'family_invitation.dart';

class FamilyDetails {
  final String name;
  final String? currentUserId;
  final List<FamilyGuardian> guardians;
  final List<FamilyInvitation> sentInvitations;

  const FamilyDetails({
    required this.name,
    required this.currentUserId,
    required this.guardians,
    required this.sentInvitations,
  });

  factory FamilyDetails.fromJson(Map<String, dynamic> json) {
    final guardiansData = json['guardians'] as List? ?? const [];

    final pendingInvitationsData =
        json['pending_invitations'] as List? ?? const [];

    return FamilyDetails(
      name: json['name']?.toString() ?? '',
      currentUserId: json['current_user_id']?.toString(),
      guardians: guardiansData.map((item) {
        return FamilyGuardian.fromJson(Map<String, dynamic>.from(item as Map));
      }).toList(),
      sentInvitations: pendingInvitationsData.map((item) {
        return FamilyInvitation.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList(),
    );
  }
}
