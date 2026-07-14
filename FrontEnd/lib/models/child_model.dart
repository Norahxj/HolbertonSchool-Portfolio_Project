class ChildModel {
  final String id;
  final String name;
  final String birthDate;
  final String? phone;
  final int age;
  final String accessCode;
  final String role;
  final int weeklyProgress;

  ChildModel({
    required this.id,
    required this.name,
    required this.birthDate,
    this.phone,
    required this.age,
    required this.accessCode,
    required this.role,
    required this.weeklyProgress,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'],
      name: json['name'],
      birthDate: json['birth_date'],
      phone: json['phone'],
      age: json['age'],
      accessCode: json['access_code'] ?? '',
      role: json['role'],
      weeklyProgress: (json['weekly_progress'] as num?)?.toInt() ?? 0,
    );
  }
}