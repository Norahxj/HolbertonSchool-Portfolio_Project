class FamilyInvitation {
  final String id;
  final String invitedEmail;
  final String familyName;
  final String? invitedByName;
  final String? invitedByEmail;

  const FamilyInvitation({
    required this.id,
    required this.invitedEmail,
    required this.familyName,
    this.invitedByName,
    this.invitedByEmail,
  });

  factory FamilyInvitation.fromJson(Map<String, dynamic> json) {
    return FamilyInvitation(
      id: json['id']?.toString() ?? '',
      invitedEmail: json['invited_email']?.toString() ?? '',
      familyName: json['family_name']?.toString() ?? '',
      invitedByName: json['invited_by_name']?.toString(),
      invitedByEmail: json['invited_by_email']?.toString(),
    );
  }
}
