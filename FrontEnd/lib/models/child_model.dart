class ChildModel {
  final String id;
  final String name;
  final String birthDate;
  final String? phone;
  final int age;
  final String accessCode;
  final String role;
  final int weeklyProgress;
  final int avatarIndex;

  ChildModel({
    required this.id,
    required this.name,
    required this.birthDate,
    this.phone,
    required this.age,
    required this.accessCode,
    required this.role,
    required this.weeklyProgress,
    required this.avatarIndex,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      birthDate: json['birth_date']?.toString() ?? '',
      phone: json['phone']?.toString(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      accessCode: json['access_code']?.toString() ?? '',
      role: json['role']?.toString() ?? 'child',
      weeklyProgress:
          (json['weekly_progress'] as num?)?.toInt() ?? 0,

      // Children created before this change will use
      // the pink girl avatar as a fallback.
      avatarIndex:
          (json['avatar_index'] as num?)?.toInt() ?? 3,
    );
  }
}