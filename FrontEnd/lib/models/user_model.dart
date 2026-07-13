class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String role;
  final String guardianType;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.role,
    required this.guardianType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      email: json['email'],
      role: json['role'],
      guardianType: json['guardian_type'],
    );
  }
}