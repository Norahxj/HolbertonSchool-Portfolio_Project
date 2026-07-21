class AssignmentChildModel {
  final String id;
  final String name;
  final int age;

  AssignmentChildModel({
    required this.id,
    required this.name,
    required this.age,
  });

  factory AssignmentChildModel.fromJson(Map<String, dynamic> json) {
    return AssignmentChildModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }
}