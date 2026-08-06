class FamilyGuardian {
  final String id;
  final String firstName;
  final String lastName;
  final String guardianType;

  const FamilyGuardian({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.guardianType,
  });

  String get fullName {
    return '$firstName $lastName'.trim();
  }

  factory FamilyGuardian.fromJson(Map<String, dynamic> json) {
    return FamilyGuardian(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      guardianType: json['guardian_type']?.toString() ?? '',
    );
  }
}
